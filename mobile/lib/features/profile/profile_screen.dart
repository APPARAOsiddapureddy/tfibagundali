import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_cinematic_components.dart';
import '../../widgets/tfi_poster_placeholder.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _savedCount = 0;
  int _remindersCount = 0;
  int _quizCount = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final api = context.read<AuthProvider>().api;
      final results = await Future.wait([
        api.getSaved(),
        api.getReminders(),
        api.getProfileQuizHistory(),
      ]);
      if (mounted) {
        setState(() {
          _savedCount = results[0].length;
          _remindersCount = results[1].length;
          _quizCount = results[2].length;
          _statsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TfiTokens.card1,
        title: Text('Log out?', style: TfiTokens.title(16)),
        content: Text('You will need to sign in again.', style: TfiTokens.body(14, color: TfiTokens.textMid)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Log out', style: TextStyle(color: TfiTokens.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<AuthProvider>().logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final hero = user?.favouriteHero;
    final phone = user?.phone ?? '';

    return TfiScaffold(
      child: RefreshIndicator(
        onRefresh: _loadStats,
        color: TfiTokens.gold,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 12, TfiTokens.padScreen, 8),
                child: Row(
                  children: [
                    Text('Profile', style: TfiTokens.display(26, color: TfiTokens.gold)),
                    const Spacer(),
                    Material(
                      color: TfiTokens.glass,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => context.push('/settings'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: TfiTokens.line),
                          ),
                          child: const Icon(Icons.settings_outlined, size: 20, color: TfiTokens.textMid),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
                child: TfiGlassPanel(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: TfiPosterPlaceholder(
                            kind: TfiPlaceholderKind.hero,
                            title: auth.displayName,
                            width: 72,
                            height: 72,
                            borderRadius: BorderRadius.circular(999),
                            icon: Icons.person_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(auth.displayName, style: TfiTokens.title(20, w: FontWeight.w800)),
                            if (phone.isNotEmpty)
                              Text(phone, style: TfiTokens.body(12, color: TfiTokens.textLo)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    hero?.name ?? 'No favourite hero',
                                    style: TfiTokens.telugu(12, color: TfiTokens.gold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push('/profile/favourite-hero'),
                                  child: const Icon(Icons.edit_outlined, size: 18, color: TfiTokens.gold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 16, TfiTokens.padScreen, 8),
                child: _statsLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: TfiTokens.gold)))
                    : Row(
                        children: [
                          Expanded(child: _StatTile(label: 'Saved', value: '$_savedCount', onTap: () => context.push('/profile/saved'))),
                          const SizedBox(width: 10),
                          Expanded(child: _StatTile(label: 'Reminders', value: '$_remindersCount', onTap: () => context.push('/profile/reminders'))),
                          const SizedBox(width: 10),
                          Expanded(child: _StatTile(label: 'Quizzes', value: '$_quizCount', onTap: () => context.push('/profile/quiz-history'))),
                        ],
                      ),
              ),
            ),
            const SliverToBoxAdapter(child: TfiSectionHeader(title: 'Your account')),
            SliverList(
              delegate: SliverChildListDelegate([
                _menuTile(context, Icons.bookmark_outline_rounded, 'Saved Items', 'Updates, movies, wallpapers, cards', '/profile/saved'),
                _menuTile(context, Icons.download_outlined, 'Downloads', 'Offline wallpapers & cards', '/profile/downloads'),
                _menuTile(context, Icons.history_rounded, 'Quiz History', 'Past scores & dates', '/profile/quiz-history'),
                _menuTile(context, Icons.alarm_outlined, 'Reminders', 'Release & event alerts', '/profile/reminders'),
                _menuTile(context, Icons.notifications_outlined, 'Notifications', 'Latest TFI alerts', '/profile/notifications'),
                _menuTile(context, Icons.tune_rounded, 'Notification Preferences', 'Choose what you hear about', '/profile/notification-preferences'),
                _menuTile(context, Icons.star_outline_rounded, 'Favourite Hero', 'Personalize your feed', '/profile/favourite-hero'),
                _menuTile(context, Icons.settings_outlined, 'Settings', 'App preferences', '/settings'),
              ]),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 8, TfiTokens.padScreen, 88),
                child: TextButton(
                  onPressed: () => _logout(context),
                  child: Text('Log Out', style: TfiTokens.body(15, color: TfiTokens.red, w: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(BuildContext context, IconData icon, String title, String subtitle, String route) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 0, TfiTokens.padScreen, 10),
      child: TfiCard(
        onTap: () => context.push(route),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: TfiTokens.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: TfiTokens.gold, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w800)),
                  Text(subtitle, style: TfiTokens.body(11, color: TfiTokens.textLo)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: TfiTokens.textFaint),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: TfiTokens.glassCard(radius: 14),
        child: Column(
          children: [
            Text(value, style: TfiTokens.display(22, color: TfiTokens.gold)),
            Text(label, style: TfiTokens.body(11, color: TfiTokens.textLo)),
          ],
        ),
      ),
    );
  }
}
