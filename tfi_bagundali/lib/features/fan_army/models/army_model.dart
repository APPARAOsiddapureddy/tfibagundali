class ArmyLeaderboardEntry {
  const ArmyLeaderboardEntry({
    required this.rank,
    required this.emoji,
    required this.name,
    required this.points,
  });

  final int rank;
  final String emoji;
  final String name;
  final int points;

  factory ArmyLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return ArmyLeaderboardEntry(
      rank: int.tryParse(json['rank']?.toString() ?? '') ?? 0,
      emoji: (json['emoji'] ?? '⭐').toString(),
      name: (json['name'] ?? '').toString(),
      points: int.tryParse(json['points']?.toString() ?? '') ?? 0,
    );
  }
}
