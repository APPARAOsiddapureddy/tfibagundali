class MovieModel {
  const MovieModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.hero,
    required this.director,
    required this.releaseDate,
    required this.genre,
    this.synopsis,
    this.releaseTargetUtc,
  });

  final String id;
  final String title;
  final String emoji;
  final String hero;
  final String director;
  final String releaseDate;
  final String genre;
  final String? synopsis;
  final DateTime? releaseTargetUtc;

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      emoji: (json['emoji'] ?? '🎬').toString(),
      hero: (json['hero'] ?? '').toString(),
      director: (json['director'] ?? '').toString(),
      releaseDate: (json['release_date'] ?? json['releaseDate'] ?? '').toString(),
      genre: (json['genre'] ?? '').toString(),
      synopsis: json['synopsis']?.toString(),
      releaseTargetUtc: DateTime.tryParse((json['release_target_utc'] ?? '').toString()),
    );
  }
}
