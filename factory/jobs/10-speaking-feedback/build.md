# Build notes: 10-speaking-feedback

Branch `factory/10-speaking-feedback`, draft PR 3. Pushed head `b2a6a3e`.

## Earlier round (inherited, no notes were written)

An earlier builder pushed milestones 1 to 3 and part of 6 without notes: the migration (`supabase/migrations/20261022072903_speaking_feedback.sql`) with pgTAP, the feedback rules and both evals, the provider module with `azure` and `fake`, the hand-built fixtures, the "Speech fixtures" workflow, the recorder and WAV modules, and the Worker routes `/api/speech/say` and `/api/voice/*`. On GitHub every check passed except "Preview link", which fails on every PR until the repository secrets are set.

## This round

- Merged `origin/main` (job 13's review site). The four conflicts were lists of folders in `eslint.config.js`, `tsconfig.node.json`, `tsconfig.worker.json` and `vitest.config.ts`; both sides kept.
- Carried two fixes from the manager: `96bcdd8` (AGENTS.md under its word budget) and `53cfa43` (wrangler and miniflare past the undici advisories). `npm audit --audit-level=high` finds 0.
- Built milestone 4, the screens. Say it now sits in the step list after Understand it. The consent screen comes first and asks for no microphone. "Not now" lets the learner say each line out loud. Recording, the eight feedback messages, "Play my recording", the failure states, "I can't speak right now", and Voice settings at `/voice` (linked from the front door and from Say it) with both choices and the kept recordings.
- Wrote the records (statement 26) except `.env.example` (see below).
- Ran the red check for statement 16 locally (below).

## Changed job 8 tests (statement 5)

Say it now comes before the finish screen, so job 8 tests that name the step count or the resume point, or walk to the finish screen, were updated with their labels kept.

- `src/screens/session-steps.test.ts`: the step list now has Say it; "step 1 of 2" and "step 2 of 2" became "of 3", with "Say it, step 3 of 3"; after Understand it comes Say it, then the finish screen; resume after `understand` is Say it and after `say` the finish screen. The probe test that borrowed an id for a pretend Say it now checks the real one. `[speak 5]` added to each.
- `e2e/session-helpers.ts`: `afterNext` treats Say it (or its consent screen) as the end of Understand it. New `passSayIt` presses "Not now" and walks the lines to the finish screen.
- `e2e/first-session.spec.ts`: `[session 9]` "step 1 of 2" and "step 2 of 2" became "of 3". `[session 13]` waits for the Say it consent screen instead of the finish screen. `[session 3] [session 7]`, `[session 14..16]`, `[smoke 3] [session 15]`, `[session 15]`, `[session 22]` (fit, keyboard, axe) call `passSayIt` (keyboard and axe go through Say it by keyboard and scan its consent screen). `[session 14..16]` and `[session 18]` now expect `step = 'say'` at the end; `[session 18]` also checks the resume at Say it.

## Done when statements and their tests

| # | Covered by |
|---|---|
| 1 | `e2e/speaking-feedback.spec.ts` "[speak 1] [speak 2] the consent screen comes first" (zero microphone calls before Turn on), `src/lib/voice-consent.test.ts`, `tests/design-rules.test.ts` [speak 1] |
| 2 | same browser test plus "[speak 2] a ticked box adds the retention row"; `src/lib/voice-consent.test.ts`; `worker/speech.test.ts` |
| 3 | browser "[speak 3] after Not now ...", "[speak 3] [speak 4] after withdrawing ..." |
| 4 | pgTAP `supabase/tests/database/speaking_feedback.test.sql`; browser "[speak 4] [speak 19] Voice settings ..." ; `src/lib/voice-api.test.ts` |
| 5 | browser "[speak 5] [speak 6] [speak 15] [speak 17] a whole dialogue", "[speak 5] leaving at Say it resumes there"; `src/screens/session-steps.test.ts`; `worker/speech.test.ts` |
| 6 | browser whole dialogue, "I can't speak right now", "stops by itself at 10 seconds" |
| 7 | browser "[speak 7] each result gets its one kind message" (all eight rows with the fake, plus a flagged word); `src/lib/speech-feedback.test.ts` |
| 8 | browser "[speak 8] Play my recording ..." (localStorage, sessionStorage, IndexedDB, Cache Storage all empty) |
| 9 | browser: no recording support, refused access, background, under half a second, 10 second stop; microphone released checked; `src/lib/wav.test.ts`, `src/lib/recorder.test.ts` |
| 10 | `src/lib/speech-feedback.test.ts` |
| 11 | `scripts/eval/speech-golden.test.ts`; result `evidence/eval-speech.txt` (30 of 30) |
| 12 | `worker/providers/speech-feedback.test.ts`, `tests/speech-provider-rules.test.ts` |
| 13 | `worker/providers/speech-feedback.test.ts` (eastus refused); browser "[speak 13] without the speech service" |
| 14 | `worker/speech.test.ts` (every refusal, provider calls stay at zero); `src/lib/voice-api.test.ts` |
| 15 | browser whole dialogue (each response body has only `feedbackClass`); `src/lib/voice-api.test.ts` |
| 16 | pgTAP `speaking_feedback.test.sql`, `data_model_schema.test.sql`; red run below |
| 17 | browser whole dialogue (attempts with transcript and class, zero kept recordings); `worker/speech.test.ts` |
| 18 | pgTAP (backdated rows) |
| 19 | `worker/speech.test.ts`; browser "[speak 4] [speak 19] Voice settings" and "[speak 19] another learner cannot fetch" |
| 20 | `worker/speech.test.ts`, `worker/providers/speech-feedback.test.ts` |
| 21 | Waits for job 9 (below). pgTAP already covers the review attempt rule for a form with a card. |
| 22 | `scripts/eval/speech-wer.test.ts` |
| 23 | `tests/speech-fixtures-workflow.test.ts` |
| 24 | `worker/speech.test.ts` (console watched), `tests/speech-provider-rules.test.ts` |
| 25 | browser "[speak 25]" fit at 320 px and 200 percent with tap sizes, keyboard alone with recording, axe light and dark; job 8's [session 22] tests through Say it |
| 26 | `docs/conventions.md`, `docs/data-model.md`, `docs/speaking-feedback.md`, README running costs. `.env.example` not changed (below) |

## Checks run (locally, in the worktree)

- `npm ci`, then `npm run check:code`: type check, lint and format pass.
- `npx vitest run`: 53 files, 740 passed, 2 skipped.
- `npm run eval:speech`: 30 of 30, 100 percent (needs 90).
- `npm audit --audit-level=high`: 0 vulnerabilities.
- pgTAP: `npx supabase test db --workdir <scratch copy>`: 7 files, 562 tests, PASS. Local Supabase ran from a scratch copy of `supabase/` with its own project id and ports (57321 to 57329), because other builders share this machine's default ports.
- Red run for statement 16: the same copy with the consent condition removed from the attempts insert rule turned 3 tests red (37, 71, 72). Output in `evidence/pgtap-red-run-without-consent-condition.txt`. This was a local run, not a GitHub run; no scratch branch was pushed, so there is no run link.
- Browser tests, Chromium only: `npx playwright test -c <scratch config> --project=chromium` with `LOCAL_DB_URL` set, the browser seed loaded, `SPEECH_FEEDBACK_PROVIDER=fake` in the local settings file, and `VITE_DESIGN_REFERENCE=1 npm run build`: 116 passed, 15 skipped (fonts not present, and the empty content pass). The scratch config only changed the port to 4183, pointed at the preinstalled Chromium, and turned video off (this machine's ffmpeg is older than Playwright wants).
- Lefthook ran on every commit (gitleaks, lint, type check, format).

Not run here: WebKit (no WebKit build is installed on this machine) and the Python checks (untouched by this job). The pull request checks run both. Whether Playwright's WebKit has `MediaRecorder` was not checked locally; the browser tests feed it the same Web Audio tone stream, and if WebKit lacks `MediaRecorder` the tests that record will fail there and need the recorder boundary stub the spec allows.

## Unfinished or uncertain

- **Statement 21 waits for job 9's merge.** The spec names job 9's grading path and `review_logs.mode = 'spoken'` but no concrete function or route of job 9, so nothing was built against job 9's branch. Still to build once job 9 is on main: the every second item rule, `POST /api/speech/recall` with a `formId`, the class to rating table, the switch to typing after a second `not_heard` or a recording failure, and their unit and browser tests.
- **`.env.example` does not yet name `SPEECH_FEEDBACK_PROVIDER`.** The file already names the three `AZURE_SPEECH_*` variables from job 7. Reading `.env*` files is against the rules and was refused, so I did not edit it blind. Someone who may open it should add one line: `SPEECH_FEEDBACK_PROVIDER=  # azure (default) or fake; fake only in local and pull request browser tests`.
- `tests/agents-md.test.ts` failed after the merge because main's AGENTS.md was over budget; the manager's commit `96bcdd8` fixed it.
- Honest limit of statement 11: the rules and the golden labels were both written in this job, so 30 of 30 proves the rules match the labels. Whether the labels match a native ear is the reviewer's check (owner's call 3) and risk test 3's.
- The 50 clip word error run (statement 22) and "the vendor pick meets the word error target" belong to risk test 3.
- Real iPhone recording is not proven (spec Risks). The owner should try Say it once on an iPhone on the preview after merge.
- Statement 23's real fixtures wait for the owner's Azure key; the current fixtures say they were built from Microsoft's documented response shape.

## How to run it locally

1. `npm ci`
2. Start a local Supabase (`npx supabase start`), load `supabase/seeds/browser/*.sql`, and write the local settings with `npx supabase status -o env | node scripts/ci/write-test-settings.ts env .env.local --from-supabase-status`, then add `SPEECH_FEEDBACK_PROVIDER=fake` to `.env.local`.
3. `VITE_DESIGN_REFERENCE=1 npm run build`, then `npx vite preview`.
4. Open the app, press Start, go through Hear it and Understand it; Say it follows. Voice settings is at `/voice`.
5. Browser tests: `LOCAL_DB_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres npx playwright test e2e/speaking-feedback.spec.ts`.

## Round 3 (WebKit browser tests)

Triage kind: confused session (a test harness gap, not an app bug). The earlier round already flagged that WebKit's `MediaRecorder` was never checked.

Cause, with evidence:
- Run 40356177557 (head b2a6a3e): 14 WebKit tests in `e2e/speaking-feedback.spec.ts` failed. The page snapshots in the run's `playwright-report` artifact show a disabled `Recording is not available` button and "Recording is not available in this browser.", so `recordingSupported()` was false. The page is https://localhost and has AudioContext, so Playwright's Linux WebKit is missing `MediaRecorder` or `navigator.mediaDevices`. The microphone stub in `e2e/microphone.ts` returned early when `mediaDevices` was missing and never stood in for `MediaRecorder`.
- Run 40359756196 (after the first fix): the record button was back, but every WebKit recording test showed "Microphone access is off", which only a NotAllowedError or SecurityError from getUserMedia produces. WebKit was still calling its own getUserMedia, which refuses; a plain assignment did not replace it.

Fix (harness only, `e2e/microphone.ts`; no test or assertion changed, no app code changed):
- Where the browser has no `navigator.mediaDevices` or no `MediaRecorder`, and only then, the stub adds stand-ins. The stand-in recorder turns the time it ran into a 16 kHz WAV of the same 440 Hz tone, so the app's own support check, decode and WAV path still run on it. Chromium keeps the real `MediaRecorder`.
- The stub getUserMedia is now set with `Object.defineProperty` on the object and on `MediaDevices.prototype`. Where a WebKit build has no `createMediaStreamDestination`, it returns a stream with one track that can be stopped.
- Also cherry-picked main's `checks: give the browser test job 30 minutes` (61521d3), as the manager asked.

Commits: a8eabd6, 61521d3 (cherry-pick), 2919012. Pushed head: 2919012.

Checks:
- `npm run check:code`: pass. `npx vitest run`: 53 files, 740 passed, 2 skipped.
- Chromium, `npx playwright test -c <scratch config, port 4183> --project=chromium e2e/speaking-feedback.spec.ts` against my own Supabase (ports 57321 to 57329): 21 passed, run after each fix.
- WebKit could not run here: `npx playwright install webkit` fails the host requirement check.
- GitHub run 40361584427 (head 2919012): all 21 WebKit speaking feedback tests passed. In attempt 1, one other test failed: WebKit `e2e/design-sample.spec.ts:193` [design 12]. It paused one word late (got "Alex", wanted "Mä" or "oon"). That test does not use the microphone stub, passed on WebKit in runs 40356177557 and 40359756196, and was not touched by this job. It looks like a timing flake. I re-ran the failed job: see the result line below.
- The re-run (run 40361584427, attempt 2) passed the whole "Browser tests (Playwright, local Supabase)" job, Chromium and WebKit, on head 2919012. Every other check job passed too.
- In attempt 2, "Preview link (Cloudflare Worker behind Access)" ran for the first time on this branch, because the browser job before it passed. It failed at the worker secrets step (`exit code 1`). That job deploys a preview and needs the repository's Cloudflare secrets. This job did not change it. It is for the manager or owner to look at, and it is outside the WebKit task.


### Round 3, follow up (runner image and the 10 second test)

- Cherry-picked main's `checks: run the browser test jobs on ubuntu-24.04` as b87d463. Run 40364430716 on that head got through the install step and ran the tests: 230 passed, 1 failed. The failure was WebKit only, `e2e/speaking-feedback.spec.ts:343` [speak 6][speak 9]. The status line said "Your recording could not be checked. Check your internet connection, then try again." where the test wanted "Yes, that was clear."
- Cause, a real bug (it would also hit a real phone): the server (`worker/speech.ts`, `isSpeechWav(info, MAX_RECORDING_MS)`) refuses any WAV longer than 10 000 ms. The 10 second stop timer in `src/lib/recorder.ts` can fire a little late on a busy device, and the client sent the whole recording uncut, so a recording that ran 10.0x seconds was refused. The test caught this; it was not weakened.
- Fix: `capToLimit` in `src/lib/recorder.ts` cuts the 16 kHz samples to exactly 10 seconds before the WAV is built. New unit tests in `src/lib/recorder.test.ts`, both [speak 9]: a recording 800 samples over the limit comes back as exactly 160 000 samples, and a 3 second one is left as it is.
- Local checks: `npm run check:code` passes. `npx vitest run`: 742 passed, 2 skipped. `VITE_DESIGN_REFERENCE=1 npm run build`, then Chromium `e2e/speaking-feedback.spec.ts` on my own Supabase and port 4183: 21 passed.
- Commit afc9aa7, pushed. GitHub run 40366546462 on head afc9aa7: the "Browser tests (Playwright, local Supabase)" job passed, Chromium and WebKit (231 passed, 0 failed). Every other check job passed too, except "Preview link (Cloudflare Worker behind Access)". That job failed again at its worker secrets step, as in run 40361584427. This job did not change it.

## Round 4: merge of main after job 9, statement 21

What changed, in plain English:
- Merged `origin/main` (job 9, daily review) into the branch. `AGENTS.md` is main's version exactly. `docs/conventions.md` keeps both label rows. `src/lib/database.types.ts` was regenerated by the Supabase CLI (`npx supabase gen types --lang typescript --local --schema public`) from the merged migrations, not merged by hand. `worker/api.ts` and `worker/test-fakes.ts` keep both jobs' routes and fakes.
- Step list: Hear it, Understand it, Say it, then Keep it, which is included only when the learner had a reviewable card as the session loaded (job 9's rule, `stepsFor`). Labels follow: 3 steps without Keep it, 4 with it (Keep it is "step 4 of 4").
- Statement 21 built. `src/lib/answer-mode.ts` is the one rule: the 2nd, 4th and so on item of a run is spoken when speaking feedback is on and recording works, else typed. The spoken method (`src/screens/SpokenAnswer.tsx`) joins job 9's answer method list (`src/screens/answer-methods.ts`). `POST /api/speech/recall` (`worker/speech.ts`) has the same checks as `/api/speech/say`, takes a `formId` the learner holds a card for, uses the form's spoken shape as the reference, and accepts either register. The class becomes the rating by one table in `src/lib/review-grade.ts` (clear Good, close Hard, try again Again) and is saved through job 9's own `answer()` path with `review_logs.mode = 'spoken'`. `not_heard` grades nothing; after a second `not_heard`, a failed recording or a refused microphone the item switches to typing. The browser can never send a spoken class: `/api/review/answer` still takes only `typed`.
- Security review fix (owner decision): the 40 checks in 10 minutes limit could be beaten with parallel requests, and failed Azure calls never counted. A new table `speech_checks` and function `public.reserve_speech_check(max, minutes)` (in the same migration, `20261022072903_speaking_feedback.sql`) take the slot in one database step (an advisory lock per learner), before the speech service is called. The slot is never given back, so every call counts whether Azure answers or fails. Both `say` and `recall` use it. The refusal message is unchanged. The daily clean up deletes slots older than one day. Data model doc, speaking feedback doc and the pgTAP table list updated.

Job 8 and job 9 tests changed to describe the merged behaviour, with every assertion kept:
- `src/screens/keep-it.test.ts` [review 6]: step names now include Say it, "step 3 of 3" became "step 4 of 4" and "step 1 of 2" became "step 1 of 3". The test that built a fake list with Say it now checks the real list. The resume point after Say it is Keep it, and after Understand it is Say it.
- `e2e/daily-review.spec.ts`: "step 3 of 3" became "step 4 of 4", "Hear it, step 1 of 3" became "of 4", and the stored step at Keep it is `say`, not `understand`.
- `e2e/review-helpers.ts` and `e2e/session-helpers.ts`: the helpers now pass Say it (with "Not now", or the quiet exit when speaking feedback is on) before Keep it.
- `supabase/tests/database/daily_review.test.sql` [review 18]: the table list now also holds job 10's three tables, and `data_model_schema.test.sql` lists `speech_checks` (grant count 57 to 58).

Tests, labelled by the statement they protect:
- [speak 21]: `src/lib/answer-mode.test.ts` (the rule), `src/lib/review-grade.test.ts` (the class table), `src/screens/keep-it.test.ts` (the one list and what an item shows), `worker/recall.test.ts` (9 tests: Good, either register, Hard and Again, not heard grades nothing, no transcript in the answer, every refusal with the provider at zero calls, shared limit, 60 at once, and no spoken kind from the browser), `e2e/spoken-review.spec.ts` (3 browser tests: a spoken item with review log and card values, all typed when speaking feedback is off, refused microphone switches to typing).
- [speak 14] limit fix: `worker/speech.test.ts` fires 60 requests at once at a slow fake provider and proves at most 40 reach it and 20 get 429; 40 failing calls fill the window and the 41st is refused; refusals before the check take no slot. `worker/recall.test.ts` repeats both for review. `supabase/tests/database/speaking_feedback.test.sql` (15 new pgTAP tests): the limit of 3 refuses the 4th call with no attempt row (a failed call still counts), a refused call takes no slot, no slot for another learner, no giving a slot back, old slots expire, no slot without consent or for `anon`, and the clean up.

Commands and results:
- `npm ci`, `npm run check:code`: pass. `npx vitest run`: 61 files, 830 passed, 2 skipped.
- pgTAP, `npx supabase test db` from a scratch copy of `supabase/` with its own project id and ports 574xx: 8 files, all successful (a first run caught job 9's table list test, fixed above).
- Local Chromium browser tests were NOT run here. The auto mode classifier refused writing `.env.local` (the local settings step), so the browser tests ran only on GitHub. WebKit also runs only there.
- GitHub: run 40386754367 (head 3b60e94): every job green except the browser job, where only my new test `spoken-review.spec.ts` failed (255 passed): I had assumed a new card has 2 reps after its first review, it has 1. Test fixed in 39ba342; its second assumption (the log's due date equals the card's new one) was also wrong, since the log holds the date before the review, fixed in 2e876ca.
- Green run: 40390323192 (head 2e876ca): Type check, lint, format; Unit tests; Python; Dependency check; Secret scan; Database tests (pgTAP); Browser tests (Chromium and WebKit) all pass. Only "Preview link (Cloudflare Worker behind Access)" fails (owner secrets), as before. Final pushed head: 2e876ca.

No new npm package. Honest limits: the spoken review texts ("Yes, that was clear.", "Close. Listen to the word below.") are mine and go to the native reviewer with the rest of the Finnish-adjacent wording; WebKit's `MediaRecorder` stand-in applies to the spoken review test too.

Result: checks pass
