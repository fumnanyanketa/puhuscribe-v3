# Job 3-data-model: security and privacy review, rounds 2 and 3

Reviewer: security. 20 October 2026. Branch `factory/3-data-model`, tip `2a21230`. I reviewed the full `git diff main...HEAD`, and looked most closely at `git diff d6e8724..2a21230`, the changes since round 1. No `.env*` file was read or searched. Nothing was run against Cloudflare or Supabase.

## Summary

Nothing must be fixed. The three new trigger functions do not run with raised rights. Learners cannot call them, and they add no new way to read another learner's rows or unapproved content. The test that switches off a check does so only inside its rolled-back transaction, and the check is switched back on straight away. The new API timing lines cannot hold a secret or personal data. Two round 1 items are fixed. The third, a GitHub Environment for the test database secret, is deferred by the owner.

## Round 1, in short

Result was pass, with three should-fix items:

1. **The main-only rule for the test database can be bypassed by a branch** (`.github/workflows/checks.yml:188`). Still open. The owner decided to stay on GitHub Free for now and revisit this before real learners arrive. GitHub Environments on a private repository need GitHub Pro or Team. Until then, any branch in the repository that edits the workflow can still reach `SUPABASE_TEST_DB_URL`.
2. **No length limit on `consents.notice_version`.** Fixed. `20261020090100_learner_model.sql:86` now allows only `^[A-Za-z0-9._-]{1,32}$`. pgTAP refuses 33 characters, a space, a line break, an empty value and a semicolon, and accepts 32 characters and a mixed label.
3. **Card-creation tests missing for paths that depend on nested rules.** Fixed. Learner C reaches `understand` and is refused cards for:
   - a form found only on a retired line;
   - a draft form used by an approved line;
   - a form found only on a draft line inside an approved dialogue;
   - a form of a dialogue retired after the session started.

Round 1 notes 4 to 7 still apply unchanged:

- A learner sets their own session step and review rating, so those rules depend on the app behaving.
- Re-approval does not force a new `approval_ref` (for job 5).
- Once anonymous sign-ins are on, guests can insert rows without limit (for jobs 6 and 9).
- An approved form is readable even if no approved line uses it.

## Findings, rounds 2 and 3

### Must fix

None.

### Should fix

None.

### Notes

1. **Turning off the dialogue check locks the `dialogues` table for the whole test.** `supabase/tests/database/data_model_content.test.sql:94-97` and `data_model_learners.test.sql:78-81`.
   - `alter table ... disable trigger` is transactional, so a failed or finished test always restores the trigger. No other session ever sees it switched off.
   - It does take an exclusive lock on `dialogues` until the test file rolls back. When the tests run on the hosted test project at merge, anything reading `dialogues` there waits a few seconds. That is harmless while no app reads the table.
   - In the content test, the later "a dialogue with a draft line cannot be approved" tests fail if the trigger is left off, so turning it back on is proven there.
   - Optional: a catalogue test that every trigger on the content tables is enabled (`pg_trigger.tgenabled = 'O'`). It would also catch a future migration that leaves one switched off.

2. **"A line's words link only to approved forms" is checked only when the line is approved.** `20261020090000_content_model.sql:286-305`. A form can be set back to draft after a line using it is approved. The learners test does this on purpose with `set-to-draft-later`. The form is then hidden and cannot get a card, so this fails closed. It is not a leak. Job 5 should know the rule is checked once, at approval.

3. **No test refuses a security definer function.** `data_model_schema.test.sql` already checks that every `private` function has an empty `search_path`. Adding `is_empty(select proname from pg_proc where pronamespace in ('public'::regnamespace, 'private'::regnamespace) and prosecdef)` would stop a future function from quietly running with raised rights. Today none exists.

## Look at closely even though it passes

- **New trigger functions.** These are `approved_dialogue_is_whole`, `lines_of_approved_dialogues_stay` and `line_words_have_approved_forms` (`20261020090000_content_model.sql:224-315`).
  - All three run with the caller's rights, not as security definer.
  - They live in `private`, which the API does not expose, have `search_path = ''`, and have `execute` revoked from `public`, `anon`, `authenticated` and `service_role`.
  - They only refuse writes and never return data.
  - Learners have no write permission on content, so in practice these triggers fire only for migrations.
  - The existing catalogue test covers their `search_path`.
- **The whole-dialogue rules.** pgTAP refuses each of these:
  - approving a dialogue with no approved line;
  - approving a dialogue with a draft line;
  - adding a line to an approved dialogue;
  - moving a line into an approved dialogue;
  - changing a line's status while its dialogue is approved;
  - approving a line whose word links to a draft or retired form.

  Un-approving and approving again in the right order still works.
- **No new way to read data.** The read rules, grants and learner rules are unchanged since round 1, apart from the `notice_version` check. `units.title_fi` was removed, and the column-list test, the generated types and the docs follow.
- **The `why_en` limit** (one line, at most 140 characters) applies to content written by migrations only. A learner cannot write it.
- **API timing lines** (`e2e/api-timing.ts`).
  - Each line holds the method, the URL path only (no host, no query string), the status, the browser project name, the milliseconds and the test title.
  - No headers or bodies, and so no Access token or publishable key.
  - Today the paths are `/api/visits` and `/api/health`, which hold no learner data.
  - If a later job adds paths that contain an id, those ids would appear in CI logs. Only test data exists there, so this is fine.
- **Worker save limit** (`worker/api.ts:77-81`). It changed from 3 to 8 seconds, still under the page's 10. Nothing new is logged, and request body checks and the JSON-only rule are unchanged.
- **Still unproven:** the first run on the hosted test project, at merge, including whether the hosted database lets the tests insert their three test users and switch the trigger off as table owner.

Result: pass
