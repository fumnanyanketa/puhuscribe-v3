# Evaluation: 8-first-session (round 1)

Evaluator, 22 October 2026. Branch `factory/8-first-session` at `679d21c`, draft PR 18, run 39671525623 (all checks green).

## How I tested

- This machine has no Docker, and the branch preview cannot run a session before merge (new tables reach the test project only on merge), so the running app was judged from the pull request run: its Playwright report (170 tests, Chromium and WebKit at 375 x 812, against the built app and a throwaway local Supabase with the test fixture), screenshots, videos and job logs. Summary in `eval-ci-run-summary.txt`. I scanned every downloaded file for token shapes and keys before keeping anything. No trace or HAR file existed. Only screenshots and two videos were kept.
- I read every test behind each statement, not only its title, and checked the expected values come from the database.
- I cloned the repository fresh at `679d21c`, ran `npm ci` and the whole unit suite: 510 of 510 pass (`eval-unit-tests-clean-copy.txt`).
- I broke 15 protections on purpose in that scratch clone and ran their tests (`eval-mutations.txt`). 14 went red. The one that stayed green (M8) is an equivalent change, because another check in the same function still refuses the line; the real break of that function (M8b) went red. Nothing was pushed.
- pgTAP could not run here, so I broke the new insert rule and function by reading the SQL and the test data (`eval-pgtap-mutations-reasoned.txt`). This found one test that passes for the wrong reason.
- Main path videos: `eval-main-path-chromium.webm`, `eval-main-path-webkit.webm` (Start, Hear it, Understand it, finish, Done).

## Results

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `eval-1-front-door-webkit.png` | Wordmark, "Today's session", one sentence, Start, the exact guest and 18+ line. Zero `/api/guest` calls on load and reload. |
| 2 | pass (test project: pending owner setup) | `eval-2-guest-once-webkit.png`, `eval-mutations.txt` M2, M6 | One POST answers 201; cookies HttpOnly, Secure, Lax, Path=/, host only, 89 to 90 days; the user is in `auth.users` with `is_anonymous`; Start again, reload and a new tab make no second account. Body holds no token or id (unit test, M6 red). On the shared test project this works only after the owner turns on anonymous sign ins. |
| 3 | pass | `eval-3-7-no-token-no-draft-webkit.png`, `eval-ci-run-summary.txt` | Every request on every screen goes to the page's own address; cookie, localStorage and sessionStorage hold no token on each screen; built file secret check passed. |
| 4 | pass | `eval-4-session-ended-webkit.png`, `eval-mutations.txt` M2, M7 | Browser test deletes the user in the database, the front door shows the ended line and the cookies are gone, Start makes a new guest. Renewal and clearing covered by unit tests with a fake Supabase (M7 red). The screenshot is the test's last frame (the new guest on Hear it). |
| 5 | pass | `eval-5-other-site-refused-webkit.png`, `eval-mutations.txt` M1 | Posts with `Origin: https://evil.example` to all four write routes answer 403, a form post 415, nothing saved, no `Access-Control-Allow-Origin`. Removing the origin check turned 4 tests red. |
| 6 | pass | `eval-6-not-ready-webkit.png`, `eval-6-all-done-webkit.png`, `eval-ci-run-summary.txt` | Pick order and reuse by unit tests; one session row in the browser. The empty content pass ran in both browsers (2 passed) after every unit was set to draft, and first proves nothing is readable. All done message shown after every dialogue is finished. |
| 7 | pass | `eval-3-7-no-token-no-draft-webkit.png`, `eval-mutations.txt` M15 | Every database request carries the learner's token and the publishable key only (unit test). The draft dialogue title, draft line gloss and draft form texts appear in no `/api` answer or page (browser test reads them from the database). Adding a service role key name to the Worker turned the repository test red. |
| 8 | pass | `eval-8-9-hear-it-continue-webkit.png`, `eval-mutations.txt` M13 | One list in `src/screens/session-steps.ts`; top bar reads "Hear it, step 1 of 2" and "Understand it, step 2 of 2"; unit test proves an added step renders before the finish screen; job 5 default kept. |
| 9 | pass | `eval-8-9-hear-it-continue-webkit.png`, `eval-9-changed-words-hint-webkit.png`, `eval-mutations.txt` M8b | Lines added one by one, earlier ones stay, speaker, spoken band, "Written" label, `lang="fi"`, Continue stores `hear` (checked in the database). Changed words azure, hint once on Hear it, "Playing" text marks the playing line. |
| 10 | pass | `eval-10-playing-webkit.png`, `eval-10-could-not-play-webkit.png` | Per the manager addendum the URLs are `/audio/<key>`. Nothing requested before a press; ready, loading and playing states; 404 shows "Could not play." with "Try again". Answered with a generated tone. |
| 11 | pass (as amended by the manager addendum) | `eval-mutations.txt` (audio path tests in the unit list) | No audio route is built. Audio is the static files job 7 copies for approved lines only; the Worker refuses keys that could leave `/audio/`. build.md says so. |
| 12 | pass | `eval-12-word-card-webkit.png`, `eval-12-plain-word-webkit.png` | A spoken and a written word open the card with lemma, form name, why, spoken and written forms from the database; both play controls; Escape returns focus. "Alex" and the draft form's "kotoisin" are plain text. |
| 13 | pass | `eval-13-understand-it-webkit.png`, `eval-mutations.txt` M3, M4, M12 | Same questions and order after a reload; wrong answer gives the gentle line and becomes unavailable; right answer gives "Yes, that is right." and Next; `understand` stored after the last question; no answer columns exist. Skipping a step, recording `say`, or unseeding the order all turned tests red. |
| 14 | pass | `eval-14-15-16-finish-saved-webkit.png`, `eval-mutations.txt` M11 | "Now you can say this.", one line with both registers, gloss and play controls, the review line, Done returns to `/`. The shown line matches Decision 5 for the fixture (the earlier of two four word lines). |
| 15 | pass | `eval-14-15-16-finish-saved-webkit.png`, `eval-15-save-failed-retry-webkit.png` | After a full run: `understand`, `ended_at` set, one session row, cards equal to the distinct approved forms, one event. A failed save shows the problem line, Try again saves, still one event. pgTAP: a second call keeps the first end time and adds nothing. |
| 16 | pass | `eval-pgtap-mutations-reasoned.txt` | pgTAP refuses empty step, `hear` and another learner's session with nothing written; no card for the withdrawn form or the second dialogue's form. Browser test finds no card outside the dialogue. |
| 17 | **fail** | `eval-pgtap-mutations-reasoned.txt` (P1) | The table, grants, rules, index and function settings are correct, and CI pgTAP passes. But the test "A cannot add an event carrying B's id" would stay green if the `user_id = auth.uid()` part of the insert rule were removed, because the session it uses has not ended yet. The statement requires pgTAP to prove this case. |
| 18 | pass | `eval-18-resume-finish-webkit.png`, `eval-mutations.txt` M13 | Leave and Continue resume at Hear it, Understand it and the finish screen; one session row, step `understand`, not ended. |
| 19 | pass | `eval-mutations.txt` M5, M9, `eval-library-log-line.txt` | Logging the cookie header turned the log test red; turning invocation logs back on turned the config test red. The Supabase library itself writes one error line (no personal data) when a sign in is lost; see Odd. |
| 20 | pass | `eval-mutations.txt` M10b, M14 | Seed has the unit at 900, two approved and one draft dialogue, a draft line, a draft form, `test-fixture:not-reviewed` refs, `test-fixture/` keys, lines 1 to 5 of the voice sheet. Adding `--include-seed` or `test-fixture` to a migration turned tests red; the built app check passed. The file sits in job 6's `supabase/seeds/browser/` instead of the spec's path, explained in build.md. |
| 21 | pass | `eval-21-visits-404-webkit.png` | `/api/visits` answers 404; migration drops `visits`; pgTAP `hasnt_table`; build.md lists removed and changed tests; moved protections keep their labels; `/api/health` unchanged. |
| 22 | pass | `eval-22-tap-areas-webkit.png`, `eval-22-axe-dark-webkit.png` | No sideways scroll at 320 px or 200 percent text on every screen; tap areas checked; axe clean in light and dark on every screen; keyboard flow passes. Job 1 to 5 tests green; the changes to them are only the re-pointing statement 21 allows. |
| 23 | **fail** | `build.md`, `eval-ci-run-summary.txt` | conventions.md, data-model.md and README (€0) are right. build.md still describes round 1 (last commit `bec8ea1`, "Result: blocked", first session browser tests "not run yet") and gives no check minutes of a full pull request run. |

## Failures and how to reproduce

1. **Statement 17: one pgTAP test passes for the wrong reason.** Open `supabase/tests/database/first_session.test.sql`. The test "A cannot add an event carrying B's id" inserts `(user_id = B, session = A001)` while A001 is at `understand` but not ended. In `20261021182910_first_session.sql`, delete `user_id = (select auth.uid()) and` from the insert rule. The insert is still refused, by the `ended_at is not null` part, with the same 42501 message, so the test stays green. Effect of the hole if it ever opened: a learner who has finished a session could add a `first_session_completed` event carrying another learner's id. Fix: run this insert against a session that passes every other part of the rule (for example A001 after it is completed, with the id of a third learner who has no event), and break the clause on a scratch branch to watch it go red.
2. **Statement 23: build.md is out of date.** Read `factory/jobs/8-first-session/build.md`. It reports round 1 only, says the browser tests had not run, ends with "Result: blocked", and lists "Waiting for job 6" steps that are already done in the branch. It does not give the check minutes of a full pull request run. Run 39671525623 used about 17.7 check minutes (sum of its job durations). Fix: add a round 2 section with the merged main, the workflow changes, the run link, the browser and empty content results and the minutes, keeping round 1 short as AGENTS.md asks.

## Odd, not failures

- **Second wall missing a test.** The step part of the event insert rule (`step_reached >= 'understand'`) is not proven alone: the test for a `hear` session also fails the `ended_at` part. A learner may set `ended_at` on their own session through the job 3 update grant, so the part matters. Worth fixing with item 1 (P2 in `eval-pgtap-mutations-reasoned.txt`).
- **The library writes to the Worker log.** On a lost sign in, `@supabase/auth-js` writes "AuthApiError: Invalid Refresh Token ..." with its stack to the console. No personal data, so statement 19 holds, but the comments "Nothing here writes to the log" in `worker/api.ts` and `worker/learner-auth.ts` claim more than is true.
- **A lost renewal answer can end a guest for good.** If a phone loses its connection while the Worker's renewed cookies are on the way back, the browser keeps the old single use refresh token. Once Supabase's 10 second reuse window has passed, the next request is refused, the cookies are cleared and the guest starts over with no way back to their progress (guests have no email until job 11). Rare, but the owner should know before real learners use it.
- **Shared limits through Cloudflare's address.** The spec flags the anonymous sign in limit. Token renewals also go through the Worker, so Supabase's per address renewal limit would also be shared by all learners. Not verified for the hosted project; belongs in the same pre-launch decision.
- **"Today's session" has no daily limit.** After Done, the front door at once offers Start for the next dialogue, with no word that the first one is saved. Matches the spec's rule; worth a look in job 13.
- **The blue word hint shows again on Understand it.** Statement 9 says it shows once on Hear it, which it does; it also appears on Understand it.
- **WebKit keyboard test.** `tabTo` in `e2e/session-helpers.ts` falls back to `focus()` in WebKit, so only Chromium proves the flow by Tab alone. The reading order test is skipped in WebKit. Reasonable, since WebKit skips buttons on Tab by default.
- **Draft line placement.** The fixture's draft line sits in the draft dialogue, so the browser test does not exercise a draft line inside an approved dialogue (job 3's pgTAP covers the rule).
- **Audio is public on the live app.** Under the manager addendum, `/audio/<key>` files need no account. Accepted by the addendum.
- **Check minutes.** About 17.7 minutes per pull request run; the free 2,000 minutes a month allow roughly 110 runs.
- A duplicated doc comment ("Answers every question right") in `e2e/session-helpers.ts` at line 96.

## Pending owner setup (only matters after merge)

- Anonymous sign ins on the Supabase test project, and a raised anonymous sign in limit. Until then a guest cannot start on the preview or after merge. Statement 2 is proven on the throwaway database.
- After merge the manager opens the preview once (the spec's plan): with job 7's content it shows the real dialogue, without it the "not ready yet" screen.

## Must fix

1. Statement 17: make "A cannot add an event carrying B's id" fail when the `user_id = auth.uid()` part of the insert rule is removed, and show the red scratch run.
2. Statement 23: update build.md for the current round with the full pull request run and its check minutes.

Result: fail
