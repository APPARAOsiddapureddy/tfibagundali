const db = require('../../config/db');

let firebaseAdmin;
try {
  firebaseAdmin = require('firebase-admin');
} catch (_) {}

function getFirebaseApp() {
  if (!firebaseAdmin) return null;
  if (firebaseAdmin.apps.length > 0) return firebaseAdmin.apps[0];

  const env = require('../../config/env');
  if (!env.FIREBASE_PROJECT_ID) return null;

  return firebaseAdmin.initializeApp({
    credential: firebaseAdmin.credential.cert({
      projectId: env.FIREBASE_PROJECT_ID,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
      privateKey: env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });
}

async function getActiveTokens(excludeUserId) {
  const { rows } = await db.query(
    `SELECT ft.token, ft.user_id FROM fcm_tokens ft
     JOIN users u ON u.id = ft.user_id
     WHERE u.deleted_at IS NULL ${excludeUserId ? 'AND ft.user_id != $1' : ''}
     LIMIT 10000`,
    excludeUserId ? [excludeUserId] : []
  );
  return rows;
}

async function getTokensWithIncompleteQuiz(date) {
  const { rows } = await db.query(
    `SELECT ft.token FROM fcm_tokens ft
     JOIN users u ON u.id = ft.user_id
     WHERE u.deleted_at IS NULL
     AND ft.user_id NOT IN (
       SELECT user_id FROM quiz_sessions WHERE quiz_date = $1 AND completed = TRUE
     )`,
    [date]
  );
  return rows.map(r => r.token);
}

async function removeInvalidToken(token) {
  await db.query(`DELETE FROM fcm_tokens WHERE token = $1`, [token]);
}

function chunkArray(arr, size) {
  const chunks = [];
  for (let i = 0; i < arr.length; i += size) chunks.push(arr.slice(i, i + size));
  return chunks;
}

async function sendBatchNotification(tokens, payload) {
  const app = getFirebaseApp();
  if (!app) {
    console.log('[FCM Dev] Would send to', tokens.length, 'tokens:', payload.title);
    return;
  }

  const chunks = chunkArray(tokens, 500);
  for (const chunk of chunks) {
    const message = {
      notification: { title: payload.title, body: payload.body },
      data: payload.data || {},
      tokens: chunk,
    };
    const response = await app.messaging().sendEachForMulticast(message);
    const invalids = response.responses
      .map((r, i) => (!r.success && r.error?.code?.includes('invalid-registration-token')) ? chunk[i] : null)
      .filter(Boolean);

    for (const token of invalids) await removeInvalidToken(token);
  }
}

const NOTIFICATION_TEMPLATES = {
  daily_quiz: { title: '🎯 Quiz Ready!', body: 'Nee daily quiz waiting! Neevu gelusthava? 🏆', data: { screen: 'quiz' } },
  streak_warning: { title: '🔥 Streak Alert!', body: 'Nee streak potundi! Oka question aadite chaalu', data: { screen: 'quiz' } },
  weekly_leaderboard: { title: '⚔️ Army Update!', body: 'Check ee week fan army leaderboard!', data: { screen: 'fanarmy' } },
};

async function sendScheduledNotification(type, extraData = {}) {
  const template = NOTIFICATION_TEMPLATES[type];
  if (!template) return;

  let tokens;
  if (type === 'daily_quiz' || type === 'streak_warning') {
    const date = new Date().toLocaleDateString('sv-SE', { timeZone: 'Asia/Kolkata' });
    tokens = await getTokensWithIncompleteQuiz(date);
  } else {
    const allTokens = await getActiveTokens();
    tokens = allTokens.map(t => t.token);
  }

  if (!tokens.length) return;

  await sendBatchNotification(tokens, {
    ...template,
    data: { ...template.data, ...extraData },
  });

  console.log(`[FCM] Sent ${type} to ${tokens.length} users`);
}

module.exports = { sendBatchNotification, sendScheduledNotification, getTokensWithIncompleteQuiz };
