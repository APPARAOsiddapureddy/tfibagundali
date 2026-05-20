import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.imageUrl,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String imageUrl;
  final String question;
  final List<String> options;
  final int correctIndex;
}

// TODO(backend): Replace this local prototype list with GET /v1/quiz/today.
// The API should return exactly 5 questions for this quiz format:
// id, image_url, question_text, four options, and server-side answer metadata.
const _prototypeQuestions = [
  QuizQuestion(
    imageUrl: 'assets/quiz/radheshyam.png',
    question: 'Guess the Movie name',
    options: ['Radhe Shyam', 'Hi nanna', 'Darling', 'Most Eligible Bachelor'],
    correctIndex: 0,
  ),
  QuizQuestion(
    imageUrl: 'assets/quiz/ashok.png',
    question: 'Guess the Movie name',
    options: ['Rakhi', 'Ashok', 'Student No.1', 'Yamadonga'],
    correctIndex: 1,
  ),
  QuizQuestion(
    imageUrl: 'assets/quiz/alluarjun.png',
    question: 'Guess the Hero of the Movie',
    options: ['Jr.NTR', 'Mahesh Babu', 'Allu Arjun', 'Pawan Kalyan'],
    correctIndex: 2,
  ),
  QuizQuestion(
    imageUrl: 'assets/quiz/chandrashekar.png',
    question: 'Guess the Movie\'s Director',
    options: [
      'Nanda kishore Emani',
      'Hanu raghavapudi',
      'chandrasekhar Yeleti',
      'Praveen Sattaru',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    imageUrl: 'assets/quiz/gv.png',
    question: 'Guess the Movie\'s Music Director',
    options: ['Mani Sharma', 'Thaman S', 'Yuvan Shankar Raja', 'G. V. Prakash'],
    correctIndex: 3,
  ),
];

class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key, this.session});
  final Map<String, dynamic>? session;

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  static const _secondsPerQuestion = 15;

  int _questionIndex = 0;
  int? _selectedIndex;
  int _secondsLeft = _secondsPerQuestion;
  Timer? _timer;
  final List<int?> _answers = List<int?>.filled(
    _prototypeQuestions.length,
    null,
  );

  QuizQuestion get _currentQuestion => _prototypeQuestions[_questionIndex];
  bool get _isLastQuestion => _questionIndex == _prototypeQuestions.length - 1;

  @override
  void initState() {
    super.initState();
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
        _goNext(force: true);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _selectOption(int index) {
    setState(() {
      _selectedIndex = index;
      _answers[_questionIndex] = index;
    });
  }

  void _goNext({bool force = false}) {
    if (_selectedIndex == null && !force) return;

    // TODO(backend): For production, submit each answer to POST /v1/quiz/answer
    // or submit all answers at the end. Keep correct-answer checks on the server
    // to prevent clients from inspecting answer keys.
    if (_isLastQuestion) {
      _timer?.cancel();
      final score = _calculateScore();
      context.go(
        '/quiz/result',
        extra: {
          'score': score,
          'total': _prototypeQuestions.length,
          'message': score == _prototypeQuestions.length
              ? 'Full mass! You got every answer right.'
              : 'Good try! Come back tomorrow for a fresh quiz.',
        },
      );
      return;
    }

    setState(() {
      _questionIndex++;
      _selectedIndex = _answers[_questionIndex];
    });
    _startTimer();
  }

  int _calculateScore() {
    var score = 0;
    for (var i = 0; i < _prototypeQuestions.length; i++) {
      if (_answers[i] == _prototypeQuestions[i].correctIndex) score++;
    }
    return score;
  }

  Future<void> _confirmExit() async {
    _timer?.cancel();
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave quiz?'),
        content: const Text('Your quiz progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) context.pop();
    if (leave != true && mounted) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final progress = (_questionIndex + 1) / _prototypeQuestions.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _confirmExit();
      },
      child: TfiScreen(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  BackButtonCircle(onTap: _confirmExit),
                  const SizedBox(width: 12),
                  Expanded(child: TfiProgressBar(value: progress)),
                  const SizedBox(width: 12),
                  _TimerPill(secondsLeft: _secondsLeft),
                  const SizedBox(width: 10),
                  Text(
                    '${_questionIndex + 1}/${_prototypeQuestions.length}',
                    style: TfiTokens.body(
                      13,
                      color: TfiTokens.textHi,
                      w: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QuestionImage(url: question.imageUrl),
                    const SizedBox(height: 18),
                    TfiChip(
                      label: 'QUESTION ${_questionIndex + 1}',
                      color: TfiTokens.fire,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.question,
                      style: TfiTokens.display(
                        24,
                        color: TfiTokens.textHi,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...List.generate(question.options.length, (index) {
                      return _OptionTile(
                        label: String.fromCharCode(65 + index),
                        text: question.options[index],
                        selected: _selectedIndex == index,
                        onTap: () => _selectOption(index),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: PrimaryButton(
                label: _isLastQuestion ? 'Finish Quiz' : 'Next Question',
                onPressed: _selectedIndex == null ? null : _goNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionImage extends StatelessWidget {
  const _QuestionImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: TfiTokens.bg2,
            border: Border.all(color: TfiTokens.lineStrong),
          ),
          child: url.startsWith('assets/')
              ? Image.asset(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _ImageFallback(),
                )
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _ImageFallback(),
                ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(gradient: TfiTokens.gradMass),
      child: Text(
        'Quiz image',
        style: TfiTokens.display(22, color: Colors.white),
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final urgent = secondsLeft <= 5;
    final color = urgent ? TfiTokens.red : TfiTokens.cyan;

    return Container(
      width: 54,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '${secondsLeft}s',
        style: TfiTokens.mono(12, color: color, w: FontWeight.w900),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? TfiTokens.fire.withValues(alpha: 0.16)
                : TfiTokens.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? TfiTokens.fire : TfiTokens.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? TfiTokens.fire
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: TfiTokens.body(
                    13,
                    color: Colors.white,
                    w: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TfiTokens.body(
                    15,
                    color: TfiTokens.textHi,
                    w: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
