import '../../movies/models/movie_model.dart';

class StatusPreviewModel {
  const StatusPreviewModel({
    required this.id,
    required this.label,
    required this.emoji,
  });

  final String id;
  final String label;
  final String emoji;
}

class HomeFeedModel {
  const HomeFeedModel({
    required this.releaseMovieId,
    required this.releaseTitle,
    required this.releaseHero,
    required this.releaseDirector,
    required this.releaseEmoji,
    required this.releaseTargetUtc,
    required this.quizDoneToday,
    required this.upcoming,
    required this.statusPreviews,
  });

  final String releaseMovieId;
  final String releaseTitle;
  final String releaseHero;
  final String releaseDirector;
  final String releaseEmoji;
  final DateTime releaseTargetUtc;
  final bool quizDoneToday;
  final List<MovieModel> upcoming;
  final List<StatusPreviewModel> statusPreviews;

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) {
    final upcomingJson = json['upcoming'] as List<dynamic>? ?? [];
    return HomeFeedModel(
      releaseMovieId: (json['release_movie_id'] ?? json['releaseMovieId'] ?? '').toString(),
      releaseTitle: (json['release_title'] ?? json['releaseTitle'] ?? '').toString(),
      releaseHero: (json['release_hero'] ?? '').toString(),
      releaseDirector: (json['release_director'] ?? '').toString(),
      releaseEmoji: (json['release_emoji'] ?? '🔥').toString(),
      releaseTargetUtc: DateTime.tryParse((json['release_target_utc'] ?? '').toString()) ??
          DateTime.now().toUtc(),
      quizDoneToday: json['quiz_done_today'] == true,
      upcoming: upcomingJson
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusPreviews: (json['status_previews'] as List<dynamic>? ?? [])
          .map((e) => StatusPreviewModel(
                id: (e as Map)['id'].toString(),
                label: e['label'].toString(),
                emoji: e['emoji'].toString(),
              ))
          .toList(),
    );
  }
}
