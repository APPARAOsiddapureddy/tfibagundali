import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

enum PollKind { poll, prediction }

class FanPoll {
  const FanPoll({
    required this.id,
    required this.kind,
    required this.question,
    required this.options,
    required this.votes,
    this.badge,
  });

  final String id;
  final PollKind kind;
  final String question;
  final List<String> options;
  final List<int> votes;
  final String? badge;
}

// TODO(backend): Replace this list with GET /v1/polls?status=active.
// Backend should return poll id, kind, question, options, vote counts,
// user_vote, close time, and result status for predictions.
const _mockPolls = [
  FanPoll(
    id: 'director-battle',
    kind: PollKind.poll,
    badge: 'Director Poll',
    question: 'Who is the better director right now?',
    options: ['S. S. Rajamouli', 'Sukumar', 'Trivikram', 'Prashanth Neel'],
    votes: [428, 386, 294, 331],
  ),
  FanPoll(
    id: 'best-plot',
    kind: PollKind.poll,
    badge: 'Story Poll',
    question: 'Which movie has the best plot?',
    options: ['Rangasthalam', 'Jersey', 'Eega', 'Agent Sai Srinivasa Athreya'],
    votes: [365, 412, 328, 241],
  ),
  FanPoll(
    id: 'best-comeback',
    kind: PollKind.poll,
    badge: 'Fan Choice',
    question: 'Which comeback announcement has more hype?',
    options: [
      'Mass action film',
      'Love story',
      'Political drama',
      'Pan-India thriller',
    ],
    votes: [514, 206, 188, 347],
  ),
];

const _mockPredictions = [
  FanPoll(
    id: 'movie-result-prediction',
    kind: PollKind.prediction,
    badge: 'Prediction',
    question: 'What will be the result of the next big star movie?',
    options: ['Blockbuster', 'Hit', 'Flop', 'Utter Flop'],
    votes: [512, 374, 92, 41],
  ),
  FanPoll(
    id: 'opening-day-prediction',
    kind: PollKind.prediction,
    badge: 'Box Office Mood',
    question: 'How will the opening day talk be?',
    options: ['Super Positive', 'Mixed', 'Below Average', 'Disaster Talk'],
    votes: [441, 292, 86, 37],
  ),
  FanPoll(
    id: 'music-prediction',
    kind: PollKind.prediction,
    badge: 'Album Prediction',
    question: 'How will the album perform after release?',
    options: ['Chartbuster', 'Good', 'Average', 'Forgettable'],
    votes: [387, 339, 126, 58],
  ),
];

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  var _tab = PollKind.poll;
  final Map<String, int> _votes = {};

  List<FanPoll> get _items =>
      _tab == PollKind.poll ? _mockPolls : _mockPredictions;

  void _vote(FanPoll poll, int optionIndex) {
    // TODO(backend): Submit vote to POST /v1/polls/:id/vote.
    // Backend should enforce one vote per user and return updated totals.
    setState(() => _votes[poll.id] = optionIndex);
  }

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Polls',
                    style: TfiTokens.display(28, color: TfiTokens.fire),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Fan opinion, movie debates, and release predictions',
                    style: TfiTokens.body(13, color: TfiTokens.textMid),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PollTabs(
                selected: _tab,
                onChanged: (tab) => setState(() => _tab = tab),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: _FeatureBanner(kind: _tab),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _DailyHighlight(
                poll: _items.first,
                selectedIndex: _votes[_items.first.id],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final poll = _items[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _PollCard(
                  poll: poll,
                  selectedIndex: _votes[poll.id],
                  onVote: (optionIndex) => _vote(poll, optionIndex),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _PollTabs extends StatelessWidget {
  const _PollTabs({required this.selected, required this.onChanged});

  final PollKind selected;
  final ValueChanged<PollKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TfiTokens.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Polls',
              selected: selected == PollKind.poll,
              onTap: () => onChanged(PollKind.poll),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Predictions',
              selected: selected == PollKind.prediction,
              onTap: () => onChanged(PollKind.prediction),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? TfiTokens.gradFire : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TfiTokens.body(
            13,
            color: selected ? Colors.white : TfiTokens.textMid,
            w: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner({required this.kind});

  final PollKind kind;

  @override
  Widget build(BuildContext context) {
    final isPrediction = kind == PollKind.prediction;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPrediction ? TfiTokens.gradPurple : TfiTokens.gradMass,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isPrediction
                  ? Icons.trending_up_rounded
                  : Icons.how_to_vote_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPrediction ? 'Fan Predictions' : 'Fan Polls',
                  style: TfiTokens.display(22, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  isPrediction
                      ? 'Predict the release mood before everyone else.'
                      : 'Vote on cinema debates and see what fans think.',
                  style: TfiTokens.body(
                    12,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyHighlight extends StatelessWidget {
  const _DailyHighlight({required this.poll, required this.selectedIndex});

  final FanPoll poll;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final color = poll.kind == PollKind.prediction
        ? TfiTokens.purple
        : TfiTokens.fire;
    final label = poll.kind == PollKind.prediction
        ? 'Featured prediction'
        : 'Daily fan debate';
    final status = selectedIndex == null ? 'Open now' : 'Vote recorded';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              poll.kind == PollKind.prediction
                  ? Icons.lock_clock_rounded
                  : Icons.local_fire_department_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TfiTokens.body(11, color: color, w: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  poll.question,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TfiTokens.body(
                    13,
                    color: TfiTokens.textHi,
                    w: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TfiTokens.body(
              11,
              color: TfiTokens.textLo,
              w: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  const _PollCard({
    required this.poll,
    required this.selectedIndex,
    required this.onVote,
  });

  final FanPoll poll;
  final int? selectedIndex;
  final ValueChanged<int> onVote;

  bool get _voted => selectedIndex != null;

  @override
  Widget build(BuildContext context) {
    final total =
        poll.votes.fold<int>(0, (sum, votes) => sum + votes) + (_voted ? 1 : 0);
    final color = poll.kind == PollKind.prediction
        ? TfiTokens.purple
        : TfiTokens.fire;
    final positiveVotes = poll.kind == PollKind.prediction
        ? poll.votes.take(2).fold<int>(0, (sum, votes) => sum + votes) +
              ((selectedIndex != null && selectedIndex! <= 1) ? 1 : 0)
        : 0;
    final moodPercent = total == 0
        ? 0
        : ((positiveVotes / total) * 100).round();

    return TfiCard(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TfiChip(label: poll.badge ?? 'Poll', color: color, active: true),
              const Spacer(),
              if (poll.kind == PollKind.prediction) ...[
                Text(
                  'Closes in 2d 4h',
                  style: TfiTokens.body(
                    11,
                    color: TfiTokens.gold,
                    w: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                '$total votes',
                style: TfiTokens.body(
                  11,
                  color: TfiTokens.textLo,
                  w: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            poll.question,
            style: TfiTokens.display(21, color: TfiTokens.textHi, height: 1.12),
          ),
          const SizedBox(height: 14),
          ...List.generate(poll.options.length, (index) {
            final votes = poll.votes[index] + (selectedIndex == index ? 1 : 0);
            final percent = total == 0 ? 0 : ((votes / total) * 100).round();
            return _PollOption(
              label: poll.options[index],
              percent: percent,
              selected: selectedIndex == index,
              voted: _voted,
              color: color,
              onTap: () => onVote(index),
            );
          }),
          if (poll.kind == PollKind.prediction) ...[
            const SizedBox(height: 4),
            _MoodMeter(percent: moodPercent, color: color),
          ],
        ],
      ),
    );
  }
}

class _MoodMeter extends StatelessWidget {
  const _MoodMeter({required this.percent, required this.color});

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TfiTokens.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Fan mood',
                  style: TfiTokens.body(
                    12,
                    color: TfiTokens.textMid,
                    w: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$percent% positive',
                style: TfiTokens.body(
                  12,
                  color: TfiTokens.gold,
                  w: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 7,
              child: Stack(
                children: [
                  Container(color: Colors.white.withValues(alpha: 0.08)),
                  FractionallySizedBox(
                    widthFactor: percent / 100,
                    child: Container(color: color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PollOption extends StatelessWidget {
  const _PollOption({
    required this.label,
    required this.percent,
    required this.selected,
    required this.voted,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int percent;
  final bool selected;
  final bool voted;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: voted ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.16) : TfiTokens.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color.withValues(alpha: 0.65) : TfiTokens.line,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (voted)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percent / 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: TfiTokens.body(
                                14,
                                color: TfiTokens.textHi,
                                w: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TfiTokens.gold.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: TfiTokens.gold.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                'Your pick',
                                style: TfiTokens.body(
                                  10,
                                  color: TfiTokens.gold,
                                  w: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (voted)
                      Text(
                        '$percent%',
                        style: TfiTokens.body(
                          13,
                          color: selected ? TfiTokens.gold : TfiTokens.textMid,
                          w: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PollDetailScreen extends StatelessWidget {
  const PollDetailScreen({super.key, required this.pollId});

  final String pollId;

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Polls',
                style: TfiTokens.display(28, color: TfiTokens.fire),
              ),
              const SizedBox(height: 8),
              Text(
                'Vote from the Polls tab.',
                textAlign: TextAlign.center,
                style: TfiTokens.body(14, color: TfiTokens.textMid),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Back to Polls',
                onPressed: () => context.go('/polls'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
