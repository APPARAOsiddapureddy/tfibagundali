import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/coin_balance_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../constants/profile_badges.dart';
import '../models/profile_state.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (auth.accessToken != null && auth.accessToken!.isNotEmpty) {
        ref.read(profileProvider.notifier).loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileProvider, (prev, next) {
      if (next.loadState != ProfileLoadState.loaded) return;
      final g = ref.read(coinBalanceProvider);
      ref.read(coinBalanceProvider.notifier).setBalance(math.max(next.coinBalance, g));
    });

    final auth = ref.watch(authProvider);
    final profile = ref.watch(profileProvider);
    final localHero = ref.watch(localStorageProvider).selectedHero ?? 'pawan';
    final coinsGlobal = ref.watch(coinBalanceProvider);

    final heroEmoji = switch (localHero) {
      'mahesh' => '👑',
      'allu' => '🔥',
      'charan' => '⚡',
      'ntr' => '🌊',
      'prabhas' => '🐯',
      'balayya' => '🦅',
      'chiru' => '🌟',
      _ => '🦁',
    };

    if (auth.accessToken == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffold,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👤', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 12),
                  Text('Login Avvandi', style: AppTheme.headingMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Mee coins, streak, badges anni save avvali ante login avvali.',
                    textAlign: TextAlign.center,
                    style: AppTheme.telugu.copyWith(color: AppColors.textMuted2, fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () => context.go('/auth'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.rButton),
                        ),
                      ),
                      child: Text('Login / Register', style: AppTheme.headingSmall.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final displayName = profile.displayName.isNotEmpty
        ? profile.displayName
        : (auth.user?.displayName ?? 'TFI Fan');
    final username = profile.username.isNotEmpty
        ? profile.username
        : (auth.user?.username ?? '@tfi_fan');

    final coinDisplay = math.max(profile.coinBalance, coinsGlobal);
    final pctText =
        '${(profile.correctAnswerPercent * 100).clamp(0, 100).toStringAsFixed(0)}%';

    final showSkeleton =
        profile.loadState == ProfileLoadState.loading && profile.userId.isEmpty;

    if (showSkeleton) {
      return Scaffold(
        backgroundColor: AppColors.scaffold,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.red),
                const SizedBox(height: 12),
                Text('Profile load avutundi…', style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.red,
          onRefresh: () => ref.read(profileProvider.notifier).loadProfile(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20 + 56 + 20),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.red.withValues(alpha: 0.08), Colors.transparent],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.red, width: 3),
                        boxShadow: [
                          BoxShadow(color: AppColors.red.withValues(alpha: 0.35), blurRadius: 18),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(heroEmoji, style: const TextStyle(fontSize: 38)),
                    ),
                    const SizedBox(height: 10),
                    Text(displayName, style: AppTheme.headingMedium.copyWith(fontSize: 26)),
                    const SizedBox(height: 2),
                    Text(username, style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.redDim,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.red.withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            '$heroEmoji Fan Army',
                            style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.goldDim,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            '🪙 $coinDisplay',
                            style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w900, color: AppColors.gold),
                          ),
                        ),
                      ],
                    ),
                    if (profile.isPremium) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '⭐ Premium Active',
                          style: AppTheme.bodySmall.copyWith(color: AppColors.gold, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                    if (profile.loadState == ProfileLoadState.error && profile.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile.errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTheme.bodySmall.copyWith(color: AppColors.red, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatsGrid(
                      totalQuizzes: profile.totalQuizzesPlayed,
                      correctPct: pctText,
                      bestStreak: profile.bestStreak,
                      shares: profile.totalShares,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '🔥 Login streak: ${profile.loginStreak} days',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BadgesWrap(earnedIds: profile.earnedBadgeIds.toSet()),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0d080f), Color(0xFF180d20)],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upgrade to Premium', style: AppTheme.bodyLarge.copyWith(color: AppColors.gold)),
                                const SizedBox(height: 2),
                                Text(
                                  'Ad-free • Exclusive packs • Gold badge',
                                  style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/premium'),
                            child: Text('View Plans', style: AppTheme.bodyMedium.copyWith(color: AppColors.gold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsTile(title: '🔔 Notifications', onTap: () {}),
                    _SettingsTile(title: '🌐 Language', onTap: () {}),
                    _SettingsTile(title: '👥 Invite Friends (+50 🪙)', onTap: () {}),
                    _SettingsTile(
                      title: '🚪 Logout',
                      danger: true,
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go('/auth');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.totalQuizzes,
    required this.correctPct,
    required this.bestStreak,
    required this.shares,
  });

  final int totalQuizzes;
  final String correctPct;
  final int bestStreak;
  final int shares;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.7,
      ),
      children: [
        _StatCard(title: 'Total Quizzes', value: '$totalQuizzes', color: AppColors.textPrimary, icon: '🎯'),
        _StatCard(title: 'Correct %', value: correctPct, color: AppColors.green, icon: '✅'),
        _StatCard(title: 'Best Streak', value: '$bestStreak', color: AppColors.red, icon: '🔥'),
        _StatCard(title: 'Shares Done', value: '$shares', color: AppColors.gold, icon: '📲'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.color, required this.icon});
  final String title;
  final String value;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(value, style: AppTheme.headingSmall.copyWith(color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgesWrap extends StatelessWidget {
  const _BadgesWrap({required this.earnedIds});

  final Set<String> earnedIds;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kAllProfileBadges.map((b) {
        final active = earnedIds.contains(b.id);
        return Opacity(
          opacity: active ? 1 : 0.45,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.goldDim : AppColors.bg3,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? AppColors.gold : AppColors.border2),
            ),
            child: Text(
              b.label,
              style: AppTheme.bodySmall.copyWith(
                color: active ? AppColors.gold : AppColors.textMuted2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, required this.onTap, this.danger = false});
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(color: danger ? AppColors.red : AppColors.textPrimary),
      ),
      trailing: Text('›', style: AppTheme.headingSmall.copyWith(color: AppColors.textMuted2)),
      onTap: onTap,
    );
  }
}
