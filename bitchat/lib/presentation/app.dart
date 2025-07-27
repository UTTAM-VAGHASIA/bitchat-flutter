import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/services/dependency_injection.dart';
import '../core/services/service_registry.dart';
import '../shared/themes/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'shell/app_shell.dart';

/// Main BitChat application widget
class BitChatApp extends StatelessWidget {
  const BitChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global app state provider
        ChangeNotifierProvider(
          create: (_) => AppStateProvider(
            configurationManager: getSingleton<ConfigurationManager>(),
            logger: getSingleton<LoggerService>(),
          ),
        ),

        // Provide core services through Provider for easy access
        Provider<LoggerService>.value(value: getSingleton<LoggerService>()),
        Provider<ConfigurationManager>.value(
          value: getSingleton<ConfigurationManager>(),
        ),
        Provider<ErrorHandlerService>.value(
          value: getSingleton<ErrorHandlerService>(),
        ),
        Provider<PerformanceMonitorService>.value(
          value: getSingleton<PerformanceMonitorService>(),
        ),
        Provider<PlatformService>.value(value: getSingleton<PlatformService>()),
        Provider<PermissionManager>.value(
          value: getSingleton<PermissionManager>(),
        ),
        Provider<SecureStorageService>.value(
          value: getSingleton<SecureStorageService>(),
        ),
        Provider<SettingsService>.value(value: getSingleton<SettingsService>()),
        Provider<MemoryManager>.value(value: getSingleton<MemoryManager>()),
        Provider<BackgroundTaskManager>.value(
          value: getSingleton<BackgroundTaskManager>(),
        ),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            home: const AppShell(),
            builder: (context, child) {
              // Global error boundary
              return ErrorBoundary(child: child ?? const SizedBox.shrink());
            },
          );
        },
      ),
    );
  }
}

/// Global error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();

    // Set up global error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorHandler = getSingleton<ErrorHandlerService>();
      errorHandler.handleError(
        details.exception,
        details.stack ?? StackTrace.current,
        context: 'Flutter Framework',
      );

      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: ErrorRecoveryWidget(
            error: _error!,
            stackTrace: _stackTrace,
            onRecover: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// Error recovery widget shown when unhandled errors occur
class ErrorRecoveryWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRecover;

  const ErrorRecoveryWidget({
    super.key,
    required this.error,
    this.stackTrace,
    required this.onRecover,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Error'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'An unexpected error occurred',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (stackTrace != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Stack Trace:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    stackTrace.toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: onRecover,
                  child: const Text('Try Again'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    // Report error to crash reporting service
                    final errorHandler = getSingleton<ErrorHandlerService>();
                    errorHandler.reportError(
                      error,
                      stackTrace ?? StackTrace.current,
                      metadata: {
                        'timestamp': DateTime.now().toIso8601String(),
                        'app_version': AppConstants.appVersion,
                      },
                    );
                  },
                  child: const Text('Report Error'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
