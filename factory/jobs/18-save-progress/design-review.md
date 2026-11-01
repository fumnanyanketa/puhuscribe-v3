# Design review: 18-save-progress, round 1

Reviewer: design and learner experience. Branch `factory/18-save-progress`, tip `e6953e4`, 1 November 2026.

Method: read the spec, `build.md`, `AGENTS.md`, `design.md` (the new "Save progress note" entry and the Button, Session frame and Status line entries) and the diff of `FinishScreen.tsx`, `SaveNote.tsx`, `SaveNote.module.css`, `save-note-copy.ts`, `save-note.ts`, `DesignReference.tsx` and `design.md`. Then I ran the app from the worktree (Vite on port 5191) and put the real finish screen on a phone in Chromium and WebKit at 375 x 812, light and dark. The finish screen needs a database that this Windows machine does not have, so I answered the app's `/api/*` calls with a stand in (one saved session whose answer says `saveNote: "first"`). The note, the buttons and the page around them are the real code. I also copied the private Switzer font files into the worktree's git ignored font folder for the run, so the layout below is measured with Switzer, and I emptied that folder again afterwards.

Screenshots are in the worktree at `factory/jobs/18-save-progress/evidence/` as `design-review-finish-*`, `design-review-focus-*` and `design-review-notnow-*` (browser, light or dark, `short` or `long` line). They are not committed.

## What is good

- The note is a plain block of text and two buttons. No card, no edge, no fill, no icon, no label above it, no animation. It matches the `design.md` entry word for word and none of the banned styles appear.
- Buttons are the shared `Button`, so the colours are explicit tokens. Measured in both browsers: "Add your email" is white (`rgb(255,255,255)` light, `rgb(28,27,35)` dark) with ink text and the `--color-control-edge` ring, 172 x 54 px. "Not now" is transparent with ink text and an underline, 90 x 44 px. "Done" stays the only black button. The WebKit dark mode contrast lesson is respected: the buttons are readable in both modes in WebKit, and the edge of the white button is visible in both.
- Both buttons meet 44 px. At 375 px they sit side by side with a 16 px gap, and they wrap under each other when the space is short.
- Focus: the note does not take focus when it appears (the code has no autofocus and the build's own test checks it; I did not re-test that part). Tab order in Chromium is Leave session, the two play buttons, "Add your email", "Not now", "Send feedback", "Done", so the note comes before "Done" in reading order and "Done" stays reachable. In WebKit links are skipped by the browser's own rule, and the order is the same for buttons. The focus ring on "Add your email" is the design system's ink ring, clearly visible in the light mode screenshot.
- "Not now" removes the note and puts focus on the replacement line, which is a plain `p` with `tabindex="-1"`. I checked in all four browser and mode combinations: the active element is that line. It is not `role="status"` and not `aria-live`, so the finish screen keeps its one status line. No outline is drawn on it after a click (it is not `:focus-visible` for a pointer), which is right.
- The note only appears once the save has succeeded, and it is below the "Your progress is saved." decision, not instead of it. "Done" is in the pinned bottom dock and never moves or loses space.
- The words are the owner's exact sentence, in plain English. The closed line "No problem. You can add your email later from Your account." is true: the front door has a "Your account" link and the account page has "Add your email" for guests. It has no em dash, no hyphen as punctuation, no "not X but Y", no hype words, no group of three, no loss warning, no number and no pressure.
- The finish screen at 375 x 812 with Switzer: for the line the screen shows (the shortest line of the dialogue, so a short one), the whole note ends at y 631 and the scrolling area ends at y 690. It is visible without scrolling, with the feedback link below it, in light and dark and in both browsers.

## About the Switzer font question

The fallback test is not a false comfort. The fallback body font is Poppins, which is wider than Switzer, so the fallback run gave the harder case for wrapping, not the easier one. I measured with Switzer: same result, the note is fully in view for a short finish line (about 59 px to spare above the dock's edge). That margin is small. The finish screen always shows the shortest line of the dialogue, so it is usually small, but it is not guaranteed. With a longer line (I tried a long line: a longer spoken and written line with a one sentence translation) the note starts at y 809, below the bottom of the scroll area, and the learner has to scroll to find it. Nothing breaks: the area scrolls, "Done" stays pinned, and the note is shown again at the third session. So there is no real layout risk from the font, but there is a small chance that a learner never sees the note at all (finding 1).

## Findings

### Should fix

None.

### Note

1. **The note can sit below the visible area with no hint that there is more.** `FinishScreen.tsx:132`, `SaveNote.module.css`. With a two or three line finish line, or a learner on large text, the note is under the fold and only a scroll shows it. This is acceptable for a gentle, optional note and the reminder at the third session is a second chance, so I did not count it. Fix, only if the owner wants the note seen more often: put the note above the "The words you met..." sentence or directly under the line card, so it stays close to the top whatever the line length. This is the owner's call because it changes the agreed place in `design.md`.
2. **The page now says "Your progress is saved." and then "Add your email to save your progress."** `FinishScreen.tsx` (the saved status line) next to `save-note-copy.ts:14`. A beginner can read these as a contradiction: it is saved, so what is left to save? The owner's sentence is decided and I do not ask to change it. The clash comes from the earlier status line, which is saved on this phone only. If the owner wants it clear, the status line could say "Your progress is saved on this phone." for guests only while the note shows. This is for the owner to decide, and nothing in this job has to change.
3. **The note appears a moment after the screen, and moves "Send feedback" down.** `FinishScreen.tsx:132`. The note is mounted when the save answer arrives (about 100 px of height), so on a slow connection the feedback link jumps while the learner reads or reaches for it. It never moves "Done" and never takes focus. Low risk. If it ever bothers anyone, reserve the space while saving or put the feedback link above the note.
4. **A screen reader hears "Your progress is saved." and nothing about the note.** The note is not announced (it must not be, by the rules). A screen reader user finds it by moving through the page or by the landmark list. That matches the design. For the same reason the landmark name `SAVE_NOTE_REGION` is "Keep your progress" while the visible sentence says "save". Matching them ("Save your progress") would avoid a small mismatch for someone who searches the page for the word they heard.
5. **"Add your email" is a button that changes the page address, not a link.** `SaveNote.tsx:43` uses `window.location.assign`. It works by tap and by keyboard (the browser tests check Enter and Space), but it cannot be opened in a new tab and a screen reader calls it a button. This is the same pattern as "Done" and the owner chose a button, so I only note it. A link styled as the secondary button would be better if the shared `Button` ever gets a link form.
6. **"Not now" and "Send feedback" are both underlined text 12 px apart.** They look alike, and a learner could tap the wrong one. Both are 44 px tall and "Not now" closes only the note, so a wrong tap costs nothing. No fix needed.
7. **`design.md` and the design reference page are in step with the code.** `/design-reference` has a live "Save progress note" section. It sits in the `card` wrapper there, while on the finish screen the note has no card. That is fine for a reference page, but the section's one line of text could say so. Not a defect.

## Banned list check

No accent bars, eyebrows, pills or badges, glow or gradient text, emoji or icons, identical card grids, hairline rows or big number tiles. Fonts are Poppins and Switzer through the tokens. No new colour: every value in `SaveNote.module.css` is a token.

## Product rules check

No mode picker, word list, streak or grammar lesson. The tone is gentle: one sentence, "Not now" is a real, quiet choice and its answer is "No problem.". Nothing is lost by declining, and the note does not return after "Not now" in the same session. The note appears twice at most, as the owner decided. New text follows the writing rules.

## Verdict

The screens match the locked design system, the buttons pass in WebKit dark mode, focus and screen reader behaviour follow the spec, and the whole note is visible at 375 x 812 for the line the screen normally shows. There is nothing to fix. The notes are for the owner to read, mainly 1 and 2.

Result: pass
