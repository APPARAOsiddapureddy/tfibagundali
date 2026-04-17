import 'question_model.dart';

class QuizTodayModel {
  const QuizTodayModel({
    required this.quizDate,
    required this.streak,
    required this.difficultyLabel,
    required this.maxCoins,
    required this.questions,
  });

  final String quizDate;
  final int streak;
  final String difficultyLabel;
  final int maxCoins;
  final List<QuestionModel> questions;

  factory QuizTodayModel.fromJson(Map<String, dynamic> json) {
    final qs = (json['questions'] as List<dynamic>? ?? [])
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return QuizTodayModel(
      quizDate: (json['quiz_date'] ?? '').toString(),
      streak: int.tryParse(json['streak']?.toString() ?? '') ?? 0,
      difficultyLabel: (json['difficulty_label'] ?? 'Medium 💪').toString(),
      maxCoins: int.tryParse(json['max_coins']?.toString() ?? '') ?? 25,
      questions: qs,
    );
  }
}

class QuizResultsSummary {
  const QuizResultsSummary({
    required this.score,
    required this.total,
    required this.coinsEarned,
    required this.streak,
  });

  final int score;
  final int total;
  final int coinsEarned;
  final int streak;
}
