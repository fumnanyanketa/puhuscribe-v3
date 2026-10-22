-- TEST FIXTURE ONLY: unit test-fixture-unit-1. Never load this into a hosted
-- database. Spec: factory/jobs/8-first-session/spec.md, "Done when" 20.
--
-- Loaded only into the throwaway local Supabase of the pull request check
-- "Browser tests (Playwright, local Supabase)" (supabase/seeds/browser/README.md).
-- The browser tests of job 8 need one approved dialogue to run a session on
-- before job 7 publishes real, reviewed content.
--
-- What is here: one unit (position 900), two approved dialogues, one draft
-- dialogue with a draft line, one draft form (approved, used by a line, then
-- set back to draft), and their words and forms.
-- The Finnish is lines 1 to 5 of docs/risk-tests/test-2-voice-lines.md. It has
-- NOT been checked by the native reviewer. The form names and "why" lines were
-- written by the job 8 builder and start with "Test fixture". Every approval
-- reference starts with test-fixture:not-reviewed, and every audio key starts
-- with test-fixture/ (no such audio file exists).
--
-- Every form tag starts with "test-fixture ", so these forms never clash with
-- real published forms of the same word.
-- The order follows docs/data-model.md: forms, then lines with their words,
-- then dialogues. The unit is approved at once (it has no whole-unit rule).

insert into public.units (slug, position, title_en, can_do_en, status, approved_at, approval_ref)
values (
  'test-fixture-unit-1', 900, 'Test fixture unit 1',
  'Test fixture. Greet someone and say where you are from.',
  'approved', now(), 'test-fixture:not-reviewed:unit-1'
);

insert into public.dialogues (unit_id, slug, position, title_en)
select u.id, d.slug, d.position, d.title
  from (values
    ('test-fixture-dialogue-1', 1, 'Test fixture dialogue 1. Alex meets Sanna.'),
    ('test-fixture-dialogue-2', 2, 'Test fixture dialogue 2. Are you from Helsinki?'),
    ('test-fixture-dialogue-draft', 3, 'Test fixture draft dialogue, never shown.')
  ) as d(slug, position, title)
  cross join public.units u
 where u.slug = 'test-fixture-unit-1';

insert into public.forms
  (lemma, form_tag, surface_kirja, surface_puhe, form_name_en, why_en, status, approved_at, approval_ref)
select f.lemma, 'test-fixture ' || f.form_tag, f.kirja, f.puhe, f.form_name, f.why, 'approved', now(),
       'test-fixture:not-reviewed:form-' || f.lemma || '-' || replace(f.form_tag, ' ', '-')
  from (values
    ('moi', 'Interj', 'moi', 'moi', 'Test fixture. Greeting',
     'Test fixture, not reviewed. An everyday hello.'),
    ('hei', 'Interj', 'hei', 'hei', 'Test fixture. Greeting',
     'Test fixture, not reviewed. Hello in both registers.'),
    ('minä', 'Pron Sg1 Nom', 'minä', 'mä', 'Test fixture. I, subject',
     'Test fixture, not reviewed. Spoken Finnish shortens minä to mä.'),
    ('olla', 'V Pres Sg1', 'olen', 'oon', 'Test fixture. Verb olla, I form',
     'Test fixture, not reviewed. Spoken Finnish says oon for olen.'),
    ('mikä', 'Pron Ela', 'mistä', 'mist', 'Test fixture. From where',
     'Test fixture, not reviewed. Spoken Finnish drops the last vowel.'),
    ('sinä', 'Pron Sg2 Nom', 'sinä', 'sä', 'Test fixture. You, subject',
     'Test fixture, not reviewed. Spoken Finnish shortens sinä to sä.'),
    ('olla', 'V Pres Sg2', 'olet', 'oot', 'Test fixture. Verb olla, you form',
     'Test fixture, not reviewed. Spoken Finnish says oot for olet.'),
    ('kotoisin', 'Adv', 'kotoisin', 'kotoisin', 'Test fixture draft form, never shown',
     'Test fixture, not reviewed. Set back to draft, so no learner sees this.'),
    ('Brasilia', 'N Prop Ela', 'Brasiliasta', 'Brasiliasta', 'Test fixture. From a place',
     'Test fixture, not reviewed. The ending -sta means from.'),
    ('mutta', 'Conj', 'mutta', 'mut', 'Test fixture. But',
     'Test fixture, not reviewed. Spoken Finnish drops the last vowel.'),
    ('asua', 'V Pres Sg1', 'asun', 'asun', 'Test fixture. Verb asua, I form',
     'Test fixture, not reviewed. The same in both registers.'),
    ('nyt', 'Adv', 'nyt', 'nyt', 'Test fixture. Now',
     'Test fixture, not reviewed. The same in both registers.'),
    ('Helsinki', 'N Prop Ine', 'Helsingissä', 'Helsingis', 'Test fixture. In a place',
     'Test fixture, not reviewed. Spoken Finnish drops the last vowel of -ssä.'),
    ('olla', 'V Pres Sg2 Qst', 'oletko', 'ootsä', 'Test fixture. Are you',
     'Test fixture, not reviewed. Spoken Finnish joins the verb and sä.'),
    ('täällä', 'Adv Ela', 'täältä', 'täält', 'Test fixture. From here',
     'Test fixture, not reviewed. Spoken Finnish drops the last vowel.'),
    ('Helsinki', 'N Prop Ela', 'Helsingistä', 'Helsingist', 'Test fixture. From a place',
     'Test fixture, not reviewed. Spoken Finnish drops the last vowel of -stä.'),
    ('kiva', 'A Sg Nom', 'kiva', 'kiva', 'Test fixture. Nice',
     'Test fixture, not reviewed. Common in speech.'),
    ('hauska', 'A Sg Nom', 'hauska', 'hauska', 'Test fixture. Nice',
     'Test fixture, not reviewed. Hauska tavata is the written greeting.'),
    ('tavata', 'V Inf1', 'tavata', 'tavata', 'Test fixture. To meet',
     'Test fixture, not reviewed. The basic form of the verb.')
  ) as f(lemma, form_tag, kirja, puhe, form_name, why);

insert into public.dialogue_lines
  (dialogue_id, position, speaker, text_puhe, text_kirja, gloss_en, audio_puhe_key, audio_kirja_key)
select d.id, l.position, l.speaker, l.puhe, l.kirja, l.gloss,
       'test-fixture/' || d.slug || '/' || l.position || '-puhe.mp3',
       'test-fixture/' || d.slug || '/' || l.position || '-kirja.mp3'
  from (values
    ('test-fixture-dialogue-1', 1, 'Alex', 'Moi! Mä oon Alex.', 'Hei! Minä olen Alex.', 'Hi! I''m Alex.'),
    ('test-fixture-dialogue-1', 2, 'Sanna', 'Mist sä oot kotoisin?', 'Mistä sinä olet kotoisin?',
     'Where are you from?'),
    ('test-fixture-dialogue-1', 3, 'Alex', 'Mä oon Brasiliasta, mut mä asun nyt Helsingis.',
     'Minä olen Brasiliasta, mutta asun nyt Helsingissä.', 'I''m from Brazil, but I live in Helsinki now.'),
    ('test-fixture-dialogue-2', 1, 'Sanna', 'Ootsä täält Helsingist?', 'Oletko sinä täältä Helsingistä?',
     'Are you from here in Helsinki?'),
    ('test-fixture-dialogue-2', 2, 'Alex', 'Kiva tavata!', 'Hauska tavata!', 'Nice to meet you!'),
    ('test-fixture-dialogue-draft', 1, 'Alex', 'Kiva tavata!', 'Hauska tavata!',
     'Test fixture draft line, never shown.')
  ) as l(dialogue_slug, position, speaker, puhe, kirja, gloss)
  join public.dialogues d on d.slug = l.dialogue_slug;

-- Every word of every line, in order. A word with no lemma (a name) has no form.
insert into public.tokens (line_id, register, position, surface, form_id)
select l.id, t.register::public.finnish_register, t.position, t.surface, f.id
  from (values
    ('test-fixture-dialogue-1', 1, 'puhe', 1, 'Moi', 'moi', 'Interj'),
    ('test-fixture-dialogue-1', 1, 'puhe', 2, 'Mä', 'minä', 'Pron Sg1 Nom'),
    ('test-fixture-dialogue-1', 1, 'puhe', 3, 'oon', 'olla', 'V Pres Sg1'),
    ('test-fixture-dialogue-1', 1, 'puhe', 4, 'Alex', null, null),
    ('test-fixture-dialogue-1', 1, 'kirja', 1, 'Hei', 'hei', 'Interj'),
    ('test-fixture-dialogue-1', 1, 'kirja', 2, 'Minä', 'minä', 'Pron Sg1 Nom'),
    ('test-fixture-dialogue-1', 1, 'kirja', 3, 'olen', 'olla', 'V Pres Sg1'),
    ('test-fixture-dialogue-1', 1, 'kirja', 4, 'Alex', null, null),
    ('test-fixture-dialogue-1', 2, 'puhe', 1, 'Mist', 'mikä', 'Pron Ela'),
    ('test-fixture-dialogue-1', 2, 'puhe', 2, 'sä', 'sinä', 'Pron Sg2 Nom'),
    ('test-fixture-dialogue-1', 2, 'puhe', 3, 'oot', 'olla', 'V Pres Sg2'),
    ('test-fixture-dialogue-1', 2, 'puhe', 4, 'kotoisin', 'kotoisin', 'Adv'),
    ('test-fixture-dialogue-1', 2, 'kirja', 1, 'Mistä', 'mikä', 'Pron Ela'),
    ('test-fixture-dialogue-1', 2, 'kirja', 2, 'sinä', 'sinä', 'Pron Sg2 Nom'),
    ('test-fixture-dialogue-1', 2, 'kirja', 3, 'olet', 'olla', 'V Pres Sg2'),
    ('test-fixture-dialogue-1', 2, 'kirja', 4, 'kotoisin', 'kotoisin', 'Adv'),
    ('test-fixture-dialogue-1', 3, 'puhe', 1, 'Mä', 'minä', 'Pron Sg1 Nom'),
    ('test-fixture-dialogue-1', 3, 'puhe', 2, 'oon', 'olla', 'V Pres Sg1'),
    ('test-fixture-dialogue-1', 3, 'puhe', 3, 'Brasiliasta', 'Brasilia', 'N Prop Ela'),
    ('test-fixture-dialogue-1', 3, 'puhe', 4, 'mut', 'mutta', 'Conj'),
    ('test-fixture-dialogue-1', 3, 'puhe', 5, 'mä', 'minä', 'Pron Sg1 Nom'),
    ('test-fixture-dialogue-1', 3, 'puhe', 6, 'asun', 'asua', 'V Pres Sg1'),
    ('test-fixture-dialogue-1', 3, 'puhe', 7, 'nyt', 'nyt', 'Adv'),
    ('test-fixture-dialogue-1', 3, 'puhe', 8, 'Helsingis', 'Helsinki', 'N Prop Ine'),
    ('test-fixture-dialogue-1', 3, 'kirja', 1, 'Minä', 'minä', 'Pron Sg1 Nom'),
    ('test-fixture-dialogue-1', 3, 'kirja', 2, 'olen', 'olla', 'V Pres Sg1'),
    ('test-fixture-dialogue-1', 3, 'kirja', 3, 'Brasiliasta', 'Brasilia', 'N Prop Ela'),
    ('test-fixture-dialogue-1', 3, 'kirja', 4, 'mutta', 'mutta', 'Conj'),
    ('test-fixture-dialogue-1', 3, 'kirja', 5, 'asun', 'asua', 'V Pres Sg1'),
    ('test-fixture-dialogue-1', 3, 'kirja', 6, 'nyt', 'nyt', 'Adv'),
    ('test-fixture-dialogue-1', 3, 'kirja', 7, 'Helsingissä', 'Helsinki', 'N Prop Ine'),
    ('test-fixture-dialogue-2', 1, 'puhe', 1, 'Ootsä', 'olla', 'V Pres Sg2 Qst'),
    ('test-fixture-dialogue-2', 1, 'puhe', 2, 'täält', 'täällä', 'Adv Ela'),
    ('test-fixture-dialogue-2', 1, 'puhe', 3, 'Helsingist', 'Helsinki', 'N Prop Ela'),
    ('test-fixture-dialogue-2', 1, 'kirja', 1, 'Oletko', 'olla', 'V Pres Sg2 Qst'),
    ('test-fixture-dialogue-2', 1, 'kirja', 2, 'sinä', 'sinä', 'Pron Sg2 Nom'),
    ('test-fixture-dialogue-2', 1, 'kirja', 3, 'täältä', 'täällä', 'Adv Ela'),
    ('test-fixture-dialogue-2', 1, 'kirja', 4, 'Helsingistä', 'Helsinki', 'N Prop Ela'),
    ('test-fixture-dialogue-2', 2, 'puhe', 1, 'Kiva', 'kiva', 'A Sg Nom'),
    ('test-fixture-dialogue-2', 2, 'puhe', 2, 'tavata', 'tavata', 'V Inf1'),
    ('test-fixture-dialogue-2', 2, 'kirja', 1, 'Hauska', 'hauska', 'A Sg Nom'),
    ('test-fixture-dialogue-2', 2, 'kirja', 2, 'tavata', 'tavata', 'V Inf1'),
    ('test-fixture-dialogue-draft', 1, 'puhe', 1, 'Kiva', 'kiva', 'A Sg Nom'),
    ('test-fixture-dialogue-draft', 1, 'puhe', 2, 'tavata', 'tavata', 'V Inf1'),
    ('test-fixture-dialogue-draft', 1, 'kirja', 1, 'Hauska', 'hauska', 'A Sg Nom'),
    ('test-fixture-dialogue-draft', 1, 'kirja', 2, 'tavata', 'tavata', 'V Inf1')
  ) as t(dialogue_slug, line_position, register, position, surface, lemma, form_tag)
  join public.dialogues d on d.slug = t.dialogue_slug
  join public.dialogue_lines l on l.dialogue_id = d.id and l.position = t.line_position
  left join public.forms f on f.lemma = t.lemma and f.form_tag = 'test-fixture ' || t.form_tag
 where d.slug like 'test-fixture-%';

-- Approve the lines of the two approved dialogues, then the dialogues. The
-- draft dialogue and its line stay drafts.
update public.dialogue_lines l
   set status = 'approved', approved_at = now(),
       approval_ref = 'test-fixture:not-reviewed:' || d.slug || '-line-' || l.position
  from public.dialogues d
 where d.id = l.dialogue_id and d.slug in ('test-fixture-dialogue-1', 'test-fixture-dialogue-2');

update public.dialogues
   set status = 'approved', approved_at = now(), approval_ref = 'test-fixture:not-reviewed:' || slug
 where slug in ('test-fixture-dialogue-1', 'test-fixture-dialogue-2');

-- The draft form: approved when its line was approved, then withdrawn. Its
-- word stays in the line as plain text, with no card.
update public.forms set status = 'draft' where lemma = 'kotoisin' and form_tag = 'test-fixture Adv';
