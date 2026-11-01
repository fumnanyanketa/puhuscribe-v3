# Design review: 19-redesign, round 1

Reviewer: design reviewer. Head 44e9d3e. I read `spec.md` (with the owner's answers of 1 November 2026), `build.md`, `design.md`, the diff, and compared every screenshot pair in `factory/jobs/19-redesign/evidence/` (app in WebKit and Chromium against the drawing). I did not run the app. Contrast figures below are my own calculation from the token values. No `.env*` file was read.

Overall: the look matches the approved drawings well. Palette, Poppins, milky panels, the road with the A1 sun and the A2, B1 and B2 fells, the line card, the word card, the sheets and the account page all read as the same soft, calm product. None of the owner's banned styles appear (no accent bars, eyebrows, glow, gradient text, emoji, banned fonts, hairline rows). Product rules hold (no mode picker, no word list, no streaks, no shaming). Three things must be fixed before approval.

## Must fix

1. **Page content sits on top of the landscape on every page screen.** Files: `src/components/PageFrame.module.css` line 59 to 71 (`.body` has only `padding: var(--space-9)` at the top). Screens: 17 Create account, 18 Enter the code, 19 Sign in, 20 Voice settings, 23 Privacy notice, 24 Send feedback (all `*-app-webkit.png`). The first line of text starts at about 135 px while the hills and trees run down to about 148 px, so trees and the sun's edge cut through the letters (clearly visible on "Your voice settings are shown below.", "We keep only what we need to teach you", "Tell us what worked"). Quiet text on the ridge colour is 4.3 to 1 and on the pine trees 3.3 to 1, under the 4.5 floor, and axe cannot see it because the art is behind the text. The drawings start the content below the hills. Fix: raise the top padding so content starts at least 160 px from the top at 375 px (about `calc(var(--band-height) - 40px)` below the header), and check every page screen, including 200 percent text.

2. **"Delete my account" fails its contrast floor and has no pair in the contrast list.** Files: `src/screens/Account.module.css` lines 371 to 374 (`.deleteLink` is `--color-peach-deep` #b8532f), `src/styles/contrast-pairs.ts` (only peach deep on white and on the panel are listed, lines 88 and 89). The link sits on the peach end of the wash (#fbe2d1) in screenshots 15 and 16, where the ratio is 3.9 to 1. It is 14 px text with no underline, so the floor is 4.5 to 1, and the owner answered "keep every floor". Fix: use the changed-word brown (`--color-changed-text`, 7 to 1) or another token that passes, and add the missing pair `peach deep on --color-wash-bottom` to the list so the test covers it. Look for any other small text placed straight on the wash (the "Delete my account" link is the one I found).

3. **The mint travelled stretch of road is not visible in any road screenshot.** Files: `src/lib/road-state.ts` lines 89 to 93 (`travelled()` divides by all 36 stops, so stop 3 gives about 6 percent), `src/components/Landscape.tsx` lines 270 to 296; screenshots 03, 04, 05 (app) against 03-road-continue-drawing. I counted pixels of the mint #8ce6cb in the three images and found one to five, so effectively none. The drawing shows a clear mint centre line and edges up to the "you" marker, and spec statement 12 asks for it. In the app the travelled part is tiny and the bottom card hides what is left. Fix: draw the mint line from the bottom of the visible road up to the marker, not as a share of 36 stops, so it is always seen between the card and the marker. Then re-take 03 to 06.

## Should fix

4. **Lines of Finnish are spread far apart.** File `src/components/FinnishLine.module.css` lines 112 to 117 (`.word` has `min-height: var(--tap-min)`), seen in screenshots 07, 09, 10, 11, 13, 26 to 28. Each word is a 44 px tall button, so a two row line has about 44 px between rows for 19 px text (leading about 2.3, the design says 1.4). The line card looks airy and each line feels like two separate lines. The drawing's lines are tight. Fix: keep the 44 px touch area with a taller hit area that overlaps the neighbour row (padding with negative margin, or a pseudo element), or lower the word target to the 24 px minimum that WCAG 2.2 AA allows and say so in the spec, since statement 46 asks for 44 px on all controls. Either way the visible leading should be near 1.4.

5. **The changed word lost its peach look.** `src/styles/tokens.css` line 61 (`--color-changed-text` #7f3618). Dark brown on pale peach reads as brown, not peach, and the drawings' thin peach outline round the word (screenshot 07 drawing, "noi") is gone. The darkening is correct for the 7 to 1 floor and I accept the colour, but the word now looks like a stain. Fix: add the drawn 1 px ring in the peach mark colour (`--color-peach`, a non-text edge) to the changed word's wash in both lines and in the tip. If the owner prefers it without, leave it.

6. **Understand it shows a card inside a card.** `src/screens/UnderstandIt.tsx` with `Screens.module.css`, screenshot 09 (app) against 09-understand-it-drawing. The drawing is one milky card with the play button and the line. The app puts the line card's inner outlined box inside a second milky panel, which adds an extra edge and shadow. Fix: show one card, as in the drawing and as the Say it screens already do.

7. **Download ready is weaker than drawn.** `src/screens/AccountPage.tsx` (the ready state) and `Account.module.css` `.ready` (lines 376 to 395), screenshot 21. "Your file is ready." is quiet normal text, but the drawing makes it a title in ink and semibold, with the quiet line below it and the orb centred in the screen. There is also a link "Back to your account" that the drawing does not have, between the orb and the "Download" button, so the primary action is far from the message. Fix: make "Your file is ready" the screen's title style, centre the group, keep "Download" at the bottom, and move or drop the extra link.

8. **Privacy section headings look tappable.** `src/screens/Account.module.css` lines 158 to 165 (`.shortHeading` is `--color-mint-deep`), screenshot 23. In this design mint means "you can tap this". Section headings such as "What we keep" and "Your voice" are not links. Fix: use ink (`--color-text`) at semibold, as the drawing does.

## Notes

9. **Look after the six darkened colours.** The look survives. Mint #1e856f is almost the drawn mint. Peach marks #db7249 are close. Quiet #556863 is hardly different. Slate #38527a reads as navy rather than the drawn light slate, but the written line is still clearly different from the spoken line (colour, weight and the dot), so I accept it. The changed word is the only one that changes character (see 5).
10. **Unreached progress segments are nearly invisible.** `src/road/RoadTop.module.css` lines 19 to 24 and the lesson bar track (`--color-track` #c3ddd2 on the wash is 1.15 to 1, white segments are 1.25 to 1). The filled part is clear and the text on screen carries the meaning, so this is not a failure, but the "12 pieces" read as white dashes on day one. Consider a slightly stronger edge on the empty pieces.
11. **Finish screen action area.** Screenshots 13 and 14: the "Done" dock has no fill, so the new words panel is cut by a hard edge just above it ("sana3" is sliced). It scrolls and works, but a soft fade or a milky bar under the dock would look finished. The chips ("sana0" and so on) are fixture words, which is fine for evidence.
12. **Voice settings filler line.** `src/screens/VoiceSettings.tsx` line 59, screenshot 20: "Your voice settings are shown below." shows as visible text. It existed before this job. Under "minimal text" it could be hidden visually and left as a status for screen readers.
13. **Road is a little straighter than drawn.** The app's road bends only slightly, while the drawing winds in a clear S. Fine for approval, but if the owner looks side by side they may mention it.
14. **Privacy first layer is long.** Screenshot 23: the "Your voice" section holds six paragraphs because the owner asked that the consent details live on the privacy page. That is the owner's decision (answer 10). The page is readable. The "Read the full notice" control is further down than the drawing shows.
15. **Checks that held.** Reduced motion: every animation has a reduced block, the opening animation becomes a 600 ms crossfade, the pulse is turned off, and hidden parts use `visibility` and not `inert` (`RoadScreen.module.css` lines 70 to 136, `RoadPicture.module.css` lines 394 to 414). "Skip" is the first control, at least 44 px. Focus: Skip, then Start, with a visible 3 px focus ring on buttons and fields in the screenshots, and focus moves to "Got it" in the tip and "Start" after Skip. Tap targets: the account and back buttons, the cross, signs-in links and switches are at least 44 px. WebKit dark mode: the page declares light only (`index.html` line 6, `tokens.css` line 24), a test checks the declaration with a dark browser, and every button has token colours. Long Finnish words: `overflow-wrap: anywhere` is kept and covered by tests. Writing rules: I found no em dashes, hype words or "not X but Y" lines in the new app text. Protected copy is unchanged and tested.
16. **Evidence gaps.** No screenshots at 320 px wide with 200 percent text or at 375 x 667, so statements 20 and 46 rest on tests only. Keep it, Use it, and "Something went wrong" have no screenshots (build.md says so). The three Say it recording states are Chromium only. I could not check the animation visually, only its code and test descriptions.

Result: changes needed

## Round 2 re-check

Checked at branch tip 921739a against the new code (`git diff 44e9d3e..HEAD`) and the retaken screenshots, including the new 375 x 667 and 320 px 200 percent shots, Keep it and the crash screen. Contrast numbers are my own calculation. I did not run the app.

### Round 1 items

1. **Content on the landscape: fixed.** `PageFrame.module.css` now gives the header a minimum height of `--page-content-top` (168 px) and the body starts under it. In 17, 18, 19, 20, 23 and 24 the first line now starts below the hills and trees, and the 320 px 200 percent privacy shot shows the same. Keep it's "Word 1 of 1." (screenshot 26) still touches the lowest edge of the hill, but it is above the 4.5 floor there (about 4.6), so I only note it.
2. **Delete my account contrast: fixed.** `--color-danger-ink` #8c3b1a is 6.1 to 1 on the peach end of the wash and 7.2 on the middle, and both pairs are now in `contrast-pairs.ts`. The colour stays warm and close to the delete pill, so the look holds. Accepted.
3. **Mint travelled road: fixed.** Screenshots 03 and 04 now show a clear mint centre line and edges from the foot of the road to the "you" marker, as drawn. Accepted. At 375 x 667 it is still visible between the marker and the card.
4. **Line spacing: fixed.** The 44 px target is now a hit area only (negative block margin, line pitch near 1.4). In 07, 09, 11, 13 and 26 the two rows of a line read as one tight line, as drawn, and plain words (names) no longer reserve height. Accepted. The hit areas of two rows overlap by a few pixels, which is the standard way to keep 44 px targets on tight text and still meets WCAG 2.5.8 (24 px minimum).
5. **Changed word ring: fixed.** The thin peach ring is back (`box-shadow: inset 0 0 0 1px var(--color-peach)`). It is 2.65 to 1 on the wash, which is fine for a decoration because the bold weight and the wash carry the meaning, and the text keeps its 7 to 1. The word now reads as peach again. Accepted.
6. **Understand it card in card: fixed.** Screenshot 09 now shows one milky card with the line and the play button, as drawn.
7. **Download ready: fixed.** "Your file is ready" is now the `h1` in title style, centred under the orb, with "Download" at the bottom, and the extra link is gone. The status line stays for screen readers only.
8. **Privacy headings: fixed.** They are ink, semibold.
9 to 12 (notes). The empty progress pieces now have a mint edge (3.6 to 1 on both ends of the wash); the road top and lesson bars read clearly as hollow pieces. The finish screen's Done dock is now a milky bar with a soft shadow, so the new words panel fades under it instead of being cut. The road bend is raised from 34 to 48. The voice settings filler line is still visible; it is old and I leave it as a note.

### The builder's choices

- **Content starts at 168 px:** good. It clears the ridge (about 148 px) and leaves a breathing space, and the first layer of every page now looks like the drawings.
- **`--color-danger-ink` #8c3b1a:** good. One extra token for one use, tested in two places.
- **Mint road from the foot of the road to the marker:** good. It is the right reading of "the stretch travelled", and a test now covers it.
- **Overlapping 44 px targets at 1.4 leading:** good, see item 4.
- **Road bend 48 instead of the drawn 34:** acceptable. The S now reads as clearly as in the drawing, which was the point. The drawing's picture is smaller on a real phone and the card hides the lowest part of the road, so a larger bend at the same scale is a fair match. It does depart from the owner's drawn number, so mention it to the owner in the summary.

### What remains

A. **Signs pile up on short phones and at 200 percent text (should fix).** `src/road/RoadPicture.tsx` and `signSpots` (`lowest` is measured from the card). In `02-road-day-one-375x667-webkit.png` and `03-road-continue-375x667-webkit.png`, sign 5 sits on top of sign 4, so "Numbers, prices and paying" is cut at "prices", and the next signs touch each other and the "you" marker. In `03-road-continue-320x640-text-200-webkit.png` the signs are a stack of overlapping boxes, with names unreadable and the top signs sitting beside and over the progress bar and the account button. The current sign, the marker and the card are fine (spec statement 20 is met), but a learner on an iPhone SE sees a jumble. Fix: when the room above the card is small, show fewer signs (the current one, the one before and the one after) or stop the signs from overlapping by spacing them from the measured room, and keep the top bar clear of signs.
B. **At 320 px with 200 percent text the card fills the screen (should fix).** `02-road-day-one-320x640-text-200-*.png`. The day one card reaches the top of the screen, covers the road, the progress bar and the account button, and `.screen` is `overflow: hidden`, so a longer stop name or guest line would be cut with no way to scroll. Fix: cap the card's height (about 70 percent of the screen) and let its inside scroll, or let the page scroll at large text.
C. **Repeated lines (note).** Keep it shows "Type the missing word" as a heading and again as the hint above "Check". The crash screen shows "Something went wrong" as the title and "Something went wrong on this screen." in the block below. Say it once each, to match "minimal text". The crash words are existing copy, so only the Keep it hint is an easy change.

The 375 x 667 and 320 px shots of every other screen (accounts, privacy, feedback, voice settings, Keep it, finish) show no sideways scroll, no clipped text and reachable actions.

Result: changes needed (A and B only; both are small and nothing in round 1 remains open)

## Round 3 re-check

Checked at branch tip 77ab27a against `git diff 921739a..77ab27a` and the retaken screenshots (`02-road-day-one-*`, `03-road-continue-*` at 375 x 667 and 320 x 640 with text at 200 percent, `26-keep-it-*`, `29-something-went-wrong-*`). I did not run the app or the database. The tests the builder added for these items passed on GitHub (run 41348915446, commit 0347ae4), which I take from `build.md`.

### A. Signs on short phones: fixed

At 375 x 667 the road now shows four signs on day one and three on the continue screen, with no board on top of another and none on the progress bar, the account button or the "you" marker (`02-road-day-one-375x667-webkit.png`, `03-road-continue-375x667-webkit.png`). "Numbers, prices and paying" is whole again. At 320 px with 200 percent text two signs stay (the current stop and the next), both whole, with the top bar clear. The rule (keep the current and next sign, drop others, grow the gap with the tallest board, nudge a board back inside the screen) is sound and is recorded in `design.md`.

### B. Card at 320 px with 200 percent text: fixed

The card now stops at 42 percent of the screen height and scrolls inside. In `02-road-day-one-320x640-text-200-webkit.png` the road, both signs, the progress bar and the account button are all visible above it, and the Start button shows about 47 px of its height at the card's lower edge, so a learner sees there is more and can tap it or scroll. Accepted.

### C. Said twice: fixed

Keep it shows "Type the missing word" once, as the field's title, and the status line keeps the sentence for screen readers only (`26-keep-it-375x667-webkit.png`). The crash screen shows "Something went wrong" once, with the problem sentence kept for screen readers (`29-something-went-wrong-app-webkit.png`). The hidden style in `StatusLine.module.css` now sits last so a tone's padding and edge cannot leave a gap. No new wording, no banned style, no new colour.

### New problems in the changed files

None that block. Notes only.

1. **Note: flag labels clipped by signs.** On the tall phone (`02-road-day-one-app-webkit.png`) and at 375 x 667 (`02-road-day-one-375x667-webkit.png`) a sign covers most of the real "A2" label, so it reads "2" or a clipped letter. At 320 px with 200 percent text the current sign covers most of the "A1" on the sun (`03-road-continue-320x640-text-200-webkit.png`, which the builder already lists). These are scenery labels, not controls, so I do not block on them. If it is cheap, keep signs from standing on the A2 flag.
2. **Note: Keep it at 200 percent text.** In `26-keep-it-320x640-text-200-webkit.png` the focused answer field sits half behind the Check bar. The page scrolls and the field is reachable, as in round 2, so I only note it.
3. **Note: the card's scroll has no visible hint** other than the cut Start button. That is enough at this size.

Result: pass
