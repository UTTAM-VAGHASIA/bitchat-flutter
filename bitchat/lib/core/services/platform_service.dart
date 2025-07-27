import 'dart:async';

import '../models/platform_info.dart';
import '../models/permission.dart';
import '../models/platform_event.dart';

/// Abstract interface for platform-specific functionality
///
/// This service provides a unified interface for accessing platform-specific
/// features across iOS, Android, and desktop platforms while maintaining
/// clean architecture principles.
abstract class PlatformService {
  /// Requests the specified permissions from the platform
  ///
  /// Returns true if all permissions are granted, false otherwise.
  /// On platforms that don't require certain permissions, they are
  /// considered automatically granted.
  Future<bool> requestPermissions(List<Permission> permissions);

  /// Gets the current permission status for the specified permissions
  ///
  /// Returns a map of permission to their current status.
  Future<Map<Permission, PermissionStatus>> getPermissionStatus(
    List<Permission> permissions,
  );

  /// Gets detailed information about the current platform
  ///
  /// Includes device capabilities, performance profile, and platform-specific
  /// features that affect BitChat functionality.
  Future<PlatformInfo> getPlatformInfo();

  /// Enables or disables background mode for the application
  ///
  /// This is crucial for maintaining mesh network connectivity when the
  /// app is not in the foreground.
  Future<void> setBackgroundMode(bool enabled);

  /// Gets the current background mode status
  Future<bool> getBackgroundModeStatus();

  /// Stream of platform-specific events
  ///
  /// Emits events such as permission changes, background mode changes,
  /// device capability changes, etc.
  Stream<PlatformEvent> get platformEvents;

  /// Checks if a specific capability is supported on this platform
  Future<bool> isCapabilitySupported(PlatformCapability capability);

  /// Gets the optimal performance settings for this device
  Future<PerformanceProfile> getPerformanceProfile();

  /// Requests the platform to optimize for battery usage
  ///
  /// This may adjust various system settings to minimize battery drain
  /// while maintaining core BitChat functionality.
  Future<void> optimizeForBattery();

  /// Gets the current battery optimization status
  Future<BatteryOptimizationStatus> getBatteryOptimizationStatus();

  /// Disposes of platform-specific resources
  Future<void> dispose();
}
