import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../platform_service.dart';
import '../../models/platform_info.dart';
import '../../models/permission.dart';
import '../../models/platform_event.dart';

/// Desktop-specific implementation of PlatformService
/// Handles Windows, macOS, and Linux platforms
class DesktopPlatformService implements PlatformService {
  static const MethodChannel _channel = MethodChannel('bitchat/platform');

  final StreamController<PlatformEvent> _eventController =
      StreamController<PlatformEvent>.broadcast();

  bool _disposed = false;
  bool _backgroundModeEnabled =
      true; // Desktop apps can always run in background

  DesktopPlatformService() {
    _initializeEventListeners();
  }

  void _initializeEventListeners() {
    // Listen for platform events
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (_disposed) return;

    switch (call.method) {
      case 'onCapabilityChanged':
        final args = call.arguments as Map<String, dynamic>;
        final capability = _parseCapability(args['capability'] as String);
        final available = args['available'] as bool;
        final details = args['details'] as String?;

        if (capability != null) {
          _eventController.add(
            CapabilityChangedEvent(
              capability: capability,
              available: available,
              details: details,
              timestamp: DateTime.now(),
            ),
          );
        }
        break;

      case 'onSystemSettingsChanged':
        final args = call.arguments as Map<String, dynamic>;
        final setting = args['setting'] as String;
        final newValue = args['newValue'];
        final previousValue = args['previousValue'];

        _eventController.add(
          SystemSettingsChangedEvent(
            setting: setting,
            newValue: newValue,
            previousValue: previousValue,
            timestamp: DateTime.now(),
          ),
        );
        break;
    }
  }

  @override
  Future<bool> requestPermissions(List<Permission> permissions) async {
    // Desktop platforms typically don't require explicit permission requests
    // for Bluetooth and other features used by BitChat
    try {
      final Map<Permission, bool> results = {};

      for (final permission in permissions) {
        switch (permission) {
          case Permission.bluetooth:
          case Permission.bluetoothAdvertise:
          case Permission.bluetoothConnect:
          case Permission.bluetoothScan:
            // Check if Bluetooth is available
            final hasBluetoothResult = await _channel.invokeMethod(
              'hasBluetoothCapability',
            );
            results[permission] = hasBluetoothResult == true;
            break;

          case Permission.storage:
          case Permission.notification:
            // These are typically available on desktop
            results[permission] = true;
            break;

          case Permission.location:
          case Permission.locationWhenInUse:
          case Permission.locationAlways:
            // Location services may not be available or required on desktop
            results[permission] = false;
            break;

          case Permission.camera:
          case Permission.microphone:
            // These require user permission on some desktop platforms
            final hasCapability = await _channel.invokeMethod('hasCapability', {
              'capability': permission.name,
            });
            results[permission] = hasCapability == true;
            break;
        }
      }

      // Return true if all critical permissions are available
      return results.entries
          .where((entry) => entry.key.isCritical)
          .every((entry) => entry.value);
    } catch (e) {
      if (kDebugMode) {
        print('DesktopPlatformService: Error requesting permissions: $e');
      }
      return false;
    }
  }

  @override
  Future<Map<Permission, PermissionStatus>> getPermissionStatus(
    List<Permission> permissions,
  ) async {
    final Map<Permission, PermissionStatus> result = {};

    for (final permission in permissions) {
      switch (permission) {
        case Permission.bluetooth:
        case Permission.bluetoothAdvertise:
        case Permission.bluetoothConnect:
        case Permission.bluetoothScan:
          try {
            final hasBluetoothResult = await _channel.invokeMethod(
              'hasBluetoothCapability',
            );
            result[permission] = hasBluetoothResult == true
                ? PermissionStatus.granted
                : PermissionStatus.denied;
          } catch (e) {
            result[permission] = PermissionStatus.unknown;
          }
          break;

        case Permission.storage:
        case Permission.notification:
          // These are typically available on desktop
          result[permission] = PermissionStatus.granted;
          break;

        case Permission.location:
        case Permission.locationWhenInUse:
        case Permission.locationAlways:
          // Location services are not typically required on desktop
          result[permission] = PermissionStatus.notApplicable;
          break;

        case Permission.camera:
        case Permission.microphone:
          try {
            final hasCapability = await _channel.invokeMethod('hasCapability', {
              'capability': permission.name,
            });
            result[permission] = hasCapability == true
                ? PermissionStatus.granted
                : PermissionStatus.denied;
          } catch (e) {
            result[permission] = PermissionStatus.unknown;
          }
          break;
      }
    }

    return result;
  }

  @override
  Future<PlatformInfo> getPlatformInfo() async {
    try {
      final Map<String, dynamic> systemInfo = await _channel.invokeMethod(
        'getSystemInfo',
      );

      final platformType = _determinePlatformType();
      final capabilities = await _getAvailableCapabilities();

      return PlatformInfo(
        type: platformType,
        version: _getSystemVersion(systemInfo),
        deviceModel:
            systemInfo['deviceModel'] ?? _getDefaultDeviceModel(platformType),
        capabilities: capabilities,
        performance: _determinePerformanceProfile(systemInfo),
        metadata: {
          'operatingSystem': systemInfo['operatingSystem'],
          'operatingSystemVersion': systemInfo['operatingSystemVersion'],
          'numberOfProcessors': systemInfo['numberOfProcessors'],
          'totalMemory': systemInfo['totalMemory'],
          'availableMemory': systemInfo['availableMemory'],
          'architecture': systemInfo['architecture'],
          'computerName': systemInfo['computerName'],
          'userName': systemInfo['userName'],
          'bluetoothAvailable': systemInfo['bluetoothAvailable'],
          'wifiAvailable': systemInfo['wifiAvailable'],
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('DesktopPlatformService: Error getting platform info: $e');
      }

      // Fallback to basic info
      final platformType = _determinePlatformType();
      return PlatformInfo(
        type: platformType,
        version: _getDefaultSystemVersion(platformType),
        deviceModel: _getDefaultDeviceModel(platformType),
        capabilities: const [
          PlatformCapability.bluetooth,
          PlatformCapability.bluetoothLowEnergy,
          PlatformCapability.backgroundProcessing,
          PlatformCapability.secureStorage,
          PlatformCapability.notifications,
          PlatformCapability.fileSystem,
          PlatformCapability.networkConnectivity,
        ],
        performance: PerformanceProfile.unknown,
      );
    }
  }

  @override
  Future<void> setBackgroundMode(bool enabled) async {
    // Desktop applications can always run in background
    _backgroundModeEnabled = enabled;

    try {
      await _channel.invokeMethod('setBackgroundMode', {'enabled': enabled});
    } catch (e) {
      if (kDebugMode) {
        print('DesktopPlatformService: Error setting background mode: $e');
      }
    }
  }

  @override
  Future<bool> getBackgroundModeStatus() async {
    return _backgroundModeEnabled;
  }

  @override
  Stream<PlatformEvent> get platformEvents => _eventController.stream;

  @override
  Future<bool> isCapabilitySupported(PlatformCapability capability) async {
    switch (capability) {
      case PlatformCapability.bluetooth:
      case PlatformCapability.bluetoothLowEnergy:
        try {
          final result = await _channel.invokeMethod('hasBluetoothCapability');
          return result == true;
        } catch (e) {
          return false;
        }

      case PlatformCapability.bluetoothAdvertising:
      case PlatformCapability.bluetoothScanning:
        // These depend on Bluetooth being available
        return await isCapabilitySupported(PlatformCapability.bluetooth);

      case PlatformCapability.backgroundProcessing:
      case PlatformCapability.secureStorage:
      case PlatformCapability.notifications:
      case PlatformCapability.fileSystem:
      case PlatformCapability.networkConnectivity:
        return true;

      case PlatformCapability.locationServices:
        // Location services are not typically available on desktop
        return false;

      case PlatformCapability.biometricAuthentication:
        try {
          final result = await _channel.invokeMethod('hasBiometricCapability');
          return result == true;
        } catch (e) {
          return false;
        }
    }
  }

  @override
  Future<PerformanceProfile> getPerformanceProfile() async {
    try {
      final systemInfo = await _channel.invokeMethod('getSystemInfo');
      return _determinePerformanceProfile(systemInfo);
    } catch (e) {
      return PerformanceProfile.unknown;
    }
  }

  @override
  Future<void> optimizeForBattery() async {
    // Desktop optimization is typically handled by the OS
    try {
      await _channel.invokeMethod('optimizeForBattery');
    } catch (e) {
      if (kDebugMode) {
        print('DesktopPlatformService: Error optimizing for battery: $e');
      }
    }
  }

  @override
  Future<BatteryOptimizationStatus> getBatteryOptimizationStatus() async {
    // Desktop platforms typically don't have battery optimization in the same way
    return BatteryOptimizationStatus.notSupported;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _eventController.close();
  }

  // Helper methods

  PlatformType _determinePlatformType() {
    if (Platform.isWindows) return PlatformType.windows;
    if (Platform.isMacOS) return PlatformType.macos;
    if (Platform.isLinux) return PlatformType.linux;
    return PlatformType.unknown;
  }

  String _getSystemVersion(Map<String, dynamic> systemInfo) {
    final os = systemInfo['operatingSystem'] as String?;
    final version = systemInfo['operatingSystemVersion'] as String?;

    if (os != null && version != null) {
      return '$os $version';
    } else if (os != null) {
      return os;
    } else {
      return _getDefaultSystemVersion(_determinePlatformType());
    }
  }

  String _getDefaultSystemVersion(PlatformType platformType) {
    switch (platformType) {
      case PlatformType.windows:
        return 'Windows Unknown';
      case PlatformType.macos:
        return 'macOS Unknown';
      case PlatformType.linux:
        return 'Linux Unknown';
      default:
        return 'Unknown OS';
    }
  }

  String _getDefaultDeviceModel(PlatformType platformType) {
    switch (platformType) {
      case PlatformType.windows:
        return 'Windows PC';
      case PlatformType.macos:
        return 'Mac';
      case PlatformType.linux:
        return 'Linux PC';
      default:
        return 'Unknown Computer';
    }
  }

  Future<List<PlatformCapability>> _getAvailableCapabilities() async {
    final capabilities = <PlatformCapability>[
      PlatformCapability.backgroundProcessing,
      PlatformCapability.secureStorage,
      PlatformCapability.notifications,
      PlatformCapability.fileSystem,
      PlatformCapability.networkConnectivity,
    ];

    // Check for Bluetooth
    try {
      final hasBluetoothResult = await _channel.invokeMethod(
        'hasBluetoothCapability',
      );
      if (hasBluetoothResult == true) {
        capabilities.addAll([
          PlatformCapability.bluetooth,
          PlatformCapability.bluetoothLowEnergy,
          PlatformCapability.bluetoothAdvertising,
          PlatformCapability.bluetoothScanning,
        ]);
      }
    } catch (e) {
      // Bluetooth not available
    }

    // Check for biometric authentication
    try {
      final hasBiometricResult = await _channel.invokeMethod(
        'hasBiometricCapability',
      );
      if (hasBiometricResult == true) {
        capabilities.add(PlatformCapability.biometricAuthentication);
      }
    } catch (e) {
      // Biometric authentication not available
    }

    return capabilities;
  }

  PerformanceProfile _determinePerformanceProfile(
    Map<String, dynamic> systemInfo,
  ) {
    final numberOfProcessors = systemInfo['numberOfProcessors'] as int?;
    final totalMemory = systemInfo['totalMemory'] as int?;

    // Desktop performance heuristics
    if (numberOfProcessors != null && totalMemory != null) {
      if (numberOfProcessors >= 8 && totalMemory >= 16 * 1024 * 1024 * 1024) {
        return PerformanceProfile.high;
      } else if (numberOfProcessors >= 4 &&
          totalMemory >= 8 * 1024 * 1024 * 1024) {
        return PerformanceProfile.medium;
      } else {
        return PerformanceProfile.low;
      }
    }

    // Fallback based on individual metrics
    if (numberOfProcessors != null) {
      if (numberOfProcessors >= 8) return PerformanceProfile.high;
      if (numberOfProcessors >= 4) return PerformanceProfile.medium;
      return PerformanceProfile.low;
    }

    if (totalMemory != null) {
      if (totalMemory >= 16 * 1024 * 1024 * 1024) {
        return PerformanceProfile.high;
      }
      if (totalMemory >= 8 * 1024 * 1024 * 1024) {
        return PerformanceProfile.medium;
      }
      return PerformanceProfile.low;
    }

    return PerformanceProfile.unknown;
  }

  PlatformCapability? _parseCapability(String capabilityString) {
    switch (capabilityString) {
      case 'bluetooth':
        return PlatformCapability.bluetooth;
      case 'bluetoothLowEnergy':
        return PlatformCapability.bluetoothLowEnergy;
      case 'bluetoothAdvertising':
        return PlatformCapability.bluetoothAdvertising;
      case 'bluetoothScanning':
        return PlatformCapability.bluetoothScanning;
      case 'backgroundProcessing':
        return PlatformCapability.backgroundProcessing;
      case 'locationServices':
        return PlatformCapability.locationServices;
      case 'secureStorage':
        return PlatformCapability.secureStorage;
      case 'biometricAuthentication':
        return PlatformCapability.biometricAuthentication;
      case 'notifications':
        return PlatformCapability.notifications;
      case 'fileSystem':
        return PlatformCapability.fileSystem;
      case 'networkConnectivity':
        return PlatformCapability.networkConnectivity;
      default:
        return null;
    }
  }
}
