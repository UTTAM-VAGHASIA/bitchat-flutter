# BitChat Flutter - Settings Screen

## Settings Screen Layout

```
┌─────────────────────────────────────────────────────────────┐
│ ◀ Settings                                                  │ ← App Bar
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 👤 PROFILE                                                  │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 👤 Display Name                                    ✏️   │ │
│ │ Anonymous User                                           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📝 Status Message                                   ✏️   │ │
│ │ Available for mesh networking                            │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🔑 Node ID                                          📋   │ │
│ │ a1b2c3d4e5f6g7h8                                        │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ 🌐 NETWORK                                                  │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📶 Auto-Connect to Mesh                            ✓    │ │
│ │ Automatically join nearby mesh networks                 │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🔋 Battery Optimization                            ✓    │ │
│ │ Reduce scanning frequency to save battery               │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📡 Max Hop Count                                    3 ▶  │ │
│ │ Maximum hops for message routing                         │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ 🔒 SECURITY                                                 │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🔐 End-to-End Encryption                           ✓    │ │
│ │ Always encrypt messages (cannot be disabled)            │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🔄 Key Rotation Interval                      24h ▶     │ │
│ │ How often to generate new encryption keys               │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🗑️ Clear Message History                               │ │
│ │ Delete all stored messages and keys                     │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Scrollable Content (Continued)

```
┌─────────────────────────────────────────────────────────────┐
│ 🔔 NOTIFICATIONS                                            │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🔔 Enable Notifications                            ✓    │ │
│ │ Show notifications for new messages                      │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🔕 Quiet Hours                                     ▶    │ │
│ │ 22:00 - 08:00                                           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📳 Vibration                                       ✓    │ │
│ │ Vibrate on new messages                                 │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ 🎨 APPEARANCE                                               │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🌙 Theme                                      Auto ▶    │ │
│ │ Light, Dark, or System                                  │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🔤 Font Size                                 Medium ▶   │ │
│ │ Small, Medium, Large, Extra Large                       │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🎨 Accent Color                               Blue ▶    │ │
│ │ Choose your preferred accent color                       │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ℹ️ ABOUT                                                    │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📱 App Version                                          │ │
│ │ BitChat Flutter v1.0.0 (Build 123)                     │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📄 Privacy Policy                                   ▶   │ │
│ │ View our privacy policy                                 │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🐛 Report Bug                                       ▶   │ │
│ │ Report issues or suggest improvements                    │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Component Specifications

### Section Headers
- **Typography**: `titleMedium` with primary color
- **Spacing**: 24dp top margin, 8dp bottom margin
- **Icons**: Relevant emoji or Material icons

### Setting Items
```dart
ListTile(
  leading: Icon(Icons.bluetooth, color: Theme.of(context).colorScheme.primary),
  title: Text('Auto-Connect to Mesh'),
  subtitle: Text('Automatically join nearby mesh networks'),
  trailing: Switch(
    value: autoConnect,
    onChanged: (value) => updateSetting('autoConnect', value),
  ),
)
```

### Setting Types

#### Toggle Settings
```
┌─────────────────────────────────────────────────────────────┐
│ 🔔 Enable Notifications                            ✓       │
│ Show notifications for new messages                         │
└─────────────────────────────────────────────────────────────┘
```

#### Selection Settings
```
┌─────────────────────────────────────────────────────────────┐
│ 🌙 Theme                                      Auto ▶       │
│ Light, Dark, or System                                      │
└─────────────────────────────────────────────────────────────┘
```

#### Action Settings
```
┌─────────────────────────────────────────────────────────────┐
│ 🗑️ Clear Message History                                   │
│ Delete all stored messages and keys                         │
└─────────────────────────────────────────────────────────────┘
```

#### Information Settings
```
┌─────────────────────────────────────────────────────────────┐
│ 📱 App Version                                              │
│ BitChat Flutter v1.0.0 (Build 123)                         │
└─────────────────────────────────────────────────────────────┘
```

## Dialog Specifications

### Edit Display Name Dialog
```
┌─────────────────────────────────────────────────────────────┐
│                   Edit Display Name                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Display Name                                                │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Anonymous User                                          │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ⚠️ This name will be visible to other users on the mesh    │
│                                                             │
│                                    [Cancel]    [Save]      │
└─────────────────────────────────────────────────────────────┘
```

### Theme Selection Dialog
```
┌─────────────────────────────────────────────────────────────┐
│                    Choose Theme                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ○ Light Theme                                               │
│ ○ Dark Theme                                                │
│ ● System Default                                            │
│                                                             │
│                                    [Cancel]    [Apply]     │
└─────────────────────────────────────────────────────────────┘
```

### Clear Data Confirmation
```
┌─────────────────────────────────────────────────────────────┐
│                  ⚠️ Clear All Data                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ This will permanently delete:                               │
│ • All message history                                       │
│ • All encryption keys                                       │
│ • Channel memberships                                       │
│ • Peer connections                                          │
│                                                             │
│ This action cannot be undone.                               │
│                                                             │
│                                    [Cancel]    [Delete]    │
└─────────────────────────────────────────────────────────────┘
```

## Advanced Settings Screens

### Network Settings Detail
```
┌─────────────────────────────────────────────────────────────┐
│ ◀ Network Settings                                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 📶 CONNECTION                                               │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Scan Interval                               30s ▶       │ │
│ │ How often to scan for new peers                         │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Connection Timeout                          10s ▶       │ │
│ │ Time to wait for peer connections                       │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Max Concurrent Connections                   8 ▶        │ │
│ │ Maximum simultaneous peer connections                   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ 🔋 POWER MANAGEMENT                                         │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Background Scanning                            ✓        │ │
│ │ Continue scanning when app is in background             │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Low Power Mode                                 ✓        │ │
│ │ Reduce scanning frequency when battery is low           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Security Settings Detail
```
┌─────────────────────────────────────────────────────────────┐
│ ◀ Security Settings                                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 🔐 ENCRYPTION                                               │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Encryption Algorithm                                     │ │
│ │ AES-256-GCM (cannot be changed)                         │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Key Exchange                                             │ │
│ │ X25519 ECDH (cannot be changed)                         │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Forward Secrecy                                ✓        │ │
│ │ Generate new keys for each session                      │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ 🔑 KEY MANAGEMENT                                           │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Export Keys                                         ▶   │ │
│ │ Export keys for backup (advanced users only)           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Import Keys                                         ▶   │ │
│ │ Import previously exported keys                         │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## State Management

### Settings State
```dart
class SettingsState {
  // Profile
  String displayName;
  String statusMessage;
  String nodeId;
  
  // Network
  bool autoConnect;
  bool batteryOptimization;
  int maxHopCount;
  Duration scanInterval;
  Duration connectionTimeout;
  int maxConnections;
  
  // Security
  bool endToEndEncryption; // Always true
  Duration keyRotationInterval;
  bool forwardSecrecy;
  
  // Notifications
  bool enableNotifications;
  TimeOfDay quietHoursStart;
  TimeOfDay quietHoursEnd;
  bool vibration;
  
  // Appearance
  ThemeMode themeMode;
  double fontSize;
  Color accentColor;
}
```

### Settings Persistence
```dart
class SettingsRepository {
  static const String _keyPrefix = 'bitchat_settings_';
  
  Future<void> saveSetting<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    final fullKey = _keyPrefix + key;
    
    if (value is bool) {
      await prefs.setBool(fullKey, value);
    } else if (value is int) {
      await prefs.setInt(fullKey, value);
    } else if (value is double) {
      await prefs.setDouble(fullKey, value);
    } else if (value is String) {
      await prefs.setString(fullKey, value);
    }
  }
  
  Future<T?> loadSetting<T>(String key, T defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    final fullKey = _keyPrefix + key;
    
    return prefs.get(fullKey) as T? ?? defaultValue;
  }
}
```

## Accessibility Features

### Screen Reader Support
```dart
Semantics(
  label: 'Auto-connect to mesh network setting',
  hint: autoConnect ? 'Currently enabled' : 'Currently disabled',
  child: SwitchListTile(
    title: Text('Auto-Connect to Mesh'),
    subtitle: Text('Automatically join nearby mesh networks'),
    value: autoConnect,
    onChanged: (value) => updateAutoConnect(value),
  ),
)
```

### High Contrast Support
- Increased contrast for switch controls
- Bold text for important settings
- Clear visual hierarchy with proper spacing
- Alternative color schemes for accessibility

### Keyboard Navigation
- **Tab**: Navigate between settings
- **Space/Enter**: Toggle switches or open dialogs
- **Escape**: Close dialogs
- **Arrow Keys**: Navigate within selection dialogs

## Validation and Error Handling

### Input Validation
```dart
String? validateDisplayName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Display name cannot be empty';
  }
  if (value.length > 32) {
    return 'Display name must be 32 characters or less';
  }
  if (value.contains(RegExp(r'[<>"/\\|?*]'))) {
    return 'Display name contains invalid characters';
  }
  return null;
}
```

### Error States
```
┌─────────────────────────────────────────────────────────────┐
│                    ⚠️ Settings Error                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Unable to save settings. Please check your device storage  │
│ and try again.                                              │
│                                                             │
│                                    [Retry]    [Cancel]     │
└─────────────────────────────────────────────────────────────┘
```

This settings screen provides comprehensive control over all aspects of BitChat while maintaining security best practices and ensuring accessibility for all users.