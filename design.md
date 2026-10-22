# PuhuScribe design system

The locked design system for PuhuScribe v3, from job 5-design-system (`factory/jobs/5-design-system/spec.md`). The design reviewer checks every screen against this file. Why the look is what it is, and what it borrows from, is in [design/brief.md](design/brief.md).

- Every value lives in `src/styles/tokens.css` as a CSS custom property. Components use those names and never a raw colour (`tests/design-tokens.test.ts` checks it).
- The reference page, `/design-reference`, shows every value and every component in every state. It exists in local development (`npm run dev`) and on preview links, behind the Cloudflare Access sign in. Learners never see it, and a normal build leaves it out (`tests/design-build.test.ts`).
- The parts live in `src/components/`, one PascalCase `.tsx` file with a `.module.css` file beside it.

The look is v2's own, chosen by the owner on 21 October 2026: a white to soft lilac page, ink text, violet for written Finnish, teal for spoken Finnish, azure for the words that change between the two, soft white cards and black pill buttons. Three ideas come from the look options page: the word being spoken lights up, the audio player sits at the bottom with a slim waveform, and the spacing is calm.

## Type

| Use                                                                       | Font    | Weight                 |
| ------------------------------------------------------------------------- | ------- | ---------------------- |
| Step names, headings, buttons, spoken Finnish lines, the word on its card | Poppins | 600, changed words 700 |
| Body text, labels, notes, the written Finnish line                        | Switzer | 400 to 600             |

Sizes, all in `rem` so a phone's larger text setting scales every line:

| Token              | Size  | For                             |
| ------------------ | ----- | ------------------------------- |
| `--text-display`   | 36 px | the reference page title        |
| `--text-title`     | 30 px | the step name                   |
| `--text-word-card` | 32 px | the word at the top of its card |
| `--text-line`      | 22 px | a spoken Finnish line           |
| `--text-heading`   | 19 px | card and section headings       |
| `--text-written`   | 17 px | the written line under it       |
| `--text-body`      | 16 px | body text                       |
| `--text-small`     | 14 px | labels and notes                |

Rules:

- **Line length.** A Finnish line is at most `--measure-line` (34 characters) wide, so a learner reads it in one sweep.
- **ä, ö and å stay readable.** Finnish is never smaller than 17 px, its line height is 1.4 (`--leading-line`), and its letter spacing is never tighter than `--tracking-line` (-0.01em), so the dots keep clear of the line above. Both fonts include ä, ö, å, Ä, Ö and Å; a browser test checks they render.
- **Long words wrap.** Finnish compounds can be very long. Lines use `overflow-wrap: anywhere` and `hyphens: auto`, so nothing scrolls sideways at 320 px or with text at 200 percent.
- **No italics.** Neither italic font file is loaded, and the base styles set `em`, `i` and similar elements upright. Emphasis comes from weight.
- **Numbers** use `font-variant-numeric: tabular-nums`, so counters and times do not jump.

### Fonts and their licences

- **Poppins**: `@fontsource/poppins` from npm, pinned in `package.json`. SIL Open Font License 1.1. Commercial use and self-hosting allowed.
- **Switzer**: the official WOFF2 files from fontshare.com, downloaded 21 October 2026 with the owner's approval. Licence: ITF Free Font License 2.0 (`FFL.txt`). Commercial use and self-hosting on our own servers allowed. The files must stay exactly as downloaded: no subsetting, no conversion (`tests/design-rules.test.ts` checks their SHA-256).
- **The Switzer files are not in this public repository.** The licence forbids making the font available through public repositories, so they are kept out of git and out of its history. `scripts/ci/fetch-private-fonts.ts` puts them in `src/assets/fonts/switzer/` from a private source when a deploy key is available (`FONTS_DEPLOY_KEY`), and writes the `@font-face` CSS there. Without the files the body text falls back to Poppins and then the system font, and the tests that need Switzer skip with a reason. How it works and how to set it up: [docs/fonts.md](docs/fonts.md).
- Both fonts are served from the app's own address. No request goes to Google Fonts or Fontshare, so no learner's IP address reaches them.

## Colour

Light and dark mode follow the phone's setting. There is no switch. Dark mode declares the same names again inside `@media (prefers-color-scheme: dark)`. Values are hex, because `light-dark()` and `color-mix()` are too new for older iPhones.

| Token                              | Light     | Dark      | Purpose                                                           |
| ---------------------------------- | --------- | --------- | ----------------------------------------------------------------- |
| `--color-ground-top`               | #ffffff   | #121117   | top of the page background fade, and fixed top bars               |
| `--color-ground-middle`            | #faf9fc   | #141319   | middle of the fade (58 percent)                                   |
| `--color-ground-bottom`            | #f1f0f6   | #17161d   | bottom of the fade, v2's lilac                                    |
| `--color-surface`                  | #ffffff   | #1c1b23   | cards, the audio player, the word card, the action area           |
| `--color-track`                    | #e3e1ec   | #34323f   | steps not reached, the unplayed waveform, the dotted connector    |
| `--color-card-edge`                | #1a16340f | #ffffff14 | the 1 px card hairline (decorative)                               |
| `--color-control-edge`             | #7a7689   | #8a8699   | the edge of a white control, such as the secondary button         |
| `--color-text`                     | #1b1a20   | #f2f0f8   | v2's ink: Finnish, headings, body text                            |
| `--color-text-quiet`               | #56525e   | #b8b4c4   | the written line, notes and captions                              |
| `--color-spoken`                   | #1f7c8e   | #4fb3c4   | the spoken register's dot                                         |
| `--color-spoken-text`              | #166270   | #7ccad7   | the "Spoken" label                                                |
| `--color-spoken-band`              | #e9f2f4   | #23303a   | the band behind a spoken line                                     |
| `--color-spoken-band-edge`         | #1f7c8e38 | #4fb3c440 | the band's 1 px edge (decorative)                                 |
| `--color-written`                  | #6b46c1   | #a78bea   | the written register's dot and "Written" label                    |
| `--color-flag-text`                | #1f42ac   | #b6c7ff   | a word that changes between spoken and written. Reserved for that |
| `--color-flag-wash`                | #e2e8f9   | #22305a   | the wash behind a changed word                                    |
| `--color-current-word`             | #1b1a20   | #f2f0f8   | the block behind the word being spoken                            |
| `--color-current-word-text`        | #f6f4fb   | #1b1a20   | the word being spoken                                             |
| `--color-current-line`             | #1f7c8e   | #4fb3c4   | the ring round the line that is playing                           |
| `--color-word-hover`               | #ecebf2   | #2a2933   | a word or quiet control under the finger, table stripes           |
| `--color-button`                   | #1b1a20   | #f2f0f8   | the black pill, the play and record controls                      |
| `--color-button-hover`             | #2a2832   | #ffffff   | its hover state                                                   |
| `--color-button-pressed`           | #000007   | #d9d6e4   | its pressed state                                                 |
| `--color-button-text`              | #f6f4fb   | #1b1a20   | text and icons on it                                              |
| `--color-button-secondary`         | #ffffff   | #1c1b23   | the white pill                                                    |
| `--color-button-secondary-hover`   | #f6f5fa   | #24232c   | its hover state                                                   |
| `--color-button-secondary-pressed` | #ecebf2   | #2c2b35   | its pressed state                                                 |
| `--color-disabled`                 | #ecebf2   | #2a2933   | a disabled control (exempt from contrast floors, kept readable)   |
| `--color-disabled-text`            | #6e6a7a   | #9a96a8   | text on it                                                        |
| `--color-focus`                    | #1b1a20   | #f2f0f8   | the keyboard focus outline                                        |
| `--color-wave-played`              | #1f7c8e   | #4fb3c4   | the played part of the waveform                                   |
| `--color-recording`                | #1f7c8e   | #4fb3c4   | the record control while recording (v2 records in teal)           |
| `--color-recording-text`           | #ffffff   | #121117   | the stop mark on it                                               |
| `--color-brand`                    | #6b4fc6   | #6b4fc6   | the sprout mark's tile                                            |
| `--color-brand-leaf`               | #ffffff   | #ffffff   | its front leaf and stem                                           |
| `--color-brand-leaf-back`          | #d9d1f2   | #d9d1f2   | its back leaf                                                     |
| `--color-wordmark-quiet`           | #8b8798   | #8a8699   | "Scribe" in the wordmark (a logo is exempt from contrast floors)  |
| `--color-gentle-wash`              | #e7e3f2   | #2a2540   | a gentle correction's block                                       |
| `--color-gentle-mark`              | #6b46c1   | #a78bea   | its open circle                                                   |
| `--color-problem-wash`             | #fff3e0   | #2e2216   | a problem message's block. System faults only                     |
| `--color-problem-text`             | #7a3d00   | #ffc58a   | its text                                                          |
| `--color-problem-edge`             | #a35200   | #d98a3a   | its edge and square mark                                          |
| `--color-backdrop`                 | #1b1a2066 | #000000a6 | dims the page behind the word card (declared on `::backdrop`)     |

Changes from v2, each for contrast: the azure text is darker than v2's #2F5AD6 (4.8:1 on its wash, under 7:1) and the teal label text is darker than v2's #1F7C8E (4.3:1 on the band, under AA). The washes keep v2's colours.

### Contrast

Every pairing below is checked in light and dark by `tests/design-tokens.test.ts`, which fails if this table and the test's list (`src/styles/contrast-pairs.ts`) differ. The reference page shows the same results. Floors: Finnish lines and word card text 7:1; all other text 4.5:1; focus outline, control edges, markers and the recording state 3:1.

| Text or mark                | On                         | Needs | Light  | Dark   | Used for                                    |
| --------------------------- | -------------------------- | ----- | ------ | ------ | ------------------------------------------- |
| `--color-text`              | `--color-spoken-band`      | 7:1   | 15.2:1 | 12.0:1 | a spoken Finnish line on its band           |
| `--color-text`              | `--color-surface`          | 7:1   | 17.3:1 | 15.1:1 | Finnish on a card and in the word card      |
| `--color-text`              | `--color-word-hover`       | 7:1   | 14.6:1 | 12.7:1 | a Finnish word under the finger             |
| `--color-flag-text`         | `--color-flag-wash`        | 7:1   | 7.0:1  | 7.7:1  | a changed word on its wash                  |
| `--color-current-word-text` | `--color-current-word`     | 7:1   | 15.8:1 | 15.3:1 | the word being spoken                       |
| `--color-text-quiet`        | `--color-surface`          | 4.5:1 | 7.6:1  | 8.4:1  | the written line and quieter text on a card |
| `--color-text-quiet`        | `--color-ground-top`       | 4.5:1 | 7.6:1  | 9.3:1  | quieter text at the top of the page         |
| `--color-text-quiet`        | `--color-ground-middle`    | 4.5:1 | 7.2:1  | 9.1:1  | quieter text in the middle of the page      |
| `--color-text-quiet`        | `--color-ground-bottom`    | 4.5:1 | 6.7:1  | 8.9:1  | quieter text at the bottom of the page      |
| `--color-text`              | `--color-ground-top`       | 4.5:1 | 17.3:1 | 16.6:1 | headings at the top of the page             |
| `--color-text`              | `--color-ground-bottom`    | 4.5:1 | 15.3:1 | 15.9:1 | headings at the bottom of the page          |
| `--color-spoken-text`       | `--color-spoken-band`      | 4.5:1 | 6.1:1  | 7.3:1  | the "Spoken" label on its band              |
| `--color-written`           | `--color-surface`          | 4.5:1 | 6.4:1  | 6.1:1  | the "Written" label on a card               |
| `--color-button-text`       | `--color-button`           | 4.5:1 | 15.8:1 | 15.3:1 | text on the black pill                      |
| `--color-text`              | `--color-button-secondary` | 4.5:1 | 17.3:1 | 15.1:1 | text on the white pill                      |
| `--color-text`              | `--color-gentle-wash`      | 4.5:1 | 13.7:1 | 12.9:1 | a gentle correction                         |
| `--color-problem-text`      | `--color-problem-wash`     | 4.5:1 | 7.7:1  | 10.0:1 | a problem message                           |
| `--color-focus`             | `--color-ground-top`       | 3:1   | 17.3:1 | 16.6:1 | the focus outline at the top of the page    |
| `--color-focus`             | `--color-ground-bottom`    | 3:1   | 15.3:1 | 15.9:1 | the focus outline at the bottom of the page |
| `--color-focus`             | `--color-surface`          | 3:1   | 17.3:1 | 15.1:1 | the focus outline on a card or a bar        |
| `--color-focus`             | `--color-spoken-band`      | 3:1   | 15.2:1 | 12.0:1 | the focus outline on the spoken band        |
| `--color-control-edge`      | `--color-surface`          | 3:1   | 4.4:1  | 4.8:1  | the edge of a white control on a card       |
| `--color-control-edge`      | `--color-ground-bottom`    | 3:1   | 3.9:1  | 5.1:1  | the edge of a white control on the page     |
| `--color-button`            | `--color-surface`          | 3:1   | 17.3:1 | 15.1:1 | the play control on a card or a bar         |
| `--color-button`            | `--color-ground-bottom`    | 3:1   | 15.3:1 | 15.9:1 | a black pill on the page                    |
| `--color-current-line`      | `--color-surface`          | 3:1   | 4.8:1  | 7.0:1  | the ring round the line that is playing     |
| `--color-recording`         | `--color-surface`          | 3:1   | 4.8:1  | 7.0:1  | the record control while recording          |
| `--color-recording-text`    | `--color-recording`        | 3:1   | 4.8:1  | 7.7:1  | the stop mark on the record control         |
| `--color-gentle-mark`       | `--color-gentle-wash`      | 3:1   | 5.1:1  | 5.2:1  | the mark on a gentle correction             |
| `--color-problem-edge`      | `--color-problem-wash`     | 3:1   | 5.1:1  | 5.6:1  | the edge of a problem message               |

### The page background

The page background is v2's fade: `linear-gradient(180deg, #FFFFFF 0%, #FAF9FC 58%, #F1F0F6 100%)`, and in dark mode #121117 to #141319 to #17161d. It is the one gradient allowed, an exception the owner approved on 21 October 2026 for the page background only. It is declared once, as `--ground-fade` in `tokens.css`, and used once, on `html` in `base.css`. Every other gradient is banned (`tests/design-css.test.ts`).

## Spacing, corners and motion

- **Spacing** follows v2's 4 px scale: `--space-1` 4 px up to `--space-9` 56 px. Spacing is in px on purpose: when a learner makes the text larger, the text grows and the margins stay, so lines keep their room.
- **Corners** follow v2: `--radius-word` 6 px (a word's highlight), `--radius-sm` 14, `--radius-md` 20 (bands), `--radius-lg` 26, `--radius-xl` 32 (cards, the word card, the action area), `--radius-pill` (buttons).
- **Tap targets** are at least `--tap-min` (44 px) both ways. Words inside a sentence are inline targets: at least 44 px tall and 24 px wide (`--word-min-width`).
- **Motion** is quiet: colour and opacity change over `--motion-fast` (150 ms, `--motion-ease`), and the word card rises over `--motion-sheet` (220 ms, `--motion-ease-out`). No bounce, no scale up. A button press moves 1 px down. The busy and loading rings turn once per `--motion-turn` (800 ms), and the working dots fade over `--motion-pulse` (1.2 s).
- **Reduce motion.** When the phone's reduce motion setting is on, nothing slides or scales: the word card fades in instead of rising, transitions stop, and the busy and loading marks stand still. Every component file that moves has a `prefers-reduced-motion: reduce` block (`tests/design-rules.test.ts`).

## Components

### Session frame (`SessionFrame`)

Every session screen sits in it. A top bar holds "Leave session" (a 44 px round link with a cross), the loop steps as segments, and the step in words, for example "Hear it, step 1 of 5". Steps follow the loop order: Hear it, Understand it, Say it, Keep it, Use it, with Use it only in sessions that have it. Colour is never the only sign of the step: the words say it. Below it, only the content area scrolls. The action area at the bottom stays in view and keeps clear of the iPhone home bar with `env(safe-area-inset-bottom)`. The learner never picks a mode.

Two options came with the first session (job 8-first-session). `steps` gives the session's own list of steps, in loop order, and replaces the default (the first session passes Hear it and Understand it, so the bar reads "Hear it, step 1 of 2"). `finished` is for the finish screen after the last step: every segment shows as done and the words read "Session finished". Without them the frame behaves as before.

### Buttons (`Button`)

- **Primary**: v2's black pill, 54 px tall. One per screen, for the main action, such as "Continue".
- **Secondary**: the white pill with a visible edge, 54 px tall. For a second choice next to a primary.
- **Quiet**: underlined text, at least 44 px. For a minor action.

A plain `<button>` with no component style of its own (such as the front page's "Try again") gets the secondary look from the base styles: token colours, an edge and a 44 px height, so the browser's own button colours never decide its contrast.

States: hover (a little lighter), pressed (darker, 1 px down), keyboard focus (the outline below), disabled (grey, not focusable), busy. A busy button keeps its size, ignores presses, shows a still or turning ring, and tells screen readers what is happening with a full sentence, for example "Saving your answer.".

### Keyboard focus

Every control works with a keyboard alone, in reading order. Focus shows a solid outline `--focus-width` (3 px) thick, `--focus-offset` (2 px) away, in `--color-focus`, at least 3:1 against whatever it sits on, in both modes. It uses `:focus-visible`, so it appears for the keyboard and not for every tap.

### Status line (`StatusLine`)

One status line per screen, with `role="status"` so screen readers announce it. It always holds one full sentence ending with a full stop. Three styles, which differ in wording and shape as well as colour:

- **Neutral**: plain quiet text, for what is happening ("Saving your answer.").
- **Gentle**: a rounded lavender block with a small open circle, for the learner's attempts ("Close. Try the double k."). Never red, never an alarm word.
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
- No glow or gloss: no gradient text (`background-clip: text` refused), no glowing clouds, no frosted glass (`backdrop-filter` refused), no glowing buttons, no gradient icon squares. The only gradient is the page background fade.
- No emoji or icon in front of every heading or list item. Icons appear only inside controls.
- Not the fonts Inter, Space Grotesk or Bricolage Grotesque (refused by test).

Writing: no em dash asides, no "not X, but Y", no colon reveals, no hype words, no habitual groups of three.
