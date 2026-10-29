# Build notes: 11-accounts

## Earlier rounds (short)

- Round 1, earlier builder, commits `a47211b` and `9b0a832`: built the whole job (database, Worker routes, screens, privacy notice, email templates, tests). It left no notes. On GitHub (draft PR 5) every check passed except the browser tests: one test failed, `[accounts 22] a guest whose account was deleted keeps job 8's message` (run 39837754783).

## Round 2 (this round)

What I did, in plain words:

1. Merged `origin/main` (4 commits). README "Running costs" now holds main's review site rows and this job's two Supabase rows; `docs/conventions.md` holds both the `[accounts N]` and `[site N]` rows.
2. Fixed the failing browser test. Kind: a real bug in the test. The test deleted the guest while the session screen was still asking the Worker for today's session. That request found the account gone and, as statement 22 requires, cleared the sign in cookies. So when the test then opened `/`, the front door no longer knew a guest had been there and showed no message. I proved this by holding that request in a scratch test until after the delete: it failed the same way every time. The fix: the `startGuest` helper in `e2e/account-helpers.ts` now waits until the session screen shows "Hear it", the same wait job 8's own deletion test uses. No test was weakened; the app behaves as the spec says.
3. Cherry picked the manager's commit `96bcdd8` (AGENTS.md back under its 2,200 word budget), which main needs too.
4. Ran the two red scratch runs (statements 19 and 21) locally. Results below.

## Done when, and the tests that cover each

| # | Tests |
|---|---|
| 1 | `e2e/account-pages.spec.ts` |
| 2 | `e2e/account-pages.spec.ts`, `e2e/accounts.spec.ts` |
| 3 | `supabase/tests/database/accounts.test.sql`, `worker/account.test.ts`, `e2e/account-pages.spec.ts` |
| 4, 5 | `worker/account.test.ts`, `src/lib/email-address.test.ts`, `e2e/accounts.spec.ts` |
| 6, 8, 12 | `e2e/accounts.spec.ts` (`@email`), `worker/account.test.ts` |
| 7 | `e2e/accounts.spec.ts`, `tests/personal-data.test.ts` (config), `worker/account.test.ts` |
| 9 | `worker/account.test.ts` (byte for byte), `tests/personal-data.test.ts`, `e2e/accounts.spec.ts` |
| 10, 11, 13, 14 | `worker/account.test.ts`, `e2e/accounts.spec.ts` |
| 15 | `e2e/accounts.spec.ts` (Mailpit), `tests/personal-data.test.ts` |
| 16 | `src/screens/privacy-page.test.ts`, `e2e/account-pages.spec.ts` |
| 17 | `src/screens/privacy-page.test.ts`, `tests/personal-data.test.ts`, `e2e/accounts.spec.ts` |
| 18 | `worker/account.test.ts`, `e2e/accounts.spec.ts` |
| 19 | `supabase/tests/database/accounts.test.sql`, `tests/personal-data.test.ts` |
| 20 | `supabase/tests/database/accounts.test.sql`, `worker/account.test.ts`, `e2e/accounts.spec.ts` |
| 21 | `supabase/tests/database/accounts.test.sql`, `worker/account.test.ts` |
| 22 | `worker/account.test.ts`, `e2e/accounts.spec.ts` |
| 23 | `worker/account.test.ts`, `supabase/tests/database/accounts.test.sql`, `tests/personal-data.test.ts`, `e2e/accounts.spec.ts` |
| 24, 25 | `supabase/tests/database/accounts.test.sql`, `src/screens/privacy-page.test.ts` (25 built with owner's call 3 = B, 24 months, per the approval "all recommendations" in `progress.md`) |
| 26 | `worker/account.test.ts`, `worker/account-logs.test.ts`, `tests/personal-data.test.ts`, `e2e/account-pages.spec.ts`, `e2e/accounts.spec.ts` |
| 27 | `e2e/account-pages.spec.ts`, `e2e/accounts.spec.ts` (axe in light and dark, 320 px, 200 percent text, keyboard) |
| 28 | `tests/checks-workflow.test.ts` (Mailpit no longer in the `-x` list; after merge and preview runs skip `@email` like `@seed`). Job 6 tests changed: `tests/checks-workflow.test.ts` now expects that list and that skip; nothing removed |
| 29 | `tests/personal-data.test.ts` |

## Checks run (round 2, local, Node 22; the project asks for 24, nothing needed 24)

- `npm run check:code`: pass.
- `npx vitest run`: 699 passed, 2 skipped (the skips need the private font files). Before the AGENTS.md cherry pick, `tests/agents-md.test.ts` failed on main's AGENTS.md, as on main.
- `npx supabase test db` on a fresh `supabase db reset`: 545 tests, pass.
- Red scratch run, statement 21 (removed `or not private.sign_in_is_live()` from `delete_my_account()`): FAIL, tests 44 to 46 (`[accounts 21] a signed out token is refused` and two more). Reverted.
- Red scratch run, statement 19 (a scratch migration adding `public.scratch_notes` with cascade and row level security, not in the export): FAIL, tests 28, 39 and 53 (`[accounts 19] the export has exactly one list per user table found in the catalogue`). Removed.
- Browser tests, local Supabase with Mailpit, built app, seeds loaded: `npx playwright test --project=chromium`: 124 passed, 15 skipped (font and preview only tests), including the `@email` tests. The fixed test also passed 5 repeats in isolation.
- Commit hook (lefthook, with gitleaks): ran on every commit, never skipped.

## Unfinished or needs the owner

- **Owner's call 2.** `src/privacy/notice-settings.ts` has one setting, `RESPONSIBLE`, set to `null`. The privacy page then says in the problem style that the name and contact are missing. The owner fills in the responsible name and the contact address. No agent chose them. Do not release before that.
- WebKit browser tests did not run here (no WebKit build on this machine). GitHub runs both browsers.
- The red scratch runs were local, not GitHub runs, because checks run only on pull requests and a scratch pull request was not opened. The manager may open one if a GitHub link is required.
- Owner setup on the Supabase test project (README, "Owner setup for accounts") is still to do before merge.
- Recordings deletion is proven only with the stand in file store; job 10 plugs in its real store.
- Statement 15 note from spec: `email_change` verification for guests was confirmed by the `@email` browser tests against local Supabase.

## How to run it locally

1. `npm ci`, then `npx supabase start -x realtime,storage-api,imgproxy,postgres-meta,studio,edge-runtime,logflare,vector,supavisor` (Mailpit runs at http://127.0.0.1:54324).
2. `npx supabase status -o env | node scripts/ci/write-test-settings.ts env .env.local --from-supabase-status`, then load `supabase/seeds/browser/*.sql` with psql.
3. `VITE_DESIGN_REFERENCE=1 npm run build`, then `LOCAL_DB_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres npx playwright test`. Port 4173 must be free (another job's server there is reused otherwise).
4. Open `/`, press Start, then "Your account", "Privacy notice", "Download my data" or "Delete my account".

Pushed head: `c9ac64f` on `factory/11-accounts`.

## Round 3

**What came back.** GitHub run 40359357474 on 44f5b15: 246 passed, 1 failed, WebKit only: `e2e/account-pages.spec.ts:183` "[accounts 27] axe ... light", `page.evaluate: AbortError: The operation was aborted.`

**Triage: wrong earlier decision (a real bug in the test harness), not a flake.** Round 2 added `Promise.all(document.getAnimations().map((a) => a.finished))` so that axe would wait for colour transitions. But when an animation is cancelled, its `finished` promise rejects with AbortError (that is what the Web Animations spec says), and `Promise.all` passes that rejection on.

**Evidence** (the run's `playwright-report` artifact, trace `0562d94...zip` from the failing WebKit test, read as data only):
- The trace's action list is `goto /sign-in` -> `fill "x"` -> `click "Send code"` -> `expect status "Please check the email address."` -> `evaluate document.fonts.ready` -> `evaluate Promise.all(...finished)`, and that last call has the AbortError.
- There is no navigation, reload, scheme switch or page close between the click and the failing call. The page scans before it (`/`, `/privacy`, `/account`, `/sign-in`) all completed.
- So a transition that was still running after the click (the button's press and focus colour) was cancelled before it finished. WebKit cancels it at that moment; Chromium had already finished it. The same wait was also in `e2e/accounts.spec.ts`.

**Fix** (3f0e160): a new `settleAnimations(page)` in `e2e/session-helpers.ts`, used by the `axe` helpers in both spec files. It takes the animations that are still running, waits for them with `Promise.allSettled` (a cancelled animation no longer changes the page, so it counts as settled), and checks again until none is running (at most 10 rounds). The axe assertion, its tags and every scanned page are unchanged.

I also cherry-picked the manager's `checks: run the browser test jobs on ubuntu-24.04` (bfbdd5c), so the browser jobs do not hang in `playwright install`.

**Commands and results**
- `npm run check:code`: pass. `npx vitest run`: 47 files, 699 passed, 2 skipped.
- Chromium browser tests, run from a private clone at `/tmp/claude-0/.../scratchpad/b11`. It had its own Supabase (project id `puhu11build`, ports 59321/59322/59324), its own preview port (4273) and its own browser folder. This left the worktree's `dist/` and the evaluator's stack (`puhu11eval`, 58xxx) alone. It used the browser seeds and `VITE_DESIGN_REFERENCE=1 npm run build`, then `LOCAL_DB_URL=...59322... MAILPIT_URL=http://127.0.0.1:59324 npx playwright test --project=chromium`: 124 passed, 15 skipped.
- WebKit did not run locally: the container has no WebKit host libraries (`browserType.launch` fails). WebKit was checked on GitHub instead.
- lefthook on commit: Prettier, gitleaks (no leaks), ESLint and tsc all pass.
- GitHub run 40364572122 on head bfbdd5c: "Browser tests (Playwright, local Supabase)" **success, 247 passed** (Chromium and WebKit, including both `[accounts 27]` axe tests). The type check, lint, Vitest, database, Python, dependency and secret scan jobs also pass.
- The same run's "Preview link (Cloudflare Worker behind Access)" job **fails**: `SUPABASE_URL is not set.` The repository secrets `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` and `CLOUDFLARE_ACCOUNT_ID` are empty. This is owner setup and not caused by the code; on 44f5b15 that job only showed as skipped because the browser tests failed first.

Pushed head: `bfbdd5c` on `factory/11-accounts`. Green browser test run: 40364572122.

Result: checks pass

## Round 4: merge of main after job 9

**What changed (plain words).** Merged `origin/main` (job 9, daily review) into the branch. Conflicts resolved:
- `AGENTS.md`: main's version exactly (2,199 words).
- `docs/conventions.md`, `docs/data-model.md`: both sides kept. One phrase in job 9's guest clean up paragraph ("Job 9 builds the clean up") now says job 11 built it, because `tests/personal-data.test.ts` forbids the old wording.
- `src/lib/database.types.ts`: regenerated with `npx supabase gen types --lang typescript --local --schema public` from a local database holding all merged migrations (own project id and ports 59xxx, config restored afterwards). Not hand merged.
- `session-types.ts`, `FrontDoor.tsx`, `worker/api.ts`: both jobs' states, links and routes kept (review states, next review day, account links, "I already have an account", the email signed out message, review routes plus the account routes).
- `SessionPage.tsx`: job 9's review loading kept; the email signed out check (statement 22) now covers loading today's session, every step save, Keep it's save and the review only finish.
- Export: job 9 added no user table; the pgTAP catalogue test (statement 19) still passes, so `export_my_data()` and the data inventory cover every user table.
- `e2e/account-helpers.ts` `frontDoorState` now also accepts job 9's empty day heading "That is all for today." (a real mismatch GitHub WebKit found; nothing weakened).

**Checks (local, Chromium).** `npm ci`; `npm run check:code` pass; `npx vitest run` 770 passed, 2 skipped; `npx supabase test db` 597 tests pass; `npx playwright test --project=chromium` 134 passed, 15 skipped, including `@email` with Mailpit. WebKit not run here. Lefthook and gitleaks ran on the merge commit.

**GitHub.** Merge commit `a5392d1`: run 40387519656 failed only WebKit `[accounts 12]` (the heading issue above). Fix commit `741b8ec`: run 40389094194, every check green except "Preview link", which failed (allowed by the manager's instruction).

Result: checks pass

## Round 5: merge of main after job 10, export covers the voice tables

**What changed (plain words).** Merged `origin/main` (job 10, speaking feedback and voice consent) into the branch (`aeb7f76`). The data export (`export_my_data()` in `20261022072911_accounts.sql`) and the data inventory (`src/privacy/data-inventory.ts`, `src/privacy/processors.ts`) now also cover job 10's user tables: the voice consent choices, `speech_checks` and `kept_recordings`. pgTAP `accounts.test.sql` and `data_model_schema.test.sql` were extended to match; the catalogue test (statement 19) fails if any user table is missing from the export, and the processors test fails if the inventory and the processor list disagree. The privacy notice's responsible name and contact were left empty on purpose.

Three browser test fixes followed, none weakening an assertion:
- `eb4575f`: `[accounts 10]` counts only its own address, and the daily review test waits for the caret before typing (`[review 9]`, ä button).
- `bd1b502`: the daily review test reads the caret through a typed function.
- `5113f59`: `[accounts 6]` (WebKit) counts the one address, not every user in the shared database.

**Checks (local).** `npm ci`; `npm run check:code` pass; `npx vitest run` 896 passed, 2 skipped (66 files); `npx supabase test db` 698 tests pass (9 files, after `db reset`); `npx playwright test e2e/accounts.spec.ts e2e/account-pages.spec.ts --project=chromium` 29 passed including `@email` with Mailpit (own project id, ports 58xxx; `config.toml` restored afterwards). Not run here: the rest of the Chromium suite and WebKit (GitHub ran both).

**GitHub.** Head `5113f59`. Run 40400873283 first hit the 30 minute job limit because "Install Chromium and WebKit" stalled for 21 minutes (cancelled, not a test failure; 220 tests had already passed). Rerun of the failed job: Browser tests green in Chromium and WebKit; every check green except "Preview link" (empty repository secrets, owner setup). Green run id: 40400873283.

Result: checks pass

## Round 6: owner's call 2

**Change (commit 8d47193).** Owner's call 2 answered on 27 October 2026: responsible party "Fumnanya Nketa", contact "exentrik.co@gmail.com". Both live only in `src/privacy/notice-settings.ts` (`RESPONSIBLE` is no longer nullable). The "not filled in yet" state and `MISSING_RESPONSIBLE` are removed (spec: no placeholders). `PrivacyPage.tsx` shows the name and a `mailto:` link that uses `.inlineLink` (wraps with `overflow-wrap: anywhere`, 44 px tall). The notice cards (`What we keep`, processors) sit in a new `.cards` class: no bullets, no left padding. The email screen and account page still link to `/privacy` (`[accounts 16]` browser test).

**Tests.** `src/screens/privacy-page.test.ts` `[accounts 16]`: name and mailto come from `RESPONSIBLE`; address shape. `tests/personal-data.test.ts` `[accounts 16]`: the address is written nowhere in src, worker or e2e except the settings file. `e2e/account-pages.spec.ts` `[accounts 16]`: name shown, one mailto link, fits 320 px. The old "missing" test was replaced because that state no longer exists.

**Commands.** `npm ci`; `npm run check:code` pass; `npx vitest run` 897 passed, 2 skipped; `npx playwright test e2e/account-pages.spec.ts --project=chromium` 12 passed (own Supabase project id `puhu11r6`, ports 563xx because other stacks held 57xxx and 58xxx; `config.toml` restored and stack stopped). lefthook (format, lint, type check, gitleaks) passed on commit.

**GitHub.** Green run id: 40552152516 on 8d47193: every check green except "Preview link" (empty repository secrets, owner setup).

Result: checks pass

## Round 6: owner's call 2 (written by the manager; the builder's session ended before its notes)

Commit `8d47193` on `factory/11-accounts`: `src/privacy/notice-settings.ts` now holds the responsible party "Fumnanya Nketa" and the contact "exentrik.co@gmail.com" (the owner said the address may change later; it stays in this one setting). `PrivacyPage.tsx` renders them with a wrapping `mailto:` link, and the notice cards no longer show list markers (`Account.module.css`). Tests: `src/screens/privacy-page.test.ts` checks the values come from the setting; `e2e/account-pages.spec.ts` gains a check of the rendered name and link. GitHub run 40552152516 on head 8d47193: every check green except "Preview link" (repository secrets).

Result: checks pass
