-- Job 3-data-model, part 3: the reference tables, closed to every API role.
-- Spec: factory/jobs/3-data-model/spec.md, "Done when" 1, 2, 7, 15 and 16, and
-- the owner's calls of 20 October 2026 (factory/jobs/3-data-model/summary.md).
-- Plain English description: docs/data-model.md.
--
-- Material for writing content, never shown to learners. Rows arrive only
-- through generated migrations (scripts/v2-import/), never through the API.

-- Sentences from earlier material, kept as reference when units are written.
-- A sentence reused in a unit becomes a new dialogue line and is approved by
-- the native reviewer in its dialogue, like every other line.
create table public.source_sentences (
  id bigint generated always as identity primary key,
  source text not null check (btrim(source) <> ''),
  source_ref text not null check (btrim(source_ref) <> ''),
  text_kirja text not null check (btrim(text_kirja) <> ''),
  text_puhe text not null check (btrim(text_puhe) <> ''),
  gloss_en text not null check (btrim(gloss_en) <> ''),
  note text not null check (btrim(note) <> ''),
  unique (source, source_ref)
);

-- Pronunciation (IPA) per base form, with where it came from and its licence.
create table public.lemma_ipa (
  lemma text primary key check (btrim(lemma) <> ''),
  ipa text not null check (btrim(ipa) <> ''),
  source text not null check (btrim(source) <> ''),
  licence text not null check (btrim(licence) <> '')
);

comment on table public.source_sentences is
  'Reference (job 3-data-model): sentences from earlier material. Never readable by learners.';
comment on table public.lemma_ipa is
  'Reference (job 3-data-model): IPA per base form, with source and licence. Never readable by learners.';

revoke all on table public.source_sentences, public.lemma_ipa from anon, authenticated, service_role;
revoke all on sequence public.source_sentences_id_seq from anon, authenticated, service_role;

-- Row level security on, and no rule: even a role that was given a permission
-- by mistake would see no rows.
alter table public.source_sentences enable row level security;
alter table public.lemma_ipa enable row level security;
