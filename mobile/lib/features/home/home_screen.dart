import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/update_actions.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/tfi_responsive.dart';
import '../../core/utils/format_utils.dart';
import '../../models/models.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_cinematic_components.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_poster_placeholder.dart';
import '../../data/static_explore_content.dart';
import '../../widgets/update_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeFeedModel? _feed;
  bool _loading = true;
  String? _error;
  final Set<String> _savedOverrides = {};

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().events.trackAppOpened();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final feed = await context.read<AuthProvider>().api.getHomeFeed();
      if (mounted) {
        setState(() {
          _feed = feed;
          _loading = false;
        });
        context.read<AuthProvider>().events.track('home_feed_viewed', sourceScreen: 'home');
        context.read<AuthProvider>().events.cardImpressions.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = userFacingError(e);
          _loading = false;
        });
      }
    }
  }

  TFIUpdateModel _parseUpdate(Map<String, dynamic> j) {
    final u = TFIUpdateModel.fromJson(j);
    if (_savedOverrides.contains(u.id)) {
      return TFIUpdateModel(
        id: u.id,
        title: u.title,
        shortSummary: u.shortSummary,
        category: u.category,
        status: u.status,
        priority: u.priority,
        imageUrl: u.imageUrl,
        hero: u.hero,
        movie: u.movie,
        publishedAt: u.publishedAt,
        reactions: u.reactions,
        isSaved: true,
        hasReacted: u.hasReacted,
        reason: u.reason,
      );
    }
    return u;
  }

  void _openUpdate(String id) {
    context.push('/updates/$id');
  }

  @override
  Widget build(BuildContext context) {
    return TfiScaffold(
      child: RefreshIndicator(
        onRefresh: _load,
        color: TfiTokens.gold,
        child: _loading
            ? _buildSkeleton()
            : _error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      ErrorState(message: _error!, onRetry: _load),
                    ],
                  )
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: TfiHomeTopBar(
                          subtitle: _feed?.greeting?['subtitle'] as String? ?? 'Today in TFI',
                          onSearch: () => context.push('/search'),
                          onNotifications: () => context.push('/profile/notifications'),
                        ),
                      ),
                      ..._buildSectionSlivers(),
                      SliverToBoxAdapter(
                        child: SizedBox(height: TfiResponsive.scrollBottomPadding(context)),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(TfiTokens.padScreen),
      children: List.generate(
        4,
        (_) => Shimmer.fromColors(
          baseColor: TfiTokens.card1,
          highlightColor: TfiTokens.card3,
          child: const TfiShimmerCard(height: 180),
        ),
      ),
    );
  }

  List<Widget> _buildSectionSlivers() {
    final sections = _feed?.sections ?? [];
    if (sections.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: EmptyState(message: 'No updates yet — pull to refresh', icon: '🎬'),
          ),
        ),
      ];
    }

    return sections.map((section) {
      final items = section.items;
      if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

      return SliverList(
        delegate: SliverChildListDelegate([
          TfiSectionHeader(
            title: section.title,
            subtitle: section.subtitle,
            actionLabel: _viewAllLabel(section.type),
            onAction: _viewAllLabel(section.type) != null ? () => _onViewAll(section.type) : null,
          ),
          ..._buildSectionItems(section.type, items),
        ]),
      );
    }).toList();
  }

  String? _viewAllLabel(String type) {
    if (type.contains('update') || type == 'today_in_tfi' || type == 'trending_updates') {
      return 'View all';
    }
    if (type == 'explore_preview') return 'Explore';
    if (type == 'quiz_preview') return 'Quiz';
    if (type == 'poll_preview') return 'Polls';
    return null;
  }

  void _onViewAll(String type) {
    if (type.contains('quiz')) {
      context.go('/quiz');
    } else if (type.contains('poll')) {
      context.go('/polls');
    } else if (type.contains('explore')) {
      context.go('/explore');
    } else {
      context.push('/updates');
    }
  }

  List<Widget> _buildSectionItems(String type, List<Map<String, dynamic>> items) {
    final ctx = context;
    if (type == 'today_in_tfi' && items.isNotEmpty) {
      final j = items.first;
      final u = _parseUpdate(j);
      return [
        TfiImageCard(
          title: u.title,
          subtitle: u.shortSummary,
          imageUrl: u.imageUrl,
          badge: u.category,
          height: TfiResponsive.heroImageCardHeight(ctx),
          placeholderKind: TfiPlaceholderKind.update,
          onTap: () => _openUpdate(u.id),
          footer: TfiReactionRow(counts: _reactionMap(u.reactions)),
        ),
        _updateActionsRow(u),
      ];
    }

    if (type == 'breaking_updates' || type == 'trending_updates') {
      final cardW = TfiResponsive.horizontalCardWidth(ctx);
      return [
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final u = _parseUpdate(items[i]);
              return SizedBox(
                width: cardW,
                child: UpdateCard(
                  update: u,
                  raw: items[i],
                  compact: true,
                  onTap: () => _openUpdate(u.id),
                  onSave: () => _toggleSave(u),
                  onShare: () => UpdateActions.share(context, u),
                  onSetAlert: () => UpdateActions.setAlert(context, items[i]),
                ),
              );
            },
          ),
        ),
      ];
    }

    if (type == 'upcoming_releases' || type == 'movie_calendar') {
      return [
        SizedBox(
          height: TfiResponsive.horizontalRailHeight(ctx),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _MovieReleaseTile(item: items[i]),
          ),
        ),
      ];
    }

    if (type == 'quiz_preview') {
      final j = items.first;
      return [
        TfiCard(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1545), Color(0xFF121622), Color(0xFF1A2033)],
          ),
          onTap: () => context.go('/quiz'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TfiBadge('QUIZ', variant: 'QUIZ'),
              const SizedBox(height: 8),
              Text(
                j['title'] as String? ?? "Today's Movie Trivia",
                style: TfiTokens.title(16, w: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                j['subtitle'] as String? ?? 'Test your TFI knowledge',
                style: TfiTokens.body(12, color: TfiTokens.textLo),
              ),
              const SizedBox(height: 12),
              TfiPrimaryButton(label: 'Play Now', onPressed: () => context.go('/quiz')),
            ],
          ),
        ),
      ];
    }

    if (type == 'poll_preview') {
      final j = items.first;
      return [
        TfiCard(
          onTap: () {
            final id = j['id'] as String?;
            if (id != null) {
              context.push('/polls/$id');
            } else {
              context.go('/polls');
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TfiBadge('POLL', variant: 'POLL'),
              const SizedBox(height: 8),
              Text(
                j['question'] as String? ?? j['title'] as String? ?? 'Fan opinion poll',
                style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TfiSecondaryButton(
                  label: 'Vote Now',
                  onPressed: () {
                    final id = j['id'] as String?;
                    if (id != null) context.push('/polls/$id');
                  },
                ),
              ),
            ],
          ),
        ),
      ];
    }

    if (type == 'explore_preview') {
      final previewItems = items.isNotEmpty ? items : StaticExploreContent.explorePreviewItems;
      final thumbW = TfiResponsive.exploreThumbWidth(ctx);
      return [
        SizedBox(
          height: 156,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
            itemCount: previewItems.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final j = previewItems[i];
              final url = j['image_url'] as String? ?? j['thumbnail_url'] as String?;
              return GestureDetector(
                onTap: () {
                  final id = j['id'] as String?;
                  final kind = j['content_type'] as String? ?? j['type'] as String? ?? '';
                  if (id == null) {
                    context.go('/explore');
                    return;
                  }
                  if (kind.contains('status')) {
                    context.push('/status-cards/$id');
                  } else {
                    context.push('/wallpapers/$id');
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(TfiTokens.rCard),
                  child: SizedBox(
                    width: thumbW,
                    height: 156,
                    child: TfiNetworkImage(
                    url: url,
                    width: thumbW,
                    height: 156,
                    placeholderKind: TfiPlaceholderKind.wallpaper,
                    placeholderTitle: j['title'] as String?,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ];
    }

    // Default: vertical update cards (my hero, etc.)
    return items.map((j) {
      final u = _parseUpdate(j);
      return UpdateCard(
        update: u,
        raw: j,
        compact: type == 'my_hero_updates',
        onTap: () => _openUpdate(u.id),
        onSave: () => _toggleSave(u),
        onShare: () => UpdateActions.share(context, u),
        onSetAlert: () => UpdateActions.setAlert(context, j),
      );
    }).toList();
  }

  Map<String, int>? _reactionMap(ReactionCounts? r) {
    if (r == null) return null;
    return {'fire': r.fire, 'mass': r.mass, 'love': r.love, 'wait': r.wait, 'total': r.total};
  }

  Widget _updateActionsRow(TFIUpdateModel u) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionIcon(Icons.bookmark_outline, u.isSaved, () => _toggleSave(u)),
          _actionIcon(Icons.share_outlined, false, () => UpdateActions.share(context, u)),
          _actionIcon(Icons.notifications_active_outlined, false, () => UpdateActions.setAlert(context, {'id': u.id, 'title': u.title})),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, bool active, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: active ? TfiTokens.gold : TfiTokens.textMid),
    );
  }

  Future<void> _toggleSave(TFIUpdateModel u) async {
    final api = context.read<AuthProvider>().api;
    try {
      if (u.isSaved) {
        await api.unsaveUpdate(u.id);
        _savedOverrides.remove(u.id);
      } else {
        await api.saveUpdate(u.id);
        _savedOverrides.add(u.id);
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    }
  }
}

class _MovieReleaseTile extends StatelessWidget {
  const _MovieReleaseTile({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title = item['title'] as String? ?? item['title_telugu'] as String? ?? 'Movie';
    final poster = item['poster_url'] as String? ?? item['image_url'] as String?;
    final days = item['days_to_release'] as int?;
    final id = item['id'] as String?;

    final tileW = TfiResponsive.moviePosterTileWidth(context);

    return GestureDetector(
      onTap: id != null ? () => context.push('/movies/$id') : null,
      child: Container(
        width: tileW,
        decoration: BoxDecoration(
          color: TfiTokens.card1,
          borderRadius: BorderRadius.circular(TfiTokens.rCard),
          border: Border.all(color: TfiTokens.lineStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(TfiTokens.rCard)),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: TfiNetworkImage(
                  url: poster,
                  fit: BoxFit.cover,
                  placeholderKind: TfiPlaceholderKind.movie,
                  placeholderTitle: title,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TfiTokens.body(12, color: TfiTokens.textHi, w: FontWeight.w700),
                  ),
                  if (days != null) ...[
                    const SizedBox(height: 6),
                    TfiCountdownChip('$days days'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
