import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/app_configuration.dart';
import '../models/platform_info.dart';
import 'dependency_injection.dart';

/// Service registry for registering all core services
class ServiceRegistry {
  static bool _isInitialized = false;

  /// Initialize all core services in the dependency injection container
  static Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('ServiceRegistry: Already initialized, skipping...');
      }
      return;
    }

    if (kDebugMode) {
      print('ServiceRegistry: Initializing core services...');
    }

    // Initialize DI container
    initializeDI();

    // Register core services
    await _registerCoreServices();

    // Register platform services
    await _registerPlatformServices();

    // Register configuration services
    await _registerConfigurationServices();

    // Register utility services
    await _registerUtilityServices();

    _isInitialized = true;

    if (kDebugMode) {
      print('ServiceRegistry: Core services initialized successfully');
    }
  }

  /// Register core application services
  static Future<void> _registerCoreServices() async {
    // Register logger service
    diContainer.registerSingleton<LoggerService>(() => LoggerServiceImpl());

    // Register error handler service
    diContainer.registerSingleton<ErrorHandlerService>(
      () => ErrorHandlerServiceImpl(),
      dependencies: [LoggerService],
    );

    // Register performance monitor service
    diContainer.registerSingleton<PerformanceMonitorService>(
      () => PerformanceMonitorServiceImpl(),
      dependencies: [LoggerService],
    );
  }

  /// Register platform-specific services
  static Future<void> _registerPlatformServices() async {
    // Register platform service
    diContainer.registerSingleton<PlatformService>(() => PlatformServiceImpl());

    // Register permission manager
    diContainer.registerSingleton<PermissionManager>(
      () => PermissionManagerImpl(),
      dependencies: [PlatformService, LoggerService],
    );

    // Register secure storage service
    diContainer.registerSingleton<SecureStorageService>(
      () => SecureStorageServiceImpl(),
      dependencies: [PlatformService],
    );
  }

  /// Register configuration and settings services
  static Future<void> _registerConfigurationServices() async {
    // Register configuration manager
    diContainer.registerSingleton<ConfigurationManager>(
      () => ConfigurationManagerImpl(),
      dependencies: [SecureStorageService, LoggerService],
    );

    // Register settings service
    diContainer.registerSingleton<SettingsService>(
      () => SettingsServiceImpl(),
      dependencies: [ConfigurationManager, SecureStorageService],
    );
  }

  /// Register utility services
  static Future<void> _registerUtilityServices() async {
    // Register memory manager
    diContainer.registerSingleton<MemoryManager>(
      () => MemoryManagerImpl(),
      dependencies: [LoggerService, PerformanceMonitorService],
    );

    // Register background task manager
    diContainer.registerSingleton<BackgroundTaskManager>(
      () => BackgroundTaskManagerImpl(),
      dependencies: [LoggerService, PerformanceMonitorService],
    );
  }

  /// Check if services are initialized
  static bool get isInitialized => _isInitialized;

  /// Dispose all services
  static Future<void> dispose() async {
    if (!_isInitialized) return;

    if (kDebugMode) {
      print('ServiceRegistry: Disposing all services...');
    }

    await diContainer.dispose();
    _isInitialized = false;

    if (kDebugMode) {
      print('ServiceRegistry: All services disposed');
    }
  }
}

// Service interfaces - these will be implemented in their respective feature modules

/// Logger service interface
abstract class LoggerService {
  void debug(String message, [Object? error, StackTrace? stackTrace]);
  void info(String message, [Object? error, StackTrace? stackTrace]);
  void warning(String message, [Object? error, StackTrace? stackTrace]);
  void error(String message, [Object? error, StackTrace? stackTrace]);
  void setLogLevel(LogLevel level);
}

/// Logger service implementation
class LoggerServiceImpl implements LoggerService {
  LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_currentLevel.index <= LogLevel.debug.index) {
      _log('DEBUG', message, error, stackTrace);
    }
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (_currentLevel.index <= LogLevel.info.index) {
      _log('INFO', message, error, stackTrace);
    }
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (_currentLevel.index <= LogLevel.warning.index) {
      _log('WARNING', message, error, stackTrace);
    }
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_currentLevel.index <= LogLevel.error.index) {
      _log('ERROR', message, error, stackTrace);
    }
  }

  @override
  void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  void _log(
    String level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $level: $message';

    if (kDebugMode) {
      print(logMessage);
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }
}

/// Log levels
enum LogLevel { debug, info, warning, error }

/// Error handler service interface
abstract class ErrorHandlerService {
  void handleError(Object error, StackTrace stackTrace, {String? context});
  void reportError(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? metadata,
  });
}

/// Error handler service implementation
class ErrorHandlerServiceImpl implements ErrorHandlerService {
  @override
  void handleError(Object error, StackTrace stackTrace, {String? context}) {
    final logger = getSingleton<LoggerService>();
    final contextMessage = context != null ? ' in $context' : '';
    logger.error('Unhandled error$contextMessage: $error', error, stackTrace);
  }

  @override
  void reportError(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? metadata,
  }) {
    // In a real implementation, this would send errors to a crash reporting service
    handleError(error, stackTrace, context: 'Error reporting');
  }
}

/// Performance monitor service interface
abstract class PerformanceMonitorService {
  void startTimer(String name);
  void endTimer(String name);
  void recordMetric(String name, double value);
  Map<String, dynamic> getMetrics();
}

/// Performance monitor service implementation
class PerformanceMonitorServiceImpl implements PerformanceMonitorService {
  final Map<String, DateTime> _timers = {};
  final Map<String, double> _metrics = {};

  @override
  void startTimer(String name) {
    _timers[name] = DateTime.now();
  }

  @override
  void endTimer(String name) {
    final startTime = _timers.remove(name);
    if (startTime != null) {
      final duration = DateTime.now()
          .difference(startTime)
          .inMilliseconds
          .toDouble();
      recordMetric('${name}_duration_ms', duration);
    }
  }

  @override
  void recordMetric(String name, double value) {
    _metrics[name] = value;
  }

  @override
  Map<String, dynamic> getMetrics() {
    return Map.from(_metrics);
  }
}

// Placeholder service interfaces - these will be implemented in their respective modules

abstract class PlatformService {
  Future<PlatformInfo> getPlatformInfo();
  Future<bool> requestPermissions(List<Permission> permissions);
  Future<void> setBackgroundMode(bool enabled);
}

class PlatformServiceImpl implements PlatformService {
  @override
  Future<PlatformInfo> getPlatformInfo() async {
    // Placeholder implementation
    return PlatformInfo(
      type: PlatformType.android,
      version: '1.0.0',
      deviceModel: 'Unknown',
      capabilities: [
        PlatformCapability.bluetooth,
        PlatformCapability.fileSystem,
      ],
      performance: PerformanceProfile.medium,
    );
  }

  @override
  Future<bool> requestPermissions(List<Permission> permissions) async {
    // Placeholder implementation
    return true;
  }

  @override
  Future<void> setBackgroundMode(bool enabled) async {
    // Placeholder implementation
  }
}

enum Permission { bluetooth, location, storage, notifications }

abstract class PermissionManager {
  Future<bool> requestPermission(Permission permission);
  Future<Map<Permission, bool>> requestMultiplePermissions(
    List<Permission> permissions,
  );
  Future<bool> hasPermission(Permission permission);
}

class PermissionManagerImpl implements PermissionManager {
  @override
  Future<bool> requestPermission(Permission permission) async {
    // Placeholder implementation
    return true;
  }

  @override
  Future<Map<Permission, bool>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    // Placeholder implementation
    return {for (final permission in permissions) permission: true};
  }

  @override
  Future<bool> hasPermission(Permission permission) async {
    // Placeholder implementation
    return true;
  }
}

abstract class SecureStorageService {
  Future<void> store(String key, String value);
  Future<String?> retrieve(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

class SecureStorageServiceImpl implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> store(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> retrieve(String key) async {
    return _storage[key];
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}

abstract class ConfigurationManager {
  Future<T?> getSetting<T>(String key, [T? defaultValue]);
  Future<void> setSetting<T>(String key, T value);
  Future<void> resetToDefaults();
  Stream<ConfigurationChange> get configurationChanges;
}

class ConfigurationManagerImpl implements ConfigurationManager {
  final Map<String, dynamic> _settings = {};

  @override
  Future<T?> getSetting<T>(String key, [T? defaultValue]) async {
    return _settings[key] as T? ?? defaultValue;
  }

  @override
  Future<void> setSetting<T>(String key, T value) async {
    _settings[key] = value;
  }

  @override
  Future<void> resetToDefaults() async {
    _settings.clear();
  }

  @override
  Stream<ConfigurationChange> get configurationChanges => const Stream.empty();
}

class ConfigurationChange {
  final String key;
  final dynamic oldValue;
  final dynamic newValue;

  const ConfigurationChange({
    required this.key,
    required this.oldValue,
    required this.newValue,
  });
}

abstract class SettingsService {
  Future<AppConfiguration> getConfiguration();
  Future<void> updateConfiguration(AppConfiguration configuration);
}

class SettingsServiceImpl implements SettingsService {
  @override
  Future<AppConfiguration> getConfiguration() async {
    // Placeholder implementation
    return const AppConfiguration(
      version: '1.0.0',
      theme: AppTheme.system,
      locale: Locale('en', 'US'),
      featureSettings: {},
      security: SecuritySettings(
        enableEncryption: true,
        enableForwardSecrecy: true,
        enableCoverTraffic: false,
        keyRotationInterval: Duration(hours: 24),
      ),
      performance: PerformanceSettings(
        enableLazyLoading: true,
        maxCacheSize: 50 * 1024 * 1024,
        backgroundTaskInterval: Duration(seconds: 30),
        enablePerformanceMonitoring: false,
      ),
    );
  }

  @override
  Future<void> updateConfiguration(AppConfiguration configuration) async {
    // Placeholder implementation
  }
}

abstract class MemoryManager {
  void optimizeMemoryUsage();
  int getCurrentMemoryUsage();
  void clearCache();
}

class MemoryManagerImpl implements MemoryManager {
  @override
  void optimizeMemoryUsage() {
    // Placeholder implementation
  }

  @override
  int getCurrentMemoryUsage() {
    // Placeholder implementation
    return 0;
  }

  @override
  void clearCache() {
    // Placeholder implementation
  }
}

abstract class BackgroundTaskManager {
  Future<void> scheduleTask(BackgroundTask task);
  void cancelTask(String taskId);
  List<BackgroundTask> getActiveTasks();
}

class BackgroundTaskManagerImpl implements BackgroundTaskManager {
  final List<BackgroundTask> _tasks = [];

  @override
  Future<void> scheduleTask(BackgroundTask task) async {
    _tasks.add(task);
  }

  @override
  void cancelTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
  }

  @override
  List<BackgroundTask> getActiveTasks() {
    return List.from(_tasks);
  }
}

class BackgroundTask {
  final String id;
  final String name;
  final Future<void> Function() execute;
  final Duration interval;

  const BackgroundTask({
    required this.id,
    required this.name,
    required this.execute,
    required this.interval,
  });
}
