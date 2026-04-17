class PollOptionModel {
  const PollOptionModel({
    required this.id,
    required this.label,
    required this.percent,
  });

  final String id;
  final String label;
  final int percent;

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      percent: int.tryParse(json['percent']?.toString() ?? '') ?? 0,
    );
  }
}

class PollModel {
  const PollModel({
    required this.id,
    required this.question,
    required this.totalVotes,
    required this.options,
  });

  final String id;
  final String question;
  final int totalVotes;
  final List<PollOptionModel> options;

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>? ?? [])
        .map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PollModel(
      id: (json['id'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      totalVotes: int.tryParse(json['total_votes']?.toString() ?? '') ?? 0,
      options: opts,
    );
  }
}
