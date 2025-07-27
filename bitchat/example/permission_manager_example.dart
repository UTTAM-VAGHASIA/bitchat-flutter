import 'package:flutter/material.dart';
import 'package:bitchat/core/platform.dart';

/// Example demonstrating how to use the PermissionManager
///
/// This example shows:
/// - How to create a PermissionManager instance
/// - How to check required permissions for the current platform
/// - How to request permissions with different configurations
/// - How to monitor permission changes
/// - How to handle permission request results
class PermissionManagerExample extends StatefulWidget {
  const PermissionManagerExample({super.key});

  @override
  State<PermissionManagerExample> createState() =>
      _PermissionManagerExampleState();
}

class _PermissionManagerExampleState extends State<PermissionManagerExample> {
  PermissionManager? _permissionManager;
  List<Permission> _requiredPermissions = [];
  Map<Permission, PermissionStatus> _permissionStatus = {};
  String _statusMessage = 'Initializing...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePermissionManager();
  }

  @override
  void dispose() {
    _permissionManager?.dispose();
    super.dispose();
  }

  Future<void> _initializePermissionManager() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Creating PermissionManager...';
      });

      // Create the PermissionManager instance
      _permissionManager = await PermissionManagerFactory.getInstance();

      // Get required permissions for this platform
      _requiredPermissions = _permissionManager!.getRequiredPermissions();

      // Get current permission status
      _permissionStatus = await _permissionManager!.getPermissionStatus(
        _requiredPermissions,
      );

      // Listen for permission changes
      _permissionManager!.permissionChanges.listen((event) {
        setState(() {
          _permissionStatus[event.permission] = event.status;
          _statusMessage =
              'Permission ${event.permission.displayName} changed to ${event.status}';
        });
      });

      setState(() {
        _isLoading = false;
        _statusMessage = 'PermissionManager initialized successfully';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Failed to initialize PermissionManager: $e';
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    if (_permissionManager == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting all permissions...';
    });

    try {
      final result = await _permissionManager!.requestRequiredPermissions();

      setState(() {
        _isLoading = false;
        if (result.allGranted) {
          _statusMessage = 'All permissions granted successfully!';
        } else {
          _statusMessage =
              'Some permissions were denied. '
              'Granted: ${result.granted.length}, '
              'Denied: ${result.denied.length}, '
              'Requires Settings: ${result.requiresSettings.length}';
        }
      });

      // Refresh permission status
      _permissionStatus = await _permissionManager!.getPermissionStatus(
        _requiredPermissions,
      );
      setState(() {});
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error requesting permissions: $e';
      });
    }
  }

  Future<void> _requestCriticalPermissions() async {
    if (_permissionManager == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting critical permissions...';
    });

    try {
      final result = await _permissionManager!.requestCriticalPermissions();

      setState(() {
        _isLoading = false;
        if (result.allGranted) {
          _statusMessage = 'All critical permissions granted!';
        } else {
          _statusMessage =
              'Some critical permissions were denied. '
              'This may affect core functionality.';
        }
      });

      // Refresh permission status
      _permissionStatus = await _permissionManager!.getPermissionStatus(
        _requiredPermissions,
      );
      setState(() {});
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error requesting critical permissions: $e';
      });
    }
  }

  Future<void> _checkPermissionStatus() async {
    if (_permissionManager == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking permission status...';
    });

    try {
      _permissionStatus = await _permissionManager!.getPermissionStatus(
        _requiredPermissions,
      );

      final allGranted = await _permissionManager!
          .areRequiredPermissionsGranted();
      final criticalGranted = await _permissionManager!
          .areCriticalPermissionsGranted();

      setState(() {
        _isLoading = false;
        _statusMessage =
            'Status updated. All granted: $allGranted, Critical granted: $criticalGranted';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error checking permission status: $e';
      });
    }
  }

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
        return Colors.purple;
      case PermissionStatus.unknown:
        return Colors.grey;
      case PermissionStatus.notApplicable:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PermissionManager Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading...'),
                        ],
                      )
                    else
                      Text(_statusMessage),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Permissions List
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Permissions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_requiredPermissions.isEmpty)
                        const Text('No permissions loaded yet...')
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: _requiredPermissions.length,
                            itemBuilder: (context, index) {
                              final permission = _requiredPermissions[index];
                              final status =
                                  _permissionStatus[permission] ??
                                  PermissionStatus.unknown;

                              return ListTile(
                                leading: Icon(
                                  permission.isCritical
                                      ? Icons.warning
                                      : Icons.info,
                                  color: permission.isCritical
                                      ? Colors.orange
                                      : Colors.blue,
                                ),
                                title: Text(permission.displayName),
                                subtitle: Text(permission.description),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      status,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _getStatusColor(status),
                                    ),
                                  ),
                                  child: Text(
                                    status.name.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _requestAllPermissions,
                    child: const Text('Request All'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _requestCriticalPermissions,
                    child: const Text('Request Critical'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading ? null : _checkPermissionStatus,
              child: const Text('Refresh Status'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      title: 'PermissionManager Example',
      home: PermissionManagerExample(),
    ),
  );
}
