import 'package:flutter/material.dart';

import '../../core/models/app_configuration.dart';
import '../../core/services/dependency_injection.dart';
import '../../core/services/service_registry.dart';

/// Global application state provider
class AppStateProvider extends ChangeNotifier {
  final ConfigurationManager _configurationManager;
  final LoggerService _logger;

  AppConfiguration? _configuration;
  bool _isInitialized = false;
  String? _errorMessage;

  AppStateProvider({
    required ConfigurationManager configurationManager,
    required LoggerService logger,
  }) : _configurationManager = configurationManager,
       _logger = logger {
    _initialize();
  }

  /// Current application configuration
  AppConfiguration? get configuration => _configuration;

  /// Whether the app state is initialized
  bool get isInitialized => _isInitialized;

  /// Current error message, if any
  String? get errorMessage => _errorMessage;

  /// Current theme mode
  ThemeMode get themeMode {
    if (_configuration == null) return ThemeMode.system;

    switch (_configuration!.theme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  /// Current locale
  Locale get locale => _configuration?.locale ?? const Locale('en', 'US');

  /// Initialize the app state
  Future<void> _initialize() async {
    try {
      _logger.info('AppStateProvider: Initializing app state...');

      // Load configuration from settings service
      final settingsService = getSingleton<SettingsService>();
      _configuration = await settingsService.getConfiguration();

      _isInitialized = true;
      _errorMessage = null;

      _logger.info('AppStateProvider: App state initialized successfully');
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(
        'AppStateProvider: Failed to initialize app state',
        error,
        stackTrace,
      );
      _errorMessage = 'Failed to initialize application: $error';
      _isInitialized = false;
      notifyListeners();
    }
  }

  /// Update the application theme
  Future<void> updateTheme(AppTheme theme) async {
    if (_configuration == null) return;

    try {
      _logger.info('AppStateProvider: Updating theme to $theme');

      final updatedConfig = _configuration!.copyWith(theme: theme);
      await _updateConfiguration(updatedConfig);

      _logger.info('AppStateProvider: Theme updated successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'AppStateProvider: Failed to update theme',
        error,
        stackTrace,
      );
      _errorMessage = 'Failed to update theme: $error';
      notifyListeners();
    }
  }

  /// Update the application locale
  Future<void> updateLocale(Locale locale) async {
    if (_configuration == null) return;

    try {
      _logger.info('AppStateProvider: Updating locale to $locale');

      final updatedConfig = _configuration!.copyWith(locale: locale);
      await _updateConfiguration(updatedConfig);

      _logger.info('AppStateProvider: Locale updated successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'AppStateProvider: Failed to update locale',
        error,
        stackTrace,
      );
      _errorMessage = 'Failed to update locale: $error';
      notifyListeners();
    }
  }

  /// Update feature settings
  Future<void> updateFeatureSettings(Map<String, dynamic> settings) async {
    if (_configuration == null) return;

    try {
      _logger.info('AppStateProvider: Updating feature settings');

      final updatedConfig = _configuration!.copyWith(featureSettings: settings);
      await _updateConfiguration(updatedConfig);

      _logger.info('AppStateProvider: Feature settings updated successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'AppStateProvider: Failed to update feature settings',
        error,
        stackTrace,
      );
      _errorMessage = 'Failed to update feature settings: $error';
      notifyListeners();
    }
  }

  /// Update security settings
  Future<void> updateSecuritySettings(SecuritySettings settings) async {
    if (_configuration == null) return;

    try {
      _logger.info('AppStateProvider: Updating security settings');

      final updatedConfig = _configuration!.copyWith(security: settings);
      await _updateConfiguration(updatedConfig);

      _logger.info('AppStateProvider: Security settings updated successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'AppStateProvider: Failed to update security settings',
        error,
        stackTrace,
      );
      _errorMessage = 'Failed to update security settings: $error';
      notifyListeners();
    }
  }

  /// Update performance settings
  Future<void> updatePerformanceSettings(PerformanceSettings settings) async {
    if (_configuration == null) return;

    try {
      _logger.info('AppStateProvider: Updating performance settings');

      final updatedConfig = _configuration!.copyWith(performance: settings);
      await _updateConfiguration(updatedConfig);

      _logger.info(
        'AppStateProvider: Performance settings updated successfully',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'AppStateProvider: Failed to update performance settings',
        error,
        stackTrace,
      );
      _errorMessage = 'Failed to update performance settings: $error';
      notifyListeners();
    }
  }

  /// Reset configuration to defaults
  Future<void> resetToDefaults() async {
    try {
      _logger.info('AppStateProvider: Resetting configuration to defaults');

      await _configurationManager.resetToDefaults();
      await _initialize(); // Reload configuration

      _logger.info(
        'AppStateProvider: Configuration reset to defaults successfully',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'AppStateProvider: Failed to reset configuration',
        error,
        stackTrace,
      );
      _errorMessage = 'Failed to reset configuration: $error';
      notifyListeners();
    }
  }

  /// Clear any error messages
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Update configuration and persist changes
  Future<void> _updateConfiguration(AppConfiguration configuration) async {
    _configuration = configuration;

    // Persist configuration
    final settingsService = getSingleton<SettingsService>();
    await settingsService.updateConfiguration(configuration);

    notifyListeners();
  }

  @override
  void dispose() {
    _logger.info('AppStateProvider: Disposing app state provider');
    super.dispose();
  }
}
