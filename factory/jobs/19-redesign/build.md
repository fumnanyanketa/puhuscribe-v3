# Build notes: 19-redesign, round 6

Branch `factory/19-redesign`, pushed to origin. No pull request was opened and nothing was merged. This file is in the worktree. Round 6 answers the owner's request of 2 November 2026, "Let it look exactly like the drawing that we had", through the manager's work list `owner-differences.md` (39 items). The tested commit is `3725570`.

## Round 6: how it was compared

The drawings were taken again from `design-drafts/v1-screens.html` and `road-journey.html` at the phone's width (375 px, the screen only). The drawing's top 32 of 620 px is the phone's own status strip (clock and battery), which a web page never draws, so the pairs cut it off and both pictures start at the top of the web page. Every position below was measured that way. One picture per screen, drawing left and app right at the same width, is in `evidence/round6-pairs/` (32 pairs; app pictures are WebKit, the three recording states are Chromium because this computer's WebKit cannot record on a plain http page).

## Round 6: item by item

Everywhere
1. Done. Progress bars and the road's 12 pieces are solid: pale white with no outline (a faint inner shadow), mint when filled. The card's lesson pieces are pale mint and mint, as drawn. A new contrast pair holds mint at 4.5:1 on the pale piece and 3.7:1 on pale mint.
2. Done. Secondary pills, "Got it", the ä and ö keys and the code boxes have the drawing's very pale edge (mint soft) and a soft shadow. Their words name them; keyboard focus still shows the 3 px ink outline.
3. Done. Fields (email, code boxes, feedback, Keep it) are milky with a soft shadow and no outline. The words are the placeholder ("Your email", "What worked, what didn't, what broke.") and the label stays for screen readers, visually hidden. Focus shows a 2 px mint edge (3.6:1 or more). The placeholder is the quiet text colour, a little darker than the drawing's grey, so it stays readable (4.5:1).
4. Done. Quiet links are small (12.5 px), quiet and underlined in soft mint ("How it works", "Send a new code", "Start as a guest instead", "I don't remember", "I can't speak right now", "Privacy notice"). "Why does it change?", "Patterns you've seen", "More about your voice" and "Read the full notice" are mint with no underline (a new `mint` button style).
5. Done. Screen and sheet titles are medium weight ink on every screen.
6. Done. The cross, the back arrow and the word card's close are a 36 px white round drawn inside a 44 px tap area.
7. Done. "Download my data" is now the title beside the back arrow when the file is ready.
8. Done. The band is the drawing's 280 x 170 shape and starts under the status strip, so its hills sit 26 px higher, clear of the headings.

The road
9. Done. The scene is anchored so the sun's centre sits 204 px from the top on every phone, where the drawing has it at 375 px (it was 292). The fells, flags and sun now match the drawing's places.
10. Done. The sun and its glow are the drawing's (30 and 44 scene units); with the scene in place they now read at the drawn size.
11. Done. `BEND` is the drawn 34. The scene box is 280 x 660 (the drawing's road runs on to 660), so the road runs on behind the card to the screen's edge, at the drawn width.
12. Done. Signs stand at the drawing's five places (t = 0.3, 0.46, 0.59, 0.7, 0.78), in its perspective (the board's size, not a transform, so its box is the size it looks), smaller toward the horizon, never under 12 px. The next and later signs show the name only; later signs are small, milky and quiet. Names stay on one line at normal text sizes; at large text a name wraps rather than run off the screen (statement 20). Where the card needs room (day one's taller card), the places move up only as far as needed, a step apart; where a short phone or large text leaves no room, the road shows fewer signs rather than let two touch. The road also measures once the opening is over.
13. Done. No board may cover the sun, its "A1" or a fell label: the farthest sign stands at least 50 scene units below the horizon, and the road screen counts the sun and the three labels as things no board may touch (it shows fewer signs if one would).
14. Done. A done sign's tick sits in a small white square (25 percent white on mint).
15. Done. The marker is a white dot on a mint disc with a wide pale mint halo ring, also under reduced motion; the slow pulse runs on top where motion is allowed. It stands a little nearer than its sign, as drawn, unless that would bring it to the card.
16. Done. The card is 90 percent white (the road shows faintly through it) and reads "Stop 3 · lesson 2 of 4" with the middle dot on every card. By hand: quiet text over the darkest asphalt through the card is about 5.0:1, ink about 13:1.
17. Done. "Have an account? Sign in" is centred under Start; the guest line and the "Privacy notice" link sit under it, 12 px, quiet and centred.
18. Done. The review count's number is peach. The drawn peach deep is 4.0:1 on peach soft, so it is a new `--color-peach-text` (#a1471f, 5.0:1, in the contrast list).
19. Not changed, as allowed. "Done for today" shows when every ready dialogue is finished and nothing is due; the app knows the next review day, not a next lesson day, so "Next lesson tomorrow" would be untrue. With a next review the line is "Your next review is tomorrow." (or the day); without one, the existing "You have finished every dialogue that is ready."

Lesson screens
20. Done. The tip's three lines are white on a darker scrim (5.1:1 on the wash, checked by axe), each with the drawing's haloed dot or ring; "Got it" is a white pill with a soft shadow and no mint edge. The lit card has the drawing's thin white glow.
21. Done, except the context. The close cross is in a white round; "Why does it change?" and "Patterns you've seen" are mint with no underline; "Plays the whole line." is not drawn (it stays for screen readers and the play buttons' names say "line"). The grey context after the meaning ("as in "those strawberries"") is not shown: the word data has `meaning` and `baseMeaning` only, no context field, and no meaning reaches the card yet (round 1 open point).
22. Done. "Understand" shows at the top right (screen readers still hear "Understand it"); the play button is on the left of the line (it comes first in the reading order too); answer rows are milky, and the right one gets a mint edge, mint text and a mint tick. "Choose what the line means." is for screen readers only.
23. Done. The record button has the drawing's double soft halo and a filled microphone; the hint is "Tap and say the line" (and "Listening"), as drawn; "Line 1 of 3." is for screen readers only.
24. Done in part, by job 10's rules. The gentle peach note sits above the record button, which after a try is named "Try again, record yourself saying the line", so the separate "Try again" pill is gone. "Play mine" stays as a small link (job 10, statement 8: after an attempt the learner can play their recording). "Next line" stays available after a try (job 10, statement 6: "Next line appears after the first attempt at a line, with any result"), so it is not drawn pale.
25. Done. "That was clear." sits at the left with its tick; the wave and the two buttons side by side follow.
26. Done in part, by jobs 8 and 18. The finish screen has no drawn bar and no "Lesson finished" (both stay for screen readers). Kept: the cross, as a link that leaves at once, because job 18 statement 12 keeps "Leave session" working with the note showing; and the written line and both play controls, small, because job 8 statement 14 says the finish line has "spoken, written labelled, both play controls, its English gloss". So the sentence card is centred with no speaker: the spoken line bold with a small play button, the written line in slate with its small play button, then the English. Five small chips, then "+6", which shows the rest and moves focus to the first word it showed. The guest's note is the milky card with "Create account"; its quiet "Not now" stays (job 18). The bottom line is small, quiet and centred under Done. For a guest it stays "Your progress is saved on this device.", because that sentence is protected copy (`save-note-copy.ts`, statement 43); the signed in line is "Your progress is saved to your account.", the drawing's "Saved to your account." in the same shape.
27. Done in part, by job 9's rules. "Type the missing word" is the title at the top; the field is milky; ä and ö are plain white rounds. Kept by job 9 statement 8: the card shows the one register the item asks about (the other register is never sent before an answer, a security rule), its one play control, and its place ("Word 1 of 1.", now small at the card's top right where a line card says "Line 2 of 8").
28. Done in part, by job 9's rules. The title stays and the field keeps what was typed: a right answer gets the mint edge and a mint tick inside it. The answer word is peach in both lines. A close or missed answer is the peach note under the field. Kept by job 9 statement 12: the status words ("Yes, that is right." small and centred above Next, where the drawing has "Right. Same in both."), and both play controls after the answer. The close words became "Close. Check the spelling above." (and "Close. Listen to the word above." for a spoken answer), because the marked word is now above the note; "below" would be untrue. "The word is ..." and "You wrote ..." are for screen readers only; the marked words and the kept field show them to the eye.

Account and other pages
29. Done. An 80 px pale mint avatar with a white ring and a grey letter, overlapping the band. "Speaking feedback" shows "On" with no chevron. The guest's note is the peach bar "Create an account to save your progress." with a plain "Create" (named "Create an account"). "Delete my account" sits at the bottom; signed in it is "Sign out · Delete my account" with Sign out not underlined.
30. Done. The field sits under the title, Send code at the bottom. The two protected warnings stay word for word, 12 px and quiet, under the field. `SENDS_CODE` is protected, so the drawn subtitle "We send you a 6-digit code." is not added (it would say the same thing twice). The Privacy notice link stays small and quiet at the bottom (job 11, statement 16 links it from the email screen).
31. Done. "Sent to alex@example.com" is the subtitle (sign in keeps the protected `SIGN_IN_SENT`, which cannot say "sent to"). Six 40 x 50 boxes; the box of the last digit has the mint edge, as drawn. "Send a new code" is the small link under the boxes; while it waits it is grey and reads "Send a new code in 0:45". "The code works for one hour." stays small under it (statement 35). Confirm is the pale pill until six digits are in. The "Use another email address" pill and the separate wait sentence are gone; the back arrow, named "Use another email address", goes back to the email field.
32. Done. "Welcome back", "Enter your email for a code.", the drawn field, Send code at the bottom and "Start as a guest instead" small and underlined under it. The protected `SENDS_CODE` stays small under the field.
33. Done. Two separate milky cards; "Keep my recordings" has "So I can hear my progress. 90 days." The keep sentence of `voiceNotice()` is protected consent wording, so it shows small and quiet under the cards and is read with the switch. "Your voice settings are shown below." and the speaking hints are for screen readers only. "My recordings" and the milky "Delete my recordings" at the bottom show only when something is kept (statement 36 names the button "Delete my recordings"; it was "Delete all my recordings").
34. Done. Title "Download my data" beside the arrow; "Your file is ready" with no full stop (the status line still says "Your file is ready." to screen readers).
35. Done. Still a page with its address and two steps, drawn as the bottom sheet over the dimmed page with the handle and "Your account" beside the arrow. The delete warning is word for word. At large text the sheet stops under the band and scrolls inside.
36. Done. "Privacy notice" is in the page, large and quiet; section headings are mint, as drawn (round 2 had made them ink); paragraphs are quiet. The voice details sit behind "More about your voice", which opens by itself when "How it works" brings the learner to `#privacy-voice`. "Updated 1 November 2026" is small and centred at the bottom.
37. Done. "What should we know?" is the heading, then the milky box with its placeholder, Send at the bottom; the protected line sits small under the box; the count shows only with 100 or fewer characters left (it is always read with the box).
38. Done. The drawing's soft mint cloud with a peach slash, "Try again" as the full width mint pill, and "Your progress is safe. Try again when you're online." on the road and account screens. Inside a lesson it still says only "Check your internet connection, then try again." (statement 41).
39. No change needed (the crash screen matched, apart from the approved missing line).

## Round 6: earlier tests changed, and why

All follow a look or a wording the owner's list changed on purpose. No test that protects text, focus, contrast or behaviour was weakened; where a sentence is now for screen readers only, the test checks it is in the page and not drawn, and checks what is drawn instead.

- `tests/design-tokens.test.ts`: the spoken and written role lists lose `RecordControl.module.css` and `FirstLessonTip.module.css`, which no longer use those tokens (the tip has its own drawn dot colours), and the written list gains `Screens.module.css` for the finish screen's written line. The lists stay exact.
- `src/styles/contrast-pairs.ts` and `design.md`: six pairs added (peach text on its washes, the "+6" chip, mint on the pale and the pale mint piece); the one pair that named "a progress piece not reached" now names a white control's edge, with the same colours and floor.
- `src/lib/road-state.test.ts`, `e2e/redesign-road.spec.ts`, `e2e/real-road.spec.ts`: "Stop 3 · lesson 3 of 4"; the progress piece test checks a solid pale piece with no outline.
- `e2e/redesign-lesson.spec.ts`: the band is the drawing's shape (bottom on screen 175 to 220 px, was "200 to 220 px high"); the finish screen's bar is not drawn (its cross still leaves at once); the hint has no full stop; "Plays the whole line." is not drawn; the email account's line.
- `e2e/redesign-pages.spec.ts`: the content of a page may start from 110 px (was 160), where the drawings put it, and still never on the band's pines, flags or sun; a visually hidden heading is not counted as drawn text; account, download, sign in, privacy (mint headings), feedback (count) and offline wording.
- `e2e/account-pages.spec.ts` ([accounts 16]) opens "More about your voice" before reading the voice details; `e2e/analytics-feedback.spec.ts` finds Send by its name (it now sits at the bottom and submits the form by id); `e2e/speaking-feedback.spec.ts` checks "My recordings" is gone when nothing is kept (was "You have no kept recordings.").
- `e2e/accounts.spec.ts`, `e2e/account-pages.spec.ts`, `e2e/account-helpers.ts`, `e2e/save-progress-helpers.ts`, `e2e/analytics-feedback.spec.ts`, `e2e/daily-review.spec.ts`, `e2e/first-session.spec.ts` (database tests, run on GitHub): the new words above; "Session finished" and "Plays the whole line." are attached, not drawn; "You wrote" is attached and the kept field is drawn; "Close. Check the spelling above."; "Sent to" and the countdown; "Welcome back".

New tests: 7 in `e2e/redesign-lesson.spec.ts` ("round 6, as drawn": the tip, Understand it, the finish screen, Keep it right and close, Say it try again) and 6 in `e2e/redesign-pages.spec.ts` (create account field, the code screen's countdown and back arrow, sign in, voice cards, privacy disclosure, account rows). In this round the code was changed before these tests were written, so they were not seen red against the round 5 code; each checks a look or wording that round 5 did not have (round 5's code fails them by construction, for example no "+6" chip, no countdown, no "Understand" label).

## Round 6: check results

- On this computer: `tsc -b`, ESLint and Prettier on `src`, `e2e`, `tests` and `design.md` pass; `npx vitest run src tests` passes (636 tests). The pre-commit hook passed (format, type check, lint, gitleaks).
- Browser tests against the mock dev server: `redesign-road`, `redesign-lesson`, `redesign-pages` and `design-reference` pass in Chromium. In WebKit the three redesign files pass except two Say it tests that need a recorder this Windows WebKit lacks (as in round 5), and the new recording test skips there on purpose. `front-door [smoke 1]` counts stylesheet requests, which the dev server does not make; it runs on the built app on GitHub.
- Not run locally (the manager asked for only the affected files): the database backed browser files; they run on GitHub.
- First full run on GitHub, commit `cbb1e90`: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41447820421 failed in the browser job (everything else passed). Causes, all mine: the finish screen had lost its play controls and its "Leave session" cross, which jobs 8 and 18 require (fixed by keeping them, item 26); the real road showed three signs on day one, because the squeezed places pushed the farthest sign onto the sun (fixed in `signSpots`, item 12); and four tests still read the old look (privacy voice details, Send's place, "no kept recordings", a WebKit timing in the privacy colour test).
- Second run, commit `4e553aa`: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41452816392 failed on three things, all mine: the design token test's exact list of files that use the written colour did not have `Screens.module.css` (the finish screen's written line, now listed on purpose); the feedback test looked for Send by its name, which changes while it is busy (it now finds the submit button by its form); and the finish screen's save note ended 0.1 px below the screen (`[save-progress 14]`).
- Third run, commit `36f5df8`: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41455907837 passed everything but `[save-progress 14]` in Chromium (736 browser tests passed): the test scrolls the note into view and it stopped flush with the edge of the scrolling area, cut by 0.1 px. The note now has a 16 px scroll margin, so it stops clear of the edge.
- Fourth full run, commit `3725570`: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41459033855, success. Browser tests (Chromium and WebKit, local database), pgTAP, unit tests, Python, dependency check, secret scan and code check all passed.

## Round 6: open points

- Pairs are WebKit except the three recording states (Chromium). The 375 x 667 and 320 x 640 evidence pictures and the Chromium app pictures not touched while working were not retaken this round (the manager asked for WebKit only); some Chromium app pictures were retaken while working and show the round 6 look.
- The word card's "as in ..." context needs a data field that does not exist.
- The finish screen's milky Done dock (round 2) stays; the drawing has none, but the list did not ask, and a test protects it.

Result: checks pass

---

# Round 5 (kept short)

Round 5 (commit `53428b9`, run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41424781086, passed): a tall tappable word keeps its text on the line and starts at the left (padding inside the word button, `text-align: start`), and every sheet gives focus back to its opener after a Safari style tap (Voice settings switch, Say it's quiet button, the word). Proof: `evidence/proof-by-breaking-round5.md`. In round 4 a retake deleted the evaluator's `eval-*` files; they were restored, and retakes now only overwrite numbered files.

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

