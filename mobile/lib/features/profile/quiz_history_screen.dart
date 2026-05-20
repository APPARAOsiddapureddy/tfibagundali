import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_cinematic_components.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await context.read<AuthProvider>().api.getProfileQuizHistory();
      if (mounted) {
        setState(() {
          _items = items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScaffold(
      child: Column(
        children: [
          TfiDetailAppBar(title: 'Quiz History', onBack: () => context.pop()),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.gold))
                : _items.isEmpty
                    ? const EmptyState(message: 'No quiz history yet', icon: '🧠')
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: TfiTokens.gold,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(TfiTokens.padScreen),
                          itemCount: _items.length,
                          itemBuilder: (_, i) {
                            final h = _items[i];
                            final score = h['score'] ?? h['correct_count'] ?? 0;
                            final total = h['total'] ?? h['total_questions'] ?? 5;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TfiCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: TfiTokens.gold.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.quiz_rounded, color: TfiTokens.gold),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            h['quiz_date']?.toString() ?? h['completed_at']?.toString() ?? 'Quiz',
                                            style: TfiTokens.body(14, color: TfiTokens.textHi, w: FontWeight.w700),
                                          ),
                                          Text('$score / $total correct', style: TfiTokens.body(11, color: TfiTokens.textLo)),
                                        ],
                                      ),
                                    ),
                                    Text('$score', style: TfiTokens.display(20, color: TfiTokens.gold)),
                                  ],
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
}
