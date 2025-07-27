// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:bitchat/core/services/service_registry.dart';
import 'package:bitchat/presentation/app.dart';

void main() {
  testWidgets('BitChat app smoke test', (WidgetTester tester) async {
    // Initialize services for testing
    await ServiceRegistry.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const BitChatApp());

    // Wait for the app to initialize
    await tester.pumpAndSettle();

    // Verify that the app loads with the loading screen or main content
    expect(find.text('BitChat'), findsOneWidget);
  });
}
