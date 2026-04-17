import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../network/api_client.dart';
import '../router/navigation_service.dart';
import '../../features/auth/providers/auth_provider.dart';

final _local = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background FCM: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static var _initialized = false;

  static Future<void> initialize(WidgetRef ref) async {
    if (_initialized) return;
    try {
      await _requestPermission();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      const settings = InitializationSettings(android: android, iOS: ios);

      await _local.initialize(
        settings,
        onDidReceiveNotificationResponse: (resp) {
          _handlePayload(resp.payload);
        },
      );

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final notification = message.notification;
        if (notification == null) return;
        const androidDetails = AndroidNotificationDetails(
          'tfi_bagundali_channel',
          'TFI Bagundali Alerts',
          channelDescription: 'Quiz reminders and movie alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          channelShowBadge: true,
        );
        const details = NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );
        await _local.show(
          notification.hashCode,
          notification.title ?? 'TFI Bagundali',
          notification.body ?? '',
          details,
          payload: jsonEncode(message.data),
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) => _handleData(m.data));

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleData(initial.data);
        });
      }

      final api = ref.read(apiClientProvider);
      await _syncToken(api);

      FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
        await _syncToken(api, token: t);
      });

      _initialized = true;
    } catch (_) {
      // Firebase / Play Services may be absent.
    }
  }

  static Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  static Future<void> _syncToken(ApiClient api, {String? token}) async {
    try {
      final t = token ?? await FirebaseMessaging.instance.getToken();
      if (t == null || t.isEmpty) return;
      await api.patch('/auth/me', body: {'fcm_token': t});
      debugPrint('FCM token synced to backend');
    } catch (e) {
      debugPrint('FCM token sync failed: $e');
    }
  }

  static Future<void> requestAfterOnboard(WidgetRef ref) async {
    try {
      await initialize(ref);
    } catch (_) {}
  }

  static void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final map = jsonDecode(payload);
      if (map is Map<String, dynamic>) {
        _handleData(map);
      }
    } catch (_) {}
  }

  static void _handleData(Map<String, dynamic> data) {
    final screen = data['screen']?.toString();
    final id = data['id']?.toString();
    switch (screen) {
      case 'quiz':
        NavigationService.navigateTo('/home/quiz');
        break;
      case 'movie':
        if (id != null) NavigationService.navigateTo('/movie/$id');
        break;
      case 'fanarmy':
        NavigationService.navigateTo('/home/army');
        break;
      case 'profile':
        NavigationService.navigateTo('/home/profile');
        break;
      default:
        break;
    }
  }
}
