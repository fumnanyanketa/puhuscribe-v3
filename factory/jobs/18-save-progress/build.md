# Build notes: 18-save-progress, round 2

Branch `factory/18-save-progress`, pushed to origin. No pull request was opened. Round 2 is the owner's one wording change after approval, the evaluator's small gap, and the evidence files. Round 1 is summarised at the end.

## Round 2

### What changed, in plain English

- **The owner's change ("...on this device").** On the finish screen a guest now sees "Your progress is saved on this device." in the bottom bar. A learner with an email keeps "Your progress is saved." exactly as before. The note sentence, its place below the learned line and its buttons did not change.
- **How the screen knows.** After the save succeeded, the finish screen asks `GET /api/me`, the route job 11's account page already uses, and shows the new line only when it answers "guest". If that request fails or the answer is anything else, the screen shows the plain line. This is one extra request to a route that already exists; no Worker change and no new route. The words are `SAVED_ON_THIS_DEVICE` in `src/screens/save-note-copy.ts`, next to the other note words, and the pure check of the answer is `accountKindOf` in `src/screens/save-note.ts`. The line is also checked by the writing rules test (33 words in all now, under the 40 limit).
- **Spec and design.** One line in the spec's "Note wording" section (the worktree copy) says it is the owner's choice of 1 November 2026, and `design.md` has the status line in the "Save progress note" entry. I labelled the new tests `[save-progress 19]`, because the spec numbers stop at 18.
- **The evaluator's gap.** The "Not now" browser test now also asserts that the browser holds at least one `puhuscribe-auth` cookie, before it asserts that every cookie is one.
- **Evidence kept.** The design reviewer's and the evaluator's files (`design-review-*.png`, `eval-*.png`, `eval-browser-checks.txt`, `eval-vitest-local.txt`, `eval-main-path-chromium.webm`) are committed in `factory/jobs/18-save-progress/evidence/`. I scanned all 51 for email addresses, tokens, keys, `Bearer`, `Authorization`, passwords and cookie values (text, and the raw bytes of the images and the video) and found none. I also looked at the one screenshot of the add email screen: its address field is empty. The commit hook ran the secret scan on them too.

### Long learned line (for the record)

With a learned line of three or four lines the note sits below the visible area of the finish screen, and the learner scrolls to see it (see `design-review-finish-*-long.png`). With short lines it is fully visible. The owner chose to keep the note below ("Keep it below (Recommended)"), so the spacing does not change.

### Tests

- `[save-progress 19]`, `e2e/save-progress.spec.ts` (`@email`, both browsers): a guest sees exactly "Your progress is saved on this device." with the note; the same learner after adding an email sees exactly "Your progress is saved." and not "on this device".
- `[save-progress 19]`, `src/screens/save-note-copy.test.ts`: the guest line is the owner's words and passes the writing rules; `accountKindOf` gives "guest" only for a clear guest answer (email, none, 401, 503, null, an odd body and "Guest" are not).
- Earlier tests I had to change, because every guest's finish screen now says the new line: the text `'Your progress is saved.'` became `'Your progress is saved on this device.'` for guests in `e2e/account-helpers.ts`, `e2e/analytics-journey.spec.ts`, `e2e/daily-review.spec.ts`, `e2e/first-session.spec.ts` (4 places), `e2e/patterns.spec.ts` (2 places) and `e2e/review-helpers.ts`. `finishTodaysSession` in `e2e/account-helpers.ts` gained an optional `'email'` argument for an account with an email, and `e2e/accounts.spec.ts` ([accounts 12], the second device) now passes it, because that device is an email account and keeps the plain line. No assertion was loosened: each still checks one exact line.

### Proof by breaking it on purpose

Scratch runs https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41277777545 and https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41278173670 (branch `scratch/18-save-progress-red-3`, deleted after the runs; the first guest variant did not compile because of an unused import, so I reran it). They run `e2e/save-progress.spec.ts` and `e2e/first-session.spec.ts` in both browsers. Files: `break-ui-control-r2.txt`, `break-ui-email-sees-guest-line-r2.txt`, `break-ui-guest-sees-old-line-r2.txt`.

| Break | Result |
| --- | --- |
| control | none red, 81 passed |
| an account with an email shown the guest line | only 3 tests per browser go red, the 3 that assert the plain line (`[save-progress 5]` twice and `[save-progress 19]`) |
| a guest shown the old line | 20 tests per browser go red: every browser test that waits for a guest's finish screen asserts the guest line |

**Not "only that test" for the guest break.** I could not make the new test the only red one for this break, and I did not try to. Every earlier test that reaches a guest's finish screen asserts the status line, so they all had to change with the owner's wording, and they all fail together when a guest sees the old line. That is one protection checked in many places. The only way to make one test red alone would be to let the other tests accept either line, which weakens them. The mirror break (an email account shown the guest line) does turn red only the tests that assert the plain line.

### Check results

- Full run on GitHub: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41278822164 (`gh workflow run checks.yml --ref factory/18-save-progress`, tested commit `f0784f1`; the commit after it only adds `evidence/r2-ci-run-41278822164-checks.txt`). Result: success. Type check, lint and format, unit tests, Python tests, database tests (including the types check), browser tests (422 passed, 31 skipped as before, 0 failed; all 34 of this job's tests passed, 17 per browser), secret scan and dependency check all passed. The jobs against the test project are skipped, as for any branch.
- On this computer: type check, lint, format check and `npx vitest run` pass (81 files, 1091 tests; `scripts/hooks/commit-tool.test.ts` passed when run alone, see below). The commit hook ran the secret scan, type check, lint and format on every commit.
- The scratch runs for the breaks are listed above and are not part of the checks. Both scratch branches of round 2 are deleted.

### Unfinished or uncertain

- The first full run of round 2 (https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41277760973) failed in the browser job on one earlier test, `[accounts 12]`, in both browsers, because its second device is an email account and its helper expected the guest line. That was the test's expectation, not the app. Fixed in `f0784f1`; see the run above.
- The finish screen now waits for `GET /api/me` before it leaves "Saving your progress.". It is one quick read of the learner's own account row; if it fails, the plain line shows.
- As in round 1: the Switzer font files are not on GitHub, so layout checks used the fallback font; the `pageshow` guard cannot be tested automatically (the evaluator says it can be checked by hand on a real iPhone); there is no Docker on this machine, so database and browser tests run on GitHub.
- `scripts/hooks/commit-tool.test.ts` timed out once at 5 seconds under the load of the full suite on my computer, and passes alone and on GitHub.

Result: checks pass

## Round 1 (short)

Tip then: `e6953e4`, tested commit `c5a6610`. Full run: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41248527014, success (database 33 tests, browser 420 passed and 31 skipped as before, 32 of them this job's, 81 unit test files). Two earlier runs failed on my own mistakes (the types file not regenerated: run 41245630657; two browser test bugs: run 41247029972) and were fixed.

Built: migration `20261031234601_save_progress_note.sql` with `public.save_progress_note` (`stable`, `security invoker`, empty `search_path`, grants written out, reads only, stores nothing); Worker field `saveNote` on `POST /api/sessions/<id>/complete` (the call lives on a small `SaveNoteDb` interface, so no earlier test or fake needed a change except the fake in `worker/test-fakes.ts`); the note on the finish screen (`SaveNote.tsx`, `SaveNote.module.css`, words and the one add email address in `save-note-copy.ts`, a `pageshow` guard in `FinishScreen.tsx`); `design.md`, `/design-reference`, `docs/data-model.md`, `docs/conventions.md`. The owner's calls: one reminder at the third finished session, "Add your email to save your progress.", a secondary white "Add your email" and a quiet "Not now".

Proof by breaking it on purpose, all in `factory/jobs/18-save-progress/evidence/`: database `break-db-*.txt` (13 variants, run 41247408043; the spec's run turned tests 3, 18, 23 and 29 red, and removing only the owner checks turns nothing red because the learner's own read rule also refuses it), local `break-worker-*`, `break-screen-*`, `break-copy-*`, `break-repo-*` (9 breaks), browser `break-ui-*.txt` (runs 41248547803 and 41249115436, control 32 of 32). The statement-to-test links are in the test names as `[save-progress N]`, and `evidence/13-17-no-package-route-privacy-change.txt` shows the `git diff --stat` command prints nothing.

How to run locally: with Docker and the throwaway local Supabase, load the seeds, run `VITE_DESIGN_REFERENCE=1 npm run build`, then `npx playwright test e2e/save-progress.spec.ts`. Without Docker, `npx vitest run worker/save-progress.test.ts src/screens/save-note-copy.test.ts tests/save-progress-rules.test.ts`, then push the branch and use the checks workflow.
