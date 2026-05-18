const fs = require('fs');
const path = require('path');
const { pool } = require('./db');

async function migrate() {
  const dir = path.join(__dirname, '../../migrations');
  const files = fs.readdirSync(dir).filter(f => f.endsWith('.sql')).sort();
  // Legacy v1 used _migrations(filename); v2 uses _migrations(name)
  const { rows: migCols } = await pool.query(`
    SELECT column_name FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = '_migrations'
  `);
  const colNames = migCols.map((r) => r.column_name);
  if (colNames.includes('filename') && !colNames.includes('name')) {
    console.log('🔄 Replacing legacy _migrations table');
    await pool.query('DROP TABLE _migrations');
  }
  await pool.query(`
    CREATE TABLE IF NOT EXISTS _migrations (
      name VARCHAR(255) PRIMARY KEY,
      applied_at TIMESTAMPTZ DEFAULT NOW()
    )
  `);
  for (const file of files) {
    const { rows } = await pool.query('SELECT 1 FROM _migrations WHERE name = $1', [file]);
    if (rows.length) continue;
    console.log(`🔄 Running migration: ${file}`);
    const sql = fs.readFileSync(path.join(dir, file), 'utf8');
    await pool.query(sql);
    await pool.query('INSERT INTO _migrations (name) VALUES ($1)', [file]);
    console.log(`✅ ${file} complete`);
  }
  console.log('✅ All migrations complete');
  await pool.end();
}

migrate().catch(err => {
  console.error('Migration failed:', err);
  process.exit(1);
});
