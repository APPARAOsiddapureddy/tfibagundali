-- Keep hero selection clean: one row per hero name, with good portrait URLs.

CREATE TEMP TABLE _hero_dupes ON COMMIT DROP AS
WITH ranked AS (
  SELECT
    id,
    FIRST_VALUE(id) OVER (
      PARTITION BY regexp_replace(lower(name), '[^a-z0-9]+', '', 'g')
      ORDER BY sort_order NULLS LAST, created_at, id
    ) AS keep_id,
    ROW_NUMBER() OVER (
      PARTITION BY regexp_replace(lower(name), '[^a-z0-9]+', '', 'g')
      ORDER BY sort_order NULLS LAST, created_at, id
    ) AS rn
  FROM heroes
)
SELECT id AS old_id, keep_id
FROM ranked
WHERE rn > 1;

INSERT INTO hero_follows (user_id, hero_id, created_at)
SELECT hf.user_id, d.keep_id, hf.created_at
FROM hero_follows hf
JOIN _hero_dupes d ON d.old_id = hf.hero_id
ON CONFLICT DO NOTHING;

DELETE FROM hero_follows hf
USING _hero_dupes d
WHERE hf.hero_id = d.old_id;

INSERT INTO update_heroes (update_id, hero_id)
SELECT uh.update_id, d.keep_id
FROM update_heroes uh
JOIN _hero_dupes d ON d.old_id = uh.hero_id
ON CONFLICT DO NOTHING;

DELETE FROM update_heroes uh
USING _hero_dupes d
WHERE uh.hero_id = d.old_id;

UPDATE users u SET favourite_hero_id = d.keep_id FROM _hero_dupes d WHERE u.favourite_hero_id = d.old_id;
UPDATE movies m SET hero_id = d.keep_id FROM _hero_dupes d WHERE m.hero_id = d.old_id;
UPDATE tfi_updates t SET hero_id = d.keep_id FROM _hero_dupes d WHERE t.hero_id = d.old_id;
UPDATE wallpapers w SET hero_id = d.keep_id FROM _hero_dupes d WHERE w.hero_id = d.old_id;
UPDATE status_cards s SET hero_id = d.keep_id FROM _hero_dupes d WHERE s.hero_id = d.old_id;
UPDATE polls p SET hero_id = d.keep_id FROM _hero_dupes d WHERE p.hero_id = d.old_id;
UPDATE quiz_questions q SET hero_id = d.keep_id FROM _hero_dupes d WHERE q.hero_id = d.old_id;
UPDATE reminders r SET hero_id = d.keep_id FROM _hero_dupes d WHERE r.hero_id = d.old_id;
UPDATE status_card_customizations s SET hero_id = d.keep_id FROM _hero_dupes d WHERE s.hero_id = d.old_id;

DELETE FROM heroes h
USING _hero_dupes d
WHERE h.id = d.old_id;

CREATE TEMP TABLE _hero_catalog (
  name TEXT,
  telugu_name TEXT,
  icon_emoji TEXT,
  sort_order INTEGER,
  aliases JSONB,
  avatar_url TEXT
) ON COMMIT DROP;

INSERT INTO _hero_catalog (name, telugu_name, icon_emoji, sort_order, aliases, avatar_url) VALUES
('Pawan Kalyan', 'పవన్ కళ్యాణ్', '⚡', 1, '["PSPK","Power Star"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/The_portrait_of_Pawan_Kalyan_(2024).jpg?width=512'),
('Mahesh Babu', 'మహేష్ బాబు', '👑', 2, '["Super Star"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/Mahesh_Babu_in_Spyder_(cropped).jpg?width=512'),
('Allu Arjun', 'అల్లు అర్జున్', '🔥', 3, '["Bunny","Icon Star"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/Allu_Arjun_at_Pushpa_2_The_Rule_meet.jpg?width=512'),
('Ram Charan', 'రామ్ చరణ్', '⚡', 4, '["Mega Power Star"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/Ram_Charan_2024_(cropped).jpg?width=512'),
('Jr NTR', 'జూనియర్ ఎన్టీఆర్', '🐯', 5, '["Jr. NTR","NTR Jr","N. T. Rama Rao Jr"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/N.T.Rama_Rao_Jr._at_the_RRR_Press_Meet_in_Chennai.jpg?width=512'),
('Prabhas', 'ప్రభాస్', '🦁', 6, '["Darling"]'::jsonb, 'https://upload.wikimedia.org/wikipedia/commons/a/ad/Prabhas_at_Saaho_Pre_release_event_%28cropped%29.jpg'),
('Balakrishna', 'బాలకృష్ణ', '💥', 7, '["Nandamuri Balakrishna","Balayya","NBK"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/Padma_Bhushan_Award_to_Shri_Nandamuri_Balakrishna_at_the_Rashtrapati_Bhavan_(cropped).jpg?width=512'),
('Chiranjeevi', 'చిరంజీవి', '🌟', 8, '["Mega Star"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/Chiranjeevi_at_ANR_Awards_2024_(cropped).jpg?width=512'),
('Nani', 'నాని', '🌿', 9, '["Natural Star"]'::jsonb, 'https://upload.wikimedia.org/wikipedia/commons/d/dc/Nani_%28cropped%29.png'),
('Vijay Deverakonda', 'విజయ్ దేవరకొండ', '🕶️', 10, '["Vijay Devarakonda","VD","Rowdy"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/Vijay_Deverakonda_at_NOTA_pressmeet_(cropped).jpg?width=512'),
('Ravi Teja', 'రవితేజ', '⚡', 11, '["Mass Maharaja"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/Ravi_Teja_in_Dhamaka_promotions_2022_(cropped).png?width=512'),
('Nagarjuna', 'నాగార్జున', '💎', 12, '["Akkineni Nagarjuna","King"]'::jsonb, 'https://upload.wikimedia.org/wikipedia/commons/e/e1/Nagarjuna_Akkineni_at_ANR_Awards.jpg'),
('Venkatesh', 'వెంకటేష్', '🏆', 13, '["Daggubati Venkatesh","Victory Venkatesh","Venky"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/Daggubati_Venkatesh_(cropped).jpg?width=512'),
('Naga Chaitanya', 'నాగ చైతన్య', '✨', 14, '["Chay"]'::jsonb, 'https://commons.wikimedia.org/wiki/Special:FilePath/Naga_Chaitanya_(cropped).jpg?width=512');

UPDATE heroes h
SET name = c.name,
    telugu_name = c.telugu_name,
    icon_emoji = c.icon_emoji,
    sort_order = c.sort_order,
    aliases = c.aliases,
    avatar_url = c.avatar_url,
    bio = COALESCE(NULLIF(h.bio, ''), c.name || ' — Telugu cinema icon.'),
    is_active = TRUE,
    updated_at = NOW()
FROM _hero_catalog c
WHERE regexp_replace(lower(h.name), '[^a-z0-9]+', '', 'g') = regexp_replace(lower(c.name), '[^a-z0-9]+', '', 'g')
   OR EXISTS (
     SELECT 1
     FROM jsonb_array_elements_text(c.aliases) a(alias)
     WHERE regexp_replace(lower(h.name), '[^a-z0-9]+', '', 'g') = regexp_replace(lower(a.alias), '[^a-z0-9]+', '', 'g')
   );

INSERT INTO heroes (name, telugu_name, icon_emoji, sort_order, aliases, avatar_url, bio)
SELECT c.name, c.telugu_name, c.icon_emoji, c.sort_order, c.aliases, c.avatar_url, c.name || ' — Telugu cinema icon.'
FROM _hero_catalog c
WHERE NOT EXISTS (
  SELECT 1
  FROM heroes h
  WHERE regexp_replace(lower(h.name), '[^a-z0-9]+', '', 'g') = regexp_replace(lower(c.name), '[^a-z0-9]+', '', 'g')
     OR EXISTS (
       SELECT 1
       FROM jsonb_array_elements_text(c.aliases) a(alias)
       WHERE regexp_replace(lower(h.name), '[^a-z0-9]+', '', 'g') = regexp_replace(lower(a.alias), '[^a-z0-9]+', '', 'g')
     )
);

TRUNCATE _hero_dupes;

INSERT INTO _hero_dupes (old_id, keep_id)
WITH ranked AS (
  SELECT
    id,
    FIRST_VALUE(id) OVER (
      PARTITION BY regexp_replace(lower(name), '[^a-z0-9]+', '', 'g')
      ORDER BY sort_order NULLS LAST, created_at, id
    ) AS keep_id,
    ROW_NUMBER() OVER (
      PARTITION BY regexp_replace(lower(name), '[^a-z0-9]+', '', 'g')
      ORDER BY sort_order NULLS LAST, created_at, id
    ) AS rn
  FROM heroes
)
SELECT id AS old_id, keep_id
FROM ranked
WHERE rn > 1;

INSERT INTO hero_follows (user_id, hero_id, created_at)
SELECT hf.user_id, d.keep_id, hf.created_at
FROM hero_follows hf
JOIN _hero_dupes d ON d.old_id = hf.hero_id
ON CONFLICT DO NOTHING;

DELETE FROM hero_follows hf
USING _hero_dupes d
WHERE hf.hero_id = d.old_id;

INSERT INTO update_heroes (update_id, hero_id)
SELECT uh.update_id, d.keep_id
FROM update_heroes uh
JOIN _hero_dupes d ON d.old_id = uh.hero_id
ON CONFLICT DO NOTHING;

DELETE FROM update_heroes uh
USING _hero_dupes d
WHERE uh.hero_id = d.old_id;

UPDATE users u SET favourite_hero_id = d.keep_id FROM _hero_dupes d WHERE u.favourite_hero_id = d.old_id;
UPDATE movies m SET hero_id = d.keep_id FROM _hero_dupes d WHERE m.hero_id = d.old_id;
UPDATE tfi_updates t SET hero_id = d.keep_id FROM _hero_dupes d WHERE t.hero_id = d.old_id;
UPDATE wallpapers w SET hero_id = d.keep_id FROM _hero_dupes d WHERE w.hero_id = d.old_id;
UPDATE status_cards s SET hero_id = d.keep_id FROM _hero_dupes d WHERE s.hero_id = d.old_id;
UPDATE polls p SET hero_id = d.keep_id FROM _hero_dupes d WHERE p.hero_id = d.old_id;
UPDATE quiz_questions q SET hero_id = d.keep_id FROM _hero_dupes d WHERE q.hero_id = d.old_id;
UPDATE reminders r SET hero_id = d.keep_id FROM _hero_dupes d WHERE r.hero_id = d.old_id;
UPDATE status_card_customizations s SET hero_id = d.keep_id FROM _hero_dupes d WHERE s.hero_id = d.old_id;

DELETE FROM heroes h
USING _hero_dupes d
WHERE h.id = d.old_id;

CREATE UNIQUE INDEX IF NOT EXISTS idx_heroes_name_key_unique
ON heroes ((regexp_replace(lower(name), '[^a-z0-9]+', '', 'g')));

UPDATE movies m
SET hero_id = h.id
FROM heroes h
WHERE m.title = 'Spirit'
  AND regexp_replace(lower(h.name), '[^a-z0-9]+', '', 'g') = 'prabhas';
