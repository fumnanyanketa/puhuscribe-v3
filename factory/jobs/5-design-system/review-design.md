# Design review: job 5-design-system, round 1

Branch `factory/5-design-system`, head 0f94502. I read `AGENTS.md`, `summary.md`, `spec.md`, `build.md`, `design.md`, `design/brief.md`, the v2 handoff README, the component CSS, and looked at the screenshots in `evidence/` (the Hear it sample in light and dark, the reference page in light and dark sliced into readable pieces, and the word card in both modes). I did not run the app; focus, tap size and contrast claims below rest on the CSS and on the build's own tests.

## What passes

- **v2's identity carries over.** The paired dialogue card (spoken on a teal band first, written under it, teal and violet dots joined by a dotted rail), the azure changed words, the soft white cards with soft shadows, the black pill buttons, the white to lilac page fade, Poppins headings over Switzer body and the flat sprout wordmark are all present and recognisable. The lit word (an ink block), the bottom player with a slim waveform and the calmer spacing from direction A are in too. It looks like one finished product, not a kit.
- **Banned list.** I found no eyebrow labels (the "Spoken" and "Written" labels sit above a line of Finnish, not above a heading, and are not uppercase), no 01/02 numbering, no glow, glass or gradient text, no icon squares, no thick one sided bars (the only one sided border is the 2 px dotted rail), no hairline row dividers, no emoji, no banned fonts, no second gradient. Icons appear only inside controls (close, play, pause, microphone, stop). The only gradient is the owner approved page fade, used once.
- **Finnish at 375 px.** The spoken line is Poppins 600 at 22 px, the written line Switzer 17 px, line height 1.4, so ä and ö dots stay clear. In the screenshots ä, ö and å are crisp in both modes and the long compounds on the reference page wrap inside the width.
- **Tap targets.** Every word button is at least 44 px tall (`FinnishLine.module.css`, `min-height: var(--tap-min)`), and play, record, Close and the pills are 44 px or more in the screenshots.
- **Focus.** A 3 px solid outline, 2 px away, at least 3:1 in both modes, through `:focus-visible`. The word card's title takes focus with no outline; that is reasonable because it is not a control.
- **Dark mode is designed, not inverted.** It has its own surfaces (#1c1b23 cards on #121117), its own lighter register colours (teal #4fb3c4, violet #a78bea), its own azure wash and its own shadows. The teal ring round the playing card and the white lit word read clearly.
- **Product rules.** One loop with the step named in words, no mode picker, no word list, no streaks or scores. Grammar sits on a card behind a tap (the word card: base form, form, a one line why, both forms with audio). Feedback copy is gentle ("Close. Try the double k."), and the amber problem block is reserved for system faults. Record control asks for nothing and is look only.
- **Writing rules.** No em dashes, no hype words, no "not X, but Y" or colon reveals in `design.md`, `design/brief.md` or any visible text. Screen text is plain full sentences.

## Findings

1. **Should fix.** `src/components/RecordControl.module.css` line 43 (recording state, seen in `reference-dark-webkit-full.png` and the light one). The 6 px ring round the teal button is cut off into a rounded square, so a dark box shows behind the circle. The round ring should show fully. Fix: give the row space round the control (padding of 6 px or more) or draw the ring another way, then retake the screenshot in both modes.
2. **Should fix.** The azure meaning is never explained to a learner. Changed words are bold azure on a wash, and a total beginner will see blue words with no hint why. Fix: add one plain sentence the first time, for example "Blue words change between spoken and written Finnish. Tap a word to see why.", as part of the Hear it text pattern in `design.md`. It also covers a second gap: only the changed words look tappable, so "Alex." and "kotoisin" give no sign that they open a card.
3. **Should fix.** `src/sample/HearItSample.tsx` draws its own top bar ("Step 1 of 5") while `SessionFrame` says "Hear it, step 1 of 5". Two versions of the same screen chrome will drift. Fix: build the sample from `SessionFrame` and `FinnishLine`, or label the sample as not the pattern. The sample is not served to learners, so this can wait for the first real screen.
4. **Note.** The changed word wash is drawn at the full 44 px tap height, behind 22 px text. In the sample nearly every word is flagged, so each line becomes a row of tall blue tiles (see the sample screenshots). It reads busy compared with the quiet card around it. See the single change below.
5. **Note.** In dark mode the primary "Continue" pill and the play button are near white and very large next to the dark card, so they pull the eye more than the Finnish. It is correct contrast and matches v2's inverted button idea, but consider a slightly dimmer fill such as #d9d6e4 in dark so the dialogue stays the focus.
6. **Note.** The reference page's spacing and radius swatches show `--radius-lg`, `-xl` and `-pill` as the same shape because the sample box is small. A larger box would make the scale readable. The page is for owner and reviewers only.
7. **Note.** The poor shadow on `--shadow-button` is `none` in dark, so buttons rely on fill alone. That is fine, and the screenshots confirm it works.
8. **Note.** Real screen readers and phones were not tested here (build notes say VoiceOver on a real iPhone is still open). Leave that to the owner's check.

## The single change that would most improve the look

Draw the changed word wash at text height (about 1.4 times the font size) and keep the 44 px tap area as invisible padding, for example with a `::before` hit area on `.word` in `src/components/FinnishLine.module.css`. The dialogue card would read as lines of Finnish with a few lit words, not rows of tall blue blocks, and the lit word would stand out more.

Result: pass
