import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../providers/app_state_provider.dart';

/// Main application shell that provides the basic app structure
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        // Show loading screen while initializing
        if (!appState.isInitialized) {
          return const LoadingScreen();
        }

        // Show error screen if initialization failed
        if (appState.errorMessage != null) {
          return ErrorScreen(
            message: appState.errorMessage!,
            onRetry: () => appState.clearError(),
          );
        }

        // Show main app content
        return const MainScreen();
      },
    );
  }
}

/// Loading screen shown during app initialization
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppConstants.appName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Initializing secure mesh network...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// Error screen shown when app initialization fails
class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorScreen({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Initialization Failed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main screen content (placeholder for now)
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'BitChat Foundation Ready',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Core infrastructure and dependency injection initialized',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 32),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foundation Components:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('✓ Clean Architecture layers'),
                    Text('✓ Dependency injection container'),
                    Text('✓ Service registry'),
                    Text('✓ Configuration management'),
                    Text('✓ Error handling'),
                    Text('✓ Logging system'),
                    Text('✓ Platform abstraction'),
                    Text('✓ State management'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Start chat functionality
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
