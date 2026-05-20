import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfi_bagundali/features/splash/splash_screen.dart';

void main() {
  testWidgets('Splash shows TFI Bagundali branding', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 2000));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('TFI Bagundali'), findsOneWidget);
    expect(find.textContaining('Mana Cinema'), findsOneWidget);
  });
}
