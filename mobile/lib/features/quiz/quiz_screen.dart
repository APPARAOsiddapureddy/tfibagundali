import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: TfiTopBar(title: 'QUIZ', subtitle: 'TFI Trivia'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: TfiTokens.gradFire,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S TFI TRIVIA",
                      style: TfiTokens.body(
                        11,
                        color: Colors.white70,
                        w: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tollywood Image Quiz',
                      style: TfiTokens.display(
                        30,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '5 questions. 4 options each. Climb the daily leaderboard.',
                      style: TfiTokens.body(
                        14,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'Start Quiz',
                      onPressed: () => context.push('/quiz/play'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: SectionTitle(title: 'Today\'s Challenge'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TfiCard(
                child: Column(
                  children: const [
                    _QuizInfoRow(step: '01', label: 'Image-based cinema clues'),
                    _QuizInfoRow(
                      step: '02',
                      label: 'Four options for every question',
                    ),
                    _QuizInfoRow(
                      step: '03',
                      label: 'Score shown after all 5 answers',
                    ),
                    _QuizInfoRow(
                      step: '04',
                      label: 'Daily and weekly leaderboard ranks',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _QuizInfoRow extends StatelessWidget {
  const _QuizInfoRow({required this.step, required this.label});

  final String step;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TfiTokens.fire.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TfiTokens.fire.withValues(alpha: 0.35)),
            ),
            child: Text(step, style: TfiTokens.mono(11, color: TfiTokens.gold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TfiTokens.body(
                14,
                color: TfiTokens.textHi,
                w: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
