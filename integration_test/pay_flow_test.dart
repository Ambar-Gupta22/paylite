import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paylite/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end payment flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Just verify the app boots to login screen
    expect(find.text('Login to PayLite'), findsOneWidget);
    
    // In a real integration test against a staging backend, we would:
    // 1. Enter credentials and login
    // 2. Tap Pay
    // 3. Enter VPA and amount
    // 4. Enter PIN
    // 5. Verify success screen
  });
}
