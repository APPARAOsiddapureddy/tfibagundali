import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/models.dart';
import '../../widgets/tfi_widgets.dart';
import '../../widgets/update_card.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});
  final String movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<AuthProvider>().api.getMovie(widget.movieId);
      context.read<AuthProvider>().events.track('movie_opened', contentType: 'movie', contentId: widget.movieId);
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const TfiScreen(child: Center(child: CircularProgressIndicator(color: TfiTokens.fire)));
    }

    final movieJson = _data?['movie'] as Map<String, dynamic>? ?? _data;
    if (movieJson == null) {
      return TfiScreen(child: Center(child: Text('Movie not found', style: TfiTokens.body(16, color: TfiTokens.red))));
    }

    final movie = MovieModel.fromJson(movieJson);
    final updates = (_data?['updates'] as List? ?? []).cast<Map>();

    return TfiScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButtonCircle(onTap: () => context.pop()),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(movie.iconEmoji ?? '🎬', style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title, style: TfiTokens.display(26, color: TfiTokens.textHi)),
                      if (movie.daysToRelease != null)
                        Text(
                          '${movie.daysToRelease} days to release',
                          style: TfiTokens.body(14, color: TfiTokens.gold, w: FontWeight.w700),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionTitle(title: 'Latest updates'),
            ...updates.take(5).map((u) {
              final m = Map<String, dynamic>.from(u);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: UpdateCard(
                  update: TFIUpdateModel.fromJson(m),
                  onTap: () => context.push('/updates/${m['id']}'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
