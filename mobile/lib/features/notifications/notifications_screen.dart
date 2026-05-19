import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await context.read<AuthProvider>().api.getNotifications();
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Map<String, dynamic> n) async {
    final id = n['id'] as String?;
    if (id != null) {
      await context.read<AuthProvider>().api.markNotificationsRead([id]);
      context.read<AuthProvider>().events.track('notification_opened', contentType: 'notification', contentId: id, sourceScreen: 'profile');
    }
    final type = n['content_type'] as String?;
    final cid = n['content_id'] as String?;
    if (cid == null) return;
    if (type == 'update') {
      if (mounted) context.push('/updates/$cid');
    } else if (type == 'movie') {
      if (mounted) context.push('/movies/$cid');
    } else if (type == 'poll') {
      if (mounted) context.push('/polls/$cid');
    }
    _load();
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
                const SizedBox(width: 8),
                Text('Notifications', style: TfiTokens.display(24, color: TfiTokens.textHi)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                : _items.isEmpty
                    ? const EmptyState(message: 'No notifications yet', icon: '🔔')
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: TfiTokens.fire,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          itemBuilder: (_, i) {
                            final n = Map<String, dynamic>.from(_items[i] as Map);
                            final read = n['is_read'] as bool? ?? false;
                            final created = n['created_at'] != null ? DateTime.tryParse(n['created_at'] as String) : null;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TfiCard(
                                child: ListTile(
                                  title: Text(
                                    n['title'] as String? ?? 'TFI Update',
                                    style: TfiTokens.body(14, color: TfiTokens.textHi, w: read ? FontWeight.w500 : FontWeight.w800),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (n['body'] != null) Text(n['body'] as String, style: TfiTokens.body(12, color: TfiTokens.textMid)),
                                      if (created != null) Text(formatRelativeTime(created), style: TfiTokens.body(10, color: TfiTokens.textLo)),
                                    ],
                                  ),
                                  trailing: read ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: TfiTokens.fire, shape: BoxShape.circle)),
                                  onTap: () => _open(n),
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
