import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/update_actions.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../models/models.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_widgets.dart';
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

  TFIUpdateModel _withSave(TFIUpdateModel u) {
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.displayName;
    final heroId = auth.user?.favouriteHeroId;

    return TfiScreen(
      child: RefreshIndicator(
        onRefresh: _load,
        color: TfiTokens.fire,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Today in TFI', style: TfiTokens.display(26, color: TfiTokens.fire)),
                          Text('Hi $name · Eeroju cinema updates ikkada', style: TfiTokens.telugu(13, color: TfiTokens.textMid)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.search, color: TfiTokens.textHi), onPressed: () => context.push('/search')),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _chip('All', () => context.push('/updates')),
                    _chip('My Hero', () {
                      if (heroId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Select a favourite hero in Profile for My Hero updates')),
                        );
                        context.push('/profile/favourite-hero');
                      } else {
                        context.push('/updates?hero_id=$heroId');
                      }
                    }),
                    _chip('View All Updates', () => context.push('/updates')),
                  ],
                ),
              ),
            ),
            if (_loading)
              SliverToBoxAdapter(child: _skeleton())
            else if (_error != null)
              SliverFillRemaining(child: ErrorState(message: _error!, onRetry: _load))
            else if (_feed != null)
              ..._feed!.sections.expand((s) => _sectionSlivers(context, s)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: ActionChip(
        label: Text(label, style: TfiTokens.body(12, color: TfiTokens.textHi)),
        onPressed: onTap,
        backgroundColor: TfiTokens.bg2,
        side: const BorderSide(color: TfiTokens.line),
      ),
    );
  }

  Widget _skeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: TfiTokens.bg2,
        highlightColor: TfiTokens.line,
        child: Column(
          children: List.generate(
            3,
            (_) => Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: TfiTokens.bg2, borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _sectionSlivers(BuildContext context, HomeSectionModel section) {
    if (section.items.isEmpty) return [];
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section.title, style: TfiTokens.display(20, color: TfiTokens.textHi)),
              if (section.subtitle != null) Text(section.subtitle!, style: TfiTokens.telugu(12, color: TfiTokens.textLo)),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final item = section.items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _itemWidget(context, section.type, item, i),
              );
            },
            childCount: section.items.length,
          ),
        ),
      ),
    ];
  }

  Widget _itemWidget(BuildContext context, String sectionType, Map<String, dynamic> item, int position) {
    final ct = item['content_type'] as String? ?? 'update';

    if (ct == 'update' || sectionType.contains('update') || sectionType == 'today_in_tfi') {
      var u = TFIUpdateModel.fromJson(item);
      u = _withSave(u);
      context.read<AuthProvider>().events.trackCardViewed(
            contentType: 'update',
            contentId: u.id,
            sourceScreen: 'home',
            position: position,
          );
      return UpdateCard(
        update: u,
        raw: item,
        onTap: () => context.push('/updates/${u.id}'),
        onSave: () async {
          final saved = await UpdateActions.toggleSave(context, u);
          setState(() {
            if (saved) {
              _savedOverrides.add(u.id);
            } else {
              _savedOverrides.remove(u.id);
            }
          });
        },
        onShare: () => UpdateActions.share(context, u),
        onSetAlert: () => UpdateActions.setAlert(context, item),
      );
    }

    if (ct == 'movie' || sectionType == 'upcoming_releases' || sectionType == 'movie_calendar') {
      final m = MovieModel.fromJson(item);
      return TfiCard(
        child: ListTile(
          leading: Text(m.iconEmoji ?? '🎬', style: const TextStyle(fontSize: 28)),
          title: Text(m.title, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w700)),
          subtitle: Text(
            m.daysToRelease != null ? '${m.daysToRelease} days to release' : m.status ?? '',
            style: TfiTokens.body(12, color: TfiTokens.gold),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: TfiTokens.gold),
            onPressed: () async {
              try {
                await context.read<AuthProvider>().api.createReminder({
                  'reminder_type': 'movie_release',
                  'title': m.title,
                  'movie_id': m.id,
                  'event_datetime': m.releaseDate?.toIso8601String(),
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Release alert set')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
                }
              }
            },
          ),
          onTap: () => context.push('/movies/${m.id}'),
        ),
      );
    }

    if (ct == 'poll' || sectionType == 'poll_preview') {
      final p = PollModel.fromJson(item);
      context.read<AuthProvider>().events.trackPollImpression(p.id, 'home');
      return TfiCard(
        child: ListTile(
          title: Text(p.question, style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w600)),
          subtitle: Text('${p.type} · ${p.totalVotes ?? 0} votes', style: TfiTokens.body(11, color: TfiTokens.textLo)),
          trailing: const Icon(Icons.how_to_vote, color: TfiTokens.fire),
          onTap: () => context.push('/polls/${p.id}'),
        ),
      );
    }

    if (ct == 'wallpaper' || ct == 'status_card' || sectionType == 'explore_preview') {
      return TfiCard(
        child: ListTile(
          leading: const Icon(Icons.image, color: TfiTokens.gold),
          title: Text(item['title'] as String? ?? 'Explore', style: TfiTokens.body(14, color: TfiTokens.textHi)),
          subtitle: const Text('Free', style: TextStyle(color: TfiTokens.green, fontSize: 11)),
          onTap: () => context.go('/explore'),
        ),
      );
    }

    if (ct == 'quiz_daily' || ct == 'quiz_category' || sectionType == 'quiz_preview') {
      return TfiCard(
        child: ListTile(
          leading: const Icon(Icons.quiz, color: TfiTokens.fire),
          title: Text(item['title'] as String? ?? "Today's TFI Trivia", style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w700)),
          trailing: const Icon(Icons.play_arrow, color: TfiTokens.fire),
          onTap: () => context.go('/quiz'),
        ),
      );
    }

    final title = item['title']?.toString() ?? sectionType;
    return TfiCard(child: Text(title, style: TfiTokens.body(14, color: TfiTokens.textHi)));
  }
}
