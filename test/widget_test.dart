import 'package:flutter_test/flutter_test.dart';
import 'package:pac_app/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PACApp());
    await tester.pumpAndSettle();
    expect(find.text('Payment Assurance Copilot'), findsOneWidget);
  });
}
