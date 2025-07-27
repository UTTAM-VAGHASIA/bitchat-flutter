import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../models/permission.dart';
import '../models/platform_info.dart';
import '../models/platform_event.dart';
import 'platform_service.dart';
import 'platform_service_factory.dart';

/// Result of a permission request operation
class PermissionRequestResult {
  /// Whether all requested permissions were granted
  final bool allGranted;

  /// Map of individual permission results
  final Map<Permission, PermissionStatus> results;

  /// Permissions that were granted
  final List<Permission> granted;

  /// Permissions that were denied
  final List<Permission> denied;

  /// Permissions that require settings navigation
  final List<Permission> requiresSettings;

  /// Error message if the request failed
  final String? error;

  const PermissionRequestResult({
    required this.allGranted,
    required this.results,
    required this.granted,
    required this.denied,
    required this.requiresSettings,
    this.error,
  });

  /// Creates a successful result
  factory PermissionRequestResult.success(
    Map<Permission, PermissionStatus> results,
  ) {
    final granted = <Permission>[];
    final denied = <Permission>[];
    final requiresSettings = <Permission>[];

    for (final entry in results.entries) {
      if (entry.value.isGranted) {
        granted.add(entry.key);
      } else if (entry.value.requiresSettings) {
        requiresSettings.add(entry.key);
      } else {
        denied.add(entry.key);
      }
    }

    return PermissionRequestResult(
      allGranted: denied.isEmpty && requiresSettings.isEmpty,
      results: results,
      granted: granted,
      denied: denied,
      requiresSettings: requiresSettings,
    );
  }

  /// Creates a failed result
  factory PermissionRequestResult.failure(String error) {
    return PermissionRequestResult(
      allGranted: false,
      results: const {},
      granted: const [],
      denied: const [],
      requiresSettings: const [],
      error: error,
    );
  }

  @override
  String toString() {
    return 'PermissionRequestResult('
        'allGranted: $allGranted, '
        'granted: $granted, '
        'denied: $denied, '
        'requiresSettings: $requiresSettings, '
        'error: $error'
        ')';
  }
}

/// Configuration for permission request flows
class PermissionRequestConfig {
  /// Whether to show rationale dialogs before requesting permissions
  final bool showRationale;

  /// Whether to automatically navigate to settings for permanently denied permissions
  final bool autoNavigateToSettings;

  /// Custom rationale messages for specific permissions
  final Map<Permission, String> customRationale;

  /// Timeout for permission requests (in seconds)
  final int timeoutSeconds;

  /// Whether to retry failed requests
  final bool retryOnFailure;

  /// Maximum number of retry attempts
  final int maxRetries;

  const PermissionRequestConfig({
    this.showRationale = true,
    this.autoNavigateToSettings = false,
    this.customRationale = const {},
    this.timeoutSeconds = 30,
    this.retryOnFailure = false,
    this.maxRetries = 2,
  });

  /// Default configuration for BitChat
  static const PermissionRequestConfig defaultConfig = PermissionRequestConfig(
    showRationale: true,
    autoNavigateToSettings: false,
    timeoutSeconds: 30,
    retryOnFailure: true,
    maxRetries: 2,
  );

  /// Configuration for critical permissions that require immediate access
  static const PermissionRequestConfig criticalConfig = PermissionRequestConfig(
    showRationale: true,
    autoNavigateToSettings: true,
    timeoutSeconds: 60,
    retryOnFailure: true,
    maxRetries: 3,
  );
}

/// Manages permission requests and monitoring across platforms
///
/// The PermissionManager provides a unified interface for handling permissions
/// across iOS, Android, and desktop platforms. It includes:
/// - Platform-specific permission mapping
/// - Request flow management with rationale dialogs
/// - Permission status monitoring and change notifications
/// - Error handling and recovery strategies
/// - Integration with the platform service layer
class PermissionManager {
  static final Logger _logger = Logger(
    level: kDebugMode ? Level.debug : Level.warning,
    printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8),
  );

  final PlatformService _platformService;
  final StreamController<PermissionChangedEvent> _permissionChangeController;
  late final StreamSubscription<PlatformEvent> _platformEventSubscription;

  /// Stream of permission change events
  Stream<PermissionChangedEvent> get permissionChanges =>
      _permissionChangeController.stream;

  /// Current platform information
  PlatformInfo? _platformInfo;

  /// Cache of current permission statuses
  final Map<Permission, PermissionStatus> _permissionCache = {};

  /// Whether the manager has been disposed
  bool _disposed = false;

  PermissionManager._({required PlatformService platformService})
    : _platformService = platformService,
      _permissionChangeController =
          StreamController<PermissionChangedEvent>.broadcast() {
    _initializeEventListeners();
    _initializePlatformInfo();
  }

  /// Creates a PermissionManager for testing purposes
  @visibleForTesting
  PermissionManager.forTesting({required PlatformService platformService})
    : _platformService = platformService,
      _permissionChangeController =
          StreamController<PermissionChangedEvent>.broadcast() {
    _initializeEventListeners();
    _initializePlatformInfo();
  }

  /// Creates a new PermissionManager instance
  static Future<PermissionManager> create() async {
    final platformService = PlatformServiceFactory.getInstance();
    final manager = PermissionManager._(platformService: platformService);
    await manager._refreshPermissionCache();
    return manager;
  }

  void _initializeEventListeners() {
    _platformEventSubscription = _platformService.platformEvents.listen(
      (event) {
        if (_disposed) return;

        if (event is PermissionChangedEvent) {
          _handlePermissionChanged(event);
        }
      },
      onError: (error) {
        _logger.e('PermissionManager: Error in platform event stream: $error');
      },
    );
  }

  Future<void> _initializePlatformInfo() async {
    try {
      _platformInfo = await _platformService.getPlatformInfo();
      _logger.d(
        'PermissionManager: Initialized for platform ${_platformInfo?.type}',
      );
    } catch (e) {
      _logger.e('PermissionManager: Failed to get platform info: $e');
    }
  }

  void _handlePermissionChanged(PermissionChangedEvent event) {
    _logger.d(
      'PermissionManager: Permission ${event.permission} changed to ${event.status}',
    );

    // Update cache
    _permissionCache[event.permission] = event.status;

    // Forward the event
    if (!_permissionChangeController.isClosed) {
      _permissionChangeController.add(event);
    }
  }

  /// Gets the required permissions for the current platform
  List<Permission> getRequiredPermissions() {
    if (_platformInfo == null) {
      _logger.w(
        'PermissionManager: Platform info not available, returning default permissions',
      );
      return _getDefaultRequiredPermissions();
    }

    switch (_platformInfo!.type) {
      case PlatformType.android:
        return _getAndroidRequiredPermissions();
      case PlatformType.ios:
        return _getIOSRequiredPermissions();
      case PlatformType.windows:
      case PlatformType.macos:
      case PlatformType.linux:
        return _getDesktopRequiredPermissions();
      case PlatformType.unknown:
        return _getDefaultRequiredPermissions();
    }
  }

  /// Gets the critical permissions that are required for core functionality
  List<Permission> getCriticalPermissions() {
    return getRequiredPermissions()
        .where((permission) => permission.isCritical)
        .toList();
  }

  /// Requests the specified permissions with the given configuration
  Future<PermissionRequestResult> requestPermissions(
    List<Permission> permissions, {
    PermissionRequestConfig config = PermissionRequestConfig.defaultConfig,
  }) async {
    if (_disposed) {
      return PermissionRequestResult.failure(
        'PermissionManager has been disposed',
      );
    }

    _logger.d('PermissionManager: Requesting permissions: $permissions');

    try {
      // Filter out permissions that are not applicable on this platform
      final applicablePermissions = _filterApplicablePermissions(permissions);

      if (applicablePermissions.isEmpty) {
        _logger.d('PermissionManager: No applicable permissions to request');
        return PermissionRequestResult.success({});
      }

      // Check current status first
      final currentStatus = await getPermissionStatus(applicablePermissions);
      final needsRequest = <Permission>[];

      for (final permission in applicablePermissions) {
        final status = currentStatus[permission] ?? PermissionStatus.unknown;
        if (!status.isGranted && status.canRequest) {
          needsRequest.add(permission);
        }
      }

      if (needsRequest.isEmpty) {
        _logger.d(
          'PermissionManager: All permissions already granted or cannot be requested',
        );
        return PermissionRequestResult.success(currentStatus);
      }

      // Show rationale if configured
      if (config.showRationale) {
        await _showRationaleIfNeeded(needsRequest, config);
      }

      // Request permissions with timeout
      final requestFuture = _requestPermissionsWithRetry(needsRequest, config);
      final timeoutFuture = Future.delayed(
        Duration(seconds: config.timeoutSeconds),
        () => throw TimeoutException(
          'Permission request timed out after ${config.timeoutSeconds} seconds',
          Duration(seconds: config.timeoutSeconds),
        ),
      );

      await Future.any([requestFuture, timeoutFuture]);

      // Always get final status regardless of success/failure
      // The platform might have granted some permissions even if the request "failed"
      final finalStatus = await getPermissionStatus(applicablePermissions);
      final result = PermissionRequestResult.success(finalStatus);

      _logger.d('PermissionManager: Permission request completed: $result');

      // Handle settings navigation if configured
      if (config.autoNavigateToSettings && result.requiresSettings.isNotEmpty) {
        await _navigateToSettingsIfNeeded(result.requiresSettings);
      }

      return result;
    } catch (e) {
      _logger.e('PermissionManager: Error requesting permissions: $e');
      return PermissionRequestResult.failure('Permission request failed: $e');
    }
  }

  /// Requests all required permissions for the current platform
  Future<PermissionRequestResult> requestRequiredPermissions({
    PermissionRequestConfig config = PermissionRequestConfig.defaultConfig,
  }) async {
    final requiredPermissions = getRequiredPermissions();
    return requestPermissions(requiredPermissions, config: config);
  }

  /// Requests only critical permissions
  Future<PermissionRequestResult> requestCriticalPermissions({
    PermissionRequestConfig config = PermissionRequestConfig.criticalConfig,
  }) async {
    final criticalPermissions = getCriticalPermissions();
    return requestPermissions(criticalPermissions, config: config);
  }

  /// Gets the current status of the specified permissions
  Future<Map<Permission, PermissionStatus>> getPermissionStatus(
    List<Permission> permissions,
  ) async {
    if (_disposed) {
      return {};
    }

    try {
      final result = await _platformService.getPermissionStatus(permissions);

      // Update cache
      _permissionCache.addAll(result);

      return result;
    } catch (e) {
      _logger.e('PermissionManager: Error getting permission status: $e');

      // Return cached values if available
      final cachedResult = <Permission, PermissionStatus>{};
      for (final permission in permissions) {
        if (_permissionCache.containsKey(permission)) {
          cachedResult[permission] = _permissionCache[permission]!;
        } else {
          cachedResult[permission] = PermissionStatus.unknown;
        }
      }
      return cachedResult;
    }
  }

  /// Gets the current status of all required permissions
  Future<Map<Permission, PermissionStatus>>
  getRequiredPermissionStatus() async {
    final requiredPermissions = getRequiredPermissions();
    return getPermissionStatus(requiredPermissions);
  }

  /// Checks if all required permissions are granted
  Future<bool> areRequiredPermissionsGranted() async {
    final status = await getRequiredPermissionStatus();
    return status.values.every((status) => status.isGranted);
  }

  /// Checks if all critical permissions are granted
  Future<bool> areCriticalPermissionsGranted() async {
    final criticalPermissions = getCriticalPermissions();
    final status = await getPermissionStatus(criticalPermissions);
    return status.values.every((status) => status.isGranted);
  }

  /// Refreshes the permission cache
  Future<void> refreshPermissionCache() async {
    await _refreshPermissionCache();
  }

  /// Refreshes the permission cache (exposed for testing)
  @visibleForTesting
  Future<void> refreshPermissionCacheForTesting() async {
    await _refreshPermissionCache();
  }

  /// Disposes of the permission manager
  Future<void> dispose() async {
    if (_disposed) return;

    _disposed = true;
    await _platformEventSubscription.cancel();
    await _permissionChangeController.close();

    _logger.d('PermissionManager: Disposed');
  }

  // Private helper methods

  Future<void> _refreshPermissionCache() async {
    try {
      final allPermissions = Permission.values;
      final status = await _platformService.getPermissionStatus(allPermissions);
      _permissionCache.clear();
      _permissionCache.addAll(status);
    } catch (e) {
      _logger.e('PermissionManager: Error refreshing permission cache: $e');
    }
  }

  List<Permission> _filterApplicablePermissions(List<Permission> permissions) {
    if (_platformInfo == null) return permissions;

    // Filter based on platform capabilities
    return permissions.where((permission) {
      switch (permission) {
        case Permission.bluetooth:
        case Permission.bluetoothAdvertise:
        case Permission.bluetoothConnect:
        case Permission.bluetoothScan:
          return _platformInfo!.supportsBluetooth;
        case Permission.location:
        case Permission.locationWhenInUse:
        case Permission.locationAlways:
          return _platformInfo!.capabilities.contains(
            PlatformCapability.locationServices,
          );
        case Permission.notification:
          return _platformInfo!.capabilities.contains(
            PlatformCapability.notifications,
          );
        case Permission.storage:
          return _platformInfo!.capabilities.contains(
            PlatformCapability.fileSystem,
          );
        case Permission.camera:
        case Permission.microphone:
          return true; // These are optional features
      }
    }).toList();
  }

  List<Permission> _getAndroidRequiredPermissions() {
    return [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location, // Required for BLE scanning on Android
      Permission.notification,
    ];
  }

  List<Permission> _getIOSRequiredPermissions() {
    return [Permission.bluetooth, Permission.notification];
  }

  List<Permission> _getDesktopRequiredPermissions() {
    return [Permission.bluetooth, Permission.notification];
  }

  List<Permission> _getDefaultRequiredPermissions() {
    return [Permission.bluetooth, Permission.notification];
  }

  Future<void> _showRationaleIfNeeded(
    List<Permission> permissions,
    PermissionRequestConfig config,
  ) async {
    // This would show platform-specific rationale dialogs
    // For now, just log the rationale
    for (final permission in permissions) {
      final rationale =
          config.customRationale[permission] ?? permission.description;
      _logger.d(
        'PermissionManager: Rationale for ${permission.displayName}: $rationale',
      );
    }
  }

  Future<bool> _requestPermissionsWithRetry(
    List<Permission> permissions,
    PermissionRequestConfig config,
  ) async {
    _logger.d(
      'PermissionManager: _requestPermissionsWithRetry called with permissions: $permissions',
    );
    int attempts = 0;

    while (attempts <= config.maxRetries) {
      try {
        _logger.d(
          'PermissionManager: Attempt ${attempts + 1} - calling platform service requestPermissions',
        );
        final success = await _platformService.requestPermissions(permissions);
        _logger.d('PermissionManager: Platform service returned: $success');
        if (success || !config.retryOnFailure) {
          return success;
        }
      } catch (e) {
        _logger.w(
          'PermissionManager: Permission request attempt ${attempts + 1} failed: $e',
        );
      }

      attempts++;
      if (attempts <= config.maxRetries) {
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempts));
      }
    }

    return false;
  }

  Future<void> _navigateToSettingsIfNeeded(List<Permission> permissions) async {
    // This would navigate to platform-specific settings
    // For now, just log the action
    _logger.d(
      'PermissionManager: Would navigate to settings for permissions: $permissions',
    );
  }
}

/// Exception thrown when a permission request times out
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message';
}
