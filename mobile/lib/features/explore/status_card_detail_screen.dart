import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../data/static_explore_content.dart';
import '../../models/models.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_cinematic_components.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_poster_placeholder.dart';

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
  bool _saved = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (StaticExploreContent.isStaticId(widget.cardId)) {
      StatusCardModel c;
      try {
        c = StaticExploreContent.statusCards.firstWhere((x) => x.id == widget.cardId);
      } catch (_) {
        c = StaticExploreContent.statusCards.first;
      }
      if (mounted) setState(() { _card = c; _loading = false; });
      return;
    }
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

  Future<void> _save() async {
    if (StaticExploreContent.isStaticId(widget.cardId)) {
      setState(() => _saved = true);
      return;
    }
    setState(() => _saving = true);
    try {
      if (_saved) {
        await context.read<AuthProvider>().api.unsaveStatusCard(widget.cardId);
      } else {
        await context.read<AuthProvider>().api.saveStatusCard(widget.cardId);
      }
      if (mounted) setState(() => _saved = !_saved);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return TfiScaffold(
        child: Column(
          children: [
            const TfiDetailAppBar(title: 'Status Card'),
            Expanded(
              child: Shimmer.fromColors(
                baseColor: TfiTokens.card1,
                highlightColor: TfiTokens.card3,
                child: const Padding(padding: EdgeInsets.all(16), child: TfiShimmerCard(height: 360)),
              ),
            ),
          ],
        ),
      );
    }
    final c = _card;
    if (c == null) {
      return TfiScaffold(
        child: Column(
          children: [
            TfiDetailAppBar(title: 'Status Card', onBack: () => context.pop()),
            const Expanded(child: ErrorState(message: 'Status card not found')),
          ],
        ),
      );
    }

    return TfiScaffold(
      child: Column(
        children: [
          TfiDetailAppBar(title: 'Status Card', onBack: () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 0, TfiTokens.padScreen, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(TfiTokens.rHero),
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: c.imageUrl != null && c.imageUrl!.isNotEmpty
                          ? TfiNetworkImage(url: c.imageUrl, fit: BoxFit.cover, placeholderKind: TfiPlaceholderKind.statusCard, placeholderTitle: c.title)
                          : TfiPosterPlaceholder(kind: TfiPlaceholderKind.statusCard, title: c.title, icon: Icons.chat_bubble_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(c.title ?? 'Status card', style: TfiTokens.display(22, color: TfiTokens.textHi)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      TfiBadge('FREE'),
                      if (c.category != null) TfiTagChip(label: c.category!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TfiGlassPanel(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameCtrl,
                          style: TfiTokens.body(14, color: TfiTokens.textHi),
                          decoration: InputDecoration(
                            labelText: 'Your name (optional)',
                            labelStyle: TfiTokens.body(12, color: TfiTokens.textLo),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TfiTokens.line)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _textCtrl,
                          maxLength: 80,
                          style: TfiTokens.body(14, color: TfiTokens.textHi),
                          decoration: InputDecoration(
                            labelText: 'Custom text (optional)',
                            labelStyle: TfiTokens.body(12, color: TfiTokens.textLo),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TfiTokens.line)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TfiSecondaryButton(label: 'Apply customize', onPressed: _customize),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TfiPrimaryButton(label: 'Download', icon: Icons.download_rounded, onPressed: _download),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TfiSecondaryButton(label: 'Share', icon: Icons.share_rounded, onPressed: _share)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TfiSecondaryButton(
                          label: _saved ? 'Saved' : 'Save',
                          icon: _saved ? Icons.bookmark : Icons.bookmark_outline,
                          onPressed: _saving ? () {} : _save,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
