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
| `--color-button-secondary`         | #ffffff   | the white pill with a mint edge                                         |
| `--color-button-secondary-hover`   | #f1f8f5   |                                                                         |
| `--color-button-secondary-pressed` | #e3f1ec   |                                                                         |
| `--color-danger`                   | #b8532f   | the "Delete for good" pill                                              |
| `--color-danger-hover`             | #a64a29   |                                                                         |
| `--color-danger-pressed`           | #94411f   |                                                                         |
| `--color-danger-text`              | #ffffff   |                                                                         |
| `--color-disabled`                 | #e3ebe8   |                                                                         |
| `--color-disabled-text`            | #5f706b   |                                                                         |
| `--color-focus`                    | #1b2a26   |                                                                         |
| `--color-wave-played`              | #1e856f   |                                                                         |
| `--color-recording`                | #db7249   | the record control while recording                                      |
| `--color-recording-text`           | #ffffff   |                                                                         |
| `--color-switch-off`               | #7d8f89   | the track of a switch that is off                                       |
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

| Text or mark                | On                         | Needs | Result | Used for                                                |
| --------------------------- | -------------------------- | ----- | ------ | ------------------------------------------------------- |
| `--color-text`              | `--color-panel`            | 7:1   | 14.6:1 | a spoken Finnish line on the line card                  |
| `--color-text`              | `--color-surface`          | 7:1   | 14.9:1 | Finnish in a sheet and in the word card                 |
| `--color-text`              | `--color-spoken-soft`      | 7:1   | 12.3:1 | the spoken word on its tile                             |
| `--color-text`              | `--color-word-hover`       | 7:1   | 13.0:1 | a Finnish word under the finger                         |
| `--color-written`           | `--color-panel`            | 7:1   | 7.7:1  | the written Finnish line on the line card               |
| `--color-written`           | `--color-surface`          | 7:1   | 7.9:1  | written Finnish in a sheet                              |
| `--color-written`           | `--color-written-soft`     | 7:1   | 7.0:1  | the written word on its tile                            |
| `--color-changed-text`      | `--color-changed-wash`     | 7:1   | 7.1:1  | a changed word on its wash                              |
| `--color-current-word-text` | `--color-current-word`     | 7:1   | 14.1:1 | the word being spoken                                   |
| `--color-text-quiet`        | `--color-surface`          | 4.5:1 | 5.9:1  | quieter text in a sheet                                 |
| `--color-text-quiet`        | `--color-panel`            | 4.5:1 | 5.8:1  | quieter text on a panel                                 |
| `--color-text-quiet`        | `--color-wash-top`         | 4.5:1 | 4.7:1  | quieter text on the mint end of the wash                |
| `--color-text-quiet`        | `--color-wash-middle`      | 4.5:1 | 5.6:1  | quieter text in the middle of the wash                  |
| `--color-text-quiet`        | `--color-wash-bottom`      | 4.5:1 | 4.8:1  | quieter text on the peach end of the wash               |
| `--color-text-quiet`        | `--color-spoken-soft`      | 4.5:1 | 4.9:1  | quieter text on a soft mint fill                        |
| `--color-text-quiet`        | `--color-written-soft`     | 4.5:1 | 5.3:1  | quieter text on the slate tile                          |
| `--color-text`              | `--color-wash-top`         | 4.5:1 | 11.9:1 | headings on the mint end of the wash                    |
| `--color-text`              | `--color-wash-bottom`      | 4.5:1 | 12.0:1 | headings on the peach end of the wash                   |
| `--color-spoken-text`       | `--color-spoken-soft`      | 4.5:1 | 5.0:1  | the "People say" label on its tile                      |
| `--color-mint-deep`         | `--color-surface`          | 4.5:1 | 6.0:1  | the "How it works" link and a sign number               |
| `--color-mint-deep`         | `--color-panel`            | 4.5:1 | 5.9:1  | mint text on a panel                                    |
| `--color-mint-deep`         | `--color-mint-soft`        | 4.5:1 | 5.0:1  | mint text on a soft mint fill                           |
| `--color-button-text`       | `--color-button`           | 4.5:1 | 4.5:1  | text on the mint pill                                   |
| `--color-mint-deep`         | `--color-button-secondary` | 4.5:1 | 6.0:1  | text on the white pill                                  |
| `--color-danger-text`       | `--color-danger`           | 4.5:1 | 4.9:1  | text on the delete pill                                 |
| `--color-text`              | `--color-gentle-wash`      | 4.5:1 | 12.3:1 | a gentle note                                           |
| `--color-problem-text`      | `--color-problem-wash`     | 4.5:1 | 7.7:1  | a problem message                                       |
| `--color-focus`             | `--color-wash-top`         | 3:1   | 11.9:1 | the focus outline on the mint end of the wash           |
| `--color-focus`             | `--color-wash-middle`      | 3:1   | 14.0:1 | the focus outline in the middle of the wash             |
| `--color-focus`             | `--color-wash-bottom`      | 3:1   | 12.0:1 | the focus outline on the peach end of the wash          |
| `--color-focus`             | `--color-surface`          | 3:1   | 14.9:1 | the focus outline in a sheet or on a card               |
| `--color-focus`             | `--color-panel`            | 3:1   | 14.6:1 | the focus outline on a panel                            |
| `--color-control-edge`      | `--color-surface`          | 3:1   | 4.5:1  | the edge of a white control in a sheet                  |
| `--color-control-edge`      | `--color-panel`            | 3:1   | 4.4:1  | the edge of a white control on a panel                  |
| `--color-control-edge`      | `--color-wash-top`         | 3:1   | 3.6:1  | the edge of a white control on the mint end of the wash |
| `--color-button`            | `--color-surface`          | 3:1   | 4.5:1  | the play control in a sheet                             |
| `--color-button`            | `--color-panel`            | 3:1   | 4.4:1  | the play control and the mint pill on a panel           |
| `--color-button`            | `--color-wash-top`         | 3:1   | 3.6:1  | the mint pill on the mint end of the wash               |
| `--color-current-line`      | `--color-panel`            | 3:1   | 4.4:1  | the ring round the line that is playing                 |
| `--color-peach`             | `--color-surface`          | 3:1   | 3.2:1  | the ring round the next sign                            |
| `--color-recording`         | `--color-panel`            | 3:1   | 3.2:1  | the record control while recording                      |
| `--color-recording-text`    | `--color-recording`        | 3:1   | 3.2:1  | the wave and stop mark on the record control            |
| `--color-switch-off`        | `--color-surface`          | 3:1   | 3.4:1  | a switch that is off                                    |
| `--color-gentle-mark`       | `--color-gentle-wash`      | 3:1   | 4.0:1  | the mark on a gentle note                               |
| `--color-problem-edge`      | `--color-problem-wash`     | 3:1   | 5.1:1  | the edge of a problem message                           |

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

### Buttons (`Button`)

- **Primary**: the flat mint pill with the small arrow circle, 52 px tall, a plain soft shadow and no glow (owner's call 5). One per screen, for the main action, such as "Continue".
- **Secondary**: the white pill with a mint edge, 52 px tall. For a second choice next to a primary.
- **Quiet**: underlined text, at least 44 px. For a minor action.
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

### Finnish line and word card (`FinnishLine`, `WordCard`)

A dialogue line in v2's register pairing. The spoken line comes first, on a teal band labelled "Spoken". The written line sits under it, labelled "Written" in text. A teal dot and a violet dot joined by a dotted line connect the two. Both lines carry `lang="fi"`. The words that change between spoken and written are azure on an azure wash, in both lines; azure means only that. The word being spoken is an ink block with light text. Each word's button is the 44 px tap area and stays invisible; the wash and the ink block are drawn on the word itself at text height, so a line reads as text with a few marked words.

Every word is a button. A tap, Enter or Space opens its word card: a native `<dialog>` that rises from the bottom. It shows the word as it appears, its base form, the name of the form, a one line "why" in English, and the spoken and written forms, each with a play control. It closes with the Close button, the Escape key, or a tap outside it. Focus moves into the card when it opens and back to the same word when it closes. While it is open, the page behind cannot be used or scrolled. Grammar is always behind this tap, never on the main screen. On design pages the card ends with "Sample, not reviewed." (the `cardNote` prop).

The first time a screen shows changed words, one plain line explains them: "Blue words change between spoken and written Finnish."

On session screens the word card's two play controls play the whole line in each register, because audio exists per line only (job 8, Decision 6). Their names say "Play the spoken line" and "Play the written line", and one plain caption under them says "Plays the whole line." (the `audioCaption` prop). A word and the punctuation after it never wrap apart: each sits in one span that does not break, with the button still the word's only tap target.

### Answer choices (`AnswerChoices`)

The rows of the comprehension check in Understand it (job 8-first-session). One full width row per English meaning, in the white pill look with a visible edge, at least 54 px tall, text left aligned and allowed to wrap. Three states, which differ in shape and words as well as colour:

- **Ready**: `--color-text` on `--color-button-secondary` with the `--color-control-edge` edge (the white pill rows of the contrast table).
- **Tried and not right**: no fill, a dashed `--color-control-edge` edge and `--color-text-quiet` text on the page (the quieter text on the page rows), with "not this one" for screen readers. It stays focusable (`aria-disabled`, not `disabled`), so focus is never lost, and pressing it again does nothing. Never red, no cross, no count. The status line says "Not this one. Listen again and try another." in the gentle style.
- **Right**: a 2 px edge in `--color-text` (the headings on the page rows), semibold text and a tick inside the row, with "that is right" for screen readers. The other rows become unavailable and the status line says "Yes, that is right."

Keyboard focus uses the normal outline. The list is named by the question heading "What does this mean?", and the screen keeps the rows in view on a short phone. The reference page shows each state.

### Play control (`PlayControl`)

A round button that plays and pauses one audio file. States: ready (a play triangle), loading (a ring), playing (pause bars), and could not play ("Could not play." with a "Try again" button). Its accessible name says what it plays, for example "Play the spoken line". Starting one control stops any other. It is one button in every state, so keyboard focus stays on it when playback fails and when "Try again" is pressed. Audio starts only from a tap or key press, never by itself; the file is not fetched until the first press. 56 px in the action area, 44 px inside a card.

### Record control (`RecordControl`)

Look only in this job; recording, voice consent and feedback come in job 8, and nothing here asks for the microphone. A 72 px round button. States, each with its own accessible name: ready ("Record yourself saying the line"), recording (teal, a square stop mark, elapsed time as 0:03 in tabular numbers, "Stop recording, 3 seconds recorded"), working ("Working on your recording", three fading dots) and unavailable (grey, disabled, with a one line reason). The spec named Geist Mono for the time; the owner's choice of v2's fonts replaced it with tabular numbers in Switzer.

### Save progress note (`SaveNote`)

One short note near the end of the finish screen (job 18-save-progress), shown to a guest after their first finished session and once more after their third. It sits in the page after the line card and "The words you met will come back in your review.", and before "Send feedback". It is a plain block, not a card, a dialog or a banner: no fill, no edge, no icon, no label above it, no animation. It is a `section` named "Keep your progress" for screen readers, and adds no heading.

- **Words.** One sentence in `--color-text`, at body size. All the words are in `src/screens/save-note-copy.ts` and follow the writing rules (no pressure, no loss warning, no number).
- **Buttons.** "Add your email" is the secondary button (white pill with an edge) and "Not now" is the quiet one, side by side, wrapping under each other on a narrow phone. "Done" stays the only primary (black) button on the screen, so finishing stays the main action. No new button style.
- **The status line above it.** For a guest the finish screen's one status line says "Your progress is saved on this device." (the owner's choice of 1 November 2026), so the note's offer to add an email reads as the next step and not as a contradiction. A learner with an email keeps "Your progress is saved." The line is `role="status"` as before, in the neutral style.
- **After "Not now".** The note is replaced by one plain line ("No problem. You can add your email later from Your account.") in the same text style. Focus moves to that line (`tabindex="-1"`), so a keyboard or screen reader user is not left on a button that has gone. Neither the note nor the line is a status or an alert: the finish screen keeps its one `role="status"` line.
- **Never blocks.** Nothing on the page is disabled, covered or moved to make room: "Done", "Leave session", "Send feedback" and the line's play controls work as before. Focus does not move when the note appears.
- **Look and reference.** Tokens only, in its own file `src/screens/SaveNote.module.css`. `/design-reference` shows the live note under "Save progress note", in light and dark.

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
