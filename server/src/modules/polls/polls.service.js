const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');

async function list(type) {
  let where = 'WHERE is_active = TRUE';
  const params = [];
  if (type) {
    where += ' AND poll_type = $1';
    params.push(type);
  }
  const { rows } = await db.query(
    `SELECT * FROM polls ${where} ORDER BY created_at DESC LIMIT 30`,
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
      'SELECT option_id FROM poll_votes WHERE user_id = $1 AND poll_id = $2',
      [userId, id]
    );
    poll.user_vote = vote[0]?.option_id || null;
  }
  return poll;
}

async function vote(userId, pollId, optionId) {
  const poll = await getOne(pollId);
  const options = poll.options;
  if (!options.find(o => o.id === optionId)) throw new AppError('Invalid option', 400);
  const { rows: existing } = await db.query(
    'SELECT 1 FROM poll_votes WHERE user_id = $1 AND poll_id = $2',
    [userId, pollId]
  );
  if (existing.length) throw new AppError('Already voted', 409);
  await db.query(
    'INSERT INTO poll_votes (user_id, poll_id, option_id) VALUES ($1,$2,$3)',
    [userId, pollId, optionId]
  );
  const opt = options.find(o => o.id === optionId);
  opt.vote_count = (opt.vote_count || 0) + 1;
  await db.query('UPDATE polls SET options = $1::jsonb, total_votes = total_votes + 1 WHERE id = $2', [
    JSON.stringify(options),
    pollId,
  ]);
  return getOne(pollId, userId);
}

function formatPoll(p) {
  const total = p.total_votes || 1;
  const options = (p.options || []).map(o => ({
    ...o,
    percent: Math.round(((o.vote_count || 0) / total) * 100),
  }));
  return {
    id: p.id,
    question: p.question,
    poll_type: p.poll_type,
    options,
    total_votes: p.total_votes,
    ends_at: p.ends_at,
    user_vote: p.user_vote,
  };
}

module.exports = { list, getOne, vote };
