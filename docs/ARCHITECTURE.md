# BitChat Flutter - Architecture Documentation

## Overview

BitChat Flutter implements a decentralized peer-to-peer messaging system using Bluetooth Low Energy (BLE) mesh networking. The architecture follows Clean Architecture principles with clear separation of concerns across multiple layers.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
├─────────────────────────────────────────────────────────────┤
│                    Application Layer                        │
├─────────────────────────────────────────────────────────────┤
│                       Domain Layer                          │
├─────────────────────────────────────────────────────────────┤
│                  Infrastructure Layer                       │
├─────────────────────────────────────────────────────────────┤
│                      Platform Layer                         │
└─────────────────────────────────────────────────────────────┘
```

## Layer Details

### 1. Presentation Layer
- **UI Components**: Flutter widgets and screens
- **State Management**: Provider/Riverpod state management
- **Navigation**: Go Router for declarative routing
- **Themes**: Material Design 3 theming system

### 2. Application Layer
- **Use Cases**: Business logic orchestration
- **Services**: Application-specific services
- **DTOs**: Data transfer objects
- **Mappers**: Entity to model conversion

### 3. Domain Layer
- **Entities**: Core business objects
- **Repositories**: Abstract data access interfaces
- **Value Objects**: Immutable data structures
- **Domain Services**: Business logic services

### 4. Infrastructure Layer
- **Repositories**: Concrete data access implementations
- **External Services**: Third-party integrations
- **Persistence**: Local storage implementation
- **Network**: Bluetooth communication layer

### 5. Platform Layer
- **Platform Channels**: Native code bridges
- **Permissions**: Platform-specific permissions
- **Hardware**: Bluetooth adapter management
- **Background Tasks**: Platform background processing

## Core Components

### Bluetooth Mesh Network Stack

```
┌─────────────────────────────────────────────────────────────┐
│                  Application Messages                       │
├─────────────────────────────────────────────────────────────┤
│               Encryption/Decryption Layer                   │
├─────────────────────────────────────────────────────────────┤
│                  Message Routing Layer                      │
├─────────────────────────────────────────────────────────────┤
│                 Packet Assembly/Parsing                     │
├─────────────────────────────────────────────────────────────┤
│                  Bluetooth LE Transport                     │
└─────────────────────────────────────────────────────────────┘
```

### Message Flow Architecture

```
User Input → Command Parser → Message Builder → Encryption → 
Routing → Packet Assembly → Bluetooth LE → Peer Discovery → 
Packet Parsing → Decryption → Message Handler → UI Update
```

## Module Architecture

### Core Modules

#### 1. Bluetooth Module (`lib/core/bluetooth/`)
```
bluetooth/
├── services/
│   ├── bluetooth_service.dart
│   ├── scanning_service.dart
│   └── connection_service.dart
├── models/
│   ├── bluetooth_device.dart
│   ├── advertisement_data.dart
│   └── connection_state.dart
├── repositories/
│   ├── bluetooth_repository.dart
│   └── device_repository.dart
└── utils/
    ├── bluetooth_utils.dart
    └── uuid_constants.dart
```

#### 2. Mesh Network Module (`lib/core/mesh/`)
```
mesh/
├── services/
│   ├── mesh_service.dart
│   ├── routing_service.dart
│   └── peer_discovery_service.dart
├── models/
│   ├── mesh_packet.dart
│   ├── routing_table.dart
│   └── peer_info.dart
├── repositories/
│   ├── mesh_repository.dart
│   └── routing_repository.dart
└── protocols/
    ├── packet_protocol.dart
    └── routing_protocol.dart
```

#### 3. Encryption Module (`lib/core/encryption/`)
```
encryption/
├── services/
│   ├── encryption_service.dart
│   ├── key_exchange_service.dart
│   └── signature_service.dart
├── models/
│   ├── key_pair.dart
│   ├── encrypted_message.dart
│   └── signature.dart
├── repositories/
│   ├── key_repository.dart
│   └── encryption_repository.dart
└── algorithms/
    ├── x25519_key_exchange.dart
    ├── aes_gcm_encryption.dart
    └── ed25519_signature.dart
```

#### 4. Chat Module (`lib/features/chat/`)
```
chat/
├── presentation/
│   ├── screens/
│   │   ├── chat_screen.dart
│   │   ├── channel_list_screen.dart
│   │   └── private_message_screen.dart
│   ├── widgets/
│   │   ├── message_bubble.dart
│   │   ├── chat_input.dart
│   │   └── user_list.dart
│   └── providers/
│       ├── chat_provider.dart
│       └── message_provider.dart
├── domain/
│   ├── entities/
│   │   ├── message.dart
│   │   ├── channel.dart
│   │   └── user.dart
│   ├── repositories/
│   │   ├── chat_repository.dart
│   │   └── message_repository.dart
│   └── use_cases/
│       ├── send_message_use_case.dart
│       └── join_channel_use_case.dart
└── data/
    ├── repositories/
    │   ├── chat_repository_impl.dart
    │   └── message_repository_impl.dart
    ├── models/
    │   ├── message_model.dart
    │   └── channel_model.dart
    └── datasources/
        ├── local_chat_datasource.dart
        └── remote_chat_datasource.dart
```

## State Management Architecture

### Provider Pattern
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => BluetoothProvider()),
    ChangeNotifierProvider(create: (_) => MeshProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => EncryptionProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ],
  child: MyApp(),
)
```

### State Flow
```
User Action → Provider → Use Case → Repository → 
Data Source → Domain Entity → UI State Update
```

## Data Flow Architecture

### Message Processing Pipeline

```
Incoming BLE Data → Packet Parser → Decryption → 
Message Validation → Routing Decision → 
Local Processing / Forward → UI Update
```

### Outgoing Message Flow

```
User Input → Command Validation → Message Creation → 
Encryption → Packet Assembly → Routing → 
BLE Transmission → Delivery Confirmation
```

## Security Architecture

### Encryption Layers

1. **Transport Layer**: BLE encryption (hardware level)
2. **Session Layer**: X25519 key exchange
3. **Message Layer**: AES-256-GCM encryption
4. **Authentication Layer**: Ed25519 signatures

### Key Management

```
Session Start → Key Generation → Key Exchange → 
Message Encryption → Forward Secrecy → Session End
```

## Storage Architecture

### Local Storage Strategy

```
Hive Boxes:
├── messages.hive      (Encrypted messages)
├── channels.hive      (Channel metadata)
├── peers.hive         (Peer information)
├── keys.hive          (Session keys - memory only)
└── settings.hive      (App configuration)
```

### Data Persistence

- **Ephemeral Data**: Keys, temporary routing info
- **Session Data**: Messages, channel state
- **Persistent Data**: User preferences, channel subscriptions

## Performance Architecture

### Battery Optimization

1. **Adaptive Scanning**: Based on battery level
2. **Connection Pooling**: Reuse BLE connections
3. **Background Processing**: Minimize wake-ups
4. **Power-Aware Routing**: Reduce transmission power

### Memory Management

1. **Object Pooling**: Reuse message objects
2. **Lazy Loading**: Load messages on demand
3. **Garbage Collection**: Regular cleanup
4. **Memory Monitoring**: Track usage patterns

## Testing Architecture

### Test Pyramid

```
┌─────────────────────────────────────────────────────────────┐
│                        E2E Tests                            │
├─────────────────────────────────────────────────────────────┤
│                    Integration Tests                        │
├─────────────────────────────────────────────────────────────┤
│                       Unit Tests                            │
└─────────────────────────────────────────────────────────────┘
```

### Test Categories

1. **Unit Tests**: Individual components
2. **Widget Tests**: UI components
3. **Integration Tests**: Feature workflows
4. **Golden Tests**: UI consistency
5. **Performance Tests**: Bluetooth operations

## Platform Architecture

### Cross-Platform Considerations

#### iOS Specific
- Background app refresh handling
- Core Bluetooth integration
- Privacy permission management
- App lifecycle management

#### Android Specific
- Bluetooth adapter management
- Background service limitations
- Permission request flows
- Battery optimization whitelist

## Deployment Architecture

### Build Pipeline

```
Source Code → Static Analysis → Unit Tests → 
Integration Tests → Build → Platform Packaging → 
Distribution → Monitoring
```

### Environment Management

- **Development**: Local testing environment
- **Staging**: Pre-production testing
- **Production**: Released application

## Monitoring & Observability

### Error Tracking

1. **Bluetooth Errors**: Connection failures, pairing issues
2. **Encryption Errors**: Key exchange failures
3. **Network Errors**: Message routing problems
4. **UI Errors**: Widget rendering issues

### Performance Monitoring

1. **Battery Usage**: Power consumption tracking
2. **Memory Usage**: Heap monitoring
3. **Network Performance**: Message delivery rates
4. **User Experience**: Response times

## Security Considerations

### Attack Surface

1. **Bluetooth Protocol**: BLE vulnerabilities
2. **Message Parsing**: Malformed packet handling
3. **Encryption**: Implementation weaknesses
4. **Storage**: Local data protection

### Mitigation Strategies

1. **Input Validation**: Strict packet validation
2. **Memory Safety**: Secure cleanup procedures
3. **Encryption**: Multiple layers of protection
4. **Emergency Features**: Instant data wipe

## Future Architecture Considerations

### Scalability

1. **Mesh Size**: Support for larger networks
2. **Message Volume**: High-throughput scenarios
3. **Feature Expansion**: New message types
4. **Platform Support**: Additional platforms

### Extensibility

1. **Plugin Architecture**: Third-party extensions
2. **Protocol Evolution**: Backward compatibility
3. **UI Themes**: Custom themes
4. **Command Extensions**: Additional IRC commands

## Dependencies

### Core Dependencies

- **flutter_blue_plus**: Bluetooth LE operations
- **crypto**: Cryptographic operations
- **hive**: Local storage
- **provider**: State management
- **path_provider**: File system access

### Development Dependencies

- **mocktail**: Unit testing mocks
- **integration_test**: Integration testing
- **build_runner**: Code generation
- **flutter_test**: Widget testing

## Configuration Management

### Environment Variables

```dart
abstract class AppConfig {
  static const String bluetoothServiceUUID = 'your-uuid-here';
  static const int maxHops = 7;
  static const int maxMessageSize = 1024;
  static const Duration scanTimeout = Duration(seconds: 30);
}
```

### Feature Flags

```dart
abstract class FeatureFlags {
  static const bool enableCoverTraffic = true;
  static const bool enableMessageCompression = true;
  static const bool enableBatteryOptimization = true;
}
```

This architecture provides a robust foundation for building a secure, scalable, and maintainable BitChat Flutter application while maintaining compatibility with existing iOS and Android implementations.