import 'dart:io';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// WhatsApp-first sharing with fallbacks when the app is not installed.
class WhatsAppShareService {
  WhatsAppShareService._();

  static const _channel = MethodChannel('com.example.tfi_bagundali/whatsapp_share');

  /// Share an image to WhatsApp (Status on Android when [toStatus] is true).
  static Future<void> shareImage({
    required String imagePath,
    String? caption,
    bool toStatus = true,
  }) async {
    if (Platform.isAndroid) {
      await _shareAndroid(imagePath: imagePath, caption: caption, toStatus: toStatus);
    } else if (Platform.isIOS) {
      await _shareIOS(imagePath: imagePath, caption: caption);
    }
  }

  static Future<void> shareText(String text) async {
    final encoded = Uri.encodeComponent(text);
    final uri = Uri.parse('whatsapp://send?text=$encoded');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Share.share(text);
    }
  }

  static Future<void> _shareAndroid({
    required String imagePath,
    String? caption,
    required bool toStatus,
  }) async {
    try {
      await _channel.invokeMethod<void>('shareImageToWhatsApp', {
        'filePath': imagePath,
        'caption': caption ?? '',
        'toStatus': toStatus,
      });
    } on PlatformException catch (e) {
      if (e.code == 'WHATSAPP_NOT_INSTALLED') {
        await Share.shareXFiles([XFile(imagePath)], text: caption);
      } else {
        rethrow;
      }
    }
  }

  static Future<void> _shareIOS({
    required String imagePath,
    String? caption,
  }) async {
    await Share.shareXFiles([XFile(imagePath)], text: caption);
  }
}
