const db = require('../../config/db');
const authService = require('../auth/auth.service');

async function getProfile(userId) {
  const user = await authService.getMe(userId);
  const { rows: saved } = await db.query(
    `SELECT item_type, item_id, created_at FROM bookmarks WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50`,
    [userId]
  );
  const { rows: reminders } = await db.query(
    `SELECT * FROM reminders WHERE user_id = $1 ORDER BY remind_at ASC`,
    [userId]
  );
  const { rows: quizHistory } = await db.query(
    `SELECT quiz_date, score, completed_at FROM quiz_sessions
     WHERE user_id = $1 AND completed = TRUE ORDER BY quiz_date DESC LIMIT 20`,
    [userId]
  );
  return { user, saved, reminders, quiz_history: quizHistory };
}

module.exports = { getProfile };
