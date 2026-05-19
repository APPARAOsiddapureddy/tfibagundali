import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../models/models.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_widgets.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  List<PollModel> _polls = [];
  String _filter = 'all';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final polls = await context.read<AuthProvider>().api.getPolls();
      if (mounted) setState(() { _polls = polls; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PollModel> get _filtered {
    switch (_filter) {
      case 'word':
        return _polls.where((p) => p.type.contains('WORD')).toList();
      case 'prediction':
        return _polls.where((p) => p.type.contains('PREDICTION')).toList();
      case 'completed':
        return _polls.where((p) => p.status == 'CLOSED').toList();
      default:
        return _polls;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Polls', style: TfiTokens.display(28, color: TfiTokens.fire)),
                Text('మీ అభిప్రాయం — fan opinion only, not betting', style: TfiTokens.telugu(13, color: TfiTokens.textMid)),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: ['all', 'word', 'prediction', 'completed'].map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1)),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                : _filtered.isEmpty
                    ? const EmptyState(message: 'No polls in this filter', icon: '🗳️')
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: TfiTokens.fire,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final p = _filtered[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TfiCard(
                                child: ListTile(
                                  title: Text(p.question, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w600)),
                                  subtitle: Text('${_pollTypeLabel(p.type)} · ${p.totalVotes ?? 0} votes', style: TfiTokens.body(11, color: TfiTokens.textLo)),
                                  trailing: const Icon(Icons.chevron_right, color: TfiTokens.fire),
                                  onTap: () => context.push('/polls/${p.id}'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _pollTypeLabel(String type) {
    if (type.contains('WORD')) return 'Word poll';
    if (type.contains('REACTION')) return 'Reaction';
    if (type.contains('PREDICTION')) return 'Fan prediction';
    return 'Poll';
  }
}

class PollDetailScreen extends StatefulWidget {
  const PollDetailScreen({super.key, required this.pollId});
  final String pollId;

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  PollModel? _poll;
  final _wordController = TextEditingController();
  bool _loading = true;
  bool _voted = false;
  bool _submitting = false;

  static const _wordSuggestions = ['Mass', 'Fire', 'Goosebumps', 'Blockbuster', 'Waiting'];
  static const _reactionEmojis = {
    'excited': '🔥 Very excited',
    'mass': '💥 Mass hype',
    'love': '😍 Loved it',
    'waiting': '⏳ Waiting',
    'more': '🤔 Need more',
  };

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await context.read<AuthProvider>().api.getPoll(widget.pollId);
      if (mounted) {
        setState(() {
          _poll = p;
          _voted = p.userVote != null || p.status == 'CLOSED';
          _loading = false;
        });
        context.read<AuthProvider>().events.track('poll_viewed', contentType: 'poll', contentId: widget.pollId, sourceScreen: 'polls');
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _vote({String? optionId, String? wordText}) async {
    if (_submitting || _voted) return;
    setState(() => _submitting = true);
    try {
      await context.read<AuthProvider>().api.votePoll(widget.pollId, optionId: optionId, wordText: wordText);
      if (wordText != null) {
        context.read<AuthProvider>().events.track('word_poll_submitted', contentType: 'poll', contentId: widget.pollId, sourceScreen: 'polls');
      } else {
        context.read<AuthProvider>().events.track('poll_voted', contentType: 'poll', contentId: widget.pollId, sourceScreen: 'polls');
      }
      await _load();
      if (mounted) setState(() => _voted = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool get _isPrediction => _poll?.type.contains('PREDICTION') == true;
  bool get _isReaction => _poll?.type.contains('REACTION') == true;
  bool get _isWord => _poll?.type.contains('WORD') == true;

  String _reactionLabel(String label) {
    final key = label.toLowerCase();
    for (final e in _reactionEmojis.entries) {
      if (key.contains(e.key)) return e.value;
    }
    return label;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const TfiScreen(child: Center(child: CircularProgressIndicator(color: TfiTokens.fire)));
    }
    if (_poll == null) {
      return const TfiScreen(child: EmptyState(message: 'Poll not found'));
    }

    return TfiScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButtonCircle(onTap: () => context.pop()),
            const SizedBox(height: 16),
            Text(_poll!.question, style: TfiTokens.display(22, color: TfiTokens.textHi)),
            const SizedBox(height: 8),
            TfiChip(label: _poll!.type, color: TfiTokens.purple),
            if (_isPrediction) ...[
              const SizedBox(height: 12),
              TfiCard(
                child: Text(
                  'Just for fan opinion. No money, no betting, no prizes.',
                  style: TfiTokens.body(13, color: TfiTokens.textMid),
                ),
              ),
            ],
            if (_poll!.status == 'CLOSED') ...[
              const SizedBox(height: 8),
              Text('Poll closed — final results', style: TfiTokens.body(12, color: TfiTokens.gold)),
            ],
            const SizedBox(height: 24),
            if (_isWord && !_voted) ...[
              Wrap(
                spacing: 8,
                children: _wordSuggestions.map((w) {
                  return ActionChip(label: Text(w), onPressed: () => _wordController.text = w);
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _wordController,
                maxLength: 20,
                style: TfiTokens.body(16, color: TfiTokens.textHi),
                decoration: InputDecoration(
                  hintText: 'Your word...',
                  filled: true,
                  fillColor: TfiTokens.bg2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: _submitting ? 'Submitting...' : 'Submit', onPressed: _submitting ? null : () => _vote(wordText: _wordController.text.trim())),
            ] else if (!_voted)
              ..._poll!.options.map((o) {
                final label = _isReaction ? _reactionLabel(o.label) : o.label;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PrimaryButton(
                    label: label,
                    filled: false,
                    onPressed: _submitting ? null : () => _vote(optionId: o.id),
                  ),
                );
              })
            else
              ..._poll!.options.map((o) {
                final pct = o.percent ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TfiCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(_isReaction ? _reactionLabel(o.label) : o.label, style: TfiTokens.body(14, color: TfiTokens.textHi))),
                            Text('$pct%', style: TfiTokens.body(14, color: TfiTokens.gold, w: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: pct / 100, color: TfiTokens.fire, backgroundColor: TfiTokens.bg2),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
