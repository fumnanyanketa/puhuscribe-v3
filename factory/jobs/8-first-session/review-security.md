# Security and privacy review: 8-first-session

Reviewer: security agent, 21 October 2026. Branch `factory/8-first-session`, head `679d21c`, diff `main...HEAD` (66 files). Read only on code; no `.env*` file was opened or searched.

## Short answer

No must-fix problem. The guest sign in, the database rules and the logging do what the spec asks, and the tests prove the important refusals. Two should-fix items: the sign in cookie name should carry the `__Host-` prefix before the app gets a custom domain, and the guest rate limit launch decision needs a line in `factory/todo.md` that also covers the shared token refresh limit.

## Findings

### Should fix

1. **Cookie name has no `__Host-` prefix.** `worker/learner-auth.ts` line 18 (`AUTH_COOKIE = 'puhuscribe-auth'`).
   Risk: once the app runs on a custom domain, any other subdomain of that domain (or a page on it served over plain HTTP) can plant its own `puhuscribe-auth` cookie for the parent domain, so a learner's progress goes into a guest account the attacker made and can read. Today the app lives on `workers.dev`, which browsers treat as a public suffix, so this cannot happen yet.
   Fix: rename the cookie to `__Host-puhuscribe-auth`. The cookie already meets every rule the prefix needs (`Secure`, `Path=/`, no `Domain`), and `@supabase/ssr`'s chunk names (`.0`, `.1`) keep the prefix. Update `isAuthCookie`, `e2e/db.ts` `userIdOf` and the cookie name assertions with it. If the owner prefers, schedule it for the custom domain job instead of this round.

2. **The guest rate limit launch decision is only in specs, not on the to-do list, and it misses the token refresh limit.** `factory/jobs/8-first-session/spec.md` Decision 2 (line 99) and Risks ("Guest abuse before the public launch"); `factory/todo.md` on main has no entry.
   Risk: the decision could be missed at launch, because `factory/todo.md` is the list the owner schedules from, and it also leaves out that every learner's token renewal reaches Supabase from the same Worker address, so the per address renewal limit (`token_refresh = 150` per 5 minutes in `supabase/config.toml` line 214, the Supabase default) is shared by all learners too. When it runs out, the Worker answers 503 and keeps the cookies (correct handling in `worker/learner-auth.ts` `signInState`), so learners see "not available" rather than losing progress.
   Fix (manager, records only): add one line to `factory/todo.md` such as "(8-first-session) Before launch: guest sign up and token renewal limits are shared by all learners because the Worker makes every Auth call; decide Turnstile, a secret key with address forwarding, a Worker limit, or a mix (jobs 10 and 11 add their own shared limits)."

### Notes (no change needed in this job)

3. **A learner can fake their own progress.** `supabase/migrations/20261020090100_learner_model.sql` line 145 (job 3) lets a learner update their own `step_reached` and `ended_at` directly. A learner who copies their own token from their browser's developer tools (`HttpOnly` stops page scripts, not the person) can call Supabase directly, mark a session as finished at "understand", then call `complete_session` or insert their own `first_session_completed` event (`supabase/migrations/20261021182910_first_session.sql` line 59). They gain cards for an approved dialogue they skipped and an event they did not earn. Only their own rows change, which the spec's threat model accepts. Consequence for job 14: count `first_session_completed` as "claimed", not as proof of learning.

4. **Audio files are public static files.** Per the manager addendum, `/audio/<key>` is served by Cloudflare's static assets with no sign in. Anyone with the address can download an approved line's audio. A line withdrawn after a deploy keeps its file online until the next build. Both depend on job 7 copying only approved lines' files; this job has no test of that (there is no `public/audio` yet). `worker/session-plan.ts` `audioPath` (lines 109 to 115) refuses keys with `..`, `.` or unusual characters, and keys come only from approved database rows, so path traversal is not possible.

5. **Guest clean up owner is inconsistent.** `docs/data-model.md` line 71 says job 9 builds the 90 day clean up of unused guests; the spec (Out of scope) says job 11. This job is the first to create real accounts, and nothing deletes unused guests yet. The `usage_events` rows go with the user (`on delete cascade`, proven by pgTAP), so the clean up covers them once it exists. Settle which job owns it before learners outside the team arrive.

## The three threat model questions, checked against the code

**What is the worst a malicious person could do?**
- Read or change another learner's rows. Not possible. The Worker never takes a user id from the request (`worker/learner-db.ts` sends none; the database fills `user_id` from the token). Session ids from the URL are passed to queries that run under the learner's own token, so row level security hides other learners' sessions (`complete_session` answers `P0002`, the Worker answers 404). pgTAP proves A cannot read B's events, add an event with B's id or B's session, or make cards through B's session.
- Steal a sign in. The cookie is `HttpOnly; Secure; SameSite=Lax; Path=/`, no `Domain`, `Max-Age` 90 days (`worker/learner-auth.ts` lines 43 to 51), checked by unit tests. The answer body of `/api/guest` holds only `{"guest":"created"}`. `src/` imports nothing from Supabase and stores nothing in `localStorage`, `sessionStorage` or `document.cookie`; the browser test checks all three. The app loads no third-party script.
- Act for a learner from another site. Every changing route goes through `refuseUnsafeWrite` (`worker/http.ts` lines 82 to 96): `POST` only, `application/json` only (which a plain HTML form cannot send, and a cross-site `fetch` with it needs a preflight that the Worker never approves), and 403 when `Origin` names another site. No `Access-Control-Allow-Origin` is ever sent. `SameSite=Lax` keeps the cookie off cross-site `POST`s anyway. `GET /api/today` can only renew the learner's own cookies.
- Fill the database with guests. From a browser on another site, no. From a script or `curl`, yes, limited only by Supabase's hourly anonymous sign up limit, which all guests share (finding 2). Previews sit behind Cloudflare Access. Recorded in the spec as a launch decision.
- Get unapproved content served. Content is read only with the learner's token (`supabaseLearnerDb`), so job 3's approval rules decide. `tests/worker-rules.test.ts` fails if any Worker file names a secret or service role key. The fixture's draft dialogue, line and form are checked absent by unit and browser tests.

**What data do we store that we must protect?**
- `auth.users` rows for guests (id and times, no email), the sign in tokens (only in the `HttpOnly` cookie and Supabase), `sessions`, `cards` and the new `usage_events` (id, user, event name, session, time; `columns_are` in pgTAP proves no address, device or free text column). Answers to the comprehension check are not sent anywhere. Everything is deleted with the user through `on delete cascade`.

**What must the system refuse?**
- Account from a page load, `GET` or another site: refused (405 on `GET`, 403 on a foreign `Origin`, 415 on non JSON; browser test counts zero `/api/guest` calls on load).
- A user id, a step beyond `understand` or someone else's session from the browser: the Worker accepts only `hear` and `understand`, one step at a time (`worker/api.ts` `recordStep`); other learners' sessions are invisible.
- Unapproved content: read through the approval rules only (see above).
- A card for an unmet form: `complete_session` refuses an empty or `hear` step and writes nothing (pgTAP), and job 3's card rule still applies inside it. See note 3 for the learner faking their own step.
- Tokens, cookies, ids or addresses in logs: nothing in `worker/` or `src/` calls `console`; `worker/logs.test.ts` drives every route through the real Supabase libraries and finds no token, cookie value, user id, address or user agent in any console output. Cloudflare invocation logs are off in `wrangler.jsonc` and a repository test pins it.
- A secret or service role key: none exists in the Worker.

## Checked and passing

- **Migration `20261021182910_first_session.sql`.** Revokes everything from `anon`, `authenticated` and `service_role`; grants `authenticated` whole table `SELECT` and `INSERT` on only `user_id`, `name`, `session_id`; row level security on; insert rule requires own id and own session at `understand` or later with `ended_at` set; partial unique index for one `first_session_completed` per learner. `complete_session` is `security invoker`, `search_path = ''`, every name schema qualified, execute revoked from `public`, `anon`, `authenticated`, `service_role` and granted to `authenticated` only. Idempotent: the end time is set only once, cards and the event use `on conflict do nothing`. All proven in `supabase/tests/database/first_session.test.sql` (60 tests) and the catalogue test, and the red scratch run is linked in `build.md`.
- **Event names.** The enum has one value, so a learner cannot invent event names; the column has no free text.
- **Drop of `visits`.** The table held no personal data; `/api/visits` now answers 404; pgTAP checks the table is gone.
- **Error answers.** Only short codes (`not_available`, `content_unusable`, `step_out_of_order`), never a line id, a database message or a Supabase error.
- **Body caps.** Every route reads at most 16 KB before answering, `413` above it, including unknown paths and `GET` routes.
- **Per request client.** A new Supabase client is built for every request, so one learner's session can never leak into another's request inside the Worker.
- **Test fixture.** `supabase/seeds/browser/010_test_fixture_unit_1.sql` is loaded only by the pull request job with `psql "$LOCAL_DB_URL"` (the runner's own database). The hosted test project gets `supabase db push` without `--include-seed`, and `config.toml` loads only `./seed.sql`. `tests/test-fixture.test.ts` proves no migration contains `test-fixture`, no workflow uses `--include-seed`, `config.toml` does not load the browser seeds, and a real production build contains none of the fixture's Finnish. Job 6's workflow tests pin the seed step to `LOCAL_DB_URL` and keep secrets out of that job. Browser tests that sign in are tagged `@seed` and are left out of the after merge run, so no guest accounts are made on the test project by tests.
- **Self-signed HTTPS script.** `scripts/ci/test-https-cert.ts` runs `openssl` with fixed arguments, writes into the git-ignored `.wrangler/test-https/`, prints only the folder. Playwright ignores certificate errors only for the local server, never for preview links. `vite.config.ts` reads the files only when `PUHUSCRIBE_TEST_HTTPS=1`. The cookie keeps `Secure`.
- **Dependencies.** `@supabase/supabase-js` 2.117.3 and `@supabase/ssr` 0.12.7, pinned exactly, MIT, from the npm registry, maintained by Supabase. They pull in the other `@supabase/*` packages, `iceberg-js` and `cookie`. `npm audit`: 0 vulnerabilities (with and without dev packages). They are used only by the Worker; nothing from them is in the browser bundle. No Python dependency changed, so pip-audit was not needed.
- **Evidence folder.** No token, key or cookie shaped value in `factory/jobs/8-first-session/evidence/`.
- **Browser storage.** Nothing personal is stored in the browser except the `HttpOnly` sign in cookie.
- **Rate limit note accuracy.** Decision 2 and Risks correctly say that Supabase sees every guest as one address and the hourly limit is shared, that previews rely on Cloudflare Access, and that the choice comes to the owner before launch. Jobs 10 and 11 cite it as "job 8's pre-launch decision". Only the to-do entry and the token refresh limit are missing (finding 2).

## For the owner to look at closely, even though it passes

- **Which address Supabase sees.** Not verified by this review. If Cloudflare gives every Worker on its network the same outgoing address when calling Supabase (which is itself behind Cloudflare), the shared limit may be shared with other Cloudflare customers' Workers too, not only with our own guests. Worth one test on the test project before the launch decision.
- **The owner setup step.** Turning on anonymous sign ins on the test project and raising its limit is safe only while previews stay behind Cloudflare Access. Raise it to what testing needs, not to the local value of 10,000.
- **No privacy notice yet.** The front door line explains why an account is made, but the full GDPR notice and the export and delete buttons come in job 11. Real accounts now exist, so no learner outside the team should use the app before job 11.
- **No clean up of unused guests yet** (note 5).

Result: pass
