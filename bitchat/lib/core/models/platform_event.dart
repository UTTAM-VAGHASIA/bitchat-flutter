import 'permission.dart';
import 'platform_info.dart';

/// Base class for all platform events
abstract class PlatformEvent {
  /// Timestamp when the event occurred
  final DateTime timestamp;

  /// Event type identifier
  final String type;

  /// Additional event data
  final Map<String, dynamic> data;

  const PlatformEvent({
    required this.timestamp,
    required this.type,
    this.data = const {},
  });

  @override
  String toString() {
    return '$runtimeType(timestamp: $timestamp, type: $type, data: $data)';
  }
}

/// Event fired when permission status changes
class PermissionChangedEvent extends PlatformEvent {
  /// The permission that changed
  final Permission permission;

  /// The new permission status
  final PermissionStatus status;

  /// The previous permission status (if known)
  final PermissionStatus? previousStatus;

  const PermissionChangedEvent({
    required this.permission,
    required this.status,
    this.previousStatus,
    required super.timestamp,
    super.data = const {},
  }) : super(type: 'permission_changed');

  @override
  String toString() {
    return 'PermissionChangedEvent('
        'permission: $permission, '
        'status: $status, '
        'previousStatus: $previousStatus, '
        'timestamp: $timestamp'
        ')';
  }
}

/// Event fired when background mode status changes
class BackgroundModeChangedEvent extends PlatformEvent {
  /// Whether background mode is now enabled
  final bool enabled;

  /// The reason for the change (user action, system restriction, etc.)
  final String? reason;

  const BackgroundModeChangedEvent({
    required this.enabled,
    this.reason,
    required super.timestamp,
    super.data = const {},
  }) : super(type: 'background_mode_changed');

  @override
  String toString() {
    return 'BackgroundModeChangedEvent('
        'enabled: $enabled, '
        'reason: $reason, '
        'timestamp: $timestamp'
        ')';
  }
}

/// Event fired when device capabilities change
class CapabilityChangedEvent extends PlatformEvent {
  /// The capability that changed
  final PlatformCapability capability;

  /// Whether the capability is now available
  final bool available;

  /// Additional information about the change
  final String? details;

  const CapabilityChangedEvent({
    required this.capability,
    required this.available,
    this.details,
    required super.timestamp,
    super.data = const {},
  }) : super(type: 'capability_changed');

  @override
  String toString() {
    return 'CapabilityChangedEvent('
        'capability: $capability, '
        'available: $available, '
        'details: $details, '
        'timestamp: $timestamp'
        ')';
  }
}

/// Event fired when battery optimization status changes
class BatteryOptimizationChangedEvent extends PlatformEvent {
  /// The new battery optimization status
  final BatteryOptimizationStatus status;

  /// The previous status (if known)
  final BatteryOptimizationStatus? previousStatus;

  const BatteryOptimizationChangedEvent({
    required this.status,
    this.previousStatus,
    required super.timestamp,
    super.data = const {},
  }) : super(type: 'battery_optimization_changed');

  @override
  String toString() {
    return 'BatteryOptimizationChangedEvent('
        'status: $status, '
        'previousStatus: $previousStatus, '
        'timestamp: $timestamp'
        ')';
  }
}

/// Event fired when the app lifecycle state changes
class AppLifecycleChangedEvent extends PlatformEvent {
  /// The new app lifecycle state
  final AppLifecycleState state;

  /// The previous app lifecycle state (if known)
  final AppLifecycleState? previousState;

  const AppLifecycleChangedEvent({
    required this.state,
    this.previousState,
    required super.timestamp,
    super.data = const {},
  }) : super(type: 'app_lifecycle_changed');

  @override
  String toString() {
    return 'AppLifecycleChangedEvent('
        'state: $state, '
        'previousState: $previousState, '
        'timestamp: $timestamp'
        ')';
  }
}

/// App lifecycle states
enum AppLifecycleState {
  /// App is in the foreground and interactive
  resumed,

  /// App is in the foreground but not interactive
  inactive,

  /// App is in the background
  paused,

  /// App is being terminated
  detached,

  /// App lifecycle state is unknown
  unknown,
}

/// Event fired when platform-specific system settings change
class SystemSettingsChangedEvent extends PlatformEvent {
  /// The setting that changed
  final String setting;

  /// The new value (if available)
  final dynamic newValue;

  /// The previous value (if known)
  final dynamic previousValue;

  const SystemSettingsChangedEvent({
    required this.setting,
    this.newValue,
    this.previousValue,
    required super.timestamp,
    super.data = const {},
  }) : super(type: 'system_settings_changed');

  @override
  String toString() {
    return 'SystemSettingsChangedEvent('
        'setting: $setting, '
        'newValue: $newValue, '
        'previousValue: $previousValue, '
        'timestamp: $timestamp'
        ')';
  }
}
