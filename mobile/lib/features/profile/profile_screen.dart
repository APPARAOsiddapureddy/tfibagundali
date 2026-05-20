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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
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
    final memberSince = user?.createdAt?.year.toString() ?? '2026';

    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TfiTopBar(
              title: 'PROFILE',
              trailing: [
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: TfiTokens.textHi,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: _ProfileHero(
                name: auth.displayName,
                phone: user?.phone ?? '',
                heroName: hero?.name,
                heroEmoji: hero?.iconEmoji,
                memberSince: memberSince,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StatsGrid(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: _FanProgress(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _QuickActions(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SectionTitle(title: 'Account'),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _tile(
                context,
                Icons.star_outline,
                'Favourite hero',
                'Personalize your fan feed',
                () => context.push('/profile/favourite-hero'),
              ),
              _tile(
                context,
                Icons.bookmark_outline,
                'Saved content',
                'Updates, movies, wallpapers, cards',
                () => context.push('/profile/saved'),
              ),
              _tile(
                context,
                Icons.download_outlined,
                'Downloads',
                'Offline wallpapers and status cards',
                () => context.push('/profile/downloads'),
              ),
              _tile(
                context,
                Icons.notifications_outlined,
                'Notifications',
                'Latest fan alerts',
                () => context.push('/profile/notifications'),
              ),
              _tile(
                context,
                Icons.tune,
                'Notification settings',
                'Choose what you want to hear about',
                () => context.push('/profile/notification-preferences'),
              ),
              _tile(
                context,
                Icons.help_outline,
                'Help',
                'Support and app questions',
                () {},
              ),
            ]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                label: 'Log Out',
                filled: false,
                onPressed: () => _logout(context),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: TfiCard(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TfiTokens.fire.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: TfiTokens.fire, size: 21),
          ),
          title: Text(
            label,
            style: TfiTokens.body(
              15,
              color: TfiTokens.textHi,
              w: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TfiTokens.body(11, color: TfiTokens.textLo),
          ),
          trailing: const Icon(Icons.chevron_right, color: TfiTokens.textFaint),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.phone,
    required this.heroName,
    required this.heroEmoji,
    required this.memberSince,
  });

  final String name;
  final String phone;
  final String? heroName;
  final String? heroEmoji;
  final String memberSince;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: TfiTokens.gradMass,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TfiTokens.fire.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  heroEmoji ?? name.characters.first.toUpperCase(),
                  style: TfiTokens.display(30, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TfiTokens.display(
                        28,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phone,
                      style: TfiTokens.body(
                        12,
                        color: Colors.white.withValues(alpha: 0.74),
                        w: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _HeroBadge(label: heroName ?? 'Choose hero'),
                        _HeroBadge(label: 'Member $memberSince'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _HeroMetric(label: 'Fan Level', value: 'Mass 4'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(label: 'Streak', value: '7d'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TfiTokens.body(11, color: Colors.white, w: FontWeight.w800),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TfiTokens.body(10, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(value, style: TfiTokens.display(16, color: Colors.white)),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO(backend): Replace these demo stats with GET /v1/profile/summary.
    // Include coins, army points, quiz accuracy, saved count, and current streak.
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.58,
      children: const [
        _StatCard(
          icon: Icons.monetization_on_outlined,
          label: 'Coins',
          value: '1,245',
          color: TfiTokens.gold,
        ),
        _StatCard(
          icon: Icons.quiz_outlined,
          label: 'Quiz Score',
          value: '18/25',
          color: TfiTokens.fire,
        ),
        _StatCard(
          icon: Icons.bookmark_outline,
          label: 'Saved',
          value: '14',
          color: TfiTokens.cyan,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TfiCard(
      accent: color,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TfiTokens.display(19, color: TfiTokens.textHi),
                ),
                const SizedBox(height: 2),
                Text(label, style: TfiTokens.body(11, color: TfiTokens.textLo)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FanProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TfiCard(
      accent: TfiTokens.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Next Level',
                  style: TfiTokens.body(
                    13,
                    color: TfiTokens.textHi,
                    w: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '760 / 1,000 pts',
                style: TfiTokens.body(
                  12,
                  color: TfiTokens.gold,
                  w: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TfiProgressBar(value: 0.76, color: TfiTokens.gold, height: 8),
          const SizedBox(height: 10),
          Text(
            'Vote in polls, finish quizzes, and save content to grow your fan level.',
            style: TfiTokens.body(12, color: TfiTokens.textMid),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.bookmark_outline,
            label: 'Saved',
            onTap: () => context.push('/profile/saved'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.download_outlined,
            label: 'Downloads',
            onTap: () => context.push('/profile/downloads'),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: TfiTokens.line),
        ),
        child: Column(
          children: [
            Icon(icon, color: TfiTokens.fire, size: 21),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TfiTokens.body(
                11,
                color: TfiTokens.textHi,
                w: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
