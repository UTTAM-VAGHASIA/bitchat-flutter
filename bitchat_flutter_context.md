# BitChat Flutter - Context Engineering Template

**Version:** 0.1.0  
**Last Updated:** July 11, 2025

## Project Overview

BitChat Flutter is a decentralized peer-to-peer messaging application working over Bluetooth Low Energy (BLE) mesh networks, inspired by the original iOS and Android implementations. It provides encrypted and ephemeral communication without relying on internet infrastructure.

**Original Projects:**
- iOS/macOS: https://github.com/permissionlesstech/bitchat  
- Android: https://github.com/permissionlesstech/bitchat-android

## Folder Structure

```
bitchat_flutter/
├── docs/
│   ├── ARCHITECTURE.md (done)
│   ├── PROTOCOL_SPEC.md (done)
│   ├── SECURITY_SPEC.md (done)
│   ├── UI_REQUIREMENTS.md (done)
│   ├── BLUETOOTH_IMPLEMENTATION.md (done)
│   ├── ENCRYPTION_SPEC.md (done)
│   ├── COMMANDS_REFERENCE.md (done)
│   └── PLATFORM_COMPATIBILITY.md (done)
├── context/
│   ├── project_requirements.md
│   ├── technical_specifications.md
│   ├── feature_matrix.md
│   ├── implementation_roadmap.md
│   ├── testing_strategy.md
│   └── deployment_guide.md
├── reference/
│   ├── ios_codebase_analysis.md
│   ├── android_codebase_analysis.md
│   ├── protocol_compatibility.md
│   └── third_party_libraries.md
├── bitchat/
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   ├── utils/
│   │   │   ├── services/
│   │   │   └── models/
│   │   ├── features/
│   │   │   ├── chat/
│   │   │   ├── mesh/
│   │   │   ├── encryption/
│   │   │   ├── channels/
│   │   │   └── settings/
│   │   ├── shared/
│   │   │   ├── widgets/
│   │   │   ├── themes/
│   │   │   └── extensions/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── providers/
│   │       └── navigation/
│   ├── test/
│   ├── android/
│   ├── ios/
│   ├── linux/
│   ├── macos/
│   └── windows/
├── protocols/
│   ├── binary_protocol.md
│   ├── message_types.md
│   ├── packet_structure.md
│   ├── encryption_flow.md
│   └── mesh_routing.md
├── examples/
│   ├── sample_conversations.md
│   ├── command_examples.md
│   └── protocol_examples.md
├── assets/
│   ├── ui_mockups/
│   ├── protocol_diagrams/
│   └── architecture_diagrams/
├── scripts/
│   ├── setup.sh
│   ├── build.sh
│   └── test.sh
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

## Core Features

### 1. Decentralized Mesh Network
- **Peer Discovery**: Automatic discovery of nearby peers
- **Multi-hop Routing**: TTL-based message relay over BLE
- **Store & Forward**: Cached messages for offline delivery
- **Privacy First**: No servers, phone numbers, or persistent identifiers

### 2. Encryption & Security
- **End-to-End Encryption**: X25519 key exchange + AES-256-GCM
- **Channel security**: Argon2id derived keys for channels
- **Digital Signatures**: Uses Ed25519 for authenticity
- **Forward Secrecy**: New keys generated for each session
- **Emergency Wipe**: Quickly clear all data

### 3. Messaging Features
- **Channel-Based Messaging**: Groups based on topics
- **Direct Messaging**: Private, encrypted chats
- **Command Support**: IRC-style commands like `/join` and `/msg`
- **Message Retention**: Optional persistence depending on channel settings

### 4. Optimized Performance
- **Adaptive Power Modes**: Adjusts operation based on battery
- **Compression**: LZ4 compression for large messages
- **Efficient Networking**: Optimized scanning and connectivity management

### 5. Privacy Measures
- **Ephemeral by Design**: No data stored permanently
- **Cover Traffic**: Randomized message timing for privacy enhancement

### 6. Future Extensions
- **WiFi Direct Integration**: Higher bandwidth transport layer (250+ Mbps)
- **Transport Selection**: Intelligent routing between BLE and WiFi Direct
- **Hybrid Mesh**: Support for mixed BLE and WiFi Direct nodes
- **Multi-Transport Bonding**: Redundant message delivery across transports

## Technical Stack

### Flutter Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  riverpod: ^2.4.9
  
  # Bluetooth
  flutter_blue_plus: ^1.31.7
  
  # Encryption
  crypto: ^3.0.3
  cryptography: ^2.7.0
  
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.2
  
  # UI
  material_color_utilities: ^0.8.0
  google_fonts: ^6.1.0
  
  # Utils
  uuid: ^4.2.1
  convert: ^3.1.1
  
  # Compression
  archive: ^3.4.9
  
  # Permissions
  permission_handler: ^11.2.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.2
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
```

## Implementation Priority

### Phase 1: Core Infrastructure
1. Bluetooth LE service setup
2. Binary protocol implementation
3. Basic peer discovery
4. Message routing foundation

### Phase 2: Encryption & Security
1. Cryptographic services
2. Key exchange mechanisms
3. Message encryption/decryption
4. Digital signatures

### Phase 3: Chat Features
1. Channel management
2. Private messaging
3. IRC-style commands
4. Message persistence

### Phase 4: UI & Polish
1. Material Design 3 implementation
2. Dark/light theme support
3. Performance optimizations
4. Battery management

### Phase 5: Advanced Features
1. Message compression
2. Cover traffic
3. Advanced routing
4. Cross-platform compatibility

### Phase 6: WiFi Direct Integration
1. Transport layer abstraction
2. WiFi Direct implementation
3. Intelligent transport selection
4. Multi-transport mesh routing
5. Enhanced file transfer capabilities

## Protocol Compatibility

The Flutter implementation must maintain 100% binary protocol compatibility with:
- iOS BitChat (Swift)
- Android BitChat (Kotlin)

### Key Compatibility Points:
- **Header Format**: Identical 13-byte header structure
- **Packet Types**: Same message types and routing logic
- **Encryption**: Identical cryptographic algorithms
- **UUIDs**: Same Bluetooth service/characteristic identifiers
- **Fragmentation**: Compatible message fragmentation

## Security Considerations

1. **No External Dependencies**: All crypto operations must be verifiable
2. **Memory Management**: Secure cleanup of sensitive data
3. **Key Storage**: Ephemeral keys in memory only
4. **Traffic Analysis**: Implement cover traffic patterns
5. **Emergency Features**: Instant data wipe capability

## Testing Strategy

### Unit Tests
- Protocol parsing/encoding
- Encryption/decryption
- Message routing logic
- Command parsing
- Battery optimization thresholds

### Integration Tests
- Bluetooth operations
- End-to-end message flow
- Multi-device scenarios
- Battery optimization
- Cross-platform service compatibility

### Compatibility Tests
- iOS ↔ Flutter communication
  - Binary protocol edge cases
  - Large message fragmentation
  - Channel encryption compatibility
  - Key exchange verification
  - Protocol version checking
- Android ↔ Flutter communication
  - Binary protocol compatibility 
  - BLE advertisement format matching
  - Message routing algorithm parity
  - Characteristic UUID matching
  - MTU negotiation compatibility
- Mixed group scenarios
  - Multi-platform channel messaging
  - Private messages across platforms
  - Command compatibility
  - Message relay through different platforms
  - Store-and-forward across platform types

### Performance Tests
- Battery usage across power modes
- Mesh size scaling tests
- Message throughput benchmarks
- Scan interval optimization tests

## Development Guidelines

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Comprehensive documentation
- Error handling at all levels

### Architecture
- Clean Architecture principles
- Separation of concerns
- Dependency injection
- State management with Provider/Riverpod

### Performance
- Minimize memory allocations
- Efficient Bluetooth operations
- Background processing optimization
- Battery-aware features
- Identical battery optimization parameters as iOS/Android:
  - Performance mode: 3s scan/2s pause, 20 connections, continuous advertising
  - Balanced mode: 2s scan/3s pause, 10 connections, 5s advertising
  - Power saver: 1s scan/8s pause, 5 connections, 15s advertising
  - Ultra low power: 0.5s scan/20s pause, 2 connections, 30s advertising

## Deployment

### Android
- Target API 34 (Android 14)
- Minimum API 26 (Android 8.0)
- Permissions: Bluetooth, Location, Notifications

### iOS
- Target iOS 16.0+
- Bluetooth permissions
- Background app refresh
- Local notifications

## Getting Started

1. **Setup Development Environment**
   ```bash
   flutter doctor
   flutter pub get
   ```

2. **Generate Required Files**
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Run Tests**
   ```bash
   flutter test
   ```

4. **Launch App**
   ```bash
   flutter run
   ```

## Important Notes

⚠️ **Security Warning**: This software has not received external security review. Do not use for sensitive communications.

🔧 **Work in Progress**: This is an active development project with ongoing protocol changes.

🌐 **Public Domain**: Released under public domain license.

## Resources

- [Original iOS Repository](https://github.com/permissionlesstech/bitchat)
- [Android Repository](https://github.com/permissionlesstech/bitchat-android)
- [Technical Whitepaper](https://github.com/permissionlesstech/bitchat/blob/main/WHITEPAPER.md)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Bluetooth LE Specifications](https://www.bluetooth.com/specifications/specs/)

---

This template provides the complete context needed for Claude Code to build a faithful Flutter replica of BitChat while maintaining protocol compatibility and security standards.