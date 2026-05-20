/// TFI Bagundali API models
library;

class UserModel {
  UserModel({
    required this.id,
    required this.phone,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.favouriteHeroId,
    this.languagePreference = 'MIXED',
    this.isOnboarded = false,
    this.favouriteHero,
    this.createdAt,
  });

  final String id;
  final String phone;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final String? favouriteHeroId;
  final String languagePreference;
  final bool isOnboarded;
  final HeroRef? favouriteHero;
  final DateTime? createdAt;

  factory UserModel.fromJson(Map<String, dynamic> j) {
    return UserModel(
      id: j['id'] as String,
      phone: j['phone'] as String? ?? '',
      displayName: j['display_name'] as String?,
      username: j['username'] as String?,
      avatarUrl: j['avatar_url'] as String?,
      favouriteHeroId: j['favourite_hero_id'] as String?,
      languagePreference: (j['language_preference'] as String? ?? 'MIXED').toUpperCase(),
      isOnboarded: j['is_onboarded'] as bool? ?? (j['favourite_hero_id'] != null),
      favouriteHero: j['favourite_hero'] != null ? HeroRef.fromJson(Map<String, dynamic>.from(j['favourite_hero'] as Map)) : null,
      createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at'] as String) : null,
    );
  }
}

class AuthResponseModel {
  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.isNewUser,
    required this.needsOnboarding,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final bool isNewUser;
  final bool needsOnboarding;

  factory AuthResponseModel.fromJson(Map<String, dynamic> j) {
    return AuthResponseModel(
      accessToken: j['accessToken'] as String? ?? j['access_token'] as String,
      refreshToken: j['refreshToken'] as String? ?? j['refresh_token'] as String,
      user: UserModel.fromJson(Map<String, dynamic>.from(j['user'] as Map)),
      isNewUser: j['isNewUser'] as bool? ?? j['is_new_user'] as bool? ?? false,
      needsOnboarding: j['needsOnboarding'] as bool? ?? j['needs_onboarding'] as bool? ?? false,
    );
  }
}

class HomeFeedModel {
  HomeFeedModel({required this.sections, this.greeting, this.meta});

  final List<HomeSectionModel> sections;
  final Map<String, dynamic>? greeting;
  final Map<String, dynamic>? meta;

  factory HomeFeedModel.fromJson(Map<String, dynamic> j) {
    final sections = (j['sections'] as List? ?? [])
        .map((e) => HomeSectionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return HomeFeedModel(
      sections: sections,
      greeting: j['greeting'] as Map<String, dynamic>?,
      meta: j['meta'] as Map<String, dynamic>?,
    );
  }
}

class HomeSectionModel {
  HomeSectionModel({
    required this.type,
    required this.title,
    this.subtitle,
    required this.items,
  });

  final String type;
  final String title;
  final String? subtitle;
  final List<Map<String, dynamic>> items;

  factory HomeSectionModel.fromJson(Map<String, dynamic> j) {
    return HomeSectionModel(
      type: j['type'] as String,
      title: j['title'] as String? ?? '',
      subtitle: j['subtitle'] as String?,
      items: (j['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );
  }
}

class TFIUpdateModel {
  TFIUpdateModel({
    required this.id,
    required this.title,
    required this.shortSummary,
    required this.category,
    required this.status,
    this.priority,
    this.imageUrl,
    this.hero,
    this.movie,
    this.publishedAt,
    this.reactions,
    this.isSaved = false,
    this.hasReacted,
    this.reason,
  });

  final String id;
  final String title;
  final String shortSummary;
  final String category;
  final String status;
  final String? priority;
  final String? imageUrl;
  final HeroRef? hero;
  final MovieRef? movie;
  final DateTime? publishedAt;
  final ReactionCounts? reactions;
  final bool isSaved;
  final String? hasReacted;
  final String? reason;

  factory TFIUpdateModel.fromJson(Map<String, dynamic> j) {
    final summary = j['short_summary'] as String? ?? j['summary'] as String? ?? '';
    Map<String, dynamic>? reactMap;
    if (j['reactions'] is Map) reactMap = Map<String, dynamic>.from(j['reactions'] as Map);
    final userState = j['user_state'] as Map<String, dynamic>?;
    return TFIUpdateModel(
      id: j['id'] as String,
      title: j['title'] as String? ?? '',
      shortSummary: summary,
      category: (j['category'] as String? ?? 'GENERAL').toUpperCase(),
      status: (j['status'] as String? ?? j['trust_status'] as String? ?? 'BUZZ').toUpperCase(),
      priority: (j['priority'] as String?)?.toUpperCase(),
      imageUrl: j['image_url'] as String?,
      hero: j['hero'] != null ? HeroRef.fromJson(Map<String, dynamic>.from(j['hero'] as Map)) : null,
      movie: j['movie'] != null ? MovieRef.fromJson(Map<String, dynamic>.from(j['movie'] as Map)) : null,
      publishedAt: j['published_at'] != null ? DateTime.tryParse(j['published_at'] as String) : null,
      reactions: reactMap != null ? ReactionCounts.fromJson(reactMap) : null,
      isSaved: userState?['is_saved'] as bool? ?? j['is_saved'] as bool? ?? false,
      hasReacted: userState?['has_reacted'] as String?,
      reason: j['reason'] as String?,
    );
  }
}

class HeroRef {
  HeroRef({this.id, required this.name, this.teluguName, this.iconEmoji});
  final String? id;
  final String name;
  final String? teluguName;
  final String? iconEmoji;

  factory HeroRef.fromJson(Map<String, dynamic> j) => HeroRef(
        id: j['id'] as String?,
        name: j['name'] as String? ?? '',
        teluguName: j['telugu_name'] as String?,
        iconEmoji: j['icon_emoji'] as String?,
      );
}

class MovieRef {
  MovieRef({this.id, required this.title, this.titleTelugu});
  final String? id;
  final String title;
  final String? titleTelugu;

  factory MovieRef.fromJson(Map<String, dynamic> j) => MovieRef(
        id: j['id'] as String?,
        title: j['title'] as String? ?? '',
        titleTelugu: j['title_telugu'] as String?,
      );
}

class HeroModel {
  HeroModel({required this.id, required this.name, this.teluguName, this.iconEmoji, this.bio});
  final String id;
  final String name;
  final String? teluguName;
  final String? iconEmoji;
  final String? bio;

  factory HeroModel.fromJson(Map<String, dynamic> j) => HeroModel(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        teluguName: j['telugu_name'] as String?,
        iconEmoji: j['icon_emoji'] as String?,
        bio: j['bio'] as String?,
      );
}

class MovieModel {
  MovieModel({
    required this.id,
    required this.title,
    this.titleTelugu,
    this.releaseDate,
    this.daysToRelease,
    this.heroName,
    this.iconEmoji,
    this.status,
    this.posterUrl,
  });

  final String id;
  final String title;
  final String? titleTelugu;
  final DateTime? releaseDate;
  final int? daysToRelease;
  final String? heroName;
  final String? iconEmoji;
  final String? status;
  final String? posterUrl;

  factory MovieModel.fromJson(Map<String, dynamic> j) => MovieModel(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        titleTelugu: j['title_telugu'] as String?,
        releaseDate: j['release_date'] != null ? DateTime.tryParse(j['release_date'] as String) : null,
        daysToRelease: j['days_to_release'] as int?,
        heroName: j['hero_name'] as String?,
        iconEmoji: j['icon_emoji'] as String?,
        status: (j['status'] as String?)?.toUpperCase(),
        posterUrl: j['poster_url'] as String?,
      );
}

class WallpaperModel {
  WallpaperModel({required this.id, this.title, this.category, this.imageUrl, this.isFree = true});
  final String id;
  final String? title;
  final String? category;
  final String? imageUrl;
  final bool isFree;

  factory WallpaperModel.fromJson(Map<String, dynamic> j) => WallpaperModel(
        id: j['id'] as String,
        title: j['title'] as String?,
        category: j['category'] as String?,
        imageUrl: j['image_url'] as String?,
        isFree: j['is_free'] as bool? ?? true,
      );
}

class StatusCardModel {
  StatusCardModel({required this.id, this.title, this.category, this.imageUrl, this.isFree = true});
  final String id;
  final String? title;
  final String? category;
  final String? imageUrl;
  final bool isFree;

  factory StatusCardModel.fromJson(Map<String, dynamic> j) => StatusCardModel(
        id: j['id'] as String,
        title: j['title'] as String?,
        category: j['category'] as String?,
        imageUrl: j['image_url'] as String? ?? j['template_url'] as String?,
        isFree: j['is_free'] as bool? ?? true,
      );
}

class PollModel {
  PollModel({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    this.totalVotes,
    this.endsAt,
    this.userVote,
    this.status,
  });

  final String id;
  final String question;
  final String type;
  final List<PollOption> options;
  final int? totalVotes;
  final DateTime? endsAt;
  final String? userVote;
  final String? status;

  factory PollModel.fromJson(Map<String, dynamic> j) {
    final opts = (j['options'] as List? ?? []).map((e) => PollOption.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    return PollModel(
      id: j['id'] as String,
      question: j['question'] as String? ?? '',
      type: (j['type'] as String? ?? j['poll_type'] as String? ?? 'NORMAL').toUpperCase(),
      options: opts,
      totalVotes: j['total_votes'] as int?,
      endsAt: j['ends_at'] != null ? DateTime.tryParse(j['ends_at'] as String) : null,
      userVote: j['user_vote'] as String?,
      status: (j['status'] as String?)?.toUpperCase(),
    );
  }
}

class PollOption {
  PollOption({required this.id, required this.label, this.voteCount, this.percent});
  final String id;
  final String label;
  final int? voteCount;
  final int? percent;

  factory PollOption.fromJson(Map<String, dynamic> j) => PollOption(
        id: j['id'] as String? ?? '',
        label: j['label'] as String? ?? '',
        voteCount: j['vote_count'] as int?,
        percent: j['percent'] as int?,
      );
}

class ReactionCounts {
  ReactionCounts({this.fire = 0, this.mass = 0, this.love = 0, this.wait = 0, this.total = 0});
  final int fire;
  final int mass;
  final int love;
  final int wait;
  final int total;

  factory ReactionCounts.fromJson(Map<String, dynamic> j) => ReactionCounts(
        fire: j['fire'] as int? ?? 0,
        mass: j['mass'] as int? ?? 0,
        love: j['love'] as int? ?? 0,
        wait: j['wait'] as int? ?? 0,
        total: j['total'] as int? ?? 0,
      );
}

class QuizModel {
  QuizModel({this.id, this.title, this.category, this.difficulty});
  final String? id;
  final String? title;
  final String? category;
  final String? difficulty;

  factory QuizModel.fromJson(Map<String, dynamic> j) => QuizModel(
        id: j['id'] as String?,
        title: j['title'] as String?,
        category: j['category'] as String?,
        difficulty: j['difficulty'] as String?,
      );
}

class QuizHistoryEntry {
  QuizHistoryEntry({this.quizDate, this.score, this.completedAt});
  final String? quizDate;
  final int? score;
  final DateTime? completedAt;

  factory QuizHistoryEntry.fromJson(Map<String, dynamic> j) => QuizHistoryEntry(
        quizDate: j['quiz_date'] as String?,
        score: j['score'] as int?,
        completedAt: j['completed_at'] != null ? DateTime.tryParse(j['completed_at'] as String) : null,
      );
}

class ReminderModel {
  ReminderModel({
    required this.id,
    required this.reminderType,
    this.title,
    this.remindAt,
    this.contentType,
    this.contentId,
    this.isActive = true,
  });

  final String id;
  final String reminderType;
  final String? title;
  final DateTime? remindAt;
  final String? contentType;
  final String? contentId;
  final bool isActive;

  factory ReminderModel.fromJson(Map<String, dynamic> j) => ReminderModel(
        id: j['id'] as String,
        reminderType: (j['reminder_type'] as String? ?? 'GENERAL').toUpperCase(),
        title: j['title'] as String?,
        remindAt: j['remind_at'] != null ? DateTime.tryParse(j['remind_at'] as String) : null,
        contentType: j['content_type'] as String?,
        contentId: j['content_id'] as String?,
        isActive: j['is_active'] as bool? ?? true,
      );
}

class NotificationPrefsModel {
  NotificationPrefsModel({required this.prefs});
  final Map<String, bool> prefs;

  factory NotificationPrefsModel.fromJson(Map<String, dynamic> j) {
    final map = <String, bool>{};
    j.forEach((k, v) {
      if (v is bool) map[k] = v;
    });
    return NotificationPrefsModel(prefs: map);
  }
}

class BookmarkModel {
  BookmarkModel({required this.contentType, required this.contentId, this.title, this.createdAt});
  final String contentType;
  final String contentId;
  final String? title;
  final DateTime? createdAt;

  factory BookmarkModel.fromJson(Map<String, dynamic> j) => BookmarkModel(
        contentType: j['content_type'] as String? ?? '',
        contentId: j['content_id'] as String? ?? j['id'] as String? ?? '',
        title: j['title'] as String?,
        createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at'] as String) : null,
      );
}
