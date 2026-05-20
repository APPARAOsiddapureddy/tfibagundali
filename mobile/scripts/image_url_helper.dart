/// Image URL helper for TFI Bagundali.
///
/// Uses Amazon's IMDB CDN server-side image processing to generate
/// optimized image URLs without downloading or resizing locally.
///
/// ## Amazon CDN URL Parameters (undocumented but widely used):
///   _V1_               → Start of processing instructions
///   QL{n}               → JPEG quality (0–100)
///   UX{n}               → Resize to width n (maintains aspect ratio)
///   UY{n}               → Resize to height n
///   CR{x},{y},{w},{h}   → Crop region from (x,y) with dimensions w×h
///   FMjpg               → Output format JPEG
///
/// ## Usage:
///   dart run scripts/image_url_helper.dart
///
/// ## NOTE FOR ADMINS:
///   In future, when adding new update/movie images, provide:
///   - A landscape still (16:9) for feed cards
///   - A portrait poster (2:3) for trending tiles and release posters
///   Use the helper functions below to generate optimized CDN URLs.
///   The admin panel should let you preview the image at the target
///   ratio before publishing.
library;

/// Extracts the base image ID from an Amazon IMDB image URL.
///
/// Example input:
///   https://m.media-amazon.com/images/M/MV5BNGI2...@._V1_FMjpg_UX1000_.jpg
/// Returns:
///   MV5BNGI2...@
String extractImageId(String url) {
  // Match the image ID between /M/ and ._V1
  final match = RegExp(r'/M/([^/]+)\._V1').firstMatch(url);
  if (match != null) return match.group(1)!;

  // Fallback: try to find the ID pattern
  final fallback = RegExp(r'(MV5[A-Za-z0-9@._+-]+)').firstMatch(url);
  if (fallback != null) return fallback.group(1)!;

  throw ArgumentError('Cannot extract image ID from URL: $url');
}

/// Generates a feed card image URL (16:9 landscape, 800px wide).
///
/// Best used with **landscape movie stills** (not portrait posters).
/// The CDN resizes to 800px width; BoxFit.cover in the app handles
/// the final 16:9 crop.
String feedCardUrl(String baseUrl, {int width = 800, int quality = 75}) {
  final id = extractImageId(baseUrl);
  return 'https://m.media-amazon.com/images/M/$id._V1_QL${quality}_UX${width}_.jpg';
}

/// Generates a poster image URL (portrait, for trending tiles & releases).
///
/// Best used with **portrait movie posters** (2:3 ratio).
String posterUrl(String baseUrl, {int width = 400, int quality = 80}) {
  final id = extractImageId(baseUrl);
  return 'https://m.media-amazon.com/images/M/$id._V1_QL${quality}_UX${width}_.jpg';
}

/// Generates a thumbnail image URL (small, square-ish).
///
/// Useful for notification icons, small avatars, etc.
String thumbnailUrl(String baseUrl, {int size = 200, int quality = 70}) {
  final id = extractImageId(baseUrl);
  return 'https://m.media-amazon.com/images/M/$id._V1_QL${quality}_UX${size}_.jpg';
}

/// Generates a cropped image URL with exact dimensions.
///
/// Uses the CR (crop) parameter to get a specific region.
/// The crop is applied AFTER the UX resize.
String croppedUrl(
  String baseUrl, {
  required int width,
  required int height,
  int cropX = 0,
  int cropY = 0,
  int quality = 75,
}) {
  final id = extractImageId(baseUrl);
  return 'https://m.media-amazon.com/images/M/$id._V1_QL${quality}_UX${width}_CR$cropX,$cropY,$width,${height}_.jpg';
}

// ─── Demo / CLI runner ──────────────────────────────────────────

void main() {
  print('╔══════════════════════════════════════════════════╗');
  print('║     TFI Bagundali — Image URL Helper             ║');
  print('╚══════════════════════════════════════════════════╝\n');

  // ── Movie-specific base URLs (raw, full resolution) ──
  final movies = {
    'Peddi (Landscape Still)':
        'https://m.media-amazon.com/images/M/MV5BNGI2MmNhNzktNWJkMC00YmM0LTgzNzktMDY3MzZjYjNlOTU3XkEyXkFqcGc@._V1_.jpg',
    'Peddi (Poster)':
        'https://m.media-amazon.com/images/M/MV5BNWEzOTBlNmUtOGMzNy00ZGZiLWJmNTMtYjRlNzE2YWFmZWI3XkEyXkFqcGc@._V1_.jpg',
    'Devara 2 (Landscape Still)':
        'https://m.media-amazon.com/images/M/MV5BZTU2MmQwZGYtMmEwZC00MzA3LTliYmYtN2MzZjc3NTI1MmM5XkEyXkFqcGc@._V1_.jpg',
    'Spirit (Landscape Still)':
        'https://m.media-amazon.com/images/M/MV5BOGY5NThjZmItNjJlMC00NTc5LTgxMGYtYTgxMDM2N2EzNWYzXkEyXkFqcGc@._V1_.jpg',
    'Spirit (Poster)':
        'https://m.media-amazon.com/images/M/MV5BNTc0YzJhM2YtNjJlYy00YjE2LThjMjAtNzM1MGJiMWUyOGJkXkEyXkFqcGc@._V1_.jpg',
    'Kuberaa (Landscape Still)':
        'https://m.media-amazon.com/images/M/MV5BMDRjZjY2YTMtMjJmMi00NzkyLWJjM2EtYTBhYTViMDczMDg5XkEyXkFqcGc@._V1_.jpg',
    'Kuberaa (Poster)':
        'https://m.media-amazon.com/images/M/MV5BYWYyZDEwZTEtMWZiMi00YzUwLTkwMzUtNzFmZDI5ZjhjYTYzXkEyXkFqcGc@._V1_.jpg',
  };

  for (final entry in movies.entries) {
    final name = entry.key;
    final url = entry.value;

    print('── $name ──');
    print('  Feed card (16:9, 800px): ${feedCardUrl(url)}');
    print('  Poster (400px):          ${posterUrl(url)}');
    print('  Thumbnail (200px):       ${thumbnailUrl(url)}');
    print('');
  }

  print('── Admin Notes ──');
  print('When adding new images, always provide:');
  print('  1. A landscape still (movie screenshot) for feed update cards');
  print('  2. A portrait poster for trending tiles & upcoming releases');
  print('  3. Use feedCardUrl() and posterUrl() to generate optimized URLs');
}
