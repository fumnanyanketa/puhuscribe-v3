# Job 1-stack: Stack & architecture

Scope item 1. Needs a decision. Date: 19 October 2026.

## What it is

This job picks the tools PuhuScribe v3 is built with and sets up the empty app so it runs on your computer and online. It copies the parts of the old PuhuScribe (v2) that already work and have tests: the review scheduler, the answer grader, the Finnish word checker and the colour palette. It also switches on the safety net the factory needs: automatic checks on every change, a separate test database in the EU, and a private preview link for every branch.

## Done when

Each statement is checked by a command or by opening a link. "The app" means the new repository, not v2.

1. **Stack recorded.** This spec's Decision section lists every load bearing choice with the pick, the runner up and why the runner up lost. `README.md` has a short stack table that links to this spec.
2. **Boots locally.** On a fresh clone on Windows, `npm ci` then `npm run dev` serves the app at a localhost address. The page loads with no console errors, and `http://localhost:<port>/api/health` returns JSON from the app's own server code (the Cloudflare Worker), not a static file.
3. **Builds.** `npm run build` exits with code 0 and produces the browser files and the Worker bundle.
4. **Code checks pass locally.** `npm run typecheck` (TypeScript strict), `npm run lint` and `npm run format:check` each exit with code 0.
5. **Scheduler and grader imported, their own tests pass.** `src/lib/fsrs/algorithm.ts`, `scheduler.ts`, `types.ts`, `fsrs.test.ts`, and `src/lib/grade.ts`, `grade.test.ts` are copied from v2 at a recorded commit. `npm test` runs all 16 scheduler tests and all 8 grader tests and they pass. A diff against v2 shows the two test files unchanged; any change to engine code is limited to import paths and is listed in `docs/v2-imports.md`.
6. **Finnish word checker imported, its own tests pass.** `scripts/generate/voikko_gate.py`, `generate.py`, `allowed_vocab.py`, `test_voikko_gate.py`, `README.md`, `scripts/requirements.txt` and `data/finnish_frequency_lemmas.json` are copied from v2 at the same recorded commit, at the same relative paths. In the GitHub check (Linux with `libvoikko1` and `voikko-fi` installed), `pytest scripts/generate` runs all 9 tests and they pass, with no API key set and no network call to an AI provider.
7. **Palette imported.** `src/styles/tokens.css` contains v2's colour palette custom properties with their values unchanged (subject to owner's call 3). It contains no font imports and no glass, orb or glow tokens. The page uses at least one palette token.
8. **Keys never reach the browser.** The app's server code serves every `/api/*` route from the same address as the page. A test fails the build if any built browser file contains a known secret name or key pattern, and a check fails if any variable whose name contains `KEY`, `SECRET`, `TOKEN` or `PASSWORD` starts with `VITE_` (Vite ships `VITE_` variables to the browser). `/api/*` responses never send `Access-Control-Allow-Origin: *`.
9. **Secrets have one home.** `.env.example` lists every variable name with a one line purpose and no values. `.gitignore` covers `.env.local`, `.dev.vars*`, `.wrangler/`, `dist/`, `playwright-report/`, `test-results/` and `.venv/`. A gitleaks scan of the full git history passes.
10. **GitHub checks run on a pull request.** Opening this job's pull request runs one workflow with these checks, all green: type check, lint, format, unit tests (Vitest), Python tests and Python lint (pytest, ruff), browser tests (Playwright on Chromium and WebKit at 375 x 812, against the built app with its Worker), secret scan (gitleaks), dependency check (`npm audit --audit-level=high` and `pip-audit`). The browser test opens the page and calls `/api/health`.
11. **The checks can fail.** A scratch branch that adds a fake key shaped string makes the secret scan go red. A scratch branch that breaks one scheduler test makes the unit test check go red. Both scratch branches and their pull requests are deleted afterwards, and the red runs are linked in the build notes.
12. **Private preview link per branch.** After the checks pass on a branch, the workflow uploads a version of a Worker named `puhuscribe-preview` with a readable alias made from the branch name, and posts the link on the pull request. Opening the link in a private browser window shows a Cloudflare Access sign in, not the app. After signing in with the owner's email, the app loads. The evaluator can open it with an Access service token.
13. **The app reaches the Supabase test project.** A Supabase project named `puhuscribe-test` exists in a specific EU region (Central EU, Frankfurt, `eu-central-1`), not the "Europe" general region. `/api/health` reports the database as reachable after a real request to that project, both locally and on the preview link. The browser test in statement 10 asserts this.
14. **Agents only hold test credentials.** `.env.local`, the GitHub secrets and the `puhuscribe-preview` Worker secrets contain only test project values. None of them holds a live project key or a Supabase personal access token (which would reach every project on the account).
15. **The test project stays awake.** A daily scheduled GitHub workflow makes one request to the test project so the free plan does not pause it for inactivity.
16. **No new running costs.** Every service used is on a free plan. `README.md` has a "Running costs" list with each service, its plan and its current cost (€0).

Product rules from `AGENTS.md` that apply: no placeholders or fake data in the app; never delete or weaken a test; no keys in code, commits, logs or chat; agents use only the test database; never edit v2.

## Decision

### Where v2 actually is

`AGENTS.md` says v2 lives at `C:/Users/fumna/dev/echoscribe-v2`. That folder is a different product: EchoScribe, a Windows dictation app (Tauri, Rust). It has no scheduler, grader or Voikko code. The real PuhuScribe v2 is the public GitHub repository `fumnanyanketa/puhuscribe-v2`. The builder clones it read only into a folder outside this repository and records the commit hash it copied from in `docs/v2-imports.md`.

### What gets imported, and how hard it is

| Engine | v2 files | Its tests | Depends on | Verdict |
|---|---|---|---|---|
| Review scheduler (FSRS-5, 19 weights, hand written) | `src/lib/fsrs/algorithm.ts`, `scheduler.ts`, `types.ts` | `src/lib/fsrs/fsrs.test.ts`, 16 tests | Nothing outside the folder. Vitest. Imports use `.js` suffixes, so TypeScript needs bundler style module resolution | Easy. Copy as is |
| Answer grader (Levenshtein, tolerance about 12 percent of answer length) | `src/lib/grade.ts` | `src/lib/grade.test.ts`, 8 tests | `./fsrs/types` (the `Rating` enum). Keep the same relative folder layout | Easy. Copy as is |
| Finnish word checker (Voikko gate) and drafting loop | `scripts/generate/voikko_gate.py`, `generate.py`, `allowed_vocab.py`, `README.md`; `scripts/requirements.txt`; `data/finnish_frequency_lemmas.json` | `scripts/generate/test_voikko_gate.py`, 9 tests, uses real Voikko, no mocks | Linux packages `libvoikko1` and `voikko-fi`; Python packages `libvoikko`, `wordfreq`, `anthropic`, `pytest`. `allowed_vocab.py` hard codes the data path two folders up, so the folder layout must match v2. `generate.py` calls the Anthropic API directly with structured outputs; without a key it falls back to an offline stub that deliberately invents words | Harder than expected. Voikko does not run on Windows the documented way, so these tests run in the GitHub check (Linux) and, optionally, in WSL on the owner's machine |
| AI proxy that keeps keys out of the browser | `workers/tts/src/worker.js`, `wrangler.toml`, `.github/workflows/deploy-tts-worker.yml` | None | Azure Speech, Anthropic API, a Voikko sidecar, Resend | Do not copy the code. It has no sign in check, allows every website (`Access-Control-Allow-Origin: *`), has no rate limit and no tests, and most routes serve features on the "Not in v3.0" list (islands, open conversation, reading). Carry the pattern only: keys live only as Worker secrets; the browser calls the app's own `/api/*`; text to speech results are cached with the Cache API |
| Design tokens | `src/styles/tokens.css`, about 160 lines | None | Imports Poppins (Google Fonts) and Switzer (Fontshare); defines glass and orb gradient tokens | Copy the colour palette values only (PRD 7.2 says "reuse palette tokens"). Fonts, glass, orb and shadows are left out: they clash with the owner's banned style list and belong to job 4 |

Not imported, on purpose: `streak.ts` and `milestones.ts` and their tests (streaks and milestones are on the "Not in v3.0" list), `topic_plan.py` and `run_batch.py` (YKI topic batches, out of v3.0), `to_seed_sql.py` and `test_seed_sql.py` (they write v2's database tables, which v3 replaces in job 3), `services/voikko/` (runtime checking is v3.1 per PRD 7.3).

The PRD says the scheduler has "44 tests". The v2 repository has 16 scheduler tests and 8 grader tests. The 44 likely counted every TypeScript test in v2, including streak and milestone tests. The builder must not invent tests to reach 44.

### The stack

| Layer | Pick | Runner up | Why the runner up lost |
|---|---|---|---|
| Frontend | React 19 + Vite 8 + TypeScript strict, as a single page app (PRD 7.3) | Next.js | Its main strengths need a server runtime. The app sits behind a session, so search engines matter only for the landing page (job 15), which can be a static page. The PRD names Vite |
| Hosting for the app and its API | One Cloudflare Worker serves the built app as static assets and runs `/api/*` (`assets.not_found_handling = "single-page-application"`, `run_worker_first = ["/api/*"]`) | Cloudflare Pages plus a separate Worker | Cloudflare's Pages docs say "Start new projects with Workers". One Worker means one deploy, one preview link covering app and API, and no cross site requests. Vercel (PRD's pick) lost earlier: its free plan forbids commercial use and Pro is $20 a month (factory plan, Note on Vercel) |
| Scaffold | `npm create cloudflare` React template (Vite + Cloudflare Vite plugin + Wrangler) | `npm create vite` plus manual Wrangler setup | The template wires local dev of app and Worker together in one `npm run dev`, which is the documented path |
| Preview links | GitHub Actions runs `wrangler versions upload --preview-alias <branch>` on the `puhuscribe-preview` Worker after the checks pass. Cloudflare Access (Zero Trust free plan, up to 50 users) guards it | Cloudflare Workers Previews (`wrangler preview`), which gives each branch its own secrets | Previews launched on 22 September 2026 as an open beta (secondary sources; the official page shows no status label). Boring stack rule. Version aliases are documented and stable. Revisit Previews when it is generally available. Workers Builds (Cloudflare's own git integration) also lost: keeping checks and previews in one GitHub workflow means a preview only appears after the checks pass |
| Separating test from live | `puhuscribe-preview` Worker holds test project secrets only. The production Worker and the live database are created at liftoff, by the owner, and agents never get their keys | Wrangler environments on one Worker with live and test secrets side by side | Keeping live keys in a separate Worker that agents never deploy is the simplest way to meet "agents only use the test database" |
| Database, sign in, access rules | Supabase (Postgres, Auth, row level security on every table), specific region `eu-central-1` Frankfurt (PRD 7.3) | Neon Postgres plus a separate sign in service | v2 data and the PRD are on Supabase; row level security and auth come built in. Stockholm (`eu-north-1`) is closer to Helsinki but the PRD names Frankfurt and test and live should match |
| Database environments | Hosted `puhuscribe-test` project for local runs and previews. From the smoke test on, database security tests run against a throwaway local Supabase started by the Supabase CLI inside the GitHub check (`supabase start`, `supabase test db`) | Run every test against the hosted test project | Shared test data makes parallel checks interfere. The local stack is isolated and free, and Supabase documents it for GitHub Actions |
| Package manager and runtime | npm, Node 24 LTS | pnpm; Node 26 | v2 uses npm, so one less tool. Node 26 is listed as "Current", not LTS, on nodejs.org today |
| Unit tests | Vitest | Jest | v2's engine tests are written for Vitest and run unchanged |
| Browser tests | Playwright, Chromium and WebKit, phone size 375 x 812, screenshots and video kept | Cypress | WebKit is the closest stand in for iPhone Safari, which matters for this app. The factory plan and evaluator already name Playwright |
| Lint and format (TypeScript) | ESLint (flat config) with typescript-eslint type checked rules, react-hooks and jsx-a11y plugins; Prettier | Biome | ESLint with typescript-eslint is the established, best documented setup. Biome would be one faster tool and stays an option later |
| Python | Python 3.12, pytest, ruff (lint and format) | black plus flake8 | ruff does both jobs in one tool. v2's pipeline already uses pytest |
| Secret scan | gitleaks via `gitleaks/gitleaks-action` (no licence key needed for personal account repositories) | TruffleHog | gitleaks runs the same way locally and in the check, and is free here |
| Dependency check | `npm audit --audit-level=high`, `pip-audit -r scripts/requirements.txt`, Dependabot version updates | `actions/dependency-review-action` | GitHub's dependency review action needs a GitHub Advanced Security licence on private repositories |
| Finnish word checker hosting | None in v3.0. Voikko runs at content build time in the GitHub check (Linux) and in WSL locally | A hosted Voikko service on Fly or Railway (PRD 7.3) | The PRD puts runtime Voikko in v3.1. No host means no extra account or bill |

### Provisional providers (decision 8 of the factory plan)

These are the MVP's providers until the risk tests run after the MVP. Each one sits behind exactly one module, so a swap changes that module only. The modules are built by the job that first needs them, not by this job (no empty placeholder files).

| Need | Provisional pick | Module (built in) | What is verified today |
|---|---|---|---|
| Install to home screen | Installable web app via `vite-plugin-pwa` (supports Vite 8) | Build config (job 16; Test 1 may switch to a Capacitor wrapper) | Plugin peer range includes Vite 8 |
| Voices (both registers) | Azure Speech neural voices `fi-FI-NooraNeural`, `fi-FI-HarriNeural`, `fi-FI-SelmaNeural`, resource in North Europe (Ireland) as in v2 | `worker/providers/voice.ts` (job 5) | Three standard fi-FI voices exist. Free tier: 0.5 million characters a month. Paid prices could not be read from Azure's page |
| Speaking feedback | Azure pronunciation assessment, locale `fi-FI` | `worker/providers/speech-feedback.ts` (job 8) | fi-FI is one of the 33 supported locales, in every speech to text region. Named phonemes are English (US) only, so Finnish gets scores without phoneme names. Whether the free tier covers it is not stated |
| App AI (drafting, explanations, later the tutor) | Claude through Amazon Bedrock with an EU endpoint (owner's call 1) | `worker/providers/ai.ts` for runtime and one AI client file in `scripts/generate/` for build time (job 5) | Bedrock lists EU endpoints for Claude in Frankfurt, Stockholm, Ireland and other EU regions, with a 10 percent premium over global routing. Anthropic's own API offers only "global" or "us" processing, not EU |

Rules for every provider module: nothing outside the module imports a vendor SDK or calls a vendor URL; the provider is picked by one environment variable; every AI call returns and logs model, tokens and cost.

Two facts job 5 must plan around: v2's `generate.py` asks for structured outputs, and Anthropic's docs say the newer "Claude in Amazon Bedrock" endpoint does not support structured outputs (the older Bedrock integration supports them for some models). Calling Bedrock from a Worker needs AWS request signing; whether the Bedrock SDK runs inside a Worker was not verified.

### Secrets and accounts

| Where | What goes there |
|---|---|
| `.env.local` (git ignored; read by Vite and by Wrangler for local dev) | Test project URL and publishable key, test database connection string. Never a `VITE_` prefix on anything secret |
| GitHub repository secrets | `CLOUDFLARE_API_TOKEN` (Workers edit only), `CLOUDFLARE_ACCOUNT_ID`, `SUPABASE_TEST_URL`, `SUPABASE_TEST_PUBLISHABLE_KEY`, `SUPABASE_TEST_DB_URL`, `CF_ACCESS_CLIENT_ID`, `CF_ACCESS_CLIENT_SECRET` |
| `puhuscribe-preview` Worker secrets | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` (test project) |

Use Supabase's new publishable and secret keys (`sb_publishable_...`, `sb_secret_...`); the old anon and service_role keys are being deprecated by the end of 2026. This job needs no secret key.

What the owner does (the builder gives exact click steps; about 30 to 45 minutes):
1. **Supabase** (existing account): create project `puhuscribe-test`, picking the specific region "Central EU (Frankfurt)". If the free plan's region picker does not offer it, stop and tell the manager. Note: the free plan allows 2 active projects, and v2's project may already use one.
2. **Cloudflare** (existing account): turn on the workers.dev subdomain; create an API token from the "Edit Cloudflare Workers" template; set up Zero Trust on the free plan; add an Access application for the preview Worker's addresses allowing your email; create one service token for the evaluator.
3. **GitHub** (existing account): paste the secrets above into the repository settings.
4. **Not needed in this job:** AWS (owner's call 1), Azure Speech resource (job 5), ElevenLabs and Google Cloud (risk tests).

## Out of scope

- The "Hei!" page and the visits table (the smoke test job), and any database table, migration or access rule.
- The data model, the 104 v2 sentences and IPA data (job 3).
- Fonts, Tailwind, components, the look of any screen (job 4). The palette import is values only.
- Any AI, voice or speech feedback call, and the provider modules themselves (jobs 5 and 8).
- Installable app manifest and offline worker (job 16).
- Production Worker, live database, custom domain (liftoff).
- Git hooks and the `AGENTS.md` conventions section (job 2). This job adds the GitHub checks only.
- Anything from v2 on the PRD's "Not in v3.0" list: streaks, milestones, journey map, islands, YKI topics, mnemonics, separate practice modes, open conversation, the language toggle.
- The hosted Voikko service (v3.1).

## Build plan

1. **Scaffold.** Create the app from the Cloudflare React template on Node 24 with npm; TypeScript strict; ESLint, Prettier, Vitest; `/api/health` in the Worker; `README.md` stack table and running costs. Covers 1 to 4, 16.
2. **Import v2 engines.** Clone v2 read only outside the repo; copy the files in the import table at one commit; record it in `docs/v2-imports.md`; run the TypeScript tests; add ruff and pytest config. Covers 5 to 7.
3. **Secret hygiene and the API pattern.** Same origin `/api/*`, no wildcard cross site header, the built file secret scan test, the `VITE_` name check, `.env.example`, `.gitignore`. Covers 8, 9.
4. **Supabase test project.** After the owner creates it: health check reaches it locally; daily keep awake workflow. Covers 13 to 15.
5. **GitHub checks.** One workflow with all checks in statement 10; prove they can fail with the two scratch branches. Covers 10, 11.
6. **Preview links.** Deploy `puhuscribe-preview` once from main, then alias uploads per branch with a pull request comment; Access in front; Playwright runs the health test against the preview with the service token. Covers 12, 13.

Dependencies: milestones 4 to 6 wait for the owner's account steps above. The repository's GitHub remote exists but has never been pushed to.

## Risks and flags

- **Look closely: database access.** This job creates the test database and decides who holds which key. Agents get only the test project's keys and connection string. A Supabase personal access token reaches every project on the account, live included, so no agent gets one.
- **Look closely: running costs.** Everything is €0 today. Limits to watch: GitHub Free has 2,000 check minutes a month on private repositories, then $0.006 a minute on Linux. My estimate, not measured, is 6 to 10 minutes per pull request run with two browsers, so about 200 runs a month fit. The Supabase free plan pauses a project after 7 days without activity (statement 15 handles this). Workers Free allows 100,000 requests a day; static files are free and unlimited.
- **v2 is still online with open paid routes.** v2's Worker lets any website call its Anthropic and Azure routes with no sign in and no rate limit, and send email through its feedback route. Anyone who finds the address can run up v2's bills. The owner may want to add limits or switch those routes off. This job does not touch v2.
- **Wrong v2 path in `AGENTS.md`.** It points to echoscribe-v2. The manager should propose a corrected line (`github.com/fumnanyanketa/puhuscribe-v2`, read only) for the owner to approve.
- **Learner data and recordings.** None in this job. For job 8: a Worker runs at the Cloudflare location nearest the user, and this research did not confirm a way to pin that to the EU on the free plan. Azure Speech's data handling for real time requests was not checked.
- **Finnish content.** No learner facing Finnish is added. The imported stub generator contains deliberately invented words for tests only. `data/finnish_frequency_lemmas.json` was built from wordfreq data; its licence was not checked against `docs/content-attribution.md` (carry that file forward in job 5).
- **AI region.** v2's `generate.py` calls Anthropic's API directly, which processes in the US or globally. It must only ever run on content briefs, never learner data, until job 5 moves it behind the AI module.
- **Region choice on the free plan.** Supabase's docs do not say whether free projects can pick a specific region. Its "Europe" general region can land in London or Zurich, which are outside the EU, so a specific region is required.
- **Beta avoided.** Workers Previews would give each branch its own secrets but is in open beta. If the alias approach misbehaves, the fallback is Pages previews, not the beta.

## Owner's calls

None of these is decided. Each has a recommendation.

**1. Which service runs Claude for the app's AI.** Needed before job 5, not for this job to finish.
- A. Amazon Bedrock, EU endpoint. A new AWS account. Pay per use with a 10 percent premium for keeping processing in the EU (for example Claude Haiku 5.5 lists at $0.10 per million input tokens and $0.50 per million output tokens before the premium). Learner data stays in the EU from the first call. This is the provider the approved factory plan names.
- B. Google Vertex AI, EU endpoint. Same 10 percent premium. Your Google Cloud account status is unknown, and which Claude models run in its EU regions was not confirmed.
- C. Anthropic's own API for build time content drafting only, then an EU provider when the tutor arrives (job 12). Probably no new account. Not EU processing, which is acceptable only while no learner data is sent, and it means switching providers later.
- Recommendation: A. The few euros of content drafting cost about the same everywhere, and choosing once avoids a switch before the tutor step.

**2. Making GitHub refuse merges until the checks pass.**
- A. Stay on GitHub Free. The checks still run on every pull request; the factory manager checks they are green before merging, and only your `/factory approve` merges. €0.
- B. Upgrade to a paid GitHub plan so GitHub itself blocks a merge with red checks. GitHub's pricing page suggests branch protection on private repositories starts at a paid plan (Team is listed at $4 per user a month); the exact plan for a personal account was not confirmed.
- Recommendation: A. No agent merges on its own anyway, and you approve every merge.

**3. Bringing v2's colours into v3 now.** This is not the design direction; job 4 brings 5 to 10 researched references and you pick the look there.
- A. Import v2's colour values now as the starting palette, as the PRD and scope say. Job 4 can change any value.
- B. Import nothing visual now. Job 4 sets every value from scratch.
- Recommendation: A. It follows the scope wording and costs nothing to replace later.

**4. The live database, decided before liftoff (not now).**
- A. Reuse v2's Supabase project with a new schema, as the PRD says. Free, but v2 testers still use it until v3.1, and the free plan's 2 project limit is then full.
- B. A new live project on Supabase Pro, $25 a month from when real learners arrive. Daily backups, no pausing, v2 untouched.
- Recommendation: B at liftoff. The factory plan already budgets Pro once real learners arrive.

## Could not verify

- Whether the Supabase free plan's region picker offers Frankfurt (docs are silent; check at project creation).
- Workers Previews' official status (only secondary sources say open beta).
- Azure Speech paid prices and whether the free tier covers pronunciation assessment.
- Which Claude models are offered on Bedrock's EU endpoints today, Bedrock's own price page, and whether the Bedrock SDK runs inside a Worker.
- Whether Dependabot alerts are free on private personal repositories, and whether Cloudflare Zero Trust's free plan asks for a payment card.
- The exact GitHub plan and price that enables branch protection for a personal private repository.
- GitHub check minutes per run (estimate only).

## Sources

- Real v2 repository: https://github.com/fumnanyanketa/puhuscribe-v2
- Cloudflare Pages ("Start new projects with Workers"): https://developers.cloudflare.com/pages/
- Workers version URLs and aliases: https://developers.cloudflare.com/workers/configuration/previews/
- Workers Previews: https://developers.cloudflare.com/workers/previews/ and https://flaviocopes.com/cloudflare-worker-previews/
- Workers single page app and API routing: https://developers.cloudflare.com/workers/static-assets/routing/single-page-application/
- Workers pricing: https://developers.cloudflare.com/workers/platform/pricing/
- Wrangler local secrets files: https://developers.cloudflare.com/workers/configuration/environment-variables/
- Cloudflare Zero Trust free plan: https://www.cloudflare.com/plans/sase-zero-trust.md
- Supabase pricing: https://supabase.com/pricing
- Supabase regions: https://supabase.com/docs/guides/platform/regions
- Supabase pausing: https://supabase.com/docs/guides/platform/free-project-pausing
- Supabase API keys: https://supabase.com/docs/guides/api/api-keys
- Supabase testing in CI: https://supabase.com/docs/guides/local-development/testing/overview
- Claude in Amazon Bedrock (regions, structured outputs): https://platform.claude.com/docs/en/build-with-claude/claude-in-amazon-bedrock
- Claude on Bedrock, legacy integration (EU profiles, 10 percent premium): https://platform.claude.com/docs/en/build-with-claude/claude-on-amazon-bedrock-legacy
- Anthropic data residency (global or us only): https://platform.claude.com/docs/en/manage-claude/data-residency
- Anthropic pricing: https://platform.claude.com/docs/en/about-claude/pricing
- Claude in Microsoft Foundry, no EU data zone: https://infoq.com/news/2026/07/claude-foundry-ga-europe/
- Azure Speech language support (fi-FI voices and pronunciation assessment): https://learn.microsoft.com/en-us/azure/ai-services/speech-service/language-support?tabs=pronunciation-assessment
- Azure pronunciation assessment features per locale: https://learn.microsoft.com/en-us/azure/ai-services/speech-service/how-to-pronunciation-assessment
- Azure Speech pricing: https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/
- GitHub Actions billing: https://docs.github.com/en/billing/concepts/product-billing/github-actions
- GitHub pricing: https://github.com/pricing
- gitleaks action: https://github.com/gitleaks/gitleaks-action
- Dependency review action: https://github.com/actions/dependency-review-action
- Node.js releases: https://nodejs.org/en/about/previous-releases
- npm registry versions read today: vite 8.3.4, vitest 5.0.5, typescript 7.0.2, react 19.3.1, vite-plugin-pwa 2.0.0, @cloudflare/vite-plugin 1.64.0

Result: ready for owner approval
