import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_cinematic_components.dart';

const _quickGames = [
  ('Movie Trivia', Icons.movie_rounded, 'movies'),
  ('Hero Quiz', Icons.star_rounded, 'heroes'),
  ('Dialogue Guess', Icons.chat_rounded, 'dialogues'),
  ('Song Clue', Icons.music_note_rounded, 'songs'),
];

const _categories = [
  ('Movies', 'movies'),
  ('Heroes', 'heroes'),
  ('General TFI', 'general'),
  ('Dialogues', 'dialogues'),
  ('Songs', 'songs'),
  ('Release Years', 'years'),
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, dynamic>? _home;
  Map<String, dynamic>? _today;
  bool _loading = true;
  String? _error;
  bool _starting = false;

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
      final results = await Future.wait([api.getQuizHome(), api.getQuizToday()]);
      if (mounted) {
        setState(() {
          _home = results[0];
          _today = results[1];
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

  Future<void> _startDaily() async {
    setState(() => _starting = true);
    try {
      final session = await context.read<AuthProvider>().api.startQuiz();
      if (mounted) context.push('/quiz/play', extra: session);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _startCategory(String category) async {
    setState(() => _starting = true);
    try {
      final session = await context.read<AuthProvider>().api.startQuiz(category: category);
      if (mounted) context.push('/quiz/play', extra: session);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  int get _questionCount {
    final n = _today?['question_count'] ?? _today?['questions_count'] ?? _home?['daily_question_count'];
    if (n is int) return n;
    if (n is String) return int.tryParse(n) ?? 5;
    final qs = _today?['questions'] as List?;
    return qs?.length ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    return TfiScaffold(
      child: RefreshIndicator(
        onRefresh: _load,
        color: TfiTokens.gold,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(TfiTokens.padScreen),
                children: [
                  Shimmer.fromColors(
                    baseColor: TfiTokens.card1,
                    highlightColor: TfiTokens.card3,
                    child: const Column(children: [TfiShimmerCard(height: 200), SizedBox(height: 16), TfiShimmerCard(height: 80)]),
                  ),
                ],
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 12, TfiTokens.padScreen, 8),
                      child: Text('Quiz', style: TfiTokens.display(26, color: TfiTokens.gold)),
                    ),
                  ),
                  if (_error != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
                        child: ErrorState(message: _error!, onRetry: _load),
                      ),
                    ),
                  SliverToBoxAdapter(child: _dailyCard()),
                  const SliverToBoxAdapter(child: TfiSectionHeader(title: 'Quick Games')),
                  SliverToBoxAdapter(child: _quickGamesRow()),
                  const SliverToBoxAdapter(child: TfiSectionHeader(title: 'Categories')),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final c = _categories[i];
                        return Padding(
                          padding: EdgeInsets.fromLTRB(TfiTokens.padScreen, 0, TfiTokens.padScreen, i == _categories.length - 1 ? 88 : 8),
                          child: TfiCard(
                            onTap: _starting ? null : () => _startCategory(c.$2),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: TfiTokens.gold.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('${i + 1}', style: TfiTokens.body(14, color: TfiTokens.gold, w: FontWeight.w800)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(c.$1, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w700))),
                                const Icon(Icons.chevron_right_rounded, color: TfiTokens.textFaint),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _categories.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _dailyCard() {
    final title = _today?['title'] as String? ?? _home?['daily_title'] as String? ?? 'TFI Daily Quiz';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: TfiTokens.gradMass,
          borderRadius: BorderRadius.circular(TfiTokens.rHero),
          boxShadow: TfiTokens.cardShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TfiBadge('Daily'),
            const SizedBox(height: 8),
            Text(title, style: TfiTokens.display(24, color: Colors.white, height: 1.05)),
            const SizedBox(height: 6),
            Text('$_questionCount questions · Tollywood trivia', style: TfiTokens.body(13, color: Colors.white70)),
            const SizedBox(height: 16),
            TfiPrimaryButton(label: 'Play Now', loading: _starting, onPressed: _starting ? null : _startDaily),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => context.push('/profile/quiz-history'),
              child: Text('View History →', style: TfiTokens.body(12, color: TfiTokens.gold, w: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickGamesRow() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TfiTokens.padScreen),
        itemCount: _quickGames.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final g = _quickGames[i];
          return GestureDetector(
            onTap: _starting ? null : () => _startCategory(g.$3),
            child: Container(
              width: 88,
              padding: const EdgeInsets.all(12),
              decoration: TfiTokens.glassCard(radius: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(g.$2, color: TfiTokens.gold, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    g.$1,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TfiTokens.body(10, color: TfiTokens.textHi, w: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
