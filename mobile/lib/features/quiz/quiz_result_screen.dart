import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.time,
  });

  final int rank;
  final String name;
  final int score;
  final String time;
}

// TODO(backend): Replace these demo lists with GET /v1/quiz/leaderboard
// using a period query parameter, for example period=daily or period=weekly.
// The backend should rank by score, completion time, and submitted_at.
const _dailyLeaderboard = [
  LeaderboardEntry(rank: 1, name: 'Rakesh', score: 5, time: '00:42'),
  LeaderboardEntry(rank: 2, name: 'Mounika', score: 5, time: '00:57'),
  LeaderboardEntry(rank: 3, name: 'Sai Kumar', score: 4, time: '00:39'),
  LeaderboardEntry(rank: 4, name: 'Anusha', score: 4, time: '01:08'),
  LeaderboardEntry(rank: 5, name: 'Kiran', score: 3, time: '00:51'),
];

const _weeklyLeaderboard = [
  LeaderboardEntry(rank: 1, name: 'Mounika', score: 34, time: '06 quizzes'),
  LeaderboardEntry(rank: 2, name: 'Rakesh', score: 32, time: '06 quizzes'),
  LeaderboardEntry(rank: 3, name: 'Sai Kumar', score: 29, time: '05 quizzes'),
  LeaderboardEntry(rank: 4, name: 'Anusha', score: 27, time: '05 quizzes'),
  LeaderboardEntry(rank: 5, name: 'Kiran', score: 24, time: '05 quizzes'),
];

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key, this.result});
  final Map<String, dynamic>? result;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  var _period = _LeaderboardPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final score = widget.result?['score'] ?? 0;
    final total = widget.result?['total'] ?? 0;
    final message = widget.result?['message'] as String? ?? 'Good try!';
    final entries = _period == _LeaderboardPeriod.daily
        ? _dailyLeaderboard
        : _weeklyLeaderboard;

    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  BackButtonCircle(onTap: () => context.go('/quiz')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Quiz Result',
                      style: TfiTokens.display(26, color: TfiTokens.textHi),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: TfiTokens.gradMass,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Text(
                      'QUIZ COMPLETE',
                      style: TfiTokens.body(
                        12,
                        color: Colors.white70,
                        w: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score / $total',
                      style: TfiTokens.display(48, color: TfiTokens.gold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TfiTokens.body(
                        14,
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(child: SectionTitle(title: 'Leaderboard')),
                  _PeriodToggle(
                    period: _period,
                    onChanged: (period) => setState(() => _period = period),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TfiCard(
                noPad: true,
                accent: _period == _LeaderboardPeriod.daily
                    ? TfiTokens.fire
                    : TfiTokens.purple,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                      child: Row(
                        children: [
                          TfiChip(
                            label: _period == _LeaderboardPeriod.daily
                                ? 'TODAY'
                                : 'THIS WEEK',
                            color: _period == _LeaderboardPeriod.daily
                                ? TfiTokens.fire
                                : TfiTokens.purple,
                            active: true,
                          ),
                          const Spacer(),
                          Text(
                            _period == _LeaderboardPeriod.daily
                                ? 'Resets midnight'
                                : 'Mon-Sun total',
                            style: TfiTokens.body(
                              11,
                              color: TfiTokens.textLo,
                              w: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...entries.map((entry) => _LeaderboardRow(entry: entry)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
              child: PrimaryButton(
                label: 'Back to Quiz',
                onPressed: () => context.go('/quiz'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryButton(
                label: 'Back to Home',
                filled: false,
                onPressed: () => context.go('/home'),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

enum _LeaderboardPeriod { daily, weekly }

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.period, required this.onChanged});

  final _LeaderboardPeriod period;
  final ValueChanged<_LeaderboardPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TfiTokens.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            label: 'Daily',
            active: period == _LeaderboardPeriod.daily,
            onTap: () => onChanged(_LeaderboardPeriod.daily),
          ),
          _ToggleButton(
            label: 'Weekly',
            active: period == _LeaderboardPeriod.weekly,
            onTap: () => onChanged(_LeaderboardPeriod.weekly),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? TfiTokens.fire.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TfiTokens.body(
            12,
            color: active ? TfiTokens.gold : TfiTokens.textLo,
            w: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final rankColor = switch (entry.rank) {
      1 => TfiTokens.gold,
      2 => TfiTokens.cyan,
      3 => TfiTokens.fire,
      _ => TfiTokens.textLo,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: entry.rank == 1
              ? TfiTokens.gold.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: entry.rank == 1
                ? TfiTokens.gold.withValues(alpha: 0.24)
                : TfiTokens.line,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: rankColor.withValues(alpha: 0.26)),
              ),
              child: Text(
                '#${entry.rank}',
                style: TfiTokens.mono(11, color: rankColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: TfiTokens.body(
                      14,
                      color: TfiTokens.textHi,
                      w: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.time,
                    style: TfiTokens.body(
                      11,
                      color: TfiTokens.textLo,
                      w: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.score}',
              style: TfiTokens.display(22, color: TfiTokens.gold),
            ),
          ],
        ),
      ),
    );
  }
}
