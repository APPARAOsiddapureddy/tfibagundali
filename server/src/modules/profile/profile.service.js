const db = require('../../config/db');
const authService = require('../auth/auth.service');
const { AppError } = require('../../middleware/error.middleware');

async function getProfile(userId) {
  return authService.getMe(userId);
}

async function updateProfile(userId, fields) {
  return authService.updateMe(userId, fields);
}

async function setFavouriteHero(userId, heroId) {
  if (heroId) {
    const { rows } = await db.query('SELECT id FROM heroes WHERE id = $1', [heroId]);
    if (!rows.length) throw new AppError('Hero not found', 404, 'NOT_FOUND');
  }
  return authService.updateMe(userId, {
    favourite_hero_id: heroId || null,
    is_onboarded: !!heroId,
  });
}

async function setFcmToken(userId, fcmToken) {
  return authService.updateMe(userId, { fcm_token: fcmToken });
}

async function getSaved(userId) {
  const { rows } = await db.query(
    `SELECT item_type as content_type, item_id, created_at FROM bookmarks
     WHERE user_id = $1 ORDER BY created_at DESC LIMIT 100`,
    [userId]
  );
  return rows;
}

async function getReminders(userId) {
  const { rows } = await db.query(
    `SELECT * FROM reminders WHERE user_id = $1 ORDER BY event_datetime ASC NULLS LAST, created_at DESC`,
    [userId]
  );
  return rows;
}

async function getDownloads(userId) {
  const { rows } = await db.query(
    `SELECT content_type, content_id, created_at FROM user_downloads
     WHERE user_id = $1 ORDER BY created_at DESC LIMIT 100`,
    [userId]
  );
  return rows;
}

async function getQuizHistory(userId) {
  const { rows } = await db.query(
    `SELECT id, quiz_date, score, completed, completed_at FROM quiz_sessions
     WHERE user_id = $1 AND completed = TRUE ORDER BY quiz_date DESC LIMIT 50`,
    [userId]
  );
  return rows;
}

module.exports = {
  getProfile,
  updateProfile,
  setFavouriteHero,
  setFcmToken,
  getSaved,
  getReminders,
  getDownloads,
  getQuizHistory,
};
