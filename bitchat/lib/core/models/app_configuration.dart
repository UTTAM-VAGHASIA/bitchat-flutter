import 'package:flutter/material.dart';

/// Application configuration model containing all app-wide settings
class AppConfiguration {
  final String version;
  final AppTheme theme;
  final Locale locale;
  final Map<String, dynamic> featureSettings;
  final SecuritySettings security;
  final PerformanceSettings performance;

  const AppConfiguration({
    required this.version,
    required this.theme,
    required this.locale,
    required this.featureSettings,
    required this.security,
    required this.performance,
  });

  AppConfiguration copyWith({
    String? version,
    AppTheme? theme,
    Locale? locale,
    Map<String, dynamic>? featureSettings,
    SecuritySettings? security,
    PerformanceSettings? performance,
  }) {
    return AppConfiguration(
      version: version ?? this.version,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      featureSettings: featureSettings ?? this.featureSettings,
      security: security ?? this.security,
      performance: performance ?? this.performance,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppConfiguration &&
        other.version == version &&
        other.theme == theme &&
        other.locale == locale &&
        other.featureSettings == featureSettings &&
        other.security == security &&
        other.performance == performance;
  }

  @override
  int get hashCode {
    return version.hashCode ^
        theme.hashCode ^
        locale.hashCode ^
        featureSettings.hashCode ^
        security.hashCode ^
        performance.hashCode;
  }
}

/// Application theme configuration
enum AppTheme { light, dark, system }

/// Security settings configuration
class SecuritySettings {
  final bool enableEncryption;
  final bool enableForwardSecrecy;
  final bool enableCoverTraffic;
  final Duration keyRotationInterval;

  const SecuritySettings({
    required this.enableEncryption,
    required this.enableForwardSecrecy,
    required this.enableCoverTraffic,
    required this.keyRotationInterval,
  });

  SecuritySettings copyWith({
    bool? enableEncryption,
    bool? enableForwardSecrecy,
    bool? enableCoverTraffic,
    Duration? keyRotationInterval,
  }) {
    return SecuritySettings(
      enableEncryption: enableEncryption ?? this.enableEncryption,
      enableForwardSecrecy: enableForwardSecrecy ?? this.enableForwardSecrecy,
      enableCoverTraffic: enableCoverTraffic ?? this.enableCoverTraffic,
      keyRotationInterval: keyRotationInterval ?? this.keyRotationInterval,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecuritySettings &&
        other.enableEncryption == enableEncryption &&
        other.enableForwardSecrecy == enableForwardSecrecy &&
        other.enableCoverTraffic == enableCoverTraffic &&
        other.keyRotationInterval == keyRotationInterval;
  }

  @override
  int get hashCode {
    return enableEncryption.hashCode ^
        enableForwardSecrecy.hashCode ^
        enableCoverTraffic.hashCode ^
        keyRotationInterval.hashCode;
  }
}

/// Performance settings configuration
class PerformanceSettings {
  final bool enableLazyLoading;
  final int maxCacheSize;
  final Duration backgroundTaskInterval;
  final bool enablePerformanceMonitoring;

  const PerformanceSettings({
    required this.enableLazyLoading,
    required this.maxCacheSize,
    required this.backgroundTaskInterval,
    required this.enablePerformanceMonitoring,
  });

  PerformanceSettings copyWith({
    bool? enableLazyLoading,
    int? maxCacheSize,
    Duration? backgroundTaskInterval,
    bool? enablePerformanceMonitoring,
  }) {
    return PerformanceSettings(
      enableLazyLoading: enableLazyLoading ?? this.enableLazyLoading,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      backgroundTaskInterval:
          backgroundTaskInterval ?? this.backgroundTaskInterval,
      enablePerformanceMonitoring:
          enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceSettings &&
        other.enableLazyLoading == enableLazyLoading &&
        other.maxCacheSize == maxCacheSize &&
        other.backgroundTaskInterval == backgroundTaskInterval &&
        other.enablePerformanceMonitoring == enablePerformanceMonitoring;
  }

  @override
  int get hashCode {
    return enableLazyLoading.hashCode ^
        maxCacheSize.hashCode ^
        backgroundTaskInterval.hashCode ^
        enablePerformanceMonitoring.hashCode;
  }
}
