# BitChat Flutter - Channel List Interface

## Channel List Layout

```
┌─────────────────────────────────────────────────────────────┐
│ BitChat                                          🔍 ➕ ⋮   │ ← App Bar
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 📋 CHANNELS                                                 │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ # general                                    👥 12  🔔  │ │ ← Active Channel
│ │ Alice: Hey everyone! The mesh network...     2 min ago  │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ # development                                👥 5   🔕  │ │ ← Muted Channel
│ │ Bob: Fixed the encryption bug in...          1 hr ago   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ # random                                     👥 8   •3  │ │ ← Unread Messages
│ │ Carol: Anyone want to test the new...        3 hr ago   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ 💬 DIRECT MESSAGES                                          │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 👤 Alice                                     🟢     •1  │ │ ← Online User
│ │ Thanks for the help with the protocol        5 min ago  │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 👤 Bob                                       🟡         │ │ ← Away User
│ │ Let's sync up tomorrow about the UI          2 hr ago   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 👤 Carol                                     ⚫         │ │ ← Offline User
│ │ See you later!                               1 day ago  │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ 🌐 MESH STATUS                                              │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📶 Connected • 4 peers • 2 hops                        │ │ ← Network Status
│ │ 🔒 Encrypted • 🔋 Battery Optimized                    │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Component Specifications

### App Bar
- **Title**: "BitChat" with app icon
- **Actions**:
  - Search button (🔍) - Search channels and messages
  - Add button (➕) - Join/create channels
  - Overflow menu (⋮) - Settings, about, etc.

### Channel Item Design
```
┌─────────────────────────────────────────────────────────────┐
│ # channel-name                           👥 12  🔔  •3     │
│ Last Sender: Preview of last message...     timestamp      │
└─────────────────────────────────────────────────────────────┘
```

**Elements**:
- Channel icon (# for public, 🔒 for private)
- Channel name with proper truncation
- Member count badge
- Notification status (🔔 enabled, 🔕 muted)
- Unread message count (•3)
- Last message preview with sender name
- Timestamp of last activity

### Direct Message Item Design
```
┌─────────────────────────────────────────────────────────────┐
│ 👤 User Name                             🟢         •1     │
│ Preview of last direct message...           timestamp      │
└─────────────────────────────────────────────────────────────┘
```

**Elements**:
- User avatar or default icon
- User display name
- Online status indicator:
  - 🟢 Online (connected to mesh)
  - 🟡 Away (connected but inactive)
  - ⚫ Offline (not connected)
- Unread message count
- Last message preview
- Timestamp of last activity

### Section Headers
- **Channels**: "📋 CHANNELS"
- **Direct Messages**: "💬 DIRECT MESSAGES"
- **Mesh Status**: "🌐 MESH STATUS"

## Material Design 3 Implementation

### List Item Styling
```dart
ListTile(
  leading: CircleAvatar(
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    child: Icon(Icons.tag, color: Theme.of(context).colorScheme.primary),
  ),
  title: Text(
    channel.name,
    style: Theme.of(context).textTheme.titleMedium,
    overflow: TextOverflow.ellipsis,
  ),
  subtitle: Text(
    '${lastMessage.sender}: ${lastMessage.preview}',
    style: Theme.of(context).textTheme.bodyMedium,
    overflow: TextOverflow.ellipsis,
  ),
  trailing: Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        formatTimestamp(lastMessage.timestamp),
        style: Theme.of(context).textTheme.labelSmall,
      ),
      if (unreadCount > 0)
        Badge(
          label: Text('$unreadCount'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
    ],
  ),
)
```

### Color Coding
- **Active Channel**: Primary container background
- **Unread Messages**: Error color for badges
- **Muted Channels**: Muted text color
- **Online Status**: Success color (green)
- **Away Status**: Warning color (yellow)
- **Offline Status**: Disabled color (gray)

## Responsive Design

### Phone Layout (< 600dp)
```
┌─────────────────────────────────────────────────────────────┐
│ BitChat                                          🔍 ➕ ⋮   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ [Full-width channel list]                                  │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ # general                            👥 12  🔔  •3     │ │
│ │ Alice: Hey everyone! The mesh...         2 min ago     │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Tablet Layout (600dp - 840dp)
```
┌─────────────────────────────────────────────────────────────┐
│ BitChat                                          🔍 ➕ ⋮   │
├─────────────────┬───────────────────────────────────────────┤
│                 │                                           │
│ [Channel List]  │ [Selected Channel Chat View]              │
│                 │                                           │
│ # general       │ ┌─────────────────────────────────────┐   │
│ # development   │ │ Alice: Hey everyone!                │   │
│ # random        │ └─────────────────────────────────────┘   │
│                 │                                           │
│ 👤 Alice        │ ┌─────────────────────────────────────┐   │
│ 👤 Bob          │ │ Bob: Great idea!                    │   │
│                 │ └─────────────────────────────────────┘   │
│                 │                                           │
└─────────────────┴───────────────────────────────────────────┘
```

### Desktop Layout (> 840dp)
```
┌─────────────────────────────────────────────────────────────┐
│ BitChat                                          🔍 ➕ ⋮   │
├─────────┬───────────────────────────────┬───────────────────┤
│         │                               │                   │
│[Channel]│ [Chat View]                   │ [Channel Details] │
│ List    │                               │                   │
│         │ ┌─────────────────────────┐   │ 👥 Members (12)   │
│# general│ │ Alice: Hey everyone!    │   │                   │
│# dev    │ └─────────────────────────┘   │ 📋 Pinned         │
│# random │                               │                   │
│         │ ┌─────────────────────────┐   │ 📎 Files          │
│👤 Alice │ │ Bob: Great idea!        │   │                   │
│👤 Bob   │ └─────────────────────────┘   │ ⚙️ Settings       │
│         │                               │                   │
└─────────┴───────────────────────────────┴───────────────────┘
```

## Interactive Features

### Channel Actions
- **Tap**: Open channel chat
- **Long Press**: Show context menu
  - Mute/Unmute notifications
  - Mark as read
  - Leave channel
  - Channel settings

### Search Functionality
```
┌─────────────────────────────────────────────────────────────┐
│ 🔍 Search channels and messages...                    ✕    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 📋 CHANNELS                                                 │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ # development                                           │ │
│ │ Contains "flutter" in recent messages                   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ 💬 MESSAGES                                                 │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Alice in #general                           2 min ago   │ │
│ │ The Flutter implementation is working great!            │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Add Channel Dialog
```
┌─────────────────────────────────────────────────────────────┐
│                    Join Channel                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Channel Name                                                │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ general                                                 │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Password (optional)                                         │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ••••••••                                    👁️         │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ☐ Create new channel if it doesn't exist                   │
│                                                             │
│                                    [Cancel]    [Join]      │
└─────────────────────────────────────────────────────────────┘
```

## State Management

### Channel List State
```dart
class ChannelListState {
  List<Channel> channels;
  List<DirectMessage> directMessages;
  MeshNetworkStatus networkStatus;
  String searchQuery;
  bool isSearching;
  Map<String, int> unreadCounts;
  Map<String, bool> mutedChannels;
}
```

### Channel Model
```dart
class Channel {
  String id;
  String name;
  String description;
  bool isPrivate;
  bool requiresPassword;
  int memberCount;
  Message lastMessage;
  DateTime lastActivity;
  bool isMuted;
  int unreadCount;
  List<String> members;
}
```

## Accessibility Features

### Screen Reader Support
```dart
Semantics(
  label: 'Channel ${channel.name} with ${channel.memberCount} members',
  hint: channel.unreadCount > 0 
    ? '${channel.unreadCount} unread messages'
    : 'No unread messages',
  child: ChannelListItem(channel: channel),
)
```

### Keyboard Navigation
- **Tab**: Navigate between channels
- **Enter**: Open selected channel
- **Space**: Toggle channel selection
- **Ctrl+F**: Open search
- **Escape**: Close search/dialogs

## Performance Optimizations

### List Performance
```dart
ListView.builder(
  itemCount: channels.length,
  itemBuilder: (context, index) {
    return ChannelListItem(
      key: ValueKey(channels[index].id),
      channel: channels[index],
    );
  },
)
```

### Efficient Updates
- Use `ValueKey` for list items to optimize rebuilds
- Implement proper `shouldRebuild` logic in providers
- Cache channel avatars and metadata
- Lazy load channel member lists

### Memory Management
- Limit message preview length
- Implement proper disposal of resources
- Use weak references for cached data
- Periodic cleanup of old data

This channel list interface provides an intuitive way to navigate between different conversations while clearly showing the status of each channel and the overall mesh network connectivity.