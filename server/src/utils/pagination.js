function parsePagination(query, defaultLimit = 20) {
  const page = Math.max(1, parseInt(query.page) || 1);
  const limit = Math.min(100, parseInt(query.limit) || defaultLimit);
  const offset = (page - 1) * limit;
  return { page, limit, offset };
}

function buildPaginatedResponse(rows, total, page, limit) {
  return {
    items: rows,
    pagination: {
      page,
      limit,
      total,
      total_pages: Math.ceil(total / limit),
      has_next: page * limit < total,
    },
  };
}

function respond(res, data, meta = {}) {
  res.json({
    success: true,
    data,
    meta: { timestamp: new Date().toISOString(), version: '1.0', ...meta },
  });
}

module.exports = { parsePagination, buildPaginatedResponse, respond };
