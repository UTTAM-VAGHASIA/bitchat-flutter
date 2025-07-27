---
inclusion: always
---

# BitChat Flutter - Project Structure Standards

## Directory Organization

The BitChat Flutter project follows Clean Architecture principles with a feature-based organization. All source code resides in `bitchat/lib/` with the following structure:

```
bitchat/lib/
├── main.dart                    # Application entry point
├── core/                        # Core infrastructure and shared utilities
│   ├── constants/              # App-wide constants and configuration
│   ├── models/                 # Core domain models and entities
│   ├── services/               # Core services (dependency injection, etc.)
│   └── utils/                  # Utility functions and helpers
├── features/                   # Feature-based modules
│   ├── channels/               # Channel management feature
│   ├── chat/                   # Chat messaging feature
│   ├── encryption/             # Cryptographic operations
│   ├── mesh/                   # Bluetooth mesh networking
│   └── settings/               # App settings and preferences
├── presentation/               # UI layer components
│   ├── navigation/             # App routing and navigation
│   ├── providers/              # State management providers
│   └── screens/                # Screen widgets and layouts
└── shared/                     # Shared UI components and themes
    ├── extensions/             # Dart extensions
    ├── themes/                 # Material Design 3 themes
    └── widgets/                # Reusable UI widgets
```

## Feature Module Structure

Each feature in `features/` follows Clean Architecture layers:

```
features/{feature_name}/
├── data/                       # Infrastructure layer
│   ├── datasources/           # External data sources (BLE, storage)
│   ├── models/                # Data transfer objects
│   └── repositories/          # Repository implementations
├── domain/                     # Domain layer
│   ├── entities/              # Business entities
│   ├── repositories/          # Repository interfaces
│   └── usecases/              # Business logic use cases
└── presentation/               # Presentation layer
    ├── providers/             # Feature-specific providers
    ├── screens/               # Feature screens
    └── widgets/               # Feature-specific widgets
```

## File Naming Conventions

- **Files**: `snake_case.dart` (e.g., `mesh_network_service.dart`)
- **Classes**: `PascalCase` (e.g., `MeshNetworkService`)
- **Variables/Functions**: `camelCase` (e.g., `sendMessage`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_HOP_COUNT`)
- **Private members**: Prefix with underscore (e.g., `_privateMethod`)

## Import Organization

Organize imports in the following order with blank lines between groups:

```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:convert';

// 2. Flutter framework
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages (alphabetical)
import 'package:cryptography/cryptography.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

// 4. Internal imports (alphabetical)
import '../core/models/message.dart';
import '../core/services/encryption_service.dart';
import 'widgets/chat_bubble.dart';
```

## Core Directory Guidelines

### `core/constants/`
- App configuration values
- Protocol constants (message types, timeouts)
- UI constants (colors, dimensions)
- Error codes and messages

### `core/models/`
- Domain entities shared across features
- Base classes and interfaces
- Protocol data structures

### `core/services/`
- Dependency injection setup
- Global services (logging, analytics)
- Service locator pattern implementation

### `core/utils/`
- Helper functions and utilities
- Extension methods on core types
- Validation utilities

## Feature Guidelines

### Required Feature Components

Each feature must implement:

1. **Domain Layer**:
   - Entities representing business objects
   - Repository interfaces defining data contracts
   - Use cases encapsulating business logic

2. **Data Layer**:
   - Repository implementations
   - Data source abstractions (local/remote)
   - Data models with serialization

3. **Presentation Layer**:
   - Provider classes for state management
   - Screen widgets for UI
   - Feature-specific reusable widgets

### Feature Dependencies

- Features can depend on `core/` components
- Features should NOT directly depend on other features
- Cross-feature communication through domain interfaces
- Use dependency injection for loose coupling

## State Management Structure

### Provider Organization

```
presentation/providers/
├── app_provider.dart           # Global app state
├── bluetooth_provider.dart     # BLE connection state
├── chat_provider.dart          # Chat messages and channels
├── encryption_provider.dart    # Cryptographic state
└── mesh_network_provider.dart  # Network topology state
```

### Provider Dependencies

- Providers depend on use cases from domain layer
- Use `MultiProvider` in main.dart for dependency injection
- Implement `ChangeNotifier` for reactive UI updates
- Use `Consumer` widgets for selective rebuilds

## Testing Structure

Mirror the main structure in `test/` directory:

```
test/
├── core/                       # Core component tests
├── features/                   # Feature-specific tests
│   └── {feature}/
│       ├── data/              # Repository and data source tests
│       ├── domain/            # Use case and entity tests
│       └── presentation/      # Provider and widget tests
├── integration_test/          # End-to-end tests
└── test_helpers/              # Test utilities and mocks
```

## Asset Organization

```
assets/
├── images/                     # App icons and images
├── fonts/                      # Custom fonts
└── config/                     # Configuration files
```

## Platform-Specific Code

```
android/                        # Android-specific implementations
ios/                           # iOS-specific implementations
windows/                       # Windows-specific implementations
macos/                         # macOS-specific implementations
linux/                         # Linux-specific implementations
```

## Documentation Standards

- Each feature directory requires a `README.md` explaining its purpose
- Complex algorithms require inline documentation
- Public APIs must have dartdoc comments
- Architecture decisions documented in `docs/` directory

## Code Organization Best Practices

1. **Single Responsibility**: Each file should have one primary purpose
2. **Dependency Direction**: Dependencies flow inward (toward domain)
3. **Interface Segregation**: Create focused, minimal interfaces
4. **Composition over Inheritance**: Prefer composition for flexibility
5. **Immutable Data**: Use immutable objects where possible
6. **Error Handling**: Consistent error handling patterns across features

## Prohibited Patterns

- Direct widget-to-widget communication (use providers)
- Hardcoded strings in UI (use localization)
- Platform-specific code in shared modules
- Circular dependencies between features
- Global state outside of providers
- Direct database access from presentation layer