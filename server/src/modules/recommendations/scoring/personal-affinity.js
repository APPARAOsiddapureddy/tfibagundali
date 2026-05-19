const { AFFINITY_WEIGHTS } = require('../constants');

function heroIdsOf(item) {
  const ids = new Set();
  if (item.hero_id) ids.add(String(item.hero_id));
  if (item.hero_ids) item.hero_ids.forEach((id) => ids.add(String(id)));
  if (item.hero?.id) ids.add(String(item.hero.id));
  return ids;
}

function movieIdsOf(item) {
  const ids = new Set();
  if (item.movie_id) ids.add(String(item.movie_id));
  if (item.movie_ids) item.movie_ids.forEach((id) => ids.add(String(id)));
  if (item.movie?.id) ids.add(String(item.movie.id));
  return ids;
}

function computePersonalAffinity(item, ctx) {
  if (!ctx) return 0.2;

  let score = 0.1;
  const heroes = heroIdsOf(item);
  const movies = movieIdsOf(item);
  const cat = item.category || '';

  if (ctx.favouriteHeroId && heroes.has(String(ctx.favouriteHeroId))) {
    score += AFFINITY_WEIGHTS.favourite_hero;
  }

  for (const h of ctx.followedHeroIds || []) {
    if (heroes.has(String(h))) {
      score += AFFINITY_WEIGHTS.followed_hero;
      break;
    }
  }

  for (const m of ctx.followedMovieIds || []) {
    if (movies.has(String(m))) {
      score += AFFINITY_WEIGHTS.followed_movie;
      break;
    }
  }

  for (const m of ctx.savedMovieIds || []) {
    if (movies.has(String(m))) score += AFFINITY_WEIGHTS.saved_related * 0.5;
  }

  for (const h of ctx.savedHeroIds || []) {
    if (heroes.has(String(h))) score += AFFINITY_WEIGHTS.saved_related * 0.5;
  }

  if (ctx.reminderMovieIds) {
    for (const m of ctx.reminderMovieIds) {
      if (movies.has(String(m))) {
        score += AFFINITY_WEIGHTS.reminder_set;
        break;
      }
    }
  }

  const heroScores = ctx.interestProfile?.hero_scores || {};
  for (const hid of heroes) {
    const hs = heroScores[hid];
    if (hs > 0) score += Math.min(0.25, hs / 100);
  }

  const catScores = ctx.interestProfile?.category_scores || {};
  if (cat && catScores[cat]) score += Math.min(0.2, catScores[cat] / 80);

  if (ctx.sessionBoosts) {
    for (const m of movies) {
      if (ctx.sessionBoosts[`movie:${m}`]) score += Math.min(0.2, ctx.sessionBoosts[`movie:${m}`]);
    }
    for (const h of heroes) {
      if (ctx.sessionBoosts[`hero:${h}`]) score += Math.min(0.2, ctx.sessionBoosts[`hero:${h}`]);
    }
  }

  return Math.min(1, score);
}

function negativeAffinityPenalty(item, ctx) {
  if (!ctx) return 0;
  const key = `${item.content_type}:${item.id}`;
  if (ctx.notInterested?.has(key)) return 1.0;
  if (ctx.hidden?.has(key)) return 0.6;

  const views = ctx.viewCounts?.[key] || 0;
  if (views >= 3) return 0.35;
  if (views >= 1) return 0.15;

  if (ctx.consumed?.has(key)) return 0.5;
  if (item.content_type === 'poll' && ctx.votedPollIds?.has(String(item.id))) return 0.7;
  if (item.content_type === 'wallpaper' && ctx.downloadedWallpaperIds?.has(String(item.id))) return 0.4;

  return 0;
}

module.exports = { computePersonalAffinity, negativeAffinityPenalty, heroIdsOf, movieIdsOf };
