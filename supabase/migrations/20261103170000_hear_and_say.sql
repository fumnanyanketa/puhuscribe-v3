-- Hear it, say it (owner's fast route, 3 November 2026). The learner now says
-- each line back right after hearing it, in the session's first step, before
-- any step is stored (step_reached is still null). Until now an attempt for a
-- line needed the session at Understand it or later, so the first step could
-- not store one.
--
-- This changes one condition of one rule: a line attempt may also belong to a
-- session that has reached no step yet. Everything else stays as job
-- 10-speaking-feedback made it: the learner's own id, their newest
-- voice_processing consent a grant, their own session, a line of that
-- session's dialogue (the lines read rule hides anything not approved), or a
-- form they hold a card for. A session that has stored "hear" (the learner is
-- in Understand it) is still refused. No grant changes: the API roles keep
-- exactly the column grants of 20261022072903_speaking_feedback.sql, and row
-- level security stays on.

alter policy "learners add attempts with voice consent"
  on public.speaking_attempts
  with check (
    user_id = (select auth.uid())
    and coalesce((
      select c.granted from public.consents c
       where c.user_id = (select auth.uid()) and c.kind = 'voice_processing'
       order by c.created_at desc
       limit 1
    ), false)
    and (
      (
        speaking_attempts.line_id is not null
        and exists (
          select 1
            from public.sessions s
            join public.dialogue_lines l on l.dialogue_id = s.dialogue_id
           where s.id = speaking_attempts.session_id
             and s.user_id = (select auth.uid())
             and (s.step_reached is null or s.step_reached >= 'understand')
             and l.id = speaking_attempts.line_id
        )
      )
      or (
        speaking_attempts.form_id is not null
        and exists (
          select 1 from public.cards k
           where k.user_id = (select auth.uid()) and k.form_id = speaking_attempts.form_id
        )
      )
    )
  );
