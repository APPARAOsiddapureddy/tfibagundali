import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/auth/token_storage.dart';
import 'core/config/app_config.dart';
import 'core/storage/local_storage.dart';
import 'core/notifications/notification_service.dart';
import 'features/auth/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initFirebaseAndCrashlytics();

  final prefs = await SharedPreferences.getInstance();
  final config = AppConfig.fromEnvironment();
  final tokenStorage = TokenStorage();
  await tokenStorage.migrateFromPrefs(LocalStorage(prefs));

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        tokenStorageProvider.overrideWithValue(tokenStorage),
        appConfigProvider.overrideWithValue(config),
      ],
      child: const App(),
    ),
  );
}

Future<void> _initFirebaseAndCrashlytics() async {
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (_) {
    // No-op: Firebase may be absent until config files are added.
  }
}
