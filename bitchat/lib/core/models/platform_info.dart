/// Enumeration of supported platform types
enum PlatformType { android, ios, windows, macos, linux, unknown }

/// Enumeration of platform capabilities relevant to BitChat
enum PlatformCapability {
  bluetooth,
  bluetoothLowEnergy,
  bluetoothAdvertising,
  bluetoothScanning,
  backgroundProcessing,
  locationServices,
  secureStorage,
  biometricAuthentication,
  notifications,
  fileSystem,
  networkConnectivity,
}

/// Performance profile categories for device optimization
enum PerformanceProfile {
  /// High-end devices with ample resources
  high,

  /// Mid-range devices with moderate resources
  medium,

  /// Low-end devices requiring optimization
  low,

  /// Unknown performance characteristics
  unknown,
}

/// Battery optimization status
enum BatteryOptimizationStatus {
  /// Battery optimization is active
  enabled,

  /// Battery optimization is disabled
  disabled,

  /// Battery optimization status is unknown
  unknown,

  /// Battery optimization is not supported on this platform
  notSupported,
}

/// Comprehensive information about the current platform
///
/// This model contains all relevant information about the device and platform
/// that affects BitChat's functionality, performance, and capabilities.
class PlatformInfo {
  /// The type of platform (iOS, Android, desktop)
  final PlatformType type;

  /// Platform version (e.g., "iOS 17.2", "Android 14", "Windows 11")
  final String version;

  /// Device model identifier (e.g., "iPhone 15 Pro", "Pixel 8")
  final String deviceModel;

  /// List of capabilities supported by this platform
  final List<PlatformCapability> capabilities;

  /// Performance profile for optimization decisions
  final PerformanceProfile performance;

  /// Additional platform-specific metadata
  final Map<String, dynamic> metadata;

  /// Whether the device supports Bluetooth Low Energy
  bool get supportsBluetooth =>
      capabilities.contains(PlatformCapability.bluetooth);

  /// Whether the device supports BLE advertising
  bool get supportsBluetoothAdvertising =>
      capabilities.contains(PlatformCapability.bluetoothAdvertising);

  /// Whether the device supports background processing
  bool get supportsBackgroundProcessing =>
      capabilities.contains(PlatformCapability.backgroundProcessing);

  /// Whether the device has secure storage capabilities
  bool get supportsSecureStorage =>
      capabilities.contains(PlatformCapability.secureStorage);

  /// Whether this is a mobile platform (iOS or Android)
  bool get isMobile => type == PlatformType.ios || type == PlatformType.android;

  /// Whether this is a desktop platform
  bool get isDesktop =>
      type == PlatformType.windows ||
      type == PlatformType.macos ||
      type == PlatformType.linux;

  const PlatformInfo({
    required this.type,
    required this.version,
    required this.deviceModel,
    required this.capabilities,
    required this.performance,
    this.metadata = const {},
  });

  /// Creates a copy of this PlatformInfo with updated values
  PlatformInfo copyWith({
    PlatformType? type,
    String? version,
    String? deviceModel,
    List<PlatformCapability>? capabilities,
    PerformanceProfile? performance,
    Map<String, dynamic>? metadata,
  }) {
    return PlatformInfo(
      type: type ?? this.type,
      version: version ?? this.version,
      deviceModel: deviceModel ?? this.deviceModel,
      capabilities: capabilities ?? this.capabilities,
      performance: performance ?? this.performance,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlatformInfo &&
        other.type == type &&
        other.version == version &&
        other.deviceModel == deviceModel &&
        _listEquals(other.capabilities, capabilities) &&
        other.performance == performance &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      version,
      deviceModel,
      Object.hashAll(capabilities),
      performance,
      Object.hashAll(metadata.entries),
    );
  }

  @override
  String toString() {
    return 'PlatformInfo('
        'type: $type, '
        'version: $version, '
        'deviceModel: $deviceModel, '
        'capabilities: $capabilities, '
        'performance: $performance, '
        'metadata: $metadata'
        ')';
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  /// Helper method to compare maps
  bool _mapEquals<T, U>(Map<T, U>? a, Map<T, U>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final T key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
}
