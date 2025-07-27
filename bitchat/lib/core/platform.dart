/// Platform abstraction layer for BitChat Flutter
///
/// This library provides a unified interface for accessing platform-specific
/// functionality across iOS, Android, and desktop platforms while maintaining
/// clean architecture principles.
///
/// ## Usage
///
/// ```dart
/// import 'package:bitchat/core/platform.dart';
///
/// // Get the platform service instance
/// final platformService = PlatformServiceFactory.getInstance();
///
/// // Request permissions
/// final granted = await platformService.requestPermissions([
///   Permission.bluetooth,
///   Permission.bluetoothAdvertise,
/// ]);
///
/// // Get platform information
/// final platformInfo = await platformService.getPlatformInfo();
/// print('Running on ${platformInfo.type} ${platformInfo.version}');
///
/// // Listen for platform events
/// platformService.platformEvents.listen((event) {
///   if (event is PermissionChangedEvent) {
///     print('Permission ${event.permission} changed to ${event.status}');
///   }
/// });
/// ```
library;

// Core service interface
export 'services/platform_service.dart';
export 'services/platform_service_factory.dart';

// Data models
export 'models/platform_info.dart';
export 'models/permission.dart';
export 'models/platform_event.dart';

// Platform-specific implementations (for testing and advanced usage)
export 'services/platform/android_platform_service.dart';
export 'services/platform/ios_platform_service.dart';
export 'services/platform/desktop_platform_service.dart';
