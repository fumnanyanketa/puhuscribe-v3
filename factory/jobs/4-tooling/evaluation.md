# Job 4-tooling: evaluation, re-check of build round 3

Evaluator, 20 October 2026. Branch `factory/4-tooling`, tip `a2765ee`, pull request #11, run 39449697080 (attempt 2 green).

How I tested. I made a new fresh clone in my scratchpad (`gh repo clone`, its own `.git`, no `core.hooksPath`), checked out `a2765ee` and ran `npm ci` there. Every hook test ran in that clone. The real shared hooks of the main checkout were never touched, and lefthook was never installed or uninstalled in the main checkout or in `.worktrees/4-tooling`. Bad commits were tried only on a throwaway local branch, deleted, never pushed. Made-up keys were generated at run time and never printed; each evidence file counts how often the value appears in the output (always 0). No `.env*` content was read or printed. The clone was deleted at the end. Round 3 changed only `lefthook.yml` (the secrets job), `scripts/hooks/commit-tool.ts`, `scripts/hooks/stop-checks.ts`, their tests and `tests/agents-md.test.ts`, so statements untouched by those files keep their round 1 evidence, and the basics were run again.

Evidence files from this re-check start with `r3-` and carry `eval` in their names. Round 1 evaluator files carry `eval` without `r3-`.

## Statements

| # | Result | Evidence | What I saw |
| --- | --- | --- | --- |
| 1 | pass | `18-eval-ci-pr11-checks.txt` | Round 3 removes no test, step or rule. No new action. Round 1 finding holds. |
| 2 | pass | `break-6-eval-agents-md-test.txt` | AGENTS.md and the PRD lists unchanged since round 1 (the round 3 diff does not touch AGENTS.md). |
| 3 | pass | `break-6-eval-agents-md-test.txt` | Unchanged since round 1. |
| 4 | pass | `break-6-eval-agents-md-test.txt` | Unchanged since round 1: 13 line Conventions section, 1,712 words, 17 lessons identical. |
| 5 | pass | `break-6-eval-agents-md-test.txt` | Unchanged since round 1. |
| 6 | pass | `r3-break-6-eval-root-files.txt` | The path test now goes red for `lefthook.yml` renamed in AGENTS.md text, `git mv ruff.toml ruff-gone.toml`, `.prettierignore` renamed in conventions.md text, `git mv eslint.config.js eslint.gone.js`, and a job file name no job has. 23 ordinary words and code identifiers (`request.jwt.claims`, `auth.uid()`, `process.env`, `2.2.2`, `.ts`, `*.test.ts`, `node:fs` and more) added to either file kept it green. |
| 7 | pass | `r3-7-8-14-18-eval-local-basics.txt`, `break-7-eval-check-code-order.txt` | `npm run check:code` exit 0 at `a2765ee`. Order and exit codes proven in round 1; the script is unchanged. |
| 8 | pass | `r3-7-8-14-18-eval-local-basics.txt`, `8-eval-local-npm-ci-hook-and-ci-true.txt` | `npm ci` installed the pre-commit hook, `npx lefthook version` 2.2.2, no tracked file changed. `CI=true` proof from round 1 stands (install step unchanged). |
| 9 | pass | `9-eval-local-ignored-files-untouched.txt`, `r3-13-eval-local-missing-tools-and-secret-advice.txt` | The only round 3 change to the checks is gitleaks' `--exit-code 3`; a clean commit (control case E) still runs all checks and commits. |
| 10 | pass | `10-eval-*.txt`, `r3-13-eval-local-missing-tools-and-secret-advice.txt` | A made-up key in `worker/` and in `factory/` is still refused, now with "gitleaks found a secret in the staged changes, so this commit is refused..." printed once, value 0 times in output. Lint, type, Python and format proofs from round 1 stand (those jobs are unchanged). |
| 11 | pass | `11-eval-local-commit-timings.txt` | Round 1: 11.3 to 11.6 s for one TypeScript file, 2.1 to 2.3 s for factory or recording only. Round 3 control commit: 10.4 s. |
| 12 | pass | `12-eval-local-worktree-and-main-commits.txt` | Unchanged since round 1. |
| 13 | pass | `r3-13-eval-local-missing-tools-and-secret-advice.txt`, `r3-break-13-15-eval-redact-and-advice-pins.txt` | Missing gitleaks (app commit and factory only commit): refused with only the install line, 0 lines about a found secret. Missing ruff: refused with the install line. Missing lefthook: refused. Tests go red when the advice is printed for any gitleaks failure, or when `--exit-code 3` or `--redact` is removed from `lefthook.yml`. |
| 14 | pass | `r3-7-8-14-18-eval-local-basics.txt`, `14-eval-local-gitleaks-full-history.txt`, `r3-18-eval-ci-pr11-checks.txt` | `check:code` exit 0; full history scan clean in round 1; CI Python job green. |
| 15 | pass | `r3-15-eval-local-stop-check.txt`, `r3-break-13-15-eval-redact-and-advice-pins.txt` | No changed app files: exit 0 in 0.65 s. A key in an app file: exit 2 naming file, line and rule; key in `.env.local` never named; value 0 times. Typical change (8 files): 11.3 to 11.5 s. `build.md` now records 11.0 to 11.1 s. Removing `--redact` from `gitleaksArgs` turns `[tooling 15]` red. Round 1 scenarios (line cap, blocked exit, non app folders) stand. |
| 16 | pass | `16-eval-local-settings-json.txt` | `.claude/` unchanged in round 3; still equals the option B JSON. |
| 17 | pass on the pull request; main part at merge | `17-eval-ci-branch-runs.txt` | Workflow unchanged in round 3. The pull request proofs from round 1 stand. The main branch proof waits for the merge. |
| 18 | pass | `r3-18-eval-ci-pr11-checks.txt`, `r3-7-8-14-18-eval-local-basics.txt` | Run 39449697080 at `a2765ee`, attempt 2: every job green. Locally 305 of 305 tests pass; `npm audit --audit-level=high` finds 0. |
| 19 | pass | `build.md` | €0; README costs table unchanged; `build.md` reports about 18 more check minutes for round 3. |

## Failures

None.

## Round 1 findings (build round 2, tip `c1666b1`)

- Statement 6 failed: the path check skipped root files without a slash, so a wrong `lefthook.yml` or a renamed `ruff.toml` left `tests/agents-md.test.ts` green. Fixed in round 3 and re-checked above.
- Statement 13 failed: with gitleaks missing, lefthook's `fail_text` also said "gitleaks found a secret in the staged changes. Remove it, tell the owner", a false alarm. Fixed in round 3 (gitleaks `--exit-code 3`, advice only on a real finding, no `fail_text`) and re-checked above.
- Gap: `build.md` did not state the stop check's typical change timing. Now in `build.md`.
- Gap: the stop check's `--redact` was not pinned by a test. Now pinned.

## Gaps

- The main branch part of statement 17 can only be proven at merge: the merge push and the close-out push must both finish, and the apply job must queue (`gh run list --branch main`).
- I could not run Claude Code itself to see the `SubagentStop` hook fire for the `factory-builder` agent only. I checked the settings JSON and ran the script directly.
- `build.md` says the gitleaks tests of the stop check and commit tool are skipped on GitHub (no gitleaks there). They pass locally, as above.

## Odd but not failures

- Run 39449697080 attempt 1 failed only the preview job: `e2e/health.spec.ts` "[2] [10] the page loads with no console errors and reaches the Worker" (11.9 s) in Chromium. Same slow test project save seen in rounds 1 and 2; round 3 changes no app or Worker code. Attempt 2 was green. The preview flake has now hit three rounds in a row and is worth its own open item.
- With ruff missing, the install line prints twice (one per ruff job).
- lefthook's own "can't find lefthook" text still suggests `--no-verify` or `LEFTHOOK=0`, which AGENTS.md forbids, and does not say to run `npm ci`. The builder flagged this; lefthook's text cannot be changed in config.
- The commit check's secret refusal says only "leaks found: 1" plus the advice; it does not name the file or rule. The stop check does.
- Round 1 notes still apply: a refused commit leaves Prettier's fixes staged; until merge, commits on main find no `lefthook.yml` and run no checks; a deep path can make `git worktree remove` fail with "Filename too long", so the manager should check `.worktrees/4-tooling` is really gone after removing it.

Result: pass
