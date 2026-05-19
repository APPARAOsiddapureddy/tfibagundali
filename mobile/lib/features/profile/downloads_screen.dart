import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await context.read<AuthProvider>().api.getDownloads();
      if (mounted) setState(() { _items = items; _loading = false; });
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                const SizedBox(width: 12),
                Text('Downloads', style: TfiTokens.display(24, color: TfiTokens.textHi)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                : _items.isEmpty
                    ? Center(child: Text('No downloads yet', style: TfiTokens.body(14, color: TfiTokens.textLo)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final m = Map<String, dynamic>.from(_items[i] as Map);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TfiCard(
                              child: ListTile(
                                leading: const Icon(Icons.download_done, color: TfiTokens.green),
                                title: Text(
                                  m['content_type'] as String? ?? 'Download',
                                  style: TfiTokens.body(14, color: TfiTokens.textHi),
                                ),
                                subtitle: Text(m['created_at']?.toString() ?? '', style: TfiTokens.body(11, color: TfiTokens.textLo)),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
