# UI Requirements - BitChat Flutter

## Overview

BitChat Flutter implements a terminal-inspired IRC-style interface with modern Material Design principles. The UI must maintain visual consistency with the original iOS and Android versions while providing a native Flutter experience.

## Design Philosophy

### Core Principles
- **Terminal-Inspired**: IRC/terminal-style chat interface
- **Minimalist**: Clean, distraction-free design
- **Accessible**: High contrast, readable fonts, proper touch targets
- **Responsive**: Adaptive layouts for different screen sizes
- **Battery Conscious**: Dark theme by default to save power

### Visual Identity
- **Typography**: Monospace fonts for chat content, sans-serif for UI elements
- **Color Scheme**: High contrast dark theme with optional light theme
- **Iconography**: Minimal, consistent icon set
- **Spacing**: Generous padding for touch-friendly interface

## Theme System

### Dark Theme (Primary)
```
Background Colors:
- Primary Background: #0D1117 (GitHub dark)
- Secondary Background: #161B22
- Card Background: #21262D
- Input Background: #30363D

Text Colors:
- Primary Text: #F0F6FC
- Secondary Text: #8B949E
- Accent Text: #58A6FF
- Success Text: #3FB950
- Warning Text: #D29922
- Error Text: #F85149

Accent Colors:
- Primary Accent: #58A6FF (blue)
- Secondary Accent: #A5A5A5 (gray)
- Active Indicator: #3FB950 (green)
- Offline Indicator: #F85149 (red)
```

### Light Theme (Secondary)
```
Background Colors:
- Primary Background: #FFFFFF
- Secondary Background: #F6F8FA
- Card Background: #FFFFFF
- Input Background: #F6F8FA

Text Colors:
- Primary Text: #24292F
- Secondary Text: #656D76
- Accent Text: #0969DA
- Success Text: #1A7F37
- Warning Text: #9A6700
- Error Text: #CF222E

Accent Colors:
- Primary Accent: #0969DA (blue)
- Secondary Accent: #656D76 (gray)
- Active Indicator: #1A7F37 (green)
- Offline Indicator: #CF222E (red)
```

## Screen Layouts

### 1. Main Chat Interface

#### Layout Structure
```
┌─────────────────────────────────┐
│ [Status Bar] [Signal] [Battery] │ <- App Bar
├─────────────────────────────────┤
│ #general                        │ <- Channel Header
│ 👥 5 peers • 🔒 Encrypted      │
├─────────────────────────────────┤
│ [12:34] alice: Hello everyone!  │ <- Message List
│ [12:35] bob: Hey alice!         │    (Scrollable)
│ [12:36] * charlie joined        │
│ [12:37] You: How's everyone?    │
│ ...                             │
│ ...                             │
├─────────────────────────────────┤
│ [/join #tech] [📎] [Send]       │ <- Input Bar
└─────────────────────────────────┘
```

#### Components
- **App Bar**: Connection status, mesh network indicator, settings
- **Channel Header**: Current channel, peer count, encryption status
- **Message List**: Scrollable chat history with timestamps
- **Input Bar**: Text input with command support and send button

### 2. Channel List / Sidebar

#### Layout Structure
```
┌─────────────────────────────────┐
│ Channels                        │ <- Header
├─────────────────────────────────┤
│ # general (5)          [🔒]     │ <- Active Channel
│ # tech (2)             [🔒]     │
│ # random (8)           [🔒]     │
├─────────────────────────────────┤
│ Direct Messages                 │ <- Section Header
├─────────────────────────────────┤
│ @ alice                [🟢]     │ <- Online Status
│ @ bob                  [🟡]     │ <- Away Status
│ @ charlie              [🔴]     │ <- Offline Status
├─────────────────────────────────┤
│ [+ Join Channel]                │ <- Action Button
└─────────────────────────────────┘
```

#### Features
- **Channel List**: Shows all joined channels with member counts
- **Direct Messages**: Private message conversations
- **Status Indicators**: Online/away/offline status for peers
- **Join Channel**: Quick channel joining interface

### 3. Settings Screen

#### Layout Structure
```
┌─────────────────────────────────┐
│ ← Settings                      │ <- Header
├─────────────────────────────────┤
│ Profile                         │ <- Section
│ Username: alice                 │
│ [Change Username]               │
├─────────────────────────────────┤
│ Privacy & Security              │
│ [🔒] Auto-encrypt messages      │
│ [🔒] Require channel passwords  │
│ [⚠️] Emergency wipe (tap 3x)    │
├─────────────────────────────────┤
│ Network                         │
│ [📡] Bluetooth mesh enabled     │
│ [🔋] Battery optimization       │
│ TTL: 7 hops                     │
├─────────────────────────────────┤
│ Appearance                      │
│ Theme: Dark                     │
│ Font size: Medium               │
│ [🌙] Follow system theme        │
└─────────────────────────────────┘
```

### 4. Peer Discovery Screen

#### Layout Structure
```
┌─────────────────────────────────┐
│ ← Nearby Peers                  │ <- Header
├─────────────────────────────────┤
│ Scanning for peers...           │ <- Status
│ [🔄] Scanning                   │
├─────────────────────────────────┤
│ bob                    [🟢]     │ <- Discovered Peer
│ Signal: ████░ -45dBm            │
│ [Connect]                       │
├─────────────────────────────────┤
│ charlie                [🟡]     │
│ Signal: ███░░ -67dBm            │
│ [Connect]                       │
├─────────────────────────────────┤
│ alice                  [🔴]     │
│ Signal: ██░░░ -82dBm            │
│ [Connect]                       │
└─────────────────────────────────┘
```

## UI Components

### 1. Message Bubble
```dart
// Terminal-style message display
Container(
  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  child: RichText(
    text: TextSpan(
      style: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: 14,
        color: Colors.white87,
      ),
      children: [
        TextSpan(
          text: '[12:34] ',
          style: TextStyle(color: Colors.grey),
        ),
        TextSpan(
          text: 'alice: ',
          style: TextStyle(color: Colors.blue),
        ),
        TextSpan(
          text: 'Hello everyone!',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  ),
)
```

### 2. Channel Header
```dart
// Channel information display
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor,
    border: Border(
      bottom: BorderSide(color: Colors.grey.shade800),
    ),
  ),
  child: Row(
    children: [
      Text(
        '#general',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      Spacer(),
      Icon(Icons.people, size: 16),
      Text(' 5 peers'),
      SizedBox(width: 8),
      Icon(Icons.lock, size: 16),
      Text(' Encrypted'),
    ],
  ),
)
```

### 3. Status Indicator
```dart
// Connection status indicator
Container(
  width: 8,
  height: 8,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: isOnline ? Colors.green : Colors.red,
  ),
)
```

### 4. Command Input
```dart
// IRC-style command input
TextField(
  controller: _messageController,
  decoration: InputDecoration(
    hintText: 'Type a message or /help for commands',
    prefixIcon: Icon(Icons.terminal),
    suffixIcon: IconButton(
      icon: Icon(Icons.send),
      onPressed: _sendMessage,
    ),
    border: OutlineInputBorder(),
  ),
  onSubmitted: _sendMessage,
)
```

## Responsive Design

### Breakpoints
- **Mobile**: < 600dp (single pane)
- **Tablet**: 600dp - 900dp (dual pane option)
- **Desktop**: > 900dp (dual pane default)

### Layout Adaptations

#### Mobile (< 600dp)
- Single pane layout
- Bottom navigation for channels
- Swipe gestures for navigation
- Full-screen chat interface

#### Tablet (600dp - 900dp)
- Optional dual pane layout
- Slide-out channel drawer
- Larger touch targets
- Optimized for landscape

#### Desktop (> 900dp)
- Dual pane layout by default
- Keyboard shortcuts
- Resizable panes
- Context menus

## Accessibility

### Requirements
- **Screen Reader**: Full VoiceOver/TalkBack support
- **High Contrast**: WCAG AA compliant color ratios
- **Touch Targets**: Minimum 44dp touch targets
- **Keyboard Navigation**: Full keyboard support
- **Text Scaling**: Dynamic type support

### Implementation
```dart
// Semantic labels for screen readers
Semantics(
  label: 'Message from alice at 12:34',
  child: MessageBubble(...),
)

// High contrast support
Theme(
  data: ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    // High contrast colors
  ),
)

// Minimum touch targets
MaterialButton(
  minWidth: 44,
  height: 44,
  child: Icon(Icons.send),
)
```

## Animations

### Subtle Animations
- **Message Arrival**: Gentle fade-in animation
- **Channel Switch**: Smooth slide transition
- **Status Changes**: Color transition for status indicators
- **Loading States**: Pulsing animation for scanning

### Performance Considerations
- **60fps Target**: All animations must maintain 60fps
- **Battery Optimization**: Reduced animations in power saving mode
- **Motion Sensitivity**: Respect system motion preferences

## Platform-Specific Considerations

### iOS
- **Safe Area**: Proper safe area handling
- **Navigation**: iOS-style navigation patterns
- **Haptic Feedback**: Appropriate haptic feedback
- **Dynamic Type**: Support for iOS Dynamic Type

### Android
- **Material Design**: Material Design 3 components
- **Navigation**: Android navigation patterns
- **Adaptive Icons**: Adaptive icon support
- **Dark Theme**: Follow system dark theme

## Error States

### No Internet Connection
```
┌─────────────────────────────────┐
│ ⚠️ No mesh network detected     │
│                                 │
│ BitChat requires nearby peers   │
│ to establish a mesh network.    │
│                                 │
│ [🔄 Scan for peers]             │
└─────────────────────────────────┘
```

### Bluetooth Disabled
```
┌─────────────────────────────────┐
│ 📡 Bluetooth Required           │
│                                 │
│ Please enable Bluetooth to      │
│ connect to the mesh network.    │
│                                 │
│ [⚙️ Open Settings]              │
└─────────────────────────────────┘
```

### Message Encryption Failed
```
┌─────────────────────────────────┐
│ 🔒 Encryption Error 🔒         │
│                                 │
│ Unable to encrypt message.      │
│ Check your security settings.   │
│                                 │
│ [🔄 Retry] [⚙️ Settings]       │
└─────────────────────────────────┘
```

## Testing Requirements

### UI Testing
- **Widget Tests**: All custom widgets
- **Integration Tests**: Complete user flows
- **Golden Tests**: Visual regression testing
- **Accessibility Tests**: Screen reader testing

### Device Testing
- **Multiple Screen Sizes**: Phone, tablet, foldable
- **Different Resolutions**: Various DPI settings
- **Platform Versions**: iOS 16+, Android 8+
- **Accessibility Features**: VoiceOver, TalkBack, high contrast

## Implementation Notes

### State Management
- Use Provider/Riverpod for UI state
- Separate business logic from UI logic
- Reactive UI updates for real-time messaging

### Performance Optimization
- Lazy loading for long message histories
- Efficient list rendering with ListView.builder
- Image caching for profile pictures
- Memory management for large channels

### Security UI
- Clear visual indicators for encryption status
- Secure input handling for passwords
- Emergency wipe confirmation dialog
- Security warning displays

## Future Enhancements

### Planned Features
- **Message Reactions**: Emoji reactions to messages
- **File Sharing**: Basic file transfer capabilities
- **Voice Messages**: Short voice message support
- **Custom Themes**: User-customizable color schemes
- **Message Search**: Full-text search across channels
- **Notification Settings**: Fine-grained notification control

### Advanced Features
- **Message Threading**: Reply-to-message functionality
- **Channel Moderation**: Admin controls for channels
- **User Profiles**: Extended user information
- **Message Formatting**: Basic markdown support
- **Backup/Restore**: Chat history backup
- **Multi-language**: Internationalization support

---

This UI requirements document provides the foundation for implementing a consistent, accessible, and user-friendly interface for BitChat Flutter while maintaining the terminal-inspired aesthetic and ensuring compatibility across platforms.