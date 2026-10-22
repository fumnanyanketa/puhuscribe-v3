-- TEST FIXTURE ONLY: units test-fixture-unit-2 and test-fixture-unit-3. Never
-- load this into a hosted database. Spec: factory/jobs/12-units-1-3/spec.md,
-- "Done when" 15.
--
-- Loaded only into the throwaway local Supabase of the pull request check
-- "Browser tests (Playwright, local Supabase)" (supabase/seeds/browser/README.md),
-- after 010_test_fixture_unit_1.sql. With it, the browser tests of job 12 have
-- three units to run sessions on and to fill the "Patterns you've seen" panel
-- before the native reviewer approves the real units 1 to 3.
--
-- What is here: two units (positions 901 and 902), one approved dialogue each,
-- their words and forms. Some words reuse the forms of unit 1's fixture, so a
-- form is met in more than one unit. One form (todella) is approved with its
-- line and then retired, so its word stays plain text with no card.
-- The Finnish is lines 6 to 10 of docs/risk-tests/test-2-voice-lines.md. It has
-- NOT been checked by the native reviewer. The form names and "why" lines were
-- written by the job 12 builder and start with "Test fixture". Every approval
-- reference starts with test-fixture:not-reviewed, and every audio key starts
-- with test-fixture/ (no such audio file exists).
--
-- Every form tag starts with "test-fixture ", so these forms never clash with
-- real published forms of the same word.
-- The order follows docs/data-model.md: forms, then lines with their words,
-- then dialogues. The units are approved at once (they have no whole-unit rule).

insert into public.units (slug, position, title_en, can_do_en, status, approved_at, approval_ref)
values
  ('test-fixture-unit-2', 901, 'Test fixture unit 2',
   'Test fixture. Order a coffee and ask the price.',
   'approved', now(), 'test-fixture:not-reviewed:unit-2'),
  ('test-fixture-unit-3', 902, 'Test fixture unit 3',
   'Test fixture. Ask whether a shop has something.',
   'approved', now(), 'test-fixture:not-reviewed:unit-3');

insert into public.dialogues (unit_id, slug, position, title_en)
select u.id, d.slug, d.position, d.title
  from (values
    ('test-fixture-unit-2', 'test-fixture-dialogue-unit-2', 1, 'Test fixture dialogue. One coffee, please.'),
    ('test-fixture-unit-3', 'test-fixture-dialogue-unit-3', 1, 'Test fixture dialogue. Do you have oat milk?')
  ) as d(unit_slug, slug, position, title)
  join public.units u on u.slug = d.unit_slug;

insert into public.forms
  (lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, status, approved_at, approval_ref)
select f.lemma, 'test-fixture ' || f.form_tag, f.kirja, f.puhe, f.form_name, f.why, 'approved', now(),
       'test-fixture:not-reviewed:form-' || f.lemma || '-' || replace(f.form_tag, ' ', '-')
  from (values
    ('yksi', 'Num Sg Nom', 'yksi', 'yks', 'Test fixture. Basic form',
     'Test fixture, not reviewed. Spoken Finnish says yks for one.'),
    ('kahvi', 'N Sg Nom', 'kahvi', 'kahvi', 'Test fixture. Basic form',
     'Test fixture, not reviewed. The same in both registers.'),
    ('kiitos', 'N Sg Nom', 'kiitos', 'kiitti', 'Test fixture. Basic form',
     'Test fixture, not reviewed. Spoken Finnish often says kiitti.'),
    ('saada', 'V Cond Sg1 Qst', 'saisinko', 'saisinks', 'Test fixture. Could I have',
     'Test fixture, not reviewed. A polite way to ask for something.'),
    ('yksi', 'Num Sg Gen', 'yhden', 'yhen', 'Test fixture. Object form',
     'Test fixture, not reviewed. Spoken Finnish drops the d.'),
    ('pulla', 'N Sg Gen', 'pullan', 'pullan', 'Test fixture. Object form',
     'Test fixture, not reviewed. The thing you ask for takes -n here.'),
    ('paljon', 'Adv Qst', 'paljonko', 'paljonks', 'Test fixture. How much',
     'Test fixture, not reviewed. Asks how much something is.'),
    ('se', 'Pron Sg Nom', 'se', 'se', 'Test fixture. It, subject',
     'Test fixture, not reviewed. The same in both registers.'),
    ('maksaa', 'V Pres Sg3', 'maksaa', 'maksaa', 'Test fixture. Verb, it form',
     'Test fixture, not reviewed. The same in both registers.'),
    ('olla', 'V Pres Sg3 Qst', 'onko', 'onks', 'Test fixture. Is there',
     'Test fixture, not reviewed. Spoken Finnish says onks.'),
    ('te', 'Pron Pl Ade', 'teillä', 'teil', 'Test fixture. You have',
     'Test fixture, not reviewed. Spoken Finnish drops the last vowel.'),
    ('kauramaito', 'N Sg Par', 'kauramaitoa', 'kauramaitoo', 'Test fixture. Some of something',
     'Test fixture, not reviewed. Spoken Finnish says -oo for -oa.'),
    ('kyllä', 'Adv', 'kyllä', 'joo', 'Test fixture. Yes',
     'Test fixture, not reviewed. Spoken Finnish says joo.'),
    ('olla', 'V Pres Sg3', 'on', 'on', 'Test fixture. Verb olla, it form',
     'Test fixture, not reviewed. The same in both registers.'),
    ('todella', 'Adv', 'todella', 'tosi', 'Test fixture retired form, never shown',
     'Test fixture, not reviewed. Retired, so no learner sees this.'),
    ('hyvä', 'A Sg Par', 'hyvää', 'hyvää', 'Test fixture. Some of something',
     'Test fixture, not reviewed. The same in both registers.')
  ) as f(lemma, form_tag, kirja, puhe, form_name, why);

insert into public.dialogue_lines
  (dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en, audio_puhe_key, audio_kirja_key)
select d.id, l.position, l.speaker, l.puhe, l.kirja, l.gloss,
       'test-fixture/' || d.slug || '/' || l.position || '-puhe.mp3',
       'test-fixture/' || d.slug || '/' || l.position || '-kirja.mp3'
  from (values
    ('test-fixture-dialogue-unit-2', 1, 'Alex', 'Moi! Yks kahvi, kiitti.', 'Hei! Yksi kahvi, kiitos.',
     'Hi! One coffee, thanks.'),
    ('test-fixture-dialogue-unit-2', 2, 'Alex', 'Saisinks mä yhen pullan?', 'Saisinko yhden pullan?',
     'Could I have a bun?'),
    ('test-fixture-dialogue-unit-2', 3, 'Alex', 'Paljonks se maksaa?', 'Paljonko se maksaa?',
     'How much is it?'),
    ('test-fixture-dialogue-unit-3', 1, 'Alex', 'Onks teil kauramaitoo?', 'Onko teillä kauramaitoa?',
     'Do you have oat milk?'),
    ('test-fixture-dialogue-unit-3', 2, 'Sanna', 'Joo, se on tosi hyvää.', 'Kyllä, se on todella hyvää.',
     'Yes, it''s really good.')
  ) as l(dialogue_slug, position, speaker, puhe, kirja, gloss)
  join public.dialogues d on d.slug = l.dialogue_slug;

-- Every word of every line, in order. Moi, hei and minä are unit 1's forms.
insert into public.tokens (line_id, register, position, surface, form_id)
select l.id, t.register::public.finnish_register, t.position, t.surface, f.id
  from (values
    ('test-fixture-dialogue-unit-2', 1, 'puhe', 1, 'Moi', 'moi', 'Interj'),
    ('test-fixture-dialogue-unit-2', 1, 'puhe', 2, 'Yks', 'yksi', 'Num Sg Nom'),
    ('test-fixture-dialogue-unit-2', 1, 'puhe', 3, 'kahvi', 'kahvi', 'N Sg Nom'),
    ('test-fixture-dialogue-unit-2', 1, 'puhe', 4, 'kiitti', 'kiitos', 'N Sg Nom'),
    ('test-fixture-dialogue-unit-2', 1, 'kirja', 1, 'Hei', 'hei', 'Interj'),
    ('test-fixture-dialogue-unit-2', 1, 'kirja', 2, 'Yksi', 'yksi', 'Num Sg Nom'),
    ('test-fixture-dialogue-unit-2', 1, 'kirja', 3, 'kahvi', 'kahvi', 'N Sg Nom'),
    ('test-fixture-dialogue-unit-2', 1, 'kirja', 4, 'kiitos', 'kiitos', 'N Sg Nom'),
    ('test-fixture-dialogue-unit-2', 2, 'puhe', 1, 'Saisinks', 'saada', 'V Cond Sg1 Qst'),
    ('test-fixture-dialogue-unit-2', 2, 'puhe', 2, 'mä', 'minä', 'Pron Sg1 Nom'),
    ('test-fixture-dialogue-unit-2', 2, 'puhe', 3, 'yhen', 'yksi', 'Num Sg Gen'),
    ('test-fixture-dialogue-unit-2', 2, 'puhe', 4, 'pullan', 'pulla', 'N Sg Gen'),
    ('test-fixture-dialogue-unit-2', 2, 'kirja', 1, 'Saisinko', 'saada', 'V Cond Sg1 Qst'),
    ('test-fixture-dialogue-unit-2', 2, 'kirja', 2, 'yhden', 'yksi', 'Num Sg Gen'),
    ('test-fixture-dialogue-unit-2', 2, 'kirja', 3, 'pullan', 'pulla', 'N Sg Gen'),
    ('test-fixture-dialogue-unit-2', 3, 'puhe', 1, 'Paljonks', 'paljon', 'Adv Qst'),
    ('test-fixture-dialogue-unit-2', 3, 'puhe', 2, 'se', 'se', 'Pron Sg Nom'),
    ('test-fixture-dialogue-unit-2', 3, 'puhe', 3, 'maksaa', 'maksaa', 'V Pres Sg3'),
    ('test-fixture-dialogue-unit-2', 3, 'kirja', 1, 'Paljonko', 'paljon', 'Adv Qst'),
    ('test-fixture-dialogue-unit-2', 3, 'kirja', 2, 'se', 'se', 'Pron Sg Nom'),
    ('test-fixture-dialogue-unit-2', 3, 'kirja', 3, 'maksaa', 'maksaa', 'V Pres Sg3'),
    ('test-fixture-dialogue-unit-3', 1, 'puhe', 1, 'Onks', 'olla', 'V Pres Sg3 Qst'),
    ('test-fixture-dialogue-unit-3', 1, 'puhe', 2, 'teil', 'te', 'Pron Pl Ade'),
    ('test-fixture-dialogue-unit-3', 1, 'puhe', 3, 'kauramaitoo', 'kauramaito', 'N Sg Par'),
    ('test-fixture-dialogue-unit-3', 1, 'kirja', 1, 'Onko', 'olla', 'V Pres Sg3 Qst'),
    ('test-fixture-dialogue-unit-3', 1, 'kirja', 2, 'teillä', 'te', 'Pron Pl Ade'),
    ('test-fixture-dialogue-unit-3', 1, 'kirja', 3, 'kauramaitoa', 'kauramaito', 'N Sg Par'),
    ('test-fixture-dialogue-unit-3', 2, 'puhe', 1, 'Joo', 'kyllä', 'Adv'),
    ('test-fixture-dialogue-unit-3', 2, 'puhe', 2, 'se', 'se', 'Pron Sg Nom'),
    ('test-fixture-dialogue-unit-3', 2, 'puhe', 3, 'on', 'olla', 'V Pres Sg3'),
    ('test-fixture-dialogue-unit-3', 2, 'puhe', 4, 'tosi', 'todella', 'Adv'),
    ('test-fixture-dialogue-unit-3', 2, 'puhe', 5, 'hyvää', 'hyvä', 'A Sg Par'),
    ('test-fixture-dialogue-unit-3', 2, 'kirja', 1, 'Kyllä', 'kyllä', 'Adv'),
    ('test-fixture-dialogue-unit-3', 2, 'kirja', 2, 'se', 'se', 'Pron Sg Nom'),
    ('test-fixture-dialogue-unit-3', 2, 'kirja', 3, 'on', 'olla', 'V Pres Sg3'),
    ('test-fixture-dialogue-unit-3', 2, 'kirja', 4, 'todella', 'todella', 'Adv'),
    ('test-fixture-dialogue-unit-3', 2, 'kirja', 5, 'hyvää', 'hyvä', 'A Sg Par')
  ) as t(dialogue_slug, line_position, register, position, surface, lemma, form_tag)
  join public.dialogues d on d.slug = t.dialogue_slug
  join public.dialogue_lines l on l.dialogue_id = d.id and l.position = t.line_position
  left join public.forms f on f.lemma = t.lemma and f.form_tag = 'test-fixture ' || t.form_tag;

-- Approve the lines, then the dialogues.
update public.dialogue_lines l
   set status = 'approved', approved_at = now(),
       approval_ref = 'test-fixture:not-reviewed:' || d.slug || '-line-' || l.position
  from public.dialogues d
 where d.id = l.dialogue_id and d.slug in ('test-fixture-dialogue-unit-2', 'test-fixture-dialogue-unit-3');

update public.dialogues
   set status = 'approved', approved_at = now(), approval_ref = 'test-fixture:not-reviewed:' || slug
 where slug in ('test-fixture-dialogue-unit-2', 'test-fixture-dialogue-unit-3');

-- The retired form: approved when its line was approved, then retired. Its
-- word stays in the line as plain text, with no card.
update public.forms set status = 'retired' where lemma = 'todella' and form_tag = 'test-fixture Adv';
