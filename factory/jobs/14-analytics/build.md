# Build notes: 14-analytics

## Round 3, 30 October 2026

Rework from `evaluation.md` (result: fail, two must fixes). The manager asked for exactly those two fixes; nothing else changed. The evaluator's report, its 21 `eval-` evidence files and the design re-check's "Round 2" section in `design-review.md` are committed with this round.

### What changed, in plain words

1. **Statement 12: the journey test's cost check can now fail.** The fake speech provider records a cost of 0, so "the total grew by the attempt's cost" was "the total equals itself". After the speech check, the test now sets that one attempt's `cost_usd` to 0.01234567 in the throwaway database (as it already moves sessions back in time), checks it reads back as that amount, and expects the owner page total to be larger than before and to grow by exactly that amount. The provider is unchanged.
2. **Statement 19: a second tap or Enter on Send while the message is sending no longer stores it twice.** `send()` in `src/screens/FeedbackPage.tsx` now returns at once while `sending` is true, as `EmailFlow` does. One line.

### Tests for round 3

| # | Test |
|---|---|
| 12 | `e2e/analytics-journey.spec.ts`, "[analytics 12] a test learner journey moves each owner page number" (changed: a known cost, and the total must grow by it) |
| 19 | `e2e/analytics-feedback.spec.ts`, "[analytics 19] a second tap and an Enter on Send while the message is sending store it once" (new, Chromium and WebKit). The `/api/feedback` answer is held 2 seconds. The test taps Send, waits for the busy state, taps again (a forced tap, since the busy button refuses Playwright's normal click), then presses Enter on it. It expects exactly one POST with the message and one stored row. |

No test was deleted or weakened. The journey's cost assertion only became stricter.

### Checks and results

- Local: `npm run check:code` pass. `npx vitest run`: 77 of 78 files passed; one job 4 test (`scripts/hooks/commit-tool.test.ts`, gitleaks) timed out under load, then passed on its own (13 of 13). The evaluator saw the same local timeout. Lefthook with gitleaks ran on every commit, never skipped. No local browser run: this machine has no Docker, so no local database. The red runs below were done on GitHub.
- **Green run: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41062289293** (`gh workflow run checks.yml --ref factory/14-analytics`, head `0fd1065`). Every job passed: Vitest 1,052 passed, 6 skipped as before; pgTAP 903 plus the 9 parallel tests; browser 388 passed, 31 skipped as before. The new test passed in both browsers and the journey passed. `evidence/ci-r3-41062289293-checks.txt`.
- **Red run, statement 19: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41062162179**, branch `scratch/14-analytics-r3-red-double` (head `f422e45`: the round 3 tests without the fix). Only the new test failed, in Chromium and WebKit, each with three identical POSTs where one was expected. `evidence/r3-red-double-send-ci-41062162179.txt`.
- **Red run, statement 12: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41062406257**, branch `scratch/14-analytics-r3-red-cost` (head `c7e2568`: round 3 plus `v_cost := v_cost + 0 * v_part` in `owner_dashboard()`). The only browser failure was the journey, at the new cost line (expected more than 0, got 0), after numbers 1 to 6 had passed. pgTAP's cost tests 103, 104, 117 and 118 also went red, as expected. `evidence/r3-red-cost-ci-41062406257.txt`.
- Both round 3 scratch branches were deleted after their runs finished.

### Unfinished or uncertain (round 3)

- Statement 33 and the go live setup are unchanged (round 1, below).
- The stop hook reports type and format errors in `.worktrees/10-speaking-feedback` (`worker/speech-db.ts`). That is another job's worktree, holding staged changes from elsewhere; I did not touch it.

## Round 2, 30 October 2026 (short)

Five fixes from the round 1 reviews. 1. The privacy notice's "How long we keep it" and "Your rights" now say the visit count and crash reports are not linked to an account, crash reports go after 30 days, and visit totals are kept as daily totals for as long as the service runs. 2. The crash report line says what is removed. 3. The visit count line says Cloudflare sees the internet address and PuhuScribe's database does not keep it. 4. "Owner page access" has its own lead in and legitimate interest as its reason; the learner lead in became "Your learning and what you send us:". 5. Pages the Worker serves on the owner host carry `data-puhuscribe-host="owner"`, and only there the crash reporter sends `same-origin` cookies, so Cloudflare Access lets the report through.

**For the owner to approve (still open):** how long visit totals are kept (no limit is set), and all round 2 notice wording.

**Tests:** `src/screens/privacy-page.test.ts` (29, 16, 25); `src/lib/crash-reporter.test.ts`, `worker/owner.test.ts`, `e2e/analytics-owner.spec.ts` (27, 24, 4, 13); `e2e/analytics-feedback.spec.ts` (25, 30).

**Green run:** https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41056806046 (head `dd81f18`). `evidence/ci-r2-41056806046-checks.txt`. Local red before the fix: `evidence/r2-red-before-fix-unit.txt`.

**Red runs:** local breaks `evidence/r2-break-crash-credentials-always-omit.txt`, `evidence/r2-break-crash-credentials-always-same-origin.txt`, `evidence/r2-break-owner-host-mark-removed.txt`; on GitHub https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41057028194 (branch `scratch/14-analytics-r2-red-omit`), only the owner host cookie tests failed, `evidence/r2-break-ci-owner-host-crash-without-cookie.txt`. Run 41056895393 was cancelled and proves nothing.

**Still open from round 2:** that Access accepts the cookie on a `keepalive` fetch is checked only at go live; scratch branch `scratch/14-analytics-r2-red-omit` and round 1's `scratch/14-analytics-red-9-*` are still on GitHub for the manager to delete.

## Round 1, 30 October 2026 (short)

Owner's calls as approved on 30 October 2026: call 1 = A (crash reports in our own EU Supabase database), call 2 = A (going live is a separate job). The owner page hostname `puhuscribe-owner.exentrik.co` was confirmed by the owner during the build; it is named only in the README and `.env.example`, never in code or config (`OWNER_HOSTNAME` stays a setting).

**Built:** the Worker counts arrivals per Helsinki day and country after answering the page byte for byte; the owner page at `/owner` on its own hostname behind Cloudflare Access, the owner's own PuhuScribe sign in and the owner list in `owner_dashboard()`; `/feedback` with three quiet links, 1 to 1,000 characters, 5 a Helsinki day; browser and Worker crash reports, cleaned twice, capped at 300 an hour and 30 per group, deleted after 30 days; records (privacy notice, inventory, data model, conventions, README owner page setup, regenerated types).

**Deviations from the spec's wording** (all keep its intent): 1. `T1` is stored. 2. The owner row reaches the download through `public.my_owner_rows()`, since learners may not use the private schema. 3. `/voice` is a run_worker_first route. 4. The parallel database tests run in their own CI step with `PGOPTIONS`. 5. The journey test is its own Playwright project, with the country set by Miniflare's `MF-CF-Blob` header. 6. The local owner host is `127.0.0.1` or `[::1]`, with a fresh key per run trusted only on this computer. 7. Seed rows and list entries added to `accounts.test.sql`, `data_model_schema.test.sql` and `daily_review.test.sql`; no assertion changed.

**Done when, round 1 tests:** 1 to 4 `worker/visits.test.ts`, `tests/analytics-rules.test.ts`; 5, 6, 8 to 11, 16, 21 to 23, 26 `supabase/tests/database/analytics.test.sql` and `analytics_parallel.test.sql`; 7 `e2e/analytics-feedback.spec.ts`, `worker/owner.test.ts`; 12 `e2e/analytics-journey.spec.ts`; 13 to 15, 18 `worker/owner.test.ts`, `e2e/analytics-owner.spec.ts`; 17 `src/lib/owner-numbers.test.ts`; 19, 20, 22 `e2e/analytics-feedback.spec.ts`, `worker/feedback.test.ts`; 23 `accounts.test.sql`, `tests/personal-data.test.ts`, `src/screens/privacy-page.test.ts`; 24, 25, 27 `src/lib/crash-reporter.test.ts`, `src/lib/crash-clean.test.ts`, `worker/crash.test.ts`, the e2e crash tests; 28, 30, 32 `tests/analytics-rules.test.ts`; 29 `src/screens/privacy-page.test.ts`; 31 the e2e 320 px, 200 percent, 44 px, keyboard and axe tests; 33 only after go live.

**Green run:** https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41051962634 (head `3bca563`): every job passed (Vitest 1,042 passed; pgTAP 903 plus 9 parallel; browser 382 passed, 31 skipped). Summary: `evidence/ci-r1-41051962634-checks.txt`.

**Red runs:**
- Statement 9, owner list check removed: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41045973075, only test 89 failed. `evidence/break-9-ci-owner-list-check-removed.txt`.
- Statement 9, live sign in check removed: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41045994845, only test 90 failed. `evidence/break-9-ci-live-sign-in-check-removed.txt`.
- Statement 9, anon given EXECUTE: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41046434519, only test 88 failed. `evidence/break-9-ci-anon-allowed-to-run.txt`. (Run 41046007587 ran before the change was committed and was cancelled.)
- Statement 14, Access check replaced by "always allow": local Vitest, 7 of 23 owner tests failed. `evidence/break-14-local-access-check-always-allow.txt`.

**Runs that failed on the way:** 41041065767, 41041996329, 41042719634, 41043424596 (database drafts: custom setting, T1, dblink, types); 41045853880 (test server on `::1`, fixed in `scripts/ci/test-owner-access.ts`); 41047697385 (CORS from `vite preview`, axe on a redirecting sign in screen, WebKit request context cookie lookup); 41049667239 (journey left Say it by the quiet exit).

**Still open from round 1:** statement 33 after go live; the owner's email in the Access policy and the owner list at go live (no agent picks it); unverified until live: Cloudflare's `/account` match and how real phones set `Sec-Fetch-Site`; scratch branches `scratch/14-analytics-red-9-list`, `-live`, `-anon`; `scripts/hooks/commit-tool.test.ts` once timed out locally (unrelated); owner host browser tests skip on preview links and after merge.

## How to run it locally

1. `npm ci`, then start the local Supabase as in job 11's notes, and write `.env.local` from `npx supabase status -o env | node scripts/ci/write-test-settings.ts env .env.local --from-supabase-status`.
2. `echo SPEECH_FEEDBACK_PROVIDER=fake >> .env.local` and `node scripts/ci/test-owner-access.ts >> .env.local` (the owner host settings for this computer).
3. Load `supabase/seeds/browser/*.sql`, then `VITE_DESIGN_REFERENCE=1 npm run build`.
4. `LOCAL_DB_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres npx playwright test`.
5. By hand: open `https://localhost:4173/`, press Start, then "Send feedback". The owner page is at `https://127.0.0.1:4173/owner` or `https://[::1]:4173/owner` (whichever the key script printed) and needs the `Cf-Access-Jwt-Assertion` header, so it is easiest through the browser tests. Add your account to `private.owners` with the README's SQL line. The privacy notice is at `/privacy`.
6. Parallel database tests: `PGOPTIONS='-c puhuscribe.parallel_test_password=postgres' psql "$LOCAL_DB_URL" -f supabase/tests/database/analytics_parallel.test.sql`.

Pushed head: see the last commit on `factory/14-analytics`.

Result: checks pass
