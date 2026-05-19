import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../models/models.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_widgets.dart';

class StatusCardDetailScreen extends StatefulWidget {
  const StatusCardDetailScreen({super.key, required this.cardId});
  final String cardId;

  @override
  State<StatusCardDetailScreen> createState() => _StatusCardDetailScreenState();
}

class _StatusCardDetailScreenState extends State<StatusCardDetailScreen> {
  StatusCardModel? _card;
  final _nameCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  bool _loading = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final c = await context.read<AuthProvider>().api.getStatusCard(widget.cardId);
      context.read<AuthProvider>().events.track('status_card_viewed', contentType: 'status_card', contentId: widget.cardId, sourceScreen: 'explore');
      if (mounted) setState(() { _card = c; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _download() async {
    try {
      await context.read<AuthProvider>().api.downloadStatusCard(widget.cardId);
      context.read<AuthProvider>().events.track('status_card_downloaded', contentType: 'status_card', contentId: widget.cardId, sourceScreen: 'explore');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status card download recorded — FREE')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    }
  }

  Future<void> _share() async {
    try {
      await context.read<AuthProvider>().api.shareStatusCard(widget.cardId);
      context.read<AuthProvider>().events.track('status_card_shared', contentType: 'status_card', contentId: widget.cardId, sourceScreen: 'explore');
      await Share.share('TFI Status Card — ${_card?.title ?? ''}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    }
  }

  Future<void> _customize() async {
    try {
      await context.read<AuthProvider>().api.customizeStatusCard(widget.cardId, {
        'name': _nameCtrl.text.trim(),
        'text': _textCtrl.text.trim(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customization saved')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customize: ${userFacingError(e)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const TfiScreen(child: Center(child: CircularProgressIndicator(color: TfiTokens.fire)));
    }
    final c = _card;
    if (c == null) {
      return TfiScreen(child: Center(child: Text('Not found', style: TfiTokens.body(16, color: TfiTokens.red))));
    }
    return TfiScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButtonCircle(onTap: () => context.pop()),
            const SizedBox(height: 12),
            TfiNetworkImage(url: c.imageUrl, height: 280),
            const SizedBox(height: 12),
            Text(c.title ?? 'Status card', style: TfiTokens.display(22, color: TfiTokens.textHi)),
            Text('FREE', style: TfiTokens.body(12, color: TfiTokens.green, w: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Your name (optional)')),
            TextField(controller: _textCtrl, decoration: const InputDecoration(labelText: 'Custom text (optional)'), maxLength: 80),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Apply customize', filled: false, onPressed: _customize),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: PrimaryButton(label: 'Download', onPressed: _download)),
                const SizedBox(width: 8),
                Expanded(child: PrimaryButton(label: 'Share', filled: false, onPressed: _share)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
