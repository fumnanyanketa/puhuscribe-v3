-- Job 8-first-session: the factory smoke test page is retired.
-- Spec: factory/jobs/8-first-session/spec.md, "Done when" 21.
--
-- The "Hei!" page of job 2-smoke saved one row in public.visits on every page
-- load. The front door of the app replaces that page, so nothing writes to or
-- reads from visits any more. docs/data-model.md planned this removal for this
-- job. The table held only an id and a time, never anything about a visitor.

drop table public.visits;
