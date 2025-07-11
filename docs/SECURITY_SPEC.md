# BitChat Flutter Security Specification

## Table of Contents
1. [Overview](#overview)
2. [Threat Model](#threat-model)
3. [Cryptographic Primitives](#cryptographic-primitives)
4. [Private Message Encryption](#private-message-encryption)
5. [Channel Encryption](#channel-encryption)
6. [Digital Signatures](#digital-signatures)
7. [Key Management](#key-management)
8. [Forward Secrecy](#forward-secrecy)
9. [Message Authentication](#message-authentication)
10. [Emergency Wipe](#emergency-wipe)
11. [Cover Traffic](#cover-traffic)
12. [Memory Management](#memory-management)
13. [Implementation Guidelines](#implementation-guidelines)
14. [Security Assumptions](#security-assumptions)
15. [Platform Compatibility](#platform-compatibility)
16. [Testing Requirements](#testing-requirements)

## Overview

BitChat implements a comprehensive security model designed for decentralized peer-to-peer messaging over Bluetooth Low Energy (BLE) mesh networks. The system provides end-to-end encryption for private messages, secure group messaging through channels, and robust protection against various attack vectors.

### Security Goals
- **Confidentiality**: All messages are encrypted end-to-end
- **Integrity**: Message tampering is detectable
- **Authenticity**: Message origin is verifiable
- **Forward Secrecy**: Past messages remain secure if keys are compromised
- **Anonymity**: User identities are protected where possible
- **Availability**: System remains functional under attack

### Security Design Principles
- **Defense in Depth**: Multiple layers of security controls
- **Fail Secure**: System defaults to secure behavior on failure
- **Minimal Attack Surface**: Reduce exposure to potential vulnerabilities
- **Cryptographic Agility**: Support for algorithm updates
- **Verifiable Security**: All cryptographic operations are auditable

## Threat Model

### Threat Actors
1. **Passive Adversary**: Monitors network traffic, collects metadata
2. **Active Adversary**: Injects/modifies messages, performs man-in-the-middle attacks
3. **Malicious Peer**: Compromised device in the mesh network
4. **Physical Adversary**: Has temporary physical access to device
5. **State Actor**: Advanced persistent threat with significant resources

### Attack Vectors
1. **Traffic Analysis**: Monitoring communication patterns
2. **Message Injection**: Inserting malicious messages
3. **Replay Attacks**: Retransmitting previously captured messages
4. **Timing Attacks**: Exploiting timing variations in cryptographic operations
5. **Side-Channel Attacks**: Extracting secrets through power/electromagnetic analysis
6. **Denial of Service**: Overwhelming the system with invalid requests
7. **Key Compromise**: Obtaining encryption keys through various means
8. **Device Compromise**: Full control over user's device

### Assets Protected
- **Message Content**: Actual message text and media
- **Communication Metadata**: Sender, recipient, timestamps
- **User Identity**: Real-world identity and pseudonyms
- **Social Graph**: Communication patterns and relationships
- **Cryptographic Keys**: All keys used for encryption and authentication

## Cryptographic Primitives

### Symmetric Encryption
- **Algorithm**: AES-256-GCM
- **Key Size**: 256 bits
- **Nonce Size**: 96 bits (12 bytes)
- **Tag Size**: 128 bits (16 bytes)
- **Implementation**: Use platform-native crypto libraries

### Asymmetric Encryption
- **Algorithm**: X25519 (Curve25519 ECDH)
- **Key Size**: 256 bits
- **Implementation**: RFC 7748 compliant

### Digital Signatures
- **Algorithm**: Ed25519
- **Key Size**: 256 bits
- **Signature Size**: 512 bits (64 bytes)
- **Implementation**: RFC 8032 compliant

### Key Derivation
- **Algorithm**: Argon2id
- **Memory Cost**: 65536 KB (64 MB)
- **Time Cost**: 3 iterations
- **Parallelism**: 4 threads
- **Salt Size**: 128 bits (16 bytes)
- **Output Size**: 256 bits (32 bytes)

### Hashing
- **Algorithm**: SHA-256
- **Output Size**: 256 bits (32 bytes)
- **Usage**: Message integrity, key derivation, digital signatures

### Random Number Generation
- **Source**: Platform-secure random number generator
- **Entropy**: Minimum 256 bits for key generation
- **Implementation**: Use `dart:math.Random.secure()` or platform-specific secure RNG

## Private Message Encryption

### Key Exchange Protocol
Private messages use X25519 Elliptic Curve Diffie-Hellman (ECDH) key exchange:

1. **Key Pair Generation**:
   ```
   (private_key_A, public_key_A) = X25519.generate_keypair()
   (private_key_B, public_key_B) = X25519.generate_keypair()
   ```

2. **Shared Secret Calculation**:
   ```
   shared_secret = X25519.compute_shared_secret(private_key_A, public_key_B)
   ```

3. **Key Derivation**:
   ```
   encryption_key = HKDF-SHA256(shared_secret, salt="BitChat-Private", info="", length=32)
   ```

### Message Encryption Process
1. **Generate Nonce**: 96-bit random nonce for each message
2. **Encrypt**: `ciphertext = AES-256-GCM.encrypt(key, nonce, plaintext, additional_data)`
3. **Additional Data**: Include sender public key, recipient public key, timestamp
4. **Output**: `nonce || ciphertext || tag`

### Message Format
```
Private Message Packet:
├── Header (13 bytes)
│   ├── Version (1 byte)
│   ├── Type (1 byte) = 0x01
│   ├── TTL (1 byte)
│   ├── Sender ID (4 bytes)
│   ├── Recipient ID (4 bytes)
│   └── Sequence (2 bytes)
├── Sender Public Key (32 bytes)
├── Nonce (12 bytes)
├── Ciphertext (variable)
└── Authentication Tag (16 bytes)
```

## Channel Encryption

### Password-Based Key Derivation
Channel messages use password-based encryption with Argon2id:

1. **Salt Generation**: 128-bit random salt per channel
2. **Key Derivation**:
   ```
   channel_key = Argon2id(
     password=channel_password,
     salt=channel_salt,
     memory=65536,
     iterations=3,
     parallelism=4,
     output_length=32
   )
   ```

### Channel Key Management
- **Key Rotation**: New keys generated every 24 hours or 10,000 messages
- **Key Distribution**: Secure key update messages for existing members
- **Key Storage**: Ephemeral keys stored in memory only

### Message Encryption Process
1. **Generate Nonce**: 96-bit random nonce for each message
2. **Additional Data**: Channel ID, sender public key, message sequence
3. **Encrypt**: `ciphertext = AES-256-GCM.encrypt(channel_key, nonce, plaintext, additional_data)`
4. **Output**: `nonce || ciphertext || tag`

### Message Format
```
Channel Message Packet:
├── Header (13 bytes)
│   ├── Version (1 byte)
│   ├── Type (1 byte) = 0x02
│   ├── TTL (1 byte)
│   ├── Channel ID (4 bytes)
│   ├── Sender ID (4 bytes)
│   └── Sequence (2 bytes)
├── Nonce (12 bytes)
├── Ciphertext (variable)
└── Authentication Tag (16 bytes)
```

## Digital Signatures

### Signature Generation
All messages are signed using Ed25519:

1. **Key Pair Generation**:
   ```
   (signing_key, verify_key) = Ed25519.generate_keypair()
   ```

2. **Message Signing**:
   ```
   message_hash = SHA-256(message_content)
   signature = Ed25519.sign(signing_key, message_hash)
   ```

3. **Signature Verification**:
   ```
   is_valid = Ed25519.verify(verify_key, message_hash, signature)
   ```

### Signature Format
```
Digital Signature:
├── Signature (64 bytes)
└── Public Key (32 bytes)
```

### Integration with Encryption
Signatures are applied to plaintext before encryption:
```
1. plaintext = original_message
2. signature = Ed25519.sign(signing_key, SHA-256(plaintext))
3. signed_message = plaintext || signature
4. ciphertext = AES-256-GCM.encrypt(key, nonce, signed_message)
```

## Key Management

### Key Lifecycle
1. **Generation**: Cryptographically secure random number generation
2. **Distribution**: Secure key exchange protocols
3. **Storage**: Ephemeral keys in memory, persistent keys encrypted
4. **Rotation**: Regular key updates for forward secrecy
5. **Destruction**: Secure memory clearing and zeroing

### Key Storage
- **Ephemeral Keys**: Stored in memory only, cleared on app termination
- **Identity Keys**: Encrypted and stored in secure platform storage
- **Channel Keys**: Derived on-demand, not persistently stored
- **Session Keys**: Generated per session, destroyed on session end

### Key Derivation Hierarchy
```
Master Identity Key (Ed25519)
├── Session Signing Key (Ed25519)
├── Session Encryption Key (X25519)
├── Channel Participation Keys
└── Emergency Wipe Key
```

## Forward Secrecy

### Session-Based Forward Secrecy
- **New Key Pairs**: Generated for each session
- **Key Destruction**: Previous keys securely destroyed
- **Session Timeout**: Maximum 24 hours per session
- **Rekeying**: Automatic key rotation every 1000 messages

### Implementation Strategy
1. **Session Initialization**: Generate new ephemeral key pairs
2. **Key Exchange**: Use Double Ratchet-inspired key derivation
3. **Message Keys**: Derive unique key for each message
4. **Key Deletion**: Immediately destroy used keys

### Double Ratchet Integration
While maintaining protocol compatibility, implement Double Ratchet concepts:
- **Diffie-Hellman Ratchet**: Regular key pair updates
- **Symmetric Key Ratchet**: Forward-secure key derivation
- **Message Key Derivation**: Unique key per message

## Message Authentication

### Message Integrity
- **AEAD Encryption**: AES-256-GCM provides built-in authentication
- **Additional Data**: Include metadata in authentication tag
- **Sequence Numbers**: Prevent replay attacks
- **Timestamps**: Detect delayed message delivery

### Replay Protection
- **Message Sequence**: Strictly increasing sequence numbers
- **Timestamp Window**: Accept messages within 5-minute window
- **Duplicate Detection**: Track recent message IDs
- **Nonce Uniqueness**: Ensure nonce never reused with same key

### Implementation
```dart
class MessageAuthenticator {
  static const int TIMESTAMP_WINDOW = 300; // 5 minutes
  static const int MAX_SEQUENCE_GAP = 1000;
  
  bool validateMessage(Message message) {
    // Check timestamp window
    if (abs(message.timestamp - currentTime()) > TIMESTAMP_WINDOW) {
      return false;
    }
    
    // Check sequence number
    if (message.sequence <= lastSeenSequence) {
      return false;
    }
    
    // Check for sequence gap
    if (message.sequence - lastSeenSequence > MAX_SEQUENCE_GAP) {
      return false;
    }
    
    return true;
  }
}
```

## Emergency Wipe

### Trigger Mechanism
- **Triple-Tap**: Three rapid taps on specific UI element
- **Panic Button**: Dedicated emergency button in settings
- **Remote Wipe**: Authenticated remote wipe command
- **Automatic Wipe**: On multiple failed authentication attempts

### Wipe Process
1. **Immediate**: Stop all network operations
2. **Memory**: Zero all cryptographic keys and sensitive data
3. **Storage**: Overwrite all persistent data with random data
4. **Verification**: Confirm complete data destruction
5. **Notification**: Optional silent notification to trusted contacts

### Implementation
```dart
class EmergencyWipe {
  static const int WIPE_PASSES = 3;
  
  Future<void> performEmergencyWipe() async {
    // Stop all operations
    await stopAllNetworkOperations();
    
    // Clear memory
    clearSensitiveMemory();
    
    // Overwrite storage
    await overwriteStorage();
    
    // Clear preferences
    await clearAllPreferences();
    
    // Reset application state
    await resetApplication();
  }
  
  void clearSensitiveMemory() {
    // Zero all key materials
    for (var key in activeKeys) {
      key.clear();
    }
    
    // Clear message buffers
    messageBuffer.clear();
    
    // Force garbage collection
    gc();
  }
}
```

## Cover Traffic

### Traffic Analysis Protection
- **Dummy Messages**: Random messages to obscure real traffic
- **Constant Rate**: Maintain consistent message transmission rate
- **Padding**: Random padding to obscure message lengths
- **Timing Jitter**: Random delays to prevent timing correlation

### Implementation Strategy
1. **Background Messages**: Regular transmission of dummy messages
2. **Message Padding**: Pad messages to fixed sizes (128, 256, 512 bytes)
3. **Transmission Delays**: Add random delays to real messages
4. **Decoy Conversations**: Simulate conversations with non-existent peers

### Cover Traffic Configuration
```dart
class CoverTrafficConfig {
  static const Duration MIN_INTERVAL = Duration(seconds: 30);
  static const Duration MAX_INTERVAL = Duration(minutes: 2);
  static const List<int> PADDING_SIZES = [128, 256, 512, 1024];
  static const double COVER_TRAFFIC_RATIO = 0.3; // 30% of traffic
}
```

## Memory Management

### Secure Memory Handling
- **Immediate Clearing**: Clear sensitive data immediately after use
- **Secure Allocation**: Use secure memory allocation where available
- **Stack Protection**: Prevent sensitive data from being swapped
- **Garbage Collection**: Force GC after clearing sensitive data

### Implementation Guidelines
```dart
class SecureMemory {
  static void secureClear(List<int> data) {
    // Overwrite with random data
    final random = Random.secure();
    for (int i = 0; i < data.length; i++) {
      data[i] = random.nextInt(256);
    }
    
    // Overwrite with zeros
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
  
  static void secureString(String sensitive) {
    // Convert to bytes and clear
    final bytes = utf8.encode(sensitive);
    secureClear(bytes);
  }
}
```

### Memory Protection
- **Key Storage**: Never store keys in serializable objects
- **String Handling**: Avoid string concatenation with sensitive data
- **Buffer Management**: Use fixed-size buffers for sensitive operations
- **Cleanup**: Implement proper cleanup in finally blocks

## Implementation Guidelines

### Secure Coding Practices
1. **Input Validation**: Validate all inputs before processing
2. **Error Handling**: Fail securely, don't leak information
3. **Logging**: Never log sensitive data
4. **Constants**: Use const for cryptographic parameters
5. **Testing**: Comprehensive security testing

### Cryptographic Implementation
```dart
class CryptographicService {
  static final _instance = CryptographicService._internal();
  factory CryptographicService() => _instance;
  CryptographicService._internal();
  
  Future<EncryptionResult> encryptMessage(
    String message,
    Uint8List key,
    Uint8List nonce,
  ) async {
    try {
      // Input validation
      if (message.isEmpty || key.length != 32 || nonce.length != 12) {
        throw ArgumentError('Invalid encryption parameters');
      }
      
      // Encrypt message
      final plaintext = utf8.encode(message);
      final cipher = AesGcm.with256bits();
      final secretBox = await cipher.encrypt(
        plaintext,
        secretKey: SecretKey(key),
        nonce: nonce,
      );
      
      return EncryptionResult(
        ciphertext: secretBox.cipherText,
        tag: secretBox.mac.bytes,
      );
    } finally {
      // Clear sensitive data
      SecureMemory.secureClear(key);
    }
  }
}
```

### Error Handling
- **Consistent Errors**: Use consistent error messages
- **No Information Leakage**: Don't reveal why operations failed
- **Graceful Degradation**: Maintain functionality where possible
- **Logging**: Log security events without sensitive data

## Security Assumptions

### Trusted Components
1. **Flutter Framework**: Assumes Flutter crypto libraries are secure
2. **Platform Crypto**: Relies on platform-native cryptographic implementations
3. **Hardware Security**: Assumes hardware-based RNG is secure
4. **Bluetooth Stack**: Assumes BLE implementation is not malicious

### Security Boundaries
1. **Device Boundary**: Physical device security is user's responsibility
2. **Network Boundary**: All network communication is potentially hostile
3. **Application Boundary**: Other apps on device are potentially malicious
4. **User Boundary**: User behavior impacts security

### Known Limitations
1. **Bluetooth Security**: BLE has inherent security limitations
2. **Traffic Analysis**: Perfect traffic analysis resistance is impossible
3. **Physical Security**: No protection against physical device compromise
4. **Social Engineering**: No protection against user manipulation

## Platform Compatibility

### iOS Compatibility
- **CommonCrypto**: Use for cryptographic operations
- **Security Framework**: For key storage and management
- **Network Extension**: For background operations
- **Keychain Services**: For persistent key storage

### Android Compatibility
- **AndroidKeyStore**: For hardware-backed key storage
- **Crypto API**: Use Android Crypto APIs
- **Background Services**: For maintaining connectivity
- **Security Provider**: Use appropriate security provider

### Cross-Platform Considerations
- **Endianness**: Consistent byte order across platforms
- **Key Format**: Standardized key serialization
- **Protocol Compatibility**: Identical wire protocol
- **Crypto Libraries**: Consistent cryptographic implementations

## Testing Requirements

### Unit Tests
- **Cryptographic Functions**: Test all crypto operations
- **Key Management**: Test key generation, storage, destruction
- **Message Processing**: Test encryption/decryption
- **Error Handling**: Test error conditions

### Integration Tests
- **End-to-End**: Test complete message flow
- **Cross-Platform**: Test iOS/Android compatibility
- **Performance**: Test crypto performance
- **Memory**: Test memory management

### Security Tests
- **Penetration Testing**: Automated security testing
- **Fuzzing**: Test with malformed inputs
- **Timing Attacks**: Test for timing vulnerabilities
- **Side-Channel**: Test for information leakage

### Test Implementation
```dart
class SecurityTest {
  @Test
  void testEncryptionDecryption() {
    final message = "Test message";
    final key = generateRandomKey();
    final nonce = generateRandomNonce();
    
    final encrypted = encryptMessage(message, key, nonce);
    final decrypted = decryptMessage(encrypted, key, nonce);
    
    expect(decrypted, equals(message));
  }
  
  @Test
  void testKeyDestruction() {
    final key = generateRandomKey();
    final originalKey = List<int>.from(key);
    
    destroyKey(key);
    
    expect(key, isNot(equals(originalKey)));
    expect(key.every((byte) => byte == 0), isTrue);
  }
}
```

## Compliance and Standards

### Cryptographic Standards
- **FIPS 140-2**: Use FIPS-approved algorithms where possible
- **NIST SP 800-57**: Follow key management guidelines
- **RFC 7748**: X25519 implementation
- **RFC 8032**: Ed25519 implementation

### Security Frameworks
- **OWASP Mobile**: Follow mobile security guidelines
- **NIST Cybersecurity Framework**: Implement security controls
- **ISO 27001**: Information security management

### Regulatory Compliance
- **GDPR**: Data protection and privacy
- **CCPA**: California privacy regulations
- **Export Controls**: Cryptographic export restrictions

## Conclusion

This security specification provides comprehensive guidelines for implementing secure messaging in BitChat Flutter. All cryptographic operations must be implemented according to these specifications to ensure compatibility with existing BitChat implementations while maintaining the highest security standards.

Regular security reviews and updates to this specification are essential as the threat landscape evolves and new vulnerabilities are discovered.

---

**Document Version**: 1.0  
**Last Updated**: July 2025  
**Next Review**: January 2026