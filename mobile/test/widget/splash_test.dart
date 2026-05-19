import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfi_bagundali/features/splash/splash_screen.dart';

void main() {
  testWidgets('Splash shows TFI Bagundali branding', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('TFI'), findsOneWidget);
    expect(find.text('BAGUNDALI'), findsOneWidget);
    expect(find.textContaining('CONTENT-FIRST'), findsOneWidget);
  });
}
