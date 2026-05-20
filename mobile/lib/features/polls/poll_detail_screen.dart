import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../models/models.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_cinematic_components.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_poster_placeholder.dart';

const _wordSuggestions = ['Mass', 'Fire', 'Goosebumps', 'Blockbuster', 'Waiting', 'Epic'];

const _reactionOptions = [
  ('fire', '🔥', 'Very excited'),
  ('mass', '💥', 'Mass hype'),
  ('love', '😍', 'Loved it'),
  ('wait', '⏳', 'Waiting'),
  ('think', '🤔', 'Need more'),
];

class PollDetailScreen extends StatefulWidget {
  const PollDetailScreen({super.key, required this.pollId});
  final String pollId;

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  PollModel? _poll;
  Map<String, dynamic>? _results;
  bool _loading = true;
  String? _error;
  bool _submitting = false;
  final _wordCtrl = TextEditingController();

  @override
  void dispose() {
    _wordCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<AuthProvider>().api;
      final poll = await api.getPoll(widget.pollId);
      Map<String, dynamic>? results;
      if (poll.hasVoted || poll.isClosed) {
        try {
          results = await api.getPollResults(widget.pollId);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _poll = poll;
          _results = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = userFacingError(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _vote({String? optionId, String? wordText, String? reaction}) async {
    setState(() => _submitting = true);
    try {
      await context.read<AuthProvider>().api.votePoll(
            widget.pollId,
            optionId: optionId,
            wordText: wordText,
            reaction: reaction,
          );
      context.read<AuthProvider>().events.track('poll_voted', contentType: 'poll', contentId: widget.pollId, sourceScreen: 'poll_detail');
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _shareResult() async {
    final poll = _poll;
    if (poll == null) return;
    await Share.share('TFI Poll — ${poll.question}\nFan opinion on TFI Bagundali');
  }

  String _typeBadge(PollModel p) {
    if (p.isWordPoll) return 'Word Poll';
    if (p.isReactionPoll) return 'Reaction';
    if (p.isPrediction) return 'Prediction';
    return 'Poll';
  }

  String _timeLeft(PollModel p) {
    if (p.isClosed) return 'Closed';
    final end = p.endsAt;
    if (end == null) return 'Open';
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return 'Closed';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return TfiScaffold(
        child: Column(
          children: [
            TfiDetailAppBar(title: 'Poll', onBack: () => context.pop()),
            Expanded(
              child: Shimmer.fromColors(
                baseColor: TfiTokens.card1,
                highlightColor: TfiTokens.card3,
                child: const Padding(padding: EdgeInsets.all(16), child: TfiShimmerCard(height: 280)),
              ),
            ),
          ],
        ),
      );
    }
    if (_error != null || _poll == null) {
      return TfiScaffold(
        child: Column(
          children: [
            TfiDetailAppBar(title: 'Poll', onBack: () => context.pop()),
            Expanded(child: ErrorState(message: _error ?? 'Poll not found', onRetry: _load)),
          ],
        ),
      );
    }

    final poll = _poll!;
    final showResults = poll.hasVoted || poll.isClosed || _results != null;

    return TfiScaffold(
      child: Column(
        children: [
          TfiDetailAppBar(title: 'Poll', onBack: () => context.pop()),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: TfiTokens.gold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 0, TfiTokens.padScreen, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (poll.imageUrl != null && poll.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(TfiTokens.rCard),
                        child: TfiNetworkImage(url: poll.imageUrl, height: 160, fit: BoxFit.cover, placeholderKind: TfiPlaceholderKind.poll, placeholderTitle: poll.question),
                      )
                    else
                      TfiPosterPlaceholder(kind: TfiPlaceholderKind.poll, title: poll.question, height: 120, icon: Icons.how_to_vote_rounded),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        TfiBadge(_typeBadge(poll)),
                        const SizedBox(width: 8),
                        TfiCountdownChip(_timeLeft(poll)),
                        const Spacer(),
                        Text('${poll.totalVotes ?? 0} votes', style: TfiTokens.body(11, color: TfiTokens.textLo)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(poll.question, style: TfiTokens.display(22, color: TfiTokens.textHi, height: 1.15)),
                    if (poll.heroName != null || poll.movieName != null) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (poll.heroName != null) TfiTagChip(label: poll.heroName!),
                          if (poll.movieName != null) TfiTagChip(label: poll.movieName!),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (showResults)
                      _PollResultsView(poll: poll, results: _results, onShare: _shareResult)
                    else if (poll.isWordPoll)
                      _WordPollBody(
                        controller: _wordCtrl,
                        submitting: _submitting,
                        onSubmit: (text) => _vote(wordText: text),
                      )
                    else if (poll.isReactionPoll)
                      _ReactionPollBody(submitting: _submitting, onVote: (r) => _vote(reaction: r))
                    else
                      _ChoicePollBody(
                        poll: poll,
                        isPrediction: poll.isPrediction,
                        submitting: _submitting,
                        onVote: (id) => _vote(optionId: id),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordPollBody extends StatelessWidget {
  const _WordPollBody({required this.controller, required this.submitting, required this.onSubmit});
  final TextEditingController controller;
  final bool submitting;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return TfiGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your one-word reaction', style: TfiTokens.body(13, color: TfiTokens.textMid)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            style: TfiTokens.display(20, color: TfiTokens.textHi),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: TfiTokens.bg2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: TfiTokens.lineStrong)),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _wordSuggestions.map((w) {
              return GestureDetector(
                onTap: () => controller.text = w,
                child: TfiTagChip(label: w),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TfiPrimaryButton(
            label: 'Submit Word',
            loading: submitting,
            onPressed: submitting || controller.text.trim().isEmpty ? null : () => onSubmit(controller.text.trim()),
          ),
        ],
      ),
    );
  }
}

class _ReactionPollBody extends StatelessWidget {
  const _ReactionPollBody({required this.submitting, required this.onVote});
  final bool submitting;
  final ValueChanged<String> onVote;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _reactionOptions.map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TfiCard(
            onTap: submitting ? null : () => onVote(r.$1),
            child: Row(
              children: [
                Text(r.$2, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Text(r.$3, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w700)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChoicePollBody extends StatelessWidget {
  const _ChoicePollBody({
    required this.poll,
    required this.isPrediction,
    required this.submitting,
    required this.onVote,
  });
  final PollModel poll;
  final bool isPrediction;
  final bool submitting;
  final ValueChanged<String> onVote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isPrediction)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'Just for fan opinion. No money, no betting.',
              style: TfiTokens.telugu(13, color: TfiTokens.textMid),
            ),
          ),
        ...poll.options.map((o) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TfiCard(
              onTap: submitting ? null : () => onVote(o.id),
              child: Text(o.label, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w700)),
            ),
          );
        }),
      ],
    );
  }
}

class _PollResultsView extends StatelessWidget {
  const _PollResultsView({required this.poll, this.results, required this.onShare});
  final PollModel poll;
  final Map<String, dynamic>? results;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final rawOpts = results?['options'];
    final items = <PollOption>[];
    if (rawOpts is List && rawOpts.isNotEmpty && rawOpts.first is Map) {
      for (final e in rawOpts) {
        items.add(PollOption.fromJson(Map<String, dynamic>.from(e as Map)));
      }
    } else {
      items.addAll(poll.options);
    }

    final total = poll.totalVotes ?? items.fold<int>(0, (s, o) => s + (o.voteCount ?? 0));
    final maxVotes = items.fold<int>(1, (m, o) => (o.voteCount ?? 0) > m ? (o.voteCount ?? 0) : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (poll.hasVoted)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Thanks for voting!', style: TfiTokens.body(13, color: TfiTokens.green, w: FontWeight.w700)),
          ),
        ...items.map((o) {
          final votes = o.voteCount ?? 0;
          final pct = o.percent ?? (total > 0 ? ((votes / total) * 100).round() : 0);
          final selected = poll.userVote == o.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        o.label,
                        style: TfiTokens.body(14, color: selected ? TfiTokens.gold : TfiTokens.textHi, w: FontWeight.w700),
                      ),
                    ),
                    Text('$pct%', style: TfiTokens.body(13, color: TfiTokens.gold, w: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Text('$votes', style: TfiTokens.body(11, color: TfiTokens.textLo)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 8,
                    child: Stack(
                      children: [
                        Container(color: TfiTokens.glass),
                        FractionallySizedBox(
                          widthFactor: maxVotes > 0 ? (votes / maxVotes).clamp(0.0, 1.0) : 0,
                          child: Container(decoration: const BoxDecoration(gradient: TfiTokens.gradGold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        TfiSecondaryButton(label: 'Share result', icon: Icons.share_rounded, onPressed: onShare),
      ],
    );
  }
}
