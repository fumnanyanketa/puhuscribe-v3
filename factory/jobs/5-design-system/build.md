# Job 5-design-system: build notes

## Round 3 (21 October 2026): fixes from the evaluator and both reviews

Branch `factory/5-design-system`, draft pull request https://github.com/fumnanyanketa/puhuscribe-v3/pull/12, head a65a783. Checks run: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39630337390 (all green; the database apply job is skipped on pull requests, as designed).
Preview links (behind the Cloudflare Access sign in):
- Reference page: https://factory-5-design-system-puhuscribe-preview.fumnanya.workers.dev/design-reference
- Hear it sample: https://factory-5-design-system-puhuscribe-preview.fumnanya.workers.dev/sample/hear-it

### What I changed, by item

Evaluator:
1. **Statement 17, the front page's "Try again".** It kept the browser's own button style; in WebKit dark mode axe read white text on light grey (1.81:1). `src/styles/base.css` now gives any button with no component style of its own token colours (the white pill: `--color-button-secondary`, `--color-text`, a `--color-control-edge` edge), a pill radius and a 44 px height, at zero specificity so component styles still win. New browser test "[design 17] axe finds no WCAG A or AA problem on the front page when the visit is not saved" routes `/api/visits` to 503, waits for "Try again", runs axe in light and dark in Chromium and WebKit, and checks the button is at least 44 px tall. The Hei! page's markup is unchanged; its button now looks like the app's white pill.
2. **Statement 18, the banned-look test** (`tests/design-css.test.ts`) now reads every declaration, in CSS and in `.tsx` style objects (camelCase keys read as CSS names). It catches a banned font in any custom property such as `--font-heading` and in the `font` shorthand (C, D), one-side thick borders through `border-width`, `border-inline-width` and `border-block-width` lists (J), any letter case (H), and gradients, glass, gradient text, uppercase, one-side borders, banned fonts and `color-mix()` in inline styles (I). 18 new "catches" tests, and an "allows" test proving equal widths, Switzer and Poppins, and words such as "interval" or "International" pass.
3. **Line endings.** `.gitattributes` now has `design/** text eol=lf`, and `design/v2-handoff/** -text` so the handoff stays byte for byte. `git add --renormalize` changed only the two SVGs in `design/assets/` (they had CRLF). A test reads the attributes with `git check-attr`.
4. **fonts.css comment** now names `tests/design-rules.test.ts`.
5. **Focus on the play control.** It is now one button in every state (play, loading, pause, "Try again"), so focus stays on it when playback fails and when "Try again" is pressed. New test "[design 9] [design 12] keyboard focus stays on the play control when it cannot play and on Try again", both browsers.
6. **Finnish on design pages.** The word card takes an optional `note`; the reference page's Finnish lines pass "Sample, not reviewed." to every card. New test "[design 16] every word card on the page is marked" opens all eight cards (two lines, four words each) and checks the note. The sample's note now reads "Sample, not reviewed." in statement 16's words.

Design review:
7. **Washes at text height.** In `FinnishLine`, the button is the invisible 44 px tap area and a face inside it carries the azure wash and the ink lit block, at text height. New test "[design 11] a changed word has its wash drawn at text height inside a 44 px tap area" (button at least 44 px, face under 1.6 times the font size). The sample's own words were already drawn at text height.
8. **First-time hint** on the sample, in the intro line: "Alex meets Sanna. Blue words change between spoken and written Finnish." `design.md` adds it to the Hear it pattern. I left out "Tap a word to see why", because the sample's words are not buttons and the hint must stay true.
9. **Record ring.** The row now has 8 px of padding, so nothing round it clips the 6 px teal ring. Screenshots: `reference-<light|dark>-<chromium|webkit>-record.png`.
10. **The sample's frame is SessionFrame.** Its own top bar and action area are gone. It now says "Hear it, step 1 of 4" (unit 1 has no Use it step). To keep both cards above the player, the intro is shorter: one line plus the hint, and the note became one line.

Security review:
11. **Build test markers** "Could not play" and "Stop recording" are replaced with "Try the states", "This button shows the busy state for two seconds", "No sound yet. Play lights up each word." and "Alex meets Sanna.", which only the design pages hold.
12. **Fonts in git.** Only `src/assets/fonts/**/*.woff2` is binary. `FFL.txt` is `-text`: git leaves its bytes alone, but it shows as text, so gitleaks reads it. The test checks both with `git check-attr`. All five files still match their SHA-256 in the commit.
13. **axe pinned to 4.13.0**, published 11 August 2026 and the newest version at least 14 days old. It brings `axe-core` 4.13.0 (5 August).

Also fixed, from the evaluator's "odd things":
- The record time no longer reads "0:75" after a minute; it shows minutes and seconds.
- The busy and loading rings and the working dots take their timings from new tokens `--motion-turn` and `--motion-pulse`. The motion test no longer exempts endless animations.
- `tests/design-build.test.ts` left `.wrangler/deploy/config.json` pointing at its temporary build: the Cloudflare plugin points `vite preview` at the last build, so after `npm test` a local `vite preview` tried to serve the deleted folder and the browser tests could not start. The test now puts the pointer back as it was. CI was not affected (separate jobs).

Decision recorded by the manager and kept: the record timer uses Switzer with tabular numbers (the owner chose v2's fonts).

### Tests changed this round (none weakened)

- `e2e/design-sample.spec.ts`, "[design 7] the frame names the step in words...": looked for "Step 1 of 5"; now "Hear it, step 1 of 4", the shared frame's wording.
- `e2e/design-sample.spec.ts`, "[design 11] both lines show spoken Finnish first...": checked `/waiting for the native reviewer/`; now checks the exact text "Sample, not reviewed." and the blue words hint.
- `tests/design-build.test.ts`: markers swapped as in item 11; "waiting for the native reviewer" became "Alex meets Sanna." because the sample's note changed. Still nine markers plus the file name check.
- `tests/design-rules.test.ts`: the font attribute test now uses `git check-attr` for the narrower rule and the licence; the motion test lost its exemption for endless animations.
- `tests/design-css.test.ts`: the rule engine was rewritten as above. Every earlier "catches" test is kept and passes.

### Red runs on purpose (files in `factory/jobs/5-design-system/evidence/` on the branch)

- `red-run-round3-css.txt`: each of the evaluator's five breaks (C, D, H, I, J) applied alone to a real file. Each turned `tests/design-css.test.ts` red (1 failed, 42 passed); restored, 43 passed.
- `red-run-round3-browser.txt`: four protections removed together. (1) Without the base button colours, the not-saved front page tests failed in both browsers and modes. In WebKit dark, axe reported `color-contrast: button`; elsewhere the 44 px height check failed. (2) A play button replaced per state lost focus in both browsers. (3) A 44 px tall word face failed the text-height test in both. (4) Cards without the note failed the "Sample, not reviewed." test in both. 10 failed; restored, all pass.

### Checks I ran (in `.worktrees/5-design-system`)

- `npm run check:code`: pass.
- `npm test`: 25 files, 425 tests, pass.
- `VITE_DESIGN_REFERENCE=1 npm run build`: pass.
- `npx playwright test`: 126 passed, 6 skipped (preview only). The two design files `--repeat-each=3`: 264 passed.
- lefthook on every commit: pass. The committed Switzer files match their download hashes.
- GitHub checks on a65a783: all pass (run linked above).

### Uncertain or left open

- Five minutes with VoiceOver on a real iPhone would still catch what automatic checks miss.
- The flat sprout icon still awaits the owner's look.
- Eight unused Poppins Devanagari files ship in `dist/`; phones never download them. Not changed.
- Security note 1 (the live build must run with `VITE_DESIGN_REFERENCE` empty) is for liftoff. `.env.example` lists it empty with a purpose.

### Screenshots (on the branch, `factory/jobs/5-design-system/evidence/`, 375 x 812)

- The sample playing, "oon" lit: `hear-it-light-chromium-playing.png`, `hear-it-dark-chromium-playing.png`, `hear-it-light-webkit-playing.png`, `hear-it-dark-webkit-playing.png` (and `-ready.png` for each).
- The word card open: `reference-<light|dark>-<chromium|webkit>-word-card.png`.
- The record control: `reference-<light|dark>-<chromium|webkit>-record.png`.
- The front page not saved, dark: `front-page-not-saved-dark-chromium.png`, `front-page-not-saved-dark-webkit.png`.
- The whole reference page: `reference-<light|dark>-<chromium|webkit>-full.png`.

### How to run it locally

```
cd .worktrees/5-design-system
npm run dev        # then open http://localhost:5173/design-reference or /sample/hear-it
```
or the built version: `VITE_DESIGN_REFERENCE=1 npm run build`, then `npx vite preview --port 4173`.

## Earlier rounds

### Round 2 (21 October 2026): the rest of the design system, head 0f94502

- Switzer self-hosted from Fontshare (owner's approval in `summary.md`), files unchanged and hash-checked; v2's page fade as the one allowed gradient; components (SessionFrame, Button, StatusLine, FinnishLine with WordCard, PlayControl, RecordControl, Wordmark); the reference page; `design.md`, `design/brief.md`, `design/assets/`; build-time gating with a production build test; Safari 15.4 CSS target; conventions updated; `VITE_DESIGN_REFERENCE` appended to `.env.example` without opening it.
- Git rewrote a byte of `Switzer-Semibold.woff2` on commit (`src/**` was text); caught before pushing and committed again. The altered copy never reached GitHub.
- Red runs: `red-run-round2-css.txt`, `red-run-round2-build.txt`, `red-run-round2-word-card.txt`. Checks run 39618302752 green. CI's Linux WebKit played the test tone (`Audio check | webkit | played`); Windows WebKit cannot, so locally it tests "Could not play".
- Changed tests then: the sample's font test (Poppins 600 and 700, Switzer 400 and 500) and its colour mode test (the fade's colours).

### Round 1 (21 October 2026): the sample screen

- The Hear it sample at `/sample/hear-it` in v2's look with direction A's lit word, bottom player and calmer spacing; the owner approved it.
- Replaced job 2's "[smoke 1] adds no styling" with "[smoke 1] [design 19] loads only its own stylesheet and font files, from its own address, and still no images, icons or media" (same-address stylesheets and fonts required; `document.styleSheets.length === 0` dropped; markup check `style, [style], [class]`). No other job 1 to 4 test changed.
- A WebKit preview run lit a word after Pause; fixed with a flag set at once on Play and Pause; 20 repeats per browser passed.
- I printed `.env.example` once with `cat` (names only, no values).
- Red run: `red-run-tokens.txt`.

Result: checks pass
