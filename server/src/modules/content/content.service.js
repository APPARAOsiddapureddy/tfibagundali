const queries = require('./content.queries');
const quizQueries = require('../quiz/quiz.queries');
const coinService = require('../coins/coins.service');
const { getOrSet, deletePattern } = require('../../config/redis');
const { getPublicUrl, getPresignedDownloadUrl } = require('../../config/s3');
const { AppError } = require('../../middleware/error.middleware');
const { parsePagination } = require('../../utils/pagination');
const { COIN_RULES } = require('../../utils/coins');

function withImageUrls(obj) {
  if (!obj) return null;
  const result = { ...obj };
  if (result.poster_s3_key) result.poster_url = getPublicUrl(result.poster_s3_key);
  if (result.image_s3_key) result.image_url = getPublicUrl(result.image_s3_key);
  if (result.thumbnail_s3_key) result.thumbnail_url = getPublicUrl(result.thumbnail_s3_key);
  if (result.hero_image) result.hero_image_url = getPublicUrl(result.hero_image);
  return result;
}

async function getHomeFeed(userId) {
  const cacheKey = `content:home_feed:${userId}`;
  return getOrSet(cacheKey, 300, async () => {
    const [featured, quizStatus, sharePreviews, upcomingMovies, heroOfWeek, coinBalance] = await Promise.all([
      queries.getFeaturedRelease(),
      getQuizStatus(userId),
      queries.getSharePreviews(6),
      queries.getUpcomingMovies(6),
      queries.getHeroOfWeek(),
      coinService.getBalance(userId),
    ]);

    return {
      featured_release: featured ? { movie: withImageUrls(featured), days_remaining: featured.days_remaining } : null,
      quiz: quizStatus,
      share_previews: sharePreviews.map(withImageUrls),
      upcoming_movies: upcomingMovies.map(withImageUrls),
      hero_of_week: heroOfWeek ? withImageUrls(heroOfWeek) : null,
      coin_balance: coinBalance,
    };
  });
}

async function getQuizStatus(userId) {
  const date = new Date().toLocaleDateString('sv-SE', { timeZone: 'Asia/Kolkata' });
  const session = await quizQueries.getSession(userId, date);
  const streak = await quizQueries.getStreakData(userId);
  return {
    completed_today: session?.completed || false,
    score: session?.score || null,
    streak: streak.streak,
    max_coins: 25,
  };
}

async function getUpcomingMovies() {
  return getOrSet('content:upcoming_movies', 3600, async () => {
    const movies = await queries.getUpcomingMovies(20);
    return movies.map(withImageUrls);
  });
}

async function getMovieById(id) {
  const movie = await queries.getMovieById(id);
  if (!movie) throw new AppError('Movie not found', 404, 'NOT_FOUND');
  return withImageUrls(movie);
}

async function setMovieReminder(userId, movieId) {
  await queries.setMovieReminder(userId, movieId);
  return { message: 'Reminder set' };
}

async function getHeroes() {
  return getOrSet('content:heroes', 3600, async () => {
    const heroes = await queries.getHeroes(true);
    return heroes.map(withImageUrls);
  });
}

async function getHeroById(id) {
  const hero = await queries.getHeroById(id);
  if (!hero) throw new AppError('Hero not found', 404, 'NOT_FOUND');
  return withImageUrls(hero);
}

async function getShareCards(query) {
  const { page, limit, offset } = parsePagination(query);
  const category = query.category || 'All';
  const cacheKey = `content:share_cards:${category}:${page}`;

  return getOrSet(cacheKey, 900, async () => {
    const { rows, total } = await queries.getShareCards(category, true, limit, offset);
    return { items: rows.map(withImageUrls), total, page, limit };
  });
}

async function getShareCardDownload(cardId, userId) {
  const card = await queries.getShareCardById(cardId);
  if (!card) throw new AppError('Card not found', 404, 'NOT_FOUND');

  if (card.is_premium) {
    const { rows } = await require('../../config/db').query(
      'SELECT is_premium, premium_expires_at FROM users WHERE id = $1', [userId]
    );
    const user = rows[0];
    if (!user?.is_premium) throw new AppError('Premium required', 403, 'PREMIUM_REQUIRED');
    const url = await getPresignedDownloadUrl(card.image_s3_key);
    return { url, watermark: false };
  }

  return { url: getPublicUrl(card.image_s3_key), watermark: true };
}

async function logShare(userId, cardId) {
  await queries.incrementShareCount(cardId);

  // Award coin (max 5/day)
  const today = new Date().toLocaleDateString('sv-SE', { timeZone: 'Asia/Kolkata' });
  const shareCountKey = `share:daily:${userId}:${today}`;
  const count = await require('../../config/redis').redis.incr(shareCountKey);
  if (count === 1) await require('../../config/redis').redis.expire(shareCountKey, 86400);

  if (count <= COIN_RULES.SHARE_MAX_PER_DAY) {
    await coinService.awardCoins(userId, COIN_RULES.SHARE_CONTENT, 'share', cardId, 'WhatsApp share bonus');
  }

  return { message: 'Share logged', coin_earned: count <= COIN_RULES.SHARE_MAX_PER_DAY };
}

module.exports = {
  getHomeFeed, getUpcomingMovies, getMovieById, setMovieReminder,
  getHeroes, getHeroById,
  getShareCards, getShareCardDownload, logShare,
};
