const db = require('../../config/db');
const { respond } = require('../../utils/pagination');
const sharp = require('sharp');
const { uploadBuffer, getPublicUrl } = require('../../config/s3');
const { v4: uuidv4 } = require('uuid');
const quizService = require('../quiz/quiz.service');

async function listQuestions(req, res, next) {
  try {
    const { rows } = await db.query(
      `SELECT * FROM quiz_questions ORDER BY created_at DESC LIMIT 100`
    );
    respond(res, { questions: rows });
  } catch (err) { next(err); }
}

async function createQuestion(req, res, next) {
  try {
    const { question_text, question_telugu, type, difficulty, option_a, option_b, option_c, option_d, correct_option, coins_reward, movie_id, hero_id, image_s3_key } = req.body;
    const { rows } = await db.query(
      `INSERT INTO quiz_questions (question_text, question_telugu, type, difficulty, option_a, option_b, option_c, option_d, correct_option, coins_reward, movie_id, hero_id, image_s3_key)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) RETURNING *`,
      [question_text, question_telugu, type, difficulty, option_a, option_b, option_c, option_d, correct_option, coins_reward || 5, movie_id || null, hero_id || null, image_s3_key || null]
    );
    respond(res, rows[0]);
  } catch (err) { next(err); }
}

async function updateQuestion(req, res, next) {
  try {
    const fields = req.body;
    const keys = Object.keys(fields);
    const setClauses = keys.map((k, i) => `${k} = $${i + 2}`).join(', ');
    const { rows } = await db.query(
      `UPDATE quiz_questions SET ${setClauses} WHERE id = $1 RETURNING *`,
      [req.params.id, ...Object.values(fields)]
    );
    respond(res, rows[0]);
  } catch (err) { next(err); }
}

async function deleteQuestion(req, res, next) {
  try {
    await db.query(`UPDATE quiz_questions SET is_active = FALSE WHERE id = $1`, [req.params.id]);
    respond(res, { message: 'Question deactivated' });
  } catch (err) { next(err); }
}

async function listMovies(req, res, next) {
  try {
    const { rows } = await db.query(`SELECT * FROM movies ORDER BY release_date ASC`);
    respond(res, { movies: rows });
  } catch (err) { next(err); }
}

async function createMovie(req, res, next) {
  try {
    const { title, title_telugu, hero_id, director, production_house, music_director, release_date, genre, synopsis, status } = req.body;
    const { rows } = await db.query(
      `INSERT INTO movies (title, title_telugu, hero_id, director, production_house, music_director, release_date, genre, synopsis, status)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`,
      [title, title_telugu, hero_id, director, production_house, music_director, release_date, genre, synopsis, status || 'upcoming']
    );
    respond(res, rows[0]);
  } catch (err) { next(err); }
}

async function updateMovie(req, res, next) {
  try {
    const fields = req.body;
    const keys = Object.keys(fields);
    const setClauses = keys.map((k, i) => `${k} = $${i + 2}`).join(', ');
    const { rows } = await db.query(
      `UPDATE movies SET ${setClauses} WHERE id = $1 RETURNING *`,
      [req.params.id, ...Object.values(fields)]
    );
    respond(res, rows[0]);
  } catch (err) { next(err); }
}

async function listShareCards(req, res, next) {
  try {
    const { rows } = await db.query(`SELECT * FROM share_cards ORDER BY created_at DESC LIMIT 100`);
    respond(res, { cards: rows });
  } catch (err) { next(err); }
}

async function createShareCard(req, res, next) {
  try {
    const { title, category, hero_id, movie_id, is_premium, publish_date } = req.body;
    let image_s3_key = null, thumbnail_s3_key = null;

    if (req.file) {
      const id = uuidv4();
      const fullBuffer = await sharp(req.file.buffer).resize({ width: 1080 }).jpeg({ quality: 85 }).toBuffer();
      const thumbBuffer = await sharp(req.file.buffer).resize({ width: 400 }).jpeg({ quality: 80 }).toBuffer();
      image_s3_key = `share-cards/${category}/${id}/full.jpg`;
      thumbnail_s3_key = `share-cards/${category}/${id}/thumb.jpg`;
      await uploadBuffer(fullBuffer, image_s3_key);
      await uploadBuffer(thumbBuffer, thumbnail_s3_key);
    }

    const { rows } = await db.query(
      `INSERT INTO share_cards (title, category, hero_id, movie_id, image_s3_key, thumbnail_s3_key, is_premium, publish_date)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
      [title, category, hero_id || null, movie_id || null, image_s3_key, thumbnail_s3_key, is_premium === 'true', publish_date || null]
    );
    respond(res, rows[0]);
  } catch (err) { next(err); }
}

async function updateShareCard(req, res, next) {
  try {
    const fields = req.body;
    const keys = Object.keys(fields);
    const setClauses = keys.map((k, i) => `${k} = $${i + 2}`).join(', ');
    const { rows } = await db.query(
      `UPDATE share_cards SET ${setClauses} WHERE id = $1 RETURNING *`,
      [req.params.id, ...Object.values(fields)]
    );
    respond(res, rows[0]);
  } catch (err) { next(err); }
}

async function createHero(req, res, next) {
  try {
    const { name, telugu_name, army_name, icon_emoji, bio, birth_date, sort_order } = req.body;
    let image_s3_key = null;
    if (req.file) {
      const id = uuidv4();
      const buffer = await sharp(req.file.buffer).resize({ width: 600 }).jpeg({ quality: 85 }).toBuffer();
      image_s3_key = `heroes/${id}/profile.jpg`;
      await uploadBuffer(buffer, image_s3_key);
    }
    const { rows } = await db.query(
      `INSERT INTO heroes (name, telugu_name, army_name, icon_emoji, image_s3_key, bio, birth_date, sort_order)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
      [name, telugu_name, army_name, icon_emoji, image_s3_key, bio, birth_date, sort_order || 0]
    );
    // Create fan army for hero
    await db.query(`INSERT INTO fan_armies (hero_id, army_name) VALUES ($1, $2) ON CONFLICT DO NOTHING`, [rows[0].id, army_name]);
    respond(res, rows[0]);
  } catch (err) { next(err); }
}

async function updateHero(req, res, next) {
  try {
    const fields = req.body;
    const keys = Object.keys(fields);
    const setClauses = keys.map((k, i) => `${k} = $${i + 2}`).join(', ');
    const { rows } = await db.query(
      `UPDATE heroes SET ${setClauses} WHERE id = $1 RETURNING *`,
      [req.params.id, ...Object.values(fields)]
    );
    respond(res, rows[0]);
  } catch (err) { next(err); }
}

async function createPoll(req, res, next) {
  try {
    const { question, options, starts_at, ends_at } = req.body;
    const { rows } = await db.query(
      `INSERT INTO polls (question, options, starts_at, ends_at) VALUES ($1,$2,$3,$4) RETURNING *`,
      [question, JSON.stringify(options), starts_at, ends_at]
    );
    respond(res, rows[0]);
  } catch (err) { next(err); }
}

async function updatePoll(req, res, next) {
  try {
    const { is_active } = req.body;
    const { rows } = await db.query(
      `UPDATE polls SET is_active = $2 WHERE id = $1 RETURNING *`,
      [req.params.id, is_active]
    );
    respond(res, rows[0]);
  } catch (err) { next(err); }
}

async function generateTodayQuiz(req, res, next) {
  try {
    const date = req.body.date || new Date().toLocaleDateString('sv-SE', { timeZone: 'Asia/Kolkata' });
    await quizService.generateDailyQuiz(date);
    respond(res, { message: `Quiz generated for ${date}` });
  } catch (err) { next(err); }
}

async function getStats(req, res, next) {
  try {
    const [users, quizzes, shares] = await Promise.all([
      db.query(`SELECT COUNT(*)::int as total, COUNT(*) FILTER (WHERE last_login_at > NOW() - INTERVAL '24 hours')::int as dau FROM users WHERE deleted_at IS NULL`),
      db.query(`SELECT COUNT(*)::int as total FROM quiz_sessions WHERE quiz_date = CURRENT_DATE AND completed = TRUE`),
      db.query(`SELECT SUM(share_count)::int as total FROM share_cards`),
    ]);
    respond(res, {
      users: users.rows[0],
      quizzes_today: quizzes.rows[0].total,
      total_shares: shares.rows[0].total,
    });
  } catch (err) { next(err); }
}

module.exports = {
  listQuestions, createQuestion, updateQuestion, deleteQuestion,
  listMovies, createMovie, updateMovie,
  listShareCards, createShareCard, updateShareCard,
  createHero, updateHero,
  createPoll, updatePoll,
  generateTodayQuiz, getStats,
};
