# BitChat Flutter - Main Chat Interface

## Chat Screen Layout

```
┌─────────────────────────────────────────────────────────────┐
│ ◀ #general                                    👥 ⚙️ ⋮      │ ← App Bar
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Alice (2 min ago)                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Hey everyone! The mesh network is working great    │   │ ← Message Bubble
│  │ today. Anyone want to test file sharing?           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                                          Bob (1 min ago)   │
│   ┌─────────────────────────────────────────────────────┐  │
│   │ Sure! I'm connected through 3 hops right now.      │  │ ← Own Message
│   │ Signal strength is good.                            │  │
│   └─────────────────────────────────────────────────────┘  │
│                                                             │
│  Carol (30 sec ago)                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ /who                                                │   │ ← Command Message
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  System (now)                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Online users: Alice, Bob, Carol, Dave (4 total)    │   │ ← System Message
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ 📎 Type a message...                              🔒 📤   │ ← Input Bar
└─────────────────────────────────────────────────────────────┘
```

## Component Specifications

### App Bar
- **Height**: 56dp (Material Design standard)
- **Background**: Primary color with elevation
- **Elements**:
  - Back button (when in channel)
  - Channel/user name with online indicator
  - Peer count badge
  - Settings button
  - Overflow menu

### Message List
- **Layout**: Scrollable list with reverse chronological order
- **Message Types**:
  - **Incoming Messages**: Left-aligned, light background
  - **Outgoing Messages**: Right-aligned, primary color background
  - **System Messages**: Center-aligned, muted background
  - **Command Messages**: Monospace font, distinct styling

### Message Bubble Design
```
┌─────────────────────────────────────────────────────────────┐
│ Sender Name                                    Timestamp    │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Message content with proper text wrapping and          │ │
│ │ support for multiple lines. Emojis and links are       │ │
│ │ properly rendered with appropriate styling.             │ │
│ └─────────────────────────────────────────────────────────┘ │
│ 🔒 Encrypted • 📶 2 hops • ✓ Delivered                    │
└─────────────────────────────────────────────────────────────┘
```

### Input Bar
- **Height**: 56dp minimum, expandable for multiline
- **Elements**:
  - Attachment button (file sharing)
  - Text input field with hint text
  - Encryption status indicator
  - Send button (enabled when text present)

## Material Design 3 Theming

### Color Scheme
```dart
ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFF2196F3), // BitChat Blue
  brightness: Brightness.light,
);

ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFF2196F3),
  brightness: Brightness.dark,
);
```

### Typography
```dart
TextTheme textTheme = TextTheme(
  headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
  titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
  titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
);
```

## Responsive Design

### Phone Layout (< 600dp width)
- Single column layout
- Full-width message bubbles
- Collapsed app bar on scroll
- Bottom navigation for main sections

### Tablet Layout (600dp - 840dp width)
- Two-column layout with channel list sidebar
- Wider message bubbles with max width
- Persistent app bar
- Side navigation panel

### Desktop Layout (> 840dp width)
- Three-column layout (channels, chat, details)
- Fixed maximum width for message bubbles
- Persistent navigation and details panels
- Keyboard shortcuts support

## Accessibility Features

### Screen Reader Support
```dart
Semantics(
  label: 'Message from ${message.sender}',
  hint: 'Double tap to copy message',
  child: MessageBubble(message: message),
)
```

### High Contrast Mode
- Increased contrast ratios for text and backgrounds
- Bold borders for message bubbles
- Enhanced focus indicators
- Alternative color schemes for color-blind users

### Font Scaling
- Support for system font size preferences
- Scalable UI elements that adapt to text size
- Minimum touch target sizes (44dp)
- Proper text overflow handling

## Animation Specifications

### Message Animations
```dart
// New message slide-in animation
AnimatedSlide(
  offset: Offset(0, isNew ? 1.0 : 0.0),
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOutCubic,
  child: MessageBubble(message: message),
)
```

### Typing Indicators
```
┌─────────────────────────────────────────────────────────────┐
│  Alice is typing...                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ● ● ●  (animated dots)                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Connection Status Animations
- Pulse animation for "connecting" state
- Smooth color transitions for connection quality
- Subtle shake animation for connection errors

## State Management

### Chat Screen State
```dart
class ChatScreenState {
  List<Message> messages;
  bool isLoading;
  bool isConnected;
  String currentChannel;
  List<String> onlineUsers;
  bool isTyping;
  String typingUser;
  ConnectionQuality connectionQuality;
}
```

### Message State
```dart
enum MessageStatus {
  sending,
  sent,
  delivered,
  failed,
}

class Message {
  String id;
  String content;
  String sender;
  DateTime timestamp;
  MessageStatus status;
  bool isEncrypted;
  int hopCount;
  MessageType type; // text, command, system, file
}
```

## Error States

### Connection Error
```
┌─────────────────────────────────────────────────────────────┐
│                    ⚠️ Connection Lost                       │
│                                                             │
│           Unable to connect to mesh network                 │
│                                                             │
│                    [Retry Connection]                       │
└─────────────────────────────────────────────────────────────┘
```

### Empty State
```
┌─────────────────────────────────────────────────────────────┐
│                       💬                                   │
│                                                             │
│                 No messages yet                             │
│            Start a conversation by typing                   │
│                   a message below                           │
└─────────────────────────────────────────────────────────────┘
```

## Performance Optimizations

### Message List Optimization
- Virtual scrolling for large message lists
- Message caching and pagination
- Lazy loading of message history
- Efficient diff algorithms for updates

### Image and Media Handling
- Progressive image loading
- Thumbnail generation for large images
- Efficient memory management for media
- Background download for attachments

This chat interface design prioritizes usability, accessibility, and performance while maintaining the security-focused nature of BitChat's decentralized messaging system.