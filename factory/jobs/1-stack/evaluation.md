# Job 1-stack: evaluation, round 1

Evaluator, 19 October 2026. Branch `factory/1-stack` at `0eeae15` (PR #1, draft). Fresh clone from GitHub into a scratch folder on Windows (Node 24.14.1, npm 11.11.0), with only `.env.local` copied across. Its values were never printed. Browser checks at 375 x 812 in Chromium and WebKit, plus the Claude browser pane. Owner decisions applied from `summary.md`: statement 7 dropped; statement 13 needs "an EU region" (the project is in `eu-west-1`); GitHub stays on the Free plan. I read `build.md` only after testing.

Nothing was changed in Cloudflare, Supabase or GitHub: no reruns, pushes or comments.

## Results

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `1-readme-and-decision.txt` | Spec Decision has 15 stack rows, each with pick, runner up and why it lost. README stack table links to `spec.md#decision`. |
| 2 | pass | `2-boots-locally.png`, `2-boots-locally-webkit.png`, `2-api-health-json.png`, `2-browser-pane-localhost.png`, `2-npm-ci.txt`, `2-npm-dev.txt`, `2-8-local-api-checks.txt`, `2-main-path-local-chromium.webm` | Fresh clone: `npm ci` exit 0, `npm run dev` served http://localhost:5173. Page shows "Server: ok" with no console errors in either browser. `/api/health` returns `{"status":"ok","service":"puhuscribe","database":"reachable"}`. POST gets 405 with an `allow` header, which proves Worker code answers and not a static file. |
| 3 | pass | `3-npm-build.txt` | `npm run build` exit 0. It built `dist/client` (browser files) and `dist/puhuscribe_preview/index.js` (Worker bundle). |
| 4 | pass | `4-typecheck.txt`, `4-lint.txt`, `4-format-check.txt` | All three exit 0 on the fresh clone. |
| 5 | pass | `5-npm-test.txt`, `5-engine-tests-verbose.txt`, `5-6-v2-diff.txt` | `npm test`: 110 passed, including 16 in `fsrs.test.ts` and 8 in `grade.test.ts`. I cloned v2 myself at `9c8d0a0` (also v2's main tip). All 6 TS files have the same git blob as v2. `docs/v2-imports.md` lists no engine changes. |
| 6 | pass | `5-6-v2-diff.txt`, `6-10-ci-run-key-lines.txt` | All 7 Python and data files have the same blob as v2 at the same paths. In CI run 39295790830, libvoikko1 and voikko-fi were installed, then pytest ran under `unshare --net` with `ANTHROPIC_API_KEY` removed: "collected 9 items ... 9 passed", and the count guard printed `{'tests': 9, 'failures': 0, 'errors': 0, 'skipped': 0}`. |
| 7 | dropped | n/a | Owner's call 3: nothing visual is imported. |
| 8 | pass | `8-built-files-secret-scan.txt`, `8-guard-negative-tests.txt`, `2-8-local-api-checks.txt` | `/api/*` is served by the Worker on the page's own address. No `Access-Control-Allow-Origin` was sent for an outside origin. The real `.env.local` values do not appear in `dist/client`. Both guards fail when fed bad input: a `VITE_` secret name in the environment or in an env file exits 1; a built file containing a secret name, an `sb_secret_` key or the real publishable key value exits 1. |
| 9 | pass | `9-gitignore-and-env-example.txt`, `9-gitleaks-full-history.txt` | `git check-ignore` confirms every path the statement lists is ignored. `.env.example` has 4 names with empty values and a one-line purpose each, plus the GitHub-only secrets in comments. Local gitleaks 8.30.1 over all 38 commits of the fresh clone: no leaks. |
| 10 | pass | `10-ci-pr-checks.txt`, `6-10-ci-run-key-lines.txt`, `10-12-13-ci-playwright-lines.txt`, `10-local-playwright.txt` | PR #1 run 39295790830 at `0eeae15`: all six checks green, plus the preview job. Browser tests ran at 375 x 812 on Chromium and WebKit against the built app (`vite preview` with the Worker): 12 passed, 4 skipped (preview only). The same tests also passed locally: 12 passed. |
| 11 | pass (see oddities 1 and 2) | `11-ci-red-runs.txt` | Run 39278766728 (`scratch/1-stack-fake-key`): gitleaks found 1 leak (generic-api-key) and the check went red. Run 39278776200 (`scratch/1-stack-broken-scheduler-test`): Vitest went red, with the scheduler test failing and the v2 hash check failing. Both branches are gone. PRs #2 and #3 are closed. |
| 12 | pass; owner sign-in check pending | `12-preview-access-login-no-token.png`, `12-ci-preview-access-signin-chromium.png`, `12-ci-preview-app-with-service-token-webkit.png`, `12-ci-preview-deep-link-chromium.png`, `12-ci-preview-main-path-chromium.webm`, `12-preview-access-no-token.txt`, `10-12-13-ci-playwright-lines.txt` | The preview job uploaded a `puhuscribe-preview` version with alias `factory-1-stack`, ran 16 tests through the service token (all passed) and posted the link on PR #1. With no token, I got HTTP 302 to `<team>.cloudflareaccess.com` for `/`, `/api/health`, the main workers.dev address and the version address. A fake token also got 302. The Access page shows "Log in to puhuscribe-preview", not the app. The owner's own sign-in is an **owner check pending** (see oddity 3). |
| 13 | pass | `13-14-env-local-shapes-and-region.txt`, `13-local-health-wrong-database.txt`, `2-8-local-api-checks.txt`, `10-12-13-ci-playwright-lines.txt` | The test project's pooler host is in `eu-west-1` (Ireland, EU), which the owner accepted. Locally, `database: reachable` came back 6 times out of 6. With deliberately wrong settings the same route says `unreachable`, so the check is real. The `[13]` browser test passed in the CI browser job and against the preview link. I did not check the project name `puhuscribe-test` myself (no Supabase access). |
| 14 | pass (with a gap, see oddity 4) | `14-github-secret-names.txt`, `13-14-env-local-shapes-and-region.txt`, `14-worker-secret-names-not-readable.txt` | `.env.local` holds only `SUPABASE_URL`, an `sb_publishable_` key and the pooler connection string for the same project. It has no `sb_secret_`, no `sbp_` personal access token and no JWT. GitHub secret names: 3 `SUPABASE_TEST_*`, the Cloudflare token and account ID, and 2 `CF_ACCESS_*`. No Dependabot or environment secrets. I could not list the Worker secrets myself. The workflow passes only `SUPABASE_TEST_URL` and `SUPABASE_TEST_PUBLISHABLE_KEY` to the Worker. |
| 15 | pass | `15-keep-awake.txt` | `keep-test-db-awake.yml` runs daily at `17 5 * * *`. Its run on the PR got "Supabase test project answered HTTP 200" (3 runs, all green). Scheduled runs begin only after merge to main, where the file does not exist yet. |
| 16 | pass | `16-running-costs.txt` | README "Running costs" lists GitHub Free, Workers Free, Zero Trust Free and Supabase Free, each at €0. I have no billing access, so the plans are taken from the README and `summary.md`. |

Browser break attempts (`break-browser-tests.txt`, `break-slow-network-waiting.png`, `break-api-down.png`), in both Chromium and WebKit:
- Two fast reloads mid-check, then Back and Forward through `/api/health`: the page ends on "Server: ok" every time.
- A 4-second API delay: the page shows "Checking the server." and then "Server: ok".
- API refused: the page shows "Server: not reachable".
- API answering 500 with HTML: also "Server: not reachable".

## Failures

None.

## Oddities (not failures)

1. **Red run links are no longer in the current build notes.** Statement 11 asks for them there. Round 2 rewrote `build.md` and dropped them. It points to "the git history of this file", and the links are in commit `caf34d8`. The manager may want the two links put back:
   - https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39278766728
   - https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39278776200
2. **Scratch PRs are closed, not deleted.** GitHub does not let users delete pull requests, so closed is the most that is possible. The branches are deleted.
3. **The Access sign-in page offers only "Cloudflare" as the sign-in method.** It shows no email one-time code option. When the owner does the pending sign-in check, they should confirm their chosen email actually gets through this screen. If it does not, the Access login method needs a one-time PIN option.
4. **I could not list the `puhuscribe-preview` Worker secrets.** The local Wrangler login is for an account that does not hold this Worker ("Worker not found"). The `.env.cloudflare*` files were off limits. The "only test values on the Worker" part of statement 14 therefore rests on the workflow code, plus the fact that the preview reaches the database with the test project's key. I also did not confirm whether `wrangler versions upload --secrets-file` carries over secrets the manager may have set on the placeholder Worker.
5. **Local browser tests fail if you build before `.env.local` exists.** The build copies `.env.local` into `dist/puhuscribe_preview/.dev.vars`. A build made earlier serves `database: not_configured` under `vite preview`, so the two `[13]` tests fail (`odd-local-playwright-built-before-env.txt`). Rebuilding fixed it. The README does not say to rebuild after adding settings.
6. **The page and `status` say "ok" even when the database is unreachable.** `/api/health` returns HTTP 200 with `status: ok` and `database: unreachable`, and the page only shows "Server: ok". This is fine for this job; later jobs should decide what a learner sees.
7. **Vite's dev server handles CORS (cross-site access) itself on `/api/*` locally.** It answers OPTIONS preflights, and it echoes `Access-Control-Allow-Origin` for `http://localhost:*` origins. This happens in `npm run dev` only, never `*` and never for outside origins. The built Worker sends no such header (CI test `[8]`).
8. **`/api` without a slash gets the app's HTML, not the Worker's JSON 404.** This is because `run_worker_first` covers `/api/*` only. It is harmless today.
9. **The built-file guard does not flag a made-up `sb_publishable_` string.** It catches only the real value. Publishable keys are meant to be public, so this is acceptable. `.env.example` says the browser never sees it.
10. **`.env.example` leaves out tooling variables** (`PLAYWRIGHT_BASE_URL`, `CI`, `BRANCH`). All are non-secret test-runner or CI variables, documented in `playwright.config.ts` and the workflow.
11. **The spec's Decision section still names Frankfurt `eu-central-1`.** README and `.env.example` correctly say Ireland `eu-west-1`.
12. **In the fake-key scratch run, the Python job ended as "cancelled" about 13 minutes after it started.** Every step had succeeded, so this looks like a runner hang against the 10-minute timeout. It is worth watching for check-minute use.
13. **CI gitleaks on a PR scans only the PR's commits** (8 in the latest run). I covered the full history with my local scan of all 38 commits.
14. **Build notes say "13 files, 110 tests" for `npm test`.** I counted 12 files and 110 tests.
15. **The latest PR run waited about 11 minutes between the six checks and the preview job.** This is queue time, not a failure. The `CLOUDFLARE_API_TOKEN` secret was replaced at 17:45:53Z, before the preview job started at 17:50:10Z, so the upload used the narrower CI key.

Result: pass
