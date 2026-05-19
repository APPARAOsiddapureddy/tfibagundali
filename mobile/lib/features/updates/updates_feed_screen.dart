import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/update_actions.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../models/models.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_widgets.dart';
import '../../widgets/update_card.dart';

class UpdatesFeedScreen extends StatefulWidget {
  const UpdatesFeedScreen({super.key, this.initialCategory, this.initialHeroId});

  final String? initialCategory;
  final String? initialHeroId;

  @override
  State<UpdatesFeedScreen> createState() => _UpdatesFeedScreenState();
}

class _UpdatesFeedScreenState extends State<UpdatesFeedScreen> {
  final _items = <Map<String, dynamic>>[];
  final _scroll = ScrollController();
  final _search = TextEditingController();
  String _category = 'all';
  String _sort = 'latest';
  String? _status;
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  final Set<String> _saved = {};

  static const _filters = [
    ('all', 'All'),
    ('official', 'Official'),
    ('my_hero', 'My Hero'),
    ('release_date', 'Releases'),
    ('trailer', 'Trailers'),
    ('song', 'Songs'),
    ('movie_launch', 'Launches'),
    ('director_hero_collab', 'Collabs'),
    ('event', 'Events'),
    ('ott_update', 'OTT'),
    ('box_office', 'Box Office'),
    ('birthday', 'Birthdays'),
    ('buzz', 'Buzz'),
  ];

  static const _sorts = [
    ('latest', 'Latest'),
    ('trending', 'Trending'),
    ('most_reacted', 'Most Reacted'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) _category = widget.initialCategory!;
    _scroll.addListener(_onScroll);
    _load(refresh: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  String? get _heroFilter {
    if (_category == 'my_hero') {
      return context.read<AuthProvider>().user?.favouriteHeroId ?? widget.initialHeroId;
    }
    return widget.initialHeroId;
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _items.clear();
    }
    setState(() {
      _loading = refresh;
      _error = null;
    });
    try {
      final cat = _category == 'my_hero' ? null : (_category == 'all' ? null : _category);
      final st = _category == 'official' ? 'official' : (_category == 'buzz' ? 'buzz' : _status);
      final data = await context.read<AuthProvider>().api.getUpdatesList(
            category: cat,
            status: st,
            heroId: _heroFilter,
            q: _search.text.trim().isEmpty ? null : _search.text.trim(),
            sort: _sort,
            page: _page,
          );
      final list = (data['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (mounted) {
        setState(() {
          if (refresh) {
            _items.clear();
          }
          _items.addAll(list);
          _hasMore = list.length >= 20;
          _loading = false;
        });
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

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    setState(() => _loadingMore = true);
    _page++;
    await _load(refresh: false);
    if (mounted) setState(() => _loadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                Expanded(child: Text('TFI Updates', style: TfiTokens.display(22, color: TfiTokens.fire))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              style: TfiTokens.body(15, color: TfiTokens.textHi),
              decoration: InputDecoration(
                hintText: 'Search updates...',
                prefixIcon: const Icon(Icons.search, color: TfiTokens.fire),
                filled: true,
                fillColor: TfiTokens.bg2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) {
                context.read<AuthProvider>().events.track('search_performed', sourceScreen: 'updates_feed', metadata: {'q': _search.text});
                _load(refresh: true);
              },
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _filters.map((f) {
                final on = _category == f.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(f.$2, style: TfiTokens.body(11, color: on ? Colors.white : TfiTokens.textMid)),
                    selected: on,
                    onSelected: (_) {
                      setState(() => _category = f.$1);
                      _load(refresh: true);
                    },
                    selectedColor: TfiTokens.fire,
                    backgroundColor: TfiTokens.bg2,
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: _sorts.map((s) {
                final on = _sort == s.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(s.$2),
                    selected: on,
                    onSelected: (_) {
                      setState(() => _sort = s.$1);
                      _load(refresh: true);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _loading && _items.isEmpty
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                : _error != null && _items.isEmpty
                    ? ErrorState(message: _error!, onRetry: () => _load(refresh: true))
                    : _items.isEmpty
                        ? const EmptyState(message: 'No updates found for this filter')
                        : RefreshIndicator(
                            onRefresh: () => _load(refresh: true),
                            color: TfiTokens.fire,
                            child: ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.all(16),
                              itemCount: _items.length + (_loadingMore ? 1 : 0),
                              itemBuilder: (_, i) {
                                if (i >= _items.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: CircularProgressIndicator(color: TfiTokens.fire)),
                                  );
                                }
                                final raw = _items[i];
                                var u = TFIUpdateModel.fromJson(raw);
                                if (_saved.contains(u.id)) {
                                  u = TFIUpdateModel(
                                    id: u.id,
                                    title: u.title,
                                    shortSummary: u.shortSummary,
                                    category: u.category,
                                    status: u.status,
                                    imageUrl: u.imageUrl,
                                    hero: u.hero,
                                    movie: u.movie,
                                    publishedAt: u.publishedAt,
                                    reactions: u.reactions,
                                    isSaved: true,
                                  );
                                }
                                context.read<AuthProvider>().events.trackCardViewed(
                                      contentType: 'update',
                                      contentId: u.id,
                                      sourceScreen: 'updates_feed',
                                      position: i,
                                    );
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: UpdateCard(
                                    update: u,
                                    raw: raw,
                                    onTap: () => context.push('/updates/${u.id}'),
                                    onSave: () async {
                                      final ok = await UpdateActions.toggleSave(context, u);
                                      setState(() => ok ? _saved.add(u.id) : _saved.remove(u.id));
                                    },
                                    onShare: () => UpdateActions.share(context, u),
                                    onSetAlert: () => UpdateActions.setAlert(context, raw),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
