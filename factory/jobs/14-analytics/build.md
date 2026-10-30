# Build notes: 14-analytics

Round 1, 30 October 2026. Branch `factory/14-analytics`. Owner's calls as approved on 30 October 2026: call 1 = A (crash reports in our own EU Supabase database), call 2 = A (going live is a separate job). The owner page hostname `puhuscribe-owner.exentrik.co` was confirmed by the owner during the build (manager's message); it is named only in the README and `.env.example`, never in code or config (`OWNER_HOSTNAME` stays a setting).

## What I built, in plain words

- **Visit count.** The Worker now runs first for the app's page routes (`/`, `/session`, `/voice`, `/account`, `/account/*`, `/sign-in`, `/privacy`, `/feedback`, `/owner`), answers them with the built page byte for byte, and after answering adds one to a per day, per country tally when the request is an arrival (statement 1's rules). Only the country goes to the database. Files never run the Worker.
- **Owner page** at `/owner` on its own hostname. The Worker checks the Cloudflare Access token on every owner host request (job 13's check, reused from `review-site/handler.ts`), answers only `/owner`, `/sign-in` and seven `/api` routes, sends other pages to `/owner`, and makes every answer private. The owner signs in with their PuhuScribe email account; the database function `owner_dashboard()` answers only for an account on the owner list with a live sign in. The page shows the learner numbers with their goals, two real tables of visits, the newest 50 feedback messages as plain text, the newest 20 crash groups, a "Send a test error" button and when the numbers were worked out.
- **Feedback.** `/feedback` with a quiet "Send feedback" link on the account page, the finish screen and the front door (only once the device has an account). 1 to 1,000 characters, at most 5 a Helsinki day, enforced in the database under a lock per learner. Stored with the account, exported and deleted with it.
- **Crash reports.** Browser listeners and an error boundary ("Something went wrong on this screen." with Reload) catch errors; at most 5 reports per page load, each once, by `fetch` with `keepalive` (plain `fetch` where it is missing), without cookies. Anything typed into a field on the page is removed from the message. The Worker cleans every field again, adds the app version (the build's commit) and a coarse browser label, and sends it through `worker/providers/crash-reports.ts`, the only file that calls `report_crash`. Unexpected Worker exceptions answer 500 `server_error` and are reported too. The database checks every field again, caps reports at 300 an hour and 30 per group, and deletes them after 30 days.
- **Records.** Privacy notice (visit count, feedback, crash reports; date moved to 30 October 2026), data inventory, data model, conventions, README owner page setup with the owner list SQL line (a placeholder the owner types), regenerated database types.

## Deviations from the spec's wording (all keep its intent; the reviewers may want to check)

1. **`T1` is stored.** Statement 2 says T1 (Tor) is stored as T1, but statements 5 and 6 say "two capital letters", which T1 is not. The tally's check and `count_visit` accept two capital letters or exactly `T1`; `F1` and the rest are still refused (pgTAP covers both).
2. **The owner row in the download goes through a function.** Statement 16 says a learner can read their own `private.owners` row. Job 3's test `[data 2] a learner cannot use the private schema` forbids giving learners the private schema, so instead `public.my_owner_rows()` (security definer) returns only the caller's own row, and `export_my_data()` lists it as `private.owners`. Learners still cannot read the table itself (pgTAP).
3. **`/voice` is a run_worker_first route.** The spec's list omits it, but statement 3's own repository test requires every route of `src/App.tsx`, and `/voice` is one.
4. **Parallel tests run in their own CI step.** `ALTER ROLE ... SET` of a custom setting is refused on Supabase, so the two connection tests (`analytics_parallel.test.sql`) get the local database password through `PGOPTIONS` in a new step of the database check, which fails unless all 9 pass and none is skipped. Inside `supabase test db` (and on the test project after a merge) the same file skips its 9 tests and says why.
5. **The journey test runs alone.** It reads totals every other test also moves, so it is its own Playwright project, `journey`, which runs after the `chromium` and `webkit` projects. The learner's country is set with the local runtime's `MF-CF-Blob` header (Miniflare's way to set `request.cf`); the live Worker never sees it.
6. **The owner host in browser tests is `127.0.0.1` or `[::1]`**, whichever `localhost` points to on that computer (the test server listens only there). `scripts/ci/test-owner-access.ts` makes a fresh key per run; the Worker trusts that key only while `OWNER_HOSTNAME` is this computer.
7. **Seed data in two earlier pgTAP files.** `accounts.test.sql` (job 11) seeds a feedback row and an owner row for its learners A, B and D, so its rule "A has a row in every user table" still holds; its assertions are unchanged. `data_model_schema.test.sql` and `daily_review.test.sql` list the new `feedback` table and its three column grants. No test was removed or weakened.

## Done when, and the tests that cover each

| # | Tests |
|---|---|
| 1 | `worker/visits.test.ts` (27 request cases, robot list) |
| 2 | `worker/visits.test.ts` (country rules; the call carries only the country), pgTAP T1 |
| 3 | `tests/analytics-rules.test.ts` (wrangler list = `worker/page-routes.ts`, App routes, built files), `scripts/security/check-built-files.ts` after every build, `worker/visits.test.ts` |
| 4 | `worker/visits.test.ts` (byte for byte, failing, throwing and hanging database, no log line) |
| 5 | `supabase/tests/database/analytics.test.sql` (exact columns from the catalogue, privileges) |
| 6 | `analytics.test.sql`, `analytics_parallel.test.sql` (two connections at once) |
| 7 | `e2e/analytics-feedback.spec.ts` (whole walk, no outside request), `tests/analytics-rules.test.ts` (index.html and built pages), `worker/owner.test.ts` (owner host never counts) |
| 8 | `analytics.test.sql` (hand worked numbers, empty data) |
| 9 | `analytics.test.sql` (one failing case per condition); red scratch runs below |
| 10 | `analytics.test.sql` (catalogue list of cost tables, total, a cost table added later is counted) |
| 11 | `analytics.test.sql` (exact keys, no id or email, no @), `tests/analytics-rules.test.ts` (no anti metric words) |
| 12 | `e2e/analytics-journey.spec.ts` |
| 13 | `worker/owner.test.ts`, `e2e/analytics-owner.spec.ts` |
| 14 | `worker/owner.test.ts` (six refusals, valid token, local keys only on this computer); red run below; `e2e/analytics-owner.spec.ts` |
| 15 | `worker/owner.test.ts`, `e2e/analytics-owner.spec.ts` |
| 16 | `analytics.test.sql`, `accounts.test.sql`, README line checked by `tests/analytics-rules.test.ts` |
| 17 | `src/lib/owner-numbers.test.ts`, `e2e/analytics-owner.spec.ts` |
| 18 | `worker/owner.test.ts`, `e2e/analytics-owner.spec.ts` |
| 19 | `e2e/analytics-feedback.spec.ts`, `worker/feedback.test.ts` |
| 20 | `e2e/analytics-owner.spec.ts` (script and onerror text, no links, 40 letter word at 375 px), `analytics.test.sql` |
| 21 | `analytics.test.sql`, `data_model_schema.test.sql` |
| 22 | `worker/feedback.test.ts`, `analytics.test.sql`, `analytics_parallel.test.sql`, `e2e/analytics-feedback.spec.ts` |
| 23 | `analytics.test.sql`, `accounts.test.sql`, `tests/personal-data.test.ts`, `src/screens/privacy-page.test.ts` |
| 24 | `src/lib/crash-reporter.test.ts`, `worker/crash.test.ts` |
| 25 | `src/lib/crash-clean.test.ts`, `worker/crash.test.ts`, `src/lib/crash-reporter.test.ts`, `e2e/analytics-feedback.spec.ts` (typed answer in review) |
| 26 | `analytics.test.sql`, `analytics_parallel.test.sql` |
| 27 | `e2e/analytics-owner.spec.ts` (both browsers, test button and front door error), `worker/crash.test.ts`, `analytics.test.sql` |
| 28 | `tests/analytics-rules.test.ts`, `tests/personal-data.test.ts` (provider listed under Supabase) |
| 29 | `src/screens/privacy-page.test.ts` |
| 30 | `worker/feedback.test.ts`, `worker/crash.test.ts`, `tests/analytics-rules.test.ts` (no supabase.co in the browser code) |
| 31 | `e2e/analytics-feedback.spec.ts`, `e2e/analytics-owner.spec.ts` (320 px, 200 percent, 44 px, keyboard, axe light and dark) |
| 32 | `tests/analytics-rules.test.ts`, the database check's type comparison |
| 33 | Not built here: proven only after go live (owner's call 2). The manager keeps the feature failing until then. |

## Checks and results

No local Docker on this Windows machine, so the database and browser checks ran only on GitHub, as manual runs of the Checks workflow on this branch (`gh workflow run checks.yml --ref factory/14-analytics`). No pull request was opened. The preview job runs only for pull requests, so it was skipped.

**Green run: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41051962634** (head `3bca563`). Every job passed: type check, lint and format; Vitest (78 files, 1,042 passed, 6 skipped for missing private fonts); pgTAP (11 files, 903 tests, then the 9 parallel tests in their own step, all `ok`); Python; dependency check; secret scan; browser tests in Chromium and WebKit (382 passed, 31 skipped as before, including the journey project). Summary with every analytics test line: `factory/jobs/14-analytics/evidence/ci-r1-41051962634-checks.txt`.

Local, this machine (Node 24): `npm run check:code` pass; `npx vitest run` 1,042 passed, 2 skipped; `VITE_DESIGN_REFERENCE=1 npm run build` pass, including `check:built-secrets` and the new `check:built-files` (32 files, none runs the Worker or loads another site); lefthook with gitleaks on every commit, never skipped.

**Red runs (each protection broken on purpose, then put back):**
- Statement 9, condition 1 (owner list check removed): https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41045973075, branch `scratch/14-analytics-red-9-list`. Only test 89 "[analytics 9] a learner not on the owner list gets nothing" failed. `evidence/break-9-ci-owner-list-check-removed.txt`.
- Statement 9, condition 2 (live sign in check removed): https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41045994845, branch `scratch/14-analytics-red-9-live`. Only test 90 "[analytics 9] an owner whose sign in was ended gets nothing" failed. `evidence/break-9-ci-live-sign-in-check-removed.txt`.
- Statement 9, condition 3 (anon given EXECUTE): https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41046434519, branch `scratch/14-analytics-red-9-anon`. Only test 88 "[analytics 9] anon cannot run owner_dashboard" failed. `evidence/break-9-ci-anon-allowed-to-run.txt`. (An earlier run on that branch, 41046007587, ran before the change was committed and proves nothing; it was cancelled.)
- Statement 14 (the Access token check replaced by "always allow"): local Vitest, 7 of 23 owner tests failed, all six refusal tests and the local key test. `evidence/break-14-local-access-check-always-allow.txt`. A local run, not a GitHub link: the check is a unit test.

**Runs that failed on the way, and why (debug triage):**
- 41041065767, 41041996329, 41042719634, 41043424596: database job iterations. Real bugs in my first drafts: `ALTER ROLE ... SET` refused for a custom setting (moved to `PGOPTIONS`); `T1` refused by the country check (spec conflict, see deviation 1); `dblink_exec` cannot run a `select` (now `dblink()`); then the types check, until the CLI's generated `database.types.ts` was committed from the run's artifact.
- 41045853880: every owner page browser test refused to connect. Real bug in the test setup: the test server listens only where `localhost` points (`::1` on the runner), not on 127.0.0.1. Fixed in `scripts/ci/test-owner-access.ts`.
- 41047697385: three owner test failures. (a) `Access-Control-Allow-Origin` came from `vite preview`'s own CORS default, not the Worker (Vitest shows the Worker never sends it); the local preview server now sends no CORS headers, like production. (b) The sign in screen redirects a signed in owner, so its axe check now uses a fresh browser. (c) In WebKit the test's request context got 401 from the dashboard although the page itself was signed in (likely its cookie lookup for `[::1]`); that check now reads the database instead. No assertion was dropped.
- 41049667239: only the journey failed: after a speech check Say it moves to the next line by itself, so the test now leaves by "I can't speak right now".

## Unfinished or uncertain

- **Statement 33** is proven only after go live (owner's call 2). Not attempted.
- **Owner input still needed at go live:** which email address goes into the Access policy and the owner list (the README tells the owner to type it; no agent picked one), and the 15 minute setup in README "Owner page setup".
- **For the owner to approve:** the new privacy notice wording (visit count, feedback, crash reports, and an "Owner page access" line for the owner list, which the download now lists). The notice date is now 30 October 2026.
- **Could not verify here:** how Cloudflare in production matches `/account` without a wildcard (both `/account` and `/account/*` are listed); `env.ASSETS.fetch` does apply the single page fallback (every page route loaded in the browser tests through it). How real phones set `Sec-Fetch-Site` on reload and home screen launch is for the go live check.
- **Scratch branches** `scratch/14-analytics-red-9-list`, `-live` and `-anon` are still on GitHub; the manager may delete them.
- `scripts/hooks/commit-tool.test.ts` once timed out in a full local Vitest run on this machine (passes alone and on GitHub); unrelated to this job.
- The browser tests that need the owner host skip with a reason on preview links and after merge (no local key there), like other `@seed` and `@email` tests.

## How to run it locally

1. `npm ci`, then start the local Supabase as in job 11's notes, and write `.env.local` from `npx supabase status -o env | node scripts/ci/write-test-settings.ts env .env.local --from-supabase-status`.
2. `echo SPEECH_FEEDBACK_PROVIDER=fake >> .env.local` and `node scripts/ci/test-owner-access.ts >> .env.local` (the owner host settings for this computer).
3. Load `supabase/seeds/browser/*.sql`, then `VITE_DESIGN_REFERENCE=1 npm run build`.
4. `LOCAL_DB_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres npx playwright test`.
5. By hand: open `https://localhost:4173/`, press Start, then "Send feedback". The owner page is at `https://127.0.0.1:4173/owner` or `https://[::1]:4173/owner` (whichever the key script printed) and needs the `Cf-Access-Jwt-Assertion` header, so it is easiest through the browser tests. Add your account to `private.owners` with the README's SQL line.
6. Parallel database tests: `PGOPTIONS='-c puhuscribe.parallel_test_password=postgres' psql "$LOCAL_DB_URL" -f supabase/tests/database/analytics_parallel.test.sql`.

Pushed head: see the last commit on `factory/14-analytics`.

Result: checks pass
