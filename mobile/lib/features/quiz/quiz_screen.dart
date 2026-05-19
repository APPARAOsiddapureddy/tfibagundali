import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_widgets.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, dynamic>? _home;
  List<dynamic> _history = [];
  Map<String, dynamic>? _leaderboard;
  bool _loading = true;

  static const _quickGameLabels = {
    'dialogue': 'Guess the Dialogue',
    'song_clue': 'Song Clue',
    'poster': 'Poster Guess',
    'silhouette': 'Hero Silhouette',
    'release_year': 'Release Year',
    'director_match': 'Director-Movie Match',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<AuthProvider>().api;
    try {
      final home = await api.getQuizHome();
      final history = await api.getQuizHistory();
      final lb = await api.getQuizLeaderboard();
      if (mounted) {
        setState(() {
          _home = home;
          _history = history;
          _leaderboard = lb;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startToday({String? category}) async {
    final api = context.read<AuthProvider>().api;
    final events = context.read<AuthProvider>().events;
    try {
      final today = await api.getQuizToday();
      final session = await api.startQuiz(category: category);
      events.track('quiz_started', contentType: 'quiz', sourceScreen: 'quiz', metadata: category != null ? {'category': category} : null);
      if (category != null) {
        events.track('quiz_category_played', contentType: 'quiz', sourceScreen: 'quiz', metadata: {'category': category});
      }
      if (!mounted) return;
      context.push('/quiz/play', extra: {
        'session_id': session['session_id'],
        'questions': today['questions'],
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lb = (_leaderboard?['leaderboard'] as List?) ?? [];
    final quickGames = (_home?['quick_games'] as List?) ?? [];

    return TfiScreen(
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
          : RefreshIndicator(
              onRefresh: _load,
              color: TfiTokens.fire,
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: TfiTopBar(title: 'QUIZ', subtitle: 'TFI Trivia')),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(gradient: TfiTokens.gradFire, borderRadius: BorderRadius.circular(22)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("TODAY'S TFI TRIVIA", style: TfiTokens.body(11, color: Colors.white70, w: FontWeight.w800)),
                            Text('Tollywood Trivia', style: TfiTokens.display(28, color: Colors.white)),
                            Text(
                              _home?['daily_available'] == true ? '5 questions · fan knowledge only' : 'No quiz today',
                              style: TfiTokens.body(13, color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(label: 'Start Quiz →', onPressed: () => _startToday()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (quickGames.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: SectionTitle(title: 'Quick Games'),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: quickGames.map((g) {
                          final key = g.toString();
                          final label = _quickGameLabels[key] ?? key;
                          return ActionChip(
                            label: Text(label, style: TfiTokens.body(12, color: TfiTokens.textHi)),
                            onPressed: () => _startToday(category: key),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: SectionTitle(title: 'Categories'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        children: ((_home?['categories'] as List?) ?? []).map((c) {
                          return TfiChip(label: c.toString(), color: TfiTokens.purple);
                        }).toList(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: SectionTitle(title: 'Leaderboard'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: lb.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: EmptyState(message: 'Leaderboard coming soon — play today\'s quiz!', icon: '🏆'),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TfiCard(
                              child: Column(
                                children: lb.take(5).map((e) {
                                  final m = Map<String, dynamic>.from(e as Map);
                                  return ListTile(
                                    title: Text(m['display_name']?.toString() ?? 'Fan', style: TfiTokens.body(14, color: TfiTokens.textHi)),
                                    trailing: Text('${m['score'] ?? 0}', style: TfiTokens.body(14, color: TfiTokens.gold, w: FontWeight.w800)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: SectionTitle(title: 'Quiz History'),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final h = _history[i] as Map<String, dynamic>? ?? {};
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: TfiCard(
                            child: ListTile(
                              leading: const Icon(Icons.quiz, color: TfiTokens.fire),
                              title: Text(h['quiz_date']?.toString() ?? 'Quiz', style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700)),
                              subtitle: Text('Score: ${h['score'] ?? 0}', style: TfiTokens.body(12, color: TfiTokens.textLo)),
                            ),
                          ),
                        );
                      },
                      childCount: _history.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }
}
