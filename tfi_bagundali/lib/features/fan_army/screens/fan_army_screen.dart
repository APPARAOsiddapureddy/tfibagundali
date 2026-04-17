import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/wa_share_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/poll_model.dart';
import '../providers/fan_army_provider.dart';
import '../repositories/fan_army_repository.dart';

class FanArmyScreen extends ConsumerStatefulWidget {
  const FanArmyScreen({super.key});

  @override
  ConsumerState<FanArmyScreen> createState() => _FanArmyScreenState();
}

class _FanArmyScreenState extends ConsumerState<FanArmyScreen> {
  String? _votedOptionId;

  @override
  Widget build(BuildContext context) {
    final hero = ref.watch(localStorageProvider).selectedHero ?? 'pawan';
    final heroEmoji = switch (hero) {
      'mahesh' => '👑',
      'allu' => '🔥',
      'charan' => '⚡',
      'ntr' => '🌊',
      'prabhas' => '🐯',
      'balayya' => '🦅',
      'chiru' => '🌟',
      _ => '🦁',
    };

    final bundleAsync = ref.watch(fanArmyProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        bottom: false,
        child: bundleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (FanArmyBundle bundle) {
            final top = bundle.leaderboard.isEmpty ? 1 : bundle.leaderboard.first.points;
            return ListView(
              padding: const EdgeInsets.only(bottom: 20 + 56 + 20),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Row(
                    children: [
                      Expanded(child: Text('FAN ARMY', style: AppTheme.headingSmall)),
                      Text(
                        '⚔️ Weekly War',
                        style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.fanArmyBorder.withValues(alpha: 0.2)),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.fanArmyGrad1, AppColors.fanArmyGrad2],
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(heroEmoji, style: AppTheme.emoji(44)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('My Army', style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2)),
                              Text('TFI Army', style: AppTheme.headingMedium.copyWith(fontSize: 26)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.redDim,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                                    ),
                                    child: Text('⭐ Member', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w900)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.bg4,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.border2),
                                    ),
                                    child: Text('Change Army', style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2)),
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bg3,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.08),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Text(
                            '🏆 Weekly Fan Army Leaderboard',
                            style: AppTheme.bodyLarge.copyWith(fontSize: 12),
                          ),
                        ),
                        ...bundle.leaderboard.map((e) {
                          final pct = top <= 0 ? 0.0 : (e.points / top).clamp(0.0, 1.0);
                          final color = e.rank <= 3 ? AppColors.gold : AppColors.textMuted2;
                          return Column(
                            children: [
                              ListTile(
                                dense: true,
                                leading: Text('${e.rank}', style: AppTheme.headingSmall.copyWith(color: color, fontSize: 20)),
                                title: Row(
                                  children: [
                                    Text(e.emoji, style: AppTheme.emoji(22)),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(e.name, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w800))),
                                  ],
                                ),
                                subtitle: Text('${e.points} pts', style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2)),
                                trailing: SizedBox(
                                  width: 56,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 56,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: AppColors.border,
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: FractionallySizedBox(
                                        widthFactor: pct,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.red,
                                            borderRadius: BorderRadius.circular(99),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (e.rank != bundle.leaderboard.length)
                                const Divider(height: 1, color: AppColors.border),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _PollCard(
                    poll: bundle.poll,
                    votedOptionId: _votedOptionId,
                    onVote: (id) async {
                      setState(() => _votedOptionId = id);
                      await ref.read(fanArmyRepositoryProvider).vote(bundle.poll.id, id);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  const _PollCard({
    required this.poll,
    required this.votedOptionId,
    required this.onVote,
  });

  final PollModel poll;
  final String? votedOptionId;
  final ValueChanged<String> onVote;

  @override
  Widget build(BuildContext context) {
    final voted = votedOptionId != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY POLL',
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.red,
              fontSize: 9,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: AppTheme.telugu.copyWith(fontSize: 14, fontWeight: FontWeight.w800),
            child: Text(poll.question),
          ),
          const SizedBox(height: 12),
          ...poll.options.map((o) {
            final chosen = votedOptionId == o.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: voted ? null : () => onVote(o.id),
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(o.label, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w800))),
                        if (voted)
                          Text('${o.percent}%', style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (voted)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: o.percent / 100.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: v,
                              minHeight: 6,
                              backgroundColor: AppColors.border,
                              color: chosen ? AppColors.red : AppColors.bg4,
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        height: 44,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.bg4,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border2),
                        ),
                        child: Text(o.label, style: AppTheme.bodyMedium),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          Text(
            '${poll.totalVotes} votes',
            style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => WaShareButton.shareText('${poll.question}\n\nDownload TFI Bagundali app!'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.whatsapp),
                foregroundColor: AppColors.whatsapp,
              ),
              child: Text('📲 Share', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
