# Security review: 10-speaking-feedback

Reviewed `git diff origin/main...HEAD` at b2a6a3e. Focused on the migration, `worker/speech.ts`, `worker/speech-db.ts`, `worker/recording-store.ts` and `worker/providers/speech-feedback.ts`.

## Findings

1. **should fix**: `worker/speech.ts:322-341`. The rate limit is checked before the call and the attempt is only written after Azure answers. Parallel requests all see the same count, so one learner can send far more than 40 paid checks in 10 minutes. Failed provider calls write no row and so never count either. Fix: reserve the slot before calling the provider, for example an insert-then-count in one statement or a per-user advisory lock in an RPC. At least, count the refused or failed calls too.
2. **note**: `supabase/migrations/20261020090100_learner_model.sql:160` (job 8). `authenticated` may insert `consents` directly with any `notice_version`, so the rule that the browser cannot choose the label only holds through the Worker. A learner can only mislabel their own rows. Consider a check or default on `notice_version`, or a trigger that sets it.
3. **note**: `supabase/migrations/20261022072903_speaking_feedback.sql:107-112, 160-165`. "Newest consent" orders by `created_at` only. Two rows of the same kind added in one transaction would tie. The Worker never does that today, but a tiebreaker (`id` is a uuid, so add a sequence or use `clock_timestamp()`) would make it certain.
4. **note**: there is no export path for `speaking_attempts` or `kept_recordings` in the Worker. Account deletion is covered by `on delete cascade`. Make sure job 11's export includes both tables, transcripts and recordings included.

## Checked and passing (owner may still want to look)

- RLS is on for both tables, all permissions are revoked and then column-scoped grants are added back. Insert checks consent on both tables (`with check`). Update can only set the transcript to empty. Kept recordings are capped at first and latest per line by a unique key. `keep_recording` is security invoker.
- Withdrawal trigger (`:185-202`): it runs with the learner's own rights in the same transaction as the consent insert. It deletes recordings, and for processing it also clears transcripts.
- 90 day pg_cron function (`:248-263`) runs as the owner and is revoked from the API roles.
- The say route reads the body with a cap first, checks the origin, and checks sign-in, consent, the session at `understand`, the line in the session's dialogue (read with the learner token) and a strict WAV check, all before the provider. The answer holds only the class and hint.
- The recording GET uses the learner token, returns 404 for other learners' ids, and sends `private, no-store` and `nosniff`.
- Provider: the Azure key and URL appear only in the provider module, regions are on an EU allow list, the fake is used only when set explicitly, and there are no `console` calls in the new Worker files.
- Look closely: `SPEECH_FEEDBACK_PROVIDER` is still missing from `.env.example` (build.md). Production must never set `fake`; the repository test covers `wrangler.jsonc` and the deploy workflows.
- Many guest accounts can multiply the per learner cap. This is job 8's open guest abuse decision.

Result: pass
