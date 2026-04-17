import '../../core/sharing/whatsapp_share_service.dart';

class WaShareButton {
  static Future<void> shareText(String text) async {
    await WhatsAppShareService.shareText(text);
  }
}
