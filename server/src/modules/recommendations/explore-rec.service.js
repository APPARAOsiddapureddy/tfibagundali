const db = require('../../config/db');
const { loadUserContext } = require('./user-context');
const candidates = require('./candidates');
const { scoreAsset } = require('./home-feed.service');

async function getExploreRecommendations(userId) {
  const ctx = await loadUserContext(userId);

  const personalized = (await candidates.fetchWallpapersAndCards(ctx, 16))
    .map((a) => ({ ...a, _score: scoreAsset(a, ctx) }))
    .sort((a, b) => b._score - a._score);

  const { rows: trendingWp } = await db.query(
    `SELECT id, title, category, image_url, hero_id, movie_id, 'wallpaper' as content_type
     FROM wallpapers WHERE is_trending = TRUE ORDER BY created_at DESC LIMIT 8`
  );
  const { rows: trendingCards } = await db.query(
    `SELECT id, title, category, image_url, hero_id, movie_id, 'status_card' as content_type
     FROM status_cards WHERE is_trending = TRUE ORDER BY created_at DESC LIMIT 8`
  );
  const trending = [...trendingWp, ...trendingCards].slice(0, 12);

  const { rows: recentWp } = await db.query(
    `SELECT id, title, category, image_url, hero_id, movie_id, 'wallpaper' as content_type
     FROM wallpapers ORDER BY created_at DESC LIMIT 6`
  );
  const { rows: recentCards } = await db.query(
    `SELECT id, title, category, image_url, hero_id, movie_id, 'status_card' as content_type
     FROM status_cards ORDER BY created_at DESC LIMIT 6`
  );
  const recent = [...recentWp, ...recentCards].slice(0, 10);

  const { rows: movies } = await db.query(
    `SELECT id, title, title_telugu, release_date, poster_url, hero_id
     FROM movies WHERE status = 'upcoming' ORDER BY release_date ASC LIMIT 8`
  );

  return {
    sections: [
      {
        type: 'for_you',
        title: ctx?.favouriteHeroId ? 'For Your Favourite Hero' : 'Trending Wallpapers',
        items: personalized.slice(0, 8),
        mix: 'personalized',
      },
      {
        type: 'trending',
        title: 'Trending Now',
        items: trending,
        mix: 'trending',
      },
      {
        type: 'recent',
        title: 'Recently Added',
        items: recent,
        mix: 'fresh',
      },
      {
        type: 'upcoming_releases',
        title: 'Upcoming Release Cards',
        items: movies.map((m) => ({ content_type: 'movie', ...m })),
        mix: 'editorial',
      },
    ],
    meta: {
      algorithm: 'explore_hybrid_v1',
      mix_ratio: { personalized: 0.5, trending: 0.3, fresh: 0.2 },
    },
  };
}

module.exports = { getExploreRecommendations };
