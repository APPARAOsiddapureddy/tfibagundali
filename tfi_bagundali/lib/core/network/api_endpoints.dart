class ApiEndpoints {
  // Auth
  static const otpSend = '/auth/otp/send';
  static const otpVerify = '/auth/otp/verify';
  static const tokenRefresh = '/auth/token/refresh';
  static const me = '/auth/me';

  // Home
  static const homeFeed = '/home/feed';
  static const upcomingMovies = '/movies/upcoming';

  // Movies
  static String movieById(String id) => '/movies/$id';
  static String movieReminder(String id) => '/movies/$id/reminder';

  // Quiz
  static const quizToday = '/quiz/today';
  static const quizSessionStart = '/quiz/session/start';
  static String quizAnswer(String sessionId) => '/quiz/session/$sessionId/answer';
  static String quizComplete(String sessionId) => '/quiz/session/$sessionId/complete';
  static const quizLeaderboardDaily = '/quiz/leaderboard/daily';
  static const quizStreak = '/quiz/streak';
  static const quizHistory = '/quiz/history';

  // Premium
  static const premiumVerify = '/premium/verify';

  // Share
  static const shareCards = '/share-cards';
  static String shareCardShare(String id) => '/share-cards/$id/share';

  // Fan armies & polls
  static const fanArmiesLeaderboard = '/fan-armies/leaderboard';
  static const fanArmiesMy = '/fan-armies/my';
  static String fanArmyJoin(String id) => '/fan-armies/$id/join';
  static const pollsActive = '/polls/active';
  static String pollVote(String id) => '/polls/$id/vote';

  // Coins
  static const coinBalance = '/coins/balance';
  static const coinStore = '/coins/store';
  static const coinRedeem = '/coins/redeem';
}

