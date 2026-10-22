# Security review: 6-pr-local-db

Reviewed branch `factory/6-pr-local-db` at `7958daa` (pull request 14), diff `main...HEAD`, 15 files. Read only. I also read the run logs of run 39649078718 (round 1) and run 39652135818 (latest), checking key shaped values by count only, never printing them.

## Findings

No must fix and no should fix findings.

### Note 1: the local Supabase listens on every network address of the runner

- **Where:** `.github/workflows/checks.yml` lines 238 to 239 (the browser job comment "the database is never opened to the internet"), and the spec's Risks line "The local database binds to the runner's own address".
- **Risk:** the Supabase CLI itself prints "All services bind to 0.0.0.0 (network-accessible, not just localhost)" in the latest run log, so what keeps the database (password `postgres`) private is GitHub's hosted runner network, which accepts no connections from outside, not the binding. This is true today and the database check has worked the same way since job 3, so nothing is exposed.
- **Fix:** no code change needed. Next time this comment is edited, name the real protection (GitHub hosted runners accept no inbound connections). If self hosted runners are ever used (out of scope today), revisit this.

### Note 2: a failed apply is no longer retried by a notes push

- **Where:** `.github/workflows/checks.yml` lines 21 to 32 (`paths-ignore`).
- **Risk:** before this job, any later push to main re-ran "Apply database changes to the test project". Now, if a merge's apply fails (for example the test project was asleep), notes pushes no longer retry it, so the test project stays one migration behind until the next code merge or a manual "Re-run failed jobs". This is a delay, not a leak: the apply still only ever runs on main, and `supabase db push` applies every pending migration on its next run.
- **Fix:** none required. The manager should re-run a failed apply by hand rather than wait for the next push.

### Note 3: the 300 file limit on path filters

- **Where:** `.github/workflows/checks.yml` lines 30 to 32 and `.github/workflows/secret-scan-notes.yml` lines 14 to 16.
- **Risk:** GitHub only reads the first 300 changed files when it applies a path filter, so a very large push to main led by factory files could skip `checks.yml`, including the apply job. The builder disclosed this. The largest merge so far changed 109 files (`06f62ac`), so it is far off.
- **Fix:** none now. If a merge ever approaches 300 files, start the checks with a manual run or split the push.

## Answers to the manager's focus questions

- **The new local browser check holds no secret.** The `browser` job (lines 229 to 317) has no `secrets.` reference, and `[prdb 2]` in `tests/checks-workflow.test.ts` line 394 pins that. Its two Worker settings come from `supabase status -o env`, and `scripts/ci/supabase-status.ts` keeps only `API_URL` and `PUBLISHABLE_KEY`, drops the secret key, service role key and JWT secret, and refuses any address that is not `http` on `127.0.0.1` or `localhost` (tested with lookalike hosts). Error messages print names only. `scripts/ci/write-test-settings.ts` writes the file with mode 600 and prints names only; the latest log shows exactly "Wrote SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY to .env.local". `.env.local` is not in the uploaded paths.
- **The after merge check is the only browser job with test project settings.** `browser-test-project` (lines 319 to 377) is the only browser job referencing `SUPABASE_TEST_URL` and `SUPABASE_TEST_PUBLISHABLE_KEY`, runs only on a push to main after the apply job succeeded (which itself excludes Dependabot), passes them per step only after `npm ci`, and keeps the upload guard. The preview job still gets them, as before, for the Worker upload.
- **Pull requests from forks or Dependabot.** No job uses `pull_request_target` or `workflow_run`. The new browser job runs on Dependabot and fork pull requests with a read only token and no secrets, which is safer than before (pull request browser tests used to receive the test project settings). The apply job's `if` line and password lines are unchanged. Preview still skips Dependabot.
- **Pinned actions.** No new third party action. `secret-scan-notes.yml` reuses the same gitleaks commit pin as `checks.yml`, with `contents: read`, `persist-credentials: false` and comments off. The browser job takes the Supabase CLI from `npm ci` (version pinned in `package-lock.json`, unchanged by this job) instead of a new action.
- **The path filter.** GitHub skips a `paths-ignore` workflow only when every changed file matches, so a push that changes anything outside `factory/` or `recording/` runs every check, including the apply job. A notes only push holds no migration, so skipping the apply is correct. Pull requests and manual runs have no path filter (`[prdb 13]` tests). Every main push still gets a secret scan: either from `checks.yml` or from `secret-scan-notes.yml`. Only edges are Notes 2 and 3.
- **`supabase/config.toml` line 26.** `auto_expose_new_tables = false` is under `[api]`, affects only local stacks (no job runs `supabase config push`), and makes the local database refuse new tables without grants, as the hosted project does. Scratch A proved the refusal (42501).
- **Seed files.** Only the browser job loads `supabase/seeds/browser/*.sql`, into `127.0.0.1`. `config.toml` seed paths are still only `./seed.sql`, and `supabase db push` in the apply job does not load seeds unless asked. The folder holds only a README today.
- **Preview job.** The migration check is a quoted three dot `git diff` piped into `scripts/ci/preview-plan.ts`; no pull request text reaches a shell unquoted. The comment body is built from the event's commit id, a preview address matched by a strict pattern, and the run link. A wrong answer from the diff would only change which tests run on the preview, not who can reach anything.
- **Round 1's printed key is not a real secret.** The one key shaped line in run 39649078718 is identical to the fixed default publishable key that every Supabase CLI local stack uses, which Supabase publishes. It only opens the local API of a runner that was destroyed when the job ended, and grants nothing on the test project or any hosted project. No secret key, service role key or JWT appears in that log. The latest run's log has no publishable or secret key at all (the only `eyJ` match is the filter command itself). Deleting the old log is optional tidiness, not a security need.

## Worth a close look by the owner even though it passes

- After the merge, the manager should confirm on the merge run that "Browser tests against the test project (after merge)" ran after the apply job, and that a later notes only push started only "Secret scan of notes" (statement 8 can only be proven then).
- If you ever move these checks to your own machines (self hosted runners), Note 1 becomes a real exposure and must be fixed first.

Result: pass
