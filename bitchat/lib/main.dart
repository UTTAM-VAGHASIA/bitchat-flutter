import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/services/service_registry.dart';
import 'presentation/app.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize core services
  await ServiceRegistry.initialize();

  // Run the app
  runApp(const BitChatApp());
}
