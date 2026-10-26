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

Result: checks pass
