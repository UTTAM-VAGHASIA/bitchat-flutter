# BitChat Flutter - Architecture Documentation

## Overview

BitChat Flutter implements a decentralized peer-to-peer messaging system using Bluetooth Low Energy (BLE) mesh networking. The architecture follows Clean Architecture principles with clear separation of concerns across multiple layers.

## High-Level Architecture

For comprehensive architecture diagrams, see the [Architecture Diagrams](../assets/architecture_diagrams/) directory:

- **[System Architecture](../assets/architecture_diagrams/system_architecture.md)**: Complete system overview with Clean Architecture layers
- **[Component Interactions](../assets/architecture_diagrams/component_interactions.md)**: Detailed component relationships and data flow
- **[Data Flow](../assets/architecture_diagrams/data_flow.md)**: Data movement patterns throughout the application
- **[Flutter Architecture](../assets/architecture_diagrams/flutter_architecture.md)**: Flutter-specific architectural patterns and widget organization

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

## Flutter Widget Architecture

### Widget Tree Structure

BitChat Flutter follows a hierarchical widget structure that maps directly to the Clean Architecture layers:

```
MaterialApp
├── MultiProvider (State Management)
│   ├── BluetoothProvider
│   ├── MeshNetworkProvider
│   ├── ChatProvider
│   ├── EncryptionProvider
│   └── SettingsProvider
├── Router (Navigation)
│   ├── ChatScreen
│   │   ├── AppBar (Connection Status)
│   │   ├── ChannelHeader (Channel Info)
│   │   ├── MessageList (Scrollable Chat)
│   │   │   ├── MessageBubble (Individual Messages)
│   │   │   ├── SystemMessage (Join/Leave Events)
│   │   │   └── TypingIndicator
│   │   └── MessageInput (Text Input + Commands)
│   ├── ChannelListScreen
│   │   ├── ChannelTile (Channel Items)
│   │   ├── DirectMessageTile (DM Items)
│   │   └── JoinChannelDialog
│   ├── SettingsScreen
│   │   ├── ProfileSection
│   │   ├── SecuritySection
│   │   ├── NetworkSection
│   │   └── AppearanceSection
│   └── PeerDiscoveryScreen
│       ├── ScanningIndicator
│       ├── PeerTile (Discovered Peers)
│       └── ConnectionStatus
└── Theme (Material Design 3)
```

### Widget Component Mapping

Flutter widgets map to native implementations as follows:

| Flutter Widget | iOS Equivalent | Android Equivalent | Purpose |
|----------------|----------------|-------------------|---------|
| `Scaffold` | `UIViewController` | `Activity/Fragment` | Screen container |
| `AppBar` | `UINavigationBar` | `ActionBar/Toolbar` | Top navigation |
| `ListView` | `UITableView` | `RecyclerView` | Scrollable lists |
| `TextField` | `UITextField` | `EditText` | Text input |
| `FloatingActionButton` | `UIButton` | `FloatingActionButton` | Primary actions |
| `BottomNavigationBar` | `UITabBar` | `BottomNavigationView` | Tab navigation |
| `Dialog` | `UIAlertController` | `AlertDialog` | Modal dialogs |
| `SnackBar` | `UIToast` | `Snackbar` | Temporary messages |

### Custom Widget Architecture

```dart
// Base widget for all BitChat UI components
abstract class BitChatWidget extends StatelessWidget {
  const BitChatWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) => buildWithTheme(context, theme),
    );
  }
  
  Widget buildWithTheme(BuildContext context, ThemeProvider theme);
}

// Message bubble with encryption status
class MessageBubble extends BitChatWidget {
  final Message message;
  final bool isOwn;
  final bool showTimestamp;
  
  const MessageBubble({
    Key? key,
    required this.message,
    required this.isOwn,
    this.showTimestamp = true,
  }) : super(key: key);
  
  @override
  Widget buildWithTheme(BuildContext context, ThemeProvider theme) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isOwn) _buildAvatar(),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOwn ? theme.primaryColor : theme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: message.isEncrypted 
                  ? Border.all(color: theme.successColor, width: 1)
                  : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isOwn) _buildSenderName(),
                  _buildMessageContent(),
                  if (showTimestamp) _buildTimestamp(),
                  if (message.isEncrypted) _buildEncryptionIndicator(),
                ],
              ),
            ),
          ),
          if (isOwn) _buildDeliveryStatus(),
        ],
      ),
    );
  }
}
```

## State Management Architecture

### Provider Pattern Implementation

BitChat uses the Provider pattern for reactive state management across the widget tree:

```dart
// Main provider setup
MultiProvider(
  providers: [
    // Core system providers
    ChangeNotifierProvider(create: (_) => BluetoothProvider()),
    ChangeNotifierProvider(create: (_) => MeshNetworkProvider()),
    ChangeNotifierProvider(create: (_) => EncryptionProvider()),
    
    // Feature providers
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => ChannelProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    
    // UI providers
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ],
  child: BitChatApp(),
)
```

### State Provider Architecture

```dart
// Base provider class with common functionality
abstract class BitChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  @protected
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  @protected
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  @protected
  Future<T> executeWithErrorHandling<T>(Future<T> Function() operation) async {
    try {
      setLoading(true);
      setError(null);
      return await operation();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}

// Chat provider with message management
class ChatProvider extends BitChatProvider {
  final MessageRepository _messageRepository;
  final EncryptionService _encryptionService;
  
  List<Message> _messages = [];
  String? _currentChannel;
  Map<String, List<Message>> _channelMessages = {};
  
  List<Message> get messages => List.unmodifiable(_messages);
  String? get currentChannel => _currentChannel;
  
  ChatProvider(this._messageRepository, this._encryptionService);
  
  Future<void> sendMessage(String content, {String? channelId}) async {
    await executeWithErrorHandling(() async {
      final message = Message(
        id: generateMessageId(),
        content: content,
        senderId: UserService.currentUserId,
        channelId: channelId ?? _currentChannel,
        timestamp: DateTime.now(),
        isEncrypted: true,
      );
      
      // Encrypt message
      final encryptedMessage = await _encryptionService.encryptMessage(message);
      
      // Send through mesh network
      await _messageRepository.sendMessage(encryptedMessage);
      
      // Update local state
      _addMessage(message);
    });
  }
  
  void _addMessage(Message message) {
    _messages.add(message);
    
    // Update channel-specific messages
    final channelId = message.channelId ?? 'direct';
    _channelMessages.putIfAbsent(channelId, () => []).add(message);
    
    notifyListeners();
  }
  
  Future<void> switchChannel(String channelId) async {
    _currentChannel = channelId;
    _messages = _channelMessages[channelId] ?? [];
    notifyListeners();
    
    // Load message history
    await loadChannelHistory(channelId);
  }
}

// Bluetooth provider with connection management
class BluetoothProvider extends BitChatProvider {
  final BluetoothService _bluetoothService;
  
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  List<BluetoothDevice> _connectedDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  
  BluetoothAdapterState get adapterState => _adapterState;
  List<BluetoothDevice> get connectedDevices => List.unmodifiable(_connectedDevices);
  List<ScanResult> get scanResults => List.unmodifiable(_scanResults);
  bool get isScanning => _isScanning;
  
  BluetoothProvider(this._bluetoothService) {
    _initializeBluetooth();
  }
  
  Future<void> _initializeBluetooth() async {
    await executeWithErrorHandling(() async {
      await _bluetoothService.initialize();
      
      // Listen to adapter state changes
      _bluetoothService.adapterStateStream.listen((state) {
        _adapterState = state;
        notifyListeners();
      });
      
      // Listen to scan results
      _bluetoothService.scanResultsStream.listen((results) {
        _scanResults = results;
        notifyListeners();
      });
    });
  }
  
  Future<void> startScanning() async {
    await executeWithErrorHandling(() async {
      _isScanning = true;
      notifyListeners();
      
      await _bluetoothService.startScanning();
    });
  }
  
  Future<void> stopScanning() async {
    _isScanning = false;
    await _bluetoothService.stopScanning();
    notifyListeners();
  }
}
```

### State Flow Architecture

```
User Interaction → Widget Event → Provider Method → Use Case → 
Repository → Data Source → Domain Entity → Provider State Update → 
Widget Rebuild → UI Update
```

### Reactive State Updates

```dart
// Widget consuming multiple providers
class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChannelProvider>(
          builder: (context, channelProvider, child) {
            return Text(channelProvider.currentChannel?.name ?? 'BitChat');
          },
        ),
        actions: [
          Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, child) {
              return ConnectionStatusIndicator(
                isConnected: bluetoothProvider.connectedDevices.isNotEmpty,
                deviceCount: bluetoothProvider.connectedDevices.length,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                
                return MessageList(messages: chatProvider.messages);
              },
            ),
          ),
          MessageInput(
            onSendMessage: (message) {
              context.read<ChatProvider>().sendMessage(message);
            },
          ),
        ],
      ),
    );
  }
}
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

## Flutter Performance Architecture

### Widget Performance Optimization

```dart
// Optimized message list with efficient rebuilds
class MessageList extends StatefulWidget {
  final List<Message> messages;
  
  const MessageList({Key? key, required this.messages}) : super(key: key);
  
  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Show newest messages at bottom
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[widget.messages.length - 1 - index];
        
        // Use RepaintBoundary to isolate repaints
        return RepaintBoundary(
          child: MessageBubble(
            key: ValueKey(message.id),
            message: message,
            isOwn: message.senderId == UserService.currentUserId,
          ),
        );
      },
      // Optimize for large lists
      cacheExtent: 1000,
      physics: const BouncingScrollPhysics(),
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// Efficient channel list with selective rebuilds
class ChannelList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<ChannelProvider, List<Channel>>(
      selector: (context, provider) => provider.channels,
      builder: (context, channels, child) {
        return ListView.separated(
          itemCount: channels.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final channel = channels[index];
            
            return Selector<ChannelProvider, bool>(
              selector: (context, provider) => 
                provider.currentChannel?.id == channel.id,
              builder: (context, isSelected, child) {
                return ChannelTile(
                  channel: channel,
                  isSelected: isSelected,
                  onTap: () => context.read<ChannelProvider>().switchChannel(channel.id),
                );
              },
            );
          },
        );
      },
    );
  }
}
```

### Memory Management for Flutter

```dart
// Memory-efficient message handling
class MessageManager {
  static const int MAX_CACHED_MESSAGES = 1000;
  static const int MESSAGE_CLEANUP_THRESHOLD = 1200;
  
  final Map<String, List<Message>> _channelMessages = {};
  final Map<String, DateTime> _lastAccess = {};
  
  void addMessage(Message message) {
    final channelId = message.channelId ?? 'direct';
    final messages = _channelMessages.putIfAbsent(channelId, () => []);
    
    messages.add(message);
    _lastAccess[channelId] = DateTime.now();
    
    // Cleanup old messages if threshold exceeded
    if (messages.length > MESSAGE_CLEANUP_THRESHOLD) {
      _cleanupOldMessages(channelId);
    }
  }
  
  void _cleanupOldMessages(String channelId) {
    final messages = _channelMessages[channelId];
    if (messages == null || messages.length <= MAX_CACHED_MESSAGES) return;
    
    // Keep only the most recent messages
    final keepCount = MAX_CACHED_MESSAGES;
    final removeCount = messages.length - keepCount;
    
    // Remove old messages and clear their memory
    for (int i = 0; i < removeCount; i++) {
      final message = messages.removeAt(0);
      message.dispose(); // Custom dispose method for cleanup
    }
    
    // Force garbage collection
    Future.microtask(() => GarbageCollector.collect());
  }
}

// Widget lifecycle management for performance
abstract class PerformantWidget extends StatefulWidget {
  const PerformantWidget({Key? key}) : super(key: key);
}

abstract class PerformantWidgetState<T extends PerformantWidget> 
    extends State<T> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // Keep state alive for performance
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onPostFrameCallback();
    });
  }
  
  void onPostFrameCallback() {
    // Override in subclasses for post-frame initialization
  }
  
  @override
  void dispose() {
    // Cleanup resources
    cleanupResources();
    super.dispose();
  }
  
  void cleanupResources() {
    // Override in subclasses for cleanup
  }
}
```

### Battery Optimization for Flutter

```dart
// Battery-aware operations
class BatteryOptimizedOperations {
  static const Duration LOW_BATTERY_SCAN_INTERVAL = Duration(minutes: 2);
  static const Duration NORMAL_SCAN_INTERVAL = Duration(seconds: 30);
  static const Duration HIGH_BATTERY_SCAN_INTERVAL = Duration(seconds: 10);
  
  final Battery _battery = Battery();
  BatteryLevel _currentLevel = BatteryLevel.unknown;
  
  Future<void> initialize() async {
    _currentLevel = await _battery.batteryLevel;
    
    // Listen to battery changes
    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      _currentLevel = await _battery.batteryLevel;
      _adjustOperationsForBattery();
    });
  }
  
  void _adjustOperationsForBattery() {
    final scanInterval = _getScanInterval();
    final maxConnections = _getMaxConnections();
    
    // Adjust Bluetooth operations
    BluetoothManager.instance.setScanInterval(scanInterval);
    BluetoothManager.instance.setMaxConnections(maxConnections);
    
    // Adjust UI refresh rates
    _adjustUIRefreshRate();
  }
  
  Duration _getScanInterval() {
    switch (_currentLevel) {
      case BatteryLevel.low:
        return LOW_BATTERY_SCAN_INTERVAL;
      case BatteryLevel.medium:
        return NORMAL_SCAN_INTERVAL;
      case BatteryLevel.high:
        return HIGH_BATTERY_SCAN_INTERVAL;
      default:
        return NORMAL_SCAN_INTERVAL;
    }
  }
  
  int _getMaxConnections() {
    switch (_currentLevel) {
      case BatteryLevel.low:
        return 3;
      case BatteryLevel.medium:
        return 6;
      case BatteryLevel.high:
        return 10;
      default:
        return 6;
    }
  }
  
  void _adjustUIRefreshRate() {
    // Reduce animation frame rates on low battery
    if (_currentLevel == BatteryLevel.low) {
      WidgetsBinding.instance.scheduleFrameCallback((_) {
        // Reduce frame rate to 30fps
        Future.delayed(Duration(milliseconds: 33), () {
          WidgetsBinding.instance.scheduleFrame();
        });
      });
    }
  }
}

// Efficient background processing
class BackgroundTaskManager {
  static const String MESH_SYNC_TASK = 'mesh_sync';
  static const String MESSAGE_CLEANUP_TASK = 'message_cleanup';
  
  final Map<String, Timer> _activeTasks = {};
  
  void startBackgroundTasks() {
    // Mesh network synchronization
    _activeTasks[MESH_SYNC_TASK] = Timer.periodic(
      Duration(minutes: 5),
      (_) => _performMeshSync(),
    );
    
    // Message cleanup
    _activeTasks[MESSAGE_CLEANUP_TASK] = Timer.periodic(
      Duration(hours: 1),
      (_) => _performMessageCleanup(),
    );
  }
  
  void stopBackgroundTasks() {
    _activeTasks.values.forEach((timer) => timer.cancel());
    _activeTasks.clear();
  }
  
  Future<void> _performMeshSync() async {
    // Lightweight mesh network synchronization
    try {
      await MeshNetworkService.instance.syncRoutingTable();
      await MeshNetworkService.instance.processQueuedMessages();
    } catch (e) {
      Logger.warning('Background mesh sync failed: $e');
    }
  }
  
  Future<void> _performMessageCleanup() async {
    // Clean up old messages and free memory
    try {
      await MessageManager.instance.cleanupOldMessages();
      await CacheManager.instance.clearExpiredCache();
    } catch (e) {
      Logger.warning('Background cleanup failed: $e');
    }
  }
}
```

### Rendering Performance

```dart
// Custom render objects for complex UI elements
class MessageBubbleRenderObject extends RenderBox {
  Message _message;
  bool _isOwn;
  TextPainter? _textPainter;
  
  MessageBubbleRenderObject({
    required Message message,
    required bool isOwn,
  }) : _message = message, _isOwn = isOwn;
  
  @override
  void performLayout() {
    // Efficient text measurement and layout
    _textPainter ??= TextPainter(
      text: TextSpan(text: _message.content),
      textDirection: TextDirection.ltr,
    );
    
    _textPainter!.layout(
      minWidth: 0,
      maxWidth: constraints.maxWidth * 0.8,
    );
    
    final bubbleWidth = _textPainter!.width + 24; // Padding
    final bubbleHeight = _textPainter!.height + 16; // Padding
    
    size = Size(bubbleWidth, bubbleHeight);
  }
  
  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = _isOwn ? Colors.blue : Colors.grey[300]!
      ..style = PaintingStyle.fill;
    
    // Draw bubble background
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      Radius.circular(16),
    );
    canvas.drawRRect(bubbleRect, paint);
    
    // Draw text
    _textPainter!.paint(canvas, offset + Offset(12, 8));
  }
}
```

## Flutter Testing Architecture

### Flutter Test Pyramid

```
┌─────────────────────────────────────────────────────────────┐
│                    Integration Tests                        │
│              (flutter_driver, integration_test)            │
├─────────────────────────────────────────────────────────────┤
│                      Widget Tests                          │
│                 (flutter_test, testWidgets)                │
├─────────────────────────────────────────────────────────────┤
│                       Unit Tests                            │
│                  (test, mockito, mocktail)                 │
└─────────────────────────────────────────────────────────────┘
```

### Flutter-Specific Test Categories

#### 1. Widget Tests
```dart
// Widget testing for UI components
class MessageBubbleTest {
  testWidgets('MessageBubble displays message content correctly', (tester) async {
    final message = Message(
      id: 'test-id',
      content: 'Test message',
      senderId: 'user-1',
      timestamp: DateTime.now(),
      isEncrypted: true,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            isOwn: false,
          ),
        ),
      ),
    );
    
    // Verify message content is displayed
    expect(find.text('Test message'), findsOneWidget);
    
    // Verify encryption indicator is shown
    expect(find.byIcon(Icons.lock), findsOneWidget);
    
    // Verify bubble styling
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(MessageBubble),
        matching: find.byType(Container),
      ),
    );
    
    expect(container.decoration, isA<BoxDecoration>());
  });
  
  testWidgets('MessageBubble handles long messages correctly', (tester) async {
    final longMessage = 'A' * 1000; // Very long message
    final message = Message(
      id: 'test-id',
      content: longMessage,
      senderId: 'user-1',
      timestamp: DateTime.now(),
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            isOwn: false,
          ),
        ),
      ),
    );
    
    // Verify message is displayed without overflow
    expect(tester.takeException(), isNull);
    expect(find.text(longMessage), findsOneWidget);
  });
}
```

#### 2. Provider Testing
```dart
// Testing state management providers
class ChatProviderTest {
  late ChatProvider chatProvider;
  late MockMessageRepository mockMessageRepository;
  late MockEncryptionService mockEncryptionService;
  
  setUp(() {
    mockMessageRepository = MockMessageRepository();
    mockEncryptionService = MockEncryptionService();
    chatProvider = ChatProvider(mockMessageRepository, mockEncryptionService);
  });
  
  test('sendMessage encrypts and sends message correctly', () async {
    // Arrange
    const messageContent = 'Test message';
    const channelId = 'test-channel';
    
    when(() => mockEncryptionService.encryptMessage(any()))
        .thenAnswer((_) async => EncryptedMessage(/* ... */));
    when(() => mockMessageRepository.sendMessage(any()))
        .thenAnswer((_) async => {});
    
    // Act
    await chatProvider.sendMessage(messageContent, channelId: channelId);
    
    // Assert
    verify(() => mockEncryptionService.encryptMessage(any())).called(1);
    verify(() => mockMessageRepository.sendMessage(any())).called(1);
    expect(chatProvider.messages.length, equals(1));
    expect(chatProvider.messages.first.content, equals(messageContent));
  });
  
  test('switchChannel updates current channel and loads history', () async {
    // Arrange
    const channelId = 'new-channel';
    final mockMessages = [
      Message(id: '1', content: 'Message 1', senderId: 'user-1'),
      Message(id: '2', content: 'Message 2', senderId: 'user-2'),
    ];
    
    when(() => mockMessageRepository.getChannelHistory(channelId))
        .thenAnswer((_) async => mockMessages);
    
    // Act
    await chatProvider.switchChannel(channelId);
    
    // Assert
    expect(chatProvider.currentChannel, equals(channelId));
    verify(() => mockMessageRepository.getChannelHistory(channelId)).called(1);
  });
}
```

#### 3. Integration Tests
```dart
// Integration testing for complete user flows
class ChatFlowIntegrationTest {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('complete chat flow works end-to-end', (tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle();
    
    // Wait for Bluetooth initialization
    await tester.pump(Duration(seconds: 2));
    
    // Navigate to channel
    await tester.tap(find.text('#general'));
    await tester.pumpAndSettle();
    
    // Send a message
    await tester.enterText(find.byType(TextField), 'Hello, world!');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    
    // Verify message appears in chat
    expect(find.text('Hello, world!'), findsOneWidget);
    
    // Verify message is encrypted
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });
  
  testWidgets('Bluetooth connection flow works correctly', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Navigate to peer discovery
    await tester.tap(find.byIcon(Icons.bluetooth));
    await tester.pumpAndSettle();
    
    // Start scanning
    await tester.tap(find.text('Scan for Peers'));
    await tester.pump(Duration(seconds: 5));
    
    // Verify scanning indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Simulate peer discovery
    // (This would require mock Bluetooth devices in test environment)
  });
}
```

#### 4. Golden Tests for UI Consistency
```dart
// Golden tests for visual regression testing
class GoldenTests {
  testWidgets('MessageBubble golden test - own message', (tester) async {
    final message = Message(
      id: 'test-id',
      content: 'This is my message',
      senderId: 'current-user',
      timestamp: DateTime(2023, 1, 1, 12, 0),
      isEncrypted: true,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: MessageBubble(
            message: message,
            isOwn: true,
          ),
        ),
      ),
    );
    
    await expectLater(
      find.byType(MessageBubble),
      matchesGoldenFile('message_bubble_own.png'),
    );
  });
  
  testWidgets('ChatScreen golden test - dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: ChatScreen(),
      ),
    );
    
    await tester.pumpAndSettle();
    
    await expectLater(
      find.byType(ChatScreen),
      matchesGoldenFile('chat_screen_dark.png'),
    );
  });
}
```

#### 5. Performance Tests
```dart
// Performance testing for Flutter-specific concerns
class PerformanceTests {
  testWidgets('MessageList scrolling performance', (tester) async {
    // Generate large number of messages
    final messages = List.generate(1000, (index) => Message(
      id: 'msg-$index',
      content: 'Message $index',
      senderId: 'user-${index % 10}',
      timestamp: DateTime.now().subtract(Duration(minutes: index)),
    ));
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageList(messages: messages),
        ),
      ),
    );
    
    // Measure scroll performance
    final stopwatch = Stopwatch()..start();
    
    // Scroll to bottom
    await tester.fling(
      find.byType(ListView),
      Offset(0, -10000),
      1000,
    );
    await tester.pumpAndSettle();
    
    stopwatch.stop();
    
    // Assert reasonable performance
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
  });
  
  testWidgets('Provider rebuild performance', (tester) async {
    int buildCount = 0;
    
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ChatProvider(MockMessageRepository(), MockEncryptionService()),
        child: MaterialApp(
          home: Consumer<ChatProvider>(
            builder: (context, provider, child) {
              buildCount++;
              return Text('Build count: $buildCount');
            },
          ),
        ),
      ),
    );
    
    final provider = tester.element(find.byType(Consumer<ChatProvider>))
        .read<ChatProvider>();
    
    // Trigger multiple state changes
    for (int i = 0; i < 10; i++) {
      provider.notifyListeners();
      await tester.pump();
    }
    
    // Verify reasonable rebuild count
    expect(buildCount, lessThan(15)); // Allow some overhead
  });
}
```

#### 6. Bluetooth Testing
```dart
// Bluetooth-specific testing with mocks
class BluetoothTests {
  testWidgets('BluetoothProvider handles connection states correctly', (tester) async {
    final mockBluetoothService = MockBluetoothService();
    final stateController = StreamController<BluetoothAdapterState>();
    
    when(() => mockBluetoothService.adapterStateStream)
        .thenAnswer((_) => stateController.stream);
    when(() => mockBluetoothService.initialize())
        .thenAnswer((_) async => {});
    
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BluetoothProvider(mockBluetoothService),
        child: MaterialApp(
          home: Consumer<BluetoothProvider>(
            builder: (context, provider, child) {
              return Text('State: ${provider.adapterState}');
            },
          ),
        ),
      ),
    );
    
    // Test state transitions
    stateController.add(BluetoothAdapterState.on);
    await tester.pump();
    expect(find.text('State: BluetoothAdapterState.on'), findsOneWidget);
    
    stateController.add(BluetoothAdapterState.off);
    await tester.pump();
    expect(find.text('State: BluetoothAdapterState.off'), findsOneWidget);
  });
}
```

## Flutter Platform Integration Architecture

### Platform Channel Architecture

```dart
// Platform-specific implementations through method channels
class PlatformIntegration {
  static const MethodChannel _channel = MethodChannel('bitchat/platform');
  
  // iOS-specific integrations
  static Future<void> configureIOSBackground() async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('configureBackgroundProcessing', {
        'backgroundModes': ['bluetooth-central', 'bluetooth-peripheral'],
        'backgroundRefresh': true,
      });
    }
  }
  
  // Android-specific integrations
  static Future<void> configureAndroidForegroundService() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('startForegroundService', {
        'channelId': 'bitchat_service',
        'channelName': 'BitChat Background Service',
        'notificationTitle': 'BitChat is running',
        'notificationText': 'Maintaining mesh network connection',
      });
    }
  }
  
  // Cross-platform Bluetooth configuration
  static Future<BluetoothCapabilities> getBluetoothCapabilities() async {
    final result = await _channel.invokeMethod('getBluetoothCapabilities');
    return BluetoothCapabilities.fromMap(result);
  }
}

// Platform-specific widget adaptations
class PlatformAdaptiveWidget extends StatelessWidget {
  final Widget iosWidget;
  final Widget androidWidget;
  final Widget? fallbackWidget;
  
  const PlatformAdaptiveWidget({
    Key? key,
    required this.iosWidget,
    required this.androidWidget,
    this.fallbackWidget,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return iosWidget;
    } else if (Platform.isAndroid) {
      return androidWidget;
    } else {
      return fallbackWidget ?? androidWidget;
    }
  }
}
```

### Cross-Platform Considerations

#### iOS-Specific Flutter Integration
```dart
class IOSSpecificFeatures {
  // Core Bluetooth integration through flutter_blue_plus
  static Future<void> configureCoreBluetoothBackground() async {
    await FlutterBluePlus.setOptions(
      showPowerAlert: false,
      restoreIdentifier: 'BitChatRestore',
    );
  }
  
  // iOS-style navigation patterns
  static Widget buildIOSNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text('BitChat'),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Icon(CupertinoIcons.settings),
        onPressed: () => Navigator.pushNamed(context, '/settings'),
      ),
    );
  }
  
  // iOS-specific permission handling
  static Future<bool> requestIOSPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ];
    
    final results = await permissions.request();
    return results.values.every((status) => status.isGranted);
  }
  
  // iOS background app refresh handling
  static Future<void> handleBackgroundAppRefresh() async {
    WidgetsBinding.instance.addObserver(IOSLifecycleObserver());
  }
}

class IOSLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // Prepare for background
        BluetoothManager.instance.enterBackgroundMode();
        break;
      case AppLifecycleState.resumed:
        // Resume from background
        BluetoothManager.instance.exitBackgroundMode();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        BluetoothManager.instance.cleanup();
        break;
      default:
        break;
    }
  }
}
```

#### Android-Specific Flutter Integration
```dart
class AndroidSpecificFeatures {
  // Android Bluetooth adapter management
  static Future<void> configureBluetoothAdapter() async {
    await MethodChannel('bitchat/android_bluetooth')
        .invokeMethod('configureAdapter', {
      'scanMode': 'SCAN_MODE_LOW_LATENCY',
      'advertisingMode': 'ADVERTISE_MODE_BALANCED',
      'txPowerLevel': 'ADVERTISE_TX_POWER_MEDIUM',
    });
  }
  
  // Android-style Material Design components
  static Widget buildMaterialAppBar(BuildContext context) {
    return AppBar(
      title: Text('BitChat'),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
      elevation: 0,
    );
  }
  
  // Android permission request flows
  static Future<bool> requestAndroidPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];
    
    // Request permissions with rationale
    for (final permission in permissions) {
      if (await permission.isDenied) {
        final status = await permission.request();
        if (status.isDenied) {
          await _showPermissionRationale(permission);
          return false;
        }
      }
    }
    
    return true;
  }
  
  // Android foreground service integration
  static Future<void> startForegroundService() async {
    await MethodChannel('bitchat/foreground_service')
        .invokeMethod('start', {
      'channelId': 'bitchat_service',
      'channelName': 'BitChat Service',
      'notificationId': 1,
      'notificationTitle': 'BitChat is running',
      'notificationContent': 'Maintaining mesh network connection',
      'notificationIcon': 'ic_notification',
    });
  }
  
  // Battery optimization whitelist
  static Future<void> requestBatteryOptimizationExemption() async {
    await MethodChannel('bitchat/battery_optimization')
        .invokeMethod('requestExemption');
  }
}
```

### Desktop Platform Support

```dart
// Desktop-specific adaptations
class DesktopFeatures {
  static bool get isDesktop => 
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  
  // Desktop window management
  static Future<void> configureDesktopWindow() async {
    if (isDesktop) {
      await windowManager.ensureInitialized();
      await windowManager.setTitle('BitChat');
      await windowManager.setMinimumSize(Size(800, 600));
      await windowManager.center();
    }
  }
  
  // Desktop-specific UI layout
  static Widget buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar for channels
        SizedBox(
          width: 250,
          child: ChannelSidebar(),
        ),
        VerticalDivider(width: 1),
        // Main chat area
        Expanded(
          child: ChatArea(),
        ),
        // Optional members panel
        if (MediaQuery.of(context).size.width > 1200) ...[
          VerticalDivider(width: 1),
          SizedBox(
            width: 200,
            child: MembersPanel(),
          ),
        ],
      ],
    );
  }
  
  // Desktop keyboard shortcuts
  static Map<LogicalKeySet, Intent> get desktopShortcuts => {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
        NewChannelIntent(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyT):
        NewTabIntent(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyW):
        CloseTabIntent(),
    LogicalKeySet(LogicalKeyboardKey.escape):
        EscapeIntent(),
  };
}
```

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

## Flutter Lifecycle Management

### Application Lifecycle Integration

```dart
// Application lifecycle management for BitChat
class BitChatLifecycleManager extends WidgetsBindingObserver {
  static final BitChatLifecycleManager _instance = BitChatLifecycleManager._internal();
  factory BitChatLifecycleManager() => _instance;
  BitChatLifecycleManager._internal();
  
  bool _isInitialized = false;
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    
    // Initialize core services
    await _initializeCoreServices();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _currentState = state;
    
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
    }
  }
  
  void _onAppResumed() {
    // Resume Bluetooth operations
    BluetoothManager.instance.resumeOperations();
    
    // Resume mesh network synchronization
    MeshNetworkService.instance.resumeSync();
    
    // Update UI refresh rates
    UIManager.instance.setRefreshRate(RefreshRate.normal);
    
    // Process queued messages
    MessageProcessor.instance.processQueuedMessages();
  }
  
  void _onAppPaused() {
    // Reduce Bluetooth scanning frequency
    BluetoothManager.instance.enterPowerSaveMode();
    
    // Pause non-essential operations
    MeshNetworkService.instance.pauseNonEssentialOperations();
    
    // Reduce UI refresh rates
    UIManager.instance.setRefreshRate(RefreshRate.reduced);
    
    // Save current state
    StateManager.instance.saveCurrentState();
  }
  
  void _onAppInactive() {
    // Prepare for potential backgrounding
    BluetoothManager.instance.prepareForBackground();
  }
  
  void _onAppDetached() {
    // Cleanup resources
    cleanup();
  }
  
  Future<void> cleanup() async {
    if (!_isInitialized) return;
    
    WidgetsBinding.instance.removeObserver(this);
    
    // Cleanup services
    await BluetoothManager.instance.cleanup();
    await MeshNetworkService.instance.cleanup();
    await MessageProcessor.instance.cleanup();
    
    _isInitialized = false;
  }
  
  Future<void> _initializeCoreServices() async {
    // Initialize services in dependency order
    await BluetoothManager.instance.initialize();
    await EncryptionService.instance.initialize();
    await MeshNetworkService.instance.initialize();
    await MessageProcessor.instance.initialize();
  }
}
```

### Widget Lifecycle Optimization

```dart
// Base class for lifecycle-aware widgets
abstract class LifecycleAwareWidget extends StatefulWidget {
  const LifecycleAwareWidget({Key? key}) : super(key: key);
}

abstract class LifecycleAwareWidgetState<T extends LifecycleAwareWidget> 
    extends State<T> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  
  bool _isActive = true;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onInitState();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onDispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isActive) {
          _isActive = true;
          onResume();
        }
        break;
      case AppLifecycleState.paused:
        if (_isActive) {
          _isActive = false;
          onPause();
        }
        break;
      default:
        break;
    }
  }
  
  // Override these methods in subclasses
  void onInitState() {}
  void onDispose() {}
  void onResume() {}
  void onPause() {}
}

// Example usage in ChatScreen
class ChatScreen extends LifecycleAwareWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends LifecycleAwareWidgetState<ChatScreen> {
  late StreamSubscription<Message> _messageSubscription;
  
  @override
  void onInitState() {
    // Subscribe to message stream
    _messageSubscription = MessageService.instance.messageStream.listen(
      _onNewMessage,
    );
  }
  
  @override
  void onDispose() {
    _messageSubscription.cancel();
  }
  
  @override
  void onResume() {
    // Resume real-time updates
    MessageService.instance.resumeRealTimeUpdates();
  }
  
  @override
  void onPause() {
    // Pause real-time updates to save battery
    MessageService.instance.pauseRealTimeUpdates();
  }
  
  void _onNewMessage(Message message) {
    if (mounted && _isActive) {
      // Update UI only if widget is active
      setState(() {
        // Update message list
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      // Widget implementation
    );
  }
}
```

### Memory Management Integration

```dart
// Memory-aware widget management
class MemoryAwareWidgetManager {
  static const int MAX_CACHED_WIDGETS = 50;
  static const Duration WIDGET_CACHE_DURATION = Duration(minutes: 5);
  
  final Map<String, CachedWidget> _widgetCache = {};
  final Map<String, DateTime> _lastAccess = {};
  
  Widget getCachedWidget(String key, Widget Function() builder) {
    final cached = _widgetCache[key];
    final now = DateTime.now();
    
    if (cached != null && 
        now.difference(_lastAccess[key]!) < WIDGET_CACHE_DURATION) {
      _lastAccess[key] = now;
      return cached.widget;
    }
    
    // Build new widget
    final widget = builder();
    _widgetCache[key] = CachedWidget(widget: widget, createdAt: now);
    _lastAccess[key] = now;
    
    // Cleanup old widgets
    _cleanupOldWidgets();
    
    return widget;
  }
  
  void _cleanupOldWidgets() {
    if (_widgetCache.length <= MAX_CACHED_WIDGETS) return;
    
    final now = DateTime.now();
    final expiredKeys = _lastAccess.entries
        .where((entry) => now.difference(entry.value) > WIDGET_CACHE_DURATION)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _widgetCache.remove(key);
      _lastAccess.remove(key);
    }
  }
}

class CachedWidget {
  final Widget widget;
  final DateTime createdAt;
  
  CachedWidget({required this.widget, required this.createdAt});
}
```

This comprehensive Flutter architecture provides a robust foundation for building a secure, scalable, and maintainable BitChat Flutter application while maintaining compatibility with existing iOS and Android implementations. The architecture emphasizes Flutter-specific patterns, performance optimization, and proper lifecycle management to ensure optimal user experience across all supported platforms.