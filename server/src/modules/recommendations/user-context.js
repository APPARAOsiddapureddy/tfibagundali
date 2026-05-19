const db = require('../../config/db');

async function loadUserContext(userId) {
  if (!userId) return null;

  const { rows: users } = await db.query(
    `SELECT favourite_hero_id, language_preference, notification_preferences FROM users WHERE id = $1`,
    [userId]
  );
  const user = users[0] || {};

  const { rows: heroFollows } = await db.query(
    'SELECT hero_id FROM hero_follows WHERE user_id = $1',
    [userId]
  );
  const { rows: movieFollows } = await db.query(
    'SELECT movie_id FROM movie_follows WHERE user_id = $1',
    [userId]
  );
  const { rows: bookmarks } = await db.query(
    `SELECT item_type, item_id FROM bookmarks WHERE user_id = $1`,
    [userId]
  );
  const { rows: pollVotes } = await db.query(
    'SELECT poll_id FROM poll_votes WHERE user_id = $1',
    [userId]
  );
  const { rows: hidden } = await db.query(
    'SELECT content_type, content_id FROM hidden_content WHERE user_id = $1',
    [userId]
  );
  const { rows: notInterested } = await db.query(
    'SELECT content_type, content_id FROM not_interested WHERE user_id = $1',
    [userId]
  );
  const { rows: views } = await db.query(
    'SELECT content_type, content_id, view_count FROM user_content_views WHERE user_id = $1',
    [userId]
  );
  const { rows: profiles } = await db.query(
    'SELECT * FROM user_interest_profiles WHERE user_id = $1',
    [userId]
  );

  const { rows: reminders } = await db.query(
    `SELECT related_id, reminder_type FROM reminders WHERE user_id = $1`,
    [userId]
  );

  const { rows: downloaded } = await db.query(
    `SELECT content_id FROM recommendation_events
     WHERE user_id = $1 AND event_name IN ('wallpaper_downloaded','status_card_downloaded')
     AND created_at > NOW() - INTERVAL '90 days'`,
    [userId]
  );

  const viewCounts = {};
  const consumed = new Set();
  for (const v of views) {
    const key = `${v.content_type}:${v.content_id}`;
    viewCounts[key] = v.view_count;
    if (v.view_count >= 2) consumed.add(key);
  }

  const hiddenSet = new Set(hidden.map((h) => `${h.content_type}:${h.content_id}`));
  const notInterestedSet = new Set(notInterested.map((n) => `${n.content_type}:${n.content_id}`));

  const savedMovieIds = bookmarks.filter((b) => b.item_type === 'movie').map((b) => b.item_id);
  const savedHeroIds = bookmarks.filter((b) => b.item_type === 'hero').map((b) => b.item_id);

  let interestProfile = profiles[0] || null;
  if (!interestProfile) {
    await db.query(
      `INSERT INTO user_interest_profiles (user_id, favourite_hero_id, followed_hero_ids, followed_movie_ids)
       VALUES ($1, $2, $3, $4) ON CONFLICT (user_id) DO NOTHING`,
      [
        userId,
        user.favourite_hero_id,
        heroFollows.map((h) => h.hero_id),
        movieFollows.map((m) => m.movie_id),
      ]
    );
    interestProfile = {
      hero_scores: {},
      movie_scores: {},
      category_scores: {},
      session_boosts: {},
    };
  }

  return {
    userId,
    favouriteHeroId: user.favourite_hero_id,
    followedHeroIds: heroFollows.map((h) => h.hero_id),
    followedMovieIds: movieFollows.map((m) => m.movie_id),
    savedMovieIds,
    savedHeroIds,
    reminderMovieIds: reminders.filter((r) => r.reminder_type?.includes('movie')).map((r) => r.related_id),
    votedPollIds: new Set(pollVotes.map((p) => String(p.poll_id))),
    downloadedWallpaperIds: new Set(downloaded.map((d) => String(d.content_id))),
    hidden: hiddenSet,
    notInterested: notInterestedSet,
    viewCounts,
    consumed,
    interestProfile,
    sessionBoosts: interestProfile.session_boosts || {},
    languagePreference: user.language_preference || 'mixed',
    notificationPreferences: user.notification_preferences || {},
  };
}

module.exports = { loadUserContext };
