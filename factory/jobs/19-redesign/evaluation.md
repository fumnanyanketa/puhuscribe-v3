# Evaluation: 19-redesign

Evaluated 2 November 2026 on branch `factory/19-redesign`, tip `8013e5a` (the code is the same as `0347ae4`; only files under `factory/` changed since). I tested the built app (`npm run build`, then `vite preview` over HTTPS) at 375 x 812 in Chromium and WebKit on this Windows machine, using the builder's own request mocks for the road, lesson and account pages, because there is no Docker here. My scripts are in the evidence folder as text (`eval-script-evaluator.spec.txt`, `eval-script-animation-and-focus.spec.txt`, `eval-script-text-size-and-long-word.spec.txt`); what each step saw is in `eval-observations-chromium.jsonl` and `eval-observations-webkit.jsonl`. Database and full browser tests ran on GitHub (`eval-ci-run.txt`). Protections were broken on purpose in a throwaway copy, never in the worktree (`eval-break-proofs.txt`). I read `build.md` only after my own testing. No `.env*` file was read, no trace or HAR file was kept.

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `eval-break-proofs.txt`, `eval-checks.txt` | An old token name (`--color-flag-wash`) or old violet value put back in a CSS file turns `[redesign 1]` red; Vitest 1166 passed. |
| 2 | pass | `eval-break-proofs.txt`, `eval-23-24-hear-it-webkit.png` | Using the written (slate) token in the road card turns `[redesign 2]` red; on screen the spoken dot is mint, the written line slate, changed words peach on their wash. |
| 3 | pass | `eval-break-proofs.txt` | A gradient or `backdrop-filter` added to the road card turns `[design 18]` red. |
| 4 | pass | `eval-23-24-hear-it-chromium.png`, `eval-34-account-guest-webkit.png` | The band sits behind every lesson and page top; inline SVG, no image request in either browser. |
| 5 | fail | `eval-5-46-text-size-webkit.json`, `eval-46-forty-letter-1-webkit.png` | Smallest visible text is 12 px on the road, Hear it, the tip and the word card; but long compound words do not wrap (see statement 46). |
| 6 | pass | `eval-checks.txt`, `eval-observations-webkit.jsonl` | Contrast unit tests pass; axe found nothing on every road card state, the finish screen, account and privacy pages I ran. |
| 7 | pass | `eval-38-delete-webkit.png`, `eval-observations-chromium.jsonl` | Mint pill with the arrow circle, white pill with a mint edge, danger pill white on #b8532f (about 4.9 to 1 by my calculation); every control I measured was 44 px or more; `[design 8] [redesign 7]` passed on GitHub in both browsers. |
| 8 | pass | `eval-ci-run.txt` | `/design-reference` is not in a normal build so I could not open it locally; its browser tests passed on GitHub in both attempts. |
| 9 | pass | `eval-break-proofs.txt` | Every "catches" probe I tried still turns red; the changed design tests are the expected list in `build.md`. |
| 10 | pass | `eval-10-road-day-one-webkit.png` | One `h1` "Your road to A1", none of the old front door strings, axe clean. |
| 11 | pass | `eval-11-opening-webkit.png` | Sprout mark, dots and "Loading your road." while the road is held back 1.2 s. |
| 12 | pass | `eval-13-road-continue-webkit.png` | Sun with A1, fells A2, B1 and B2 (no YKI), mint travelled line up to the marker. Road bend: see the note below. |
| 13 | pass | `eval-13-markup-and-long-name-320-webkit.png`, `eval-observations-webkit.jsonl` | Five signs read "Stop 3, At the grocery store, current"; tapping every sign changes nothing and sends nothing; an `<img onerror>` and a `<script>` in stop data showed as text and did not run. |
| 14 | pass | `eval-observations-chromium.jsonl` | 12 piece bar, 44 x 44 "Your account" with "E" for an email learner, "G" for a guest, one `GET /api/me`, none for a visitor. |
| 15 | pass | `eval-15-review-webkit.png`, `eval-15-done-webkit.png`, `eval-15-stop-finished-webkit.png`, `eval-15-ended-webkit.png` | Every card state in its words; review shows count and minutes and stop finished has Continue (owner's answers 7 and 8). |
| 16 | pass | `eval-observations-chromium.jsonl` | Zero `/api/guest` calls on load; a double tap on Start made exactly one. |
| 17 | pass | `eval-17-18-animation-webkit.json`, `eval-17-animation-mid-webkit.png`, `eval-17-after-skip-webkit.png` | Skip is first in tab order; Start is hidden and cannot be tapped until about 3.8 s (a tap there at 1 s made no account); storage empty; it plays again on reload. |
| 18 | pass | `eval-17-18-animation-chromium.json`, `eval-observations-webkit.jsonl` | Longest animation ends at 4500 ms; Skip ends all within 52 to 87 ms; reduced motion is opacity only, 600 ms; a signed in learner has only the pulse. |
| 19 | pass | `eval-19-build-search.txt`, `eval-break-proofs.txt` | No fixture marker or fixture stop names in `dist/`; importing the fixture in the road screen turns `[redesign 19]` red. |
| 20 | pass | `eval-20-375x667-continue-webkit.png`, `eval-20-320x640-200-continue-webkit.png` | Card top below the marker and current sign in every state; no sideways scroll at 320 px and 200 percent text. |
| 21 | pass | `eval-23-24-hear-it-webkit.png` | 44 px cross, bar named "Hear it, step 1 of 3", fills 11 to 33 percent as lines show, "Hear it" is the one `h1`. |
| 22 | fail | `eval-22-focus-return-webkit.json`, `eval-22-leave-sheet-webkit.png` | In WebKit, after tapping the cross, "Keep going" or Escape leaves focus on the page body, not the cross. Chromium and the keyboard path are right. |
| 23 | pass | `eval-23-24-hear-it-webkit.png` | Speaker, "Line 1 of 3", dots, no labels, gloss under a dashed line, "Playing" in words, a name is plain text. |
| 24 | pass | `eval-observations-chromium.jsonl` | One card at a time, status "Line 1 of 3.", no audio before a press. |
| 25 | pass | `eval-25-tip-webkit.png` | Three lines and "Got it", focus in and back to "Next line", shows again after a reload. |
| 26 | pass | `eval-26-word-card-webkit.png` | Word, meaning, both tiles with play buttons, "Plays the whole line.", dictionary form, "Why does it change?", "Patterns you've seen"; Escape returns focus to the word. |
| 27 | pass | `eval-27-word-card-no-meaning-webkit.png` | Without data the meaning lines are left out; nothing invented. |
| 28 | pass | `eval-28-understand-it-webkit.png` | Existing question, one card, one play button, three rows. |
| 29 | pass | `eval-29-consent-sheet-webkit.png`, `eval-observations-chromium.jsonl` | Title, "How it works", "Turn on", "Not now", no box, zero microphone calls; a double tap on Turn on sent one choice with keep off. |
| 30 | pass | `eval-30-say-it-chromium.png`, `eval-30-say-it-recording-chromium.png`, `eval-ci-run.txt` | Record button 88 px, "Tap and say the line.", then "Listening." and "Stop". This WebKit build cannot record, so WebKit states rest on GitHub, where they passed. |
| 31 | pass | `eval-31-keep-it-close-webkit.png` | Check waits for text; a close answer shows the line, "The word is maksaa in spoken and written Finnish." on the peach soft note. |
| 32 | pass | `build.md` | Job 16 is held, so Use it is out of scope, as written. |
| 33 | pass | `eval-33-finish-guest-webkit.png`, `eval-33-finish-email-webkit.png` | Tick, line card, "3 new words" chips, the owner's save note, one status line; email learner has no note. |
| 34 | pass | `eval-34-account-guest-webkit.png`, `eval-34-account-email-webkit.png` | Guest: G, journey "Stop 3 of 36", add note, four rows, no Sign out. Email: address, Sign out and Delete. |
| 35 | pass | `eval-35-create-account-webkit.png`, `eval-35-enter-code-webkit.png`, `eval-35-sign-in-webkit.png` | Protected sentences in full; an empty address is refused; one code field with `autocomplete="one-time-code"`; guest warning on Sign in. |
| 36 | pass | `eval-36-voice-settings-webkit.png` | Two switches; one press sent one `turn_off`; the Keep switch says the 90 day sentence before the press. |
| 37 | pass | `eval-37-download-ready-webkit.png` | One press gave the file and showed "Your file is ready" in place. |
| 38 | pass | `eval-38-delete-webkit.png` | Warning in full; nothing deleted before "Delete for good"; a double tap sent one delete. |
| 39 | pass | `eval-39-privacy-webkit.png` | First layer, the owner's sentence, full notice behind one control, axe clean. |
| 40 | pass | `eval-40-feedback-webkit.png` | Empty send refused, typing stops at 1,000, a double tap sent one message. |
| 41 | pass | `eval-41-no-connection-road-webkit.png` | Road offline: "No connection", "Your progress is safe.", Try again. Lesson and crash screens rest on the builder's tests. |
| 42 | pass | `eval-31-keep-it-close-webkit.png` | A learner's close answer uses the gentle peach note, never the problem block. |
| 43 | fail | `eval-ci-run.txt` | GitHub's browser job failed on both attempts at this commit, each time a different WebKit test; the second is a race in a helper this job added. |
| 44 | pass | `eval-checks.txt`, `eval-observations-chromium.jsonl` | The `git diff --stat` command printed nothing; no cookie, local or session storage after the road, the animation and a lesson. |
| 45 | pass | `eval-break-proofs.txt` | A quoted `'/session'` put into the road screen turns `[redesign 45]` red. |
| 46 | fail | `eval-46-forty-letter-1-webkit.png`, `eval-46-forty-letter-variants-webkit.json` | A 44 letter word does not wrap in the line card at 375 px: it runs up to 180 px past the card, under the play button and off the screen. Controls are 44 px and nothing scrolls sideways on the pages at 320 px. |
| 47 | pass | `eval-22-focus-return-chromium.json`, `eval-observations-chromium.jsonl` | Keyboard order, focus in and back, Escape, one `h1` per screen, axe clean where I ran it; the WebKit tap gap is under 22. |
| 48 | pass | evidence folder | About 40 screens with app and drawing pairs in both browsers, plus small phone and 200 percent sets; no secret in them. |
| 49 | pass | `eval-checks.txt` | Conventions row, data model "no database object", README €0, `design-drafts/` unchanged. |
| 50 | owner | none yet | Owner approval comes after this evaluation; no `summary.md` yet. |

## Failures and how to reproduce them

### Statement 46 (and the wrap clause of 5): long Finnish words do not wrap

1. Open a lesson whose line holds a long word, at 375 x 812. The builder's own test data does it: one line whose spoken and written text is `epäjärjestelmällistyttämättömyydelläänsäkään`.
2. Look at Hear it. The word stays on one line, runs under the play button and off the right edge (`eval-46-forty-letter-1-webkit.png`). The same happens when the word sits mid line (`eval-46-forty-letter-2-webkit.png`) or is a tappable word (`eval-46-forty-letter-3-webkit.png`): 125 to 180 px past the card.

Cause, from the CSS: every word sits in a `.keep` span with `white-space: nowrap` (`src/components/FinnishLine.module.css`, there since job 8, to keep a word with its punctuation), so `overflow-wrap: anywhere` on the line never applies. The builder's test `[redesign 46] a 40 letter Finnish word wraps inside its card at 375 px` passes for the wrong reason: it checks that the line's group box ends inside the screen, but the overflowing text does not widen that box, and the page does not scroll sideways because the card clips it. AGENTS.md's job 7 lesson asks for exactly this case.

### Statement 22: focus does not return to the cross in WebKit after a tap

1. In WebKit at 375 x 812, open a lesson at Hear it.
2. Tap the cross, then tap "Keep going" (or press Escape).
3. `document.activeElement` is the page body, not the cross (`eval-22-focus-return-webkit.json`). In Chromium it is the cross. By keyboard (Enter on the cross, Enter on Keep going) WebKit is right.

Cause: `src/components/Sheet.tsx` remembers `document.activeElement` when the sheet opens. Safari and this WebKit build do not focus a button when it is tapped, so what it remembers is the body. The word card, which focuses its opener explicitly, returns focus correctly in the same browser. The builder's `[redesign 22]` test passes on GitHub only because the Linux WebKit build does focus a tapped button; it also failed in my local WebKit run. A real iPhone behaves like the local build.

### Statement 43: the full browser suite is not green at this commit

1. GitHub run 41360761462, commit `8013e5a`. Attempt 1: `[save-progress 19]` failed in WebKit (the database still showed the guest without an email right after "Confirm"). Attempt 2 (rerun of the failed job): `[session 18]` failed in WebKit, a sheet blocked the cross.
2. The second one comes from `leaveLesson` and `dismissTip` in `e2e/session-helpers.ts`, both added by this job. They check `isVisible()` once, without waiting, so when the speaking consent sheet opens a moment after Say it appears, the helper misses it and then cannot press the cross. The first one reads the database straight after pressing "Confirm" without waiting for the screen to confirm; that test predates this job.
3. The same code passed in run 41348915446, so these are timing races, not broken features. They are still red runs on the commit that would merge.

## The road bend (48 where the drawing has 34)

It does not matter for any statement. The bend is decoration: it changes no behaviour, text, colour or contrast, and every road test and the design reviewer accept it. In `eval-13-road-continue-webkit.png` against `03-road-continue-drawing.png` the S reads about the same, because the phone shows the picture larger and the card hides the lower road. It is still a number that differs from the owner's approved drawing, so the owner should see the pair and say whether to put it back to 34. It is one constant (`BEND` in `src/components/landscape-geometry.ts`).

## Odd, not failures

- Job 20 is now merged on main, but this branch is not rebased on it, so every road test still runs on the fixture through Playwright request mocks (the spec said "through the Worker's test fake"). `parseRoad` reads job 20's real column names (`stop_number`, `title_en`, `can_do_en`, `part_number`, `lessons_total`, `lessons_done`; `lessons_total` is always 4 there). The open point in `build.md` that job 20 answers visitors with 401 is out of date: main now has `road_for_visitors()`. After the rebase the road tests should run once with `PUHUSCRIBE_REAL_ROAD=1`.
- The Worker test `[redesign 25] [personal data] reads only the caller's own session rows` passes for the wrong reason: the other learner's fake database is never connected, so it would pass even if the field read everyone's rows. The real protection is the row rule on `sessions`, which the job 3 pgTAP tests already prove.
- A fast double tap on "Next line" moves two lines, so line 2 can be skipped (`eval-observations-chromium.jsonl`, status went from "Line 1 of 3." to "Line 3 of 3.").
- The tip lets Tab reach the words of the lit line card. That fits "the line card stays lit", but the spec's "Tab cannot reach the page behind" could be read more strictly.
- "How it works" on the consent sheet opens the privacy page in a new tab, so a learner may never see it before pressing "Turn on" (the security reviewer raised this; the owner chose it).
- Locally, prettier flags the 13 `design-drafts/` files only because the Windows checkout has CRLF line endings; GitHub's code check passed.

Result: fail

## Round 4 re-evaluation

Re-evaluated 2 November 2026 on commit `2ef3ad3` (branch tip `89951c9` differs only in `build.md`), rebased onto main at `658034b`. I tested a throwaway copy of `2ef3ad3` (made with `git archive`, its `src/` checked identical to the worktree's) built with `npm run build` and served by `vite preview` over HTTPS, at 375 x 812 in Chromium and WebKit, with the builder's request mocks, because there is no Docker here. Real taps were made with Playwright's touch screen, without the builder's `mousedown` trick. My scripts are `eval-r4-script-main.spec.txt`, `eval-r4-script-overlap.spec.txt` and `eval-r4-script-patterns.spec.txt`. Breaks were made only in the throwaway copy and undone (`eval-r4-break-proofs.txt`). I read the round 4 part of `build.md` and `proof-by-breaking-round4.md` first, as the manager asked. No `.env*` file was read; no trace or HAR file was kept (`PUHUSCRIBE_NO_TRACE=1`).

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 5 | pass | `eval-r4-observations-webkit.jsonl`, `eval-r4-46-hear-it-plain-alone-webkit.png` | Long words now wrap (`overflow-wrap: anywhere` reaches the word); no type size changed in round 4. |
| 46 | fail | `eval-r4-46-realistic-21-letter-tappable-webkit.png`, `eval-r4-46-tappable-mid-webkit.png`, `eval-r4-46-text-over-text-webkit.jsonl` | A plain long word wraps cleanly inside the card in both browsers, also at 320 px with 200 percent text. A tappable long word that follows another word overlaps the row above by 9 to 10 px ("Voinks" and "Missä on" run into the word below) and its wrapped pieces are centred. A real 21 letter word, `terveyskeskuslääkärin`, does it at 375 px. |
| 22 | pass | `eval-r4-22-focus-return-webkit.json`, `eval-r4-22-leave-sheet-webkit.png` | With real touch taps in WebKit, focus returns to the cross after "Keep going", Escape and a tap on the dimmed page; also by keyboard, and after focus was on "Next line". "Leave" goes to the road. axe clean on the open sheet. Same in Chromium. |
| 24 | pass | `eval-r4-24-double-tap-webkit.json`, `eval-r4-24-say-it-after-double-tap-webkit.png` | A double click and three fast finger taps move one line; a tap after a pause and clicks 700 ms apart move the next. "Continue" tapped three times on a slow network saved the step once. Say it moves one line on a double tap. Same in Chromium. |
| 43 | pass | `eval-r4-ci-run.txt` | Run 41415511557 on `2ef3ad3e138559aa2a1c9b300e9241e9cc340470`: every job green on attempt 1, browser job 708 passed, 0 failed, 0 flaky. The earlier tests changed in round 4 are stricter waits and one helper that names the word card by its face; none is weakened. |
| 47 | fail | `eval-r4-47-other-sheets-webkit.json` | New finding, also present before round 4. In WebKit, a tap on the "Speaking feedback" switch in Voice settings opens the consent sheet; after "Not now" or Escape focus is on the page body, not the switch. The word card and "Patterns you've seen" return focus correctly (`eval-r4-47-patterns-webkit.json`). |
| 10, 13, 14, 19 | pass | `eval-r4-ci-run.txt`, `eval-r4-spot-road-day-one-webkit.png` | The three `real-road` tests passed against the real `GET /api/road` in both browsers on GitHub. Locally (mocks) the day one road has one `h1` "Your road to A1" and axe finds nothing. |
| 15, 20 | pass | `eval-r4-spot-road-continue-webkit.png`, `eval-r4-spot-checks-webkit.json` | Five signs with their names, card below the marker, no sideways scroll, axe clean. |
| 23 | pass | `eval-r4-spot-line-card-webkit.png` | The line card is unchanged: "noi" and "nuo" washed, punctuation stays with its word, play buttons, gloss, axe clean. |
| 26 | pass | `eval-r4-46-word-card-webkit.png` | The word card wraps a 44 letter word in its title and both tiles, inside the sheet. |

The other statements were not touched by round 4 (it changed `FinnishLine`, `Sheet`, `SessionFrame`, `HearIt`, `SayIt` and tests only) and keep their results from the table above, backed by the green run.

### Proof by breaking (throwaway copy)

- Wrap rule removed (`.keep .plain, .keep .word`): the builder's four 44 letter tests go red in both browsers (8 failed), and my own measure shows the word 177 px past the card in WebKit.
- `overflow-wrap: break-word` instead of `anywhere`: the two tappable variants go red; the plain ones stay green, which is right, because a plain inline word does wrap with `break-word`.
- `returnFocus={cross}` removed: the builder's two tap tests go red in both browsers, and my real tap run in WebKit shows the body focused after "Keep going", Escape and the dimmed page.
- Steady press removed in Hear it: a double click moves to line 3, and three fast taps leave Hear it altogether.
- Diagnostic only, not a fix: with `.keep .word { margin-top: 0; text-align: start; }` added, the row overlap drops from 9.1 px to 0.4 px and the pieces start at the left. So the overlap comes from the word button's negative top margin, now that the button can be several rows tall, and the centring from the button's default `text-align: center`.

### Failures and how to reproduce them

**Statement 46: a wrapped tappable word runs into the row above.**

1. At 375 x 812, open a lesson whose spoken line is `Missä on terveyskeskuslääkärin vastaanotto?` with `terveyskeskuslääkärin` as a word with a card (any form data).
2. Look at Hear it. The spoken line wraps the word, but "Missä on" sits on top of "terveyskeskuslääkä" and "rin" stands alone in the middle of its row (`eval-r4-46-realistic-21-letter-tappable-webkit.png`). The same in Chromium, in Say it (`eval-r4-46-say-it-webkit.png`) and with the builder's own case "Voinks" plus a tappable 44 letter word (`eval-r4-46-tappable-mid-webkit.png`).
3. The builder's tests pass because they measure each word's right edge and where the punctuation sits, not whether one row covers another. Their evidence screenshot (`29-long-word-app-webkit.png`) uses a plain word, which is fine.

**Statement 47: the Voice settings consent sheet does not return focus in WebKit after a tap.**

1. In WebKit at 375 x 812, open `/voice` with speaking feedback not yet chosen.
2. Tap the "Speaking feedback" switch, then tap "Not now" (or press Escape).
3. `document.activeElement` is the body (`eval-r4-47-other-sheets-webkit.json`). By keyboard it is the switch; in Chromium it is the switch. Cause: `VoiceSettings.tsx` does not pass `returnFocus` to its `ConsentSheet`, so it relies on the old way that round 4 fixed for the leave sheet. `build.md` names this gap. I missed it in round 3 because I tapped only the leave sheet and the word card.

### Odd, not failures

- Inside a tappable word the punctuation sits a little apart from the last letter ("säkään ?"), because it is outside the word's wash padding.
- Two quick Enter presses on "Next line" move two lines. That fits the fix, which ignores only double clicks and quick finger taps; a keyboard press is deliberate.
- After a tap on "Keep going" the cross has focus but shows no outline (`eval-r4-22-after-keep-going-webkit.png`). That is how `:focus-visible` treats a pointer, and the outline shows by keyboard.
- Word buttons are 44 px tall but can be as narrow as 24 px ("noi" is 35 px wide, `eval-r4-spot-checks-webkit.json`), the inline target rule of round 2. My first table said every control I measured was 44 px or more; for the words that measured only the height.
- The GitHub browser job skips 6 more tests than round 3 (147 against 141); they are the new long word evidence screenshots, which run only with `PUHUSCRIBE_EVIDENCE=1`.
- The road bend is still 48 for the owner to decide.

Result: fail

## Round 5 re-evaluation

Re-evaluated 2 November 2026 on commit `53428b9` (branch tip `e4c4db4` differs only in `build.md`). I tested a throwaway copy of `53428b9` (made with `git archive`, its `src/` checked identical to the worktree's), built and served by `vite preview` over HTTPS with the builder's request mocks, because there is no Docker here. Everything ran at 375 x 812 in Chromium and WebKit, and again at 320 x 640 with text at 200 percent, using real finger taps (Playwright's touch screen), without the builder's `mousedown` trick. My scripts are `eval-r5-script.spec.txt` and `eval-r5-break-script.sh.txt`. Breaks were made only in the throwaway copy and undone (`eval-r5-break-proofs.txt`). I read the round 5 part of `build.md` and `proof-by-breaking-round5.md` first. No `.env*` file was read, and no trace or HAR file was kept (`PUHUSCRIBE_NO_TRACE=1`).

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 46 | pass | `eval-r5-46-summary.txt`, `eval-r5-46-layout-hear-it-375-webkit.jsonl`, `eval-r5-46-hear-it-375-r21-after-tappable-webkit.png`, `eval-r5-46-say-it-320-200-r21-after-plain-webkit.png` | I tested seven lines (the 21 letter `terveyskeskuslääkärin` after plain words, after tappable words and in quotes, and a 44 letter word tappable or plain in the middle, first, or twice), in Hear it and Say it, at 375 and at 320 with 200 percent text, in both browsers (112 measured lines). In every case the text rows overlap by 0.4 px at most (round 4 measured 9.1 to 10.3 px), every later row of a wrapped word starts at the button's left edge (0 px), text-align is `start`, nothing scrolls sideways, every word stays 19 px or more inside its card, and every word button is at least 44 px tall. A finger at the centre of every piece of text lands on that word's own button, and 256 real taps on the first and last piece of each word each opened that word's own card. |
| 46 (one-row words) | pass | `eval-r5-46-one-row-hear-it-375-webkit.json`, `eval-r5-46-one-row-say-it-375-webkit.png`, `eval-r5-break-proofs.txt` | The builder's dialogue at 375 px has the same layout under the round 4 and round 5 CSS: none of the 10 text pieces moves and neither word button ("noi", "nuo") moves or resizes, in both browsers and both screens. The buttons are 44 px tall, a tap on "noi" opens its card, and axe finds nothing. |
| 47 | pass | `eval-r5-47-focus-return-webkit.json`, `eval-r5-47-focus-return-chromium.json`, `eval-r5-47-voice-after-focus-return-webkit.png` | With real taps in WebKit, focus goes back to the opener after its close button, Escape and a tap on the dimmed page in every case: the leave sheet (cross), the word card from a spoken word, a written word, a tall wrapped word and a word in Say it, the patterns panel (back to "Patterns you've seen", then the card's Close back to "noi"), the quiet "Turn on speaking feedback" in Say it, the Voice settings Speaking feedback switch (also after "Turn on", and by keyboard), and the finish screen chips. The first lesson tip gives focus to "Next line". Chromium shows the same results, there are no console errors, and axe finds nothing on Voice settings. |
| 43 | pass | `eval-r5-ci-run.txt` | GitHub run 41424781086 on `53428b9a7826c7eabf6648e918ce78a73efceb78` was green on its first attempt in every job. The browser job had 720 passed, 0 failed and 0 flaky, including the new round 5 tests in both browsers and the three real road tests. Against round 4 there are 12 more passes and 6 more skips (the new 21 letter evidence screenshots), so no test was removed. The only lines removed from tests in round 5 let a helper open Say it as well as Hear it, with Hear it still the default; nothing was weakened. |
| 5, 22, 23, 26, 28 to 31, 33, 36, 10 to 20 | pass | `eval-r5-spot-checks.txt` | Spot check on the clean build: the builder's lesson, pages and road browser files gave 290 passed and 2 failed, both in WebKit. Both failing tests wait for the record button, which the app shows only where the browser has MediaRecorder (`src/lib/recorder.ts`), and Playwright's WebKit on Windows has none. Both pass in Chromium here and in WebKit on GitHub. Round 5 changed only `FinnishLine`'s word button, `Switch`, `ConsentSheet`, `SayIt` and `VoiceSettings`, so the other statements keep their round 4 results, backed by the green run. |

### Proof by breaking (throwaway copy)

- **Break A.** I put back the round 4 word button CSS (`FinnishLine.module.css` as at `2ef3ad3`). The builder's two 21 letter tests went red in both browsers (row overlap 9.09 px). My own measure showed 9.1 to 10.3 px of overlap and centred pieces again (`eval-r5-break-A-layout-hear-it-375-webkit.jsonl`, `eval-r5-break-A-hear-it-r21-webkit.png`).
- **Break B.** With only `text-align: start` removed, the same tests went red in both browsers (later pieces 85 px and 53 px from the left).
- **Break C.** With `returnFocus={speakingSwitch}` removed from Voice settings, the builder's switch test went red in both browsers. In my WebKit tap run, focus fell to the page body after "Not now", Escape, the dimmed page and "Turn on" (`eval-r5-break-C-focus-webkit.json`). This is exactly the round 4 failure.
- **Break D.** With `reopen.current?.focus()` removed from Say it, the builder's quiet button test went red in both browsers, and in my tap run focus fell to the body (`eval-r5-break-D-focus-webkit.json`).
- **Break E.** I made `Sheet` ignore `returnFocus`. The leave sheet and switch tests went red in both browsers. In my WebKit tap run, only the leave sheet and the switch lost focus (`eval-r5-break-E-focus-webkit.json`). The word card, the chips, the quiet button and the patterns panel each have their own way back, so each fix is protected separately.
- After each break the copy was restored (its `src` checked identical to the worktree's) and rebuilt. The baseline and the final run of the builder's round 5 tests passed 14 of 14 in both browsers.

### Failures

None.

### Odd, not failures

- When a word has a visible focus outline (after a key press), the outline is drawn on the 44 px tap area. So it crosses the text of the next row, for example the outline round "noi" runs through "mansikat maksaa?" (`eval-r5-46-one-row-hear-it-375-webkit.png`), and the outline round "maksaa" crosses the last piece of the long word above it (`eval-r5-46-hear-it-375-long44-tappable-mid-webkit.png`). This is not new in round 5, because the one-row layout is identical to round 4. It only lasts while the word has focus. It could be drawn at text height in a later job.
- The later pieces of a wrapped word start about 5 px left of the other rows of the line. They start at the button's edge, and the button sits 0.08 em outside the text because of the word's wash padding (`eval-r5-46-hear-it-375-r21-after-plain-webkit.png`, "rin"). It is small, and it is consistent.
- The consent sheet that opens by itself when Say it appears has no opener. After "Not now", Escape or the dimmed page, focus is on the page body in both browsers. The spec asks for focus to return to the opener, and there is none here. Sending focus to the Say it heading or the quiet button would help a screen reader user, and is the owner's or designer's call.
- My one long focus test once ran past Playwright's 30 second limit with four workers, which is a limit of my script and not the app. With a longer limit it passed 8 of 8.
- The road bend is still 48 for the owner to decide.

Result: pass
