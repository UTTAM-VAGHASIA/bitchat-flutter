/// Feature registration model for managing feature lifecycle and dependencies
class FeatureRegistration {
  final String id;
  final String name;
  final Version version;
  final List<String> dependencies;
  final Map<String, dynamic> configuration;
  final FeatureLifecycle lifecycle;

  const FeatureRegistration({
    required this.id,
    required this.name,
    required this.version,
    required this.dependencies,
    required this.configuration,
    required this.lifecycle,
  });

  FeatureRegistration copyWith({
    String? id,
    String? name,
    Version? version,
    List<String>? dependencies,
    Map<String, dynamic>? configuration,
    FeatureLifecycle? lifecycle,
  }) {
    return FeatureRegistration(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      dependencies: dependencies ?? this.dependencies,
      configuration: configuration ?? this.configuration,
      lifecycle: lifecycle ?? this.lifecycle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureRegistration &&
        other.id == id &&
        other.name == name &&
        other.version == version &&
        other.dependencies == dependencies &&
        other.configuration == configuration &&
        other.lifecycle == lifecycle;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        version.hashCode ^
        dependencies.hashCode ^
        configuration.hashCode ^
        lifecycle.hashCode;
  }

  @override
  String toString() {
    return 'FeatureRegistration(id: $id, name: $name, version: $version, lifecycle: $lifecycle)';
  }
}

/// Version information for features
class Version {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;

  const Version({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease,
  });

  factory Version.parse(String version) {
    final parts = version.split('.');
    if (parts.length < 3) {
      throw ArgumentError('Invalid version format: $version');
    }

    final patchParts = parts[2].split('-');
    final patch = int.parse(patchParts[0]);
    final preRelease = patchParts.length > 1 ? patchParts[1] : null;

    return Version(
      major: int.parse(parts[0]),
      minor: int.parse(parts[1]),
      patch: patch,
      preRelease: preRelease,
    );
  }

  @override
  String toString() {
    final base = '$major.$minor.$patch';
    return preRelease != null ? '$base-$preRelease' : base;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Version &&
        other.major == major &&
        other.minor == minor &&
        other.patch == patch &&
        other.preRelease == preRelease;
  }

  @override
  int get hashCode {
    return major.hashCode ^
        minor.hashCode ^
        patch.hashCode ^
        preRelease.hashCode;
  }

  bool isGreaterThan(Version other) {
    if (major != other.major) return major > other.major;
    if (minor != other.minor) return minor > other.minor;
    if (patch != other.patch) return patch > other.patch;

    // Handle pre-release versions
    if (preRelease == null && other.preRelease != null) return true;
    if (preRelease != null && other.preRelease == null) return false;
    if (preRelease != null && other.preRelease != null) {
      return preRelease!.compareTo(other.preRelease!) > 0;
    }

    return false;
  }

  bool isLessThan(Version other) {
    return !isGreaterThan(other) && this != other;
  }

  bool isGreaterThanOrEqual(Version other) {
    return isGreaterThan(other) || this == other;
  }

  bool isLessThanOrEqual(Version other) {
    return isLessThan(other) || this == other;
  }
}

/// Feature lifecycle states
enum FeatureLifecycle {
  notStarted,
  initializing,
  initialized,
  starting,
  started,
  stopping,
  stopped,
  error,
  disposed,
}

extension FeatureLifecycleExtension on FeatureLifecycle {
  bool get isActive => this == FeatureLifecycle.started;
  bool get isInitialized => index >= FeatureLifecycle.initialized.index;
  bool get canStart => this == FeatureLifecycle.initialized;
  bool get canStop => this == FeatureLifecycle.started;
  bool get isError => this == FeatureLifecycle.error;
  bool get isDisposed => this == FeatureLifecycle.disposed;
}
