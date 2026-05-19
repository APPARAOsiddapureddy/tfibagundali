import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
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

    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TfiTopBar(
              title: 'PROFILE',
              trailing: [
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: const Icon(Icons.settings_outlined, color: TfiTokens.textHi),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: TfiTokens.bg2,
                    child: Text(hero?.iconEmoji ?? '⭐', style: const TextStyle(fontSize: 36)),
                  ),
                  const SizedBox(height: 12),
                  Text(auth.displayName, style: TfiTokens.display(26, color: TfiTokens.textHi)),
                  Text(user?.phone ?? '', style: TfiTokens.body(13, color: TfiTokens.textLo)),
                  if (hero != null) ...[
                    const SizedBox(height: 8),
                    TfiChip(label: 'Favourite: ${hero.name}', color: TfiTokens.fire),
                  ],
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _tile(context, Icons.star_outline, 'Favourite hero', () => context.push('/profile/favourite-hero')),
              _tile(context, Icons.bookmark_outline, 'Saved content', () => context.push('/profile/saved')),
              _tile(context, Icons.alarm, 'Reminders', () => context.push('/profile/reminders')),
              _tile(context, Icons.download_outlined, 'Downloads', () => context.push('/profile/downloads')),
              _tile(context, Icons.quiz_outlined, 'Quiz history', () => context.push('/profile/quiz-history')),
              _tile(context, Icons.notifications_outlined, 'Notifications', () => context.push('/profile/notifications')),
              _tile(context, Icons.tune, 'Notification settings', () => context.push('/profile/notification-preferences')),
              _tile(context, Icons.language, 'Language', () => _languageSheet(context)),
              _tile(context, Icons.help_outline, 'Help', () {}),
            ]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(label: 'Log Out', filled: false, onPressed: () => _logout(context)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _languageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TfiTokens.bg2,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['MIXED', 'TELUGU', 'ENGLISH'].map((lang) {
            return ListTile(
              title: Text(lang, style: TfiTokens.body(15, color: TfiTokens.textHi)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await context.read<AuthProvider>().api.updateProfile({'language_preference': lang});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language: $lang')));
                  }
                } catch (_) {}
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: TfiCard(
        child: ListTile(
          leading: Icon(icon, color: TfiTokens.fire),
          title: Text(label, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right, color: TfiTokens.textFaint),
          onTap: onTap,
        ),
      ),
    );
  }
}
