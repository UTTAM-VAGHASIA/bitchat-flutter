---
inclusion: always
---

# BitChat Flutter - Technical Standards

## Development Environment

- **Flutter Version Management**: Use `fvm` for consistent Flutter SDK versions across development environments
- **Flutter SDK**: 3.16+ (managed via fvm, latest stable recommended) (Current version during development: 3.32.8)
- **Dart Language**: 3.2+ with null safety enabled (Current version during development: 3.8.1)
- **IDE**: VS Code with Flutter and Dart extensions or Android Studio or Kiro with Flutter and Dart Extensions

## Documentation Requirements

**Context7 MCP Server**: Use the Context7 MCP server for fetching up-to-date documentation during development sessions.

- **Required for all coding tasks**: Before implementing any feature or fixing bugs, fetch relevant documentation
- **Framework Documentation**: Always fetch Flutter and Dart documentation for the versions specified in pubspec.yaml
- **Dependency Documentation**: Fetch documentation for all third-party packages used in the current task:
  - `flutter_blue_plus` for Bluetooth operations
  - `cryptography` for encryption implementations
  - `hive` for local storage operations
  - `provider` for state management
  - `permission_handler` for platform permissions
- **Version-Specific**: Ensure documentation matches the exact versions specified in pubspec.yaml
- **Session-Based**: Fetch documentation at the beginning of each coding session to ensure latest information
- **Task-Specific**: Only fetch documentation relevant to the current implementation task to maintain focus

**Usage Pattern**:
```
1. Identify required dependencies for the current task
2. Check pubspec.yaml for exact versions
3. Use Context7 MCP server to fetch documentation for:
   - Flutter framework (current version)
   - Dart language (current version)  
   - Relevant third-party packages (exact versions)
4. Reference fetched documentation throughout implementation
```

## Architecture Requirements

**Clean Architecture Pattern**: Strictly enforce 5-layer separation:
1. **Presentation** → UI components, screens, state management
2. **Application** → Use cases, business logic orchestration  
3. **Domain** → Business entities, repository interfaces, domain services
4. **Infrastructure** → Repository implementations, external services
5. **Platform** → Hardware abstraction, OS-specific implementations

**Dependency Rules**: Inner layers must not depend on outer layers. Use dependency injection for all cross-layer communication.

## Code Style Standards

- **Formatting**: `dart format` with 80-character line limit (enforced)
- **Linting**: `flutter_lints` package with custom rules
- **Naming**: `snake_case` files, `PascalCase` classes, `camelCase` variables
- **Documentation**: All public APIs require dartdoc comments
- **Imports**: Organize as: Dart core → Flutter → Third-party → Internal (alphabetical within groups)

## Required Dependencies

```yaml
dependencies:
  flutter_blue_plus: ^1.35.5      # BLE operations - do not upgrade without compatibility testing
  cryptography: ^2.7.0            # Encryption (X25519, AES-256-GCM, Ed25519)
  hive: ^2.2.3                    # Local storage and message persistence
  provider: ^6.1.1                # State management pattern
  permission_handler: ^12.0.1     # Platform permissions for Bluetooth/location
```

## State Management Rules

- **Pattern**: Provider with ChangeNotifier for reactive UI updates
- **Required Providers**: ChatProvider, BluetoothProvider, MeshNetworkProvider, EncryptionProvider
- **Dependency Injection**: Service locator pattern for provider dependencies
- **State Persistence**: Use Hive for local state that survives app restarts

## Build and Testing Standards

**Setup Commands**:
```bash
fvm flutter pub get
fvm flutter packages pub run build_runner build
```

**Development**:
```bash
fvm flutter run                    # Debug mode
fvm flutter run --release         # Release mode
```

**Quality Assurance**:
```bash
fvm flutter analyze               # Static analysis (must pass)
fvm flutter test                 # Unit tests (required for all business logic)
fvm flutter test integration_test # Integration tests
```

**Platform Builds**:
```bash
fvm flutter build apk            # Android
fvm flutter build ios           # iOS  
fvm flutter build windows       # Windows
fvm flutter build macos         # macOS
fvm flutter build linux         # Linux
```

## Platform Constraints

- **iOS**: 14.0+ minimum (iPhone 6s+), Xcode 12.0+ for development
- **Android**: API 26+ minimum (Android 8.0+)
- **Desktop**: Platform-specific development tools required
- **Hardware**: Bluetooth 4.0+ (BLE) required for core functionality
- **Testing**: Physical devices required for Bluetooth mesh testing

## Security Requirements

- All cryptographic operations must use the `cryptography` package
- No hardcoded keys or secrets in source code
- Forward secrecy required for all message encryption
- Cover traffic implementation for privacy protection