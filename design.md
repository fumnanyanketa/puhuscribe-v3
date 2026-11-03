# PuhuScribe design system

The locked design system for PuhuScribe v3. It began as job 5-design-system (`factory/jobs/5-design-system/spec.md`) and was rebuilt from the owner's approved drawings of 1 November 2026 in job 19-redesign (`factory/jobs/19-redesign/spec.md`). The design reviewer checks every screen against this file. Why the look is what it is, and what it borrows from, is in [design/brief.md](design/brief.md) and `design-drafts/README.md`.

- Every value lives in `src/styles/tokens.css` as a CSS custom property. Components use those names and never a raw colour (`tests/design-tokens.test.ts` checks it).
- The reference page, `/design-reference`, shows every value and every component in every state, and each colour that was made darker next to the drawn one. It exists in local development (`npm run dev`) and on preview links, behind the Cloudflare Access sign in. Learners never see it, and a normal build leaves it out (`tests/design-build.test.ts`).
- The parts live in `src/components/`, one PascalCase `.tsx` file with a `.module.css` file beside it.
- The drawings are the source of truth for the look: `design-drafts/v1-screens.html` (the lesson, the account, privacy, feedback and error screens), `design-drafts/road-journey.html` (the road, the fells, the opening animation), `design-drafts/written-colour.html` option A (slate blue) and `design-drafts/numbers-question.html` option C (the finished lesson). They are drawn 280 px wide; real sizes at 375 px are the drawn sizes times 1.25, raised to the floors below. They stay unchanged in `design-drafts/` as history.

## The current look

The soft, milky look of the owner's reference (`design-drafts/reference-soft-gym-app.jpg`), approved on 1 November 2026: a mint to off white to peach wash behind every screen with a fine grain on it, milky white panels, a small landscape behind the top of each screen, and the road to the A1 sun with the A2, B1 and B2 fells beyond it on the home screen. There is no mascot. As little text as possible: one short line per screen. The look is light only (owner's call 4): the app declares itself light, so a phone's dark setting does not darken it.

Where each colour may appear (owner's call 1, answer A: peach is used as drawn, which is wider than the first rule):

- **Mint**: everything you tap (the primary pill, the play controls, the record button, links such as "How it works"), the progress fill, the done signs, the travelled road, the brand mark, and spoken Finnish (the spoken dot, the "People say" tile). `tests/design-tokens.test.ts` lists the files that may use the spoken tokens.
- **Slate blue**: written Finnish only. The written dot and the written line, the "Books write" tile and its play control. Nothing else is slate.
- **Peach**: the words that change between spoken and written (peach text on a peach wash, in both lines), the ring round the next sign, the sun and the fell flags, the recording state, gentle notes (a learner's attempt, never red), the save note, the delete action and the error mark. The changed word has its own tokens (`--color-changed-text`, `--color-changed-wash`) that nothing else uses.
- **Ink and quiet ink**: all other text.

Rules from the owner that win over anything below:

- No mascot. The line card keeps its two dots joined by a dotted line.
- The journey is the heart of the app, but it must not look like Duolingo's winding path of round nodes: it is a road in perspective with signs.
- Only buttons are pills. No badges or pills scattered as decoration.
- In the owner's words: "at no point should the app lose its aesthetic feel. I don't want it to look like every Claude deployed slop." Take the look from the owner's references, never from common app patterns.

## Type

Poppins everywhere (owner's call 3 of job 19-redesign), self-hosted. Weight 600 for headings and Finnish lines, 500 for buttons and signs, 400 for body text, 700 for changed words.

Sizes, all in `rem` so a phone's larger text setting scales every line. They are the drawn sizes times 1.25, raised to the floors:

| Token               | Size    | For                                            |
| ------------------- | ------- | ---------------------------------------------- |
| `--text-display`    | 36 px   | the reference page title                       |
| `--text-word-card`  | 32 px   | the word at the top of its card                |
| `--text-line-large` | 21 px   | the spoken line on Understand it               |
| `--text-title`      | 20 px   | the lesson title, a sheet title                |
| `--text-line`       | 19 px   | the spoken line on the line card               |
| `--text-heading`    | 17 px   | card and section headings                      |
| `--text-written`    | 17 px   | the written line                               |
| `--text-body`       | 15 px   | body text, sheet text, privacy paragraphs      |
| `--text-button`     | 14.5 px | button text                                    |
| `--text-reading`    | 14 px   | the least size of a sentence of reading text   |
| `--text-sign`       | 13 px   | the names on the road signs                    |
| `--text-small-plus` | 12.5 px | small labels                                   |
| `--text-small`      | 12 px   | hints, the speaker name, captions, fell labels |

Rules:

- **Floors.** No text is under 12 px at default settings. Any sentence of reading text is at least 14 px. Spoken Finnish is at least 18 px and written Finnish at least 17 px (the project's floor from job 5, kept by owner's call 2: the drawn 14.5 px written line was too small). `tests/design-tokens.test.ts` checks the tokens, and no component sets a font size of its own.
- **Line length.** A Finnish line is at most `--measure-line` (34 characters) wide, so a learner reads it in one sweep.
- **ä, ö and å stay readable.** Finnish is never smaller than 17 px, its line height is 1.4 (`--leading-line`), and its letter spacing is never tighter than `--tracking-line` (-0.01em), so the dots keep clear of the line above. Poppins includes ä, ö, å, Ä, Ö and Å; a browser test checks they render.
- **Long words wrap.** Finnish compounds can be very long. Lines use `overflow-wrap: anywhere`, so nothing scrolls sideways at 320 px or with text at 200 percent. A 40 letter word wraps inside its box at 375 px.
- **No italics.** No italic font file is loaded, and the base styles set `em`, `i` and similar elements upright. Emphasis comes from weight.
- **Numbers** use `font-variant-numeric: tabular-nums`, so counters and times do not jump.

### Fonts and their licences

- **Poppins**: `@fontsource/poppins` from npm, pinned in `package.json`. SIL Open Font License 1.1. Commercial use and self-hosting allowed. It is served from the app's own address. No request goes to Google Fonts or any other font service, so no learner's IP address leaves for one. The drawings load Poppins from Google Fonts; the app must not.
- **Switzer** is no longer used (owner's call 3, 1 November 2026). Its files were never in this public repository (the licence forbids it); the private fetch step and `docs/fonts.md` stay for history, and nothing in the app imports them.

## Colour

Light only. Values are hex, because `light-dark()` and `color-mix()` are too new for older iPhones. Where a colour in the drawings failed one of the project's contrast floors (owner's call 2, answer A: keep every floor), it is as little darker as the floor needs. The comment on each such token in `tokens.css` names the drawn value, and `/design-reference` shows the built colour beside the drawn one.

| Drawn                                       | Built   | Why                                                                  |
| ------------------------------------------- | ------- | -------------------------------------------------------------------- |
| mint #23917a                                | #1e856f | white text on the mint pill was 3.9:1, the floor is 4.5:1            |
| slate #4f6d94                               | #38527a | written Finnish needs 7:1, the drawn slate was 5.3:1 on white        |
| slate soft #e4ebf4                          | #edf2f8 | slate on the "Books write" tile reaches 7:1                          |
| peach deep #b8532f as the changed word text | #7f3618 | the changed word on its wash was 4.0:1, Finnish needs 7:1            |
| peach #ee8763 for marks                     | #db7249 | the ring round the next sign and the record button need 3:1 on white |
| quiet #637570                               | #556863 | quiet text was 3.9:1 on the mint end of the wash, the floor is 4.5:1 |

| Token                              | Value     | Purpose                                                                 |
| ---------------------------------- | --------- | ----------------------------------------------------------------------- |
| `--color-wash-top`                 | #cbede1   | the mint end of the wash, as drawn                                      |
| `--color-wash-middle`              | #f7f8f6   | the middle, as drawn                                                    |
| `--color-wash-bottom`              | #fbe2d1   | the peach end, as drawn                                                 |
| `--color-surface`                  | #ffffff   | sheets, solid cards, fields, the word card                              |
| `--color-panel`                    | #fbfdfc   | milky panels, drawn as 80 percent white, written here as a solid colour |
| `--color-panel-edge`               | #ffffff   | a panel's 1 px edge, as drawn                                           |
| `--color-track`                    | #c3ddd2   | progress segments not reached, rails                                    |
| `--color-card-edge`                | #1b2a2614 | a 1 px hairline round a solid card, 8 percent ink                       |
| `--color-control-edge`             | #1e856f   | the edge of a white control, 3.6:1 on the mint end of the wash          |
| `--color-text`                     | #1b2a26   | ink, as drawn                                                           |
| `--color-text-quiet`               | #556863   | drawn #637570 was 3.9:1 on the mint end of the wash; this reaches 4.7   |
| `--color-mint`                     | #1e856f   | drawn #23917a, white on it was 3.9:1; this reaches 4.5                  |
| `--color-mint-hover`               | #1b7a65   |                                                                         |
| `--color-mint-pressed`             | #176a58   |                                                                         |
| `--color-mint-deep`                | #1a6f5d   | text on mint soft, "How it works", the current sign, as drawn           |
| `--color-mint-mid`                 | #74bba9   | the dotted connector, quiet edges, as drawn                             |
| `--color-mint-soft`                | #d6efe7   | rails and soft fills, as drawn                                          |
| `--color-spoken`                   | #1e856f   | the spoken dot and the wave                                             |
| `--color-spoken-text`              | #1a6f5d   | the "People say" label                                                  |
| `--color-spoken-soft`              | #d6efe7   | the "People say" tile and the spoken line's edge                        |
| `--color-written`                  | #38527a   | drawn #4f6d94 was 5.3:1 on white, Finnish lines need 7:1                |
| `--color-written-soft`             | #edf2f8   | drawn #e4ebf4, lightened so slate on it reaches 7:1                     |
| `--color-changed-text`             | #7f3618   | drawn #b8532f was 4.0:1 on its wash; this reaches 7:1                   |
| `--color-changed-wash`             | #fde4d8   | as drawn                                                                |
| `--color-peach`                    | #db7249   | drawn #ee8763; marks need 3:1 on white                                  |
| `--color-peach-soft`               | #fde4d8   | gentle notes and the save note, as drawn                                |
| `--color-peach-deep`               | #b8532f   | the delete pill and the mark on a gentle note, as drawn                 |
| `--color-current-word`             | #1b2a26   |                                                                         |
| `--color-current-word-text`        | #f4faf8   |                                                                         |
| `--color-current-line`             | #1e856f   | ring round the line that is playing                                     |
| `--color-word-hover`               | #e6f2ed   |                                                                         |
| `--color-button`                   | #1e856f   | the flat mint pill (owner's call 5)                                     |
| `--color-button-hover`             | #1b7a65   |                                                                         |
| `--color-button-pressed`           | #176a58   |                                                                         |
| `--color-button-text`              | #ffffff   |                                                                         |
| `--color-button-secondary`         | #ffffff   | the white pill with a very pale edge                                    |
| `--color-button-secondary-hover`   | #f1f8f5   |                                                                         |
| `--color-button-secondary-pressed` | #e3f1ec   |                                                                         |
| `--color-danger`                   | #b8532f   | the "Delete for good" pill                                              |
| `--color-danger-hover`             | #a64a29   |                                                                         |
| `--color-danger-pressed`           | #94411f   |                                                                         |
| `--color-danger-text`              | #ffffff   |                                                                         |
| `--color-danger-ink`               | #8c3b1a   | the small "Delete my account" text on the wash, 6.1:1 on the peach end  |
| `--color-disabled`                 | #e3ebe8   |                                                                         |
| `--color-disabled-text`            | #5f706b   |                                                                         |
| `--color-focus`                    | #1b2a26   |                                                                         |
| `--color-wave-played`              | #1e856f   |                                                                         |
| `--color-recording`                | #db7249   | the record control while recording                                      |
| `--color-recording-text`           | #ffffff   |                                                                         |
| `--color-switch-off`               | #7d8f89   | the track of a switch that is off                                       |
| `--color-scrim`                    | #1b2a2666 | dims the screen behind the first lesson tip's lit card                  |
| `--color-brand`                    | #1e856f   |                                                                         |
| `--color-brand-leaf`               | #ffffff   |                                                                         |
| `--color-brand-leaf-back`          | #bfe3d8   |                                                                         |
| `--color-wordmark-quiet`           | #6f817b   |                                                                         |
| `--color-gentle-wash`              | #fde4d8   |                                                                         |
| `--color-gentle-mark`              | #b8532f   |                                                                         |
| `--color-problem-wash`             | #fff3e0   | system faults only, such as no connection                               |
| `--color-problem-text`             | #7a3d00   |                                                                         |
| `--color-problem-edge`             | #a35200   |                                                                         |
| `--color-backdrop`                 | #1b2a2666 |                                                                         |

### Contrast

Every pairing below is checked by `tests/design-tokens.test.ts`, which fails if this table and the test's list (`src/styles/contrast-pairs.ts`) differ. The reference page shows the same results. Floors: Finnish lines and word card text 7:1; all other text 4.5:1; focus outline, control edges, markers and the recording state 3:1. By my hand calculation the drawn colours were under their floor in the five places the first table lists, and the build changed those and no others.

| Text or mark                | On                         | Needs | Result | Used for                                                           |
| --------------------------- | -------------------------- | ----- | ------ | ------------------------------------------------------------------ |
| `--color-text`              | `--color-panel`            | 7:1   | 14.6:1 | a spoken Finnish line on the line card                             |
| `--color-text`              | `--color-surface`          | 7:1   | 14.9:1 | Finnish in a sheet and in the word card                            |
| `--color-text`              | `--color-spoken-soft`      | 7:1   | 12.3:1 | the spoken word on its tile                                        |
| `--color-text`              | `--color-word-hover`       | 7:1   | 13.0:1 | a Finnish word under the finger                                    |
| `--color-written`           | `--color-panel`            | 7:1   | 7.7:1  | the written Finnish line on the line card                          |
| `--color-written`           | `--color-surface`          | 7:1   | 7.9:1  | written Finnish in a sheet                                         |
| `--color-written`           | `--color-written-soft`     | 7:1   | 7.0:1  | the written word on its tile                                       |
| `--color-changed-text`      | `--color-changed-wash`     | 7:1   | 7.1:1  | a changed word on its wash                                         |
| `--color-current-word-text` | `--color-current-word`     | 7:1   | 14.1:1 | the word being spoken                                              |
| `--color-text-quiet`        | `--color-surface`          | 4.5:1 | 5.9:1  | quieter text in a sheet                                            |
| `--color-text-quiet`        | `--color-panel`            | 4.5:1 | 5.8:1  | quieter text on a panel                                            |
| `--color-text-quiet`        | `--color-wash-top`         | 4.5:1 | 4.7:1  | quieter text on the mint end of the wash                           |
| `--color-text-quiet`        | `--color-wash-middle`      | 4.5:1 | 5.6:1  | quieter text in the middle of the wash                             |
| `--color-text-quiet`        | `--color-wash-bottom`      | 4.5:1 | 4.8:1  | quieter text on the peach end of the wash                          |
| `--color-text-quiet`        | `--color-spoken-soft`      | 4.5:1 | 4.9:1  | quieter text on a soft mint fill                                   |
| `--color-text-quiet`        | `--color-written-soft`     | 4.5:1 | 5.3:1  | quieter text on the slate tile                                     |
| `--color-text`              | `--color-wash-top`         | 4.5:1 | 11.9:1 | headings on the mint end of the wash                               |
| `--color-text`              | `--color-wash-bottom`      | 4.5:1 | 12.0:1 | headings on the peach end of the wash                              |
| `--color-spoken-text`       | `--color-spoken-soft`      | 4.5:1 | 5.0:1  | the "People say" label on its tile                                 |
| `--color-mint-deep`         | `--color-surface`          | 4.5:1 | 6.0:1  | the "How it works" link and a sign number                          |
| `--color-mint-deep`         | `--color-panel`            | 4.5:1 | 5.9:1  | mint text on a panel                                               |
| `--color-mint-deep`         | `--color-mint-soft`        | 4.5:1 | 5.0:1  | mint text on a soft mint fill                                      |
| `--color-peach-deep`        | `--color-surface`          | 4.5:1 | 4.9:1  | the name on the next sign                                          |
| `--color-peach-deep`        | `--color-panel`            | 4.5:1 | 4.8:1  | the next stop name on the card                                     |
| `--color-danger-ink`        | `--color-wash-bottom`      | 4.5:1 | 6.1:1  | the "Delete my account" link on the peach end of the wash          |
| `--color-danger-ink`        | `--color-wash-middle`      | 4.5:1 | 7.2:1  | the "Delete my account" link in the middle of the wash             |
| `--color-button-text`       | `--color-button`           | 4.5:1 | 4.5:1  | text on the mint pill                                              |
| `--color-mint-deep`         | `--color-button-secondary` | 4.5:1 | 6.0:1  | text on the white pill                                             |
| `--color-danger-text`       | `--color-danger`           | 4.5:1 | 4.9:1  | text on the delete pill                                            |
| `--color-text`              | `--color-gentle-wash`      | 4.5:1 | 12.3:1 | a gentle note                                                      |
| `--color-peach-text`        | `--color-gentle-wash`      | 4.5:1 | 5.0:1  | the words of a gentle note, peach as drawn                         |
| `--color-peach-text`        | `--color-peach-soft`       | 4.5:1 | 5.0:1  | the review count and the guest note on the account page            |
| `--color-text-quiet`        | `--color-sign-num`         | 4.5:1 | 5.3:1  | the "+6" chip of the new words                                     |
| `--color-problem-text`      | `--color-problem-wash`     | 4.5:1 | 7.7:1  | a problem message                                                  |
| `--color-focus`             | `--color-wash-top`         | 3:1   | 11.9:1 | the focus outline on the mint end of the wash                      |
| `--color-focus`             | `--color-wash-middle`      | 3:1   | 14.0:1 | the focus outline in the middle of the wash                        |
| `--color-focus`             | `--color-wash-bottom`      | 3:1   | 12.0:1 | the focus outline on the peach end of the wash                     |
| `--color-focus`             | `--color-surface`          | 3:1   | 14.9:1 | the focus outline in a sheet or on a card                          |
| `--color-focus`             | `--color-panel`            | 3:1   | 14.6:1 | the focus outline on a panel                                       |
| `--color-control-edge`      | `--color-surface`          | 3:1   | 4.5:1  | the edge of a white control in a sheet                             |
| `--color-control-edge`      | `--color-panel`            | 3:1   | 4.4:1  | the edge of a white control on a panel                             |
| `--color-control-edge`      | `--color-wash-top`         | 3:1   | 3.6:1  | the edge of a white control on the mint end of the wash            |
| `--color-control-edge`      | `--color-wash-bottom`      | 3:1   | 3.6:1  | the edge of a white control on the peach end of the wash           |
| `--color-mint`              | `--color-progress-track`   | 3:1   | 4.5:1  | the filled part of a progress bar beside the pale part not reached |
| `--color-mint`              | `--color-mint-soft`        | 3:1   | 3.7:1  | a lesson done beside a lesson not done on the road card            |
| `--color-button`            | `--color-surface`          | 3:1   | 4.5:1  | the play control in a sheet                                        |
| `--color-button`            | `--color-panel`            | 3:1   | 4.4:1  | the play control and the mint pill on a panel                      |
| `--color-button`            | `--color-wash-top`         | 3:1   | 3.6:1  | the mint pill on the mint end of the wash                          |
| `--color-current-line`      | `--color-panel`            | 3:1   | 4.4:1  | the ring round the line that is playing                            |
| `--color-peach`             | `--color-surface`          | 3:1   | 3.2:1  | the ring round the next sign                                       |
| `--color-recording`         | `--color-panel`            | 3:1   | 3.2:1  | the record control while recording                                 |
| `--color-recording-text`    | `--color-recording`        | 3:1   | 3.2:1  | the wave and stop mark on the record control                       |
| `--color-switch-off`        | `--color-surface`          | 3:1   | 3.4:1  | a switch that is off                                               |
| `--color-gentle-mark`       | `--color-gentle-wash`      | 3:1   | 4.0:1  | the mark on a gentle note                                          |
| `--color-problem-edge`      | `--color-problem-wash`     | 3:1   | 5.1:1  | the edge of a problem message                                      |

### The page wash and the grain

The page background is the drawings' wash: `linear-gradient(165deg, #cbede1 0%, #f7f8f6 50%, #fbe2d1 100%)`, mint at the top left to peach at the bottom right. It is the one CSS gradient allowed, an exception the owner approved on 21 October 2026 for the page background only, and it changed colours on 1 November 2026. It is declared once, as `--ground-wash` in `tokens.css`, and used once, on `html` in `base.css`. Every other CSS gradient, `backdrop-filter` (frosted glass) and gradient text stay refused (`tests/design-css.test.ts`). Gradients inside the landscape's inline SVG are drawn art and not CSS.

The fine grain is an inline SVG noise (`--grain`, no gradient, no request) on `body::before` at 7 percent. It sits on the ground behind panels and text, so it cannot change a text contrast.

### Panels

Milky panels, sheets and cards take their fill, edge, shadow and corner from `--panel-fill`, `--panel-edge`, `--panel-shadow` and `--panel-radius` (sheets use `--sheet-radius`). No component sets its own. A panel is an opaque near white (`--color-panel`), so every contrast on it is exact; the drawings' 80 percent white is not reproduced, because see through panels would let the wash change text contrast.

## Spacing, corners and motion

- **Spacing** follows a 4 px scale: `--space-1` 4 px up to `--space-9` 56 px. Spacing is in px on purpose: when a learner makes the text larger, the text grows and the margins stay, so lines keep their room.
- **Corners**: `--radius-word` 6 px (a word's highlight), `--radius-sm` 14, `--radius-md` 20, `--radius-lg` 26, `--radius-xl` 32, `--radius-pill` (buttons); panels 22 px and sheets 28 px.
- **Tap targets** are at least `--tap-min` (44 px) both ways. Words inside a sentence are inline targets: at least 44 px tall and 24 px wide (`--word-min-width`).
- **Motion** is quiet: colour and opacity change over `--motion-fast` (150 ms, `--motion-ease`), and sheets rise over `--motion-sheet` (220 ms, `--motion-ease-out`). No bounce. A button press moves 1 px down. The busy and loading rings turn once per `--motion-turn` (800 ms), the working dots fade over `--motion-pulse` (1.2 s), and the "you" marker on the road pulses over `--motion-marker` (2 s). The opening animation runs `--motion-intro` (4.5 s) and has a Skip button.
- **Reduce motion.** When the phone's reduce motion setting is on, nothing slides, scales, draws or pulses: sheets fade in instead of rising, the opening animation becomes a crossfade of `--motion-fade` (600 ms) or less, transitions stop, and the busy and loading marks stand still. Every component file that moves has a `prefers-reduced-motion: reduce` block (`tests/design-rules.test.ts`).

## Components

### Landscape (`Landscape`, `RoadScene`)

A small landscape drawn in inline SVG from fixed shapes and numbers: no image file, no request, no third party. Its colours are the `--land-*` tokens, and the evening set (`data-land="evening"`) swaps in for Done for today. It is `aria-hidden`. The band sits behind the top of every screen except the road, about 210 px high at 375 px, and fades into the wash (the fade is drawn inside the SVG). The road scene is the home screen's picture (see "The road").

### Session frame (`SessionFrame`)

Every lesson screen sits in it. The landscape band, a 44 px cross in a milky round, a progress bar and the step name at the right. The bar fills by the share of the lesson done: finished steps plus the share of the current step. Its accessible name is the old words, for example "Hear it, step 1 of 5". The cross opens the sheet "Leave this lesson?" with "Keep going" and "Leave". On the finish screen it leaves at once. Only the content area scrolls. The action area at the bottom stays in view and keeps clear of the iPhone home bar with `env(safe-area-inset-bottom)`. The learner never picks a mode.

Options: `steps` gives the session's own list of steps; `finished` is for the finish screen (the bar is full); `progress` is the share of the current step that is done; `stepHeading` makes the step name the screen's `h1`, and `hideStepName` hides it from the eye where the drawing shows only the question.

### Sheets (`Sheet`)

A bottom sheet is a native `<dialog>` opened with `showModal()`, so the page behind cannot be used and Tab stays inside. It rises from the bottom (fades with reduced motion), has a small handle, closes with Escape and with a tap on the dimmed page unless it must not, moves focus in when it opens and gives it back to what had it before. While it is open the page behind cannot scroll. The leave sheet, the word card, the speaking consent sheet and the first lesson tip use the same rules.

A sheet opened by a button gives that button as `returnFocus`, so focus goes back to it when the sheet closes. The leave sheet gives the cross, the consent sheet in Voice settings gives the Speaking feedback switch, and in Say it focus goes back to the quiet "Turn on speaking feedback" button once the sheet has closed. The word card and the patterns panel give focus back to their word and button themselves. Safari does not focus a button that is tapped, so without it focus would land on the page.

### Buttons (`Button`)

- **Primary**: the flat mint pill with the small arrow circle, 52 px tall, a plain soft shadow and no glow (owner's call 5). One per screen, for the main action, such as "Continue".
- **Secondary**: the white pill with a very pale mint edge and a soft shadow, as drawn (round 6), 52 px tall. Its words name it, so the edge only decorates; focus shows the ink outline. For a second choice next to a primary.
- **Quiet**: small quiet text (12.5 px) with a soft mint underline, at least 44 px tall. For a minor action.
- **Mint**: mint text with no underline ("Why does it change?", "More about your voice").
- **Danger**: the deep peach pill, for "Delete for good" only.

A plain `<button>` with no component style of its own gets the secondary look from the base styles: token colours, an edge and a 44 px height, so the browser's own button colours never decide its contrast (job 5's lesson: WebKit's defaults failed contrast). Every button sets explicit token colours.

States: hover (a little darker), pressed (darker, 1 px down), keyboard focus (the outline below), disabled (grey, not focusable), busy. A busy button keeps its size, ignores presses, shows a still or turning ring, and tells screen readers what is happening with a full sentence, for example "Saving your answer.".

### Keyboard focus

Every control works with a keyboard alone, in reading order. Focus shows a solid outline `--focus-width` (3 px) thick, `--focus-offset` (2 px) away, in `--color-focus` (ink), at least 3:1 against whatever it sits on. It uses `:focus-visible`, so it appears for the keyboard and not for every tap.

### Status line (`StatusLine`)

One status line per screen, with `role="status"` so screen readers announce it. It always holds one full sentence ending with a full stop. Three styles, which differ in wording and shape as well as colour:

- **Neutral**: plain quiet text, for what is happening ("Saving your answer.").
- **Gentle**: a rounded peach note with a small open circle, for the learner's attempts ("Close. Try the double k."). Never red, never an alarm word.
- **Problem**: a square-cornered amber block with an edge all round and a filled square, for system faults only ("No connection. Check your internet, then try again."). A learner's mistake never uses it.

### The road (`RoadScreen`, `RoadPicture`, `RoadCard`, `RoadTop`)

The home screen. The wordmark header, "Today's session", the lead sentence, the can do line and the link list of the old front door are gone; the Voice settings, Privacy notice and Send feedback links live on the account page. One visually hidden `h1`, "Your road to A1".

- **The scene.** Inline SVG in the 280 x 620 drawing box, in two layers (the backdrop, then the road) so the opening animation can draw the road on its own: the sky, the A1 sun low on the horizon with "A1" on it, three fells beyond it with summit flags and the real text labels A2, B1 and B2, a pine ridge, and the road winding in perspective toward the sun. The stretch the learner has travelled has a mint centre line. The box is 112 percent of the screen width and sits 56 px above the screen's top, so the sun is at the same height on every phone.
- **Stops are signs.** Five at a time: the current stop, up to two before it, and the rest after it, shifted so five always show. A sign is a list item, a number and a name on a pole, never a button: tapping one does nothing. The five form one ordered list named "Stops on your road", and each item reads like "Stop 3, Grocery store, current". Four states: done (filled mint with a tick), current (ringed in mint, number in mint), next (a peach ring, only on the Stop finished card) and later (quiet). Names wrap, and the text never shrinks below 12 px. Names are text, never HTML.
- **The "you" marker** is a white dot with a mint ring on the road at the current stop, with a slow pulse that stops under reduced motion.
- **Signs on a short phone or at large text.** Five signs show when there is room. When any two boards, or a board and the top bar, would touch, the road shows fewer: the sign of the current stop and the next one are always kept, then one more on alternate sides, and the gap between signs grows with the tallest board. A board that would run past an edge of the screen is nudged back inside. The card stops at 42 percent of the screen height and its inside scrolls, so the road, the bar and the account button stay in view at 320 px with text at 200 percent.
- **Said once.** Keep it draws "Type the missing word" once, as the field's title; the status line carries it for screen readers. The crash screen draws "Something went wrong" once, as its title; the problem sentence stays in the page for screen readers.
- **The travelled road** is mint from the bottom of the road up to the "you" marker (so it is always seen between the card and the marker), with mint edges. Nothing is drawn while nothing is travelled. The road's bend is the drawing's 34 (round 6).
- **The top** holds only the progress bar (12 pieces, one per three stops, solid mint when all three are done and solid pale white with no outline otherwise, as drawn; mint is 4.5 to 1 on the pale piece) and the account button, a 44 px round named "Your account" that shows the first letter of the learner's email, a G for a guest, or a plain person mark.
- **The card at the bottom** is one milky panel, by state. Day one: stop 1's name, "Stop 1, 4 short lessons", "Start", "Have an account? Sign in", and small, the protected guest line and "Privacy notice". Recap, after the first-open questions: see "The first-open questions and the recap card". Start or continue: the stop's name, "Stop 3, lesson 2 of 4", the lesson pieces and "Start" or "Continue". Review: "Review", "About 4 minutes" (a fixed rule of 18 seconds a word), the count and "Start review". Stop finished: the stop and its can do sentence, "Next stop" and the next name, "Continue". Done for today and the end of the road: the evening sky and no button. The existing messages show as one plain line in the same card.
- **Small phones.** The signs are placed above the card whatever its height, so the card never covers the current sign or the marker. At 320 px wide and 200 percent text nothing scrolls sideways.
- **Loading** shows the sprout mark on its mint tile and three fading dots, then the road. **No connection** shows a cloud with a slash, "No connection", "Your progress is safe. Check your internet connection, then try again." and "Try again" (the first sentence only where nothing waits to be saved).

### The opening animation

It plays every time the road opens, for everyone: a first visit, a returning guest, a signed in learner, after a refresh and when coming back from a lesson (owner, 3 November 2026; before that it played only on a device with no account). About 4.5 seconds, CSS only: the landscape fades in, the road is drawn from the bottom, the sun rises, the A2, B1 and B2 fells appear, the signs pop in (with one approved spoken line as a speech bubble on day one, only when the stop data has one), then the view moves in and the card rises. It ends on the learner's own current stop: stop 1 for a new visitor. Nothing is stored for it.

"Skip" is a text button of at least 44 px, first in the tab order. It ends the animation at once and moves focus to the card's button ("Start", "Continue" or "Start review"). Under reduced motion there is no animation at all: the road opens straight on its final screen, with no Skip. Hidden parts use `visibility`, never `inert` (older Safari lacks it), so nothing hidden can be focused or tapped while it runs.

### The first-open questions and the recap card (`IntroQuestion`)

On a phone that has not seen them, "Start" on the day one card opens two questions, one per screen, in the page frame: "Why are you learning Finnish?" (Work, Daily life, Family and friends, Studies) and "When will you practise?" (Morning, Lunch break, Evening, No fixed time). The answers are the answer choice rows of Understand it; one tap moves on. A quiet "Skip" (named "Skip this question") moves on without an answer, and the back arrow goes back one screen. Focus moves to the question when a screen opens. Then the road comes back with the recap card: stop 1's name, its "I can" line from the road data, a small mint play button with "Your first line" beside it (the spoken first line of the first dialogue, fetched only when pressed), "Start", which makes the guest account, and under it the protected guest line and "Privacy notice". The answers stay in the phone's own storage (`src/lib/intro-answers.ts`) and are never sent; if storage fails the flow still works and shows again next time. Once the recap card has shown, that phone goes straight from Start to the session. A learner with a guest session or an account, or a guest whose session ended on this phone, never sees the questions.

### Line card and word card (`LineCard`, `FinnishLine`, `WordCard`)

A dialogue line as drawn on 1 November 2026. A milky panel with the speaker's name (12 px, quiet) and "Line 2 of 8" at its top right. Inside, the spoken line in a soft box with a mint play button at its end, and under it the written line in slate with a slate play button. Two dots at the left, mint for spoken and slate for written, are joined by a dotted line. There are no "Spoken" and "Written" labels: each group is named for screen readers ("How people say it", "How it is written"). Both lines carry `lang="fi"`. The English gloss sits inside the card under a dashed line.

- The words that change between spoken and written are peach on a peach wash, in both lines, with the drawn thin peach ring (`--color-peach`, 1 px, inside). Peach there means only that (`--color-changed-text`, `--color-changed-wash`). The text colour is darker than drawn to keep 7 to 1; the ring and the bold weight carry the look.
- The 44 px tap area of a word is padding inside its button that a negative block margin cancels, so a word that wraps onto several rows keeps its text on the line's rows (no overlap with the row above) and its pieces start at the left. The tap area of a word overlaps the next row's by a few pixels, so the rows stay about 1.4 apart as drawn and every word is still a 44 px target.
- Understand it shows the one spoken line as one milky card with its play button, not a box inside a second card.
- The word being spoken is an ink block with light text. Each word's button is the 44 px tap area and stays invisible; the wash and the ink block are drawn on the word itself at text height.
- Every word with word data is a button. A word without data (a name) is plain text, never a dead button. A word and the punctuation after it never wrap apart, but a word too long for its line (a 44 letter compound) wraps inside the line instead of running past the card: the punctuation sits inside the word's button, hidden from screen readers so the button's name stays the word.
- While a line plays the card shows a ring and the word "Playing" next to the speaker's name, so colour is never the only sign.
- Understand it shows only the spoken line, larger (21 px), with one play button. Say it and Keep it show the card without play buttons.

#### The tip on a learner's first lesson (`FirstLessonTip`)

On the learner's first lesson only, before Hear it is finished, the line card stays lit and the rest of the screen dims with a real scrim. Three short lines: "How people say it" (mint dot), "How it's written" (slate dot) and "Tap any word to learn it" (peach ring), and a "Got it" button. Focus moves to "Got it" when it opens and back to "Next line" when it closes. Escape closes it. Tab cannot leave the lit card and the tip, and the page behind cannot be used or scrolled. Whether it shows comes from the session answer (`firstLesson`), never from the phone.

#### The word card (`WordCard`)

A bottom sheet. The word large with a play button and a close cross, what it means in plain English, two tiles "People say" (mint) and "Books write" (slate) each with a play button, "Dictionary form" with the base form and what it means, and "Why does it change?" behind one more tap. Audio exists per line only, so every play button plays the whole line in its register, its name says so, and one caption says "Plays the whole line." The two meaning lines come from word data (`meaning`, `baseMeaning`); when it is missing the line is left out and no text is invented. The quiet "Patterns you've seen" button stays under the facts. The card keeps its dialog behaviour: focus in and back, Escape, tap outside, no page scroll.

### Answer choices (`AnswerChoices`)

The rows of the comprehension check in Understand it. One full width white row per English meaning, at least 52 px tall, text left aligned and allowed to wrap. Three states, which differ in shape and words as well as colour:

- **Ready**: ink on white with a soft shadow.
- **Tried and not right**: no fill, a dashed edge and quiet text, with "not this one" for screen readers. It stays focusable (`aria-disabled`, not `disabled`), so focus is never lost, and pressing it again does nothing. Never red, no cross, no count. The status line says "Not this one. Listen again and try another."
- **Right**: a 2 px mint edge, semibold text and a tick in a mint circle, with "that is right" for screen readers. The other rows become unavailable and the status line says "Yes, that is right." The bottom pill reads "Next" and is unavailable until the answer is right.

### Play control (`PlayControl`)

A round button that plays and pauses one audio file. Mint for the spoken line, slate for the written line. States: ready (a play triangle), loading (a ring), playing (pause bars), and could not play ("Could not play." with a "Try again" button). Its accessible name says what it plays, for example "Play the spoken line". Starting one control stops any other. It is one button in every state, so keyboard focus stays on it when playback fails and when "Try again" is pressed. Audio starts only from a tap or key press, never by itself; the file is not fetched until the first press. 48 px on a line card, 44 px small.

### Record control (`RecordControl`)

A large 88 px round mint button with two flat rings. States, each with its own accessible name: ready ("Record yourself saying the line", hint "Tap and say the line."), recording (peach, a still wave, hint "Listening.", and a quiet "Stop"; the button is named "Stop recording, 3 seconds recorded"), working (three fading dots, "Listening to your recording.") and unavailable (grey, disabled, with a one line reason). A clear result is a milky card with a mint tick, the feedback sentence, the wave, "Play mine" and "Try again". A try again result is the gentle peach note with its open ring. The spoken answer in Keep it uses the same button and keeps its own words.

### Sheets in use

The leave sheet ("Leave this lesson?"), the word card, the speaking consent sheet and the delete page share the sheet look. **The speaking consent sheet** shows only its title "Say it out loud", a "How it works" link to the privacy page's "Your voice" section (it opens in a new tab so the lesson stays where it is), "Turn on" and "Not now". Nothing asks for the microphone before "Turn on". The box "Keep my recordings" is never ticked for the learner and is not on the sheet; it is a switch in Voice settings. Escape does what "Not now" does, because it records nothing.

### Switches (`Switch`)

A real switch with a name: a button with `role="switch"` and `aria-checked`, 44 px tall, one press changes it. The hint under the name says the state in words. Used for "Speaking feedback" and "Keep my recordings" in Voice settings.

### Page frame (`PageFrame`)

Every page that is not a lesson or the road: the landscape band, a 44 px back arrow in a milky round, the page's title beside it, the content starting at least 168 px from the top (`--page-content-top`), below the hills, trees and sun of the band, and the actions at the bottom clear of the home bar. Section headings on the privacy notice are ink: mint means a control you can press. Used by the account page, the email and code screens, Voice settings, the privacy notice, Send feedback and the delete page.

### The finished lesson

A tick orb, "Now you can say this.", the line card with its English line, a panel headed "N new words" with the new words as tappable chips (each opens its word card; the count is the number of chips and nothing else), the save note for a guest, a quiet "Send feedback" link, "Done", and one status line. The drawing's "lines said aloud" box is not built. The save note is a milky panel with centred words: "Create an account to save your progress.", a "Create account" button and a quiet "Not now". It keeps job 18's rules: not a status, alert or dialog, no focus move, and the finish screen has exactly one `role="status"`.

### The account page and its neighbours

The account page is a profile: a large avatar with the letter, the name line ("Guest" and "Saved on this device", or the email and "Saved to your email"), a "Your journey" panel ("Stop 3 of 36", a bar, "Now: Grocery store", "A1"), and one settings panel with four rows (Speaking feedback with On or Off, Download my data, Privacy notice, Send feedback). A guest sees the peach bar "Create an account to save your progress." with a plain "Create" (named "Create an account"). At the bottom: "Sign out · Delete my account" (Sign out for email accounts only) as small text. When the data file is ready it shows in place under the title "Download my data": a tick orb, "Your file is ready", one line and "Download", with the back arrow as the only way back. "Delete my account" is small text in `--color-danger-ink`, which reaches 4.5 to 1 on the peach end of the wash. The delete page keeps its address and its two steps and looks like the drawn sheet: "Delete your account?", the warning in full, "Delete for good" as the danger pill and "Keep my account". The email screens have one milky field (its words as the placeholder, its label for screen readers) and the button at the bottom; the protected sentences sit small (12 px) and quiet under the field; the code screen says "Sent to" the address, its "Send a new code" link reads the wait, and its back arrow goes back to the email; the code is one input with `autocomplete="one-time-code"` and a visible box for each digit (`CodeField`).

### The privacy notice

A readable first layer: the title, a two line summary, five short sections (What we keep, Your voice, How long, Your rights, Who runs PuhuScribe), "Updated" with the date, and "Read the full notice". Behind that control is the whole notice of job 11, unchanged in content. Each claim of the first layer is checked against `src/privacy/data-inventory.ts` by a unit test.

### Errors, offline and loading

"Opening" is the sprout mark on a mint tile and three fading dots. "No connection" is a cloud with a slash, the title, "Your progress is safe." (only on the road and account screens, where nothing waits to be saved) and "Check your internet connection, then try again.", and "Try again". "Something went wrong" is the crash screen with a peach mark, the existing words and "Reload"; it does not claim a report was sent. All other problem messages keep their words and show in the problem style.

### Save progress note (`SaveNote`)

See "The finished lesson". Its words are in `src/screens/save-note-copy.ts`: "Create an account to save your progress." and "Create account" are the owner's words of 1 November 2026. After "Not now" the note is replaced by one plain line ("No problem. You can add your email later from Your account.") that takes focus.

### Wordmark (`Wordmark`)

v2's sprout mark and "PuhuScribe" in Poppins Bold, flat with no gloss. Sources and licence in `design/assets/README.md`.

## Screen text

- Full sentences that end with a full stop, in plain English. Explain a term the first time.
- Corrections are gentle and never shaming. Say what to try next ("Close. Try the double k."), not what went wrong.
- Success is quiet text. No confetti, badges, streaks, scores or celebrations.
- Follow the writing rules in `AGENTS.md`: no em dashes, no colon reveals, no "not X, but Y", no hype words, no habitual groups of three.
- Client facing text is English. Any Finnish a learner sees goes through the content pipeline and the native reviewer.

## Browsers

The oldest browser supported is **Safari 15.4 on iPhone** (March 2022). Vite builds CSS for it (`build.cssTarget` in `vite.config.ts`). These need care:

- `100dvh` always follows a `100vh` line, for browsers without `dvh`.
- `<dialog>` and `showModal()` arrive in Safari 15.4. Focus return and the scroll lock are done in our own code, not left to the browser.
- `::backdrop` does not see custom properties from `:root` in older browsers, so `--color-backdrop` is declared on `::backdrop` itself.
- `env(safe-area-inset-bottom)` needs `viewport-fit=cover` in `index.html`.
- Not allowed in CSS: `light-dark()` (Safari 17.5), `color-mix()` (16.2), `@starting-style`, `@property`, `@container`, and the `popover` attribute. `tests/design-css.test.ts` refuses them.
- Browser features new since 2022 need a fallback in code too (AGENTS.md, lesson from job 2).

## Banned (the owner's list, as rules)

Layout:

- No thick coloured bar along one edge of a card or box. A border on one side may be at most 2 px (checked by test).
- No thin lines splitting content into table-like rows. A real table is used only for real tabular data.
- No eyebrows: no small uppercase label above a heading. `text-transform: uppercase` is refused by test.
- No rows of three to five huge statistics, unless the numbers are the point of the page.
- No identical card grids with an icon, a title and two lines each.
- No fake numbering (01, 02, 03) on things that are not steps.

Style:

- No stock AI colour schemes: cream with a serif and terracotta, near-black with one neon, purple to blue gradients.
- No pills or badges scattered as decoration. Buttons are pills because v2's buttons are; labels are plain text.
- No glow or gloss: no gradient text (`background-clip: text` refused), no glowing clouds, no frosted glass (`backdrop-filter` refused), no glowing buttons, no gradient icon squares. The only CSS gradient is the page wash.
- No emoji or icon in front of every heading or list item. Icons appear only inside controls.
- Not the fonts Inter, Space Grotesk or Bricolage Grotesque (refused by test).

Writing: no em dash asides, no "not X, but Y", no colon reveals, no hype words, no habitual groups of three.

## Round 6: as drawn (2 November 2026)

The owner asked for the app to look exactly like the drawings. What changed, everywhere: solid pale progress pieces with no outline; white pills with a very pale edge; milky fields with no outline whose focus is a 2 px mint edge; small quiet underlined links; medium weight screen titles; the cross and back arrow drawn as a 36 px round inside a 44 px tap area; the band in the drawing's 280 x 170 shape starting under the phone's status strip. On the road: the scene anchored so the sun's centre is 204 px from the top, signs at the drawing's places and perspective (never under 12 px, never over the sun or the fell labels), the next and later signs without a number, a done sign's tick in a small white square, the marker's pale mint halo, a 90 percent white card and "Stop 3 · lesson 2 of 4". Lessons: the tip's white lines on a darker scrim, Understand it's play button on the left, the record button's double soft halo, Say it's peach note above the record button, Keep it's title at the top and the answer kept in its field, and a finish screen with no top bar, the spoken line alone and five chips then "+N". The full list, item by item, is in `factory/jobs/19-redesign/build.md`.
