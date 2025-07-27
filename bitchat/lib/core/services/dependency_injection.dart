import 'dart:async';

/// Service lifecycle types for dependency injection
enum ServiceLifecycle { singleton, factory, scoped }

/// Service registration information
class ServiceRegistration<T> {
  final ServiceLifecycle lifecycle;
  final T Function() factory;
  final List<Type> dependencies;
  final bool lazy;

  const ServiceRegistration({
    required this.lifecycle,
    required this.factory,
    this.dependencies = const [],
    this.lazy = true,
  });
}

/// Dependency injection container interface
abstract class DIContainer {
  /// Register a singleton service
  void registerSingleton<T>(
    T Function() factory, {
    List<Type> dependencies = const [],
  });

  /// Register a factory service
  void registerFactory<T>(
    T Function() factory, {
    List<Type> dependencies = const [],
  });

  /// Register a scoped service
  void registerScoped<T>(
    T Function() factory, {
    List<Type> dependencies = const [],
  });

  /// Get a singleton service instance
  T getSingleton<T>();

  /// Get a factory service instance (new instance each time)
  T getFactory<T>();

  /// Get a scoped service instance
  T getScoped<T>();

  /// Check if a service is registered
  bool isRegistered<T>();

  /// Clear all scoped services
  void clearScoped();

  /// Dispose all services and clear container
  Future<void> dispose();
}

/// Default implementation of dependency injection container
class DIContainerImpl implements DIContainer {
  final Map<Type, ServiceRegistration> _registrations = {};
  final Map<Type, dynamic> _singletonInstances = {};
  final Map<Type, dynamic> _scopedInstances = {};
  final Map<Type, List<Type>> _dependencyGraph = {};

  @override
  void registerSingleton<T>(
    T Function() factory, {
    List<Type> dependencies = const [],
  }) {
    _registrations[T] = ServiceRegistration<T>(
      lifecycle: ServiceLifecycle.singleton,
      factory: factory,
      dependencies: dependencies,
    );
    _dependencyGraph[T] = dependencies;
  }

  @override
  void registerFactory<T>(
    T Function() factory, {
    List<Type> dependencies = const [],
  }) {
    _registrations[T] = ServiceRegistration<T>(
      lifecycle: ServiceLifecycle.factory,
      factory: factory,
      dependencies: dependencies,
    );
    _dependencyGraph[T] = dependencies;
  }

  @override
  void registerScoped<T>(
    T Function() factory, {
    List<Type> dependencies = const [],
  }) {
    _registrations[T] = ServiceRegistration<T>(
      lifecycle: ServiceLifecycle.scoped,
      factory: factory,
      dependencies: dependencies,
    );
    _dependencyGraph[T] = dependencies;
  }

  @override
  T getSingleton<T>() {
    final registration = _getRegistration<T>();
    if (registration.lifecycle != ServiceLifecycle.singleton) {
      throw StateError('Service $T is not registered as singleton');
    }

    if (_singletonInstances.containsKey(T)) {
      return _singletonInstances[T] as T;
    }

    final instance = _createInstance<T>(registration);
    _singletonInstances[T] = instance;
    return instance;
  }

  @override
  T getFactory<T>() {
    final registration = _getRegistration<T>();
    if (registration.lifecycle != ServiceLifecycle.factory) {
      throw StateError('Service $T is not registered as factory');
    }

    return _createInstance<T>(registration);
  }

  @override
  T getScoped<T>() {
    final registration = _getRegistration<T>();
    if (registration.lifecycle != ServiceLifecycle.scoped) {
      throw StateError('Service $T is not registered as scoped');
    }

    if (_scopedInstances.containsKey(T)) {
      return _scopedInstances[T] as T;
    }

    final instance = _createInstance<T>(registration);
    _scopedInstances[T] = instance;
    return instance;
  }

  @override
  bool isRegistered<T>() {
    return _registrations.containsKey(T);
  }

  @override
  void clearScoped() {
    // Dispose scoped instances if they implement Disposable
    for (final instance in _scopedInstances.values) {
      if (instance is Disposable) {
        instance.dispose();
      }
    }
    _scopedInstances.clear();
  }

  @override
  Future<void> dispose() async {
    // Dispose all instances
    final allInstances = [
      ..._singletonInstances.values,
      ..._scopedInstances.values,
    ];

    for (final instance in allInstances) {
      if (instance is Disposable) {
        await instance.dispose();
      }
    }

    _singletonInstances.clear();
    _scopedInstances.clear();
    _registrations.clear();
    _dependencyGraph.clear();
  }

  ServiceRegistration<T> _getRegistration<T>() {
    final registration = _registrations[T];
    if (registration == null) {
      throw StateError('Service $T is not registered');
    }
    return registration as ServiceRegistration<T>;
  }

  T _createInstance<T>(ServiceRegistration<T> registration) {
    // Check for circular dependencies
    _checkCircularDependencies<T>([]);

    try {
      return registration.factory();
    } catch (e) {
      throw StateError('Failed to create instance of $T: $e');
    }
  }

  void _checkCircularDependencies<T>(List<Type> visited) {
    if (visited.contains(T)) {
      throw StateError(
        'Circular dependency detected: ${visited.join(' -> ')} -> $T',
      );
    }

    final dependencies = _dependencyGraph[T] ?? [];
    final newVisited = [...visited, T];

    for (final _ in dependencies) {
      _checkCircularDependencies<dynamic>(newVisited);
    }
  }
}

/// Interface for disposable services
abstract class Disposable {
  Future<void> dispose();
}

/// Global dependency injection container instance
late DIContainer diContainer;

/// Initialize the dependency injection container
void initializeDI() {
  diContainer = DIContainerImpl();
}

/// Convenience methods for accessing services
T getSingleton<T>() => diContainer.getSingleton<T>();
T getFactory<T>() => diContainer.getFactory<T>();
T getScoped<T>() => diContainer.getScoped<T>();

/// Service locator pattern implementation
class ServiceLocator {
  static final DIContainer _container = diContainer;

  static T get<T>() {
    if (_container.isRegistered<T>()) {
      // Try to get as singleton first, then scoped, then factory
      try {
        return _container.getSingleton<T>();
      } catch (_) {
        try {
          return _container.getScoped<T>();
        } catch (_) {
          return _container.getFactory<T>();
        }
      }
    }
    throw StateError('Service $T is not registered');
  }

  static bool isRegistered<T>() => _container.isRegistered<T>();
}
