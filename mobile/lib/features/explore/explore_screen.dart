import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/models.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_widgets.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<WallpaperModel> _wallpapers = [];
  List<StatusCardModel> _cards = [];
  List<MovieModel> _movies = [];
  List<HeroModel> _heroes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = context.read<AuthProvider>().api;
      final results = await Future.wait([
        api.getWallpapers(),
        api.getStatusCards(),
        api.getMovies(),
        api.getHeroes(),
      ]);
      if (mounted) {
        setState(() {
          _wallpapers = results[0] as List<WallpaperModel>;
          _cards = results[1] as List<StatusCardModel>;
          _movies = results[2] as List<MovieModel>;
          _heroes = results[3] as List<HeroModel>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Explore', style: TfiTokens.display(26, color: TfiTokens.fire)),
                      Text('Wallpapers · Cards · Movies · Heroes — all FREE', style: TfiTokens.body(12, color: TfiTokens.green, w: FontWeight.w700)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.search, color: TfiTokens.textHi), onPressed: () => context.push('/search')),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            labelColor: TfiTokens.fire,
            unselectedLabelColor: TfiTokens.textLo,
            indicatorColor: TfiTokens.fire,
            tabs: const [
              Tab(text: 'Wallpapers'),
              Tab(text: 'Cards'),
              Tab(text: 'Movies'),
              Tab(text: 'Heroes'),
              Tab(text: 'Archive'),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _wallpaperGrid(),
                      _cardGrid(),
                      _movieList(),
                      _heroList(),
                      Center(
                        child: PrimaryButton(
                          label: 'View all TFI updates',
                          onPressed: () => context.push('/updates'),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _wallpaperGrid() {
    if (_wallpapers.isEmpty) return const EmptyState(message: 'No wallpapers yet', icon: '🖼️');
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.7),
      itemCount: _wallpapers.length,
      itemBuilder: (_, i) {
        final w = _wallpapers[i];
        return GestureDetector(
          onTap: () => context.push('/wallpapers/${w.id}'),
          child: TfiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: TfiNetworkImage(url: w.imageUrl, height: double.infinity)),
                const SizedBox(height: 6),
                Text(w.title ?? 'Wallpaper', maxLines: 1, overflow: TextOverflow.ellipsis, style: TfiTokens.body(11, color: TfiTokens.textHi)),
                Text('FREE', style: TfiTokens.body(9, color: TfiTokens.green, w: FontWeight.w800)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cardGrid() {
    if (_cards.isEmpty) return const EmptyState(message: 'No status cards yet', icon: '💬');
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.7),
      itemCount: _cards.length,
      itemBuilder: (_, i) {
        final c = _cards[i];
        return GestureDetector(
          onTap: () => context.push('/status-cards/${c.id}'),
          child: TfiCard(
            child: Column(
              children: [
                Expanded(child: TfiNetworkImage(url: c.imageUrl, height: double.infinity)),
                Text(c.title ?? 'Card', style: TfiTokens.body(11, color: TfiTokens.textHi)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _movieList() {
    if (_movies.isEmpty) return const EmptyState(message: 'No movies yet', icon: '🎬');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movies.length,
      itemBuilder: (_, i) {
        final m = _movies[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TfiCard(
            child: ListTile(
              leading: Text(m.iconEmoji ?? '🎬', style: const TextStyle(fontSize: 28)),
              title: Text(m.title, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w600)),
              subtitle: Text(m.daysToRelease != null ? '${m.daysToRelease} days' : m.status ?? '', style: TfiTokens.body(12, color: TfiTokens.gold)),
              onTap: () => context.push('/movies/${m.id}'),
            ),
          ),
        );
      },
    );
  }

  Widget _heroList() {
    if (_heroes.isEmpty) return const EmptyState(message: 'No heroes yet', icon: '⭐');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _heroes.length,
      itemBuilder: (_, i) {
        final h = _heroes[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TfiCard(
            child: ListTile(
              leading: Text(h.iconEmoji ?? '⭐', style: const TextStyle(fontSize: 28)),
              title: Text(h.name, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w600)),
              subtitle: Text(h.teluguName ?? '', style: TfiTokens.telugu(12, color: TfiTokens.textMid)),
              onTap: () => context.push('/heroes/${h.id}'),
            ),
          ),
        );
      },
    );
  }
}
