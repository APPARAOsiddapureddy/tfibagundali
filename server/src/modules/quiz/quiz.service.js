const queries = require('./quiz.queries');
const coinService = require('../coins/coins.service');
const { redis, getOrSet } = require('../../config/redis');
const { AppError } = require('../../middleware/error.middleware');
const { getQuizCoins } = require('../../utils/coins');
const { getPublicUrl } = require('../../config/s3');

function getTodayIST() {
  return new Date().toLocaleDateString('sv-SE', { timeZone: 'Asia/Kolkata' });
}

function secondsUntilMidnightIST() {
  const now = new Date();
  const midnight = new Date(now.toLocaleDateString('sv-SE', { timeZone: 'Asia/Kolkata' }) + 'T23:59:59+05:30');
  return Math.max(0, Math.floor((midnight - now) / 1000) + 1);
}

function stripCorrectAnswers(questions) {
  return questions.map(q => ({
    id: q.id,
    position: q.position,
    type: q.type,
    difficulty: q.difficulty,
    question_text: q.question_text,
    question_telugu: q.question_telugu,
    image_url: q.image_s3_key ? getPublicUrl(q.image_s3_key) : null,
    options: { a: q.option_a, b: q.option_b, c: q.option_c, d: q.option_d },
    time_limit_seconds: q.difficulty === 'hard' ? 10 : q.difficulty === 'medium' ? 12 : 15,
    coins_reward: q.coins_reward || 5,
  }));
}

async function getToday(userId) {
  const date = getTodayIST();
  const cacheKey = `quiz:daily:${date}`;

  const session = await queries.getSession(userId, date);

  let quizSet = await redis.get(cacheKey);
  if (quizSet) {
    quizSet = JSON.parse(quizSet);
  } else {
    const dbSet = await queries.getDailyQuizSet(date);
    if (!dbSet) {
      // Auto-generate if missing (fallback)
      await generateDailyQuiz(date);
      const newSet = await queries.getDailyQuizSet(date);
      quizSet = newSet?.questions || [];
    } else {
      quizSet = dbSet.questions || [];
    }
    const ttl = secondsUntilMidnightIST();
    await redis.setex(cacheKey, ttl, JSON.stringify(quizSet));
  }

  const maxCoins = quizSet.reduce((sum, q) => sum + (q.coins_reward || 5), 0);

  return {
    quiz_date: date,
    questions: stripCorrectAnswers(quizSet.map((q, i) => ({ ...q, position: i + 1 }))),
    already_completed: session?.completed || false,
    max_coins_today: maxCoins || 25,
    session_score: session?.score || null,
  };
}

async function startSession(userId) {
  const date = getTodayIST();
  const existing = await queries.getSession(userId, date);
  if (existing?.completed) throw new AppError('Quiz already completed for today', 409, 'QUIZ_ALREADY_COMPLETED');
  const session = await queries.createSession(userId, date);
  return { session_id: session.id, quiz_date: date };
}

async function submitAnswer(userId, sessionId, questionId, selectedOption, timeTakenMs) {
  // Verify session belongs to user
  const date = getTodayIST();
  const session = await queries.getSession(userId, date);
  if (!session || session.id !== parseInt(sessionId)) {
    throw new AppError('Session not found', 404, 'SESSION_NOT_FOUND');
  }
  if (session.completed) throw new AppError('Session already completed', 409, 'QUIZ_ALREADY_COMPLETED');

  // Get correct answer from DB (never exposed to client)
  const db = require('../../config/db');
  const { rows } = await db.query(
    'SELECT correct_option, coins_reward, movie_id FROM quiz_questions WHERE id = $1',
    [questionId]
  );

  const question = rows[0];
  if (!question) throw new AppError('Question not found', 404, 'QUESTION_NOT_FOUND');

  const isCorrect = selectedOption === question.correct_option;

  await queries.recordAnswer(sessionId, questionId, selectedOption, isCorrect, timeTakenMs);

  const coinBalance = await coinService.getBalance(userId);

  return {
    is_correct: isCorrect,
    correct_option: question.correct_option,
    coins_earned: isCorrect ? (question.coins_reward || 5) : 0,
    coin_balance: coinBalance,
  };
}

async function completeSession(userId, sessionId, totalTimeTakenMs) {
  const date = getTodayIST();
  const session = await queries.getSession(userId, date);
  if (!session || session.id !== parseInt(sessionId)) {
    throw new AppError('Session not found', 404, 'SESSION_NOT_FOUND');
  }
  if (session.completed) throw new AppError('Session already completed', 409, 'QUIZ_ALREADY_COMPLETED');

  const { count, correct } = await queries.getAnswerCount(sessionId);
  const coinsEarned = getQuizCoins(correct);

  const completed = await queries.completeSession(sessionId, correct, coinsEarned, totalTimeTakenMs);

  if (coinsEarned > 0) {
    await coinService.awardCoins(userId, coinsEarned, 'quiz_reward', String(sessionId), `Quiz ${date}: ${correct}/5`);
  }

  // Update army points
  try {
    const armyService = require('../fanarmy/fanarmy.service');
    await armyService.addActivityPoints(userId, coinsEarned + 10);
  } catch (_) {}

  const streakData = await queries.getStreakData(userId);
  const coinBalance = await coinService.getBalance(userId);

  return {
    score: correct,
    total: count,
    coins_earned: coinsEarned,
    coin_balance: coinBalance,
    streak: streakData.streak,
    quiz_date: date,
  };
}

async function generateDailyQuiz(date) {
  const existing = await queries.getDailyQuizSet(date);
  if (existing) return;

  const recentIds = await queries.getRecentlyUsedQuestionIds(30);
  const pool = await queries.getQuestionPool(recentIds, 100);

  const selected = pickDiverseQuestions(pool, 5);
  if (selected.length < 5) {
    // Fallback: allow recently used if pool too small
    const fallback = await queries.getQuestionPool([], 20);
    const needed = 5 - selected.length;
    const extras = fallback.filter(q => !selected.find(s => s.id === q.id)).slice(0, needed);
    selected.push(...extras);
  }

  const ids = selected.map(q => q.id);
  await queries.createDailyQuizSet(date, ids);
  await queries.incrementTimesServed(ids);
  return ids;
}

function pickDiverseQuestions(pool, count) {
  const types = ['movie_still', 'dialogue', 'song_clue', 'release_year', 'hero_silhouette'];
  const selected = [];
  const usedTypes = {};

  // First pass: pick one of each type if available
  for (const type of types) {
    if (selected.length >= count) break;
    const candidates = pool.filter(q => q.type === type && !selected.find(s => s.id === q.id));
    if (candidates.length > 0) {
      selected.push(candidates[Math.floor(Math.random() * candidates.length)]);
      usedTypes[type] = (usedTypes[type] || 0) + 1;
    }
  }

  // Second pass: fill remaining slots
  const remaining = pool.filter(q => !selected.find(s => s.id === q.id));
  while (selected.length < count && remaining.length > 0) {
    const idx = Math.floor(Math.random() * remaining.length);
    selected.push(remaining.splice(idx, 1)[0]);
  }

  return selected.slice(0, count);
}

async function getDailyLeaderboard() {
  const date = getTodayIST();
  return getOrSet(`quiz:leaderboard:daily:${date}`, 300, () => queries.getDailyLeaderboard(date));
}

async function getWeeklyLeaderboard() {
  return getOrSet('quiz:leaderboard:weekly', 900, () => queries.getWeeklyLeaderboard());
}

async function getUserHistory(userId) {
  return queries.getUserHistory(userId);
}

async function getStreak(userId) {
  return getOrSet(`user:streak:${userId}`, secondsUntilMidnightIST(), () => queries.getStreakData(userId));
}

module.exports = {
  getToday, startSession, submitAnswer, completeSession,
  generateDailyQuiz, getDailyLeaderboard, getWeeklyLeaderboard,
  getUserHistory, getStreak,
};
