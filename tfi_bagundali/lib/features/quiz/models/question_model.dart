class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.coins,
    required this.timeLimitSeconds,
    required this.text,
    required this.imageUrl,
    required this.emoji,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final String type;
  final String difficulty;
  final int coins;
  final int timeLimitSeconds;
  final String text;
  final String? imageUrl;
  final String emoji;
  final List<String> options;
  final int correctIndex;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return QuestionModel(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? 'medium').toString(),
      coins: int.tryParse(json['coins']?.toString() ?? '') ?? 0,
      timeLimitSeconds: int.tryParse(json['time_limit_seconds']?.toString() ?? '') ?? 12,
      text: (json['text'] ?? json['question'] ?? '').toString(),
      imageUrl: json['image_url']?.toString(),
      emoji: (json['emoji'] ?? '🎬').toString(),
      options: opts,
      correctIndex: int.tryParse(json['correct_index']?.toString() ?? '') ?? 0,
    );
  }
}
