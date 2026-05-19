const { DIVERSITY } = require('./constants');
const { heroIdsOf } = require('./scoring/personal-affinity');

function applyDiversityRules(rankedItems, limit = 20) {
  const result = [];
  const heroStreak = {};
  const categoryCount = {};
  const movieCount = {};
  let lastHero = null;
  let streak = 0;
  let buzzCount = 0;
  const maxBuzz = Math.ceil(limit * DIVERSITY.max_buzz_ratio_top_feed);

  for (const item of rankedItems) {
    if (result.length >= limit) break;

    const heroes = [...heroIdsOf(item)];
    const heroKey = heroes[0] || 'none';
    const cat = item.category || item.content_type || 'other';
    const movieId = item.movie_id || item.movie?.id || 'none';

    if (heroKey === lastHero) {
      streak += 1;
      if (streak > DIVERSITY.max_consecutive_same_hero) continue;
    } else {
      lastHero = heroKey;
      streak = 1;
    }

    if (result.length < 10) {
      categoryCount[cat] = (categoryCount[cat] || 0) + 1;
      if (categoryCount[cat] > DIVERSITY.max_same_category_in_first_10) continue;

      movieCount[movieId] = (movieCount[movieId] || 0) + 1;
      if (movieCount[movieId] > DIVERSITY.max_same_movie_in_top_10) continue;
    }

    const trust = (item.trust_status || '').toLowerCase();
    if (trust === 'buzz') {
      if (buzzCount >= maxBuzz) continue;
      buzzCount += 1;
    }

    const diversityBonus = result.length > 0 && heroKey !== lastHero ? 0.03 : 0;
    item._diversityBonus = diversityBonus;
    result.push(item);
  }

  return result;
}

module.exports = { applyDiversityRules };
