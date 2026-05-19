import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Map<String, dynamic>? _results;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.length < 2) return;
    setState(() => _loading = true);
    try {
      final r = await context.read<AuthProvider>().api.search(q);
      context.read<AuthProvider>().events.track('search_performed', metadata: {'query': q});
      if (mounted) setState(() { _results = r; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _results?['groups'] as Map<String, dynamic>? ?? _results ?? {};

    return TfiScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TfiTokens.body(16, color: TfiTokens.textHi),
                    decoration: InputDecoration(
                      hintText: 'Search updates, movies, heroes...',
                      hintStyle: TfiTokens.body(14, color: TfiTokens.textLo),
                      filled: true,
                      fillColor: TfiTokens.bg2,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: IconButton(icon: const Icon(Icons.search, color: TfiTokens.fire), onPressed: _search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
              ],
            ),
          ),
          if (_loading) const Expanded(child: Center(child: CircularProgressIndicator(color: TfiTokens.fire)))
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: groups.entries.map((e) {
                  final items = e.value as List? ?? [];
                  if (items.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key, style: TfiTokens.display(18, color: TfiTokens.fire)),
                      const SizedBox(height: 8),
                      ...items.map((item) {
                        final m = Map<String, dynamic>.from(item as Map);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TfiCard(
                            child: ListTile(
                              title: Text(
                                m['title'] as String? ?? m['name'] as String? ?? m['question'] as String? ?? 'Item',
                                style: TfiTokens.body(14, color: TfiTokens.textHi),
                              ),
                              onTap: () {
                                final id = m['id']?.toString();
                                if (id == null) return;
                                final type = e.key.toLowerCase();
                                context.read<AuthProvider>().events.track(
                                      'search_result_clicked',
                                      contentType: type,
                                      contentId: id,
                                      sourceScreen: 'search',
                                    );
                                if (type.contains('update')) {
                                  context.push('/updates/$id');
                                } else if (type.contains('movie')) {
                                  context.push('/movies/$id');
                                } else if (type.contains('poll')) {
                                  context.push('/polls/$id');
                                }
                              },
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
