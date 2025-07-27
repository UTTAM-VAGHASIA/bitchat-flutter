# BitChat Flutter - Main App Design Document

## Overview

The BitChat Flutter main application serves as the foundational layer for a decentralized peer-to-peer messaging system operating over Bluetooth Low Energy (BLE) mesh networks. This design document outlines the architecture, components, and implementation strategy for the main app that provides core infrastructure, application shell, and coordination between individual features while maintaining 100% binary protocol compatibility with existing iOS and Android BitChat implementations.

The main app follows Clean Architecture principles with clear layer separation and uses Flutter's cross-platform capabilities to support iOS 14.0+, Android 8.0+ (API 26+), and desktop platforms (Windows, macOS, Linux).

## Architecture

### Clean Architecture Layers

The application follows a strict Clean Architecture pattern with the following layer hierarchy:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   UI Screens    │  │   Providers     │  │  Navigation  │ │
│  │   & Widgets     │  │ (State Mgmt)    │  │   & Routing  │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                   Application Layer                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   Use Cases     │  │   App Services  │  │  Coordinators│ │
│  │  & Interactors  │  │   & Facades     │  │  & Mediators │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │    Entities     │  │  Repository     │  │   Domain     │ │
│  │   & Models      │  │  Interfaces     │  │   Services   │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                 Infrastructure Layer                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │  Repositories   │  │   Data Sources  │  │   External   │ │
│  │ Implementation  │  │  (Local/Remote) │  │   Services   │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    Platform Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   Flutter       │  │   Native        │  │   System     │ │
│  │   Framework     │  │   Platform      │  │   Services   │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**Design Rationale**: Clean Architecture ensures maintainability, testability, and independence from external frameworks. Each layer has clear responsibilities and dependencies flow inward, making the system resilient to changes in external dependencies.

### Dependency Injection Architecture

The application uses a centralized dependency injection container to manage object lifecycles and dependencies:

```dart
// Core DI Container Structure
abstract class DIContainer {
  // Singleton services
  T getSingleton<T>();
  
  // Factory services
  T getFactory<T>();
  
  // Scoped services (per feature/session)
  T getScoped<T>();
}
```

**Design Rationale**: Dependency injection enables loose coupling, easier testing through mock injection, and centralized configuration of service lifecycles.

## Components and Interfaces

### Core Application Components

#### 1. Application Shell (`AppShell`)

The main application container that provides:
- Material Design 3 theming with light/dark mode support
- Global navigation structure
- Background service coordination
- System-wide error boundary

```dart
class AppShell extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: AppRouter.config,
      builder: (context, child) => ErrorBoundary(child: child),
    );
  }
}
```

#### 2. Feature Coordinator (`FeatureCoordinator`)

Manages communication and coordination between features:

```dart
abstract class FeatureCoordinator {
  void registerFeature(Feature feature);
  void unregisterFeature(String featureId);
  Future<void> coordinateFeatures(CoordinationEvent event);
  Stream<FeatureEvent> get eventStream;
}
```

**Design Rationale**: The coordinator pattern ensures features remain decoupled while enabling necessary inter-feature communication through well-defined events.

#### 3. Configuration Manager (`ConfigurationManager`)

Handles application-wide settings and preferences:

```dart
abstract class ConfigurationManager {
  Future<T> getSetting<T>(String key, T defaultValue);
  Future<void> setSetting<T>(String key, T value);
  Future<void> resetToDefaults();
  Stream<ConfigurationChange> get configurationChanges;
}
```

### Platform Abstraction Layer

#### Platform Service Interface

Abstracts platform-specific functionality:

```dart
abstract class PlatformService {
  Future<bool> requestPermissions(List<Permission> permissions);
  Future<PlatformInfo> getPlatformInfo();
  Future<void> setBackgroundMode(bool enabled);
  Stream<PlatformEvent> get platformEvents;
}
```

**Design Rationale**: Platform abstraction ensures consistent behavior across iOS, Android, and desktop while allowing platform-specific optimizations.

### State Management Architecture

#### Provider-Based State Management

Uses Provider pattern with ChangeNotifier for reactive state management:

```dart
// Global App State
class AppStateProvider extends ChangeNotifier {
  AppTheme _theme = AppTheme.system;
  NavigationState _navigationState = NavigationState.initial();
  
  // State getters and setters with notification
  void updateTheme(AppTheme theme) {
    _theme = theme;
    notifyListeners();
  }
}

// Feature-Specific State
abstract class FeatureStateProvider extends ChangeNotifier {
  String get featureId;
  bool get isInitialized;
  Future<void> initialize();
  Future<void> dispose();
}
```

**Design Rationale**: Provider pattern offers excellent performance with granular rebuilds, strong typing, and easy testing while maintaining Flutter's reactive paradigm.

## Data Models

### Core Domain Models

#### Application Configuration Model

```dart
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
}
```

#### Feature Registration Model

```dart
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
}
```

#### Platform Information Model

```dart
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
}
```

**Design Rationale**: Immutable data models with clear value semantics ensure predictable state management and easier debugging.

### Event Models

#### Feature Coordination Events

```dart
abstract class CoordinationEvent {
  final String sourceFeatureId;
  final DateTime timestamp;
  final Map<String, dynamic> payload;
}

class FeatureLifecycleEvent extends CoordinationEvent {
  final FeatureLifecycleState state;
  final String? error;
}

class FeatureDataEvent extends CoordinationEvent {
  final String dataType;
  final dynamic data;
}
```

## Error Handling

### Hierarchical Error Handling Strategy

#### 1. Global Error Boundary

```dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final ErrorHandler? errorHandler;
  
  @override
  Widget build(BuildContext context) {
    return ErrorWidget.builder = (FlutterErrorDetails details) {
      return ErrorRecoveryWidget(
        error: details.exception,
        onRecover: () => _recoverFromError(details),
      );
    };
  }
}
```

#### 2. Feature-Level Error Handling

```dart
abstract class FeatureErrorHandler {
  Future<ErrorRecoveryAction> handleError(
    FeatureError error,
    ErrorContext context,
  );
  
  bool canRecover(FeatureError error);
  Future<void> reportError(FeatureError error);
}
```

#### 3. Service-Level Error Handling

```dart
class ServiceResult<T> {
  final T? data;
  final ServiceError? error;
  final bool isSuccess;
  
  const ServiceResult.success(this.data) 
    : error = null, isSuccess = true;
  
  const ServiceResult.failure(this.error) 
    : data = null, isSuccess = false;
}
```

**Design Rationale**: Hierarchical error handling ensures errors are caught at the appropriate level, with graceful degradation and user-friendly error messages.

### Error Recovery Strategies

1. **Automatic Retry**: For transient errors (network, permissions)
2. **Graceful Degradation**: Disable non-critical features on errors
3. **User-Guided Recovery**: Present recovery options to users
4. **Emergency Reset**: Complete app state reset for critical errors

## Testing Strategy

### Testing Pyramid Implementation

#### 1. Unit Tests (70% of test coverage)

```dart
// Service Unit Tests
class ConfigurationManagerTest {
  late MockStorage mockStorage;
  late ConfigurationManager configManager;
  
  @setUp
  void setUp() {
    mockStorage = MockStorage();
    configManager = ConfigurationManagerImpl(mockStorage);
  }
  
  @test
  void shouldPersistSettingsCorrectly() async {
    // Test implementation
  }
}
```

#### 2. Integration Tests (20% of test coverage)

```dart
// Feature Integration Tests
class FeatureCoordinationTest {
  @test
  void shouldCoordinateBetweenFeatures() async {
    // Test feature communication
  }
}
```

#### 3. Widget Tests (10% of test coverage)

```dart
// UI Widget Tests
class AppShellTest {
  @test
  void shouldRenderCorrectTheme() async {
    await tester.pumpWidget(AppShell());
    expect(find.byType(MaterialApp), findsOneWidget);
  }
}
```

### Test Infrastructure

#### Mock Services

```dart
class MockPlatformService extends Mock implements PlatformService {
  @override
  Future<bool> requestPermissions(List<Permission> permissions) async {
    return true; // Configurable mock behavior
  }
}
```

#### Test Utilities

```dart
class TestAppBuilder {
  static Widget buildTestApp({
    required Widget child,
    List<Provider>? providers,
    ThemeData? theme,
  }) {
    return MultiProvider(
      providers: providers ?? [],
      child: MaterialApp(
        theme: theme,
        home: child,
      ),
    );
  }
}
```

**Design Rationale**: Comprehensive testing strategy ensures reliability and maintainability, with emphasis on unit tests for business logic and integration tests for feature coordination.

## Security Implementation

### Security Architecture

#### 1. Secure Memory Management

```dart
class SecureMemoryManager {
  static void clearSensitiveData(List<int> data) {
    // Overwrite memory with random data
    final random = Random.secure();
    for (int i = 0; i < data.length; i++) {
      data[i] = random.nextInt(256);
    }
  }
  
  static SecureString createSecureString(String value) {
    return SecureString._(value);
  }
}
```

#### 2. Secure Storage Abstraction

```dart
abstract class SecureStorage {
  Future<void> store(String key, String value);
  Future<String?> retrieve(String key);
  Future<void> delete(String key);
  Future<void> emergencyWipe();
}
```

#### 3. Permission Management

```dart
class PermissionManager {
  static const Map<PlatformType, List<Permission>> requiredPermissions = {
    PlatformType.android: [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.location, // Required for BLE scanning on Android
    ],
    PlatformType.ios: [
      Permission.bluetooth,
    ],
  };
  
  Future<PermissionStatus> requestAllPermissions() async {
    final platform = await PlatformService.getCurrentPlatform();
    final permissions = requiredPermissions[platform] ?? [];
    return await PermissionHandler.requestMultiple(permissions);
  }
}
```

**Design Rationale**: Security is built into the foundation with secure memory management, encrypted storage, and minimal permission requests to protect user privacy.

## Performance Optimization

### Performance Architecture

#### 1. Lazy Loading Strategy

```dart
class LazyFeatureLoader {
  final Map<String, Future<Feature>> _loadingFeatures = {};
  final Map<String, Feature> _loadedFeatures = {};
  
  Future<Feature> loadFeature(String featureId) async {
    if (_loadedFeatures.containsKey(featureId)) {
      return _loadedFeatures[featureId]!;
    }
    
    return _loadingFeatures.putIfAbsent(featureId, () async {
      final feature = await _createFeature(featureId);
      _loadedFeatures[featureId] = feature;
      return feature;
    });
  }
}
```

#### 2. Background Processing

```dart
class BackgroundTaskManager {
  final Queue<BackgroundTask> _taskQueue = Queue();
  final Isolate? _backgroundIsolate;
  
  Future<void> scheduleTask(BackgroundTask task) async {
    if (task.priority == TaskPriority.immediate) {
      await _executeTask(task);
    } else {
      _taskQueue.add(task);
      _processQueue();
    }
  }
}
```

#### 3. Memory Management

```dart
class MemoryManager {
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  final LRUCache<String, dynamic> _cache = LRUCache(maxCacheSize);
  
  void optimizeMemoryUsage() {
    if (_getCurrentMemoryUsage() > maxCacheSize * 0.8) {
      _cache.evictLeastRecentlyUsed();
      System.gc(); // Suggest garbage collection
    }
  }
}
```

**Design Rationale**: Performance optimizations focus on lazy loading, efficient background processing, and proactive memory management to maintain the <5% battery usage requirement.

## Development Infrastructure

### Build Configuration

#### Multi-Platform Build Setup

```yaml
# pubspec.yaml configuration
flutter:
  platforms:
    android:
      minSdkVersion: 26
      targetSdkVersion: 34
    ios:
      deployment_target: '14.0'
    windows:
      minimum_version: '10.0.17763.0'
    macos:
      deployment_target: '10.14'
    linux:
      minimum_version: 'Ubuntu 18.04'
```

#### Development Scripts

```bash
#!/bin/bash
# scripts/dev_setup.sh
echo "Setting up BitChat Flutter development environment..."

# Install dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run static analysis
flutter analyze

# Run tests
flutter test --coverage

echo "Development environment ready!"
```

### Quality Assurance Pipeline

#### Automated Quality Checks

```dart
// analysis_options.yaml configuration
analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  rules:
    - prefer_const_constructors
    - prefer_final_fields
    - avoid_print
    - prefer_single_quotes
    - sort_constructors_first
```

**Design Rationale**: Comprehensive development infrastructure ensures code quality, consistent builds across platforms, and efficient development workflows.

## Deployment Strategy

### Build Optimization

#### Release Build Configuration

```dart
// Build optimization for release
class BuildConfig {
  static const bool isDebug = kDebugMode;
  static const bool enableLogging = !kReleaseMode;
  static const int logLevel = isDebug ? LogLevel.verbose : LogLevel.error;
  
  static void configureForRelease() {
    if (kReleaseMode) {
      // Disable debug features
      Logger.setLevel(LogLevel.error);
      PerformanceMonitor.disable();
    }
  }
}
```

#### Platform-Specific Optimizations

```dart
class PlatformOptimizations {
  static void applyOptimizations() {
    if (Platform.isAndroid) {
      // Android-specific optimizations
      _optimizeForAndroid();
    } else if (Platform.isIOS) {
      // iOS-specific optimizations
      _optimizeForIOS();
    }
  }
}
```

**Design Rationale**: Deployment strategy focuses on optimized builds, platform-specific configurations, and automated quality assurance to ensure reliable releases across all target platforms.