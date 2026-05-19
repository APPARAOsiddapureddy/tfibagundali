import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/empty_error_state.dart';
import '../../widgets/tfi_widgets.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await context.read<AuthProvider>().api.getProfileQuizHistory();
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                const SizedBox(width: 12),
                Text('Quiz history', style: TfiTokens.display(24, color: TfiTokens.textHi)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: TfiTokens.fire))
                : _items.isEmpty
                    ? const EmptyState(message: 'No quiz history yet', icon: '🧠')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final h = Map<String, dynamic>.from(_items[i] as Map);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TfiCard(
                              child: ListTile(
                                leading: const Icon(Icons.quiz, color: TfiTokens.fire),
                                title: Text(h['quiz_date']?.toString() ?? 'Quiz', style: TfiTokens.body(14, color: TfiTokens.textHi)),
                                trailing: Text('${h['score'] ?? 0}', style: TfiTokens.body(16, color: TfiTokens.gold, w: FontWeight.w800)),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
