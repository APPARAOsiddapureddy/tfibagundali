const { loadUserContext } = require('./user-context');
const candidates = require('./candidates');
const { scorePoll } = require('./home-feed.service'); // eslint-disable-line import/no-cycle

async function getPollRecommendations(userId) {
  const ctx = await loadUserContext(userId);
  const polls = await candidates.fetchPolls(ctx, 20);
  const ranked = polls
    .map((p) => ({ ...p, _score: scorePoll(p, ctx), voted: false }))
    .sort((a, b) => b._score - a._score);

  const active = ranked.filter((p) => !ctx?.votedPollIds?.has(String(p.id)));
  const voted = ranked.filter((p) => ctx?.votedPollIds?.has(String(p.id)));

  return {
    sections: [
      { type: 'for_you', title: 'Recommended Polls', items: active.slice(0, 10) },
      { type: 'trending', title: 'Trending Polls', items: ranked.slice(0, 5) },
      ...(voted.length ? [{ type: 'voted', title: 'You Voted', items: voted.slice(0, 5) }] : []),
    ],
    meta: { algorithm: 'poll_hybrid_v1' },
  };
}

module.exports = { getPollRecommendations };
