import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_cinematic_components.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_poster_placeholder.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<dynamic> _all = [];
  bool _loading = true;

  static const _tabTypes = ['update', 'movie', 'wallpaper', 'status_card', 'poll'];
  static const _tabLabels = ['Updates', 'Movies', 'Wallpapers', 'Cards', 'Polls'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabTypes.length, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await context.read<AuthProvider>().api.getSaved();
      if (mounted) setState(() { _all = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _forTab(int index) {
    final type = _tabTypes[index];
    return _all
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((m) {
          final ct = (m['content_type'] as String? ?? m['item_type'] as String? ?? '').toLowerCase();
          if (type == 'status_card') return ct.contains('status') || ct.contains('card');
          return ct.contains(type);
        })
        .toList();
  }

  void _openItem(Map<String, dynamic> m) {
    final type = (m['content_type'] as String? ?? m['item_type'] as String? ?? '').toLowerCase();
    final id = m['content_id'] as String? ?? m['item_id'] as String?;
    if (id == null) return;
    if (type.contains('update')) {
      context.push('/updates/$id');
    } else if (type.contains('movie')) {
      context.push('/movies/$id');
    } else if (type.contains('wallpaper')) {
      context.push('/wallpapers/$id');
    } else if (type.contains('card') || type.contains('status')) {
      context.push('/status-cards/$id');
    } else if (type.contains('poll')) {
      context.push('/polls/$id');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScaffold(
      child: Column(
        children: [
          TfiDetailAppBar(title: 'Saved Items', onBack: () => context.pop()),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            labelColor: TfiTokens.gold,
            unselectedLabelColor: TfiTokens.textLo,
            indicatorColor: TfiTokens.gold,
            tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
          ),
          Expanded(
            child: _loading
                ? Center(
                    child: Shimmer.fromColors(
                      baseColor: TfiTokens.card1,
                      highlightColor: TfiTokens.card3,
                      child: const TfiShimmerCard(height: 120),
                    ),
                  )
                : TabBarView(
                    controller: _tabs,
                    children: List.generate(_tabTypes.length, (tabIndex) => _tabContent(tabIndex)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabContent(int tabIndex) {
    final items = _forTab(tabIndex);
    if (items.isEmpty) {
      return EmptyState(message: 'No saved ${_tabLabels[tabIndex].toLowerCase()} yet', icon: '🔖');
    }

    final isGrid = tabIndex == 2 || tabIndex == 3;

    return RefreshIndicator(
      onRefresh: _load,
      color: TfiTokens.gold,
      child: isGrid
          ? GridView.builder(
              padding: const EdgeInsets.all(TfiTokens.padScreen),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final m = items[i];
                final title = m['title'] as String? ?? 'Saved';
                final url = m['image_url'] as String? ?? m['thumbnail_url'] as String?;
                return TfiExplorePosterCell(
                  title: title,
                  imageUrl: url,
                  placeholderKind: tabIndex == 2 ? TfiPlaceholderKind.wallpaper : TfiPlaceholderKind.statusCard,
                  onTap: () => _openItem(m),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(TfiTokens.padScreen),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final m = items[i];
                final url = m['image_url'] as String? ?? m['thumbnail_url'] as String?;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TfiCard(
                    onTap: () => _openItem(m),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: url != null && url.isNotEmpty
                                ? TfiNetworkImage(url: url, height: 52, fit: BoxFit.cover)
                                : TfiPosterPlaceholder(title: m['title'] as String?, width: 52, height: 52),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            m['title'] as String? ?? 'Saved item',
                            style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: TfiTokens.textFaint),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
