/// Enumeration of permissions required by BitChat
enum Permission {
  /// Bluetooth access permission
  bluetooth,

  /// Bluetooth advertising permission (Android 12+)
  bluetoothAdvertise,

  /// Bluetooth connection permission (Android 12+)
  bluetoothConnect,

  /// Bluetooth scanning permission (Android 12+)
  bluetoothScan,

  /// Location permission (required for BLE scanning on Android)
  location,

  /// Precise location permission
  locationWhenInUse,

  /// Background location permission
  locationAlways,

  /// Notification permission
  notification,

  /// Storage permission for message persistence
  storage,

  /// Camera permission (for future QR code features)
  camera,

  /// Microphone permission (for future voice message features)
  microphone,
}

/// Status of a permission request
enum PermissionStatus {
  /// Permission has been granted
  granted,

  /// Permission has been denied
  denied,

  /// Permission has been permanently denied (requires settings)
  permanentlyDenied,

  /// Permission is restricted (iOS parental controls, etc.)
  restricted,

  /// Permission status is unknown
  unknown,

  /// Permission is not applicable on this platform
  notApplicable,
}

/// Extension methods for Permission enum
extension PermissionExtension on Permission {
  /// Gets the human-readable name for this permission
  String get displayName {
    switch (this) {
      case Permission.bluetooth:
        return 'Bluetooth';
      case Permission.bluetoothAdvertise:
        return 'Bluetooth Advertising';
      case Permission.bluetoothConnect:
        return 'Bluetooth Connection';
      case Permission.bluetoothScan:
        return 'Bluetooth Scanning';
      case Permission.location:
        return 'Location';
      case Permission.locationWhenInUse:
        return 'Location (When in Use)';
      case Permission.locationAlways:
        return 'Location (Always)';
      case Permission.notification:
        return 'Notifications';
      case Permission.storage:
        return 'Storage';
      case Permission.camera:
        return 'Camera';
      case Permission.microphone:
        return 'Microphone';
    }
  }

  /// Gets the description of why this permission is needed
  String get description {
    switch (this) {
      case Permission.bluetooth:
        return 'Required to communicate with other BitChat devices';
      case Permission.bluetoothAdvertise:
        return 'Required to advertise your device to other BitChat users';
      case Permission.bluetoothConnect:
        return 'Required to connect to other BitChat devices';
      case Permission.bluetoothScan:
        return 'Required to discover other BitChat devices nearby';
      case Permission.location:
        return 'Required for Bluetooth device discovery on Android';
      case Permission.locationWhenInUse:
        return 'Required for Bluetooth device discovery while using the app';
      case Permission.locationAlways:
        return 'Required for background Bluetooth device discovery';
      case Permission.notification:
        return 'Required to show message notifications';
      case Permission.storage:
        return 'Required to store messages and app data';
      case Permission.camera:
        return 'Required for QR code scanning features';
      case Permission.microphone:
        return 'Required for voice message features';
    }
  }

  /// Whether this permission is critical for core BitChat functionality
  bool get isCritical {
    switch (this) {
      case Permission.bluetooth:
      case Permission.bluetoothAdvertise:
      case Permission.bluetoothConnect:
      case Permission.bluetoothScan:
        return true;
      case Permission.location:
      case Permission.locationWhenInUse:
        return true; // Critical on Android for BLE scanning
      case Permission.locationAlways:
      case Permission.notification:
      case Permission.storage:
      case Permission.camera:
      case Permission.microphone:
        return false;
    }
  }
}

/// Extension methods for PermissionStatus enum
extension PermissionStatusExtension on PermissionStatus {
  /// Whether the permission is granted
  bool get isGranted => this == PermissionStatus.granted;

  /// Whether the permission is denied
  bool get isDenied =>
      this == PermissionStatus.denied ||
      this == PermissionStatus.permanentlyDenied ||
      this == PermissionStatus.restricted;

  /// Whether the permission can be requested again
  bool get canRequest =>
      this == PermissionStatus.denied || this == PermissionStatus.unknown;

  /// Whether the user needs to go to settings to grant the permission
  bool get requiresSettings => this == PermissionStatus.permanentlyDenied;
}
