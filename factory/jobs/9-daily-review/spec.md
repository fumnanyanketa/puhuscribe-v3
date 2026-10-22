# Job 9-daily-review: Daily review (Keep it)

Scope item 7. Routine, handles learner data. Needs a decision. Date: 21 October 2026. Builds on jobs 1 to 5 as merged and on `8-first-session` once it merges. Runs beside `10-speaking-feedback` and `11-accounts`. Test label: `[review N]`.

## Summary for the owner

1. Words a learner met in a dialogue come back for review from the next day. They see the English meaning and the dialogue line with one word missing, can play the line, and type the missing word.
2. v2's grader marks the answer (right, close, or not yet) and v2's scheduler picks the next review date. The learner never rates themselves, and they always see the right word after answering.
3. Review is the Keep it step at the end of today's session. When no new dialogue is ready, today's session is the review alone. The front door still has one button and no mode picker.
4. When nothing is due, the front door says so plainly and names the day of the next review. No streaks, counts, scores or confetti.
5. Costs nothing, adds no table, needs nothing from you before the build. Spoken answers plug into the same place in job 10.

## What it is

The Keep it step of the loop. Job 8 puts every form a learner met into their review queue. This job brings those forms back when they are due: the learner recalls each one by typing it into the line where they met it, the answer is graded automatically, and the form is rescheduled from the result. It serves P2 (spaced retrieval, scheduled automatically, no self rating), P1 (every prompt is a line from a dialogue the learner heard, never a word list) and P5 (spoken first, written shown alongside, both with audio).

## Done when

Terms used below. "Phone size" and "browser test" mean what they mean in job 8: Playwright at 375 x 812 in Chromium and WebKit, against the built app and a throwaway local Supabase from `6-pr-local-db`. "The fixture" is job 8's `supabase/seeds/test-fixture-unit-1.sql`, used unchanged. "A day later" means a test helper moves the learner's card times (`created_at`, `due`, `last_review`) back 24 hours in the local database only. "Helsinki day" means the calendar date in the `Europe/Helsinki` time zone. Tags: **[security]** and **[personal data]** mark statements the reviewers and evaluator check closely.

### Which cards come up

1. **One rule decides what is reviewable.** A card is reviewable now when its form is readable by the learner (approved, through job 3's rules), its `due` time has passed, and the Helsinki day it was last touched (`last_review`, or `created_at` if never reviewed) is before today. One database function, `public.review_queue(p_limit integer)`, returns the learner's reviewable cards (form id, `reps`, `due`), oldest `due` first, then lowest form id, at most the smaller of `p_limit` and 15. pgTAP with learners A and B proves: a card made today is not returned; one made yesterday is; one reviewed today is not; one due tomorrow is not; one whose form was set back to draft is not; B's cards never reach A; the limit and the order hold; `anon` cannot call it. **[personal data]**
2. **The next review day is known.** `public.next_review_day()` returns the earliest Helsinki day on which one of the learner's cards becomes reviewable by the rule in statement 1, together with today's Helsinki date, or no day when the learner has no cards. pgTAP covers today, tomorrow, a later date and no cards. **[personal data]**
3. **Every prompt is a line the learner met.** For each card the Worker picks one line with one tested function: approved lines in dialogues where the learner has a session with `step_reached` at least `understand`, preferring a line whose spoken tokens link to the form, then one whose written tokens do; ties go to the lowest unit position, then dialogue position, then line position. A card with no such line, or whose form became unreadable, is skipped: not shown, not graded, not changed. Vitest covers the picker; a Worker unit test with a fake database covers the skip.

### The front door

4. **One button, four states.** The front door adds review to job 8's states, never as a second choice. Browser tests with the fixture drive each state:
   - **First day, after dialogue 1.** Job 8's state for the next dialogue, with no mention of review (cards made today wait, statement 1).
   - **A day later, dialogue 2 ready, cards reviewable.** Job 8's front door, with one sentence added after its description: "It ends with a short review of words you met before." One "Start" button.
   - **No new dialogue ready, cards reviewable.** Heading "Today's session", the sentence "A short review of words you met before. Type each missing word from memory." and one "Start" button.
   - **Nothing ready and nothing reviewable.** Statement 5.

   An unfinished session of either kind shows job 8's "Continue today's session". No count of due words appears anywhere on the front door.
5. **An empty day is plain and kind.** The front door shows the wordmark, the heading "That is all for today.", job 8's sentence "You have finished every dialogue that is ready." and "Your next review is later today.", "Your next review is tomorrow." or "Your next review is on Saturday 24 October." (weekday and date in English). There is no button, and no streak, count, score, badge, illustration or celebration. One unit-tested function turns the two dates from statement 2 into that wording, including across the end of a month, the end of a year and a daylight saving change. The device clock is never used. Browser test.

### Keep it inside a session

6. **Keep it is a step in job 8's step list.** Keep it is added to the one ordered step list after Understand it, and after Say it once job 10 merges. A session includes it only when the learner had a reviewable card when the session screen loaded; the top bar then reads "Keep it, step 3 of 3". Without one, the session reads "step 1 of 2" exactly as in job 8, and job 8's tests stay unchanged and green. Finishing Keep it stores `step_reached = 'keep'`, then the finish screen calls `complete_session` exactly as in job 8. "Continue today's session" after Understand it resumes at Keep it. Browser test, including the database values. **[personal data]**
7. **A review-only session when no dialogue is ready.** Start adds one `sessions` row with an empty `dialogue_id`, or reuses the learner's unfinished one. Its step list is Keep it alone ("Keep it, step 1 of 1"). At the end the Worker sets `step_reached = 'keep'` and `ended_at`, and does not call `complete_session`. The finish screen says "Review finished." and "These words will come back when they are due." with one "Done" button back to `/`. No counts, scores or celebration. Browser test checks the screen and the row. **[personal data]**

### One review item

8. **The prompt.** Each item shows a short instruction "Type the missing word.", the line's English gloss, the speaker label, and the picked line in its register (spoken on the teal band, or written with its label) with every word of that form replaced by a gap the screen reader calls "missing word". The line is `lang="fi"`. One play control ("Play the spoken line" or "Play the written line") plays the line's approved file at `/audio/<key>` (job 8's addendum), only when pressed. The other register and the words' cards appear only after answering. On the first pass the item shows its place, such as "3 of 15". No answer reaches the browser before the learner answers: the items response holds no form surface, no token of the gap and no line text for the other register (Worker unit test, and a browser test reading the response).
9. **Typing works on a phone.** One text field labelled "Type the missing word", with `lang="fi"`, `autocapitalize="off"`, `autocorrect="off"`, `spellcheck="false"`, `autocomplete="off"`, `enterkeyhint="done"` and at most 100 characters. Two buttons under it, named "Type ä" and "Type ö", insert the letter where the cursor is and keep focus in the field. The primary "Check" is unavailable while the field is empty, and Enter submits. A quiet "I don't remember" submits an empty answer. Browser test types with the ä button and submits with Enter.
10. **Graded by v2's grader, unchanged.** `POST /api/review/answer` takes the session id, the form id, the typed text and the answer kind `typed`. The Worker reads the card and the form with the learner's token and grades with `gradeAnswer` from `src/lib/grade.ts` against the form's spoken shape and its written shape, keeping the better result (correct before close before wrong). Correct gives the rating Good, close gives Hard, wrong or empty gives Again; this rating is the only one that exists. The request carries no rating, card value or user id, and any field outside the four above, text over 100 characters, or a kind other than `typed`, answers 400. Vitest cases for the wrapper: the exact spoken shape, the exact written shape, capital letters, a missing ä (close), one slip in a long word (close), another word (wrong), empty, and extra spaces or punctuation. **[security]**
11. **Rescheduled by v2's scheduler, saved in one step.** The Worker runs `new FSRS().schedule(card, rating, now)` with its default settings, then calls `public.record_review(...)` once. In one transaction the function updates the card to the new values and adds one `review_logs` row with the grader's rating, mode `typed` and the log values, but only while the card's `reps` still equals the value the Worker read. Otherwise it writes nothing and the Worker answers 409, and the screen keeps its first result. pgTAP proves A cannot record a review on B's card, a stale `reps` writes nothing, a log row that fails its checks leaves the card unchanged, and `anon` cannot call the function. A browser test answers one item right and one wrong, then finds two log rows (ratings 3 and 1) and card values equal to what the same engine computes from the stored `review_time`. **[security] [personal data]**
12. **Feedback is gentle and always shows the word.** After Check, the status line says "Yes, that is right." (neutral) for correct, "Close. Check the spelling below." (gentle) for close, and "Here is the word. It will come back soon." (gentle) for wrong or "I don't remember". Then the full line appears in both registers with both play controls and tappable words (`FinnishLine` and `WordCard` as in job 8), the answer word marked in both lines, the form's spoken and written shapes, and "You wrote" with the typed text (`lang="fi"`) when something was typed. No red, no score, no count of mistakes, and never the words "wrong" or "incorrect". Primary "Next". Browser test covers all three results.
13. **One more try in the same run.** An item graded close or wrong comes back once more after the other items, without a place number, and is graded and saved again (a second log row). It does not come back a third time in that run; statement 1 then holds it until the next Helsinki day. Vitest covers the run order function; a browser test covers one retry.
14. **Leaving mid review loses nothing checked.** Answers already checked stay saved. "Continue today's session" restarts Keep it with whatever is still reviewable, so answered cards do not repeat. Browser test.

### A clean slot for spoken recall (job 10)

15. **The answer method is one list.** The review item takes its answer methods from one list in one file, today only typing. The grading wrapper takes an answer with a kind (today only `typed` with text) and returns the grader's result and rating. Job 10 adds a `spoken` kind (a transcript graded the same way, saved with mode `spoken`) without changing the item, the queue, the scheduler call or the database. A Vitest test proves a second method added to the list renders in the item's answer area.

### Safety, data and records

16. **The routes follow job 8's protections.** Every new route answers 401 without a sign in, reads and writes only with the learner's own token, never uses a Supabase secret or service role key, takes the user id only from the token, and answers 404 for a session id that is not the learner's. Routes that change something accept only `POST` with JSON and refuse other origins (job 8 statement 5). Worker unit tests. **[security]**
17. **Nothing unapproved is served, and the typed answer is never kept.** Every Finnish word in Keep it comes from approved lines and forms read with the learner's token; the fixture's draft line and draft form never appear in any review response (Worker unit test and browser test). The typed text is used for grading and the "You wrote" line, then dropped: no table stores it, and no Worker log holds it, nor a cookie, token or user id (a unit test watches `console`). **[security] [personal data]**
18. **One migration, functions only.** One new migration adds `review_queue`, `next_review_day` and `record_review`, each `security invoker` with `search_path = ''`, execute removed from `public` and `anon` and granted to `authenticated` only. It adds no table or column and leaves job 8's `complete_session`, `usage_events`, enum values and fixture unchanged. `src/lib/database.types.ts` is regenerated by the Supabase CLI. A scratch branch that makes `record_review` `security definer` turns the "A cannot record on B's card" test red, and the run is linked in `build.md`. **[security] [personal data]**
19. **The v2 engines stay unchanged.** `src/lib/grade.ts` and `src/lib/fsrs/*` are byte for byte the same and `tests/v2-imports.test.ts` passes. If the Worker's TypeScript settings refuse v2's enums, the builder turns off the same two options for the Worker as `tsconfig.app.json` did, and records it under "Settings changed" in `docs/v2-imports.md`.
20. **Phone, keyboard, accessibility.** As job 8 statement 22 for every new screen: nothing scrolls sideways at 320 px wide or with text at 200 percent; every control, including "Type ä" and "Type ö", is at least 44 x 44; the whole review works by keyboard alone in reading order; `@axe-core/playwright` finds no WCAG 2.0 to 2.2 A or AA violation in light and dark mode. All earlier tests stay green and unchanged.
21. **Records.** `docs/conventions.md` adds the `[review N]` label row. `docs/data-model.md` describes the three functions and the reviewable rule in plain words. The README "Running costs" stays at €0. `build.md` lists any new npm package with its reason (none expected) and the check minutes of one full pull request run.

Product rules from `AGENTS.md` that apply: P1, P2 and P5 as above; one front door, the learner never picks a mode; nothing unmet is reviewed (statement 3 and job 3's card rule); grammar only behind a tap; gentle corrections, never shaming; no self rating; AI never grades or schedules, and this job makes no AI call; nothing unapproved is served; GDPR minimum data, with export and deletion through job 3's cascade; agents use only the test database; no placeholders or fake data in the app; never delete or weaken a test; client facing text in English; the "Not in v3.0" list is binding.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | Where review appears | The Keep it step at the end of today's session, and a review-only session when no new dialogue is ready. The front door keeps one button | A separate "Review, 7 due" entry beside today's session, like v2's review hub (`design/v2-handoff/app-screens/screens-review.jsx`) | Two entries are a mode picker, and v2's hub showed word counts toward 1,000 words, which is the vocabulary bank on the "Not in v3.0" list. Review first, before Hear it, also lost: the loop order is binding |
| 2 | What the prompt is | The line where the learner met the form, with the form missing, plus its English gloss and the line's audio on press | v2's recall screen: an English word ("to be"), type the Finnish | Forms have no English word gloss in the data model, so this would change job 7's contract, and an isolated word is a word list (against P1). The gapped line uses only approved content that already exists |
| 3 | Which answer counts | Either the spoken or the written shape of the form, whichever grades better | Only the shape of the register shown | Typing correct written Finnish into a spoken line would come back as a miss. Both registers are right Finnish (P5), and being marked down for right Finnish is the kind of correction the product promises not to make |
| 4 | When a card comes up | Due by the scheduler, at most once per Helsinki day, new cards from the day after they were met, plus one retry inside the same run | Every card whose due time has passed, including v2's 1 and 10 minute learning steps | The front door would offer a new review minutes after each run and could never reach a finished day. The PRD's session is about 10 minutes a day, and the scope asks for review "the next day". The in-run retry keeps a short repeat for missed words |
| 5 | Run size | At most 15 cards per run, oldest due first | No cap | After a missed week the review would swallow the whole session. 15 is my estimate (about 15 to 20 seconds per typed word, not measured); it is one constant to change |
| 6 | Where grading and scheduling run | In the Worker, saved by one database function | The browser grades, schedules and writes the card | The browser would hold the answer before the learner types and could send any rating, which is a self rating by another route. Two separate writes could also leave a log without its card change |
| 7 | Where "today" comes from | `Europe/Helsinki`, worked out in Postgres with `at time zone` | The learner's device time zone | Learners live in Finland and a device clock can be wrong or changed. Postgres documents time zone conversion; Cloudflare does not document which time zone data its Workers runtime ships (not verified) |
| 8 | What the learner sees after answering | The right word and the full line every time | Only "right" or "not yet" | Pashler and colleagues (2005) found that giving the correct answer after an error greatly raised retention a week later, while feedback after a correct answer made little difference |
| 9 | Test content | Job 8's fixture unchanged, with a test-only helper that moves card times back a day in the local database | A new fixture, or waiting a real day | A new fixture would duplicate job 8's; waiting a day cannot run in a check. Job 8's two approved dialogues already give every front door state |

New npm packages: none.

### Notes for the builder

- Rows come back from Supabase with times as text and `state` as the same strings as v2's `State` enum. Convert them to the `Card` type before `schedule()`, and convert the result back for `record_review`.
- `record_review` takes the form id, the `reps` the Worker read, the new card values, the rating, the mode and the log values. The learner's existing column grants already allow both writes; the function adds no rights.
- The gap replaces each token of the picked line, in that register, that links to the card's form. Job 7 guarantees each token's text appears in order in its line (job 7 addendum, content 21).
- The text field is a new component in `src/components/` built from existing tokens. Borrow the layout of v2's recall screens (`screens-review.jsx`, "Recall" and "Recall graded"), without their small uppercase labels, the big tick circle and the coloured page wash. The design reviewer checks it against `design.md`.
- The front door's data route from job 8 gains two facts from the database: whether a card is reviewable now, and the two dates from statement 2. The browser words them; it never reads its own clock for this.
- Coordinate the step list order and migration timestamps with `10-speaking-feedback` and `11-accounts` through the manager. Say it sits before Keep it.

## Out of scope

- Spoken recall, the microphone, transcripts and the `spoken` mode (job 10). Only the slot in statement 15 exists.
- Export, deletion buttons, the privacy notice and email accounts (job 11). Review logs are covered by job 3's cascade.
- Any change to job 8's data: its tables, enum values, `complete_session`, `usage_events` or fixture.
- New content, new tables or columns, English word glosses for forms, or per-word audio (jobs 7 and 12).
- The "Patterns you've seen" panel (job 12), analytics (job 14), notifications or reminders, install and offline behaviour.
- Any AI call.
- From the "Not in v3.0" list and the scope: no streaks, rank titles, confetti, milestone ladder or journey map; no vocabulary bank, word list, "words learned" count or review hub; no mode picker or practice modes; no grammar lessons; no bilingual or Finnish-only toggle; no mnemonics; no YKI content.

## Build plan

1. **Database.** The migration with `review_queue`, `next_review_day` and `record_review`, pgTAP for both learners, regenerated types, the red scratch run. Covers 1, 2, 11, 18.
2. **Worker.** The line picker, the grading wrapper, the run order function, the items and answer routes, the review-only session, the front door facts, quiet logs. Unit tests with fakes. Covers 3, 10, 13, 15 to 17, 19.
3. **Screens.** Front door states, Keep it in the step list, the review-only session and its finish screen, the review item, the text field with ä and ö, the feedback view, the date wording. Covers 4 to 9, 12, 14.
4. **Browser tests and records.** Full runs at phone size on the local database with the day-later helper, accessibility checks, docs. Covers 20, 21 and proves the rest end to end.

**Dependencies.**
- `8-first-session` merged: its step list, session frame use, guest sign in, front door, fixture and `complete_session`.
- `6-pr-local-db` merged, so pull request browser tests run on a throwaway local Supabase.
- Job 7's real dialogue is not needed. Browser tests read expected content from the database, so they also pass when it is present.
- New functions reach the shared test project only on merge (owner's rule from job 3), as in job 8.

## Risks and flags

- **Look closely: learner data.** Review logs are a dated record of what each learner remembered and missed. They stay in the EU database, are reached only by their owner, and are removed by job 3's cascade when the account is deleted. Job 11's export must include them. The typed answer is never stored (statement 17).
- **Look closely: database access.** Three new functions; one writes learner rows. They run as the learner, so the existing rules still apply, and statement 18 proves the main protection can fail.
- **A learner can change their own schedule.** As in job 8, a learner who copies their cookie can call Supabase directly and write any values to their own cards and logs. It touches only their own data; the analytics job should not treat review logs as proof of learning.
- **Short words grade loosely.** v2's grader allows one slip in any word, so for a two-letter word another word can count as close (for example "ja" for "jo"). The grader stays unchanged by rule; if this matters in use, the fix is a new wrapper rule in a later job.
- **Phone keyboards.** Turning off autocorrect is new to some browsers (MDN marks `autocorrect` as Baseline 2026), so older phones may still change Finnish words as they are typed. Playwright cannot show the on-screen keyboard, so whether it covers the "Check" button on a real iPhone is checked by the owner during daily use.
- **No new Finnish.** Prompts reuse approved lines with a word removed. The fixture's Finnish stays in throwaway databases only, as in job 8, and nothing goes to the native reviewer.
- **Running costs.** €0. Database functions and a few more Worker requests per session, within the free plans.

## Owner's calls

None. No spending, brand, design direction or publishing choice is involved. The product choices in the Decision table (once a day, 15 per run, both registers accepted) are open to change at your final approval.

## Could not verify

- Which time zone data the Cloudflare Workers runtime ships; the spec avoids depending on it.
- How browsers before 2026 treat `autocorrect="off"`.
- How long one typed review takes on a phone; the cap of 15 is an estimate.
- Whether the Worker's TypeScript settings accept v2's enums without a change (statement 19 covers both cases).

## Sources

- PRD sections 3, 4.1, 5 and 7.2: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- Scope item 7 and inherited rules: `docs/scope/scope.md`
- Job 8 spec and its manager addendum: `factory/jobs/8-first-session/spec.md`; job 7 addendum: `factory/jobs/7-content-pipeline/spec.md`
- Data model: `factory/jobs/3-data-model/spec.md`, `docs/data-model.md`, `supabase/migrations/20261020090100_learner_model.sql`
- v2 engines: `docs/v2-imports.md`, `src/lib/grade.ts`, `src/lib/fsrs/scheduler.ts`, `src/lib/fsrs/types.ts`
- v2 review screens: `design/v2-handoff/app-screens/screens-review.jsx`; design system: `design.md`, `src/components/`
- Pashler, Cepeda, Wixted and Rohrer (2005), "When does feedback facilitate learning of words?": https://www.yorku.ca/ncepeda/publications/PCWR2005.pdf
- MDN, the `autocorrect` attribute (Baseline 2026): https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/autocorrect
- PostgreSQL date and time functions, `AT TIME ZONE`: https://www.postgresql.org/docs/current/functions-datetime.html
- Supabase, calling database functions from the JavaScript client (`rpc`): https://supabase.com/docs/reference/javascript/rpc

Result: ready for owner approval
