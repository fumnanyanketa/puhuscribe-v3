# Build notes: 19-redesign, round 5

Branch `factory/19-redesign`, pushed to origin. No pull request was opened and nothing was merged. This file is in the worktree. Round 5 answers the two failures of the round 4 re-evaluation (`evaluation.md`, commit `8aa2598`). The tested commit is `__COMMIT__`.

## Round 5: what changed

| # | Item | What I did | Protected by |
| --- | --- | --- | --- |
| 1 | Statement 46: a tappable long word after other words ran into the row above, and its pieces were centred | Both causes were the evaluator's. The 44 px tap area was a negative margin only, which made sense for a one row button, but a button of several rows then had its first row pulled up 9 px over the row above. The tap area is now padding inside the button (`--pad`, what 44 px needs above and below one row of text) that the negative margin cancels, so the text stays on the line's rows. The button also gets `text-align: start`, so the pieces of a wrapped word start at the left and no piece such as "rin" is centred. One row buttons look as before. | `e2e/redesign-lesson.spec.ts` `[redesign 46] [redesign 5]`, in Hear it and in Say it, both browsers: a tappable word after other words (the 21 letter `terveyskeskuslääkärin` in Hear it, a longer one in Say it, whose card is wider) is measured by its text: the first piece may sit no more than 1 px above the bottom of the text row above, and every piece after the first starts at the button's left edge. Both go red on the old CSS (proofs 1 and 2). The row overlap was 9.09 px before, as the evaluator measured. |
| 2 | Statement 47: focus lands on the body after a tap in Voice settings | `Switch` takes a `ref`, and `ConsentSheet` takes `returnFocus`; Voice settings passes its Speaking feedback switch. Every other use of a sheet was checked the same way (see below). | `e2e/redesign-pages.spec.ts` `[redesign 47]`: with a mousedown that cannot move focus (Safari's tap), tapping the switch opens the sheet and "Not now", Escape and the dimmed page each give focus back to the switch (proof 3). |

Every place that opens a dialog, each tested with a Safari style tap:

- The leave sheet (cross): fixed in round 4, tested.
- The consent sheet in Voice settings: fixed here (above).
- The consent sheet in Say it. It opens by itself when Say it appears, so it has no opener, but the quiet "Turn on speaking feedback" button of the "Not now" state opens it too, and that button is hidden while the sheet is open. Focus is now given back to it by hand once the sheet has closed. Test: `[redesign 47]` in `e2e/redesign-lesson.spec.ts` with "Not now", Escape and the dimmed page (proof 4).
- The word card (a word of a line, and a chip on the finish screen): `FinnishLine` gives focus back to the word itself. Test: `[redesign 47]`, tapped (proof 5).
- The "Patterns you've seen" panel: it focuses its own button. Tested in the database backed `e2e/patterns.spec.ts` (`[units 10] [redesign 47]`), which runs on GitHub.
- The first lesson tip is not a sheet and returns focus to "Next line", tested in round 1.

Also: screenshots were retaken, with a new one for the 21 letter tappable word (`30-tappable-long-word-*`). `design.md` has the lines on the tap area and on which control gets focus back. The road bend stays at 48 for the owner.

## Round 5: evidence folder

In round 4 my retake of the screenshots deleted the evaluator's own files from the first evaluation (94 `eval-*.png`), because I cleared every png before taking mine. I restored all of them from git in this round. From now on my retake deletes only the numbered files that I make myself.

## Round 5: earlier tests changed

None. Two assertions of my own round 5 test were tightened while writing it (it compares only the pieces after the first, because the first piece starts after the word's own padding). No earlier test was removed or weakened.

## Round 5: proof by breaking each new protection

`evidence/proof-by-breaking-round5.md`: 5 deliberate breaks, each applied in the working copy, its test run, red for the intended reason, and undone: the old margin with no padding, centred pieces, the Voice settings switch not given focus back, Say it not giving focus back to its quiet button, and the word not getting focus back after its card. Nothing from a break was committed.

## Round 5: check results

- `npm run check:code` and `npx vitest run` on this computer: type check and lint pass; vitest passes except `tooling 9`, a timing test that fails under load on this machine and passes on GitHub (see round 1's open points).
- The mock based browser files pass in Chromium and WebKit on this computer, except three WebKit tests that need a recorder or Tab on buttons, which this Windows WebKit lacks. They pass on GitHub.
- Full run on GitHub: __RUN5__

Result: __FINAL__

---

# Round 4 (kept short)

Round 4 (commit `2ef3ad3`, run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41415511557, passed): long words wrap (`overflow-wrap: anywhere` inside the word, its punctuation inside the button), `Sheet` takes `returnFocus` (the leave sheet gives the cross), a second press of Next line within a double tap is ignored, the browser test helpers wait for the screen to settle and `addEmail` waits for the added state, the road runs against the real `GET /api/road` (job 20 answers visitors with 200 through `road_for_visitors`; a new `real-road` spec), rebased onto `origin/main`. The stop hook complained about `.worktrees/10-speaking-feedback`, which is another job's worktree and not this one. Proof: `evidence/proof-by-breaking-round4.md`.

# Round 3 (kept short)

Round 3 (commit `0347ae4`, run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41348915446, passed): fewer signs on short phones (`fitSigns`, `signGap`, boards nudged inside the screen), a card that stops at 42 percent of the screen and scrolls inside, Keep it and the crash screen say each sentence once. Proof: `evidence/proof-by-breaking-round3.md`.

# Round 2 (kept short)

Round 2 (commit `48ff3c8`, run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41343076151, passed): content starts at least 168 px from the top; `--color-danger-ink`; the mint road to the marker; Finnish rows about 1.4 apart with 44 px hit areas that overlap; the peach ring; one card on Understand it; the download ready title; ink privacy headings; the Keep sentence and the speech country on the privacy page (one read of `GET /api/voice`); hollow progress pieces; a milky finish dock; road bend 48. Proof: `evidence/proof-by-breaking-round2.md`.

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

- **Job 20's route (corrected in round 4).** `GET /api/road` answers a visitor with 200 and all the stops with no progress, through `public.road_for_visitors()`, and a learner through `public.road()`. The road screen reads both (`parseRoad` takes job 20's column names). An earlier version of this note said visitors get a 401. That is out of date: job 20 is merged and the road runs against the real route (see round 4).
- **Word meanings** (`meaning`, `baseMeaning`) are not sent by the Worker yet. Wiring `meaning_en` into the session payload is a later job, so the card still leaves the line out and invents nothing.
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

