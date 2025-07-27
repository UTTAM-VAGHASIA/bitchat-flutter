# Platform Compatibility Specification

## Overview

This document defines comprehensive cross-platform compatibility requirements for BitChat Flutter, ensuring 100% binary protocol compatibility with existing iOS (Swift) and Android (Kotlin) implementations while leveraging platform-specific optimizations and features.

## Cross-Platform Compatibility Matrix

### Flutter Platform Support Matrix

| Platform | Target Version | Minimum Version | BLE Support | Background Processing | Flutter Support | Status |
|----------|----------------|-----------------|-------------|-------------------|----------------|--------|
| iOS      | 16.0+          | 14.0            | Core Bluetooth | Background App Refresh | flutter_blue_plus | ✅ Full |
| Android  | API 34 (14)    | API 26 (8.0)    | BluetoothAdapter | Foreground Service | flutter_blue_plus | ✅ Full |
| macOS    | 12.0+          | 11.0            | Core Bluetooth | Background Processing | flutter_blue_plus | ✅ Full |
| Windows  | 10 (1903)+     | 10 (1803)       | Windows BLE API | Background Tasks | flutter_blue_plus | ⚠️ Limited |
| Linux    | Ubuntu 20.04+  | Ubuntu 18.04    | BlueZ 5.50+    | systemd services | flutter_blue_plus | ⚠️ Limited |
| Web      | N/A            | N/A             | Web Bluetooth API | Service Workers | Limited | ❌ Not Supported |

### Flutter-Specific Platform Features

```dart
// Platform detection and feature availability
class FlutterPlatformSupport {
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;
  
  static Future<PlatformCapabilities> getPlatformCapabilities() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return IOSCapabilities(iosInfo);
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return AndroidCapabilities(androidInfo);
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      return MacOSCapabilities(macInfo);
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return WindowsCapabilities(windowsInfo);
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return LinuxCapabilities(linuxInfo);
    }
    
    return UnknownPlatformCapabilities();
  }
}

abstract class PlatformCapabilities {
  bool get supportsBluetooth;
  bool get supportsBackgroundProcessing;
  bool get supportsNotifications;
  bool get supportsFileSystem;
  String get platformName;
  String get platformVersion;
}

class IOSCapabilities extends PlatformCapabilities {
  final IosDeviceInfo deviceInfo;
  
  IOSCapabilities(this.deviceInfo);
  
  @override
  bool get supportsBluetooth => true;
  
  @override
  bool get supportsBackgroundProcessing => true;
  
  @override
  bool get supportsNotifications => true;
  
  @override
  bool get supportsFileSystem => true;
  
  @override
  String get platformName => 'iOS';
  
  @override
  String get platformVersion => deviceInfo.systemVersion;
  
  bool get hasSecureEnclave => deviceInfo.model.contains('iPhone') && 
      !deviceInfo.model.contains('iPhone5');
}

class AndroidCapabilities extends PlatformCapabilities {
  final AndroidDeviceInfo deviceInfo;
  
  AndroidCapabilities(this.deviceInfo);
  
  @override
  bool get supportsBluetooth => deviceInfo.version.sdkInt >= 18;
  
  @override
  bool get supportsBackgroundProcessing => deviceInfo.version.sdkInt >= 26;
  
  @override
  bool get supportsNotifications => true;
  
  @override
  bool get supportsFileSystem => true;
  
  @override
  String get platformName => 'Android';
  
  @override
  String get platformVersion => deviceInfo.version.release;
  
  bool get hasHardwareKeystore => deviceInfo.version.sdkInt >= 23;
  bool get supportsBLEAdvertising => deviceInfo.version.sdkInt >= 21;
}
```

### Protocol Interoperability

```yaml
# Protocol Compatibility Matrix
binary_protocol:
  header_format: "13-byte identical across all platforms"
  packet_types: "Same message types and routing logic"
  fragmentation: "Compatible message fragmentation"
  endianness: "Little-endian for cross-platform compatibility"

encryption_compatibility:
  key_exchange: "X25519 - identical implementation"
  symmetric_encryption: "AES-256-GCM - same parameters"
  password_derivation: "Argon2id - identical salt/iteration"
  digital_signatures: "Ed25519 - same curve parameters"

network_behavior:
  mesh_routing: "TTL-based routing (max 7 hops)"
  peer_discovery: "Identical UUID and advertising format"
  message_caching: "Same store-and-forward logic"
  fragmentation_logic: "Identical reconstruction algorithm"
```

## iOS Compatibility

### Core Requirements

```dart
// iOS-specific configuration
const IOSConfig = {
  targetVersion: '16.0',
  minimumVersion: '14.0',
  bluetoothFramework: 'Core Bluetooth',
  backgroundModes: ['bluetooth-central', 'bluetooth-peripheral'],
  capabilities: ['bluetooth-le'],
};
```

### Bluetooth LE Implementation

```dart
// iOS Core Bluetooth equivalence
class IOSBluetoothManager extends BluetoothManager {
  // Equivalent to CBCentralManager
  late CBCentralManager centralManager;
  
  // Equivalent to CBPeripheralManager
  late CBPeripheralManager peripheralManager;
  
  // Service UUIDs - must match iOS implementation
  static const String serviceUUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String txCharacteristicUUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String rxCharacteristicUUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
  
  @override
  Future<void> initializeBluetooth() async {
    // Initialize with same parameters as iOS
    await FlutterBluePlus.setLogLevel(LogLevel.emergency);
    await FlutterBluePlus.turnOn();
    
    // Configure advertising - match iOS advertisement data
    await startAdvertising();
    await startScanning();
  }
  
  Future<void> startAdvertising() async {
    final advertisementData = {
      'localName': 'BitChat-${deviceId.substring(0, 8)}',
      'serviceUuids': [serviceUUID],
      'manufacturerData': await buildManufacturerData(),
    };
    
    await FlutterBluePlus.startAdvertising(advertisementData);
  }
}
```

### Background Processing

```dart
// iOS Background App Refresh integration
class IOSBackgroundProcessor {
  static const String backgroundTaskIdentifier = 'com.bitchat.bluetooth-sync';
  
  Future<void> configureBackgroundProcessing() async {
    // Register background task
    await MethodChannel('bitchat/background')
        .invokeMethod('registerBackgroundTask', {
      'identifier': backgroundTaskIdentifier,
      'bluetoothContinuation': true,
    });
  }
  
  Future<void> handleBackgroundExecution() async {
    // Maintain BLE operations in background
    // Process pending messages
    // Update mesh routing table
    // Sync with available peers
  }
}
```

### iOS-Specific Features

```dart
// iOS Platform Integration
class IOSPlatformIntegration {
  // Keychain integration for secure storage
  Future<void> storeSecureData(String key, String value) async {
    await MethodChannel('bitchat/keychain')
        .invokeMethod('store', {'key': key, 'value': value});
  }
  
  // iOS notification integration
  Future<void> showNotification(String message) async {
    await MethodChannel('bitchat/notifications')
        .invokeMethod('show', {'message': message});
  }
  
  // iOS-specific UI patterns
  Widget buildIOSActionSheet(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('BitChat Actions'),
      actions: [
        CupertinoActionSheetAction(
          child: const Text('Join Channel'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
```

## Android Compatibility

### Core Requirements

```dart
// Android-specific configuration
const AndroidConfig = {
  targetSdkVersion: 34,
  minSdkVersion: 26,
  bluetoothFramework: 'BluetoothAdapter',
  permissions: [
    'BLUETOOTH',
    'BLUETOOTH_ADMIN',
    'BLUETOOTH_ADVERTISE',
    'BLUETOOTH_CONNECT',
    'BLUETOOTH_SCAN',
    'ACCESS_FINE_LOCATION',
    'FOREGROUND_SERVICE',
  ],
};
```

### Bluetooth LE Implementation

```dart
// Android BluetoothAdapter equivalence
class AndroidBluetoothManager extends BluetoothManager {
  late BluetoothAdapter bluetoothAdapter;
  late BluetoothLeAdvertiser bluetoothAdvertiser;
  late BluetoothLeScanner bluetoothScanner;
  
  @override
  Future<void> initializeBluetooth() async {
    // Initialize with Android-specific parameters
    await requestPermissions();
    await enableBluetooth();
    
    // Configure advertising - match Android advertisement format
    await startAdvertising();
    await startScanning();
  }
  
  Future<void> requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ];
    
    await permissions.request();
  }
  
  Future<void> startAdvertising() async {
    final settings = AdvertiseSettings(
      advertiseMode: AdvertiseMode.advertiseModeBalanced,
      connectable: true,
      timeout: 0,
      txPowerLevel: AdvertiseTx.advertiseTxPowerMedium,
    );
    
    final data = AdvertiseData(
      includeDeviceName: true,
      includeTxPowerLevel: true,
      serviceUuids: [serviceUUID],
      manufacturerData: await buildManufacturerData(),
    );
    
    await FlutterBluePlus.startAdvertising(settings, data);
  }
}
```

### Background Processing

```dart
// Android Foreground Service integration
class AndroidBackgroundService {
  static const String channelId = 'bitchat_background';
  static const String channelName = 'BitChat Background Service';
  
  Future<void> startForegroundService() async {
    await MethodChannel('bitchat/foreground_service')
        .invokeMethod('start', {
      'channelId': channelId,
      'channelName': channelName,
      'notificationTitle': 'BitChat is running',
      'notificationContent': 'Maintaining mesh network connection',
    });
  }
  
  Future<void> configureWorkManager() async {
    // Configure periodic background work
    await MethodChannel('bitchat/work_manager')
        .invokeMethod('schedulePeriodicWork', {
      'workName': 'mesh_sync',
      'intervalMinutes': 15,
      'requiresCharging': false,
      'requiresDeviceIdle': false,
    });
  }
}
```

### Android-Specific Features

```dart
// Android Platform Integration
class AndroidPlatformIntegration {
  // Android Keystore integration
  Future<void> storeSecureData(String key, String value) async {
    await MethodChannel('bitchat/keystore')
        .invokeMethod('store', {'key': key, 'value': value});
  }
  
  // Android notification channels
  Future<void> createNotificationChannel() async {
    await MethodChannel('bitchat/notifications')
        .invokeMethod('createChannel', {
      'channelId': 'bitchat_messages',
      'channelName': 'BitChat Messages',
      'importance': 'high',
    });
  }
  
  // Android-specific UI patterns
  Widget buildAndroidBottomSheet(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Join Channel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Desktop Compatibility

### Windows Support

```dart
// Windows 10+ BLE implementation
class WindowsBluetoothManager extends BluetoothManager {
  late WindowsBluetoothAdapter adapter;
  
  @override
  Future<void> initializeBluetooth() async {
    // Windows-specific BLE initialization
    await MethodChannel('bitchat/windows_ble')
        .invokeMethod('initialize');
    
    // Configure Windows BLE advertising
    await startWindowsAdvertising();
  }
  
  Future<void> startWindowsAdvertising() async {
    await MethodChannel('bitchat/windows_ble')
        .invokeMethod('startAdvertising', {
      'serviceUuid': serviceUUID,
      'localName': 'BitChat-${deviceId.substring(0, 8)}',
      'manufacturerData': await buildManufacturerData(),
    });
  }
}
```

### macOS Support

```dart
// macOS native Bluetooth framework
class MacOSBluetoothManager extends BluetoothManager {
  // Reuse iOS Core Bluetooth implementation
  @override
  Future<void> initializeBluetooth() async {
    // macOS uses same Core Bluetooth framework as iOS
    await super.initializeBluetooth();
    
    // macOS-specific configuration
    await configureMacOSSpecificFeatures();
  }
  
  Future<void> configureMacOSSpecificFeatures() async {
    // System tray integration
    await MethodChannel('bitchat/macos_integration')
        .invokeMethod('configureSystemTray');
    
    // Dock integration
    await MethodChannel('bitchat/macos_integration')
        .invokeMethod('configureDockIcon');
  }
}
```

### Linux Support

```dart
// Linux BlueZ integration
class LinuxBluetoothManager extends BluetoothManager {
  late BlueZAdapter blueZAdapter;
  
  @override
  Future<void> initializeBluetooth() async {
    // BlueZ D-Bus integration
    await MethodChannel('bitchat/bluez')
        .invokeMethod('initialize');
    
    // Configure BlueZ advertising
    await startBlueZAdvertising();
  }
  
  Future<void> startBlueZAdvertising() async {
    await MethodChannel('bitchat/bluez')
        .invokeMethod('startAdvertising', {
      'serviceUuid': serviceUUID,
      'localName': 'BitChat-${deviceId.substring(0, 8)}',
      'manufacturerData': await buildManufacturerData(),
    });
  }
}
```

### Desktop UI Patterns

```dart
// Adaptive desktop layouts
class DesktopUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar for channels
          SizedBox(
            width: 250,
            child: ChannelsSidebar(),
          ),
          // Main chat area
          Expanded(
            child: ChatArea(),
          ),
          // Members/info panel
          if (MediaQuery.of(context).size.width > 1200)
            SizedBox(
              width: 200,
              child: MembersPanel(),
            ),
        ],
      ),
    );
  }
}
```

## Protocol Compatibility Matrix

### Message Format Compatibility

```dart
// Identical binary protocol across platforms
class ProtocolCompatibility {
  // Header format - identical across all platforms
  static const int headerLength = 13;
  
  static List<int> buildHeader({
    required int messageType,
    required int payloadLength,
    required int ttl,
    required String sourceId,
    required String destId,
  }) {
    final header = ByteData(headerLength);
    
    // Byte 0: Message type
    header.setUint8(0, messageType);
    
    // Bytes 1-2: Payload length (little-endian)
    header.setUint16(1, payloadLength, Endian.little);
    
    // Byte 3: TTL
    header.setUint8(3, ttl);
    
    // Bytes 4-7: Source ID (4 bytes)
    final sourceBytes = hex.decode(sourceId.substring(0, 8));
    header.setUint32(4, sourceBytes.buffer.asByteData().getUint32(0, Endian.little), Endian.little);
    
    // Bytes 8-11: Destination ID (4 bytes)
    final destBytes = hex.decode(destId.substring(0, 8));
    header.setUint32(8, destBytes.buffer.asByteData().getUint32(0, Endian.little), Endian.little);
    
    // Byte 12: Flags
    header.setUint8(12, 0);
    
    return header.buffer.asUint8List();
  }
  
  // Encryption compatibility
  static Future<List<int>> encryptMessage(
    List<int> message,
    List<int> key,
    List<int> nonce,
  ) async {
    // Use identical AES-256-GCM parameters across platforms
    final cipher = AesGcm.with256bits();
    final secretKey = SecretKey(key);
    
    final result = await cipher.encrypt(
      message,
      secretKey: secretKey,
      nonce: nonce,
    );
    
    return result.cipherText + result.mac.bytes;
  }
}
```

### Network Behavior Compatibility

```dart
// Identical mesh routing logic
class MeshRouting {
  static const int maxTTL = 7;
  static const int defaultTTL = 3;
  
  static bool shouldForwardMessage(Message message, Set<String> seenMessages) {
    // Identical forwarding logic across platforms
    if (message.ttl <= 0) return false;
    if (seenMessages.contains(message.messageId)) return false;
    if (message.destId == deviceId) return false;
    
    return true;
  }
  
  static Message decrementTTL(Message message) {
    // Identical TTL decrement logic
    return message.copyWith(ttl: message.ttl - 1);
  }
}
```

## Testing Strategy

### Cross-Platform Testing

```dart
// Automated cross-platform testing
class CrossPlatformTesting {
  static Future<void> runCompatibilityTests() async {
    // Test binary protocol compatibility
    await testBinaryProtocol();
    
    // Test encryption compatibility
    await testEncryptionCompatibility();
    
    // Test network behavior compatibility
    await testNetworkBehavior();
    
    // Test cross-platform communication
    await testCrossPlatformCommunication();
  }
  
  static Future<void> testBinaryProtocol() async {
    // Create identical messages on different platforms
    final message = TestMessage(
      type: MessageType.channelMessage,
      payload: 'Test message',
      sourceId: 'test-source',
      destId: 'test-dest',
      ttl: 3,
    );
    
    // Verify identical serialization
    final serialized = message.serialize();
    final deserialized = TestMessage.deserialize(serialized);
    
    assert(message == deserialized);
  }
  
  static Future<void> testEncryptionCompatibility() async {
    // Test key exchange compatibility
    final keyPair1 = await generateKeyPair();
    final keyPair2 = await generateKeyPair();
    
    final sharedSecret1 = await computeSharedSecret(keyPair1.privateKey, keyPair2.publicKey);
    final sharedSecret2 = await computeSharedSecret(keyPair2.privateKey, keyPair1.publicKey);
    
    assert(listEquals(sharedSecret1, sharedSecret2));
    
    // Test message encryption compatibility
    final message = 'Test encryption message';
    final encrypted = await encryptMessage(message.codeUnits, sharedSecret1, generateNonce());
    final decrypted = await decryptMessage(encrypted, sharedSecret2);
    
    assert(String.fromCharCodes(decrypted) == message);
  }
}
```

### Interoperability Testing

```dart
// Test communication between different platform implementations
class InteroperabilityTesting {
  static Future<void> testIOSFlutterCommunication() async {
    // Connect Flutter app to iOS BitChat
    final connection = await BluetoothConnection.connect('ios-bitchat-device');
    
    // Send message from Flutter to iOS
    final message = 'Flutter to iOS test';
    await connection.sendMessage(message);
    
    // Verify iOS receives and processes message correctly
    final response = await connection.waitForResponse(timeout: Duration(seconds: 10));
    assert(response.contains('ACK'));
  }
  
  static Future<void> testAndroidFlutterCommunication() async {
    // Connect Flutter app to Android BitChat
    final connection = await BluetoothConnection.connect('android-bitchat-device');
    
    // Send message from Flutter to Android
    final message = 'Flutter to Android test';
    await connection.sendMessage(message);
    
    // Verify Android receives and processes message correctly
    final response = await connection.waitForResponse(timeout: Duration(seconds: 10));
    assert(response.contains('ACK'));
  }
  
  static Future<void> testMixedGroupScenarios() async {
    // Test group chat with iOS, Android, and Flutter devices
    final devices = [
      await BluetoothConnection.connect('ios-device'),
      await BluetoothConnection.connect('android-device'),
      await BluetoothConnection.connect('flutter-device'),
    ];
    
    // Join same channel from all devices
    for (final device in devices) {
      await device.sendCommand('/join test-channel');
    }
    
    // Send message from each device
    for (int i = 0; i < devices.length; i++) {
      final message = 'Message from device $i';
      await devices[i].sendMessage(message);
      
      // Verify all other devices receive the message
      for (int j = 0; j < devices.length; j++) {
        if (i != j) {
          final received = await devices[j].waitForMessage(timeout: Duration(seconds: 5));
          assert(received.contains(message));
        }
      }
    }
  }
}
```

### Performance Testing

```dart
// Platform-specific performance benchmarks
class PerformanceTesting {
  static Future<void> runPerformanceBenchmarks() async {
    await benchmarkMessageThroughput();
    await benchmarkBatteryUsage();
    await benchmarkMemoryUsage();
    await benchmarkLatency();
  }
  
  static Future<void> benchmarkMessageThroughput() async {
    final stopwatch = Stopwatch()..start();
    const messageCount = 1000;
    
    for (int i = 0; i < messageCount; i++) {
      final message = 'Benchmark message $i';
      await sendMessage(message);
    }
    
    stopwatch.stop();
    final messagesPerSecond = messageCount / (stopwatch.elapsedMilliseconds / 1000);
    
    print('Message throughput: $messagesPerSecond messages/second');
    assert(messagesPerSecond > 10); // Minimum performance requirement
  }
  
  static Future<void> benchmarkBatteryUsage() async {
    // Platform-specific battery monitoring
    await MethodChannel('bitchat/battery')
        .invokeMethod('startMonitoring');
    
    // Run typical usage scenario for 1 hour
    await simulateTypicalUsage(Duration(hours: 1));
    
    final batteryUsage = await MethodChannel('bitchat/battery')
        .invokeMethod('getBatteryUsage');
    
    print('Battery usage: ${batteryUsage}% per hour');
    assert(batteryUsage < 5); // Maximum 5% battery usage per hour
  }
}
```

## Deployment Considerations

### App Store Requirements

```yaml
# iOS App Store configuration
ios_deployment:
  bundle_id: "com.bitchat.flutter"
  target_version: "16.0"
  capabilities:
    - bluetooth-le
    - background-processing
    - keychain-access-groups
  privacy_usage_descriptions:
    bluetooth: "BitChat uses Bluetooth to communicate with nearby devices"
    background_refresh: "BitChat needs background access to maintain mesh network"
  
# Android Play Store configuration
android_deployment:
  package_name: "com.bitchat.flutter"
  target_sdk: 34
  permissions:
    - android.permission.BLUETOOTH
    - android.permission.BLUETOOTH_ADMIN
    - android.permission.BLUETOOTH_ADVERTISE
    - android.permission.BLUETOOTH_CONNECT
    - android.permission.BLUETOOTH_SCAN
    - android.permission.ACCESS_FINE_LOCATION
    - android.permission.FOREGROUND_SERVICE
  privacy_policy_url: "https://bitchat.example.com/privacy"
```

### Desktop Distribution

```yaml
# Windows distribution
windows_deployment:
  target_version: "10.0.19041.0"  # Windows 10 version 2004
  package_format: "msix"
  store_submission: true
  sideloading_enabled: true
  
# macOS distribution
macos_deployment:
  target_version: "12.0"
  package_format: "dmg"
  app_store_submission: true
  notarization_required: true
  
# Linux distribution
linux_deployment:
  formats: ["AppImage", "snap", "deb", "rpm"]
  target_distributions: ["Ubuntu", "Fedora", "Arch"]
  system_dependencies: ["bluez", "libbluetooth-dev"]
```

### Version Management

```dart
// Coordinated version management
class VersionManager {
  static const String currentVersion = '1.0.0';
  static const int protocolVersion = 1;
  
  static bool isCompatible(String otherVersion) {
    // Check protocol compatibility
    final otherProtocolVersion = getProtocolVersion(otherVersion);
    return otherProtocolVersion == protocolVersion;
  }
  
  static int getProtocolVersion(String version) {
    // Extract protocol version from app version
    final parts = version.split('.');
    return int.parse(parts[0]);
  }
  
  static Future<void> checkForUpdates() async {
    // Check for updates across all platforms
    final latestVersion = await getLatestVersion();
    
    if (shouldUpdate(currentVersion, latestVersion)) {
      await promptForUpdate(latestVersion);
    }
  }
}
```

## Migration and Upgrade Paths

### Data Migration

```dart
// Cross-platform data migration
class DataMigration {
  static Future<void> exportUserData() async {
    final data = {
      'channels': await ChannelStorage.exportChannels(),
      'contacts': await ContactStorage.exportContacts(),
      'settings': await SettingsStorage.exportSettings(),
      'keys': await KeyStorage.exportKeys(), // Encrypted
    };
    
    final json = jsonEncode(data);
    await saveToFile('bitchat_backup.json', json);
  }
  
  static Future<void> importUserData(String backupPath) async {
    final json = await loadFromFile(backupPath);
    final data = jsonDecode(json);
    
    await ChannelStorage.importChannels(data['channels']);
    await ContactStorage.importContacts(data['contacts']);
    await SettingsStorage.importSettings(data['settings']);
    await KeyStorage.importKeys(data['keys']);
  }
  
  static Future<void> migrateFromLegacyFormat() async {
    // Migrate from iOS/Android specific formats
    if (await hasLegacyIOSData()) {
      await migrateIOSData();
    }
    
    if (await hasLegacyAndroidData()) {
      await migrateAndroidData();
    }
  }
}
```

### Settings Synchronization

```dart
// Cross-platform settings sync
class SettingsSync {
  static Future<void> syncSettings() async {
    final settings = await loadLocalSettings();
    
    // Encrypt settings for transmission
    final encrypted = await encryptSettings(settings);
    
    // Broadcast settings to other devices
    await broadcastSettings(encrypted);
  }
  
  static Future<void> receiveSettings(List<int> encryptedSettings) async {
    final settings = await decryptSettings(encryptedSettings);
    
    // Merge with local settings
    await mergeSettings(settings);
  }
}
```

## Platform-Specific Implementation Details

### Flutter Plugin Architecture

```dart
// Custom plugin for platform-specific features
class BitChatPlugin {
  static const MethodChannel _channel = MethodChannel('bitchat/plugin');
  
  static Future<void> initializePlatformSpecific() async {
    await _channel.invokeMethod('initialize');
  }
  
  static Future<void> configureBluetooth() async {
    await _channel.invokeMethod('configureBluetooth');
  }
  
  static Future<void> setupBackgroundProcessing() async {
    await _channel.invokeMethod('setupBackgroundProcessing');
  }
}
```

### Native Code Integration

```kotlin
// Android native implementation
class BitChatPlugin: FlutterPlugin, MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                initializeBluetooth()
                result.success(null)
            }
            "configureBluetooth" -> {
                configureBluetooth()
                result.success(null)
            }
            "setupBackgroundProcessing" -> {
                setupForegroundService()
                result.success(null)
            }
        }
    }
    
    private fun initializeBluetooth() {
        // Android-specific Bluetooth initialization
    }
    
    private fun configureBluetooth() {
        // Android-specific Bluetooth configuration
    }
    
    private fun setupForegroundService() {
        // Android-specific background service setup
    }
}
```

```swift
// iOS native implementation
class BitChatPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "bitchat/plugin",
            binaryMessenger: registrar.messenger()
        )
        let instance = BitChatPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initializeBluetooth()
            result(nil)
        case "configureBluetooth":
            configureBluetooth()
            result(nil)
        case "setupBackgroundProcessing":
            setupBackgroundProcessing()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initializeBluetooth() {
        // iOS-specific Bluetooth initialization
    }
    
    private func configureBluetooth() {
        // iOS-specific Bluetooth configuration
    }
    
    private func setupBackgroundProcessing() {
        // iOS-specific background processing setup
    }
}
```

### Build System Configuration

```yaml
# Flutter build configuration
flutter:
  uses-material-design: true
  
  # Platform-specific assets
  assets:
    - assets/images/
    - assets/icons/
    - assets/sounds/
  
  # Platform-specific fonts
  fonts:
    - family: BitChatMono
      fonts:
        - asset: assets/fonts/BitChatMono-Regular.ttf
        - asset: assets/fonts/BitChatMono-Bold.ttf
          weight: 700

# Platform-specific build configurations
android:
  compileSdkVersion: 34
  minSdkVersion: 26
  targetSdkVersion: 34
  
ios:
  deployment_target: "14.0"
  
macos:
  deployment_target: "11.0"
  
windows:
  target_version: "10.0.19041.0"
  
linux:
  target_distribution: "ubuntu-20.04"
```

## Future Transport Extensions

### WiFi Direct Integration

```dart
// WiFi Direct transport abstraction
class WiFiDirectTransport implements TransportProtocol {
  static const String serviceType = "bitchat-wifi";
  
  @override
  Future<void> initialize() async {
    // Platform-specific initialization
    if (Platform.isIOS || Platform.isMacOS) {
      await _initializeMultipeerConnectivity();
    } else if (Platform.isAndroid) {
      await _initializeWifiP2P();
    }
  }
  
  Future<void> _initializeMultipeerConnectivity() async {
    // iOS/macOS implementation using MultipeerConnectivity framework
    await MethodChannel('bitchat/multipeer')
        .invokeMethod('initialize', {'serviceType': serviceType});
  }
  
  Future<void> _initializeWifiP2P() async {
    // Android implementation using WiFi P2P API
    await MethodChannel('bitchat/wifi_p2p')
        .invokeMethod('initialize');
  }
  
  @override
  Future<void> startDiscovery() async {
    // Start peer discovery
  }
  
  @override
  Future<void> send(Uint8List data, String peerId) async {
    // Send data over WiFi Direct
  }
}
```

### Transport Selection

The system will intelligently select between BLE and WiFi Direct based on:

1. **Message Size**: 
   - Small messages (<1KB): Prefer BLE (lower power)
   - Large messages/files: Use WiFi Direct

2. **Battery Level**:
   - <20%: BLE only
   - 20-50%: BLE preferred, WiFi Direct for large transfers only
   - >50%: WiFi Direct available for all transfers
   - Charging: Prefer WiFi Direct

3. **Device Capabilities**:
   - Not all devices support WiFi Direct
   - Graceful fallback to BLE

```dart
class TransportManager {
  final BluetoothTransport _bleTransport = BluetoothTransport();
  final WiFiDirectTransport _wifiTransport = WiFiDirectTransport();
  final BatteryMonitor _battery = BatteryMonitor();
  
  Future<void> initialize() async {
    await _bleTransport.initialize(); // Always initialize BLE
    
    // Initialize WiFi Direct only if supported
    if (await _isWiFiDirectSupported()) {
      await _wifiTransport.initialize();
    }
  }
  
  Future<TransportProtocol> selectTransport(Message message) async {
    // Check WiFi Direct availability
    final wifiAvailable = await _wifiTransport.isAvailable();
    
    // Check battery status
    final batteryLevel = await _battery.getBatteryLevel();
    final isCharging = await _battery.isCharging();
    
    // Check message size
    final messageSize = message.data.length;
    
    // Decision logic
    if (isCharging && wifiAvailable && messageSize > 500) {
      return _wifiTransport;
    }
    
    if (batteryLevel > 0.5 && wifiAvailable && messageSize > 2048) {
      return _wifiTransport;
    }
    
    if (batteryLevel > 0.2 && wifiAvailable && messageSize > 10240) {
      return _wifiTransport;
    }
    
    // Default to BLE for most communications
    return _bleTransport;
  }
}
```

### iOS MultipeerConnectivity Integration

```swift
// iOS native implementation
class MultipeerManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    private let serviceType: String
    private var session: MCSession
    private var peerID: MCPeerID
    private var browser: MCNearbyServiceBrowser
    private var advertiser: MCNearbyServiceAdvertiser
    
    init(serviceType: String, displayName: String) {
        self.serviceType = serviceType
        self.peerID = MCPeerID(displayName: displayName)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        self.advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        
        super.init()
        
        self.session.delegate = self
        self.browser.delegate = self
        self.advertiser.delegate = self
    }
    
    func startAdvertising() {
        advertiser.startAdvertisingPeer()
    }
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    func send(data: Data, toPeers peerIDs: [MCPeerID]) -> Bool {
        do {
            try session.send(data, toPeers: peerIDs, with: .reliable)
            return true
        } catch {
            return false
        }
    }
}
```

### Android WiFi P2P Integration

```kotlin
// Android native implementation
class WifiP2pManager {
    private val manager: WifiP2pManager = context.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
    private val channel: WifiP2pManager.Channel = manager.initialize(context, Looper.getMainLooper(), null)
    
    fun discoverPeers(listener: WifiP2pManager.ActionListener) {
        manager.discoverPeers(channel, listener)
    }
    
    fun connect(config: WifiP2pConfig, listener: WifiP2pManager.ActionListener) {
        manager.connect(channel, config, listener)
    }
    
    fun createGroup(listener: WifiP2pManager.ActionListener) {
        manager.createGroup(channel, listener)
    }
}
```

### Cross-Platform Compatibility for WiFi Direct

| Platform | Implementation | Max Speed | Range | Compatibility |
|----------|----------------|-----------|-------|---------------|
| iOS      | MultipeerConnectivity | ~60 Mbps | ~60m | iOS to iOS, iOS to macOS |
| Android  | WiFi P2P API | ~250 Mbps | ~200m | Android to Android |
| Flutter  | Platform channels | Platform dependent | Platform dependent | iOS ⟷ iOS, Android ⟷ Android |

**Note**: Due to platform limitations, cross-platform WiFi Direct (iOS ⟷ Android) is not directly supported. In mixed device groups, the mesh network will use BLE as the common transport, with WiFi Direct enhancing communication between compatible devices.

## Summary

This platform compatibility specification ensures BitChat Flutter maintains 100% protocol compatibility while leveraging platform-specific optimizations. Key achievements:

1. **Protocol Compatibility**: Identical binary protocol across all platforms
2. **Security Compatibility**: Same cryptographic algorithms and implementations
3. **Network Behavior**: Identical mesh routing and peer discovery
4. **Platform Optimization**: Leverages platform-specific features for better performance
5. **Testing Strategy**: Comprehensive cross-platform and interoperability testing
6. **Deployment Ready**: Platform-specific deployment configurations

The implementation provides a solid foundation for cross-platform BitChat deployment while maintaining the security and functionality of the original iOS and Android implementations.