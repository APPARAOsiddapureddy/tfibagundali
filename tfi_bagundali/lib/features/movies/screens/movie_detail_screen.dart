import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/countdown_widget.dart';
import '../../../shared/widgets/wa_share_button.dart';
import '../models/movie_model.dart';
import '../providers/movie_provider.dart';
import '../repositories/movie_repository.dart';

class MovieDetailScreen extends ConsumerWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMovie = ref.watch(movieProvider(movieId));
    final repo = ref.watch(movieRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: asyncMovie.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text('Movie load failed', style: AppTheme.bodyMedium)),
          data: (MovieModel m) => ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              SizedBox(
                height: 190,
                child: Stack(
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.movieHeroGrad1, AppColors.movieHeroGrad2],
                        ),
                      ),
                      child: SizedBox.expand(),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Opacity(
                        opacity: 0.08,
                        child: Text(m.emoji, style: AppTheme.emoji(120)),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.scaffold.withValues(alpha: 0.5),
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text('←', style: AppTheme.bodyLarge),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UPCOMING RELEASE',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppColors.red,
                              fontSize: 9,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(m.title, style: AppTheme.headingLarge.copyWith(fontSize: 36)),
                          const SizedBox(height: 2),
                          Text(
                            '${m.hero} • ${m.director}',
                            style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (m.releaseTargetUtc != null) ...[
                      Expanded(child: CountdownWidget(targetUtc: m.releaseTargetUtc!)),
                    ] else ...[
                      const Expanded(child: SizedBox()),
                    ],
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => repo.setReminder(m.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.rButton)),
                        ),
                        child: Text(
                          '🔔 Set Reminder',
                          style: AppTheme.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MovieTabs(movie: m, repo: repo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovieTabs extends StatefulWidget {
  const _MovieTabs({required this.movie, required this.repo});

  final MovieModel movie;
  final MovieRepository repo;

  @override
  State<_MovieTabs> createState() => _MovieTabsState();
}

class _MovieTabsState extends State<_MovieTabs> {
  int idx = 0;
  final tabs = const ['About', 'Gallery', 'Fan Talk'];

  @override
  Widget build(BuildContext context) {
    final m = widget.movie;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.bg3,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final active = i == idx;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => idx = i),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? AppColors.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tabs[i],
                      style: AppTheme.bodySmall.copyWith(
                        color: active ? Colors.white : AppColors.textMuted2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        if (idx == 0) ...[
          Text(
            m.synopsis ??
                'Synopsis: A mass action entertainer with style and fire. (Offline preview)',
            style: AppTheme.bodyMedium.copyWith(color: AppColors.textMuted2, height: 1.6),
          ),
          const SizedBox(height: 14),
          Text('Cast & Crew', style: AppTheme.bodyLarge.copyWith(fontSize: 13)),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CastChip(name: 'Hero', role: 'Lead', emoji: m.emoji),
                const SizedBox(width: 10),
                const _CastChip(name: 'Director', role: 'Vision', emoji: '🎬'),
                const SizedBox(width: 10),
                const _CastChip(name: 'Music', role: 'DSP', emoji: '🎵'),
                const SizedBox(width: 10),
                const _CastChip(name: 'Villain', role: '???', emoji: '😈'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => WaShareButton.shareText('🔥 ${m.title}\nComing soon!\nDownload TFI Bagundali app!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.rButton)),
              ),
              child: Text('📲 Share This Movie', style: AppTheme.headingSmall.copyWith(color: Colors.white)),
            ),
          ),
        ] else if (idx == 1) ...[
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
            children: List.generate(6, (i) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.bg4,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(m.emoji, style: AppTheme.emoji(40)),
              );
            }),
          ),
        ] else ...[
          Text('Expectations?', style: AppTheme.bodyLarge.copyWith(fontSize: 14)),
          const SizedBox(height: 10),
          const _FanTalkBars(),
        ],
      ],
    );
  }
}

class _CastChip extends StatelessWidget {
  const _CastChip({required this.name, required this.role, required this.emoji});

  final String name;
  final String role;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.bg4,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: AppTheme.emoji(22)),
        ),
        const SizedBox(height: 6),
        Text(name, style: AppTheme.bodySmall.copyWith(fontSize: 9)),
        Text(role, style: AppTheme.bodySmall.copyWith(fontSize: 8, color: AppColors.textMuted2)),
      ],
    );
  }
}

class _FanTalkBars extends StatelessWidget {
  const _FanTalkBars();

  @override
  Widget build(BuildContext context) {
    const opts = <({String label, double value})>[
      (label: '🔥 Mass Blockbuster', value: 0.62),
      (label: '👍 Good', value: 0.24),
      (label: '😐 Average', value: 0.14),
    ];
    return Column(
      children: opts.map((o) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(o.label, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: o.value,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${(o.value * 100).round()}%', style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
