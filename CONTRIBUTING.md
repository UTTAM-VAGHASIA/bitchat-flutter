# Contributing to BitChat Flutter

## Overview

We welcome contributions to BitChat Flutter! This document outlines the process for contributing to the project.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Android Studio or VS Code with Flutter extension
- Git

### Setting Up the Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/UTTAM-VAGHASIA/bitchat-flutter.git
   cd bitchat-flutter
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Generate required files**:
   ```bash
   flutter packages pub run build_runner build
   ```

## Development Guidelines

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format your code
- Run `dart analyze` to check for issues
- Use meaningful variable and function names
- Add comprehensive documentation for public APIs

### Architecture

- Follow Clean Architecture principles
- Maintain separation of concerns
- Use dependency injection where appropriate
- Follow the established project structure

### Protocol Compatibility

**Critical**: All changes must maintain 100% binary protocol compatibility with:
- [iOS BitChat](https://github.com/permissionlesstech/bitchat)
- [Android BitChat](https://github.com/permissionlesstech/bitchat-android)

### Testing

- Write unit tests for new functionality
- Ensure all tests pass before submitting
- Test on both iOS and Android platforms
- Test interoperability with original BitChat apps

## Contribution Process

### 1. Create an Issue

Before starting work, create an issue to discuss:
- Bug reports
- Feature requests
- Architecture changes
- Documentation improvements

### 2. Branch Naming

Use descriptive branch names:
- `feature/add-new-command`
- `bugfix/fix-bluetooth-connection`
- `docs/update-protocol-spec`

### 3. Making Changes

1. **Create a new branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the guidelines above

3. **Test thoroughly**:
   ```bash
   flutter test
   flutter analyze
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Add descriptive commit message"
   ```

### 4. Pull Request

1. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request** on GitHub with:
   - Clear description of changes
   - Reference to related issues
   - Testing performed
   - Screenshots if UI changes

## Areas for Contribution

### High Priority

1. **Core Bluetooth Implementation**
   - BLE mesh networking
   - Connection management
   - Protocol compatibility

2. **Encryption Services**
   - X25519 key exchange
   - AES-256-GCM encryption
   - Ed25519 signatures

3. **Message Routing**
   - TTL-based routing
   - Store and forward
   - Fragmentation

### Medium Priority

1. **User Interface**
   - Terminal-inspired design
   - Dark/light themes
   - Command interface

2. **Performance Optimization**
   - Battery management
   - Memory optimization
   - Network efficiency

3. **Testing**
   - Unit tests
   - Integration tests
   - Cross-platform compatibility tests

### Low Priority

1. **Documentation**
   - API documentation
   - User guides
   - Technical specifications

2. **Developer Tools**
   - Debug utilities
   - Performance profiling
   - Test helpers

## Code Review Process

1. **Automated checks** must pass:
   - `dart analyze` with no errors
   - `flutter test` with all tests passing
   - Format check with `dart format`

2. **Manual review** will check:
   - Code quality and style
   - Architecture compliance
   - Protocol compatibility
   - Security considerations

3. **Testing verification**:
   - Functionality works as expected
   - No regressions introduced
   - Cross-platform compatibility maintained

## Security Considerations

- **Never commit secrets** or private keys
- **Review cryptographic code** carefully
- **Follow secure coding practices**
- **Report security issues** privately

## Questions?

If you have questions about contributing:
- Create an issue for discussion
- Check existing documentation
- Review the original iOS/Android implementations

## License

By contributing to BitChat Flutter, you agree that your contributions will be licensed under the same public domain license as the project.

---

Thank you for contributing to BitChat Flutter!
