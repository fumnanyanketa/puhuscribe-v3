# Build notes: 13-review-site (carried over to the public repository)

Builder, 22 October 2026. Public repository `fumnanyanketa/puhuscribe-v3`, branch `factory/13-review-site`, commit `20c34e1` on top of the public main, draft pull request https://github.com/fumnanyanketa/puhuscribe-v3/pull/8 (the factory merges; not from GitHub). Spec label `[site N]`. Built for DNS case C1 from the manager's addendum: the Worker and its Access lock live in the Exentrik Cloudflare account. Nothing was deployed and nothing in any Cloudflare account was touched.

## Carry over to the public repository

The owner approved the job in the private repository, which is now archived (`puhuscribe-v3-archive`). Its commits, pull request #19 and run numbers below belong to that archive. In the public repository the job is one commit, `20c34e1`, made from the saved patch of the old branch against the old main.
- **How it was applied.** `git apply --3way --index` applied all 24 files without a conflict. Recording files and binary evidence were excluded. The direct apply wrote CRLF into the working copy on this Windows machine, so the files were rewritten from the index, and every job file now checks out LF. The lock file was regenerated with `npm install --package-lock-only`. The only change against the public main is the `jose` entry.
- **Public repository protections kept, and extended to this workflow.** `review-site.yml` runs only its build job on a pull request, and that job holds no secret or variable, so pull requests from forks get nothing. A new test, "[site 10] [public 1] ... every job that runs on a pull request (forks included) holds no secret", fails if a job holding a secret could run on a pull request. The live test step now also sets `PUHUSCRIBE_NO_TRACE: '1'` (tested), so no trace or HTML report is written into a public artifact. It already uploads only `.png` and `.webm` files after the secret check. `checks.yml`, the Switzer font guard and `THIRD-PARTY-NOTICES.md` are untouched.
- **Nothing private in the commit.** No email address, key, token, account id or Access team name appears in the diff (checked with an email pattern and a 32 hex pattern), and no binary file. The index screenshots are outside the repository: `C:\Users\fumna\dev\puhuscribe-v3-evidence\13-review-site\local-4-index-375-chromium.png` and `local-4-index-375-webkit.png`.
- **Local checks at `20c34e1`.** `npm ci` and `npm run check:code` pass. `npm test`: 632 passed and 2 skipped. One test failed, the known gitleaks timeout in `scripts/hooks/commit-tool.test.ts` ("[tooling 9] a made-up key is refused"). Run alone, all 13 tests in that file pass, and the file is unchanged from main. The review site browser tests: 6 passed, 18 live tests skipped. The lefthook commit check passed.
- **GitHub at `20c34e1`.** See the last line of this file and the manager's report.

## Round 2: what changed

From `evaluation.md` (two must-fix items) and the manager's bundled should-fix list.

**Must fix 1. Windows checkouts.** `.gitattributes` gains `review-site/** text eol=lf`. The job's other files were already covered: `scripts/**`, `e2e/**`, `tests/**`, `/.github/**`, and `/*.md` for the README. A new test, "[site 9] [site 10] every review site file checks out with LF on every machine" in `tests/review-site.test.ts`, asks `git check-attr eol` about every file of the job; it goes red when the new line is removed. Proof on this Windows machine, from fresh clones of GitHub with `core.autocrlf=true`: at the round 1 tip the five `review-site/` files check out `w/crlf`; at `b8cdf45` every job file is `w/lf`, and `npm ci && npm run check:code` passes with exit code 0 (`evidence/r2-must-fix-1-windows-clone-check-code.txt`).

**Must fix 2. The settings check test passed for the wrong reason.** In `review-site/handler.test.ts` the Access key source is now a spy (`vi.fn`) that hands out the right key and never throws. The tests now assert that it is never called:
- with either setting missing or empty;
- with a team domain that is not `https://<team>.cloudflareaccess.com` (four shapes, including `...cloudflareaccess.com.evil.example`, `http://` and a trailing slash), each with a token that the handed-out key would accept;
- with an AUD that is not 64 lower case hex characters (new test).

The valid token test asserts the spy was called with the team domain. Scratch runs, each file restored afterwards (`evidence/r2-break-6-3-settings-and-folder-checks.txt`):
- Team domain check removed: 2 tests red.
- AUD check removed: 2 tests red.
- The whole settings line removed: 3 tests red.

**Should fix, done.**
- `scripts/review-site/build.ts` refuses a `content/drafts` folder or a listed `content/drafts/<slug>` folder that is a symlink or a file. There are two new Vitest cases (a symlinked dialogue folder and a symlinked drafts folder), and the "no drafts folder" case now checks its exact message. Removing the check turns these 3 tests red (same evidence file).
- Bad input now also removes any older `dist-review/`, so a stale site cannot be deployed by mistake. The round 1 test "an existing build is left alone" was changed on the manager's instruction to "bad input also removes an older build". This is a deliberate change of behaviour, not a weaker test.
- The 404 answer is a small HTML page: "Not found. Go to the start page", linking to `/`. It has no script and no file list, and keeps every header and the strict site policy. Unit tests check the exact page, its single link and HEAD. The live 404 test now checks for the link instead of the old plain line.
- Each round link's accessible name includes the dialogue title, for example `aria-label="Round 1, A new colleague"`. The visible text is still "Round 1". A first try with a visually hidden span gave screen readers "Round 1 , A new colleague", so I switched to `aria-label`; its name starts with the visible text. Covered by the unit tests and by `e2e/review-site-index.spec.ts`, which looks up the exact accessible name and checks the visible text, in Chromium and WebKit.
- `docs/content-pipeline.md` says Cloudflare (the Exentrik account) holds both emails in the Access policy and its sign-in records and sends the PIN email; that where, whether in the EU and for how long are not confirmed; and that removing the reviewer does not delete those records. It also names the four deploy settings (from the design review's notes).

**Should fix, not done, with the reason.**
- **"Dialogue: <title>" instead of the slug.** Not changed. Spec statement 4 asks for each dialogue's English title and its slug, and the title is already the heading of each card, so "Dialogue: <title>" would print the title twice and drop the slug the spec requires. If the manager wants the slug line gone or reworded, it is a one line change in `indexHtml` once the spec says so.
- **`package.json` and `package-lock.json` in the push trigger.** Left out. Dependabot bumps are merged to main by a person, so the actor check in the deploy job would not stop them, and a path filter cannot tell a Dependabot change from any other. Adding the two files would redeploy the review site after every merged dependency bump. A `jose` update reaches the site with the next content change or a manual start.

## What was built (current state)

- **The list.** `review-site/dialogues.json` is `{"dialogues": ["meeting-people-new-colleague"]}` (owner's call 2, A).
- **The build.** `npm run build:review-site` (`scripts/review-site/build.ts`, run by Node 24) writes `dist-review/` with the index, `robots.txt` and each listed dialogue's `round-<n>.html`, byte for byte. Every input is checked first. On bad input it names the cause, writes nothing and removes any older `dist-review/`. Bad input means a bad or repeated slug, a missing or symlinked drafts or dialogue folder, a slug with no review page, a symlinked page, a page over 25 MiB or a badly named page.
- **The index page.** Each dialogue's English title and slug, and one link per round with "Review received" or "Waiting for your review". Two plain sentences say what to do. It has no script and loads nothing from the network. Screenshots (kept outside the public repository): `local-4-index-375-chromium.png` and `local-4-index-375-webkit.png` in `C:\Users\fumna\dev\puhuscribe-v3-evidence\13-review-site\`.
- **The Worker** `puhuscribe-review` (`review-site/worker.ts` entry, rules in `review-site/handler.ts`):
  - Answers only GET and HEAD.
  - Serves a file only with a valid Access token for this application: keys from `<team domain>/cdn-cgi/access/certs`, RS256 only, with issuer, audience and expiry checked. The settings' shapes are checked before any key is asked for.
  - Looks up only `/`, `/robots.txt` and `/<slug>/round-<n>`. Everything else gets a 404 page with a link to the start page.
  - Sets the noindex, no-store, no-referrer, nosniff and no-framing headers on every response.
  - Has no logs, never opens the token's claims, and is bound to nothing but the assets.
- **The workflow** `.github/workflows/review-site.yml`, unchanged in round 2. It builds, tests and dry runs on pull requests with no secret, and deploys only from main. It skips with a notice until the setup exists and fails on a half finished setup. The live tests run after a deploy, and only clean screenshots and videos are uploaded.
- **Docs.** `docs/content-pipeline.md`, `docs/conventions.md`, README running costs, `.env.example`.

## Tests by "Done when" statement

| Statement | Tests |
| --- | --- |
| 1 | `tests/review-site.test.ts` "the list" (3 tests); `scripts/review-site/build.test.ts` "a list file holding anything other than the slugs" |
| 2 | `scripts/review-site/build.test.ts` "the build copies only listed pages" (4 tests, SHA-256 equality and the git ignore) |
| 3 | `scripts/review-site/build.test.ts` "the build refuses bad input" (17 tests: bad slug, path slug, duplicate, no page, no drafts folder, symlinked dialogue folder, symlinked drafts folder, symlinked page, over 25 MiB, exactly 25 MiB accepted, five bad names, extra keys, older build removed) |
| 4 | `scripts/review-site/build.test.ts` "the index page" (7 tests); `e2e/review-site-index.spec.ts` (3 tests, Chromium and WebKit at 375 x 812, including the accessible link names) |
| 5 | `review-site/handler.test.ts` "search engines kept out" (3 tests); live: `e2e/review-site.spec.ts` headers test |
| 6 | `review-site/handler.test.ts` "the second lock" (13 tests, key source spy). Breaks: `evidence/break-6-always-allow.txt` (round 1), `evidence/r2-break-6-3-settings-and-folder-checks.txt` (round 2) |
| 7 | `review-site/handler.test.ts` "read only" (10 tests, includes the 404 page). Breaks: `evidence/break-5-7-headers-methods-paths.txt`. `wrangler dev`: `evidence/local-5-7-wrangler-dev.txt` |
| 8 | `tests/review-site.test.ts` "keeps no logs and never reads who signed in" |
| 9 | `tests/review-site.test.ts` "the review Worker" (3 tests) and "line endings" |
| 10 | `tests/review-site.test.ts` "the review site workflow" tests. Manual start from the branch, deploy skipped: run 39732155909 (`evidence/ci-10-manual-start-from-branch-deploy-skipped.txt`). Deploy gate with a stub: `evidence/local-10-11-deploy-step-gate.txt` |
| 11 | `tests/review-site.test.ts` "passes the two Access settings as plain variables", "settings without emails" (2 tests) |
| 12 | `scripts/review-site/build.test.ts` "a new round goes up by itself, only when listed" |
| 14 to 17 | `e2e/review-site.spec.ts` (9 tests per engine), live only. Round 1 run against a local stand in: `evidence/local-14-17-live-tests-against-local-stand-in.txt` |
| 19 | `tests/review-site.test.ts` "the live tests run only the @review-site tests, and only clean files are uploaded" |
| 20 | `tests/review-site.test.ts` "written down" (3 tests) |
| 13, 18 | Owner and manager steps in the Zero Trust dashboard, after merge |

## Checks run (round 2)

On this computer in the worktree, 22 October 2026, at `b8cdf45`, unless marked otherwise.

| Check | Command | Result |
| --- | --- | --- |
| Type check, lint, format | `npm run check:code` | Pass |
| Same, in a fresh Windows clone with `core.autocrlf=true` | `npm ci && npm run check:code` | Pass (`evidence/r2-must-fix-1-windows-clone-check-code.txt`) |
| Unit tests | `npm test` | 32 files, 560 tests pass |
| Browser tests, this job | `PLAYWRIGHT_BASE_URL=http://localhost:9 npx playwright test e2e/review-site-index.spec.ts e2e/review-site.spec.ts` | 6 passed, 18 live tests skipped (no `REVIEW_SITE_URL`) |
| Commit check (lefthook: Prettier, ESLint, tsc, gitleaks) | on the round 2 commit | Pass |
| GitHub "Review site" on the pull request | run 39736945156 | Pass: build, tests, dry run; deploy skipped |
| GitHub "Checks" on the pull request | run 39736945137 | Pass, every job (apply and after-merge browser tests skipped as on every pull request) |

## What waits for the owner (nothing fails red on main until then)

Unchanged from round 1. The first main run after merge skips the deploy with the notice "Review site not deployed" and stays green. The steps, in order:

1. Switch on Zero Trust Free in the Exentrik account and pick a team name. If Cloudflare asks for a payment card for the $0 plan, that is the owner's call.
2. Add One-time PIN as the login method.
3. Create a service token for the live tests. Cloudflare shows the client secret only once.
4. Create the Access application for `puhuscribe.exentrik.co` with a 24 hour session and two policies. An Allow policy holds the owner's chosen email and the reviewer's email, typed in the dashboard. A Service Auth policy holds the token from step 3. There is no Everyone rule and no Bypass rule. Copy the AUD tag.
5. Create an API token limited to the Exentrik account and the exentrik.co zone. First confirm there is no DNS record named `puhuscribe`. If the deploy cannot attach the domain with this token, attach it once in the dashboard rather than widening the token.
6. GitHub secrets: `CLOUDFLARE_REVIEW_API_TOKEN`, `CLOUDFLARE_REVIEW_ACCOUNT_ID`, `REVIEW_CF_ACCESS_CLIENT_ID`, `REVIEW_CF_ACCESS_CLIENT_SECRET`.
7. GitHub variables: `REVIEW_ACCESS_TEAM_DOMAIN`, `REVIEW_ACCESS_AUD`, and `REVIEW_WORKERS_SUBDOMAIN` (without it the statement 17 test skips, which proves nothing).
8. Start "Review site" on main. Then the owner signs in from a private window (statement 18), and the manager takes the masked Access screenshot (statement 13).

## Things the manager should know

- **Two more secrets than the brief named:** `REVIEW_CF_ACCESS_CLIENT_ID` and `REVIEW_CF_ACCESS_CLIENT_SECRET`, read only by the live test step. The deploy step uses only the two Cloudflare secrets. Under C1 the PuhuScribe account's evaluator token cannot pass the Exentrik organisation's Access.
- **The Worker is two files.** A Worker's entry file may export only handlers.
- **405 comes before the token check.** It reveals nothing and serves nothing.
- **Extra refusals beyond the spec.** The Worker and the deploy step refuse a team domain or AUD of the wrong shape. Tokens must be RS256 and carry an expiry. An older round with no returned file says "Not reviewed".
- **ESLint ignore** is `**/.wrangler/`, because `wrangler dev` writes `review-site/.wrangler/`.
- **Not verified, as the spec flagged:** whether Access adds `Cf-Access-Jwt-Assertion` to service token requests (if not, the statement 15 live tests get 403 on the first main run); whether the new token may attach the custom domain; Cloudflare's default session length.
- **For `factory/todo.md`** (the manager's file), round 2 left these alone:
  - The design review's owner guidance for this file: a short owner-only section, and a draft message for the reviewer.
  - Its notes on a finished-state line, round order, `role="list"`, and a link back from the review page.
  - The security note about a GitHub environment that limits the deploy secrets to main.
  - The RS256 pin, which has no test of its own.

## How to run it locally

```
npm ci
npm run build:review-site
npx vitest run scripts/review-site review-site tests/review-site.test.ts
PLAYWRIGHT_BASE_URL=http://localhost:9 npx playwright test e2e/review-site-index.spec.ts
npx wrangler dev --config review-site/wrangler.jsonc   # 403 to everything: no Access settings locally
```

## Earlier rounds

- **Round 1**, tip `6d30b7e`. Built the list, the build script, the index, the Worker and its config, the workflow, the live tests and the docs. GitHub runs:
  - "Checks" 39732146905, green.
  - "Review site" 39732147030, green.
  - Manual start from the branch 39732155909, green with the deploy skipped.

  Evidence: `evidence/ci-pr19-checks.txt`, `evidence/ci-10-pr19-review-site-dry-run.txt`, the `break-` and `local-` files. The evaluator found two must-fix items:
  - CRLF on Windows checkouts.
  - A settings test that passed for the wrong reason.

  Both are fixed in round 2.

Result: checks pass
