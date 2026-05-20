import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/tfi_cinematic_components.dart';
import '../../widgets/tfi_network_image.dart';
import '../../widgets/tfi_poster_placeholder.dart';

class QuizQuestionData {
  const QuizQuestionData({
    required this.id,
    required this.question,
    required this.options,
    this.imageUrl,
  });

  final String id;
  final String question;
  final List<QuizOptionData> options;
  final String? imageUrl;
}

class QuizOptionData {
  const QuizOptionData({required this.id, required this.label});
  final String id;
  final String label;
}

List<QuizQuestionData> _parseQuestions(Map<String, dynamic> session) {
  final raw = session['questions'] as List? ?? [];
  return raw.map((e) {
    final m = Map<String, dynamic>.from(e as Map);
    final opts = (m['options'] as List? ?? []).map((o) {
      final om = Map<String, dynamic>.from(o as Map);
      return QuizOptionData(
        id: om['id'] as String? ?? om['option_id'] as String? ?? om['label'] as String? ?? '',
        label: om['label'] as String? ?? om['text'] as String? ?? '',
      );
    }).toList();
    return QuizQuestionData(
      id: m['id'] as String? ?? m['question_id'] as String? ?? '',
      question: m['question'] as String? ?? m['question_text'] as String? ?? '',
      options: opts,
      imageUrl: m['image_url'] as String?,
    );
  }).toList();
}

class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key, this.session});
  final Map<String, dynamic>? session;

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  static const _secondsPerQuestion = 15;

  Map<String, dynamic>? _session;
  List<QuizQuestionData> _questions = [];
  int _questionIndex = 0;
  String? _selectedOptionId;
  int _secondsLeft = _secondsPerQuestion;
  Timer? _timer;
  bool _submitting = false;
  bool _answered = false;
  bool _loading = true;

  QuizQuestionData get _current => _questions[_questionIndex];
  bool get _isLast => _questionIndex >= _questions.length - 1;
  Object? get _sessionId => _session?['session_id'] ?? _session?['id'];

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    if (widget.session != null && (widget.session!['questions'] as List?)?.isNotEmpty == true) {
      _applySession(widget.session!);
      return;
    }
    try {
      final session = await context.read<AuthProvider>().api.startQuiz();
      if (mounted) _applySession(session);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingError(e))));
        context.pop();
      }
    }
  }

  void _applySession(Map<String, dynamic> session) {
    final qs = _parseQuestions(session);
    if (qs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No quiz questions available')));
        context.pop();
      }
      return;
    }
    setState(() {
      _session = session;
      _questions = qs;
      _loading = false;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _submitAndAdvance(force: true);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _selectOption(String optionId) {
    if (_answered) return;
    setState(() => _selectedOptionId = optionId);
  }

  Future<void> _submitAndAdvance({bool force = false}) async {
    if (_selectedOptionId == null && !force) return;
    if (_submitting) return;

    setState(() => _submitting = true);
    _timer?.cancel();

    final sid = _sessionId;
    if (sid != null && _selectedOptionId != null) {
      try {
        await context.read<AuthProvider>().api.submitQuizAnswer(sid, _current.id, _selectedOptionId!);
      } catch (_) {}
    }

    if (!mounted) return;

    if (_isLast) {
      Map<String, dynamic> result = {'score': 0, 'total': _questions.length};
      if (sid != null) {
        try {
          result = await context.read<AuthProvider>().api.completeQuiz(sid);
        } catch (_) {}
      }
      if (mounted) {
        context.go('/quiz/result', extra: {
          'score': result['score'] ?? result['correct_count'] ?? 0,
          'total': result['total'] ?? result['total_questions'] ?? _questions.length,
          'correct': result['correct'] ?? result['correct_count'],
          'wrong': result['wrong'] ?? result['wrong_count'],
          'percentage': result['percentage'] ?? result['percent'],
          'message': result['message'] as String? ?? 'Quiz complete!',
        });
      }
      return;
    }

    setState(() {
      _questionIndex++;
      _selectedOptionId = null;
      _answered = false;
      _submitting = false;
    });
    _startTimer();
  }

  Future<void> _confirmExit() async {
    _timer?.cancel();
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TfiTokens.card1,
        title: Text('Leave quiz?', style: TfiTokens.title(16)),
        content: Text('Your progress will be lost.', style: TfiTokens.body(14, color: TfiTokens.textMid)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Leave', style: TextStyle(color: TfiTokens.red))),
        ],
      ),
    );
    if (leave == true && mounted) context.pop();
    if (leave != true && mounted) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const TfiScaffold(child: Center(child: CircularProgressIndicator(color: TfiTokens.gold)));
    }

    final progress = (_questionIndex + 1) / _questions.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _confirmExit();
      },
      child: TfiScaffold(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 12, TfiTokens.padScreen, 8),
              child: Row(
                children: [
                  Material(
                    color: TfiTokens.glass,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _confirmExit,
                      borderRadius: BorderRadius.circular(12),
                      child: const SizedBox(width: 40, height: 40, child: Icon(Icons.close_rounded, color: TfiTokens.textHi, size: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: TfiTokens.glass,
                        color: TfiTokens.gold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TfiCountdownChip('${_secondsLeft}s'),
                  const SizedBox(width: 8),
                  Text('${_questionIndex + 1}/${_questions.length}', style: TfiTokens.body(12, color: TfiTokens.textHi, w: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 4, TfiTokens.padScreen, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(TfiTokens.rCard),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: _current.imageUrl != null && _current.imageUrl!.isNotEmpty
                            ? TfiNetworkImage(url: _current.imageUrl, fit: BoxFit.cover, placeholderKind: TfiPlaceholderKind.quiz, placeholderTitle: _current.question)
                            : TfiPosterPlaceholder(kind: TfiPlaceholderKind.quiz, title: _current.question, icon: Icons.quiz_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const TfiBadge('Question'),
                    const SizedBox(height: 10),
                    Text(_current.question, style: TfiTokens.display(22, color: TfiTokens.textHi, height: 1.12)),
                    const SizedBox(height: 18),
                    ...List.generate(_current.options.length, (index) {
                      final o = _current.options[index];
                      final selected = _selectedOptionId == o.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: _answered ? null : () => _selectOption(o.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected ? TfiTokens.gold.withValues(alpha: 0.15) : TfiTokens.card1.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: selected ? TfiTokens.gold : TfiTokens.lineStrong, width: selected ? 2 : 1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selected ? TfiTokens.gold : TfiTokens.glass,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TfiTokens.body(13, color: selected ? const Color(0xFF1A0F00) : TfiTokens.textMid, w: FontWeight.w900),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(o.label, style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w600))),
                              ],
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
              padding: const EdgeInsets.fromLTRB(TfiTokens.padScreen, 8, TfiTokens.padScreen, 24),
              child: TfiPrimaryButton(
                label: _isLast ? 'Finish Quiz' : 'Next Question',
                loading: _submitting,
                onPressed: _selectedOptionId == null || _submitting ? null : () => _submitAndAdvance(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
