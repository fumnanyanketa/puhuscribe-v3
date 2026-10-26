# Design review, job 12-units-1-3

Judged from code, CSS and spec wording only (no browser run).

## Findings

1. Note. `src/components/PatternsPanel.tsx`, form shapes and "Where you met it" repeat "Spoken"/"Written" labels per form. This is long for a sheet but follows the spec. No change.
2. Note. `src/components/PatternsPanel.module.css` `.group:first-of-type` margin relies on the sections being the first `section` in the body. It works today. Low risk.
3. Note. The sheet is a dialog with a Close button, Escape and tap outside. Focus goes to the title, then the form's group heading. Headings use `tabIndex=-1`, so there is no outline and no Tab stop. This is fine.

## Checked and fine

- Entry is a quiet text button on the word card, only when `onPatterns` is passed. The panel has no address and no menu link.
- No counts, scores or study controls in the panel. It is grouped by form name, not a word list.
- Finnish text uses `overflow-wrap: anywhere` on shapes, lines, base form, group names and facts. `.shapes` uses auto-fit with `minmax(8rem, 1fr)`, and `min-width: 0` is set on flex children. The title wraps and Close moves under it at large text.
- Tap targets use `--tap-min` (44 px) for Close, Button and the small PlayControl. Global `:focus-visible` exists in `base.css`.
- Colours are tokens only, with dark values for the spoken and written label colours. Reduced motion is handled.
- No banned styles found: no accent bars, eyebrows, pills, gradients or emoji. The Close icon is a functional, aria-hidden cross.

Must fix: 0. Should fix: 0.

Result: pass
