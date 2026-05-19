const db = require('../../config/db');

async function logImpressions(userId, sectionType, items) {
  if (!userId || !items?.length) return;
  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    await db.query(
      `INSERT INTO recommendation_impressions (
        user_id, content_type, content_id, section_type, position,
        final_score, scoring_breakdown, reason
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
      [
        userId,
        item.content_type,
        item.id,
        sectionType,
        i,
        item._score ?? null,
        JSON.stringify(item._breakdown || {}),
        item._reason || null,
      ]
    );
  }
}

module.exports = { logImpressions };
