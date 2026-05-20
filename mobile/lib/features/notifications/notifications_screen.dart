import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_cinematic_components.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_poster_placeholder.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await context.read<AuthProvider>().api.getNotifications();
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

  Future<void> _markAllRead() async {
    final unread = _items.where((n) => !(n['is_read'] as bool? ?? false)).map((n) => n['id'] as String).whereType<String>().toList();
    if (unread.isEmpty) return;
    try {
      await context.read<AuthProvider>().api.markNotificationsRead(unread);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
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
    if (cid == null) {
      _load();
      return;
    }
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
    final hasUnread = _items.any((n) => !(n['is_read'] as bool? ?? false));

    return TfiScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: TfiTokens.padScreen),
            child: Row(
              children: [
                Expanded(child: TfiDetailAppBar(title: 'Notifications', onBack: () => context.pop())),
                if (hasUnread && !_loading)
                  TextButton(onPressed: _markAllRead, child: Text('Mark all read', style: TfiTokens.body(11, color: TfiTokens.gold, w: FontWeight.w700))),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? Center(
                    child: Shimmer.fromColors(
                      baseColor: TfiTokens.card1,
                      highlightColor: TfiTokens.card3,
                      child: const Padding(padding: EdgeInsets.all(16), child: TfiShimmerCard(height: 80)),
                    ),
                  )
                : _items.isEmpty
                    ? const EmptyState(message: 'No notifications yet', icon: '🔔')
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: TfiTokens.gold,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(TfiTokens.padScreen),
                          itemCount: _items.length,
                          itemBuilder: (_, i) {
                            final n = _items[i];
                            final read = n['is_read'] as bool? ?? false;
                            final created = n['created_at'] != null ? DateTime.tryParse(n['created_at'] as String) : null;
                            final thumb = n['image_url'] as String? ?? n['thumbnail_url'] as String?;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TfiCard(
                                onTap: () => _open(n),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: thumb != null && thumb.isNotEmpty
                                            ? TfiNetworkImage(url: thumb, height: 48, fit: BoxFit.cover)
                                            : TfiPosterPlaceholder(width: 48, height: 48, icon: Icons.notifications_rounded),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n['title'] as String? ?? 'TFI Update',
                                            style: TfiTokens.body(14, color: TfiTokens.textHi, w: read ? FontWeight.w500 : FontWeight.w800),
                                          ),
                                          if (n['body'] != null)
                                            Text(n['body'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: TfiTokens.body(12, color: TfiTokens.textMid)),
                                          if (created != null)
                                            Text(formatRelativeTime(created), style: TfiTokens.body(10, color: TfiTokens.textLo)),
                                        ],
                                      ),
                                    ),
                                    if (!read)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: const BoxDecoration(color: TfiTokens.fire, shape: BoxShape.circle),
                                      ),
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
