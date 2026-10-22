-- Job 3-data-model, part 1: the learning content tables.
-- Spec: factory/jobs/3-data-model/spec.md, "Done when" 1, 2, 4, 5, 6, 7 and 14.
-- Plain English description of every table: docs/data-model.md.
--
-- Content is units, their dialogues, each dialogue's lines in spoken (puhe) and
-- written (kirja) Finnish, each line's words (tokens), and the word forms a
-- learner reviews (forms). Learners may read content only when it is approved
-- and every parent above it is approved too. Nobody writes content through the
-- API: rows arrive through migrations (job 5 decides how its pipeline
-- publishes). No column here identifies a learner or the reviewer.

-- Helper functions for the triggers live in a schema the API does not expose.
create schema if not exists private;
revoke all on schema private from public;

-- Enums ----------------------------------------------------------------------

create type public.content_status as enum ('draft', 'approved', 'retired');
create type public.finnish_register as enum ('puhe', 'kirja');

-- Tables ---------------------------------------------------------------------

-- A real situation tied to an A1 "can do" statement. Its titles are English
-- only: Finnish a learner sees lives in dialogue lines, which have both
-- registers and audio (design review, round 1).
create table public.units (
  id bigint generated always as identity primary key,
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  position integer not null unique check (position > 0),
  title_en text not null check (btrim(title_en) <> ''),
  can_do_en text not null check (btrim(can_do_en) <> ''),
  status public.content_status not null default 'draft',
  approved_at timestamptz,
  approval_ref text,
  constraint units_approval_complete check (
    status <> 'approved'
    or (approved_at is not null and coalesce(btrim(approval_ref), '') <> '')
  )
);

-- One short dialogue in a unit.
create table public.dialogues (
  id bigint generated always as identity primary key,
  unit_id bigint not null references public.units (id) on delete restrict,
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  position integer not null check (position > 0),
  title_en text not null check (btrim(title_en) <> ''),
  status public.content_status not null default 'draft',
  approved_at timestamptz,
  approval_ref text,
  unique (unit_id, position),
  constraint dialogues_approval_complete check (
    status <> 'approved'
    or (approved_at is not null and coalesce(btrim(approval_ref), '') <> '')
  )
);

-- One line of a dialogue, in both registers, each with its own audio.
-- While a line is a draft any of its texts or audio keys may still be missing;
-- the database refuses to approve it until every one is present.
create table public.dialogue_lines (
  id bigint generated always as identity primary key,
  dialogue_id bigint not null references public.dialogues (id) on delete restrict,
  position integer not null check (position > 0),
  speaker text not null check (btrim(speaker) <> ''),
  text_puhe text,
  text_kirja text,
  gloss_en text,
  audio_puhe_key text,
  audio_kirja_key text,
  status public.content_status not null default 'draft',
  approved_at timestamptz,
  approval_ref text,
  unique (dialogue_id, position),
  constraint dialogue_lines_approval_complete check (
    status <> 'approved'
    or (
      coalesce(btrim(text_puhe), '') <> ''
      and coalesce(btrim(text_kirja), '') <> ''
      and coalesce(btrim(gloss_en), '') <> ''
      and coalesce(btrim(audio_puhe_key), '') <> ''
      and coalesce(btrim(audio_kirja_key), '') <> ''
      and approved_at is not null
      and coalesce(btrim(approval_ref), '') <> ''
    )
  )
);

-- The thing a learner reviews: one analysed word form with its written and
-- spoken shape, its form name and a one line "why".
create table public.forms (
  id bigint generated always as identity primary key,
  lemma text not null check (btrim(lemma) <> ''),
  form_tag text not null check (btrim(form_tag) <> ''),
  analysis jsonb,
  surface_kirja text not null check (btrim(surface_kirja) <> ''),
  surface_puhe text not null check (btrim(surface_puhe) <> ''),
  form_name_en text,
  -- The one line "why": no line break (or any other control character) and at
  -- most 140 characters (design review, round 1; the owner may pick another cap).
  why_en text check (why_en !~ '[[:cntrl:]]' and char_length(why_en) <= 140),
  status public.content_status not null default 'draft',
  approved_at timestamptz,
  approval_ref text,
  unique (lemma, form_tag, surface_kirja, surface_puhe),
  constraint forms_approval_complete check (
    status <> 'approved'
    or (
      coalesce(btrim(form_name_en), '') <> ''
      and coalesce(btrim(why_en), '') <> ''
      and approved_at is not null
      and coalesce(btrim(approval_ref), '') <> ''
    )
  )
);

-- One word of a line in one register. form_id is empty for words that are
-- never reviewed, such as names.
create table public.tokens (
  id bigint generated always as identity primary key,
  line_id bigint not null references public.dialogue_lines (id) on delete restrict,
  register public.finnish_register not null,
  position integer not null check (position > 0),
  surface text not null check (btrim(surface) <> ''),
  form_id bigint references public.forms (id) on delete restrict,
  unique (line_id, register, position)
);

comment on table public.units is
  'Learning content (job 3-data-model): a real situation tied to an A1 can do statement.';
comment on table public.dialogues is
  'Learning content (job 3-data-model): one short dialogue in a unit.';
comment on table public.dialogue_lines is
  'Learning content (job 3-data-model): one dialogue line in spoken and written Finnish, each with audio.';
comment on table public.forms is
  'Learning content (job 3-data-model): one word form a learner reviews.';
comment on table public.tokens is
  'Learning content (job 3-data-model): one word of a line in one register, linked to its form.';

-- Indexes for the columns the access rules filter on (the unique constraints
-- above already index unit_id, dialogue_id and line_id).
create index units_status_idx on public.units (status);
create index dialogues_status_idx on public.dialogues (status);
create index dialogue_lines_status_idx on public.dialogue_lines (status);
create index forms_status_idx on public.forms (status);
create index tokens_form_id_idx on public.tokens (form_id);

-- Approved content is frozen, and every approval is a new one ---------------------
-- While a row is approved, the only change allowed is its status (back to
-- draft, or to retired), and it cannot be deleted. To change a word, the
-- pipeline first sets the row back to draft, which hides it from learners
-- until it is approved again.
-- Leaving "approved" clears approved_at and approval_ref and keeps the old pair
-- in private.approval_history. Approving again therefore needs a new time and a
-- reference this row has never had, so changed content can never carry an old
-- review (evaluation, round 1).

create table private.approval_history (
  table_name text not null,
  row_id bigint not null,
  approval_ref text not null,
  approved_at timestamptz,
  superseded_at timestamptz not null default now(),
  primary key (table_name, row_id, approval_ref)
);

comment on table private.approval_history is
  'Content approvals that were withdrawn (job 3-data-model). Not reachable through the API.';

revoke all on table private.approval_history from public, anon, authenticated, service_role;
alter table private.approval_history enable row level security;

create function private.freeze_approved_content()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.status = 'approved' then
    if tg_op = 'DELETE' then
      raise exception 'approved content cannot be deleted: set %.% back to draft or retired first',
        tg_table_name, old.id;
    end if;
    if new.status = 'approved' then
      if (to_jsonb(new) - 'status') is distinct from (to_jsonb(old) - 'status') then
        raise exception 'approved content cannot change: set %.% back to draft first',
          tg_table_name, old.id;
      end if;
    else
      -- Leaving "approved": nothing else may change in the same step, and the
      -- approval is withdrawn.
      if (to_jsonb(new) - array['status', 'approved_at', 'approval_ref'])
         is distinct from (to_jsonb(old) - array['status', 'approved_at', 'approval_ref']) then
        raise exception 'approved content cannot change: set %.% back to draft first',
          tg_table_name, old.id;
      end if;
      insert into private.approval_history (table_name, row_id, approval_ref, approved_at)
      values (tg_table_name, old.id, old.approval_ref, old.approved_at)
      on conflict do nothing;
      new.approved_at := null;
      new.approval_ref := null;
    end if;
  elsif tg_op = 'UPDATE' and new.status = 'approved' and exists (
    select 1 from private.approval_history h
    where h.table_name = tg_table_name and h.row_id = new.id and h.approval_ref = new.approval_ref
  ) then
    raise exception 'this approval reference was already used for %.%: approving again needs a new review',
      tg_table_name, new.id;
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create trigger freeze_approved before update or delete on public.units
  for each row execute function private.freeze_approved_content();
create trigger freeze_approved before update or delete on public.dialogues
  for each row execute function private.freeze_approved_content();
create trigger freeze_approved before update or delete on public.dialogue_lines
  for each row execute function private.freeze_approved_content();
create trigger freeze_approved before update or delete on public.forms
  for each row execute function private.freeze_approved_content();

-- A token belongs to what a learner sees of its line, so the tokens of an
-- approved line cannot be added, changed or deleted either.
create function private.freeze_tokens_of_approved_lines()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op in ('UPDATE', 'DELETE') and exists (
    select 1 from public.dialogue_lines l where l.id = old.line_id and l.status = 'approved'
  ) then
    raise exception 'the tokens of an approved line cannot change: set dialogue_lines.% back to draft first',
      old.line_id;
  end if;
  if tg_op in ('INSERT', 'UPDATE') and exists (
    select 1 from public.dialogue_lines l where l.id = new.line_id and l.status = 'approved'
  ) then
    raise exception 'the tokens of an approved line cannot change: set dialogue_lines.% back to draft first',
      new.line_id;
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create trigger freeze_tokens_of_approved_lines before insert or update or delete on public.tokens
  for each row execute function private.freeze_tokens_of_approved_lines();

-- An approved dialogue is always whole --------------------------------------------
-- A learner must never see a dialogue with a line missing. So a dialogue can be
-- approved only when it has at least one approved line and no draft line, and
-- while it is approved its lines cannot be added, removed, moved, approved,
-- set back to draft or retired. To fix a line, the pipeline sets the dialogue
-- back to draft first (which hides the whole dialogue), then the line.
-- Retired lines are lines taken out on purpose; they do not block approval.

create function private.approved_dialogue_is_whole()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.status = 'approved' and (tg_op = 'INSERT' or old.status <> 'approved') then
    if not exists (
      select 1 from public.dialogue_lines l where l.dialogue_id = new.id and l.status = 'approved'
    ) then
      raise exception 'a dialogue needs at least one approved line before it can be approved (dialogues.%)',
        new.id;
    end if;
    if exists (
      select 1 from public.dialogue_lines l where l.dialogue_id = new.id and l.status = 'draft'
    ) then
      raise exception 'a dialogue with a draft line cannot be approved (dialogues.%)', new.id;
    end if;
  end if;
  return new;
end;
$$;

create trigger approved_dialogue_is_whole before insert or update on public.dialogues
  for each row execute function private.approved_dialogue_is_whole();

create function private.lines_of_approved_dialogues_stay()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op in ('UPDATE', 'DELETE') and exists (
    select 1 from public.dialogues d where d.id = old.dialogue_id and d.status = 'approved'
  ) and (
    tg_op = 'DELETE'
    or new.dialogue_id is distinct from old.dialogue_id
    or new.status is distinct from old.status
  ) then
    raise exception 'the lines of an approved dialogue cannot be added, removed or change status: set dialogues.% back to draft first',
      old.dialogue_id;
  end if;
  if tg_op in ('INSERT', 'UPDATE') and exists (
    select 1 from public.dialogues d where d.id = new.dialogue_id and d.status = 'approved'
  ) and (
    tg_op = 'INSERT'
    or new.dialogue_id is distinct from old.dialogue_id
    or new.status is distinct from old.status
  ) then
    raise exception 'the lines of an approved dialogue cannot be added, removed or change status: set dialogues.% back to draft first',
      new.dialogue_id;
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create trigger lines_of_approved_dialogues_stay before insert or update or delete on public.dialogue_lines
  for each row execute function private.lines_of_approved_dialogues_stay();

-- A line is approved only when every word in it that links to a form links to
-- an approved form. This holds at the moment of approval: a form set back to
-- draft or retired later is hidden from learners while lines still use it, so
-- that word then has no card (docs/data-model.md says how jobs 6 and 7 handle it).

create function private.line_words_have_approved_forms()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.status = 'approved' and (tg_op = 'INSERT' or old.status <> 'approved') and exists (
    select 1
    from public.tokens t
    join public.forms f on f.id = t.form_id
    where t.line_id = new.id and f.status <> 'approved'
  ) then
    raise exception 'a line whose words link to a form that is not approved cannot be approved (dialogue_lines.%)',
      new.id;
  end if;
  return new;
end;
$$;

create trigger line_words_have_approved_forms before insert or update on public.dialogue_lines
  for each row execute function private.line_words_have_approved_forms();

revoke all on function private.freeze_approved_content() from public, anon, authenticated, service_role;
revoke all on function private.freeze_tokens_of_approved_lines() from public, anon, authenticated, service_role;
revoke all on function private.approved_dialogue_is_whole() from public, anon, authenticated, service_role;
revoke all on function private.lines_of_approved_dialogues_stay() from public, anon, authenticated, service_role;
revoke all on function private.line_words_have_approved_forms() from public, anon, authenticated, service_role;

-- Permissions -------------------------------------------------------------------
-- Remove everything the API roles could have been given by default, then grant
-- learners (the authenticated role) read access only. anon and service_role
-- get nothing.

revoke all on table public.units, public.dialogues, public.dialogue_lines, public.forms, public.tokens
  from anon, authenticated, service_role;
revoke all on sequence public.units_id_seq, public.dialogues_id_seq, public.dialogue_lines_id_seq,
  public.forms_id_seq, public.tokens_id_seq
  from anon, authenticated, service_role;

grant select on table public.units, public.dialogues, public.dialogue_lines, public.forms, public.tokens
  to authenticated;

-- Row level security: a learner reads only approved rows whose parents are
-- approved too.

alter table public.units enable row level security;
alter table public.dialogues enable row level security;
alter table public.dialogue_lines enable row level security;
alter table public.forms enable row level security;
alter table public.tokens enable row level security;

create policy "learners read approved units"
  on public.units
  for select
  to authenticated
  using (status = 'approved');

create policy "learners read approved dialogues in approved units"
  on public.dialogues
  for select
  to authenticated
  using (
    status = 'approved'
    and exists (
      select 1 from public.units u
      where u.id = dialogues.unit_id and u.status = 'approved'
    )
  );

create policy "learners read approved lines in approved dialogues"
  on public.dialogue_lines
  for select
  to authenticated
  using (
    status = 'approved'
    and exists (
      select 1
      from public.dialogues d
      join public.units u on u.id = d.unit_id
      where d.id = dialogue_lines.dialogue_id
        and d.status = 'approved'
        and u.status = 'approved'
    )
  );

create policy "learners read approved forms"
  on public.forms
  for select
  to authenticated
  using (status = 'approved');

create policy "learners read the tokens of approved lines"
  on public.tokens
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.dialogue_lines l
      join public.dialogues d on d.id = l.dialogue_id
      join public.units u on u.id = d.unit_id
      where l.id = tokens.line_id
        and l.status = 'approved'
        and d.status = 'approved'
        and u.status = 'approved'
    )
  );
