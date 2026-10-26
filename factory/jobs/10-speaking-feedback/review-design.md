# Design review, 10-speaking-feedback

Judged from code, CSS and the spec wording. No browser run.

Checked and fine: consent text matches statement 1 word for word (plain sentences, unticked box, two buttons); Say it is step 3 of 3; eight feedback messages match the table with `lang="fi"` on Finnish words and no score or transcript; "Play my recording", "Try again", "Next line"/"Continue" and "I can't speak right now" are present; "Not now" gives "Say the line out loud after the voice." with a quiet "Turn on speaking feedback"; failure states use the spec's exact sentences and always leave "Next line"/"Continue"; Voice settings has one press off for each choice, kept recordings with Play and Delete, and "Delete all my recordings". Layouts use `minmax(0, 1fr)`, `overflow-wrap: anywhere` and `--tap-min` (44 px) throughout. Only tokens are used. No banned styles (no accent bars, eyebrows, pills, gradients, emoji, banned fonts).

## Findings

1. should fix, `src/screens/SayIt.tsx` (feedback state, `shown`): once an attempt gives feedback, the "Line 1 of 3." counter disappears, so a beginner loses their place. Fix: put the line count in the visible heading area (for example next to the dialogue title) so it stays while feedback shows.
2. should fix, `src/screens/SayIt.tsx` (mode change from consent to record, and back): focus is not moved when the consent screen replaces the line view, so keyboard and screen reader users land on nothing. Fix: move focus to the new `h1` (tabIndex -1) on each mode change.
3. note, `src/screens/VoiceSettings.tsx`: turning speaking feedback on takes two presses (open consent, then confirm). This is right, because consent must be shown. No change.
4. note, `src/screens/Voice.module.css` `.check`: the checkbox focus ring relies on the global focus style. Confirm in the axe and keyboard test that the ring is visible in dark mode.
5. note, `src/screens/VoiceSettings.tsx` Delete buttons: `aria-label` starts with the visible word "Delete", so label-in-name is met.

Must fix: 0. Should fix: 2.

Result: pass
