# Build notes: 19-redesign, round 2

Branch `factory/19-redesign`, pushed to origin. No pull request was opened and nothing was merged. This file is in the worktree (`.worktrees/19-redesign/factory/jobs/19-redesign/build.md`), not in the main checkout. Round 2 answers `review-design.md` and `review-security.md` (both committed with this work). The tested commit is `__COMMIT__`.

## Round 2: what changed, item by item

| # | Item | What I did | Protected by |
| --- | --- | --- | --- |
| 1 | Content on the hills (design, must fix) | The `PageFrame` header is at least `--page-content-top` (168 px, a new token) tall, so the first text starts at 168 px or lower on every page. The crash screen got the same padding. | `e2e/redesign-pages.spec.ts` `[redesign 4]`: for every page, at 375 x 812, 375 x 667 and 320 px wide with text at 200 percent, the first text of the content is at least 160 px down and lower than the lowest tree, flag or sun of the band. `tests/redesign-rules.test.ts` for the crash screen. |
| 2 | "Delete my account" contrast (must fix) | New token `--color-danger-ink` (#8c3b1a, 6.1 to 1 on the peach end of the wash). Two new pairs in `contrast-pairs.ts` (on the peach end and on the middle of the wash). The colour tables in `design.md` are regenerated. | `tests/design-tokens.test.ts` (each pair) and `tests/redesign-rules.test.ts` `[redesign 6]`: the link's colour token must have its pair on the peach end of the wash at 4.5 to 1 in the list. That is the test that would have caught the old colour. |
| 3 | Mint travelled road (must fix) | The road picture draws the mint from the foot of the road up to the "you" marker's own position, with mint edges, and draws nothing on day one. It no longer takes a share of 36 stops. | `e2e/redesign-road.spec.ts` `[redesign 12]`: at stop 3 the mint ends within 12 px of the marker, reaches the foot of the picture and is over 200 px long; on day one there is none. |
| 4 | Finnish line leading (should) | Each word keeps its 44 px button, but a negative block margin makes it take one line of text, so the hit areas of two rows overlap by a few pixels and the rows are about 1.4 apart. Names without a card are plain inline text. | `e2e/redesign-lesson.spec.ts`: row pitch between 1.2 and 1.6 times the font size while every word button is 44 px tall. The earlier 44 px target tests stay green. |
| 5 | Peach ring (should) | Changed words get the drawn 1 px ring in `--color-peach`, inside. The darker text colour stays. | `e2e/redesign-lesson.spec.ts` `[redesign 2]`: ring on changed words in both lines and none on other words. |
| 6 | Understand it, one card (should) | The wrapper of the spoken only line card adds no panel; the line's own box is the milky card. | `e2e/redesign-lesson.spec.ts` `[redesign 28]`: the outer element has no fill or shadow and exactly one panel sits inside. |
| 7 | Download ready (should) | "Your file is ready." is the title (the page's `h1`, ink, semibold, centred under the orb), the quiet line is under it, and "Download" is at the bottom. The status line still says "Your file is ready." for screen readers and is not drawn twice, so job 11's download tests stay as they were. The extra "Back to your account" link is removed. No spec statement needs it (statement 37 lists the title, one line and "Download"); the back arrow, named "Back to your account", is the way back. | `e2e/redesign-pages.spec.ts` `[redesign 37]`: title, centred, one link with that name and no button, and the status line still saying it. |
| 8 | Privacy headings (should) | Ink instead of mint. | `e2e/redesign-pages.spec.ts` `[redesign 39]`: the five headings are ink. |
| 9 | Keep sentence (security) | The "Keep my recordings" switch's help text is the `keepBox` sentence from `voiceNotice()`, with "On." or "Off." in front so the state is in words. The privacy page voice section shows the same sentence before "You can change both choices at any time in Voice settings." | `e2e/redesign-pages.spec.ts` `[redesign 36]` (the switch description in both states) and `[redesign 29] [redesign 39]` (privacy page). `src/screens/protected-copy.test.ts` still freezes the text and the version label. |
| 10 | Country (security) | The privacy page makes one read of `GET /api/voice` and passes the real region to `voiceNotice()`, so a signed in learner reads "in the EU, in Italy" (or whichever country the Worker names). A visitor gets a 401 and reads "in the EU". The consent sheet is unchanged: title, "How it works" and two buttons. The processors list no longer says the country is on the speaking screen. | `e2e/redesign-pages.spec.ts` (with a region, and with a 401) and `e2e/account-pages.spec.ts` `[accounts 16]`. |

Also from the notes:

- **Unreached progress pieces** (road top, lesson bar, lesson pieces on the card) are hollow with a 1 px `--color-control-edge` edge, 3 to 1 on the mint, middle and peach ends of the wash (new pair on the peach end). Test: `e2e/redesign-road.spec.ts` `[redesign 14] [redesign 6]`.
- **Done dock on the finish screen** is a milky bar with the dock shadow instead of a hard cut (`SessionFrame` `finished`). Test: `e2e/redesign-lesson.spec.ts` `[redesign 33]`.
- **Road curve:** the bend is 48 against the drawing's 34 (`BEND` in `landscape-geometry.ts`), because the phone shows the picture larger and the card hides the lowest part. The S now reads like the drawing (see `evidence/03-road-continue-app-*.png`).
- **Keep it counter** ("Word 1 of 1.") now starts below the hills (it sat on them).
- **Evidence:** every screenshot was taken again. New: Keep it (prompt, right, close), "Something went wrong" (taken from its box on the reference page, because a render error cannot be made on purpose in the app), and twelve key screens at 375 x 667 and at 320 px wide with text at 200 percent, in both browsers (`*-375x667-*.png`, `*-320x640-text-200-*.png`). The three Say it recording states are still Chromium only.
- **Records:** `design.md` (page content start, ring, tight rows, one card, ready screen, delete link, travelled road, hollow pieces) with its regenerated colour and contrast tables, and `src/privacy/processors.ts`.

## Round 2: earlier tests I changed, and why

- `e2e/redesign-pages.spec.ts` `[redesign 37]`: the title is "Your file is ready." instead of "Download my data", and the extra link is gone (item 7). `e2e/accounts.spec.ts` is not changed for this.
- `e2e/account-pages.spec.ts` `[accounts 16]`: the privacy page now makes exactly one `/api` call, `GET /api/voice`, for the country (item 10), where it made none. A visitor's call is a 401 before any database read. The test still checks that every request stays on the page's own address and that the cookie is empty. I changed this on purpose. It is the one place where I loosened a check, so the reviewer should look at it. `[redesign 39]` has the same single call.
- `tests/redesign-rules.test.ts` and `e2e/redesign-evidence.spec.ts` have new tests and shots only.

## Round 2: proof by breaking each new protection

`evidence/proof-by-breaking-round2.md`: 14 deliberate breaks, each applied in the working copy, its test run, red for the intended reason, and undone. They are: the header losing its height (text back on the hills), the delete link back on the failing colour, the mint road as a share of 36 stops, the words of a line spaced by their 44 px again, the ring removed, a card inside a card on Understand it, a back button on the ready screen, mint privacy headings, the Keep switch without the consent sentence, the privacy page with no country, the privacy page without the Keep sentence, a progress piece without its edge, the finish dock without its fill, and the crash screen on the hills. Nothing from a break was committed.

## Round 2: check results

- `npm run check:code` and `npx vitest run` on this computer: type check and lint pass; vitest passes except `tooling 9` (gitleaks timing under load, see round 1's open points), which passes alone and on GitHub. The format check warns only about `design-drafts/` line endings on this Windows copy.
- The three mock based browser files (`redesign-road`, `redesign-lesson`, `redesign-pages`) pass in Chromium against the running app (118 tests).
- Full run on GitHub: __RUN2__
- No scratch branch of this job is left on origin.

## Round 2: unfinished or uncertain

- The country only shows for someone with an account (a visitor reads "in the EU"). The Worker is the only place that knows it. If the owner wants it for everyone, the Worker needs a small public route, which is not in this job.
- Two word buttons on neighbouring rows overlap by about 9 px, so a tap on the overlap goes to the lower row's word. That is the cost of tight lines with 44 px targets, as the review suggested.
- WebKit screenshots of the three Say it recording states are missing, as in round 1 (the local WebKit cannot record).

Result: __FINAL__

---

# Round 1 (kept short)

Round 1 built the road, the lesson screens, the account and privacy pages and the Worker reads, with no database change. Its tested commit was `07f7daa` (run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41333172662, all checks passed). Its statement to test map (statements 1 to 49) still holds. Proof by breaking for round 1 is in `evidence/proof-by-breaking.md` (18 breaks). The full round 1 notes are in git history at `44e9d3e`. The parts below are the ones still needed. Round 2 added one colour that is not a drawn one: `--color-danger-ink` #8c3b1a, for small delete text on the wash.

### Colours changed from the drawings

Every floor of `src/styles/contrast-pairs.ts` is kept (47 pairs, in `design.md` and tested). These six drawn values were under their floor, so I darkened the least needed.

| Role | Drawn | Built | Reason |
| --- | --- | --- | --- |
| Mint (button, marks, spoken dot) | #23917a | #1e856f | White on the button was 3.9 to 1, now 4.5 to 1. |
| Slate (written Finnish) | #4f6d94 | #38527a | Finnish lines need 7 to 1; the drawn value gave 5.3 to 1 on white. |
| Slate soft (tile) | #e4ebf4 | #edf2f8 | So slate text on it reaches 7 to 1. |
| Changed word text | #b8532f | #7f3618 | The drawn value gave 4.0 to 1 on its peach wash; now 7 to 1. |
| Peach marks (sun, rings, recording) | #ee8763 | #db7249 | Marks need 3 to 1 on white. |
| Quiet text | #637570 | #556863 | The drawn value gave 3.9 to 1 on the mint end of the wash; now 4.7 to 1. |

`/design-reference` shows each changed colour beside the drawn one.

### Earlier tests I changed, and why

All changes follow a text or layout change made on purpose. None removes or weakens a check. Where an old sentence is gone, the test now proves it is gone or checks the new sentence.

**Design tests (statement 9)**
- `tests/design-css.test.ts`: the allowed gradient name is `--ground-wash` (was `--ground-fade`). All "catches" tests stay.
- `tests/design-tokens.test.ts`: rewritten for the new tokens, roles, panels and type scale. The raw colour refusal stays. The dark mode pairs are gone because the look is light only (owner's answer).
- `tests/design-rules.test.ts`: the font check is Poppins everywhere (owner's answer), light only, sizes in `rem`.
- `tests/design-build.test.ts`: also proves the road fixture marker is not in a build.
- `e2e/design-sample.spec.ts` and `e2e/design-reference.spec.ts`: Switzer tests became Poppins tests; the dark and light page background test became one light only test; "Spoken" and "Written" labels are gone, so the test checks the named groups; the word card facts are the new card's; the sideways scroll check counts a part inside an svg by the svg's edge; two front page axe tests install the road mock and wait for the opening to finish.

**Text and layout changed on purpose (statement 43)**
- `e2e/front-door.spec.ts`, `e2e/health.spec.ts`: the home screen is the road ("Your road to A1" is a hidden `h1`); the problem line appears only when there is a problem.
- `e2e/account-pages.spec.ts`: "I already have an account" is "Have an account? Sign in" (a link); the privacy notice sections sit behind "Read the full notice".
- `e2e/accounts.spec.ts`: the guest account page is a profile page ("Add your email to keep your progress.", "Saved on this device", address and "Saved to your email"); "Delete my account" on the confirmation is "Delete for good"; the email screen title is "Create your account" (owner's answer); "I already have an account" is the "Sign in" link.
- `e2e/analytics-feedback.spec.ts`, `e2e/analytics-journey.spec.ts`: the field label is "What should we know?"; "Go to the front door" is "Back to the road"; the road has no feedback link, so the form is opened by its address; the consent is a sheet.
- `e2e/first-session.spec.ts`: Hear it shows one card at a time; changed words are peach; word card facts sit behind "Why does it change?"; the bottom button of Understand it is unavailable until the answer is right; the finish bar is named "Session finished"; the old "The words you met will come back in your review." line is not on the screen (the test proves it is gone).
- `e2e/save-progress.spec.ts` and `e2e/save-progress-helpers.ts`: the note is a milky panel (a 1 px edge, fill and shadow instead of none); "Create your account" heading; the secondary button text is mint deep; the answer's `newWords` list is left out of the compared body; the note is reached by scrolling above the action area; the old "comes back in your review" line is gone.
- `src/screens/save-note-copy.test.ts`: the owner's new words for the note and button (an owner's change).
- `e2e/speaking-feedback.spec.ts`: the consent is a sheet (title, "How it works", "Turn on", "Not now", no keep box); keeping recordings is a switch in Voice settings, so tests that need kept recordings turn it on there; "Play my recording" is "Play mine"; the Say it card has no play buttons; Voice settings buttons are switches; a clear result shows a card with "Try again" in place of the record button.
- `e2e/spoken-review.spec.ts`, `e2e/patterns.spec.ts`, `e2e/daily-review.spec.ts`: the road's buttons ("Start", "Start review", "Continue"); the review card shows the count and minutes; "Done for today" is a card on the road; the cross opens the sheet; play controls and word cards follow the new card.
- `src/components/patterns-panel.test.ts`: the word card layout changed, so the test checks the order of the new facts.
- `src/lib/review-day.test.ts` (added to) and `worker/review.test.ts`, `worker/test-fakes.ts`: `reviewCount` on a review only day.
- Helpers (`e2e/session-helpers.ts`, `account-helpers.ts`, `owner-helpers.ts`, `review-helpers.ts`, `test-base.ts`, `road-route.ts`): new contexts install the road mock; helpers close the first lesson tip and leave through the sheet.
- `playwright.config.ts`: `reducedMotion: 'reduce'` for every test, so the opening is a short crossfade. The animation tests set `no-preference` for their own blocks.
- Removed source: `src/screens/FrontDoor.tsx` and its CSS (the road replaces it) and `src/screens/VoiceConsent.tsx` (the consent is a sheet). Both were only used by the screens they belonged to.

### Departures from the drawings

1. **Done for today** shows the existing sentence "Your next review is tomorrow." (or the day). The drawing says "Next lesson tomorrow". The app knows the next review day, not the next lesson day, and the sentence must be true.
2. **Privacy first layer wording.** "Never your name" became "We never ask for your name." and "Checked, then deleted" became "Your recording is checked, then deleted, unless you choose to keep it." The first layer may only claim what the data inventory supports (tested).
3. **Consent sheet.** There is no keep box on the sheet. "Keep my recordings" is a switch in Voice settings and stays off after "Turn on". The spec said "How it works" opens job 10's full text; the owner's answer said it opens the privacy page voice section, so it does.
4. **Understand it** keeps the existing question words ("What does this mean?"). The drawing's "What does Maria ask?" and "Check" are samples.
5. **Day one card order** puts the sign in link and privacy link under "Start", and the guest line small under them.
6. **Account "Add" button** is named "Add your email" for screen readers.
7. **New words chips** show up to 24 words with no "+N" chip. The heading counts the chips shown.
8. **Opening animation card** is hidden with `visibility` until about 3.4 seconds, so a screen reader reaches the card after the animation or through "Skip". The card is never covered at small phone size.
9. **Review label** is "Start review" (the drawing says "Start").
10. **Delete page title** is "Delete your account?".

### Open points

- **Job 20's route answers 401 for visitors.** Its `GET /api/road` needs a signed in learner (columns `stop_number`, `title_en`, `can_do_en`, `part_number`, `lessons_total`, `lessons_done`). The day one road is shown to people with no account, so it needs a form of the route that answers visitors with zero progress. `parseRoad` already accepts both the interface shape and job 20's column names, as a list or `{ stops }`. Job 20 or the manager needs to decide; the swap on my side is `loadRoad()` only.
- **Word meanings** (`meaning`, `baseMeaning`) are not sent by the Worker yet. Job 20 adds the data. With none, the card leaves the line out and invents nothing.
- **The consent text is not shown in full any more.** The four paragraphs of `src/lib/voice-consent.ts` stay frozen word for word with their version label (tested), but the learner now sees the privacy page voice section instead, which says the same facts in the privacy notice's words. The owner may want the privacy page to hold the consent paragraphs word for word.
- **Privacy "Updated" date** is `NOTICE_UPDATED` in `src/privacy/notice-settings.ts`, set to 2026-11-01.
- **Sign in page heading** is unchanged ("Sign in with your email").
- **Keep it, Use it with Otso, "Something went wrong"** have no app screenshots in the evidence. Keep it runs for real in the database tests on GitHub; Otso is out of scope; the crash screen is covered by a unit test. The three Say it recording states (listening, clear, try again) are Chromium screenshots only, because the local WebKit build cannot record on a plain http page. Both browsers run them on GitHub.
- **Options A and B** of `numbers-question.html` were not built (owner chose C).
- **Unit test `tooling 9`** (gitleaks timing) timed out twice on this computer under the load of the whole suite and passes alone and on GitHub.
- **Banned list check.** No eyebrows, no accent borders, no pills scattered, no gradient text, no emoji. Peach is wider than the old rule (owner's answer 1).

### How to run it locally

1. `npm ci`. Create `.env.local` the usual way (never print it).
2. Without Docker, run the screens against the mocks: `npx vite --port 5199 --host 127.0.0.1`, then `PLAYWRIGHT_BASE_URL=http://127.0.0.1:5199 npx playwright test e2e/redesign-road.spec.ts e2e/redesign-lesson.spec.ts e2e/redesign-pages.spec.ts --project=chromium`. Open `http://127.0.0.1:5199/design-reference` (with `VITE_DESIGN_REFERENCE=1`) to see every part in each state.
3. With Docker and the throwaway Supabase, load the seeds, run `VITE_DESIGN_REFERENCE=1 npm run build` and `npx playwright test`.
4. Evidence: `PUHUSCRIBE_EVIDENCE=1 PLAYWRIGHT_BASE_URL=http://127.0.0.1:5199 npx playwright test e2e/redesign-evidence.spec.ts`.
5. Real stops: `GET /api/road` must answer from job 20. Set `PUHUSCRIBE_REAL_ROAD=1` to make the browser tests use it instead of the fixture.

