# Conventions

How the code in this repository is organised, named, tested and checked. Each rule names a real file that already follows it. `AGENTS.md` has the short version. `tests/agents-md.test.ts` fails if a path or `npm run` script named here stops existing.

Written in job 4-tooling (`factory/jobs/4-tooling/spec.md`), from what jobs 1 to 3 built.

## Folder layout

| Folder | What lives there | Example |
| --- | --- | --- |
| `src/` | The React app (browser code) | `src/App.tsx` |
| `src/lib/` | Shared app code, including the engines imported from v2 | `src/lib/grade.ts` |
| `src/styles/` | The design values (`tokens.css`), the fonts and the base styles every page gets | `src/styles/tokens.css` |
| `src/components/` | The screen parts: one PascalCase .tsx file with a CSS Module (.module.css) beside it | `src/components/FinnishLine.tsx` |
| `src/design-reference/` | The reference page, built only in development and preview builds | `src/design-reference/DesignReference.tsx` |
| `design/` | The design brief, brand assets and v2's design handoff; the design guide is `design.md` at the root | `design/brief.md` |
| `worker/` | The one Cloudflare Worker: serves the built app and every `/api/*` route | `worker/api.ts` |
| `review-site/` | The private review site for the native reviewer: its own Worker `puhuscribe-review`, its config and the list of dialogues it shows ([docs/content-pipeline.md](content-pipeline.md#the-review-site)) | `review-site/handler.ts` |
| `e2e/` | Playwright browser tests | `e2e/first-session.spec.ts` |
| `tests/` | Tests about the whole repository (workflow shape, hygiene, these docs) | `tests/repo-hygiene.test.ts` |
| `scripts/security/` | Build guards, run directly by Node 24 (no build step) | `scripts/security/check-env-names.ts` |
| `scripts/ci/` | Helpers the GitHub checks run, also run directly by Node 24 | `scripts/ci/preview-alias.ts` |
| `scripts/v2-import/` | Turns copied v2 files into load SQL, run directly by Node 24 | `scripts/v2-import/build.ts` |
| `scripts/hooks/` | The agent stop check, run directly by Node 24 | `scripts/hooks/stop-checks.ts` |
| `scripts/review-site/` | Builds the private review site into `dist-review/`, run directly by Node 24 (job 13-review-site) | `scripts/review-site/build.ts` |
| `scripts/generate/` | The Python content pipeline: v2's imported files and the pipeline built in job 7-content-pipeline ([docs/content-pipeline.md](content-pipeline.md)) | `scripts/generate/pipeline.py` |
| `supabase/migrations/` | Database changes, in order | `supabase/migrations/20261020090100_learner_model.sql` |
| `supabase/tests/database/` | pgTAP database tests | `supabase/tests/database/first_session.test.sql` |
| `content/` | The content pipeline's briefs, drafts, review files, recordings, cost log and thresholds; v2 file copies and the corrections list | `content/briefs/meeting-people-new-colleague.json` |
| `data/` | Reference data copied from v2 | `docs/v2-imports.md` lists each file |
| `docs/` | Plans, scope, data model and these conventions | `docs/data-model.md` |
| `factory/` | The factory's board, feature list, job specs, notes and evidence | `factory/features.json` |
| `spikes/` | Throwaway experiments, not app code | `spikes/ios-mic/index.html` |

`docs/`, `factory/`, `spikes/` and `.claude/` are not app code: Prettier, ESLint and ruff leave them alone. The owner's private recording folder (video material) is not in the public copy, but the checks still ignore it if it exists.

## Naming

- TypeScript files are kebab-case: `scripts/security/check-built-secrets.ts`.
- React components are PascalCase: `src/App.tsx`.
- Unit tests sit next to the code they test, as `<name>.test.ts`: `worker/sessions.test.ts` tests what `worker/api.ts` does with sessions.
- Browser tests are `e2e/<area>.spec.ts`: `e2e/health.spec.ts`.
- Migrations are `<UTC timestamp>_<snake_case>.sql`, always made with `npx supabase migration new <snake_case>`: `supabase/migrations/20261019183410_create_visits.sql`.
- pgTAP files are `<area>_<topic>.test.sql`: `supabase/tests/database/data_model_learners.test.sql`.
- Reference data loads are `<timestamp>_load_v2_<what>.sql`. The database check runs every `*_load_v2_*.sql` file a second time to prove it changes nothing: `supabase/migrations/20261020090300_load_v2_lemma_ipa.sql`.

## Test labels

Every test name carries the label of the job whose spec it protects and the "Done when" statement number, in square brackets. Each test file's header comment names the spec. Each spec states its label.

| Job | Label | Example |
| --- | --- | --- |
| 1-stack | `[N]` (bare number) | `tests/repo-hygiene.test.ts` |
| 2-smoke | `[smoke N]` | `tests/checks-workflow.test.ts` |
| 3-data-model | `[data N]` | `src/lib/database-types.test.ts` |
| 4-tooling | `[tooling N]` | `tests/agents-md.test.ts` |
| 5-design-system | `[design N]` | `tests/design-tokens.test.ts` |
| 7-content-pipeline | `[content N]` | `tests/content-audio.test.ts`; in pytest the label opens each test's docstring, as in `scripts/generate/test_content_checks.py` |
| 8-first-session | `[session N]` | `worker/sessions.test.ts` |
| 9-daily-review | `[review N]` | `worker/review.test.ts` |
| 12-units-1-3 | `[units N]` | `worker/patterns.test.ts`; in pytest `scripts/generate/test_units_1_3.py` |
| 13-review-site | `[site N]` | `review-site/handler.test.ts` |

A test may carry two labels when it protects two statements. Never remove a label or a test to make a check pass.

## Migrations and pgTAP

Example: `supabase/migrations/20261020090100_learner_model.sql` with its tests in `supabase/tests/database/data_model_learners.test.sql`.

- New tables give the API roles nothing by default. Each migration still writes it out: revoke everything from `anon`, `authenticated` and `service_role`, then grant only what the spec allows.
- Row level security is on for every table. Rules name their role (`to authenticated`) and read the user as `(select auth.uid())`, so Postgres runs it once per query.
- Columns that rules or queries filter on get an index.
- Helper functions live in the `private` schema with `set search_path = ''`, and every API role's right to run them is revoked.
- Each pgTAP file runs in one transaction that is rolled back (`begin;` then `select plan(n);`, ending with `rollback;`), so it leaves no rows, also on the test project.
- A test acts as a learner by setting `request.jwt.claims` with `set_config` and then `set local role authenticated`.
- Reference data is loaded by upsert migrations (`on conflict ... do update`), so loading twice changes nothing.
- `src/lib/database.types.ts` comes only from the Supabase CLI (`npx supabase gen types --lang typescript --local --schema public`). The database check fails if the committed file differs.
- Migrations reach the shared test project only through the workflow, on the push to main that a merge makes. Nobody applies them by hand.
- `supabase/config.toml` sets `auto_expose_new_tables = false`, so a local database gives a new table no API access unless its migration grants it, as on the test project.
- Browser test seed files live in `supabase/seeds/browser/`, named with a number first so their order is clear. Only the pull request check "Browser tests (Playwright, local Supabase)" loads them, into its throwaway database. They never reach a hosted database. A Playwright test that needs their rows carries the tag `@seed`.
- A test that runs against the test project never depends on its row counts or on rows another run wrote.

## Provider modules

Voice, speech feedback and AI each sit behind one module in `worker/providers/`. The first job that adds a provider creates the folder. Swapping a provider then changes that one module.

- Provider keys exist only as Worker secrets (and in `.env.local` locally). The browser never holds one.
- The browser calls only `/api/*` on its own address. `worker/index.ts` sends those requests to `worker/api.ts`, which today is the only code that talks to an outside service (Supabase), with the key from the Worker's environment.
- Every AI call is logged with its cost.

Build time providers (job 7-content-pipeline). The content pipeline runs on a build machine, never in the Worker, so its two providers live in `scripts/generate/providers/`: `scripts/generate/providers/ai.py` is the only file that calls an AI service and `scripts/generate/providers/voice.py` the only file that calls a voice service (`scripts/generate/test_content_providers.py` checks both). `AI_PROVIDER` (`anthropic` or `fake`) and `VOICE_PROVIDER` (`azure` or `fake`) pick them. Their keys, `ANTHROPIC_API_KEY` and `AZURE_SPEECH_KEY`, exist only as GitHub secrets read by the manual workflow `.github/workflows/content-pipeline.yml`. Every call and synthesis is logged with its cost in `content/logs/` (`ai-calls.jsonl`). No pipeline database role exists: content reaches the database only through publish migrations.

## Secrets

Example: `.env.example` lists every name with a one line purpose and no value. `tests/repo-hygiene.test.ts` checks it.

- Real values live only in `.env.local` (git ignored) and in GitHub secrets. Never in code, commits, logs, test files or chat.
- Never read, search or print `.env*` files. Job worktrees hold a copy of `.env.local`. Search with `git grep`, which reads only tracked files.
- No variable whose name looks secret may start with `VITE_`, because Vite copies those into browser files. `scripts/security/check-env-names.ts` refuses the build if one does, and `scripts/security/check-built-secrets.ts` checks the built files for secret values.
- Files from a test run are scanned for secret values before upload: `scripts/ci/check-files-for-secrets.ts`.
- The test database password reaches only the job "Apply database changes to the test project" in `.github/workflows/checks.yml`.
- Third-party GitHub Actions are pinned to a full commit, with the version in a comment.

## Files imported from v2

Example: `src/lib/grade.ts`, listed with its v2 commit in `docs/v2-imports.md`.

- They stay byte for byte unchanged. `tests/v2-imports.test.ts` compares each file's hash with v2's.
- They are listed in `.prettierignore` and excluded from `ruff format` in `ruff.toml`, so no formatter touches them.
- A lint exception is made per file, with a comment saying why: see the `src/lib/grade.ts` block in `eslint.config.js`.

## Evidence folders

Each job keeps its proof in `factory/jobs/<job-id>/evidence/`. Proof is never deleted and never holds a secret. File names:

- `<statement>-<short-name>.<ext>`, with several statement numbers joined by hyphens: `factory/jobs/3-data-model/evidence/15-16-loader-tamper-and-v2-match.txt`.
- `r<round>-` in front for a check made again in a later round: `factory/jobs/3-data-model/evidence/r4-17-red-run.txt`.
- `break-` in front for a test that breaks something on purpose: `factory/jobs/1-stack/evidence/break-browser-tests.txt`.
- `ci-` or `local-` in front for command output from GitHub or from this computer: `factory/jobs/2-smoke/evidence/ci-pr6-checks.txt`, `factory/jobs/2-smoke/evidence/local-03-typecheck.txt`.

## build.md

The builder's notes, `factory/jobs/<job-id>/build.md`, are rewritten each round. Example: `factory/jobs/3-data-model/build.md`.

- What was built, in plain English; which "Done when" statements each test covers; the check results with the commands run; anything unfinished; how to run it locally.
- An "Earlier rounds" section keeps, for each earlier round, its tip commit, its green and red run links and a one line summary.
- The last line is `Result: checks pass` or `Result: blocked: <one line reason>`.

## Checks and where they run

| Check | Before a commit (lefthook) | When a builder agent stops | On GitHub (every pull request and push to main) |
| --- | --- | --- | --- |
| Type check (`tsc -b`) | When a staged file is `.ts`, `.tsx`, `.json` or `.jsonc` | When a changed app file is one of those | Yes |
| Lint (ESLint) | Staged `.ts`, `.tsx`, `.js` files | Changed `.ts`, `.tsx`, `.js` app files | Yes |
| Format (Prettier) | Fixes staged files and adds the fixes | Changed app files (check only) | Yes (check only) |
| Python lint and format (ruff) | Staged `.py` files | No | Yes |
| Secret scan (gitleaks) | The staged changes, output redacted | Changed app files, output redacted | Pull request commits; pushes to main; full history on a manual run |
| Unit tests (Vitest) | No | No | Yes |
| Python tests (pytest, Voikko) and the content checks on committed drafts | No | No | Yes |
| Database tests (pgTAP) | No | No | Yes |
| Browser tests (Playwright) | No | No | Pull requests and manual runs: on a throwaway local Supabase in the runner, no secret. Pushes to main: against the test project, after the apply job, without `@seed` tests |
| Dependency check (`npm audit`, `pip-audit`) | No | No | Yes |

- **Before a commit:** `lefthook.yml`. lefthook installs its git hook during `npm ci` (not on GitHub, where `CI=true`). The one time installs for gitleaks and ruff are in the README.
- **When a builder agent stops:** `scripts/hooks/stop-checks.ts`, started by the `SubagentStop` hook in `.claude/settings.json` for the `factory-builder` agent only. It checks the app files changed in each factory worktree since it left main. Files under `factory/`, `docs/` and `.claude/`, and the private recording folder, do not count. A builder whose `build.md` ends with `Result: blocked:` may stop.
- **On GitHub:** `.github/workflows/checks.yml`. A push to main that changes only `factory/` files or the private recording folder skips it and runs only the secret scan in `.github/workflows/secret-scan-notes.yml`. Pull requests always run every check.
- **By hand:** `npm run check:code` runs the type check, lint and format check, in that order.

Never skip a check (`git commit --no-verify`, `LEFTHOOK=0`) and never edit one to make it pass. If a check is wrong, say so in the job notes.

Do not run `npx lefthook uninstall`. lefthook 2.2.2 rewrites `.claude/settings.json` when it uninstalls (it reorders the keys), which changes a file only the owner decides on. Git keeps one hooks folder for the main checkout and every worktree, so the last `npm ci` decides which copy of lefthook the hook starts; after a factory worktree is removed, run `npm ci` in the main checkout. Until then the hook cannot find lefthook and refuses every commit there (`assert_lefthook_installed` in `lefthook.yml`), so nothing is committed unchecked.
