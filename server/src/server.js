require('dotenv').config();
const http = require('http');
const app = require('./app');
const env = require('./config/env');
const { pool } = require('./config/db');
const { redis } = require('./config/redis');
const { startWorker } = require('./jobs/worker');

const server = http.createServer(app);

async function start() {
  try {
    // Verify DB connection
    await pool.query('SELECT 1');
    console.log('✅ PostgreSQL connected');

    // Verify Redis
    await redis.ping();
    console.log('✅ Redis connected');

    // Start background jobs
    if (env.NODE_ENV !== 'test') {
      await startWorker();
      console.log('✅ Background jobs started');
    }

    server.listen(env.PORT, () => {
      console.log(`🚀 TFI Bagundali API running on port ${env.PORT} [${env.NODE_ENV}]`);
    });
  } catch (err) {
    console.error('❌ Failed to start server:', err);
    process.exit(1);
  }
}

// Graceful shutdown
async function shutdown(signal) {
  console.log(`\n${signal} received — shutting down gracefully`);
  server.close(async () => {
    await pool.end();
    await redis.quit();
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10000);
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('unhandledRejection', (reason) => {
  console.error('Unhandled rejection:', reason);
});

start();
