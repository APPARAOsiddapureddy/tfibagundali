import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key, this.session});
  final Map<String, dynamic>? session;

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  late final Object _sessionId;
  late final List<Map<String, dynamic>> _questions;
  int _q = 0;
  String? _selected;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _sessionId = widget.session?['session_id'] ?? 0;
    _questions = (widget.session?['questions'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  List<String> _options(Map<String, dynamic> q) {
    final opts = q['options'] as Map<String, dynamic>? ?? {};
    return ['a', 'b', 'c', 'd']
        .map((k) => opts[k] as String?)
        .whereType<String>()
        .toList();
  }

  Future<void> _next() async {
    if (_selected == null || _submitting) return;
    setState(() => _submitting = true);
    final q = _questions[_q];
    final api = context.read<AuthProvider>().api;
    try {
      await api.submitQuizAnswer(_sessionId, q['id'] as String, _selected!);
      if (_q < _questions.length - 1) {
        setState(() {
          _q++;
          _selected = null;
          _submitting = false;
        });
      } else {
        final result = await api.completeQuiz(_sessionId);
        context.read<AuthProvider>().events.track('quiz_completed', contentType: 'quiz');
        if (mounted) context.go('/quiz/result', extra: result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return TfiScreen(
        child: Center(
          child: Text('No questions', style: TfiTokens.body(16, color: TfiTokens.textMid)),
        ),
      );
    }

    final q = _questions[_q];
    final options = _options(q);
    final labels = ['a', 'b', 'c', 'd'];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Leave quiz?'),
            content: const Text('Your progress may be lost.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave')),
            ],
          ),
        );
        if (leave == true && context.mounted) context.pop();
      },
      child: TfiScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                const SizedBox(width: 12),
                Expanded(child: TfiProgressBar(value: (_q + 1) / _questions.length)),
                const SizedBox(width: 12),
                Text(
                  '${_q + 1}/${_questions.length}',
                  style: TfiTokens.body(13, color: TfiTokens.textHi, w: FontWeight.w700),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TfiChip(label: 'QUESTION ${_q + 1}', color: TfiTokens.fire),
                  const SizedBox(height: 16),
                  Text(
                    q['question_text'] as String? ?? '',
                    style: TfiTokens.display(24, color: TfiTokens.textHi),
                  ),
                  const SizedBox(height: 28),
                  ...List.generate(options.length, (i) {
                    final key = labels[i];
                    final on = _selected == key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = key),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: on ? TfiTokens.fire.withValues(alpha: 0.15) : TfiTokens.bg2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: on ? TfiTokens.fire : TfiTokens.line, width: on ? 2 : 1),
                          ),
                          child: Text(
                            options[i],
                            style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: PrimaryButton(
              label: _submitting ? 'Submitting...' : (_q < _questions.length - 1 ? 'Next →' : 'Finish'),
              onPressed: _selected == null || _submitting ? null : _next,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
