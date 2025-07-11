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
  flutter_blue_plus: ^1.31.7
  permission_handler: ^11.2.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
```

### Bluetooth Manager Implementation

```dart
class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;
  BluetoothManager._internal();
  
  FlutterBluePlus _bluetooth = FlutterBluePlus();
  StreamSubscription<BluetoothAdapterState>? _stateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  
  // Dual role state management
  bool _isPeripheralMode = false;
  bool _isCentralMode = false;
  Set<BluetoothDevice> _connectedDevices = {};
  
  // Connection pools
  final Map<String, PeerConnection> _activePeers = {};
  final Queue<PendingMessage> _messageQueue = Queue();
  
  Future<void> initialize() async {
    // Initialize Bluetooth state monitoring
    _stateSubscription = FlutterBluePlus.adapterState.listen(
      _onBluetoothStateChanged,
    );
    
    // Check initial state
    final state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) {
      await _startDualRole();
    }
  }
  
  Future<void> _startDualRole() async {
    // Start both peripheral and central roles
    await Future.wait([
      _startPeripheralMode(),
      _startCentralMode(),
    ]);
  }
}
```

### Peripheral Mode Implementation

```dart
class PeripheralManager {
  static const String DEVICE_NAME = "BitChat";
  
  Future<void> startAdvertising() async {
    try {
      // Configure advertising data
      await FlutterBluePlus.startAdvertising(
        name: DEVICE_NAME,
        serviceUuids: [BluetoothService.SERVICE_UUID],
        manufacturerData: _buildManufacturerData(),
      );
      
      // Setup GATT server
      await _setupGattServer();
      
      print("Peripheral mode started successfully");
    } catch (e) {
      throw BluetoothException("Failed to start advertising: $e");
    }
  }
  
  Future<void> _setupGattServer() async {
    // Setup characteristic handlers
    await _setupTxCharacteristic();
    await _setupRxCharacteristic();
  }
  
  Map<int, List<int>> _buildManufacturerData() {
    return {
      0xFFFF: [
        0x01, // Protocol version
        0x00, // Flags
        ...utf8.encode("BitChat"),
      ],
    };
  }
}
```

### Central Mode Implementation

```dart
class CentralManager {
  Timer? _scanTimer;
  static const Duration SCAN_DURATION = Duration(seconds: 10);
  static const Duration SCAN_INTERVAL = Duration(seconds: 30);
  
  Future<void> startScanning() async {
    try {
      // Configure scan parameters
      await FlutterBluePlus.startScan(
        timeout: SCAN_DURATION,
        withServices: [BluetoothService.SERVICE_UUID],
        withNames: ["BitChat"],
        androidScanMode: AndroidScanMode.balanced,
      );
      
      // Listen for scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        _onDeviceDiscovered,
        onError: _onScanError,
      );
      
      // Schedule periodic scanning
      _scheduleScan();
      
    } catch (e) {
      throw BluetoothException("Failed to start scanning: $e");
    }
  }
  
  void _onDeviceDiscovered(List<ScanResult> results) {
    for (final result in results) {
      if (_isBitChatDevice(result)) {
        _connectToDevice(result.device);
      }
    }
  }
  
  bool _isBitChatDevice(ScanResult result) {
    // Verify BitChat service UUID
    if (result.advertisementData.serviceUuids
        .contains(BluetoothService.SERVICE_UUID)) {
      return true;
    }
    
    // Check device name
    if (result.device.name == "BitChat") {
      return true;
    }
    
    return false;
  }
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

## Testing Strategy

### Unit Tests

```dart
class BluetoothManagerTest {
  group('BluetoothManager', () {
    late BluetoothManager manager;
    
    setUp(() {
      manager = BluetoothManager();
    });
    
    test('should initialize correctly', () async {
      await manager.initialize();
      expect(manager.isInitialized, isTrue);
    });
    
    test('should handle adapter state changes', () async {
      // Mock adapter state change
      await manager.onAdapterStateChanged(BluetoothAdapterState.off);
      expect(manager.isScanning, isFalse);
    });
    
    test('should manage connection pool', () async {
      final connection = await manager.getConnection('test-peer');
      expect(connection, isNotNull);
    });
  });
}
```

### Integration Tests

```dart
class BluetoothIntegrationTest {
  testWidgets('should discover and connect to peers', (tester) async {
    final manager = BluetoothManager();
    await manager.initialize();
    
    // Start scanning
    await manager.startScanning();
    
    // Simulate peer discovery
    await tester.pump(Duration(seconds: 5));
    
    // Verify connections
    expect(manager.connectedPeers.length, greaterThan(0));
  });
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

The implementation prioritizes:
- **Reliability**: Comprehensive error handling and recovery
- **Efficiency**: Battery-aware operations and adaptive scanning
- **Compatibility**: Cross-platform support with platform-specific optimizations
- **Scalability**: Connection pooling and message queuing
- **Security**: Secure connection establishment and data transmission

Future enhancements should focus on mesh optimization algorithms, advanced power management, and protocol efficiency improvements.