import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

const _exploreChips = ['All', 'Movies', 'Heroes', 'Events', 'Quotes', 'FDFS', 'Birthday'];

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _chipIndex = 0;
  List<WallpaperModel> _wallpapers = [];
  List<StatusCardModel> _cards = [];
  List<MovieModel> _movies = [];
  List<HeroModel> _heroes = [];
  bool _loading = true;
  String? _error;

  String get _chip => _exploreChips[_chipIndex];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
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
          _wallpapers = StaticExploreContent.mergeWallpapers(results[0] as List<WallpaperModel>);
          _cards = StaticExploreContent.mergeStatusCards(results[1] as List<StatusCardModel>);
          _movies = results[2] as List<MovieModel>;
          _heroes = results[3] as List<HeroModel>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = userFacingError(e);
          _wallpapers = StaticExploreContent.wallpapers;
          _cards = StaticExploreContent.statusCards;
          _loading = false;
        });
      }
    }
  }

  bool _matchCategory(String? cat) {
    if (cat == null) return false;
    final c = cat.toUpperCase();
    return switch (_chip) {
      'Events' => c.contains('EVENT'),
      'Quotes' => c.contains('QUOTE'),
      'FDFS' => c.contains('FDFS') || c.contains('FIRST'),
      'Birthday' => c.contains('BIRTHDAY') || c.contains('BDAY'),
      _ => true,
    };
  }

  List<WallpaperModel> get _filteredWallpapers {
    if (_chip == 'Movies' || _chip == 'Heroes') return [];
    if (_chip == 'All') return _wallpapers;
    return _wallpapers.where((w) => _matchCategory(w.category)).toList();
  }

  List<StatusCardModel> get _filteredCards {
    if (_chip == 'Movies' || _chip == 'Heroes') return [];
    if (_chip == 'All') return _cards;
    return _cards.where((c) => _matchCategory(c.category)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return TfiScaffold(
      child: RefreshIndicator(
        onRefresh: _load,
        color: TfiTokens.gold,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 12, TfiTokens.padScreen, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Explore', style: TfiTokens.display(26, color: TfiTokens.gold)),
                          Text('Wallpapers · Cards · Movies · Heroes', style: TfiTokens.telugu(12, color: TfiTokens.textLo)),
                        ],
                      ),
                    ),
                    Material(
                      color: TfiTokens.glass,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => context.push('/search'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: TfiTokens.line),
                          ),
                          child: const Icon(Icons.search_rounded, size: 20, color: TfiTokens.textMid),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: TfiFilterChipRow(
                  labels: _exploreChips,
                  selectedIndex: _chipIndex,
                  onSelected: (i) => setState(() => _chipIndex = i),
                ),
              ),
            ),
            if (_loading)
              SliverToBoxAdapter(child: _buildShimmer())
            else if (_error != null && _wallpapers.isEmpty && _cards.isEmpty)
              SliverToBoxAdapter(child: ErrorState(message: _error!, onRetry: _load))
            else
              ..._buildContentSlivers(),
            const SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(TfiTokens.padScreen),
      child: Shimmer.fromColors(
        baseColor: TfiTokens.card1,
        highlightColor: TfiTokens.card3,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: 6,
          itemBuilder: (_, _) => const TfiShimmerCard(height: 200),
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers() {
    if (_chip == 'Movies') {
      return [_movieListSliver(_movies)];
    }
    if (_chip == 'Heroes') {
      return [_heroListSliver(_heroes)];
    }

    final slivers = <Widget>[];
    final walls = _filteredWallpapers;
    final cards = _filteredCards;

    if (walls.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: TfiSectionHeader(title: 'Wallpapers', subtitle: 'Download & share — FREE'),
        ),
      );
      slivers.add(_wallpaperGridSliver(walls));
    }
    if (cards.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: TfiSectionHeader(title: 'Status Cards', subtitle: 'WhatsApp-ready — FREE'),
        ),
      );
      slivers.add(_cardGridSliver(cards));
    }
    if (_chip == 'All') {
      if (_movies.isNotEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: TfiSectionHeader(
              title: 'Movies',
              actionLabel: 'See all',
              onAction: () => setState(() => _chipIndex = 1),
            ),
          ),
        );
        slivers.add(_movieListSliver(_movies.take(8).toList()));
      }
      if (_heroes.isNotEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: TfiSectionHeader(
              title: 'Heroes',
              actionLabel: 'See all',
              onAction: () => setState(() => _chipIndex = 2),
            ),
          ),
        );
        slivers.add(_heroListSliver(_heroes.take(8).toList()));
      }
    }

    if (slivers.isEmpty) {
      slivers.add(
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: EmptyState(message: 'Nothing here yet — try another category', icon: '🎬'),
          ),
        ),
      );
    }
    return slivers;
  }

  SliverPadding _wallpaperGridSliver(List<WallpaperModel> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final w = items[i];
            return TfiExplorePosterCell(
              title: w.title ?? 'Wallpaper',
              imageUrl: w.imageUrl,
              onTap: () => context.push('/wallpapers/${w.id}'),
              placeholderKind: TfiPlaceholderKind.wallpaper,
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  SliverPadding _cardGridSliver(List<StatusCardModel> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final c = items[i];
            return TfiExplorePosterCell(
              title: c.title ?? 'Status card',
              imageUrl: c.imageUrl,
              onTap: () => context.push('/status-cards/${c.id}'),
              placeholderKind: TfiPlaceholderKind.statusCard,
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  SliverList _movieListSliver(List<MovieModel> items) {
    if (items.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          const Padding(padding: EdgeInsets.all(32), child: EmptyState(message: 'No movies yet', icon: '🎬')),
        ]),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          final m = items[i];
          return Padding(
            padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 0, TfiTokens.padScreen, 10),
            child: TfiCard(
              onTap: () => context.push('/movies/${m.id}'),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 56,
                      height: 72,
                      child: m.posterUrl != null && m.posterUrl!.isNotEmpty
                          ? TfiNetworkImage(url: m.posterUrl, height: 72, fit: BoxFit.cover, placeholderKind: TfiPlaceholderKind.movie, placeholderTitle: m.title)
                          : TfiPosterPlaceholder(kind: TfiPlaceholderKind.movie, title: m.title, height: 72, icon: Icons.movie_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w800)),
                        if (m.heroName != null) Text(m.heroName!, style: TfiTokens.body(12, color: TfiTokens.textMid)),
                        Text(
                          m.daysToRelease != null ? '${m.daysToRelease} days to release' : (m.status ?? ''),
                          style: TfiTokens.body(11, color: TfiTokens.gold, w: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: TfiTokens.textFaint),
                ],
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  SliverList _heroListSliver(List<HeroModel> items) {
    if (items.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          const Padding(padding: EdgeInsets.all(32), child: EmptyState(message: 'No heroes yet', icon: '⭐')),
        ]),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          final h = items[i];
          return Padding(
            padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 0, TfiTokens.padScreen, 10),
            child: TfiCard(
              onTap: () => context.push('/heroes/${h.id}'),
              child: Row(
                children: [
                  TfiPosterPlaceholder(
                    kind: TfiPlaceholderKind.hero,
                    title: h.name,
                    width: 56,
                    height: 56,
                    borderRadius: BorderRadius.circular(12),
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h.name, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w800)),
                        if (h.teluguName != null) Text(h.teluguName!, style: TfiTokens.telugu(12, color: TfiTokens.textMid)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: TfiTokens.textFaint),
                ],
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}
