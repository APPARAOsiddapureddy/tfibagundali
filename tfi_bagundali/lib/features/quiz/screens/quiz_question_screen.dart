import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../providers/quiz_provider.dart';

class QuizQuestionScreen extends ConsumerWidget {
  const QuizQuestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qz = ref.watch(quizProvider);

    ref.listen(quizProvider, (prev, next) {
      final r = next.results;
      if (r != null && prev?.results == null && context.mounted) {
        context.go('/home/quiz/results', extra: r);
      }
    });

    final q = qz.currentQuestion;
    if (q == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffold,
        body: Center(child: Text('Loading…', style: AppTheme.bodyMedium)),
      );
    }

    final isDanger = qz.timer <= 5;
    final answered = qz.answered;
    final reveal = qz.reveal;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${qz.currentIndex + 1} / 5',
                          style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (i) {
                            Color c = AppColors.border;
                            if (i < qz.currentIndex) c = AppColors.green;
                            if (i == qz.currentIndex) c = AppColors.gold;
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: i == 4 ? 0 : 4),
                                height: 4,
                                decoration: BoxDecoration(
                                  color: c,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '+${q.coins} 🪙',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isDanger ? AppColors.red : AppColors.gold),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      qz.timer.toString(),
                      style: AppTheme.headingSmall.copyWith(
                        color: isDanger ? AppColors.red : AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldDim,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    q.type.toUpperCase(),
                    style: AppTheme.bodySmall.copyWith(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.bg4,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: q.imageUrl != null && q.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: q.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => const ShimmerLoader(width: double.infinity, height: 150, borderRadius: 16),
                        errorWidget: (_, __, ___) => Center(child: Text(q.emoji, style: AppTheme.emoji(64))),
                      )
                    : Center(child: Text(q.emoji, style: AppTheme.emoji(64))),
              ),
              const SizedBox(height: 14),
              DefaultTextStyle(
                style: AppTheme.bodyLarge.copyWith(height: 1.4),
                child: Text(q.text),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: q.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final correct = q.correctIndex == i;
                    final selected = qz.selectedOption == i;
                    final wrongSelected = answered && selected && !correct;

                    Color bg = AppColors.bg3;
                    Color border = AppColors.border2;
                    Color text = AppColors.textPrimary;
                    Color keyBg = AppColors.bg4;
                    Color keyText = AppColors.textPrimary;

                    if (reveal && correct) {
                      bg = AppColors.green.withValues(alpha: 0.10);
                      border = AppColors.green;
                      text = AppColors.green;
                      keyBg = AppColors.green;
                      keyText = Colors.white;
                    } else if (wrongSelected) {
                      bg = AppColors.redDim;
                      border = AppColors.red;
                      text = AppColors.red;
                      keyBg = AppColors.red;
                      keyText = Colors.white;
                    }

                    final key = String.fromCharCode('A'.codeUnitAt(0) + i);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border, width: 1.5),
                      ),
                      child: InkWell(
                        onTap: answered ? null : () => ref.read(quizProvider.notifier).submitAnswer(i),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: keyBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  key,
                                  style: AppTheme.bodySmall.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: keyText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DefaultTextStyle(
                                  style: AppTheme.bodyMedium.copyWith(color: text, fontSize: 13),
                                  child: Text(q.options[i]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
