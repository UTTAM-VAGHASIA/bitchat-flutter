# BitChat Flutter - Commands Reference

## Overview

BitChat implements an IRC-style command system that provides users with powerful control over messaging, channels, and network operations. This document specifies the complete command interface for the Flutter implementation, ensuring full compatibility with the iOS and Android versions.

## Flutter Command Architecture

### Flutter Command Parser Design

The command system uses a centralized parser with Flutter-specific optimizations and reactive state management:

```dart
class FlutterCommandParser extends ChangeNotifier {
  static const String COMMAND_PREFIX = '/';
  static final RegExp _commandRegex = RegExp(r'^/(\w+)(?:\s+(.*))?$');
  
  static CommandResult parseCommand(String input) {
    if (!input.startsWith(COMMAND_PREFIX)) {
      return CommandResult.notACommand(input);
    }
    
    final match = _commandRegex.firstMatch(input);
    if (match == null) {
      return CommandResult.error('Invalid command format');
    }
    
    final command = match.group(1)!.toLowerCase();
    final argsString = match.group(2) ?? '';
    final args = _parseArguments(argsString);
    
    return CommandResult.success(command, args);
  }
  
  static List<String> _parseArguments(String argsString) {
    if (argsString.isEmpty) return [];
    
    final List<String> args = [];
    final RegExp argRegex = RegExp(r'(?:"([^"]*)"|(\S+))');
    
    for (final match in argRegex.allMatches(argsString)) {
      args.add(match.group(1) ?? match.group(2)!);
    }
    
    return args;
  }
}
```

### Flutter Command Registry with Provider Integration

Commands are registered in a centralized registry with Flutter Provider integration for reactive UI updates:

```dart
class FlutterCommandRegistry extends ChangeNotifier {
  static final FlutterCommandRegistry _instance = FlutterCommandRegistry._internal();
  factory FlutterCommandRegistry() => _instance;
  FlutterCommandRegistry._internal();
  
  final Map<String, CommandHandler> _handlers = {};
  final Map<String, CommandMetadata> _metadata = {};
  final List<CommandExecutionResult> _commandHistory = [];
  
  // Reactive getters for UI
  List<CommandExecutionResult> get commandHistory => List.unmodifiable(_commandHistory);
  List<String> get availableCommands => _handlers.keys.toList();
  
  void registerCommand(String name, CommandHandler handler, CommandMetadata metadata) {
    _handlers[name] = handler;
    _metadata[name] = metadata;
    notifyListeners(); // Notify UI of new commands
  }
  
  Future<CommandExecutionResult> executeCommand(
    String command, 
    List<String> args, 
    CommandContext context
  ) async {
    final handler = _handlers[command];
    if (handler == null) {
      final result = CommandExecutionResult.error('Unknown command: $command');
      _addToHistory(result);
      return result;
    }
    
    final metadata = _metadata[command]!;
    
    // Show loading state in UI
    notifyListeners();
    
    try {
      // Validate permissions
      if (!_hasPermission(context.user, metadata.requiredPermission)) {
        final result = CommandExecutionResult.error('Insufficient permissions');
        _addToHistory(result);
        return result;
      }
      
      // Validate arguments
      final validationResult = _validateArguments(args, metadata);
      if (!validationResult.isValid) {
        final result = CommandExecutionResult.error(validationResult.errorMessage);
        _addToHistory(result);
        return result;
      }
      
      // Execute command with timeout
      final result = await handler(args, context)
          .timeout(Duration(seconds: 30), onTimeout: () {
        return CommandExecutionResult.error('Command timed out');
      });
      
      _addToHistory(result);
      return result;
      
    } catch (e) {
      final result = CommandExecutionResult.error('Command failed: ${e.toString()}');
      _addToHistory(result);
      return result;
    } finally {
      // Update UI state
      notifyListeners();
    }
  }
  
  void _addToHistory(CommandExecutionResult result) {
    _commandHistory.add(result);
    
    // Keep only last 100 commands
    if (_commandHistory.length > 100) {
      _commandHistory.removeAt(0);
    }
    
    notifyListeners();
  }
  
  // Auto-completion support
  List<String> getCommandSuggestions(String partial) {
    return _handlers.keys
        .where((cmd) => cmd.toLowerCase().startsWith(partial.toLowerCase()))
        .toList()
        ..sort();
  }
  
  // Get command help
  String? getCommandHelp(String command) {
    final metadata = _metadata[command];
    return metadata?.description;
  }
  
  // Clear command history
  void clearHistory() {
    _commandHistory.clear();
    notifyListeners();
  }
}

// Flutter-specific command context with UI integration
class FlutterCommandContext extends CommandContext {
  final BuildContext buildContext;
  final ScaffoldMessengerState scaffoldMessenger;
  
  FlutterCommandContext({
    required this.buildContext,
    required this.scaffoldMessenger,
    required User user,
    Channel? currentChannel,
    required ChannelService channelService,
    required MessagingService messagingService,
    required MeshService meshService,
    required UserService userService,
    required UIService uiService,
    required SecurityService securityService,
    required LogService logService,
  }) : super(
    user: user,
    currentChannel: currentChannel,
    channelService: channelService,
    messagingService: messagingService,
    meshService: meshService,
    userService: userService,
    uiService: uiService,
    securityService: securityService,
    logService: logService,
  );
  
  // Flutter-specific UI helpers
  void showSnackBar(String message, {bool isError = false}) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
          ? Theme.of(buildContext).colorScheme.error
          : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  Future<bool> showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
      context: buildContext,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  void showLoadingDialog(String message) {
    showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
  
  void hideLoadingDialog() {
    Navigator.of(buildContext).pop();
  }
}
```

## Core User Commands

### `/j <channel> [password]`

Joins a channel with optional password authentication.

**Syntax**: `/j <channel> [password]`
**Alias**: `/join <channel> [password]`

**Parameters**:
- `channel`: Channel name (required, 1-32 characters, alphanumeric + underscore)
- `password`: Channel password (optional, 8-128 characters)

**Implementation**:
```dart
class JoinCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandExecutionResult.error('Usage: /join <channel> [password]');
    }
    
    final channelName = args[0];
    final password = args.length > 1 ? args[1] : null;
    
    // Validate channel name
    if (!_isValidChannelName(channelName)) {
      return CommandExecutionResult.error('Invalid channel name. Use alphanumeric characters and underscores only.');
    }
    
    try {
      final joinResult = await context.channelService.joinChannel(channelName, password);
      
      if (joinResult.success) {
        context.uiService.switchToChannel(channelName);
        return CommandExecutionResult.success('Joined channel: $channelName');
      } else {
        return CommandExecutionResult.error(joinResult.errorMessage);
      }
    } catch (e) {
      return CommandExecutionResult.error('Failed to join channel: ${e.toString()}');
    }
  }
  
  bool _isValidChannelName(String name) {
    return RegExp(r'^[a-zA-Z0-9_]{1,32}$').hasMatch(name);
  }
}
```

### `/leave <channel>`

Leaves a specified channel.

**Syntax**: `/leave <channel>`

**Parameters**:
- `channel`: Channel name to leave (required)

**Implementation**:
```dart
class LeaveCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandExecutionResult.error('Usage: /leave <channel>');
    }
    
    final channelName = args[0];
    
    if (!context.channelService.isJoined(channelName)) {
      return CommandExecutionResult.error('You are not in channel: $channelName');
    }
    
    try {
      await context.channelService.leaveChannel(channelName);
      
      // Switch to default channel if leaving current channel
      if (context.uiService.currentChannel == channelName) {
        context.uiService.switchToChannel('general');
      }
      
      return CommandExecutionResult.success('Left channel: $channelName');
    } catch (e) {
      return CommandExecutionResult.error('Failed to leave channel: ${e.toString()}');
    }
  }
}
```

### `/m <user> <message>`

Sends a private message to a specific user.

**Syntax**: `/m <user> <message>`
**Alias**: `/msg <user> <message>`

**Parameters**:
- `user`: Target user's nickname (required)
- `message`: Message content (required, 1-4096 characters)

**Implementation**:
```dart
class MessageCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    if (args.length < 2) {
      return CommandExecutionResult.error('Usage: /msg <user> <message>');
    }
    
    final targetUser = args[0];
    final message = args.skip(1).join(' ');
    
    if (message.isEmpty) {
      return CommandExecutionResult.error('Message cannot be empty');
    }
    
    if (message.length > 4096) {
      return CommandExecutionResult.error('Message too long (max 4096 characters)');
    }
    
    try {
      final result = await context.messagingService.sendPrivateMessage(targetUser, message);
      
      if (result.success) {
        context.uiService.displayPrivateMessage(context.user.nickname, targetUser, message);
        return CommandExecutionResult.success('Private message sent to $targetUser');
      } else {
        return CommandExecutionResult.error(result.errorMessage);
      }
    } catch (e) {
      return CommandExecutionResult.error('Failed to send message: ${e.toString()}');
    }
  }
}
```

### `/w [channel]`

Lists users in a channel or all channels.

**Syntax**: `/w [channel]`
**Alias**: `/who [channel]`

**Parameters**:
- `channel`: Specific channel to query (optional)

**Implementation**:
```dart
class WhoCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    try {
      if (args.isEmpty) {
        // List all users across all channels
        final allUsers = await context.channelService.getAllUsers();
        return _formatAllUsersOutput(allUsers);
      } else {
        // List users in specific channel
        final channelName = args[0];
        final users = await context.channelService.getChannelUsers(channelName);
        return _formatChannelUsersOutput(channelName, users);
      }
    } catch (e) {
      return CommandExecutionResult.error('Failed to get user list: ${e.toString()}');
    }
  }
  
  CommandExecutionResult _formatAllUsersOutput(Map<String, List<User>> usersByChannel) {
    final buffer = StringBuffer();
    buffer.writeln('Users by channel:');
    
    for (final entry in usersByChannel.entries) {
      buffer.writeln('  ${entry.key}: ${entry.value.map((u) => u.nickname).join(', ')}');
    }
    
    return CommandExecutionResult.success(buffer.toString());
  }
  
  CommandExecutionResult _formatChannelUsersOutput(String channel, List<User> users) {
    final userList = users.map((u) => u.nickname).join(', ');
    return CommandExecutionResult.success('Users in $channel: $userList');
  }
}
```

### `/channels`

Lists all available channels.

**Implementation**:
```dart
class ChannelsCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    try {
      final channels = await context.channelService.getAvailableChannels();
      
      if (channels.isEmpty) {
        return CommandExecutionResult.success('No channels available');
      }
      
      final buffer = StringBuffer();
      buffer.writeln('Available channels:');
      
      for (final channel in channels) {
        final userCount = await context.channelService.getChannelUserCount(channel.name);
        final lockIcon = channel.isPasswordProtected ? '🔒 ' : '';
        buffer.writeln('  $lockIcon${channel.name} (${userCount} users)');
        
        if (channel.topic.isNotEmpty) {
          buffer.writeln('    Topic: ${channel.topic}');
        }
      }
      
      return CommandExecutionResult.success(buffer.toString());
    } catch (e) {
      return CommandExecutionResult.error('Failed to get channel list: ${e.toString()}');
    }
  }
}
```

### `/nick <nickname>`

Changes the user's display name.

**Syntax**: `/nick <nickname>`

**Parameters**:
- `nickname`: New nickname (required, 1-32 characters, alphanumeric + underscore)

**Implementation**:
```dart
class NickCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandExecutionResult.error('Usage: /nick <nickname>');
    }
    
    final newNickname = args[0];
    
    if (!_isValidNickname(newNickname)) {
      return CommandExecutionResult.error('Invalid nickname. Use 1-32 alphanumeric characters and underscores only.');
    }
    
    try {
      final result = await context.userService.changeNickname(newNickname);
      
      if (result.success) {
        return CommandExecutionResult.success('Nickname changed to: $newNickname');
      } else {
        return CommandExecutionResult.error(result.errorMessage);
      }
    } catch (e) {
      return CommandExecutionResult.error('Failed to change nickname: ${e.toString()}');
    }
  }
  
  bool _isValidNickname(String nickname) {
    return RegExp(r'^[a-zA-Z0-9_]{1,32}$').hasMatch(nickname);
  }
}
```

## Channel Management Commands

### `/create <channel> [password]`

Creates a new channel with optional password protection.

**Syntax**: `/create <channel> [password]`

**Required Permission**: `CREATE_CHANNEL`

**Implementation**:
```dart
class CreateCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandExecutionResult.error('Usage: /create <channel> [password]');
    }
    
    final channelName = args[0];
    final password = args.length > 1 ? args[1] : null;
    
    if (!_isValidChannelName(channelName)) {
      return CommandExecutionResult.error('Invalid channel name');
    }
    
    if (password != null && !_isValidPassword(password)) {
      return CommandExecutionResult.error('Password must be 8-128 characters long');
    }
    
    try {
      final result = await context.channelService.createChannel(channelName, password);
      
      if (result.success) {
        return CommandExecutionResult.success('Channel created: $channelName');
      } else {
        return CommandExecutionResult.error(result.errorMessage);
      }
    } catch (e) {
      return CommandExecutionResult.error('Failed to create channel: ${e.toString()}');
    }
  }
  
  bool _isValidPassword(String password) {
    return password.length >= 8 && password.length <= 128;
  }
}
```

### `/password <channel> <password>`

Sets or changes a channel's password.

**Syntax**: `/password <channel> <password>`

**Required Permission**: `CHANNEL_ADMIN`

### `/topic <channel> <topic>`

Sets a channel's topic.

**Syntax**: `/topic <channel> <topic>`

**Required Permission**: `CHANNEL_MODERATOR`

### `/kick <user> <channel>`

Removes a user from a channel.

**Syntax**: `/kick <user> <channel>`

**Required Permission**: `CHANNEL_MODERATOR`

## System Commands

### `/peers`

Shows connected peers and mesh network status.

**Implementation**:
```dart
class PeersCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    try {
      final peers = await context.meshService.getConnectedPeers();
      
      if (peers.isEmpty) {
        return CommandExecutionResult.success('No peers connected');
      }
      
      final buffer = StringBuffer();
      buffer.writeln('Connected peers:');
      
      for (final peer in peers) {
        final signalStrength = peer.rssi != null ? ' (${peer.rssi}dBm)' : '';
        final hops = peer.hopCount > 0 ? ' via ${peer.hopCount} hops' : ' direct';
        buffer.writeln('  ${peer.nickname}$signalStrength$hops');
      }
      
      buffer.writeln('\nTotal: ${peers.length} peer(s)');
      
      return CommandExecutionResult.success(buffer.toString());
    } catch (e) {
      return CommandExecutionResult.error('Failed to get peer list: ${e.toString()}');
    }
  }
}
```

### `/mesh`

Displays detailed mesh network status.

**Implementation**:
```dart
class MeshCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    try {
      final status = await context.meshService.getNetworkStatus();
      
      final buffer = StringBuffer();
      buffer.writeln('Mesh Network Status:');
      buffer.writeln('  Connected Peers: ${status.connectedPeers}');
      buffer.writeln('  Reachable Peers: ${status.reachablePeers}');
      buffer.writeln('  Network Diameter: ${status.networkDiameter} hops');
      buffer.writeln('  Messages Routed: ${status.messagesRouted}');
      buffer.writeln('  Messages Cached: ${status.messagesCached}');
      buffer.writeln('  Battery Mode: ${status.batteryMode}');
      buffer.writeln('  Bluetooth State: ${status.bluetoothState}');
      
      return CommandExecutionResult.success(buffer.toString());
    } catch (e) {
      return CommandExecutionResult.error('Failed to get mesh status: ${e.toString()}');
    }
  }
}
```

### `/battery`

Shows battery optimization status.

### `/encrypt`

Shows encryption status for current session.

### `/wipe`

Emergency data wipe with triple confirmation.

**Implementation**:
```dart
class WipeCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    // First confirmation
    final confirmed1 = await context.uiService.showConfirmationDialog(
      'Emergency Data Wipe',
      'This will permanently delete all messages, keys, and settings. Continue?',
      'WIPE',
      'Cancel'
    );
    
    if (!confirmed1) {
      return CommandExecutionResult.success('Wipe cancelled');
    }
    
    // Second confirmation
    final confirmed2 = await context.uiService.showConfirmationDialog(
      'Confirm Data Wipe',
      'Are you absolutely sure? This cannot be undone.',
      'YES, WIPE',
      'Cancel'
    );
    
    if (!confirmed2) {
      return CommandExecutionResult.success('Wipe cancelled');
    }
    
    // Third confirmation with typing requirement
    final confirmed3 = await context.uiService.showTextConfirmationDialog(
      'Final Confirmation',
      'Type "WIPE ALL DATA" to confirm:',
      'WIPE ALL DATA'
    );
    
    if (!confirmed3) {
      return CommandExecutionResult.success('Wipe cancelled');
    }
    
    try {
      await context.securityService.emergencyWipe();
      return CommandExecutionResult.success('All data wiped successfully');
    } catch (e) {
      return CommandExecutionResult.error('Failed to wipe data: ${e.toString()}');
    }
  }
}
```

## Debug Commands

### `/debug`

Toggles debug mode and detailed logging.

**Required Permission**: `DEBUG`

### `/logs`

Shows recent application logs.

**Implementation**:
```dart
class LogsCommand extends CommandHandler {
  @override
  Future<CommandExecutionResult> execute(List<String> args, CommandContext context) async {
    final count = args.isNotEmpty ? int.tryParse(args[0]) ?? 50 : 50;
    
    try {
      final logs = await context.logService.getRecentLogs(count);
      
      if (logs.isEmpty) {
        return CommandExecutionResult.success('No recent logs');
      }
      
      final buffer = StringBuffer();
      buffer.writeln('Recent logs ($count entries):');
      
      for (final log in logs) {
        buffer.writeln('${log.timestamp} [${log.level}] ${log.message}');
      }
      
      return CommandExecutionResult.success(buffer.toString());
    } catch (e) {
      return CommandExecutionResult.error('Failed to get logs: ${e.toString()}');
    }
  }
}
```

### `/stats`

Shows detailed network statistics.

### `/test <command>`

Runs system tests for diagnostics.

### `/version`

Shows version information.

## Command Execution Context

```dart
class CommandContext {
  final User user;
  final Channel? currentChannel;
  final ChannelService channelService;
  final MessagingService messagingService;
  final MeshService meshService;
  final UserService userService;
  final UIService uiService;
  final SecurityService securityService;
  final LogService logService;
  
  CommandContext({
    required this.user,
    this.currentChannel,
    required this.channelService,
    required this.messagingService,
    required this.meshService,
    required this.userService,
    required this.uiService,
    required this.securityService,
    required this.logService,
  });
}
```

## Permission System

```dart
enum CommandPermission {
  none,
  user,
  channelModerator,
  channelAdmin,
  createChannel,
  systemAdmin,
  debug,
}

class CommandMetadata {
  final String name;
  final String description;
  final String usage;
  final CommandPermission requiredPermission;
  final List<String> aliases;
  final bool requiresNetworkConnection;
  final bool requiresConfirmation;
  
  const CommandMetadata({
    required this.name,
    required this.description,
    required this.usage,
    this.requiredPermission = CommandPermission.user,
    this.aliases = const [],
    this.requiresNetworkConnection = false,
    this.requiresConfirmation = false,
  });
}
```

## Auto-completion System

```dart
class CommandAutoComplete {
  static List<String> getSuggestions(String input, CommandContext context) {
    if (!input.startsWith('/')) return [];
    
    final parts = input.split(' ');
    final command = parts[0].substring(1).toLowerCase();
    
    if (parts.length == 1) {
      // Complete command names
      return _getCommandSuggestions(command, context);
    } else {
      // Complete command arguments
      return _getArgumentSuggestions(command, parts.skip(1).toList(), context);
    }
  }
  
  static List<String> _getCommandSuggestions(String partial, CommandContext context) {
    final availableCommands = CommandRegistry.getAvailableCommands(context.user);
    
    return availableCommands
        .where((cmd) => cmd.startsWith(partial))
        .map((cmd) => '/$cmd')
        .toList();
  }
  
  static List<String> _getArgumentSuggestions(
    String command, 
    List<String> args, 
    CommandContext context
  ) {
    switch (command) {
      case 'join':
      case 'leave':
        return _getChannelSuggestions(args.isEmpty ? '' : args.last, context);
      case 'msg':
        if (args.isEmpty) {
          return _getUserSuggestions('', context);
        }
        break;
      case 'who':
        return _getChannelSuggestions(args.isEmpty ? '' : args.last, context);
    }
    
    return [];
  }
}
```

## Error Handling

```dart
class CommandExecutionResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  
  CommandExecutionResult.success(this.message, {this.data}) : success = true;
  CommandExecutionResult.error(this.message, {this.data}) : success = false;
}

class CommandValidationResult {
  final bool isValid;
  final String errorMessage;
  
  CommandValidationResult.valid() : isValid = true, errorMessage = '';
  CommandValidationResult.invalid(this.errorMessage) : isValid = false;
}
```

## Command History

```dart
class CommandHistory {
  static const int maxHistorySize = 100;
  static final List<String> _history = [];
  static int _currentIndex = -1;
  
  static void addCommand(String command) {
    _history.add(command);
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
    }
    _currentIndex = _history.length;
  }
  
  static String? getPrevious() {
    if (_history.isEmpty) return null;
    
    _currentIndex = (_currentIndex - 1).clamp(0, _history.length - 1);
    return _history[_currentIndex];
  }
  
  static String? getNext() {
    if (_history.isEmpty) return null;
    
    _currentIndex = (_currentIndex + 1).clamp(0, _history.length);
    return _currentIndex < _history.length ? _history[_currentIndex] : null;
  }
}
```

## Rate Limiting

```dart
class CommandRateLimiter {
  static const int maxCommandsPerMinute = 30;
  static final Map<String, List<DateTime>> _userCommands = {};
  
  static bool isRateLimited(String userId) {
    final now = DateTime.now();
    final userCommands = _userCommands[userId] ?? [];
    
    // Remove commands older than 1 minute
    userCommands.removeWhere((time) => now.difference(time).inMinutes >= 1);
    
    return userCommands.length >= maxCommandsPerMinute;
  }
  
  static void recordCommand(String userId) {
    final userCommands = _userCommands[userId] ?? [];
    userCommands.add(DateTime.now());
    _userCommands[userId] = userCommands;
  }
}
```

## Integration with Flutter UI

```dart
class CommandInputWidget extends StatefulWidget {
  final Function(String) onCommandExecuted;
  
  const CommandInputWidget({Key? key, required this.onCommandExecuted}) : super(key: key);
  
  @override
  State<CommandInputWidget> createState() => _CommandInputWidgetState();
}

class _CommandInputWidgetState extends State<CommandInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_suggestions.isNotEmpty)
          Container(
            height: 120,
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_suggestions[index]),
                  onTap: () => _selectSuggestion(_suggestions[index]),
                );
              },
            ),
          ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onTextChanged,
          onSubmitted: _onSubmitted,
          decoration: const InputDecoration(
            hintText: 'Enter command or message...',
            prefixIcon: Icon(Icons.terminal),
          ),
        ),
      ],
    );
  }
  
  void _onTextChanged(String text) {
    setState(() {
      _suggestions = CommandAutoComplete.getSuggestions(text, context);
    });
  }
  
  void _onSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      widget.onCommandExecuted(text.trim());
      _controller.clear();
      setState(() {
        _suggestions = [];
      });
    }
  }
}
```

## Protocol Compatibility

The Flutter command system maintains full compatibility with iOS and Android implementations:

1. **Command Names**: Identical command names and aliases
2. **Argument Parsing**: Same argument parsing rules and escaping
3. **Permission Levels**: Identical permission hierarchy
4. **Error Messages**: Standardized error message formats
5. **Response Formats**: Consistent response formatting

## Testing Strategy

```dart
class CommandTestSuite {
  static Future<void> runAllTests() async {
    await testCommandParsing();
    await testCommandExecution();
    await testPermissionSystem();
    await testAutoCompletion();
    await testRateLimiting();
  }
  
  static Future<void> testCommandParsing() async {
    // Test various command formats
    assert(CommandParser.parseCommand('/join test').command == 'join');
    assert(CommandParser.parseCommand('/msg user "hello world"').args.length == 2);
    assert(CommandParser.parseCommand('not a command').isNotACommand);
  }
  
  static Future<void> testCommandExecution() async {
    // Test command execution with mocked services
    final mockContext = MockCommandContext();
    final result = await CommandRegistry.executeCommand('join', ['test'], mockContext);
    assert(result.success);
  }
}
```

This comprehensive command system provides a powerful, extensible interface for BitChat users while maintaining full compatibility with the existing iOS and Android implementations. The system handles all aspects of command processing, from parsing and validation to execution and error handling, ensuring a robust and user-friendly experience.