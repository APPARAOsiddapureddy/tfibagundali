-- Refresh weak or broken hero portrait URLs in existing databases.

UPDATE heroes SET avatar_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Mahesh_Babu_in_Spyder_(cropped).jpg?width=512', updated_at = NOW()
WHERE regexp_replace(lower(name), '[^a-z0-9]+', '', 'g') = 'maheshbabu';

UPDATE heroes SET avatar_url = 'https://upload.wikimedia.org/wikipedia/commons/a/ad/Prabhas_at_Saaho_Pre_release_event_%28cropped%29.jpg', updated_at = NOW()
WHERE regexp_replace(lower(name), '[^a-z0-9]+', '', 'g') = 'prabhas';

UPDATE heroes SET avatar_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Chiranjeevi_at_ANR_Awards_2024_(cropped).jpg?width=512', updated_at = NOW()
WHERE regexp_replace(lower(name), '[^a-z0-9]+', '', 'g') = 'chiranjeevi';

UPDATE heroes SET avatar_url = 'https://upload.wikimedia.org/wikipedia/commons/d/dc/Nani_%28cropped%29.png', updated_at = NOW()
WHERE regexp_replace(lower(name), '[^a-z0-9]+', '', 'g') = 'nani';

UPDATE heroes SET avatar_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Vijay_Deverakonda_at_NOTA_pressmeet_(cropped).jpg?width=512', updated_at = NOW()
WHERE regexp_replace(lower(name), '[^a-z0-9]+', '', 'g') = 'vijaydeverakonda';

UPDATE heroes SET avatar_url = 'https://upload.wikimedia.org/wikipedia/commons/e/e1/Nagarjuna_Akkineni_at_ANR_Awards.jpg', updated_at = NOW()
WHERE regexp_replace(lower(name), '[^a-z0-9]+', '', 'g') = 'nagarjuna';
