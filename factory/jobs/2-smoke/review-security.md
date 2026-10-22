# Job 2-smoke: security and privacy review, round 1

Reviewer: security. 19 October 2026. Branch `factory/2-smoke` at `f78289a`, pull request #6. I read `AGENTS.md` (with Lessons learned), `spec.md`, `build.md`, `summary.md`, job 1's `review-security.md` and the full diff against main. I ran nothing against Cloudflare or Supabase.

## Incident during this review (not a finding against the build)

While checking where `SUPABASE_TEST_DB_URL` is used, I ran a text search across the worktree. It also matched the git-ignored `.env.local`, so the test project's full database connection string, password included, was printed in my session output. I did not copy it into this file or any other file.

- **Why it matters:** the spec's manager steps turn reviewer session logs into replay files under `recording/`. This session's log now holds the test database password. The password controls the test project only.
- **What to do:**
  - Redact this session's log before any replay or transcript is made from it.
  - Owner's call: rotate the test project's database password, then update `.env.local` and the `SUPABASE_TEST_DB_URL` GitHub secret. Cost is about five minutes, and the old value in my session log becomes useless.
- **Suggested lesson line:** reviewers and builders search tracked files only (`git grep`), or exclude `.env*` explicitly, because worktrees hold a copy of `.env.local`.

## Findings

No must fix findings. No should fix findings.

### Note: unreviewed migrations reach the shared test project

- **Where:** `.github/workflows/checks.yml` lines 135-162 (`apply-test-db`).
- **Risk:** any branch's migration and test SQL run on the test project as `postgres` before either reviewer or the owner has seen them. The branch can also edit the pgTAP tests that are supposed to stop a bad grant, so the red-run protection (statement 9) only works when the tests are left alone.
- **Judgement:** the test project holds no learner data and only test values, so this is acceptable now. The spec names this risk.
- **Fix, later:** before test learner data (evaluator accounts, consents, recordings) lives in the test project, apply migrations only after the owner approves. For example, use a `workflow_dispatch` or a label-gated run. GitHub environment approvals are not available on private repositories on the Free plan.

### Note: `supabase/setup-cli@v3` is pinned by tag in the job that holds the database password

- **Where:** `.github/workflows/checks.yml` line 150.
- **Risk:** the binary this action installs is the program that then receives the password on lines 156 and 162. If the tag were moved to a bad release, that release would see the password. The impact is limited to the test project.
- **Fix:** pin this one action to a full commit SHA, with the tag in a comment. Do the same for every action before the live database gets a migration path.

### Note: the database itself does not limit insert volume

- **Where:** `supabase/migrations/20261019183410_create_visits.sql` lines 22 and 29-33; `worker/api.ts` lines 137-150.
- **Risk:** anyone signed in to the preview can send unlimited `POST /api/visits`. Anyone holding the publishable key can bulk-insert arrays of rows through PostgREST, and through `/graphql/v1`, since `pg_graphql` is on and `anon` now has INSERT. Every row passes `visited_at = now()`.
- **Judgement:** each row is a number and a time. Today only the owner and the evaluator's token pass Access, and the key stays in the Worker. The 500 MB limit is millions of rows away, so this does not matter for a test project.
- **Fix, at liftoff:** add a rate limit on the public Worker. If `visits` survives job 3, cap or drop it then.

## Checked and passing (look closely anyway)

- **Grants (migration lines 20-22).**
  - `revoke all` on the table and on `visits_id_seq` from `anon`, `authenticated` and `service_role`, then `grant insert` to `anon` only.
  - No sequence grant was needed. This is correct for an identity column.
  - Revoking on the table also removes any column-level grants.
  - No function, view, trigger or `security definer` was added. Default privileges on `public` are not changed, so Supabase's defaults still apply to future tables.
  - Job 3 must repeat the revoke-then-grant pattern on every new table. A pgTAP test that every table in `public` has row level security on would catch a missed one.
- **Row level security (lines 26-33).**
  - It is enabled, with one `for insert to anon` policy.
  - There is no select policy, so even an accidental future SELECT grant returns zero rows, not data.
  - `generated always` stops `anon` from choosing `id` through the API.
- **pgTAP coverage (`supabase/tests/database/visits_access.test.sql`).**
  - As `anon`: insert with defaults works and adds one row; read, update and delete give 42501; the back-dated insert fails with the exact row level security message.
  - As `authenticated`: read, insert, update and delete give 42501.
  - `table_privs_are` pins the exact privilege list for all three roles, so TRUNCATE, REFERENCES and TRIGGER are covered too.
  - The red run proves the test fails on a SELECT grant.
  - Not covered, low value: future-dated inserts (same expression), column-level grants, sequence privileges and grants to `PUBLIC`. Postgres gives tables no `PUBLIC` grants by default.
- **GraphQL.**
  - `pg_graphql` is on (the health check relies on it).
  - With INSERT only, `anon` can see the `visits` type in introspection and call an insert mutation that hits the same policy.
  - Without a SELECT grant, it has no collection query and cannot read records back.
  - Nothing is exposed beyond the table's name.
- **pgTAP left on the test project.**
  - The test file's own `create extension` is inside `begin ... rollback`, so it is undone.
  - My understanding of the CLI is that `supabase test db` enables pgTAP and removes it afterwards if it created it. I could not verify this.
  - If it stays installed, it lives in `extensions`, which PostgREST does not expose for RPC, and its functions run with the caller's own rights. Low risk. The evaluator's `pg_extension` query settles it.
- **The apply job (lines 135-162).**
  - The secret is set only as step-level `env` on its two steps, and on no other job (guarded by `tests/checks-workflow.test.ts`).
  - The job runs no `npm ci`, `npx` or `node`.
  - `persist-credentials: false` is set and nothing is uploaded.
  - The password goes on the command line, which is acceptable on a single-use runner, and GitHub masks the full value in logs. On a connection error the CLI prints the host and user (project ref), not the password.
- **Dependabot and forks.**
  - `github.actor` stays `dependabot[bot]` on re-runs, and Dependabot runs do not get Actions secrets anyway.
  - The repository is private, so fork pull requests get no secrets unless that setting is switched on. Keep it off.
  - A branch can still edit the workflow to print the secret. The spec accepts this, and local agents already hold the same value in `.env.local`.
- **The database check job (lines 116-133):** no secrets. It runs branch SQL only on a throwaway local database.
- **Worker `POST /api/visits` (`worker/api.ts` lines 70-150).**
  - It sends exactly `apikey`, `content-type` and `prefer` with the body `{}`. No visitor header, IP, cookie or body is forwarded, and nothing is logged.
  - Supabase's answer is cancelled unread and never returned.
  - Requiring a JSON content type stops form posts from other sites. The missing `Access-Control-Allow-Origin` and the 405 on OPTIONS block cross-site `fetch`.
  - Reading at most 16 KiB of the request body before answering is bounded and safe.
- **Personal data.**
  - The table has no personal data.
  - From Cloudflare's documentation as I know it (not verified here): a Worker's request to another Cloudflare-fronted host (supabase.co) carries a Cloudflare address in `CF-Connecting-IP`, not the visitor's, plus a `CF-Worker` header naming the `fumnanya.workers.dev` subdomain.
  - Workers Logs may record the IPs of the owner and evaluator for 3 days. This is carried over from job 1: check it before learner data arrives.
  - The test project is in Ireland, in the EU.
- **The anonymous preview test (`e2e/visits.spec.ts` lines 208-220):** it builds a fresh request context with empty `extraHTTPHeaders`, as job 1's lesson requires.
- **New dependency `supabase` 2.121.0.** It is pinned exactly. Its MIT dependencies come from Supabase's own platform binaries, plus `jose`, `eciesjs` and `@noble/*`. The diff adds no install script. `npm audit` is green.
- **`supabase/config.toml`:** it holds only the CLI defaults, with `env()` placeholders and no literal secrets. It affects only the local database; `db push` does not send it.
- **The page (`src/App.tsx`):** no user text is shown, no HTML is injected and there are no redirects.
- **Carried over from job 1, unchanged:** a separate Cloudflare account for previews, a daily check from main that preview links still ask for sign in, a cache or rate limit on `/api/health`, and the Workers Logs IP question.

Result: pass
