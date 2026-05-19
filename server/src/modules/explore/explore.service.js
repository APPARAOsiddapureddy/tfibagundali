const exploreRec = require('../recommendations/explore-rec.service');
const db = require('../../config/db');

async function getExplore(userId) {
  const rec = await exploreRec.getExploreRecommendations(userId);
  const { rows: heroes } = await db.query(
    'SELECT id, name, telugu_name, icon_emoji FROM heroes ORDER BY sort_order LIMIT 8'
  );
  const { rows: archive } = await db.query(
    `SELECT id, title, category, trust_status, published_at FROM tfi_updates
     WHERE is_active ORDER BY published_at DESC LIMIT 12`
  );
  const { rows: trailers } = await db.query(
    `SELECT id, title, short_summary, summary, image_url, published_at FROM tfi_updates
     WHERE is_active AND LOWER(category) IN ('trailer', 'teaser') ORDER BY published_at DESC LIMIT 8`
  );
  const { rows: songs } = await db.query(
    `SELECT id, title, COALESCE(short_summary, summary) as short_summary, published_at FROM tfi_updates
     WHERE is_active AND LOWER(category) = 'song' ORDER BY published_at DESC LIMIT 8`
  );

  return {
    sections: [
      ...rec.sections,
      { type: 'hero_collections', title: 'Hero Collections', items: heroes },
      { type: 'update_archive', title: 'Update Archive', items: archive },
      { type: 'latest_trailers', title: 'Latest Trailers', items: trailers },
      { type: 'recent_songs', title: 'Recent Songs', items: songs },
    ],
    meta: rec.meta,
  };
}

module.exports = { getExplore };
