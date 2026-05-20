const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');

function todayIST() {
  return new Date().toLocaleDateString('sv-SE', { timeZone: 'Asia/Kolkata' });
}

function stripQuestion(q) {
  return {
    id: q.id,
    type: q.type,
    difficulty: q.difficulty,
    question_text: q.question_text,
    question_telugu: q.question_telugu,
    image_url: q.image_url,
    options: { a: q.option_a, b: q.option_b, c: q.option_c, d: q.option_d },
    time_limit_seconds: q.difficulty === 'hard' ? 10 : q.difficulty === 'medium' ? 12 : 15,
  };
}

async function getHome() {
  const date = todayIST();
  const { rows: set } = await db.query('SELECT * FROM daily_quiz_sets WHERE quiz_date = $1', [date]);
  const categories = ['hero', 'movie', 'dialogue', 'song', 'classic', 'latest'];
  return {
    daily_available: !!set.length,
    categories,
    quick_games: ['dialogue', 'song_clue', 'poster', 'silhouette', 'release_year', 'director_match'],
  };
}

async function getToday(userId) {
  const date = todayIST();
  const { rows: set } = await db.query('SELECT * FROM daily_quiz_sets WHERE quiz_date = $1', [date]);
  if (!set.length) throw new AppError('No quiz today', 404);
  const { rows: questions } = await db.query(
    `SELECT * FROM quiz_questions WHERE id = ANY($1::uuid[])`,
    [set[0].question_ids]
  );
  let completed = false;
  if (userId) {
    const { rows: sess } = await db.query(
      'SELECT completed FROM quiz_sessions WHERE user_id = $1 AND quiz_date = $2',
      [userId, date]
    );
    completed = sess[0]?.completed || false;
  }
  return {
    quiz_date: date,
    questions: questions.map(stripQuestion),
    already_completed: completed,
  };
}

async function startSession(userId) {
  const date = todayIST();
  const { rows: existing } = await db.query(
    'SELECT * FROM quiz_sessions WHERE user_id = $1 AND quiz_date = $2',
    [userId, date]
  );
  if (existing[0]?.completed) throw new AppError('Quiz already completed', 409);
  if (existing[0]) return { session_id: existing[0].id };
  const { rows } = await db.query(
    'INSERT INTO quiz_sessions (user_id, quiz_date) VALUES ($1,$2) RETURNING id',
    [userId, date]
  );
  return { session_id: rows[0].id };
}

async function submitAnswer(userId, sessionId, questionId, selectedOption) {
  const { rows: q } = await db.query('SELECT correct_option FROM quiz_questions WHERE id = $1', [questionId]);
  if (!q.length) throw new AppError('Question not found', 404);
  const isCorrect = q[0].correct_option.toLowerCase() === selectedOption?.toLowerCase();
  await db.query(
    `INSERT INTO quiz_answers (session_id, question_id, selected_option, is_correct)
     VALUES ($1,$2,$3,$4) ON CONFLICT (session_id, question_id) DO UPDATE SET selected_option = $3, is_correct = $4`,
    [sessionId, questionId, selectedOption, isCorrect]
  );
  if (isCorrect) {
    await db.query('UPDATE quiz_sessions SET score = score + 1 WHERE id = $1', [sessionId]);
  }
  return { is_correct: isCorrect };
}

async function complete(userId, sessionId) {
  const { rows } = await db.query(
    `UPDATE quiz_sessions SET completed = TRUE, completed_at = NOW()
     WHERE id = $1 AND user_id = $2 RETURNING score`,
    [sessionId, userId]
  );
  const total = await db.query('SELECT COUNT(*)::int as c FROM quiz_answers WHERE session_id = $1', [sessionId]);
  return {
    score: rows[0]?.score || 0,
    total: total.rows[0].c,
    message: rows[0]?.score >= 8 ? 'Mass Knowledge Bro! 🔥' : 'Good try! Play again tomorrow.',
  };
}

module.exports = { getHome, getToday, startSession, submitAnswer, complete };
