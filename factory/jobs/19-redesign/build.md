# Build notes: 19-redesign, round 1

Branch `factory/19-redesign` (from main `7f4f4b7`), pushed to origin. No pull request was opened and nothing was merged. The worktree is `.worktrees/19-redesign`. The tested commit is `07f7daa`.

## What I built, in plain English

Every screen a learner sees now has the look the owner approved on 1 November 2026. The drawings in `design-drafts/` were the source of truth.

- **The road is the home screen.** It replaces the front door. It draws the sky, the A1 sun, three fells (A2, B1, B2), a pine ridge and a winding road, with five stop signs and a "you" marker. A milky card at the bottom changes by state: day one, start or continue, review, stop finished, done for today, and the existing messages. The top holds a 12 piece progress bar and the account button.
- **The opening animation** plays only when the device has no account. It takes 4.5 seconds, has a "Skip" button first in the tab order, and becomes a short crossfade for people who asked for reduced motion.
- **The lesson screens** (Hear it, Understand it, Say it, Keep it, Lesson finished) share one frame: the landscape band, a cross that opens "Leave this lesson?", a progress bar and the step name. Hear it shows one line card at a time. A first lesson shows a short tip once. The word card is a bottom sheet with two tiles ("People say", "Books write"), the dictionary form and "Why does it change?" behind one more tap.
- **Say it** has the consent as a bottom sheet ("Say it out loud", "How it works", "Turn on", "Not now"), a large record button, a peach recording state, a clear result card and a gentle "try again" note.
- **Lesson finished** shows the tick, the sentence, the line card, a panel "N new words" with the words as tappable chips, the save note (owner's new words, centred) and "Done".
- **Account, email, sign in, voice settings, download, delete, privacy and feedback** are redrawn. The account page is a profile page. Voice settings uses two real switches. The privacy notice has a short first layer and "Read the full notice".
- **Offline and crash screens** are redrawn ("No connection", "Something went wrong").
- **Design records.** `design.md` is rewritten for the new look, with generated colour and contrast tables. `/design-reference` shows every new part in each state. `docs/conventions.md` has the `[redesign N]` row. `docs/data-model.md` says no database object was added.
- **Worker additions, no database change.** `/api/today` gives `reviewCount` on a review only day. The session answer gives `firstLesson` (read from the learner's own session rows that the pick already reads). The complete answer gives `newWords` (cards created at the session's end). Each read is the caller's own rows, and a failing read never breaks saving.
- **Stops come from job 20.** The road reads stops only through `loadRoad()` in `src/lib/road-data.ts`, which calls `GET /api/road`. Until job 20 merges, tests and `/design-reference` use a fixture of 36 real English stop names. A build test proves the fixture is not in a normal build.

Nothing was added to `package.json`, `wrangler.jsonc`, `supabase/`, `worker/providers/`, `worker/personal-data/` or `scripts/generate/`. The proof is `evidence/44-no-new-dependencies.txt` (the command printed nothing).

## Owner's answers of 1 November 2026, and how I followed them

| Answer | Done |
| --- | --- |
| Peach as drawn | Peach marks, the gentle note, the save note, the delete pill and the next sign use peach. |
| Keep every contrast floor | Six drawn colours were darkened, shown beside the drawn ones below. |
| Poppins everywhere | Switzer is gone from the app. Fonts load from the app's own address. |
| Light only | No dark block. `index.html` declares `color-scheme: light`. |
| Flat buttons | Mint pill, white pill with a mint edge, underlined quiet text, deep peach danger pill. |
| Hear it one line at a time | One card, "Next line", then "Continue". |
| Review card shows count and minutes | "Review", the number, "About N minutes", "Start review". |
| Lesson finished: "N new words" chips, no "lines said aloud" box | Option C of `numbers-question.html`. |
| Signed in learners see no save note | The note hangs only on the answer that asks for it, which is for guests. |
| No daily limit; Stop finished keeps Continue; "Done for today" only when nothing is left | As drawn, with the state rules in `src/lib/road-state.ts`. |
| Guest line kept small | Small text under the day one card, with "Privacy notice". |
| Consent sheet as drawn, "How it works" opens the privacy page voice section | Opens `/privacy#privacy-voice` in a new tab. |
| Privacy controller stays the owner as a person | The first layer says only "part of the product family of Exentrik" in the owner's sentence; the full notice is unchanged. |
| Progress bar of 12 pieces, one per 3 stops | `progressSegments` in `src/lib/road-state.ts`. |
| B2 label "B2" only | No YKI. |
| Brand mark mint | `--color-brand`. |
| Word meanings come from job 20 | `meaning` and `baseMeaning` are optional fields read by the card. The Worker does not send them yet. |
| Save note "Create an account to save your progress." with "Create account", centred; email screen titled "Create your account" | In `src/screens/save-note-copy.ts` and `EmailFlow.tsx`. Job 18's copy test changed as an owner's change (listed below). |

## Colours changed from the drawings

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

## Which test protects which "done when" statement

Every test name carries `[redesign N]`. Files are under `e2e/` (browser), `src/` and `worker/` (unit) and `tests/` (repository).

| Statements | Protected by |
| --- | --- |
| 1 colours replaced | `tests/design-tokens.test.ts` (removed names and values, hex tokens, light only), `tests/design-rules.test.ts` |
| 2 role colours | `tests/design-tokens.test.ts` (files that may use each role token), `e2e/redesign-lesson.spec.ts` (spoken, written and changed colours on a rendered line) |
| 3 wash, grain, panels | `tests/design-tokens.test.ts`, `tests/design-css.test.ts` (name only changed), `e2e/design-reference.spec.ts` (wash declared once) |
| 4 landscape | `e2e/redesign-lesson.spec.ts` (inline drawing, hidden from screen readers, no image, about 210 px) |
| 5 type scale | `tests/design-tokens.test.ts` (floors, scale table, no component font size), `tests/design-rules.test.ts`, `e2e/design-reference.spec.ts` (Poppins and ä ö å) |
| 6 contrast | `tests/design-tokens.test.ts` (every pair, and `design.md` lists the same pairs) |
| 7 buttons | `e2e/design-reference.spec.ts` (44 px, busy state, focus outline), `e2e/design-sample.spec.ts` |
| 8 records, reference page | `e2e/design-reference.spec.ts` (every token, pairing and part) |
| 9 design tests change only on purpose | Listed below. No test was removed or weakened. |
| 10 road is home | `e2e/redesign-road.spec.ts`, `e2e/front-door.spec.ts`, `e2e/health.spec.ts` |
| 11 loading | `e2e/redesign-road.spec.ts` |
| 12, 13, 14 scene, signs, top | `e2e/redesign-road.spec.ts`, `src/lib/road-state.test.ts`, `src/road/home-view.test.ts`, `tests/redesign-rules.test.ts` |
| 15 card by state | `e2e/redesign-road.spec.ts`, `src/road/home-view.test.ts`, `src/lib/review-day.test.ts`, `worker/review.test.ts`, `e2e/daily-review.spec.ts` |
| 16 loading creates nothing | `e2e/redesign-road.spec.ts` (zero `/api/guest` before Start) and job 8's `[session 1]` |
| 17, 18 animation | `e2e/redesign-road.spec.ts` (`document.getAnimations()`: 4.0 to 5.0 s, Skip under 300 ms, reduced motion opacity only, none for a signed in learner but the pulse), `src/lib/road-data.test.ts` |
| 19 interface with job 20 | `src/lib/road-data.test.ts`, `tests/redesign-rules.test.ts`, `tests/design-build.test.ts` (fixture marker not in a build) |
| 20 small phone | `e2e/redesign-road.spec.ts` (card never covers the current sign or marker, 320 px, 200 percent) |
| 21 frame | `e2e/redesign-lesson.spec.ts` |
| 22 leave sheet | `e2e/redesign-lesson.spec.ts`, `e2e/first-session.spec.ts` (`[session 18]`), `e2e/speaking-feedback.spec.ts` |
| 23, 24 line card, Hear it | `e2e/redesign-lesson.spec.ts`, `e2e/first-session.spec.ts`, `e2e/design-reference.spec.ts` |
| 25 first lesson tip | `e2e/redesign-lesson.spec.ts`, `worker/lesson-facts.test.ts` |
| 26, 27 word card, meanings | `e2e/redesign-lesson.spec.ts` (with both meanings, with none), `src/components/patterns-panel.test.ts` |
| 28 Understand it | `e2e/redesign-lesson.spec.ts`, `e2e/first-session.spec.ts` |
| 29 consent sheet | `e2e/redesign-lesson.spec.ts`, `e2e/redesign-pages.spec.ts`, `e2e/speaking-feedback.spec.ts`, `src/screens/protected-copy.test.ts` (text and version label unchanged) |
| 30 Say it | `e2e/redesign-lesson.spec.ts`, `e2e/speaking-feedback.spec.ts`, `e2e/spoken-review.spec.ts` |
| 31 Keep it | `e2e/daily-review.spec.ts`, `e2e/spoken-review.spec.ts` (behaviour on the redrawn screen, in both browsers on GitHub) |
| 32 Use it with Otso | **Out of scope.** Job 16 is held and has not merged, so there is nothing to restyle. |
| 33 Lesson finished | `e2e/redesign-lesson.spec.ts`, `src/screens/new-words.test.ts`, `worker/lesson-facts.test.ts`, `e2e/save-progress.spec.ts` |
| 34 to 40 account pages | `e2e/redesign-pages.spec.ts`, `e2e/accounts.spec.ts`, `src/screens/protected-copy.test.ts`, `src/privacy/first-layer.test.ts` |
| 41 errors | `e2e/redesign-pages.spec.ts`, `src/components/crash-boundary.test.ts` |
| 42 three status styles | `e2e/design-reference.spec.ts` |
| 43 existing behaviour | The whole earlier suite on GitHub, with the changes listed below |
| 44 nothing new sent, stored or installed | `e2e/redesign-road.spec.ts`, `tests/redesign-rules.test.ts`, `evidence/44-no-new-dependencies.txt` |
| 45 paths | `tests/redesign-rules.test.ts` |
| 46, 47 phone, keyboard, screen reader | `e2e/redesign-road.spec.ts`, `e2e/redesign-lesson.spec.ts`, `e2e/redesign-pages.spec.ts` (each screen: no sideways scroll, 44 px, one `h1`, axe) |
| 48 evidence | `e2e/redesign-evidence.spec.ts` and the files in `evidence/` |
| 49 records | `docs/conventions.md`, `design.md`, `docs/data-model.md`, this file |
| 50 owner approval | Not mine. `summary.md` records it. |

## Proof by breaking each protection

`evidence/proof-by-breaking.md` lists 18 deliberate breaks. Each one was applied in the working copy, its test was run, it went red for the intended reason, and the break was undone. They cover: a removed colour token coming back, a role colour used outside its files, a second gradient, a component font size, a too pale quiet text, a quoted app path, the fixture imported by a screen, storage on the phone, the consent text changed without its version label, the softened delete warning, the old privacy claim, every session counting as the first lesson, a new word chip loading audio from another address, the microphone asked for before consent, deleting before the second press, the tip on every lesson, a guest made on loading the road, and the cross leaving without the sheet. The browser breaks ran against the app with the test mocks (Chromium), the others with vitest. Nothing was committed from a break, so there are no `scratch/19-redesign-red-*` branches. The two scratch branches used to find failing tests faster, `scratch/19-redesign-triage` and `scratch/19-redesign-diag`, are deleted.

## Earlier tests I changed, and why

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

## Departures from the drawings

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

## Open points

- **Job 20's route answers 401 for visitors.** Its `GET /api/road` needs a signed in learner (columns `stop_number`, `title_en`, `can_do_en`, `part_number`, `lessons_total`, `lessons_done`). The day one road is shown to people with no account, so it needs a form of the route that answers visitors with zero progress. `parseRoad` already accepts both the interface shape and job 20's column names, as a list or `{ stops }`. Job 20 or the manager needs to decide; the swap on my side is `loadRoad()` only.
- **Word meanings** (`meaning`, `baseMeaning`) are not sent by the Worker yet. Job 20 adds the data. With none, the card leaves the line out and invents nothing.
- **The consent text is not shown in full any more.** The four paragraphs of `src/lib/voice-consent.ts` stay frozen word for word with their version label (tested), but the learner now sees the privacy page voice section instead, which says the same facts in the privacy notice's words. The owner may want the privacy page to hold the consent paragraphs word for word.
- **Privacy "Updated" date** is `NOTICE_UPDATED` in `src/privacy/notice-settings.ts`, set to 2026-11-01.
- **Sign in page heading** is unchanged ("Sign in with your email").
- **Keep it, Use it with Otso, "Something went wrong"** have no app screenshots in the evidence. Keep it runs for real in the database tests on GitHub; Otso is out of scope; the crash screen is covered by a unit test. The three Say it recording states (listening, clear, try again) are Chromium screenshots only, because the local WebKit build cannot record on a plain http page. Both browsers run them on GitHub.
- **Options A and B** of `numbers-question.html` were not built (owner chose C).
- **Unit test `tooling 9`** (gitleaks timing) timed out twice on this computer under the load of the whole suite and passes alone and on GitHub.
- **Banned list check.** No eyebrows, no accent borders, no pills scattered, no gradient text, no emoji. Peach is wider than the old rule (owner's answer 1).

## Check results

Commands run in the worktree:

- `npm run check:code` (type check, lint, format check): passes. The format check warns about `design-drafts/` line endings on this Windows copy only; GitHub's check passes.
- `npx vitest run`: 90 files, 1159 tests. All pass except `tooling 9` under load (see above).
- `npx playwright test e2e/redesign-road.spec.ts e2e/redesign-lesson.spec.ts e2e/redesign-pages.spec.ts --project=chromium` against the dev server with the test mocks: all pass.
- `gh workflow run checks.yml --ref factory/19-redesign`, run **https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41333172662**, tested commit `07f7daa`: success. The browser job at 375 x 812 in Chromium and WebKit with the local database passed 592 tests; its 85 skipped tests are the evidence script (made on purpose) and the tests that run only against the test project or a preview link. The database job (pgTAP, 936 tests), unit tests, Python, dependency check, secret scan and the code check all passed.
- Earlier runs on the way: 41316883503 (cancelled at the job limit while many earlier specs failed slowly), then runs 41322610905, 41324767686, 41327239201, 41329108105 and 41331079921, each of which found earlier specs still to update. Each was fixed in the commit after it. Two scratch triage branches (shorter timeouts) were used for the first two and are deleted.
- Evidence: `evidence/` holds 28 screens, each in both browsers (three in Chromium only) beside the drawing, `44-no-new-dependencies.txt` and `proof-by-breaking.md`. No file holds a secret (made from mocks and made up text).

## How to run it locally

1. `npm ci`. Create `.env.local` the usual way (never print it).
2. Without Docker, run the screens against the mocks: `npx vite --port 5199 --host 127.0.0.1`, then `PLAYWRIGHT_BASE_URL=http://127.0.0.1:5199 npx playwright test e2e/redesign-road.spec.ts e2e/redesign-lesson.spec.ts e2e/redesign-pages.spec.ts --project=chromium`. Open `http://127.0.0.1:5199/design-reference` (with `VITE_DESIGN_REFERENCE=1`) to see every part in each state.
3. With Docker and the throwaway Supabase, load the seeds, run `VITE_DESIGN_REFERENCE=1 npm run build` and `npx playwright test`.
4. Evidence: `PUHUSCRIBE_EVIDENCE=1 PLAYWRIGHT_BASE_URL=http://127.0.0.1:5199 npx playwright test e2e/redesign-evidence.spec.ts`.
5. Real stops: `GET /api/road` must answer from job 20. Set `PUHUSCRIBE_REAL_ROAD=1` to make the browser tests use it instead of the fixture.

## Unfinished or uncertain

- Job 20's route and the word meanings are not mine to finish (see open points).
- Statement 50, the owner's approval, is not mine.
- No scratch branch of this job is left on origin.

Result: checks pass
