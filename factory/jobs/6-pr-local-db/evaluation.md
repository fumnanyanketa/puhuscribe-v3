# Evaluation: 6-pr-local-db (round 1)

Evaluator, 21 October 2026. Pull request #14, head `7958daa`, branch `factory/6-pr-local-db`.

This job changes the GitHub checks and has no screen, so nothing was clicked through at phone size. Each statement was tested as a CI change, from four sources:

- the workflow file and tests at `7958daa`
- the GitHub runs of #14 and of scratch pull requests #15 (A) and #16 (B), read with `gh run view`, `gh api` and the job logs
- the job's tests, run locally in the worktree
- 11 protections broken on purpose in a scratch copy

Docker is not installed on this computer, so a local Supabase cannot start here. The database and browser checks were judged from the GitHub runs only. The shared test project was not touched: no `.env*` file was read, nothing was pushed, and the worktree was not edited. Owner's call 1 is still open (default A), so statement 14 does not apply yet.

`build.md` was read only after testing. Its claims match what I found.

## Results

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `eval-1-2-3-pr14-local-browser-check.txt`, `eval-break-protections.txt` (B4) | On #14 the check "Browser tests (Playwright, local Supabase)" started at 18:23:26, the same second as the database check, and has no `needs`. The CLI pulled only postgres, kong, postgrest and gotrue as services. `supabase status` lists the other ten as stopped. All 5 migrations were applied from empty, and 126 tests passed in Chromium and WebKit. The `if` line is `github.event_name != 'push'`, so manual runs and Dependabot pull requests are included. No manual run of the new workflow exists yet. |
| 2 | pass | `eval-1-2-3-pr14-local-browser-check.txt`, `eval-2-key-scan-of-run-logs.txt`, `eval-break-protections.txt` (B1, B2, B3) | The job has no `secrets.` reference. The log says "Wrote SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY to .env.local" (names only). The build passed the built-secrets check. The `playwright-report` download is 43.5 MB. The current runs have 0 key-shaped lines in their logs. Round 1's log still holds one (see "Odd but not a failure"). |
| 3 | pass | `eval-1-2-3-pr14-local-browser-check.txt`, `eval-break-protections.txt` (B5) | The log shows "Rows in visits on the throwaway database: 30" after the tests. The `[13]` test (`database: reachable`) passed in both browsers. |
| 4 | pass | `eval-4-5-6-7-scratch-runs.txt` | Scratch A's migration has written grants and RLS. Its local browser check was green in run 39651502908, and its `@seed` test read the new table through the local API (200, seeded row). The apply job was skipped in every scratch run, and main still has only its 5 migrations. |
| 5 | pass | `eval-4-5-6-7-scratch-runs.txt` | A's local browser check ran 18:18:22 to 18:26:09 and B's ran 18:18:24 to 18:25:58, both green. Each run's test proves the other run's table is absent (404, `PGRST205`). `build.md` records the overlap. |
| 6 | pass | `eval-4-5-6-7-scratch-runs.txt`, `eval-9-apply-job-unchanged.txt`, `eval-break-protections.txt` (B6) | `config.toml` has `auto_expose_new_tables = false` under `[api]`. Scratch A's ungranted table was refused with `42501` in both browsers. #14 does not change `supabase/tests`, and pgTAP passed 413 of 413, twice. |
| 7 | pass | `eval-7-broken-seed-red.txt`, `eval-1-2-3-pr14-local-browser-check.txt`, `eval-break-protections.txt` (B7) | #14 logs "No browser seed files". Scratch A loaded `010` in name order. Broken seed run 39654984608 failed at step 7, "Load the browser test seed files", after loading `020` and before `030`, and every later step was skipped. `sql_paths` is still `["./seed.sql"]`, and no other job mentions `seeds/`. |
| 8 | after merge | `eval-break-protections.txt` (B8) | The static parts hold: the name, `needs: [database, apply-test-db]`, the `if` line for a push to main where apply succeeded, `--grep-invert @seed`, the upload guard, and the only `SUPABASE_TEST_*` secrets among the browser test jobs. On #14 both it and the apply job show "skipped". What to look for at merge is listed below. |
| 9 | pass | `eval-9-apply-job-unchanged.txt`, `eval-break-protections.txt` (B11) | The apply job block is byte-identical to `8081642`: same sha256, 37 lines. The `[data 18]` test "no other job can change a remote database" is unchanged, and it goes red when another job runs `db push`. |
| 10 | pass | `eval-10-preview-branches.txt`, `eval-break-protections.txt` (B9, B10) | On #14 the log says "Database changed: false", the suite ran without `@seed` (132 passed), and the comment is unchanged. On scratch A it says "Database changed: true", only the 6 `@preview` tests ran, the preview was still uploaded, and the comment carries the spec's note with the run link. |
| 11 | pass | `eval-local-tests.txt` | The three replaced tests are listed in `build.md` with reasons. `[smoke 11]` moved to `browser-test-project` with the same substance. The "3 third-party actions" count is unchanged. The only other edit to an existing test adds `secret-scan-notes.yml` to the pinning check, which makes that test stronger. |
| 12 | pass | (diff of `README.md`, `docs/conventions.md`, `docs/data-model.md` at `7958daa`) | Both README sections, the checks table row and the convention lines are present, and so is the data-model paragraph. I found no banned writing in the new text. |
| 13 | pass | `eval-13-billed-minutes.txt` | No paid service was added. The local Supabase start took 1 min 38 s. #14's full run took 21 billed minutes (browser 7, preview 7, database 2, five other jobs 1 each), and `build.md` says plainly that this passes 20. |
| 14 | n/a | | This applies only if owner's call 1 is B. The call is not answered, so the default is A. |
| 15 | pass | `eval-15-pr14-checks.txt` | On #14 at `7958daa`, 8 checks succeeded, and apply plus after-merge were skipped as designed. The pull request is mergeable. |

Locally at `7958daa`, `npx vitest run tests/checks-workflow.test.ts scripts/ci` passed 79 of 79, and `npm test` passed 464 of 464 (`eval-local-tests.txt`).

## Protections broken on purpose

`eval-break-protections.txt`. I made an unchanged copy of `7958daa` in my scratch folder, broke one protection at a time and ran the job's tests. Each break turned at least one test red, and restoring the file turned them green again. Nothing was pushed.

- B1 (statement 2): a test project secret added to the pull request browser job. Two tests went red: `[prdb 2]` holds no secret, and `[prdb 8]` only job.
- B2 (statement 2): round 1's log filter, which leaked the key, put back. `[prdb 2]` start output filter went red.
- B3 (statement 2): `supabase-status.ts` made to accept any address. `[prdb 2]` refuses non-local address went red.
- B4 (statement 1): `needs: [database]` added to the local browser check. `[prdb 1]` waits for no job went red.
- B5 (statement 3): the visits step allowed to pass with zero rows. `[prdb 3]` went red.
- B6 (statement 6): `auto_expose_new_tables = true`. `[prdb 6]` went red.
- B7 (statement 7): the browser seed folder added to `config.toml` seed paths. `[prdb 7]` went red.
- B8 (statement 8): the after-merge suite run without `--grep-invert @seed`. `[prdb 8]` went red.
- B9 (statement 10): migration detection pointed at the wrong folder. Two `[prdb 10]` unit tests went red.
- B10 (statement 10): the `@preview` tag removed from the lock tests. `[prdb 10]` went red.
- B11 (statement 9): `supabase db push --db-url` added to the after-merge job. `[data 18]` went red.

## Failures

None.

## After merge: what the manager should look for

Statement 8 and the path filter:

1. On the merge push to main, "Apply database changes to the test project" succeeds.
2. "Browser tests against the test project (after merge)" then starts. It runs `npx playwright test --grep-invert @seed`, passes, and uploads `playwright-report-test-project` only after the guard step passes.
3. On that same run, "Browser tests (Playwright, local Supabase)" shows skipped.
4. The next push to main that changes only `factory/` or `recording/` files starts only the workflow "Secret scan of notes". "Checks" does not start, and gitleaks is green.

## Odd but not a failure

- **A local key is still in one old run log.** Run 39649078718 (round 1, head `f2550ae`) has one log line with the local stack's publishable key (`eval-2-key-scan-of-run-logs.txt`, value redacted). It only worked on a runner that no longer exists, and every later run shows 0 such lines. AGENTS.md says no keys in logs, so I recommend deleting that run's log: `gh api -X DELETE repos/fumnanyanketa/puhuscribe-v3/actions/runs/39649078718/logs`. That is the owner's or manager's call.
- **The image registry rate-limited #14's run.** The local browser check logged "toomanyrequests: Rate exceeded" from `public.ecr.aws`, and the CLI's retry got through. The database check and the local browser check both pull the Postgres image anonymously at the same moment, and parallel jobs multiply that. Expect an occasional red start step that a re-run fixes.
- **Excluded services still cost start time.** While setting up the schema, the CLI pulls the realtime and storage-api images, about 53 of the 98 seconds the start took, even though both services are excluded. Neither service runs afterwards.
- **The local stack listens on every network address of the runner.** The CLI prints "All services bind to 0.0.0.0". GitHub-hosted runners accept no inbound connections from the internet, and the `[prdb 1]` test forbids tunnel tools, so this matches the spec's intent.
- **One test name is out of date.** The `[13]` test is still called "/api/health reports the Supabase test project as reachable". On a pull request it now proves the throwaway database is reachable.
- **The pull request comment has no final full stop.** The database note ends with the bare run link, while the spec text ends with "<run link>.". Leaving the stop off keeps the link clean.
- **The spec counts one service too few.** It says "the other nine names", but CLI 2.121.0 accepts thirteen, so ten are excluded. The spec's intent holds: only Postgres, kong, postgrest and gotrue run.
- **Edge cases in the path filter (the manager's extra).** Suppose an apply run on main fails and the next push changes only factory files. That push will not retry the apply, so a manual rerun is needed. The builder's 300-file edge is also real. Neither affects pull requests.
- **The migration check can only err towards the warning.** The preview's diff uses `github.event.pull_request.base.sha`. If that is older than the base the merge commit was built on, main's newer migrations could count as "changed". The preview would then run only the lock tests and show the database note. That direction is the safe one.
- **Some parts have no real run yet.** No manual run of the new workflow exists. The `if` line and its test cover manual runs. Dependabot pull request #13 still runs main's old workflow until it is rebased after the merge.
- **The test project's table list was not read.** That needs the test database password. The proof that the scratch tables never reached it is indirect: the apply job was skipped on every scratch run, and main holds only its 5 migrations.

## Must-fix items

None that block this job. Recommended before or at merge: delete the log of run 39649078718 (see above).

Result: pass
