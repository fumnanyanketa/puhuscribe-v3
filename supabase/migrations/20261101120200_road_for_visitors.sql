-- Job 20-a1-road, round 4: visitors read the road with no progress.
-- Spec: factory/jobs/20-a1-road/spec.md, "Done when" 29 (the manager's amendment of 1 November 2026).
--
-- The day one screen shows the road (stop names, "Stop 1, N short lessons") to a visitor with no
-- account, and nothing may create a guest before Start. So public.road_for_visitors() gives the same
-- 14 columns as public.road(), where dialogues_done, review_forms_reviewed and lessons_done are 0.
--
-- It takes no user and never looks at one: there is no auth.uid() and no learner table in it, so it
-- cannot return any learner's progress, not even when learners have progress. It counts only approved
-- content, by the same rules the learner read policies apply (an approved dialogue in an approved
-- unit, an approved line, an approved form). Because the table policies are for learners only, it runs
-- with the rights of its owner (security definer, empty search path) and is granted to anon for this
-- function alone. The road tables themselves stay closed to anon. It writes nothing (stable). It holds
-- counts, stop names and "I can" sentences only: no Finnish text, no id, no personal data.
--
-- public.road() is unchanged and still callable by authenticated only.

create function public.road_for_visitors()
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
security definer
set search_path = ''
as $$
  with first_seen as (
    select distinct on (t.form_id) t.form_id as fid, u.stop_number as stop_n
      from public.tokens t
      join public.forms f on f.id = t.form_id and f.status = 'approved'
      join public.dialogue_lines l on l.id = t.line_id and l.status = 'approved'
      join public.dialogues d on d.id = l.dialogue_id and d.status = 'approved'
      join public.units u on u.id = d.unit_id and u.status = 'approved'
     where t.form_id is not null and u.stop_number is not null
     order by t.form_id, u.stop_number, d.position, l.position, t.position
  ),
  new_forms as (
    select fs.stop_n, count(*)::integer as total
      from first_seen fs
     group by fs.stop_n
  ),
  ready as (
    select u.stop_number as stop_n, count(*)::integer as n
      from public.dialogues d
      join public.units u on u.id = d.unit_id and u.status = 'approved'
     where d.status = 'approved' and u.stop_number is not null
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
         0,
         coalesce(nf.total, 0),
         0,
         4,
         0,
         coalesce(r.n, 0) = s.planned_dialogues
    from public.road_stops s
    join public.road_parts p on p.number = s.part_number
    left join ready r on r.stop_n = s.number
    left join new_forms nf on nf.stop_n = s.number
   order by s.number;
$$;

comment on function public.road_for_visitors() is
  'Job 20-a1-road: one row per stop of the A1 road for a visitor with no account: the same columns as road(), progress always 0. Approved content only, no user, security definer, writes nothing.';

revoke all on function public.road_for_visitors() from public, anon, authenticated, service_role;
grant execute on function public.road_for_visitors() to anon;
