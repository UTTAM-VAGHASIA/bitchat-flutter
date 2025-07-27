import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../platform_service.dart';
import '../../models/platform_info.dart';
import '../../models/permission.dart';
import '../../models/platform_event.dart';

/// Android-specific implementation of PlatformService
class AndroidPlatformService implements PlatformService {
  static const MethodChannel _channel = MethodChannel('bitchat/platform');

  final StreamController<PlatformEvent> _eventController =
      StreamController<PlatformEvent>.broadcast();

  bool _disposed = false;
  bool _backgroundModeEnabled = false;

  AndroidPlatformService() {
    _initializeEventListeners();
  }

  void _initializeEventListeners() {
    // Listen for permission changes
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (_disposed) return;

    switch (call.method) {
      case 'onPermissionChanged':
        final args = call.arguments as Map<String, dynamic>;
        final permission = _parsePermission(args['permission'] as String);
        final status = _parsePermissionStatus(args['status'] as String);
        final previousStatus = args['previousStatus'] != null
            ? _parsePermissionStatus(args['previousStatus'] as String)
            : null;

        if (permission != null && status != null) {
          _eventController.add(
            PermissionChangedEvent(
              permission: permission,
              status: status,
              previousStatus: previousStatus,
              timestamp: DateTime.now(),
            ),
          );
        }
        break;

      case 'onBackgroundModeChanged':
        final args = call.arguments as Map<String, dynamic>;
        final enabled = args['enabled'] as bool;
        final reason = args['reason'] as String?;

        _backgroundModeEnabled = enabled;
        _eventController.add(
          BackgroundModeChangedEvent(
            enabled: enabled,
            reason: reason,
            timestamp: DateTime.now(),
          ),
        );
        break;

      case 'onBatteryOptimizationChanged':
        final args = call.arguments as Map<String, dynamic>;
        final status = _parseBatteryOptimizationStatus(
          args['status'] as String,
        );
        final previousStatus = args['previousStatus'] != null
            ? _parseBatteryOptimizationStatus(args['previousStatus'] as String)
            : null;

        if (status != null) {
          _eventController.add(
            BatteryOptimizationChangedEvent(
              status: status,
              previousStatus: previousStatus,
              timestamp: DateTime.now(),
            ),
          );
        }
        break;
    }
  }

  @override
  Future<bool> requestPermissions(List<Permission> permissions) async {
    try {
      final Map<ph.Permission, ph.PermissionStatus> results = {};

      for (final permission in permissions) {
        final platformPermission = _mapToPlatformPermission(permission);
        if (platformPermission != null) {
          final status = await platformPermission.request();
          results[platformPermission] = status;
        }
      }

      // All permissions must be granted for success
      return results.values.every((status) => status.isGranted);
    } catch (e) {
      if (kDebugMode) {
        print('AndroidPlatformService: Error requesting permissions: $e');
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
      final platformPermission = _mapToPlatformPermission(permission);
      if (platformPermission != null) {
        final status = await platformPermission.status;
        result[permission] = _mapFromPlatformPermissionStatus(status);
      } else {
        result[permission] = PermissionStatus.notApplicable;
      }
    }

    return result;
  }

  @override
  Future<PlatformInfo> getPlatformInfo() async {
    try {
      final Map<String, dynamic> deviceInfo = await _channel.invokeMethod(
        'getDeviceInfo',
      );

      final capabilities = <PlatformCapability>[
        PlatformCapability.bluetooth,
        PlatformCapability.bluetoothLowEnergy,
        PlatformCapability.bluetoothAdvertising,
        PlatformCapability.bluetoothScanning,
        PlatformCapability.backgroundProcessing,
        PlatformCapability.locationServices,
        PlatformCapability.secureStorage,
        PlatformCapability.notifications,
        PlatformCapability.fileSystem,
        PlatformCapability.networkConnectivity,
      ];

      // Add biometric authentication if available
      if (deviceInfo['hasBiometrics'] == true) {
        capabilities.add(PlatformCapability.biometricAuthentication);
      }

      return PlatformInfo(
        type: PlatformType.android,
        version: 'Android ${deviceInfo['androidVersion'] ?? 'Unknown'}',
        deviceModel: deviceInfo['deviceModel'] ?? 'Unknown Android Device',
        capabilities: capabilities,
        performance: _determinePerformanceProfile(deviceInfo),
        metadata: {
          'apiLevel': deviceInfo['apiLevel'],
          'manufacturer': deviceInfo['manufacturer'],
          'brand': deviceInfo['brand'],
          'hardware': deviceInfo['hardware'],
          'totalMemory': deviceInfo['totalMemory'],
          'availableMemory': deviceInfo['availableMemory'],
          'batteryLevel': deviceInfo['batteryLevel'],
          'isCharging': deviceInfo['isCharging'],
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('AndroidPlatformService: Error getting platform info: $e');
      }

      // Fallback to basic info
      return const PlatformInfo(
        type: PlatformType.android,
        version: 'Android Unknown',
        deviceModel: 'Unknown Android Device',
        capabilities: [
          PlatformCapability.bluetooth,
          PlatformCapability.bluetoothLowEnergy,
          PlatformCapability.backgroundProcessing,
          PlatformCapability.secureStorage,
          PlatformCapability.notifications,
          PlatformCapability.fileSystem,
        ],
        performance: PerformanceProfile.unknown,
      );
    }
  }

  @override
  Future<void> setBackgroundMode(bool enabled) async {
    try {
      await _channel.invokeMethod('setBackgroundMode', {'enabled': enabled});
      _backgroundModeEnabled = enabled;
    } catch (e) {
      if (kDebugMode) {
        print('AndroidPlatformService: Error setting background mode: $e');
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
      case PlatformCapability.bluetoothAdvertising:
      case PlatformCapability.bluetoothScanning:
      case PlatformCapability.backgroundProcessing:
      case PlatformCapability.locationServices:
      case PlatformCapability.secureStorage:
      case PlatformCapability.notifications:
      case PlatformCapability.fileSystem:
      case PlatformCapability.networkConnectivity:
        return true;

      case PlatformCapability.biometricAuthentication:
        try {
          final result = await _channel.invokeMethod('hasBiometrics');
          return result == true;
        } catch (e) {
          return false;
        }
    }
  }

  @override
  Future<PerformanceProfile> getPerformanceProfile() async {
    try {
      final deviceInfo = await _channel.invokeMethod('getDeviceInfo');
      return _determinePerformanceProfile(deviceInfo);
    } catch (e) {
      return PerformanceProfile.unknown;
    }
  }

  @override
  Future<void> optimizeForBattery() async {
    try {
      await _channel.invokeMethod('optimizeForBattery');
    } catch (e) {
      if (kDebugMode) {
        print('AndroidPlatformService: Error optimizing for battery: $e');
      }
    }
  }

  @override
  Future<BatteryOptimizationStatus> getBatteryOptimizationStatus() async {
    try {
      final result = await _channel.invokeMethod(
        'getBatteryOptimizationStatus',
      );
      return _parseBatteryOptimizationStatus(result) ??
          BatteryOptimizationStatus.unknown;
    } catch (e) {
      return BatteryOptimizationStatus.unknown;
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _eventController.close();
  }

  // Helper methods

  ph.Permission? _mapToPlatformPermission(Permission permission) {
    switch (permission) {
      case Permission.bluetooth:
        return ph.Permission.bluetooth;
      case Permission.bluetoothAdvertise:
        return ph.Permission.bluetoothAdvertise;
      case Permission.bluetoothConnect:
        return ph.Permission.bluetoothConnect;
      case Permission.bluetoothScan:
        return ph.Permission.bluetoothScan;
      case Permission.location:
        return ph.Permission.location;
      case Permission.locationWhenInUse:
        return ph.Permission.locationWhenInUse;
      case Permission.locationAlways:
        return ph.Permission.locationAlways;
      case Permission.notification:
        return ph.Permission.notification;
      case Permission.storage:
        return ph.Permission.storage;
      case Permission.camera:
        return ph.Permission.camera;
      case Permission.microphone:
        return ph.Permission.microphone;
    }
  }

  PermissionStatus _mapFromPlatformPermissionStatus(
    ph.PermissionStatus status,
  ) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return PermissionStatus.granted;
      case ph.PermissionStatus.denied:
        return PermissionStatus.denied;
      case ph.PermissionStatus.permanentlyDenied:
        return PermissionStatus.permanentlyDenied;
      case ph.PermissionStatus.restricted:
        return PermissionStatus.restricted;
      case ph.PermissionStatus.limited:
        return PermissionStatus.granted; // Treat limited as granted
      case ph.PermissionStatus.provisional:
        return PermissionStatus.granted; // Treat provisional as granted
    }
  }

  Permission? _parsePermission(String permissionString) {
    switch (permissionString) {
      case 'bluetooth':
        return Permission.bluetooth;
      case 'bluetoothAdvertise':
        return Permission.bluetoothAdvertise;
      case 'bluetoothConnect':
        return Permission.bluetoothConnect;
      case 'bluetoothScan':
        return Permission.bluetoothScan;
      case 'location':
        return Permission.location;
      case 'locationWhenInUse':
        return Permission.locationWhenInUse;
      case 'locationAlways':
        return Permission.locationAlways;
      case 'notification':
        return Permission.notification;
      case 'storage':
        return Permission.storage;
      case 'camera':
        return Permission.camera;
      case 'microphone':
        return Permission.microphone;
      default:
        return null;
    }
  }

  PermissionStatus? _parsePermissionStatus(String statusString) {
    switch (statusString) {
      case 'granted':
        return PermissionStatus.granted;
      case 'denied':
        return PermissionStatus.denied;
      case 'permanentlyDenied':
        return PermissionStatus.permanentlyDenied;
      case 'restricted':
        return PermissionStatus.restricted;
      case 'unknown':
        return PermissionStatus.unknown;
      case 'notApplicable':
        return PermissionStatus.notApplicable;
      default:
        return null;
    }
  }

  BatteryOptimizationStatus? _parseBatteryOptimizationStatus(
    String statusString,
  ) {
    switch (statusString) {
      case 'enabled':
        return BatteryOptimizationStatus.enabled;
      case 'disabled':
        return BatteryOptimizationStatus.disabled;
      case 'unknown':
        return BatteryOptimizationStatus.unknown;
      case 'notSupported':
        return BatteryOptimizationStatus.notSupported;
      default:
        return null;
    }
  }

  PerformanceProfile _determinePerformanceProfile(
    Map<String, dynamic> deviceInfo,
  ) {
    final totalMemory = deviceInfo['totalMemory'] as int?;
    final apiLevel = deviceInfo['apiLevel'] as int?;

    // Simple heuristic based on memory and API level
    if (totalMemory != null) {
      if (totalMemory >= 8 * 1024 * 1024 * 1024) {
        // 8GB+
        return PerformanceProfile.high;
      } else if (totalMemory >= 4 * 1024 * 1024 * 1024) {
        // 4GB+
        return PerformanceProfile.medium;
      } else {
        return PerformanceProfile.low;
      }
    }

    // Fallback to API level
    if (apiLevel != null) {
      if (apiLevel >= 31) {
        // Android 12+
        return PerformanceProfile.medium;
      } else if (apiLevel >= 26) {
        // Android 8+
        return PerformanceProfile.low;
      }
    }

    return PerformanceProfile.unknown;
  }
}
