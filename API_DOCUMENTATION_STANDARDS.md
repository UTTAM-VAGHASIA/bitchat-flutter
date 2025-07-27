# BitChat Flutter - API Documentation Standards

**Version:** 1.0  
**Last Updated:** July 26, 2025

## Overview

This document defines the standards for documenting APIs, classes, methods, and functions in BitChat Flutter. Consistent documentation improves code maintainability, developer onboarding, and API usability.

## General Documentation Principles

### 1. Documentation Goals
- **Clarity**: Documentation should be clear and unambiguous
- **Completeness**: Cover all public APIs and important private methods
- **Accuracy**: Keep documentation synchronized with code
- **Examples**: Provide practical usage examples
- **Context**: Explain why, not just what

### 2. Documentation Audience
- **Primary**: Flutter developers working on BitChat
- **Secondary**: Contributors and maintainers
- **Tertiary**: Security auditors and protocol implementers

## Dart Documentation Standards

### 1. Class Documentation

#### Class-Level Documentation Template
```dart
/// Service responsible for managing Bluetooth Low Energy mesh networking.
/// 
/// This service handles device discovery, connection management, and message
/// routing across the mesh network. It maintains strict compatibility with
/// the iOS and Android BitChat implementations by using identical UUIDs,
/// packet formats, and routing algorithms.
/// 
/// The service operates in dual mode, acting as both a central (scanner) and
/// peripheral (advertiser) to enable mesh networking capabilities.
/// 
/// ## Usage
/// 
/// ```dart
/// final meshService = BluetoothMeshService();
/// await meshService.initialize();
/// 
/// // Start mesh networking
/// await meshService.startScanning();
/// await meshService.startAdvertising();
/// 
/// // Send a message
/// await meshService.sendMessage('Hello, mesh!', channelId: 'general');
/// ```
/// 
/// ## Protocol Compatibility
/// 
/// This implementation maintains binary protocol compatibility with:
/// - iOS BitChat v2.1.0+
/// - Android BitChat v1.8.0+
/// 
/// ## Security Considerations
/// 
/// All messages are encrypted using AES-256-GCM with X25519 key exchange.
/// The service implements cover traffic and timing obfuscation to prevent
/// traffic analysis attacks.
/// 
/// ## Performance Notes
/// 
/// The service implements adaptive power management with four power modes:
/// - Performance: 3s scan, 2s pause, 20 connections max
/// - Balanced: 2s scan, 3s pause, 10 connections max  
/// - Power Saver: 1s scan, 8s pause, 5 connections max
/// - Ultra Low Power: 0.5s scan, 20s pause, 2 connections max
/// 
/// See also:
/// - [BluetoothDevice] for device representation
/// - [MeshMessage] for message structure
/// - [EncryptionService] for cryptographic operations
class BluetoothMeshService {
  // Implementation...
}
```

#### Key Elements for Class Documentation
1. **Purpose**: What the class does
2. **Responsibilities**: Key responsibilities and capabilities
3. **Usage Example**: Basic usage pattern
4. **Compatibility**: Protocol/platform compatibility notes
5. **Security**: Security implications and features
6. **Performance**: Performance characteristics and considerations
7. **Related Classes**: Links to related APIs

### 2. Method Documentation

#### Method Documentation Template
```dart
/// Encrypts a message for secure transmission over the mesh network.
/// 
/// This method implements end-to-end encryption using X25519 key exchange
/// and AES-256-GCM symmetric encryption. The encryption is compatible with
/// the iOS and Android BitChat implementations.
/// 
/// The encryption process:
/// 1. Performs X25519 key exchange with recipient's public key
/// 2. Derives encryption key using HKDF-SHA256
/// 3. Encrypts message with AES-256-GCM
/// 4. Includes authentication tag for integrity verification
/// 
/// ## Parameters
/// 
/// - [message]: The plaintext message to encrypt. Must not be empty.
/// - [recipientPublicKey]: The recipient's X25519 public key (32 bytes).
/// - [senderPrivateKey]: The sender's X25519 private key (32 bytes).
/// - [additionalData]: Optional additional authenticated data.
/// 
/// ## Returns
/// 
/// Returns an [EncryptedMessage] containing:
/// - `ciphertext`: The encrypted message bytes
/// - `nonce`: The 12-byte nonce used for encryption
/// - `tag`: The 16-byte authentication tag
/// - `senderPublicKey`: The sender's public key for key exchange
/// 
/// ## Throws
/// 
/// - [ArgumentError]: If any parameter is invalid (null, wrong size, etc.)
/// - [CryptographicException]: If encryption fails due to cryptographic error
/// - [StateError]: If the encryption service is not initialized
/// 
/// ## Example
/// 
/// ```dart
/// try {
///   final encrypted = await encryptMessage(
///     'Hello, secure world!',
///     recipientPublicKey,
///     senderPrivateKey,
///   );
///   
///   print('Encrypted ${encrypted.ciphertext.length} bytes');
///   await sendEncryptedMessage(encrypted);
/// } catch (e) {
///   print('Encryption failed: $e');
/// }
/// ```
/// 
/// ## Security Notes
/// 
/// - Uses cryptographically secure random nonce generation
/// - Implements forward secrecy through ephemeral key pairs
/// - Provides authenticated encryption (confidentiality + integrity)
/// - Compatible with NIST SP 800-38D AES-GCM specification
/// 
/// ## Performance
/// 
/// Typical encryption time: <1ms for messages up to 1KB on modern devices.
/// Memory usage: ~2KB temporary allocation during encryption.
/// 
/// See also:
/// - [decryptMessage] for the corresponding decryption operation
/// - [generateKeyPair] for creating X25519 key pairs
/// - [EncryptedMessage] for the return type structure
Future<EncryptedMessage> encryptMessage(
  String message,
  Uint8List recipientPublicKey,
  Uint8List senderPrivateKey, {
  Uint8List? additionalData,
}) async {
  // Implementation...
}
```

#### Key Elements for Method Documentation
1. **Purpose**: What the method does
2. **Algorithm/Process**: How it works (for complex methods)
3. **Parameters**: Detailed parameter descriptions with constraints
4. **Return Value**: What is returned and its structure
5. **Exceptions**: All possible exceptions and when they occur
6. **Usage Example**: Practical example showing typical usage
7. **Security/Performance Notes**: Important considerations
8. **Related Methods**: Links to related functionality

### 3. Property Documentation

#### Property Documentation Template
```dart
/// The current connection state of the Bluetooth mesh service.
/// 
/// This property reflects the overall state of the mesh networking service,
/// including both central (scanning) and peripheral (advertising) operations.
/// 
/// The state changes are emitted through the [connectionStateStream] for
/// reactive programming patterns.
/// 
/// ## Possible Values
/// 
/// - [ConnectionState.disconnected]: Service is stopped, no BLE operations
/// - [ConnectionState.connecting]: Service is initializing BLE operations
/// - [ConnectionState.connected]: Service is active and mesh networking is operational
/// - [ConnectionState.error]: Service encountered an error and stopped
/// 
/// ## Example
/// 
/// ```dart
/// if (meshService.connectionState == ConnectionState.connected) {
///   await meshService.sendMessage('Hello!');
/// } else {
///   print('Mesh service not ready: ${meshService.connectionState}');
/// }
/// ```
/// 
/// See also:
/// - [connectionStateStream] for reactive state monitoring
/// - [initialize] to change state to connected
/// - [dispose] to change state to disconnected
ConnectionState get connectionState => _connectionState;
```

### 4. Enum Documentation

#### Enum Documentation Template
```dart
/// Represents the different types of messages in the BitChat protocol.
/// 
/// These message types are part of the binary protocol specification and
/// must remain compatible with the iOS and Android implementations.
/// Each type has a specific byte value used in the packet header.
/// 
/// ## Protocol Compatibility
/// 
/// The enum values correspond to the following byte values in the packet header:
/// - Discovery: 0x01
/// - Channel: 0x02  
/// - Private: 0x03
/// - Routing: 0x04
/// - Acknowledgment: 0x05
/// - Fragment: 0x06
/// - Ping: 0x07
/// - Pong: 0x08
/// 
/// ## Usage
/// 
/// ```dart
/// final header = PacketHeader(
///   messageType: MessageType.channel,
///   ttl: 7,
///   sourceId: deviceId,
///   destinationId: 0, // Broadcast
///   payloadLength: payload.length,
/// );
/// ```
enum MessageType {
  /// Peer discovery announcement message.
  /// 
  /// Used when a device joins the mesh network to announce its presence
  /// and capabilities to nearby peers. Contains device information such as
  /// supported channels and public key for secure communication.
  discovery(0x01),
  
  /// Channel (group) message.
  /// 
  /// Used for messages sent to a specific channel that all channel members
  /// can receive. These messages are encrypted with the channel's shared key
  /// derived from the channel password using Argon2id.
  channel(0x02),
  
  /// Private (direct) message.
  /// 
  /// Used for one-to-one encrypted messages between two specific peers.
  /// These messages use X25519 key exchange and AES-256-GCM encryption
  /// for end-to-end security.
  private(0x03),
  
  /// Routing table update message.
  /// 
  /// Used to share routing information across the mesh network, enabling
  /// multi-hop message delivery. Contains information about reachable peers
  /// and the hop count to reach them.
  routing(0x04),
  
  /// Message acknowledgment.
  /// 
  /// Used to confirm receipt of messages that require acknowledgment.
  /// Helps with reliability and delivery confirmation in the mesh network.
  acknowledgment(0x05),
  
  /// Message fragment.
  /// 
  /// Used when a message is too large for a single BLE packet and must be
  /// split into multiple fragments. Each fragment contains sequence information
  /// for proper reassembly at the destination.
  fragment(0x06),
  
  /// Keep-alive ping message.
  /// 
  /// Used to maintain connections and verify that peers are still reachable.
  /// Helps with connection management and network topology maintenance.
  ping(0x07),
  
  /// Ping response message.
  /// 
  /// Response to a ping message, confirming that the peer is still active
  /// and reachable. Used for connection health monitoring.
  pong(0x08);
  
  /// The byte value used in the binary protocol.
  final int value;
  
  const MessageType(this.value);
}
```

## Documentation Best Practices

### 1. Writing Style Guidelines

#### Language and Tone
- **Use active voice**: "The method encrypts the message" vs "The message is encrypted"
- **Be concise**: Avoid unnecessary words while maintaining clarity
- **Use present tense**: "Returns a list" vs "Will return a list"
- **Be specific**: Use precise technical terms rather than vague descriptions

#### Formatting Standards
- **Use proper Markdown**: Leverage headers, lists, code blocks, and links
- **Code examples**: Always use proper syntax highlighting with ```dart
- **Parameter lists**: Use consistent formatting for parameter descriptions
- **Line length**: Keep documentation lines under 80 characters when possible

### 2. Code Examples

#### Example Quality Standards
```dart
/// Example of a well-documented method with comprehensive example
/// 
/// ```dart
/// // Initialize the service
/// final meshService = BluetoothMeshService();
/// await meshService.initialize();
/// 
/// // Set up message listener
/// meshService.messageStream.listen((message) {
///   print('Received: ${message.content}');
/// });
/// 
/// // Send a message
/// try {
///   await meshService.sendMessage(
///     'Hello, mesh network!',
///     channelId: 'general',
///     priority: MessagePriority.normal,
///   );
///   print('Message sent successfully');
/// } catch (e) {
///   print('Failed to send message: $e');
/// }
/// 
/// // Clean up
/// await meshService.dispose();
/// ```
```

#### Example Requirements
- **Complete**: Show full usage pattern, not just method calls
- **Realistic**: Use realistic data and scenarios
- **Error Handling**: Include proper error handling
- **Context**: Show setup and cleanup when relevant
- **Comments**: Add explanatory comments for complex examples

### 3. Cross-References and Links

#### Linking Standards
```dart
/// Processes incoming mesh messages and routes them appropriately.
/// 
/// This method works in conjunction with [sendMessage] to provide
/// bidirectional communication. It uses [MessageValidator] to ensure
/// message integrity and [EncryptionService] for decryption.
/// 
/// For message format details, see [MessageType] enum and the
/// protocol specification in `docs/PROTOCOL_SPEC.md`.
/// 
/// Related functionality:
/// - [sendMessage]: For sending messages
/// - [MessageValidator.validate]: For message validation
/// - [EncryptionService.decrypt]: For message decryption
```

#### Link Types
- **Class references**: `[ClassName]` for classes in the same package
- **Method references**: `[methodName]` for methods in the same class
- **External references**: `[package:name/file.dart]` for external packages
- **Documentation references**: Relative paths to markdown files

### 4. Security and Compatibility Documentation

#### Security Documentation Template
```dart
/// ## Security Considerations
/// 
/// This method handles sensitive cryptographic material and implements
/// the following security measures:
/// 
/// - **Memory Safety**: Sensitive data is zeroed after use
/// - **Timing Attack Resistance**: Uses constant-time operations
/// - **Input Validation**: All inputs are validated before processing
/// - **Error Handling**: Fails securely without leaking information
/// 
/// **⚠️ Security Warning**: This method must not be called with untrusted
/// input without proper validation. Malformed input could lead to
/// cryptographic vulnerabilities.
```

#### Compatibility Documentation Template
```dart
/// ## Protocol Compatibility
/// 
/// This implementation maintains strict compatibility with:
/// - **iOS BitChat**: v2.1.0+ (tested with v2.1.3)
/// - **Android BitChat**: v1.8.0+ (tested with v1.8.2)
/// 
/// **Binary Compatibility**: The packet format produced by this method
/// is byte-for-byte identical to the reference implementations.
/// 
/// **Cryptographic Compatibility**: Uses identical algorithms and parameters:
/// - X25519 key exchange (RFC 7748)
/// - AES-256-GCM encryption (NIST SP 800-38D)
/// - HKDF key derivation (RFC 5869)
```

## Documentation Maintenance

### 1. Keeping Documentation Current

#### Update Triggers
- **Code Changes**: Update docs when changing method signatures or behavior
- **Bug Fixes**: Update examples if they contained bugs
- **Performance Changes**: Update performance notes
- **Security Updates**: Update security considerations

#### Review Process
- **Code Reviews**: Include documentation review in PR process
- **Regular Audits**: Quarterly documentation accuracy reviews
- **User Feedback**: Address documentation issues reported by users

### 2. Documentation Testing

#### Example Validation
```dart
// Test that documentation examples actually work
void main() {
  group('Documentation Examples', () {
    test('BluetoothMeshService example should work', () async {
      // Copy example from documentation and verify it compiles and runs
      final meshService = BluetoothMeshService();
      await meshService.initialize();
      
      // ... rest of example ...
      
      await meshService.dispose();
    });
  });
}
```

#### Documentation Linting
```bash
# Check for common documentation issues
dart doc --validate-links
dart analyze --fatal-warnings

# Custom documentation checks
scripts/check-docs.sh
```

## Tools and Automation

### 1. Documentation Generation

#### dartdoc Configuration
```yaml
# dartdoc_options.yaml
dartdoc:
  include:
    - lib/**
  exclude:
    - lib/src/internal/**
  categoryOrder:
    - "Core Services"
    - "Bluetooth Mesh"
    - "Encryption"
    - "Protocol"
    - "UI Components"
```

#### Generation Commands
```bash
# Generate API documentation
dart doc

# Generate with custom options
dart doc --output docs/api --validate-links

# Serve documentation locally
dart doc --serve
```

### 2. Documentation Quality Tools

#### Custom Linting Rules
```dart
// Custom analyzer rules for documentation
analyzer:
  rules:
    - public_member_api_docs: true
    - package_api_docs: true
    - comment_references: true
```

#### Documentation Coverage
```bash
# Check documentation coverage
dart doc --dry-run --quiet 2>&1 | grep "warning: "

# Generate documentation coverage report
scripts/doc-coverage.sh
```

## Examples of Well-Documented APIs

### 1. Service Class Example
```dart
/// Manages encrypted storage for BitChat application data.
/// 
/// This service provides secure, encrypted storage for sensitive application
/// data including user preferences, channel subscriptions, and cached messages.
/// All data is encrypted using AES-256-GCM with keys derived from the device's
/// secure enclave (iOS) or Android Keystore.
/// 
/// ## Usage
/// 
/// ```dart
/// final storage = SecureStorageService();
/// await storage.initialize();
/// 
/// // Store encrypted data
/// await storage.store('user_preferences', userPrefs);
/// 
/// // Retrieve and decrypt data
/// final prefs = await storage.retrieve<UserPreferences>('user_preferences');
/// ```
/// 
/// ## Security Features
/// 
/// - Hardware-backed encryption keys (when available)
/// - Automatic key rotation every 30 days
/// - Secure deletion of sensitive data
/// - Protection against cold boot attacks
/// 
/// ## Platform Support
/// 
/// - **iOS**: Uses Keychain Services and Secure Enclave
/// - **Android**: Uses Android Keystore and EncryptedSharedPreferences
/// - **Desktop**: Uses platform-specific secure storage APIs
class SecureStorageService {
  // Implementation...
}
```

### 2. Data Model Example
```dart
/// Represents an encrypted message in the BitChat protocol.
/// 
/// This class encapsulates all the data needed to represent an encrypted
/// message that can be transmitted over the Bluetooth mesh network and
/// successfully decrypted by the recipient.
/// 
/// ## Structure
/// 
/// The encrypted message contains:
/// - **Ciphertext**: The encrypted message content
/// - **Nonce**: The unique nonce used for encryption (12 bytes)
/// - **Tag**: The authentication tag for integrity verification (16 bytes)
/// - **Metadata**: Additional information needed for decryption
/// 
/// ## Protocol Compatibility
/// 
/// This structure is binary-compatible with the iOS and Android implementations
/// and follows the packet format specified in `docs/PROTOCOL_SPEC.md`.
/// 
/// ## Example
/// 
/// ```dart
/// final encrypted = EncryptedMessage(
///   ciphertext: encryptedBytes,
///   nonce: randomNonce,
///   tag: authTag,
///   senderPublicKey: senderKey,
///   timestamp: DateTime.now(),
/// );
/// 
/// // Serialize for transmission
/// final bytes = encrypted.toBytes();
/// 
/// // Deserialize from received data
/// final received = EncryptedMessage.fromBytes(receivedBytes);
/// ```
@immutable
class EncryptedMessage {
  /// The encrypted message content.
  /// 
  /// This is the result of AES-256-GCM encryption of the original plaintext
  /// message. The length varies based on the original message size.
  final Uint8List ciphertext;
  
  /// The nonce used for encryption.
  /// 
  /// This is a 12-byte (96-bit) random value that must be unique for each
  /// encryption operation with the same key. It's generated using a
  /// cryptographically secure random number generator.
  final Uint8List nonce;
  
  /// The authentication tag for integrity verification.
  /// 
  /// This is a 16-byte (128-bit) tag generated by the AES-GCM algorithm
  /// that allows verification of both the ciphertext integrity and the
  /// authenticity of the additional authenticated data.
  final Uint8List tag;
  
  // ... rest of implementation
}
```

## Conclusion

Good API documentation is essential for maintainable, secure, and compatible code. By following these standards, we ensure that:

- **Developers** can quickly understand and use APIs correctly
- **Security auditors** can verify cryptographic implementations
- **Contributors** can maintain protocol compatibility
- **Users** can troubleshoot issues effectively

Remember: Documentation is code, and like code, it should be reviewed, tested, and maintained with the same rigor as the implementation itself.

---

**Questions?** Create an issue or refer to existing well-documented classes in the codebase for examples.