import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_cinematic_components.dart';

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  State<NotificationPrefsScreen> createState() => _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  Map<String, bool> _prefs = {};
  Map<String, bool> _rollback = {};
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
          _rollback = Map.from(_prefs);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(String key, bool value) async {
    final prev = _prefs[key];
    setState(() => _prefs[key] = value);
    try {
      await context.read<AuthProvider>().api.patchNotificationPrefs({key: value});
      _rollback[key] = value;
    } catch (_) {
      if (mounted) setState(() => _prefs[key] = prev ?? _rollback[key] ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScaffold(
      child: Column(
        children: [
          TfiDetailAppBar(title: 'Notification Preferences', onBack: () => context.pop()),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.gold))
                : ListView(
                    padding: const EdgeInsets.all(TfiTokens.padScreen),
                    children: _labels.entries.map((e) {
                      final on = _prefs[e.key] ?? true;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TfiGlassPanel(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          child: SwitchListTile(
                            title: Text(e.value, style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w600)),
                            subtitle: Text('Telugu cinema alerts', style: TfiTokens.body(11, color: TfiTokens.textLo)),
                            value: on,
                            activeThumbColor: TfiTokens.gold,
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
