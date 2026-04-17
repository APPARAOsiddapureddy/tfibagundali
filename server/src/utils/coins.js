// Coin reward constants matching PRD
const COIN_RULES = {
  DAILY_LOGIN: 2,
  QUIZ_5_OF_5: 25,
  QUIZ_4_OF_5: 15,
  QUIZ_3_OF_5: 5,
  QUIZ_BELOW_3: 0,
  SHARE_CONTENT: 1,
  SHARE_MAX_PER_DAY: 5,
  STREAK_7_DAY: 20,
  STREAK_30_DAY: 100,
  REFERRAL: 50,
};

const COIN_COSTS = {
  WALLPAPER_PACK: 50,
  PREMIUM_DIALOGUE_CARD: 20,
  PREMIUM_DISCOUNT: 200,
  ARMY_BADGE_UPGRADE: 100,
};

function getQuizCoins(score) {
  if (score === 5) return COIN_RULES.QUIZ_5_OF_5;
  if (score === 4) return COIN_RULES.QUIZ_4_OF_5;
  if (score === 3) return COIN_RULES.QUIZ_3_OF_5;
  return COIN_RULES.QUIZ_BELOW_3;
}

module.exports = { COIN_RULES, COIN_COSTS, getQuizCoins };
