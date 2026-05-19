const { TRUST_SCORES } = require('../constants');

function computeTrust(item) {
  const status = (item.trust_status || item.status || 'buzz').toLowerCase();
  return TRUST_SCORES[status] ?? TRUST_SCORES.buzz;
}

function lowTrustPenalty(item) {
  const t = computeTrust(item);
  if (t >= TRUST_SCORES.media_report) return 0;
  const ageDays = item.published_at
    ? (Date.now() - new Date(item.published_at).getTime()) / 86400000
    : 30;
  if (ageDays > 3) return 0.25;
  if (ageDays > 1) return 0.12;
  return 0.05;
}

module.exports = { computeTrust, lowTrustPenalty };
