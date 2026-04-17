class CoinUtils {
  static int quizRewardForScore(int score) {
    if (score == 5) return 25;
    if (score == 4) return 15;
    if (score == 3) return 5;
    return 0;
  }

  static int dailyLoginReward() => 2;
}

