# Security review: go-live (pull request 41)

Reviewer: security agent, 4 November 2026. Read only on code. Scope: `git diff origin/main...factory/go-live` (commits `94726d5` and `253a911`), the builder's notes (`factory/jobs/go-live/build.md` in the main folder; there is no `spec.md`), AGENTS.md, and the repository settings as GitHub reports them (names only, no values). No `.env` file was read.

What I checked and found sound:

- The three actions in `.github/workflows/live.yml` are pinned to full commits, and each commit matches its tag on GitHub today: `actions/checkout` v7.0.1, `actions/setup-node` v7.1.0, `supabase/setup-cli` v3.0.1.
- The workflow has `permissions: contents: read`, `persist-credentials: false` everywhere, no `pull_request_target`, and the task input reaches only `if:` expressions, so it cannot inject shell commands.
- No seed file can reach the live database. `supabase db push` loads seeds only with `--include-seed`, which is never passed, and `supabase/seeds/browser/*` is named only in `checks.yml` against the throwaway local database. The 19 schema migrations hold no test users or fixture rows.
- The production Worker config has `workers_dev: false` and `preview_urls: false`, and `vars` holds only `CANONICAL_HOST`. Top level `vars` are not inherited by a wrangler environment. `scripts/ci/check-live-build.ts` refuses any other name, address or variable. The design pages are only built when `VITE_DESIGN_REFERENCE` is `1` (`src/main.tsx:23`), and the check scans the built files for their text. Owner routes answer 404 without `OWNER_HOSTNAME` (`worker/index.ts:73`).
- The www redirect (`worker/canonical-host.ts:38`) builds the target from the fixed `CANONICAL_HOST`, so it cannot become an open redirect.
- Cookie rename: every Set-Cookie, including every clear, goes through `cookieValue` (`worker/learner-auth.ts:74`), which always sets Secure, Path=/ and no Domain. Sign out, account deletion and an ended session all clear through `clearCookies` (`worker/account.ts:98, 104, 114, 460, 516`, `worker/api.ts:348`, `worker/island.ts:190`). Nothing reads the old name, and a test shows an old `puhuscribe-auth` cookie does not count as a sign in.
- The diff holds no real secret. The only secret shaped strings are made up test values in `tests/go-live.test.ts`.
- `scripts/ci/check-live-settings.ts` and `scripts/ci/write-test-settings.ts` print names and rule text only, never a value.

## Findings

### 1. Must fix: the live database password is a repository secret that any branch can read

- Where: `.github/workflows/live.yml:89-101`, `:118-129` and `:173-183` (jobs `migrations`, `content` and `app` have no `environment:`). In GitHub, `SUPABASE_LIVE_DB_URL`, `SUPABASE_LIVE_URL` and `SUPABASE_LIVE_PUBLISHABLE_KEY` already exist as repository secrets, the repository has no environments, and `main` has no branch protection.
- Risk: the `if: github.ref == 'refs/heads/main'` lines only protect this one file. Any workflow on any branch of this repository can read every repository secret. A pull request from a branch here runs that branch's own `checks.yml` with secrets. A branch can also edit `live.yml`, remove the `if:` lines and start it on that branch. So a bad dependency in a branch, or a misled agent, could print or send away the live database password. With it, someone could read every learner's email address and progress, or delete them.
- Fix:
  1. In GitHub settings, create an environment named `live`. Set deployment branches to "Selected branches" with only `main`. Add the owner as required reviewer. Leave "Allow administrators to bypass" off.
  2. Move `SUPABASE_LIVE_DB_URL`, `SUPABASE_LIVE_URL` and `SUPABASE_LIVE_PUBLISHABLE_KEY` into that environment, then delete the repository level copies.
  3. Add `environment: live` to the jobs `migrations`, `content` and `app` in `live.yml`. Add a test in `tests/go-live.test.ts` that every job naming a live secret declares it, and that no live secret name appears at repository level in any other workflow.

  GitHub then refuses those secrets to any run that is not on `main`, even if a branch edits the workflow, and every live run waits for the owner's click. One limit remains: agents work through the owner's GitHub login, and that login can approve a waiting run. Give agent sessions a token that cannot approve deployments, or approve live runs only in the browser.

### 2. Must fix: the preview token can replace the live Worker's code

- Where: `wrangler.jsonc:71-81` puts the Worker `aleksi` in the same Cloudflare account as `puhuscribe-preview`. `.github/workflows/checks.yml:732-770` gives `CLOUDFLARE_API_TOKEN` (`puhuscribe-ci`, Account, Workers Scripts, Edit) to branch code on every pull request, after `npm ci` of the branch's packages.
- Risk: Workers Scripts, Edit covers every Worker in the account, and Cloudflare cannot narrow it to one Worker. A branch can run `wrangler deploy --env production` or rename its Worker to `aleksi`. That uploads new code to meetaleksi.com, and the new code keeps the live secrets. It could then read every learner's sign in cookie and the live provider keys. The builder flagged this. `factory/todo.md:11` already says "Separate Cloudflare account for previews before liftoff". The builder's option (a) adds Zone, Workers Routes, Edit to this same token, which also lets any branch repoint meetaleksi.com. Option (b) leaves this risk as it is.
- Fix (recommended setup):
  1. Make a second Cloudflare account just for the live app, for example "Aleksi live". Move the `meetaleksi.com` zone there. Nothing is live yet, so the move only affects the parked records and the Brevo DNS records, which must be copied across. Whether the nameservers change on a move is not verified; check before deleting anything.
  2. In that account, create one token, for example `aleksi-live-deploy`, with only Account, Workers Scripts, Edit and Zone, Workers Routes, Edit for `meetaleksi.com`. No DNS edit is needed if the parked apex A records are deleted by hand first, as the build notes say.
  3. Store it, with that account's id, as `CLOUDFLARE_LIVE_API_TOKEN` and `CLOUDFLARE_LIVE_ACCOUNT_ID` in the `live` environment from finding 1, and use only those names in the `app` job.
  4. Leave `puhuscribe-ci` on the preview account, where it cannot reach the live account.

  If the owner will not make a second account before launch, the minimum is still a separate live token in the `live` environment. The owner must then accept in writing, in `summary.md`, that any branch's preview job can replace the live app's code until the accounts are split.

### 3. Must fix: the privacy notice says the database is in Ireland, but the live project is in Frankfurt

- Where: `src/privacy/processors.ts:52` (`where: 'In the EU (Ireland).'`) and the first layer claim source `src/privacy/first-layer.ts:67`. `README.md:130` and `:145` (this diff) say the live project `aleksi-live` is in Frankfurt.
- Risk: real learners would read a false statement about where their data is kept. Germany is still in the EU, but a privacy notice must be accurate. Ireland was the test project's region.
- Fix: confirm the region in the live project's dashboard (Settings, General). Change `where` to "In the EU (Germany)." and update the claim source and the tests that pin the text. Move `NOTICE_UPDATED` if the date changes.

### 4. Should fix: a Turnstile test secret would make the live check always pass

- Where: `worker/providers/human-check.ts:82`. When both settings are present, `test` is true for any published test secret, whatever the address. `checkHuman` then passes every token (`:129`). The deploy step (`live.yml:185-188`) only checks that the two secrets are not empty.
- Risk: if `TURNSTILE_SECRET` in GitHub ever holds Cloudflare's test secret, which is easy to do because previews and live share one secret name, the live bot check turns off without any error. Scripts could then use up Supabase's anonymous sign in limit and block real learners.
- Fix: in `humanCheckKeys`, return null when the secret is a test secret and `mayUseTestKeys(hostname)` is false, and add a test with `meetaleksi.com` and the test pair. Better still, give live its own widget (only `meetaleksi.com` in its hostnames) and its own secret names in the `live` environment.

### 5. Should fix: live shares the Anthropic and Azure keys with every branch

- Where: `live.yml:178` and `:181` use the same `AZURE_SPEECH_KEY` and `ANTHROPIC_API_KEY` that `checks.yml` gives to branch code for previews.
- Risk: branch code can read these keys and spend on them directly. That skips the $10 a month cap in `private.tutor_limits`, which only applies to calls that go through the Worker. The keys cannot read learners' past chats.
- Fix: create separate live keys (an Anthropic workspace with its own spend limit, and an Azure Speech resource in an EU region) and store them only in the `live` environment.

### 6. Should fix: the Brevo entry does not mention tracking or how long Brevo keeps the email

- Where: `src/privacy/processors.ts:79-86` and the deletion promise in `src/privacy/data-inventory.ts:19` ("Deleting your account deletes everything linked to it at once").
- Risk: Brevo transactional email can add open and click tracking, which records when a learner opens the email and from which device and IP address. The owner saw a Brevo "Unsubscribe" link, which suggests account level email features are on. Brevo also keeps a sending log with the address after the learner deletes their account. The notice says neither. The builder could not verify the "In the EU" claim against Brevo's full privacy policy or its sub-processor list.
- Fix: before launch, in Brevo, turn off open and click tracking for transactional email, and make sure recipients are not saved as contacts. Read Brevo's sub-processor list and how long it keeps transactional logs. Add one sentence to the Brevo entry with that retention, plus a transfer sentence like Anthropic's if any non EU sub-processor handles the emails. If tracking cannot be turned off, the notice must say so.

### 7. Note: package code runs in the same job as the live secrets

- Where: `live.yml:147` (`npm ci`), `:166` (`npm run build`), `:193` (`npx wrangler deploy`).
- Risk: the secrets are only in the deploy step's environment. But install scripts and build code from earlier steps can change files on disk, including `node_modules/wrangler` and `scripts/ci/write-test-settings.ts`, and the deploy step then runs those files with every live secret. The comment at `:26-28` claims more separation than the job really has. Every Worker deploy has this risk, and the lockfile and integrity hashes limit it.
- Fix (optional): try `npm ci --ignore-scripts` and confirm the build and deploy still work, and fix the comment. Also, the comment at `:24-25` says the database URL is only in Supabase CLI steps; it is also given to `check-live-settings.ts` (`:91`, `:120`). That is harmless, because no packages are installed in those jobs, but the comment should say so.

### 8. Note: old preview cookies are never cleared

- Where: `worker/learner-auth.ts:62-64` no longer counts `puhuscribe-auth` as a sign in cookie, so sign out does not clear it.
- Risk: browsers that used a preview keep the old cookie for up to 90 days. It holds a refresh token for the test project that still works. This is test data only, and no browser has that cookie on meetaleksi.com.
- Fix: none needed for live. If wanted, sign out could also clear the old name once.

## For the owner to look at closely, even though it passes

- **Live Supabase settings are set by hand.** `supabase db push` copies the tables and rules, not `supabase/config.toml`. In the live dashboard, check each of these before the first learner:
  - The magic link and email change templates hold only the code, with no link, like `supabase/templates/`.
  - Site URL is `https://meetaleksi.com`, and the redirect list holds nothing else.
  - Anonymous sign ins are on, and the email code expiry is 3600 seconds or less.
  - The Data API exposes only `public` and `graphql_public`, so the `private` schema stays hidden.
- **The clean up jobs must exist in live.** The notice promises guest deletion after 90 days, crash reports deleted after 30 days, and old voice data removed. After the `migrations` task, check that the live project lists three `pg_cron` jobs: `delete-inactive-accounts`, `forget-old-crash-reports` and `forget-old-voice-data`.
- **Free plan backups.** `README.md:130` puts the live project on Supabase Free. The owner cannot download backups on that plan, and the project pauses when idle. A lost database means lost learner progress.
- **The live database password** should be used nowhere else. Change it if it ever appears in a log. GitHub hides the exact secret text, but not a reshaped copy of it.
- **The content check matches file names only** (`scripts/ci/check-approved-dialogues.ts`). A non publish migration that inserted dialogue rows would not be caught. Today none does, but reviewers of later jobs should watch for it.
- **The privacy contact** in `src/privacy/notice-settings.ts:15` is a Gmail address. This diff did not change it, but learners' privacy requests will go to Google.

Result: changes needed
