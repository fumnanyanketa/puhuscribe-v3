# Design review: 8-first-session

Reviewer: design and learner experience. 21 October 2026. Branch `factory/8-first-session`, head `679d21c`.

## How I checked

- Read the spec with the manager addendum, `build.md`, `design.md`, `src/styles/tokens.css`, the diff, and every new screen and component.
- Looked at the builder's twelve screenshots in `evidence/local-screens/` (light and dark, 375 px).
- Built the app (`npm run build`) and rendered it myself in Chromium at 375 px, light and dark, with the Worker answers faked in the browser (no database here). My extra screens: front door when the session ended, not ready, all done, continue, and Start failing; the session page when not ready and when loading fails; Hear it on the last line; Understand it after a wrong answer at 375 x 667 and at 200 percent text; the finish screen when saving fails; the word card. Screens are in the scratchpad `shots/` folder (not committed).
- I did not download the PR 18 artifacts. The browser tests need a database, so the screens above stand in.

## What is in good shape

- One front door, no mode picker, no streaks, scores, confetti, badges or counts anywhere. Nothing from the "Not in v3.0" list is built. The English answer choices are not a language toggle.
- Spoken Finnish comes first on the teal band, written Finnish under it labelled "Written", both `lang="fi"`, both with audio. Grammar shows only inside the word card behind a tap.
- Wrong answer wording is gentle ("Not this one. Listen again and try another."), in the lavender gentle style, with a dashed muted row, no red, no cross, no count. The right answer has a tick and a heavier edge, so colour is not the only sign.
- Every colour comes from tokens. Dark mode reads well. No banned fonts, no accent bars, no eyebrows, no gradients beyond the page fade, no icon sprinkles (the one tick sits inside a control).
- Tap targets: answer rows are 54 px tall, play controls 44 px, words 44 px tall. The browser tests check this at 320 px, 200 percent text, with a keyboard-only run and axe in both modes.
- Text follows the writing rules. I found no em dashes, no hyphens as punctuation, no colon reveals, no hype words, no groups of three in app text.
- Test labels are `[session N]` throughout. No TODO or placeholder in `src`, `worker`, `e2e` or `tests`. The old Hei! and `visits` tests were removed or moved with labels kept; see finding 8 for gaps.
- The Say it slot is clean: one list in `src/screens/session-steps.ts`, a unit test for a step added after Understand it, and a top bar that reads "step 2 of 2" with no dead end.

## Findings

### Must fix

1. **A question mark or comma can wrap onto a line of its own.** `src/components/FinnishLine.tsx` lines 52 to 76 (`{word.after}` sits outside the word button) and `FinnishLine.module.css` (`.spokenLine`, `.writtenLine`). On a spoken line such as "Ootsä täält Helsingist?" the "?" dropped alone onto a second line inside the teal band (reproduced at 375 px, light and dark). Real lines are mostly questions and commas, so learners will see this often, and it looks broken to someone learning where punctuation belongs. Fix: wrap each word button and its `after` text in one `white-space: nowrap` span so punctuation stays with its word, and add a browser check with a long question line at 375 and 320 px.

### Should fix

2. **Understand it hides the answers on a short phone, especially after a wrong answer.** `src/screens/UnderstandIt.tsx` lines 94 to 120 with `Screens.module.css` `.question`. The line card is about 290 px tall. At 375 x 667 (iPhone SE size) the screen shows the title, the card and "What does this mean?", and no answer row at all. After a wrong answer the action area grows to two lines and covers more. At 375 x 812 only two of three rows show, and the right answer is half hidden in the screenshot `5-understand-right-light.png`. Nothing says the learner must scroll. Fix: keep the choices in view, for example scroll the answer list into view when the step opens and after a wrong answer, or drop the line card's extra spacing and hint text on this step, or put the choices directly under the Finnish line with the controls beside it. Add a screenshot test at 375 x 667.
3. **The word card's play buttons play a whole line, but sit under one word.** `src/screens/LineCard.tsx` lines 27 to 36 and `src/components/WordCard.tsx` (the Spoken and Written rows). The card shows "Moi" and "Hei" with a play button beside each, so a learner expects to hear that one word and gets the whole line (Decision 6). The accessible name says "line", the screen does not. Fix: one plain caption in the card in session screens, such as "Plays the whole line.", passed in through the same optional prop that already renames the controls.
4. **Empty and finished messages are stranded at the bottom of the front door.** `FrontDoor.tsx` lines 94 to 112 and `FrontDoor.module.css` `.actions`. For "not ready yet" and "finished every dialogue" the only message is small quiet text pushed to the bottom of a mostly blank screen, far from the heading, and there is no button. A learner can easily miss it and think the app is stuck. Fix: show these two messages directly under the heading in place of the "A session is one short dialogue" sentence, in the normal body size.
5. **The session page "not ready" screen sends the learner in a circle.** `SessionPage.tsx` lines 98 to 119. It has no frame and a black primary "Back to the start" that leads to the front door, which for "not ready" and "all done" has no button. Fix: for those two states drop the button (the front door is the same message), keep "Try again" only for load failures, and keep "Back to the start" as a secondary or quiet button.
6. **Returning learners see no button and no message while the front door loads.** `FrontDoor.tsx` line 79 to 112. Until `GET /api/today` answers (up to 10 seconds on a weak connection) nothing is shown below the intro. Fix: show a neutral status line "Loading today's session." (as the session page does) or a disabled Start while waiting.
7. **The new component and the frame changes are not in the design system.** `src/components/AnswerChoices.tsx` and `.module.css`, `SessionFrame.tsx` (`steps`, `finished`, the "Session finished" label). `design.md` was not changed and the reference page (`src/design-reference/`) does not show answer rows, although `design.md` says the reference page shows every component in every state and the spec said the design reviewer checks the new component against `design.md`. Fix: add an "Answer choices" section to `design.md` (ready, tried and not right, right, focus, with the text and dashed edge or tick rules) and a section on the reference page with each state in light and dark. Describe the `steps` and `finished` options in the "Session frame" section. Add the two states' contrast pairs (quiet text on the page, text colour edge on the surface) to `src/styles/contrast-pairs.ts` and `design.md`.
8. **Moved protections left a few gaps.** Removed test files: `e2e/visits.spec.ts`, `worker/visits.test.ts`, `supabase/tests/database/visits_access.test.sql`. `build.md` lists them honestly. Still missing on the new screens:
   - `[smoke 6]` "never sends the key, the project address or upstream text back" (old `worker/visits.test.ts` line 227) has no equivalent for `/api/guest` or the session routes when Supabase fails. `worker/guest.test.ts` line 109 checks status and cookies only. The old `[smoke 5]` (nothing sent from the visitor) is partly covered by `worker/logs.test.ts` but not for what the Worker sends upstream. Add a test with a failing fake Supabase that returns text containing the key and project address, and assert the answer body holds neither.
   - The old `[smoke 3]` keyboard test (Tab to "Try again", Enter, focus lands on the status line) and "status line is announced and shows the saving text first" have no front door or finish screen equivalent, although `FinishScreen.tsx` line 56 and `SessionPage.tsx` line 71 rely on the same focus move. Add one keyboard test for finish "Try again".
9. **Hear it does not say how many lines there are.** `HearIt.tsx` lines 52 to 69. A beginner pressing "Next line" cannot tell how many remain, and the new line is added below the fold without any announcement to a screen reader (no live region). Fix: add a plain "Line 2 of 5." in the status line next to the help text, and make it announce. This is a count of lines, not a score.
10. **The can-do sentence has no label.** `FrontDoor.tsx` line 92 and `HearIt.tsx` line 58. "I can say who I am and where I am from." appears as an unexplained second paragraph. Fix: give it a short plain lead in, such as "By the end of this session:" shown as its own sentence ("By the end of this session, you can say who you are and where you are from."), so the learner knows why it is there. Use the same wording on both screens.

### Notes

11. The finish screen says "Now you can say this." and "The words you met will come back in your review.", but until jobs 10 and 9 land the learner cannot say anything back and no review exists. The spec asks for this wording, so it is fine for now. Check the wording again when job 10 adds Say it, and make sure the line is the one the learner then records.
12. "Blue words change between spoken and written Finnish." names a colour. The changed words are also bold, so colour is not the only sign, but the sentence does not mention that. Acceptable (design.md fixes this wording). Consider "Bold blue words" if a learner with colour blindness is a concern.
13. A signed out visitor on an empty content database is asked to start a guest account and is then told nothing is ready (statement 6 behaves as written). Harmless in tests; before launch, the empty state should be shown before any account is made.
14. Front door heading stays "Today's session" after every dialogue is finished. Wording is spec fixed; consider "No session today" when job 13 does onboarding.
15. Fixture text ("Fixture form name", "Test fixture dialogue 1") shows only in local screenshots. The repository tests keep it out of the build. Nothing to change.

## Result

Result: changes needed
