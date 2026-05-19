import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, this.result});
  final Map<String, dynamic>? result;

  @override
  Widget build(BuildContext context) {
    final score = result?['score'] ?? 0;
    final total = result?['total'] ?? 0;
    final message = result?['message'] as String? ?? 'Good try!';

    return TfiScreen(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF2A1318), TfiTokens.bg1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text('QUIZ COMPLETE!', style: TfiTokens.display(32, color: TfiTokens.textHi)),
              const SizedBox(height: 8),
              Text('$score / $total', style: TfiTokens.display(48, color: TfiTokens.gold)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: TfiTokens.telugu(16, color: TfiTokens.textMid)),
              const SizedBox(height: 32),
              PrimaryButton(label: 'Back to Home', onPressed: () => context.go('/home')),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/quiz'),
                child: Text('Back to Quiz', style: TfiTokens.body(14, color: TfiTokens.fire, w: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
