-- Fast route review-links: one private review link per send, for the people who
-- signed up at meetaleksi.com/reviewers, and the answers they give line by line.
-- Spec: factory/jobs/review-links/spec.md, "Done when" 1 to 6 and 9.
-- Plain English description: docs/data-model.md, "Review links".
--
-- What is new:
--   private.review_links        one row per link sent: the sign up, the batch (1 to 4), the hash of
--                               the link's secret, when it was sent, and the answer count of the minute
--   private.review_answers      one answer per link and line: correct, needs_fix or not_sure, and a
--                               note of at most 500 characters for needs_fix
--   private.review_batch_dialogues()   the published road dialogues in road order, split into batches
--   private.review_token_hash(text)    the sha256 hash of a well formed secret, or null
--   public.review_link_overview(text)               the batch's dialogues and progress (anon only)
--   public.review_link_dialogue(text, bigint)       one dialogue of the batch with its lines (anon only)
--   public.review_link_answer(text, bigint, text, text)  saves one answer (anon only)
--   public.owner_create_review_link(uuid, integer, text) records a new link (owner only)
--   public.owner_delete_review_link(uuid)           removes a link whose email was not sent (owner only)
--   public.owner_review_overview()                  every link with its progress, and every
--                                                   "needs_fix" and "not_sure" answer (owner only)
--
-- The secret. The Worker makes a random 256 bit secret for each link (43 base64url characters) and
-- puts it only in the reviewer's email. The database keeps only its sha256 hash: every function that
-- takes a secret hashes it first and looks the hash up, so a copy of the table does not open a link.
-- A wrong, deleted or malformed secret gets the same answer (null), so nobody can tell from the
-- answer whether a reviewer exists.
--
-- The batches. The published dialogues (an approved dialogue in an approved unit on the road, the
-- same rule as public.road_for_visitors) in the order a learner meets them: by stop, then by the
-- dialogue's place in its stop. The first 27 are batch 1, the next 27 batch 2, the next 27 batch 3,
-- and batch 4 takes the rest. Nothing is typed by hand: publishing a new dialogue moves the batches.
--
-- Deleting a sign up (public.owner_delete_reviewer_signup) deletes its links, and deleting a link
-- deletes its answers (on delete cascade), so the link stops working and the answers are gone.
--
-- Both tables are in the private schema, which the API roles cannot reach, and every API role's
-- rights on them are revoked in writing. The browser roles get nothing on them. The Worker holds only
-- the publishable key, so it reads and writes as anon through the three review_link functions, which
-- check the secret, the batch, the answer and the note. The owner works through three functions that
-- answer only an account on private.owners with a live sign in, as owner_dashboard() does.
-- Postgres lets everyone (PUBLIC) run a new function; each one below has that revoked in writing.

-- The tables -------------------------------------------------------------------------------

create table private.review_links (
  id uuid primary key default gen_random_uuid(),
  signup_id uuid not null references private.reviewer_signups (id) on delete cascade,
  batch integer not null check (batch between 1 and 4),
  token_hash text not null unique check (token_hash ~ '^[0-9a-f]{64}$'),
  sent_at timestamptz not null default now(),
  -- The answers saved in the current minute, for the limit in review_link_answer.
  minute_start timestamptz,
  minute_count integer not null default 0 check (minute_count >= 0)
);

comment on table private.review_links is
  'Fast route review-links: one private review link per send. Only the hash of the link secret is kept. Deleted with its sign up.';

create index review_links_signup_id_idx on private.review_links (signup_id);

revoke all on table private.review_links from public, anon, authenticated, service_role;
alter table private.review_links enable row level security;
-- No rule is made: no API role may read or write the rows directly.

create table private.review_answers (
  link_id uuid not null references private.review_links (id) on delete cascade,
  line_id bigint not null references public.dialogue_lines (id) on delete restrict,
  answer text not null check (answer in ('correct', 'needs_fix', 'not_sure')),
  note text
    check (note is null
           or (answer = 'needs_fix' and char_length(note) between 1 and 500 and note = btrim(note)
               and replace(note, E'\n', '') !~ '[[:cntrl:]]')),
  answered_at timestamptz not null default now(),
  primary key (link_id, line_id)
);

comment on table private.review_answers is
  'Fast route review-links: a reviewer''s answer for one line, through one link. Kept until the owner deletes the sign up.';

create index review_answers_line_id_idx on private.review_answers (line_id);
create index review_answers_answered_at_idx on private.review_answers (answered_at);

revoke all on table private.review_answers from public, anon, authenticated, service_role;
alter table private.review_answers enable row level security;
-- No rule is made: no API role may read or write the rows directly.

-- The helpers ------------------------------------------------------------------------------

create function private.review_batch_dialogues()
returns table (dialogue_id bigint, batch integer, batch_position integer)
language sql
stable
set search_path = ''
as $$
  with ordered as (
    select d.id,
           (row_number() over (order by u.stop_number, d.position, d.id))::integer as n
      from public.dialogues d
      join public.units u on u.id = d.unit_id and u.status = 'approved'
     where d.status = 'approved' and u.stop_number is not null
  ), batched as (
    select o.id, o.n, least(4, ((o.n - 1) / 27) + 1) as batch from ordered o
  )
  select b.id, b.batch, b.n - (b.batch - 1) * 27 from batched b
$$;

comment on function private.review_batch_dialogues() is
  'Fast route review-links: the published road dialogues in road order, 27 to a batch, batch 4 taking the rest.';

revoke all on function private.review_batch_dialogues() from public, anon, authenticated, service_role;

create function private.review_token_hash(p_token text)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when p_token ~ '^[A-Za-z0-9_-]{43}$' then encode(sha256(convert_to(p_token, 'UTF8')), 'hex')
  end
$$;

comment on function private.review_token_hash(text) is
  'Fast route review-links: the sha256 hash (hex) of a well formed link secret, or null for any other text.';

revoke all on function private.review_token_hash(text) from public, anon, authenticated, service_role;

-- The reviewer's three doors (anon, from the Worker) ----------------------------------------

create function public.review_link_overview(p_token text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_link private.review_links%rowtype;
begin
  select * into v_link from private.review_links r where r.token_hash = private.review_token_hash(p_token);
  if not found then
    return null;
  end if;
  return jsonb_build_object(
    'batch', v_link.batch,
    'dialogues', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', d.id,
               'position', b.batch_position,
               'title', d.title_en,
               'stop', u.title_en,
               'lines', (select count(*) from public.dialogue_lines l
                          where l.dialogue_id = d.id and l.status = 'approved'),
               'answered', (select count(*) from private.review_answers a
                              join public.dialogue_lines l on l.id = a.line_id
                             where a.link_id = v_link.id and l.dialogue_id = d.id and l.status = 'approved'))
             order by b.batch_position)
        from private.review_batch_dialogues() b
        join public.dialogues d on d.id = b.dialogue_id
        join public.units u on u.id = d.unit_id
       where b.batch = v_link.batch), '[]'::jsonb));
end;
$$;

comment on function public.review_link_overview(text) is
  'Fast route review-links: the dialogues of the link''s batch with each one''s line and answer counts. Null for a wrong, deleted or malformed secret.';

revoke all on function public.review_link_overview(text) from public, anon, authenticated, service_role;
grant execute on function public.review_link_overview(text) to anon;

create function public.review_link_dialogue(p_token text, p_dialogue_id bigint)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_link private.review_links%rowtype;
  v_position integer;
  v_of integer;
begin
  select * into v_link from private.review_links r where r.token_hash = private.review_token_hash(p_token);
  if not found then
    return null;
  end if;
  select b.batch_position into v_position from private.review_batch_dialogues() b
   where b.dialogue_id = p_dialogue_id and b.batch = v_link.batch;
  if v_position is null then
    return null;
  end if;
  select count(*) into v_of from private.review_batch_dialogues() b where b.batch = v_link.batch;
  return (
    select jsonb_build_object(
             'id', d.id,
             'position', v_position,
             'of', v_of,
             'title', d.title_en,
             'stop', u.title_en,
             'previous', (select b.dialogue_id from private.review_batch_dialogues() b
                           where b.batch = v_link.batch and b.batch_position = v_position - 1),
             'next', (select b.dialogue_id from private.review_batch_dialogues() b
                       where b.batch = v_link.batch and b.batch_position = v_position + 1),
             'lines', coalesce((
               select jsonb_agg(jsonb_build_object(
                        'id', l.id,
                        'position', l.position,
                        'speaker', l.speaker,
                        'spoken', l.text_puhe,
                        'written', l.text_kirja,
                        'english', l.gloss_en,
                        'spoken_audio', l.audio_puhe_key,
                        'written_audio', l.audio_kirja_key,
                        'answer', a.answer,
                        'note', a.note)
                      order by l.position)
                 from public.dialogue_lines l
                 left join private.review_answers a on a.line_id = l.id and a.link_id = v_link.id
                where l.dialogue_id = d.id and l.status = 'approved'), '[]'::jsonb))
      from public.dialogues d
      join public.units u on u.id = d.unit_id
     where d.id = p_dialogue_id);
end;
$$;

comment on function public.review_link_dialogue(text, bigint) is
  'Fast route review-links: one dialogue of the link''s batch, its approved lines with their texts, audio keys and this link''s answers. Null for a wrong secret or a dialogue outside the batch.';

revoke all on function public.review_link_dialogue(text, bigint) from public, anon, authenticated, service_role;
grant execute on function public.review_link_dialogue(text, bigint) to anon;

-- Saves one answer. Refuses (raises 22023, writing nothing) an answer that is not one of the three,
-- or a note longer than 500 characters or with control characters other than a line break. A note
-- is kept only with needs_fix; an empty note is kept as none. Then it answers:
--   'no_link'       for a wrong, deleted or malformed secret
--   'limit'         when this link already saved 60 answers in the current minute
--   'not_in_batch'  for a line that is not an approved line of a dialogue in the link's batch
--   'saved'         when the answer is saved; a second answer for the same line replaces the first.
-- The minute's count is kept on the link's row, which is locked while it is counted, so parallel
-- calls cannot beat the limit.
create function public.review_link_answer(p_token text, p_line_id bigint, p_answer text, p_note text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_link private.review_links%rowtype;
  v_note text := nullif(btrim(p_note), '');
begin
  if p_answer is null or p_answer not in ('correct', 'needs_fix', 'not_sure') then
    raise exception 'bad answer' using errcode = '22023';
  end if;
  if p_answer <> 'needs_fix' then
    v_note := null;
  end if;
  if v_note is not null and (char_length(v_note) > 500 or replace(v_note, E'\n', '') ~ '[[:cntrl:]]') then
    raise exception 'bad note' using errcode = '22023';
  end if;

  select * into v_link from private.review_links r
   where r.token_hash = private.review_token_hash(p_token)
     for update;
  if not found then
    return 'no_link';
  end if;
  if v_link.minute_start is null or v_link.minute_start <= now() - interval '1 minute' then
    update private.review_links set minute_start = now(), minute_count = 1 where id = v_link.id;
  elsif v_link.minute_count >= 60 then
    return 'limit';
  else
    update private.review_links set minute_count = minute_count + 1 where id = v_link.id;
  end if;

  if not exists (
    select 1 from public.dialogue_lines l
      join private.review_batch_dialogues() b on b.dialogue_id = l.dialogue_id
     where l.id = p_line_id and l.status = 'approved' and b.batch = v_link.batch) then
    return 'not_in_batch';
  end if;

  insert into private.review_answers (link_id, line_id, answer, note)
  values (v_link.id, p_line_id, p_answer, v_note)
  on conflict (link_id, line_id) do update
    set answer = excluded.answer, note = excluded.note, answered_at = now();
  return 'saved';
end;
$$;

comment on function public.review_link_answer(text, bigint, text, text) is
  'Fast route review-links: saves or replaces one answer for a line of the link''s batch, at most 60 a minute per link. Called by the Worker as anon.';

revoke all on function public.review_link_answer(text, bigint, text, text) from public, anon, authenticated, service_role;
grant execute on function public.review_link_answer(text, bigint, text, text) to anon;

-- The owner's three functions ----------------------------------------------------------------
-- Each answers only an account on the owner list whose sign in is still live (the same two
-- conditions as public.owner_dashboard()); anyone else gets null.

-- Records a new link for a sign up and returns the name and email the Worker sends it to:
-- {"found": false} when there is no such sign up. The Worker makes the secret; only its hash is kept.
create function public.owner_create_review_link(p_signup_id uuid, p_batch integer, p_token text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_hash text := private.review_token_hash(p_token);
  v_signup private.reviewer_signups%rowtype;
  v_link private.review_links%rowtype;
begin
  if not exists (select 1 from private.owners o where o.user_id = (select auth.uid())) then
    return null;
  end if;
  if not private.sign_in_is_live() then
    return null;
  end if;
  if p_batch is null or p_batch not between 1 and 4 then
    raise exception 'bad batch' using errcode = '22023';
  end if;
  if v_hash is null then
    raise exception 'bad secret' using errcode = '22023';
  end if;
  select * into v_signup from private.reviewer_signups s where s.id = p_signup_id;
  if not found then
    return jsonb_build_object('found', false);
  end if;
  insert into private.review_links (signup_id, batch, token_hash)
  values (v_signup.id, p_batch, v_hash)
  returning * into v_link;
  return jsonb_build_object(
    'found', true,
    'id', v_link.id,
    'batch', v_link.batch,
    'sent_at', v_link.sent_at,
    'name', v_signup.name,
    'email', v_signup.email);
end;
$$;

comment on function public.owner_create_review_link(uuid, integer, text) is
  'Fast route review-links: records a new review link (its batch and the hash of its secret) for one sign up, for the owner with a live sign in; null for anyone else.';

revoke all on function public.owner_create_review_link(uuid, integer, text) from public, anon, authenticated, service_role;
grant execute on function public.owner_create_review_link(uuid, integer, text) to authenticated;

create function public.owner_delete_review_link(p_link_id uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_count bigint;
begin
  if not exists (select 1 from private.owners o where o.user_id = (select auth.uid())) then
    return null;
  end if;
  if not private.sign_in_is_live() then
    return null;
  end if;
  delete from private.review_links r where r.id = p_link_id;
  get diagnostics v_count = row_count;
  return v_count > 0;
end;
$$;

comment on function public.owner_delete_review_link(uuid) is
  'Fast route review-links: deletes one review link and its answers (used when its email could not be sent), for the owner with a live sign in; null for anyone else.';

revoke all on function public.owner_delete_review_link(uuid) from public, anon, authenticated, service_role;
grant execute on function public.owner_delete_review_link(uuid) to authenticated;

create function public.owner_review_overview()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not exists (select 1 from private.owners o where o.user_id = (select auth.uid())) then
    return null;
  end if;
  if not private.sign_in_is_live() then
    return null;
  end if;
  return jsonb_build_object(
    'links', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', r.id,
               'signup_id', r.signup_id,
               'batch', r.batch,
               'sent_at', r.sent_at,
               'lines', (select count(*) from public.dialogue_lines l
                           join private.review_batch_dialogues() b on b.dialogue_id = l.dialogue_id
                          where b.batch = r.batch and l.status = 'approved'),
               'answered', (select count(*) from private.review_answers a where a.link_id = r.id))
             order by r.sent_at desc, r.id)
        from private.review_links r), '[]'::jsonb),
    'answers', coalesce((
      select jsonb_agg(jsonb_build_object(
               'link_id', a.link_id,
               'line_id', a.line_id,
               'answer', a.answer,
               'note', a.note,
               'answered_at', a.answered_at,
               'name', s.name,
               'dialogue', d.title_en,
               'position', l.position,
               'speaker', l.speaker,
               'spoken', l.text_puhe,
               'written', l.text_kirja,
               'english', l.gloss_en)
             order by a.answered_at desc, a.link_id, a.line_id)
        from private.review_answers a
        join private.review_links r on r.id = a.link_id
        join private.reviewer_signups s on s.id = r.signup_id
        join public.dialogue_lines l on l.id = a.line_id
        join public.dialogues d on d.id = l.dialogue_id
       where a.answer in ('needs_fix', 'not_sure')), '[]'::jsonb));
end;
$$;

comment on function public.owner_review_overview() is
  'Fast route review-links: every review link with its batch, time and answer count, and every needs_fix and not_sure answer newest first, for the owner with a live sign in; null for anyone else.';

revoke all on function public.owner_review_overview() from public, anon, authenticated, service_role;
grant execute on function public.owner_review_overview() to authenticated;
