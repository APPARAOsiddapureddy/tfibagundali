const { EDITORIAL_BOOST } = require('../constants');

function computeEditorial(item) {
  if (item.is_pinned) return 1.0;
  if (item.is_breaking || item.priority === 'breaking') return EDITORIAL_BOOST.breaking;
  if (item.is_trending || item.priority === 'trending') return EDITORIAL_BOOST.trending;
  if (item.priority === 'important') return EDITORIAL_BOOST.important;
  const es = Number(item.editorial_score) || 0;
  return Math.min(1, es);
}

module.exports = { computeEditorial };
