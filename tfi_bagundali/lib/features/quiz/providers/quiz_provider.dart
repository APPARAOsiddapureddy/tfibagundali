import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/coin_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/providers/coin_balance_provider.dart';
import '../models/question_model.dart';
import '../models/quiz_session_model.dart';
import '../repositories/quiz_repository.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ref.watch(apiClientProvider));
});

class QuizState {
  const QuizState({
    required this.questions,
    required this.currentIndex,
    required this.answered,
    required this.score,
    required this.timer,
    required this.sessionId,
    required this.results,
    required this.isLoading,
    required this.streak,
    required this.difficultyLabel,
    required this.maxCoins,
    required this.quizDate,
    required this.selectedOption,
    required this.reveal,
    required this.totalTimeMs,
  });

  final List<QuestionModel> questions;
  final int currentIndex;
  final bool answered;
  final int score;
  final int timer;
  final String? sessionId;
  final QuizResultsSummary? results;
  final bool isLoading;
  final int streak;
  final String difficultyLabel;
  final int maxCoins;
  final String quizDate;
  final int? selectedOption;
  final bool reveal;
  final int totalTimeMs;

  QuestionModel? get currentQuestion =>
      questions.isEmpty || currentIndex >= questions.length ? null : questions[currentIndex];

  factory QuizState.initial() => const QuizState(
        questions: [],
        currentIndex: 0,
        answered: false,
        score: 0,
        timer: 0,
        sessionId: null,
        results: null,
        isLoading: false,
        streak: 0,
        difficultyLabel: 'Medium 💪',
        maxCoins: 25,
        quizDate: '',
        selectedOption: null,
        reveal: false,
        totalTimeMs: 0,
      );

  QuizState copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    bool? answered,
    int? score,
    int? timer,
    String? sessionId,
    QuizResultsSummary? results,
    bool? isLoading,
    int? streak,
    String? difficultyLabel,
    int? maxCoins,
    String? quizDate,
    int? selectedOption,
    bool applySelectedOption = false,
    bool? reveal,
    bool applyReveal = false,
    int? totalTimeMs,
    bool clearResults = false,
    bool clearSession = false,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answered: answered ?? this.answered,
      score: score ?? this.score,
      timer: timer ?? this.timer,
      sessionId: clearSession ? null : (sessionId ?? this.sessionId),
      results: clearResults ? null : (results ?? this.results),
      isLoading: isLoading ?? this.isLoading,
      streak: streak ?? this.streak,
      difficultyLabel: difficultyLabel ?? this.difficultyLabel,
      maxCoins: maxCoins ?? this.maxCoins,
      quizDate: quizDate ?? this.quizDate,
      selectedOption: applySelectedOption ? selectedOption : this.selectedOption,
      reveal: applyReveal ? (reveal ?? false) : this.reveal,
      totalTimeMs: totalTimeMs ?? this.totalTimeMs,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this.ref) : super(QuizState.initial());

  final Ref ref;
  Timer? _timer;
  DateTime? _questionStartedAt;

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> initQuiz() async {
    _cancelTimer();
    state = QuizState.initial().copyWith(isLoading: true, clearResults: true, clearSession: true);
    final repo = ref.read(quizRepositoryProvider);
    final today = await repo.getToday();
    if (today.questions.isEmpty) {
      state = QuizState.initial().copyWith(isLoading: false);
      return;
    }
    final sessionId = await repo.startSession(quizDate: today.quizDate);
    state = QuizState(
      questions: today.questions,
      currentIndex: 0,
      answered: false,
      score: 0,
      timer: today.questions.first.timeLimitSeconds,
      sessionId: sessionId,
      results: null,
      isLoading: false,
      streak: today.streak,
      difficultyLabel: today.difficultyLabel,
      maxCoins: today.maxCoins,
      quizDate: today.quizDate,
      selectedOption: null,
      reveal: false,
      totalTimeMs: 0,
    );
    _questionStartedAt = DateTime.now();
    _startTimerForCurrentQuestion();
  }

  void _startTimerForCurrentQuestion() {
    _cancelTimer();
    final q = state.currentQuestion;
    if (q == null || state.results != null) return;
    _questionStartedAt = DateTime.now();
    state = state.copyWith(
      timer: q.timeLimitSeconds,
      answered: false,
      applySelectedOption: true,
      selectedOption: null,
      applyReveal: true,
      reveal: false,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.answered) return;
      if (state.timer <= 1) {
        _cancelTimer();
        unawaited(submitAnswer(null));
        return;
      }
      state = state.copyWith(timer: state.timer - 1);
    });
  }

  Future<void> submitAnswer(int? option) async {
    if (state.answered || state.currentQuestion == null) return;
    _cancelTimer();

    final q = state.currentQuestion!;
    final started = _questionStartedAt ?? DateTime.now();
    final elapsed = DateTime.now().difference(started).inMilliseconds;

    final correct = option != null && option == q.correctIndex;
    final newScore = correct ? state.score + 1 : state.score;

    state = state.copyWith(
      answered: true,
      applySelectedOption: true,
      selectedOption: option,
      applyReveal: true,
      reveal: true,
      score: newScore,
      totalTimeMs: state.totalTimeMs + elapsed,
    );

    final repo = ref.read(quizRepositoryProvider);
    await repo.submitAnswer(
      sessionId: state.sessionId ?? 'offline_session',
      questionId: q.id,
      selectedOption: option,
      timeTakenMs: elapsed,
    );

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        answered: false,
        applySelectedOption: true,
        selectedOption: null,
        applyReveal: true,
        reveal: false,
        score: newScore,
      );
      _startTimerForCurrentQuestion();
    } else {
      await completeQuiz(newScore);
    }
  }

  Future<void> completeQuiz(int finalScore) async {
    _cancelTimer();
    final repo = ref.read(quizRepositoryProvider);
    await repo.completeSession(
      sessionId: state.sessionId ?? 'offline_session',
      totalTimeTakenMs: state.totalTimeMs,
    );

    final coins = CoinUtils.quizRewardForScore(finalScore);
    final streak = state.streak;

    if (coins > 0) {
      ref.read(coinBalanceProvider.notifier).add(coins);
    }

    state = state.copyWith(
      results: QuizResultsSummary(
        score: finalScore,
        total: state.questions.length,
        coinsEarned: coins,
        streak: streak,
      ),
      isLoading: false,
      answered: true,
      reveal: true,
    );
  }

  void reset() {
    _cancelTimer();
    state = QuizState.initial().copyWith(isLoading: false);
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  ref.watch(authProvider);
  return QuizNotifier(ref);
});
