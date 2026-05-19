const { hoursSince } = require('./freshness');

function computeEngagement(item) {
  const views = item.view_count || 0;
  const saves = item.save_count || 0;
  const shares = item.share_count || 0;
  const reactions = (item.reaction_fire || 0) + (item.reaction_mass || 0)
    + (item.reaction_love || 0) + (item.reaction_wait || 0);
  const votes = item.total_votes || item.vote_count || 0;
  const downloads = item.download_count || 0;
  const reminders = item.reminder_count || 0;
  const followers = item.follower_count || 0;

  const raw = views * 0.01 + reactions * 0.02 + saves * 0.15 + shares * 0.2
    + votes * 0.03 + downloads * 0.12 + reminders * 0.25 + followers * 0.05;

  const ageH = hoursSince(item.published_at || item.created_at);
  const decay = 1 / (1 + ageH / 48);
  const normalized = Math.log1p(raw) / 8;
  return Math.min(1, normalized * decay);
}

module.exports = { computeEngagement };
