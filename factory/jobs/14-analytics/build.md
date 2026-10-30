# Build notes: 14-analytics

## Round 2, 30 October 2026

Rework from the round 1 reviews (`security-review.md`: pass with four notes; `design-review.md`: changes needed). Both reviews are now committed on the branch. The manager asked for exactly five fixes; everything else in the reviews is on `factory/todo.md` and was not touched.

### What changed, in plain words

1. **"How long we keep it" and "Your rights" now tell the truth about the two items that are not linked to an account** (design must fix 1, and note 16). The notice used to say everything is kept until the account is deleted and that deleting the account deletes everything at once. It now says that deleting the account deletes everything linked to it, that the visit count and crash reports are not linked to any account so deleting the account does not change them, that crash reports are deleted after 30 days, and that the visit count is kept as daily totals with no personal data for as long as the service runs. The rights section adds one line: the visit count and crash reports cannot be linked to a person, so a request to see or delete "your part" cannot be met, and the person is told so.
2. **The crash report line says what is removed** (design should fix 2). "Nothing you typed or said is included" promised more than the code can prove. It now says the browser removes any text typed into a box on the screen from the error message before sending, and that before saving we also remove anything shaped like an email address, an id, a sign in token or a long number, and replace ids in the screen address. That matches `src/lib/crash-reporter.ts` (typed values), `src/lib/crash-clean.ts` (the shapes and the path), run in the browser and again in `worker/crash.ts`.
3. **The visit count line no longer says "which we do not keep" about the internet address** (design should fix 4). It now says Cloudflare, which runs the app, sees the address because it delivers the page, and PuhuScribe's database does not keep it.
4. **"Owner page access" has its own lead in, "Only for the app's owner:", and the legal reason "Our legitimate interest in keeping the owner page private (GDPR Article 6(1)(f))"** (design should fix 3). Its "how long" is now "Until the account is taken off the owner list or deleted", which is what the README's two SQL lines and the cascade do. The download still lists `private.owners` for every account, in the same place (the list is `LEARNER_TABLES` then `OWNER_TABLES`). The same finding asked to rename the learner lead in "Your learning progress:" to "Your learning and what you send us:", since feedback is not progress; I did that too because it is part of the same finding and is not on `todo.md`. The owner can undo it with one line.
5. **Crash reports from the owner host now get through Cloudflare Access** (security note 1). Live, Access lets an owner host request through only when the browser sends Access's `CF_Authorization` cookie, and the crash reporter sent every report with `credentials: 'omit'`. Now the Worker marks every page the owner host serves (`/owner` and `/sign-in`) with `data-puhuscribe-host="owner"` on its `<html>` element (`worker/owner.ts`, shared names in `src/lib/owner-host.ts`), and the crash reporter sends `same-origin` cookies only when that mark is there. The app host never adds the mark and keeps `omit`, and its pages stay byte for byte what `env.ASSETS.fetch` returned (statement 4). The Worker still never reads a cookie on `/api/crash`. On the owner host, `same-origin` also sends the owner's own PuhuScribe sign in cookie with a report; the Worker ignores it, as before.

Why the mark comes from the Worker: the browser cannot tell the two hosts apart on its own. The owner hostname is a Worker setting that never goes into the built files, the Access cookie is hidden from scripts, and a rule based on the page path would also send cookies from `/owner` and `/sign-in` on the app host. Only a 200 HTML answer is changed; its stale `Content-Length` and `ETag` are dropped.

### For the owner to approve

- **How long the visit totals are kept.** Neither the spec nor the migration sets a limit (no deletion job for `private.visit_tallies`). The notice now says: "Kept as daily totals with no personal data for as long as the service runs, whether or not you delete your account." If you want a limit (for example 25 months), that is a small migration and one sentence; tell the manager.
- **All round 2 notice wording** (the five points above), with the date kept at 30 October 2026. The wording differs from the spec's "Privacy notice facts" table for the visit count and crash reports, on purpose: the reviewers found the table's lines false or too strong.

### Done when, and the tests for round 2

| # | Tests (new or changed in round 2) |
|---|---|
| 29 | `src/screens/privacy-page.test.ts`: visit count line (address kept by Cloudflare, not by PuhuScribe's database); crash line says what is removed and no longer "nothing you typed or said"; "How long we keep it" (account deletion leaves visits and crashes, 30 days, totals with no personal data); rights (deletion covers what is linked to the account, the not linked line); "Owner page access" under its own lead in with legitimate interest (also labelled 16, 25) |
| 27, 24 | `src/lib/crash-reporter.test.ts`: on the owner host the report is sent with `same-origin` cookies; `worker/owner.test.ts`: the owner host marks `/owner` and `/sign-in` and drops the stale length and ETag, leaves a 304 untouched; `e2e/analytics-owner.spec.ts`: on the owner host the page carries the mark and the `/api/crash` request carries the `CF_Authorization` cookie (Chromium and WebKit) |
| 25, 30 | `src/lib/crash-reporter.test.ts`: on the app host, and with any other mark value, no cookies; `e2e/analytics-feedback.spec.ts`: a signed in guest on the app host sends a crash report with no `Cookie` header, and the page has no mark |
| 4, 27 | `worker/owner.test.ts`: the app host serves `/owner` byte for byte, with no mark |
| 13 | `worker/owner.test.ts` "serves /owner and /sign-in from the built page" now expects the marked page. Its test page gained a real `<html lang="en">` element; before, it had none, so the old assertion could not have seen a change to that element. |

The changed assertions in `privacy-page.test.ts` replace the old notice text with the new text and add checks that the false sentences are gone. No test was deleted or weakened.

### Checks and results

Local, this machine (Node 24):
- `npx vitest run src/screens/privacy-page.test.ts src/lib/crash-reporter.test.ts worker/owner.test.ts` before the fix: 10 failed, 42 passed (`evidence/r2-red-before-fix-unit.txt`).
- `npm run check:code`: pass. `npx vitest run`: 78 files, 1,056 passed, 2 skipped. `VITE_DESIGN_REFERENCE=1 npm run build`: pass, including `check:built-secrets` (32 files) and `check:built-files`; the built `index.html` has no owner host mark. Lefthook with gitleaks ran on every commit, never skipped.

Break runs (each protection removed on purpose, then put back):
- Crash reporter sends `omit` everywhere (the round 1 code): only "[analytics 27] [analytics 24] on the owner host, sends the report with same origin cookies" failed. `evidence/r2-break-crash-credentials-always-omit.txt`.
- Crash reporter sends `same-origin` everywhere: only the two app host tests failed ("sends one report ... and no cookies" and "on the app host, or with any other mark, sends no cookies"). `evidence/r2-break-crash-credentials-always-same-origin.txt`.
- Worker stops marking owner host pages: only "serves /owner and /sign-in from the built page" and "marks the owner host page as the owner host" failed. `evidence/r2-break-owner-host-mark-removed.txt`.
- The notice tests: the red run before the fix shows each one failing on the old text.
- Browser test, on GitHub, crash reporter sends `omit` on the owner host too: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41057028194, branch `scratch/14-analytics-r2-red-omit`. Only three tests failed: the unit owner host test, and "[analytics 27] on the owner host, a crash report carries the cookie Cloudflare Access needs" in Chromium and in WebKit, each because the request's cookie header was empty. Round 1's "Send a test error" test still passed under this break, which shows why the new test was needed. `evidence/r2-break-ci-owner-host-crash-without-cookie.txt`.

GitHub (`gh workflow run checks.yml --ref factory/14-analytics`):

**Green run: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41056806046** (head `dd81f18`). Every job passed: type check, lint and format; Vitest (78 files, 1,052 passed, 6 skipped for the missing private fonts, as before); pgTAP (11 files, 903 tests, then the 9 parallel tests in their own step); Python; dependency check; secret scan; browser tests in Chromium and WebKit (386 passed, 31 skipped as before, journey project included). Both new browser tests ran and passed in both browsers. Summary with every analytics test line: `evidence/ci-r2-41056806046-checks.txt`. No pull request was opened, so the preview job was skipped.

### Unfinished or uncertain (round 2)

- Statement 33 and the go live setup are unchanged from round 1 (below).
- Not verifiable before go live: that Cloudflare Access sends `CF_Authorization` with a same origin `fetch` carrying `keepalive`. Browsers send same origin cookies with such requests, and the browser test shows the cookie on the request, but the live gate is checked only at go live (README "Owner page setup" step 5).
- Scratch branch `scratch/14-analytics-r2-red-omit` is on GitHub with round 1's `scratch/14-analytics-red-9-*` branches; the manager may delete them. Run 41056895393 on it was started before its commit existed (lint refused my first try) and was cancelled; it proves nothing.

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
