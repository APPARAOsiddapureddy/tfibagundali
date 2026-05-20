import '../models/models.dart';

/// Curated static samples for UI preview (wallpapers, cards, explore tiles).
/// Uses placeholders when [imageUrl] is null — no hardcoded movie poster URLs.
abstract final class StaticExploreContent {
  static const bool alwaysIncludeStaticSamples = true;

  static List<WallpaperModel> get wallpapers => [
    const WallpaperModel(id: 'static-wp-1', title: 'Mass Hero Wallpaper', category: 'hero'),
    const WallpaperModel(id: 'static-wp-2', title: 'Peddi Countdown', category: 'countdown'),
    const WallpaperModel(id: 'static-wp-3', title: 'Fire Status Glow', category: 'hero'),
    const WallpaperModel(id: 'static-wp-4', title: 'TFI Pride Wallpaper', category: 'trending'),
  ];

  static List<StatusCardModel> get statusCards => [
    const StatusCardModel(id: 'static-sc-1', title: 'Mass Status Card', category: 'hero_status'),
    const StatusCardModel(id: 'static-sc-2', title: 'Release Countdown', category: 'countdown'),
    const StatusCardModel(id: 'static-sc-3', title: 'Fan Pride Card', category: 'quote'),
    const StatusCardModel(id: 'static-sc-4', title: 'Weekend Vibe', category: 'hero_status'),
  ];

  static List<Map<String, dynamic>> get explorePreviewItems => [
    {'id': 'static-wp-1', 'title': 'Wallpaper', 'content_type': 'wallpaper'},
    {'id': 'static-sc-1', 'title': 'Status Card', 'content_type': 'status_card'},
    {'id': 'static-wp-2', 'title': 'Countdown', 'content_type': 'wallpaper'},
    {'id': 'static-sc-2', 'title': 'Card', 'content_type': 'status_card'},
  ];

  static List<WallpaperModel> mergeWallpapers(List<WallpaperModel> fromApi) {
    if (!alwaysIncludeStaticSamples && fromApi.isNotEmpty) return fromApi;
    final seen = fromApi.map((w) => w.id).toSet();
    return [...fromApi, ...wallpapers.where((w) => !seen.contains(w.id))];
  }

  static List<StatusCardModel> mergeStatusCards(List<StatusCardModel> fromApi) {
    if (!alwaysIncludeStaticSamples && fromApi.isNotEmpty) return fromApi;
    final seen = fromApi.map((c) => c.id).toSet();
    return [...fromApi, ...statusCards.where((c) => !seen.contains(c.id))];
  }

  static bool isStaticId(String id) => id.startsWith('static-');
}
