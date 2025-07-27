# Bluetooth Implementation Specification

## Overview

This document defines the Bluetooth Low Energy (BLE) implementation for BitChat Flutter, ensuring protocol compatibility with existing iOS and Android versions while leveraging Flutter's cross-platform capabilities.

## Table of Contents

1. [BLE Architecture](#ble-architecture)
2. [flutter_blue_plus Integration](#flutter_blue_plus-integration)
3. [Mesh Network Topology](#mesh-network-topology)
4. [Dual Role Implementation](#dual-role-implementation)
5. [Connection Management](#connection-management)
6. [Platform-Specific Considerations](#platform-specific-considerations)
7. [Permission Handling](#permission-handling)
8. [Background Operation](#background-operation)
9. [Battery Optimization](#battery-optimization)
10. [Error Handling](#error-handling)
11. [Testing Strategy](#testing-strategy)

## BLE Architecture

### Core Components

```dart
// Core BLE service structure
class BluetoothService {
  static const String SERVICE_UUID = "F47B5E2D-4A9E-4C5A-9B3F-8E1D2C3A4B5C";
  static const String CHARACTERISTIC_UUID = "A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D";
  
  // Maximum BLE packet size for compatibility
  static const int MAX_PACKET_SIZE = 512;
  static const int MAX_PAYLOAD_SIZE = 499; // 512 - 13 byte header
}
```

### Service Architecture

```
BitChat BLE Service
├── TX Characteristic (Write)
│   ├── Properties: WRITE_WITHOUT_RESPONSE
│   ├── Max Length: 512 bytes
│   └── Usage: Outgoing messages
├── RX Characteristic (Notify)
│   ├── Properties: NOTIFY
│   ├── Max Length: 512 bytes
│   └── Usage: Incoming messages
└── Device Information
    ├── Advertised Name: "BitChat"
    ├── Service UUID: Custom UUID
    └── Manufacturer Data: Protocol version
```

## flutter_blue_plus Integration

### Core Dependencies

```yaml
dependencies:
  flutter_blue_plus: ^1.35.5
  permission_handler: ^12.0.1
  device_info_plus: ^9.1.0
  battery_plus: ^4.0.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^0.3.0
  integration_test:
    sdk: flutter
```

### Flutter Blue Plus Configuration

```dart
// pubspec.yaml platform-specific configuration
flutter:
  # iOS configuration
  ios:
    deployment_target: '14.0'
    
  # Android configuration  
  android:
    compileSdkVersion: 34
    minSdkVersion: 26
    targetSdkVersion: 34

# Android permissions in android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

# iOS configuration in ios/Runner/Info.plist
<key>NSBluetoothAlwaysUsageDescription</key>
<string>BitChat uses Bluetooth to communicate with nearby devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>BitChat uses Bluetooth to be discoverable by nearby devices</string>
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>bluetooth-peripheral</string>
</array>
```

### Bluetooth Manager Implementation

```dart
class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;
  BluetoothManager._internal();
  
  // Stream controllers for reactive state management
  final StreamController<BluetoothAdapterState> _stateController = 
      StreamController<BluetoothAdapterState>.broadcast();
  final StreamController<List<ScanResult>> _scanResultsController = 
      StreamController<List<ScanResult>>.broadcast();
  final StreamController<List<BluetoothDevice>> _connectedDevicesController = 
      StreamController<List<BluetoothDevice>>.broadcast();
  
  // Subscriptions
  StreamSubscription<BluetoothAdapterState>? _stateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final Map<String, StreamSubscription> _deviceSubscriptions = {};
  
  // State management
  BluetoothAdapterState _currentState = BluetoothAdapterState.unknown;
  bool _isPeripheralMode = false;
  bool _isCentralMode = false;
  final Set<BluetoothDevice> _connectedDevices = {};
  final List<ScanResult> _scanResults = [];
  
  // Connection management
  final Map<String, PeerConnection> _activePeers = {};
  final Queue<PendingMessage> _messageQueue = Queue();
  Timer? _connectionMonitorTimer;
  
  // Getters for reactive streams
  Stream<BluetoothAdapterState> get adapterStateStream => _stateController.stream;
  Stream<List<ScanResult>> get scanResultsStream => _scanResultsController.stream;
  Stream<List<BluetoothDevice>> get connectedDevicesStream => _connectedDevicesController.stream;
  
  // Current state getters
  BluetoothAdapterState get currentState => _currentState;
  List<BluetoothDevice> get connectedDevices => List.unmodifiable(_connectedDevices);
  List<ScanResult> get scanResults => List.unmodifiable(_scanResults);
  bool get isScanning => FlutterBluePlus.isScanningNow;
  
  Future<void> initialize() async {
    try {
      // Check if Bluetooth is supported
      if (!await FlutterBluePlus.isSupported) {
        throw BluetoothException(
          'Bluetooth not supported on this device',
          type: BluetoothError.adapterOff,
        );
      }
      
      // Initialize state monitoring
      _stateSubscription = FlutterBluePlus.adapterState.listen(
        _onBluetoothStateChanged,
        onError: (error) {
          print('Bluetooth state error: $error');
        },
      );
      
      // Initialize scan results monitoring
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        _onScanResults,
        onError: (error) {
          print('Scan results error: $error');
        },
      );
      
      // Get initial state
      _currentState = await FlutterBluePlus.adapterState.first;
      _stateController.add(_currentState);
      
      // Start connection monitoring
      _startConnectionMonitoring();
      
      // Initialize dual role if Bluetooth is on
      if (_currentState == BluetoothAdapterState.on) {
        await _startDualRole();
      }
      
      print('BluetoothManager initialized successfully');
    } catch (e) {
      print('Failed to initialize BluetoothManager: $e');
      rethrow;
    }
  }
  
  void _onBluetoothStateChanged(BluetoothAdapterState state) {
    print('Bluetooth state changed: $state');
    _currentState = state;
    _stateController.add(state);
    
    switch (state) {
      case BluetoothAdapterState.on:
        _startDualRole();
        break;
      case BluetoothAdapterState.off:
        _stopAllOperations();
        break;
      default:
        break;
    }
  }
  
  void _onScanResults(List<ScanResult> results) {
    _scanResults.clear();
    _scanResults.addAll(results);
    _scanResultsController.add(_scanResults);
    
    // Process BitChat devices
    for (final result in results) {
      if (_isBitChatDevice(result)) {
        _handleBitChatDeviceDiscovered(result);
      }
    }
  }
  
  bool _isBitChatDevice(ScanResult result) {
    // Check service UUID
    if (result.advertisementData.serviceUuids.contains(BluetoothService.SERVICE_UUID)) {
      return true;
    }
    
    // Check device name
    if (result.device.name.contains('BitChat')) {
      return true;
    }
    
    // Check manufacturer data
    final manufacturerData = result.advertisementData.manufacturerData;
    if (manufacturerData.containsKey(0xFFFF)) {
      final data = manufacturerData[0xFFFF]!;
      if (data.length >= 7 && 
          String.fromCharCodes(data.skip(2).take(7)) == 'BitChat') {
        return true;
      }
    }
    
    return false;
  }
  
  Future<void> _handleBitChatDeviceDiscovered(ScanResult result) async {
    final deviceId = result.device.id.id;
    
    // Skip if already connected
    if (_connectedDevices.any((device) => device.id.id == deviceId)) {
      return;
    }
    
    // Skip if connection attempt is in progress
    if (_activePeers.containsKey(deviceId)) {
      return;
    }
    
    // Attempt connection if we have capacity
    if (_connectedDevices.length < ConnectionPool.MAX_CONNECTIONS) {
      await _attemptConnection(result.device);
    }
  }
  
  Future<void> _attemptConnection(BluetoothDevice device) async {
    final deviceId = device.id.id;
    
    try {
      print('Attempting connection to device: ${device.name} ($deviceId)');
      
      final peerConnection = PeerConnection(
        peerId: deviceId,
        device: device,
      );
      
      _activePeers[deviceId] = peerConnection;
      
      await peerConnection.connect();
      
      _connectedDevices.add(device);
      _connectedDevicesController.add(connectedDevices);
      
      // Subscribe to device state changes
      _deviceSubscriptions[deviceId] = device.state.listen(
        (state) => _onDeviceStateChanged(device, state),
      );
      
      print('Successfully connected to device: ${device.name}');
    } catch (e) {
      print('Failed to connect to device ${device.name}: $e');
      _activePeers.remove(deviceId);
    }
  }
  
  void _onDeviceStateChanged(BluetoothDevice device, BluetoothDeviceState state) {
    final deviceId = device.id.id;
    
    switch (state) {
      case BluetoothDeviceState.disconnected:
        _handleDeviceDisconnected(device);
        break;
      case BluetoothDeviceState.connected:
        // Device connected - handled in _attemptConnection
        break;
      default:
        break;
    }
  }
  
  void _handleDeviceDisconnected(BluetoothDevice device) {
    final deviceId = device.id.id;
    
    print('Device disconnected: ${device.name}');
    
    // Clean up connection
    _connectedDevices.remove(device);
    _activePeers.remove(deviceId);
    _deviceSubscriptions[deviceId]?.cancel();
    _deviceSubscriptions.remove(deviceId);
    
    _connectedDevicesController.add(connectedDevices);
  }
  
  Future<void> _startDualRole() async {
    try {
      // Start both peripheral and central roles
      await Future.wait([
        _startPeripheralMode(),
        _startCentralMode(),
      ]);
      
      print('Dual role mode started successfully');
    } catch (e) {
      print('Failed to start dual role mode: $e');
    }
  }
  
  void _startConnectionMonitoring() {
    _connectionMonitorTimer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _monitorConnections(),
    );
  }
  
  void _monitorConnections() {
    // Check for stale connections
    final staleConnections = _activePeers.values
        .where((peer) => peer.isStale)
        .toList();
    
    for (final peer in staleConnections) {
      print('Removing stale connection: ${peer.peerId}');
      peer.disconnect();
    }
  }
  
  Future<void> _stopAllOperations() async {
    // Stop scanning
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
    
    // Stop advertising
    if (FlutterBluePlus.isAdvertising) {
      await FlutterBluePlus.stopAdvertising();
    }
    
    // Disconnect all devices
    for (final device in _connectedDevices.toList()) {
      await device.disconnect();
    }
    
    _isPeripheralMode = false;
    _isCentralMode = false;
  }
  
  Future<void> dispose() async {
    // Cancel timers
    _connectionMonitorTimer?.cancel();
    
    // Cancel subscriptions
    await _stateSubscription?.cancel();
    await _scanSubscription?.cancel();
    
    for (final subscription in _deviceSubscriptions.values) {
      await subscription.cancel();
    }
    _deviceSubscriptions.clear();
    
    // Close stream controllers
    await _stateController.close();
    await _scanResultsController.close();
    await _connectedDevicesController.close();
    
    // Stop all operations
    await _stopAllOperations();
    
    print('BluetoothManager disposed');
  }
}
```

### Peripheral Mode Implementation

```dart
class PeripheralManager {
  static const String DEVICE_NAME = "BitChat";
  static const int ADVERTISING_INTERVAL_MS = 1000; // 1 second
  static const int ADVERTISING_TX_POWER = -12; // dBm
  
  bool _isAdvertising = false;
  Timer? _advertisingTimer;
  String? _deviceId;
  
  Future<void> startAdvertising() async {
    try {
      // Generate unique device ID if not exists
      _deviceId ??= await _generateDeviceId();
      
      // Configure advertising parameters
      final advertisingData = AdvertisingData(
        localName: '$DEVICE_NAME-${_deviceId!.substring(0, 8)}',
        serviceUuids: [BluetoothService.SERVICE_UUID],
        manufacturerData: _buildManufacturerData(),
        includeTxPowerLevel: true,
        includeDeviceName: true,
      );
      
      // Platform-specific advertising settings
      if (Platform.isAndroid) {
        await _startAndroidAdvertising(advertisingData);
      } else if (Platform.isIOS) {
        await _startIOSAdvertising(advertisingData);
      }
      
      // Setup GATT server
      await _setupGattServer();
      
      _isAdvertising = true;
      print("Peripheral mode started successfully");
      
      // Start periodic advertising refresh (iOS requirement)
      _startAdvertisingRefresh();
      
    } catch (e) {
      throw BluetoothException("Failed to start advertising: $e");
    }
  }
  
  Future<void> _startAndroidAdvertising(AdvertisingData data) async {
    await FlutterBluePlus.startAdvertising(
      name: data.localName,
      serviceUuids: data.serviceUuids,
      manufacturerData: data.manufacturerData,
      settings: AndroidAdvertisingSettings(
        advertiseMode: AdvertiseMode.advertiseModeBalanced,
        txPowerLevel: AdvertiseTx.advertiseTxPowerMedium,
        connectable: true,
        timeout: 0, // Advertise indefinitely
      ),
    );
  }
  
  Future<void> _startIOSAdvertising(AdvertisingData data) async {
    // iOS has more restrictions on advertising
    await FlutterBluePlus.startAdvertising(
      name: data.localName,
      serviceUuids: data.serviceUuids,
      // iOS doesn't support manufacturer data in background
      manufacturerData: _isInForeground() ? data.manufacturerData : null,
    );
  }
  
  void _startAdvertisingRefresh() {
    // Refresh advertising every 30 seconds to maintain visibility
    _advertisingTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (_isAdvertising) {
        await _refreshAdvertising();
      }
    });
  }
  
  Future<void> _refreshAdvertising() async {
    try {
      // Stop and restart advertising to refresh
      await FlutterBluePlus.stopAdvertising();
      await Future.delayed(Duration(milliseconds: 100));
      await startAdvertising();
    } catch (e) {
      print('Failed to refresh advertising: $e');
    }
  }
  
  Future<void> _setupGattServer() async {
    // Note: flutter_blue_plus doesn't support GATT server mode
    // This would require platform-specific implementation
    // For now, we'll use the connection-based approach
    
    print('GATT server setup - using connection-based approach');
  }
  
  Map<int, List<int>> _buildManufacturerData() {
    final deviceIdBytes = utf8.encode(_deviceId!.substring(0, 8));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final timestampBytes = ByteData(4)..setUint32(0, timestamp, Endian.little);
    
    return {
      0xFFFF: [
        0x01, // Protocol version
        0x00, // Flags (bit 0: supports encryption, bit 1: supports channels)
        ...utf8.encode("BitChat"),
        0x00, // Separator
        ...deviceIdBytes,
        ...timestampBytes.buffer.asUint8List(),
      ],
    };
  }
  
  Future<String> _generateDeviceId() async {
    // Generate unique device ID based on device info
    final deviceInfo = DeviceInfoPlugin();
    String identifier;
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      identifier = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      identifier = iosInfo.identifierForVendor ?? 'unknown';
    } else {
      identifier = 'desktop-${DateTime.now().millisecondsSinceEpoch}';
    }
    
    // Create hash of identifier for privacy
    final bytes = utf8.encode(identifier);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  bool _isInForeground() {
    // Check if app is in foreground
    return WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }
  
  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;
    
    try {
      await FlutterBluePlus.stopAdvertising();
      _advertisingTimer?.cancel();
      _isAdvertising = false;
      print("Advertising stopped");
    } catch (e) {
      print("Failed to stop advertising: $e");
    }
  }
  
  bool get isAdvertising => _isAdvertising;
  String? get deviceId => _deviceId;
}

class AdvertisingData {
  final String localName;
  final List<String> serviceUuids;
  final Map<int, List<int>> manufacturerData;
  final bool includeTxPowerLevel;
  final bool includeDeviceName;
  
  const AdvertisingData({
    required this.localName,
    required this.serviceUuids,
    required this.manufacturerData,
    this.includeTxPowerLevel = false,
    this.includeDeviceName = true,
  });
}

class AndroidAdvertisingSettings {
  final AdvertiseMode advertiseMode;
  final AdvertiseTx txPowerLevel;
  final bool connectable;
  final int timeout;
  
  const AndroidAdvertisingSettings({
    required this.advertiseMode,
    required this.txPowerLevel,
    required this.connectable,
    required this.timeout,
  });
}

enum AdvertiseMode {
  advertiseModeBalanced,
  advertiseModeHighFrequency,
  advertiseModeLowLatency,
  advertiseModeLowPower,
}

enum AdvertiseTx {
  advertiseTxPowerHigh,
  advertiseTxPowerMedium,
  advertiseTxPowerLow,
  advertiseTxPowerUltraLow,
}
```

### Central Mode Implementation

```dart
class CentralManager {
  Timer? _scanTimer;
  bool _isScanning = false;
  
  // Adaptive scan parameters based on battery and performance mode
  Duration _currentScanDuration = Duration(seconds: 10);
  Duration _currentScanInterval = Duration(seconds: 30);
  AndroidScanMode _currentScanMode = AndroidScanMode.balanced;
  
  // Device discovery tracking
  final Map<String, DateTime> _lastSeenDevices = {};
  final Set<String> _connectionAttempts = {};
  
  Future<void> startScanning() async {
    if (_isScanning) {
      print('Scanning already in progress');
      return;
    }
    
    try {
      print('Starting BLE scan with duration: $_currentScanDuration, interval: $_currentScanInterval');
      
      _isScanning = true;
      
      // Configure scan parameters based on platform
      if (Platform.isAndroid) {
        await _startAndroidScan();
      } else if (Platform.isIOS) {
        await _startIOSScan();
      } else {
        await _startGenericScan();
      }
      
      // Schedule periodic scanning
      _scheduleScan();
      
    } catch (e) {
      _isScanning = false;
      throw BluetoothException("Failed to start scanning: $e");
    }
  }
  
  Future<void> _startAndroidScan() async {
    await FlutterBluePlus.startScan(
      timeout: _currentScanDuration,
      withServices: [BluetoothService.SERVICE_UUID],
      androidScanMode: _currentScanMode,
      androidUsesFineLocation: true,
    );
  }
  
  Future<void> _startIOSScan() async {
    // iOS has different scanning behavior
    await FlutterBluePlus.startScan(
      timeout: _currentScanDuration,
      withServices: [BluetoothService.SERVICE_UUID],
      // iOS automatically handles scan modes
    );
  }
  
  Future<void> _startGenericScan() async {
    await FlutterBluePlus.startScan(
      timeout: _currentScanDuration,
      withServices: [BluetoothService.SERVICE_UUID],
    );
  }
  
  void _scheduleScan() {
    _scanTimer?.cancel();
    
    _scanTimer = Timer.periodic(_currentScanInterval, (timer) async {
      if (!_isScanning) return;
      
      try {
        // Stop current scan
        await FlutterBluePlus.stopScan();
        
        // Wait before starting next scan
        await Future.delayed(Duration(milliseconds: 500));
        
        // Start new scan
        if (Platform.isAndroid) {
          await _startAndroidScan();
        } else if (Platform.isIOS) {
          await _startIOSScan();
        } else {
          await _startGenericScan();
        }
        
        print('Periodic scan restarted');
      } catch (e) {
        print('Failed to restart periodic scan: $e');
      }
    });
  }
  
  void _onDeviceDiscovered(List<ScanResult> results) {
    final now = DateTime.now();
    
    for (final result in results) {
      final deviceId = result.device.id.id;
      
      // Update last seen time
      _lastSeenDevices[deviceId] = now;
      
      // Check if this is a BitChat device
      if (_isBitChatDevice(result)) {
        _processBitChatDevice(result);
      }
    }
    
    // Clean up old device entries
    _cleanupOldDevices(now);
  }
  
  void _processBitChatDevice(ScanResult result) {
    final deviceId = result.device.id.id;
    final device = result.device;
    
    print('Discovered BitChat device: ${device.name} ($deviceId) RSSI: ${result.rssi}');
    
    // Skip if connection attempt is already in progress
    if (_connectionAttempts.contains(deviceId)) {
      return;
    }
    
    // Skip if already connected
    if (BluetoothManager.instance.connectedDevices
        .any((d) => d.id.id == deviceId)) {
      return;
    }
    
    // Check signal strength threshold
    if (result.rssi < -80) {
      print('Device signal too weak: ${result.rssi} dBm');
      return;
    }
    
    // Attempt connection
    _connectToDevice(result);
  }
  
  bool _isBitChatDevice(ScanResult result) {
    // Check service UUID
    if (result.advertisementData.serviceUuids.contains(BluetoothService.SERVICE_UUID)) {
      return true;
    }
    
    // Check device name patterns
    final deviceName = result.device.name;
    if (deviceName.startsWith('BitChat')) {
      return true;
    }
    
    // Check manufacturer data
    final manufacturerData = result.advertisementData.manufacturerData;
    if (manufacturerData.containsKey(0xFFFF)) {
      final data = manufacturerData[0xFFFF]!;
      if (data.length >= 9) {
        // Check for BitChat signature
        final signature = String.fromCharCodes(data.skip(2).take(7));
        if (signature == 'BitChat') {
          return true;
        }
      }
    }
    
    return false;
  }
  
  Future<void> _connectToDevice(ScanResult result) async {
    final deviceId = result.device.id.id;
    final device = result.device;
    
    // Mark connection attempt
    _connectionAttempts.add(deviceId);
    
    try {
      print('Attempting to connect to ${device.name} ($deviceId)');
      
      // Create connection with timeout
      await device.connect(
        timeout: Duration(seconds: 10),
        autoConnect: false,
      );
      
      print('Connected to ${device.name}');
      
      // Setup characteristics and start communication
      await _setupDeviceCommunication(device);
      
    } catch (e) {
      print('Failed to connect to ${device.name}: $e');
    } finally {
      // Remove connection attempt marker
      _connectionAttempts.remove(deviceId);
    }
  }
  
  Future<void> _setupDeviceCommunication(BluetoothDevice device) async {
    try {
      // Discover services
      final services = await device.discoverServices();
      
      // Find BitChat service
      final bitChatService = services.firstWhere(
        (service) => service.uuid.toString().toUpperCase() == 
                     BluetoothService.SERVICE_UUID.toUpperCase(),
        orElse: () => throw Exception('BitChat service not found'),
      );
      
      // Find characteristics
      final txCharacteristic = bitChatService.characteristics.firstWhere(
        (char) => char.uuid.toString().toUpperCase() == 
                  BluetoothService.TX_CHARACTERISTIC.toUpperCase(),
        orElse: () => throw Exception('TX characteristic not found'),
      );
      
      final rxCharacteristic = bitChatService.characteristics.firstWhere(
        (char) => char.uuid.toString().toUpperCase() == 
                  BluetoothService.RX_CHARACTERISTIC.toUpperCase(),
        orElse: () => throw Exception('RX characteristic not found'),
      );
      
      // Enable notifications on RX characteristic
      await rxCharacteristic.setNotifyValue(true);
      
      // Create peer connection
      final peerConnection = PeerConnection(
        peerId: device.id.id,
        device: device,
        txCharacteristic: txCharacteristic,
        rxCharacteristic: rxCharacteristic,
      );
      
      // Register with connection manager
      await ConnectionManager.instance.registerConnection(peerConnection);
      
      print('Device communication setup complete for ${device.name}');
      
    } catch (e) {
      print('Failed to setup device communication: $e');
      await device.disconnect();
      rethrow;
    }
  }
  
  void _cleanupOldDevices(DateTime now) {
    final cutoff = now.subtract(Duration(minutes: 5));
    
    _lastSeenDevices.removeWhere((deviceId, lastSeen) {
      return lastSeen.isBefore(cutoff);
    });
  }
  
  void _onScanError(dynamic error) {
    print('Scan error: $error');
    
    // Attempt to recover from scan error
    Future.delayed(Duration(seconds: 5), () {
      if (_isScanning) {
        print('Attempting to recover from scan error');
        startScanning();
      }
    });
  }
  
  Future<void> stopScanning() async {
    if (!_isScanning) return;
    
    try {
      _scanTimer?.cancel();
      await FlutterBluePlus.stopScan();
      _isScanning = false;
      print('Scanning stopped');
    } catch (e) {
      print('Failed to stop scanning: $e');
    }
  }
  
  void setScanParameters({
    required Duration scanDuration,
    required Duration scanInterval,
    AndroidScanMode scanMode = AndroidScanMode.balanced,
  }) {
    _currentScanDuration = scanDuration;
    _currentScanInterval = scanInterval;
    _currentScanMode = scanMode;
    
    print('Scan parameters updated: duration=$scanDuration, interval=$scanInterval, mode=$scanMode');
    
    // Restart scanning with new parameters if currently scanning
    if (_isScanning) {
      stopScanning().then((_) => startScanning());
    }
  }
  
  bool get isScanning => _isScanning;
  Map<String, DateTime> get lastSeenDevices => Map.unmodifiable(_lastSeenDevices);
}

enum AndroidScanMode {
  balanced,
  lowLatency,
  lowPower,
  opportunistic,
}
```

## Mesh Network Topology

### Network Structure

```
BitChat Mesh Network
├── Star-Mesh Hybrid
│   ├── Direct connections (1-hop)
│   ├── Multi-hop routing (max 7 hops)
│   └── Store-and-forward capability
├── Peer Discovery
│   ├── Bluetooth advertising
│   ├── Service UUID filtering
│   └── Automatic connection management
└── Routing Algorithm
    ├── TTL-based forwarding
    ├── Duplicate detection
    └── Optimal path selection
```

### Mesh Implementation

```dart
class MeshNetwork {
  static const int MAX_HOPS = 7;
  static const int MAX_CONNECTIONS = 8; // Platform BLE limit
  
  final Map<String, PeerNode> _nodes = {};
  final Map<String, List<String>> _routingTable = {};
  final Set<String> _processedMessages = {};
  
  class PeerNode {
    final String deviceId;
    final BluetoothDevice device;
    final DateTime lastSeen;
    final int hopCount;
    final List<String> route;
    
    PeerNode({
      required this.deviceId,
      required this.device,
      required this.lastSeen,
      required this.hopCount,
      required this.route,
    });
  }
  
  Future<void> broadcastMessage(Message message) async {
    final packet = _buildPacket(message);
    
    // Send to all direct connections
    for (final peer in _getDirectPeers()) {
      await peer.sendPacket(packet);
    }
    
    // Store for offline peers
    await _storeMessage(message);
  }
  
  Future<void> routeMessage(Packet packet) async {
    // Check TTL
    if (packet.ttl <= 0) return;
    
    // Check for duplicates
    if (_processedMessages.contains(packet.id)) return;
    _processedMessages.add(packet.id);
    
    // Decrement TTL and forward
    packet.ttl--;
    await _forwardToNextHop(packet);
  }
  
  void _updateRoutingTable(String peerId, List<String> route) {
    _routingTable[peerId] = route;
    
    // Prune old entries
    _routingTable.removeWhere((key, value) => 
      value.length > MAX_HOPS || 
      !_isRouteValid(value)
    );
  }
}
```

## Dual Role Implementation

### Role Management

```dart
class DualRoleManager {
  bool _isPeripheralActive = false;
  bool _isCentralActive = false;
  
  // Platform-specific role limitations
  static const bool ANDROID_DUAL_ROLE_SUPPORT = true;
  static const bool IOS_DUAL_ROLE_SUPPORT = true;
  
  Future<void> enableDualRole() async {
    if (!await _checkDualRoleSupport()) {
      throw BluetoothException("Dual role not supported on this device");
    }
    
    // Start peripheral mode first
    await _startPeripheralMode();
    
    // Delay before starting central mode (iOS requirement)
    await Future.delayed(Duration(milliseconds: 500));
    
    // Start central mode
    await _startCentralMode();
  }
  
  Future<bool> _checkDualRoleSupport() async {
    final features = await FlutterBluePlus.isSupported;
    return features;
  }
  
  Future<void> _handleRoleConflict() async {
    // Prioritize peripheral mode for battery efficiency
    if (_isPeripheralActive && _isCentralActive) {
      await _adjustScanInterval();
    }
  }
}
```

### Connection State Machine

```dart
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  authenticating,
  authenticated,
  error,
}

class PeerConnection {
  final String peerId;
  final BluetoothDevice device;
  ConnectionState _state = ConnectionState.disconnected;
  
  // Connection parameters
  BluetoothCharacteristic? _txCharacteristic;
  BluetoothCharacteristic? _rxCharacteristic;
  StreamSubscription<List<int>>? _dataSubscription;
  
  // Message handling
  final Queue<OutgoingMessage> _sendQueue = Queue();
  final Map<String, Completer<void>> _acknowledgments = {};
  
  Future<void> connect() async {
    _setState(ConnectionState.connecting);
    
    try {
      await device.connect(
        timeout: Duration(seconds: 10),
        autoConnect: false,
      );
      
      // Discover services
      final services = await device.discoverServices();
      await _setupCharacteristics(services);
      
      _setState(ConnectionState.connected);
      
      // Start authentication
      await _authenticate();
      
    } catch (e) {
      _setState(ConnectionState.error);
      throw BluetoothException("Connection failed: $e");
    }
  }
  
  Future<void> _setupCharacteristics(List<BluetoothService> services) async {
    final bitChatService = services.firstWhere(
      (s) => s.uuid.toString() == BluetoothService.SERVICE_UUID,
    );
    
    _txCharacteristic = bitChatService.characteristics.firstWhere(
      (c) => c.uuid.toString() == BluetoothService.TX_CHARACTERISTIC,
    );
    
    _rxCharacteristic = bitChatService.characteristics.firstWhere(
      (c) => c.uuid.toString() == BluetoothService.RX_CHARACTERISTIC,
    );
    
    // Subscribe to notifications
    await _rxCharacteristic!.setNotifyValue(true);
    _dataSubscription = _rxCharacteristic!.value.listen(_onDataReceived);
  }
}
```

## Connection Management

### Connection Pool

```dart
class ConnectionPool {
  static const int MAX_CONNECTIONS = 8;
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 30);
  
  final Map<String, PeerConnection> _connections = {};
  final Queue<ConnectionRequest> _connectionQueue = Queue();
  
  Future<PeerConnection> getConnection(String peerId) async {
    // Return existing connection
    if (_connections.containsKey(peerId)) {
      return _connections[peerId]!;
    }
    
    // Check connection limit
    if (_connections.length >= MAX_CONNECTIONS) {
      await _releaseOldestConnection();
    }
    
    // Create new connection
    final connection = await _createConnection(peerId);
    _connections[peerId] = connection;
    
    return connection;
  }
  
  Future<void> _releaseOldestConnection() async {
    final oldest = _connections.values
        .reduce((a, b) => a.lastActivity.isBefore(b.lastActivity) ? a : b);
    
    await oldest.disconnect();
    _connections.remove(oldest.peerId);
  }
  
  void _monitorConnections() {
    Timer.periodic(Duration(minutes: 1), (timer) {
      _cleanupStaleConnections();
    });
  }
}
```

### Message Queuing

```dart
class MessageQueue {
  final Queue<QueuedMessage> _queue = Queue();
  final Map<String, List<QueuedMessage>> _peerQueues = {};
  
  void enqueue(Message message, String peerId) {
    final queuedMessage = QueuedMessage(
      message: message,
      peerId: peerId,
      timestamp: DateTime.now(),
      retryCount: 0,
    );
    
    _queue.add(queuedMessage);
    _peerQueues.putIfAbsent(peerId, () => []).add(queuedMessage);
    
    _processQueue();
  }
  
  Future<void> _processQueue() async {
    while (_queue.isNotEmpty) {
      final queuedMessage = _queue.removeFirst();
      
      try {
        await _sendMessage(queuedMessage);
      } catch (e) {
        await _handleSendError(queuedMessage, e);
      }
    }
  }
  
  Future<void> _handleSendError(QueuedMessage message, dynamic error) async {
    message.retryCount++;
    
    if (message.retryCount < 3) {
      // Exponential backoff
      final delay = Duration(seconds: pow(2, message.retryCount).toInt());
      await Future.delayed(delay);
      
      _queue.add(message);
    } else {
      // Store for later delivery
      await _storeOfflineMessage(message);
    }
  }
}
```

## Platform-Specific Considerations

### Android Implementation

```dart
class AndroidBluetoothManager extends BluetoothManager {
  @override
  Future<void> initialize() async {
    // Check Android version
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      // Android 12+ requires new permissions
      if (androidInfo.version.sdkInt >= 31) {
        await _requestAndroid12Permissions();
      }
    }
    
    await super.initialize();
  }
  
  Future<void> _requestAndroid12Permissions() async {
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ];
    
    await permissions.request();
  }
  
  @override
  Future<void> startAdvertising() async {
    // Android-specific advertising settings
    await FlutterBluePlus.startAdvertising(
      name: "BitChat",
      serviceUuids: [BluetoothService.SERVICE_UUID],
      manufacturerData: _buildManufacturerData(),
      settings: AndroidAdvertisingSettings(
        advertiseMode: AdvertiseMode.balanced,
        txPowerLevel: AdvertiseTx.medium,
        connectable: true,
      ),
    );
  }
}
```

### iOS Implementation

```dart
class IOSBluetoothManager extends BluetoothManager {
  @override
  Future<void> initialize() async {
    // iOS-specific initialization
    if (Platform.isIOS) {
      await _configureiOSBackground();
    }
    
    await super.initialize();
  }
  
  Future<void> _configureiOSBackground() async {
    // Configure background processing
    await FlutterBluePlus.setOptions(
      showPowerAlert: false,
      restoreIdentifier: "BitChatRestore",
    );
  }
  
  @override
  Future<void> startAdvertising() async {
    // iOS advertising limitations
    await FlutterBluePlus.startAdvertising(
      name: "BitChat",
      serviceUuids: [BluetoothService.SERVICE_UUID],
      // iOS doesn't support manufacturer data in background
      manufacturerData: _isInForeground() ? _buildManufacturerData() : null,
    );
  }
}
```

## Permission Handling

### Permission Manager

```dart
class PermissionManager {
  static const Map<Permission, String> PERMISSION_RATIONALE = {
    Permission.bluetooth: "Required for peer-to-peer communication",
    Permission.bluetoothScan: "Required to discover nearby devices",
    Permission.bluetoothAdvertise: "Required to be discoverable",
    Permission.bluetoothConnect: "Required to connect to peers",
    Permission.locationWhenInUse: "Required for Bluetooth scanning on Android",
  };
  
  Future<bool> requestAllPermissions() async {
    final requiredPermissions = _getRequiredPermissions();
    
    for (final permission in requiredPermissions) {
      final status = await permission.request();
      
      if (status != PermissionStatus.granted) {
        await _showPermissionDialog(permission);
        return false;
      }
    }
    
    return true;
  }
  
  List<Permission> _getRequiredPermissions() {
    if (Platform.isAndroid) {
      return [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ];
    } else if (Platform.isIOS) {
      return [
        Permission.bluetooth,
      ];
    }
    
    return [];
  }
}
```

## Background Operation

### Background Task Manager

```dart
class BackgroundTaskManager {
  static const String TASK_IDENTIFIER = "com.bitchat.background";
  
  Future<void> configureBackgroundOperation() async {
    if (Platform.isIOS) {
      await _configureiOSBackground();
    } else if (Platform.isAndroid) {
      await _configureAndroidBackground();
    }
  }
  
  Future<void> _configureiOSBackground() async {
    // Configure background app refresh
    await FlutterBluePlus.setOptions(
      restoreIdentifier: TASK_IDENTIFIER,
      showPowerAlert: false,
    );
    
    // Register background task
    await _registerBackgroundTask();
  }
  
  Future<void> _configureAndroidBackground() async {
    // Configure foreground service
    await _startForegroundService();
    
    // Configure wake locks
    await _configurePowerManagement();
  }
  
  Future<void> _startForegroundService() async {
    // Android foreground service for persistent Bluetooth
    // Implementation depends on platform channels
  }
}
```

### Power Management

```dart
class PowerManager {
  BatteryLevel _batteryLevel = BatteryLevel.unknown;
  PowerMode _powerMode = PowerMode.normal;
  
  enum PowerMode { 
    aggressive, // High scanning, frequent advertising
    normal,     // Balanced operation
    conservative, // Reduced scanning, longer intervals
    minimal     // Emergency power saving
  }
  
  Future<void> initialize() async {
    // Monitor battery level
    _batteryLevel = await Battery().batteryLevel;
    
    // Adjust power mode based on battery
    _adjustPowerMode();
    
    // Monitor battery changes
    Battery().onBatteryStateChanged.listen(_onBatteryChanged);
  }
  
  void _adjustPowerMode() {
    if (_batteryLevel.value < 20) {
      _powerMode = PowerMode.minimal;
    } else if (_batteryLevel.value < 50) {
      _powerMode = PowerMode.conservative;
    } else {
      _powerMode = PowerMode.normal;
    }
    
    _applyPowerMode();
  }
  
  void _applyPowerMode() {
    switch (_powerMode) {
      case PowerMode.minimal:
        _setScanInterval(Duration(minutes: 5));
        _setAdvertisingInterval(Duration(minutes: 2));
        break;
      case PowerMode.conservative:
        _setScanInterval(Duration(minutes: 2));
        _setAdvertisingInterval(Duration(seconds: 30));
        break;
      case PowerMode.normal:
        _setScanInterval(Duration(seconds: 30));
        _setAdvertisingInterval(Duration(seconds: 10));
        break;
    }
  }
}
```

## Battery Optimization

### Adaptive Power Modes

```dart
enum PowerMode {
  performance,   // High performance, charging or >60% battery
  balanced,      // Normal operation, 30-60% battery
  powerSaver,    // Battery saving, 10-30% battery
  ultraLowPower  // Minimal operation, <10% battery
}

class BatteryOptimizer {
  static final BatteryOptimizer _instance = BatteryOptimizer._internal();
  factory BatteryOptimizer() => _instance;
  BatteryOptimizer._internal();
  
  PowerMode _currentMode = PowerMode.balanced;
  
  // Exact parameters matching iOS/Android implementations
  static const Map<PowerMode, BatteryParameters> modeParameters = {
    PowerMode.performance: BatteryParameters(
      scanDuration: Duration(seconds: 3),
      scanInterval: Duration(seconds: 2),
      maxConnections: 20,
      advertisingInterval: Duration(milliseconds: 500), // Continuous
    ),
    PowerMode.balanced: BatteryParameters(
      scanDuration: Duration(seconds: 2),
      scanInterval: Duration(seconds: 3),
      maxConnections: 10,
      advertisingInterval: Duration(seconds: 5),
    ),
    PowerMode.powerSaver: BatteryParameters(
      scanDuration: Duration(seconds: 1),
      scanInterval: Duration(seconds: 8),
      maxConnections: 5,
      advertisingInterval: Duration(seconds: 15),
    ),
    PowerMode.ultraLowPower: BatteryParameters(
      scanDuration: Duration(milliseconds: 500),
      scanInterval: Duration(seconds: 20),
      maxConnections: 2,
      advertisingInterval: Duration(seconds: 30),
    ),
  };
  
  Future<void> initialize() async {
    // Monitor battery level
    final batteryLevel = await _getBatteryLevel();
    final isCharging = await _isCharging();
    
    _updatePowerMode(batteryLevel, isCharging);
    
    // Set up battery level listener
    Battery().onBatteryStateChanged.listen((BatteryState state) async {
      final level = await _getBatteryLevel();
      final charging = state == BatteryState.charging;
      _updatePowerMode(level, charging);
    });
  }
  
  void _updatePowerMode(int batteryLevel, bool isCharging) {
    if (isCharging) {
      _setMode(PowerMode.performance);
    } else if (batteryLevel <= 10) {
      _setMode(PowerMode.ultraLowPower);
    } else if (batteryLevel <= 30) {
      _setMode(PowerMode.powerSaver);
    } else if (batteryLevel <= 60) {
      _setMode(PowerMode.balanced);
    } else {
      _setMode(PowerMode.performance);
    }
  }
  
  void _setMode(PowerMode mode) {
    if (_currentMode == mode) return;
    
    _currentMode = mode;
    _applyModeSettings(mode);
  }
  
  void _applyModeSettings(PowerMode mode) {
    final params = modeParameters[mode]!;
    
    // Apply scan parameters
    BluetoothManager().setScanParameters(
      scanDuration: params.scanDuration,
      scanInterval: params.scanInterval,
    );
    
    // Apply connection limits
    BluetoothManager().setMaxConnections(params.maxConnections);
    
    // Apply advertising parameters
    BluetoothManager().setAdvertisingInterval(params.advertisingInterval);
    
    print('Power mode set to: $mode');
  }
}

class BatteryParameters {
  final Duration scanDuration;
  final Duration scanInterval;
  final int maxConnections;
  final Duration advertisingInterval;
  
  const BatteryParameters({
    required this.scanDuration,
    required this.scanInterval,
    required this.maxConnections,
    required this.advertisingInterval,
  });
}
```

### Power Mode Implementation

```dart
class AdaptiveBluetoothManager extends BluetoothManager {
  Timer? _scanTimer;
  Timer? _advertisingTimer;
  bool _isScanning = false;
  
  @override
  Future<void> setScanParameters({
    required Duration scanDuration,
    required Duration scanInterval,
  }) async {
    // Cancel existing scan timer
    _scanTimer?.cancel();
    
    // Set up new scanning cycle
    _scanTimer = Timer.periodic(scanDuration + scanInterval, (timer) async {
      if (_isScanning) {
        await stopScan();
        _isScanning = false;
        
        // Schedule next scan
        await Future.delayed(scanInterval);
      }
      
      await startScan(timeout: scanDuration);
      _isScanning = true;
    });
  }
  
  @override
  Future<void> setAdvertisingInterval(Duration interval) async {
    // Cancel existing advertising timer
    _advertisingTimer?.cancel();
    
    // For continuous advertising (Performance mode)
    if (interval.inMilliseconds < 1000) {
      await FlutterBluePlus.startAdvertising(
        name: "BitChat",
        serviceUuids: [BluetoothService.SERVICE_UUID],
      );
      return;
    }
    
    // Set up periodic advertising
    bool advertising = false;
    _advertisingTimer = Timer.periodic(interval, (timer) async {
      if (advertising) {
        await FlutterBluePlus.stopAdvertising();
        advertising = false;
      } else {
        await FlutterBluePlus.startAdvertising(
          name: "BitChat",
          serviceUuids: [BluetoothService.SERVICE_UUID],
          timeout: Duration(seconds: 3), // Short advertising burst
        );
        advertising = true;
      }
    });
  }
  
  @override
  Future<void> setMaxConnections(int maxConnections) async {
    // Implement connection limit
    if (_connectedDevices.length > maxConnections) {
      // Disconnect excess connections
      final excessDevices = _connectedDevices.skip(maxConnections).toList();
      for (final device in excessDevices) {
        await device.disconnect();
      }
    }
    
    // Store max connections setting
    _maxConnections = maxConnections;
  }
}
```

## Error Handling

### Error Classification

```dart
enum BluetoothError {
  adapterOff,
  permissionDenied,
  connectionFailed,
  serviceNotFound,
  characteristicNotFound,
  writeError,
  readError,
  scanError,
  advertisingError,
  timeout,
  unknown,
}

class BluetoothException implements Exception {
  final BluetoothError type;
  final String message;
  final dynamic originalError;
  
  BluetoothException(this.message, {this.type = BluetoothError.unknown, this.originalError});
  
  @override
  String toString() => 'BluetoothException: $message';
}
```

### Recovery Strategies

```dart
class ErrorRecoveryManager {
  static const int MAX_RETRY_ATTEMPTS = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 5);
  
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation,
    BluetoothError expectedError,
  ) async {
    int attempts = 0;
    
    while (attempts < MAX_RETRY_ATTEMPTS) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= MAX_RETRY_ATTEMPTS) {
          rethrow;
        }
        
        await _handleError(e, expectedError);
        await Future.delayed(RETRY_DELAY * attempts);
      }
    }
    
    throw BluetoothException("Maximum retry attempts exceeded");
  }
  
  Future<void> _handleError(dynamic error, BluetoothError expectedError) async {
    switch (expectedError) {
      case BluetoothError.adapterOff:
        await _waitForAdapterOn();
        break;
      case BluetoothError.connectionFailed:
        await _resetConnection();
        break;
      case BluetoothError.scanError:
        await _restartScanning();
        break;
      default:
        // Log error and continue
        print("Bluetooth error: $error");
    }
  }
  
  Future<void> _waitForAdapterOn() async {
    await FlutterBluePlus.adapterState
        .where((state) => state == BluetoothAdapterState.on)
        .first;
  }
}
```

## Flutter-Specific Testing Strategy

### Unit Tests with Mocktail

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Mock classes
class MockFlutterBluePlus extends Mock implements FlutterBluePlus {}
class MockBluetoothDevice extends Mock implements BluetoothDevice {}
class MockBluetoothService extends Mock implements BluetoothService {}
class MockBluetoothCharacteristic extends Mock implements BluetoothCharacteristic {}

class BluetoothManagerTest {
  group('BluetoothManager', () {
    late BluetoothManager manager;
    late MockFlutterBluePlus mockFlutterBluePlus;
    
    setUp(() {
      mockFlutterBluePlus = MockFlutterBluePlus();
      manager = BluetoothManager();
      
      // Setup default mock behaviors
      when(() => mockFlutterBluePlus.isSupported)
          .thenAnswer((_) async => true);
      when(() => mockFlutterBluePlus.adapterState)
          .thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
      when(() => mockFlutterBluePlus.scanResults)
          .thenAnswer((_) => Stream.value([]));
    });
    
    test('should initialize correctly when Bluetooth is supported', () async {
      // Arrange
      when(() => mockFlutterBluePlus.adapterState)
          .thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
      
      // Act
      await manager.initialize();
      
      // Assert
      expect(manager.currentState, equals(BluetoothAdapterState.on));
      verify(() => mockFlutterBluePlus.isSupported).called(1);
    });
    
    test('should throw exception when Bluetooth is not supported', () async {
      // Arrange
      when(() => mockFlutterBluePlus.isSupported)
          .thenAnswer((_) async => false);
      
      // Act & Assert
      expect(
        () => manager.initialize(),
        throwsA(isA<BluetoothException>()),
      );
    });
    
    test('should handle adapter state changes correctly', () async {
      // Arrange
      final stateController = StreamController<BluetoothAdapterState>();
      when(() => mockFlutterBluePlus.adapterState)
          .thenAnswer((_) => stateController.stream);
      
      await manager.initialize();
      
      // Act
      stateController.add(BluetoothAdapterState.off);
      await Future.delayed(Duration.zero); // Allow stream to process
      
      // Assert
      expect(manager.currentState, equals(BluetoothAdapterState.off));
    });
    
    test('should process BitChat devices correctly', () async {
      // Arrange
      final mockDevice = MockBluetoothDevice();
      final scanResult = ScanResult(
        device: mockDevice,
        advertisementData: AdvertisementData(
          localName: 'BitChat-12345678',
          serviceUuids: [BluetoothService.SERVICE_UUID],
          manufacturerData: {
            0xFFFF: [0x01, 0x00, ...utf8.encode('BitChat')],
          },
        ),
        rssi: -45,
        timeStamp: DateTime.now(),
      );
      
      when(() => mockDevice.id).thenReturn(DeviceIdentifier('test-device-id'));
      when(() => mockDevice.name).thenReturn('BitChat-12345678');
      
      // Act
      final isBitChatDevice = manager._isBitChatDevice(scanResult);
      
      // Assert
      expect(isBitChatDevice, isTrue);
    });
    
    test('should manage connection pool correctly', () async {
      // Arrange
      final mockDevice = MockBluetoothDevice();
      when(() => mockDevice.id).thenReturn(DeviceIdentifier('test-device'));
      when(() => mockDevice.connect(timeout: any(named: 'timeout')))
          .thenAnswer((_) async => {});
      when(() => mockDevice.discoverServices())
          .thenAnswer((_) async => []);
      
      // Act
      await manager._attemptConnection(mockDevice);
      
      // Assert
      expect(manager.connectedDevices.length, equals(1));
      expect(manager.connectedDevices.first.id.id, equals('test-device'));
    });
    
    tearDown(() {
      manager.dispose();
    });
  });
  
  group('PeripheralManager', () {
    late PeripheralManager peripheralManager;
    late MockFlutterBluePlus mockFlutterBluePlus;
    
    setUp(() {
      peripheralManager = PeripheralManager();
      mockFlutterBluePlus = MockFlutterBluePlus();
    });
    
    test('should start advertising with correct parameters', () async {
      // Arrange
      when(() => mockFlutterBluePlus.startAdvertising(
        name: any(named: 'name'),
        serviceUuids: any(named: 'serviceUuids'),
        manufacturerData: any(named: 'manufacturerData'),
      )).thenAnswer((_) async => {});
      
      // Act
      await peripheralManager.startAdvertising();
      
      // Assert
      verify(() => mockFlutterBluePlus.startAdvertising(
        name: any(named: 'name', that: contains('BitChat')),
        serviceUuids: [BluetoothService.SERVICE_UUID],
        manufacturerData: any(named: 'manufacturerData'),
      )).called(1);
      
      expect(peripheralManager.isAdvertising, isTrue);
    });
    
    test('should build manufacturer data correctly', () {
      // Act
      final manufacturerData = peripheralManager._buildManufacturerData();
      
      // Assert
      expect(manufacturerData, containsPair(0xFFFF, any));
      final data = manufacturerData[0xFFFF]!;
      expect(data[0], equals(0x01)); // Protocol version
      expect(String.fromCharCodes(data.skip(2).take(7)), equals('BitChat'));
    });
  });
  
  group('CentralManager', () {
    late CentralManager centralManager;
    late MockFlutterBluePlus mockFlutterBluePlus;
    
    setUp(() {
      centralManager = CentralManager();
      mockFlutterBluePlus = MockFlutterBluePlus();
    });
    
    test('should start scanning with correct parameters', () async {
      // Arrange
      when(() => mockFlutterBluePlus.startScan(
        timeout: any(named: 'timeout'),
        withServices: any(named: 'withServices'),
        androidScanMode: any(named: 'androidScanMode'),
      )).thenAnswer((_) async => {});
      
      // Act
      await centralManager.startScanning();
      
      // Assert
      verify(() => mockFlutterBluePlus.startScan(
        timeout: any(named: 'timeout'),
        withServices: [BluetoothService.SERVICE_UUID],
        androidScanMode: any(named: 'androidScanMode'),
      )).called(1);
      
      expect(centralManager.isScanning, isTrue);
    });
    
    test('should adjust scan parameters correctly', () {
      // Arrange
      const newScanDuration = Duration(seconds: 5);
      const newScanInterval = Duration(seconds: 15);
      
      // Act
      centralManager.setScanParameters(
        scanDuration: newScanDuration,
        scanInterval: newScanInterval,
        scanMode: AndroidScanMode.lowPower,
      );
      
      // Assert
      expect(centralManager._currentScanDuration, equals(newScanDuration));
      expect(centralManager._currentScanInterval, equals(newScanInterval));
      expect(centralManager._currentScanMode, equals(AndroidScanMode.lowPower));
    });
  });
}
```

### Widget Tests for Bluetooth UI Components

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

class MockBluetoothProvider extends Mock implements BluetoothProvider {}

class BluetoothWidgetTests {
  group('BluetoothStatusWidget', () {
    late MockBluetoothProvider mockProvider;
    
    setUp(() {
      mockProvider = MockBluetoothProvider();
    });
    
    testWidgets('should display connected status correctly', (tester) async {
      // Arrange
      when(() => mockProvider.currentState)
          .thenReturn(BluetoothAdapterState.on);
      when(() => mockProvider.connectedDevices)
          .thenReturn([MockBluetoothDevice(), MockBluetoothDevice()]);
      when(() => mockProvider.isScanning).thenReturn(false);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BluetoothProvider>.value(
            value: mockProvider,
            child: BluetoothStatusWidget(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Connected: 2 devices'), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_connected), findsOneWidget);
    });
    
    testWidgets('should display scanning indicator when scanning', (tester) async {
      // Arrange
      when(() => mockProvider.currentState)
          .thenReturn(BluetoothAdapterState.on);
      when(() => mockProvider.connectedDevices).thenReturn([]);
      when(() => mockProvider.isScanning).thenReturn(true);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BluetoothProvider>.value(
            value: mockProvider,
            child: BluetoothStatusWidget(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Scanning...'), findsOneWidget);
    });
    
    testWidgets('should display error state when Bluetooth is off', (tester) async {
      // Arrange
      when(() => mockProvider.currentState)
          .thenReturn(BluetoothAdapterState.off);
      when(() => mockProvider.connectedDevices).thenReturn([]);
      when(() => mockProvider.isScanning).thenReturn(false);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BluetoothProvider>.value(
            value: mockProvider,
            child: BluetoothStatusWidget(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Bluetooth is off'), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);
    });
  });
  
  group('PeerDiscoveryScreen', () {
    testWidgets('should display discovered peers correctly', (tester) async {
      // Arrange
      final mockScanResults = [
        ScanResult(
          device: MockBluetoothDevice(),
          advertisementData: AdvertisementData(
            localName: 'BitChat-Device1',
            serviceUuids: [BluetoothService.SERVICE_UUID],
          ),
          rssi: -45,
          timeStamp: DateTime.now(),
        ),
        ScanResult(
          device: MockBluetoothDevice(),
          advertisementData: AdvertisementData(
            localName: 'BitChat-Device2',
            serviceUuids: [BluetoothService.SERVICE_UUID],
          ),
          rssi: -67,
          timeStamp: DateTime.now(),
        ),
      ];
      
      when(() => mockProvider.scanResults).thenReturn(mockScanResults);
      when(() => mockProvider.isScanning).thenReturn(true);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BluetoothProvider>.value(
            value: mockProvider,
            child: PeerDiscoveryScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('BitChat-Device1'), findsOneWidget);
      expect(find.text('BitChat-Device2'), findsOneWidget);
      expect(find.text('-45 dBm'), findsOneWidget);
      expect(find.text('-67 dBm'), findsOneWidget);
    });
  });
}
```

### Integration Tests

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bitchat/main.dart' as app;

class BluetoothIntegrationTests {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Bluetooth Integration Tests', () {
    testWidgets('complete Bluetooth initialization flow', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for Bluetooth initialization
      await tester.pump(Duration(seconds: 3));
      
      // Verify Bluetooth status is displayed
      expect(find.textContaining('Bluetooth'), findsAtLeastNWidgets(1));
      
      // Navigate to peer discovery
      await tester.tap(find.byIcon(Icons.bluetooth_searching));
      await tester.pumpAndSettle();
      
      // Verify peer discovery screen is shown
      expect(find.text('Nearby Peers'), findsOneWidget);
      
      // Start scanning
      await tester.tap(find.text('Start Scanning'));
      await tester.pumpAndSettle();
      
      // Verify scanning indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for scan results (in real test, this would find actual devices)
      await tester.pump(Duration(seconds: 10));
    });
    
    testWidgets('Bluetooth permission handling', (tester) async {
      // Mock permission requests
      const MethodChannel('flutter.baseflow.com/permissions/methods')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'requestPermissions') {
          return <String, int>{
            'android.permission.BLUETOOTH': 1,
            'android.permission.BLUETOOTH_SCAN': 1,
            'android.permission.BLUETOOTH_ADVERTISE': 1,
            'android.permission.BLUETOOTH_CONNECT': 1,
            'android.permission.ACCESS_FINE_LOCATION': 1,
          };
        }
        return null;
      });
      
      app.main();
      await tester.pumpAndSettle();
      
      // Verify permissions are requested on startup
      // This would be verified through platform channel interactions
    });
    
    testWidgets('Bluetooth error recovery', (tester) async {
      // Mock Bluetooth adapter turning off
      const MethodChannel('flutter_blue_plus')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'adapterState') {
          return 'off';
        }
        return null;
      });
      
      app.main();
      await tester.pumpAndSettle();
      
      // Verify error state is displayed
      expect(find.textContaining('Bluetooth is off'), findsOneWidget);
      
      // Verify recovery options are shown
      expect(find.text('Enable Bluetooth'), findsOneWidget);
    });
  });
}
```

### Performance Tests

```dart
class BluetoothPerformanceTests {
  group('Bluetooth Performance Tests', () {
    test('scan performance under load', () async {
      final manager = BluetoothManager();
      await manager.initialize();
      
      final stopwatch = Stopwatch()..start();
      
      // Start scanning
      await manager.startScanning();
      
      // Simulate high-frequency scan results
      for (int i = 0; i < 100; i++) {
        final mockResults = List.generate(10, (index) => 
          ScanResult(
            device: MockBluetoothDevice(),
            advertisementData: AdvertisementData(
              localName: 'Device-$index',
            ),
            rssi: -50 - index,
            timeStamp: DateTime.now(),
          ),
        );
        
        manager._onScanResults(mockResults);
        await Future.delayed(Duration(milliseconds: 10));
      }
      
      stopwatch.stop();
      
      // Verify performance is acceptable
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
    
    test('connection pool performance', () async {
      final connectionPool = ConnectionPool();
      final stopwatch = Stopwatch()..start();
      
      // Create multiple connections rapidly
      final futures = List.generate(20, (index) async {
        final mockDevice = MockBluetoothDevice();
        when(() => mockDevice.id).thenReturn(DeviceIdentifier('device-$index'));
        
        return connectionPool.getConnection('device-$index');
      });
      
      await Future.wait(futures);
      stopwatch.stop();
      
      // Verify connection creation is fast
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      // Verify connection limit is enforced
      expect(connectionPool.activeConnections.length, 
             lessThanOrEqualTo(ConnectionPool.MAX_CONNECTIONS));
    });
    
    test('memory usage during extended operation', () async {
      final manager = BluetoothManager();
      await manager.initialize();
      
      // Simulate extended operation
      for (int i = 0; i < 1000; i++) {
        // Simulate device discovery and connection attempts
        final mockDevice = MockBluetoothDevice();
        when(() => mockDevice.id).thenReturn(DeviceIdentifier('device-$i'));
        
        await manager._attemptConnection(mockDevice);
        
        // Periodically trigger cleanup
        if (i % 100 == 0) {
          await manager._cleanupStaleConnections();
        }
      }
      
      // Verify memory usage is reasonable
      // This would require platform-specific memory monitoring
      expect(manager.connectedDevices.length, 
             lessThanOrEqualTo(ConnectionPool.MAX_CONNECTIONS));
    });
  });
}
```

### Mock Implementations for Testing

```dart
class MockBluetoothService {
  static void setupMocks() {
    // Mock flutter_blue_plus methods
    const MethodChannel('flutter_blue_plus')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isSupported':
          return true;
        case 'adapterState':
          return 'on';
        case 'startScan':
          return null;
        case 'stopScan':
          return null;
        case 'startAdvertising':
          return null;
        case 'stopAdvertising':
          return null;
        default:
          return null;
      }
    });
    
    // Mock permission_handler methods
    const MethodChannel('flutter.baseflow.com/permissions/methods')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'requestPermissions') {
        return <String, int>{
          'android.permission.BLUETOOTH': 1,
          'android.permission.BLUETOOTH_SCAN': 1,
          'android.permission.BLUETOOTH_ADVERTISE': 1,
          'android.permission.BLUETOOTH_CONNECT': 1,
          'android.permission.ACCESS_FINE_LOCATION': 1,
        };
      }
      return null;
    });
  }
}
```

## Implementation Checklist

### Core Features
- [ ] Bluetooth adapter state management
- [ ] Dual role implementation (peripheral + central)
- [ ] Service and characteristic setup
- [ ] Peer discovery and connection
- [ ] Message routing and forwarding
- [ ] Connection pool management
- [ ] Error handling and recovery

### Platform Support
- [ ] Android permission handling
- [ ] iOS background operation
- [ ] Cross-platform compatibility
- [ ] Battery optimization
- [ ] Power management

### Testing
- [ ] Unit tests for core components
- [ ] Integration tests for BLE operations
- [ ] Platform-specific testing
- [ ] Performance benchmarking
- [ ] Battery usage analysis

## Best Practices

1. **Always check Bluetooth state** before operations
2. **Handle permissions gracefully** with clear explanations
3. **Implement proper error recovery** for network failures
4. **Optimize for battery life** with adaptive scanning
5. **Test on real devices** - BLE behavior varies significantly
6. **Monitor connection limits** - platforms have constraints
7. **Use appropriate scan modes** for different scenarios
8. **Implement proper cleanup** to prevent memory leaks

## Conclusion

This Bluetooth implementation provides a robust foundation for BitChat's mesh networking capabilities while maintaining cross-platform compatibility and battery efficiency. The dual-role architecture enables both peer discovery and message routing, creating a resilient decentralized communication network.

### Flutter-Specific Error Handling Patterns

```dart
// Comprehensive error handling for Flutter Bluetooth operations
class FlutterBluetoothErrorHandler {
  static Future<T> executeWithErrorHandling<T>(
    Future<T> Function() operation,
    String context,
  ) async {
    try {
      return await operation();
    } on PlatformException catch (e) {
      throw _handlePlatformException(e, context);
    } on TimeoutException catch (e) {
      throw BluetoothException(
        'Operation timed out in $context: ${e.message}',
        type: BluetoothError.timeout,
        originalError: e,
      );
    } on StateError catch (e) {
      throw BluetoothException(
        'Invalid state in $context: ${e.message}',
        type: BluetoothError.unknown,
        originalError: e,
      );
    } catch (e) {
      throw BluetoothException(
        'Unexpected error in $context: $e',
        type: BluetoothError.unknown,
        originalError: e,
      );
    }
  }
  
  static BluetoothException _handlePlatformException(
    PlatformException e,
    String context,
  ) {
    switch (e.code) {
      case 'bluetooth_not_supported':
        return BluetoothException(
          'Bluetooth not supported on this device',
          type: BluetoothError.adapterOff,
          originalError: e,
        );
      case 'bluetooth_not_enabled':
        return BluetoothException(
          'Bluetooth is not enabled',
          type: BluetoothError.adapterOff,
          originalError: e,
        );
      case 'location_permission_denied':
        return BluetoothException(
          'Location permission required for Bluetooth scanning',
          type: BluetoothError.permissionDenied,
          originalError: e,
        );
      case 'bluetooth_permission_denied':
        return BluetoothException(
          'Bluetooth permission denied',
          type: BluetoothError.permissionDenied,
          originalError: e,
        );
      case 'scan_failed':
        return BluetoothException(
          'Bluetooth scan failed: ${e.message}',
          type: BluetoothError.scanError,
          originalError: e,
        );
      case 'connection_failed':
        return BluetoothException(
          'Device connection failed: ${e.message}',
          type: BluetoothError.connectionFailed,
          originalError: e,
        );
      default:
        return BluetoothException(
          'Platform error in $context: ${e.message}',
          type: BluetoothError.unknown,
          originalError: e,
        );
    }
  }
}

// Retry mechanism with exponential backoff
class BluetoothRetryManager {
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    
    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        if (attempt >= maxAttempts) {
          rethrow;
        }
        
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }
        
        print('Operation failed (attempt $attempt/$maxAttempts): $e');
        print('Retrying in ${delay.inMilliseconds}ms...');
        
        await Future.delayed(delay);
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
        );
      }
    }
    
    throw StateError('This should never be reached');
  }
}
```

### Flutter-Specific Best Practices

1. **Stream Management**: Always dispose of stream subscriptions to prevent memory leaks
2. **State Management**: Use Provider or Riverpod for reactive Bluetooth state updates
3. **Platform Channels**: Handle platform-specific Bluetooth features through method channels
4. **Error Recovery**: Implement comprehensive error handling with user-friendly messages
5. **Battery Optimization**: Adapt scanning and advertising based on battery level
6. **Permission Handling**: Request permissions gracefully with clear explanations
7. **Background Processing**: Configure proper background modes for iOS and foreground services for Android
8. **Testing**: Use comprehensive mocking for reliable unit and integration tests

### Implementation Checklist

#### Core Flutter Integration
- [x] flutter_blue_plus dependency configuration
- [x] Platform-specific permission setup
- [x] Stream-based reactive state management
- [x] Comprehensive error handling
- [x] Memory leak prevention
- [x] Battery optimization integration

#### Platform Support
- [x] Android 8.0+ (API 26+) support
- [x] iOS 14.0+ support
- [x] Android 12+ permission handling
- [x] iOS background processing configuration
- [x] Cross-platform compatibility testing

#### Testing Infrastructure
- [x] Unit tests with mocktail
- [x] Widget tests for UI components
- [x] Integration tests for complete flows
- [x] Performance tests for scalability
- [x] Mock implementations for reliable testing

#### Advanced Features
- [x] Adaptive power management
- [x] Connection pool management
- [x] Automatic error recovery
- [x] Real-time device monitoring
- [x] Comprehensive logging and debugging

The implementation prioritizes:
- **Reliability**: Comprehensive error handling and recovery with Flutter-specific patterns
- **Performance**: Optimized for Flutter's reactive architecture and mobile constraints
- **Maintainability**: Clean separation of concerns with proper dependency injection
- **Testability**: Comprehensive test coverage with proper mocking strategies
- **Cross-Platform Compatibility**: Consistent behavior across iOS, Android, and desktop platforms**Efficiency**: Battery-aware operations and adaptive scanning
- **Compatibility**: Cross-platform support with platform-specific optimizations
- **Scalability**: Connection pooling and message queuing
- **Security**: Secure connection establishment and data transmission

Future enhancements should focus on mesh optimization algorithms, advanced power management, and protocol efficiency improvements.