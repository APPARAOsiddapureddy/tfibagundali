import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfi_bagundali/app.dart';
import 'package:tfi_bagundali/core/auth/token_storage.dart';
import 'package:tfi_bagundali/core/config/app_config.dart';
import 'package:tfi_bagundali/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets('app boots with ProviderScope', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenStorageProvider.overrideWithValue(TokenStorage(memory: {})),
          appConfigProvider.overrideWithValue(AppConfig.development),
        ],
        child: const App(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
