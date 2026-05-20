import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_cinematic_components.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await context.read<AuthProvider>().api.getDownloads();
      if (mounted) {
        setState(() {
          _items = items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScaffold(
      child: Column(
        children: [
          TfiDetailAppBar(title: 'Downloads', onBack: () => context.pop()),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.gold))
                : _items.isEmpty
                    ? const EmptyState(message: 'No downloads yet', icon: '📥')
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: TfiTokens.gold,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(TfiTokens.padScreen),
                          itemCount: _items.length,
                          itemBuilder: (_, i) {
                            final m = _items[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TfiCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: TfiTokens.green.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.download_done_rounded, color: TfiTokens.green),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m['title'] as String? ?? m['content_type'] as String? ?? 'Download',
                                            style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700),
                                          ),
                                          Text(
                                            m['created_at']?.toString() ?? '',
                                            style: TfiTokens.body(11, color: TfiTokens.textLo),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const TfiBadge('FREE'),
                                  ],
                                ),
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
