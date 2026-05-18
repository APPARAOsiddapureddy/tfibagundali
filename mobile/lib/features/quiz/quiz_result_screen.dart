import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0, -0.3), radius: 1.2, colors: [Color(0xFF2A1318), TfiTokens.bg1]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text('QUIZ COMPLETE!', style: TfiTokens.display(36, color: TfiTokens.textHi)),
              const SizedBox(height: 8),
              Text('4/5 correct', style: TfiTokens.display(48, color: TfiTokens.gold)),
              const SizedBox(height: 24),
              TfiCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('+50', 'COINS'),
                    Container(width: 1, height: 40, color: TfiTokens.line),
                    _stat('+120', 'ARMY PTS'),
                    Container(width: 1, height: 40, color: TfiTokens.line),
                    _stat('#8', 'RANK'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(label: 'Back to Home', onPressed: () => context.go('/home')),
              const SizedBox(height: 12),
              TextButton(onPressed: () => context.push('/quiz/play'), child: Text('Play Again', style: TfiTokens.body(14, color: TfiTokens.fire, w: FontWeight.w700))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String v, String l) => Column(
        children: [
          Text(v, style: TfiTokens.display(28, color: TfiTokens.textHi)),
          Text(l, style: TfiTokens.body(10, color: TfiTokens.textFaint, w: FontWeight.w700)),
        ],
      );
}
