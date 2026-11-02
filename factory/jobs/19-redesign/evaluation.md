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
