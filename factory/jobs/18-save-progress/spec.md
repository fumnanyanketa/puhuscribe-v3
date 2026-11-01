# Job 18-save-progress: Ask a guest to keep their progress

Not in `docs/scope/scope.md`: the owner's own idea, decided on 31 October 2026 ("After 1st session"). Not GA on the factory's list, but it reads a learner's account kind and session history, so the three threat model answers are included. Needs a decision. Date: 31 October 2026. Builds on main as merged, including jobs 8-first-session, 11-accounts and 14-analytics. Runs beside `15-onboarding` (front door only) and the rewrite of `17-landing-page` (moves the app under `/learn`). Test label: `[save-progress N]`.

## Summary for the owner

1. After a guest finishes their first session and the screen says "Your progress is saved.", a short note appears on that same finish screen: "Add your email to keep your progress and use it on other devices." with an "Add your email" button and a "Not now" button. It never blocks "Done" and never appears during a session.
2. Nothing new is stored. The app works out "this was the first finished session" from records that already exist in the database, so there is no new table and the privacy notice does not change. Nothing is saved on the phone either. "Not now" just closes the note, and the next finish screen is a different session, so it does not come back.
3. Email accounts and people with no account never see it. The "Add your email" button opens the add email screen from job 11, unchanged, including its warning about an email that already has an account.
4. Costs €0: no new service, package, AI call or message sent. Nothing goes to any third party. The work is one small read only database function, one extra field in the answer the finish screen already gets, and one block on the screen.
5. Three calls are yours: whether the note ever comes back (I recommend one reminder at the third finished session), the exact words (my draft uses your sentence word for word), and how loud the "Add your email" button is (I recommend a quiet white button so "Done" stays the main action).

## What it is

A guest's progress lives in a real account that only exists on one phone, and it is deleted after 90 days without use (jobs 8 and 11). Today the only way to fix that is the quiet "Add your email" button on the account page, which most learners will never open. This job adds one short, optional note to the end of session screen, at the moment the learner has just done something worth keeping. It serves P2 and P4 indirectly, by keeping the learner's review history and speaking history safe across devices, as job 11 does.

## Done when

Terms. **Guest**: an account with `is_anonymous = true` in the sign in token. **Finished session**: a dialogue session whose `ended_at` is set by `public.complete_session` (job 8). **First finished session**: the session named on the learner's `first_session_completed` event (job 8, one per learner, never changes). **The note**: the block described below. **The finish screen**: `src/screens/FinishScreen.tsx`. **Browser test**, **phone size** and **the fixture** mean what they mean in jobs 8 and 11: Playwright at 375 x 812 in Chromium and WebKit, against the built app and a throwaway local Supabase with the fixture dialogues. Tests that read a code from Mailpit carry the tag `@email`, as in job 11. **axe** is the automatic accessibility checker (`@axe-core/playwright`). Tags: **[security]** and **[personal data]** mark statements the security reviewer and the evaluator check closely.

### When the note shows

1. **A guest sees it after their first finished session.** Browser test: a new guest finishes the fixture's first dialogue with the existing helper `finishTodaysSession` (`e2e/account-helpers.ts`). After the status line reads "Your progress is saved.", the finish screen shows the note: a region named "Keep your progress" holding the sentence, an "Add your email" button and a "Not now" button. In the page it sits after the line card and "The words you met will come back in your review." and before "Send feedback". Both browsers.
2. **Never mid session, and never before the progress is saved.** Browser tests: (a) the note's words appear on none of the front door, Hear it, Understand it, Say it and Keep it screens; (b) with the answer to the complete request delayed by 2 seconds, the finish screen shows "Saving your progress." and no note, then the note once the answer arrives; (c) with the complete request aborted, the screen shows job 8's "not saved" message and "Try again" and no note, and after "Try again" succeeds the note appears. **[personal data]**
3. **The Worker adds one field to an answer that already exists.** `POST /api/sessions/<id>/complete` still answers `{"saved":true}`. When the database function (statement 4) says the note is due, the answer is `{"saved":true,"saveNote":"first"}` (or `"reminder"`, statement 8). The Worker asks the function only after `complete_session` has succeeded, with the learner's own token, and a failure of the function (a fake that throws) gives the plain `{"saved":true}` with status 200: the note can never break saving. Status, headers and cookies are otherwise unchanged. No new route is added. Job 8's `worker/sessions.test.ts` check `toEqual({ saved: true })` stays unchanged and green. Worker unit tests with a fake database. **[security]**
4. **The database decides, from records that already exist.** `public.save_progress_note(p_session_id uuid)` returns `'first'`, `'reminder'` or `'none'`. It is `security invoker` (the learner's own read rules apply), `stable` (so it cannot write anything), `search_path = ''`, execute granted to `authenticated` only and revoked from `public`, `anon` and `service_role` in writing. It returns `'first'` only when all of these hold: the token says the caller is a guest (`auth.jwt() ->> 'is_anonymous'` is true; a missing claim counts as not a guest); the session is the caller's own, is a dialogue session and has ended; and its id is the session on the caller's `first_session_completed` event. In every other case it returns `'none'` and never raises an error. pgTAP gives each condition its own failing case: a token with `is_anonymous` false on an otherwise valid first session; the caller's second finished session; a session id that belongs to another learner; and the `anon` role calling it (refused). One more test passes an open session, which two conditions refuse together, so it is an outcome test for "never mid session" and not a proof of a single rule. A scratch run turns the function `security definer` and removes its explicit owner check, and the other learner test goes red; the run is linked in `build.md`. **[security] [personal data]**
5. **Email accounts never see it.** Browser test, `@email`: a guest adds `learner-a@example.com` through job 11's screens and Mailpit, then finishes the fixture's first dialogue. The finish screen shows "Your progress is saved." and no note, and the answer to the complete request has no `saveNote`. A second test: a guest sees the note on the first session, adds an email, finishes the second session, and sees no note. This also proves that job 11's token renewal gives the database a token that says "not a guest". **[personal data]**
6. **People with no account never see it.** Worker unit test: `POST /api/sessions/<id>/complete` with no sign in cookie answers 401 as in job 8, has no `saveNote`, and the database function is never called (a spy). Browser test: a guest's `auth.users` row is deleted in the test database during the session (the method of job 11's statement 22), then the learner finishes; the screen shows job 8's own message and no note.
7. **It shows once.** The note belongs to one finished session, and no other session qualifies, so no flag is stored. Browser tests: (a) "Not now" closes the note; reloading `/session` and the front door shows no note, and finishing the fixture's second dialogue shows none; (b) "Add your email" opens the add email screen; going back with the browser's Back button shows no note on whatever screen loads; (c) pgTAP: the second finished session returns `'none'`. On purpose, completing the same first session twice (a retry after a lost answer) answers with the note both times, because the first answer may never have reached the screen; a Worker test pins this and `build.md` says so.
8. **Only if owner's call 1 is B: one reminder, at the third finished session.** The function also returns `'reminder'` for a guest's third finished dialogue session, counted by `ended_at` with the session id as tie breaker, and `'first'` still wins on the first. Nothing is stored for this either. pgTAP: a guest's third finished session returns `'reminder'`; the second and fourth return `'none'`; a token with `is_anonymous` false returns `'none'` on the third. The reminder uses the same words and the same screen. Browser test, `@email`: if the fixture has fewer than three dialogues, the test inserts two earlier finished session rows for that guest through the test database helper, then finishes one session and sees the note; the next finished session shows none. With call 1 A or C this statement does not exist. **[personal data]**

### What it says and does

9. **The words are in one file and follow the writing rules.** `src/screens/save-note-copy.ts` exports the constants of "Note wording" below (the owner may edit them at approval). A Vitest test checks, on that file: at most 40 words in all; no em dash, no hyphen used as punctuation, no colon and no exclamation mark; none of the words seamless, unlock, elevate, empower, supercharge, game-changer, cutting-edge, effortless; none of streak, points, lose, lost, losing, miss, hurry, expire, "last chance", free; no digit; no ä, ö or å; and that the text contains the labels "Add your email" and "Not now". A browser test checks that the page shows exactly this text in the note and no other text inside it. The note has no element with `lang="fi"`.
10. **"Add your email" goes to the existing flow, and says what job 11 says.** Browser test: pressing it opens the add email screen (heading "Add your email", job 11's two sentences `SENDS_CODE` and `TAKEN_WARNING` shown unchanged). The test checks the address with `new URL(page.url()).pathname.endsWith('/account/email')`, so it passes with or without a `/learn` prefix. `@email` test: from the note the guest finishes the flow with a code from Mailpit and sees "Your email is added. Your progress is saved to your account."; the database shows the same `auth.users` id, now with `is_anonymous = false`. The note adds no new account code. **[personal data]**
11. **"Not now" closes the note and says where to find it later.** Pressing it sends no request and writes nothing on the phone (storage and cookies read before and after). The note is replaced by one plain line, "No problem. You can add your email later from Your account." and focus moves to that line (`tabindex="-1"`, as the finish screen's status line does) so a keyboard or screen reader user is not left on a button that has gone. The line has no `role="status"` or `role="alert"`.
12. **Gentle, and it never blocks.** The note is a block in the page, not a dialog: no `role="dialog"`, no `aria-modal`, no overlay, no bottom sheet, no focus trap, no `inert` on the rest of the page, no autofocus, no timer and no animation, and focus does not move when it appears. With the note showing, a browser test presses "Done" and reaches the front door in one tap, opens "Leave session", and finds "Send feedback" and the line's play controls still operable. The bottom action area is unchanged: its status line and "Done" are fully visible and the note adds nothing to it. The note and its follow up line carry no `role="status"`, `role="alert"` or `aria-live`, because earlier tests (`finishTodaysSession` and others) look for the finish screen's one `status` element and must stay unchanged. The note shows no number, score, streak, badge or celebration, and no wording about losing anything. **[personal data]**
13. **Nothing new is sent, stored or installed.** For a guest from Start to the note and through "Not now", a browser test finds only requests to the app's own address and only the requests that exist today (job 8's session routes and the complete request, with no extra request for the note); `document.cookie` holds only the sign in cookie; `localStorage.length` and `sessionStorage.length` are 0. The command `git diff --stat main...HEAD -- package.json package-lock.json wrangler.jsonc src/privacy worker/providers worker/personal-data` prints nothing. A repository test reads this job's one migration and fails on `create table`, `alter table`, `create type` or `alter type`, so nothing new is stored. The privacy notice, the data inventory and the download file need no new line because nothing new is kept. No AI call and no third party. **[personal data]**

### Phone, keyboard and look

14. **Phone size.** At 375 x 812, in both browsers and in light and dark mode, the whole note is visible without scrolling on the fixture's finish screen. If a longer line pushes it out of view, the builder tightens spacing and never hides or shortens the note, and `build.md` records the case. At 320 px wide and with text at 200 percent nothing scrolls sideways; both buttons are at least 44 x 44; long words wrap (`overflow-wrap: anywhere`).
15. **Keyboard and screen reader.** The Tab order on the finish screen is the line card controls, "Add your email", "Not now", "Send feedback", "Done", using the existing `tabTo` helper (`e2e/session-helpers.ts`). Enter and Space work on both buttons. Each control has a visible focus outline from `design.md`. The note is a `section` with `aria-label="Keep your progress"` and adds no heading, so the page keeps one `h1`. axe finds no WCAG 2.0 to 2.2 A or AA violation on the finish screen with the note, in light and dark mode, and again after "Not now". With reduced motion switched on the page is identical.
16. **The look uses the design system only.** Styles use tokens only, so `tests/design-tokens.test.ts`, `tests/design-css.test.ts` and `tests/design-rules.test.ts` pass unchanged. Every button has explicit token colours in WebKit dark mode (job 5's lesson). The block has no image, icon, emoji, uppercase label, pill or badge, accent border, gradient or table style rows. It is built in its own CSS module (`src/screens/SaveNote.module.css`) so it does not collide with job 15's edits. With owner's call 3 A, "Add your email" is the secondary button and "Not now" the quiet one, and "Done" is the only primary button on the screen. `design.md` gains a short "Save progress note" entry and `/design-reference` shows the note in light and dark. The design reviewer checks it against `design.md` and the banned list in `AGENTS.md`.

### Paths, with or without `/learn`

17. **Works at `/` today and under `/learn` after job 17.** This job adds no page route and no API route, so `worker/page-routes.ts` and `tests/analytics-rules.test.ts` stay unchanged and green. The one address the note uses, the add email screen, is built in one place: if job 17 has merged and added a helper for the app's base path, the note uses it; otherwise the note uses the same plain `/account/email` string that `AccountPage` uses, held in one constant in `save-note-copy.ts`, so job 17's move changes one line. A repository test fails if any file this job adds or changes holds a quoted app path (`'/account`, `'/session`, `'/learn`, and the same in double quotes or backticks) outside that constant. New browser tests open pages only through the existing helpers in `e2e/` and check addresses with `endsWith`. If job 17 merges first, it updates those helpers and this job rebases on them; if this job merges first, job 17 updates the helpers it already has to update.

### Records

18. **Records and earlier tests.** `docs/data-model.md` describes `save_progress_note` in one short paragraph (what it reads, that it writes nothing). `docs/conventions.md` adds the `[save-progress N]` row. `src/lib/database.types.ts` is the Supabase CLI's output. The README's running costs stay at €0. `build.md` lists every earlier test it changed; the expected list is one item, the fake in `worker/test-fakes.ts`, which gains a `saveProgressNote` method that answers `'none'` by default. All earlier tests stay green and unchanged, in particular job 8's finish screen and `[session N]` tests, job 11's account tests, job 14's tests and job 15's tests once merged.

Product rules from `AGENTS.md` that apply: P2 and P4 indirectly; one front door, one loop (the note sits on the finish screen and asks the learner to pick no mode); gentle wording; GDPR minimum data (nothing new collected, so no notice change); no users under 18 (unchanged); nothing sent to a third party; audio untouched; agents use only the test database; no placeholders; never delete or weaken a test; client facing text in English; the "Not in v3.0" list is binding.

## Note wording (draft for the owner's approval)

- Region name (read by screen readers, not shown): Keep your progress
- Sentence: Add your email to keep your progress and use it on other devices.
- Button: Add your email
- Button: Not now
- Line shown after "Not now": No problem. You can add your email later from Your account.
- Finish screen status line for a guest: Your progress is saved on this device. A learner with an email keeps "Your progress is saved." Owner's choice of 1 November 2026 (round 2, test label `[save-progress 19]`). It is in `save-note-copy.ts` as `SAVED_ON_THIS_DEVICE`.

That is 31 words with the region name. The sentence is the owner's, word for word. It makes no promise about what happens if the email already has an account; job 11's screen, one tap later, says that in two sentences, and statement 10 checks it is still there.

## Threat model

**What is the worst a malicious person could do here?**
- Make the note appear for themselves when they should not see it, or hide it. This changes nothing but their own screen. The decision uses only their own rows and their own token.
- See another learner's session history through the function. It runs with the caller's own read rules and takes no learner id, so it can only look at the caller's own rows (statement 4).
- Use the note as a way to attach an email they cannot read to an account. The note adds no account code. The add email flow of job 11 still needs the 6 digit code from that inbox (job 11, statements 7 and 8).
- Write to the database through the new function. It is `stable`, so Postgres refuses any write inside it.
- Reach the function without a sign in. `anon` is refused (statement 4).

**What data are we storing that we must protect?**
- Nothing new. The function reads the learner's sessions, their `first_session_completed` event and a claim in their own token, and returns one word. No table, column, cookie, local storage or log line is added (statements 13 and 18).

**What must the system refuse even if asked nicely?**
- Showing the note to an email account, to a person with no account, or in the middle of a session.
- Showing it again for a later session, except the one reminder if the owner picks it.
- Taking a learner id from the request, or reading another learner's rows.
- Storing the "Not now" choice, anything about the device, or a timestamp of when the note was shown.
- Sending the learner or their email to any third party.
- Blocking "Done", Leave session or any other control while the note shows.
- Wording that pressures: no countdown, no loss warning, no streak.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | Where "already shown" and "Not now" are remembered | Nowhere new. The function derives "first finished session" from the existing `sessions` and `usage_events` rows, so the note can belong only to that one session. "Not now" is not remembered because nothing needs it: the next finish screen is another session | A new one row per learner table that records "shown" (or "not now") | It adds learner data, which brings an export entry, an inventory entry, a privacy notice line, a cascade and access rules, two existing `tables_are` tests to extend, and tests for all of it. It would also record "shown" when the learner may never have seen it (a lost answer). What it buys is a hard guarantee against the note appearing twice for the same session, which only happens when the same finish is saved twice, and then the first showing may not have happened. I ask the owner to confirm, because the owner preferred a database record; this is one, and it already exists |
| 2 | Other places for the memory | See the row above | Device storage; the sign in account's own user data; the existing `usage_events` table | Device storage: it is lost when the learner clears the browser, uses a private window or changes phone, which is the exact moment the note is about; it breaks the rule, tested in jobs 14 and 15, that the app writes only the sign in cookie to the device; and job 15 already found that the EU rule on device storage is unsettled for "seen" flags (I did not read the EDPB text for this spec). User data on the sign in account: every write is a call to Supabase Auth's `/user`, which Supabase's rate limit page lists at 30 requests per 5 minutes per address, and every learner reaches Auth from the Worker's address (job 11, Decision 6); it would also be missing from the download file. `usage_events`: job 8's browser test counts exactly one event row per learner after the first session (`e2e/first-session.spec.ts`), so an extra event row would turn it red and force a change to a finished job's test |
| 3 | How the database knows the caller is a guest | The `is_anonymous` claim in the token, read with `auth.jwt()` inside the function | The Worker first asks `public.my_account()` (job 11) and calls the function only for guests | Supabase's anonymous sign in page says the token carries an `is_anonymous` claim "which you can use to distinguish in RLS policies", and PostgREST has checked the token's signature before the function runs, so this is not the unchecked cookie read job 11 forbids. One call instead of two, and every condition sits in one function where pgTAP can test each. The cost is that a token stays valid for up to an hour, but job 11 swaps the cookies when an email is added, so the old token is no longer sent from that device (statement 5 proves it) |
| 4 | How the answer reaches the screen | One extra field in the existing complete answer | A new route, or a second request from the finish screen | The finish screen already waits for that answer, so the note can only follow a saved session (statement 2), a failure cannot show a note over a "not saved" message, and no new route needs moving when job 17 changes addresses |
| 5 | Where the note sits | A plain block in the finish screen's content, in reading order, with "Done" untouched in the bottom bar | A modal or bottom sheet, or a banner on the front door | A sheet steals focus and needs a focus trap, which breaks the owner's "never blocks". The front door is where job 15's welcome and job 11's links live, and the moment the learner has just finished something is the point of the idea |
| 6 | Wording of the choices | "Add your email" and "Not now", the owner's words | "Maybe later", "Skip" | None of the sources I read showed a wording that works better. "Not now" says the choice is about time and not a refusal |
| 7 | Whether it comes back | Owner's call 1 | | |
| 8 | How loud the button is | Owner's call 3 | | |

New npm packages: none. New Worker routes: none. New database objects: one function. New tables or columns: none.

### Notes for the builder

- Order the work so that the migration, then the Worker, then the screen can each be tested alone. The migration timestamp comes from the manager, as in earlier jobs.
- In pgTAP, set the claims as `first_session.test.sql` does (`request.jwt.claims` with `is_anonymous`), and run the function as `authenticated`. Revoke execute from `public`, `anon`, `authenticated` and `service_role` in the migration, then grant to `authenticated` (Postgres grants `EXECUTE` to `public` by default).
- Keep the Worker call after `completeSession` returns `'saved'`, inside a `try` that swallows only this call's failure. Log nothing.
- Count finished sessions (owner's call 1 B only) with `dialogue_id is not null and ended_at is not null`. Review only sessions (job 9) have no dialogue and are not counted.
- In `FinishScreen.tsx`, `save()` currently answers a boolean. Return both the saved flag and whether the answer carried a note, keep job 14's "Send feedback" link and job 8's strict mode guard, and show the note only when the state is `saved`. Put the pure check of the answer in a small function with a Vitest test.
- `Button` already gives 44 px targets and explicit colours. Do not add a new button variant.

## What other apps do (research, 31 October 2026)

Short on purpose; the owner decided the timing already. I marked what I read and what I could not.

| Reference | What it shows | Borrow | Leave out |
|---|---|---|---|
| Duolingo, Appcues teardown (read): https://goodux.appcues.com/blog/duolingo-user-onboarding | Learners start without an account and get "periodic prompts to create an account". The article says signup is optional and "becomes increasingly compelling over time as users wish to save their progress". The button wording is not in the article | Optional, and asked after the learner has something to save. Owner's call 1 is about "periodic" | A repeated prompt, the mascot, and the progress bar before it |
| Babbel, Appcues teardown (read): https://goodux.appcues.com/blog/babbel-mobile-permission-priming | Registration is asked only after the first lesson is finished and the learner has seen the congratulations and score. The article does not say whether it can be skipped | The same moment the owner chose: after the first finished lesson | The score, and single sign on buttons for Google and Facebook (job 11 uses an emailed code) |
| ScreensDesign, Duolingo onboarding (read): https://screensdesign.com/articles/duolingo-onboarding-design/ | Says "too much account setup before this choice weakens momentum". Nothing about the account prompt itself | Keep the ask short and after the first lesson | Nothing else from it |
| ScreensDesign, mobile signup examples (read): https://screensdesign.com/articles/mobile-app-signup-flow-examples/ | One example (Joon) asks for an account at a step it labels "Save Your Result", after the learner built something. No example with a skip label | "Save" framing, tied to what the learner just did | Nothing |
| Guest login and account upgrade (search summary only, page not opened): https://crux.supercraft.host/blog/guest-login-and-account-upgrade/ | A vendor blog. Its advice, as the search summary gave it: keep the guest's data under the same user id so the prompt feels like saving and not restarting | Confirms job 11's design, which already keeps the same account id | Anything else; it is vendor content and unverified |
| Supabase, anonymous sign ins (read): https://supabase.com/docs/guides/auth/auth-anonymous | The token has an `is_anonymous` claim for use in access rules; converting means linking an email with `updateUser` | Decision 3 | Nothing |

**Could not verify.** I did not see Duolingo's or Babbel's current in app wording, whether either has a "Not now" label, or how often Duolingo repeats the prompt: the pages I read describe the flow without the screens, and Duolingo's own screens are in galleries I did not open. Mobbin and Refero were not tried. Everything above is third party description.

## Out of scope

- Any stored flag, table, column or event about the note (Decision 1), and anything stored on the phone.
- Sending any message to a learner (the note is on screen only), push or email reminders, a link in any email.
- A note on the front door, the account page, the review finish screen (`ReviewFinish`) or any other screen.
- Changes to the add email flow, the account page, sign in, deletion or the 90 day clean up (job 11).
- A dashboard or analytics event about how many learners see or tap the note. The owner page (job 14) is unchanged, so conversion is not measured; the owner can read how many guests became email accounts only from the database.
- Streaks, loss warnings ("you will lose your progress"), countdowns, rewards or celebration (the "Not in v3.0" list and the writing rules).
- The note for guests who finished their first session before this job ships. They get no first note; with owner's call 1 B they can still get the reminder.
- Sign in with Google or Apple, passwords, passkeys.
- Any Finnish text.

## Build plan

1. **Database.** One migration with `public.save_progress_note`, grants and revokes written out. pgTAP for each condition (and the reminder if call 1 is B), the `anon` refusal, the `stable` check, the repository test that the migration creates no table or type, regenerated types, the scratch red run. Covers 4, 8 (database part), 13 (migration test).
2. **Worker.** `saveProgressNote` on the learner database module, the extra field in the complete answer, the fake in `worker/test-fakes.ts`, unit tests for the answer, the failure case, the signed out case and the repeat. Covers 3, 6, 7 (Worker part).
3. **Screen.** `save-note-copy.ts` and its Vitest rules, the `SaveNote` component and CSS module, the wiring in `FinishScreen.tsx`, the path constant and its repository test, the `design.md` entry and `/design-reference`. Covers 9, 11, 12, 16, 17.
4. **Browser tests and records.** Tests for statements 1, 2, 5, 6, 7, 10 to 16 in both browsers, light and dark, including the `@email` tests and the repeat tests; docs; the list of changed earlier tests in `build.md`. Covers 1, 2, 5 to 8, 10 to 15, 18.

**Dependencies.**
- Jobs 8, 11 and 14 are merged. Mailpit in the local check (job 11) is the infrastructure the `@email` tests use.
- Preview links wait on the Cloudflare preview keys (todo). Until they exist, the evaluator runs the app locally with the throwaway database, as in earlier jobs. The `@email` tests are skipped after merge and on previews, as job 11 set up.
- Owner's calls 1 to 3 answered before the build starts.
- The `/learn` move is not built yet. This spec names it as a dependency in statement 17 only.

## Risks and flags

- **Look closely: learner data.** The function reads a learner's account kind and session history. It stores nothing and writes nothing (statements 4 and 13). The note's only link to personal data is that it changes what an account holder sees.
- **Look closely: database access rules.** One new function a learner can call. It is `security invoker` and `stable`, and its grants are written out. The pgTAP tests and the scratch run are the main protection, as in job 9's functions.
- **The promise and the taken email.** "Keep your progress" is true when the email is new. If the guest types an email that already has an account, job 11 deletes the guest's progress on this phone and signs them in to that account. Job 11's screen says so in two sentences before any code is sent, and statement 10 checks it is still there. The owner may want the note to say more; that is part of owner's call 2.
- **The same finish saved twice shows the note twice.** By design (statement 7, Decision 1). It happens only on a retry after a lost answer, when the learner may not have seen it the first time.
- **Reminder needs three dialogues.** If call 1 is B, a guest sees the reminder only after finishing three dialogues. Units 1 to 3 are drafted and wait for the native reviewer's batch, so until they are published the reminder can only be tested with extra finished session rows.
- **Earlier tests look for one `status` on the finish screen.** The note and its follow up line must not use `role="status"`, `role="alert"` or `aria-live` (statement 12), or a finished job's tests break.
- **Coordination.** Job 15 changes only the front door. Job 16 (held) adds a Use it step before the finish screen from unit 4; the note hangs on the complete answer and not on the steps, so it needs no change as long as the finish screen still saves once at the end. Job 17's rewrite moves the app under `/learn`; statement 17 covers it.
- **No paid service, no cost, no Finnish content, no consent or recording change.** €0. The wording is English.
- **No legal text changes.** Nothing new is stored, so the privacy notice stays as approved. If owner's call 1 or a later job adds a stored flag, the notice, the data inventory and the download must change in the same job (job 11's rule).

## Owner's calls

**1. Does the note come back?** The note appears on the first finished session. After that, three choices.
- A. Never again. The learner is asked once. The account page still has "Add your email" for anyone who changes their mind. Least pushy. Someone who said "Not now" on day one and stops using the app after day three loses their progress after 90 days without a reminder.
- B. One reminder, on the learner's third finished session, only if they are still a guest (recommended). Same words, same screen, nothing stored. By the third session the learner has more to keep and has come back twice, so the ask is more relevant than it was on day one. It needs three published dialogues to ever show. Then never again.
- C. Every finish screen until they add an email. Highest sign up, and the pressure is the kind the owner's rules and the writing rules rule out. I advise against it. If chosen, the spec comes back to me, because it needs a stored count.
- Recommendation: **B**. It keeps to "no more than one gentle reminder".

**2. The words.** The draft is in "Note wording". Final words are approved at job approval.
- A. Your sentence, word for word: "Add your email to keep your progress and use it on other devices." (recommended).
- B. Shorter: "Add your email to save your progress." Drops the other devices benefit, which is the reason a learner would bother.
- C. Add a reason: "Your progress is only on this phone for now. Add your email to keep it and use it on other devices." Clearer about why, but the first sentence can read as a warning.
- Recommendation: **A**. Whichever you pick, the wording must keep the rules in statement 9.

**3. How loud the "Add your email" button is.**
- A. A white button with an edge (the secondary style), with "Not now" as plain text and "Done" still the only black button (recommended). Finishing stays the main action. Fewer learners tap it than with B.
- B. A black button (the primary style) above "Done". More learners tap it. Two black buttons compete on a screen where the design system says one main action, and "Done" no longer looks like the way out.
- Recommendation: **A**.

**Owner inputs (not choices):** none for money, names or contacts. Approve the wording at final approval.

No design direction call: the note uses the locked design system and existing buttons. The pattern references above are for the owner's information.

## Could not verify

- Duolingo's and Babbel's current in app wording, their skip labels and how often Duolingo repeats its prompt (see "What other apps do").
- That the `is_anonymous` claim in the token is false immediately after job 11 swaps the cookies on the local Supabase. Job 11 renews the session for this reason; statement 5 proves it end to end.
- Whether the fixture has three dialogues (needed only for call 1 B's browser test; the spec gives a fallback).
- The EDPB's text on device storage (job 15 cites it; I did not read it here, and the pick avoids the question).
- How many dialogues will be published at launch, which decides whether a reminder can ever show.

## Sources

- Project: `AGENTS.md`, `factory/jobs/11-accounts/spec.md`, `factory/jobs/15-onboarding/spec.md`, `factory/jobs/17-landing-page/spec.md` (before its rewrite), `factory/progress.md` and `factory/specs-waiting.md` (owner's decisions of 31 October 2026), `docs/data-model.md`, `supabase/migrations/20261021182910_first_session.sql`, `supabase/tests/database/first_session.test.sql`, `src/screens/FinishScreen.tsx`, `src/screens/SessionPage.tsx`, `src/screens/EmailFlow.tsx`, `src/screens/AccountPage.tsx`, `src/components/Button.tsx`, `src/privacy/data-inventory.ts`, `worker/account.ts`, `worker/api.ts`, `worker/learner-db.ts`, `worker/sessions.test.ts`, `e2e/account-helpers.ts`, `e2e/first-session.spec.ts`, `design.md`
- PRD: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md` (guest start, email account and progress sync are in the MVP list; the "Not in v3.0" list)
- Supabase anonymous sign ins (the `is_anonymous` claim, converting with `updateUser`): https://supabase.com/docs/guides/auth/auth-anonymous
- Supabase rate limits (`/user` at 30 requests per 5 minutes per address, read 31 October 2026): https://supabase.com/docs/guides/auth/rate-limits
- Duolingo: https://goodux.appcues.com/blog/duolingo-user-onboarding, https://screensdesign.com/articles/duolingo-onboarding-design/
- Babbel: https://goodux.appcues.com/blog/babbel-mobile-permission-priming
- Signup flow examples: https://screensdesign.com/articles/mobile-app-signup-flow-examples/
- Guest account upgrade (search summary only): https://crux.supercraft.host/blog/guest-login-and-account-upgrade/

Result: ready for owner approval
