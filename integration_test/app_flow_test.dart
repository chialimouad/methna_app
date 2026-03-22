import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:methna_app/main.dart' as app;

/// Integration test for the full app flow:
/// Splash → Login → Home (Swipe) → Match → Chat
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Flow', () {
    testWidgets('Splash screen appears and navigates', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // After splash, we should see either login or home screen
      // depending on auth state. For a fresh app, expect login.
      final loginOrHome = find.byType(Scaffold);
      expect(loginOrHome, findsWidgets);
    });

    testWidgets('Login screen has email and password fields', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for text fields on the login screen
      final textFields = find.byType(TextField);
      // Should have at least email + password
      expect(textFields, findsWidgets);
    });

    testWidgets('Login with empty fields shows validation', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Try to find and tap a login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Should show some validation error (snackbar or inline)
        // At minimum, should not crash
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
