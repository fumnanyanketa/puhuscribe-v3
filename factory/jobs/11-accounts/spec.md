# Job 11-accounts: Accounts and personal data

Scope item 9. GA. Needs a decision. Date: 21 October 2026. Builds after `8-first-session` and `6-pr-local-db` are merged, on their code as merged. Runs beside `9-daily-review`, `10-speaking-feedback` and `12-units-1-3`. Test label: `[accounts N]`.

## Summary for the owner

1. A guest adds their email and types a 6 digit code from the email. They keep the same account, so every session and review card stays. Nothing moves or gets copied.
2. On a second phone they sign in with the same email and a new code, and see the same progress, because progress lives in the database and not on the phone.
3. A privacy page explains in plain words what is kept, why, for how long, where, and who to contact. In the app, a learner can download all their data as one file and delete their account and everything in it.
4. Guests who never come back are deleted after 90 days without activity (your decision of 20 October). The deletion path is ready for job 10's recordings and is tested now with a stand-in.
5. Costs nothing. Before real learners use it you choose an email sender (I recommend deciding at launch). Before the build finishes, you supply the name and contact address printed on the privacy page.

## What it is

Today a guest's progress lives in a real account that only exists on one phone (job 8). This job lets the learner add an email to that same account, sign in on other devices, read how their data is handled, download it, and delete it. It serves every principle indirectly by keeping the learner's review history (P2) and speaking history (P4) safe across devices, and it meets the GDPR rules in `AGENTS.md`: collect the minimum, explain why, allow export and deletion.

## Done when

Terms used below. "Phone size", "browser test" and "the fixture" mean what they mean in job 8: Playwright at 375 x 812 in Chromium and WebKit, against the built app and a throwaway local Supabase, with the fixture dialogue seed. In this job the local Supabase also runs Mailpit, its built-in mail catcher, and browser tests read codes from Mailpit's local API. Test email addresses use the reserved domain `example.com` (for example `learner-a@example.com`). Browser tests that send email carry the tag `@email`. "Two devices" means two separate Playwright browser contexts, which share no cookies. "User tables" means every table, in any schema this project creates, that has a foreign key to `auth.users` or a column named `user_id` (today `sessions`, `cards`, `review_logs`, `consents`, `usage_events`). Tags: **[security]** and **[personal data]** mark statements the security reviewer and the evaluator check closely.

### Front door and account page

1. **The front door explains before it collects.** Under job 8's Start line, `/` shows a "Privacy notice" link. A quiet "Your account" link opens `/account`. When this device has no account, `/` also shows a quiet "I already have an account" button that opens sign in. Loading `/` still creates nothing (job 8's `[session 1]` stays green). **[personal data]**
2. **The account page says what kind of account this is.** `/account` shows one of three states. Guest: "You are using a guest account on this device. Add your email to keep your progress and use it on other devices." with a primary "Add your email" button. Email account: "You are signed in as <email>." with a "Sign out" button. No account: "There is no account on this device." with "Sign in with your email". In the first two states it also shows "Download my data", "Delete my account" (quiet) and the privacy notice link. It shows no counts, scores or streaks. Browser test for each state. **[personal data]**
3. **The Worker learns the account from the database, not from Auth.** `GET /api/me` answers `{ "kind": "guest" | "email" | "none" }`, plus `email` only for an email account. It never returns a token or user id. It calls a new database function `public.my_account()`: `security definer`, `search_path = ''`, no arguments, execute granted to `authenticated` only. It returns the caller's own `id`, `email`, `is_anonymous`, `created_at`, `last_sign_in_at` and `email_confirmed_at`, and returns no row when the token's `session_id` is no longer in `auth.sessions` (signed out or deleted). pgTAP proves A gets only A's row, gets nothing after A's session row is removed, and that `anon` cannot execute it. **[security] [personal data]**

### Guest to email account

4. **Adding an email sends a code, and says up front what happens if the email is taken.** "Add your email" opens a screen with one email field (`type="email"`, `autocomplete="email"`) and this text: "We send a 6 digit code to this address. We use your email only to send you sign in codes." and "If this email already has a PuhuScribe account, the code signs you in to that account instead. Your guest progress on this device is then deleted, because progress cannot be moved between accounts." Pressing "Send code" posts `POST /api/account/email`. An address that is empty, longer than 254 characters, or not shaped like an email gets the gentle line "Please check the email address." and no request to Supabase. Only a guest may call this route; an email account gets 409 and nothing is sent.
5. **The code screen.** It reads "Enter the 6 digit code we sent to <email>. The code works for one hour." with one field (`inputmode="numeric"`, `autocomplete="one-time-code"`) and a primary "Confirm" button. "Send a new code" becomes available after 60 seconds (Supabase's own limit); before that it is disabled with the text "You can ask for a new code after one minute." A wrong or expired code shows, in the gentle style, "That code did not work. Check the numbers and try again." and changes nothing.
6. **The guest keeps the same account and every row.** Browser test, `@email`: a guest finishes the fixture session, adds `learner-a@example.com`, and types the code from Mailpit. Afterwards the local database shows the same `auth.users` id, now with `is_anonymous = false` and that email; the guest's `sessions`, `cards` and `usage_events` rows are identical (same ids and values) to a snapshot taken before; no other `auth.users` row was added. The page shows "Your email is added. Your progress is saved to your account." and `/account` shows the email state. **[personal data]**
7. **No code, no email.** Until the right code is entered, the account stays a guest: `is_anonymous = true` and `email` empty in the database (browser test reads them after "Send code" and after a wrong code). `supabase/config.toml` sets `[auth.email] enable_confirmations = true` so the local database behaves like the hosted one (repository test). This stops anyone attaching an email they cannot read to an account. **[security]**
8. **An email that already has an account: refuse to merge, offer to switch, delete the guest.** When Supabase answers that the email is taken, the Worker instead asks Supabase to send that account a sign in code, and gives the browser exactly the same answer as in statement 4. When the learner types that code, the Worker signs this device in to the existing account, then deletes the guest account through `delete_my_account()` with the guest's own token, then sets the new sign in cookies. The page shows "You are signed in to your account. The guest progress from this device was deleted." Browser test, `@email`: account B exists with progress; a guest on another device adds B's email, types the code, ends up as B with B's rows unchanged, and the guest's `auth.users` row and all its user table rows are gone. **[security] [personal data]**
9. **The answer never tells whether an email has an account.** For a new address, a taken address, and (statement 11) an unknown address, `POST /api/account/email` and `POST /api/sign-in` give the same status and the same body, and the screens show the same text. Worker unit tests with a fake Supabase compare the three answers byte for byte. **[security]**

### Second device

10. **Sign in with a code.** "Sign in with your email" opens the same email and code screens, with the heading "Sign in with your email". `POST /api/sign-in` asks Supabase for a sign in code with `shouldCreateUser: false`, then answers "If this email has a PuhuScribe account, we sent it a 6 digit code." with the added line "No code after a few minutes? Check the address, or go back and start as a guest." `POST /api/sign-in/verify` checks the code and sets the sign in cookies as job 8 does (`HttpOnly`, `Secure`, `SameSite=Lax`).
11. **Sign in never creates an account.** Browser test: signing in with an unknown address shows the statement 10 text, sends no email (Mailpit is empty), and adds no `auth.users` row. Every email account therefore started as a guest. **[security]**
12. **The second device shows the same progress.** Browser test, `@email`, two devices: device A is a guest who finishes the fixture session and adds an email; device B signs in with that email. On B, `/` shows the same state as on A (the next dialogue, or "You have finished every dialogue that is ready."), and B's downloaded file (statement 18) lists the same sessions and cards as A's. B then finishes the fixture's second dialogue; after a reload, A shows it finished too. **[personal data]**
13. **A guest on the second device is warned before signing in.** When this device already has a guest account, the sign in screen first shows "This device has a guest account. Signing in deletes its progress, because progress cannot be moved between accounts. To keep it, add your email to the guest account instead." with "Sign in anyway" and "Go back". After a successful sign in the guest account is deleted as in statement 8. Browser test checks the warning, the deletion and the new account. **[personal data]**
14. **Sign out, for email accounts only.** "Sign out" posts `POST /api/sign-out`, which signs out this device only (Supabase `scope: 'local'`), clears the cookies, and `/` then shows "You are signed out on this device." with the "I already have an account" button. The other device stays signed in (two device browser test). Guests see no sign out button, because a guest cannot sign back in; the account page says so in one line: "A guest account cannot sign back in, so add your email before you leave."
15. **The code emails show a code and no link.** `supabase/templates/` holds two English templates, for Supabase's "Magic link" email and its "Change email address" email. Both carry the subject "Your PuhuScribe code" and the same body: the code (`{{ .Token }}`), "Enter it in the app. It works for one hour.", and "If you did not ask for this code, you can ignore this email." They contain no link and nothing that tells whether the address already had an account. `config.toml` points to them. A browser test reads one email of each kind from Mailpit and checks the code is 6 digits and the body has no `http`.

### Privacy notice

16. **A plain privacy notice at `/privacy`.** It loads without an account and makes no `/api` call. It is linked from `/`, `/account`, and the email screen. It answers, in plain English and short sections: who is responsible and how to reach them (owner's call 2); what is kept and why, with the legal reason for each; how long; where it is stored and who processes it; the sign in cookies (only those needed for the app to work, no tracking or advertising cookies); the learner's rights (see and download, correct, delete, restrict, object, withdraw consent, complain to Finland's Office of the Data Protection Ombudsman) and that requests are answered within one month; that PuhuScribe is for adults 18 and over; and the date it was last updated. It states only the facts in "Privacy notice facts" below plus job 10's voice facts if job 10 has merged. A Vitest test checks each section exists. Writing rules from `AGENTS.md` apply. **[personal data]**
17. **One list of what we keep feeds both the notice and the download.** `src/privacy/data-inventory.ts` lists, for the account and for every user table, a plain description and how long it is kept; the notice renders its "What we keep" section from it. A browser test downloads a file and fails if the file's table names and the inventory's table names differ. A repository test fails if any file in `worker/providers/` is not named in the notice's list of processors (`src/privacy/processors.ts`), so job 10's speech provider cannot ship unlisted. **[personal data]**

### Download my data

18. **One file with everything.** "Download my data" fetches `GET /api/account/export`, which answers `application/json` with `content-disposition: attachment; filename="puhuscribe-data-<YYYY-MM-DD>.json"` and `cache-control: no-store`. The file holds `about` (plain English: what each part is), `exported_at`, `account` (the fields of statement 3), and `tables`, one list of rows per user table, plus `files` from each registered file store (statement 23; empty today). It holds no token and no other learner's rows. The status line reads "Preparing your file." then "Your file is ready." Works for guests and email accounts. Browser test in both browsers checks the download event, the name and the content against the database. **[personal data]**
19. **The download is complete, and a forgotten table fails the check.** The tables come from one database function, `public.export_my_data()`, `security invoker` (so the read rules apply), `search_path = ''`, execute for `authenticated` only, building each list with `to_jsonb(row)` so every column is included. pgTAP proves: the set of user tables found in the database catalogue equals the set of keys in `export_my_data()->'tables'`; for each user table, a seeded row of A's appears with every column of that table; none of B's rows appear; `anon` cannot execute it. The catalogue query lists Supabase's own schemas to skip, so a table in a new project schema is caught too. A scratch branch that adds a user table (with cascade and row level security, so job 3's catalogue test passes) without adding it to the export turns the database check red; the run is linked in `build.md`. **[security] [personal data]**

### Delete my account

20. **A clear confirmation, then everything goes.** "Delete my account" opens a screen: "This deletes your account and everything saved with it, including your progress and any recordings. It cannot be undone. Download your data first if you want a copy." with "Delete my account" (primary) and "Keep my account" (secondary). Confirming posts `POST /api/account/delete`; afterwards the cookies are cleared and `/` shows "Your account and all its data are deleted." Browser test for a guest and for an email account: afterwards the `auth.users` row is gone and a catalogue driven query finds zero rows for that id in every user table. **[personal data]**
21. **The delete function can only delete its caller, and only from a live sign in.** `public.delete_my_account()`: `security definer`, `search_path = ''`, no arguments, execute for `authenticated` only. It deletes `auth.users` where `id = auth.uid()`, and refuses (writing nothing) when `auth.uid()` is empty or the token's `session_id` is not in `auth.sessions`. pgTAP proves A deletes only A, B's rows stay, a signed out token is refused, `anon` cannot execute it, and A's rows in every user table are gone afterwards. A scratch branch that removes the live sign in check turns the database check red; linked in `build.md`. **[security] [personal data]**
22. **Deletion while another device is signed in.** Two device browser test, `@email`: B is signed in to the same email account and has the session screen open; A deletes the account. B's next press in the session writes no row (the database refuses rows for a missing user) and B is shown "You are signed out on this device. Sign in with your email to continue."; reloading `/` on B shows the same. Afterwards the database holds zero rows for that id. Guests keep job 8's own message. Any `/api` route that finds the account gone (statement 3 returns no row, or a write is refused for a missing user) clears the cookies and answers 401. **[security] [personal data]**
23. **The path for recordings exists now and is tested with a stand-in.** `worker/personal-data/file-stores.ts` exports a list of file stores, each with `exportFor` and `deleteAllFor`. It is empty today. `POST /api/account/delete` calls every store's `deleteAllFor` before the database delete; if any store fails, nothing in the database is deleted and the screen shows the problem style "Your account was not deleted. Check your internet connection, then try again." Worker unit tests with a fake store prove the order, the stop on failure, and that the export includes the fake store's `exportFor` result. A repository test fails if code in `worker/` writes files (calls to Supabase Storage `storage.from(` or an R2 binding's `put(`) outside a module listed in `file-stores.ts`. For the 90 day clean up, `private.user_has_stored_files(uuid)` returns false today; pgTAP replaces it inside a rolled back test and proves the clean up then skips that user. Job 10 fills both in if it stores files. Until then, recordings deletion is proven only with the stand-in, and `build.md` says so. **[personal data]**

### Guests who never convert

24. **Unused guest accounts are deleted after 90 days.** `private.delete_inactive_guests()` deletes every `auth.users` row with `is_anonymous = true` whose newest activity is more than 90 days old, skipping users for whom `private.user_has_stored_files` is true. Newest activity means the latest of the account's `created_at` and its sessions' `started_at` and `ended_at` and its `review_logs.review_time`. A migration enables `pg_cron` and schedules the function once a day. pgTAP with backdated test users proves: a guest inactive 91 days is deleted with all rows; a guest inactive 89 days, a guest with a session 10 days ago, and an email account inactive 400 days all stay; the schedule exists in `cron.job`; no API role can execute the function. The privacy notice states the rule. **[personal data]**
25. **Only if owner's call 3 is B or C:** the same function also deletes email accounts with no activity for the chosen period, with the same tests and the rule stated in the notice.

### Shared rules, checks and records

26. **Job 8's protections cover every new route.** Every new route that changes something accepts only `POST` with `content-type: application/json` and answers 403 to an `Origin` from another site. No new answer sends `Access-Control-Allow-Origin`. The browser still never holds a token or calls a `supabase.co` address. The Worker never logs an email address, a code, a token or a user id (unit test watching `console`). No Supabase secret key or service role key is used anywhere. **[security] [personal data]**
27. **Phone, keyboard, accessibility.** Every new screen at phone size: nothing scrolls sideways at 320 px wide or with text at 200 percent; every control is at least 44 x 44; each field has a visible label; the whole flow works by keyboard alone; `@axe-core/playwright` finds no WCAG 2.0 to 2.2 A or AA violation in light or dark mode. New fields use one new component, `TextField`, built from existing tokens in v2's input style (a white card field with its label above, from `design/v2-handoff/app-screens/screens-onboarding.jsx`), checked by the design reviewer against `design.md`.
28. **The checks run the email tests where email works.** The local browser check from job 6 also starts Mailpit (its name is removed from the `-x` list, as job 6 allows). The after merge check and the preview run skip `@email` tests as they skip `@seed`, because the test project's built in sender delivers only to members of the Supabase organisation. `build.md` lists every job 6 test changed for this and why; none is weakened. All existing tests stay green.
29. **Records.** `docs/data-model.md` describes the three new functions, the clean up and the export check. `docs/conventions.md` adds the `[accounts N]` row and the rule "a new user table goes into `export_my_data()` and `src/privacy/data-inventory.ts` in the same job". The README "Running costs" stays at €0 and lists the owner setup steps below. `src/lib/database.types.ts` is regenerated by the Supabase CLI.

Product rules from `AGENTS.md` that apply: GDPR minimum data, export and deletion; audio discarded by default (this job stores none); no users under 18 (stated on the front door and in the notice); one front door, the learner never picks a mode (the account page is reached by a quiet link and holds no learning); gentle wording for the learner's own mistakes, the problem style only for system faults; agents use only the test database; no placeholders (the notice ships only with owner's call 2 answered); never delete or weaken a test; client facing text in English; the "Not in v3.0" list is binding.

## Privacy notice facts

The builder writes the notice from these facts only. The owner approves the wording at final approval.

| Topic | Fact for the notice | Source |
|---|---|---|
| Guest account | A random account id and its sign in times. No name. | Job 8 |
| Email account | The email address, used only to send sign in codes. No newsletters. | This job |
| Learning progress | Sessions (which dialogue, how far, when), review cards and review results, one "finished first session" event | Jobs 3 and 8 |
| Voice consent | Each consent choice, the notice version and the time | Job 3 |
| Voice data | Only what job 10 records, in job 10's words | Job 10, if merged |
| Legal reason | Account and progress: needed to provide the service you asked for (GDPR Article 6(1)(b)). Voice: your consent (Article 6(1)(a)), from job 10 | GDPR |
| How long | Guest accounts: deleted after 90 days with no learning activity. Email accounts: owner's call 3. Everything: deleted at once when you delete your account | Owner decision 20 Oct; this job |
| Provider logs | Supabase keeps API and database logs for 1 day and auth audit logs for 1 hour on the Free plan. The Worker's request logs are off | Supabase pricing; job 8 |
| Where | Database and sign in: Supabase, EU (Ireland). Requests pass through Cloudflare's network, which may handle them outside the EU under its data processing terms (EU standard contractual clauses and the EU US Data Privacy Framework). Sign in emails: sent by Supabase until owner's call 1 changes it | README; Cloudflare GDPR page |
| Cookies | Only sign in cookies needed for the app to work | Job 8 |
| Under 18 | Not for under 18s | PRD section 10 |
| Contact and controller | Owner's call 2 | Owner |

## Threat model (GA)

**What is the worst a malicious person could do here?**
- Take over a learner's progress by attaching their own email to it, or by attaching a victim's email to a guest. Both need the code from that inbox (statements 7 and 8).
- Sign in as someone else. Needs a code from their inbox; codes are 6 digits, expire after one hour, and Supabase limits verification attempts.
- Find out whether someone uses PuhuScribe by trying their email. Every path gives the same answer (statement 9). This matters here: the app is for recent immigrants.
- Export or delete another learner's data. Both functions take no user id and act only on the token's own id; delete also needs a live sign in (statements 19 and 21).
- Delete an account from another website. JSON only, `Origin` check and `SameSite=Lax` cookies (statement 26).
- Flood a victim's inbox with codes, or use up the shared Supabase limits so nobody can sign in. Supabase allows one code per address per 60 seconds and 2 emails an hour on the built in sender. All requests reach Supabase from the Worker's address, so Supabase's per address limits are shared by every learner. This must be settled before launch together with job 8's guest abuse decision (Risks).
- Someone holding an unlocked phone deletes the account. The confirmation screen is the only guard. Accepted, because that person can already use the account.

**What data are we storing that we must protect?**
- Email addresses, account times and the sign in tokens in cookies.
- Each learner's progress, review history, consent history and usage event, and later job 10's voice data.
- The downloaded file, once on the learner's phone, is theirs to keep safe; the server never stores a copy.

**What must the system refuse even if asked nicely?**
- Attaching an email without its code, or creating an email account without a guest first.
- Saying whether an email has an account.
- Moving or copying progress between accounts.
- Exporting or deleting by a user id from the request, or deleting from a signed out token.
- Using a Supabase secret key or service role key, or logging an email, code, token or user id.
- Sending any email other than a sign in code.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | How the learner proves the email is theirs | A 6 digit code typed into the app (Supabase email OTP, `{{ .Token }}` in the templates) | A magic link in the email | The app becomes an installed web app (job 16). On iPhone, a link from Mail opens in Safari, which keeps separate cookies from the installed app, so the sign in lands in the wrong place; Apple's own WWDC23 web app guidance says to use one time passcodes instead of magic links. Email scanners such as Microsoft Defender Safe Links can open a link before the learner does and use it up (Supabase email templates page). A typed code also keeps the whole sign in in one browser and one Worker request |
| 2 | Who sends the emails in this job | Supabase's built in sender on the test project; Mailpit in local and pull request tests | A custom sender now (Brevo, Scaleway, Resend) | The built in sender delivers only to members of the Supabase organisation and 2 emails an hour, which is enough for the owner's own test and no real learner. A custom sender is a new service (owner's call 1). Supabase sends the emails in both cases, so changing sender later changes settings, not code |
| 3 | A guest adds an email that already has an account | Refuse to merge. The code signs the device in to the existing account and the guest account is deleted, with a warning before the email is sent | Merge the guest's rows into the existing account | Two cards for the same form would need a rule for combining review schedules, which is scheduling logic the PRD keeps deterministic and simple; a merge needs a privileged function that writes across two accounts; and the case is rare, because "I already have an account" sits on the front door before Start. Supabase's anonymous sign in page leaves conflict handling to the app |
| 4 | How an account is deleted | `delete_my_account()`, a `security definer` SQL function that deletes the caller's `auth.users` row; job 3's cascades remove every user table row | Supabase's Admin API `auth.admin.deleteUser()` from the Worker | The Admin API needs a secret key in the Worker, which jobs 1, 2 and 8 kept out on purpose because it bypasses every access rule. Supabase's own clean up example deletes from `auth.users` with SQL, and job 3's tests already write `auth.users` as `postgres` on the test project |
| 5 | How the export is built | One SQL function, read through the learner's own access, checked against the database catalogue | The Worker reading each table in turn | A list in Worker code cannot be checked against the database by pgTAP, so a forgotten table would pass |
| 6 | How the Worker knows the account | `my_account()` in the database, which also checks the sign in is still live | `auth.getUser()` against Supabase Auth on each request | Supabase's rate limit table lists `/user` among sign in requests at 30 per 5 minutes per address, and every learner reaches Auth from the Worker's address. Whether plain reads count is not stated; the database call avoids the question |
| 7 | How the 90 day clean up runs | `pg_cron` inside the database, once a day | A scheduled GitHub workflow or Cloudflare cron | Both need the database password or a secret key in a new place; job 6 keeps the password in the apply job only. Supabase Cron is Supabase's documented scheduler (keep runs short and few) |
| 8 | Passwords | None. Codes only | Email and password | A password is one more secret to store, reset and protect, and needs a reset flow by email anyway |
| 9 | Delete confirmation | A confirmation screen | A code emailed before deletion (Supabase `reauthenticate`) | Guests have no email, and on the built in sender each deletion would use one of 2 emails an hour |
| 10 | Recording deletion before job 10 exists | A file store list called before the database delete, a database hook for the clean up, both tested with a stand in, and a repository test that catches unregistered file writes | Wait for job 10 | Jobs 10 and 11 build at the same time; the contract lets whichever merges second plug in, and the tests fail if it does not |

New npm packages: none expected (`@supabase/supabase-js` and `@supabase/ssr` arrive with job 8). New database extension: `pg_cron`.

### Notes for the builder

- After `updateUser({ email })` on a guest, verify with `type: 'email_change'`; for a sign in code, `type: 'email'`. In statement 8 the Worker cannot know which code the learner holds without revealing it, so it tries `email_change` first, then `email`. The `email_change` type is in `@supabase/auth-js`'s types and a user report on GitHub issue 25787 says it is the one that works for guests; confirm against the local Supabase and record it in `build.md`.
- After linking, renew the session so the new access token says `is_anonymous: false`.
- Read `is_anonymous` from the expired access token in the cookie only to pick the signed out message (statement 22); never trust it for anything else.
- Raise the local email limits in `config.toml` (`[auth.rate_limit] email_sent`, `[auth.email] max_frequency`) only as far as the browser tests need; local only.
- Coordinate the migration timestamp with jobs 9, 10 and 12 through the manager.

## Contract notes for the manager (jobs 9 and 10)

1. Any job that adds a user table adds it to `export_my_data()` and `src/privacy/data-inventory.ts` in the same job. Statements 17 and 19 fail otherwise, whichever job merges second.
2. If job 10 stores recording files, it adds a file store to `worker/personal-data/file-stores.ts`, replaces `private.user_has_stored_files`, adds its speech provider to `src/privacy/processors.ts`, and adds its voice facts to the notice. Its consent screen links to `/privacy`.
3. If job 10 uses Supabase Storage with the learner as owner, Supabase refuses to delete a user who still owns files, so a missed file makes deletion fail loudly rather than leave a file behind.

## Out of scope

- Changing the email address, passwords, Google or Apple sign in, passkeys, two step sign in, a list of signed in devices, signing out everywhere.
- Merging progress between accounts.
- Setting up a custom email sender or a sending domain (owner's call 1), CAPTCHA or Turnstile, rate limits in the Worker (the launch decision from job 8).
- Recording storage, voice consent screens and the voice wording of the notice (job 10).
- Terms of service, a cookie banner (only necessary cookies are used), marketing or newsletter email, the waitlist (job 15), analytics and feedback (job 14), onboarding (job 13).
- Tools for the owner to answer privacy requests; the owner answers by email.
- From the "Not in v3.0" list: no streaks, rank titles, milestone counts or word counts on the account page; no Owner Insights dashboard; no bilingual or Finnish only toggle.

## Build plan

1. **Database.** One migration: `my_account()`, `export_my_data()`, `delete_my_account()`, `private.user_has_stored_files()`, `private.delete_inactive_guests()`, `pg_cron` and its schedule, grants and revokes written out. pgTAP, regenerated types, two red scratch runs. Covers 3, 19, 21, 23 (database part), 24, 25.
2. **Worker.** `/api/me`, the email, sign in, verify, sign out, export and delete routes, neutral answers, file store list, signed out handling, quiet logs, unit tests with fakes. Covers 4, 5, 8 to 11, 14, 18, 22, 23, 26.
3. **Screens, notice and emails.** Front door links, account page, email and code screens, delete confirmation, `TextField`, `/privacy` with the inventory and processors list, the two email templates and `config.toml`. Covers 1, 2, 13, 15 to 17, 20, 27.
4. **Browser tests, checks and records.** Mailpit in the local check, the `@email` tag, two device tests, accessibility, docs. Covers 6, 7, 12, 28, 29 and proves the rest end to end.

**Dependencies.**
- `8-first-session` and `6-pr-local-db` merged.
- Owner setup on the Supabase test project before merge (free, about 10 minutes, steps written in the README by the builder): paste the two email templates; check that "Confirm email" and "Secure email change" are on; turn off "Write audit logs to the database", so deleted users leave no audit rows behind.
- Owner's call 2 answered before the build finishes; owner's call 3 answered before the notice is final.
- As in job 8, the preview cannot run new database parts until merge; the evaluator uses the pull request's test videos and a local run where Docker exists.

## Risks and flags

- **Look closely: learner data and sign in.** First job that stores email addresses and deletes accounts. Covered by the threat model and statements 3, 6 to 11, 19 to 24 and 26.
- **Look closely: database and access rules.** Three functions callable by learners, two of them `security definer` (they run with the owner's rights and must act only on the caller). The pgTAP tests and the two red scratch runs are the main protection.
- **Look closely: deleting data automatically.** The 90 day clean up deletes real accounts with no human step. A wrong activity rule would delete active guests; statement 24's tests cover the edges.
- **Paid service, later.** Real learners need a custom email sender (owner's call 1). Each is a new service holding learner email addresses.
- **Shared limits before launch.** Every sign in request reaches Supabase from the Worker's address: 30 sign in requests and 30 code checks per 5 minutes are shared by all learners. Fine for testing; the launch decision from job 8 (Turnstile, a secret key with address forwarding, or Worker limits) must include these.
- **Legal wording.** The notice is written from verified facts but is not legal advice. Before public launch the owner may want a privacy professional to read it, and should sign Supabase's data processing addendum (requested from the dashboard's legal documents page; whether Free plan accounts can request it was not confirmed).
- **Deleted data in backups.** Whether Supabase keeps any backup of a Free plan project, and for how long, was not checked. The notice must not claim either way until it is.
- **Running costs.** €0. `pg_cron` runs one short job a day.

## Owner's calls

**1. Who sends sign in emails to real learners.** The built in sender reaches only you and other members of your Supabase organisation, 2 emails an hour. Fine for this job; not for anyone else.
- A. Keep the built in sender now and decide at launch, with prices checked again then. No new service today. Nobody outside your Supabase team can add an email or sign in until then.
- B. Brevo (French company, EU). Free plan of 300 emails a day according to reviews; I could not open Brevo's own price page, so this is unverified.
- C. Scaleway Transactional Email (French cloud). 300 emails included, then €0.25 per 1,000, no monthly fee, per Scaleway's price page; whether it needs a payment method was not checked.
- D. Resend. Free plan of 3,000 emails a month and 100 a day, with an Ireland sending region, but Resend stores account data and email logs in the United States.
- Each of B to D also needs a domain you own with a few DNS records, and a sender address you choose. Recommendation: A now. At launch, B or C, because learner email addresses then stay with an EU company.

**2. Who the privacy notice names as responsible, and the contact address it prints.** The notice cannot ship without them, and I will not pick an address.
- A. Your business (its registered name and business ID) with a contact address on a domain you own. Looks established and keeps your personal address private.
- B. Your own name with an address you already use. Fastest; your name and that address become public on the page.
- Recommendation: A, if your business is registered.

**3. How long an email account with no activity is kept.**
- A. Until the learner deletes it. Simplest; the notice says "as long as you keep your account".
- B. Deleted after 24 months with no activity, with no warning email until a custom sender exists. Least data kept; a learner returning after two years starts over.
- C. 12 months, same as B but shorter.
- Recommendation: B. It matches GDPR's storage limit idea and reuses the guest clean up at no cost.

No design direction call: the screens reuse the locked design system and v2's own sign in screen layout.

## Could not verify

- That `updateUser({ email })` answers "email exists" for a taken address, that `email_change` is the right type to verify a guest's code, and that with confirmations off the local Supabase links an email without a code (the reason for statement 7's setting). The tests settle each.
- Whether reading `/user` counts toward Supabase's sign in rate limit.
- That `pg_cron` is on the Free plan and in the local CLI database image, and that `postgres` may delete from `auth.users` on the hosted project inside a function (Supabase's own clean up SQL suggests yes).
- Whether the hosted email templates can be edited while using the built in sender.
- Brevo's prices and terms; whether Scaleway needs a payment method; Resend's region rules on the Free plan (its docs and changelog disagree).
- Whether Free plan accounts can request Supabase's data processing addendum; whether Supabase keeps backups of Free plan projects.
- Finland's Data Protection Ombudsman site (tietosuoja.fi) returned an error when I tried it; the builder links its complaint page after checking it loads.

## Sources

- PRD sections 4.1, 7.3, 10 and 11: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- Project: `factory/jobs/3-data-model/spec.md` and `summary.md` (90 day decision), `factory/jobs/8-first-session/spec.md`, `factory/jobs/6-pr-local-db/spec.md`, `docs/data-model.md`, `supabase/migrations/20261020090100_learner_model.sql`, `supabase/config.toml`, `design.md`, `design/v2-handoff/app-screens/screens-onboarding.jsx`
- Supabase anonymous sign ins (convert with `updateUser`, conflicts left to the app, clean up SQL, no automatic clean up): https://supabase.com/docs/guides/auth/auth-anonymous
- Supabase custom SMTP (built in sender: team members only, 2 an hour, not for production): https://supabase.com/docs/guides/auth/auth-smtp
- Supabase rate limits (per address limits, `/user` listed, one code per 60 seconds): https://supabase.com/docs/guides/auth/rate-limits
- Supabase passwordless email (code via `{{ .Token }}`, one hour expiry, `shouldCreateUser`): https://supabase.com/docs/guides/auth/auth-email-passwordless
- Supabase email templates (template list, link scanners use up links): https://supabase.com/docs/guides/auth/auth-email-templates
- Supabase user data (Storage owners block deletion, tokens valid until expiry, check `session_id`): https://supabase.com/docs/guides/auth/managing-user-data
- Supabase audit logs (database copy can be turned off): https://supabase.com/docs/guides/auth/audit-logs
- Supabase Cron (8 jobs or fewer, 10 minutes each, run history table): https://supabase.com/docs/guides/cron
- Supabase pricing (Free: log retention 1 day, audit logs 1 hour, custom SMTP allowed): https://supabase.com/pricing
- Supabase data processing addendum: https://supabase.com/legal/dpa
- Supabase changelog on auth schema restrictions (April 2025): https://supabase.com/changelog/34270-restricting-access-on-auth-storage-and-realtime-schemas-on-april-21-2025
- GitHub issue 25787 (converting guests, `email_change` report): https://github.com/supabase/supabase/issues/25787
- Apple WWDC23 "What's new in web apps" notes (one time passcodes instead of magic links): https://wwdcnotes.com/notes/wwdc23/10120
- WebKit bug 181849 (home screen apps do not share storage with Safari): https://bugs.webkit.org/show_bug.cgi?id=181849
- Cloudflare GDPR page (standard contractual clauses and Data Privacy Framework): https://www.cloudflare.com/trust-hub/gdpr/
- GDPR Articles 12, 13 and 20: https://gdpr-info.eu/art-12-gdpr/, https://gdpr-info.eu/art-13-gdpr/, https://gdpr-info.eu/art-20-gdpr/
- Resend pricing and regions: https://resend.com/pricing.md, https://resend.com/docs/dashboard/domains/regions
- Scaleway pricing: https://www.scaleway.com/en/pricing/managed-services/
- Brevo reviews (official page not readable): https://www.sendx.io/blog/brevo-pricing-plans-costs-alternatives-2026

Result: ready for owner approval
