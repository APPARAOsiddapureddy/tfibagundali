const { Worker } = require('bullmq');
const env = require('../config/env');
const { scheduleRecurringJobs, quizQueue, notificationQueue, leaderboardQueue } = require('./queue');

const connection = { url: env.REDIS_URL };

async function startWorker() {
  const quizWorker = new Worker('quiz', async (job) => {
    console.log(`[Job] Processing: ${job.name}`);
    switch (job.name) {
      case 'generate-daily-quiz': {
        const { generateDailyQuiz } = require('../modules/quiz/quiz.service');
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        const date = tomorrow.toLocaleDateString('sv-SE', { timeZone: 'Asia/Kolkata' });
        await generateDailyQuiz(date);
        console.log(`[Job] Generated quiz for ${date}`);
        break;
      }
      case 'award-streak-bonus': {
        await awardStreakBonuses();
        break;
      }
    }
  }, { connection });

  const notificationWorker = new Worker('notifications', async (job) => {
    const { sendScheduledNotification } = require('../modules/notifications/notifications.service');
    switch (job.name) {
      case 'send-quiz-reminder':
        await sendScheduledNotification('daily_quiz');
        break;
      case 'send-streak-warning':
        await sendScheduledNotification('streak_warning');
        break;
      case 'send-release-reminder':
        await sendReleaseReminders();
        break;
    }
  }, { connection });

  const leaderboardWorker = new Worker('leaderboard', async (job) => {
    switch (job.name) {
      case 'reset-weekly-leaderboard': {
        const { resetWeeklyPoints, updateRanks } = require('../modules/fanarmy/fanarmy.queries');
        await resetWeeklyPoints();
        await updateRanks();
        const { redis } = require('../config/redis');
        await redis.del('fanarmy:leaderboard:weekly', 'fanarmy:all');
        await redis.del('fanarmy:points:weekly');
        console.log('[Job] Weekly leaderboard reset');
        break;
      }
      case 'cleanup-expired-tokens': {
        const db = require('../config/db');
        const { rowCount } = await db.query(`DELETE FROM refresh_tokens WHERE expires_at < NOW()`);
        console.log(`[Job] Cleaned up ${rowCount} expired tokens`);
        break;
      }
    }
  }, { connection });

  [quizWorker, notificationWorker, leaderboardWorker].forEach(w => {
    w.on('failed', (job, err) => console.error(`[Job] ${job?.name} failed:`, err.message));
    w.on('completed', (job) => console.log(`[Job] ${job.name} completed`));
  });

  await scheduleRecurringJobs();
  console.log('✅ Job workers started');
}

async function awardStreakBonuses() {
  const db = require('../config/db');
  const coinService = require('../modules/coins/coins.service');

  // Find users completing 7-day streaks today
  const { rows: streak7 } = await db.query(`
    SELECT DISTINCT user_id FROM quiz_sessions
    WHERE quiz_date = CURRENT_DATE - 1 AND completed = TRUE
    AND user_id IN (
      SELECT user_id FROM quiz_sessions
      WHERE quiz_date >= CURRENT_DATE - 7 AND completed = TRUE
      GROUP BY user_id HAVING COUNT(*) >= 7
    )
  `);

  for (const { user_id } of streak7) {
    await coinService.awardCoins(user_id, 20, 'streak_bonus', '7day', '🔥 7-day streak bonus!');
  }

  // 30-day streaks
  const { rows: streak30 } = await db.query(`
    SELECT DISTINCT user_id FROM quiz_sessions
    WHERE quiz_date = CURRENT_DATE - 1 AND completed = TRUE
    AND user_id IN (
      SELECT user_id FROM quiz_sessions
      WHERE quiz_date >= CURRENT_DATE - 30 AND completed = TRUE
      GROUP BY user_id HAVING COUNT(*) >= 30
    )
  `);

  for (const { user_id } of streak30) {
    await coinService.awardCoins(user_id, 100, 'streak_bonus', '30day', '🏆 30-day streak bonus!');
  }
}

async function sendReleaseReminders() {
  const db = require('../config/db');
  const { sendBatchNotification } = require('../modules/notifications/notifications.service');

  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const tomorrowStr = tomorrow.toLocaleDateString('sv-SE', { timeZone: 'Asia/Kolkata' });

  const { rows: movies } = await db.query(
    `SELECT m.id, m.title FROM movies m WHERE m.release_date::text = $1`,
    [tomorrowStr]
  );

  for (const movie of movies) {
    const { rows: tokens } = await db.query(
      `SELECT ft.token FROM fcm_tokens ft
       JOIN movie_reminders mr ON mr.user_id = ft.user_id
       WHERE mr.movie_id = $1`,
      [movie.id]
    );
    if (tokens.length > 0) {
      await sendBatchNotification(tokens.map(t => t.token), {
        title: '🎬 Raabo!',
        body: `${movie.title} reppati ki vastuundi! Ready ga?`,
        data: { screen: 'moviedetail', id: movie.id },
      });
    }
  }
}

module.exports = { startWorker };
