/**
 * Drops all tables and recreates public schema (dev only).
 * Use when migrating from v1 schema or after a failed migration.
 */
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const { pool } = require('../src/config/db');

async function reset() {
  if (process.env.NODE_ENV === 'production') {
    console.error('Refusing to reset database in production.');
    process.exit(1);
  }
  console.log('⚠️  Resetting database (DROP SCHEMA public CASCADE)...');
  await pool.query('DROP SCHEMA public CASCADE');
  await pool.query('CREATE SCHEMA public');
  await pool.query('GRANT ALL ON SCHEMA public TO public');
  console.log('✅ Database reset complete. Run: npm run migrate && npm run seed');
  await pool.end();
}

reset().catch((err) => {
  console.error('Reset failed:', err.message);
  process.exit(1);
});
