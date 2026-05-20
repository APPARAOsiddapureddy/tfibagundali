import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../models/models.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_cinematic_components.dart';

const _pollFilters = ['All', 'Trending', 'My Hero', 'Movies', 'Word Polls', 'Predictions', 'Completed'];

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  int _filterIndex = 0;
  List<PollModel> _polls = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().events.track('polls_viewed', sourceScreen: 'polls');
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final polls = await context.read<AuthProvider>().api.getPolls();
      if (mounted) setState(() { _polls = polls; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = userFacingError(e);
          _loading = false;
        });
      }
    }
  }

  List<PollModel> get _filtered {
    final filter = _pollFilters[_filterIndex];
    final favHero = context.read<AuthProvider>().user?.favouriteHero?.name;
    return _polls.where((p) {
      switch (filter) {
        case 'Trending':
          return (p.totalVotes ?? 0) >= 50;
        case 'My Hero':
          return favHero != null && p.heroName != null && p.heroName!.toLowerCase().contains(favHero.toLowerCase().split(' ').first);
        case 'Movies':
          return p.movieName != null && p.movieName!.isNotEmpty;
        case 'Word Polls':
          return p.isWordPoll;
        case 'Predictions':
          return p.isPrediction;
        case 'Completed':
          return p.isClosed || p.hasVoted;
        default:
          return true;
      }
    }).toList();
  }

  String _typeBadge(PollModel p) {
    if (p.isWordPoll) return 'Word';
    if (p.isReactionPoll) return 'Reaction';
    if (p.isPrediction) return 'Prediction';
    return 'Poll';
  }

  String _timeLeft(PollModel p) {
    if (p.isClosed) return 'Closed';
    if (p.hasVoted) return 'Voted';
    final end = p.endsAt;
    if (end == null) return 'Open';
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return 'Closed';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    return '${diff.inHours}h left';
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return TfiScaffold(
      child: RefreshIndicator(
        onRefresh: _load,
        color: TfiTokens.gold,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 12, TfiTokens.padScreen, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Polls', style: TfiTokens.display(26, color: TfiTokens.gold)),
                    Text('Fan debates & opinions — free, no betting', style: TfiTokens.telugu(12, color: TfiTokens.textLo)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: TfiFilterChipRow(
                  labels: _pollFilters,
                  selectedIndex: _filterIndex,
                  onSelected: (i) => setState(() => _filterIndex = i),
                ),
              ),
            ),
            if (_loading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(TfiTokens.padScreen),
                  child: Shimmer.fromColors(
                    baseColor: TfiTokens.card1,
                    highlightColor: TfiTokens.card3,
                    child: Column(children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: TfiShimmerCard(height: 120)))),
                  ),
                ),
              )
            else if (_error != null)
              SliverToBoxAdapter(child: ErrorState(message: _error!, onRetry: _load))
            else if (items.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(padding: EdgeInsets.all(32), child: EmptyState(message: 'No polls in this filter yet', icon: '🗳️')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final poll = items[i];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(TfiTokens.padScreen, 0, TfiTokens.padScreen, i == items.length - 1 ? 88 : 12),
                      child: _PollListCard(
                        poll: poll,
                        typeBadge: _typeBadge(poll),
                        timeLabel: _timeLeft(poll),
                        onTap: () => context.push('/polls/${poll.id}'),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PollListCard extends StatelessWidget {
  const _PollListCard({
    required this.poll,
    required this.typeBadge,
    required this.timeLabel,
    required this.onTap,
  });

  final PollModel poll;
  final String typeBadge;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final voted = poll.hasVoted;
    final closed = poll.isClosed;

    return TfiCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TfiBadge(typeBadge),
              const SizedBox(width: 8),
              if (poll.isPrediction)
                Expanded(
                  child: Text(
                    'Fan opinion only',
                    style: TfiTokens.body(10, color: TfiTokens.textLo),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              TfiCountdownChip(timeLabel),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            poll.question,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TfiTokens.title(16, w: FontWeight.w800),
          ),
          if (poll.heroName != null || poll.movieName != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                if (poll.heroName != null) TfiTagChip(label: poll.heroName!),
                if (poll.movieName != null) TfiTagChip(label: poll.movieName!),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text('${poll.totalVotes ?? 0} votes', style: TfiTokens.body(12, color: TfiTokens.textLo)),
              const Spacer(),
              if (voted)
                Text('Voted ✓', style: TfiTokens.body(11, color: TfiTokens.green, w: FontWeight.w800))
              else if (closed)
                Text('Closed', style: TfiTokens.body(11, color: TfiTokens.textLo, w: FontWeight.w800))
              else
                Text('Vote →', style: TfiTokens.body(11, color: TfiTokens.gold, w: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}
