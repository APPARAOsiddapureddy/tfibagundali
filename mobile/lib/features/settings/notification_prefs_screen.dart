import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  State<NotificationPrefsScreen> createState() => _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  Map<String, bool> _prefs = {};
  bool _loading = true;

  static const _labels = {
    'movie_updates': 'Movie updates',
    'my_hero_updates': 'My hero updates',
    'trailer_alerts': 'Trailer alerts',
    'song_alerts': 'Song alerts',
    'release_reminders': 'Release reminders',
    'event_reminders': 'Event reminders',
    'quiz_reminders': 'Quiz reminders',
    'poll_results': 'Poll results',
    'wallpaper_drops': 'Wallpaper drops',
    'ott_updates': 'OTT updates',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<AuthProvider>().api.getNotificationPrefs();
      final prefs = Map<String, dynamic>.from(data['preferences'] as Map? ?? data);
      if (mounted) {
        setState(() {
          _prefs = prefs.map((k, v) => MapEntry(k, v == true));
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(String key, bool value) async {
    setState(() => _prefs[key] = value);
    try {
      await context.read<AuthProvider>().api.patchNotificationPrefs({key: value});
    } catch (_) {
      if (mounted) setState(() => _prefs[key] = !value);
    }
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
                Text('Notifications', style: TfiTokens.display(22, color: TfiTokens.textHi)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: _labels.entries.map((e) {
                      final on = _prefs[e.key] ?? true;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TfiCard(
                          child: SwitchListTile(
                            title: Text(e.value, style: TfiTokens.body(14, color: TfiTokens.textHi)),
                            value: on,
                            activeThumbColor: TfiTokens.fire,
                            onChanged: (v) => _toggle(e.key, v),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
