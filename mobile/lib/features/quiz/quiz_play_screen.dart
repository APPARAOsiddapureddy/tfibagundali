import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _q = 0;
  int? _selected;
  final _questions = [
    ('Who directed Baahubali?', ['Rajamouli', 'Sukumar', 'Trivikram', 'Koratala']),
    ('Pushpa 2 hero is?', ['Allu Arjun', 'Prabhas', 'NTR', 'Mahesh']),
  ];

  void _next() {
    if (_q < _questions.length - 1) {
      setState(() { _q++; _selected = null; });
    } else {
      context.go('/quiz/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_q];
    return TfiScreen(
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
                Text('${_q + 1}/${_questions.length}', style: TfiTokens.body(13, color: TfiTokens.textHi, w: FontWeight.w700)),
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
                  Text(q.$1, style: TfiTokens.display(26, color: TfiTokens.textHi)),
                  const SizedBox(height: 28),
                  ...List.generate(q.$2.length, (i) {
                    final on = _selected == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = i),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: on ? TfiTokens.fire.withValues(alpha: 0.15) : TfiTokens.bg2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: on ? TfiTokens.fire : TfiTokens.line, width: on ? 2 : 1),
                          ),
                          child: Text(q.$2[i], style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w600)),
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
            child: PrimaryButton(label: 'Next →', onPressed: _selected == null ? null : _next),
          ),
        ],
      ),
    );
  }
}
