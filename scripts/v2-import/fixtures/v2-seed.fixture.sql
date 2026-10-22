-- Made-up fixture in the shape of v2's supabase/seeds/05_island_sentences.sql,
-- for the starter sentence loader's tests (job 3-data-model, "Done when" 15).
-- Not Finnish and not learning content: the owner's decision of 20 October 2026
-- is that the loader is tested with made-up data until the reviewer's
-- corrections to the real 104 sentences arrive.

INSERT INTO topics (slug, name_fi, name_en, yki_category, sort_order)
VALUES ('arki', 'Arki', 'Everyday essentials', 'daily_life', 5)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO sentences (kirjakieli, puhekieli, translation_en, level, topic_id) VALUES
  -- 1-2 · first group
  ('Fixture written one.', 'Fixture spoken one.', 'Fixture English one.', 'A1', (SELECT id FROM topics WHERE slug = 'arki')),
  ('Fixture written two''s.', 'Fixture spoken two''s.', 'Fixture English two''s.', 'A1', (SELECT id FROM topics WHERE slug = 'arki')),
  -- 3 · second group
  ('Fixture written three.', 'Fixture spoken three.', 'Fixture English three.', 'A1', (SELECT id FROM topics WHERE slug = 'arki'));
