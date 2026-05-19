const { SCORE_WEIGHTS } = require('../constants');
const { computeFreshness } = require('./freshness');
const { computeTrust, lowTrustPenalty } = require('./trust');
const { computeEngagement } = require('./engagement');
const { computePersonalAffinity, negativeAffinityPenalty } = require('./personal-affinity');
const { computeEditorial } = require('./editorial');
const { computeActionability } = require('./actionability');

function computeNovelty(item, ctx) {
  if (!ctx) return 0.7;
  const key = `${item.content_type}:${item.id}`;
  if (!ctx.viewCounts?.[key] && !ctx.consumed?.has(key)) return 1.0;
  const views = ctx.viewCounts?.[key] || 0;
  if (views === 1) return 0.6;
  if (views === 2) return 0.35;
  return 0.1;
}

function expiredPenalty(item) {
  if (item.expires_at && new Date(item.expires_at) < new Date()) return 0.5;
  if (item.ends_at && new Date(item.ends_at) < new Date()) return 0.4;
  return 0;
}

function buildReason(item, breakdown, ctx) {
  if (breakdown.editorial >= 0.8) return 'Breaking in TFI';
  if (breakdown.trust >= 0.95) return 'Official update';
  if (breakdown.personal_affinity >= 0.6 && ctx?.favouriteHeroId) {
    return 'Because you follow this hero';
  }
  if (breakdown.engagement >= 0.7) return 'Trending in TFI';
  if (breakdown.freshness >= 0.85) return 'Just published';
  return null;
}

function scoreItem(item, ctx, options = {}) {
  const freshness = item.freshness_score ?? computeFreshness(item);
  const trust = item.trust_score ?? computeTrust(item);
  const engagement = item.engagement_score ?? computeEngagement(item);
  const personal = computePersonalAffinity(item, ctx);
  const editorial = computeEditorial(item);
  const actionability = computeActionability(item);
  const novelty = computeNovelty(item, ctx);

  const repetition = (ctx?.viewCounts?.[`${item.content_type}:${item.id}`] || 0) >= 4 ? 0.2 : 0;
  const consumed = ctx?.consumed?.has(`${item.content_type}:${item.id}`) ? 0.25 : 0;
  const lowTrust = lowTrustPenalty(item);
  const expired = expiredPenalty(item);
  const negative = negativeAffinityPenalty(item, ctx);

  const breakdown = {
    freshness,
    personal_affinity: personal,
    trust,
    engagement: typeof engagement === 'number' && engagement > 1 ? engagement / 10 : engagement,
    editorial_priority: editorial,
    actionability,
    novelty,
    diversity_bonus: options.diversityBonus || 0,
    repetition_penalty: repetition,
    consumed_penalty: consumed,
    low_trust_penalty: lowTrust,
    expired_penalty: expired,
    negative_penalty: negative,
  };

  const w = SCORE_WEIGHTS;
  let finalScore =
    breakdown.freshness * w.freshness +
    breakdown.personal_affinity * w.personal_affinity +
    breakdown.trust * w.trust +
    breakdown.engagement * w.engagement +
    breakdown.editorial_priority * w.editorial_priority +
    breakdown.actionability * w.actionability +
    breakdown.novelty * w.novelty +
    breakdown.diversity_bonus * w.diversity_bonus -
    breakdown.repetition_penalty -
    breakdown.consumed_penalty -
    breakdown.low_trust_penalty -
    breakdown.expired_penalty -
    breakdown.negative_penalty;

  finalScore = Math.max(0, Math.min(1, finalScore));
  const reason = buildReason(item, breakdown, ctx);

  return { finalScore, breakdown, reason };
}

function rankItems(items, ctx, options = {}) {
  const scored = items.map((item) => {
    const { finalScore, breakdown, reason } = scoreItem(item, ctx, options);
    return { ...item, _score: finalScore, _breakdown: breakdown, _reason: reason };
  });
  scored.sort((a, b) => b._score - a._score);
  return scored;
}

module.exports = { scoreItem, rankItems, computeFreshness, computeTrust, computeEngagement };
