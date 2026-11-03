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
| Automatic checks                | GitHub Actions: until the MVP launch a secret scan per change, one full run before launch |

Supabase's free plan offers only the general "Europe" region, so Supabase chose the country for the test project: Ireland, in the EU. The live project, made at liftoff on a paid plan, can pick a specific EU region.

Engines copied from PuhuScribe v2 are listed, with the v2 commit they came from, in [docs/v2-imports.md](docs/v2-imports.md).

## Run it locally (Windows)

Needs Node 24.

```
npm ci
npm run dev
```

Open the address it prints (usually http://localhost:5173). The front door shows today's session; pressing Start makes a guest account on the Supabase project in `.env.local` (anonymous sign ins must be switched on there) and opens the session at `/session` (job 8-first-session). `http://localhost:5173/api/health` answers from the Worker.

`npm ci` also installs the commit check (lefthook, `lefthook.yml`). Before every commit it formats the staged files and scans them for secrets with gitleaks. Until the MVP launch it runs no ESLint, type check or ruff (owner's decision of 3 November 2026). It needs two free tools, installed once:

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
- **Browser tests:** the check "Browser tests (Playwright, local Supabase)" starts its own throwaway Supabase in the runner (Postgres, the API gateway, the REST API and sign in), applies every migration, loads `supabase/seeds/browser/*.sql`, and runs the browser tests against the app pointed at it. It holds no secret, and parallel pull requests never share a database. Until the MVP launch both browser test checks run only in the full run (see "Tests until the MVP launch" below).
- **Seed rows for browser tests:** put them in `supabase/seeds/browser/` as numbered `.sql` files. They are made-up rows, loaded only into that throwaway database, and never reach a hosted database. Tag a test that needs them `@seed`.
- **Applying:** migrations reach the test project only through the workflow, and only after the owner approves a job (owner's rule from job 3-data-model). On a pull request the job "Apply database changes to the test project" is skipped. On the push to main that the merge makes, it runs `supabase db push` and then the same tests against the test project. Nobody applies migrations by hand, and no agent uses `supabase link`, a personal access token or a secret key.
- **Types:** `src/lib/database.types.ts` is made by the Supabase CLI from the migrated database (`npx supabase gen types --lang typescript --local --schema public`, which needs Docker). The database check regenerates it and fails if the committed file differs; when it does, the check keeps the new file as the `database-types` download on the run page.

## Tests until the MVP launch

The owner decided on 3 November 2026 that no tests run until every requirement for the MVP is done. Then the full run happens once, as the general test before launch. The workflow is `.github/workflows/checks.yml`.

- **Every pull request:** only the secret scan (gitleaks, because the repository is public), then the preview link is uploaded and posted. No browser test runs against it, and its comment says so.
- **Every push to main:** the secret scan, and "Apply database changes to the test project", which applies new migrations with no database test in front of it (content publishing depends on it). A push with no new migration applies nothing. If an apply fails, re-run the failed jobs of that run from its Actions page.
- **Before every commit:** lefthook runs only the Prettier fix and the secret scan.
- **The full run** (by hand, once before the MVP launch): on GitHub, open Actions, then Checks, then "Run workflow", pick `main`, tick "full" and run it. It runs the type check, lint and format, the unit tests, the Python tests, the dependency check, every database test, every browser test (about 720) on Chromium and WebKit, the `@empty-content` tests, and the browser tests against the test project. It takes about 30 minutes. A manual run without "full" runs only the secret scan, over the full git history.

No test is deleted. After the launch, a fast run is ready to switch on: removing the full-run `if:` lines from the test jobs gives every change the type check, unit, Python and dependency checks, the 29 browser tests tagged `@smoke` on Chromium (the road, one whole lesson, the word card, sign in, the account page and privacy), and the database tests only when `scripts/ci/checks-plan.ts` says the change needs them. That run took 5 minutes 19 seconds on pull request 16. To put a browser test in that set, give it the tag: `test('[label N] title', { tag: '@smoke' }, async ({ page }) => { ... })`.

## Preview links

When every check passes on a pull request, the workflow uploads a version of the `puhuscribe-preview` Worker with an alias made from the branch name (`factory/1-stack` becomes `factory-1-stack`) and posts the link on the pull request. Until the MVP launch no browser test runs against it, and the comment says so. Without the `CLOUDFLARE_ACCOUNT_ID` secret, wrangler finds the account from the Cloudflare API token.

The preview uses the shared test project, which gets a pull request's database changes only after the owner approves the job. So when a pull request adds, changes or deletes a file in `supabase/migrations/`, the comment says that screens needing the new database parts do not work on the link yet.

A push to main that changes only `factory/` or `recording/` files skips the checks and gets only a secret scan (`.github/workflows/secret-scan-notes.yml`). Cloudflare Access guards every preview link: a visitor sees a sign in page first. The evaluator gets in with an Access service token. The Supabase test project is kept awake by a daily workflow (`.github/workflows/keep-test-db-awake.yml`).

## Running costs

| Service                                                                                     | Plan                                                                                                                                                                                        | Cost today                                     |
| ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| GitHub (private repository, Actions checks)                                                 | Free (2,000 check minutes a month)                                                                                                                                                          | €0                                             |
| Cloudflare Workers (app, API, preview links)                                                | Workers Free                                                                                                                                                                                | €0                                             |
| Cloudflare Zero Trust (Access sign in for preview links)                                    | Free (up to 50 users)                                                                                                                                                                       | €0                                             |
| Cloudflare Workers, Exentrik account (`puhuscribe-review`, the private review site)         | Workers Free                                                                                                                                                                                | €0                                             |
| Cloudflare Zero Trust, Exentrik account (Access sign in for the review site, 2 of 50 seats) | Free (up to 50 users)                                                                                                                                                                       | €0                                             |
| Supabase (test project `puhuscribe-test`)                                                   | Free                                                                                                                                                                                        | €0                                             |
| Supabase built in email sender (sign in code emails)                                        | Included in Free (reaches only the Supabase team, 2 emails an hour)                                                                                                                         | €0                                             |
| Supabase Cron (daily clean up of unused accounts)                                           | Included in Free                                                                                                                                                                            | €0                                             |
| Anthropic API (drafting Finnish content at build time)                                      | Pay per use (key not created yet)                                                                                                                                                           | €0 so far; about $0.25 per dialogue (estimate) |
| Azure Speech (voices for both registers at build time)                                      | Free tier F0: 0.5 million characters a month, 20 requests a minute. The A1 road (job 20-a1-road) needs about 50,000 to 80,000 characters, and a guard refuses a run that would pass 450,000 | €0                                             |
| GitHub Actions minutes (the A1 road's import and voice runs, job 20-a1-road)                | Free while the repository is public; about 3 minutes a part to import and about 15 to voice                                                                                                 | €0                                             |
| Azure Speech to text (Say it speaking feedback, job 10)                                     | Free tier F0 during the build: 5 audio hours a month, one check at a time                                                                                                                   | €0; about $1 per hour of learner audio on S0   |
| Visit count, feedback and crash reports (job 14-analytics, in the Supabase database above)  | Included in Free; page loads now run the Worker and count toward Workers Free's 100,000 requests a day                                                                                      | €0                                             |

Before real learners can add an email or sign in, the owner chooses an email sender (job 11-accounts, owner's call 1, decided at launch). That will be a new service and may cost money.

## Owner page setup (job 14-analytics)

The owner page shows the launch numbers, the visit count, the newest feedback and recent crashes. It lives at its own address, `https://puhuscribe-owner.exentrik.co` (confirmed by the owner on 30 October 2026), served by the same Worker as the app. Free, about 15 minutes, done by the owner at go live (a separate job, owner's call 2). Nothing here holds a key.

1. In the Exentrik Cloudflare account, Zero Trust, Access, Applications: add a self hosted application for `puhuscribe-owner.exentrik.co` covering the whole hostname, with the One-time PIN login and one Allow policy holding the owner's own email address (typed there, never in a file). Add the evaluator's service token policy if the evaluator should reach it. Copy the application's AUD tag.
2. On the production Worker, set three plain variables: `OWNER_HOSTNAME` = `puhuscribe-owner.exentrik.co`, `OWNER_ACCESS_TEAM_DOMAIN` = the team domain (`https://<team>.cloudflareaccess.com`) and `OWNER_ACCESS_AUD` = the AUD tag. Attach the hostname to the Worker. Without all three, no hostname is treated as the owner page's. Never set `OWNER_ACCESS_LOCAL_JWKS` there: it is for the browser tests on this computer only.
3. Make sure your own PuhuScribe email account exists (start a session, then "Add your email" on the account page).
4. Put that account on the owner list. In the Supabase dashboard of the live project, SQL editor, run this one line, typing your own address in place of the words in angle brackets:

   ```sql
   insert into private.owners (user_id) select id from auth.users where email = '<your email address>';
   ```

   The email address never goes in a file. To take an account off the list later: `delete from private.owners where user_id = (select id from auth.users where email = '<the address>');`

5. Open `https://puhuscribe-owner.exentrik.co/owner`, pass the Cloudflare login, then sign in with your PuhuScribe email code. "Send a test error" under Crashes checks that crash reports arrive.

## Owner setup for accounts (job 11-accounts)

Free, about 10 minutes, on the Supabase test project (`puhuscribe-test`), in the dashboard. Needed before job 11 merges; nothing here holds a key.

1. Authentication, Emails, Templates, "Magic link": subject `Your PuhuScribe code`, body copied from `supabase/templates/magic-link.html`.
2. Authentication, Emails, Templates, "Change email address": subject `Your PuhuScribe code`, body copied from `supabase/templates/email-change.html`.
3. Authentication, Sign In / Providers, Email: check that "Confirm email" and "Secure email change" are on.
4. Authentication, Audit logs (or the project's Auth settings): turn off "Write audit logs to the database", so a deleted account leaves no audit rows behind.

The privacy notice also needs the owner's own input in `src/privacy/notice-settings.ts`: the name of who is responsible for learner data and the contact address for privacy requests. No agent fills these in.
