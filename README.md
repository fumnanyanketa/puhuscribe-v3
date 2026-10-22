# PuhuScribe v3

PuhuScribe teaches adult newcomers in Finland the Finnish people actually speak, from A0 to A1. House rules for every AI session are in [AGENTS.md](AGENTS.md). Feature work goes through the factory (`/factory`).

## Stack

The full decision, with the runner up for each choice and why it lost, is in [factory/jobs/1-stack/spec.md](factory/jobs/1-stack/spec.md#decision).

| Layer                           | Pick                                                                                      |
| ------------------------------- | ----------------------------------------------------------------------------------------- |
| Frontend                        | React 19, Vite 8, TypeScript (strict), single page app                                    |
| Hosting and API                 | One Cloudflare Worker serves the built app and every `/api/*` route from the same address |
| Database, sign in, access rules | Supabase, in an EU region (test project: West EU, Ireland, `eu-west-1`)                   |
| Runtime and packages            | Node 24 LTS, npm                                                                          |
| Unit tests                      | Vitest                                                                                    |
| Browser tests                   | Playwright, Chromium and WebKit at phone size (375 x 812)                                 |
| Lint and format                 | ESLint (typescript-eslint type checked rules, react-hooks, jsx-a11y), Prettier            |
| Finnish content pipeline        | Python 3.12, Voikko, pytest, ruff (runs in the GitHub check on Linux)                     |
| Secret scan                     | gitleaks                                                                                  |
| Dependency check                | `npm audit`, `pip-audit`, Dependabot                                                      |
| Automatic checks                | GitHub Actions, on every pull request                                                     |

Supabase's free plan offers only the general "Europe" region, so Supabase chose the country for the test project: Ireland, in the EU. The live project, made at liftoff on a paid plan, can pick a specific EU region.

Engines copied from PuhuScribe v2 are listed, with the v2 commit they came from, in [docs/v2-imports.md](docs/v2-imports.md).

## Run it locally (Windows)

Needs Node 24.

```
npm ci
npm run dev
```

Open the address it prints (usually http://localhost:5173). The front door shows today's session; pressing Start makes a guest account on the Supabase project in `.env.local` (anonymous sign ins must be switched on there) and opens the session at `/session` (job 8-first-session). `http://localhost:5173/api/health` answers from the Worker.

`npm ci` also installs the commit check (lefthook, `lefthook.yml`). Before every commit it formats the staged files and checks them with ESLint, the type check, ruff and gitleaks. It needs two free tools, installed once:

| Tool                                 | One time install                                               |
| ------------------------------------ | -------------------------------------------------------------- |
| gitleaks (secret scan)               | `winget install --id Gitleaks.Gitleaks -e`                     |
| ruff (Python lint and format checks) | `python -m pip install --user -r scripts/requirements-dev.txt` |

If one is missing, the commit is refused with that install command. Where each check runs is in [docs/conventions.md](docs/conventions.md#checks-and-where-they-run).

Other commands:

| Command                | What it does                                                                                                        |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `npm run build`        | Builds the browser files and the Worker bundle into `dist/`                                                         |
| `npm run typecheck`    | TypeScript strict check                                                                                             |
| `npm run lint`         | ESLint                                                                                                              |
| `npm run format:check` | Prettier check (`npm run format` fixes)                                                                             |
| `npm run check:code`   | Type check, lint and format check, in that order. Stops at the first that fails                                     |
| `npm test`             | Unit tests (Vitest), including the imported v2 scheduler and grader tests                                           |
| `npm run test:browser` | Browser tests (Playwright) against the built app and its Worker. First run `npx playwright install chromium webkit` |

The Finnish word checker tests need Linux (Voikko). They run in the GitHub check. See [scripts/generate/README.md](scripts/generate/README.md).

Switzer, the body font, is not in this repository because its licence forbids public repositories. Without it the app uses Poppins for body text and every command above passes; a script fetches the files when a deploy key is available. See [docs/fonts.md](docs/fonts.md).

Third party licences and attributions (the skills in `.claude/skills/` and some reference data) are in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md). The repository itself has no licence yet.

Local settings go in `.env.local`, which git ignores. [.env.example](.env.example) lists every name. Without the Supabase test project settings, `/api/health` reports the database as `not_configured` and the browser tests fail on purpose.

## Database changes

The database is defined in code in `supabase/`, made by the Supabase CLI. The CLI is pinned in `package.json`, so local runs and the GitHub check use the same version. Every table, who can read and write it, and how to load v2's data again are described in [docs/data-model.md](docs/data-model.md).

- **Add a change:** `npx supabase migration new <short_name>` creates a timestamped SQL file in `supabase/migrations/`. Write the change there. Every new table gets its permissions written out (remove all, then grant only what is needed), row level security, and its access rules in the same migration.
- **Tests:** pgTAP tests (SQL tests) live in `supabase/tests/database/`. Each one runs in a transaction that is rolled back. They prove what each role can and cannot do. With Docker installed, `npx supabase db start` followed by `npx supabase test db` runs them on a throwaway local database. The GitHub check "Database tests (local Supabase, pgTAP)" is the reference.
- **Browser tests:** on a pull request, the check "Browser tests (Playwright, local Supabase)" starts its own throwaway Supabase in the runner (Postgres, the API gateway, the REST API and sign in), applies every migration, loads `supabase/seeds/browser/*.sql`, and runs every browser test against the app pointed at it. It holds no secret, and parallel pull requests never share a database. After a merge, "Browser tests against the test project (after merge)" runs them against the test project, without tests tagged `@seed`.
- **Seed rows for browser tests:** put them in `supabase/seeds/browser/` as numbered `.sql` files. They are made-up rows, loaded only into that throwaway database, and never reach a hosted database. Tag a test that needs them `@seed`.
- **Applying:** migrations reach the test project only through the workflow, and only after the owner approves a job (owner's rule from job 3-data-model). On a pull request the job "Apply database changes to the test project" is skipped. On the push to main that the merge makes, it runs `supabase db push` and then the same tests against the test project. Nobody applies migrations by hand, and no agent uses `supabase link`, a personal access token or a secret key.
- **Types:** `src/lib/database.types.ts` is made by the Supabase CLI from the migrated database (`npx supabase gen types --lang typescript --local --schema public`, which needs Docker). The database check regenerates it and fails if the committed file differs; when it does, the check keeps the new file as the `database-types` download on the run page.

## Preview links

When every check passes on a pull request, the workflow uploads a version of the `puhuscribe-preview` Worker with an alias made from the branch name (`factory/1-stack` becomes `factory-1-stack`), runs the browser tests against it (without tests tagged `@seed`), and posts the link on the pull request.

The preview uses the shared test project, which gets a pull request's database changes only after the owner approves the job. So when a pull request adds, changes or deletes a file in `supabase/migrations/`, only the Cloudflare Access lock tests (tag `@preview`) run on the preview, and the comment says that screens needing the new database parts do not work on the link yet. The full browser tests for that pull request ran on its throwaway database; their videos and screenshots are in the `playwright-report` download of the run, linked in the comment.

A push to main that changes only `factory/` or `recording/` files skips the checks and gets only a secret scan (`.github/workflows/secret-scan-notes.yml`). Cloudflare Access guards every preview link: a visitor sees a sign in page first. The evaluator gets in with an Access service token. The Supabase test project is kept awake by a daily workflow (`.github/workflows/keep-test-db-awake.yml`).

## Running costs

| Service                                                  | Plan                                                                      | Cost today                                     |
| -------------------------------------------------------- | ------------------------------------------------------------------------- | ---------------------------------------------- |
| GitHub (private repository, Actions checks)              | Free (2,000 check minutes a month)                                        | €0                                             |
| Cloudflare Workers (app, API, preview links)             | Workers Free                                                              | €0                                             |
| Cloudflare Zero Trust (Access sign in for preview links) | Free (up to 50 users)                                                     | €0                                             |
| Supabase (test project `puhuscribe-test`)                | Free                                                                      | €0                                             |
| Anthropic API (drafting Finnish content at build time)   | Pay per use (key not created yet)                                         | €0 so far; about $0.25 per dialogue (estimate) |
| Azure Speech (voices for both registers at build time)   | Free allowance, 0.5 million characters a month (resource not created yet) | €0                                             |
