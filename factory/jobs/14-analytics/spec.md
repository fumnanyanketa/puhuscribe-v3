# Job 14-analytics: Analytics, feedback and crash reporting

Scope item 14. GA. Needs a decision. Date: 30 October 2026. Builds on main as merged, including jobs 8-first-session, 9-daily-review, 10-speaking-feedback, 11-accounts and 13-review-site (with the review site's move to `puhuscribe-review.exentrik.co` from pull request 11). Test label: `[analytics N]`.

## Summary for the owner

1. PuhuScribe counts its own visits. Each day it adds one to a tally per country (for example "Finland, 30 October: 14"). It stores nothing else about the visitor: no address, no cookie, no browser details. The tally lives in your EU database.
2. A visit means someone arriving at the app from a link, a bookmark, the home screen or by typing the address. Moving between screens inside the app does not count, and neither do files or obvious robots. One person who opens the app three times counts three times, because without an identifier nobody can be counted only once.
3. You get one private owner page at `https://puhuscribe-owner.exentrik.co` with the launch numbers: day 7 retention, median session length, the share of learners who use speak back, AI and speech cost per active learner, visits by day and country, the newest feedback and recent crashes. Three locks guard it: a Cloudflare login, your own PuhuScribe account, and a check inside the app.
4. Learners can send short feedback from the account page, the front door and the finish screen. Errors in the app are caught and stored, with nothing that identifies the learner, so you can see what broke.
5. Costs €0 with my recommendation for crash reports (owner's call 1). The real numbers start only once the live app runs at `puhuscribe.exentrik.co`, which is a separate step (owner's call 2).

## Owner's calls

**1. Where crash reports go.** A crash report is a short note the app writes when something breaks: what error, in which file, on which screen, in which browser.

- **A. PuhuScribe stores its own crash reports (recommended).** Reports go to your EU Supabase database through the app's own address and show on the owner page. No new service, no new account, €0. Kept 30 days. You get a simple list grouped by error, without the full tooling of a crash service (no email alerts, no source code view, no release tracking).
- **B. Sentry, free Developer plan.** The best known crash service. Free plan: 5,000 errors, 1 user, 30 day lookback (Sentry's price page). Team plan $29 a month if you outgrow it. Error data can be stored in Frankfurt if you choose the EU region when you create the account, and that choice cannot be changed later. Your account details, organisation settings and access keys are stored in the United States whatever you pick (Sentry's data storage page). A new company processes learner error data, so the privacy notice must name it, and a new outside address receives data from every learner's phone.
- **C. GlitchTip, hosted free plan.** An open source copy of Sentry. Free plan: 1,000 events a month, kept 30 days; paid from $15 a month for 100,000 (GlitchTip's price page). It offers an EU instance in Germany. The page does not say who runs the hosting or under which data terms, so this needs checking before use. 1,000 events a month can run out quickly if one bug repeats.
- Recommendation: **A**. It needs no new service, keeps the data in your EU database, and fits the "no third party script or counter" rule you set today. The code sits behind one module, so moving to B later changes that module only.

**2. When the live app goes up.** The counter and the owner page only see real visitors once the app runs at `https://puhuscribe.exentrik.co` with a live database. That does not exist yet: `wrangler.jsonc` says the production Worker "is created separately at liftoff, by the owner", the app's previews run in a different Cloudflare account from the one that holds `exentrik.co` (job 13's addendum), and agents may never touch a live database.

- **A. A separate go live job after this one (recommended).** This job ships fully tested on local and test databases. The go live job creates the production Worker in the Exentrik account, the live Supabase project in the EU, both addresses and the owner page's Cloudflare login, with you doing the live steps. Real visitor numbers start on the day it goes live.
- **B. Add going live to this job.** Real numbers sooner, but the job roughly doubles in size, several steps must be done by you by hand on the live database, and approval waits for all of it.
- Recommendation: **A**. It keeps this job testable without the live database and makes going live one clear, reviewable step.

**Owner inputs (not choices):**
- Which of your email addresses goes into the owner page's Cloudflare login and onto the owner list. The manager will ask; it never picks one.
- Confirm the owner page address `puhuscribe-owner.exentrik.co`, or give another name under `exentrik.co`.
- About 15 minutes of setup at go live (Build plan, step 6).

No design direction call: the two new screens reuse the locked design system.

## What it is

The app learns whether it works for learners, without watching them. It counts arrivals per country and day, works out the launch numbers from data the app already stores, lets learners send a short message, and catches errors. The owner reads all of it on one private page. It serves the principles indirectly: P4 is measured directly (the speak back share), and retention and session length show whether the loop of P1 to P3 keeps learners coming back.

How it stays inside the PRD's "Not in v3.0" rule ("Owner Insights dashboard beyond a minimal tester count"): the owner page shows the tester count and only the few numbers the PRD itself sets as launch goals and cost target, plus the visits, feedback and crashes this scope item asks for, on one page with no charts, filters, per learner views or exports.

## Done when

Terms used below.
- **Helsinki day**: a calendar day in the `Europe/Helsinki` time zone, worked out in Postgres, never from the device (as in job 9).
- **The window**: the 30 Helsinki days ending today, today included.
- **Learner**: an account in `auth.users` (guest or email) that is not on the owner list.
- **Active learner**: a learner with at least one `sessions` row whose `started_at` falls in the window.
- **Owner host**: the hostname in the Worker variable `OWNER_HOSTNAME` (live: `puhuscribe-owner.exentrik.co`). **App host**: any other hostname the Worker answers on.
- **Browser test**, **phone size** and **the fixture** mean what they mean in jobs 8 and 11: Playwright at 375 x 812 in Chromium and WebKit, against the built app and a throwaway local Supabase. Browser tests that check visit counting set a normal (not headless) user agent on their browser context.
- Tags: **[security]** and **[personal data]** mark statements the security reviewer and the evaluator check closely.

### Counting visits

1. **What counts as one visit.** The Worker counts a request as one visit only when all of these hold: the method is `GET`; the host is the app host; the path is one of the app's page routes (statement 3); the `Accept` header contains `text/html`; `Sec-Fetch-Dest` is absent or `document`; no `Sec-Purpose` or `Purpose` header mentions `prefetch` or `prerender`; a `User-Agent` header is present and does not match the obvious robot list (Decision, note 1); and the request is an arrival, not a move inside the app. An arrival means `Sec-Fetch-Site` is `none`, `same-site` or `cross-site`; when `Sec-Fetch-Site` is absent (older browsers), the `Referer` is absent or names another origin. A Vitest table test covers each rule with a request that counts and one that does not, including a move from `/` to `/session` (not counted), a reload of `/` (counted), `HEAD`, `/api/today`, `/assets/index.js`, a link preview robot, `curl`, and an old browser with no `Sec-Fetch-*` headers arriving from a search engine (counted).
2. **The country comes from Cloudflare and nothing else is kept.** The country is `request.cf.country` when it is two capital letters. A missing value, or Cloudflare's `XX` (no country data), is stored as `XX`; `T1` (Tor) is stored as `T1`. The Worker reads the user agent, referer and fetch headers only to decide statement 1 and never passes them on. Nothing is read from or written to the visitor's device for counting: no cookie, no local storage, no script. Vitest checks the country rules and that the database call carries only the country. **[personal data]**
3. **Only page requests reach the Worker; files stay free.** `wrangler.jsonc` sets `assets.binding` to `ASSETS` and lists in `run_worker_first` the `/api/*` pattern plus each page route of `src/App.tsx` (today `/`, `/session`, `/account`, `/account/*`, `/sign-in`, `/privacy`, plus this job's `/feedback` and `/owner`). The Worker answers page routes with `env.ASSETS.fetch(request)`. A repository test fails if a route in `src/App.tsx` is missing from the list, or if any file in the built `dist/` matches a `run_worker_first` pattern, so files never run the Worker.
4. **Counting never slows or changes the page.** The tally is written after the page is answered (`ctx.waitUntil`), and a failed write is dropped silently. The page answer is byte for byte what `env.ASSETS.fetch` returned: no added `Set-Cookie`, no added header, no log line. Vitest with a database fake that fails or hangs proves the page still arrives unchanged.
5. **The tally table holds a day, a country and a number.** `private.visit_tallies` has exactly the columns `day date`, `country text` (two capital letters) and `visits bigint`, with `(day, country)` as the key. No API role can read or write it. A pgTAP test checks the exact column list from the catalogue, so a later column (an address, a time, a user id) turns the check red. **[personal data] [security]**
6. **One narrow door adds to the tally.** `public.count_visit(p_country text)`: `security definer`, `search_path = ''`, returns nothing. It refuses any value that is not two capital letters, takes the day from the database clock in Helsinki time (never from the caller), and adds one with an insert that adds to the existing row on conflict. Execute is revoked from `public`, `authenticated` and `service_role` and granted to `anon` only (the Worker calls it with the publishable key and no sign in). pgTAP proves: two calls make a count of 2; `fi`, `FIN`, `F1` and an empty value are refused and write nothing; two calls from two connections at once both count; `anon` cannot read the table; `authenticated` cannot execute the function. **[security]**
7. **No outside counter, no outside requests.** A browser test walks a guest from the front door through the fixture session, the feedback page and the account page, and fails if any request leaves the app's own origin. A repository test fails if `index.html` or the built files load a script from another origin. The owner page is not counted: requests to the owner host never call `count_visit` (Vitest).

### The numbers

8. **One database function computes every number.** `public.owner_dashboard()` returns one JSON object with exactly these keys, each with a plain English definition in `docs/data-model.md`:
   - `visits_by_day`: for each Helsinki day of the window, the total visits and the visits from `FI`;
   - `visits_by_country`: each country's total over the window, largest first;
   - `active_learners`: the count of active learners (this is the tester count);
   - `day7_retention`: among learners whose first ever session started on a Helsinki day D with D + 7 between the window's first day and yesterday, how many started a session on day D + 7, as `retained`, `cohort` and a percentage;
   - `median_session_minutes`: the median of `ended_at` minus `started_at` over sessions started in the window that have an end time and lasted at most 2 hours, with the number of sessions used and the number left out (no end, or longer);
   - `speak_back`: among active learners, how many have at least one `speaking_attempts` row created in the window, as a count, the base and a percentage;
   - `ai_cost_usd`: the sum of every `cost_usd` recorded by learners in the window (today only `speaking_attempts`), as the total and the amount per active learner, in US dollars as recorded;
   - `feedback`: the newest 50 messages (statement 20);
   - `crashes`: the newest 20 crash groups (statement 27);
   - `computed_at`.
   Accounts on the owner list are left out of every learner number. The `first_session_completed` event is not used, because a learner can claim it (job 8 security review). pgTAP seeds backdated learners as `postgres` and checks each number against a hand worked answer, including empty data (no division by zero; percentages show as none).
9. **Only the owner can run it, from a live sign in.** `public.owner_dashboard()`: `security definer`, `search_path = ''`, no arguments, execute for `authenticated` only. It returns nothing and writes nothing unless `auth.uid()` has a row in `private.owners` and the token's `session_id` is still in `auth.sessions` (job 11's live sign in rule). pgTAP gives each condition its own failing case: a learner not on the list; an owner whose sign in was ended; `anon`. Removing each condition on a scratch branch turns only its own test red (run links in `build.md`). **[security]**
10. **Every future cost is counted.** A pgTAP catalogue test finds every table in the project's schemas with a `cost_usd` column, seeds one row in each, and fails if `owner_dashboard()`'s cost total misses any. So the tutor job cannot log an AI cost the owner page does not see.
11. **No anti metric, no per learner view.** The JSON keys equal the list in statement 8 exactly (pgTAP). Its text holds no learner's user id and no email address (pgTAP searches it for every seeded id and email). A repository test fails if the owner page or the function mentions words learned, forms learned, streaks or screens per session.
12. **A test learner's journey moves each number.** One browser test with backdated seeding: first the owner page shows the fixture's starting numbers; then a test learner arrives (visits plus one, from the country the test sets in `request.cf`), starts a first session on day D and another on day D + 7, finishes a session of a known length, makes one speech check with the fake provider (cost recorded), sends feedback, and causes a browser error. After a reload each of the seven numbers (visits by day, visits by country, active learners, day 7 retention, median session, speak back, cost), the feedback list and the crash list show the expected change, each asserted on its own.

### The owner page

13. **Its own address.** On the owner host, the Worker answers only `/owner`, `/sign-in`, files, and the routes `/api/owner/dashboard`, `/api/crash`, `/api/health`, `/api/me`, `/api/sign-in`, `/api/sign-in/verify` and `/api/sign-out`; any other page route redirects to `/owner`, and any other `/api` route gets 404. On the app host, `/api/owner/*` gets 404. When `OWNER_HOSTNAME`, `OWNER_ACCESS_TEAM_DOMAIN` or `OWNER_ACCESS_AUD` is missing, no host is treated as the owner host. Vitest. **[security]**
14. **Lock one and two: Cloudflare Access, and the Worker checks its token too.** At go live, Access covers the whole owner host (Build plan, step 6). In addition, every page and `/api` request to the owner host needs a `Cf-Access-Jwt-Assertion` token signed by the team's Access keys, issued by `OWNER_ACCESS_TEAM_DOMAIN`, with audience `OWNER_ACCESS_AUD`, checked by the Worker with the same method as job 13 (`jose`, keys fetched from the team's certs address). Vitest with a locally made key: no header, a malformed token, a wrong signature, a wrong audience, a wrong issuer and an expired token each get 403 with one plain line; a valid token goes on. Replacing the check with "always allow" turns these tests red (run link in `build.md`). The built app files on the owner host are the same public files the app host serves, so only Access guards them. **[security]**
15. **Lock three: the owner's own PuhuScribe account.** On the owner host the owner signs in with job 11's email code flow (no guest accounts are made there). `GET /api/owner/dashboard` calls `owner_dashboard()` with the owner's token. A signed in account not on the owner list sees "This account cannot open the owner page." and no number. No secret key or service role key is used. **[security]**
16. **The owner list.** `private.owners` holds only `user_id` (linked to `auth.users`, deleted with the account) and `added_at`. No API role can write it, and a learner can read only their own row, so `export_my_data()` lists it and job 11's catalogue test stays green. The migration creates it empty. The README gives the owner the one SQL line to add themselves on a project (run in the Supabase SQL editor, typing their own email there), and says the email never goes in a file. pgTAP: a learner cannot add themselves, cannot read another row, and a learner's export shows an empty list. **[security] [personal data]**
17. **One plain page.** `/owner` shows, top to bottom: "Learners" (active learners; day 7 retention as "x percent (a of b learners)" with the goal "at least 25 percent"; median session as "m minutes, from n finished sessions" with the goal "at least 8 minutes"; speak back as "x percent (a of b)" with the goal "at least half"; AI and speech cost as "$t in total, $p per active learner" with the PRD target "under €0.75 a month"); "Visits" (a real table of the window's days with "All visits" and "From Finland", then countries by visits with English names from `Intl.DisplayNames`, falling back to the code, `XX` as "Unknown" and `T1` as "Tor network"); "Feedback"; "Crashes"; and the time the numbers were worked out. One short sentence under each number says what it counts. No charts, filters, date pickers or exports. It follows `design.md` and the banned list in `AGENTS.md`.
18. **Owner host answers are private.** Every owner host response from the Worker carries `X-Robots-Tag: noindex, nofollow`, `Cache-Control: private, no-store`, `Referrer-Policy: no-referrer` and a `Content-Security-Policy` with `frame-ancestors 'none'`. `/api/owner/dashboard` accepts only `GET`, never sends `Access-Control-Allow-Origin`, and refuses a request whose `Origin` or `Sec-Fetch-Site` shows another origin, including the app host. Vitest. **[security]**

### Feedback

19. **A quiet link, a short form.** A quiet "Send feedback" link sits on `/account`, on the finish screen, and on the front door when this device has an account. It opens `/feedback` with the heading "Send feedback", the line "Tell us what worked, what did not, or what broke. Please do not include personal details.", one labelled text box "Your message" (1 to 1,000 characters, with a count), and a primary "Send" button. After sending: "Thank you. Your message is sent." Without an account the page says "Start your first session, then you can send feedback." with a link to the front door. The loop itself gains no step and no prompt.
20. **The owner reads it.** The owner page lists the newest 50 messages with the date, the screen it came from (front door, account, finish) and whether the account is a guest or email account. It never shows a user id or email. Text shows as plain text, never as HTML: a message holding `<script>` or `<img onerror>` shows as typed and runs nothing, and links are not clickable. A 40 letter word wraps at 375 px (`overflow-wrap: anywhere`). Browser test.
21. **Stored with the learner's account.** `public.feedback` holds `id`, `user_id` (linked to `auth.users`, deleted with the account), `created_at` (database default), `screen` (one of `front_door`, `account`, `finish`) and `message` (1 to 1,000 characters). Learners may add rows for themselves (columns `user_id`, `screen`, `message` only) and read their own; nobody may change or delete through the API. The owner reads only through `owner_dashboard()`. pgTAP: learner A cannot read B's messages, cannot add one for B, cannot set `created_at`; `anon` can do nothing. **[security] [personal data]**
22. **Five a day, enforced in the database.** A learner can send at most 5 messages per Helsinki day; the 6th is refused, and parallel requests cannot beat the limit (pgTAP from two connections; the rule takes a lock per learner). `POST /api/feedback` (JSON, same origin, body read and capped at 8 KB before answering) answers 201, 400 for an empty or too long message, and 429 with the gentle line "You have sent 5 messages today. Please try again tomorrow." **[security]**
23. **Part of the learner's data.** Feedback is in `export_my_data()`, in `src/privacy/data-inventory.ts` and in the privacy notice. It is deleted with the account, including job 11's automatic clean up of unused accounts, so it is kept exactly as long as the account. Job 11's catalogue and export tests pass unchanged. **[personal data]**

### Crash reports (owner's call 1, option A; with B or C only the provider module and where reports are read change)

24. **Errors are caught.** In the browser, listeners for `error` and `unhandledrejection` and a React error boundary around the app catch errors. The boundary shows, in the problem style, "Something went wrong on this screen." with a "Reload" button. In the Worker, an unexpected exception in any route answers 500 with `{"error":"server_error"}` and is reported; the existing handled answers (503 `not_available` and others) are not crashes. The browser sends at most 5 reports per page load and each distinct error once, by `fetch` with `keepalive`, falling back to a plain `fetch` where `keepalive` is missing.
25. **A report holds only an allow list, and nothing that identifies a learner.** `POST /api/crash` (JSON, same origin, body capped at 8 KB) accepts only: `source` (`browser`), the error `name` (at most 80 characters), `message` (at most 300 after cleaning), up to 10 stack frames of file name, line, column and function name (own bundle files only), and the page path with every id replaced by `:id` and no query or fragment. The Worker adds the app version (the build's commit) and a coarse browser and system label from the user agent (for example "Safari 17, iOS"), then drops the user agent. Cleaning removes email addresses, ids, token shaped strings, digit runs of 6 or more, and query strings in any URL. Never sent or stored: a user id, address, cookie, header, full user agent, typed answer, transcript, feedback text or form value. Vitest feeds reports holding an email, a token, a session id in the path and a typed answer through the route and checks none is stored; a browser test types an answer in review, forces an error on that screen, and checks the stored report does not contain the answer. **[personal data] [security]**
26. **Stored in the EU database through a narrow door.** `private.crash_reports` has no column for a user, address or user agent. `public.report_crash(...)`: `security definer`, `search_path = ''`, execute for `anon` only, checks every field's length and shape again (a direct caller skips the Worker), computes the group from the error name and first frame, and drops reports past 300 an hour in total or 30 an hour per group, counted under a lock so parallel calls cannot beat it. A daily `pg_cron` job deletes reports older than 30 days. pgTAP proves each refusal, the caps, the deletion, and that no API role can read the table. **[security]**
27. **A forced error shows up.** The owner page has a "Send a test error" button that throws a real error in the page. After a reload, the crash list shows it grouped, with its count in the last 30 days, last seen time, path `/owner`, browser label, app version and frames. A browser test in both browsers does this, and a second one throws an error on the learner front door with Playwright and finds it on the owner page. A Vitest test makes a route throw and finds the report sent to the database fake.
28. **One module.** Sending reports to the database sits in `worker/providers/crash-reports.ts`, the only file that knows where reports go, and it is listed under Supabase in `src/privacy/processors.ts`. A repository test fails if any other file calls `report_crash`.

### Shared rules, privacy notice and records

29. **The privacy notice says it plainly.** New facts on the visit count, feedback and crash reports, written from the table below. No new processor under option A. `PrivacyPage` tests check each new section. **[personal data]**
30. **Job 8's protections cover every new route.** Every new route that changes something accepts only `POST` with JSON and answers 403 to another site's `Origin`. No answer sends `Access-Control-Allow-Origin`. The visit counter and `/api/crash` never read or renew sign in cookies. The Worker logs no feedback text, crash content, country, user id or token (unit test watching `console`). The browser never holds a token or calls a `supabase.co` address. **[security] [personal data]**
31. **Phone, keyboard, accessibility.** `/feedback` and `/owner` at phone size: nothing scrolls sideways at 320 px or with text at 200 percent; every control is at least 44 x 44; each field has a visible label; everything works by keyboard; `@axe-core/playwright` finds no WCAG 2.0 to 2.2 A or AA violation in light or dark mode; every button has explicit token colours (job 5 lesson).
32. **Records.** `docs/data-model.md` adds the four new tables, the new functions and each number's definition. `docs/conventions.md` adds the `[analytics N]` row. The README lists the owner page setup steps and the owner list SQL line, and keeps running costs at €0. `src/lib/database.types.ts` is regenerated by the Supabase CLI. All earlier tests stay green.

### Proven after go live (owner's call 2)

33. **Live check.** Once the live app and the owner host exist, the owner opens `https://puhuscribe.exentrik.co` from a phone on a Finnish connection, then opens the owner page in a private window, signs in to Cloudflare Access and to PuhuScribe, and sees one more visit from Finland today. An anonymous request to the owner host lands on Cloudflare's sign in page and shows no number. Evidence screenshots hide every email address. The manager keeps the feature `failing` until this passes, as with job 13.

Product rules from `AGENTS.md` that apply: GDPR minimum data, export and deletion (feedback is exported and deleted; tallies and crash reports hold no personal data); AI at the edges, every AI call logged with its cost (statement 10); one front door, one loop (feedback is a quiet link outside the loop); no streaks and nothing from the "Not in v3.0" list; agents use only the test database; no keys in code, logs or chat; no placeholders; never weaken a test; client facing text in English; the providers rule (statement 28).

## Privacy notice facts

The builder writes the new notice text from these facts only. The owner approves the wording at final approval.

| Topic | Fact for the notice | Source |
|---|---|---|
| Visit count | When you open PuhuScribe, we add one to a count for your country and the day. The country comes from your internet address, which we do not keep. We store no cookie, identifier or browser details for this. Legal reason: our legitimate interest in knowing how many people use the app and from where (GDPR Article 6(1)(f)). Kept as daily totals. | This job |
| Feedback | The message you send, which screen you sent it from, and when. Stored with your account and deleted with it, including when an unused account is deleted automatically. Legal reason: needed to provide the service you asked for (Article 6(1)(b)). | This job |
| Crash reports | When the app breaks, it records the error, the file and line, the screen, the app version and a short browser label such as "Safari 17, iOS". Not linked to your account, and nothing you typed or said is included. Deleted after 30 days. Legal reason: legitimate interest in keeping the app working (Article 6(1)(f)). | This job |
| Where | Supabase, EU (Ireland), as today | Job 11 |

## Threat model (GA)

**What is the worst a malicious person could do here?**
- Read the owner page: every learner number and every feedback message. Needs the owner's Access login (an email code), the owner's PuhuScribe sign in (another email code), and a token the Worker accepts (statements 13 to 16). A script injected into a learner page cannot read owner data: the owner host keeps its own cookies, and the owner route refuses requests from any other origin and never allows cross origin reading (statement 18).
- Read another learner's feedback. Read rules allow only one's own rows; the owner function shows no id or email (statements 11, 21).
- Push the visit count up by reloading or scripting requests. Possible, as with any counter that keeps no identifier. It changes a number, not data. Statement 1 drops obvious robots, and the owner page shows learner numbers beside visits, so a jump in visits without learners is visible. Accepted and stated.
- Fill the crash list with junk to hide real crashes, or fill the database. Capped at 300 an hour and 30 per group, deleted after 30 days (statement 26). Real crashes can be dropped during such a flood; accepted.
- Use feedback to send spam or abuse to the owner. Needs an account, at most 5 a day per account, 1,000 characters, shown as plain text with no clickable links (statements 20, 22). Supabase's anonymous sign in limit bounds new guest accounts; the launch decision from job 8 (Turnstile, address forwarding or Worker limits) covers mass guest creation.
- Skew the launch numbers. A learner can change their own session end times and add their own cost rows with their own token (job 8 note). One learner moves a share by at most one learner, and a median resists one outlier, but the cost total can be inflated, so check it against the Azure bill each month (Risks).
- Use up the Workers Free limit of 100,000 requests a day, which now includes page loads. The same is true of every `/api` route today; it is part of job 8's launch decision.
- Plant script through a feedback message or crash message. Both are rendered as text only (statements 20, 25).

**What data are we storing that we must protect?**
- Feedback messages, which are free text and may hold whatever a learner types, linked to their account.
- The owner list, which says which account opens the owner page.
- The tallies and crash reports hold no personal data by design. The protection is that they stay that way: statements 5, 25 and 26 check their columns and contents.

**What must the system refuse even if asked nicely?**
- Storing an address, cookie, identifier, user agent or time of day with a visit, or reading anything from the device to count it.
- Showing which learner sent which feedback, or any per learner number, list or export.
- Running `owner_dashboard()` for anyone not on the owner list, or from a signed out token.
- Using a Supabase secret key or service role key.
- Accepting a crash report field outside the allow list, or storing a typed answer, transcript or feedback text in one.
- Counting visits on the owner host, or adding any third party script or counter.
- Tracking words learned, streak length or screens per session.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | How a visit is seen | The Worker counts the page request the browser already sends, with `run_worker_first` on page routes only | A small script in the app that sends `POST /api/visit` on start | The EDPB's guidelines on the ePrivacy storage and access rule (2/2023) treat making a device send information, as tracking pixels do, as "gaining access", which can need consent. Counting the request the browser sends anyway to load the page avoids that question. A script also adds a request per page load. (Not legal advice.) |
| 2 | What one visit is | An arrival: a page request not made from another PuhuScribe page, judged by `Sec-Fetch-Site`, with `Referer` as the fallback for older browsers | Every page load | The app moves between screens with full page loads (`window.location.assign` in `FrontDoor.tsx` and `AccountPage.tsx`), so one sitting would count three or four times |
| 3 | Unique visitors | Not counted | A daily hash of address and browser, as some privacy friendly counters do | The owner's rule: nothing that identifies a person and no identifier. Returning learners are measured by the learner numbers instead |
| 4 | Where the tally is kept | `private.visit_tallies` in the EU Supabase, written only through `count_visit()` by `anon` | Cloudflare Workers Analytics Engine | The owner's decision is the project's own EU database; Analytics Engine keeps the data at Cloudflare |
| 5 | Owner page location | Its own hostname, `puhuscribe-owner.exentrik.co`, served by the same Worker, with Access over the whole hostname and the Worker's own token check | A path, `/owner`, on the app's hostname, with Access on that path | On one hostname the owner's sign in cookie and Access cookie sit beside every learner page, so a script injected into a learner page could call the owner routes as the owner. A separate hostname gives the owner page its own cookies, and Access protecting a whole hostname avoids path matching mistakes |
| 6 | How the Worker reads numbers about all learners | The owner signs in with their own PuhuScribe account; `owner_dashboard()` checks an owner list and a live sign in | A Supabase secret key in the Worker | A secret key bypasses every access rule, and jobs 1, 2, 8 and 11 kept it out on purpose. A third option, a read only Postgres login over a direct database connection, also lost: a new database driver and a new password secret in the Worker, for the same result |
| 7 | Where feedback goes | A table in the EU database, shown on the owner page | An email to the owner | No email sender for real use exists yet (job 11, owner's call 1) |
| 8 | Who may send feedback | Signed in learners (guest or email), 5 a day | Anyone, without an account | Without an account there is nothing to limit by except the address, which the owner's rules keep out |
| 9 | Feedback retention | Kept as long as the account (deleted with it and by job 11's automatic clean up) | A separate 12 month limit | The account rules already bound it (90 days for unused guests, 24 months for email accounts), and the notice already states them. The owner can ask for a shorter limit |
| 10 | Crash reports | Own reports in the EU database (owner's call 1, A) | Sentry Developer plan | See owner's call 1 |
| 11 | Retention cohort | First ever session, by `sessions.started_at` (set by the database; a learner cannot write it) | The `first_session_completed` event | A learner can claim that event (job 8 security review) |
| 12 | Time span | One fixed window, the last 30 days | A date picker | A filter is the start of a broader insights dashboard, which the PRD rules out; the PRD's own targets are measured 30 days after launch |
| 13 | Cost currency | US dollars, as recorded in `cost_usd` | Converted to euros | Conversion needs a rate source and changes old numbers; the PRD's euro target is shown beside it as text |

**Notes for the builder.**
1. The obvious robot list matches the user agent, ignoring case, against: `bot`, `crawl`, `spider`, `slurp`, `preview`, `facebookexternalhit`, `embedly`, `curl`, `wget`, `python`, `httpclient`, `java/`, `go-http-client`, `node-fetch`, `axios`, `headless`, `lighthouse`, `pingdom`, `uptime`, `monitor`. Keep it in one exported list with its tests.
2. Workers need `fetch(request, env, ctx)` for `ctx.waitUntil`; `worker/index.ts` uses two arguments today.
3. Reuse job 13's token check. If it moves to a shared module, the review site's tests must stay green unchanged.
4. Postgres grants `EXECUTE` on new functions to `public` by default. Revoke it in writing for every new function.
5. Coordinate the migration timestamp with any open job through the manager.

## Contract notes for later jobs

1. **Tutor step (scope item 12)**: every runtime AI call stores its cost in a `cost_usd` column of a learner table; statement 10's catalogue test makes the owner page include it.
2. **Landing page (job 15)**: if this Worker serves it on the app host, add its route to `run_worker_first` and it is counted. If it lives elsewhere, it needs its own counting decision; no outside counter either way.
3. **Installable app (job 16)**: its service worker must send page requests to the network when online, or arrivals from the home screen are not counted. Its tests should check this.
4. **Go live (owner's call 2)**: the production Worker sets `OWNER_HOSTNAME`, `OWNER_ACCESS_TEAM_DOMAIN` and `OWNER_ACCESS_AUD`, attaches both hostnames, and the owner adds themselves to `private.owners` on the live project.

## Out of scope

- Going live: the production Worker, the live database and attaching the hostnames (owner's call 2).
- Unique visitor counts, sessions per visitor, paths through the app, time on page, referrer or campaign tracking, device or screen statistics.
- Charts, date pickers, filters, exports, per learner views, cohort tables beyond day 7, email alerts or weekly reports.
- Replying to feedback, deleting or tagging feedback on the owner page, a public feedback board, ratings or stars.
- Source maps on the owner page, release tracking, performance monitoring.
- Any third party script, counter, tag manager or crash service under option A.
- Turnstile, Worker rate limits and the guest sign in limit (job 8's launch decision).
- Cloudflare Web Analytics (switched off by the owner).
- From the "Not in v3.0" list: no Owner Insights dashboard beyond the minimal page above; no streaks, rank titles or milestones; nothing shown to learners about their own numbers.

## Build plan

1. **Database.** One migration: `private.visit_tallies` and `count_visit()`; `public.feedback` with its rules and daily limit; `private.owners`; `private.crash_reports`, `report_crash()` and its 30 day `pg_cron` job; `owner_dashboard()`; the export update; grants and revokes written out. pgTAP, the cost catalogue test, the scratch red runs, regenerated types. Covers 5, 6, 8 to 11, 16, 21 to 23, 26.
2. **Worker.** Page routing through `ASSETS`, the visit rules and counter, owner host routing and token check, `/api/owner/dashboard`, `/api/feedback`, `/api/crash`, the crash provider module, the top level error catch, quiet logs. Vitest with fakes. Covers 1 to 4, 7, 13 to 15, 18, 22, 24, 25, 28, 30.
3. **Screens.** `/feedback` and its three links, the error boundary, `/owner` with its sections and the test error button, privacy notice and inventory updates. Covers 17, 19, 20, 23, 24, 29, 31.
4. **Browser tests.** The journey test, the forced error tests, the owner page tests with a locally made Access token on a test owner host, the outside request test, accessibility. Covers 7, 12, 20, 25, 27, 31.
5. **Records.** Docs, README, conventions. Covers 32.
6. **At go live (owner, about 15 minutes, with the builder's click steps).** In the Exentrik Cloudflare account: an Access self hosted application for `puhuscribe-owner.exentrik.co` with One-time PIN and one Allow policy holding the owner's email, plus the evaluator's service token policy; the three Worker variables; the owner list SQL line on the live project. Covers 33.

**Dependencies.**
- Pull request 11 (review site moved to `puhuscribe-review.exentrik.co`) merged, so `puhuscribe.exentrik.co` is free for the app.
- The Exentrik account's Zero Trust setup from job 13. The owner already holds a seat there, so no new seat is needed.
- Owner's call 2 for statement 33.
- Preview links still wait for the Cloudflare preview keys (todo, 29 October). Until then the evaluator runs the app locally, and the owner host is tested locally with a locally made Access key.

## Risks and flags

- **Look closely: learner data.** Feedback is new free text linked to accounts. Crash reports come from every learner's phone and must stay free of personal data; statement 25 is the main protection.
- **Look closely: database and access rules.** Two functions callable by `anon` without sign in (`count_visit`, `report_crash`) and one `security definer` function that reads every learner's rows (`owner_dashboard`). The pgTAP tests and the scratch red runs are the main protection.
- **Look closely: a new private address on the owner's domain.** If the Access policy were wrong, the Worker's token check and the owner account would be the remaining locks.
- **Legal reading.** The visit count relies on legitimate interest and on counting only what the browser sends to load the page. Browser crash reports are sent by the app's own script and are treated as needed to keep the service working. This is not legal advice; the owner may want a privacy professional to read the notice before public launch, as job 11 already suggested.
- **Numbers learners can change.** Session end times and recorded costs are written with the learner's own token. Check the cost line against the Azure bill each month.
- **Deleted accounts leave the numbers.** When a learner deletes their account, their sessions, attempts and feedback go too, so past numbers can drop. The tallies and crash reports are not affected.
- **Running costs.** €0 under option A. App page loads now run the Worker and count toward Workers Free's 100,000 requests a day (they were free file requests before). At test and launch traffic this is far below the limit. Past the limit, Cloudflare answers with error 1027 unless the Worker is set to fail open. Option B or C adds a new outside company and possible costs later.
- **Small numbers.** With a handful of testers, a percentage moves by many points per learner; the page shows "a of b" beside every percentage for that reason.

## Could not verify

- The `XX` and `T1` country values come from a search summary of Cloudflare's header docs; Cloudflare's Request page says only "two-letter country code" and that the value can be null. The tests cover both values and a missing value either way.
- Whether `env.ASSETS.fetch` applies the `single-page-application` fallback (the docs say `not_found_handling` applies to it), and exactly how `run_worker_first` matches a pattern such as `/account` without a wildcard. The builder records both in `build.md`.
- How each browser sets `Sec-Fetch-Site` on a reload and on a home screen launch. Statement 1's tests fix our rule; real browsers are checked by hand on one iPhone and one Android phone at go live.
- Sentry's docs page does not say whether the EU region is on the free plan; a search summary of Sentry's own FAQ says it is. GlitchTip's price page does not say who runs the hosting or under which data terms.
- Whether Workers Free fails open or closed by default when the daily limit is passed.
- Whether `Intl.DisplayNames` exists on every phone the owner uses; the page falls back to codes.

## Sources

- PRD sections 3, 4.1, 12 and 13: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- Project: `docs/scope/scope.md` items 14 and 15, `docs/data-model.md`, `factory/todo.md` (job 8 note on `first_session_completed`), `factory/features.json`, `factory/progress.md` (30 October), `factory/jobs/11-accounts/spec.md`, `factory/jobs/13-review-site/spec.md` and its addendum, `wrangler.jsonc`, `worker/index.ts`, `worker/api.ts`, `worker/http.ts`, `src/App.tsx`, `src/privacy/processors.ts`, `supabase/migrations/20261020090100_learner_model.sql`, `supabase/migrations/20261022072903_speaking_feedback.sql`, README running costs
- Cloudflare Workers Request (`request.cf.country`): https://developers.cloudflare.com/workers/runtime-apis/request/
- Cloudflare visitor location header (`XX`, `T1`): https://developers.cloudflare.com/fundamentals/reference/http-headers/
- Workers static assets binding (`run_worker_first` arrays, `!` patterns, `env.ASSETS.fetch`): https://developers.cloudflare.com/workers/static-assets/binding/
- Workers static assets routing: https://developers.cloudflare.com/workers/static-assets/routing/worker-script/
- Workers static assets billing (file requests free; Worker first requests run the Worker): https://developers.cloudflare.com/workers/static-assets/billing-and-limitations/
- Workers limits (100,000 requests a day, error 1027, 10 ms CPU): https://developers.cloudflare.com/workers/platform/limits/
- Access token validation: https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/authorization-cookie/validating-json/
- EDPB Guidelines 2/2023 on the technical scope of Art. 5(3) ePrivacy Directive, version 2.0: https://edpb.europa.eu/system/files/2024-10/edpb_guidelines_202302_technical_scope_art_53_eprivacydirective_v2_en_0.pdf
- Sentry pricing: https://sentry.io/pricing/
- Sentry data storage location: https://docs.sentry.io/organization/data-storage-location/
- GlitchTip pricing: https://glitchtip.com/pricing

Result: ready for owner approval
