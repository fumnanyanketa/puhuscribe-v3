# Job 17-landing-page: Landing page and the move of the app to /learn

Scope item 15. Treated as GA (public page, and a change to every address of the app). Needs a decision. Round 2, 31 October 2026, written on the owner's answers of that day (the end of `factory/specs-waiting.md`) and on the owner's hero design (the v2 landing page). Builds on main as merged, including 14-analytics and 11-accounts, and after 15-onboarding is merged. Test label: `[landing N]`.

## Summary for the owner

1. The public page lives at the main address, `puhuscribe.exentrik.co/`. The whole learner app moves under `/learn`. Today's front door becomes `/learn`, `/account` becomes `/learn/account`, and so on. `/api/*` stays where it is. Old addresses forward to the new ones, so no bookmark breaks.
2. The page starts from your v2 hero. Its main button, "Start your first session", opens `/learn` with no sign up. The page has no form, no waitlist, no email, no price and no script. It sets no cookie and asks no outside address for anything.
3. Real screens carry the look. A script makes every picture from the running app at phone size, so they can be remade. A picture may show only Finnish the native reviewer approved. Until units 1 to 3 are approved, the pictures show screens with no Finnish lines.
4. Exentrik appears once, in the small "who is responsible" line. The line needs its legal name and business ID (Y-tunnus) from you. Nothing is built that costs money. No database change, no new service.
5. Four calls stay with you, and the spec carries a recommendation for each: which parts of the v2 hero stay (fake numbers, button wording, the beta tag, "Research"), what the pictures show before approval, the colour of the button and of "street", and the address of the privacy page. Section 2 of the calls points out where the v2 hero meets your banned list, with no recommendation. I also need the hero picture as a file.

## Owner's calls

The spec's "Done when" statements are written for the recommended option of each call. If you pick differently, the statements named under that call change, and the manager sends them back to me.

### 1. What stays of the v2 hero, and what changes

Your hero is the starting point and some parts will go. Everything the page says must be true of the running v3 app (statement 5), and the v3 app has none of the items below.

**What is in the v2 hero and what v3 has** (read from `_v2-readonly/public/landing/phone.js` and `landing-app.js`).

| In the hero | In the v3 app today |
|---|---|
| "Mastered 847 of 1200, Conversational foundations", the ring and "+34 this week" | Nothing like it. A 1,200 phrase target is close to the vocabulary bank with a word target, which is on the PRD's "Not in v3.0" list |
| "Register balance", Kirjakieli understood 78 percent, Puhekieli spoken 52 percent | No such measure |
| The month calendar strip and "Kesäkuu 2026" | No calendar, and no daily streak (the scope bans streaks) |
| The "This month +21%" bar chart and "Total growth on spoken Finnish" | No progress chart. Job 14's numbers are the owner's, not the learner's |
| The "Kuuntele · Listen" card, "Tap what you hear, then build the phrase" and the chips "Mä oon nyt" | The listening step is play and read, not build a phrase. The Finnish is not approved |
| The phone's first screen (v2 "Päivän sessio") with a flame counter and the buttons "Vielä" and "Osaan" | Review has no self rating (principle P2), and there is no flame |
| "Now in beta" and "No app store needed, add it to your home screen" | Depends on what you decide in 1c |
| Nav "Research" and "Features" | There is no research section to back the first, and the second is the progress panels |
| Button "Become a tester" | The app has no tester sign up. The page's button is "Start your first session" |

**1a. The fake numbers and progress panels (847 of 1200, +21%, calendar, register balance, the month chart).**
- **A. Remove all of them and show real screens in their place (recommended).** The page says only what the app does. Nothing in the first picture can be caught out by a visitor who opens the app.
- **B. Keep them as a picture of what is planned, with a label "Planned".** Still shows features the app lacks. Consumer law bans misleading a person about what a product contains (the EU's Unfair Commercial Practices Directive, which I read only at Annex I in round 1), and a number such as 847 reads as a real learner's result. It would also put a progress dashboard on show that the PRD defers.
- **C. Build a progress screen first.** Moves the page weeks later and is outside this job and outside the v3.0 scope.

**1b. "Become a tester" against "Start your first session, no sign up".**
- **A. "Start your first session" on the nav button, the hero and the closing band, all opening `/learn` (recommended).** Matches your answer. "Tester" suggests a sign up that no longer exists.
- **B. Keep "Become a tester" as the words and open `/learn`.** A visitor expects a form and gets the app. Fewer people press it.
- **C. "Try it now" in the nav and "Start your first session" in the hero.** Two names for one action. Harmless, slightly less clear.

**1c. The "Now in beta" tag and the home screen note.**
- **A. Remove both (recommended until the installable app job is merged).** The home screen note is true only once scope item 16 (installable app) ships, and I could not check that it will. A beta tag is a status you may or may not want to promise.
- **B. Keep one plain sentence, "PuhuScribe is in beta. Tell us what to fix on the feedback page.", and the home screen note only after item 16 is merged.** True today: the app has a feedback page (job 14). Sets honest expectations, since only the first units exist. Both go in the claims table (statement 5).
- **C. Keep the tag and note as drawn.** The tag is a pill label (call 2) and the note is false until item 16 is done.
- If you pick B, the sentence is plain text, not a pill.

**1d. "Research" in the nav, and the section behind it.** v2's Research section names three principles but cites no source, and its text points at the Day One Sprint and Language Island, both on the "Not in v3.0" list.
- **A. Remove the nav item and the section (recommended).** The nav becomes "How it works", "Two Finnishes", "Questions" and the main button. "Features" goes too, because v2's Features section is the progress panels.
- **B. Replace it with a short plain part, "Why this works", that names the five principles in your own words and cites nothing it cannot back.** One more section to keep true.
- **C. Write a real research section with named studies.** The strongest page, but it is new content with sources I would have to check, and you approve each claim. A later job.

**1e. What the phone and the two floating cards show before the reviewer approves any Finnish.** Units 1 to 3 are drafted and wait for the native reviewer.
- **A. The phone shows the new visitor's front door with the welcome of job 15 (the Spoken and Written bands, no Finnish). One card is a crop of the same bands, the other a crop of the voice settings choice (recommended).** Real screens, no Finnish, nothing to retake later except two pictures when the first dialogue is approved.
- **B. Hold the hero until the first dialogue is approved.** The page cannot go public before then anyway (the reviewer must approve before go live), so this costs nothing if approval comes first. If approval is late, the page is late.
- **C. Show the v2 Finnish (such as "Mä oon nyt") from the start.** Refused by the rule "nothing unapproved is served" and by statement 7. Possible only after the reviewer approves that exact line.
- Recommendation: **A**, and swap to an approved dialogue as soon as one exists (statement 9 says how).

### 2. Where the v2 hero meets your banned list (pointed out only)

You asked me to point these out and not decide. The spec's baseline follows your list and the locked design system until you say otherwise. If you choose to keep any item below, `design.md` and the design tests (`tests/design-css.test.ts`, `tests/design-rules.test.ts`) must record it as your exception, because they refuse these today. I will not weaken a test without your written choice.

| Element in the hero or in v2's page | Your banned list or `design.md` | What the baseline does |
|---|---|---|
| Small uppercase labels "KUUNTELE · LISTEN", "MASTERED", "REGISTER BALANCE", the day names "MON TUE", and v2's section labels ("The core idea", "Why it works", "How it works", "In the app", "For new arrivals in Finland") | Eyebrows. `design.md` refuses `text-transform: uppercase` by test | No small labels above headings. A card names itself in normal sentence case |
| Pill tags: "Now in beta", the "No app store needed" pill, the word chips "Mä oon nyt", "Last month", the badges "Arki · daily" | Pills and badges | Plain text. Chips only if they are the app's own word chips in a real screen |
| Big numbers: 847, "of 1200", "+21%" at 40 px, 78%, 52% | Big number tiles | None. The page holds no statistics |
| Also in v2's page, not in the hero picture. Frosted glass nav (`backdrop-filter`), glowing button shadows, the aurora gradient and grid behind the hero, blurred colour orbs, gradient progress bars | Glow and gloss. `design.md` allows one gradient, the page fade | Solid nav, flat buttons, the page fade only |
| Also in v2's page. The cards "01 Day One Sprint, 02 Daily Sessions, 03 Language Island" with icon squares, and the three identical research cards | Fake numbering, identical card grids, icon sprinkles. Day One Sprint and Language Island are on "Not in v3.0" | The loop is told in plain sentences |
| Also in v2's page. Google Fonts and Fontshare preconnects, React loaded from files and the page drawn in the browser | `design.md`: fonts from our own address. Scope: no outside requests | Own fonts, plain HTML, no script |

Whether an element inside a picture counts is yours to say. A real app screen shows only what the app draws, so it has none of the items above.

### 3. The colour of the main button and of "street"

Your hero draws the main button purple and "street" in purple. In the locked design system the primary button is the black pill, and violet (`--color-written`) means written Finnish. "Street" means spoken Finnish, whose colour is teal (`--color-spoken`).
- **A. Follow the picture, purple button and purple "street".** Closest to what you showed. The page then has a purple primary that the app does not have, and violet appears on the word that stands for spoken Finnish, which teaches the opposite colour code.
- **B. Black pill button and "street" in the spoken teal, "kirjakieli" in violet and "puhekieli" in teal as v2 already does in the lead (recommended).** The page and the app agree, so the first screen a visitor meets after pressing the button looks like the page they left. The page loses the one strong purple accent.
- **C. Black pill button and "street" in purple.** Keeps your purple accent and the app's button. The colour clash on "street" stays.
- If A, `design.md` gains a landing page button entry and a test exception. Under B and C no design test changes.

### 4. The address of the privacy page

You said the whole app moves and listed the privacy page link.
- **A. `/learn/privacy` (recommended).** Follows your rule. The landing footer links to it. One page, one rule.
- **B. Keep `/privacy` at the top level.** Reads like a public legal page, as on most sites. It becomes a second exception to "everything under /learn", with its own rule for counting and for the owner host.

### Owner inputs (not choices)

The manager asks for each. I pick none, and the builder invents none.
- **The hero picture as a file.** The manager places it in `factory/jobs/17-landing-page/hero-picture.*` and gives the builder the path. It is the layout target of the overview page. Its content is not copied (statement 7 and call 1).
- **Exentrik's legal name and business ID (Y-tunnus).** In the spec they are `<Exentrik legal name>` and `<Exentrik business ID, Y-tunnus>`. I could not check whether Exentrik is a registered company or a trading name. Asked at spec approval, as the lesson from 11-accounts says.
- **The contact printed in the responsible line.** The one in the privacy notice setting today. The manager asks whether it is still right (an address of yours, never chosen by me).
- Whether you want the title and description lines changed (my proposal is under "The page text").
- Time at go live: attach the main address and check statement 28. No keys or DNS are new in this job.

## What it is

A public page that explains in plain English what PuhuScribe is and sends people into the app with one button, "Start your first session". It takes nothing from the visitor. Its pictures are real screens of the running app, remade by a script. The learner app moves to `/learn` so the page can have the main address.

It serves P5 (the page explains both forms and shows them), P4 (it says the learner says it back) and P2 (it says review needs no rating) as claims the app already keeps (claims table). It adds nothing from the PRD's "Not in v3.0" list.

## Done when

Terms.
- **The page**: `/`. **The app**: `/learn` and everything under it. **The shell**: the built `index.html`, which draws every app page.
- **The landing file**: the built HTML file of the page (`landing.html`, see Decision 2).
- **Phone size**, **browser test** and **the fixture**: as in jobs 8, 11, 14 and 15 (Playwright at 375 x 812 in Chromium and WebKit, against the built app and a throwaway local Supabase). **Owner host** and **app host**: as in job 14.
- **Approved Finnish**: a line in a dialogue that went through the automatic checks and the native reviewer and was published (the published content committed by the content jobs 12 and 13). Until one exists the approved set is empty. The builder confirms where the published lines are read from.
- Tags: **[security]**, **[personal data]** and **[Finnish content]** mark statements the reviewers and the evaluator check closely.

### The page

1. **The page is real HTML at `/`.** `GET /` answers 200 with the finished page in the HTML itself. With scripts switched off, every heading, paragraph, link and picture description is present (browser test). `/` is in `PAGE_ROUTES` and `run_worker_first`. The Worker answers it with the landing file's bytes unchanged and counts the arrival (statement 16). The landing file has no second address: `/landing`, `/landing.html` and `/index.html` redirect to `/` or answer 404, and a test pins which. No built file is served at `/` itself (`tests/analytics-rules.test.ts` keeps its built files check green).
2. **The page takes and keeps nothing, and runs no code.** The built landing file has no `script` element, no `form`, no `input`, no `textarea`, no `button` that submits, and no `iframe`. A browser test follows a visitor from the page to `/learn` and fails if the page sets a cookie, writes local or session storage, or requests any other origin, or any `/api/` address. A `Content-Security-Policy` meta tag allows only its own origin: `default-src 'none'`, `style-src`, `font-src` and `img-src` set to `'self'`, `script-src 'none'`, `connect-src 'none'`, `form-action 'none'`, `base-uri 'none'`. The browser test fails on any violation. If Vite's output cannot meet it without `'unsafe-inline'`, the builder stops and says so. The policy is not loosened. **[personal data] [security]**
3. **The words follow the writing rules and say nothing about money.** A repository test reads the built HTML and fails on: more or fewer than one `h1`; a skipped heading level; a missing `lang="en"`; a hype word from `AGENTS.md`; an em dash or a hyphen used as punctuation; any of the words price, pricing, paid, free, plan, plans, subscription, founding, waitlist, discount, premium, the signs € and $, a number with a currency, a countdown, a date, a count of learners; and a `text-transform: uppercase` rule in its CSS. It also fails if "Exentrik" appears anywhere except the responsible line (statement 23) and fails on "tester" and "beta" unless the owner's call 1 allows them.
4. **The main button.** The link "Start your first session" has `href="/learn"`, and sits in the nav, in the hero and in the closing part. A browser test presses each and lands on the front door (the welcome shows for a new visitor, job 15). No sign up screen sits between. Pressing it creates no account: the landing page makes no request at all, and the front door creates an account only when Start is pressed (job 8's `[session 1]`).
5. **Every claim is true.** The evaluator walks the claims table below against the running app and records each row's proof in `build.md`. A row that fails changes the page text, not the table. Nothing is claimed that is not in the table. The rows marked "at go live" are checked again then.
6. **Finnish in the text is limited and traceable.** Every string inside a `lang="fi"` element in the landing file is `puhekieli` or `kirjakieli`, or a line found word for word in the approved set. A repository test fails on the letters ä, ö or å in the page text outside `lang="fi"` elements. The two glossary words go to the native reviewer with the page text, and the page does not go public before the reviewer answers (go live dependency). **[Finnish content]**

### The pictures

7. **The pictures show approved Finnish only.** No picture on the page, and not the social card, shows a Finnish line that is not in the approved set. Until units 1 to 3 are approved, the pictures show screens with no Finnish line, or none at all. Once an approved dialogue exists, the page may use its first dialogue. Two tests protect this. First, the script that makes the pictures reads every element with `lang="fi"` on the screen it captures and refuses to write the picture if any text in it is outside the approved set. Second, a repository test reads `src/landing/shots.json` (statement 8), which lists the Finnish text visible in each picture, and fails on any entry not in the approved set. With an empty approved set it fails on any entry at all. The owner's hero picture is a layout target only, and its Finnish and numbers are not copied. **[Finnish content]**
8. **The script makes the pictures from the running app, and a person cannot hand edit one.** `npm run landing:shots` starts the built app with the throwaway local database and the fixture, opens it at 375 x 812 (device scale 2, light mode, English), drives it like a learner (Start, then the screens named in the manifest), captures each screen or part of a screen, composes the hero and writes the files under `public/shots/` with a WebP file and a PNG fallback for each, plus `src/landing/shots.json`. The manifest lists for each picture: the file, the app address it was taken from, the size, the visible text lines, the Finnish text (empty until approval), the SHA-256 of the files and the alt text. A repository test recomputes every hash and fails if a file was edited or is missing from the manifest. The script refuses to run without the real fonts (`docs/fonts.md`), so no picture shows fallback type. A second test runs the script twice into temporary folders and fails if any picture differs by more than 0.1 percent of its pixels. It skips with a reason when the fonts or the local stack are absent, as the tests that need Switzer already do. The README says how to remake the pictures.
9. **The hero is real screens.** Beside the headline sits one composed picture, made by the script. It holds a phone showing one real screen and two tilted cards, which are crops of real elements from other screens. The tilt is in the picture, so the page needs no script or JavaScript scaling. Until an approved dialogue exists, the phone shows the new visitor's front door with job 15's welcome and the cards show the Spoken and Written bands and the speaking feedback choice, if owner's call 1e is A. The script takes its screen list from `shots.json`'s source, one file of settings in `scripts/landing/`, so swapping to the approved first dialogue changes that file and nothing else. The picture holds no number, calendar, chart, progress ring, streak or self rating (a test reads the manifest's visible text, and the evaluator looks at each picture).
10. **The pictures are safe and light.** The manifest's visible text holds no email address, no identifier shaped like a UUID or a long number, no `localhost`, no `supabase` and no key shape (repository test). Each picture has `width` and `height` in the HTML, and a description (alt text) of 20 to 150 characters that says what the screen shows. The hero's WebP is at most 150 KB, each other WebP at most 80 KB, and each PNG fallback at most 300 KB. Pictures below the first screen are `loading="lazy"`. These limits are my proposal, and the builder records the real sizes. A picture's text is not the only copy of anything the page claims: every claim is also in the page's own text.

### The move to /learn

11. **The new addresses.** Every page of the app answers 200 with the shell at its new address, and the page it draws is the page it drew before. The map:

| Before | After |
|---|---|
| `/` front door | `/learn` |
| `/session` | `/learn/session` |
| `/voice` | `/learn/voice` |
| `/account` | `/learn/account` |
| `/account/email` | `/learn/account/email` |
| `/account/delete` | `/learn/account/delete` |
| `/sign-in` | `/learn/sign-in` |
| `/privacy` | `/learn/privacy` (call 4 A) |
| `/feedback` | `/learn/feedback` |
| `/owner` | `/learn/owner` |

    `/api/*` is unchanged, and the cookies of job 8 and job 11 keep their names and scope (they cover the whole host, so a learner stays signed in across the move). A browser test visits each new address in both browsers and checks the page's own heading.
12. **Old addresses forward.** The shell, loaded at any of the ten old addresses (with or without a trailing slash, with its query kept, such as `?notice=signed-out` and `?from=account`), replaces the address with the new one and shows that page. A table test lists all ten, plus `/account/anything` as a deep link. The forwarding map is fixed in code. No part of the target comes from the visitor, so `//evil.example`, `/\evil.example`, `/learn/../x` and a full web address in the path never forward anywhere outside this site: they go to `/`. The two design pages that exist only in development and in design builds (`/sample/hear-it`, `/design-reference`) are left alone. **[security]**
13. **One file holds the addresses, and no link is missed.** `src/lib/app-paths.ts` names every app address once. Every link, redirect and `window.location` call in `src` and `worker`, and every address in the browser tests, takes its address from it. A repository test fails on a quoted old address (`'/session'`, `'/account'`, `href="/privacy"`, `assign('/')` and the like) in any file except that one and the forwarding table, and on any link or redirect to `/` in the app that is not `paths.landing`. The places I found today are `FrontDoor`, `AccountPage`, `EmailFlow`, `DeletePage`, `FeedbackPage`, `FinishScreen`, `KeepIt`, `ReviewFinish`, `SessionPage`, `SayIt`, `VoiceSettings`, `PrivacyPage`, `OwnerPage`, `SessionFrame`'s leave link and `src/lib/account-notice.ts`'s `/?notice=` redirect. The builder searches for more. The sign out, account delete and notice redirects end at `/learn` and `/learn?notice=...`. A browser test for each (sign out, delete, a guest whose account ended) fails if it ends on `/`.
14. **The Worker's page list follows.** `worker/page-routes.ts` lists `/`, `/learn`, and the nine addresses under `/learn` (the account pages as `/learn/account` and `/learn/account/*`). `wrangler.jsonc`'s `run_worker_first` lists exactly `/api/*` and those. `tests/analytics-rules.test.ts` keeps all its checks, with these edits only: the front door is now `/learn` and `/` is the landing page (so the check "every page of `src/App.tsx`, and the front door, is a route" reads `/learn`, and the check "every listed route is a page of the app" skips `/` as the landing page), and the sample paths in the built files check use the new addresses. After the edit it still fails when a route is missing from either list, and a repository test proves that by removing one on purpose. `build.md` lists each edited line and why. Nothing is deleted or weakened. The built files check also fails if a built file sits at `/learn` or under it.
15. **Unknown addresses.** Under `/learn`, an address the app does not know shows the front door, as today (job 8). Outside `/learn`, an address that is not a page of the site, a file or `/api` and reaches the shell is sent to `/` by the shell, so no learner screen ever shows at a stray address. A browser test covers `/nonsense`, `/learn/nonsense` and a path with a long Finnish compound word.
16. **One arrival is still one visit, and the page counts too.** Job 14's counting stays as it is, with the page route list changed. A Vitest table test, with browser headers: `GET /` typed or from another site calls `count_visit` once, with the country alone. `GET /learn` sent by a click on the page's button (`Sec-Fetch-Site: same-origin`) calls it never, so a visitor who reads the page and starts the app counts once. `GET /learn` typed, or from the home screen or a bookmark (`Sec-Fetch-Site: none`), counts once. Robot agents, prefetches, files, `/robots.txt` and `/sitemap.xml` never count. Nothing else about the visitor is read, and no new field is stored. The owner page's sentence under "Visits" (job 14, statement 17) changes from "arrival at the app" to "arrival at the page or the app", with its test updated and not weakened. **[personal data]**
17. **The owner host.** On the owner host (job 14), `/learn/owner` and `/learn/sign-in` are answered as `/owner` and `/sign-in` are now, with the same Access check, the same private headers and the same marked page. Every other page address, `/` included, answers 302 to `/learn/owner`. The old `/owner` and `/sign-in` also answer 302 to the new ones, so the owner's own bookmark works. The landing page is never served on the owner host. `/api/owner/dashboard` and the other owner host API routes are unchanged. `worker/owner.test.ts` follows the new addresses with the same assertions. Job 14's route list test is not weakened. **[security]**
18. **Only GET and HEAD reach the page.** Job 8's protections apply to the one route this job adds. `POST`, `PUT`, `PATCH` and `DELETE` to `/` answer 405 with `Allow: GET, HEAD`, the body is read and capped at 2 KB before answering, and no answer sends `Access-Control-Allow-Origin`. This job adds no `/api` route and no database function (Vitest). **[security]**
19. **The earlier tests follow, and job 15 lands on `/learn`.** Every browser test and unit test that opens the front door takes its address from `paths.frontDoor` (`/learn`), through one helper in `e2e/`. The expected count is about 32 `goto('/')` in 11 files today, and `build.md` lists every test changed and the reason. No test is deleted or weakened, and the number of assertions never goes down. Job 15's welcome code does not move: it lives in the front door screen and is drawn at `/learn`. Job 15's tests are changed by the address only: statement 1 ("`/` shows ...") is read as `/learn`, and its hallway test sheet opens `/learn`. Job 15 must be merged before this job's build starts (Dependencies).

### Search and sharing

20. **The head of the page.** The landing file has: `<title>` of at most 60 characters; one meta description of 70 to 160 characters; `<link rel="canonical">` with the absolute live address `SITE_ORIGIN/`, from the one constant `SITE_ORIGIN` in `src/landing/site.ts`; `<meta name="robots" content="index, follow">`; `lang="en"`; the viewport and `color-scheme` tags; an SVG favicon made from `design/assets/app-icon.svg`; Open Graph tags `og:title`, `og:description`, `og:type` (`website`), `og:url`, `og:image` (absolute), `og:image:width` 1200, `og:image:height` 630, `og:image:alt` and `og:site_name`; and Twitter tags `twitter:card` (`summary_large_image`), `twitter:title`, `twitter:description`, `twitter:image` and `twitter:image:alt`. No `twitter:site`. A repository test parses the built HTML and checks each tag, each length and that every URL is absolute and starts with `SITE_ORIGIN`. Proposed text is under "The page text".
21. **Search engines see the page and not the app.** The shell (`index.html`) gains `<meta name="robots" content="noindex, follow">`, so every app address stays out of search results, the front door included. `/robots.txt` allows everything except `/api/` and names the sitemap. It does not block app pages, because a blocked page cannot show its `noindex`. `/sitemap.xml` lists the one address `SITE_ORIGIN/`. Tests read the three built files and fetch them from the local server.
22. **The social card.** `/social-card.png` is a 1200 x 630 PNG of at most 300 KB, made by `scripts/landing/build-social-card.ts` from an HTML template that uses only token colours and Poppins. It follows statement 7: no Finnish line outside the approved set, and with an empty set no Finnish at all. It may hold the wordmark, the page's one line at 64 px or more with 7:1 contrast computed from the tokens, and the hero's phone (a crop of the same real capture). It is listed in the manifest like the other pictures. A test reads the PNG header for the size and the file size, fetches it from the local server (200, `image/png`) and checks `og:image` points at it. Real chat previews cannot be checked before the live address exists (statement 28).

### Responsible line and privacy

23. **Exentrik appears only in the responsible line.** The footer has the line "PuhuScribe is a product of `<Exentrik legal name>`, business ID `<Exentrik business ID, Y-tunnus>`. Responsible for your data: `<name from the privacy notice setting>`. Contact: `<contact from the privacy notice setting>`." The name and business ID are two new fields in `src/privacy/notice-settings.ts`, the one file the privacy notice already reads, so the page and `/learn/privacy` can never disagree. Nothing is typed into the page. The word "Exentrik" is absent from the title, head, headings, nav, pictures and social card (statement 3). A format test checks the business ID is seven digits, a hyphen and one digit. While either field is empty, a build for the live address (`VITE_PUBLIC_RELEASE=1`, which the go live job sets) fails with a plain message, and every other build leaves the company part out of the line. The values are the owner's. A builder never invents them. **[personal data]**
24. **The privacy notice stays true.** The page collects nothing new, so the notice gains no new part. Its existing visit count line (job 14's `NOT_LINKED_ITEMS` entry in `src/privacy/data-inventory.ts`) says "page or app" instead of "app", and its keeping time is unchanged. `/learn/privacy` shows the company line from statement 23. The page's footer links to it with the address from `app-paths.ts`. `PrivacyPage` and data inventory tests are updated and not weakened. Job 11's tests for processors and export stay green because no provider, table or data is added. **[personal data]**

### Phone, keyboard, accessibility and weight

25. **Phone, keyboard and accessibility.** For `/` at phone size in both browsers: nothing scrolls sideways at 320 px or with text at 200 percent; every link and summary is at least 44 x 44; everything works by keyboard alone in reading order with the focus outline of `design.md`; the nav links are hidden below 760 px and the main button stays; `@axe-core/playwright` finds no WCAG 2.0 to 2.2 A or AA violation in light or dark mode; every button and link styled as a button has explicit token colours (job 5's lesson); a 40 letter word in the responsible line wraps (`overflow-wrap: anywhere`); smooth scroll to "See how it works" applies only when the phone does not ask for reduced motion; every picture has its description. The page follows the phone's light and dark setting like the app, and its pictures are the light mode captures in both (the builder records how the dark mode page frames them, and the design review checks it).
26. **Light on an older phone.** The page uses no framework and no script: the HTML, one CSS file built from the tokens, the fonts and the pictures. With an empty cache, the HTML, CSS, fonts and favicon are at most 100 KB compressed, and with the hero picture the first screen is at most 300 KB compressed (my proposal; the builder records the real numbers). The pictures carry `width` and `height`, so the layout does not jump (cumulative layout shift of at most 0.1, which web.dev calls good, as I recall). In Chromium with a 4 times CPU slowdown and Lighthouse's mobile network settings (as I remember them 1.6 Mbps down and 150 ms round trip; the builder records the exact numbers), the largest paint comes within 2.5 seconds, the median of 5 runs. Fonts are served from the app's own address. Without the private Switzer files the page falls back to Poppins and the system font, and the tests that need Switzer skip with a reason (`docs/fonts.md`).
27. **Records and what stays green.** `docs/conventions.md` adds the `[landing N]` row. `design.md` gains a short "Landing page" entry and the shot rule. The README lists how to remake the pictures, the address map, the Exentrik fields and states running costs (€0). `docs/data-model.md` does not change (no database change in this job, and a repository test shows `git diff --stat main...HEAD -- supabase` prints nothing). The existing banned look tests cover the page CSS (the builder extends the glob if it misses it and says so). Every earlier test stays green, and `build.md` lists every test changed and why.

### Proven after go live

28. **Live check.** Once the live app exists, the owner opens `https://puhuscribe.exentrik.co/` on a phone, reads the page, presses "Start your first session", reaches the front door and starts a session. They open an old address such as `/account` and see it forward to `/learn/account`. They share the page link in a chat app and in a social post draft and see the card. They open the owner host and see `/learn/owner` after Access. Evidence screenshots hide every address. The manager keeps the feature `failing` until this passes, as with jobs 13 and 14.

## The page text (proposal)

English only. The owner changes any of it at the overview. Every sentence follows the writing rules. The words in angle brackets are settings, not text. This is the baseline for the recommended answers of call 1.

**Nav.** The wordmark. Links "How it works", "Two Finnishes", "Questions". Button "Start your first session". Under 760 px only the wordmark and the button show.

**Hero, left.**
- Headline (the owner's own): "Understand the books. Speak the street." Colour of "street" under call 3.
- Lead (the owner's own): "Every phrase comes taught twice, in the textbook <span lang="fi">kirjakieli</span> and the spoken <span lang="fi">puhekieli</span>. So you are never lost between what you studied and what you actually hear."
- Buttons: "Start your first session" (to `/learn`) and "See how it works" (to `#two-finnishes`).
- One line under the buttons: "No sign up needed. PuhuScribe is for adults, 18 and over." (The age line also keeps job 15's call 3 in view.)
- With call 1c B: the sentence "PuhuScribe is in beta. Tell us what to fix on the feedback page." as plain text, and the home screen sentence only after scope item 16 is merged.

**Hero, right.** The composed picture of statement 9.

**Two Finnishes** (`id="two-finnishes"`). "Books teach one Finnish. The street speaks another." (v2's own heading.) "Most Finnish courses teach the language of books. Adults in Helsinki talk differently. Every line in PuhuScribe comes in both forms, written Finnish (<span lang="fi">kirjakieli</span>) and spoken Finnish (<span lang="fi">puhekieli</span>), and both have audio. We start with how people talk." Beside it, one picture: the Spoken and Written bands (no Finnish) until an approved line exists. Then the approved pair, in a crop of the real Hear it screen, with the words that change marked as the app marks them.

**How a session works** (`id="how-it-works"`). Four short paragraphs with plain headings, in the order the app runs them, no numbers and no icons. "Hear it. You listen to a short dialogue from a real situation, such as meeting someone new or ordering a coffee, line by line. Understand it. Tap any word to see its basic form and why it looks the way it does. Say it. You say the lines back. If you allow it, PuhuScribe listens and tells you how close you were, in a gentle way. Your recording is not kept unless you ask us to keep it. Keep it. Words you met come back for a short review when it is time. The app decides when. You type the word from memory and there is nothing to rate. There are no streaks and no points."

**Who it is for.** "PuhuScribe is for adults who have moved to Finland and want to speak Finnish with the people around them. It starts from zero, with no placement test, and works toward A1, the first level on the European scale for language skills."

**Questions.** Four questions in native `details` elements, with spacing and no divider lines.
- "Do I need an account to start?" "No. Press Start and you begin as a guest. You can add an email address later from the account page."
- "Do I have to record my voice?" "No. Speaking feedback is your choice. A screen explains what is recorded before you turn it on, and your voice stays in the EU. It is not kept unless you ask us to keep it."
- "What if I already know some Finnish?" "Everyone starts at the beginning, so you can move through the first dialogues quickly."
- "What happens to my data?" "We keep the minimum. You can download everything or delete your account from the account page. The privacy notice explains each item."

**Closing part.** Heading "Try the first session." One sentence, "It takes a few minutes and needs no account.", and the button "Start your first session". The time claim is only used if the evaluator measures it (claims table).

**Footer.** The wordmark. "PuhuScribe is for adults, 18 and over." A "Privacy notice" link (to `/learn/privacy`). The responsible line of statement 23.

**Head text (proposal).** Title: "PuhuScribe | Learn the Finnish people actually speak". Description: "Learn spoken Finnish from your first sentence. Short dialogues in spoken and written Finnish, with a chance to say each line back and get feedback." Social description: "Short dialogues in spoken and written Finnish, and a chance to say each line back." Card line: "Understand the books. Speak the street." Card alt text: "PuhuScribe wordmark and the line Understand the books. Speak the street."

## Claims table

Each claim on the page and what makes it true. The evaluator checks every row at the end of the build and again at go live where marked.

| Claim on the page | What makes it true | Checked against |
|---|---|---|
| Every phrase comes taught twice, in written and spoken Finnish, and both have audio | Every approved line has both forms and both audio files | Published content (go live: after the reviewer's approval) |
| Teaches spoken Finnish from the start, and spoken comes first | Spoken is shown first in every dialogue | Job 8's screens |
| You hear a dialogue, tap a word to see its basic form, say the lines back, and the words return for review | Hear it, Understand it, Say it and Keep it are built (jobs 8 to 10). Use it (the tutor) is not mentioned | The running app |
| Speaking feedback is optional, the recording is not kept unless asked, the voice stays in the EU | Job 10's consent screen and defaults, Azure EU | The voice settings screen (go live) |
| Review is scheduled by the app, typed, nothing to rate, no streaks or points | Job 9, and the scope | The running app |
| Starts from zero with no placement test, works toward A1 | PRD section 4.1 | PRD |
| No sign up needed, you begin as a guest | Job 8's guest start | The running app |
| You can add an email address later, download your data, or delete your account | Job 11's account pages | The running app |
| For adults, 18 and over | PRD section 10 | Job 15's and job 8's front door line |
| The first situations include meeting someone and ordering a coffee | Units 1 and 2 | Published content (go live) |
| The first session takes a few minutes (only if kept) | Measured on the fixture and the first unit | The evaluator times it |
| The pictures show the app | The script captures the running app | Statement 8 |
| In beta, feedback page (only with call 1c B) | The feedback page exists (job 14) | The running app |
| Add it to your home screen (only with call 1c B and item 16 merged) | Scope item 16 | The running app, go live |

The page does not say how many units exist, does not name the tutor, gives no learner numbers and says nothing about price, paid plans or founding members. Units 1 to 3 are drafted and wait for the reviewer. Units 4 to 6 and the tutor step are not built.

## Threat model (GA)

**What is the worst a malicious person could do here?**
- Use the new forwarding to send a learner to a bad site. The forwarding map is fixed in code, nothing in the target comes from the visitor, and every odd path goes to `/` (statement 12).
- Break sign in, sign out or account deletion through the move, so a learner cannot leave or erase their data. Every redirect takes its address from one file, a repository test fails on a missed link, and each of the three endings has its own browser test (statements 11, 13).
- Reach the owner page by a new address that skips the Access lock. The owner host answers only its two page addresses and redirects the rest, and the Access check runs before anything (statement 17).
- Make the page claim something false, such as a feature the app lacks, which is misleading marketing. The claims table, the banned word test and the picture rules cover it (statements 3, 5, 7, 9).
- Show unapproved Finnish in a picture that a search engine and chat apps copy and cache. The script refuses to write such a picture and a repository test checks the manifest (statement 7).
- Show a real person's data in a screenshot. Pictures come only from the throwaway local database and the fixture, and the manifest text is scanned for emails, ids and keys (statement 10).
- Use up the Workers Free limit of 100,000 requests a day with page loads. Possible for any public page, the same limit as job 14's note. Past it, Cloudflare stops the Worker unless set to fail open (unverified).
- Plant a script on the page. The page has no script, and its policy allows none (statement 2).

**What data are we storing that we must protect?**
- Nothing new. The page and the move add no table, no function, no key and no provider.
- The visit tally holds a day and a country (job 14). It now also counts arrivals at the page.
- The committed pictures and the manifest hold only fixture screens and approved text.
- The responsible line holds a company name, its business ID and a contact. The business ID is public. Neither is secret.

**What must the system refuse even if asked nicely?**
- Collecting anything on the page: a form, a cookie, local storage, a script, a pixel or an outside request.
- Showing a Finnish line that is not approved, in the page, a picture or the card.
- Stating a price, a paid plan, a founding member offer, a deadline or a number of learners.
- Forwarding to an address the visitor names, and serving the page on the owner host.
- Letting a person hand edit a picture, or a build for the live address with the company fields empty.
- Weakening a design or analytics test to make the move pass.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | Where the page lives | `/` for the page and `/learn` for the app (the owner's answer of 31 October, like Duolingo) | The page at `/about` with the app at `/` (round 1) | The owner chose the main address. Search engines and people typing the name reach the page, and the app gets its own path. Duolingo and Busuu, which the owner named, both put the public page at the root and the app elsewhere (see the references, with what I could not confirm) |
| 2 | How the page is served at `/` | The page is a built file `landing.html`. The Worker answers `/` by asking Cloudflare's static files for it, and `index.html` stays the shell of the app | The page is the root `index.html` and the shell moves to another file | Cloudflare's docs say that a request matching no file gets the root `/index.html` with a 200 (single page application mode, read 31 October 2026). Every deep link under `/learn` would then show the landing page unless the Worker rewrote each one. Keeping the shell as `index.html` leaves all app deep links as they work now and puts one rewrite in one place, `/`. Cost: the Worker changes its "unchanged request" rule for `/` only, and the file's own address needs a redirect (statement 1) |
| 3 | How the page is built | Plain HTML and one CSS file built from the tokens, no script | v2's way: React loaded from files and the page drawn in the browser | v2's page is drawn by script, so a crawler or chat app that does not run script sees an empty shell and the card would be missing. It loads Google Fonts and Fontshare, which breaks the no outside request rule. A site tool such as Astro adds a second build system for one page. Cost: no React `Button`, so the CSS repeats the button look from tokens, and the design tests must cover that file |
| 4 | The hero picture | One picture composed by the script from real captures | The owner's v2 mock-up image as supplied; a hand made screenshot | The mock-up carries numbers and Finnish the app lacks or has not approved. A hand made file cannot be remade, and a picture that is not made by the script cannot be checked against the approved set |
| 5 | Picture format | WebP with a PNG fallback, in `picture` elements | PNG only, or AVIF | PNG alone makes the hero heavy for a slow phone. AVIF is newer, and learners use older phones (a lesson in `AGENTS.md`). The builder checks browser support tables and records them, as I did not verify the versions |
| 6 | Old addresses | The shell forwards the ten old addresses from a fixed map | Worker 301 redirects for each old address; or no forwarding | A Worker redirect needs the ten old paths in `run_worker_first`, so each would be a page route to count and test. No forwarding breaks the owner's and the testers' bookmarks and the home screen icons already made. The forward costs a few lines in the shell and no new route |
| 7 | Counting | Job 14's counter unchanged, with the new route list | A separate tally for the page | Job 14 locked the table's columns by test. Cost: page and app visits are one number, and a click from the page to the app counts once because it is same origin |
| 8 | How the pictures are made | Playwright, already in the stack, driving the real app | A screenshot service or a design tool export | A service sends the app's screens to a third party and costs money. A design tool export is hand made and drifts from the app |
| 9 | Retire the waitlist | Nothing built: no form, table, email, sender or owner section | A "keep me posted" form | The owner dropped it on 31 October. A later job 18, save progress, covers keeping progress, and is not part of this job |

New npm packages: none expected (Playwright, Sharp-like image conversion may be needed for WebP; the builder uses a package already in the lockfile or Playwright's own capture formats and records any new package for the owner). New database objects: none.

**Notes for the builder.**
1. Cloudflare's `html_handling` default serves `/landing` from `landing.html`. Test that `/landing`, `/landing.html` and `/index.html` never become a second public copy (statement 1), and record how `run_worker_first` `/` behaves with the default setting.
2. Confirm the Cloudflare Vite plugin builds an extra HTML entry (`build.rollupOptions.input`) and that the file lands in `dist/client` unchanged. Record it.
3. `supabase/config.toml` holds `site_url` and redirect addresses for the local test stack only. Job 11 signs in with typed codes, so no email holds an app link. The builder checks both and records that no auth email or setting points at an old address.
4. Keep the Worker's rewrite for `/` to one function with its own test, and keep `/learn/*` requests going to `env.ASSETS.fetch(request)` unchanged, so job 14's byte for byte test stays as it is for app pages.
5. The shell's forwarding runs before the app draws, so the old page never flashes.

## Contract notes for other jobs

1. **Onboarding (15)**: build 15 first, on today's `/`. Job 17 then moves its welcome with the front door to `/learn` and changes only its test addresses and its hallway sheet's link (statement 19). If 15 is still open when 17 starts, the manager has 15 merge first. The welcome has no link to the landing page.
2. **Tutor step (16)**: held. The page names no tutor feature. If it ships before the page goes public, the owner may add one sentence, which goes through the claims table.
3. **Save progress (18, new)**: builds on `/learn`, after this job. It uses `paths` from `src/lib/app-paths.ts` for every address it adds and the landing page makes no mention of it until it is built.
4. **Installable app (scope item 16)**: its manifest `start_url` is `/learn`, and its service worker leaves `/` (the page), `/robots.txt` and `/sitemap.xml` to the network, or arrivals are not counted. Its icons use `design/assets/app-icon.svg`. This job adds only the SVG favicon.
5. **Analytics (14)**: counting is reused, the page route list changes, the owner page sentence changes (statements 14, 16, 17).
6. **Accounts (11)**: `notice-settings.ts` gains two fields (statement 23). The privacy notice moves with the app (call 4).
7. **Go live**: attach `puhuscribe.exentrik.co`, set `VITE_PUBLIC_RELEASE=1` for the live build, switch off `workers_dev` on the production Worker so the page has one public address, check statement 28 and submit the sitemap to search engines if the owner wishes.

## Banned looks, and how the baseline avoids each

| Easy drift on a landing page | How the baseline avoids it |
|---|---|
| Three feature cards in a row, identical card grids | Sections are headings with paragraphs in one column. The hero's cards are pictures of real screens, two, different sizes |
| Numbered steps (01, 02, 03) | The four steps are plain headings in the order the app runs them. No numbers or icons |
| Stat tiles and big numbers | No numbers on the page |
| Gradient hero, purple to blue, glow, glass, gradient text | The page's own ground fade only (the one gradient `design.md` allows). Solid nav. No glow |
| Eyebrow labels | Headings only |
| Hairline rows | The questions use spacing and bold text, no dividers |
| Accent borders, pills everywhere | The only pills are the buttons. No coloured edge on a box |
| Icons and emoji sprinkled in | No icons outside controls, no emoji |
| Cream with serif and terracotta, near black with neon | The locked palette |
| Inter, Space Grotesk, Bricolage Grotesque | Poppins and Switzer, as `design.md` |
| Fake urgency and social proof | No countdown, no learner count, no testimonials, no press logos, no tester count |

The existing banned look tests (`tests/design-css.test.ts`, `tests/design-tokens.test.ts`, `tests/design-rules.test.ts`) must cover the new CSS. If a glob misses it, the builder extends the glob and says so in `build.md`.

## Out of scope

- A waitlist or any form, any email sent by the page, an email sender, a waitlist table or function, any owner page section for sign ups, bot protection for a form. (Dropped by the owner on 31 October.)
- Price, paid plans, founding members, offers and checkout. The page says nothing about them.
- Going live: the production Worker, hostnames, DNS and the live database. The go live job publishes the page together with the app.
- Job 18, save progress, and any prompt asking a guest for an email.
- Progress screens, calendars, charts, rings, streaks, a word bank with a target, the Day One Sprint and Language Island.
- A research section with studies (call 1d C), a blog, video, audio on the page, a chat widget, testimonials, press logos, counters, referral loops.
- Tracking of any kind beyond job 14's country tally. No campaign tags, no A/B tests, no outside counter, no pixel, no cookie banner (nothing is set).
- A Finnish version of the page, a language toggle (on the "Not in v3.0" list for the app), structured data and Search Console setup.
- Changes to what the app screens do. The move changes their addresses only.
- From the "Not in v3.0" list: no Day One Sprint front door, no vocabulary bank, no four modes, no grammar lessons, no sentence bank page, no standalone tutor, no rank titles, confetti or milestones, no bilingual toggle, no mnemonics, no YKI, no store builds, no Owner Insights beyond job 14's minimal page. No streaks.
- Editing v2's files. The read only copy is looked at and never changed.

## Build plan

1. **The look overview, before any picture.** One plain page, `factory/jobs/17-landing-page/overview/landing-look.html`, made with the real tokens and not shipped. It names each picture: 1 the owner's hero picture beside the baseline hero at 375 px and at desktop width; 2 the table of every hero part, kept or removed, as the owner's calls decide; 3 "Two Finnishes", "How a session works" and "Questions"; 4 the two or three screens the script will capture, with their Finnish status; 5 the social card at 1200 x 630 and small in a chat; 6 the address map, old and new. It says how the pieces fit. The manager shows it with calls 1 to 4. The look work waits for the answers. Step 2 does not depend on the look and can start earlier.
2. **The move.** `src/lib/app-paths.ts`, `App.tsx`, every link and redirect, the shell's forwarding, `page-routes.ts`, `wrangler.jsonc`, the owner host rules, the `/` route in the Worker, the edited tests and the helper in `e2e/`. Covers 11 to 19.
3. **Pictures.** `scripts/landing/` with the capture, the hero composition, the social card and the checks, the manifest and its tests. Covers 7 to 10 and 22.
4. **The page.** The landing file, its CSS, head tags, `robots.txt`, `sitemap.xml`, the shell's `noindex`, the footer and the `notice-settings.ts` fields, the privacy notice update. Covers 1 to 6, 20, 21, 23, 24.
5. **Browser tests and records.** Journeys in both browsers (page, button, `/learn`, forwarding, owner host), accessibility, weight, docs, README and the live check sheet. Covers 1 to 6, 11 to 13, 16, 25 to 27.

**Dependencies.**
- Job 15 merged (in build now) and job 14 and job 11 merged.
- The owner's answers to calls 1 to 4, the hero picture file, and Exentrik's legal name and business ID (the build may start step 2 without them and cannot finish without them).
- The native reviewer's answer on the two glossary words, and on any Finnish line the pictures use, before the page is public.
- Scope item 16 merged, only if call 1c keeps the home screen sentence.
- The font key (`FONTS_DEPLOY_KEY`) for Switzer. The pictures are made with the real fonts, so the person remaking them needs it.
- Preview links still wait for the Cloudflare preview keys. Until then the evaluator runs the page locally. Real chat previews and the live checks wait for the live address.

## Risks and flags

- **Look closely: every address of the app changes.** Sign in, sign out, delete, guest start and the owner host all pass through the move. Statements 11 to 17 and the three ending tests are the protection. A missed link would drop a learner on the page instead of the app.
- **Look closely: Finnish content.** The two glossary words, and any Finnish a picture shows. The approved set is empty today, so the baseline pictures show none. They go to the native reviewer.
- **Look closely: learner data and consent.** The page takes nothing, and the pictures use only the fixture. The evaluator checks that no real address or id sits in any picture or text.
- **Look closely: database access rules.** None touched. Statement 27 proves it.
- **Paid services and running costs.** None. Page, pictures and move cost €0. Page loads count toward Workers Free's 100,000 requests a day. Static file requests may not count, as I recall from Cloudflare's pricing page, and I did not re-read it today.
- **Promises.** The page makes only the claims in the table. If the owner adds "beta" or the home screen sentence, those are promises too.
- **The owner's design is changed by the facts.** The v2 hero shows features the app lacks. The overview shows what remains, and the owner decides. The baseline follows the owner's banned list and `design.md` until told otherwise (section 2 of the calls).
- **Company details.** The legal name and business ID are the owner's. A live build fails without them. I could not verify whether Exentrik is registered.
- **Coordination with 15.** 15 is built on `/` now. The move changes only its test addresses. If 15's tests land after this job starts, they must use `paths.frontDoor`.
- **Visits are mixed.** Page and app arrivals are one number on the owner page (Decision 7).
- **GA.** The job is done only when `summary.md` records the owner's own written "approved" line with the date.

## Could not verify

- **The address references.** I could not confirm Duolingo's `/learn` or Busuu's `/dashboard` by fetching. Duolingo's page returned only its name. Busuu's `/dashboard` returned its public page, titled "Learn languages: Spanish, French, German and start for free", with no redirect shown. The two addresses are the owner's observation.
- **The live v2 landing page.** I read its code in the read only copy (`_v2-readonly/public/landing/`) and not the live site. The owner's description of the hero (a tilted pair of cards, the "Now in beta" tag) matches that code.
- **The owner's hero picture.** I have not seen the file. I worked from the owner's description and the code.
- **Award galleries.** Awwwards' education list gave names only. Land-book returned 403. Godly redirected to recent.design with titles only. SiteInspire gave names and dates. The references below are real brand pages opened in round 1.
- **Exentrik's status.** Whether it is a registered company or a trading name, its legal name and its business ID.
- **The business ID's check digit.** I did not check the registry's rule, so the test checks the shape only.
- **Where approved lines are read from.** No publish migration exists today. The builder confirms the place the content jobs commit them to.
- **Browser support for WebP on the oldest phones the app targets, Lighthouse settings and the layout shift threshold.** From memory. The builder records the real figures.
- **Workers Free over the limit**, whether it fails open or closed, and **static file billing.** Not verified.
- **Whether scope item 16 will ship the home screen install** the hero note promises.

## References

Real pages, opened on 30 October 2026 unless marked. The table keeps the eight round 1 references, with borrowings changed for a page with no form and no price, and adds the two address references and v2's own page.

| Reference | Borrow | Leave out |
|---|---|---|
| PuhuScribe v2 landing, the owner's own page. Code read from `_v2-readonly/public/landing/` on 31 October 2026. Live: https://puhuscribe-v2.vercel.app/landing (title only) | The headline, the lead, the split of the nav, the phone with two flanking cards, the "Two Finnishes" explainer with the register card, the Questions order | Everything in call 1 and the table of call 2 |
| Duolingo, https://www.duolingo.com/ (address reference, owner's example; app path unconfirmed by me) | The public page at the root and the app on its own path, the single clear button to start | Its sign up wall, mascot and streak language |
| Busuu, https://www.busuu.com/ (address reference, owner's example `/dashboard`, unconfirmed by me) | The public page at the root and the app at `/dashboard`. Also a short time promise, only if it is true for us | "120 million learners", awards we do not have, the business section |
| Memrise, https://www.memrise.com/ | One sentence promise about real speech ("Understand native speakers. Sound more like them."); a short FAQ that answers "speaking in week one"; a "Now you say it" closing prompt | Press logo strip, video led layout, the language picker, the cost answer (the page says nothing about price) |
| Speak, https://www.speak.com/ | The same call to action at the top and the bottom | Award badges, "15M+ downloads", the three method cards, its prices |
| Babbel, https://www.babbel.com/ | A plain statement of the method | The promo countdown banner (false urgency, banned by the EU directive's Annex I point 7), the "92% improved" claim, stock lifestyle photos |
| Lingoda, https://www.lingoda.com/en/ | Nothing now, since the page makes no offer. Kept for when offers return | The sale banner, "Hurry now!" |
| Pimsleur, https://www.pimsleur.com/ | Naming the method in plain steps and saying what you do in each | "Scientifically proven" claims, the all caps banner. Its page says "up to 4 users" in one place and "up to 3" in another, the kind of slip our claims table prevents |
| Senthora, https://senthora.ai (listed on Awwwards) | A short privacy and beginner FAQ | Numbered steps, six feature cards, a streak, uppercase labels |
| Halden app site, https://recent.design/i/1u0n947-halden-app-website (Godly's feed, listed as minimal, light, consumer) | The calm light single column mood | Scroll animation and the phone mockup (I read only its listing, not the site) |

## Sources

- PRD sections 0, 2, 3, 4.1, 6, 10, 11, 13 and 14: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md` (read in round 1)
- Project: `AGENTS.md`, `design.md`, `docs/scope/scope.md` item 15 and item 16, `factory/specs-waiting.md` (the owner's answers of 31 October 2026), `factory/progress.md`, `factory/jobs/14-analytics/spec.md`, `factory/jobs/15-onboarding/spec.md`, `factory/jobs/11-accounts/spec.md`, `worker/page-routes.ts`, `worker/index.ts`, `worker/owner.ts`, `worker/visits.ts`, `wrangler.jsonc`, `src/App.tsx`, `src/main.tsx`, `src/screens/*.tsx` (the link and redirect search), `src/lib/account-notice.ts`, `src/lib/crash-clean.ts`, `tests/analytics-rules.test.ts`, `scripts/security/check-built-files.ts`, `supabase/config.toml`, `supabase/migrations/`, `supabase/tests/database/analytics.test.sql`
- The owner's v2 landing page, read only copy: `C:/Users/fumna/dev/_v2-readonly/public/landing/index.html`, `landing-app.js`, `phone.js`
- Cloudflare, static assets single page application behaviour (a request matching no file gets the root `/index.html`; `run_worker_first` keeps that behaviour), read 31 October 2026: https://developers.cloudflare.com/workers/static-assets/routing/single-page-application/
- Cloudflare static assets `html_handling` (round 1): https://developers.cloudflare.com/workers/static-assets/routing/advanced/html-handling/
- Cloudflare Workers pricing (Free 100,000 requests a day): https://developers.cloudflare.com/workers/platform/pricing/
- Unfair Commercial Practices Directive, Annex I, legislation.gov.uk copy: https://www.legislation.gov.uk/eudr/2005/29/annex/I/adopted
- Open Graph protocol: https://ogp.me/
- Facebook sharing image guidance: https://developers.facebook.com/docs/sharing/webmasters/images/
- Google, snippets and meta descriptions: https://developers.google.com/search/docs/appearance/snippet
- Google, canonical URLs and `noindex` versus robots.txt: https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls
- web.dev, Largest Contentful Paint thresholds: https://web.dev/articles/lcp
- Address references fetched 31 October 2026 (titles only): https://www.duolingo.com/learn, https://www.busuu.com/dashboard
- References opened on 30 October 2026: https://www.memrise.com/, https://www.speak.com/, https://www.babbel.com/, https://www.busuu.com/, https://www.lingoda.com/en/, https://www.pimsleur.com/, https://senthora.ai, https://recent.design/i/1u0n947-halden-app-website, https://www.awwwards.com/websites/education/, https://www.siteinspire.com/websites/categories/education

## Changes from round 1

Removed with the waitlist: owner's calls 2 (email sender), 3 (founding member), 4 (bot protection) and 7 (when public, now fixed as "with the app at go live"); the statements on the form, the one answer for every case, the trap and clock, the confirmation email, confirm and leave pages, no account, the list table, `join_waitlist`, confirm and leave functions, not tied to an account, retention, the key, breaking each protection, the owner function, the owner page section and the privacy notice's waitlist part; the threat model answers on the list, fake consent, mail relay and scraping; the waitlist privacy facts table, the email provider decision, the key and link origin notes and the sender and key contract notes. Changed: the page address (call 1 of round 1, now decided), the look (now the owner's v2 hero with real screens), Exentrik (now only the responsible line). Kept: search metadata, the social card, no cookie and no outside request, going public with the app, the three threat model questions, the references.

Result: ready for owner approval
