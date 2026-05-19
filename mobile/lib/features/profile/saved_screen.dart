import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_widgets.dart';

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
    try {
      final items = await context.read<AuthProvider>().api.getSaved();
      if (mounted) setState(() { _all = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<dynamic> _forTab(int index) {
    final type = _tabTypes[index];
    return _all.where((e) {
      final m = e as Map<String, dynamic>;
      final ct = (m['content_type'] as String? ?? m['item_type'] as String? ?? '').toLowerCase();
      if (type == 'status_card') return ct.contains('status') || ct.contains('card');
      return ct.contains(type);
    }).toList();
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
    return TfiScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                const SizedBox(width: 12),
                Text('Saved', style: TfiTokens.display(24, color: TfiTokens.textHi)),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            labelColor: TfiTokens.fire,
            tabs: const [
              Tab(text: 'Updates'),
              Tab(text: 'Movies'),
              Tab(text: 'Wallpapers'),
              Tab(text: 'Cards'),
              Tab(text: 'Polls'),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                : TabBarView(
                    controller: _tabs,
                    children: List.generate(_tabTypes.length, (tabIndex) {
                      final items = _forTab(tabIndex);
                      if (items.isEmpty) {
                        return EmptyState(message: 'No saved ${_tabTypes[tabIndex].replaceAll('_', ' ')} yet');
                      }
                      return RefreshIndicator(
                        onRefresh: _load,
                        color: TfiTokens.fire,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final m = Map<String, dynamic>.from(items[i] as Map);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TfiCard(
                                child: ListTile(
                                  title: Text(m['title'] as String? ?? 'Saved item', style: TfiTokens.body(14, color: TfiTokens.textHi)),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => _openItem(m),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}
