const Redis = require('ioredis');
const env = require('./env');

const redis = new Redis(env.REDIS_URL, {
  maxRetriesPerRequest: 3,
  retryStrategy: (times) => Math.min(times * 100, 3000),
  lazyConnect: false,
});

redis.on('error', (err) => {
  console.error('Redis error:', err.message);
});

redis.on('connect', () => {
  console.log('✅ Redis connected');
});

// Helper: get cached or compute and cache
async function getOrSet(key, ttlSeconds, computeFn) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const value = await computeFn();
  if (value !== null && value !== undefined) {
    await redis.setex(key, ttlSeconds, JSON.stringify(value));
  }
  return value;
}

// Helper: delete keys by pattern (use sparingly)
async function deletePattern(pattern) {
  let cursor = '0';
  do {
    const [nextCursor, keys] = await redis.scan(cursor, 'MATCH', pattern, 'COUNT', 100);
    cursor = nextCursor;
    if (keys.length > 0) {
      await redis.del(...keys);
    }
  } while (cursor !== '0');
}

module.exports = { redis, getOrSet, deletePattern };
