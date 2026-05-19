const db = require('../../config/db');
const authService = require('../auth/auth.service');
const targeting = require('../recommendations/notifications.service');

async function list(userId, limit = 50) {
  const { rows } = await db.query(
    `SELECT * FROM user_notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2`,
    [userId, limit]
  );
  return rows;
}

async function getPreferences(userId) {
  const user = await authService.getMe(userId);
  return user.notification_preferences || {};
}

async function updatePreferences(userId, prefs) {
  const user = await authService.updateMe(userId, { notification_preferences: prefs });
  return user.notification_preferences;
}

async function markRead(userId, notificationIds) {
  if (!notificationIds?.length) return { marked: 0 };
  const { rowCount } = await db.query(
    `UPDATE user_notifications SET is_read = TRUE
     WHERE user_id = $1 AND id = ANY($2::uuid[])`,
    [userId, notificationIds]
  );
  return { marked: rowCount };
}

async function getTargets(userId) {
  return targeting.getNotificationTargets(userId);
}

module.exports = { list, getPreferences, updatePreferences, markRead, getTargets };
