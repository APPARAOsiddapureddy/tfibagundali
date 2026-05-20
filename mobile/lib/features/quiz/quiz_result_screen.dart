import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_cinematic_components.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key, this.result});
  final Map<String, dynamic>? result;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _loadingBoard = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final data = await context.read<AuthProvider>().api.getQuizLeaderboard();
      final entries = data['entries'] as List? ?? data['leaderboard'] as List? ?? [];
      if (mounted) {
        setState(() {
          _leaderboard = entries.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loadingBoard = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingBoard = false);
    }
  }

  void _shareResult(int score, int total, int? pct) {
    Share.share('TFI Quiz — I scored $score/$total${pct != null ? ' ($pct%)' : ''} on TFI Bagundali!');
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.result?['score'] as int? ?? 0;
    final total = widget.result?['total'] as int? ?? 0;
    final correct = widget.result?['correct'] as int? ?? score;
    final wrong = widget.result?['wrong'] as int? ?? (total - score).clamp(0, total);
    final pct = widget.result?['percentage'] as int? ?? (total > 0 ? ((score / total) * 100).round() : 0);
    final message = widget.result?['message'] as String? ?? 'Quiz complete!';

    return TfiScaffold(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TfiDetailAppBar(title: 'Quiz Result', onBack: () => context.go('/quiz')),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TfiTokens.padScreen),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: TfiTokens.gradMass,
                  borderRadius: BorderRadius.circular(TfiTokens.rHero),
                  boxShadow: [
                    BoxShadow(color: TfiTokens.gold.withValues(alpha: 0.25), blurRadius: 24, spreadRadius: 2),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 8),
                    Text('QUIZ COMPLETE', style: TfiTokens.body(11, color: Colors.white70, w: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('$score / $total', style: TfiTokens.display(52, color: TfiTokens.gold)),
                    Text('$pct%', style: TfiTokens.display(20, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(message, textAlign: TextAlign.center, style: TfiTokens.body(14, color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
              child: Row(
                children: [
                  Expanded(child: _StatBox(label: 'Correct', value: '$correct', color: TfiTokens.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatBox(label: 'Wrong', value: '$wrong', color: TfiTokens.red)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatBox(label: 'Score %', value: '$pct%', color: TfiTokens.gold)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TfiTokens.padScreen),
              child: Column(
                children: [
                  TfiPrimaryButton(label: 'Share Result', icon: Icons.share_rounded, onPressed: () => _shareResult(score, total, pct)),
                  const SizedBox(height: 10),
                  TfiSecondaryButton(label: 'View History', icon: Icons.history_rounded, onPressed: () => context.push('/profile/quiz-history')),
                  const SizedBox(height: 10),
                  TfiSecondaryButton(label: 'Back to Quiz', onPressed: () => context.go('/quiz')),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: TfiSectionHeader(title: 'Leaderboard', subtitle: 'Daily fans')),
          if (_loadingBoard)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(color: TfiTokens.gold)),
              ),
            )
          else if (_leaderboard.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
                child: TfiCard(
                  child: Text('Leaderboard coming soon — play daily to climb ranks!', style: TfiTokens.body(13, color: TfiTokens.textMid)),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final e = _leaderboard[i];
                  final rank = e['rank'] as int? ?? i + 1;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(TfiTokens.padScreen, 0, TfiTokens.padScreen, 8),
                    child: TfiCard(
                      child: Row(
                        children: [
                          Text('#$rank', style: TfiTokens.mono(12, color: TfiTokens.gold)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e['name'] as String? ?? e['display_name'] as String? ?? 'Fan',
                              style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700),
                            ),
                          ),
                          Text('${e['score'] ?? 0}', style: TfiTokens.display(18, color: TfiTokens.gold)),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _leaderboard.length.clamp(0, 10),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: TfiTokens.glassCard(radius: 14),
      child: Column(
        children: [
          Text(value, style: TfiTokens.display(20, color: color)),
          Text(label, style: TfiTokens.body(11, color: TfiTokens.textLo)),
        ],
      ),
    );
  }
}
