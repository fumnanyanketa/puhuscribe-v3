-- Job 16-tutor-step (the tutor, Otso): the new consent value for talking with Otso.
-- Spec: factory/jobs/16-tutor-step/spec.md, "Done when" 5 and 22.
--
-- A new enum value cannot be used in the same transaction that adds it, and each migration file
-- runs in its own transaction, so the value is added here, one file before the table and the rules
-- that use it (20261103140100_tutor_calls.sql).

alter type public.consent_kind add value if not exists 'ai_tutor';
