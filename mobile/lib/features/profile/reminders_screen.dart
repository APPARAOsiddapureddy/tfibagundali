import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_cinematic_components.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_poster_placeholder.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
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
      final items = await context.read<AuthProvider>().api.listReminders();
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

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TfiTokens.card1,
        title: Text('Delete reminder?', style: TfiTokens.title(16)),
        content: Text('You will not receive this alert.', style: TfiTokens.body(14, color: TfiTokens.textMid)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: TfiTokens.red))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await context.read<AuthProvider>().api.deleteReminder(id);
      context.read<AuthProvider>().events.track('reminder_deleted', contentType: 'reminder', contentId: id, sourceScreen: 'profile');
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScaffold(
      child: Column(
        children: [
          TfiDetailAppBar(title: 'Reminders', onBack: () => context.pop()),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.gold))
                : _items.isEmpty
                    ? const EmptyState(message: 'No reminders set', icon: '⏰')
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: TfiTokens.gold,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(TfiTokens.padScreen),
                          itemCount: _items.length,
                          itemBuilder: (_, i) {
                            final m = _items[i];
                            final dt = m['event_datetime'] != null ? DateTime.tryParse(m['event_datetime'] as String) : null;
                            final thumb = m['image_url'] as String? ?? m['thumbnail_url'] as String?;
                            final enabled = m['enabled'] as bool? ?? m['is_active'] as bool? ?? true;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TfiCard(
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        width: 52,
                                        height: 52,
                                        child: thumb != null && thumb.isNotEmpty
                                            ? TfiNetworkImage(url: thumb, height: 52, fit: BoxFit.cover, placeholderKind: TfiPlaceholderKind.movie)
                                            : TfiPosterPlaceholder(width: 52, height: 52, icon: Icons.alarm_rounded),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m['title'] as String? ?? m['reminder_type'] as String? ?? 'Reminder',
                                            style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700),
                                          ),
                                          if (dt != null)
                                            Text(formatEventDate(dt), style: TfiTokens.body(11, color: TfiTokens.gold)),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: enabled,
                                      activeThumbColor: TfiTokens.gold,
                                      onChanged: (v) async {
                                        final id = m['id'] as String?;
                                        if (id == null) return;
                                        try {
                                          await context.read<AuthProvider>().api.patchReminder(id, {'enabled': v});
                                          _load();
                                        } catch (_) {}
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: TfiTokens.textLo),
                                      onPressed: () {
                                        final id = m['id'] as String?;
                                        if (id != null) _delete(id);
                                      },
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
