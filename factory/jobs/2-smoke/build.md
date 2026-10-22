# Job 2-smoke: build notes, round 2

Builder, 19 October 2026. Branch `factory/2-smoke`, tip `f8f3e0c`. Pull request (draft): https://github.com/fumnanyanketa/puhuscribe-v3/pull/6

Round 2 makes the three fixes the manager asked for, from `review-design.md` (findings 1 and 2) and `review-security.md` (the note on `supabase/setup-cli`). Nothing else changed.

## What changed

1. **The page's time limit works on older phones.**
   - Before, the page used `AbortSignal.timeout()`, which older iOS Safari (before 16) and older Android WebViews do not have. On those browsers every save failed, and "Try again" failed the same way.
   - The 10 second limit is now an `AbortController` with a `setTimeout`, and the timer is cleared when the request finishes (`src/App.tsx`).
2. **Keyboard focus is kept after "Try again".**
   - The button disappears once pressed, so focus used to fall back to the top of the page.
   - Now pressing it first moves focus to the status line, which has `tabIndex={-1}` so it can take focus without becoming a Tab stop. The status line keeps focus through "Saving your visit." and the result.
   - I chose this over keeping a disabled button: the spec says the button appears only after a failure, and a button disabled while it has focus loses focus in Chromium anyway.
3. **Third-party actions are pinned to full commit SHAs** (`.github/workflows/checks.yml`), with the version in a comment:
   - `supabase/setup-cli@45a513f8c64c0bc8e0e3dfe572b5c95be85f6359 # v3.0.1`, in both database jobs. This is the commit the `v3` tag pointed to.
   - `gitleaks/gitleaks-action@e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e # v3.0.0`. It receives the GitHub token. This is the commit the `v3` tag pointed to.
   - The other actions are GitHub's own (`actions/checkout`, `setup-node`, `setup-python`, `upload-artifact`) and stay on version tags. `keep-test-db-awake.yml` uses no actions.
   - A comment at the top of the workflow states the rule.

## New and changed tests

No test was deleted or loosened.

- `e2e/visits.spec.ts`, new, Chromium and WebKit, built app and preview:
  - `[smoke 3] keyboard: Tab to "Try again", press Enter, and focus moves to the status line instead of being lost`. It presses Tab to reach the button. WebKit only tabs to buttons when a system setting allows it, so if Tab did not reach the button, the test focuses it directly. Then it presses Enter and checks the status line has focus during "Saving your visit." and after "Your visit is saved."
  - `[smoke 3] the visit still saves on a browser without AbortSignal.timeout (older iOS Safari, Android WebViews)`. It removes `AbortSignal.timeout` before the page loads, checks it is gone, and expects "Your visit is saved."
  - `[smoke 3] without AbortSignal.timeout, a request with no answer still ends in the failure message after 10 seconds`. It uses Playwright's fake clock: still "Saving your visit." at 9 seconds, then the failure message and "Try again" at 10 seconds.
  - Before the fix, 5 of these 6 runs failed: both keyboard runs, both "still saves" runs, and the WebKit "10 seconds" run. The Chromium "10 seconds" run passed even before the fix, so on its own it does not prove the fix. All 6 pass after it.
- `tests/checks-workflow.test.ts`:
  - The two `setup-cli@v3` checks now require the pinned SHA. This makes them stronger.
  - New: every action not made by GitHub, in both workflow files, must be pinned to a 40-character commit with a `# vX.Y.Z` comment. `checks.yml` must have exactly three such lines.
  - New: the gitleaks line must be pinned.

## Check results

Local (Windows, Node 24.14.1, tip `f8f3e0c`):

- `npm run typecheck`, `npm run lint`, `npm run format:check`: exit 0
- `npm test`: 14 files, 165 tests passed
- `npm run build`: both secret checks passed
- `npx playwright test`: 38 passed, 6 skipped (preview only), twice in a row
- `gitleaks git` on the branch's commits since `origin/main`: no leaks. Following the new rule, I no longer scan or print the working folder, which holds `.env.local`.
- The database tests do not run here (no Docker). The GitHub check is the reference.

GitHub, PR #6, run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39309408183 at `f8f3e0c`. All nine checks are green:

- **Database tests (local Supabase, pgTAP):** 22 of 22 passed, with setup-cli at the pinned commit. https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39309408183/job/118254812098
- **Apply database changes to the test project:** "Remote database is up to date.", then 22 of 22 passed on the test project. https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39309408183/job/118256205450
- **Browser tests:** 38 passed, 6 skipped. The upload guard found no secret value in 94 files. https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39309408183/job/118256605190
- **Preview link:** 44 passed against https://factory-2-smoke-puhuscribe-preview.fumnanya.workers.dev. The guard found no secret value in 59 files. https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39309408183/job/118257683941
- **Other checks:** Type check, lint and format; Unit tests; Python tests and lint; Secret scan (gitleaks at the pinned commit); Dependency check. All succeeded.

## Unchanged from round 1 (still true)

- **Statements met.** 1 to 11, 13 and 14 are met, and 12 is met for the automated part. The evaluator still does:
  - the row count on the test project before and after;
  - listing the table's columns;
  - checking `npm run dev` in the network panel.
- **Red run for statement 9:** https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39306307758/job/118244184064
  - Scratch PR #7 gave `anon` read access, and tests 9 and 15 failed.
  - The apply, browser and preview jobs were skipped.
  - The PR is closed and the branch deleted.
- **The migration reached the test project** in run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39304093094.
- **Job 1 test lines changed in round 1:** all in `e2e/health.spec.ts`, swapping the old page text for "Hei!" and "Your visit is saved.", and `/api/health` for `/api/visits`, in four tests plus the header comment. The full list is in round 1 of this file in git history.
- **Check minutes:** about 14 billed minutes per full run (each job rounded up to the minute). Round 2 adds about 1 minute: the three new browser tests run in both browsers, here and on the preview. Every service is still free.
- **Still open:**
  - Whether pgTAP stays installed on the test project after the CLI's test run.
  - The Cloudflare logging questions from the spec.
  - The `--db-url` password is passed as a command line argument (GitHub masks it; the runner is used once).

## How to run it locally

From `C:/Users/fumna/dev/puhuscribe-v3/.worktrees/2-smoke` (Node 24; `.env.local` holds the test project settings):

```
npm ci
npm run dev            # open http://localhost:5173: "Hei!" and "Your visit is saved."
npm test
npm run build
npm run test:browser
```

Result: checks pass
