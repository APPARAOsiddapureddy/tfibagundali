import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tfi_bagundali/core/providers/auth_provider.dart';
import 'package:tfi_bagundali/features/auth/login_screen.dart';
import 'package:tfi_bagundali/core/theme/app_theme.dart';

void main() {
  testWidgets('Login screen has Send OTP button', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: MaterialApp(theme: AppTheme.dark, home: const LoginScreen()),
      ),
    );
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.text('TFI BAGUNDALI'), findsOneWidget);
  });
}
