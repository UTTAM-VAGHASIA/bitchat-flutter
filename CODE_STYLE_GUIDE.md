# BitChat Flutter - Code Style Guide

**Version:** 1.0  
**Last Updated:** July 26, 2025

## Overview

This document defines the coding standards and style guidelines for BitChat Flutter development. These standards ensure code consistency, maintainability, and readability across the project. All contributors must follow these guidelines, which complement the existing `API_DOCUMENTATION_STANDARDS.md`.

## Table of Contents

- [General Principles](#general-principles)
- [Dart Language Standards](#dart-language-standards)
- [Flutter-Specific Guidelines](#flutter-specific-guidelines)
- [Project Architecture Standards](#project-architecture-standards)
- [Naming Conventions](#naming-conventions)
- [Code Organization](#code-organization)
- [Documentation Standards](#documentation-standards)
- [Error Handling](#error-handling)
- [Testing Standards](#testing-standards)
- [Performance Guidelines](#performance-guidelines)
- [Security Coding Practices](#security-coding-practices)
- [Tools and Automation](#tools-and-automation)

## General Principles

### Code Quality Principles

1. **Readability First**: Code should be self-documenting and easy to understand
2. **Consistency**: Follow established patterns throughout the codebase
3. **Simplicity**: Prefer simple, clear solutions over complex ones
4. **Maintainability**: Write code that's easy to modify and extend
5. **Performance**: Consider performance implications of coding decisions
6. **Security**: Always consider security implications

### Development Philosophy

```dart
// Good: Clear, self-documenting code
final encryptedMessage = await encryptionService.encryptMessage(
  plaintext: userMessage,
  recipientPublicKey: peer.publicKey,
  algorithm: EncryptionAlgorithm.aes256Gcm,
);

// Bad: Unclear, abbreviated code
final em = await es.enc(msg, key, 1);
```

## Dart Language Standards

### Code Formatting

#### Line Length and Wrapping
```dart
// Maximum line length: 80 characters
// Use dart format for automatic formatting

// Good: Proper line wrapping
final result = await bluetoothService.scanForDevices(
  scanDuration: const Duration(seconds: 10),
  allowDuplicates: false,
  scanMode: ScanMode.lowLatency,
);

// Bad: Line too long
final result = await bluetoothService.scanForDevices(scanDuration: const Duration(seconds: 10), allowDuplicates: false, scanMode: ScanMode.lowLatency);
```

#### Indentation and Spacing
```dart
// Use 2 spaces for indentation (enforced by dart format)
class BluetoothMeshService {
  final BluetoothAdapter _adapter;
  final List<ConnectedDevice> _connectedDevices = [];
  
  BluetoothMeshService(this._adapter);
  
  Future<void> startScanning() async {
    if (_adapter.isScanning) {
      return;
    }
    
    await _adapter.startScan(
      timeout: const Duration(seconds: 30),
      allowDuplicates: false,
    );
  }
}
```

### Variable and Function Declarations

#### Variable Declarations
```dart
// Good: Use final for immutable variables
final String deviceId = generateDeviceId();
final List<Message> messages = <Message>[];

// Good: Use const for compile-time constants
const Duration scanTimeout = Duration(seconds: 30);
const String protocolVersion = '2.1.0';

// Good: Use var when type is obvious
var encryptionService = EncryptionService();
var isConnected = await checkConnection();

// Bad: Unnecessary type annotation when obvious
String deviceId = generateDeviceId(); // Type is obvious from function
```

#### Function Declarations
```dart
// Good: Clear function signature with proper typing
Future<EncryptedMessage> encryptMessage({
  required String plaintext,
  required Uint8List recipientPublicKey,
  EncryptionAlgorithm algorithm = EncryptionAlgorithm.aes256Gcm,
}) async {
  // Implementation
}

// Good: Use positional parameters for simple cases
bool isValidDeviceId(String deviceId) {
  return deviceId.length == 32 && deviceId.isNotEmpty;
}

// Bad: Unclear parameter names
Future<bool> process(String s, List<int> l, bool f) async {
  // What do these parameters represent?
}
```

### Collections and Generics

#### Collection Initialization
```dart
// Good: Use collection literals with explicit types when needed
final List<String> channelIds = <String>[];
final Map<String, Device> deviceMap = <String, Device>{};
final Set<String> activeChannels = <String>{};

// Good: Use collection literals for initialization
final supportedAlgorithms = <EncryptionAlgorithm>[
  EncryptionAlgorithm.aes256Gcm,
  EncryptionAlgorithm.chaCha20Poly1305,
];

// Good: Use spread operator for combining collections
final allDevices = <Device>[
  ...nearbyDevices,
  ...connectedDevices,
];
```

#### Generic Type Usage
```dart
// Good: Explicit generic types for clarity
class MessageQueue<T extends Message> {
  final Queue<T> _queue = Queue<T>();
  
  void enqueue(T message) => _queue.add(message);
  T? dequeue() => _queue.isEmpty ? null : _queue.removeFirst();
}

// Good: Use bounded generics when appropriate
abstract class Serializable<T> {
  Map<String, dynamic> toJson();
  T fromJson(Map<String, dynamic> json);
}
```## F
lutter-Specific Guidelines

### Widget Development Standards

#### Widget Structure
```dart
// Good: Well-structured StatelessWidget
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwnMessage,
    this.onTap,
  });

  final Message message;
  final bool isOwnMessage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        child: _buildMessageContent(context),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isOwnMessage 
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: isOwnMessage
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
```

#### StatefulWidget Patterns
```dart
// Good: Proper StatefulWidget structure
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.channelId,
  });

  final String channelId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildMessageInput(),
    );
  }

  // Helper methods for building UI components
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Channel: ${widget.channelId}'),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showChannelInfo,
        ),
      ],
    );
  }
}
```

#### Widget Composition
```dart
// Good: Compose widgets for reusability
class ChannelListTile extends StatelessWidget {
  const ChannelListTile({
    super.key,
    required this.channel,
    required this.onTap,
  });

  final Channel channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildChannelIcon(),
      title: _buildChannelName(),
      subtitle: _buildLastMessage(),
      trailing: _buildUnreadBadge(),
      onTap: onTap,
    );
  }

  Widget _buildChannelIcon() {
    return CircleAvatar(
      backgroundColor: channel.color,
      child: Text(
        channel.name.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChannelName() {
    return Text(
      channel.name,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLastMessage() {
    if (channel.lastMessage == null) {
      return const Text('No messages yet');
    }
    
    return Text(
      channel.lastMessage!.content,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUnreadBadge() {
    if (channel.unreadCount == 0) {
      return null;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        '${channel.unreadCount}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

### State Management with Provider

#### Provider Usage Patterns
```dart
// Good: Proper Provider setup
class ChatProvider extends ChangeNotifier {
  final MessageService _messageService;
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._messageService);

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMessages(String channelId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final messages = await _messageService.getMessages(channelId);
      _messages.clear();
      _messages.addAll(messages);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load messages: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendMessage(String content, String channelId) async {
    try {
      final message = await _messageService.sendMessage(content, channelId);
      _messages.add(message);
      notifyListeners();
    } catch (e) {
      _setError('Failed to send message: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

// Good: Consumer usage
class ChatMessageList extends StatelessWidget {
  const ChatMessageList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${chatProvider.error}'),
                ElevatedButton(
                  onPressed: () => chatProvider.loadMessages('general'),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chatProvider.messages.length,
          itemBuilder: (context, index) {
            final message = chatProvider.messages[index];
            return MessageBubble(
              message: message,
              isOwnMessage: message.senderId == getCurrentUserId(),
            );
          },
        );
      },
    );
  }
}
```

## Project Architecture Standards

### Clean Architecture Implementation

#### Layer Structure
```dart
// Domain Layer - Core business logic
abstract class MessageRepository {
  Future<List<Message>> getMessages(String channelId);
  Future<Message> sendMessage(String content, String channelId);
  Stream<Message> get messageStream;
}

class Message {
  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.channelId,
    required this.timestamp,
    this.encryptedContent,
  });

  final String id;
  final String content;
  final String senderId;
  final String channelId;
  final DateTime timestamp;
  final Uint8List? encryptedContent;
}

// Application Layer - Use cases
class SendMessageUseCase {
  const SendMessageUseCase(this._messageRepository);

  final MessageRepository _messageRepository;

  Future<Message> execute({
    required String content,
    required String channelId,
  }) async {
    // Validate input
    if (content.trim().isEmpty) {
      throw ArgumentError('Message content cannot be empty');
    }

    if (content.length > 1000) {
      throw ArgumentError('Message content too long');
    }

    // Execute business logic
    return await _messageRepository.sendMessage(content, channelId);
  }
}

// Infrastructure Layer - External dependencies
class BluetoothMessageRepository implements MessageRepository {
  const BluetoothMessageRepository(
    this._bluetoothService,
    this._encryptionService,
  );

  final BluetoothService _bluetoothService;
  final EncryptionService _encryptionService;

  @override
  Future<Message> sendMessage(String content, String channelId) async {
    // Encrypt message
    final encrypted = await _encryptionService.encrypt(content);
    
    // Send via Bluetooth
    await _bluetoothService.broadcast(encrypted, channelId);
    
    // Return message object
    return Message(
      id: generateMessageId(),
      content: content,
      senderId: getCurrentUserId(),
      channelId: channelId,
      timestamp: DateTime.now(),
      encryptedContent: encrypted,
    );
  }
}
```

#### Dependency Injection
```dart
// Good: Dependency injection setup
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final BluetoothService _bluetoothService;
  late final EncryptionService _encryptionService;
  late final MessageRepository _messageRepository;

  void initialize() {
    _bluetoothService = BluetoothService();
    _encryptionService = EncryptionService();
    _messageRepository = BluetoothMessageRepository(
      _bluetoothService,
      _encryptionService,
    );
  }

  BluetoothService get bluetoothService => _bluetoothService;
  EncryptionService get encryptionService => _encryptionService;
  MessageRepository get messageRepository => _messageRepository;
}

// Usage in main.dart
void main() {
  ServiceLocator().initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(ServiceLocator().messageRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BluetoothProvider(ServiceLocator().bluetoothService),
        ),
      ],
      child: const BitChatApp(),
    ),
  );
}
```#
# Naming Conventions

### File and Directory Naming

#### File Naming
```
// Good: snake_case for files
lib/
├── core/
│   ├── models/
│   │   ├── message.dart
│   │   ├── channel.dart
│   │   └── encrypted_message.dart
│   ├── services/
│   │   ├── bluetooth_service.dart
│   │   ├── encryption_service.dart
│   │   └── message_service.dart
│   └── utils/
│       ├── device_id_generator.dart
│       └── crypto_utils.dart
├── features/
│   ├── chat/
│   │   ├── data/
│   │   │   └── chat_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── chat_repository.dart
│   │   │   └── send_message_use_case.dart
│   │   └── presentation/
│   │       ├── chat_screen.dart
│   │       ├── chat_provider.dart
│   │       └── widgets/
│   │           ├── message_bubble.dart
│   │           └── message_input.dart
│   └── channels/
│       ├── channel_list_screen.dart
│       └── channel_provider.dart
└── shared/
    ├── widgets/
    │   ├── loading_indicator.dart
    │   └── error_message.dart
    └── themes/
        └── app_theme.dart

// Bad: Inconsistent naming
lib/
├── Core/              // Should be lowercase
├── BluetoothSvc.dart  // Should be snake_case
└── msgBubble.dart     // Should be snake_case
```

#### Directory Structure
```
// Good: Feature-based organization
lib/
├── core/              # Core business logic and shared utilities
├── features/          # Feature-specific modules
├── presentation/      # Global UI components and navigation
└── shared/           # Shared UI components and utilities

// Each feature follows clean architecture
features/
├── feature_name/
│   ├── data/         # Data layer (repositories, data sources)
│   ├── domain/       # Domain layer (entities, use cases)
│   └── presentation/ # Presentation layer (screens, providers, widgets)
```

### Class and Interface Naming

#### Class Naming
```dart
// Good: PascalCase for classes
class BluetoothMeshService { }
class EncryptedMessage { }
class MessageRepository { }
class ChatProvider extends ChangeNotifier { }

// Good: Descriptive names
class X25519KeyExchangeService { }
class AES256GCMEncryption { }
class BluetoothLowEnergyScanner { }

// Bad: Unclear abbreviations
class BtSvc { }  // What does this do?
class MsgRepo { }  // Too abbreviated
class Crypto { }   // Too generic
```

#### Abstract Classes and Interfaces
```dart
// Good: Abstract classes for contracts
abstract class MessageRepository {
  Future<List<Message>> getMessages(String channelId);
  Future<void> sendMessage(Message message);
}

abstract class EncryptionService {
  Future<Uint8List> encrypt(String plaintext, Uint8List key);
  Future<String> decrypt(Uint8List ciphertext, Uint8List key);
}

// Good: Mixin naming
mixin BluetoothEventHandling {
  void onDeviceConnected(BluetoothDevice device);
  void onDeviceDisconnected(BluetoothDevice device);
}
```

### Variable and Method Naming

#### Variable Naming
```dart
// Good: Descriptive camelCase
final String deviceId = generateDeviceId();
final List<ConnectedDevice> connectedDevices = [];
final Duration scanTimeout = const Duration(seconds: 30);
final bool isEncryptionEnabled = true;

// Good: Boolean variables with clear intent
bool isConnected = false;
bool hasUnreadMessages = false;
bool canSendMessage = true;
bool shouldRetryConnection = false;

// Bad: Unclear or abbreviated names
final String id = generateId();  // ID of what?
final List<Device> devs = [];    // Abbreviated
final bool flag = true;          // What flag?
```

#### Method Naming
```dart
// Good: Verb-based method names
Future<void> connectToDevice(BluetoothDevice device) async { }
Future<List<Message>> loadMessages(String channelId) async { }
bool validateMessageContent(String content) { }
void notifyMessageReceived(Message message) { }

// Good: Boolean methods with clear intent
bool isValidDeviceId(String deviceId) { }
bool hasActiveConnections() { }
bool canEncryptMessage(Message message) { }

// Good: Factory methods
static EncryptedMessage fromBytes(Uint8List bytes) { }
static BluetoothDevice createMockDevice() { }

// Bad: Unclear method names
void process() { }        // Process what?
bool check(String s) { }  // Check what?
void handle() { }         // Handle what?
```

#### Constants and Enums
```dart
// Good: SCREAMING_SNAKE_CASE for global constants
const String PROTOCOL_VERSION = '2.1.0';
const int MAX_MESSAGE_LENGTH = 1000;
const Duration DEFAULT_SCAN_TIMEOUT = Duration(seconds: 30);

// Good: PascalCase for enums
enum MessageType {
  text,
  image,
  file,
  system,
}

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

enum EncryptionAlgorithm {
  aes256Gcm,
  chaCha20Poly1305,
}
```

## Code Organization

### Import Organization

#### Import Grouping and Ordering
```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// 2. Flutter framework
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages (alphabetical)
import 'package:crypto/crypto.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

// 4. Internal imports (alphabetical)
import '../core/models/message.dart';
import '../core/services/encryption_service.dart';
import '../shared/widgets/loading_indicator.dart';
```

#### Export Organization
```dart
// Good: Barrel exports for clean API
// lib/core/models/models.dart
export 'channel.dart';
export 'device.dart';
export 'encrypted_message.dart';
export 'message.dart';
export 'user.dart';

// Usage
import 'package:bitchat/core/models/models.dart';
```

### Class Organization

#### Member Ordering
```dart
class BluetoothMeshService {
  // 1. Static constants
  static const String SERVICE_UUID = '12345678-1234-1234-1234-123456789abc';
  static const Duration DEFAULT_TIMEOUT = Duration(seconds: 30);
  
  // 2. Static variables
  static BluetoothMeshService? _instance;
  
  // 3. Instance variables (private first, then public)
  final BluetoothAdapter _adapter;
  final StreamController<BluetoothEvent> _eventController;
  bool _isScanning = false;
  
  // 4. Constructors
  BluetoothMeshService._(this._adapter) 
    : _eventController = StreamController<BluetoothEvent>.broadcast();
  
  factory BluetoothMeshService(BluetoothAdapter adapter) {
    return _instance ??= BluetoothMeshService._(adapter);
  }
  
  // 5. Getters and setters
  bool get isScanning => _isScanning;
  Stream<BluetoothEvent> get eventStream => _eventController.stream;
  
  // 6. Public methods
  Future<void> startScanning() async {
    if (_isScanning) return;
    
    _isScanning = true;
    await _adapter.startScan();
    _notifyStateChanged();
  }
  
  Future<void> stopScanning() async {
    if (!_isScanning) return;
    
    _isScanning = false;
    await _adapter.stopScan();
    _notifyStateChanged();
  }
  
  // 7. Private methods
  void _notifyStateChanged() {
    _eventController.add(BluetoothEvent.stateChanged(_isScanning));
  }
  
  // 8. Overridden methods
  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
```

## Documentation Standards

### Dartdoc Comments

#### Class Documentation
```dart
/// Service responsible for managing Bluetooth Low Energy mesh networking.
/// 
/// This service handles device discovery, connection management, and message
/// routing across the mesh network. It maintains strict compatibility with
/// the iOS and Android BitChat implementations.
/// 
/// ## Usage
/// 
/// ```dart
/// final meshService = BluetoothMeshService(bluetoothAdapter);
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
/// ## Security Considerations
/// 
/// All messages are encrypted using AES-256-GCM with X25519 key exchange.
/// The service implements cover traffic and timing obfuscation to prevent
/// traffic analysis attacks.
/// 
/// See also:
/// - [BluetoothDevice] for device representation
/// - [MeshMessage] for message structure
/// - [EncryptionService] for cryptographic operations
class BluetoothMeshService {
  // Implementation...
}
```

#### Method Documentation
```dart
/// Encrypts a message for secure transmission over the mesh network.
/// 
/// This method implements end-to-end encryption using X25519 key exchange
/// and AES-256-GCM symmetric encryption, maintaining compatibility with
/// iOS and Android implementations.
/// 
/// ## Parameters
/// 
/// - [message]: The plaintext message to encrypt. Must not be empty.
/// - [recipientPublicKey]: The recipient's X25519 public key (32 bytes).
/// - [additionalData]: Optional additional authenticated data.
/// 
/// ## Returns
/// 
/// Returns an [EncryptedMessage] containing the encrypted data and metadata.
/// 
/// ## Throws
/// 
/// - [ArgumentError]: If parameters are invalid (null, wrong size, etc.)
/// - [CryptographicException]: If encryption fails
/// - [StateError]: If the service is not initialized
/// 
/// ## Example
/// 
/// ```dart
/// try {
///   final encrypted = await encryptMessage(
///     'Hello, secure world!',
///     recipientPublicKey,
///   );
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
/// 
/// See also:
/// - [decryptMessage] for decryption
/// - [generateKeyPair] for key generation
Future<EncryptedMessage> encryptMessage(
  String message,
  Uint8List recipientPublicKey, {
  Uint8List? additionalData,
}) async {
  // Implementation...
}
```

### Inline Comments

#### When to Use Comments
```dart
// Good: Explain complex business logic
Future<void> _performKeyExchange(BluetoothDevice device) async {
  // Generate ephemeral key pair for forward secrecy
  final ephemeralKeyPair = await _generateEphemeralKeyPair();
  
  // Send our public key to the peer
  await _sendPublicKey(device, ephemeralKeyPair.publicKey);
  
  // Wait for peer's public key with timeout
  final peerPublicKey = await _waitForPeerPublicKey(device)
      .timeout(const Duration(seconds: 10));
  
  // Derive shared secret using X25519
  final sharedSecret = await _deriveSharedSecret(
    ephemeralKeyPair.privateKey,
    peerPublicKey,
  );
  
  // Store the session key for this device
  _sessionKeys[device.id] = sharedSecret;
}

// Good: Explain non-obvious code
bool _isValidPacketHeader(Uint8List header) {
  // Check magic bytes (first 4 bytes should be 0x42, 0x49, 0x54, 0x43)
  if (header.length < 4) return false;
  return header[0] == 0x42 && header[1] == 0x49 && 
         header[2] == 0x54 && header[3] == 0x43;
}

// Bad: Obvious comments
final String deviceId = generateDeviceId(); // Generate device ID
if (isConnected) { // If connected
  return true; // Return true
}
```

#### TODO and FIXME Comments
```dart
// TODO(username): Implement message fragmentation for large messages
// Expected completion: Sprint 15
Future<void> sendLargeMessage(String message) async {
  if (message.length > MAX_MESSAGE_SIZE) {
    throw UnimplementedError('Message fragmentation not yet implemented');
  }
  // Current implementation...
}

// FIXME(username): Memory leak in connection cleanup
// Issue: #123 - Connections not properly disposed
// Priority: High
void _cleanupConnection(BluetoothDevice device) {
  // Current cleanup logic has issues
  _connections.remove(device.id);
  // TODO: Properly dispose of streams and controllers
}

// HACK(username): Temporary workaround for flutter_blue_plus issue
// Remove when https://github.com/boskokg/flutter_blue_plus/issues/456 is fixed
void _workaroundBluetoothIssue() {
  // Temporary solution that needs to be replaced
}
```## Err
or Handling

### Exception Handling Patterns

#### Custom Exceptions
```dart
// Good: Specific exception types
class BluetoothException implements Exception {
  const BluetoothException(this.message, {this.code});
  
  final String message;
  final String? code;
  
  @override
  String toString() => 'BluetoothException: $message${code != null ? ' ($code)' : ''}';
}

class CryptographicException implements Exception {
  const CryptographicException(this.message, {this.cause});
  
  final String message;
  final Object? cause;
  
  @override
  String toString() => 'CryptographicException: $message';
}

class MessageValidationException implements Exception {
  const MessageValidationException(this.message, {this.field});
  
  final String message;
  final String? field;
  
  @override
  String toString() => 'MessageValidationException: $message${field != null ? ' (field: $field)' : ''}';
}
```

#### Error Handling Patterns
```dart
// Good: Comprehensive error handling
Future<Message> sendMessage(String content, String channelId) async {
  try {
    // Validate input
    if (content.trim().isEmpty) {
      throw MessageValidationException(
        'Message content cannot be empty',
        field: 'content',
      );
    }
    
    if (content.length > MAX_MESSAGE_LENGTH) {
      throw MessageValidationException(
        'Message too long: ${content.length} > $MAX_MESSAGE_LENGTH',
        field: 'content',
      );
    }
    
    // Check connection
    if (!await _isConnectedToChannel(channelId)) {
      throw BluetoothException(
        'Not connected to channel: $channelId',
        code: 'NOT_CONNECTED',
      );
    }
    
    // Encrypt message
    final encrypted = await _encryptionService.encrypt(content);
    
    // Send message
    await _bluetoothService.broadcast(encrypted, channelId);
    
    // Return success
    return Message(
      id: generateMessageId(),
      content: content,
      channelId: channelId,
      timestamp: DateTime.now(),
    );
    
  } on MessageValidationException {
    // Re-throw validation exceptions as-is
    rethrow;
  } on BluetoothException {
    // Re-throw Bluetooth exceptions as-is
    rethrow;
  } on CryptographicException catch (e) {
    // Wrap crypto exceptions with context
    throw BluetoothException(
      'Failed to encrypt message: ${e.message}',
      code: 'ENCRYPTION_FAILED',
    );
  } catch (e, stackTrace) {
    // Log unexpected errors and wrap them
    _logger.error('Unexpected error sending message', e, stackTrace);
    throw BluetoothException(
      'Unexpected error sending message: $e',
      code: 'UNKNOWN_ERROR',
    );
  }
}

// Good: Error handling in UI
class ChatProvider extends ChangeNotifier {
  String? _error;
  bool _isLoading = false;
  
  String? get error => _error;
  bool get isLoading => _isLoading;
  
  Future<void> sendMessage(String content, String channelId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final message = await _messageService.sendMessage(content, channelId);
      _messages.add(message);
      notifyListeners();
    } on MessageValidationException catch (e) {
      _setError('Invalid message: ${e.message}');
    } on BluetoothException catch (e) {
      if (e.code == 'NOT_CONNECTED') {
        _setError('Not connected to channel. Please check your connection.');
      } else {
        _setError('Failed to send message: ${e.message}');
      }
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### Result Pattern for Error Handling

#### Result Type Implementation
```dart
// Good: Result type for better error handling
abstract class Result<T> {
  const Result();
  
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  
  T get value {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    throw StateError('Cannot get value from failure result');
  }
  
  String get error {
    if (this is Failure<T>) {
      return (this as Failure<T>).error;
    }
    throw StateError('Cannot get error from success result');
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final String error;
}

// Usage example
Future<Result<Message>> sendMessage(String content, String channelId) async {
  try {
    if (content.trim().isEmpty) {
      return const Failure('Message content cannot be empty');
    }
    
    final message = await _messageService.sendMessage(content, channelId);
    return Success(message);
  } catch (e) {
    return Failure('Failed to send message: $e');
  }
}

// Usage in UI
Future<void> _handleSendMessage(String content) async {
  final result = await _chatService.sendMessage(content, widget.channelId);
  
  if (result.isSuccess) {
    _messageController.clear();
    _scrollToBottom();
  } else {
    _showErrorSnackBar(result.error);
  }
}
```

## Testing Standards

### Unit Test Structure

#### Test Organization
```dart
// Good: Well-organized test file
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:bitchat/core/services/encryption_service.dart';
import 'package:bitchat/core/models/encrypted_message.dart';

// Generate mocks
@GenerateMocks([BluetoothService])
import 'encryption_service_test.mocks.dart';

void main() {
  group('EncryptionService', () {
    late EncryptionService encryptionService;
    late MockBluetoothService mockBluetoothService;
    
    setUp(() {
      mockBluetoothService = MockBluetoothService();
      encryptionService = EncryptionService(mockBluetoothService);
    });
    
    tearDown(() {
      encryptionService.dispose();
    });
    
    group('encrypt', () {
      test('should encrypt message successfully with valid inputs', () async {
        // Arrange
        const message = 'Hello, secure world!';
        final publicKey = Uint8List.fromList(List.filled(32, 1));
        
        // Act
        final result = await encryptionService.encrypt(message, publicKey);
        
        // Assert
        expect(result, isA<EncryptedMessage>());
        expect(result.ciphertext, isNotEmpty);
        expect(result.nonce.length, equals(12));
        expect(result.tag.length, equals(16));
      });
      
      test('should throw ArgumentError for empty message', () async {
        // Arrange
        const message = '';
        final publicKey = Uint8List.fromList(List.filled(32, 1));
        
        // Act & Assert
        expect(
          () => encryptionService.encrypt(message, publicKey),
          throwsA(isA<ArgumentError>()),
        );
      });
      
      test('should throw ArgumentError for invalid public key', () async {
        // Arrange
        const message = 'Test message';
        final invalidKey = Uint8List.fromList(List.filled(16, 1)); // Wrong size
        
        // Act & Assert
        expect(
          () => encryptionService.encrypt(message, invalidKey),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
    
    group('decrypt', () {
      test('should decrypt message successfully', () async {
        // Arrange
        const originalMessage = 'Hello, secure world!';
        final keyPair = await encryptionService.generateKeyPair();
        final encrypted = await encryptionService.encrypt(
          originalMessage,
          keyPair.publicKey,
        );
        
        // Act
        final decrypted = await encryptionService.decrypt(
          encrypted,
          keyPair.privateKey,
        );
        
        // Assert
        expect(decrypted, equals(originalMessage));
      });
      
      test('should throw CryptographicException for tampered ciphertext', () async {
        // Arrange
        const originalMessage = 'Hello, secure world!';
        final keyPair = await encryptionService.generateKeyPair();
        final encrypted = await encryptionService.encrypt(
          originalMessage,
          keyPair.publicKey,
        );
        
        // Tamper with ciphertext
        final tamperedCiphertext = Uint8List.fromList(encrypted.ciphertext);
        tamperedCiphertext[0] = tamperedCiphertext[0] ^ 1;
        
        final tamperedMessage = EncryptedMessage(
          ciphertext: tamperedCiphertext,
          nonce: encrypted.nonce,
          tag: encrypted.tag,
          senderPublicKey: encrypted.senderPublicKey,
          timestamp: encrypted.timestamp,
        );
        
        // Act & Assert
        expect(
          () => encryptionService.decrypt(tamperedMessage, keyPair.privateKey),
          throwsA(isA<CryptographicException>()),
        );
      });
    });
  });
}
```

#### Widget Testing
```dart
// Good: Widget test structure
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:bitchat/features/chat/presentation/chat_screen.dart';
import 'package:bitchat/features/chat/presentation/chat_provider.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('ChatScreen', () {
    late MockChatProvider mockChatProvider;
    
    setUp(() {
      mockChatProvider = MockChatProvider();
    });
    
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider<ChatProvider>.value(
          value: mockChatProvider,
          child: const ChatScreen(channelId: 'test-channel'),
        ),
      );
    }
    
    testWidgets('should display loading indicator when loading', (tester) async {
      // Arrange
      when(mockChatProvider.isLoading).thenReturn(true);
      when(mockChatProvider.messages).thenReturn([]);
      when(mockChatProvider.error).thenReturn(null);
      
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('test-channel'), findsOneWidget);
    });
    
    testWidgets('should display messages when loaded', (tester) async {
      // Arrange
      final messages = [
        createTestMessage(content: 'Hello'),
        createTestMessage(content: 'World'),
      ];
      when(mockChatProvider.isLoading).thenReturn(false);
      when(mockChatProvider.messages).thenReturn(messages);
      when(mockChatProvider.error).thenReturn(null);
      
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Assert
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('World'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    
    testWidgets('should send message when send button is tapped', (tester) async {
      // Arrange
      when(mockChatProvider.isLoading).thenReturn(false);
      when(mockChatProvider.messages).thenReturn([]);
      when(mockChatProvider.error).thenReturn(null);
      
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      
      // Assert
      verify(mockChatProvider.sendMessage('Test message', 'test-channel')).called(1);
    });
  });
}
```

## Performance Guidelines

### Memory Management

#### Proper Resource Disposal
```dart
// Good: Proper resource management
class BluetoothMeshService extends ChangeNotifier {
  StreamSubscription<BluetoothDevice>? _scanSubscription;
  StreamController<MeshEvent>? _eventController;
  Timer? _heartbeatTimer;
  
  @override
  void dispose() {
    // Cancel subscriptions
    _scanSubscription?.cancel();
    _scanSubscription = null;
    
    // Close controllers
    _eventController?.close();
    _eventController = null;
    
    // Cancel timers
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    
    super.dispose();
  }
}

// Good: Using try-finally for cleanup
Future<void> processLargeFile(File file) async {
  RandomAccessFile? raf;
  try {
    raf = await file.open();
    // Process file...
  } finally {
    await raf?.close();
  }
}
```

#### Efficient Collections
```dart
// Good: Use appropriate collection types
class MessageCache {
  // Use LinkedHashMap for LRU behavior
  final LinkedHashMap<String, Message> _cache = LinkedHashMap();
  final int _maxSize;
  
  MessageCache(this._maxSize);
  
  void put(String key, Message message) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      _cache.remove(key);
    } else if (_cache.length >= _maxSize) {
      // Remove least recently used
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = message;
  }
  
  Message? get(String key) {
    final message = _cache.remove(key);
    if (message != null) {
      // Move to end (most recently used)
      _cache[key] = message;
    }
    return message;
  }
}

// Good: Use Set for uniqueness checks
class DeviceManager {
  final Set<String> _connectedDeviceIds = <String>{};
  
  bool isConnected(String deviceId) {
    return _connectedDeviceIds.contains(deviceId); // O(1) lookup
  }
  
  void addDevice(String deviceId) {
    _connectedDeviceIds.add(deviceId);
  }
}
```

### Async Programming Best Practices

#### Efficient Async Operations
```dart
// Good: Use Future.wait for parallel operations
Future<void> initializeServices() async {
  await Future.wait([
    _bluetoothService.initialize(),
    _encryptionService.initialize(),
    _storageService.initialize(),
  ]);
}

// Good: Use Stream.listen with proper error handling
void _listenToBluetoothEvents() {
  _bluetoothService.eventStream.listen(
    (event) => _handleBluetoothEvent(event),
    onError: (error) => _logger.error('Bluetooth event error', error),
    onDone: () => _logger.info('Bluetooth event stream closed'),
  );
}

// Good: Use async generators for streaming data
Stream<Message> watchMessages(String channelId) async* {
  // Yield cached messages first
  final cached = await _getCachedMessages(channelId);
  for (final message in cached) {
    yield message;
  }
  
  // Then yield real-time messages
  await for (final message in _messageStream) {
    if (message.channelId == channelId) {
      yield message;
    }
  }
}
```## Securi
ty Coding Practices

### Cryptographic Operations

#### Secure Key Handling
```dart
// Good: Secure key management
class SecureKeyManager {
  static const int KEY_SIZE = 32; // 256 bits
  static const int NONCE_SIZE = 12; // 96 bits for AES-GCM
  
  /// Generates a cryptographically secure random key.
  /// 
  /// The key is generated using the platform's secure random number
  /// generator and should be disposed of securely after use.
  Uint8List generateSecureKey() {
    final random = Random.secure();
    final key = Uint8List(KEY_SIZE);
    for (int i = 0; i < KEY_SIZE; i++) {
      key[i] = random.nextInt(256);
    }
    return key;
  }
  
  /// Securely zeros out sensitive data in memory.
  /// 
  /// This helps prevent sensitive data from remaining in memory
  /// after it's no longer needed.
  void secureZero(Uint8List data) {
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
  
  /// Derives a key from a password using Argon2id.
  /// 
  /// This is used for channel passwords and provides protection
  /// against brute force attacks.
  Future<Uint8List> deriveKeyFromPassword(
    String password,
    Uint8List salt,
  ) async {
    // Use Argon2id with appropriate parameters
    final argon2 = Argon2id(
      memory: 65536,    // 64 MB
      iterations: 3,    // 3 iterations
      parallelism: 4,   // 4 parallel threads
      hashLength: 32,   // 256-bit output
    );
    
    return await argon2.hash(
      password: utf8.encode(password),
      salt: salt,
    );
  }
}

// Good: Constant-time comparison to prevent timing attacks
bool constantTimeEquals(Uint8List a, Uint8List b) {
  if (a.length != b.length) {
    return false;
  }
  
  int result = 0;
  for (int i = 0; i < a.length; i++) {
    result |= a[i] ^ b[i];
  }
  
  return result == 0;
}
```

#### Input Validation and Sanitization
```dart
// Good: Comprehensive input validation
class MessageValidator {
  static const int MAX_MESSAGE_LENGTH = 1000;
  static const int MIN_MESSAGE_LENGTH = 1;
  static const int MAX_CHANNEL_NAME_LENGTH = 50;
  
  /// Validates message content for security and format requirements.
  /// 
  /// Throws [MessageValidationException] if validation fails.
  static void validateMessageContent(String content) {
    if (content.isEmpty) {
      throw MessageValidationException(
        'Message content cannot be empty',
        field: 'content',
      );
    }
    
    if (content.length > MAX_MESSAGE_LENGTH) {
      throw MessageValidationException(
        'Message too long: ${content.length} > $MAX_MESSAGE_LENGTH characters',
        field: 'content',
      );
    }
    
    // Check for null bytes (potential injection)
    if (content.contains('\x00')) {
      throw MessageValidationException(
        'Message contains invalid null bytes',
        field: 'content',
      );
    }
    
    // Validate UTF-8 encoding
    try {
      utf8.encode(content);
    } catch (e) {
      throw MessageValidationException(
        'Message contains invalid UTF-8 characters',
        field: 'content',
      );
    }
  }
  
  /// Validates channel name for security requirements.
  static void validateChannelName(String channelName) {
    if (channelName.isEmpty) {
      throw MessageValidationException(
        'Channel name cannot be empty',
        field: 'channelName',
      );
    }
    
    if (channelName.length > MAX_CHANNEL_NAME_LENGTH) {
      throw MessageValidationException(
        'Channel name too long: ${channelName.length} > $MAX_CHANNEL_NAME_LENGTH',
        field: 'channelName',
      );
    }
    
    // Only allow alphanumeric, hyphens, and underscores
    final validPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validPattern.hasMatch(channelName)) {
      throw MessageValidationException(
        'Channel name contains invalid characters. Only letters, numbers, hyphens, and underscores are allowed.',
        field: 'channelName',
      );
    }
  }
  
  /// Validates device ID format and security requirements.
  static void validateDeviceId(String deviceId) {
    if (deviceId.length != 32) {
      throw MessageValidationException(
        'Device ID must be exactly 32 characters',
        field: 'deviceId',
      );
    }
    
    // Must be hexadecimal
    final hexPattern = RegExp(r'^[0-9a-fA-F]+$');
    if (!hexPattern.hasMatch(deviceId)) {
      throw MessageValidationException(
        'Device ID must be hexadecimal',
        field: 'deviceId',
      );
    }
  }
}

// Good: Sanitize data for logging
class SecureLogger {
  static String sanitizeForLog(String data) {
    // Remove or mask sensitive information
    return data
        .replaceAll(RegExp(r'\b[0-9a-fA-F]{32}\b'), '[DEVICE_ID]')
        .replaceAll(RegExp(r'\b[0-9a-fA-F]{64}\b'), '[KEY]')
        .replaceAll(RegExp(r'password\s*[:=]\s*\S+', caseSensitive: false), 'password: [REDACTED]');
  }
  
  static void logSecure(String level, String message, [Object? error]) {
    final sanitized = sanitizeForLog(message);
    // Log the sanitized message
    print('[$level] $sanitized');
    if (error != null) {
      print('Error: ${sanitizeForLog(error.toString())}');
    }
  }
}
```

### Secure Data Storage

#### Sensitive Data Handling
```dart
// Good: Secure storage implementation
class SecureStorage {
  static const String _keyPrefix = 'bitchat_secure_';
  
  /// Stores sensitive data with encryption.
  /// 
  /// Data is encrypted before storage and the encryption key
  /// is derived from the device's secure enclave when available.
  Future<void> storeSecure(String key, String value) async {
    try {
      // Derive encryption key from device keystore
      final encryptionKey = await _deriveStorageKey(key);
      
      // Encrypt the value
      final encrypted = await _encrypt(value, encryptionKey);
      
      // Store encrypted data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyPrefix$key', base64.encode(encrypted));
      
      // Securely zero the encryption key
      _secureZero(encryptionKey);
    } catch (e) {
      throw StorageException('Failed to store secure data: $e');
    }
  }
  
  /// Retrieves and decrypts sensitive data.
  Future<String?> retrieveSecure(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString('$_keyPrefix$key');
      
      if (encryptedData == null) {
        return null;
      }
      
      // Derive decryption key
      final decryptionKey = await _deriveStorageKey(key);
      
      // Decrypt the data
      final encrypted = base64.decode(encryptedData);
      final decrypted = await _decrypt(encrypted, decryptionKey);
      
      // Securely zero the decryption key
      _secureZero(decryptionKey);
      
      return decrypted;
    } catch (e) {
      throw StorageException('Failed to retrieve secure data: $e');
    }
  }
  
  /// Securely deletes sensitive data.
  Future<void> deleteSecure(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$key');
  }
}
```

## Tools and Automation

### Code Quality Tools

#### Analysis Options Configuration
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
  
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  
  errors:
    # Treat certain warnings as errors
    invalid_assignment: error
    missing_return: error
    dead_code: error
    unused_import: error
    unused_local_variable: error

linter:
  rules:
    # Style rules
    - always_declare_return_types
    - always_put_control_body_on_new_line
    - always_put_required_named_parameters_first
    - always_specify_types
    - annotate_overrides
    - avoid_bool_literals_in_conditional_expressions
    - avoid_empty_else
    - avoid_function_literals_in_foreach_calls
    - avoid_init_to_null
    - avoid_null_checks_in_equality_operators
    - avoid_relative_lib_imports
    - avoid_return_types_on_setters
    - avoid_shadowing_type_parameters
    - avoid_types_as_parameter_names
    - avoid_unnecessary_containers
    - await_only_futures
    - camel_case_extensions
    - camel_case_types
    - cancel_subscriptions
    - close_sinks
    - comment_references
    - constant_identifier_names
    - control_flow_in_finally
    - curly_braces_in_flow_control_structures
    - empty_catches
    - empty_constructor_bodies
    - empty_statements
    - file_names
    - hash_and_equals
    - implementation_imports
    - invariant_booleans
    - iterable_contains_unrelated_type
    - library_names
    - library_prefixes
    - list_remove_unrelated_type
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - non_constant_identifier_names
    - null_closures
    - omit_local_variable_types
    - only_throw_errors
    - overridden_fields
    - package_api_docs
    - package_names
    - package_prefixed_library_names
    - parameter_assignments
    - prefer_adjacent_string_concatenation
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_constructors_over_static_methods
    - prefer_contains
    - prefer_equal_for_default_values
    - prefer_final_fields
    - prefer_final_locals
    - prefer_for_elements_to_map_fromIterable
    - prefer_generic_function_type_aliases
    - prefer_if_null_operators
    - prefer_initializing_formals
    - prefer_inlined_adds
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_iterable_whereType
    - prefer_single_quotes
    - prefer_spread_collections
    - prefer_typing_uninitialized_variables
    - prefer_void_to_null
    - public_member_api_docs
    - recursive_getters
    - slash_for_doc_comments
    - sort_child_properties_last
    - sort_constructors_first
    - sort_unnamed_constructors_first
    - test_types_in_equals
    - throw_in_finally
    - type_init_formals
    - unawaited_futures
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_getters_setters
    - unnecessary_lambdas
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_null_in_if_null_operators
    - unnecessary_overrides
    - unnecessary_parenthesis
    - unnecessary_statements
    - unnecessary_this
    - unrelated_type_equality_checks
    - use_full_hex_values_for_flutter_colors
    - use_function_type_syntax_for_parameters
    - use_rethrow_when_possible
    - valid_regexps
    - void_checks
```

#### Pre-commit Hooks
```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Running pre-commit checks..."

# Format code
echo "Formatting code..."
dart format .

# Run static analysis
echo "Running static analysis..."
flutter analyze
if [ $? -ne 0 ]; then
  echo "Static analysis failed. Please fix the issues before committing."
  exit 1
fi

# Run tests
echo "Running tests..."
flutter test
if [ $? -ne 0 ]; then
  echo "Tests failed. Please fix the failing tests before committing."
  exit 1
fi

# Check for TODO/FIXME without assignee
echo "Checking for unassigned TODOs..."
if grep -r "TODO:" lib/ --include="*.dart" | grep -v "TODO([a-zA-Z]"; then
  echo "Found TODOs without assignee. Please assign TODOs to a person."
  exit 1
fi

echo "All pre-commit checks passed!"
```

#### Continuous Integration Configuration
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: |
        cd bitchat
        flutter pub get
    
    - name: Verify formatting
      run: |
        cd bitchat
        dart format --output=none --set-exit-if-changed .
    
    - name: Analyze project source
      run: |
        cd bitchat
        flutter analyze
    
    - name: Run tests
      run: |
        cd bitchat
        flutter test --coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: bitchat/coverage/lcov.info
```

### Development Scripts

#### Build Scripts
```bash
#!/bin/bash
# scripts/build.sh

set -e

echo "Building BitChat Flutter..."

# Navigate to Flutter app
cd bitchat

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean
flutter pub get

# Generate code
echo "Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run tests
echo "Running tests..."
flutter test

# Build for different platforms
echo "Building for Android..."
flutter build apk --release

echo "Building for iOS..."
flutter build ios --release --no-codesign

echo "Build completed successfully!"
```

#### Setup Script
```bash
#!/bin/bash
# scripts/setup.sh

set -e

echo "Setting up BitChat Flutter development environment..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check Flutter doctor
echo "Checking Flutter installation..."
flutter doctor

# Navigate to Flutter app
cd bitchat

# Install dependencies
echo "Installing dependencies..."
flutter pub get

# Generate code
echo "Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run tests to verify setup
echo "Running tests to verify setup..."
flutter test

# Set up git hooks
echo "Setting up git hooks..."
cp ../scripts/pre-commit ../.git/hooks/
chmod +x ../.git/hooks/pre-commit

echo "Setup completed successfully!"
echo "You can now run 'flutter run' to start the app."
```

## Conclusion

This code style guide provides comprehensive standards for BitChat Flutter development. Following these guidelines ensures:

### Key Benefits

1. **Consistency**: Uniform code style across the entire project
2. **Maintainability**: Code that's easy to understand and modify
3. **Security**: Secure coding practices for cryptographic operations
4. **Performance**: Efficient code that performs well on mobile devices
5. **Quality**: High-quality code with comprehensive testing

### Enforcement

- **Automated Tools**: Use `dart format`, `flutter analyze`, and CI/CD pipelines
- **Code Reviews**: Enforce standards through peer review process
- **Documentation**: Keep this guide updated as the project evolves
- **Training**: Ensure all contributors understand and follow these standards

### Continuous Improvement

This guide is a living document that should evolve with the project. Contributors are encouraged to:

- **Suggest Improvements**: Propose updates to improve code quality
- **Share Best Practices**: Share discoveries and lessons learned
- **Update Examples**: Keep examples current with latest Flutter/Dart features
- **Maintain Standards**: Help maintain consistency across the codebase

---

**Remember**: Good code style is not just about following rules—it's about writing code that your future self and your teammates will thank you for. 🚀

For questions about this style guide or specific coding standards, please create an issue or start a discussion on GitHub.