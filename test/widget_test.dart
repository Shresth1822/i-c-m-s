import 'package:flutter_test/flutter_test.dart';
import 'package:icms/main.dart';

void main() {
  testWidgets('App starts and displays home screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the home screen is displayed.
    expect(find.text('Insurance Claim Management'), findsOneWidget);
    expect(find.text('Welcome to ICMS'), findsOneWidget);
  });
}
