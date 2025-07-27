# UI Requirements - BitChat Flutter

## Overview

BitChat Flutter implements a terminal-inspired IRC-style interface with modern Material Design principles. The UI must maintain visual consistency with the original iOS and Android versions while providing a native Flutter experience.

### UI Mockups and Design Specifications

For detailed UI mockups and design specifications, see the [UI Mockups](../assets/ui_mockups/) directory:

- **[Main Chat Interface](../assets/ui_mockups/main_chat_interface.md)**: Primary chat screen layout and message display
- **[Channel List](../assets/ui_mockups/channel_list.md)**: Channel navigation and direct message interface
- **[Settings Screen](../assets/ui_mockups/settings_screen.md)**: Comprehensive settings and configuration interface
- **[Peer Discovery](../assets/ui_mockups/peer_discovery.md)**: Mesh network visualization and peer management

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

## Flutter Theme System

### Material Design 3 Integration

```dart
// Custom theme implementation for BitChat
class BitChatTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF58A6FF),
      onPrimary: Color(0xFF0D1117),
      secondary: Color(0xFFA5A5A5),
      onSecondary: Color(0xFF0D1117),
      surface: Color(0xFF21262D),
      onSurface: Color(0xFFF0F6FC),
      background: Color(0xFF0D1117),
      onBackground: Color(0xFFF0F6FC),
      error: Color(0xFFF85149),
      onError: Color(0xFF0D1117),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF161B22),
      foregroundColor: Color(0xFFF0F6FC),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF21262D),
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF30363D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Color(0xFF8B949E)),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'RobotoMono',
        color: Color(0xFFF0F6FC),
        fontSize: 14,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'RobotoMono',
        color: Color(0xFF8B949E),
        fontSize: 12,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFFF0F6FC),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF8B949E),
      size: 20,
    ),
  );
  
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0969DA),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF656D76),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF24292F),
      background: Color(0xFFFFFFFF),
      onBackground: Color(0xFF24292F),
      error: Color(0xCF222E),
      onError: Color(0xFFFFFFFF),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF6F8FA),
      foregroundColor: Color(0xFF24292F),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFFFFFFF),
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF6F8FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Color(0xFF656D76)),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'RobotoMono',
        color: Color(0xFF24292F),
        fontSize: 14,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'RobotoMono',
        color: Color(0xFF656D76),
        fontSize: 12,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFF24292F),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF656D76),
      size: 20,
    ),
  );
}

// Custom colors for BitChat-specific elements
class BitChatColors {
  // Status colors
  static const Color onlineGreen = Color(0xFF3FB950);
  static const Color awayYellow = Color(0xFFD29922);
  static const Color offlineRed = Color(0xFFF85149);
  static const Color encryptedBlue = Color(0xFF58A6FF);
  
  // Message type colors
  static const Color systemMessage = Color(0xFF8B949E);
  static const Color privateMessage = Color(0xFF58A6FF);
  static const Color channelMessage = Color(0xFFF0F6FC);
  
  // Signal strength colors
  static const Color signalStrong = Color(0xFF3FB950);
  static const Color signalMedium = Color(0xFFD29922);
  static const Color signalWeak = Color(0xFFF85149);
}
```

### Responsive Theme Configuration

```dart
// Responsive theme that adapts to screen size and platform
class ResponsiveTheme extends StatelessWidget {
  final Widget child;
  
  const ResponsiveTheme({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine screen size category
        final screenSize = _getScreenSize(constraints);
        
        // Get base theme
        final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
        final baseTheme = isDark ? BitChatTheme.darkTheme : BitChatTheme.lightTheme;
        
        // Apply responsive modifications
        final responsiveTheme = _applyResponsiveModifications(baseTheme, screenSize);
        
        return Theme(
          data: responsiveTheme,
          child: child,
        );
      },
    );
  }
  
  ScreenSize _getScreenSize(BoxConstraints constraints) {
    if (constraints.maxWidth < 600) {
      return ScreenSize.mobile;
    } else if (constraints.maxWidth < 900) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }
  
  ThemeData _applyResponsiveModifications(ThemeData baseTheme, ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return baseTheme.copyWith(
          textTheme: baseTheme.textTheme.copyWith(
            bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: 14),
            bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          iconTheme: baseTheme.iconTheme.copyWith(size: 20),
        );
      case ScreenSize.tablet:
        return baseTheme.copyWith(
          textTheme: baseTheme.textTheme.copyWith(
            bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: 16),
            bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
          iconTheme: baseTheme.iconTheme.copyWith(size: 22),
        );
      case ScreenSize.desktop:
        return baseTheme.copyWith(
          textTheme: baseTheme.textTheme.copyWith(
            bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: 16),
            bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
          iconTheme: baseTheme.iconTheme.copyWith(size: 24),
        );
    }
  }
}

enum ScreenSize { mobile, tablet, desktop }
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

## Flutter UI Components

### 1. Message Bubble Widget

```dart
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwn;
  final bool showTimestamp;
  final bool showSender;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const MessageBubble({
    Key? key,
    required this.message,
    required this.isOwn,
    this.showTimestamp = true,
    this.showSender = true,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOwn && showSender) _buildAvatar(context),
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOwn 
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: message.isEncrypted 
                    ? Border.all(color: BitChatColors.encryptedBlue, width: 1)
                    : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isOwn && showSender) _buildSenderName(context),
                    _buildMessageContent(context),
                    if (showTimestamp) _buildTimestamp(context),
                    if (message.isEncrypted) _buildEncryptionIndicator(context),
                  ],
                ),
              ),
            ),
          ),
          if (isOwn) _buildDeliveryStatus(context),
        ],
      ),
    );
  }
  
  Widget _buildAvatar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8, top: 4),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Text(
          message.senderName.isNotEmpty 
            ? message.senderName[0].toUpperCase()
            : '?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSenderName(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text(
        message.senderName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
  
  Widget _buildMessageContent(BuildContext context) {
    return SelectableText(
      message.content,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontFamily: 'RobotoMono',
      ),
    );
  }
  
  Widget _buildTimestamp(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Text(
        _formatTimestamp(message.timestamp),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 10,
        ),
      ),
    );
  }
  
  Widget _buildEncryptionIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock,
            size: 12,
            color: BitChatColors.encryptedBlue,
          ),
          SizedBox(width: 4),
          Text(
            'Encrypted',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BitChatColors.encryptedBlue,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeliveryStatus(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (message.deliveryStatus) {
      case DeliveryStatus.sending:
        icon = Icons.schedule;
        color = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
        break;
      case DeliveryStatus.sent:
        icon = Icons.check;
        color = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
        break;
      case DeliveryStatus.delivered:
        icon = Icons.done_all;
        color = BitChatColors.onlineGreen;
        break;
      case DeliveryStatus.failed:
        icon = Icons.error_outline;
        color = BitChatColors.offlineRed;
        break;
    }
    
    return Container(
      margin: EdgeInsets.only(left: 8, top: 4),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
```

### 2. Channel Header Widget

```dart
class ChannelHeader extends StatelessWidget {
  final Channel channel;
  final int peerCount;
  final bool isEncrypted;
  final VoidCallback? onTap;
  
  const ChannelHeader({
    Key? key,
    required this.channel,
    required this.peerCount,
    required this.isEncrypted,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  channel.isPrivate ? Icons.lock : Icons.tag,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    channel.isPrivate ? channel.name : '#${channel.name}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildChannelActions(context),
              ],
            ),
            if (channel.topic.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                channel.topic,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 8),
            _buildChannelStats(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChannelActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.info_outline),
          iconSize: 20,
          onPressed: () => _showChannelInfo(context),
          tooltip: 'Channel Info',
        ),
        IconButton(
          icon: Icon(Icons.more_vert),
          iconSize: 20,
          onPressed: () => _showChannelMenu(context),
          tooltip: 'Channel Menu',
        ),
      ],
    );
  }
  
  Widget _buildChannelStats(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(Icons.people, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        SizedBox(width: 4),
        Text(
          '$peerCount peer${peerCount != 1 ? 's' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        if (isEncrypted) ...[
          SizedBox(width: 16),
          Icon(Icons.lock, size: 16, color: BitChatColors.encryptedBlue),
          SizedBox(width: 4),
          Text(
            'Encrypted',
            style: theme.textTheme.bodySmall?.copyWith(
              color: BitChatColors.encryptedBlue,
            ),
          ),
        ],
        Spacer(),
        _buildConnectionStatus(context),
      ],
    );
  }
  
  Widget _buildConnectionStatus(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, child) {
        final connectedDevices = bluetoothProvider.connectedDevices.length;
        final isScanning = bluetoothProvider.isScanning;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isScanning)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            else
              Icon(
                connectedDevices > 0 ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                size: 16,
                color: connectedDevices > 0 
                  ? BitChatColors.onlineGreen 
                  : BitChatColors.offlineRed,
              ),
            SizedBox(width: 4),
            Text(
              isScanning ? 'Scanning...' : '$connectedDevices connected',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showChannelInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChannelInfoDialog(channel: channel),
    );
  }
  
  void _showChannelMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ChannelMenuSheet(channel: channel),
    );
  }
}
```

### 3. Status Indicator Widget

```dart
class StatusIndicator extends StatelessWidget {
  final ConnectionStatus status;
  final double size;
  final bool showLabel;
  
  const StatusIndicator({
    Key? key,
    required this.status,
    this.size = 8,
    this.showLabel = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final label = _getStatusLabel();
    
    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(color),
          SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      );
    }
    
    return _buildIndicator(color);
  }
  
  Widget _buildIndicator(Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor() {
    switch (status) {
      case ConnectionStatus.online:
        return BitChatColors.onlineGreen;
      case ConnectionStatus.away:
        return BitChatColors.awayYellow;
      case ConnectionStatus.offline:
        return BitChatColors.offlineRed;
      case ConnectionStatus.connecting:
        return Colors.orange;
    }
  }
  
  String _getStatusLabel() {
    switch (status) {
      case ConnectionStatus.online:
        return 'Online';
      case ConnectionStatus.away:
        return 'Away';
      case ConnectionStatus.offline:
        return 'Offline';
      case ConnectionStatus.connecting:
        return 'Connecting';
    }
  }
}

enum ConnectionStatus { online, away, offline, connecting }
```

### 4. Command Input Widget

```dart
class CommandInput extends StatefulWidget {
  final Function(String) onMessageSent;
  final Function(String)? onCommandExecuted;
  final bool enabled;
  
  const CommandInput({
    Key? key,
    required this.onMessageSent,
    this.onCommandExecuted,
    this.enabled = true,
  }) : super(key: key);
  
  @override
  State<CommandInput> createState() => _CommandInputState();
}

class _CommandInputState extends State<CommandInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _commandHistory = [];
  int _historyIndex = -1;
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showSuggestions && _suggestions.isNotEmpty)
          _buildSuggestions(),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Type a message or /help for commands',
                      prefixIcon: Icon(
                        _controller.text.startsWith('/') 
                          ? Icons.terminal 
                          : Icons.chat_bubble_outline,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: _clearInput,
                          )
                        : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _onTextChanged,
                    onSubmitted: _onSubmitted,
                    onTap: () => _updateSuggestions(),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: widget.enabled && _controller.text.trim().isNotEmpty
                    ? () => _onSubmitted(_controller.text)
                    : null,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuggestions() {
    return Container(
      constraints: BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            dense: true,
            leading: Icon(
              suggestion.startsWith('/') ? Icons.terminal : Icons.person,
              size: 16,
            ),
            title: Text(
              suggestion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'RobotoMono',
              ),
            ),
            onTap: () => _selectSuggestion(suggestion),
          );
        },
      ),
    );
  }
  
  void _onTextChanged(String text) {
    setState(() {
      _updateSuggestions();
    });
  }
  
  void _updateSuggestions() {
    final text = _controller.text;
    final suggestions = <String>[];
    
    if (text.startsWith('/')) {
      // Command suggestions
      suggestions.addAll(_getCommandSuggestions(text));
    } else if (text.startsWith('@')) {
      // User suggestions
      suggestions.addAll(_getUserSuggestions(text));
    } else if (text.startsWith('#')) {
      // Channel suggestions
      suggestions.addAll(_getChannelSuggestions(text));
    }
    
    setState(() {
      _suggestions = suggestions.take(5).toList();
      _showSuggestions = suggestions.isNotEmpty;
    });
  }
  
  List<String> _getCommandSuggestions(String partial) {
    final commands = [
      '/help', '/join', '/leave', '/msg', '/who', '/channels',
      '/nick', '/create', '/topic', '/kick', '/ban', '/unban',
      '/peers', '/mesh', '/battery', '/encrypt', '/wipe',
    ];
    
    return commands
        .where((cmd) => cmd.toLowerCase().startsWith(partial.toLowerCase()))
        .toList();
  }
  
  List<String> _getUserSuggestions(String partial) {
    // Get user suggestions from current channel
    // This would be implemented based on your user management system
    return [];
  }
  
  List<String> _getChannelSuggestions(String partial) {
    // Get channel suggestions from available channels
    // This would be implemented based on your channel management system
    return [];
  }
  
  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    
    setState(() {
      _showSuggestions = false;
      _suggestions.clear();
    });
    
    _focusNode.requestFocus();
  }
  
  void _onSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    // Add to history
    _commandHistory.add(text);
    if (_commandHistory.length > 50) {
      _commandHistory.removeAt(0);
    }
    _historyIndex = _commandHistory.length;
    
    // Clear input
    _controller.clear();
    setState(() {
      _showSuggestions = false;
      _suggestions.clear();
    });
    
    // Process command or message
    if (text.startsWith('/')) {
      widget.onCommandExecuted?.call(text);
    } else {
      widget.onMessageSent(text);
    }
  }
  
  void _clearInput() {
    _controller.clear();
    setState(() {
      _showSuggestions = false;
      _suggestions.clear();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
```

## Flutter Responsive Design

### Responsive Layout System

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget tabletLayout;
  final Widget desktopLayout;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobileLayout,
    required this.tabletLayout,
    required this.desktopLayout,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobileLayout;
        } else if (constraints.maxWidth < 900) {
          return tabletLayout;
        } else {
          return desktopLayout;
        }
      },
    );
  }
}
```

### Breakpoint-Specific Layouts

#### Mobile Layout (< 600dp)

```dart
class MobileLayout extends StatefulWidget {
  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          ChatScreen(),
          ChannelListScreen(),
          PeerDiscoveryScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Channels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth_searching),
            label: 'Peers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
```

#### Tablet Layout (600dp - 900dp)

```dart
class TabletLayout extends StatefulWidget {
  @override
  State<TabletLayout> createState() => _TabletLayoutState();
}

class _TabletLayoutState extends State<TabletLayout> {
  bool _showSidebar = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (_showSidebar)
            Container(
              width: 300,
              child: ChannelSidebar(
                onChannelSelected: (channel) {
                  // Handle channel selection
                  setState(() => _showSidebar = false);
                },
              ),
            ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => setState(() => _showSidebar = !_showSidebar),
                  ),
                  title: Text('BitChat'),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.bluetooth_searching),
                      onPressed: () => _showPeerDiscovery(),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () => _showSettings(),
                    ),
                  ],
                ),
                Expanded(child: ChatScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showPeerDiscovery() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => PeerDiscoverySheet(
          scrollController: scrollController,
        ),
      ),
    );
  }
  
  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }
}
```

#### Desktop Layout (> 900dp)

```dart
class DesktopLayout extends StatefulWidget {
  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  double _sidebarWidth = 250;
  double _membersPanelWidth = 200;
  bool _showMembersPanel = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Channel sidebar
          Container(
            width: _sidebarWidth,
            child: Column(
              children: [
                Container(
                  height: 56,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'BitChat',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _showJoinChannelDialog,
                        tooltip: 'Join Channel',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ChannelSidebar(),
                ),
              ],
            ),
          ),
          
          // Resizable divider
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _sidebarWidth = (_sidebarWidth + details.delta.dx)
                      .clamp(200.0, 400.0);
                });
              },
              child: Container(
                width: 4,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          
          // Main chat area
          Expanded(
            child: ChatScreen(),
          ),
          
          // Members panel (optional)
          if (_showMembersPanel) ...[
            Container(
              width: 4,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            Container(
              width: _membersPanelWidth,
              child: MembersPanel(
                onClose: () => setState(() => _showMembersPanel = false),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  void _showJoinChannelDialog() {
    showDialog(
      context: context,
      builder: (context) => JoinChannelDialog(),
    );
  }
}
```

### Adaptive Widgets

```dart
// Widget that adapts its behavior based on screen size
class AdaptiveWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  
  const AdaptiveWidget({
    Key? key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        EdgeInsets padding;
        
        if (constraints.maxWidth < 600) {
          padding = mobilePadding ?? EdgeInsets.all(8);
        } else if (constraints.maxWidth < 900) {
          padding = tabletPadding ?? EdgeInsets.all(16);
        } else {
          padding = desktopPadding ?? EdgeInsets.all(24);
        }
        
        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

// Adaptive dialog that shows as bottom sheet on mobile
class AdaptiveDialog extends StatelessWidget {
  final Widget child;
  final String? title;
  
  const AdaptiveDialog({
    Key? key,
    required this.child,
    this.title,
  }) : super(key: key);
  
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
  }) {
    if (MediaQuery.of(context).size.width < 600) {
      // Show as bottom sheet on mobile
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        builder: (context) => AdaptiveDialog(
          title: title,
          child: child,
        ),
      );
    } else {
      // Show as dialog on tablet/desktop
      return showDialog<T>(
        context: context,
        builder: (context) => Dialog(
          child: AdaptiveDialog(
            title: title,
            child: child,
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (title != null) ...[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Divider(),
              ],
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Divider(),
            ],
            Flexible(child: child),
          ],
        ),
      );
    }
  }
}
```

## Flutter Accessibility Implementation

### Comprehensive Accessibility Support

```dart
class AccessibilityManager {
  static bool get isScreenReaderEnabled {
    return WidgetsBinding.instance.window.accessibilityFeatures.accessibleNavigation;
  }
  
  static bool get isHighContrastEnabled {
    return WidgetsBinding.instance.window.accessibilityFeatures.highContrast;
  }
  
  static bool get isReduceMotionEnabled {
    return WidgetsBinding.instance.window.accessibilityFeatures.disableAnimations;
  }
  
  static double get textScaleFactor {
    return WidgetsBinding.instance.window.textScaleFactor;
  }
}
```

### Accessible Message Components

```dart
class AccessibleMessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwn;
  
  const AccessibleMessageBubble({
    Key? key,
    required this.message,
    required this.isOwn,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final semanticLabel = _buildSemanticLabel();
    
    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: () => _handleMessageTap(context),
      onLongPress: () => _handleMessageLongPress(context),
      child: Container(
        constraints: BoxConstraints(minHeight: 44), // Minimum touch target
        child: MessageBubble(
          message: message,
          isOwn: isOwn,
        ),
      ),
    );
  }
  
  String _buildSemanticLabel() {
    final timeString = _formatTimeForScreenReader(message.timestamp);
    final senderString = isOwn ? 'You' : message.senderName;
    final encryptionString = message.isEncrypted ? ', encrypted message' : '';
    
    return 'Message from $senderString at $timeString: ${message.content}$encryptionString';
  }
  
  String _formatTimeForScreenReader(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
  
  void _handleMessageTap(BuildContext context) {
    // Announce message details for screen readers
    if (AccessibilityManager.isScreenReaderEnabled) {
      SemanticsService.announce(
        'Selected message: ${message.content}',
        TextDirection.ltr,
      );
    }
  }
  
  void _handleMessageLongPress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MessageActionsSheet(message: message),
    );
  }
}
```

### High Contrast Theme Support

```dart
class HighContrastTheme {
  static ThemeData get darkHighContrast => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFF000000),
      surface: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      background: Color(0xFF000000),
      onBackground: Color(0xFFFFFFFF),
      error: Color(0xFFFF0000),
      onError: Color(0xFFFFFFFF),
    ),
    // Ensure high contrast ratios
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  static ThemeData get lightHighContrast => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF000000),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF000000),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
      background: Color(0xFFFFFFFF),
      onBackground: Color(0xFF000000),
      error: Color(0xFFCC0000),
      onError: Color(0xFFFFFFFF),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Color(0xFF000000),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF000000),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
```

### Keyboard Navigation Support

```dart
class KeyboardNavigationWidget extends StatefulWidget {
  final Widget child;
  
  const KeyboardNavigationWidget({Key? key, required this.child}) : super(key: key);
  
  @override
  State<KeyboardNavigationWidget> createState() => _KeyboardNavigationWidgetState();
}

class _KeyboardNavigationWidgetState extends State<KeyboardNavigationWidget> {
  final FocusNode _focusNode = FocusNode();
  
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowUp): PreviousMessageIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): NextMessageIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): SelectMessageIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): ClearSelectionIntent(),
        LogicalKeySet(LogicalKeyboardKey.tab): NextFocusIntent(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): PreviousFocusIntent(),
      },
      child: Actions(
        actions: {
          PreviousMessageIntent: CallbackAction<PreviousMessageIntent>(
            onInvoke: (intent) => _navigateToPreviousMessage(),
          ),
          NextMessageIntent: CallbackAction<NextMessageIntent>(
            onInvoke: (intent) => _navigateToNextMessage(),
          ),
          SelectMessageIntent: CallbackAction<SelectMessageIntent>(
            onInvoke: (intent) => _selectCurrentMessage(),
          ),
          ClearSelectionIntent: CallbackAction<ClearSelectionIntent>(
            onInvoke: (intent) => _clearSelection(),
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          child: widget.child,
        ),
      ),
    );
  }
  
  void _navigateToPreviousMessage() {
    // Implementation for keyboard navigation
  }
  
  void _navigateToNextMessage() {
    // Implementation for keyboard navigation
  }
  
  void _selectCurrentMessage() {
    // Implementation for message selection
  }
  
  void _clearSelection() {
    // Implementation for clearing selection
  }
}

// Intent classes for keyboard shortcuts
class PreviousMessageIntent extends Intent {}
class NextMessageIntent extends Intent {}
class SelectMessageIntent extends Intent {}
class ClearSelectionIntent extends Intent {}
```

### Dynamic Text Scaling

```dart
class ScalableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const ScalableText(
    this.text, {
    Key? key,
    this.style,
    this.maxLines,
    this.overflow,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    
    // Limit text scale factor to prevent UI breaking
    final clampedScaleFactor = textScaleFactor.clamp(0.8, 2.0);
    
    return Text(
      text,
      style: effectiveStyle.copyWith(
        fontSize: effectiveStyle.fontSize! * clampedScaleFactor,
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
```

### Touch Target Optimization

```dart
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  
  const AccessibleButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
```

### Screen Reader Announcements

```dart
class AccessibilityAnnouncer {
  static void announce(String message, {bool interrupt = false}) {
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: interrupt 
        ? Assertiveness.assertive 
        : Assertiveness.polite,
    );
  }
  
  static void announceMessageReceived(Message message) {
    final announcement = 'New message from ${message.senderName}: ${message.content}';
    announce(announcement, interrupt: false);
  }
  
  static void announceConnectionStatus(int connectedPeers) {
    final announcement = connectedPeers > 0 
      ? 'Connected to $connectedPeers peer${connectedPeers > 1 ? 's' : ''}'
      : 'No peers connected';
    announce(announcement);
  }
  
  static void announceChannelJoined(String channelName) {
    announce('Joined channel $channelName');
  }
  
  static void announceError(String error) {
    announce('Error: $error', interrupt: true);
  }
}
```

### Accessibility Testing

```dart
class AccessibilityTests {
  static Future<void> runAccessibilityTests() async {
    testWidgets('should have proper semantic labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleMessageBubble(
            message: Message(
              content: 'Test message',
              senderName: 'Alice',
              timestamp: DateTime.now(),
            ),
            isOwn: false,
          ),
        ),
      );
      
      // Verify semantic label exists
      expect(
        find.bySemanticsLabel(RegExp(r'Message from Alice.*Test message')),
        findsOneWidget,
      );
    });
    
    testWidgets('should have minimum touch targets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleButton(
            child: Icon(Icons.send),
            onPressed: () {},
          ),
        ),
      );
      
      final button = tester.widget<Container>(
        find.descendant(
          of: find.byType(AccessibleButton),
          matching: find.byType(Container),
        ),
      );
      
      expect(button.constraints!.minWidth, greaterThanOrEqualTo(44));
      expect(button.constraints!.minHeight, greaterThanOrEqualTo(44));
    });
    
    testWidgets('should support keyboard navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KeyboardNavigationWidget(
            child: ChatScreen(),
          ),
        ),
      );
      
      // Test keyboard shortcuts
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      
      // Verify navigation occurred
      // Implementation depends on specific navigation logic
    });
  }
}
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