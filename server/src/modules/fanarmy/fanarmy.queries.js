const db = require('../../config/db');

async function getAllArmies() {
  const { rows } = await db.query(
    `SELECT fa.*, h.name as hero_name, h.icon_emoji, h.image_s3_key
     FROM fan_armies fa JOIN heroes h ON h.id = fa.hero_id
     ORDER BY fa.weekly_points DESC`
  );
  return rows;
}

async function getArmyById(id) {
  const { rows } = await db.query(
    `SELECT fa.*, h.name as hero_name, h.icon_emoji FROM fan_armies fa
     JOIN heroes h ON h.id = fa.hero_id WHERE fa.id = $1`,
    [id]
  );
  return rows[0] || null;
}

async function getArmyByHeroId(heroId) {
  const { rows } = await db.query(
    `SELECT * FROM fan_armies WHERE hero_id = $1`, [heroId]
  );
  return rows[0] || null;
}

async function getUserMembership(userId) {
  const { rows } = await db.query(
    `SELECT am.*, fa.army_name, h.icon_emoji, h.name as hero_name,
      RANK() OVER (PARTITION BY am.army_id ORDER BY am.points DESC) as user_rank
     FROM army_members am
     JOIN fan_armies fa ON fa.id = am.army_id
     JOIN heroes h ON h.id = fa.hero_id
     WHERE am.user_id = $1`,
    [userId]
  );
  return rows[0] || null;
}

async function joinArmy(userId, armyId) {
  // Check cooldown (3 months)
  const existing = await getUserMembership(userId);
  if (existing) {
    const threeMonthsAgo = new Date();
    threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);
    if (new Date(existing.joined_at) > threeMonthsAgo) {
      throw new Error('You can only change armies every 3 months');
    }
    await db.query(`DELETE FROM army_members WHERE user_id = $1`, [userId]);
    await db.query(`UPDATE fan_armies SET member_count = member_count - 1 WHERE id = $1`, [existing.army_id]);
  }

  const { rows } = await db.query(
    `INSERT INTO army_members (user_id, army_id) VALUES ($1, $2)
     ON CONFLICT (user_id, army_id) DO NOTHING RETURNING *`,
    [userId, armyId]
  );
  await db.query(`UPDATE fan_armies SET member_count = member_count + 1 WHERE id = $1`, [armyId]);
  return rows[0];
}

async function addArmyPoints(userId, points) {
  await db.query(
    `UPDATE army_members SET points = points + $2 WHERE user_id = $1`,
    [userId, points]
  );
  // Update army weekly_points
  await db.query(
    `UPDATE fan_armies SET weekly_points = weekly_points + $2, total_points = total_points + $2
     WHERE id = (SELECT army_id FROM army_members WHERE user_id = $1)`,
    [userId, points]
  );
}

async function getLeaderboard() {
  const { rows } = await db.query(
    `SELECT fa.id, fa.army_name, fa.member_count, fa.weekly_points, fa.total_points, fa.rank,
      h.icon_emoji, h.name as hero_name
     FROM fan_armies fa JOIN heroes h ON h.id = fa.hero_id
     ORDER BY fa.weekly_points DESC LIMIT 10`
  );
  return rows;
}

async function updateRanks() {
  await db.query(`
    UPDATE fan_armies fa SET rank = ranked.rank
    FROM (SELECT id, RANK() OVER (ORDER BY weekly_points DESC) as rank FROM fan_armies) ranked
    WHERE fa.id = ranked.id
  `);
}

async function resetWeeklyPoints() {
  await db.query(`UPDATE fan_armies SET weekly_points = 0`);
}

async function getActivePoll() {
  const { rows } = await db.query(
    `SELECT * FROM polls WHERE is_active = TRUE AND starts_at <= NOW() AND ends_at > NOW()
     ORDER BY created_at DESC LIMIT 1`
  );
  return rows[0] || null;
}

async function getUserPollVote(userId, pollId) {
  const { rows } = await db.query(
    `SELECT * FROM poll_votes WHERE user_id = $1 AND poll_id = $2`, [userId, pollId]
  );
  return rows[0] || null;
}

async function castPollVote(userId, pollId, optionId) {
  const { rows } = await db.query(
    `INSERT INTO poll_votes (user_id, poll_id, option_id) VALUES ($1, $2, $3)
     ON CONFLICT (user_id, poll_id) DO NOTHING RETURNING *`,
    [userId, pollId, optionId]
  );
  if (rows[0]) {
    // Increment vote count in JSONB options
    await db.query(
      `UPDATE polls SET total_votes = total_votes + 1,
       options = (
         SELECT jsonb_agg(
           CASE WHEN opt->>'id' = $2 THEN jsonb_set(opt, '{vote_count}', ((opt->>'vote_count')::int + 1)::text::jsonb)
           ELSE opt END
         ) FROM jsonb_array_elements(options) opt
       )
       WHERE id = $1`,
      [pollId, optionId]
    );
  }
  return rows[0];
}

module.exports = {
  getAllArmies, getArmyById, getArmyByHeroId, getUserMembership, joinArmy,
  addArmyPoints, getLeaderboard, updateRanks, resetWeeklyPoints,
  getActivePoll, getUserPollVote, castPollVote,
};
