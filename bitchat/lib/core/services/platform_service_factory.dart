import 'dart:io';

import 'platform_service.dart';
import 'platform/android_platform_service.dart';
import 'platform/ios_platform_service.dart';
import 'platform/desktop_platform_service.dart';

/// Factory class for creating platform-specific PlatformService implementations
///
/// This factory automatically detects the current platform and returns the
/// appropriate implementation, ensuring clean architecture principles are
/// maintained while providing platform-specific functionality.
class PlatformServiceFactory {
  static PlatformService? _instance;

  /// Gets the singleton instance of the appropriate PlatformService
  ///
  /// The instance is created lazily and cached for subsequent calls.
  /// This ensures consistent behavior throughout the application lifecycle.
  static PlatformService getInstance() {
    _instance ??= _createPlatformService();
    return _instance!;
  }

  /// Creates a new instance of the appropriate PlatformService
  ///
  /// This method can be used for testing or when a fresh instance is needed.
  /// In most cases, you should use [getInstance] instead.
  static PlatformService createInstance() {
    return _createPlatformService();
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

  /// Creates the appropriate PlatformService based on the current platform
  static PlatformService _createPlatformService() {
    if (Platform.isAndroid) {
      return AndroidPlatformService();
    } else if (Platform.isIOS) {
      return IOSPlatformService();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return DesktopPlatformService();
    } else {
      throw UnsupportedError(
        'Platform ${Platform.operatingSystem} is not supported by BitChat',
      );
    }
  }

  /// Gets information about the current platform without creating a service instance
  ///
  /// This is useful for quick platform checks without the overhead of
  /// initializing the full platform service.
  static String getCurrentPlatformName() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown';
    }
  }

  /// Checks if the current platform is supported by BitChat
  static bool isCurrentPlatformSupported() {
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux;
  }

  /// Gets the list of all supported platform names
  static List<String> getSupportedPlatforms() {
    return ['Android', 'iOS', 'Windows', 'macOS', 'Linux'];
  }
}
