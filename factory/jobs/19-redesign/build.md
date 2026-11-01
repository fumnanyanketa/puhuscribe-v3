# Build notes: 19-redesign, round 3

Branch `factory/19-redesign`, pushed to origin. No pull request was opened and nothing was merged. This file is in the worktree. Round 3 answers the two small items left in "Round 2 re-check" of `review-design.md` (A and B) and its note C. Both review files are committed with this work. The tested commit is `__COMMIT__`.

## Round 3: what changed

| Item | What I did | Protected by |
| --- | --- | --- |
| A. Signs pile up on short phones and at 200% text | The road shows fewer signs while any two boards, or a board and the top bar, would touch. The sign of the current stop and the next one are always kept (`fitSigns` in `road-state.ts`), then one more on alternate sides. The gap between signs grows with the tallest board (`signGap`, so two tall boards never touch). A board that would run past an edge of the screen is nudged back inside. A hidden 1 rem box tells the screen when the text size changes, because a capped card does not change size. The boards may be wider (58 percent of the screen). The check waits for the opening animation, whose scaling would give wrong sizes. | `e2e/redesign-road.spec.ts` `[redesign 20] [redesign 13]`: in all five card states, at 375 x 667 and at 320 x 640 with text at 200 percent, at least two signs show, one of them done or current, no two boards touch, none touches the progress bar or the account button, every board is whole on the screen. `src/lib/road-state.test.ts` for `fitSigns`. |
| B. Card fills the screen at 320 px, 200% text | The card's wrapper stops at 42 percent of the screen height and its inside scrolls (`overflow-y: auto`), so the road, the bar and the account button stay in view. | The same test: the card's height is at most 43 percent of the screen, the bar and the account button are on screen and not covered (`elementFromPoint`), and the card's button is reached by scrolling inside the card. |
| C. Said twice | Keep it shows "Type the missing word" once, as the field's title (where the drawing has it); its status line is now for screen readers only. The crash screen shows "Something went wrong" once, as the title; the problem sentence (existing copy) stays in the page for screen readers, in the problem style. `StatusLine`'s hidden style now wins over a tone's padding and edge and keeps its sentence in a 1 px box. | `e2e/redesign-lesson.spec.ts` `[redesign 31]` and `e2e/design-reference.spec.ts` `[redesign 41]` count the visible copies (one) and check the status line still holds the sentence. |

Records: `design.md` has a bullet for the signs and the card cap and one for "said once". Screenshots retaken: every road screen (both browsers, all three sizes), Keep it and the crash screen. `evidence/02-road-day-one-*`, `03-road-continue-*`, `04`, `05` and `06` at 375 x 667 and 320 x 640 with text at 200 percent show the result.

## Round 3: earlier tests changed

None. The new tests are added; no earlier check was changed or loosened this round.

## Round 3: proof by breaking each new protection

`evidence/proof-by-breaking-round3.md`: 7 deliberate breaks, each applied in the working copy, its test run, red for the intended reason, and undone: all five signs shown whatever the room, no gap for tall boards, no height cap on the card, the next sign left out of the fit (unit test), the text size probe dropped, Keep it saying its instruction twice, and the crash screen saying its sentence twice. Nothing from a break was committed.

## Round 3: check results

- `npm run check:code` and `npx vitest run` on this computer: type check and lint pass; vitest passes except one `commit-tool` timing test that fails under load on this machine and passes alone and on GitHub (round 1's open points).
- The mock based browser files and the reference page (161 tests) pass in Chromium against the running app.
- Full run on GitHub: __RUN3__
- No scratch branch of this job is left on origin.

## Round 3: unfinished or uncertain

- At 320 px with text at 200 percent the two remaining signs are big (their names are 26 px) and the current sign can partly cover the A1 label of the sun. They never touch each other, the bar or an edge. That is the price of keeping text at 200 percent.
- When the opening animation ends, a short phone may drop signs once (the check waits for the animation so its sizes are right).

Result: __FINAL__

---

# Round 2 (kept short)

Round 2 answered the first design and security reviews. Commit `48ff3c8`, run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41343076151, all checks passed. Page content starts at least 168 px from the top (`--page-content-top`); the delete link has its own token `--color-danger-ink` with contrast pairs on the wash; the mint road runs from the foot of the road to the marker; Finnish rows are about 1.4 apart with 44 px hit areas that overlap; changed words have the thin peach ring; Understand it is one card; the download ready screen has the title "Your file is ready."; privacy headings are ink; the Keep switch and the privacy page show the `keepBox` sentence; the privacy page names the speech service's country through one read of `GET /api/voice` (the one check loosened: `[accounts 16]` now allows exactly that call); unreached progress pieces are hollow with a 3 to 1 edge; the finish dock is a milky bar; the road's bend is 48 against the drawn 34. Proof by breaking: `evidence/proof-by-breaking-round2.md` (14 breaks). The full round 2 notes are in git history at `921739a`.

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

