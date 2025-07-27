import 'permission_manager.dart';

/// Factory class for creating PermissionManager instances
///
/// This factory provides a centralized way to create and manage PermissionManager
/// instances, ensuring proper initialization and lifecycle management.
class PermissionManagerFactory {
  static PermissionManager? _instance;

  /// Gets the singleton instance of PermissionManager
  ///
  /// The instance is created lazily and cached for subsequent calls.
  /// This ensures consistent permission state management throughout the
  /// application lifecycle.
  static Future<PermissionManager> getInstance() async {
    _instance ??= await PermissionManager.create();
    return _instance!;
  }

  /// Creates a new instance of PermissionManager
  ///
  /// This method can be used for testing or when a fresh instance is needed.
  /// In most cases, you should use [getInstance] instead.
  static Future<PermissionManager> createInstance() async {
    return await PermissionManager.create();
  }

  /// Resets the singleton instance
  ///
  /// This is primarily useful for testing scenarios where you need to
  /// ensure a clean state between tests.
  static Future<void> reset() async {
    if (_instance != null) {
      await _instance!.dispose();
      _instance = null;
    }
  }

  /// Checks if the singleton instance has been created
  static bool get hasInstance => _instance != null;

  /// Gets the singleton instance if it exists, null otherwise
  ///
  /// This method does not create a new instance if one doesn't exist.
  /// Use [getInstance] if you need an instance is available.
  static PermissionManager? get instanceOrNull => _instance;
}
