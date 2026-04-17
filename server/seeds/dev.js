require('dotenv').config();
const { pool } = require('../src/config/db');

const HEROES = [
  { name: 'Pawan Kalyan', telugu_name: 'పవన్ కళ్యాణ్', army_name: 'Power Army', icon_emoji: '🦁', sort_order: 1 },
  { name: 'Mahesh Babu', telugu_name: 'మహేష్ బాబు', army_name: 'Mahesh Army', icon_emoji: '👑', sort_order: 2 },
  { name: 'Allu Arjun', telugu_name: 'అల్లు అర్జున్', army_name: 'Bunny Army', icon_emoji: '🔥', sort_order: 3 },
  { name: 'Ram Charan', telugu_name: 'రామ్ చరణ్', army_name: 'Charan Army', icon_emoji: '⚡', sort_order: 4 },
  { name: 'Jr. NTR', telugu_name: 'జూనియర్ ఎన్టీఆర్', army_name: 'Young Tiger Army', icon_emoji: '🌊', sort_order: 5 },
  { name: 'Prabhas', telugu_name: 'ప్రభాస్', army_name: 'Rebel Army', icon_emoji: '🐯', sort_order: 6 },
  { name: 'Balakrishna', telugu_name: 'బాలకృష్ణ', army_name: 'Nandamuri Sena', icon_emoji: '🦅', sort_order: 7 },
  { name: 'Chiranjeevi', telugu_name: 'చిరంజీవి', army_name: 'Mega Army', icon_emoji: '🌟', sort_order: 8 },
];

const MOVIES = [
  { title: 'Pushpa 3', title_telugu: 'పుష్ప 3', director: 'Sukumar', release_date: '2025-08-15', genre: 'Mass Action', status: 'upcoming', hero_name: 'Allu Arjun' },
  { title: 'Devara 2', title_telugu: 'దేవర 2', director: 'Koratala Siva', release_date: '2025-05-03', genre: 'Mass', status: 'upcoming', hero_name: 'Jr. NTR' },
  { title: 'HHVM', title_telugu: 'హరి హర వీర మల్లు', director: 'Krish Jagarlamudi', release_date: '2025-07-04', genre: 'Period Action', status: 'upcoming', hero_name: 'Pawan Kalyan' },
  { title: 'Game Changer 2', title_telugu: 'గేమ్ చేంజర్ 2', director: 'Shankar', release_date: '2025-06-18', genre: 'Action', status: 'upcoming', hero_name: 'Ram Charan' },
  { title: 'Baahubali', title_telugu: 'బాహుబలి', director: 'SS Rajamouli', release_date: '2015-07-10', genre: 'Epic', status: 'released', hero_name: 'Prabhas' },
  { title: 'RRR', title_telugu: 'ఆర్‌ఆర్‌ఆర్', director: 'SS Rajamouli', release_date: '2022-03-25', genre: 'Period Action', status: 'released', hero_name: 'Jr. NTR' },
  { title: 'Pushpa', title_telugu: 'పుష్ప', director: 'Sukumar', release_date: '2021-12-17', genre: 'Mass Action', status: 'released', hero_name: 'Allu Arjun' },
  { title: 'Magadheera', title_telugu: 'మాగధీర', director: 'SS Rajamouli', release_date: '2009-07-31', genre: 'Fantasy Action', status: 'released', hero_name: 'Ram Charan' },
];

const QUIZ_QUESTIONS = [
  { question_text: "Ee movie lo 'Naatu Naatu' song vasindi?", question_telugu: "ఈ మూవీలో 'నాటు నాటు' సాంగ్ వచ్చింది?", type: 'song_clue', difficulty: 'easy', option_a: 'Baahubali', option_b: 'RRR', option_c: 'Pushpa', option_d: 'Magadheera', correct_option: 'b', coins_reward: 3 },
  { question_text: 'Mahesh Babu hero ga first movie?', question_telugu: 'మహేష్ బాబు హీరోగా మొదటి మూవీ?', type: 'hero_silhouette', difficulty: 'medium', option_a: 'Raja Kumarudu', option_b: 'Neeku Naaku Naidu', option_c: 'Murari', option_d: 'Okkadu', correct_option: 'a', coins_reward: 4 },
  { question_text: "Pushpa lo hero enti?", question_telugu: "పుష్పలో హీరో ఎంటి?", type: 'movie_still', difficulty: 'easy', option_a: 'Mahesh', option_b: 'Allu Arjun', option_c: 'NTR', option_d: 'Prabhas', correct_option: 'b', coins_reward: 3 },
  { question_text: "Baahubali movie lo villain enti?", question_telugu: "బాహుబలి మూవీలో విలన్ ఎంటి?", type: 'movie_still', difficulty: 'medium', option_a: 'Rana Daggubati', option_b: 'Sonu Sood', option_c: 'Nassar', option_d: 'Prakash Raj', correct_option: 'a', coins_reward: 4 },
  { question_text: "RRR movie release year enti?", question_telugu: "RRR మూవీ రిలీజ్ ఇయర్ ఎంటి?", type: 'release_year', difficulty: 'easy', option_a: '2020', option_b: '2021', option_c: '2022', option_d: '2023', correct_option: 'c', coins_reward: 3 },
  { question_text: "SS Rajamouli director ga first blockbuster?", type: 'dialogue', difficulty: 'hard', option_a: 'Magadheera', option_b: 'Vikramarkudu', option_c: 'Student No 1', option_d: 'Simhadri', correct_option: 'a', coins_reward: 5 },
  { question_text: "Pawan Kalyan real name enti?", type: 'hero_silhouette', difficulty: 'medium', option_a: 'Konidela Kalyan Babu', option_b: 'Siva Shankar Vara Prasad', option_c: 'Harikrishna', option_d: 'Nandamuri', correct_option: 'b', coins_reward: 4 },
  { question_text: "'Naatu Naatu' Oscar winner movie?", type: 'song_clue', difficulty: 'easy', option_a: 'Baahubali', option_b: 'Pushpa', option_c: 'RRR', option_d: 'KGF', correct_option: 'c', coins_reward: 3 },
  { question_text: "Allu Arjun grandfather enti?", type: 'hero_silhouette', difficulty: 'hard', option_a: 'Allu Ramalingaiah', option_b: 'ANR', option_c: 'NTR', option_d: 'Chiranjeevi', correct_option: 'a', coins_reward: 5 },
  { question_text: "Chiranjeevi 150th movie?", type: 'movie_still', difficulty: 'medium', option_a: 'Khaidi No 150', option_b: 'Godfather', option_c: 'Acharya', option_d: 'Sye Raa', correct_option: 'a', coins_reward: 4 },
  { question_text: "Baahubali - The Beginning release year?", type: 'release_year', difficulty: 'easy', option_a: '2013', option_b: '2014', option_c: '2015', option_d: '2016', correct_option: 'c', coins_reward: 3 },
  { question_text: "Jr. NTR full name enti?", type: 'dialogue', difficulty: 'medium', option_a: 'Nandamuri Taraka Rama Rao', option_b: 'Nandamuri Tarak', option_c: 'Nandamuri Harikrishna', option_d: 'Nandamuri Balakrishna', correct_option: 'a', coins_reward: 4 },
  { question_text: "Pushpa movie director enti?", type: 'movie_still', difficulty: 'easy', option_a: 'Trivikram', option_b: 'Sukumar', option_c: 'Harish Shankar', option_d: 'Anil Ravipudi', correct_option: 'b', coins_reward: 3 },
  { question_text: "Devara movie villain enti?", type: 'movie_still', difficulty: 'medium', option_a: 'Rana', option_b: 'Siddharth', option_c: 'Saif Ali Khan', option_d: 'Ajay Devgn', correct_option: 'c', coins_reward: 4 },
  { question_text: "Magadheera heroine enti?", type: 'movie_still', difficulty: 'easy', option_a: 'Kajal Agarwal', option_b: 'Tamannaah', option_c: 'Anushka', option_d: 'Samantha', correct_option: 'a', coins_reward: 3 },
];

const SHARE_CARDS = [
  { title: 'Power Star Morning Status', category: 'hero_status', is_premium: false },
  { title: 'Pushpa 3 Countdown Card', category: 'countdown', is_premium: false },
  { title: 'Iconic Dialogue Card', category: 'dialogue', is_premium: false },
  { title: 'Mahesh B-Day Special', category: 'birthday', is_premium: true },
  { title: 'Bunny Army Flag 2025', category: 'fan_army', is_premium: false },
  { title: 'NTR Tiger Status Pack', category: 'hero_status', is_premium: true },
  { title: 'Baahubali Anniversary', category: 'anniversary', is_premium: false },
  { title: 'RRR Dialogue Telugu', category: 'dialogue', is_premium: false },
];

const POLL = {
  question: 'Best mass hero of the decade — yevaru?',
  options: [
    { id: 'a', label: 'Pawan Kalyan', vote_count: 0 },
    { id: 'b', label: 'Mahesh Babu', vote_count: 0 },
    { id: 'c', label: 'Allu Arjun', vote_count: 0 },
    { id: 'd', label: 'Jr. NTR', vote_count: 0 },
  ],
  starts_at: new Date().toISOString(),
  ends_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
};

async function seed() {
  console.log('🌱 Seeding database...');

  // Insert heroes
  const heroMap = {};
  for (const h of HEROES) {
    const { rows } = await pool.query(
      `INSERT INTO heroes (name, telugu_name, army_name, icon_emoji, sort_order)
       VALUES ($1,$2,$3,$4,$5) ON CONFLICT DO NOTHING RETURNING id, name`,
      [h.name, h.telugu_name, h.army_name, h.icon_emoji, h.sort_order]
    );
    if (rows[0]) {
      heroMap[h.name] = rows[0].id;
      // Create fan army
      await pool.query(
        `INSERT INTO fan_armies (hero_id, army_name) VALUES ($1,$2) ON CONFLICT DO NOTHING`,
        [rows[0].id, h.army_name]
      );
    }
  }
  console.log('✅ Heroes seeded:', Object.keys(heroMap).length);

  // Insert movies
  const movieMap = {};
  for (const m of MOVIES) {
    const heroId = heroMap[m.hero_name];
    const { rows } = await pool.query(
      `INSERT INTO movies (title, title_telugu, hero_id, director, release_date, genre, status)
       VALUES ($1,$2,$3,$4,$5,$6,$7) ON CONFLICT DO NOTHING RETURNING id, title`,
      [m.title, m.title_telugu, heroId || null, m.director, m.release_date, m.genre, m.status]
    );
    if (rows[0]) movieMap[m.title] = rows[0].id;
  }
  console.log('✅ Movies seeded:', Object.keys(movieMap).length);

  // Insert quiz questions
  let qCount = 0;
  for (const q of QUIZ_QUESTIONS) {
    const { rowCount } = await pool.query(
      `INSERT INTO quiz_questions (question_text, question_telugu, type, difficulty, option_a, option_b, option_c, option_d, correct_option, coins_reward)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) ON CONFLICT DO NOTHING`,
      [q.question_text, q.question_telugu || null, q.type, q.difficulty, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_option, q.coins_reward]
    );
    qCount += rowCount;
  }
  console.log('✅ Quiz questions seeded:', qCount);

  // Insert share cards
  let cardCount = 0;
  for (const c of SHARE_CARDS) {
    const { rowCount } = await pool.query(
      `INSERT INTO share_cards (title, category, image_s3_key, is_premium, is_active, publish_date)
       VALUES ($1,$2,$3,$4,TRUE,CURRENT_DATE) ON CONFLICT DO NOTHING`,
      [c.title, c.category, `share-cards/${c.category}/placeholder.jpg`, c.is_premium]
    );
    cardCount += rowCount;
  }
  console.log('✅ Share cards seeded:', cardCount);

  // Insert poll
  await pool.query(
    `INSERT INTO polls (question, options, starts_at, ends_at, is_active)
     VALUES ($1,$2,$3,$4,TRUE) ON CONFLICT DO NOTHING`,
    [POLL.question, JSON.stringify(POLL.options), POLL.starts_at, POLL.ends_at]
  );
  console.log('✅ Poll seeded');

  await pool.end();
  console.log('\n🎉 Seed complete!');
}

seed().catch(err => { console.error('Seed failed:', err); process.exit(1); });
