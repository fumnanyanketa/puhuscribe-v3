# House rules for PuhuScribe v3 (AGENTS.md)

Every AI session reads this file first. It is short on purpose. The detail lives in the files it links.

## What this project is

PuhuScribe teaches adult newcomers in Finland the Finnish people actually speak, from A0 to A1. The product source of truth is the PRD at `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`. The feature list is `docs/scope/scope.md`. The build plan is `docs/factory-and-risk-tests-plan.md`. When they disagree, the PRD wins.

The v2 app is the GitHub repository `github.com/fumnanyanketa/puhuscribe-v2`, cloned read only outside this repository when needed. (`C:/Users/fumna/dev/echoscribe-v2` is a different product, a dictation app.) v2's proven engines (review scheduler, answer grading, Finnish word analysis, design token colours) are imported unchanged. Never edit v2 from this project.

## Stack

- React 19, Vite and TypeScript (strict), built as a single page app in `src/`.
- One Cloudflare Worker (`worker/`) serves the built app and every `/api/*` route from the same address.
- Supabase in an EU region for the database, sign in and access rules, defined in code in `supabase/`.
- Node 24 and npm. Vitest for unit tests, Playwright for browser tests (Chromium and WebKit at 375 x 812).
- Python 3.12 for the Finnish content pipeline in `scripts/generate/` (Voikko, pytest, ruff).

The README stack table is the full list. `factory/jobs/1-stack/spec.md` records why each was picked.

## How work happens here

All feature work goes through the factory (`/factory`). Read `.claude/skills/factory/SKILL.md`. The owner, Fumnanya, approves every finished job, and every spec except routine jobs (see parallel mode in the skill). No agent merges to main on its own.

## Product rules (every feature inherits these)

- **Five principles, or it does not ship.** Every feature serves at least one of the principles in PRD section 3.
  - P1. Short dialogues just above the learner's level, never word lists.
  - P2. Spaced retrieval scheduled automatically with no self rating.
  - P3. Task based units tied to an A1 "can do" statement.
  - P4. The learner says it back every session and gets feedback.
  - P5. Spoken Finnish (puhekieli) first, written Finnish (kirjakieli) alongside, both with audio.
- **The PRD's "Not in v3.0" list is binding.** Nothing on it is built in v3.0. These are the items of PRD section 4.1, word for word.
  - Day One Sprint as the front door
  - Vocabulary bank with a 2,000-word target
  - Practice hub as four separate modes (Speak/Listen/Write/Read)
  - Grammar Stage 2 as standalone lessons
  - Sentence Bank / language islands as a top-level surface (→ paid tier, v3.2)
  - Converse tutor "Otso" as a standalone surface (→ appears inside the loop from unit 4; open-ended mode is paid tier)
  - Rank titles, confetti, milestone ladder, journey stage map
  - Bilingual / Finnish-only toggle
  - Mnemonics
  - YKI-specific content and skill tagging
  - Native app store builds (Capacitor path stays documented)
  - Owner Insights dashboard beyond a minimal tester count

  The scope adds one more item, no streaks.
- **One front door, one loop.** Hear it, Understand it, Say it, Keep it, Use it. The learner never picks a mode.
- **Nothing unmet is reviewed.** A form enters review only after the learner met it in a dialogue.
- **Grammar is a card behind a tap.** Corrections are gentle and never shaming.
- **AI at the edges.** AI drafts and explains. It never publishes unchecked content and never decides scheduling or grading. Every AI call is logged with its cost.
- **Nothing unapproved is served.** Every Finnish line a learner sees passed the automatic checks and the native reviewer. Tutor replies are shown, never stored as learnable content.
- **Spoken Finnish means standard spoken Finnish as a Helsinki adult speaks it in 2026.** No dialects.

## Privacy rules

- GDPR applies. Collect the minimum, explain why, allow export and deletion. No users under 18.
- Learner data and voice recordings stay in the EU. Audio is discarded by default.
- Agents only ever use the test database. Never the live one.
- No keys, tokens or passwords in code, commits, logs or chat. They live in `.env.local` (git ignored) and GitHub secrets.

## Build rules

- No placeholders, fake data in the app, or "TODO: implement" left in finished work.
- Never delete or weaken a test to make it pass. If a test is wrong, say so in the job notes.
- Voice, speech feedback and AI providers each sit behind one module, so a provider can be swapped by changing that module only. The risk tests may change providers after the MVP.
- Client facing text is English unless the owner says Finnish. Finnish learning content is its own thing and always goes to the native reviewer.

## Conventions

Detail, with a real example file for each, is in [docs/conventions.md](docs/conventions.md).

- **Folders.** App in `src/` (shared code in `src/lib/`), Worker and API in `worker/`, browser tests in `e2e/`, repository tests in `tests/`, Node scripts in `scripts/`, database in `supabase/`.
- **Names.** kebab-case TypeScript files, PascalCase React components, unit tests next to the code as `*.test.ts`.
- **Test labels.** Every test name carries `[<job label> N]` for the "Done when" statement it protects.
- **Database.** Every migration revokes all access from the API roles, grants only what the spec allows, turns on row level security, and has pgTAP tests (SQL tests of what each role may read and write) in `supabase/tests/database/`.
- **Providers.** Voice, speech feedback and AI each sit behind one module in `worker/providers/`. The browser calls only `/api/*`.
- **Secrets.** Only in `.env.local` and GitHub secrets. Never read, search or print `.env*` files; use `git grep`.
- **Fonts.** The Switzer font files are not in git (the licence forbids public repositories). `scripts/ci/fetch-private-fonts.ts` fetches them when a key is set, and tests that need them skip with a reason when they are absent (`docs/fonts.md`). Never commit the files.
- **v2 files** stay unchanged and hash checked (`docs/v2-imports.md`).
- **Checks.** `npm run check:code` runs the type check, lint and format check. GitHub runs every check on every pull request.
- **Before every commit**, lefthook (a git hook manager, configured in `lefthook.yml`) runs those checks on the staged files, plus ruff (Python lint) and gitleaks (a secret scanner).
- **When a builder agent stops**, `scripts/hooks/stop-checks.ts` checks the factory worktrees.

## Project rules

- **GA features** (general availability, marked `"ga": true` in `factory/features.json`). The spec answers three threat model questions. What is the worst thing a malicious person could do here? What data are we storing that we must protect? What should the system refuse to do even if asked nicely? The job is done only when `summary.md` records the owner's own written "approved" line with the date.
- **Evidence folder.** Proof lives in `factory/jobs/<job-id>/evidence/`. It is never deleted and never holds a secret.
- **Debug triage.** Before fixing anything broken, say which of three kinds it is.
  - **A real bug.** Reproduce it, prove the cause from evidence, make the smallest fix, and add a test that fails without the fix.
  - **A confused session.** Stop and start a fresh one.
  - **A wrong earlier decision.** Stop and send it back to the spec. Do not patch around it.
- **Output style.** Plain short sentences. Explain a technical term the first time you use it. Report in a few lines. The writing rules below apply.
- **Never skip the checks.** No `git commit --no-verify`, no `LEFTHOOK=0`, no editing a check to make it pass. If a check is wrong, say so in the job notes.

## Writing rules (app text, docs, summaries)

Plain, direct English. No em dashes, and no hyphens used as punctuation. No colon reveals such as "Here's the thing:". No habitual groups of three, such as three adjectives or three bullets every time. No "not X, but Y" framing, no hype words (seamless, unlock, elevate, empower, supercharge, game-changer, cutting-edge, effortless). Summaries for the owner explain consequences, not code.

## Lessons learned

The factory adds one line here for every mistake a reviewer, the evaluator or the owner caught, so it does not happen again.

- Test debug files (Playwright traces, HAR files, HTML reports) record request headers. Never keep them while a secret header is set, and scan every file for secret values before any upload. (1-stack, security review)
- A test meant to act as a stranger must clear any headers the test config adds for everyone, and should assert no pass was sent. (1-stack, builder)
- Never choose an email address for the owner. Ask which one to use, every time. (1-stack, owner)
- Supabase's free plan offers only broad regions such as "Europe", not a specific city; check the assigned country is in the EU. (1-stack, owner setup)
- When a check fails, find the cause from evidence before reporting one. A guess about timing was wrong; the cause was a test bug. (1-stack, manager)
- Cloudflare's "Workers Scripts: Edit" permission also covers Access application edits, so a Workers key can change login locks. (1-stack, manager)
- Never search, grep or print files matching .env*. Job worktrees hold a copy of .env.local, and a broad search printed a database password. Use git grep or exclude .env*. (2-smoke, security review)
- New Supabase tables give the API roles no access by default (since May 2026). Write every grant and revoke out in the migration, and test them. (2-smoke, spec)
- Pin third-party GitHub Actions that receive secrets to a full commit SHA, with the version in a comment. (2-smoke, security review)
- In the Workers runtime, read (and cap) a request body before answering, or the next request on that connection can fail locally. (2-smoke, builder)
- Browser features new since 2022 (such as AbortSignal.timeout) need a fallback; learners use older phones. (2-smoke, design review)
- A test can pass for the wrong reason. Prove each protection by breaking it on purpose and watching its test go red, and make sure no other rule can refuse the same action. (3-data-model, evaluator)
- When approved content is withdrawn, clear its approval; going live again needs a new reviewer reference. (3-data-model, evaluator)
- Database types must be the Supabase CLI's exact output, never written by hand. (3-data-model, builder)
- Keep earlier rounds in build.md in a short section; overwriting them lost proof links. (3-data-model, evaluator)
- Two Postgres read rules that look at each other loop forever; enforce such rules at write time instead. (3-data-model, builder)
- After a merge, do not push to main until the merge run has finished: the checks cancel an older run on the same branch, which cancelled the first database apply. (3-data-model, manager)
- An error message must only claim what happened: a missing tool printed "found a secret". Tie each message to its cause. (4-tooling, evaluator)
- A path check that only looks for slashes misses top folder files; test the files you name. (4-tooling, evaluator)
- After merging a job that changes the commit check, run npm ci in the main folder before removing its copy, or main refuses commits. (4-tooling, builder)
- Before researching a design direction, ask the owner what they already have; two hours of research ended at v2's design. (5-design-system, owner)
- Before asking the owner to choose anything visual, show one overview naming each picture and how they fit. (5-design-system, owner)
- Put evidence file names in backticks; the secret scanner read bare names as a key. (5-design-system, manager)
- The browser's default button style fails contrast in WebKit dark mode; give every button token colours. (5-design-system, evaluator)
- A log filter dropping lines containing "key" misses a key labelled "Publishable" and hides errors like "duplicate key value". Filter by value shape and test realistic rows. (6-pr-local-db, security review)
- A reviewer's page must let them say "not yet, fix these" and still send their file without a false approval. Test every non-approving path. (7-content-pipeline, design review)
- Boxes showing Finnish must wrap long compound words (`overflow-wrap: anywhere`); test a 40 letter word at 375 px. (7-content-pipeline, design review)
- Playwright's WebKit drops Secure cookies on http://localhost, so tests of a Secure sign in cookie need a local HTTPS server (self signed). (8-first-session, builder)
- A database rule with several conditions needs one failing test per condition, or a test passes for the wrong reason. Remove each condition and watch only its test go red. (8-first-session, evaluator)
- Windows turns line endings into CRLF unless `.gitattributes` says otherwise; each new top level text folder needs an `eol=lf` line, and only a fresh clone plus `npm run check:code` proves Windows. (13-review-site, evaluator)
- With a GitHub Actions allow list, list every pinned action, including ones another action pulls in, or checks fail to start. (public repository move, manager)
- Warn the owner of any running cost or limit, with a number, at the first sign, and never pause a promised step like the video recording silently. (public repository move, owner)
- This file has a 2,200 word test; count words before adding a lesson and trim an unpinned line. (9-daily-review, manager)
- A failure in one browser only can be a real bug: a late timer sent a recording over the 10 second cap. Fix, do not re-run. (10-speaking-feedback, manager)
