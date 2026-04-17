import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/quiz_provider.dart';

class QuizStartScreen extends ConsumerWidget {
  const QuizStartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiz = ref.watch(quizProvider);
    final streak = quiz.streak > 0 ? quiz.streak : 3;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Stack(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.quizCardG1, AppColors.scaffold],
                ),
              ),
              child: SizedBox.expand(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.bg3,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text('←', style: AppTheme.bodyLarge),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text('🎯', style: AppTheme.emoji(72)),
                  const SizedBox(height: 12),
                  Text('Daily Cinema Challenge', style: AppTheme.headingMedium),
                  const SizedBox(height: 10),
                  Text('Day $streak 🔥', style: AppTheme.bodyMedium.copyWith(color: AppColors.textMuted2)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.redDim,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '🔥 $streak day streak!',
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Win up to 25 🪙 coins today',
                    style: AppTheme.bodyLarge.copyWith(color: AppColors.gold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Ee roju: Medium 💪',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: quiz.isLoading
                          ? null
                          : () async {
                              await ref.read(quizProvider.notifier).initQuiz();
                              if (!context.mounted) return;
                              final qz = ref.read(quizProvider);
                              if (qz.questions.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Quiz load avvatledu — offline try cheyyandi', style: AppTheme.bodyMedium)),
                                );
                                return;
                              }
                              if (context.mounted) context.push('/home/quiz/play');
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.rButton),
                        ),
                      ),
                      child: quiz.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Start Aaduta! 🎯',
                              style: AppTheme.headingSmall.copyWith(color: Colors.white, fontSize: 24),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Questions 1 of 5',
                    style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
