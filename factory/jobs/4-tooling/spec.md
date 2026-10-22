# Job 4-tooling: Coding standards & tooling

Scope item 2. Date: 20 October 2026. Builds on jobs 1-stack, 2-smoke and 3-data-model as merged on main (`676b7e7`). Test label for this job: `[tooling N]`.

## What it is

This job writes down how the code in this project is organised and checked, in the house rules file every AI session reads. It also makes the checks run on your computer while agents work, not only on GitHub: before an agent can save a change into the project history (a commit), a quick check looks for formatting mistakes, code errors and leaked passwords, and refuses the change if it finds one. Finally, it fixes a problem found at job 3's merge, where a newer GitHub check run on the main version cancelled an older one that was copying database changes to the test database.

## What already exists (do not rebuild)

Job 1 set up most of the tooling, and every item below already runs on every pull request in `.github/workflows/checks.yml`. This job keeps all of it as it is.

| What | Where it is configured | Where it is enforced today |
|---|---|---|
| TypeScript strict type check (`tsc -b` over the app, node and Worker configs) | `tsconfig*.json` | CI job "Type check, lint, format" |
| ESLint, typescript-eslint strict and stylistic type checked rules, react-hooks, jsx-a11y | `eslint.config.js` | same CI job (`npm run lint`) |
| Prettier (no semicolons, single quotes, width 110, trailing commas) | `.prettierrc.json`, `.prettierignore` | same CI job (`npm run format:check`) |
| Unit tests, including the v2 hash check, the workflow shape tests and the repo hygiene tests | `vitest.config.ts`, `tests/` | CI job "Unit tests (Vitest)" |
| Python lint and format (ruff), Voikko tests (pytest, network off, exactly 9 tests) | `ruff.toml`, `pytest.ini` | CI job "Python tests and lint" |
| Database security tests (pgTAP), second load run, generated types match | `supabase/` | CI job "Database tests (local Supabase, pgTAP)" |
| Browser tests (Playwright, Chromium and WebKit, 375 x 812) | `playwright.config.ts`, `e2e/` | CI jobs "Browser tests" and "Preview link" |
| Secret scan (gitleaks, pull request commits; full history on a manual run) | `gitleaks/gitleaks-action` pinned to a commit | CI job "Secret scan (gitleaks)" |
| Dependency check (`npm audit --audit-level=high`, `pip-audit`), Dependabot monthly | `checks.yml`, `.github/dependabot.yml` | CI job "Dependency check" |
| No secret-looking `VITE_` names; no secret in built browser files | `scripts/security/` | inside `npm run build` (CI browser and preview jobs) |
| No secret value in uploaded test files | `scripts/ci/check-files-for-secrets.ts` | CI browser and preview jobs |
| LF line endings for app files; secrets and outputs git ignored | `.gitattributes`, `.gitignore` | `tests/repo-hygiene.test.ts` |
| Progress log after every Claude turn (owner approved in job 2) | `.claude/settings.json` Stop hook, `recording/log-turn.mjs` | Claude Code, main sessions |

What is missing: no check runs on your computer before a commit (`.git/hooks` holds only git's samples); no check runs when an agent stops; `AGENTS.md` has no conventions section and says it will be "expanded once the app is scaffolded"; and main-branch check runs can cancel each other.

## Done when

Each statement is checked by a command, a test, or a GitHub run. New tests carry `[tooling N]`.

1. **Nothing already built is rebuilt or weakened.** Every check in the table above still runs with the same commands. `git diff main...factory/4-tooling` deletes no test, removes no workflow step, and loosens no lint, type or format rule. No new third-party GitHub Action is added (the "3 third-party actions" test in `tests/checks-workflow.test.ts` still passes unchanged).
2. **AGENTS.md describes the real project.** It states the real stack in a few lines that match the README stack table (React 19, Vite, TypeScript strict single page app; one Cloudflare Worker serving the app and `/api/*`; Supabase in the EU; Node 24 and npm; Vitest; Playwright; Python 3.12 content pipeline). It keeps the five principles. It replaces its short "Not in v3.0" summary with the PRD section 4.1 "Not in v3.0" list word for word (all 12 items), as PRD section 17 asks for the agent rules file, and keeps "no streaks" from the scope. The out of date sentence "Scope item 2 ... expands it once the app is scaffolded" is gone.
3. **AGENTS.md carries the project rules.** A short "Project rules" part says:
   - **GA features** (`"ga": true` in `factory/features.json`): the spec answers the three threat model questions (What is the worst thing a malicious person could do here? What data are we storing that we must protect? What should the system refuse to do even if asked nicely?), and the job is done only when `summary.md` records your own written "approved" line with the date.
   - **Evidence folder:** proof lives in `factory/jobs/<job-id>/evidence/`, is never deleted, and never holds a secret.
   - **Debug triage:** before fixing anything broken, say which of three kinds it is: a real bug (reproduce it, prove the cause from evidence, smallest fix, a test that fails without the fix); a confused session (stop and start a fresh one); a wrong earlier decision (stop and send it back to the spec, do not patch around it).
   - **Output style:** plain short sentences, explain a technical term the first time, report in a few lines; no em dashes or hyphens used as punctuation (added to the existing writing rules).
   - **Never skip the checks:** no `git commit --no-verify`, no `LEFTHOOK=0`, no editing a check to make it pass. If a check is wrong, say so in the job notes.
4. **AGENTS.md stays short.** The new "Conventions" section is at most 25 lines and links `docs/conventions.md` for detail. The whole file stays under 2,200 words (a test counts them). The "Lessons learned" section keeps all 17 current lines, unchanged.
5. **`docs/conventions.md` records the conventions the code actually follows,** each with one real example file from the repository:
   - folder layout (`src/`, `src/lib/`, `worker/`, `e2e/`, `tests/`, `scripts/security|ci|v2-import` run directly by Node 24, `scripts/generate/` Python from v2, `supabase/migrations/`, `supabase/tests/database/`, `content/`, `data/`, `docs/`, `factory/`, `recording/`, `spikes/`);
   - naming (kebab-case TypeScript files, PascalCase React components, `*.test.ts` next to the code, `e2e/*.spec.ts`, migrations `<UTC timestamp>_<snake_case>.sql` made with `npx supabase migration new`, pgTAP files `<area>_<topic>.test.sql`, reference loads `*_load_v2_*.sql`);
   - test labels: each test name carries `[<job label> N]` for the "Done when" statement it protects, and each test file's header names the spec (job 1 used bare `[N]`, job 2 `[smoke N]`, job 3 `[data N]`, this job `[tooling N]`; each spec names its label);
   - migrations and pgTAP: revoke everything from `anon`, `authenticated` and `service_role`, grant only what the spec allows, row level security on, rules use `to <role>` and `(select auth.uid())`, indexes on filtered columns, helper functions in `private` with an empty `search_path`, every test file in one rolled back transaction with `plan(n)`, acting as a learner through `request.jwt.claims` and `set local role`, reference data loaded by upsert migrations, `src/lib/database.types.ts` only from the Supabase CLI, migrations reach the test project only on merge to main;
   - the provider module rule: voice, speech feedback and AI each sit behind one module in `worker/providers/` (the first job that adds a provider creates the folder), keys only as Worker secrets, the browser calls only `/api/*`, every AI call logged with its cost;
   - secret handling: `.env.local` only, `.env.example` names without values, GitHub secrets, never a secret-looking `VITE_` name, never read, search or print `.env*` files (use `git grep`), the test database password only in the apply job, third-party actions pinned to a full commit;
   - files imported from v2 stay unchanged and hash checked, are left out of Prettier and ruff format, and any lint exception is per file with a comment;
   - the evidence folder naming that jobs 1 to 3 used (`<statement>-<short-name>.<ext>`, `r<round>-` for re-checks, `break-` for deliberate break tests, `ci-` and `local-` for command output);
   - `build.md`: rewritten each round, with an "Earlier rounds" section that keeps each round's tip commit, green and red run links and a one line summary, ending with the `Result:` line;
   - a "Checks and where they run" table: before a commit, when an agent stops (only if owner's call 1 adds it), and on GitHub.
6. **A test keeps both files honest.** `tests/agents-md.test.ts` fails when: a file or folder path written in `AGENTS.md` or `docs/conventions.md` does not exist; an `npm run <script>` they name is not in `package.json`; any of the 12 "Not in v3.0" items or the five principles is missing from `AGENTS.md`; `AGENTS.md` passes 2,200 words; or a current "Lessons learned" line is removed. Proof: renaming one linked path on a scratch commit turns it red (saved to evidence, not pushed).
7. **One command runs the fast code checks.** `npm run check:code` runs the type check, lint and format check in that order and exits non-zero if any fails. The README command table lists it.
8. **The commit check installs itself.** After `npm ci` in the main checkout or in a fresh factory worktree, a pre-commit hook managed by lefthook is installed with no extra step; `npx lefthook version` prints the pinned version. On GitHub (where `CI=true`), `npm ci` installs no hook.
9. **The commit check covers the staged files, in parallel:**
   - Prettier formats staged files it covers and adds the fixes to the commit;
   - ESLint checks staged `.ts`, `.tsx` and `.js` files;
   - `tsc -b` runs when a staged file is `.ts`, `.tsx`, `.json` or `.jsonc`;
   - `ruff check` and `ruff format --check` run on staged `.py` files;
   - gitleaks scans the staged changes, with secrets redacted in its output.
   `.prettierignore` and the ESLint ignores still apply, so factory, docs and v2 files are not touched.
10. **Each check refuses a bad commit.** In a throwaway local branch that is never pushed, five commits are tried: a lint error, a type error, a Python lint error, and a made-up key in the shape gitleaks detects are each refused with the tool's message; an unformatted file is committed formatted. The made-up key's value does not appear in the hook output. The terminal output of each is saved to `evidence/`, then the branch is deleted.
11. **It is fast.** Measured on your Windows computer and written in `build.md`: a commit that changes one TypeScript file finishes its check in under 20 seconds; a commit of only `factory/` or `recording/` files finishes in under 5 seconds. If the type check makes the first target fail, the builder moves the type check out of the commit check, says why in `build.md`, and the type check stays in `npm run check:code` and CI.
12. **It works where the factory commits.** A commit inside `.worktrees/4-tooling` runs that worktree's own `lefthook.yml`. A manager-style commit of only `factory/` files on main passes. While this job is still open (main has no `lefthook.yml` yet), a commit on main still works; the builder proves this, because installing hooks in a worktree writes to the hooks folder that main shares.
13. **A missing tool fails safely and says how to fix it.** If gitleaks is not installed, or a `.py` file is staged and ruff is not installed, the commit is refused with one line naming the free install command. The README "Run it locally" section lists the one time installs (gitleaks through `winget install --id Gitleaks.Gitleaks -e`; ruff through `scripts/requirements-dev.txt`).
14. **The whole repository is clean today.** `npm run check:code` exits 0 on the branch. A local `gitleaks git --redact` over the full history finds no leaks. The CI Python job passes.
15. **Only if owner's call 1 is B or C: the agent-stop check.** `scripts/hooks/stop-checks.ts`, with tests in `scripts/hooks/stop-checks.test.ts`:
    - with no changed app files it exits 0 in under 2 seconds;
    - with a lint, type or format error, or a made-up key, in a changed file it exits 2 and prints at most 40 lines naming the check and the files, never a secret value;
    - files under `factory/`, `recording/`, `docs/` and `.claude/` do not count as app files;
    - it never opens, lists or prints a `.env*` file (a test puts a made-up key in an untracked `.env.local` and checks the output);
    - for a builder, if its job's `build.md` ends with `Result: blocked:`, it lets the builder stop;
    - on your computer, a typical builder change finishes in under 60 seconds (measured, in `build.md`).
16. **Claude Code settings change only as you choose.** For option A, `.claude/settings.json` is unchanged. For option B or C, it holds exactly the JSON shown under owner's call 1, and the progress log hook stays. No other file under `.claude/` changes.
17. **Main-branch runs never cancel each other; pull request runs still do.** In `checks.yml`:
    - the workflow concurrency group is per branch for pull requests and per run for everything else, and `cancel-in-progress` is true only for pull requests;
    - the job "Apply database changes to the test project" gets its own concurrency group (`apply-test-db`) that queues instead of cancelling, so two applies never run at once and none is dropped.
    New `[tooling 17]` tests in `tests/checks-workflow.test.ts` pin both. Proof on the pull request: two quick pushes to the branch cancel the older run; two manual runs of the workflow on the branch both finish. Proof at merge (by the manager): the merge push and the close-out push to main both finish with neither cancelled, shown by `gh run list --branch main`.
18. **All checks are green.** Every GitHub check passes on the pull request. `npm audit --audit-level=high` stays clean with the new package.
19. **No new running costs.** lefthook and gitleaks are free and open source. Everything stays on free plans; the README "Running costs" table stays at €0. `build.md` reports the extra check minutes the proof runs used.

Product rules from `AGENTS.md` that apply: never delete or weaken a test; no placeholders; no keys in code, commits, logs or chat; agents use only the test database; the "Not in v3.0" list is binding (written into `AGENTS.md` here, nothing built).

## Decision

| Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|
| Commit check tool | lefthook 2.2.x (MIT, one npm package with prebuilt Windows binaries; installs its hooks on `npm install` and skips that when `CI=true`; filters staged files by pattern and runs jobs in parallel from one `lefthook.yml`) | husky 9 with lint-staged | Husky is the most widely used option, but needs a second package (lint-staged) for staged-file filtering, and the Python and gitleaks steps would become shell lines with no file filter. One package and one file is less to maintain and review |
| Second runner up | | the `pre-commit` framework (Python) | Needs Python on every machine before any check runs, and its gitleaks hook builds from source or uses Docker; Docker is not on your computer |
| Where conventions live | A short section in `AGENTS.md` plus `docs/conventions.md` for detail | Everything in `AGENTS.md` | Claude Code reads `AGENTS.md` into every session automatically (since v2.1.277), so every line costs every session. The detail file is read when needed |
| Local secret scan | gitleaks 8.30.1 (the current release, 21 March 2026), installed once with winget; same tool and default rules as the CI check | Betterleaks | gitleaks' README now says it is feature complete and will get security patches only; its author moved to Betterleaks, described as a drop-in successor. Switching only the local scan would give two tools with different rules. Moving CI and local together is a later job |
| Formatting at commit | Prettier fixes staged files and adds the fixes | Refuse the commit | Formatting never changes meaning; refusing a commit over spacing costs an agent a round trip |
| Everything else at commit | Check only, no automatic fixes | ESLint `--fix` | Lint fixes can change code; the agent should see and own them |
| Main-branch run cancelling | Per-run group for pushes and manual runs, cancel only for pull requests; a separate queued group for the apply job | Keep one group per branch and set `cancel-in-progress` to true only for pull requests | GitHub's docs say that even without `cancel-in-progress`, a newly queued run cancels any pending run in the same group, so a third quick push to main would still cancel one main run. GitHub added `queue: max` in May 2026 (up to 100 waiting runs per group), but it cannot be combined with `cancel-in-progress: true` |

Illustrative shapes (the builder confirms exact flags with each tool's `--help`):

```yaml
# lefthook.yml
pre-commit:
  parallel: true
  jobs:
    - name: format
      run: npx prettier --write --ignore-unknown {staged_files}
      stage_fixed: true
    - name: lint
      glob: '*.{ts,tsx,js}'
      run: npx eslint --no-warn-ignored {staged_files}
    - name: typecheck
      glob: '*.{ts,tsx,json,jsonc}'
      run: npx tsc -b
    - name: python
      glob: '*.py'
      run: ruff check {staged_files} && ruff format --check {staged_files}
    - name: secrets
      run: gitleaks git --pre-commit --staged --redact --no-banner
```

```yaml
# checks.yml, top level
concurrency:
  group: checks-${{ github.event_name == 'pull_request' && github.ref || github.run_id }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

# checks.yml, inside the apply-test-db job
    concurrency:
      group: apply-test-db
      queue: max
```

If GitHub refuses `queue: max` at job level (the pull request run would show a workflow error at once), the builder drops that one line and records it: the apply job then keeps at most one waiting run, and a replaced waiting run is harmless because the next apply pushes every migration not yet applied.

## Out of scope

- The pull request browser tests against a throwaway local database (`pr-local-db`, its own factory job before job 6).
- Changing the test database password, a GitHub Environment for its secret (needs a paid plan; you chose free), the test project's occasional slow saves, Dependabot secrets, a deploy step for main, a separate Cloudflare account for previews, a daily preview login check, a narrower Cloudflare key. All stay open items for the manager.
- Moving the secret scan to Betterleaks, or switching ESLint and Prettier to Biome.
- Running unit, browser or database tests in the commit check or the agent-stop check. They stay in CI.
- Editing `.claude/agents/*`, `.claude/skills/*` or any `.claude/` file other than `settings.json` as owner's call 1 says. If the factory agent files should mention the hooks, the manager does that.
- Editing the "Lessons learned" lines. The manager decides whether the lesson about waiting for the merge run can be retired once statement 17 is proven at merge.
- Copying evidence into `docs/evidence/`. The earlier workflow plan named that folder; the factory's job evidence folders replaced it.
- Session time and spend caps and the cost log from the factory plan.
- Anything on the PRD's "Not in v3.0" list. This job only writes the list into `AGENTS.md`.

## Build plan

1. **Conventions.** `docs/conventions.md`, the `AGENTS.md` changes, `tests/agents-md.test.ts`, `npm run check:code`, README command table. Covers 2 to 7.
2. **Commit check.** Add lefthook (exact version pinned), `lefthook.yml`, LF line endings for it in `.gitattributes`; install gitleaks with winget (free; tell the owner in one line); the five refused commits in a throwaway branch; timings; the worktree and main-commit proofs; README one time installs. Covers 8 to 14.
3. **Main-branch runs.** The two concurrency changes and their `[tooling 17]` tests; the two pull request proofs (cancelled push, two manual runs). Covers 17.
4. **Agent-stop check (only if owner's call 1 is B or C).** `scripts/hooks/stop-checks.ts` and its tests (add the folder to the Vitest, TypeScript and ESLint configs), then the exact `settings.json` change. Covers 15, 16.
5. **Prove and document.** All checks green, check minutes in `build.md`, evidence saved, "Checks and where they run" table final. Covers 1, 18, 19.

Dependencies: GitHub checks and previews exist from job 1. Docker is not on your computer, so database tests stay CI only. Statement 17's main-branch proof can only happen at merge, like job 3's statement 18.

## Risks and flags

- **Look closely: database (how changes reach the test project).** Statement 17 changes when and in what order the job that applies migrations to the test database runs. If two main runs carry migrations, the queue applies them in arrival order; an older run's tests could then meet a newer schema. Rare today, because the manager's close-out pushes carry no migrations.
- **Look closely: Claude Code settings.** Owner's call 1. A stop check that cannot go green could keep an agent working in circles. Claude Code stops that after 8 blocked stops in a row; the `Result: blocked` exit and the 40 line cap limit it further. With two builders working at once, one builder's stop check also sees the other builder's worktree.
- **Secrets near the hooks.** Both checks run next to `.env.local`. gitleaks scans only git changes, so the git-ignored `.env.local` is never read; output is redacted; the stop check never opens `.env*` (statement 15). Made-up keys for the proofs are committed only in a local branch that is never pushed, so they never reach GitHub's history scan.
- **A new install script.** lefthook runs its own setup script on every `npm ci`, including in CI jobs that later receive secrets (it skips installing there, but the script still runs). The version is pinned exactly and checked by `npm audit` and Dependabot. The security reviewer should look at this.
- **Hooks shared across worktrees.** Git keeps one hooks folder for the main checkout and all worktrees, so the builder's `npm ci` in this job's worktree changes how commits behave on main before merge (statement 12).
- **gitleaks is in maintenance mode.** Security patches only; a later move to Betterleaks is a separate decision.
- **Running costs.** €0. About 30 extra GitHub check minutes for the proof runs (two manual runs at about 14 minutes each), inside GitHub Free's 2,000 a month. This month's minutes used so far were not checked.
- No learner data, recordings, consent or Finnish learning content is touched.

## Owner's calls

Nothing in this job costs money, and no email address is needed.

**1. Should Claude Code also run the checks each time an agent finishes its turn?** The commit check catches problems when an agent saves work. This call is about also checking when an agent says it is done, even if it has unsaved changes. It changes `.claude/settings.json`, which is yours to decide.

- **A. No stop check.** Settings stay as they are. Problems are caught at every commit and on GitHub. A builder that stops with unsaved broken work is caught only at its next commit or on GitHub. The scope line "run clean on every stop" then becomes "run clean on every commit".
- **B. Check when a builder agent stops.** Only the factory builder is affected. If its work has a formatting, code or secret problem, it is told to fix it and cannot finish until the checks are clean or it reports itself blocked. Adds up to about a minute to each builder finish. The manager, reviewers, evaluator and your own sessions are untouched.
- **C. B, plus your own and the manager's sessions.** Any session that leaves app code changed in the main folder is also held until it is clean. The manager normally changes only factory files, so for it this costs about a second per turn. Matches the scope's "every stop" exactly.
- **Recommendation: B.** It covers the agent that writes code, and nothing else changes how your sessions behave.

The exact settings for B (the progress log line is today's, unchanged):

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "node \"$CLAUDE_PROJECT_DIR/recording/log-turn.mjs\"" }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "factory-builder",
        "hooks": [
          {
            "type": "command",
            "command": "node \"$CLAUDE_PROJECT_DIR/scripts/hooks/stop-checks.ts\" worktrees",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

For C, the `Stop` list gets one more entry after the progress log:

```json
{
  "type": "command",
  "command": "node \"$CLAUDE_PROJECT_DIR/scripts/hooks/stop-checks.ts\" main",
  "timeout": 120
}
```

How it works: a stop hook that exits with code 2 keeps the agent working and shows it the hook's message. `SubagentStop` with the matcher `factory-builder` fires only when the builder agent finishes. `worktrees` checks the factory worktrees; `main` checks the main folder. The settings take effect only after this job is merged, because sessions start in the main folder.

## Could not verify

- How lefthook behaves with git worktrees, which shell it uses for commands on Windows, and what its hook does in a checkout where lefthook is not installed. Statements 12 and 13 make the builder prove each on your computer.
- Whether `queue: max` works at job level (GitHub's changelog and docs do not say). The fallback is in "Decision".
- lefthook 2.2.2's publish date (about 12 October 2026, read from npm metadata, not an official date). I could not open its npm page or download count.
- Which gitleaks version `gitleaks/gitleaks-action` v3.0.0 runs in CI, so "same rules" assumes both use the default rule set of a recent 8.x release.
- The exact staged-scan flags of gitleaks 8.30.1 (community pages differ); the builder confirms with `gitleaks git --help`. Whether `winget` installs it without an administrator prompt.
- Whether Prettier skips files listed in `.prettierignore` when they are passed by name; statement 12's factory-only commit proves it either way.
- Whether Python and ruff are installed on your computer, and whether your global git settings set `core.hooksPath` (lefthook then refuses to install until told to).
- Whether Claude Code picks up a settings change in a running session or only in new ones.
- The hook timings; statements 11 and 15 measure them.

## Sources

- Scope item 2 and the rules every feature inherits: `docs/scope/scope.md`
- PRD sections 3, 4.1, 7 and 17: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- Project rules origin (GA sign off, evidence, threat model questions, debug triage, output style): `docs/workflow-upgrade-plan.md`, `docs/archive/skills-v1/architect/SKILL.md`, `docs/archive/skills-v1/debug/SKILL.md`
- Merge run cancellation: `factory/jobs/3-data-model/summary.md` ("Merge run")
- Claude Code hooks (Stop and SubagentStop input, exit code 2, `stop_hook_active`, the 8 continuation cap, matcher on agent type, default 600 second timeout, `CLAUDE_PROJECT_DIR`): https://code.claude.com/docs/en/hooks
- Claude Code reads `AGENTS.md` without a `CLAUDE.md` (v2.1.277 and later): https://code.claude.com/docs/en/memory
- GitHub Actions concurrency (expression in `cancel-in-progress`, a new run cancels the pending one, `github.head_ref || github.run_id` example, `queue: max`): https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency
- GitHub changelog, larger concurrency queues (7 May 2026): https://github.blog/changelog/2026-05-07-github-actions-concurrency-groups-now-allow-larger-queues
- lefthook (staged files, glob, `stage_fixed`, parallel): https://lefthook.dev/ and https://github.com/evilmartians/lefthook
- lefthook skips its install when `CI=true`: https://lefthook.dev/usage/envs/CI
- lefthook install and `core.hooksPath`: https://lefthook.dev/usage/commands/install/
- lefthook 2.2.2 package metadata: https://registry.npmjs.org/lefthook/latest
- husky 9.1.7 package metadata: https://registry.npmjs.org/husky/latest
- husky, lefthook and lint-staged compared (2026): https://www.pkgpulse.com/guides/husky-vs-lefthook-vs-lint-staged-git-hooks-nodejs-2026
- gitleaks (commands `git`, `dir`, `stdin`; `--redact`; exit codes; feature complete notice): https://github.com/gitleaks/gitleaks
- gitleaks latest release v8.30.1, 21 March 2026: https://api.github.com/repos/gitleaks/gitleaks/releases/latest
- winget package `Gitleaks.Gitleaks`: https://winget.ragerworks.com/package/Gitleaks.Gitleaks
- Betterleaks as gitleaks' successor: https://www.bleepingcomputer.com/news/security/betterleaks-a-new-open-source-secrets-scanner-to-replace-gitleaks/

Result: ready for owner approval
