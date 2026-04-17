const { Queue } = require('bullmq');
const env = require('../config/env');

const connection = { url: env.REDIS_URL };

const quizQueue = new Queue('quiz', { connection });
const notificationQueue = new Queue('notifications', { connection });
const leaderboardQueue = new Queue('leaderboard', { connection });

async function scheduleRecurringJobs() {
  // Remove existing repeatable jobs to avoid duplicates
  for (const q of [quizQueue, notificationQueue, leaderboardQueue]) {
    const jobs = await q.getRepeatableJobs();
    for (const job of jobs) await q.removeRepeatableByKey(job.key);
  }

  // Daily quiz generation — 11:30 PM IST
  await quizQueue.add('generate-daily-quiz', {}, {
    repeat: { pattern: '30 18 * * *', tz: 'Asia/Kolkata' }, // 23:30 IST = 18:00 UTC
    jobId: 'generate-daily-quiz',
  });

  // Quiz reminder — 10:00 AM IST
  await notificationQueue.add('send-quiz-reminder', {}, {
    repeat: { pattern: '0 4 * * *', tz: 'UTC' }, // 10:00 IST = 04:30 UTC
    jobId: 'quiz-reminder',
  });

  // Streak warning — 8:00 PM IST
  await notificationQueue.add('send-streak-warning', {}, {
    repeat: { pattern: '30 14 * * *', tz: 'UTC' }, // 20:00 IST = 14:30 UTC
    jobId: 'streak-warning',
  });

  // Reset weekly leaderboard — Monday midnight IST
  await leaderboardQueue.add('reset-weekly-leaderboard', {}, {
    repeat: { pattern: '30 18 * * SUN', tz: 'UTC' }, // Mon 00:00 IST = Sun 18:30 UTC
    jobId: 'reset-leaderboard',
  });

  // Award streak bonuses — midnight IST
  await quizQueue.add('award-streak-bonus', {}, {
    repeat: { pattern: '5 18 * * *', tz: 'UTC' }, // 00:05 IST = 18:35 UTC prev day
    jobId: 'streak-bonus',
  });

  // Cleanup expired tokens — 3:00 AM IST
  await leaderboardQueue.add('cleanup-expired-tokens', {}, {
    repeat: { pattern: '30 21 * * *', tz: 'UTC' }, // 03:00 IST = 21:30 UTC prev day
    jobId: 'cleanup-tokens',
  });
}

module.exports = { quizQueue, notificationQueue, leaderboardQueue, scheduleRecurringJobs };
