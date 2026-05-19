import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_widgets.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await context.read<AuthProvider>().api.listReminders();
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: const Text('You will not receive this alert.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
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
                Text('Reminders', style: TfiTokens.display(24, color: TfiTokens.textHi)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                : _items.isEmpty
                    ? const EmptyState(message: 'No reminders set', icon: '⏰')
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: TfiTokens.fire,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _items.length,
                          itemBuilder: (_, i) {
                            final m = Map<String, dynamic>.from(_items[i] as Map);
                            final dt = m['event_datetime'] != null ? DateTime.tryParse(m['event_datetime'] as String) : null;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TfiCard(
                                child: ListTile(
                                  leading: const Icon(Icons.alarm, color: TfiTokens.gold),
                                  title: Text(
                                    m['title'] as String? ?? m['reminder_type'] as String? ?? 'Reminder',
                                    style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    dt != null ? formatEventDate(dt) : '',
                                    style: TfiTokens.body(11, color: TfiTokens.textLo),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: TfiTokens.red),
                                    onPressed: () => _delete(m['id'] as String),
                                  ),
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
