import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';

/// Push notifications via Firebase.
///
/// To enable: add `firebase_core` + `firebase_messaging` to pubspec,
/// configure `google-services.json` / `GoogleService-Info.plist`, then
/// uncomment the integration block in [init].
class FcmService {
  static Future<void> init(AuthProvider auth) async {
    if (kDebugMode) {
      debugPrint('FCM: add firebase_messaging to enable push. Token API ready at POST /profile/fcm-token');
    }
    // When Firebase is configured:
    // final messaging = FirebaseMessaging.instance;
    // final settings = await messaging.requestPermission();
    // if (settings.authorizationStatus == AuthorizationStatus.denied) return;
    // final token = await messaging.getToken();
    // if (token != null) await auth.api.setFcmToken(token);
    // FirebaseMessaging.instance.onTokenRefresh.listen((t) => auth.api.setFcmToken(t));
  }
}
