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

class WallpaperDetailScreen extends StatefulWidget {
  const WallpaperDetailScreen({super.key, required this.wallpaperId});
  final String wallpaperId;

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  WallpaperModel? _wallpaper;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
          const SnackBar(content: Text('Download recorded — FREE wallpaper saved to your account')),
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const TfiScreen(child: Center(child: CircularProgressIndicator(color: TfiTokens.fire)));
    }
    final w = _wallpaper;
    if (w == null) {
      return TfiScreen(child: Center(child: Text('Not found', style: TfiTokens.body(16, color: TfiTokens.red))));
    }
    return TfiScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [BackButtonCircle(onTap: () => context.pop())]),
          ),
          Expanded(child: TfiNetworkImage(url: w.imageUrl, fit: BoxFit.contain)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.title ?? 'Wallpaper', style: TfiTokens.display(20, color: TfiTokens.textHi)),
                Text('FREE · ${w.category ?? 'GENERAL'}', style: TfiTokens.body(12, color: TfiTokens.green, w: FontWeight.w800)),
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
        ],
      ),
    );
  }
}
