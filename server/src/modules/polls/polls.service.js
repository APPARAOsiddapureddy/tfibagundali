const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');
const events = require('../recommendations/events.service');

async function list(type) {
  let where = 'WHERE is_active = TRUE AND (status IS NULL OR status = \'ACTIVE\')';
  const params = [];
  if (type) {
    where += ' AND poll_type = $1';
    params.push(type.toLowerCase());
  }
  const { rows } = await db.query(
    `SELECT * FROM polls ${where} AND (ends_at IS NULL OR ends_at > NOW())
     ORDER BY trending_score DESC, total_votes DESC LIMIT 30`,
    params
  );
  return rows.map(formatPoll);
}

async function getOne(id, userId) {
  const { rows } = await db.query('SELECT * FROM polls WHERE id = $1', [id]);
  if (!rows.length) throw new AppError('Poll not found', 404);
  const poll = formatPoll(rows[0]);
  if (userId) {
    const { rows: vote } = await db.query(
      'SELECT option_id, word_text FROM poll_votes WHERE user_id = $1 AND poll_id = $2',
      [userId, id]
    );
    poll.user_vote = vote[0]?.option_id || null;
    poll.user_word = vote[0]?.word_text || null;
  }
  if (poll.ends_at && new Date(poll.ends_at) < new Date()) poll.status = 'CLOSED';
  return poll;
}

async function vote(userId, pollId, { option_id, word_text }) {
  const poll = await getOne(pollId);
  if (poll.status === 'CLOSED') throw new AppError('Poll is closed', 400, 'POLL_CLOSED');

  const { rows: existing } = await db.query(
    'SELECT 1 FROM poll_votes WHERE user_id = $1 AND poll_id = $2',
    [userId, pollId]
  );
  if (existing.length) throw new AppError('Already voted', 409, 'ALREADY_VOTED');

  const isWord = poll.poll_type === 'word' || poll.poll_type === 'WORD_POLL';
  if (isWord) {
    const word = (word_text || '').trim().slice(0, 40);
    if (word.length < 1) throw new AppError('Word required', 400);
    await db.query(
      'INSERT INTO poll_votes (user_id, poll_id, word_text) VALUES ($1,$2,$3)',
      [userId, pollId, word]
    );
    await events.trackEvent({ user_id: userId, event_name: 'word_poll_submitted', content_type: 'poll', content_id: pollId });
  } else {
    if (!option_id) throw new AppError('option_id required', 400);
    const options = poll.options;
    if (!options.find((o) => o.id === option_id)) throw new AppError('Invalid option', 400);
    await db.query(
      'INSERT INTO poll_votes (user_id, poll_id, option_id) VALUES ($1,$2,$3)',
      [userId, pollId, option_id]
    );
    const opt = options.find((o) => o.id === option_id);
    opt.vote_count = (opt.vote_count || 0) + 1;
    await db.query('UPDATE polls SET options = $1::jsonb, total_votes = total_votes + 1 WHERE id = $2', [
      JSON.stringify(options),
      pollId,
    ]);
    await events.trackEvent({ user_id: userId, event_name: 'poll_voted', content_type: 'poll', content_id: pollId });
  }

  await db.query('UPDATE polls SET total_votes = total_votes + 1 WHERE id = $1', [pollId]);
  return getResults(pollId, userId);
}

async function getResults(pollId, userId) {
  const poll = await getOne(pollId, userId);
  return { poll, results: poll.options, total_votes: poll.total_votes };
}

function formatPoll(p) {
  const total = p.total_votes || 1;
  const options = (p.options || []).map((o) => ({
    ...o,
    percent: Math.round(((o.vote_count || 0) / total) * 100),
  }));
  return {
    id: p.id,
    question: p.question,
    type: (p.poll_type || 'NORMAL').toUpperCase(),
    poll_type: p.poll_type,
    category: p.category,
    options,
    total_votes: p.total_votes,
    starts_at: p.starts_at,
    ends_at: p.ends_at,
    status: (p.status || 'ACTIVE').toUpperCase(),
    trending_score: p.trending_score,
    user_vote: p.user_vote,
    user_word: p.user_word,
  };
}

module.exports = { list, getOne, vote, getResults };
