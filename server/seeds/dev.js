require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const { pool } = require('../src/config/db');

const HEROES = [
  { name: 'Pawan Kalyan', telugu_name: 'పవన్ కళ్యాణ్', icon_emoji: '⚡', sort_order: 1, aliases: ['PSPK', 'Power Star'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/The_portrait_of_Pawan_Kalyan_(2024).jpg?width=512' },
  { name: 'Mahesh Babu', telugu_name: 'మహేష్ బాబు', icon_emoji: '👑', sort_order: 2, aliases: ['Super Star'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Mahesh_Babu_in_Spyder_(cropped).jpg?width=512' },
  { name: 'Allu Arjun', telugu_name: 'అల్లు అర్జున్', icon_emoji: '🔥', sort_order: 3, aliases: ['Bunny', 'Icon Star'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Allu_Arjun_at_Pushpa_2_The_Rule_meet.jpg?width=512' },
  { name: 'Ram Charan', telugu_name: 'రామ్ చరణ్', icon_emoji: '⚡', sort_order: 4, aliases: ['Mega Power Star'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Ram_Charan_2024_(cropped).jpg?width=512' },
  { name: 'Jr NTR', telugu_name: 'జూనియర్ ఎన్టీఆర్', icon_emoji: '🐯', sort_order: 5, aliases: ['Jr. NTR', 'NTR Jr', 'N. T. Rama Rao Jr'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/N.T.Rama_Rao_Jr._at_the_RRR_Press_Meet_in_Chennai.jpg?width=512' },
  { name: 'Prabhas', telugu_name: 'ప్రభాస్', icon_emoji: '🦁', sort_order: 6, aliases: ['Darling'], avatar_url: 'https://upload.wikimedia.org/wikipedia/commons/a/ad/Prabhas_at_Saaho_Pre_release_event_%28cropped%29.jpg' },
  { name: 'Balakrishna', telugu_name: 'బాలకృష్ణ', icon_emoji: '💥', sort_order: 7, aliases: ['Nandamuri Balakrishna', 'Balayya', 'NBK'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Padma_Bhushan_Award_to_Shri_Nandamuri_Balakrishna_at_the_Rashtrapati_Bhavan_(cropped).jpg?width=512' },
  { name: 'Chiranjeevi', telugu_name: 'చిరంజీవి', icon_emoji: '🌟', sort_order: 8, aliases: ['Mega Star'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Chiranjeevi_at_ANR_Awards_2024_(cropped).jpg?width=512' },
  { name: 'Nani', telugu_name: 'నాని', icon_emoji: '🌿', sort_order: 9, aliases: ['Natural Star'], avatar_url: 'https://upload.wikimedia.org/wikipedia/commons/d/dc/Nani_%28cropped%29.png' },
  { name: 'Vijay Deverakonda', telugu_name: 'విజయ్ దేవరకొండ', icon_emoji: '🕶️', sort_order: 10, aliases: ['Vijay Devarakonda', 'VD', 'Rowdy'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Vijay_Deverakonda_at_NOTA_pressmeet_(cropped).jpg?width=512' },
  { name: 'Ravi Teja', telugu_name: 'రవితేజ', icon_emoji: '⚡', sort_order: 11, aliases: ['Mass Maharaja'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Ravi_Teja_in_Dhamaka_promotions_2022_(cropped).png?width=512' },
  { name: 'Nagarjuna', telugu_name: 'నాగార్జున', icon_emoji: '💎', sort_order: 12, aliases: ['Akkineni Nagarjuna', 'King'], avatar_url: 'https://upload.wikimedia.org/wikipedia/commons/e/e1/Nagarjuna_Akkineni_at_ANR_Awards.jpg' },
  { name: 'Venkatesh', telugu_name: 'వెంకటేష్', icon_emoji: '🏆', sort_order: 13, aliases: ['Daggubati Venkatesh', 'Victory Venkatesh', 'Venky'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Daggubati_Venkatesh_(cropped).jpg?width=512' },
  { name: 'Naga Chaitanya', telugu_name: 'నాగ చైతన్య', icon_emoji: '✨', sort_order: 14, aliases: ['Chay'], avatar_url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Naga_Chaitanya_(cropped).jpg?width=512' },
];

const normalizeHeroName = (name) => name.toLowerCase().replace(/[^a-z0-9]+/g, '');

async function seed() {
  console.log('🌱 Seeding TFI Bagundali v2...');
  const heroMap = {};

  for (const h of HEROES) {
    const keys = [h.name, ...h.aliases].map(normalizeHeroName);
    let { rows } = await pool.query(
      `SELECT id, name FROM heroes
       WHERE regexp_replace(lower(name), '[^a-z0-9]+', '', 'g') = ANY($1::text[])
       ORDER BY sort_order, created_at
       LIMIT 1`,
      [keys]
    );
    if (rows[0]) {
      rows = (await pool.query(
        `UPDATE heroes
         SET name = $2, telugu_name = $3, icon_emoji = $4, sort_order = $5,
             bio = $6, aliases = $7::jsonb, avatar_url = $8, is_active = TRUE, updated_at = NOW()
         WHERE id = $1
         RETURNING id, name`,
        [rows[0].id, h.name, h.telugu_name, h.icon_emoji, h.sort_order, `${h.name} — Telugu cinema icon.`, JSON.stringify(h.aliases), h.avatar_url]
      )).rows;
    } else {
      rows = (await pool.query(
        `INSERT INTO heroes (name, telugu_name, icon_emoji, sort_order, bio, aliases, avatar_url)
         VALUES ($1,$2,$3,$4,$5,$6::jsonb,$7)
         RETURNING id, name`,
        [h.name, h.telugu_name, h.icon_emoji, h.sort_order, `${h.name} — Telugu cinema icon.`, JSON.stringify(h.aliases), h.avatar_url]
      )).rows;
    }
    if (rows[0]) heroMap[h.name] = rows[0].id;
  }
  if (!Object.keys(heroMap).length) {
    const { rows } = await pool.query('SELECT id, name FROM heroes');
    rows.forEach(r => { heroMap[r.name] = r.id; });
  }

  const rcId = heroMap['Ram Charan'];
  const pkId = heroMap['Pawan Kalyan'];
  const aaId = heroMap['Allu Arjun'];
  const ntrId = heroMap['Jr NTR'];
  const prabhasId = heroMap['Prabhas'];

  const { rows: peddiRows } = await pool.query(
    `INSERT INTO movies (title, title_telugu, hero_id, director, genre, release_date, status, synopsis)
     VALUES ('Peddi','పెద్ది',$1,'Buchi Babu Sana','Action Drama','2026-06-04','upcoming',
     'Ram Charan''s Peddi is set for a grand theatrical release.')
     ON CONFLICT DO NOTHING RETURNING id`,
    [rcId]
  );
  const peddiId = peddiRows[0]?.id;

  await pool.query(
    `INSERT INTO movies (title, title_telugu, hero_id, director, genre, release_date, status) VALUES
     ('Devara 2','దేవర 2',$1,'Koratala Siva','Mass','2026-05-03','upcoming'),
     ('Pushpa 3','పుష్ప 3',$2,'Sukumar','Mass Action','2026-08-15','upcoming'),
     ('Spirit','స్పిరిట్',$3,'Sandeep Reddy Vanga','Action','2026-09-01','upcoming')
     ON CONFLICT DO NOTHING`,
    [ntrId, aaId, prabhasId]
  );

  if (peddiId) {
    const timeline = [
      ['Movie announced', 'done', 1],
      ['Launch event completed', 'done', 2],
      ['Shooting started', 'done', 3],
      ['First look released', 'done', 4],
      ['Release date announced', 'current', 5],
      ['Trailer coming soon', 'pending', 6],
      ['Pre-release event', 'pending', 7],
      ['Release day', 'pending', 8],
    ];
    for (const [label, status, order] of timeline) {
      await pool.query(
        `INSERT INTO movie_timeline (movie_id, label, status, sort_order) VALUES ($1,$2,$3,$4) ON CONFLICT DO NOTHING`,
        [peddiId, label, status, order]
      );
    }
  }

  await pool.query(
    `INSERT INTO tfi_updates (title, summary, body, category, trust_status, hero_id, movie_id, priority, is_breaking, is_trending, reaction_fire, reaction_mass, reaction_love, reaction_wait, published_at) VALUES
     ('Peddi locks June 4 release 🔥',
      'Ram Charan''s Peddi is set for a grand theatrical release. Fans are already marking their calendars.',
      'Official announcement confirms June 4 theatrical release for Peddi.',
      'release', 'official', $1, $2, 'breaking', TRUE, TRUE, 12400, 8100, 5600, 4700, NOW() - INTERVAL '2 hours'),
     ('Big trailer launch event expected soon',
      'Fans are waiting for an official announcement on the trailer drop.',
      'Industry buzz around a major trailer event this week.',
      'trailer', 'media_report', $1, $2, 'trending', FALSE, TRUE, 4800, 3200, 2100, 1800, NOW() - INTERVAL '1 hour'),
     ('First single dropping this Friday',
      'Music lovers are excited for the first single from the upcoming album.',
      NULL, 'song', 'verified', $3, NULL, 'normal', FALSE, TRUE, 3200, 2100, 1500, 900, NOW() - INTERVAL '4 hours'),
     ('New hero-director combo creating buzz',
      'A fresh collaboration is trending across fan circles.',
      NULL, 'collab', 'buzz', $4, NULL, 'normal', FALSE, TRUE, 2100, 1800, 900, 1200, NOW() - INTERVAL '6 hours')
     ON CONFLICT DO NOTHING`,
    [rcId, peddiId, aaId, pkId]
  );

  const questions = [
    ['"Taggede Le" dialogue ye movie lo undi?', 'డైలాగ్ ఏ మూవీలో?', 'dialogue', 'easy', 'Pushpa', 'Arya', 'Julayi', 'Race Gurram', 'a'],
    ['RRR release year enti?', 'RRR రిలీజ్ ఇయర్?', 'release_year', 'easy', '2020', '2021', '2022', '2023', 'c'],
    ['Pushpa lo hero enti?', 'పుష్పలో హీరో?', 'movie', 'easy', 'Mahesh', 'Allu Arjun', 'NTR', 'Prabhas', 'b'],
  ];
  const qIds = [];
  for (const q of questions) {
    const { rows } = await pool.query(
      `INSERT INTO quiz_questions (question_text, question_telugu, type, difficulty, option_a, option_b, option_c, option_d, correct_option)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING id`,
      q
    );
    if (rows[0]) qIds.push(rows[0].id);
  }
  const today = new Date().toLocaleDateString('sv-SE', { timeZone: 'Asia/Kolkata' });
  if (qIds.length) {
    await pool.query(
      `INSERT INTO daily_quiz_sets (quiz_date, question_ids) VALUES ($1, $2)
       ON CONFLICT (quiz_date) DO NOTHING`,
      [today, qIds]
    );
  }

  await pool.query(
    `INSERT INTO polls (question, poll_type, options, ends_at, movie_id) VALUES
     ('Most awaited upcoming movie this month?', 'normal',
      '[{"id":"a","label":"Peddi","vote_count":4200},{"id":"b","label":"Devara 2","vote_count":3100},{"id":"c","label":"Pushpa 3","vote_count":2800},{"id":"d","label":"Spirit","vote_count":1900}]'::jsonb,
      NOW() + INTERVAL '7 days', $1),
     ('One word for Peddi update?', 'word',
      '[{"id":"a","label":"Mass","vote_count":1200},{"id":"b","label":"Fire","vote_count":980},{"id":"c","label":"Goosebumps","vote_count":760},{"id":"d","label":"Waiting","vote_count":540}]'::jsonb,
      NOW() + INTERVAL '3 days', $1),
     ('How hyped are you for the Peddi trailer?', 'reaction',
      '[{"id":"excited","label":"Very excited","vote_count":800},{"id":"mass","label":"Mass hype","vote_count":650},{"id":"love","label":"Loved the glimpse","vote_count":420},{"id":"waiting","label":"Waiting for more","vote_count":300}]'::jsonb,
      NOW() + INTERVAL '5 days', $1),
     ('Will Peddi cross 200Cr opening weekend? (fan opinion only)', 'prediction',
      '[{"id":"yes","label":"Yes — mass opening","vote_count":900},{"id":"maybe","label":"Maybe","vote_count":600},{"id":"no","label":"Unlikely","vote_count":200}]'::jsonb,
      NOW() + INTERVAL '6 days', $1)
     ON CONFLICT DO NOTHING`,
    [peddiId]
  );

  const wallpapers = [
    ['Ram Charan Mass Wallpaper', 'hero', rcId, '🎬'],
    ['PK Attitude Status', 'hero', pkId, '⚡'],
    ['NTR Fire Wallpaper', 'hero', ntrId, '🌊'],
    ['Peddi Countdown', 'countdown', rcId, '🔥'],
  ];
  for (const [title, cat, heroId, emoji] of wallpapers) {
    await pool.query(
      `INSERT INTO wallpapers (title, category, hero_id, image_url, is_trending)
       VALUES ($1,$2,$3,$4,TRUE) ON CONFLICT DO NOTHING`,
      [title, cat, heroId, `https://placehold.co/400x800/121622/FFB545?text=${encodeURIComponent(emoji)}`]
    );
  }

  const cards = [
    ['RC Mass Status Card', 'hero_status', rcId],
    ['Peddi Countdown Card', 'countdown', rcId],
    ['PK Power Status', 'hero_status', pkId],
  ];
  for (const [title, cat, heroId] of cards) {
    await pool.query(
      `INSERT INTO status_cards (title, category, hero_id, image_url, is_trending)
       VALUES ($1,$2,$3,'https://placehold.co/400x600/1A1F2E/FF6B21?text=Card',TRUE) ON CONFLICT DO NOTHING`,
      [title, cat, heroId]
    );
  }

  const { rows: seedUsers } = await pool.query('SELECT id FROM users LIMIT 3');
  for (const u of seedUsers) {
    await pool.query(
      `INSERT INTO user_notifications (user_id, title, body, category, content_type)
       SELECT $1, v.title, v.body, v.category, v.content_type
       FROM (VALUES
         ('Peddi update is live', 'Breaking: new stills dropped for Peddi.', 'updates', 'update'),
         ('Daily quiz ready', 'Play today''s TFI quiz and test your fan knowledge.', 'quiz', 'quiz'),
         ('New poll: fan opinion', 'Vote on the most awaited movie this month.', 'polls', 'poll')
       ) AS v(title, body, category, content_type)
       WHERE NOT EXISTS (
         SELECT 1 FROM user_notifications n WHERE n.user_id = $1 AND n.title = v.title
       )`,
      [u.id]
    );
  }

  console.log('✅ Seed complete');
  await pool.end();
}

seed().catch(e => { console.error(e); process.exit(1); });
