# Security review: 9-daily-review

Reviewed head d901807 against origin/main.

## Findings

None of severity must fix or should fix.

- note: supabase/migrations/20261022072901_daily_review.sql:118-129 (record_review). The function finds the card by `form_id` only and relies on the cards update rule (learner_model.sql:230) to limit it to the caller's card. That is correct while it stays security invoker, and the pgTAP test plus the red security definer scratch run prove it. If anyone ever changes it to security definer, it would update another learner's card. Optional extra guard: add `and c.user_id = (select auth.uid())` to the update.
- note: record_review takes all the scheduler values from the caller, so a signed-in learner calling the RPC directly with their own token can set their own card values. This only affects their own data, and the cards update rule from job 8 already allowed it. No cross-learner risk.

## Checked and passing

- review_queue and next_review_day: security invoker, `search_path = ''`, filter on `auth.uid()`, join forms under the forms read rule (approved only), limit capped at 15 and kept at 0 or above. Execute revoked from public/anon/service_role and granted only to authenticated (migration lines 155-170).
- Row rules: cards and review_logs select, update and insert are all `user_id = auth.uid()`. The log insert uses the owner of the updated card, so it passes the insert check only for the caller.
- Worker routes (worker/api.ts): GET items uses refuseNonGet. POST answer and done use refuseUnsafeWrite (method, origin, body). All three need a signed-in learner, and every database call uses the learner's own client. parseAnswer (worker/review.ts) requires an exact set of keys, a UUID, a safe integer id, text of at most 100 characters and kind = typed. The session id in the path is regex checked.
- Draft content: lines, tokens and forms are read with the learner's token, so job 3's approved-only read rules apply. The test sets a form back to draft and confirms it leaves the queue.
- Browser: no new innerHTML, storage, logging or third-party calls, and no new dependencies.

## Owner should look closely

- record_review depends on staying security invoker (see first note).
- Typed answer text is sent to the Worker for grading only and is not stored. Confirm that matches what you want, since no review log column holds it.

Result: pass
