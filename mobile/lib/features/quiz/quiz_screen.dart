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
          const SliverToBoxAdapter(child: TfiTopBar(title: 'QUIZ', subtitle: 'ZONE')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: TfiTokens.gradFire, borderRadius: BorderRadius.circular(22), border: Border.all(color: TfiTokens.fire.withValues(alpha: 0.5))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DAILY CHALLENGE', style: TfiTokens.body(11, color: Colors.white70, w: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('Tollywood Trivia', style: TfiTokens.display(32, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('5 questions · 60 seconds · +50 coins', style: TfiTokens.body(13, color: Colors.white70)),
                    const SizedBox(height: 16),
                    PrimaryButton(label: 'Start Quiz →', onPressed: () => context.push('/quiz/play')),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionTitle(title: 'PAST QUIZZES'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TfiCard(
                  child: Row(
                    children: [
                      PosterTile(emoji: '🧠', size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quiz #${120 - i}', style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700)),
                            Text('${4 - i % 2}/5 correct · +${(4 - i) * 10} coins', style: TfiTokens.body(12, color: TfiTokens.textLo)),
                          ],
                        ),
                      ),
                      Text('${80 + i * 5}%', style: TfiTokens.display(22, color: TfiTokens.gold)),
                    ],
                  ),
                ),
              ),
              childCount: 5,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
