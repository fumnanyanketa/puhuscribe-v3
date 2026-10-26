# Design review: 9-daily-review

Judged from code and CSS only (no browser run). Design system is locked (`design.md`). All new CSS uses tokens, no banned styles found (no accent bars, eyebrows, badges, gradients, emoji, banned fonts). Wording matches the spec for the four front door states, the empty day, "Keep it, step N of N", the three result lines and the finish screen. Field attributes, 44 px letter buttons, "missing word" gap name, `lang="fi"` and the global focus ring (`base.css:72`) are in place.

## Findings

1. Should fix. `src/screens/ReviewItemView.tsx` (play control row) and `src/components/GapLine.tsx` (label). "Spoken" or "Written" appears twice on the prompt, once as the band label and again next to the play button, which is noise for a screen reader and a beginner. Fix: drop the extra label beside the control, or merge so the label shows once (the control already has the name "Play the spoken line").
2. Note. `src/screens/KeepIt.tsx`: the `heading` ref is never focused; focus goes to the field or "Next". Fine for keyboard use, but a new item is not announced except by the field label. Consider announcing "Word 3 of 15." through the status area.
3. Note. `src/components/GapLine.module.css`: the blank is a fixed 3.2em for every word, so it hints nothing about length (good). Contrast of the 2 px rule uses `--color-text`, fine in both modes.
4. Note. Phone width (375 px): lines use `overflow-wrap: anywhere`, the letter buttons wrap, the grid uses `minmax(0, 1fr)`. No overflow expected. Axe and the 320 px / 200 percent checks remain with the browser tests.

Result: pass
