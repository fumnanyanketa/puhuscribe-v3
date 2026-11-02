# Follow up: Keep it marks only the answer

Branch `factory/19-keep-it-marks`, from main at 2ad3d9f (job 19 merged). Not merged.

## What changed

On the Keep it result (right and close), only the answer word is marked, in both lines: the peach wash, peach deep text, and bold in the spoken line. The box that marks a word changing between spoken and written (mä and minä) is turned off on that screen only, so two neighbouring highlighted words no longer compete. Hear it, Say it, the word card and the finish screen still show that box.

Job 9's rules are kept. The other register still appears only after an answer, the answer is still read out as ", the missing word" once per line, and the words still open their cards.

## Colour

The drawn peach deep (`#b8532f`) on the peach wash is 4.0 to 1. That is under the 7 to 1 floor for a Finnish line in `src/styles/contrast-pairs.ts`, and under the 4.5 to 1 floor for any text. So the mark keeps `--color-changed-text` (`#7f3618`), the peach deep the design system darkened to 7 to 1 for this wash (spec statement 6, "colours are slightly darker where the drawings fail the floors"). The floors and the pair list are unchanged. The bold weight in the spoken line is new, as drawn.

## Tests

In `e2e/redesign-lesson.spec.ts`, round 6 block:

- `[redesign 31] Keep it right: exactly one word per line carries a mark...` and the same for close. In each line, every word is checked for a wash, a ring or a colour of its own. Exactly one word has any of them, and it is maksaa, with the wash, no ring, the 7 to 1 peach deep, weight 700 in the spoken line and 400 in the written line. Red on main in both browsers (mä was the second mark), green after the fix.
- `[redesign 2] the changed word box stays on Hear it`.

## Evidence

WebKit, taken as in round 6 (drawing left at 375 px wide with its top 32 px cut, app right at 375 x 812):

- `evidence/round6-pairs/27-keep-it-right-pair-fix.png`
- `evidence/round6-pairs/28-keep-it-close-pair-fix.png`

## Checks

- Local: `npm run check:code` passes. `npx vitest run`: 1187 passed, 2 skipped. `npx playwright test e2e/redesign-lesson.spec.ts`: all pass except three Say it recording tests in WebKit, which cannot record on this computer (known since round 6); the design reference page shows "No connection" locally, so its tests need the GitHub run.
- GitHub, `gh workflow run checks.yml --ref factory/19-keep-it-marks`: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41467560193 passed. Type check, lint and format, dependency check, secret scan, database tests, Python tests, browser tests (Chromium and WebKit) and unit tests all pass. The after merge jobs and the preview link were skipped, as on every branch run.

Result: checks pass
