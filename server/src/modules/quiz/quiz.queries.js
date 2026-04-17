const db = require('../../config/db');

async function getDailyQuizSet(date) {
  const { rows } = await db.query(
    `SELECT dqs.id, dqs.question_ids, dqs.quiz_date,
      array_agg(row_to_json(qq) ORDER BY array_position(dqs.question_ids, qq.id)) AS questions
     FROM daily_quiz_sets dqs
     JOIN quiz_questions qq ON qq.id = ANY(dqs.question_ids)
     WHERE dqs.quiz_date = $1
     GROUP BY dqs.id`,
    [date]
  );
  return rows[0] || null;
}

async function getQuestionPool(excludeIds = [], limit = 100) {
  const { rows } = await db.query(
    `SELECT id, type, difficulty, coins_reward FROM quiz_questions
     WHERE is_active = true
     AND ($1::uuid[] IS NULL OR id != ALL($1::uuid[]))
     ORDER BY times_served ASC, RANDOM()
     LIMIT $2`,
    [excludeIds.length ? excludeIds : null, limit]
  );
  return rows;
}

async function getRecentlyUsedQuestionIds(days = 30) {
  const { rows } = await db.query(
    `SELECT DISTINCT UNNEST(question_ids) AS id
     FROM daily_quiz_sets
     WHERE quiz_date > CURRENT_DATE - $1::int`,
    [days]
  );
  return rows.map(r => r.id);
}

async function createDailyQuizSet(date, questionIds) {
  const { rows } = await db.query(
    `INSERT INTO daily_quiz_sets (quiz_date, question_ids) VALUES ($1, $2)
     ON CONFLICT (quiz_date) DO NOTHING RETURNING *`,
    [date, questionIds]
  );
  return rows[0];
}

async function getSession(userId, date) {
  const { rows } = await db.query(
    `SELECT * FROM quiz_sessions WHERE user_id = $1 AND quiz_date = $2`,
    [userId, date]
  );
  return rows[0] || null;
}

async function createSession(userId, date) {
  const { rows } = await db.query(
    `INSERT INTO quiz_sessions (user_id, quiz_date) VALUES ($1, $2)
     ON CONFLICT (user_id, quiz_date) DO UPDATE SET started_at = NOW()
     RETURNING *`,
    [userId, date]
  );
  return rows[0];
}

async function recordAnswer(sessionId, questionId, selectedOption, isCorrect, timeTakenMs) {
  await db.query(
    `INSERT INTO quiz_answers (session_id, question_id, selected_option, is_correct, time_taken_ms)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT DO NOTHING`,
    [sessionId, questionId, selectedOption, isCorrect, timeTakenMs]
  );
}

async function completeSession(sessionId, score, coinsEarned, timeTakenMs) {
  const { rows } = await db.query(
    `UPDATE quiz_sessions
     SET completed = TRUE, score = $2, coins_earned = $3, time_taken_ms = $4, completed_at = NOW()
     WHERE id = $1 RETURNING *`,
    [sessionId, score, coinsEarned, timeTakenMs]
  );
  return rows[0];
}

async function getAnswerCount(sessionId) {
  const { rows } = await db.query(
    `SELECT COUNT(*) as count, SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as correct
     FROM quiz_answers WHERE session_id = $1`,
    [sessionId]
  );
  return { count: parseInt(rows[0].count), correct: parseInt(rows[0].correct) };
}

async function getDailyLeaderboard(date, limit = 50) {
  const { rows } = await db.query(
    `SELECT qs.user_id, u.username, u.display_name, qs.score, qs.coins_earned, qs.time_taken_ms,
      RANK() OVER (ORDER BY qs.score DESC, qs.time_taken_ms ASC) as rank
     FROM quiz_sessions qs
     JOIN users u ON u.id = qs.user_id
     WHERE qs.quiz_date = $1 AND qs.completed = TRUE
     ORDER BY qs.score DESC, qs.time_taken_ms ASC
     LIMIT $2`,
    [date, limit]
  );
  return rows;
}

async function getWeeklyLeaderboard(limit = 50) {
  const { rows } = await db.query(
    `SELECT u.id, u.username, u.display_name,
      SUM(qs.score) as total_score, SUM(qs.coins_earned) as total_coins,
      COUNT(qs.id) as quizzes_played,
      RANK() OVER (ORDER BY SUM(qs.score) DESC, SUM(qs.coins_earned) DESC) as rank
     FROM quiz_sessions qs
     JOIN users u ON u.id = qs.user_id
     WHERE qs.quiz_date > CURRENT_DATE - 7 AND qs.completed = TRUE
     GROUP BY u.id
     ORDER BY total_score DESC
     LIMIT $1`,
    [limit]
  );
  return rows;
}

async function getUserHistory(userId, limit = 30) {
  const { rows } = await db.query(
    `SELECT * FROM quiz_sessions WHERE user_id = $1 ORDER BY quiz_date DESC LIMIT $2`,
    [userId, limit]
  );
  return rows;
}

async function getStreakData(userId) {
  const { rows } = await db.query(
    `WITH consecutive AS (
      SELECT quiz_date,
        quiz_date - (ROW_NUMBER() OVER (ORDER BY quiz_date))::int AS grp
      FROM quiz_sessions
      WHERE user_id = $1 AND completed = TRUE
    )
    SELECT COUNT(*) as streak, MAX(quiz_date) as last_date
    FROM consecutive
    WHERE grp = (
      SELECT quiz_date - (ROW_NUMBER() OVER (ORDER BY quiz_date))::int
      FROM quiz_sessions
      WHERE user_id = $1 AND completed = TRUE
      ORDER BY quiz_date DESC LIMIT 1
    )`,
    [userId]
  );
  return { streak: parseInt(rows[0]?.streak || 0), last_date: rows[0]?.last_date };
}

async function incrementTimesServed(questionIds) {
  await db.query(
    `UPDATE quiz_questions SET times_served = times_served + 1 WHERE id = ANY($1::uuid[])`,
    [questionIds]
  );
}

module.exports = {
  getDailyQuizSet, getQuestionPool, getRecentlyUsedQuestionIds, createDailyQuizSet,
  getSession, createSession, recordAnswer, completeSession, getAnswerCount,
  getDailyLeaderboard, getWeeklyLeaderboard, getUserHistory, getStreakData,
  incrementTimesServed,
};
