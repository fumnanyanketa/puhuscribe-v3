# Job 15-onboarding: Onboarding

Scope item 13. Not GA. Needs a decision. Date: 30 October 2026. Builds on main as merged, including jobs 8-first-session, 11-accounts and 14-analytics. Runs beside the specs for `16-tutor-step` and `17-landing-page`. Test label: `[onboarding N]`.

## Summary for the owner

1. A new visitor sees a short welcome (73 words) on the front door, right above Start. It says what a session is, and two plain bands, "Spoken" and "Written", show what the two forms of Finnish mean in the app. One tap on Start takes them to the first dialogue line.
2. Who sees it: anyone with no account on that phone. Pressing Start makes the guest account, so they never see it again. Nothing new is stored on the phone or in the database, so the privacy notice does not change.
3. The welcome has no Finnish, no quiz, no level question, no carousel and no buttons of its own. Everyone starts at A0, as the scope says.
4. The "can say it in their own words" part is proven by a hallway test with 5 real adults, run by you with a stopwatch. It takes about 40 minutes of your time after the build and needs a link that opens on a phone.
5. Costs €0: no new service, no database change, no AI call, no new package. Five calls are yours: the shape of the welcome, the look, the age line, the hallway test and whether any Finnish appears.

## Owner's calls

**1. The shape of the welcome.**

- **A. One block on the front door (recommended).** The welcome sits between the lead sentence and Start. Start is the skip, so there is no Skip button. Nothing that works today changes. The risk is crowding on a small phone; Done when 9 makes the builder fit it or trim words.
- **B. Two short screens on their own page, `/welcome`, with Continue and Skip.** Bigger type and one idea per screen. It costs one to two more taps before the first line and a new page that the visit counter must list. It also changes the tests that open `/` as a new visitor: a search for `goto('/')` finds 32 places in 11 browser test files, and each one that acts as a new visitor would first need a Skip tap. Nothing would be weakened, but it is a long list.
- **C. No welcome page at all; explain inside the first Hear it step.** The explanation would sit next to real approved Finnish, which helps understanding, and it needs no new Finnish. It does not match the scope's "welcome, then lands in the session", and it changes the Hear it screen and its tests.
- Recommendation: **A**. The research below points the same way: the best apps get to the first lesson fast, and tutorial screens did not help in the one controlled study found.

**2. The look.**

- **A. The existing design system only, with no new pictures (recommended).** The two bands use the same teal band and violet label as the Hear it screen, so the learner meets them again a few seconds later. €0.
- **B. One drawn picture, for example two speech shapes.** It needs an illustrator or generated art, which is a new brand asset and a spend, and it can drift into v2's glossy bubbles, which your banned list rules out. If you pick B, the builder first makes one overview page naming each picture, and you choose before any screen is built.
- Recommendation: **A**. If you pick A, no overview page is needed and the builder shows one sample screen in light and dark mode as part of the design review.

**3. The age line (PRD section 10: under 18s out of scope, "stated in terms").** No terms of service exist yet (job 11 left them out), so today the statement sits in the guest line under Start ("PuhuScribe is for adults, 18 and over.") and in the privacy notice. I have not decided this.

- **A. Keep the existing line directly under Start (recommended).** The statement is read at the moment of starting. No extra tap, no data. It proves nothing about who taps Start.
- **B. Add a tick box, "I am 18 or older", that must be ticked before Start works.** Stronger sign that the notice was seen. One more tap at the moment speed matters, and the welcome would no longer be a block with no controls. If we stored the tick, it would be new personal data to export and delete.
- **C. Ask for an age or birth year.** It collects personal data, and a child can type any number. Not recommended.
- Whichever you pick, the welcome must not move the line away from Start.

**4. The hallway test, who runs it and when.** Done when 12 needs about 40 minutes of your time and 5 adults who have not seen the app.

- **A. Run it after the build and before you approve (recommended if a phone link exists by then).** The job stays "waiting for the owner" until the sheet is filled in.
- **B. Approve the build on the automatic checks, run the test during your two weeks of daily use, and keep this scope item open until the sheet is in.** Faster to merge. If the test fails, the fix comes after the merge.
- **C. Let an AI agent read the welcome and say what it understood.** Cheap, but it tells us nothing about real learners. I would use it only as a spare check, never as proof.
- Pass bar, my proposal, yours to change: at least 4 of 5 people reach the first dialogue line within 60 seconds, and at least 4 of 5 explain both forms correctly in their own words.

**5. Finnish in the welcome.**

- **A. No Finnish (recommended).** The bands use the English labels "Spoken" and "Written", the same as the Hear it screen. Nothing needs the native reviewer.
- **B. Add the two Finnish names, puhekieli and kirjakieli.** Helps people who meet the words elsewhere. The job is then flagged and the native reviewer checks the two words. The words appear nowhere else in the app today, so they would need an explanation.
- **C. Show one Finnish example pair, such as v2's "Minä olen kotona" and "Mä oon kotona".** Most concrete. It would be new Finnish outside the content pipeline, so it goes to the native reviewer. A new visitor has no account, and approved lines are readable only by signed in learners (`supabase/migrations/20261020090000_content_model.sql`, grant at line 370), so the app cannot show an approved line yet without changing the database access rules. Not recommended.

**Owner inputs (not choices):**

- Approve the welcome wording at final approval (the draft is under "Welcome wording"). If you prefer v2's own English line "Books teach one Finnish. The street speaks another." in place of the sentence "Every line comes in two forms, and you can hear both.", say so.
- 5 adults and about 40 minutes for the hallway test (Done when 12). Their names are not collected.
- A link that opens on a phone. Preview links still wait for the Cloudflare preview keys (todo, 29 October), and the live app waits for the go live job from job 14. Until one of them exists, the hallway test cannot start.

## What it is

The front door gets a short welcome for people who have no account on the phone yet. It tells them what a session is and what "Spoken" and "Written" mean here, then Start takes them straight into the first dialogue. It asks nothing, stores nothing and tests nothing. It serves P5 most (both forms from the first line, spoken first) and P1 (short dialogues) through the one sentence about the session.

The PRD's fair plan (22 to 25 October, QR flow for the stand) is over and nothing here depends on it.

## Done when

Terms. **New visitor**: a fresh browser context with no cookies and no stored data, so `/api/today` answers that nobody is signed in. **Returning learner**: a browser that holds a guest or email account. **Browser test**, **phone size** and **the fixture** mean what they mean in jobs 8 and 11: Playwright at 375 x 812 in Chromium and WebKit, against the built app and a throwaway local Supabase with the fixture dialogue. **The welcome**: the block described below. **axe** is an automatic accessibility checker; it runs through `@axe-core/playwright`.

### The welcome

1. **Where it sits.** For a new visitor, `/` shows in this order: the wordmark, the heading "Today's session", the lead sentence, the welcome (a region named "Welcome to PuhuScribe", with that text as its `h2`), the Start button, the guest line directly under Start with nothing between them, "I already have an account", then the privacy and account links. The heading and lead sentence are job 8's words, unchanged. Browser test of the order, in both browsers.
2. **The words.** The welcome's text is exactly the "Welcome wording" below, held in one file, `src/screens/welcome-copy.ts`, as exported constants (the owner may edit them at approval). A Vitest test checks, on that file: at most 80 words counting the heading and band labels; no em dash, no hyphen used as punctuation and no colon in the sentences; none of the words seamless, unlock, elevate, empower, supercharge, game-changer, cutting-edge, effortless; none of "Day One", "Sprint", "streak", "confetti", "points", "level", "quiz", "placement"; and that the text contains the labels "Spoken" and "Written". A browser test checks that the page shows that text and no other text inside the region.
3. **The two forms, drawn as in Hear it.** The region holds two bands in the order Spoken, then Written. Each band carries its label as text, so colour is never the only sign. The Spoken band uses `--color-spoken-band` with `--color-spoken-text` for its label; the Written label uses `--color-written`; the sentences use `--color-text`. A browser test reads the computed colours in light and dark mode and compares them with the tokens. The azure colour is not used, because azure only marks words that change (`design.md`).
4. **It asks nothing and has no controls.** The region contains no button, link, input, select or text area, so there is nothing to tap inside it and no level, goal or age question. It contains no element with `lang="fi"` and its copy file has no ä, ö or å (Vitest), unless owner's call 5 says otherwise.

### Who sees it, and when

5. **Only new visitors.** The welcome shows only when `/api/today` answers that nobody is signed in, and the answer is not "ended", is not an email account's signed out state, and the address carries no `?notice=` message. Browser tests, each in both browsers: a new visitor sees it; a guest who pressed Start and returns by "Leave session" does not; an email account (the fixture's, as in job 11) does not; a guest whose account was deleted in the database (the "ended" message) does not; each of the three notices (`signed-out`, `signed-out-email`, `deleted`) shows its message and no welcome. A returning learner's front door is otherwise the same as before this job.
6. **No flash, and offline is fine.** The region is not in the page until `/api/today` has answered: a test delays that answer by 2 seconds for a guest and checks the welcome never appears. When the request fails (the test aborts it), the welcome shows, and Start's failure message, "Could not start your session. Check your internet connection, then try again.", is job 8's own and unchanged.

### Nothing new is stored or sent

7. **No storage, no new request, no new code outside the app.** For a new visitor, from loading `/` to opening Hear it, a browser test finds: only the same requests as today (the app's files, `GET /api/today`, then job 8's Start and session requests), all to the app's own address; `document.cookie` empty before Start; `localStorage.length` and `sessionStorage.length` both 0 at `/` before Start and at `/session` after it. The command `git diff --stat main...HEAD -- worker supabase wrangler.jsonc package.json package-lock.json src/privacy` prints nothing: no new route, migration, setting, package or privacy notice change. The notice needs no new line because nothing new is kept. **[personal data]**

### Speed

8. **One tap from the front door to the first line.** A browser test as a new visitor presses Start once and nothing else. Hear it opens with the first dialogue line's spoken text on screen (read from the database, so it also passes when job 12's real dialogue is first) with its play controls, and no other click was needed. The test records the time from the press to the line and fails above 10 seconds on the local stack. That limit guards against a slow regression. It does not measure people; statement 12 does. Loading `/` still creates no account (job 8's `[session 1]`).
9. **Start and the guest line fit on the first screen.** At 375 x 812, in both browsers and in light and dark mode, a new visitor sees the whole Start button and the whole guest line without scrolling. If they do not fit, the builder tightens spacing, then the optional third paragraph of the welcome, and never the guest line. A smaller phone may scroll, and then Start stays reachable by keyboard before the links.

### Phone, keyboard and look

10. **Accessibility.** For the new visitor's front door: nothing scrolls sideways at 320 px wide or with text at 200 percent; Start stays at least 44 px tall; the page has one `h1` then the welcome's `h2`; the first Tab stop is Start (the existing `tabTo` helper in `e2e/session-helpers.ts`, which handles WebKit's Tab setting); axe finds no WCAG 2.0 to 2.2 A or AA violation in light and dark mode; the welcome has no animation or transition, and with reduced motion switched on the page is unchanged; every button on the page has explicit token colours (job 5's lesson).
11. **Design rules.** New styles use tokens only, so `tests/design-tokens.test.ts`, `tests/design-css.test.ts` and `tests/design-rules.test.ts` pass unchanged. The block has no image file (job 8's `[smoke 1]`, which fails on any `img`, `picture`, `video` or `canvas`, stays green), no icon or emoji, no uppercase label, no carousel or dots, no accent border, no table style rows and no gradient. The design reviewer checks it against `design.md` and the banned list in `AGENTS.md`.

### Can they say it, and how fast

12. **The hallway test.** The builder writes `factory/jobs/15-onboarding/evidence/hallway-test.md`: the exact words the owner says to each person, the stopwatch rule, the two questions asked word for word, a marking guide with three example answers that pass and three that fail, and a table of 5 rows (person 1 to 5, age band, months in Finland, speaks Finnish yes or no, seconds to the first line, the two answers in their own words, pass or fail). The owner runs it and fills it in. The setup:
    - 5 adults, 18 or older, who have not seen PuhuScribe and do not speak Finnish well, ideally in Finland less than 18 months. Not you or the native reviewer, and not people who helped build it.
    - A fresh private browser window with no account, on a phone, on a link the owner picked (Risks). The person gets the phone with the front door open and the words "Use this app as you like." The stopwatch starts then and stops when the first dialogue line is on screen. The owner gives no help and does not read anything aloud.
    - Straight after, two questions, word for word: "In your own words, what does spoken Finnish mean in this app?" and "In your own words, what does written Finnish mean in this app?" Answers are written down as said. No audio or video is recorded and no name is taken.
    - A pass for a person means they reach the line within 60 seconds and both answers match the marking guide's two ideas (spoken is how people really talk in daily life; written is how Finnish appears in books, forms and signs), in any wording. Pass bar: at least 4 of 5 on the time and at least 4 of 5 on the answers (owner's call 4).
    - The evaluator checks that the sheet is complete and the counts add up. It cannot judge the people, and the job summary says so. The manager keeps the job at "waiting for the owner" until the sheet is in, as with job 14's live check.
    - If the bar is missed, it is a rework: first a wording change and a second round of 3 new people. If that also fails, the owner chooses between owner's call 1 option B and owner's call 5.

### Records

13. **Records and earlier tests.** `design.md` gains a short "Welcome block" entry, and `/design-reference` shows the block in light and dark. `docs/conventions.md` adds the `[onboarding N]` row. The README's running costs stay at €0. `build.md` lists every earlier test it changed, and the expected list is empty. All earlier tests stay green and unchanged, in particular job 8's `[session 1]`, `[session 3]`, `[session 22]` and `[smoke 1]`, job 11's front door and `/account` tests, and job 14's `tests/analytics-rules.test.ts` (the page route list does not change, so the visit counter sees the same pages).

Product rules from `AGENTS.md` that apply: P5, with P1 through the session sentence; one front door, one loop (the welcome is on the front door and the learner picks nothing); no placement test; nothing unapproved is served (no Finnish at all by default); no users under 18 (owner's call 3); GDPR minimum data (nothing new is collected); gentle and plain wording; no streaks, confetti, Day One, language toggle or other item of the "Not in v3.0" list; client facing text in English; no placeholders; never delete or weaken a test.

## Welcome wording (draft for the owner's approval)

Heading (`h2`): Welcome to PuhuScribe

- Paragraph 1: You tap any word to see what it is, and you say the lines back. The words you met come back for review on later days.
- Paragraph 2: Every line comes in two forms, and you can hear both.
- Band labelled "Spoken": How people in Finland talk day to day, in shops and at work.
- Band labelled "Written": How Finnish is written in books and on forms.
- Paragraph 3: Spoken comes first. The written form sits under it.

That is 73 words with the heading and labels. The session sentence under "Today's session" (job 8) already says the learner hears a dialogue line by line and checks they understand it, so the welcome does not repeat it. The text names no step beyond what a learner meets today. Job 16 (tutor) adds a step from unit 4; the welcome needs no change for it, because it never lists the steps.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | Where the welcome lives | A block in the front door, shown to new visitors (owner's call 1, A) | Its own page with two screens, Continue and Skip | More taps before the first line, a new page for the visit counter, and a change to up to 32 test openings of `/`. NN/g found that people who read an app tutorial rated tasks harder (4.92 against 5.49 on a 7 point scale, p = 0.047) with no gain in success, and advises against a multi screen manual for simple apps (see the research table). The test covered only 4 iPhone apps, so it is a hint and proves nothing about ours |
| 2 | How we know it is a first visit | From the account check the front door already makes. No account, no "ended" message, no notice means new. Nothing is stored | A "welcome seen" flag in the phone's local storage | The EU storage and access rule for devices (the EDPB's guidelines 2/2023, the same source job 14 used) covers writing to a device even when nothing is sent. Whether a "seen" flag counts as strictly necessary was not verified. Job 14, the privacy notice and job 8's tests all rely on the app writing nothing to the device except sign in cookies. A flag would also change the notice. A database flag is impossible, because a visitor has no account until Start |
| 3 | The cost of that pick | A person who signed out of an email account earlier, or cleared their browser, and opens the address fresh sees the welcome again. "I already have an account" sits right under Start. Someone who saw the welcome and left without pressing Start sees it again, which is correct because they never began | The flag, which hides the welcome from both of those people | The repeat costs a returning learner a few seconds. The flag costs a privacy question and a new item in the notice |
| 4 | How the two forms are explained | Plain English with two bands that look like the Hear it screen. No Finnish | A real Finnish pair, such as v2's "Minä olen kotona" and "Mä oon kotona" | The pair would be Finnish outside the content pipeline and unapproved, and the app cannot read an approved line for a visitor with no account. Giving signed out visitors read access changes the database rules job 3 set |
| 5 | Proof of "in their own words" | A hallway test with 5 real adults, run by the owner | A quiz inside the welcome that asks which description fits spoken Finnish | Your rule against quizzes and gamification. A quiz adds a tap, tests recognising an answer rather than saying it, and teaches the learner nothing new |
| 6 | Questions in the welcome | None. Everyone starts at A0 | A goal and level quiz, as Duolingo, Babbel and Speak run | The scope says no placement test. Each question adds time to the one minute budget and collects data the app does not need |
| 7 | Format | One block, no carousel, no dots, no step bar | v2's three step carousel with a step bar | v2's third step led into the Day One Sprint, which is banned. Taps before the first line rise with each step. The session screens already use a step bar with words for real steps |
| 8 | Length | At most 80 words (73 drafted) | A fuller explanation of the loop | Adult silent reading averages about 238 words per minute in English (Brysbaert 2019, 190 studies), so 73 words take about 18 seconds. People reading a second language read slower. At half speed it is about 37 seconds, still inside the minute with Start and loading. The hallway test is the real measure |
| 9 | Age statement | Open: owner's call 3. This spec changes nothing | An age tick box | The owner decides |

New npm packages: none. New database objects: none. New Worker code: none.

## What the best apps do right now (research, 30 October 2026)

I read each page marked "read". Everything is third party analysis, not the companies' own data.

| Reference | What it shows | Borrow | Leave out |
|---|---|---|---|
| Duolingo, Appcues teardown (read): https://goodux.appcues.com/blog/duolingo-user-onboarding and ScreensDesign (read): https://screensdesign.com/articles/duolingo-onboarding-design/ | First lesson before any sign up. A speech bubble says "Just 7 quick questions before we start your first lesson!". The article credits putting the first lesson early because practice is stronger proof than explanation. A company reported gain (about 20 percent more daily users) from delaying sign up reached me only through a secondary summary: https://taplytics.com/blog/duolingo-ab-test-onboarding | Value before account. PuhuScribe already starts as a guest | The questions, the mascot, the level quiz |
| Babbel, Appcues (read): https://goodux.appcues.com/blog/babbel-mobile-permission-priming and Lazyweb (read, 30 steps listed, five shown): https://lazyweb.com/flow/babbel/onboarding | Language, notification request, profile questions, a first lesson, then the account prompt | The account comes after the first lesson | The early notification request, the profile questions, the length |
| Speak, ScreensDesign (read): https://screensdesign.com/apps/speak-learn-spanish-french/ and Lazyweb: https://lazyweb.com/flow/speak/onboardings | 13 steps before the paywall by one count, 28 by Lazyweb's. Sign up at step 4. The first speaking lesson begins about 2 minutes 32 seconds into the video, after the paywall | Nothing. It is the counter example for the one minute goal | Everything in its first run |
| Pimsleur, ScreensDesign (read): https://screensdesign.com/showcase/pimsleur-language-learning | 14 onboarding steps with interactive method tutorials, then a paywall with a 7 day trial | A method led product does explain its method; we do it in one block | The 14 steps and the paywall |
| Busuu and others, ScreensDesign article (read): https://screensdesign.com/articles/language-learning-app-onboarding/ | Busuu offers a known level or a ten minute placement test and puts the next lesson at the top of the dashboard. The article advises teaching the lesson loop before the dashboard | The next lesson at the top is what the front door already does. The loop is taught by doing it | The placement test (the scope rules it out) |
| Memrise, Lazyweb (seen only through a search summary): https://app.lazyweb.com/flow/memrise/signup | 10 steps, a personalisation quiz, an interactive demo, account creation early | Nothing | Early account, quiz |
| Nielsen Norman Group, mobile tutorials (read): https://www.nngroup.com/articles/mobile-tutorials/ | 70 users, 4 iPhone apps. Tutorial readers: 91 percent task success against 94 percent for skippers (no significant gap) and lower ease ratings (4.92 against 5.49, significant). Advice: question whether you need onboarding, prefer contextual help | Keep it to one short block. The existing one time line in Hear it, "Blue words change between spoken and written Finnish.", is the contextual help | A multi screen manual |
| Reading speed, BPS summary of Brysbaert 2019 (read the summary): https://www.bps.org.uk/research-digest/most-comprehensive-review-date-finds-average-persons-reading-speed-slower | Average adult silent reading of English non fiction is 238 words per minute | The arithmetic in Decision 8 | Taking it as a promise for second language readers, who read slower |
| PuhuScribe v2, the owner's own handoff: `design/v2-handoff/README.md` section "01 · Onboarding", `design/v2-handoff/app-screens/screens-onboarding.jsx`, `design/v2-handoff/brand/ps-screens-flow.jsx`. The live app https://puhuscribe-v2.vercel.app returned only its title to my tool, so I could not read it | A 3 step welcome with Skip: welcome, "why two registers" with a register card, and the Day One intro | See the next list | See the next list |

**Reused from v2:** the idea that a welcome explains the two forms; the English message that books teach one Finnish and people speak another (offered as optional wording above); the pairing of a spoken band and a written line, which is already the design system's `FinnishLine`; the idea of a way out of the welcome (here, Start is the way out).

**Left out of v2:** the Finnish heading and "Tervetuloa" (new Finnish), the example pair (new Finnish), the glossy bubble cluster, the small uppercase label above the heading, the chips, the step bar, the third step and its "Aloita Day One" button (the Day One Sprint is on the "Not in v3.0" list), and the Skip button (Start does that).

**Could not reach:** Mobbin returned 403, so no Mobbin collection was read. Page Flows has no language learning onboarding collection that search could find. Apple's Human Interface Guidelines onboarding page returned only its title.

## Out of scope

- A placement test, a level, goal or motivation question, or any question at all.
- Day One Sprint, a vocabulary bank or word targets, a practice hub, a language toggle, mnemonics, rank titles, streaks, confetti, a journey map (all on the PRD's "Not in v3.0" list).
- Any Finnish text in the welcome, unless owner's call 5 changes it.
- A carousel, dots, a mascot or a new illustration (owner's call 2, B only).
- A "welcome seen" flag, cookie, local storage, or any new column, table, route or setting.
- An age tick box or age question (owner's call 3).
- The landing page, waitlist and public explanation of PuhuScribe (job 17). The PRD's QR flow for the fair stand.
- The tutor step (job 16). Changes to the Hear it screen, the sign in or the account pages.
- Analytics events about the welcome. Job 14 counts visits and nothing about screens.

## Build plan

1. **Overview page, only if the owner picks something other than reuse.** If owner's call 1 is B or C, or call 2 is B, the builder makes one plain overview page, `factory/jobs/15-onboarding/welcome-overview.html`, naming each picture, and waits for the owner's choice before building screens. With calls 1 A and 2 A this step is skipped.
2. **The block.** `src/screens/welcome-copy.ts`, a `Welcome` component with its CSS module from existing tokens, and the front door rule for when it shows. Vitest for the copy rules. Covers 1 to 6.
3. **Browser tests.** Visibility cases, requests and storage, one tap to the first line, fit at 375 x 812, accessibility in both browsers, light and dark. Covers 1 to 11.
4. **Records and design review.** `design.md` entry, `/design-reference`, conventions row, README, the empty changed tests list in `build.md`. Covers 13.
5. **The hallway test pack.** The sheet in `evidence/hallway-test.md`. Covers the build side of 12.
6. **Owner step, after the build.** The hallway test and the written approval of the wording. About 40 minutes. Covers 12.

**Dependencies.**

- Jobs 8, 11 and 14 merged (they are).
- Owner's calls 1 to 5 answered before the build starts. Call 4 can wait until step 6.
- A link that opens on a phone for step 6: a preview link (waits for the Cloudflare preview keys) or the live app (waits for job 14's go live job).
- Until a preview exists, the evaluator runs the app locally with the throwaway database, as in earlier jobs.

## Risks and flags

- **Look closely: the age statement.** The PRD wants it "stated in terms" and no terms exist. The wording and whether to ask for a tick is your call (owner's call 3). This spec adds no age data.
- **No learner data, no recordings, no consent change.** Nothing new is stored, collected or sent, and statement 7 checks it. No database change, so no new access rule to review. That is why the job is not GA and needs no threat model.
- **No Finnish content by default.** The welcome has no Finnish. If you pick owner's call 5 B or C, the job is flagged and goes to the native reviewer.
- **No paid service, no running cost.** €0.
- **The hallway test creates guest accounts.** Pressing Start makes a real guest account (a random id, no name) in whichever database the link points to. Use a preview link (test database) or the live app once it exists. Tell each person it happens and that the account is deleted after 90 days without use (job 11).
- **A small sample.** 5 people is a sanity check. A pass is not proof that learners in general understand; a fail is a strong signal.
- **Crowding on small phones.** Statement 9 may force trimming. The estimate is tight: the page is about 790 px high to the bottom of Start at 375 px wide, before the guest line. I did not build it to check.
- **Heading for new visitors.** The front door keeps the heading "Today's session" and job 8's lead sentence, because job 8's tests require them. The design review of job 8 noted that a new visitor might expect a different heading. Changing it is a later decision and changes `[session 1]`.
- **Coordination with job 16 (tutor, Otso).** The welcome never lists the loop's steps, so a new "Use it" step needs no change here. Job 16 must keep Start on the front door and must not add a step before the first Hear it line, or the one tap and one minute claims move.
- **Coordination with job 17 (landing page).** The welcome is part of the front door screen, not of an address. If job 17 puts the landing page at `/` and moves the app's front door to another address, the welcome moves with the front door. Job 17 must then list that address in `worker/page-routes.ts` (job 14's repository test fails otherwise), and its "Try it" link must open the front door, not `/session`, or the welcome is skipped. A same site move is not counted as a second visit (job 14, statement 1). If the landing page lives on another host, nothing changes here. The owner decides the landing address in job 17.
- **Visit counting.** No new page route, so job 14's counter and test are unaffected. Option B of call 1 would add `/welcome`, and a script driven move from `/` to it would be a same site move, so not counted twice.

## Could not verify

- Whether Start and the guest line fit above the fold at 375 x 812 with the welcome in place. The estimate is tight and statement 9 settles it.
- Whether a "welcome seen" flag in local storage would need consent under the EU device rule. I did not read the guidelines' text on the strictly necessary exception. The pick avoids the question.
- Reading speed for second language readers. I found only the English average (238 words per minute) in a summary, not the full paper.
- Duolingo's reported 20 percent gain: a secondary summary of a company interview, not an independent measure.
- Speak's step count: ScreensDesign lists 13 steps and Lazyweb 28. I did not see the flow itself.
- Memrise's flow: only through a search summary.
- The live v2 app, Mobbin collections, a Page Flows language collection and Apple's onboarding guidance (see "Could not reach").
- That the hallway test's pass bar (4 of 5) is the right one. It is a proposal, not a finding.

## Sources

- PRD sections 3, 4.1, 5, 10 and 13: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- Project: `docs/scope/scope.md` item 13, `AGENTS.md`, `docs/factory-and-risk-tests-plan.md` (decisions 8 and 9), `design.md`, `design/brief.md`, `src/App.tsx`, `src/screens/FrontDoor.tsx`, `src/screens/FrontDoor.module.css`, `src/lib/account-notice.ts`, `worker/page-routes.ts`, `e2e/front-door.spec.ts`, `e2e/session-helpers.ts`, `supabase/migrations/20261020090000_content_model.sql`, `factory/jobs/8-first-session/spec.md` and `review-design.md`, `factory/jobs/11-accounts/spec.md`, `factory/jobs/14-analytics/spec.md`
- v2 onboarding: `design/v2-handoff/README.md`, `design/v2-handoff/app-screens/screens-onboarding.jsx`, `design/v2-handoff/brand/ps-screens-flow.jsx`
- Duolingo: https://goodux.appcues.com/blog/duolingo-user-onboarding, https://screensdesign.com/articles/duolingo-onboarding-design/, https://taplytics.com/blog/duolingo-ab-test-onboarding
- Babbel: https://goodux.appcues.com/blog/babbel-mobile-permission-priming, https://lazyweb.com/flow/babbel/onboarding
- Speak: https://screensdesign.com/apps/speak-learn-spanish-french/, https://lazyweb.com/flow/speak/onboardings
- Pimsleur: https://screensdesign.com/showcase/pimsleur-language-learning
- Language app onboarding (Busuu and others): https://screensdesign.com/articles/language-learning-app-onboarding/
- Memrise: https://app.lazyweb.com/flow/memrise/signup
- NN/g mobile tutorials: https://www.nngroup.com/articles/mobile-tutorials/
- Reading speed: https://www.bps.org.uk/research-digest/most-comprehensive-review-date-finds-average-persons-reading-speed-slower
- EDPB Guidelines 2/2023 on the technical scope of Art. 5(3) ePrivacy Directive, version 2.0: https://edpb.europa.eu/system/files/2024-10/edpb_guidelines_202302_technical_scope_art_53_eprivacydirective_v2_en_0.pdf

Result: ready for owner approval
