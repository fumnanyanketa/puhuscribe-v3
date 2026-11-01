-- Job 20-a1-road, part 1: the A1 road in the database.
-- Spec: factory/jobs/20-a1-road/spec.md, "Done when" 1 to 6.
-- Plain English description: docs/data-model.md.
--
-- The road is 6 parts and 36 stops (docs/curriculum-a1.md). Each stop has its English name and its
-- "I can" sentence. A unit is the stop's published content (its dialogues). The rows of the two
-- road tables come from the next migration, made by scripts/generate/road_sql.py.
--
-- Both road tables hold English text only: no Finnish and no learner data. A learner may read them
-- (the road screen shows stops that are not live yet); nobody writes them through the API.
--
-- Two functions run with the learner's own rights (security invoker): public.road() counts the
-- caller's progress per stop, and public.stop_review_forms(stop) lists the words of a stop's review
-- lesson. Neither writes anything, and neither returns a Finnish word, a line or another learner's id.
--
-- Forms get two English texts for the word card: what this word form means (meaning_en) and what its
-- dictionary form means (lemma_meaning_en). Approving a form needs both.

-- The road tables -------------------------------------------------------------------

-- Later legs (A2 and beyond) add parts and stops past 6 and 36 with a new migration.
create table public.road_parts (
  number integer primary key check (number > 0),
  title_en text not null check (btrim(title_en) <> '')
);

create table public.road_stops (
  number integer primary key check (number > 0),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  part_number integer not null references public.road_parts (number) on delete restrict,
  name_en text not null check (btrim(name_en) <> ''),
  can_do_en text not null check (btrim(can_do_en) <> ''),
  planned_dialogues integer not null default 3 check (planned_dialogues > 0)
);

comment on table public.road_parts is
  'A1 road (job 20-a1-road): the parts of the road, English titles only.';
comment on table public.road_stops is
  'A1 road (job 20-a1-road): the stops of the road with their English names and I can sentences, English only.';

create index road_stops_part_number_idx on public.road_stops (part_number);

-- A unit may be a stop's content ----------------------------------------------------

-- stop_number is empty for units that are not on the road (the test fixture units). When set it is
-- the unit's position, so the road order and the unit order are one order.
alter table public.units
  add column stop_number integer unique references public.road_stops (number) on delete restrict;
alter table public.units
  add constraint units_stop_number_is_position check (stop_number is null or stop_number = position);

-- The word card texts of a form -----------------------------------------------------

-- The migration changes the approval rule of forms, so it refuses to run on a database that already
-- holds approved forms: they would have no meaning. Today no database does.
do $guard$
begin
  if exists (select 1 from public.forms where status = 'approved') then
    raise exception 'approved forms exist without the two meaning texts: add them first';
  end if;
end
$guard$;

alter table public.forms
  add column meaning_en text
    check (meaning_en !~ '[[:cntrl:]]' and char_length(meaning_en) <= 60),
  add column lemma_meaning_en text
    check (lemma_meaning_en !~ '[[:cntrl:]]' and char_length(lemma_meaning_en) <= 60);

alter table public.forms drop constraint forms_approval_complete;
alter table public.forms add constraint forms_approval_complete check (
  status <> 'approved'
  or (
    coalesce(btrim(form_name_en), '') <> ''
    and coalesce(btrim(why_en), '') <> ''
    and coalesce(btrim(meaning_en), '') <> ''
    and coalesce(btrim(lemma_meaning_en), '') <> ''
    and approved_at is not null
    and coalesce(btrim(approval_ref), '') <> ''
  )
);

-- Access to the road tables -----------------------------------------------------------

revoke all on table public.road_parts, public.road_stops from anon, authenticated, service_role;
grant select on table public.road_parts, public.road_stops to authenticated;

alter table public.road_parts enable row level security;
alter table public.road_stops enable row level security;

create policy "learners read the road parts"
  on public.road_parts
  for select
  to authenticated
  using (true);

create policy "learners read the road stops"
  on public.road_stops
  for select
  to authenticated
  using (true);

-- public.road(): one row per stop ------------------------------------------------------

-- Always every stop in stop order, with zero counts where nothing is published yet. A stop's new
-- forms are the forms whose first readable line, ordered by stop, dialogue and line, is in that
-- stop. Every table below is read with the learner's own rights, so an unapproved dialogue, line or
-- form is never counted, and only the caller's own sessions and review logs are.
create function public.road()
returns table (
  stop_number integer,
  stop_slug text,
  title_en text,
  can_do_en text,
  part_number integer,
  part_title_en text,
  dialogues_total integer,
  dialogues_ready integer,
  dialogues_done integer,
  review_forms_total integer,
  review_forms_reviewed integer,
  lessons_total integer,
  lessons_done integer,
  live boolean
)
language sql
stable
security invoker
set search_path = ''
as $$
  with first_seen as (
    select distinct on (t.form_id) t.form_id as fid, u.stop_number as stop_n
      from public.tokens t
      join public.forms f on f.id = t.form_id
      join public.dialogue_lines l on l.id = t.line_id
      join public.dialogues d on d.id = l.dialogue_id
      join public.units u on u.id = d.unit_id
     where t.form_id is not null and u.stop_number is not null
     order by t.form_id, u.stop_number, d.position, l.position, t.position
  ),
  new_forms as (
    select fs.stop_n,
           count(*)::integer as total,
           (count(*) filter (
              where exists (
                select 1 from public.review_logs r
                 where r.user_id = (select auth.uid()) and r.form_id = fs.fid
              )
           ))::integer as reviewed
      from first_seen fs
     group by fs.stop_n
  ),
  ready as (
    select u.stop_number as stop_n, count(*)::integer as n
      from public.dialogues d
      join public.units u on u.id = d.unit_id
     where u.stop_number is not null
     group by u.stop_number
  ),
  done as (
    select u.stop_number as stop_n, count(distinct se.dialogue_id)::integer as n
      from public.sessions se
      join public.dialogues d on d.id = se.dialogue_id
      join public.units u on u.id = d.unit_id
     where se.user_id = (select auth.uid())
       and se.ended_at is not null
       and u.stop_number is not null
     group by u.stop_number
  )
  select s.number,
         s.slug,
         s.name_en,
         s.can_do_en,
         s.part_number,
         p.title_en,
         s.planned_dialogues,
         coalesce(r.n, 0),
         coalesce(dn.n, 0),
         coalesce(nf.total, 0),
         coalesce(nf.reviewed, 0),
         4,
         coalesce(dn.n, 0)
           + case when coalesce(nf.total, 0) > 0 and coalesce(nf.reviewed, 0) = coalesce(nf.total, 0)
                  then 1 else 0 end,
         coalesce(r.n, 0) = s.planned_dialogues
    from public.road_stops s
    join public.road_parts p on p.number = s.part_number
    left join ready r on r.stop_n = s.number
    left join done dn on dn.stop_n = s.number
    left join new_forms nf on nf.stop_n = s.number
   order by s.number;
$$;

comment on function public.road() is
  'Job 20-a1-road: one row per stop of the A1 road with the caller''s lesson progress. Counts only, security invoker, writes nothing.';

-- public.stop_review_forms(stop): the words of a stop's review lesson -----------------------

-- The ids of the stop's new forms, in order of first appearance, that the caller holds a card for
-- and has met in a finished session. A form met only in a session that never finished, a form first
-- met in an earlier stop and another learner's card are never returned.
create function public.stop_review_forms(p_stop_number integer)
returns table (form_id bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  with seen as (
    select t.form_id as fid,
           u.stop_number as stop_n,
           d.position as dpos,
           l.position as lpos,
           t.position as tpos,
           row_number() over (
             partition by t.form_id order by u.stop_number, d.position, l.position, t.position
           ) as rn
      from public.tokens t
      join public.forms f on f.id = t.form_id
      join public.dialogue_lines l on l.id = t.line_id
      join public.dialogues d on d.id = l.dialogue_id
      join public.units u on u.id = d.unit_id
     where t.form_id is not null and u.stop_number is not null
  )
  select sn.fid
    from seen sn
   where sn.rn = 1
     and sn.stop_n = p_stop_number
     and exists (
       select 1 from public.cards c
        where c.user_id = (select auth.uid()) and c.form_id = sn.fid
     )
     and exists (
       select 1
         from public.sessions se
         join public.dialogue_lines l2 on l2.dialogue_id = se.dialogue_id
         join public.tokens t2 on t2.line_id = l2.id
        where se.user_id = (select auth.uid())
          and se.ended_at is not null
          and t2.form_id = sn.fid
     )
   order by sn.dpos, sn.lpos, sn.tpos;
$$;

comment on function public.stop_review_forms(integer) is
  'Job 20-a1-road: the form ids of a stop''s review lesson: its new forms the caller holds a card for and met in a finished session. Security invoker, writes nothing.';

-- Permissions of the functions: learners only ---------------------------------------------

revoke all on function public.road() from public, anon, authenticated, service_role;
grant execute on function public.road() to authenticated;

revoke all on function public.stop_review_forms(integer) from public, anon, authenticated, service_role;
grant execute on function public.stop_review_forms(integer) to authenticated;
