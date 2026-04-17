import '../../features/home/models/home_feed_model.dart';
import '../../features/quiz/models/question_model.dart';
import '../../features/quiz/models/quiz_session_model.dart';
import '../../features/share_zone/models/share_card_model.dart';
import '../../features/fan_army/models/army_model.dart';
import '../../features/fan_army/models/poll_model.dart';
import '../../features/movies/models/movie_model.dart';

/// Offline / demo payloads when API is unavailable.
class FallbackData {
  FallbackData._();

  static const String pushpaMovieId = 'pushpa3';

  static List<MovieModel> upcomingMovies() => [
        MovieModel(
          id: 'pushpa3',
          title: 'Pushpa 3',
          emoji: '🔥',
          hero: 'Allu Arjun',
          director: 'Sukumar',
          releaseDate: 'Aug 15 2025',
          genre: 'Mass Action',
          synopsis:
              'Pushpa’s world expands with higher stakes, bigger mass moments, and Sukumar’s signature style.',
          releaseTargetUtc: DateTime.utc(2025, 8, 15, 5, 30),
        ),
        MovieModel(
          id: 'devara2',
          title: 'Devara 2',
          emoji: '🌊',
          hero: 'Jr. NTR',
          director: 'Koratala Siva',
          releaseDate: 'May 3 2025',
          genre: 'Mass',
          synopsis: 'The coastal epic continues with raw emotion and high-voltage action.',
          releaseTargetUtc: DateTime.utc(2025, 5, 3, 5, 30),
        ),
        MovieModel(
          id: 'hhvm',
          title: 'HHVM',
          emoji: '🦁',
          hero: 'Pawan Kalyan',
          director: 'Krish',
          releaseDate: 'Jul 4 2025',
          genre: 'Period Action',
          synopsis: 'A period spectacle built for the big screen and whistle moments.',
          releaseTargetUtc: DateTime.utc(2025, 7, 4, 5, 30),
        ),
        MovieModel(
          id: 'gc2',
          title: 'Game Changer 2',
          emoji: '⚡',
          hero: 'Ram Charan',
          director: 'Shankar',
          releaseDate: 'Jun 18 2025',
          genre: 'Action',
          synopsis: 'A futuristic political action ride with Shankar-scale set pieces.',
          releaseTargetUtc: DateTime.utc(2025, 6, 18, 5, 30),
        ),
      ];

  static List<QuestionModel> quizQuestions() => [
        QuestionModel(
          id: 'q1',
          type: 'song_clue',
          difficulty: 'easy',
          coins: 3,
          timeLimitSeconds: 15,
          text: "Ee movie lo 'Naatu Naatu' song vasindi?",
          imageUrl: null,
          emoji: '🎶',
          options: const ['Baahubali', 'RRR', 'Pushpa', 'Magadheera'],
          correctIndex: 1,
        ),
        QuestionModel(
          id: 'q2',
          type: 'hero_silhouette',
          difficulty: 'medium',
          coins: 4,
          timeLimitSeconds: 12,
          text: 'Mahesh Babu hero ga first movie?',
          imageUrl: null,
          emoji: '👑',
          options: const ['Raja Kumarudu', 'Neeku Naaku Naidu', 'Murari', 'Okkadu'],
          correctIndex: 0,
        ),
        QuestionModel(
          id: 'q3',
          type: 'movie_still',
          difficulty: 'easy',
          coins: 3,
          timeLimitSeconds: 15,
          text: 'Pushpa lo hero enti?',
          imageUrl: null,
          emoji: '🔥',
          options: const ['Mahesh', 'Allu Arjun', 'NTR', 'Prabhas'],
          correctIndex: 1,
        ),
        QuestionModel(
          id: 'q4',
          type: 'release_year',
          difficulty: 'easy',
          coins: 3,
          timeLimitSeconds: 15,
          text: 'RRR movie release year enti?',
          imageUrl: null,
          emoji: '📅',
          options: const ['2020', '2021', '2022', '2023'],
          correctIndex: 2,
        ),
        QuestionModel(
          id: 'q5',
          type: 'dialogue',
          difficulty: 'hard',
          coins: 5,
          timeLimitSeconds: 10,
          text: 'SS Rajamouli director ga first blockbuster?',
          imageUrl: null,
          emoji: '💬',
          options: const ['Magadheera', 'Vikramarkudu', 'Student No 1', 'Simhadri'],
          correctIndex: 0,
        ),
      ];

  static QuizTodayModel quizToday() => QuizTodayModel(
        quizDate: DateTime.now().toUtc().toIso8601String(),
        streak: 3,
        difficultyLabel: 'Medium 💪',
        maxCoins: 25,
        questions: quizQuestions(),
      );

  static List<ArmyLeaderboardEntry> fanArmyLeaderboard() => const [
        ArmyLeaderboardEntry(rank: 1, emoji: '🦁', name: 'Power Army', points: 824350),
        ArmyLeaderboardEntry(rank: 2, emoji: '👑', name: 'Mahesh Army', points: 791200),
        ArmyLeaderboardEntry(rank: 3, emoji: '🔥', name: 'Bunny Army', points: 744800),
        ArmyLeaderboardEntry(rank: 4, emoji: '🌊', name: 'Young Tiger Army', points: 698100),
        ArmyLeaderboardEntry(rank: 5, emoji: '⚡', name: 'Charan Army', points: 672400),
      ];

  static PollModel activePoll() => const PollModel(
        id: 'poll1',
        question: 'Best mass hero of the decade — yevaru?',
        totalVotes: 12480,
        options: [
          PollOptionModel(id: 'o1', label: 'Pawan Kalyan', percent: 28),
          PollOptionModel(id: 'o2', label: 'Mahesh Babu', percent: 24),
          PollOptionModel(id: 'o3', label: 'Allu Arjun', percent: 26),
          PollOptionModel(id: 'o4', label: 'Jr. NTR', percent: 22),
        ],
      );

  static List<ShareCardModel> shareCards() => const [
        ShareCardModel(
          id: 'sc1',
          title: 'Power Star Morning 🦁',
          category: 'Hero Status',
          emoji: '🦁',
          thumbnailUrl: null,
          shareCount: 1200,
          isPremium: false,
        ),
        ShareCardModel(
          id: 'sc2',
          title: 'Pushpa 3 Countdown 🔥',
          category: 'Countdown',
          emoji: '🔥',
          thumbnailUrl: null,
          shareCount: 980,
          isPremium: false,
        ),
        ShareCardModel(
          id: 'sc3',
          title: 'Iconic Dialogue 💬',
          category: 'Dialogues',
          emoji: '💬',
          thumbnailUrl: null,
          shareCount: 640,
          isPremium: false,
        ),
        ShareCardModel(
          id: 'sc4',
          title: 'Mahesh B-Day 🎂',
          category: 'Birthdays',
          emoji: '🎂',
          thumbnailUrl: null,
          shareCount: 310,
          isPremium: true,
        ),
        ShareCardModel(
          id: 'sc5',
          title: 'Bunny Army Flag 🔥',
          category: 'Fan Army',
          emoji: '🔥',
          thumbnailUrl: null,
          shareCount: 420,
          isPremium: false,
        ),
        ShareCardModel(
          id: 'sc6',
          title: 'NTR Tiger Pack 🌊',
          category: 'Hero Status',
          emoji: '🌊',
          thumbnailUrl: null,
          shareCount: 280,
          isPremium: true,
        ),
        ShareCardModel(
          id: 'sc7',
          title: 'Baahubali Anniversary ⚔️',
          category: 'Dialogues',
          emoji: '⚔️',
          thumbnailUrl: null,
          shareCount: 510,
          isPremium: false,
        ),
        ShareCardModel(
          id: 'sc8',
          title: 'RRR Dialogue 💥',
          category: 'Dialogues',
          emoji: '💥',
          thumbnailUrl: null,
          shareCount: 770,
          isPremium: false,
        ),
      ];

  static HomeFeedModel homeFeed() {
    final movies = upcomingMovies();
    final release = movies.first;
    return HomeFeedModel(
      releaseMovieId: release.id,
      releaseTitle: release.title,
      releaseHero: release.hero,
      releaseDirector: release.director,
      releaseEmoji: release.emoji,
      releaseTargetUtc: DateTime.utc(2025, 8, 15, 5, 30),
      quizDoneToday: false,
      upcoming: movies,
      statusPreviews: shareCards()
          .take(4)
          .map(
            (c) => StatusPreviewModel(
              id: c.id,
              label: c.title.split(' ').first,
              emoji: c.emoji,
            ),
          )
          .toList(),
    );
  }

  static MovieModel movieDetail(String id) {
    for (final m in upcomingMovies()) {
      if (m.id == id) return m;
    }
    return MovieModel(
      id: id,
      title: 'PUSHPA 3',
      emoji: '🔥',
      hero: 'Allu Arjun',
      director: 'Sukumar',
      releaseDate: 'Aug 15 2025',
      genre: 'Mass Action',
      synopsis: 'Upcoming Telugu big-screen spectacle (offline preview).',
      releaseTargetUtc: DateTime.utc(2025, 8, 15, 5, 30),
    );
  }
}
