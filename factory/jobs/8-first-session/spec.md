# Job 8-first-session: First session loop (Hear it, Understand it)

Scope item 6. GA. Needs a decision. Date: 21 October 2026. Builds on jobs 1 to 5 as merged on main. Runs beside `7-content-pipeline` and `6-pr-local-db`. Test label: `[session N]`.

## Summary for the owner

1. A visitor presses Start and becomes a guest: a real account with no email, kept on that phone by a cookie the page's own code cannot read.
2. They hear today's dialogue line by line in spoken Finnish, with the written Finnish under each line, and can tap any word for its card.
3. A short check (two or three taps) asks what lines mean, with gentle wording and nothing scored or stored.
4. The session ends with one sentence they can now say; the words they met go into their review, and the database records the session and one `first_session_completed` event.
5. Costs nothing a month. You flip one free switch on the test database before merge. Until job 7 publishes real Finnish, tests use a clearly marked test dialogue that exists only in throwaway databases.

## What it is

The first real screens of PuhuScribe. A learner opens the app, starts as a guest, and works through the first two steps of the loop (Hear it, Understand it) on one approved dialogue. Every layer is real: the account, the content read through the database's approval rules, the audio route, and the saved progress. Say it (job `10-speaking-feedback`) slots in later between Understand it and the finish screen.

It serves P1 (a short dialogue, never a word list), P5 (spoken first, written labelled, both with audio), P3 (the unit's "can do" statement on the front door) and P2 (met forms enter the review queue with no self rating).

## Done when

Terms used below. "Phone size" means 375 x 812 in Chromium and WebKit, as in job 1. "Browser test" means a Playwright test at phone size in both browsers against the built app and a throwaway local Supabase (provided by job `6-pr-local-db`). "The fixture" is the test seed in statement 20. "A learner" is a guest signed in through this job. Tags: **[security]** and **[personal data]** mark statements the security reviewer and evaluator must check closely.

### The front door and the guest account

1. **The front door.** `/` shows the wordmark, the heading "Today's session", one sentence saying what a session is, a primary "Start" button, and this line under it: "Starting creates a guest account on this device so your progress is saved. PuhuScribe is for adults, 18 and over." Loading the page creates nothing: a browser test counts zero calls to `/api/guest` before Start is pressed. **[personal data]**
2. **Start makes a real guest account.** Pressing Start sends one `POST /api/guest`. The Worker creates a Supabase anonymous user with the publishable key and answers 201. The answer body holds no token and no user id. The sign in cookies are `HttpOnly`, `Secure`, `SameSite=Lax`, `Path=/`, with no `Domain`, and the refresh cookie lasts 90 days (matching the owner's 90 day rule for unused guests). A browser test then finds exactly one new `auth.users` row with `is_anonymous = true` in the local database. Pressing Start again, reloading, or opening `/` in a new tab of the same browser creates no second account. **[security] [personal data]**
3. **The browser never holds a token or talks to Supabase.** On every screen of this job, every request goes to the page's own address and none to a `supabase.co` address; `document.cookie`, `localStorage` and `sessionStorage` contain no Supabase token; the existing built-file secret checks still pass. Browser test. **[security]**
4. **Expired sign ins renew; lost ones start over kindly.** When the access token has expired, the Worker renews it with the refresh token, sets the new cookies, and the request succeeds. If renewal fails (the user was deleted or the token revoked), the Worker clears the cookies and `/` shows "Your guest session ended on this device. Press Start to begin again." Worker unit tests with a fake Supabase cover both; a browser test covers the second by deleting the user in the local database. **[security]**
5. **Other websites cannot act for a learner.** Every `/api` route that changes something accepts only `POST` with `content-type: application/json`, and answers 403 when an `Origin` header names another site. `GET` routes change nothing. No answer sends `Access-Control-Allow-Origin`. Worker unit tests, plus a browser test that posts from another origin and finds nothing saved. **[security]**

### Today's session

6. **Today's session is picked by one rule.** `POST /api/sessions/today` picks the first approved dialogue the learner can read (lowest unit position, then lowest dialogue position) that they have not finished. If the learner has an unfinished session for it, that session is reused; otherwise one `sessions` row is added for it. The user id comes from the token, never from the request. With no readable dialogue the screen says "Today's session is not ready yet. Please come back later." and shows no Finnish. After the learner has finished every readable dialogue, `/` says "You have finished every dialogue that is ready." Browser tests with the fixture and with an empty content database. **[personal data]**
7. **Content is read only through the learner's own access.** The Worker reads units, dialogues, lines, tokens and forms with the learner's token, so the database's approval rules from job 3 decide what comes back. No Supabase secret key or service role key is used anywhere. The fixture's draft dialogue, draft line and draft form never appear in any `/api` answer or on screen (browser test plus Worker unit test). **[security]**
8. **The steps come from one list.** The session's steps are one ordered list in one file (today Hear it, Understand it), followed by the finish screen. The top bar reads "Hear it, step 1 of 2" and "Understand it, step 2 of 2". `SessionFrame` gets an optional list of steps; its default and the job 5 tests stay unchanged. A unit test proves a step added to the list renders between Understand it and the finish screen, which is where Say it goes in job 10.

### Hear it

9. **Line by line, spoken first, written labelled.** Hear it shows the first line. Each line shows the speaker label, the spoken Finnish on the teal band and the written Finnish under it labelled "Written", both `lang="fi"`, using `FinnishLine`. "Next line" adds the next line under the earlier ones, which stay visible. On the last line the primary button reads "Continue", and pressing it stores `step_reached = 'hear'`. A word is shown as changed (azure) when its form's spoken and written shapes differ. The first time changed words appear, the line "Blue words change between spoken and written Finnish." shows once. The line whose audio is playing is marked by more than colour. Browser test, including the database value.
10. **Both registers have audio, started only by a press.** Each line has "Play the spoken line" and "Play the written line" controls (`PlayControl`), pointing at `/api/audio/<line id>/puhe` and `/api/audio/<line id>/kirja`. Nothing plays by itself. Browser tests answer those URLs with a generated tone (never speech) and check the request, the ready, loading and playing states, and that a 404 shows "Could not play." with "Try again".
11. **The audio route serves only approved audio.** `GET /api/audio/<line id>/<register>` streams the file only when the learner's token can read that line through the database rules. Without an account it answers 401. A line that does not exist, is a draft, is retired, or sits in a draft dialogue or unit answers 404, the same as a missing one. A register other than `puhe` or `kirja` answers 404. The answer has an `audio/*` type and `cache-control: private`, and never contains a storage key or the store's address. The file is fetched through one module, `worker/audio-store.ts`, so the store can be swapped. Worker unit tests with a fake database and a fake store cover each case. **[security]**

### Understand it

12. **Tap any word for its card.** In both steps, every word linked to a form the learner can read is a button. Tapping it opens `WordCard` with the word as it appears, the base form (`lemma`), the form name (`form_name_en`), the one line why (`why_en`), the spoken form (`surface_puhe`) and the written form (`surface_kirja`). The card's two play controls play that line in each register and are named "Play the spoken line" and "Play the written line". A word with no form (such as a name), or whose form the learner cannot read, is plain text. The job 5 card behaviour (focus in and back, Escape, tap outside, no scrolling behind) still holds. A browser test taps one spoken and one written word and checks every field against the database.
13. **A short comprehension check.** Understand it asks up to three questions, one at a time, one per line chosen by a fixed rule (Decision 4). Each shows the line (spoken, written, play controls, tappable words) and "What does this mean?" with up to three English choices: that line's gloss and the glosses of other lines in the dialogue. The same session shows the same questions and order after a reload. A right answer shows "Yes, that is right." and "Next". A wrong answer shows, in the gentle status style, "Not this one. Listen again and try another.", and that choice becomes unavailable. No red, no score, no count of mistakes, and nothing about the answers is stored. After the last question the Worker stores `step_reached = 'understand'`. Browser test answers wrong, then right, and checks the database has no answer data.
14. **The finish screen gives one sentence.** After Understand it, the finish screen shows "Now you can say this.", one line of the dialogue (spoken, written labelled, both play controls, its English gloss), then "The words you met will come back in your review." and a primary "Done" button that returns to `/`. The line is picked by a fixed rule (Decision 5) in one unit tested function. No counts, scores, badges, streaks or celebration. Browser test.

### What is saved

15. **Saved at the end, all at once.** When the finish screen opens, the Worker calls the database function `public.complete_session(session_id)` once. In one transaction it sets the session's `ended_at`, adds a card with default values (which equal `createEmptyCard()`, job 3 statement 3) for every approved form linked from any token of the dialogue's lines, and adds one `first_session_completed` event if the learner has none. Calling it again changes nothing: no second card for a form, no second event. If the call fails, the screen shows the problem style "Your progress was not saved. Check your internet connection, then try again." with "Try again". A browser test, after a full run, finds in the local database the session with `step_reached = 'understand'` and `ended_at` set, one card per distinct approved form in that dialogue, and exactly one event. **[personal data]**
16. **Nothing unmet enters review.** `complete_session` refuses a session whose step is empty or `hear`, and refuses another learner's session, writing nothing in either case. No card is made for a form that appears only in the fixture's second dialogue. pgTAP tests, plus the browser test in statement 15. **[personal data]**
17. **The usage event table and the function have tight rules.** One migration adds:
    - enum `usage_event_name` with the single value `first_session_completed`;
    - table `usage_events` with `id` (uuid), `user_id` (default `auth.uid()`, references `auth.users(id)` on delete cascade), `name`, `session_id` (references `sessions(id)` on delete cascade) and `created_at` (set by the database). Nothing else: no IP address, device, browser or free text;
    - all permissions removed from `anon`, `authenticated` and `service_role`, then `authenticated` may read its own rows and insert only `user_id`, `name`, `session_id`; row level security on; the insert rule requires the learner's own id and their own session with `step_reached` at least `understand` and `ended_at` set; a unique index allows one `first_session_completed` per learner;
    - `public.complete_session` as `security invoker` with `search_path = ''`, execute removed from `public` and `anon` and granted to `authenticated` only.

    pgTAP proves, with two learners A and B, that A cannot read B's events, add an event carrying B's id or B's session, add an event before finishing, add a second `first_session_completed`, or make cards through B's session; that `anon` can neither read the table nor call the function; and that deleting a user removes their events. The job 3 table list test and catalogue test include the new table. `src/lib/database.types.ts` is regenerated by the CLI. A scratch branch that loosens the insert rule turns the database check red, and the run is linked in `build.md`. **[security] [personal data]**
18. **Leave and come back.** "Leave session" returns to `/`, which then shows "Continue today's session". Continuing resumes the same session row at Hear it (step empty), Understand it (step `hear`) or the finish screen (step `understand`, not yet ended). Browser test checks the screen and that no second session row was added.
19. **Logs hold nothing personal.** The Worker writes no cookie, token, user id, IP address or request header to its logs (a unit test watches `console`). Cloudflare's invocation logs are turned off in `wrangler.jsonc` (`observability.logs.invocation_logs: false`), because requests now carry sign in cookies and Cloudflare does not document which request details those logs keep. **[security] [personal data]**

### Test content, old page, records

20. **The test dialogue lives only in throwaway databases.** `supabase/seeds/test-fixture-unit-1.sql` holds one test unit (slug `test-fixture-unit-1`, position 900), two approved dialogues, one draft dialogue, a draft line, a draft form, their tokens and forms. Every approved row's `approval_ref` starts with `test-fixture:not-reviewed`, and audio keys start with `test-fixture/`. Its Finnish is lines 1 to 5 of `docs/risk-tests/test-2-voice-lines.md` (already in the repository, not reviewed); its form names and "why" lines are written by the builder and marked as fixture. `supabase/config.toml` loads it only through the local seed. Repository tests prove that no migration contains `test-fixture`, that the checks workflow never applies seeds to the test project (no `--include-seed`), and that the built app contains none of the fixture's Finnish. Browser tests read expected content from the database, so they also pass when job 7's real dialogue is present.
21. **The Hei! page and `visits` are retired, as `docs/data-model.md` planned for this job.** `/` is the front door. `/api/visits` answers 404. A migration drops `visits`. Tests whose only subject was the Hei! page or `visits` go with them; every protection that still applies is moved to the front door and session screens with its original label kept (same address requests [smoke 6] and [8], own fonts and styles only [design 19], no console errors, deep links load the app, the Access page hides the app on previews, unknown `/api` paths answer 404). `build.md` lists every removed and changed test line. `/api/health` and the keep awake workflow are unchanged.
22. **Phone, keyboard, accessibility.** Every new screen at phone size: nothing scrolls sideways at 320 px wide or with text at 200 percent; every control's tap area is at least 44 x 44 (words at least 24 wide and 44 tall); the whole flow works by keyboard alone in reading order; `@axe-core/playwright` finds no WCAG 2.0 to 2.2 A or AA violation in light and dark mode. All job 1 to 5 tests that are not retired by statement 21 stay green and unchanged.
23. **Records.** `docs/conventions.md` adds the `[session N]` label row. `docs/data-model.md` describes `usage_events`, `complete_session` and the removal of `visits`. The README "Running costs" stays at €0. `build.md` gives the reason for each new npm package and the check minutes of one full pull request run.

Product rules from `AGENTS.md` that apply: P1, P2, P3 and P5 as above; one front door, the learner never picks a mode; nothing unmet is reviewed; grammar only behind a tap; gentle corrections, never shaming; nothing unapproved is served; no AI call in this job; GDPR minimum data, export and deletion possible through the job 3 cascade; no users under 18; agents use only the test database; no placeholders or fake data in the app; never delete or weaken a test except as statement 21 states; client facing text in English; the "Not in v3.0" list is binding.

## Threat model (GA)

**What is the worst a malicious person could do here?**
- Read or change another learner's progress. Stopped by the database rules (job 3 and statement 17) and by the Worker never taking a user id or another learner's session from the request. A learner who copies their own cookie out of the browser can call Supabase directly, but only on their own rows, as the database allows.
- Steal a learner's sign in. The tokens sit in cookies the page's scripts cannot read, and the app loads no third-party script.
- Create thousands of guest accounts to fill the database or use up the sign in limit so real learners cannot start. In this job accounts are made only by a same-site JSON `POST`, Supabase's own hourly limit applies, and previews sit behind Cloudflare Access. Before the public launch this needs more (Risks).
- Get unapproved Finnish or audio served. Content and audio are only ever read with the learner's own token through the approval rules; no secret key exists in the Worker.
- Make another site's page act for a learner. `SameSite=Lax` cookies, JSON only, and the `Origin` check.

**What data are we storing that we must protect?**
- The guest's account (`auth.users`: an id, creation and sign in times) and their sign in tokens.
- Their sessions (which dialogue, when, how far), their cards (which forms they met) and their usage event.
- No name, email, audio, answers or device details. Supabase Auth may log the requesting address; through the Worker that is Cloudflare's address, not the learner's (not verified).

**What must the system refuse even if asked nicely?**
- Making an account from a page load, a `GET`, or another website.
- Accepting a user id, a step beyond `understand`, or someone else's session id from the browser.
- Serving a line, word, form or audio file that is not approved with approved parents, or revealing where audio files are stored.
- Making a card for a form the learner has not met in a finished Understand it step.
- Writing tokens, cookies, user ids or IP addresses to any log.
- Using a Supabase secret key or service role key.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | How the browser signs in and reaches the database | The Worker uses `@supabase/supabase-js` with `@supabase/ssr`'s `createServerClient`, whose cookie adapter we write so every cookie is `HttpOnly`, `Secure`, `SameSite=Lax`. Every database call goes through `/api/*` with the learner's own token | `supabase-js` in the browser (Supabase's default pattern) | Breaks the job 1 and 2 rule that the browser calls only its own address (and test [smoke 6]); puts the tokens where any script on the page can read them. Hand-written calls to the Auth API (job 2's style) also lost: token renewal with single-use refresh tokens is subtle and the library already does it |
| 2 | Guest sign up | Supabase anonymous sign in, called by the Worker with the publishable key | The same call with a Supabase secret key and the `Sb-Forwarded-For` header, so Supabase limits each learner's own address | Supabase accepts that header only with a secret key, which bypasses every access rule; jobs 1 and 2 kept secret keys out on purpose. Consequence of the pick: Supabase sees every guest as coming from Cloudflare's address, so its hourly limit is shared by all guests. Fine for private previews; must be settled before launch (Risks) |
| 3 | Saving the end of the session | One database function, `complete_session`, `security invoker`, in one transaction | Three separate calls from the Worker (end the session, add cards, add the event) | A dropped connection between calls leaves half a save. The function adds no rights: the existing rules still apply as the learner |
| 4 | Where the comprehension questions come from | Built from the approved lines and their English glosses by one fixed, tested rule: the lines with the most reviewable words (ties to the earlier line), up to three, each with up to two other glosses from the same dialogue as wrong choices, order fixed by the session id. Borrows v2's "What does this mean?" screen (`design/v2-handoff/app-screens/screens-dayone.jsx`), minus its red wrong state | Questions written in Finnish by the pipeline and approved by the reviewer (the PRD's "in Finnish, English hint on demand") | Needs a new content table, which changes the dialogue contract shared with job 7 (the run plan forbids that inside either job), plus reviewer time. Can be added later as a new table without breaking anything. Consequence: the question is the Finnish line, the answers are English |
| 5 | The "one sentence you can now say" | A fixed rule: the shortest line (by spoken words) with at least two words that have readable forms; ties go to the earlier line; if none qualifies, the shortest line with one | A marker on the dialogue chosen by the pipeline and approved by the reviewer | Same contract reason as 4. Recommended for the manager to add to the contract later as one nullable column; then this rule is replaced |
| 6 | Audio on the word card | The card's two controls play the whole line in that register | A separate audio clip per form | The data model has audio per line only, and about 300 extra clips would be job 7's work and a contract change |
| 7 | What lights up during playback | The line that is playing | Each word as it is spoken, as in the job 5 sample | Needs word timings, which the data model does not hold (contract change) |
| 8 | How audio reaches the browser | `/api/audio/<line id>/<register>` on the Worker, gated by the learner's right to read the line, file fetched by `worker/audio-store.ts` | Direct links to the storage service | Breaks the same address rule, and a storage link can be shared or guessed past the approval rules |
| 9 | Where the usage event lives | Its own table, `usage_events`, as the job 3 spec planned for this job | A true or false column on `sessions` | Job 14 needs more kinds of event; one table with an enum grows without breaking |
| 10 | Test content | A clearly named seed loaded only into throwaway local databases | Waiting for job 7, or seeding the shared test project | Waiting blocks this job; the shared test project must hold only content that went through the pipeline. v2's 104 sentences lost too: the owner ruled they load nowhere until the corrections list arrives, and they have no tokens, forms or audio |
| 11 | Cloudflare invocation logs | Off | Keep them and inspect a sample | Cloudflare's page says only that they hold "Request, Response, and related metadata"; with sign in cookies on every request, off is the safe default. The Worker's own logs stay |
| 12 | Page routing | The plain path check `src/main.tsx` already uses, for `/` and `/session` | React Router | A dependency for two paths |

New npm packages: `@supabase/supabase-js` and `@supabase/ssr` (both MIT, both Supabase's own). Versions are pinned by the builder.

### Notes for the builder

- The anonymous sign in request format (`POST /auth/v1/signup` with no email) is what `signInAnonymously()` sends; read it from `@supabase/auth-js` rather than writing it by hand. Do not trust `getSession()` on the server (Supabase's docs warn against it); the Worker does not need to know who the learner is, because the database takes the id from the token.
- Set `enable_anonymous_sign_ins = true` and a high `[auth.rate_limit] anonymous_users` in `supabase/config.toml`, so the local database can run every browser test. This is local only.
- Whether WebKit keeps `Secure` cookies on `http://localhost` is not verified. MDN says localhost is exempt but does not say which browsers follow that. If WebKit drops them, run the local test server over HTTPS and record it in `build.md`; never drop `Secure`.
- Tokens link to forms per register. For a token with a form, "changed" means `surface_puhe` differs from `surface_kirja`. Line text is split into word buttons by finding each token's `surface` in order in the line's text; if a line cannot be split, the whole session refuses to start with the problem message and the cause goes to `build.md` (never show a half-built line).
- New answer choice rows need a small component in `src/components/` using existing tokens; the design reviewer checks it against `design.md`.
- Coordinate migration timestamps and `config.toml` seed paths with `6-pr-local-db` and `7-content-pipeline` through the manager.

## Contract notes for the manager (settle before the build starts)

These touch the dialogue contract shared with job 7. This spec changes none of it.

1. **Where audio files live.** Job 3 left this to job 7, and the audio route here needs a real store, not only a test fake. Recommendation: settle it now in one place. Either a Cloudflare R2 bucket bound to the Worker (free tier 10 GB a month, egress free, read with no key) or a private Supabase Storage bucket (Free plan 1 GB storage and 5 GB egress a month). R2 avoids a key and egress limits. Whether R2 needs a payment method on file was not checked. `worker/audio-store.ts` implements whichever is picked.
2. **Line text and tokens.** This job assumes each token's `surface` appears, in order, in its line's text for that register. Job 7 should guarantee it.
3. **Later additions, none needed now.** A "key line" marker (Decision 5), authored comprehension questions (Decision 4) and word timings (Decision 7) can each be added later as a new nullable column or table.

## Out of scope

- Say it, recording, the microphone, voice consent (job `10-speaking-feedback`). Only the empty place in the step list exists.
- The daily review screen and grading (job `9-daily-review`). This job only creates cards.
- Adding an email, signing in on another device, signing out, export and delete buttons, the privacy notice, the 90 day guest clean up (job `11-accounts`).
- Writing, reviewing, voicing or publishing any Finnish learning content, choosing the audio store, and any table for content (job 7).
- Onboarding beyond the front door's two lines (job 13), analytics dashboards (job 14), CAPTCHA or Turnstile, rate limiting in the Worker, a Content Security Policy, install and offline behaviour.
- Any AI call.
- From the "Not in v3.0" list: no streaks, rank titles, confetti, milestone ladder or journey map; no vocabulary bank or word counts; no mode picker or practice hub; no grammar lessons; no bilingual or Finnish-only toggle (the English choices in the check are not a toggle); no mnemonics; no YKI content.

## Build plan

1. **Database.** `usage_events`, `complete_session`, the `visits` drop, pgTAP, regenerated types, the fixture seed and local config, the red scratch run. Covers 16, 17, 20, part of 21.
2. **Worker.** Supabase client and cookie adapter, `/api/guest`, `/api/sessions/today`, step and complete routes, `/api/audio`, origin checks, quiet logs, invocation logs off. Unit tests with fakes. Covers 2, 4 to 7, 11, 15, 19.
3. **Screens.** Front door, session flow from the step list, Hear it, Understand it with the check, finish screen, the `SessionFrame` steps option, the answer choice component. Covers 1, 3, 8 to 10, 12 to 14, 18.
4. **Browser tests and clean up.** Full flow tests at phone size on the local database, retiring the Hei! page and re-pointing its protections, accessibility checks, docs and records. Covers 21 to 23 and proves the rest end to end.

**Dependencies.**
- `6-pr-local-db` merged first: pull-request browser tests need a throwaway local Supabase with the Auth service and seeds. Until then the builder runs browser tests locally if Docker is available and says so in `build.md`.
- Before this job merges, the owner turns on anonymous sign ins on the Supabase test project and raises its anonymous sign in limit (both free, in the dashboard's Authentication settings). Without them the preview cannot start a guest after merge.
- New tables reach the shared test project only on merge (owner's rule from job 3), so the branch's preview cannot run a session. The evaluator uses the pull request's browser test videos and screenshots, plus a local run where Docker exists. After merge, the manager opens the preview once: with job 7 merged it shows the real dialogue; without it, the "not ready yet" screen.
- Contract note 1 settled.

## Risks and flags

- **Look closely: learner data.** First job that creates accounts and stores learner progress. Covered by statements 2, 15 to 17 and 19 and the threat model.
- **Look closely: database and access rules.** New table, new function, a dropped table, and the first sign ins on the test project.
- **Look closely: Finnish content.** The fixture holds unreviewed Finnish (lines 1 to 5 of the voice test sheet) and builder-written form names and "why" lines. It lives only in throwaway local databases and never reaches the test project, previews' data or the live app (statement 20). It does not go to the reviewer.
- **Guest abuse before the public launch.** Because the Worker makes every sign up, Supabase's per-address limit becomes one shared limit for all guests: too low and real learners are refused, too high and one person can create many accounts. Supabase "strongly" recommends CAPTCHA or Cloudflare Turnstile for anonymous sign ins. Before liftoff the manager should bring the owner a decision (Turnstile, a secret key with address forwarding, a Worker rate limit, or a mix). Turnstile would add a Cloudflare script to the page. Cloudflare's rate limit binding counts per location and approximately, and its availability on the Free plan was not confirmed.
- **Guests lose progress by clearing the browser.** Supabase's docs say an anonymous user cannot get back in after clearing browsing data or on another device. Job 11 adds email. The front door line says the account lives on this device.
- **No privacy notice yet.** Statement 1's line explains why the account exists, but GDPR's full information duty needs the privacy notice from job 11, which must exist before any learner outside the team uses the app.
- **Running costs.** €0. Supabase Free includes 50,000 monthly active users (whether anonymous users count toward that is not stated). Audio passes through the Worker, which counts against the Workers free request allowance.

## Owner's calls

None for this build. One owner setup step (free, about two minutes), listed under Dependencies. The guest abuse decision in Risks comes to you before launch, not now.

## Could not verify

- The exact anonymous sign up request; the builder reads it from `@supabase/auth-js`.
- Whether `@supabase/ssr` runs unchanged in Cloudflare Workers (Supabase's page shows a Hono example but does not name Workers).
- Whether WebKit keeps `Secure` cookies on `http://localhost`.
- What Cloudflare invocation logs record from request headers.
- Whether anonymous users count toward Supabase's monthly active user limit.
- Whether R2 needs a payment method on file, and whether the Workers rate limit binding is on the Free plan.
- Whether Supabase Auth logs the requesting address, and that through the Worker it is Cloudflare's.
- The exact names of the dashboard settings for anonymous sign ins and their limit.

## Sources

- PRD sections 3, 4.1, 5, 7.4, 8 and 10: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- Data model: `factory/jobs/3-data-model/spec.md`, `docs/data-model.md`, `supabase/migrations/20261020090000_content_model.sql`, `supabase/migrations/20261020090100_learner_model.sql`
- Design system: `factory/jobs/5-design-system/spec.md` and `summary.md`, `design.md`, `src/components/`
- Supabase anonymous sign ins (30 per hour per address, changeable; CAPTCHA advice; no automatic clean up; lost on clearing data): https://supabase.com/docs/guides/auth/auth-anonymous
- Supabase rate limits (`Sb-Forwarded-For` needs a secret key and must be switched on): https://supabase.com/docs/guides/auth/rate-limits
- Supabase server side client (`@supabase/ssr`, `createServerClient`, cookie adapter, do not trust `getSession()`): https://supabase.com/docs/guides/auth/server-side/creating-a-client
- Supabase pricing (Free: 50,000 MAU, 1 GB storage, 5 GB egress, 500 MB database): https://supabase.com/pricing
- Report of Supabase limits counting a Cloudflare Worker's address: https://github.com/AndrewDongminYoo/auto-chatter/issues/164
- MDN `Set-Cookie` (`Secure` on localhost, `SameSite=Lax` and `POST`, `__Host-`): https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Set-Cookie
- Cloudflare Workers Logs (invocation logs content, how to turn them off, 3 days on Free): https://developers.cloudflare.com/workers/observability/logs/workers-logs/
- Cloudflare Workers rate limit binding (10 or 60 second periods, per location, approximate): https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/
- Cloudflare R2 pricing (10 GB a month free, egress free): https://developers.cloudflare.com/r2/pricing/

Result: ready for owner approval


## Manager addendum (21 October 2026): contract settled with job 7

- **Audio location.** Audio files are the static files job 7 publishes under `public/audio/<audio key>`, copied there only for approved lines. This job plays `/audio/<key>` directly. The Worker audio route, the R2 bucket and any Supabase Storage bucket are not built. Reason: no new paid service or account, and the "unapproved line cannot reach a learner" rule holds because only approved lines' files are ever in the build. Statements that mention the audio route are met by the static path instead, and `build.md` says which.
- **Token text.** Job 7 guarantees each token's text appears in order in its line's text (job 7 statement added in its addendum). This job may rely on it.
- **Highlight.** Whole line highlighted during playback, no word timings, as this spec decided.
