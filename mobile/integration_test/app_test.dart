import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tfi_bagundali/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches and reaches login', (tester) async {
    await tester.pumpWidget(const TfiBagundaliApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Send OTP'), findsOneWidget);
  });
}
