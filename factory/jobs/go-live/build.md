# Build notes: go-live

Branch `factory/go-live`, worktree `.worktrees/go-live`, pull request https://github.com/fumnanyanketa/puhuscribe-v3/pull/41 (not merged). Round 1 commits: `94726d5` (app changes) and `253a911` (the Live workflow and its checks). Round 2 (this round): the rework after `review-security.md`, in the commit that adds these notes to the branch.

There is no `spec.md` for this job. The manager's brief (4 November 2026) is the spec. Its items are numbered here, and the tests carry those numbers as `[go-live N]`:

1. A manual-only workflow, main only, with separate jobs: apply migrations to the live project, publish the approved content, build and deploy the production Worker.
2. App changes for production: the `__Host-` sign in cookie, the landing page address, Brevo in the privacy notice.
3. Turnstile accepts tokens from meetaleksi.com.
4. These notes.

## Round 2: what changed after the security review

The owner decided on 4 November 2026 that the zone `meetaleksi.com` and the Worker `aleksi` move to the owner's separate Exentrik Cloudflare account. The previews stay on the current account with the token `puhuscribe-ci`.

- **GitHub environment `live`** (review finding 1). The jobs `migrations`, `content` and `app` in `.github/workflows/live.yml` now declare `environment: live`, so they get the live secrets only from that environment. The manager creates the environment (main only, the owner as required reviewer, administrators may not bypass) and the owner moves the secrets into it. I changed no repository setting. The check job "Approved content (no secret)" holds no secret and has no environment.
- **Separate Cloudflare account for live** (review finding 2). The `app` job deploys with `CLOUDFLARE_LIVE_API_TOKEN` and `CLOUDFLARE_LIVE_ACCOUNT_ID` from the `live` environment. They are handed to wrangler under the names it reads (`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`) in the deploy step only. The workflow never names the preview token, the preview account id or the review site's token, and it stops without deploying when either live value is missing (no falling back to an account guessed from the token).
- **Privacy notice region** (review finding 3). The live project is in Frankfurt, Germany (`eu-central-1`). The Supabase entry now says "In the EU (Germany)." (`src/privacy/processors.ts`), with the first layer's claim source (`src/privacy/first-layer.ts`) and the tests that pin the text. "Ireland" stays only where it is true and learners never read it as the database's place: the README's line about the test project, Anthropic's company name and the Azure speech region names. The notice date stays 4 November 2026 (the same day as round 1).
- **Turnstile test secrets refused on live** (review finding 4). `humanCheckKeys` in `worker/providers/human-check.ts` now returns no keys when the Worker holds one of Cloudflare's published test secrets and the address is not local, a `workers.dev` preview or a name reserved for tests (`.example`, `.test`, `.invalid`, which can never be a public site and which the unit tests use). On `meetaleksi.com` that means no check at all and no guest (503, as when the keys are missing), never a check that passes every token. Written test first: it failed on the old code, then passed.
- **Live Anthropic and Azure keys** (review finding 5). Because the `app` job runs in the `live` environment, an environment secret named `ANTHROPIC_API_KEY`, `AZURE_SPEECH_KEY`, `TURNSTILE_SITE_KEY` or `TURNSTILE_SECRET` replaces the repository secret of the same name. The owner may add separate live keys there later (an Anthropic workspace with its own spend limit, an Azure Speech resource in an EU region, a live-only Turnstile widget with only `meetaleksi.com` in its hostnames); no file needs to change. Until then live uses the shared keys, which branch code on the preview account can also read. The Azure region and tier are GitHub variables (`vars.`); environment variables of the same name override them the same way.
- **Workflow comments** (review finding 7). The header now says what each job really holds: the database password also reaches the settings check (no packages installed in those jobs), and in `app` package code runs earlier in the job than the deploy step that holds the secrets. I did not add `npm ci --ignore-scripts`; that is an untested change to how the build installs.
- **Review site deploy in its own environment** (manager's addition, 4 November 2026). The Exentrik account also holds the review site, deployed by `.github/workflows/review-site.yml` with `CLOUDFLARE_REVIEW_API_TOKEN`, which can edit every Worker in that account, `aleksi` included. Its `deploy` job now declares `environment: review`, so the token is read from that environment. The secret names are unchanged (`CLOUDFLARE_REVIEW_API_TOKEN`, `CLOUDFLARE_REVIEW_ACCOUNT_ID`), so no other line of the workflow changed. Once the environment requires the owner's approval, every review site deploy (a push to main that touches the site) waits for that click too. `docs/content-pipeline.md` says where the token lives. A test pins it like the live one.
- Not changed in this round: finding 6 (Brevo tracking and log retention) needs the owner's Brevo dashboard and Brevo's own terms, and finding 8 (old preview cookies) needs no change for live. Both stay on the checklist below.

## What the job builds, in plain English

- **A Live workflow** (`.github/workflows/live.yml`). Nothing reaches the live app on a push or a pull request. The manager starts it by hand on main and picks one task per run. Each live task then waits for the owner's approval in the `live` environment.
- **A production Worker config.** `wrangler.jsonc` keeps the preview Worker at the top level and gains a `production` environment: the Worker `aleksi`, on `meetaleksi.com` and `www.meetaleksi.com`, with no workers.dev address and no preview addresses, so no Cloudflare Access application covers it. Only a build with `CLOUDFLARE_ENV=production` uses it, and only the Live workflow does that. Which Cloudflare account it lands in is decided by the token and account id, now the Exentrik account's.
- **www goes to the apex.** On the live Worker, any page or `/api/*` request on `www.meetaleksi.com` gets a permanent redirect to the same path on `meetaleksi.com` (`worker/canonical-host.ts`). Files such as pictures and scripts are served by Cloudflare without running the Worker, so a file asked for on `www` is still answered there; every page a person opens is redirected.
- **Sign in cookie renamed** to `__Host-puhuscribe-auth` (`worker/learner-auth.ts`). The browser refuses the cookie unless it is Secure, on Path=/ and has no Domain, which the Worker already sets. The browser test helpers and two unit tests use the new name.
- **Landing page address.** `og:url` is `https://meetaleksi.com/`. There was no canonical link and I did not add one: `scripts/security/check-built-files.ts` treats any `<link href>` to another address as an outside load and fails the build. Adding one needs a narrow change to that check, which is the manager's or owner's call.
- **Privacy notice.** Brevo is a processor entry: "Sends the sign in code emails, only if you add your email. It receives your email address and the email with your code." Where: "In the EU." Detail: "Sendinblue SAS, a company in France that trades as Brevo, sends these emails as our processor." Supabase no longer says it sends the emails, and its place is now Germany. Who is responsible is unchanged.
- **Turnstile.** The Worker compares the hostname Cloudflare reports for each token with the address the request came to, so `meetaleksi.com` works once it is in the widget's hostnames. Tokens from `www` or a preview are refused there, and since round 2 a test secret is refused there too.

## The Live workflow, task by task

Start it in GitHub: Actions, Live, Run workflow, branch `main`, pick the task, then approve the waiting run in the browser (the `live` environment asks the owner). Run the tasks one at a time in this order. Two Live runs never overlap: a second one waits.

**Every task first runs "Approved content (no secret)".** It checks that every dialogue in `content/approvals/part-<n>.json` has exactly one publish migration, that no publish migration exists for a dialogue the owner did not approve, and that every file under `public/audio/` is approved (`scripts/ci/check-approved-dialogues.ts`, `scripts/ci/check-published-audio.ts`). Today: 108 approved dialogues, 108 publish migrations. If it fails, nothing else runs.

**1. `migrations`** (environment `live`).
- Checks the live settings are not the test project's (`scripts/ci/check-live-settings.ts`, which compares project refs and prints no value), lists what it would apply (a dry run), then runs `supabase db push --db-url "$SUPABASE_DB_URL" --yes --include-all`. That applies every migration the live project lacks: tables and access rules, reference data, the clean up jobs and the 108 publish migrations, which put the approved dialogues in. No seed or fixture file is loaded; the seed flag is never passed and `supabase/seeds/browser/` is never named (a test checks).
- Needs: `SUPABASE_LIVE_DB_URL` (session pooler string, password percent-encoded) and `SUPABASE_LIVE_URL` in the `live` environment; `SUPABASE_TEST_URL` (repository secret, only to tell the projects apart). No package is installed in this job.
- A second run applies nothing new.

**2. `content`** (environment `live`).
- The same settings check, then `supabase migration list --db-url ...` piped into `scripts/ci/check-live-migrations.ts`, which reads only the Remote column and fails if a migration of main, each publish migration included, is missing, or if live has one main lacks. No learner data is read.
- Why a check and not a second publish: a dialogue reaches any Supabase project only through its publish migration, exactly as on the test project, so task 1 publishes the content. The audio ships with the Worker in task 3.
- Needs: the same secrets as task 1.

**3. `app`** (environment `live`).
- `npm ci`, the Switzer fonts if `FONTS_DEPLOY_KEY` exists, the settings check, then `npm run build` with `CLOUDFLARE_ENV=production` and `VITE_DESIGN_REFERENCE=0` (no design or sample pages). `scripts/ci/check-live-build.ts` refuses the build unless it is the Worker `aleksi` on exactly the two addresses, with no workers.dev or preview address, only `CANONICAL_HOST` as a variable, no design page text and the live `og:url`. Then `npx wrangler deploy --secrets-file <temporary file>`. Last, header-only requests to `https://meetaleksi.com/` (expects 200) and `https://www.meetaleksi.com/learn` (expects a 301 to the apex), retried for up to 5 minutes while the certificate is issued. HEAD requests count no visit and do not touch the database.
- Needs, in the `live` environment: `CLOUDFLARE_LIVE_API_TOKEN`, `CLOUDFLARE_LIVE_ACCOUNT_ID`, `SUPABASE_LIVE_URL`, `SUPABASE_LIVE_PUBLISHABLE_KEY`. From the environment if present, otherwise the repository: `ANTHROPIC_API_KEY`, `AZURE_SPEECH_KEY`, variables `AZURE_SPEECH_REGION` and `AZURE_SPEECH_TIER`, `TURNSTILE_SITE_KEY`, `TURNSTILE_SECRET`, optionally `FONTS_DEPLOY_KEY`; `SUPABASE_TEST_URL` for the settings check. The deploy stops without both Turnstile values and without both live Cloudflare values.

## Cloudflare permissions for the live token

Cloudflare's "Workers authorization" page says attaching a custom domain during `wrangler deploy` needs Editor on the Worker plus Zone, Workers Routes, Write for each affected zone. So the live token in the Exentrik account needs exactly: **Account, Workers Scripts, Edit** (that account) and **Zone, Workers Routes, Edit** (zone `meetaleksi.com` only). It needs no DNS permission if the parked apex A records are gone before the first deploy, because a custom domain makes its own DNS records. If the first run fails with a permission error, read the first `[ERROR]` code in the log; do not widen the token beyond this without asking. Not verified in a real run.

## Remaining risks for the manager and owner

- **Approvals through the owner's login.** Agents work through the owner's GitHub login, which can approve a waiting `live` run. Approve live runs only in the browser, or give agent sessions a token that cannot approve deployments (review finding 1).
- **Shared provider keys** until the owner adds live ones to the `live` environment (see round 2 above).
- **Brevo** (review finding 6). Turn off open and click tracking for transactional email and make sure recipients are not saved as contacts. Read Brevo's sub-processor list and how long it keeps sending logs, then add one sentence to the Brevo entry (and a transfer sentence if a non-EU sub-processor handles the emails). "In the EU" rests on Brevo's help centre ("Data storage location") and a Brevo community answer; the full privacy policy page could not be read. Not legal advice.
- **The cookie rename signs everyone out of the previews once.** Old `puhuscribe-auth` cookies stay in preview browsers for up to 90 days (test data only).
- **Owner page.** The live Worker has no `OWNER_HOSTNAME`, `OWNER_ACCESS_TEAM_DOMAIN` or `OWNER_ACCESS_AUD`, so it has no owner page. README "Owner page setup" is a separate step, and its address `puhuscribe-owner.exentrik.co` would now have to be attached to the Worker in the Exentrik account.
- **Free plan.** The live project is on Supabase Free: no downloadable backups, and it pauses when idle.
- **The content check matches file names**; a non-publish migration that inserted dialogue rows would not be caught. None does today.

## Owner and manager checklist for launch day

Cloudflare, Exentrik account. The manager reports steps 1 and 3 done on 4 November 2026 (zone added to the Exentrik account, nameservers switched at Spaceship); check the rest.
1. Add the zone `meetaleksi.com` to the Exentrik account (Free plan). Cloudflare gives two new nameservers.
2. Make sure the Brevo records are in the new zone exactly as they were: TXT `brevo-code` at the apex, CNAME `brevo1._domainkey` and `brevo2._domainkey` (DNS only, not proxied), TXT `_dmarc`. Do not copy the two parked A records from Spaceship, and add nothing for `www`.
3. At Spaceship, replace the nameservers with the two from step 1. DNSSEC is off at the registry, so nothing else is needed there. Wait until the Exentrik account shows the zone as Active.
4. Remove `meetaleksi.com` from the old (preview) account once the new zone is active, so the old zone cannot be used by mistake.
5. In Brevo, check the domain still shows as authenticated after the move.
6. Create a token in the Exentrik account with only Account, Workers Scripts, Edit and Zone, Workers Routes, Edit on `meetaleksi.com`. Note the Exentrik account id.
6b. The review site token: the owner makes a fresh `CLOUDFLARE_REVIEW_API_TOKEN` in the Exentrik account (same permissions as before: Workers and the custom domain on exentrik.co), stores it with `CLOUDFLARE_REVIEW_ACCOUNT_ID` in the `review` environment, then deletes the old repository copies of both. Optionally move `REVIEW_CF_ACCESS_CLIENT_ID` and `REVIEW_CF_ACCESS_CLIENT_SECRET` there too; the deploy job reads environment secrets first and repository secrets otherwise.

GitHub:
7. The manager has created the environment `live` (main only, the owner as required reviewer). Check administrators may not bypass. The manager creates the environment `review` the same way.
8. The owner stores in `live`: `CLOUDFLARE_LIVE_API_TOKEN`, `CLOUDFLARE_LIVE_ACCOUNT_ID`, `SUPABASE_LIVE_DB_URL`, `SUPABASE_LIVE_URL`, `SUPABASE_LIVE_PUBLISHABLE_KEY`, then deletes the three repository-level `SUPABASE_LIVE_*` copies. Optionally, live-only `ANTHROPIC_API_KEY`, `AZURE_SPEECH_KEY`, `TURNSTILE_SITE_KEY`, `TURNSTILE_SECRET`.
9. Check the repository still has `SUPABASE_TEST_URL`, the Azure and Anthropic keys and the Turnstile pair (or that `live` has them), and the variables `AZURE_SPEECH_REGION` and `AZURE_SPEECH_TIER`.

Turnstile, Brevo, Supabase:
10. `meetaleksi.com` is in the hostnames of the Turnstile widget whose keys live will use. A widget in the preview account works for a domain in another account only if its hostname list allows it; if not, create a live widget in the Exentrik account and store its pair in `live`.
11. Brevo tracking and contacts settings (see Remaining risks).
12. In the live Supabase dashboard: the two "Your Aleksi code" templates hold only the code; Site URL `https://meetaleksi.com` with nothing else in the redirect list; anonymous sign ins on at the limit the owner wants; email code expiry 3600 seconds or less; the Data API exposes only `public` and `graphql_public`.

Merge and run:
13. Merge pull request 41 after review and let the merge run finish.
14. Run `migrations` and approve it. The dry run should list 127 migration files the first time; the apply should end without an error. Then, in the live dashboard, check three `pg_cron` jobs exist: `delete-inactive-accounts`, `forget-old-crash-reports`, `forget-old-voice-data`.
15. Run `content`. It should say 108 of the 108 publish migrations are live.
16. Run `app`. It should end with `https://meetaleksi.com/ answers 200` and `https://www.meetaleksi.com/learn answers 301 https://meetaleksi.com/learn`.

By hand, in a browser:
17. Open https://meetaleksi.com and press Start once: the bot check passes, a guest session opens, no Cloudflare Access login appears.
18. Add an email on the account page and check the code arrives from Aleksi <hello@meetaleksi.com>.
19. Open the privacy notice: Supabase in Germany, the Brevo entry.

Later deploys: `app` again. New migrations from later jobs need `migrations`, then `content`, then `app`.

## Tests and the item each covers

- `worker/go-live.test.ts`: `[go-live 1]` the www redirects; `[go-live 3]` a real token from `meetaleksi.com` makes a guest, tokens from `www` or a preview are refused, `meetaleksi.com` never falls back to the test keys, and (round 2) a test secret set on the live Worker gives no check and no guest while local, preview and reserved test names keep the test secret.
- `worker/guest.test.ts`: `[go-live 2]` the `__Host-` cookie, and an old-name cookie is not a sign in.
- `src/screens/privacy-page.test.ts`: `[go-live 2]` Brevo's entry, and (round 2) Supabase "In the EU (Germany)." and never Ireland; `[accounts 16] [accounts 17]` now expects the Germany text; `[analytics 29]` lists Brevo.
- `src/privacy/first-layer.test.ts`: the notice date and the EU claim (its title now names the live database in Germany).
- `tests/go-live.test.ts` also pins the review site: its `deploy` job, the only job holding a secret, declares `environment: review`, and no other workflow names the review token or account id.
- `tests/go-live.test.ts`: `[go-live 2]` `og:url`; `[go-live 1]` the production environment in `wrangler.jsonc`; the workflow (manual only, main only, the four jobs, no seeds, the database password only where it belongs, the production build checked before the deploy, pinned actions); round 2: every job holding a secret declares `environment: live` and the check job holds none, the `app` job uses only `CLOUDFLARE_LIVE_API_TOKEN` and `CLOUDFLARE_LIVE_ACCOUNT_ID` and never the preview or review token, no other workflow names a live secret or the `live` environment; plus the four check scripts with passing and failing cases.

Broken on purpose and watched go red, then restored. Round 1: the redirect wiring, the old cookie name, the Turnstile hostname comparison, the Brevo entry, the old `og:url`, and the live build check on a preview build and on a design build. Round 2: `environment: review` removed from the review site deploy; `environment: live` removed from `content`; the preview token put back in `app`; "Ireland" put back in the Supabase entry; the new Turnstile rule absent (the test failed before the fix was written).

## Check results (round 2)

- `npm run check:code`: type check pass, lint pass. The format check reports the same 13 files under `design-drafts/` as `origin/main`; none is from this job.
- Touched tests: `npx vitest run tests/go-live.test.ts tests/review-site.test.ts worker/go-live.test.ts src/screens/privacy-page.test.ts src/privacy/first-layer.test.ts worker/human-check.test.ts`: all pass.
- All unit tests, `npx vitest run --maxWorkers=4`: 98 files, 1325 passed, 2 skipped. With the default number of workers, two runs each had the same two failures, `[tooling 9]` and `[tooling 13]` in `scripts/hooks/commit-tool.test.ts`, both "Test timed out in 5000ms" while gitleaks scans a temporary repository under full parallel load. That file passes alone and with 4 workers, and it touches no file this job changed. I did not change its timeout. Worth watching on slower machines.
- Commit hooks (Prettier fix, gitleaks): pass.
- Not run: browser, Python and database tests (paused until the MVP launch). Nothing was run against the live project, and no Live task was started.

## How to run it locally

- Unit tests: `npx vitest run worker/go-live.test.ts worker/guest.test.ts tests/go-live.test.ts src/screens/privacy-page.test.ts`.
- The production build without deploying: `CLOUDFLARE_ENV=production VITE_DESIGN_REFERENCE=0 npm run build`, then `node scripts/ci/check-live-build.ts`. Run a normal `npm run build` afterwards so `vite preview` uses the preview config again.
- The content check: `node scripts/ci/check-approved-dialogues.ts`.

## Round 1 (kept short)

Built the Live workflow, the production Worker config, the www redirect, the cookie rename, the landing `og:url` and the Brevo entry, as above. Round 1 deployed with the preview account's `CLOUDFLARE_API_TOKEN` and noted that it lacked Zone, Workers Routes, Edit on `meetaleksi.com`, and that it lets any pull request preview change the live Worker. Round 1 checks: type check and lint pass, all unit tests 1319 passed with 2 skipped, the production build and its check passed. The security review (`review-security.md`) asked for the changes in round 2.

Result: checks pass
