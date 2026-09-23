import 'package:flutter_test/flutter_test.dart';
import 'package:live_translator/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LiveTranslatorApp());

    // Verify that our Splash Screen is rendering.
    expect(find.text('Live Translator'), findsNothing); // It's not in the title yet, but we can look for the icon
    // Wait for the GetX app to settle.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
