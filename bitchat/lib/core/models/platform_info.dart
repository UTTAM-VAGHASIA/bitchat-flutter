/// Platform information model containing device and capability details
class PlatformInfo {
  final PlatformType type;
  final String version;
  final String deviceModel;
  final List<Capability> capabilities;
  final PerformanceProfile performance;

  const PlatformInfo({
    required this.type,
    required this.version,
    required this.deviceModel,
    required this.capabilities,
    required this.performance,
  });

  PlatformInfo copyWith({
    PlatformType? type,
    String? version,
    String? deviceModel,
    List<Capability>? capabilities,
    PerformanceProfile? performance,
  }) {
    return PlatformInfo(
      type: type ?? this.type,
      version: version ?? this.version,
      deviceModel: deviceModel ?? this.deviceModel,
      capabilities: capabilities ?? this.capabilities,
      performance: performance ?? this.performance,
    );
  }

  bool hasCapability(Capability capability) {
    return capabilities.contains(capability);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlatformInfo &&
        other.type == type &&
        other.version == version &&
        other.deviceModel == deviceModel &&
        other.capabilities == capabilities &&
        other.performance == performance;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        version.hashCode ^
        deviceModel.hashCode ^
        capabilities.hashCode ^
        performance.hashCode;
  }

  @override
  String toString() {
    return 'PlatformInfo(type: $type, version: $version, model: $deviceModel)';
  }
}

/// Supported platform types
enum PlatformType { android, ios, windows, macos, linux, web }

extension PlatformTypeExtension on PlatformType {
  bool get isMobile => this == PlatformType.android || this == PlatformType.ios;
  bool get isDesktop =>
      this == PlatformType.windows ||
      this == PlatformType.macos ||
      this == PlatformType.linux;
  bool get isWeb => this == PlatformType.web;

  String get displayName {
    switch (this) {
      case PlatformType.android:
        return 'Android';
      case PlatformType.ios:
        return 'iOS';
      case PlatformType.windows:
        return 'Windows';
      case PlatformType.macos:
        return 'macOS';
      case PlatformType.linux:
        return 'Linux';
      case PlatformType.web:
        return 'Web';
    }
  }
}

/// Device capabilities
enum Capability {
  bluetooth,
  bluetoothLowEnergy,
  location,
  camera,
  microphone,
  storage,
  notifications,
  backgroundProcessing,
  networkAccess,
  fileSystem,
}

extension CapabilityExtension on Capability {
  String get displayName {
    switch (this) {
      case Capability.bluetooth:
        return 'Bluetooth';
      case Capability.bluetoothLowEnergy:
        return 'Bluetooth Low Energy';
      case Capability.location:
        return 'Location Services';
      case Capability.camera:
        return 'Camera';
      case Capability.microphone:
        return 'Microphone';
      case Capability.storage:
        return 'Storage';
      case Capability.notifications:
        return 'Notifications';
      case Capability.backgroundProcessing:
        return 'Background Processing';
      case Capability.networkAccess:
        return 'Network Access';
      case Capability.fileSystem:
        return 'File System';
    }
  }

  bool get isRequired {
    switch (this) {
      case Capability.bluetooth:
      case Capability.bluetoothLowEnergy:
      case Capability.storage:
        return true;
      default:
        return false;
    }
  }
}

/// Performance profile for the device
class PerformanceProfile {
  final PerformanceTier tier;
  final int memoryMB;
  final int cpuCores;
  final bool hasHardwareEncryption;
  final double batteryOptimizationFactor;

  const PerformanceProfile({
    required this.tier,
    required this.memoryMB,
    required this.cpuCores,
    required this.hasHardwareEncryption,
    required this.batteryOptimizationFactor,
  });

  PerformanceProfile copyWith({
    PerformanceTier? tier,
    int? memoryMB,
    int? cpuCores,
    bool? hasHardwareEncryption,
    double? batteryOptimizationFactor,
  }) {
    return PerformanceProfile(
      tier: tier ?? this.tier,
      memoryMB: memoryMB ?? this.memoryMB,
      cpuCores: cpuCores ?? this.cpuCores,
      hasHardwareEncryption:
          hasHardwareEncryption ?? this.hasHardwareEncryption,
      batteryOptimizationFactor:
          batteryOptimizationFactor ?? this.batteryOptimizationFactor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceProfile &&
        other.tier == tier &&
        other.memoryMB == memoryMB &&
        other.cpuCores == cpuCores &&
        other.hasHardwareEncryption == hasHardwareEncryption &&
        other.batteryOptimizationFactor == batteryOptimizationFactor;
  }

  @override
  int get hashCode {
    return tier.hashCode ^
        memoryMB.hashCode ^
        cpuCores.hashCode ^
        hasHardwareEncryption.hashCode ^
        batteryOptimizationFactor.hashCode;
  }

  @override
  String toString() {
    return 'PerformanceProfile(tier: $tier, memory: ${memoryMB}MB, cores: $cpuCores)';
  }
}

/// Performance tier classification
enum PerformanceTier { low, medium, high, premium }

extension PerformanceTierExtension on PerformanceTier {
  String get displayName {
    switch (this) {
      case PerformanceTier.low:
        return 'Low Performance';
      case PerformanceTier.medium:
        return 'Medium Performance';
      case PerformanceTier.high:
        return 'High Performance';
      case PerformanceTier.premium:
        return 'Premium Performance';
    }
  }

  int get maxConcurrentConnections {
    switch (this) {
      case PerformanceTier.low:
        return 2;
      case PerformanceTier.medium:
        return 4;
      case PerformanceTier.high:
        return 6;
      case PerformanceTier.premium:
        return 8;
    }
  }

  Duration get backgroundTaskInterval {
    switch (this) {
      case PerformanceTier.low:
        return const Duration(seconds: 60);
      case PerformanceTier.medium:
        return const Duration(seconds: 30);
      case PerformanceTier.high:
        return const Duration(seconds: 15);
      case PerformanceTier.premium:
        return const Duration(seconds: 10);
    }
  }
}
