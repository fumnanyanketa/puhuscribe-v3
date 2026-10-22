# Job 2-smoke: Factory smoke test, a Hei! page that saves one visit

Not a scope.md item. It comes from the plan's "Factory smoke test" section (`docs/factory-and-risk-tests-plan.md`). Date: 19 October 2026. Builds on job 1-stack as merged on main.

## What it is

The app's front page will say "Hei!" and save one visit to the test database each time someone opens it. The page then says whether the visit was saved. This is a practice feature. It is small on purpose, so it can go through every factory step (spec, build, checks, both reviewers, preview link, evaluator, your approval) and show the factory works before any real feature is built. It also creates the first database table and the first automatic tests that prove nobody can read or change data they should not.

## Done when

Each statement is checked by a command, by the GitHub checks, or by opening the page. New tests are labelled `[smoke N]` with the statement number they protect. "The test project" means the hosted Supabase project `puhuscribe-test` (West EU, Ireland). "The page" means the app's front page, `/`.

1. **The page says Hei!.** Locally (`npm run dev` and the built app) and on the preview link, the page shows one heading, "Hei!", marked as Finnish (`lang="fi"` on the heading), and one status line below it. The browser tab title stays "PuhuScribe". The page adds no styling: no CSS file, no colours, no fonts, no images, no icons. It uses the browser's defaults until job 4.
2. **One visit per page load.** Each fresh load or reload of the page sends exactly one `POST /api/visits` to the page's own address. This also holds under `npm run dev`, where React's strict mode runs start-up code twice. A browser test counts the requests in the built app, in Chromium and WebKit. The evaluator checks `npm run dev` in the browser's network panel.
3. **Status messages in one style, with a next step.** Every message is a full sentence ending with a full stop:
   - while saving: "Saving your visit."
   - when saved: "Your visit is saved."
   - when not saved: "Your visit was not saved. Check your internet connection, then try again." with a "Try again" button below it.

   The status line is announced to screen readers (`role="status"`). The "Try again" button appears only after a failure. Pressing it sends one new `POST /api/visits`, shows "Saving your visit." and then the result. Browser tests in both browsers cover: the saved case, a blocked request (failure message, then a successful "Try again"), a server answer of 503, and a slow answer of 4 seconds ("Saving your visit." shows first).
4. **The Worker saves the visit.** `POST /api/visits` with `content-type: application/json` adds exactly one row to `visits` in the test project and answers `201` with `{"saved":true}`. If the database does not confirm the row (an error, no answer within 3 seconds, or settings missing), it answers `503` with `{"error":"visit_not_saved"}`. Any other method gets `405` with `allow: POST`. A `POST` without the JSON content type gets `415` and saves nothing (this stops other websites from adding visits with a plain form). No `/api/visits` response sends `Access-Control-Allow-Origin`. Unit tests with a fake database cover every one of these answers.
5. **No personal data.** The table `public.visits` has exactly two columns: `id` (a number the database generates) and `visited_at` (the time, set by the database). The Worker sends the database nothing from the visitor's request: no IP address, user agent, cookies, referrer, page address or request headers. Its request to Supabase carries only the `apikey`, `content-type` and `prefer` headers and an empty JSON body. The Worker writes nothing about the request to its logs. A unit test checks the exact outgoing request. The evaluator lists the table's columns on the test project.
6. **No secret key anywhere, and the browser never talks to Supabase.** The Worker writes with the test project's publishable key it already holds. No Supabase secret key (`sb_secret_...`) and no personal access token (`sbp_...`) is added to `.env.local`, GitHub secrets, Worker secrets or code. A browser test checks that every request the page makes goes to the page's own address, never to a `supabase.co` address. Job 1's checks on the built browser files (no key values, no secret `VITE_` names) still pass.
7. **The table and its access rule live in code.** The repository has a `supabase/` folder made by the Supabase CLI (`config.toml`, `migrations/`, `tests/`). The CLI is pinned as a development package (`supabase` in `package.json`), so local runs and the GitHub check use the same version. One migration:
   - creates `public.visits` with the two columns in statement 5;
   - removes every default permission on the table from the `anon`, `authenticated` and `service_role` roles, then gives `anon` (the role the publishable key runs as) permission to insert and nothing else;
   - turns on row level security (the per-row access rules);
   - adds one insert rule for `anon` that only accepts a row whose `visited_at` is the database's own current time (`with check (visited_at = now())`), so nobody can back-date or invent visits.

   No other grant, rule, function or view. `README.md` gets a short "Database changes" section: how to add a migration, where the tests live, and that migrations are only ever applied to the test project by the workflow.
8. **Database security tests.** `supabase/tests/` holds pgTAP tests (SQL tests run by `supabase test db`). Each runs inside a transaction that is rolled back, so it leaves no rows. Acting as `anon`, they prove:
   - adding a visit with default values works and adds exactly one row;
   - reading visits fails;
   - changing a visit fails;
   - deleting a visit fails;
   - adding a visit with a chosen time (for example 1 January 2020) fails.

   Acting as `authenticated`, they prove reading, adding, changing and deleting all fail. They also check the table has row level security on and exactly the two columns.
9. **The security tests can fail.** A scratch branch that gives `anon` permission to read visits makes the database check go red. The branch is deleted and its pull request closed afterwards. The red run is linked in `build.md`.
10. **A new GitHub check runs the database tests on a throwaway database.** The checks workflow gets a new check, "Database tests (local Supabase, pgTAP)". It starts a local Supabase inside the GitHub runner with only the services the tests need, applies every migration from an empty database, and runs `supabase test db`. It is green on this job's pull request, alongside all six of job 1's checks. Locally, the same command works wherever Docker is installed; the GitHub check is the reference.
11. **Migrations reach the test project through the workflow, never by hand.** After the database check passes, a job "Apply database changes to the test project" runs `supabase db push --db-url` with the existing `SUPABASE_TEST_DB_URL` secret. Then it proves on the test project that the publishable key cannot read, change or delete visits (by running the same pgTAP tests against it, or an equivalent check through the Supabase API). This job:
    - runs no `npm ci` and no project code, so the database password is never present while branch packages run;
    - passes the secret only to the steps that need it;
    - is skipped for Dependabot pull requests, which behave as they do today.

    The browser tests and the preview job wait for it. A second run on an unchanged branch applies nothing and stays green. The migration appears in the test project's migration history.
12. **The preview link shows the page and records a visit.** On the preview link (behind Cloudflare Access, as in job 1), the page shows "Hei!" and "Your visit is saved." The preview job's browser tests check this with the evaluator's service token. The evaluator opens the preview once and confirms the number of rows in `visits` on the test project went up by exactly one, using a direct SQL count before and after while no check is running. Without signing in, the preview still shows the Access sign in page, and `POST /api/visits` is refused (302, 401 or 403) and saves nothing.
13. **The existing checks stay green and keep their strength.** All of job 1's checks pass on this pull request. Job 1's browser tests that look for the old page text ("PuhuScribe" heading, "Server: ok") or wait for the page's `/api/health` call are changed to the new page text and the `/api/visits` call. Each still proves what it proved before: no console errors, the page calls its own address, deep links load the app, the Access page does not show the app. `build.md` lists every changed test line. No test is deleted or weakened. `/api/health`, its unit tests and the keep awake workflow are unchanged.
14. **No new running costs.** Every service stays on its free plan and the README "Running costs" list stays at €0. `build.md` reports how many check minutes one full pull request run used, so the GitHub Free allowance (2,000 minutes a month) can be watched.

Product rules from `AGENTS.md` that apply: no placeholders or fake data in the app; never delete or weaken a test; collect the minimum personal data (here, none); no keys in code, commits, logs or chat; agents use only the test database; client facing text in English. "Hei!" is a page heading for this practice page, not learning content: it has no audio, no unit and is never reviewed. It is only ever shown on the private preview link.

## Decision

Each choice below lists the pick, the runner up, and why the runner up lost. Sources are listed at the end.

| Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|
| How the Worker writes a visit | The publishable key (runs as the `anon` role) plus an insert-only access rule on `visits`. The Worker sends `Prefer: return=minimal`, so it never reads the row back | A database function that adds a visit and returns the total, running with the owner's rights (`security definer`), called by the publishable key | Supabase's row level security guide says a security definer function in a schema the API exposes is callable over the API with the creator's rights, and says never to create one there. Supabase's own advisor flags it (lint 0028). A Supabase secret key also lost: it bypasses every access rule, and job 1 gave no agent or Worker a secret key |
| What the page shows when saved | "Your visit is saved." | The total number of visits | Showing a total needs read access to `visits` or the security definer function above. Either one breaks the insert-only rule this job is meant to prove. The evaluator proves the save with a direct row count instead |
| What a visit stores | `id` and `visited_at` only, both set by the database | Also the page address, a session id or the browser type | None is needed to prove the factory. GDPR asks for the minimum. Anything more drifts into analytics, which is scope item 14 |
| How the table is defined | Supabase CLI migrations in `supabase/migrations/`, CLI pinned in `package.json` | Plain SQL files applied with `psql`, or another migration tool | The CLI is also what runs the local throwaway database and `supabase test db`, so one tool covers all three jobs. `supabase/setup-cli@v3` reads the CLI version from `package-lock.json`, so GitHub and local match |
| Permissions on the new table | Written out in the migration: remove all, then grant `anon` insert only | Rely on Supabase's default permissions | Since 30 May 2026, new Supabase projects no longer give the API roles access to new `public` tables automatically, and from 30 October 2026 this applies to all projects. CLI v2.106.0 made the local database behave the same way. Writing the permissions out gives the same result locally and on the test project, whatever the setting |
| How migrations reach the test project | A workflow job runs `supabase db push --db-url` with the existing test connection string, after the database tests pass and before the browser tests | `supabase link` plus `db push --linked`, run by an agent | Linking needs a Supabase personal access token, which reaches every project on the account, live included. Job 1 ruled that out. Also lost: Supabase Branching (one database per pull request), which is not included on the Free plan and costs $0.01344 per branch per hour on Pro; and the manager running the command by hand, which is not repeatable and lets the preview run ahead of the table |
| Order of the checks | Database tests on a local throwaway database, then apply to the test project, then browser tests and preview | Apply only after every check passes | The browser tests already run against the test project (job 1), so the table must exist there before they run |
| How the security tests run | pgTAP through `supabase test db`, on a local Supabase started in the runner with only the needed services (`supabase db start`, or `supabase start -x` with the unneeded services listed if `test db` needs more) | Vitest tests calling the local Supabase API with the local publishable key | pgTAP is the documented Supabase way to test access rules, with a sample GitHub workflow. It tests the rules directly, as each role, without the extra moving parts of the API |

### Notes for the builder

- The Worker's request is `POST {SUPABASE_URL}/rest/v1/visits` with headers `apikey`, `content-type: application/json` and `prefer: return=minimal`, body `{}`. PostgREST's docs say an insert answers `201` with no body by default, and that missing columns get their defaults. I could not confirm that an empty object `{}` is accepted. If the test project rejects it, use any request shape that inserts one row with all defaults, record it in `build.md`, and never add a column to make it work.
- If `anon` needs permission on the identity column's sequence to insert, grant usage on that sequence only and say so in `build.md`.
- `supabase init` creates `supabase/.gitignore`. Keep it, and check that `supabase/.temp/` is ignored.
- The local Supabase prints its own local keys at start. They are local defaults, not test project keys, but keep them out of uploaded files and logs where possible.
- Job 1's `/api/health` uses the `/graphql/v1` endpoint. Supabase's changelog says `pg_graphql` stopped being on by default for new projects from 18 May 2026, yet job 1's evaluator saw the check work. Leave it alone in this job. Do not switch the health check to `visits`.

## Out of scope

- Any table other than `visits`, and any part of the data model: units, dialogue lines, forms, review cards, sessions, consents, the 104 v2 sentences (job 3). Whether `visits` is kept or dropped later is job 3's call.
- Any styling, fonts, colours, design tokens or components (job 4).
- Sign in, accounts, the `authenticated` role having any access, or anything tied to a person (job 9).
- A visit counter on the page, a visits dashboard, unique visitor counting, cookies, session ids, or any analytics (job 14).
- Anything on the PRD's "Not in v3.0" list. In particular: no streaks or "you visited N days in a row", no confetti or celebration when a visit saves.
- A Supabase secret key, a personal access token, Supabase Branching, or `supabase link`.
- The production Worker, the live database, a deploy step for main, or rate limits for a public site (liftoff).
- Changing `/api/health`, the keep awake workflow, the Cloudflare Access setup, or `wrangler.jsonc` observability settings.
- Job 1's open security ideas (a separate Cloudflare account for previews; a daily check from main that preview links still ask for sign in) and the Dependabot secrets item. The manager tracks these; they are not part of this job.
- Git hooks and the `AGENTS.md` conventions section (job 2, Coding standards & tooling).
- The recording steps below (progress log, session replay). The manager does those.

## Build plan

1. **The table in code.** Add the pinned Supabase CLI, run `supabase init`, write the migration and the pgTAP tests. Run them locally if Docker is available. Covers 5, 7, 8.
2. **The database check.** Add "Database tests (local Supabase, pgTAP)" to the checks workflow. Prove it goes red with the scratch branch, then clean up. Covers 9, 10.
3. **The Worker route.** Add `POST /api/visits` with its unit tests, including the exact outgoing request and every error answer. Covers 4, 5, 6.
4. **The page.** Replace the front page with "Hei!" and the three messages plus "Try again". Write the new browser tests and update job 1's browser tests to the new page text. Covers 1, 2, 3, 6, 13.
5. **The test project and the preview.** Add the "Apply database changes to the test project" job and order the browser and preview jobs after it. Add the anonymous `POST /api/visits` test to the preview tests. Update the README. Report check minutes. Covers 11, 12, 14.

Dependencies: GitHub checks, the Supabase test project, the `SUPABASE_TEST_DB_URL` GitHub secret and the preview links all exist from job 1. Docker on the owner's Windows computer is not known; the GitHub check is the reference for the database tests.

## Risks and flags

- **Look closely: database and access rules.** This job creates the first table, the first access rule, the first migration path to the test project, and puts the test database password (`SUPABASE_TEST_DB_URL`) to use in a GitHub job for the first time. That password gives full control of the test project only. It is kept out of every job that installs branch packages. A branch can still change the workflow file itself, the same accepted risk as job 1's Cloudflare key, limited to test values.
- **Shared test database.** A branch's migration reaches the test project once its database tests pass, before your approval. If a job is rejected, its table stays in the test project until a later migration removes it. The CLI may then refuse later pushes until the migration history is repaired. The manager handles that by hand when it happens. This touches only the test project.
- **Learner data.** None is stored: a visit is a number and a time. Two things were not verified and matter before real learners arrive. First, Cloudflare Workers Logs (switched on in job 1, kept 3 days on the free plan) record each request; Cloudflare's page does not say whether that includes the visitor's IP address. Second, whether Cloudflare adds any visitor-identifying header to the Worker's own request to Supabase. The Worker forwards no headers itself.
- **Running costs.** €0. Each check run now starts a small local database, which uses more GitHub check minutes; the amount is not measured yet (statement 14 measures it). Every check run and preview test adds a few rows to the test project. Each row is a number and a time, so the 500 MB free database limit is far away.
- **Finnish content.** "Hei!" appears on screen, but it is a page heading on a private practice page with no audio and no review. It does not go to the native reviewer. The first real screen (job 6) replaces this page.
- **The table travels.** Every database the migrations run on gets `visits`, including the live one at liftoff, unless job 3 drops it.

## Manager steps (recording, not the builder's work)

The plan asks the smoke test to produce a progress log and a session replay. These are the manager's steps and are not in "Done when".

1. **Progress log.** Keep appending one dated line to `factory/progress.md` at every stage, as in job 1. The plan also describes an automatic log written after every Claude turn. That does not exist yet: the repository has no `.claude/settings.json` hook. Adding one changes Claude Code's settings, so the manager shows the owner the exact hook and waits for an OK before turning it on.
2. **Session replay.** After the job merges, turn the job's session logs (manager, spec writer, builder, both reviewers, evaluator) into replay files with claude-replay (`es617/claude-replay`, open source, makes one HTML file per session). Optionally also make readable pages with Simon Willison's `claude-code-transcripts`. Save them under `recording/`. Before saving, scan every file for secret values and redact them, as job 1's first lesson requires. Publishing any of them is the owner's call (below).
3. **Dashboard and evidence.** Take a dashboard screenshot at every stage and add scenes to `recording/scenes.md` as the `/factory` skill says. Copy the preview run's Playwright video of the page saving a visit into `recording/` as the "it really works" clip.

## Owner's calls

**1. How the practice page looks.**
- A. Plain browser defaults now (black text on white, the browser's own font). The factory is proven this week. You choose the real look in job 4, from researched references.
- B. Hold the smoke test until job 4 is done, so the video shows a designed page. The factory stays unproven until then, and job 4 itself would run through an untested factory.
- Recommendation: A.

**2. Spending.** Nothing in this job costs money. Everything stays on free plans. No decision needed.

**3. Email addresses.** None needed. The preview sign in keeps the address you already chose in job 1.

**4. Publishing the session replays and transcripts.** This decision is needed after the job merges, not before the build.
- A. Keep them private, in the private repository's `recording/` folder. You decide what to show when you edit the video.
- B. Publish them as public pages after a secret scan, for example as a GitHub Gist (the transcripts tool can do this). This makes them public proof for the series, but session logs can hold file paths, settings names and other details you may not want public.
- Recommendation: A for now. Decide B per video, once you see the files.

## Could not verify

- Whether PostgREST accepts an empty JSON object `{}` as "insert one row with all defaults".
- Whether `supabase test db` runs with only `supabase db start` (Postgres alone), and whether `supabase test db --db-url` works against the test project's session pooler connection.
- Whether `supabase db push --db-url` asks for confirmation in a GitHub job without the global `--yes` flag.
- The CLI v2.106.0 note that the local database withholds default permissions comes from a release tracker site (releases.sh), not from Supabase's own page.
- Whether `anon` needs a separate permission on the identity column's sequence to insert.
- What Cloudflare Workers Logs record about the visitor (IP address or not), and whether Cloudflare adds visitor headers to a Worker's outgoing request.
- How many GitHub check minutes the local Supabase start adds per run.

## Sources

- Supabase row level security guide (security definer warning, no access until policies exist): https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase API keys (publishable key runs as `anon`, `apikey` header, secret keys bypass row level security): https://supabase.com/docs/guides/api/api-keys
- Supabase changelog, tables not exposed automatically (28 April, 30 May and 30 October 2026, `pg_graphql` off by default from 18 May 2026, recommended grants): https://supabase.com/changelog/45329-breaking-change-tables-not-exposed-to-data-and-graphql-api-automatically
- Supabase CLI v2.106.0 release note (local database withholds default permissions), 11 June 2026: https://releases.sh/release/rel__tSt2l5y6ZxWs6rMGLLZF-supabase-cli-v2-106-0-makes-public-schema-objects-opt-in-by-default
- Supabase database advisors (lint 0024 permissive policy, lint 0028 security definer callable without sign in): https://supabase.com/docs/guides/database/database-advisors
- Supabase CLI `db push`, `test db`, `db start`: https://supabase.com/docs/reference/cli/supabase-db-push
- Supabase CLI `start` and its `-x` exclude list: https://supabase.com/docs/reference/cli/supabase-start
- Supabase testing overview (pgTAP, sample GitHub workflow): https://supabase.com/docs/guides/local-development/testing/overview
- Supabase setup-cli action (v3, version read from the lockfile): https://github.com/supabase/setup-cli
- Supabase pricing (Free: 500 MB database, 2 projects, pauses after 1 week; Branching not included on Free, $0.01344 per branch per hour on Pro): https://supabase.com/pricing.md
- PostgREST tables and views (insert answers 201 with no body by default; missing columns get defaults): https://docs.postgrest.org/en/stable/references/api/tables_views.html
- Cloudflare Workers Logs (3 days on Free, invocation logs can be turned off): https://developers.cloudflare.com/workers/observability/logs/workers-logs/
- claude-replay: https://cdn.jsdelivr.net/npm/claude-replay@0.10.0/README.md and https://hn.svelte.dev/item/47276604
- claude-code-transcripts: https://simonwillison.net/2025/Dec/25/claude-code-transcripts/

Result: ready for owner approval
