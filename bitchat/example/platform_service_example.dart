import 'package:flutter/material.dart';
import 'package:bitchat/core/platform.dart';

/// Example demonstrating how to use the PlatformService
///
/// This example shows how to:
/// - Get platform information
/// - Request permissions
/// - Listen for platform events
/// - Check platform capabilities
class PlatformServiceExample extends StatefulWidget {
  const PlatformServiceExample({super.key});

  @override
  State<PlatformServiceExample> createState() => _PlatformServiceExampleState();
}

class _PlatformServiceExampleState extends State<PlatformServiceExample> {
  late final PlatformService _platformService;
  PlatformInfo? _platformInfo;
  Map<Permission, PermissionStatus> _permissionStatus = {};
  List<PlatformEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _platformService = PlatformServiceFactory.getInstance();
    _initializePlatformService();
  }

  Future<void> _initializePlatformService() async {
    try {
      // Get platform information
      final platformInfo = await _platformService.getPlatformInfo();

      // Get permission status for critical permissions
      final criticalPermissions = [
        Permission.bluetooth,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ];

      final permissionStatus = await _platformService.getPermissionStatus(
        criticalPermissions,
      );

      // Listen for platform events
      _platformService.platformEvents.listen((event) {
        setState(() {
          _events.insert(0, event);
          // Keep only the last 10 events
          if (_events.length > 10) {
            _events = _events.take(10).toList();
          }
        });
      });

      setState(() {
        _platformInfo = platformInfo;
        _permissionStatus = permissionStatus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing platform service: $e')),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    final criticalPermissions = [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ];

    final granted = await _platformService.requestPermissions(
      criticalPermissions,
    );

    // Refresh permission status
    final permissionStatus = await _platformService.getPermissionStatus(
      criticalPermissions,
    );

    setState(() {
      _permissionStatus = permissionStatus;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'All permissions granted!'
                : 'Some permissions were denied',
          ),
          backgroundColor: granted ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _toggleBackgroundMode() async {
    final currentStatus = await _platformService.getBackgroundModeStatus();
    await _platformService.setBackgroundMode(!currentStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Background mode ${!currentStatus ? 'enabled' : 'disabled'}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Platform Service Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlatformInfoSection(),
            const SizedBox(height: 24),
            _buildPermissionsSection(),
            const SizedBox(height: 24),
            _buildActionsSection(),
            const SizedBox(height: 24),
            _buildEventsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformInfoSection() {
    if (_platformInfo == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Platform information not available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Type: ${_platformInfo!.type.name}'),
            Text('Version: ${_platformInfo!.version}'),
            Text('Device: ${_platformInfo!.deviceModel}'),
            Text('Performance: ${_platformInfo!.performance.name}'),
            Text('Mobile: ${_platformInfo!.isMobile}'),
            Text('Desktop: ${_platformInfo!.isDesktop}'),
            const SizedBox(height: 8),
            Text(
              'Capabilities:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...(_platformInfo!.capabilities.map(
              (capability) => Text('• ${capability.name}'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permissions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ..._permissionStatus.entries.map(
              (entry) => _buildPermissionRow(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow(Permission permission, PermissionStatus status) {
    Color statusColor;
    switch (status) {
      case PermissionStatus.granted:
        statusColor = Colors.green;
        break;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
        statusColor = Colors.red;
        break;
      case PermissionStatus.restricted:
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(permission.displayName)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status.name,
              style: TextStyle(color: statusColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actions', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _requestPermissions,
                  child: const Text('Request Permissions'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _toggleBackgroundMode,
                  child: const Text('Toggle Background Mode'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Events',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (_events.isEmpty)
              const Text('No events yet')
            else
              ..._events.map((event) => _buildEventRow(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(PlatformEvent event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${event.timestamp.hour.toString().padLeft(2, '0')}:'
            '${event.timestamp.minute.toString().padLeft(2, '0')}:'
            '${event.timestamp.second.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _platformService.dispose();
    super.dispose();
  }
}
