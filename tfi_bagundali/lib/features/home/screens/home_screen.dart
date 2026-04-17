import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/coin_balance_provider.dart';
import '../../../shared/widgets/coin_chip.dart';
import '../../../shared/widgets/countdown_widget.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../models/home_feed_model.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinBalanceProvider);
    final feedAsync = ref.watch(homeFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        bottom: false,
        child: feedAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.only(bottom: 20 + 56 + 24),
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  children: [
                    Expanded(child: ShimmerLoader(width: 180, height: 22, borderRadius: 8)),
                    SizedBox(width: 12),
                    ShimmerLoader(width: 96, height: 32, borderRadius: 20),
                    SizedBox(width: 10),
                    ShimmerLoader(width: 36, height: 36, borderRadius: 16),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ShimmerLoader(width: double.infinity, height: 120, borderRadius: 20),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: ShimmerLoader(width: double.infinity, height: 96, borderRadius: 18),
              ),
            ],
          ),
          error: (_, __) => _HomeBody(feed: null, coins: coins),
          data: (feed) => _HomeBody(feed: feed, coins: coins),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.feed, required this.coins});

  final HomeFeedModel? feed;
  final int coins;

  @override
  Widget build(BuildContext context) {
    final f = feed;
    final upcoming = f?.upcoming ?? const [];
    final previews = f?.statusPreviews ?? const [];

    return ListView(
      padding: const EdgeInsets.only(bottom: 20 + 56 + 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'TFI BAGUNDALI',
                  style: AppTheme.headingSmall.copyWith(color: AppColors.red),
                ),
              ),
              CoinChip(balance: coins),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.bg3,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text('🔔', style: AppTheme.emoji(16)),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/movie/${f?.releaseMovieId ?? 'pushpa3'}'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.releaseCardG1,
                    AppColors.releaseCardG2,
                    AppColors.releaseCardG3,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.bg4,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(f?.releaseEmoji ?? '🔥', style: AppTheme.emoji(28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEXT BIG RELEASE',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.red,
                            fontSize: 9,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          f?.releaseTitle ?? 'PUSHPA 3',
                          style: AppTheme.coinNumber,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${f?.releaseHero ?? 'Allu Arjun'} • ${f?.releaseDirector ?? 'Sukumar'}',
                          style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
                        ),
                        const SizedBox(height: 8),
                        if (f != null)
                          CountdownWidget(targetUtc: f.releaseTargetUtc)
                        else
                          const Row(
                            children: [
                              _StaticCountdown(label: 'DAYS', value: '00'),
                              SizedBox(width: 6),
                              _StaticCountdown(label: 'HRS', value: '00'),
                              SizedBox(width: 6),
                              _StaticCountdown(label: 'MIN', value: '00'),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Set Alert 🔔',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => context.push('/home/quiz'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.quizCardG1,
                    AppColors.quizCardG2,
                    AppColors.quizCardG3,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Text('🎯', style: AppTheme.emoji(36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (f?.quizDoneToday ?? false)
                              ? "Today's Quiz Complete! 🏆"
                              : 'Daily Cinema Challenge Ready!',
                          style: AppTheme.bodyLarge.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (f?.quizDoneToday ?? false)
                              ? 'Come back tomorrow'
                              : '5 questions • Neevu gelusthava? 🏆',
                          style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      (f?.quizDoneToday ?? false) ? '✓ DONE' : '25 🪙 MAX',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SectionHeader(title: 'Upcoming Releases', actionText: 'See All →'),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: upcoming.isEmpty ? 4 : upcoming.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              if (upcoming.isEmpty) {
                return const _MovieCard(
                  title: 'Pushpa 3',
                  emoji: '🔥',
                  date: 'Aug 15 2025',
                  genre: 'Mass Action',
                );
              }
              final m = upcoming[i];
              return _MovieCard(
                title: m.title,
                emoji: m.emoji,
                date: m.releaseDate,
                genre: m.genre,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SectionHeader(
          title: "Today's WhatsApp Status 📲",
          actionText: 'More →',
          onTap: () => context.push('/home/share'),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: previews.isEmpty ? 4 : previews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              if (previews.isEmpty) {
                return const _StatusCard(label: 'Power Star', emoji: '🦁');
              }
              final p = previews[i];
              return _StatusCard(label: p.label, emoji: p.emoji);
            },
          ),
        ),
      ],
    );
  }
}

class _StaticCountdown extends StatelessWidget {
  const _StaticCountdown({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTheme.headingSmall.copyWith(color: AppColors.red, fontSize: 20)),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              fontSize: 7,
              color: AppColors.textMuted2,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({
    required this.title,
    required this.emoji,
    required this.date,
    required this.genre,
  });

  final String title;
  final String emoji;
  final String date;
  final String genre;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 118,
            decoration: BoxDecoration(
              color: AppColors.bg4,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: AppTheme.emoji(40)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyLarge.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(date, style: AppTheme.bodySmall.copyWith(color: AppColors.red, fontSize: 9)),
          Text(genre, style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2, fontSize: 8)),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.label, required this.emoji});

  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: AppTheme.emoji(36)),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 96,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.bodySmall.copyWith(fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.whatsapp,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'WA',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
