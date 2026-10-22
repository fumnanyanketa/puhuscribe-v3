# Build notes: 6-pr-local-db (round 1)

Branch `factory/6-pr-local-db`, pull request #14, head `7958daa`. Owner's call 1 is not answered yet, so option A (recorded proof only) applies. Milestones 1 to 4 are built; milestone 5 (option B, Docker Desktop) is not built, and nothing paid was added.

## What was built

- **Pull request browser tests now run on their own throwaway database.** A new check, "Browser tests (Playwright, local Supabase)", runs on every pull request (Dependabot included) and every manual run. Inside its own GitHub runner it starts a small Supabase (Postgres, the API gateway kong, postgrest and gotrue only), applies every migration from an empty database, loads any browser seed files, builds the app pointed at that database, and runs the full browser test suite in Chromium and WebKit. It starts at the same time as the database check. It holds no secret. The two Worker settings (local address and local publishable key) come from `supabase status` through `scripts/ci/write-test-settings.ts`, which prints names only and refuses any address that is not on the runner itself (`scripts/ci/supabase-status.ts`). After the tests, a `psql` step proves the app saved visits in that database.
- **After a merge, the browser tests run against the shared test project**, in a new check "Browser tests against the test project (after merge)". It runs only on a push to main once the apply job succeeded, leaves out tests tagged `@seed`, and keeps the upload guard. It is the only browser test job that gets the test project settings.
- **Preview links on database pull requests.** The preview job compares the pull request with its base branch (three-dot `git diff` of `supabase/migrations/`). When migrations changed, it still uploads the preview and posts the link, runs only the Cloudflare Access lock tests (now tagged `@preview`), and the comment adds the owner's note with a link to the run's `playwright-report` download (`scripts/ci/preview-plan.ts`). Otherwise it runs the suite without `@seed` tests, as before.
- **Local permissions match the test project.** `supabase/config.toml` sets `auto_expose_new_tables = false`.
- **Browser seed data has one home**, `supabase/seeds/browser/` (a README explains the rules). Only the local browser check loads it, in name order, stopping at the first error. With no files it logs that none exist.
- **Docs.** README sections "Database changes" and "Preview links", the checks table and three convention lines in `docs/conventions.md`, and the paragraph in `docs/data-model.md`.
- **Manager's extra statement: done.** `checks.yml` now skips pushes to main that change only `factory/` or `recording/` files (`paths-ignore`). It is safe. GitHub requires no check here: the repository is private on GitHub Free, where branch protection and rulesets are not available (`evidence/ci-13-no-required-checks.txt`, HTTP 403). Such a push holds no migration, so the apply job has nothing to apply. One gap needed closing, because skipped pushes would no longer get the CI secret scan, and factory notes are where agents write the most text. A small new workflow, `.github/workflows/secret-scan-notes.yml`, runs the same pinned gitleaks action on pushes to main that touch those folders (about 10 seconds). Pull requests still run every check. One residual edge: GitHub only looks at the first 300 changed files of a push when it applies a path filter, so a push of more than 300 files led by factory files could skip the checks; every such change already passed its pull request checks.

## Tests and the statements they cover

Repository tests in `tests/checks-workflow.test.ts` (labels `[prdb N]`) and unit tests in `scripts/ci/supabase-status.test.ts` and `scripts/ci/preview-plan.test.ts`.

| Statement | Tests or proof |
| --- | --- |
| 1 | `[prdb 1]` check name; runs on pull requests and manual runs, never on pushes; no `needs`; excluded services are exactly the CLI's list minus kong, postgrest and gotrue; no remote database command; start, then build, then the full suite; no tunnel. Proof: run 39652135818 |
| 2 | `[prdb 2]` no `secrets.` in the job; settings from `supabase status` via `write-test-settings.ts`; the start output filter tested against made-up key rows; report upload kept. Unit tests `[prdb 2]` in `supabase-status.test.ts` (only two names kept, secret key and JWT secret dropped, non-local address refused, errors print names only) |
| 3 | `[prdb 3]` psql row count step after the tests. Proof: "Rows in visits on the throwaway database: 30", and `[13]` passed in both browsers |
| 4 | Scratch A (#15): local browser check green, apply job skipped |
| 5 | Scratch A and B (#16) local browser checks overlapped (A 18:18:22 to 18:26:09, B 18:18:24 to 18:25:58 UTC); each proved the other's table does not exist (404, PGRST205) |
| 6 | `[prdb 6]` config line. Scratch A's table with no grants refused by the local API (42501). All pgTAP tests unchanged and green on #14 |
| 7 | `[prdb 7]` loader order, place and wording; no other job and no `config.toml` seed path loads the folder. Scratch A loaded its seed row and read it; the broken seed commit turned the check red at the seed step |
| 8 | `[prdb 8]` name, `needs`, one-line `if`, `--grep-invert @seed`, only job with the test project settings, upload guard. Proven at merge by the manager |
| 9 | Existing `[smoke 11]` and `[data 18]` apply job tests, unchanged and green |
| 10 | `[prdb 10]` checkout depth, diff command, both test commands, upload and comment either way, `@preview` tag on every lock test block. Unit tests in `preview-plan.test.ts`. Scratch A showed the database branch; #14 showed the other |
| 11 | See "Replaced tests" below |
| 12 | Docs listed above |
| 13 | Minutes below. Manager's extra statement: three `[prdb 13]` tests (path filter on push only, nothing on pull requests or manual runs, the notes secret scan) |
| 15 | Run 39652135818 on #14: every check green |

Every protection was broken on purpose and its test went red (`evidence/local-break-prdb-tests.txt`).

### Replaced tests (statement 11)

- `[smoke 11] the browser tests wait for the test project to be updated` is now `[smoke 11] [prdb 11] the browser tests against the test project wait for the test project to be updated`, on the after-merge check. Same substance.
- `[data 18] on a pull request the browser tests run once the database tests pass, without the apply job` is removed. Its premise ended: pull request browser tests no longer use the test project and no longer wait for anything. Replaced by the `[prdb 1]` and `[prdb 8]` tests.
- `[data 18] the app, the Worker and the browser tests use only tables already on the test project` is removed. Pull request browser tests now run on a database with the pull request's own tables, which was the point of this job. Replaced by the `[prdb 1]`, `[prdb 2]` and `[prdb 10]` tests.
- `[smoke 11] every action not made by GitHub is pinned` now also covers the new `secret-scan-notes.yml` (a stronger test). Its count of 3 actions in `checks.yml` is unchanged, because the local browser check takes the Supabase CLI from `npm ci` (the version pinned in `package-lock.json`, 2.121.0) instead of adding a fourth `setup-cli` line.

## Check results

Local, in the worktree (Windows, no Docker):

- `npm run check:code`: type check, lint and format all pass.
- `npx vitest run`: 464 of 464 pass.
- lefthook on every commit: Prettier, ESLint, `tsc -b` and gitleaks pass.
- Database and browser tests need Docker, which this computer does not have, so they ran only on GitHub.

GitHub, pull request #14:

- Run 39649078718 (head `f2550ae`): all green.
- Run 39651275761 (head `9d4a9fc`): unit tests red. Debug triage: a real bug. My docs wrote `NNN_name.sql` inside backticks in `docs/conventions.md`, and the existing `[tooling 6]` test requires every backticked path there to exist (log: `expected [ 'NNN_name.sql' ] to deeply equal []`). Fixed by writing the rule in plain words (`7958daa`); the test is unchanged.
- Run 39652135818 (head `7958daa`): every check green, apply job and after-merge check skipped (`evidence/ci-1-2-3-10-15-pr14-checks.txt`).

Scratch pull requests (closed, branches deleted, never merged):

- #15 scratch A, round 1 run 39651502908: local browser check green; database check red on the existing pgTAP rule "every rule on a new table names the authenticated role" (scratch A's table has an anon read rule), so the scratch branch added itself to that test's exceptions. Round 2 run 39652877872 gave the CLI's database types (`database-types` download). Round 3 run 39653294892 (head `650d067`): every check green, preview ran only the six `@preview` tests and posted the database note (`evidence/ci-10-scratch-a-preview.txt`). Broken seed run 39654984608 (head `ce365af`): red at "Load the browser test seed files"; the file after the broken one was never loaded (`evidence/break-7-broken-seed-red.txt`).
- #16 scratch B, run 39651508732: local browser check green (`evidence/ci-4-5-6-7-scratch-b-local-browser.txt`). Scratch A's matching proof: `evidence/ci-4-5-6-7-scratch-a-local-browser.txt`.

## Minutes (statement 13)

Local Supabase start: 1 minute 38 seconds to 1 minute 40 seconds (start plus applying all five migrations).

Billed minutes for one full pull request run (run 39652135818, each job rounded up to the minute, as in job 3's notes):

| Job | Minutes |
| --- | --- |
| Browser tests (Playwright, local Supabase) | 7 |
| Preview | 7 |
| Database tests | 2 |
| Type check, lint, format | 1 |
| Unit tests | 1 |
| Python tests and lint | 1 |
| Secret scan | 1 |
| Dependency check | 1 |
| Apply job, after-merge browser check | 0 (skipped on pull requests) |
| **Total** | **21** |

**This passes 20 billed minutes.** A pull request run now costs about 21 minutes, up from about 14. The local browser check takes 7 minutes instead of 3 (the Supabase start adds about 1.7 minutes, installing the browsers about 1 minute, and the tests about 3.7). The preview took 7 instead of 4 in this run and 6 in round 1, because the test project is slow; on a database pull request the preview runs only the six lock tests and took 2 minutes. In exchange, every manager push that changes only factory or recording files now costs about 1 minute instead of about 14, which in parallel mode should save more than the 7 extra per pull request. The extra cost stays inside the GitHub Free allowance only while monthly use stays under 2,000 minutes; this month's use was not checked. Caching the Playwright browsers could save about 1 minute per run; that is a possible follow-up, not built.

## Unfinished or uncertain

- **Statement 8 and the path filter can only be proven after merge**, by the manager: on the merge push, the after-merge check should run after the apply job, and a later push that changes only `factory/` should start only "Secret scan of notes".
- **Statement 14 (option B)** is not built; it waits for owner's call 1.
- **The spec says "the other nine names"** for `supabase start -x`; CLI 2.121.0 accepts thirteen names, so ten are excluded (realtime, storage-api, imgproxy, mailpit, postgres-meta, studio, edge-runtime, logflare, vector, supavisor). The spec's intent (only Postgres, kong, postgrest and gotrue run) is what was built; the run log's "Stopped services" line confirms it.
- **Round 1 printed the local publishable key once** in the log of run 39649078718 (the start table row "Publishable" has no word "key"). It is the Supabase CLI's built-in local key, which works only on that runner and was thrown away with it. The filter was fixed and now proven: later runs show 0 matching lines. That old log still holds the line; deleting a run log is the owner's call.
- **Could-not-verify items from the spec, now settled:** `supabase status -o env` gives `API_URL` and `PUBLISHABLE_KEY`; local kong accepts the publishable key for `/rest/v1` and `/graphql/v1`; gotrue starts with mailpit excluded; the Worker inside `vite preview` reaches `http://127.0.0.1:54321`.
- Local and hosted Supabase versions can still differ (spec risk); the after-merge check catches that.

## How to run it locally

Without Docker, run the workflow tests: `npx vitest run tests/checks-workflow.test.ts scripts/ci`. The local browser check itself runs on GitHub on every pull request (the `playwright-report` download holds its videos and screenshots). With Docker (option B, not built) the same steps would be `npx supabase start -x <list>`, then `npx supabase status -o env | node scripts/ci/write-test-settings.ts env <file> --from-supabase-status`, then build and `npx playwright test`; writing to `.env.local` would overwrite your own settings, which is why statement 14 asks for a separate script.

Result: checks pass
