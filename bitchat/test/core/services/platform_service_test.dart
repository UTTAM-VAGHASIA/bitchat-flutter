import 'package:flutter_test/flutter_test.dart';
import 'package:bitchat/core/platform.dart';

void main() {
  group('PlatformServiceFactory', () {
    setUpAll(() {
      // Initialize Flutter bindings for testing
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    tearDown(() async {
      // Reset the singleton instance after each test
      await PlatformServiceFactory.reset();
    });

    test('should return the same instance when called multiple times', () {
      final instance1 = PlatformServiceFactory.getInstance();
      final instance2 = PlatformServiceFactory.getInstance();

      expect(instance1, same(instance2));
    });

    test('should create new instance when createInstance is called', () {
      final instance1 = PlatformServiceFactory.createInstance();
      final instance2 = PlatformServiceFactory.createInstance();

      expect(instance1, isNot(same(instance2)));
    });

    test('should return current platform name', () {
      final platformName = PlatformServiceFactory.getCurrentPlatformName();

      expect(platformName, isNotEmpty);
      expect(
        PlatformServiceFactory.getSupportedPlatforms(),
        contains(platformName),
      );
    });

    test('should indicate current platform is supported', () {
      expect(PlatformServiceFactory.isCurrentPlatformSupported(), isTrue);
    });

    test('should return list of supported platforms', () {
      final supportedPlatforms = PlatformServiceFactory.getSupportedPlatforms();

      expect(supportedPlatforms, isNotEmpty);
      expect(supportedPlatforms, contains('Android'));
      expect(supportedPlatforms, contains('iOS'));
      expect(supportedPlatforms, contains('Windows'));
      expect(supportedPlatforms, contains('macOS'));
      expect(supportedPlatforms, contains('Linux'));
    });
  });

  group('PlatformInfo', () {
    test('should create PlatformInfo with required fields', () {
      const platformInfo = PlatformInfo(
        type: PlatformType.android,
        version: 'Android 14',
        deviceModel: 'Pixel 8',
        capabilities: [PlatformCapability.bluetooth],
        performance: PerformanceProfile.high,
      );

      expect(platformInfo.type, PlatformType.android);
      expect(platformInfo.version, 'Android 14');
      expect(platformInfo.deviceModel, 'Pixel 8');
      expect(platformInfo.capabilities, [PlatformCapability.bluetooth]);
      expect(platformInfo.performance, PerformanceProfile.high);
    });

    test('should correctly identify mobile platforms', () {
      const androidInfo = PlatformInfo(
        type: PlatformType.android,
        version: 'Android 14',
        deviceModel: 'Pixel 8',
        capabilities: [],
        performance: PerformanceProfile.high,
      );

      const iosInfo = PlatformInfo(
        type: PlatformType.ios,
        version: 'iOS 17',
        deviceModel: 'iPhone 15',
        capabilities: [],
        performance: PerformanceProfile.high,
      );

      const windowsInfo = PlatformInfo(
        type: PlatformType.windows,
        version: 'Windows 11',
        deviceModel: 'PC',
        capabilities: [],
        performance: PerformanceProfile.high,
      );

      expect(androidInfo.isMobile, isTrue);
      expect(iosInfo.isMobile, isTrue);
      expect(windowsInfo.isMobile, isFalse);

      expect(androidInfo.isDesktop, isFalse);
      expect(iosInfo.isDesktop, isFalse);
      expect(windowsInfo.isDesktop, isTrue);
    });

    test('should correctly identify capabilities', () {
      const platformInfo = PlatformInfo(
        type: PlatformType.android,
        version: 'Android 14',
        deviceModel: 'Pixel 8',
        capabilities: [
          PlatformCapability.bluetooth,
          PlatformCapability.bluetoothAdvertising,
          PlatformCapability.secureStorage,
        ],
        performance: PerformanceProfile.high,
      );

      expect(platformInfo.supportsBluetooth, isTrue);
      expect(platformInfo.supportsBluetoothAdvertising, isTrue);
      expect(platformInfo.supportsSecureStorage, isTrue);
      expect(platformInfo.supportsBackgroundProcessing, isFalse);
    });

    test('should support copyWith', () {
      const original = PlatformInfo(
        type: PlatformType.android,
        version: 'Android 14',
        deviceModel: 'Pixel 8',
        capabilities: [PlatformCapability.bluetooth],
        performance: PerformanceProfile.high,
      );

      final updated = original.copyWith(
        version: 'Android 15',
        capabilities: [
          PlatformCapability.bluetooth,
          PlatformCapability.bluetoothAdvertising,
        ],
      );

      expect(updated.type, original.type);
      expect(updated.version, 'Android 15');
      expect(updated.deviceModel, original.deviceModel);
      expect(updated.capabilities, [
        PlatformCapability.bluetooth,
        PlatformCapability.bluetoothAdvertising,
      ]);
      expect(updated.performance, original.performance);
    });
  });

  group('Permission', () {
    test('should have correct display names', () {
      expect(Permission.bluetooth.displayName, 'Bluetooth');
      expect(
        Permission.bluetoothAdvertise.displayName,
        'Bluetooth Advertising',
      );
      expect(Permission.location.displayName, 'Location');
    });

    test('should have correct descriptions', () {
      expect(Permission.bluetooth.description, contains('communicate'));
      expect(Permission.bluetoothAdvertise.description, contains('advertise'));
      expect(Permission.location.description, contains('discovery'));
    });

    test('should correctly identify critical permissions', () {
      expect(Permission.bluetooth.isCritical, isTrue);
      expect(Permission.bluetoothAdvertise.isCritical, isTrue);
      expect(Permission.bluetoothConnect.isCritical, isTrue);
      expect(Permission.bluetoothScan.isCritical, isTrue);
      expect(Permission.location.isCritical, isTrue);
      expect(Permission.locationWhenInUse.isCritical, isTrue);

      expect(Permission.notification.isCritical, isFalse);
      expect(Permission.storage.isCritical, isFalse);
      expect(Permission.camera.isCritical, isFalse);
    });
  });

  group('PermissionStatus', () {
    test('should correctly identify granted status', () {
      expect(PermissionStatus.granted.isGranted, isTrue);
      expect(PermissionStatus.denied.isGranted, isFalse);
      expect(PermissionStatus.permanentlyDenied.isGranted, isFalse);
    });

    test('should correctly identify denied status', () {
      expect(PermissionStatus.denied.isDenied, isTrue);
      expect(PermissionStatus.permanentlyDenied.isDenied, isTrue);
      expect(PermissionStatus.restricted.isDenied, isTrue);
      expect(PermissionStatus.granted.isDenied, isFalse);
    });

    test('should correctly identify requestable status', () {
      expect(PermissionStatus.denied.canRequest, isTrue);
      expect(PermissionStatus.unknown.canRequest, isTrue);
      expect(PermissionStatus.granted.canRequest, isFalse);
      expect(PermissionStatus.permanentlyDenied.canRequest, isFalse);
    });

    test('should correctly identify settings requirement', () {
      expect(PermissionStatus.permanentlyDenied.requiresSettings, isTrue);
      expect(PermissionStatus.denied.requiresSettings, isFalse);
      expect(PermissionStatus.granted.requiresSettings, isFalse);
    });
  });

  group('PlatformEvent', () {
    test('should create PermissionChangedEvent correctly', () {
      final event = PermissionChangedEvent(
        permission: Permission.bluetooth,
        status: PermissionStatus.granted,
        previousStatus: PermissionStatus.denied,
        timestamp: DateTime.now(),
      );

      expect(event.permission, Permission.bluetooth);
      expect(event.status, PermissionStatus.granted);
      expect(event.previousStatus, PermissionStatus.denied);
      expect(event.type, 'permission_changed');
    });

    test('should create BackgroundModeChangedEvent correctly', () {
      final event = BackgroundModeChangedEvent(
        enabled: true,
        reason: 'User enabled',
        timestamp: DateTime.now(),
      );

      expect(event.enabled, isTrue);
      expect(event.reason, 'User enabled');
      expect(event.type, 'background_mode_changed');
    });

    test('should create CapabilityChangedEvent correctly', () {
      final event = CapabilityChangedEvent(
        capability: PlatformCapability.bluetooth,
        available: true,
        details: 'Bluetooth adapter enabled',
        timestamp: DateTime.now(),
      );

      expect(event.capability, PlatformCapability.bluetooth);
      expect(event.available, isTrue);
      expect(event.details, 'Bluetooth adapter enabled');
      expect(event.type, 'capability_changed');
    });
  });
}
