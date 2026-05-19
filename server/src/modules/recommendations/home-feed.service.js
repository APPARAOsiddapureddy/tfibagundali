const db = require('../../config/db');
const { loadUserContext } = require('./user-context');
const { rankItems } = require('./scoring');
const { applyDiversityRules } = require('./diversity');
const { HOME_SECTIONS } = require('./constants');
const candidates = require('./candidates');
const { logImpressions } = require('./impressions.service');
const { scoreItem } = require('./scoring');
const { POLL_SCORE_WEIGHTS, ASSET_SCORE_WEIGHTS } = require('./constants');
const { computeFreshness } = require('./scoring/freshness');
const { computePersonalAffinity } = require('./scoring/personal-affinity');

function formatUpdateItem(item) {
  return {
    content_type: 'update',
    id: item.id,
    title: item.title,
    summary: item.summary,
    category: item.category,
    trust_status: item.trust_status,
    hero: item.hero,
    movie: item.movie,
    image_url: item.image_url,
    priority: item.priority,
    is_breaking: item.is_breaking,
    is_trending: item.is_trending,
    reactions: {
      fire: item.reaction_fire,
      mass: item.reaction_mass,
      love: item.reaction_love,
      wait: item.reaction_wait,
    },
    published_at: item.published_at,
    score: item._score,
    reason: item._reason,
  };
}

function buildColdStartSections(ctx, rankedUpdates, movies, polls, assets, quiz) {
  const officialFirst = rankedUpdates.filter((u) => ['official', 'verified'].includes(u.trust_status));
  const todayItems = officialFirst.slice(0, 5).length ? officialFirst.slice(0, 5) : rankedUpdates.slice(0, 5);
  const breaking = rankedUpdates.filter(
    (u) => u.is_breaking || u.priority === 'breaking' || ['official', 'verified'].includes(u.trust_status)
  ).slice(0, 5);

  return assembleSections(ctx, {
    today: todayItems,
    breaking,
    trending: rankedUpdates.filter((u) => u.is_trending).slice(0, 6).length
      ? rankedUpdates.filter((u) => u.is_trending).slice(0, 6)
      : rankedUpdates.slice(0, 6),
    hero: [],
    movies,
    polls,
    assets,
    quiz,
    calendar: movies,
  });
}

function buildPersonalizedSections(ctx, rankedUpdates, movies, polls, assets, quiz) {
  const favId = ctx?.favouriteHeroId;
  const heroUpdates = favId
    ? rankedUpdates.filter((u) => String(u.hero_id) === String(favId)).slice(0, 5)
    : [];

  const officialBreaking = rankedUpdates.filter(
    (u) => u.is_breaking && ['official', 'verified'].includes(u.trust_status)
  );

  const today = [...officialBreaking, ...rankedUpdates]
    .filter((v, i, a) => a.findIndex((x) => x.id === v.id) === i)
    .slice(0, 5);

  const breaking = rankedUpdates.filter((u) => u.is_breaking || u.priority === 'breaking').slice(0, 5);

  return assembleSections(ctx, {
    today,
    breaking,
    trending: rankedUpdates.filter((u) => u.is_trending || u._score > 0.65).slice(0, 6),
    hero: heroUpdates,
    movies,
    polls,
    assets,
    quiz,
    calendar: movies,
  });
}

function assembleSections(ctx, pools) {
  const sections = [];
  const hasHero = !!ctx?.favouriteHeroId;

  for (const def of HOME_SECTIONS) {
    if (def.type === 'my_hero_updates' && !hasHero) continue;
    if (def.type === 'my_hero_updates' && !pools.hero?.length) continue;

    let items = [];
    switch (def.type) {
      case 'today_in_tfi':
        items = pools.today;
        break;
      case 'breaking_updates':
        items = pools.breaking;
        break;
      case 'trending_updates':
        items = pools.trending;
        break;
      case 'my_hero_updates':
        items = pools.hero;
        break;
      case 'upcoming_releases':
        items = pools.movies;
        break;
      case 'quiz_preview':
        items = quizPreviewItems(pools.quiz);
        break;
      case 'poll_preview':
        items = pools.polls;
        break;
      case 'explore_preview':
        items = pools.assets;
        break;
      case 'movie_calendar':
        items = pools.calendar || pools.movies;
        break;
      default:
        break;
    }

    if (!items?.length) continue;
    sections.push({
      type: def.type,
      title: def.title,
      subtitle: def.subtitle || null,
      items: items.slice(0, def.limit).map(formatSectionItem),
    });
  }

  return sections;
}

function formatSectionItem(item) {
  if (item.content_type === 'update') return formatUpdateItem(item);
  if (item.content_type === 'movie') {
    const days = item.release_date
      ? Math.max(0, Math.ceil((new Date(item.release_date) - new Date()) / 86400000))
      : null;
    return {
      content_type: 'movie',
      id: item.id,
      title: item.title,
      title_telugu: item.title_telugu,
      hero_name: item.hero_name,
      icon_emoji: item.icon_emoji,
      release_date: item.release_date,
      days_to_release: days,
      score: item._score,
      reason: item._reason,
    };
  }
  if (item.content_type === 'poll') {
    return {
      content_type: 'poll',
      id: item.id,
      question: item.question,
      poll_type: item.poll_type,
      options: item.options,
      ends_at: item.ends_at,
      total_votes: item.total_votes,
      score: item._score,
      reason: item._reason,
    };
  }
  if (item.content_type === 'wallpaper' || item.content_type === 'status_card') {
    return {
      content_type: item.content_type,
      id: item.id,
      title: item.title,
      category: item.category,
      image_url: item.image_url,
      score: item._score,
      reason: item._reason,
    };
  }
  if (item.content_type === 'quiz_category') {
    return {
      content_type: 'quiz_category',
      id: item.id,
      title: item.title,
      difficulty: item.difficulty,
    };
  }
  return item;
}

function quizPreviewItems(quiz) {
  if (!quiz) return [];
  const items = [];
  if (quiz.daily) {
    items.push({
      content_type: 'quiz_daily',
      id: quiz.daily.quiz_date,
      title: "Today's TFI Trivia",
      quiz_date: quiz.daily.quiz_date,
    });
  }
  return [...items, ...(quiz.categories || []).slice(0, 2)];
}

function scorePoll(poll, ctx) {
  const personal = computePersonalAffinity(poll, ctx);
  const freshness = poll.ends_at
    ? Math.max(0, 1 - (new Date(poll.ends_at) - Date.now()) / (7 * 86400000))
    : 0.5;
  const trending = Math.min(1, (poll.trending_score || poll.total_votes || 0) / 5000);
  const timeLeft = poll.ends_at && new Date(poll.ends_at) > new Date()
    ? Math.min(1, 1 / (1 + (new Date(poll.ends_at) - Date.now()) / 86400000))
    : 0;
  const w = POLL_SCORE_WEIGHTS;
  return personal * w.personal + freshness * w.active_freshness + trending * w.trending + timeLeft * w.time_left + 0.1;
}

function scoreAsset(asset, ctx) {
  const personal = computePersonalAffinity(asset, ctx);
  const freshness = computeFreshness(asset);
  const pop = Math.min(1, (asset.download_count || 0) / 500);
  const w = ASSET_SCORE_WEIGHTS;
  return personal * w.personal + freshness * w.freshness + pop * w.popularity + 0.1;
}

async function getHomeFeed(userId) {
  const ctx = await loadUserContext(userId);
  let displayName = 'Fan';
  if (userId) {
    const { rows } = await db.query('SELECT display_name FROM users WHERE id = $1', [userId]);
    displayName = rows[0]?.display_name || 'Fan';
  }

  const updateCandidates = await candidates.generateUpdateCandidates(ctx);
  let rankedUpdates = rankItems(updateCandidates, ctx);
  rankedUpdates = applyDiversityRules(rankedUpdates, 30);

  const movies = rankItems(await candidates.fetchMovies(12), ctx).slice(0, 8);
  const pollPool = await candidates.fetchPolls(ctx, 10);
  const polls = pollPool
    .map((p) => ({ ...p, _score: scorePoll(p, ctx) }))
    .sort((a, b) => b._score - a._score)
    .slice(0, 2);

  const assets = (await candidates.fetchWallpapersAndCards(ctx, 12))
    .map((a) => ({ ...a, _score: scoreAsset(a, ctx) }))
    .sort((a, b) => b._score - a._score)
    .slice(0, 8);

  const quiz = await candidates.fetchQuizPreviews(ctx);

  const sections = ctx?.favouriteHeroId || ctx?.followedHeroIds?.length
    ? buildPersonalizedSections(ctx, rankedUpdates, movies, polls, assets, quiz)
    : buildColdStartSections(ctx, rankedUpdates, movies, polls, assets, quiz);

  if (userId) {
    for (const section of sections) {
      logImpressions(userId, section.type, section.items).catch(() => {});
    }
  }

  return {
    greeting: {
      display_name: displayName,
      tagline: 'Eeroju TFI lo em jarigindhi?',
      personalized: !!(ctx?.favouriteHeroId || ctx?.followedMovieIds?.length),
    },
    sections,
    meta: {
      algorithm: 'hybrid_v1',
      cold_start: !ctx?.favouriteHeroId && !ctx?.followedHeroIds?.length,
    },
  };
}

async function getUpdatesFeed(userId, { limit = 20, offset = 0 } = {}) {
  const ctx = await loadUserContext(userId);
  const updateCandidates = await candidates.generateUpdateCandidates(ctx);
  const ranked = applyDiversityRules(rankItems(updateCandidates, ctx), limit + offset);
  return {
    items: ranked.slice(offset, offset + limit).map(formatUpdateItem),
    total: ranked.length,
  };
}

module.exports = { getHomeFeed, getUpdatesFeed, scorePoll, scoreAsset };
