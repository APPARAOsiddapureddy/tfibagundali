import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/sharing/whatsapp_share_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/quiz_session_model.dart';
import '../providers/quiz_provider.dart';

class QuizResultsScreen extends ConsumerStatefulWidget {
  const QuizResultsScreen({super.key, this.summary});

  final QuizResultsSummary? summary;

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen> {
  final GlobalKey _shareCardKey = GlobalKey();

  Future<void> _shareQuizScore(QuizResultsSummary s) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Creating score card…')));
    try {
      final boundary = _shareCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        await WhatsAppShareService.shareText(
          'I scored ${s.score}/5 in TFI Bagundali daily quiz! 🎬🏆 '
          'Can you beat me? Download: https://tfibagundali.in/app',
        );
        return;
      }
      final image = await boundary.toImage(pixelRatio: 2);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/quiz_score_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      final text = 'I scored ${s.score}/5 in TFI Bagundali daily quiz! 🎬🏆 '
          'Can you beat me? Download: https://tfibagundali.in/app';

      await WhatsAppShareService.shareImage(
        imagePath: file.path,
        caption: text,
        toStatus: false,
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Share failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromRoute = GoRouterState.of(context).extra is QuizResultsSummary
        ? GoRouterState.of(context).extra as QuizResultsSummary
        : null;
    final s = widget.summary ??
        fromRoute ??
        const QuizResultsSummary(score: 0, total: 5, coinsEarned: 0, streak: 0);

    final headline = switch (s.score) {
      5 => 'PAKKAA FAN!',
      4 => 'DHAMAKA!',
      3 => 'Practice Cheyyi!',
      _ => 'Poyi Movies Choodu!',
    };

    final sub = switch (s.score) {
      5 => 'Nuvvu legend ra!',
      4 => '🔥 Super performance!',
      3 => 'Inka next time better!',
      _ => '😄 Chill ra!',
    };

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 24),
            Center(
              child: Text(
                switch (s.score) {
                  5 => '🏆',
                  4 => '🔥',
                  3 => '💪',
                  _ => '😄',
                },
                style: AppTheme.emoji(s.score == 5 ? 64 : 52),
              ),
            ).animate().scale(duration: 420.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: 12),
            Center(
              child: Text(
                headline,
                textAlign: TextAlign.center,
                style: AppTheme.headingLarge.copyWith(color: AppColors.red),
              ),
            ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.06, curve: Curves.easeOutCubic),
            const SizedBox(height: 6),
            Center(
              child: Text(sub, style: AppTheme.bodyMedium.copyWith(color: AppColors.textMuted2)),
            ),
            if (s.score == 5) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: Lottie.network(
                  'https://assets10.lottiefiles.com/packages/lf20_u4yrau.json',
                  repeat: false,
                  errorBuilder: (_, __, ___) => Center(child: Text('🎉', style: AppTheme.emoji(56))),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '${s.score}', style: AppTheme.headingLarge.copyWith(fontSize: 80)),
                    TextSpan(
                      text: '/${s.total}',
                      style: AppTheme.headingMedium.copyWith(color: AppColors.textMuted2, fontSize: 28),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                List.filled(s.score, '⭐').join(' '),
                style: AppTheme.bodyLarge.copyWith(fontSize: 22, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 18),
            if (s.coinsEarned > 0)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.goldDim,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                ),
                child: Column(
                  children: [
                    Text(
                      '+${s.coinsEarned} 🪙',
                      style: AppTheme.headingLarge.copyWith(color: AppColors.gold, fontSize: 42),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'COINS EARNED TODAY',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.textMuted2,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            if (s.streak > 0) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.redDim,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.35)),
                ),
                child: Text(
                  '🔥 ${s.streak} day streak! Keep it up!',
                  style: AppTheme.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: 16),
            RepaintBoundary(
              key: _shareCardKey,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2a0a12), Color(0xFF12060c)],
                  ),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Text('TFI BAGUNDALI', style: AppTheme.bodySmall.copyWith(letterSpacing: 3, color: AppColors.gold)),
                    const SizedBox(height: 8),
                    Text('${s.score}/${s.total}', style: AppTheme.headingLarge.copyWith(fontSize: 48, color: Colors.white)),
                    Text('Daily Quiz Score', style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2)),
                    if (s.streak > 0) Text('Streak ${s.streak} 🔥', style: AppTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _shareQuizScore(s),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whatsapp,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.rButton)),
                ),
                child: Text(
                  '📲 SHARE MY SCORE ON WHATSAPP',
                  style: AppTheme.headingSmall.copyWith(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border2),
                  backgroundColor: AppColors.bg3,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.rButton)),
                ),
                child: Text("See Today's Leaderboard", style: AppTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                ref.read(quizProvider.notifier).reset();
                context.go('/home');
              },
              child: Text('Go to Home', style: AppTheme.bodyMedium.copyWith(color: AppColors.textMuted2)),
            ),
          ],
        ),
      ),
    );
  }
}
