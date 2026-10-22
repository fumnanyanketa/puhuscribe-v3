# Job 5-design-system: evaluation

Evaluator, 21 October 2026. Current round: round 3, branch `factory/5-design-system` at a65a783 (PR #12, run 39630337390).

## Round 3 re-check

How I tested. I made a fresh Windows clone of the branch (git converting line endings, as on the owner's machine), ran `npm ci`, `npm run check:code`, the unit tests, a normal production build and a `VITE_DESIGN_REFERENCE=1` build. I served the design build locally with `vite preview` (no database settings, so nothing was written to any database). I drove the front page, `/sample/hear-it` and `/design-reference` with my own Playwright script at 375 x 812 in Chromium and WebKit, light and dark, and ran axe myself. I repeated my round 1 break tests on real files, added 17 new ones, and ran the job's own design browser tests. Every evidence file named below is in `evidence/`.

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `eval-docs-and-config-checks.txt` | Unchanged since round 1: the brief records the direction, date, sources and call answers, with no colour codes or sizes. |
| 2 | pass | `eval-docs-and-config-checks.txt` | The wordmark and app icon SVGs and their README are present. The README says the flat icon still awaits the owner's look. |
| 3 | pass | `r3-eval-18-break-tests.txt` (N16), `r3-eval-basics.txt` | A raw `hsl()` colour in the sample CSS turns the test red. The spinner and dots timings are now tokens (`--motion-turn`, `--motion-pulse`). |
| 4 | pass | `r3-eval-basics.txt` | 425 unit tests pass, including the 60 contrast checks. Round 1 already proved the contrast test turns red. |
| 5 | pass | `r3-eval-drive-log.txt`, `r3-eval-18-break-tests.txt` (N15) | No request leaves the app's own address on any page. A Google Fonts import added to a component CSS file turns the test red. |
| 6 | pass | `eval-docs-and-config-checks.txt` | `design.md` still covers every required part. |
| 7 | pass | `r3-eval-7-sample-ready-webkit-light.png`, `r3-eval-drive-log.txt` | The sample now uses the shared `SessionFrame`: "Hear it, step 1 of 4", with Leave session and the action area. Nothing scrolls sideways at 320 px or at 200 percent text, on either page, in either browser or mode. |
| 8 | pass | `r3-eval-drive-log.txt` | No control on the reference page or the sample is under 44 px (words at least 44 tall and 24 wide). The front page "Try again" button is now 109 x 44. |
| 9 | pass | `r3-eval-drive-log.txt` | 35 Tab stops in Chromium and 34 in WebKit (Safari skips links). All are in reading order and show a 2 px or thicker outline, in both modes. |
| 10 | pass | `10-eval-status-line-chromium-light.png` | Unchanged since round 1. |
| 11 | pass | `r3-eval-11-line-washes-chromium-light.png`, `r3-eval-drive-log.txt` | Each word's button is 44 px tall with a clear background. The wash sits at text height (27 px for 22 px text, 21 px for 17 px). All 8 word cards open, close with Escape, and return focus to their word. Enter opens a card with focus inside. |
| 12 | pass | `r3-eval-12-sample-playing-webkit-dark.png`, `r3-eval-12-play-failed-focus-chromium-light.png`, `r3-eval-drive-log.txt` | Play lights the 8 words in order in both browsers and modes, Pause holds "Alex", and Play resumes at "Mist". When a file cannot play, focus stays on the same button, now named "Try again: play a broken file". It stays there through the retry too. Starting a second tone stops the first. |
| 13 | pass | `r3-eval-13-record-ring-webkit-dark.png`, `r3-eval-drive-log.txt` | The 6 px recording ring is whole, and no ancestor clips it. Pressing every record button made zero microphone requests. |
| 14 | pass | `r3-eval-drive-log.txt` | With reduce motion on, the card's transform stays `none` while it opens, in both browsers. |
| 15 | pass | `r3-eval-16-word-card-note-chromium-dark.png` | Every component renders in dark mode in both browsers. |
| 16 | pass | `r3-eval-basics.txt`, `r3-eval-16-word-card-note-webkit-light.png` | The production build holds none of the design pages' code, names or Finnish. The only "olla" match is inside React's word "collapsed". Every word card now ends with "Sample, not reviewed.", and the job's test checks it with the cards open. |
| 17 | pass | `r3-eval-17-front-not-saved-webkit-dark.png`, `r3-eval-front-saved-state.txt`, `r3-eval-drive-log.txt` | With `/api/visits` forced to 503, axe finds 0 violations on the front page in Chromium and WebKit, light and dark. "Try again" is 44 px tall in token colours (light text on #1c1b23 in dark mode). The saved state (fake 201) also has 0 violations. The reference page, the sample and the open word card have 0 violations everywhere. |
| 18 | pass | `r3-eval-18-break-tests.txt`, `r3-eval-18-break-reasons.txt` | All 5 round 1 misses (C, D, J, H, I) now turn the test red. 16 of my 17 new attempts also turned it red, for the right reason. Only `font-variant-caps: all-small-caps` stays green, which is not on the spec's list (see odd things). |
| 19 | pass | `r3-eval-19-front-saved-webkit-dark.png`, `r3-eval-ci-run.txt` | The front page loads only its own stylesheet and fonts. The only visual change is the agreed "Try again" button styling. CI: 126 browser tests passed and 6 skipped (the same 6 as round 1, for the preview link only); the preview job ran 132 tests and all passed. |
| 20 | pass | `r3-eval-basics.txt` | Packages unchanged except `@axe-core/playwright` pinned to 4.13.0. `build.md` explains it is the newest version at least 14 days old. |

Basics: on the fresh Windows clone, `check:code` now passes, because the design files check out with LF endings. The production build has no design pages, and the job's own design browser tests pass locally (88 passed). PR #12 run 39630337390 is green in every job (`r3-eval-basics.txt`, `r3-eval-ci-run.txt`).

Round 1 oddities, rechecked:
- Fixed: `check:code` on a fresh Windows clone.
- Fixed: the `fonts.css` comment now names `tests/design-rules.test.ts`.
- Fixed: focus stays on the play control when it fails and when "Try again" is pressed.
- Fixed: the word cards carry "Sample, not reviewed." and are tested open.
- Fixed: the literal motion timings are now tokens.

Design review items, rechecked:
- Fixed: the changed-word washes sit at text height inside 44 px tap areas.
- Fixed: the recording ring is not clipped.
- Fixed: the sample is built on `SessionFrame`.

### Odd things that are not failures (round 3)

- `font-variant-caps: all-small-caps` passes the banned look test. It gives the same small capitals look as an eyebrow, but the spec lists only `text-transform: uppercase`. The design reviewer covers the rest of the list.
- Still open from round 1, for the owner:
  - Confirm the flat sprout icon.
  - Confirm that tabular numbers in Switzer replace Geist Mono for the record time.
  - The record time will read "0:75" after a minute; job 8 should handle that.
- The sample page's words are plain text, not word buttons, so the sample has no word card. That is acceptable for a look sample, and the reference page has the real component.
- The front page "Try again" button now uses the white pill look from the base styles. Statement 19 allows the base styles, and the coordinator asked for 44 px. Any other unstyled button added later will get the same look.

## Round 1 findings (0f94502)

Round 1 result: fail, on statements 17 and 18. The round 1 evidence keeps its names in `evidence/`, such as `18-eval-break-tests.txt`, `17-eval-front-page-not-saved-webkit-dark.png` and `16-eval-builds-and-scan.txt`.
- **17.** axe found `color-contrast` on the front page "Try again" button in WebKit dark mode when the visit was not saved: 1.81:1 (white on #c0c0c0). The job's own test failed locally; CI passed only because its visit always saved. Fixed in round 3 with token colours and a 44 px size.
- **18.** The banned look test stayed green for five breaks: `--font-heading: 'Inter'` in tokens.css, the `font:` shorthand with Inter, `border-width: 0 0 0 6px`, `text-transform: UPPERCASE`, and a gradient in a .tsx style object. Fixed in round 3.
- **Oddities.**
  - `check:code` failed on a fresh Windows clone because of line endings.
  - A comment in `fonts.css` named a test file that did not exist.
  - Keyboard focus dropped to the page body when a play control failed.
  - The word cards showed unmarked sample Finnish ("olla", "minä"), and the test never opened them.
  - The spinners used literal timings.

  All are fixed in round 3.

Result: pass
