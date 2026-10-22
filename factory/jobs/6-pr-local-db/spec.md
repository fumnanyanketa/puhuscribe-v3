# Job 6-pr-local-db: Pull-request browser tests against a throwaway local database

Factory job, no scope item. Owner decision of 20 October 2026 (`factory/jobs/3-data-model/summary.md`). Date: 21 October 2026. Builds on jobs 1 to 5 as merged on main (`8081642`). Test label: `[prdb N]`.

## Summary for the owner

1. Today a job that adds a database table cannot pass its browser tests, because those tests use the shared test database, which only gets new tables after you approve.
2. This job gives every pull request its own private, empty database inside GitHub's machine, with that job's tables, used for the browser tests and then thrown away.
3. Jobs running side by side can no longer disturb each other's tests, and the shared test database still changes only after your approval.
4. One catch remains: the preview link still uses the shared test database, so a job's new database parts do not work on its link until you approve it.
5. One question for you: how the evaluator should click through those parts before you approve (recommended: a free tool, Docker Desktop, on your computer; about 30 minutes of your time once).

## What it is

Every pull request already tests its database rules on a throwaway database. This job does the same for the browser tests: the GitHub check starts a small Supabase inside its own runner, applies the pull request's database changes, points the app at it, and runs every browser test there. Nothing is shared between runs, so parallel jobs cannot collide. After you approve and the job is merged, the shared test project gets the changes and the browser tests run against it once more.

## Done when

Each statement is checked by a test in `tests/checks-workflow.test.ts`, a GitHub run, or a command. New tests carry `[prdb N]`. "The local browser check" is the new check named in statement 1. "Scratch pull requests" are pull requests opened only for proof, never merged, closed and their branches deleted afterwards, with run links in `build.md`.

1. **Pull request browser tests run on a throwaway database.** On every pull request (Dependabot included) and every manual run, the check "Browser tests (Playwright, local Supabase)" starts a local Supabase in its own runner with `supabase start`, excluding every service the app does not use (only Postgres, the API gateway `kong`, `postgrest` and `gotrue` run), applies every migration in the pull request's `supabase/migrations/` from an empty database, builds the app, and runs the full Playwright suite in Chromium and WebKit at 375 x 812 against it. It starts at the same time as the database check and does not wait for it.
2. **That check holds no secret.** Its job text contains no `secrets.` reference (test). The Worker's two settings are the local API address and the local publishable key from `supabase status`, written to `.env.local` on the runner by `scripts/ci/write-test-settings.ts`, which prints names only. `npm run build` (with its built-secrets check) passes with them. The check still keeps its report, screenshots and videos as the `playwright-report` download, which the evaluator uses.
3. **The app in that check really talks to the throwaway database.** After the tests, a `psql` step on the local database shows at least one row in `visits`, and `/api/health` reported `database: reachable` during the run (the existing `[13]` test).
4. **A new table works on its own pull request.** Scratch pull request A adds a migration with a new table (grants written out as the conventions say) and a Playwright test that reads it through the local API. The local browser check is green, while the apply job shows "skipped" and the test project never receives the table.
5. **Parallel runs share nothing.** Scratch pull request B, pushed while A's checks run, adds a different table. Each scratch test also asserts that the other pull request's table does not exist. Both local browser checks are green, and `build.md` shows their run times overlapping.
6. **Local permissions match the test project.** `supabase/config.toml` sets `auto_expose_new_tables = false`, so a new table gets no API access unless its migration grants it, as on the hosted test project. Scratch A adds a second table with no grants, and its test proves the local API refuses it. All existing pgTAP tests still pass unchanged.
7. **Browser test seed data has one home.** Every `supabase/seeds/browser/*.sql` file is loaded, in name order, into the throwaway database after the migrations and before the tests, stopping at the first error; with no files the step logs that none exist. The database check, the apply job and the after-merge check never load them, and `config.toml` seed paths do not include them (tests). A Playwright test that needs seed rows carries the tag `@seed`. Proof: a commit on scratch A with a broken seed file turns the local browser check red at that step.
8. **After merge, the test project is checked as today.** On a push to main, once "Apply database changes to the test project" succeeds, the check "Browser tests against the test project (after merge)" runs the suite with `--grep-invert @seed` against the app pointed at the test project. It is the only browser job that receives `SUPABASE_TEST_URL` and `SUPABASE_TEST_PUBLISHABLE_KEY`, it keeps today's upload guard for them, and it is skipped on pull requests and manual runs. The local browser check is skipped on pushes to main. Proven at merge by the manager, as with job 3's statement 18.
9. **The shared test project still changes only after approval.** The apply job, its `if` line, its queue and its two password lines are unchanged. No other job runs `db push`, `--db-url`, `supabase link` or `migration up` (the existing `[data 18]` test, unchanged).
10. **Preview links on pull requests that change the database.** When a pull request adds, changes or deletes a file under `supabase/migrations/` compared with its base branch, the preview job still uploads the preview and posts the link, but runs only tests tagged `@preview` (the Cloudflare Access lock tests, which get that tag), and the pull request comment adds this text: "This pull request changes the database. The preview uses the shared test project, which gets these changes only after you approve the job, so screens that need them do not work on this link yet. The browser tests ran on a throwaway database with the changes; their videos and screenshots are in the playwright-report download of this run: <run link>." When no migration changes, the preview job runs the suite with `--grep-invert @seed`, as today. Tests pin both branches; scratch A shows the first, this job's own pull request the second.
11. **Tests whose premise changed are replaced, none weakened.** Three tests assumed pull request browser tests use the test project: `[smoke 11] the browser tests wait for the test project to be updated` moves to the after-merge check unchanged in substance; `[data 18] on a pull request the browser tests run once the database tests pass` and `[data 18] the app, the Worker and the browser tests use only tables already on the test project` are replaced by `[prdb]` tests for statements 1, 2, 8 and 10. `build.md` lists each with the reason. Every other existing test passes unchanged, including "3 third-party actions" (no new action; the same pinned `supabase/setup-cli` is reused).
12. **The docs say how it works.** README sections "Database changes" and "Preview links", the "Checks and where they run" table in `docs/conventions.md` plus two convention lines (seed files live in `supabase/seeds/browser/` and never reach a hosted database; a test that runs against the test project never depends on its row counts or on rows another run wrote), and the paragraph in `docs/data-model.md` that says how changes reach the test project.
13. **Costs stay at €0 and minutes are measured.** No paid service. `build.md` reports the local Supabase start time and the billed minutes per pull request run, per job. If a full pull request run passes 20 billed minutes (today about 14), `build.md` says so plainly.
14. **Only if owner's call 1 is B: the evaluator can run it on your computer.** With Docker Desktop running, one npm script (the builder names it, listed in the README) starts a local Supabase for the current worktree, applies its migrations and browser seed, builds and serves the app at `http://localhost:4173` against it, and stops and discards it afterwards. It never opens or changes `.env.local` (its file hash is the same before and after). If another local Supabase is already running, it refuses with one line saying which one, so two evaluators never share a database. Proof: a visit saved through the served app appears in the local database.
15. **All checks are green** on this job's pull request.

Product rules from `AGENTS.md` that apply: agents use only the test database (the throwaway database is local to a runner and holds no learner data); no keys in code, commits, logs or chat; never delete or weaken a test (statement 11 records each replacement); no placeholders (the seed loader runs today and logs zero files); third-party actions pinned to a full commit.

## Decision

| Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|
| Where pull request browser tests get their database | A local Supabase started by the CLI in the browser check's own runner | Supabase Branching (a hosted database per pull request) | Not included in the Free plan; needs Pro "from $25/month" plus "$0.01344 per branch, per hour", and a Supabase access token in GitHub with power over every project. Offered as owner's call 1 C |
| Second runner up | | A second free hosted project shared by all pull requests | Parallel pull requests would change one shared database, which is the race this job removes. The Free plan has a "Limit of 2 active projects" |
| One browser check or two | Two: a local check for pull requests and manual runs, a test project check after merge | One check with steps switched by event | Two jobs let a test prove the pull request check references no secret at all |
| Which services start | Postgres, `kong`, `postgrest`, `gotrue` (`supabase start -x` with the other nine names the CLI accepts) | The full stack | Studio, storage, realtime, edge functions and logging are unused and add start time. Auth is kept because job 8 adds guest sign in. A job that needs another service removes its name from the list |
| Order with the database check | In parallel | Wait for the database check | Waiting adds about 2 minutes to every pull request. A broken migration fails both checks at their start step anyway |
| How the preview knows a pull request changes the database | A three-dot git diff of `supabase/migrations/` against the base branch | Compare with the test project's migration list | That needs the database password, which only the apply job may hold |
| Seed data for browser tests | Explicit `psql` loop over `supabase/seeds/browser/` in the local browser check only | `config.toml` seed paths | Seed paths run on `supabase start` and `db reset`, and possibly on the database check's start too, which would change what the pgTAP tests see. An explicit step is visible and testable |
| Local default permissions | `auto_expose_new_tables = false` | Leave the CLI default | The CLI's own comment says an unset value "falls back to `true`", while new hosted projects give the API roles no access (lesson from job 2). Explicit removes the doubt |

Supabase's own CI guide uses the same CLI in GitHub Actions (`supabase db start`, `supabase test db`). The local stack "mints its own keys", which grant nothing on a hosted project.

## Out of scope

- Loading any seed or made-up content into the shared test project, and what preview links show before real approved content exists. Job 8 needs this settled; it goes to the manager as an open item.
- Supabase Branching, unless owner's call 1 is C (the manager then sends this spec back for a new preview section).
- A deploy for main, a second Cloudflare account, a GitHub Environment for the password, a narrower Cloudflare key, Docker image caching, self-hosted runners.
- Skipping the checks on manager pushes that change only `factory/` and `recording/` (see Risks; a separate decision for the manager).
- Changing the database check, the apply job, `keep-test-db-awake.yml`, any migration, any pgTAP test, the app or the Worker.
- Anything on the PRD's "Not in v3.0" list. This job builds no learner feature.

## Build plan

1. **Local browser check.** The new job, the local settings, the seed loader, `config.toml` parity, the `@seed` and `@preview` tags, the replaced and new workflow tests. Covers 1, 2, 3, 6, 7, 11.
2. **After-merge check and preview.** Move the test project run behind the apply job; the migration diff, `@preview` only run and comment text in the preview job. Covers 8, 9, 10.
3. **Scratch proofs.** Scratch pull requests A and B pushed together, the broken seed commit, then close and delete both. Covers 4, 5, 6, 7, 10.
4. **Docs and minutes.** README, conventions, data model note, minutes in `build.md`. Covers 12, 13, 15.
5. **Only if owner's call 1 is B.** The local evaluator script and its proof on your computer. Covers 14.

Milestones 1 to 4 do not wait for owner's call 1. The manager should merge this job before job 7 or 8, because their pull requests add migrations and cannot pass browser tests until it is on main.

## Risks and flags

- **Secrets and the test database flow (look closely).** This job moves the test project settings out of the pull request browser check and changes which jobs run against the test project. Faster mode then calls for both reviewers. Threat note: the worst case is a pull request run that reaches or changes the shared test project; the job keeps the password in the apply job only, adds no secret anywhere, and the pull request browser check holds none (statement 2). The local database binds to the runner's own address and is never opened to the internet; the system must refuse any tunnel to it.
- **Local and hosted can differ.** The CLI's Postgres, PostgREST and Auth versions may not match the hosted project's. A pull request can pass locally and fail after merge; the after-merge check catches it, and main then shows red until fixed.
- **Running costs: GitHub minutes.** Still €0. Each pull request run gets a second Supabase start (estimate 1 to 2 minutes, measured in statement 13), and each scratch proof run costs about 15 minutes. GitHub Free includes 2,000 minutes a month for private repositories, then $0.006 a minute on Linux. Bigger than this job: every manager push to main today runs the full checks (about 14 minutes) even when it changes only factory files, and parallel mode makes many such pushes. This month's minutes used were not checked.
- **Preview links show less for database jobs.** See owner's call 1. The evaluator otherwise judges new database parts from recorded test videos only.
- No learner data, recordings, consent or Finnish learning content is touched. Seed files added by later jobs will hold made-up rows that never reach a hosted database.

## Owner's calls

**1. How should the evaluator (and you) see a job's new database parts before you approve it?** After this job, those parts work in the browser tests but not on the preview link, because the shared test database gets them only after your approval.

- **A. Recorded proof only.** The evaluator watches the videos and screenshots of the browser tests on the throwaway database and clicks through the rest on the preview link. €0, no setup. The evaluator then mostly checks the builder's own tests, which weakens its role as an independent tester for jobs 8 to 11.
- **B. Docker Desktop on your computer.** The evaluator starts the job's own throwaway database on your computer and clicks through everything (statement 14). Docker Desktop is free for businesses under 250 employees and under $10 million revenue. About 30 minutes of your time once (my estimate): install, admin rights, likely a restart. It uses memory and disk while running; evaluators take turns. Builders could also run database tests locally.
- **C. Supabase Branching.** Every pull request gets its own hosted database and a fully working preview link you can open on your phone. Supabase Pro from $25 a month plus $0.01344 per hour per open branch, and a Supabase access token stored in GitHub. A paid service, so yours to decide.
- **Recommendation: B.** It keeps the evaluator independent at no cost. A applies until Docker is installed. C becomes cheaper to reconsider at liftoff, when the live project moves to a paid plan anyway.

## Could not verify

- The variable name `supabase status -o env` uses for the local publishable key in CLI 2.121.0 (the docs list only `ANON_KEY`, `SERVICE_ROLE_KEY` and `JWT_SECRET`; the API keys page says `supabase start` prints a publishable key). The builder confirms from the output names only.
- That local `kong` accepts the publishable key for `/rest/v1` and `/graphql/v1`, and that `gotrue` starts with `mailpit` excluded.
- That the Worker inside `vite preview` can call `http://127.0.0.1:54321` on the runner.
- The CLI 2.121.0 default for `auto_expose_new_tables` (the config comment and job 2's release note disagree); statement 6 makes it explicit either way.
- The local start time, and what GitHub does for this account when the 2,000 minutes run out.
- How Branching would pass each branch's address and key to the preview Worker (option C only).
- Docker Desktop's disk and memory use and install time on your computer.

## Sources

- Owner decision and open item: `factory/jobs/3-data-model/summary.md`; current workflow `.github/workflows/checks.yml`; tests `tests/checks-workflow.test.ts`; minutes per job `factory/jobs/3-data-model/build.md`
- `supabase start` flags, `-x` names, `--ignore-health-check`: https://supabase.com/docs/reference/cli/supabase-start
- `supabase status -o env` names: https://supabase.com/docs/reference/cli/supabase-status
- Local stack keys ("A local stack mints its own keys", publishable and secret key printed by `supabase start`): https://supabase.com/docs/guides/api/api-keys
- Supabase CI testing with GitHub Actions: https://supabase.com/docs/guides/deployment/ci/testing
- Supabase pricing (Branching not in Free, $0.01344 per branch hour, Pro from $25, 2 active free projects): https://supabase.com/pricing.md
- Branching billing: https://supabase.com/docs/guides/platform/manage-your-usage/branching
- GitHub Actions billing (2,000 included minutes on Free, $0.006 per Linux minute): https://docs.github.com/en/billing/concepts/product-billing/github-actions
- Docker Desktop licence (free under 250 employees and $10 million revenue): https://docs.docker.com/subscription/desktop-license/

Result: ready for owner approval
