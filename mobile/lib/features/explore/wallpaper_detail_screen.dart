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

class WallpaperDetailScreen extends StatefulWidget {
  const WallpaperDetailScreen({super.key, required this.wallpaperId});
  final String wallpaperId;

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  WallpaperModel? _wallpaper;
  bool _loading = true;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (StaticExploreContent.isStaticId(widget.wallpaperId)) {
      WallpaperModel w;
      try {
        w = StaticExploreContent.wallpapers.firstWhere((x) => x.id == widget.wallpaperId);
      } catch (_) {
        w = StaticExploreContent.wallpapers.first;
      }
      if (mounted) setState(() { _wallpaper = w; _loading = false; });
      return;
    }
    try {
      final w = await context.read<AuthProvider>().api.getWallpaper(widget.wallpaperId);
      context.read<AuthProvider>().events.track('wallpaper_viewed', contentType: 'wallpaper', contentId: widget.wallpaperId, sourceScreen: 'explore');
      if (mounted) setState(() { _wallpaper = w; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _download() async {
    try {
      await context.read<AuthProvider>().api.downloadWallpaper(widget.wallpaperId);
      context.read<AuthProvider>().events.track('wallpaper_downloaded', contentType: 'wallpaper', contentId: widget.wallpaperId, sourceScreen: 'explore');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download saved to your account — FREE')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    }
  }

  Future<void> _share() async {
    try {
      await context.read<AuthProvider>().api.shareWallpaper(widget.wallpaperId);
      context.read<AuthProvider>().events.track('wallpaper_shared', contentType: 'wallpaper', contentId: widget.wallpaperId, sourceScreen: 'explore');
      final url = _wallpaper?.imageUrl ?? '';
      await Share.share('TFI Wallpaper — ${_wallpaper?.title ?? ''}\n$url');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    }
  }

  Future<void> _save() async {
    if (StaticExploreContent.isStaticId(widget.wallpaperId)) {
      setState(() => _saved = true);
      return;
    }
    setState(() => _saving = true);
    try {
      if (_saved) {
        await context.read<AuthProvider>().api.unsaveWallpaper(widget.wallpaperId);
      } else {
        await context.read<AuthProvider>().api.saveWallpaper(widget.wallpaperId);
      }
      if (mounted) setState(() => _saved = !_saved);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return TfiScaffold(
        child: Column(
          children: [
            const TfiDetailAppBar(title: 'Wallpaper'),
            Expanded(
              child: Shimmer.fromColors(
                baseColor: TfiTokens.card1,
                highlightColor: TfiTokens.card3,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: TfiShimmerCard(height: 400),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final w = _wallpaper;
    if (w == null) {
      return TfiScaffold(
        child: Column(
          children: [
            TfiDetailAppBar(title: 'Wallpaper', onBack: () => context.pop()),
            const Expanded(child: ErrorState(message: 'Wallpaper not found')),
          ],
        ),
      );
    }

    return TfiScaffold(
      child: Column(
        children: [
          TfiDetailAppBar(title: 'Wallpaper', onBack: () => context.pop()),
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
                      child: w.imageUrl != null && w.imageUrl!.isNotEmpty
                          ? TfiNetworkImage(url: w.imageUrl, fit: BoxFit.cover, placeholderKind: TfiPlaceholderKind.wallpaper, placeholderTitle: w.title)
                          : TfiPosterPlaceholder(kind: TfiPlaceholderKind.wallpaper, title: w.title, icon: Icons.wallpaper_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(w.title ?? 'Wallpaper', style: TfiTokens.display(22, color: TfiTokens.textHi)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      TfiBadge('FREE'),
                      if (w.category != null) TfiTagChip(label: w.category!),
                    ],
                  ),
                  const SizedBox(height: 20),
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
