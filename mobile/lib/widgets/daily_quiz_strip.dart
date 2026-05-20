import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

/// Compact strip reminding users to complete today's daily quiz.
///
/// Styled to match the dark cinema theme of the app — uses the
/// fire/gold gradient accent with a subtle dark glass effect.
class DailyQuizStrip extends StatelessWidget {
  const DailyQuizStrip({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // TODO: Hide this widget if the user has already completed today's quiz.
    // Use a provider or API check to determine quiz completion status.
    // Example: if (quizCompletedToday) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF1A1428), // subtle warm dark purple
                Color(0xFF14172A), // matches TfiCard bg
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TfiTokens.fire.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: TfiTokens.fire.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container with fire gradient
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: TfiTokens.gradFire,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: TfiTokens.fire.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete today\'s quiz',
                      style: TfiTokens.body(13.5, color: TfiTokens.textHi, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '10 Qs · 15s each · Earn coins',
                      style: TfiTokens.body(11, color: TfiTokens.textLo),
                    ),
                  ],
                ),
              ),

              // Chevron with accent glow
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: TfiTokens.fire.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: TfiTokens.fire.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
