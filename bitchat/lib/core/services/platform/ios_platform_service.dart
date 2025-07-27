import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../platform_service.dart';
import '../../models/platform_info.dart';
import '../../models/permission.dart';
import '../../models/platform_event.dart';

/// iOS-specific implementation of PlatformService
class IOSPlatformService implements PlatformService {
  static const MethodChannel _channel = MethodChannel('bitchat/platform');

  final StreamController<PlatformEvent> _eventController =
      StreamController<PlatformEvent>.broadcast();

  bool _disposed = false;
  bool _backgroundModeEnabled = false;

  IOSPlatformService() {
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
        print('IOSPlatformService: Error requesting permissions: $e');
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
        // iOS doesn't require some permissions that Android does
        result[permission] = _getIOSPermissionDefault(permission);
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
        PlatformCapability.secureStorage,
        PlatformCapability.biometricAuthentication, // iOS has Face ID/Touch ID
        PlatformCapability.notifications,
        PlatformCapability.fileSystem,
        PlatformCapability.networkConnectivity,
      ];

      // Location services are available but not always required on iOS
      if (deviceInfo['hasLocationServices'] == true) {
        capabilities.add(PlatformCapability.locationServices);
      }

      return PlatformInfo(
        type: PlatformType.ios,
        version: 'iOS ${deviceInfo['systemVersion'] ?? 'Unknown'}',
        deviceModel: deviceInfo['deviceModel'] ?? 'Unknown iOS Device',
        capabilities: capabilities,
        performance: _determinePerformanceProfile(deviceInfo),
        metadata: {
          'systemName': deviceInfo['systemName'],
          'systemVersion': deviceInfo['systemVersion'],
          'model': deviceInfo['model'],
          'localizedModel': deviceInfo['localizedModel'],
          'identifierForVendor': deviceInfo['identifierForVendor'],
          'totalMemory': deviceInfo['totalMemory'],
          'availableMemory': deviceInfo['availableMemory'],
          'batteryLevel': deviceInfo['batteryLevel'],
          'batteryState': deviceInfo['batteryState'],
          'lowPowerModeEnabled': deviceInfo['lowPowerModeEnabled'],
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('IOSPlatformService: Error getting platform info: $e');
      }

      // Fallback to basic info
      return const PlatformInfo(
        type: PlatformType.ios,
        version: 'iOS Unknown',
        deviceModel: 'Unknown iOS Device',
        capabilities: [
          PlatformCapability.bluetooth,
          PlatformCapability.bluetoothLowEnergy,
          PlatformCapability.backgroundProcessing,
          PlatformCapability.secureStorage,
          PlatformCapability.biometricAuthentication,
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
        print('IOSPlatformService: Error setting background mode: $e');
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
      case PlatformCapability.secureStorage:
      case PlatformCapability.biometricAuthentication:
      case PlatformCapability.notifications:
      case PlatformCapability.fileSystem:
      case PlatformCapability.networkConnectivity:
        return true;

      case PlatformCapability.locationServices:
        try {
          final result = await _channel.invokeMethod('hasLocationServices');
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
        print('IOSPlatformService: Error optimizing for battery: $e');
      }
    }
  }

  @override
  Future<BatteryOptimizationStatus> getBatteryOptimizationStatus() async {
    try {
      final result = await _channel.invokeMethod(
        'getBatteryOptimizationStatus',
      );
      // iOS handles battery optimization automatically
      return result == true
          ? BatteryOptimizationStatus.enabled
          : BatteryOptimizationStatus.disabled;
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
        return null; // Not required on iOS
      case Permission.bluetoothConnect:
        return null; // Not required on iOS
      case Permission.bluetoothScan:
        return null; // Not required on iOS
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

  PermissionStatus _getIOSPermissionDefault(Permission permission) {
    switch (permission) {
      case Permission.bluetoothAdvertise:
      case Permission.bluetoothConnect:
      case Permission.bluetoothScan:
        // These are not required on iOS - Bluetooth permission covers all
        return PermissionStatus.granted;
      default:
        return PermissionStatus.notApplicable;
    }
  }

  Permission? _parsePermission(String permissionString) {
    switch (permissionString) {
      case 'bluetooth':
        return Permission.bluetooth;
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

  PerformanceProfile _determinePerformanceProfile(
    Map<String, dynamic> deviceInfo,
  ) {
    final model = deviceInfo['model'] as String?;
    final totalMemory = deviceInfo['totalMemory'] as int?;

    // iOS device performance heuristics based on model
    if (model != null) {
      final modelLower = model.toLowerCase();

      // iPhone 15 Pro, iPhone 14 Pro, iPad Pro with M-series chips
      if (modelLower.contains('iphone15') ||
          modelLower.contains('iphone14') ||
          modelLower.contains('ipadpro') ||
          modelLower.contains('macbook')) {
        return PerformanceProfile.high;
      }

      // iPhone 12, 13, iPad Air
      if (modelLower.contains('iphone12') ||
          modelLower.contains('iphone13') ||
          modelLower.contains('ipadair')) {
        return PerformanceProfile.medium;
      }

      // Older devices
      if (modelLower.contains('iphone') || modelLower.contains('ipad')) {
        return PerformanceProfile.low;
      }
    }

    // Fallback to memory-based heuristic
    if (totalMemory != null) {
      if (totalMemory >= 6 * 1024 * 1024 * 1024) {
        // 6GB+
        return PerformanceProfile.high;
      } else if (totalMemory >= 3 * 1024 * 1024 * 1024) {
        // 3GB+
        return PerformanceProfile.medium;
      } else {
        return PerformanceProfile.low;
      }
    }

    return PerformanceProfile.unknown;
  }
}
