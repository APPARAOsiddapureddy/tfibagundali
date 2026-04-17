const db = require('../../config/db');

async function getBalance(userId) {
  const { rows } = await db.query(
    `SELECT balance FROM user_coin_balances WHERE user_id = $1`,
    [userId]
  );
  return rows[0]?.balance ?? 0;
}

async function addLedgerEntry(client, userId, amount, type, referenceId, note) {
  const currentBalance = await (client || db).query(
    `SELECT balance FROM user_coin_balances WHERE user_id = $1 FOR UPDATE`,
    [userId]
  ).then(r => r.rows[0]?.balance ?? 0);

  const newBalance = currentBalance + amount;
  if (newBalance < 0) throw new Error('Insufficient coins');

  await (client || db).query(
    `INSERT INTO coin_ledger (user_id, amount, balance_after, type, reference_id, note)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [userId, amount, newBalance, type, referenceId, note]
  );

  await (client || db).query(
    `INSERT INTO user_coin_balances (user_id, balance, updated_at)
     VALUES ($1, $2, NOW())
     ON CONFLICT (user_id) DO UPDATE SET balance = $2, updated_at = NOW()`,
    [userId, newBalance]
  );

  return newBalance;
}

async function getHistory(userId, limit, offset) {
  const { rows } = await db.query(
    `SELECT id, amount, balance_after, type, reference_id, note, created_at
     FROM coin_ledger WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );
  const { rows: countRows } = await db.query(
    `SELECT COUNT(*)::int as total FROM coin_ledger WHERE user_id = $1`, [userId]
  );
  return { rows, total: countRows[0].total };
}

async function getRedemptions() {
  return [
    { id: 'wallpaper_pack', name: 'Hero Wallpaper Pack (5 images)', cost: 50, type: 'content' },
    { id: 'dialogue_card', name: 'Premium Dialogue Card (no watermark)', cost: 20, type: 'content' },
    { id: 'premium_discount', name: '₹20 off Premium Subscription', cost: 200, type: 'discount' },
    { id: 'badge_upgrade', name: 'Fan Army Badge Upgrade (Silver → Gold)', cost: 100, type: 'badge' },
  ];
}

module.exports = { getBalance, addLedgerEntry, getHistory, getRedemptions };
