# Job 1-stack: build notes, round 2 (security review fixes)

Builder, 19 October 2026. Branch `factory/1-stack`, tip `0eeae15`. Pull request: https://github.com/fumnanyanketa/puhuscribe-v3/pull/1 (draft).

Round 2 fixes the security review (`review-security.md`): finding 1 (must fix), note 3, and the `.env.example` line from finding 2. The manager had already deleted the leaked artifacts, rotated the evaluator's service token, updated `CF_ACCESS_CLIENT_SECRET` and revoked Access sessions. I did not change the Cloudflare token, the Access app, or any Cloudflare or Supabase resource.

## What I changed

- **No file can hold the service token headers.**
  - When `CF_ACCESS_CLIENT_ID` and `CF_ACCESS_CLIENT_SECRET` are set, `playwright.config.ts` writes no trace (`trace: 'off'`) and no HTML report. It never records a HAR file. Screenshots and videos stay on, since they hold pixels only.
  - Without the token, for example the local browser check, traces are still kept for failed tests.
- **The preview job uploads only screenshots and videos.** The artifact is now `preview-screenshots-and-videos`, with paths `test-results/**/*.png` and `test-results/**/*.webm`. The HTML report, traces and `error-context.md` files are no longer uploaded. Playwright's error text can list request headers.
- **A guard runs before every upload: `scripts/ci/check-files-for-secrets.ts`.**
  - It fails if any file in `playwright-report/` or `test-results/` contains the value of a named environment variable. That includes every entry inside zip files, because Playwright traces are compressed zips and a plain `grep` would miss them.
  - It prints file and variable names only, never a value.
  - It refuses to run if a named variable is empty, because it would then check nothing.
  - It fails safe on a zip it cannot read.
  - The upload steps run only when the guard passed.
  - Preview job: it checks `CF_ACCESS_CLIENT_ID`, `CF_ACCESS_CLIENT_SECRET` and `SUPABASE_PUBLISHABLE_KEY`.
  - Browser check: it checks `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`.
- **`persist-credentials: false` on all 7 checkouts in `checks.yml`,** so the GitHub token is not left in `.git/config` while npm install scripts, the build, wrangler or Playwright run. The comment step already passes its own `GH_TOKEN`. The keep-awake workflow has no checkout.
- **`.env.example`.** `CLOUDFLARE_API_TOKEN` is now described as "A Cloudflare API token used only for Worker uploads", with no permissions listed.

## Tests for this round

Test names carry the statement they protect.

- `scripts/ci/check-files-for-secrets.test.ts`, 8 tests (statements 12 and 14). Every test uses a made-up value, never the real secret. They cover:
  - clean screenshots and videos pass;
  - a plain file holding the secret fails, and the output does not contain the value;
  - a deflated trace inside a zip holding the secret fails. The test first proves the value is invisible in the raw zip bytes;
  - the client ID is checked too;
  - an unreadable zip fails;
  - an empty variable makes the guard refuse to run;
  - missing folders are skipped;
  - the zip reader handles stored and deflated entries.
- `tests/playwright-config.test.ts`, 3 tests (statements 12 and 14):
  - with the token set, the trace is off, there is no HAR anywhere, and there is no HTML reporter;
  - without the token, traces are kept on failure and no headers are added.
- **Checked by hand against a real Playwright trace.** A throwaway test (not committed) sent a dummy secret header with tracing on. The guard found it in 5 entries of the real `trace.zip`, including `0-trace.network` and `2-trace.network`, and exited 1.

No test was removed or loosened.

## Check results

Local (Windows, Node 24.14.1), tip `0eeae15`:

- typecheck, lint and format: exit 0
- `npm test`: 13 files, 110 tests passed
- `npm run build`: both secret checks passed
- `npx playwright test`: 12 passed, 4 skipped (the 4 run only against the preview)
- `gitleaks git` on the full history: no leaks

GitHub, PR #1, run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39295790830, all seven jobs green:

- Type check, lint, format; Unit tests; Python tests and lint; Secret scan; Dependency check: success.
- Browser tests: 12 passed, 4 skipped. The guard reported "No secret values found in 24 files (checked SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY)", then the upload ran.
- Preview link: 16 passed against https://factory-1-stack-puhuscribe-preview.fumnanya.workers.dev. The guard reported "No secret values found in 15 files (checked CF_ACCESS_CLIENT_ID, CF_ACCESS_CLIENT_SECRET, SUPABASE_PUBLISHABLE_KEY)". Only `preview-screenshots-and-videos` was uploaded (14 files).
- The run's artifacts are `playwright-report`, `preview-screenshots-and-videos` and `gitleaks-results.sarif`. The gitleaks action uploads its SARIF on every run. I checked this one without printing any content: it has 0 results.

## Statement status

| Statement | Status |
|---|---|
| 1 to 6, 8 to 11, 16 | Met |
| 7 | Dropped by the owner |
| 12 Private preview link | Met, except the owner sign in check, which is done at owner approval |
| 13 | Met, in an EU region (`eu-west-1`), as the owner accepted |
| 14 | Met. Tokens are test only and are now kept out of uploaded files |
| 15 | Met. The workflow passed once on PR #1; daily runs start after merge |

Round 1 detail, with every test mapped to its statement, is in the git history of this file.

## Left open (not for this round)

- **Security finding 2: a narrower CI token.** This is the owner's or manager's step: a separate token from the "Edit Cloudflare Workers" template replaces the `CLOUDFLARE_API_TOKEN` secret. The workflow needs no change, because it only runs `wrangler versions upload`.
- **The reviewer's "look at closely" items:**
  - The Workers permission is account-wide.
  - `SUPABASE_TEST_DB_URL` is unused; keep it out of workflows.
  - If Dependabot secrets are added, add only the two `SUPABASE_TEST_*` values.
  - Keep fork secrets off.
  - Cache or rate-limit `/api/health` once a public production Worker exists.
  - Check Workers observability logs before learner data arrives.
  - Python `>=` ranges come from v2 unchanged.
- **Earlier open items:**
  - The PR stays a draft until the owner sign in check.
  - There is no deploy-on-push-to-main step yet.
  - Dependabot pull requests will fail the database browser test without Dependabot secrets.
  - Scheduled workflows pause after 60 days of no repository activity.
- **No email address** appears in code, workflows, docs, tests or these notes.

## How to run it locally

From `C:/Users/fumna/dev/puhuscribe-v3/.worktrees/1-stack` (Node 24; `.env.local` holds the test project settings):

```
npm ci
npm run dev
npm test
npm run build
npm run test:browser
```

Result: checks pass
