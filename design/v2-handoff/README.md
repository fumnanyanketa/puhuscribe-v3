# Handoff: PuhuScribe v2 — Brand System & 5 Core Screens

## Overview
PuhuScribe is a mobile (iOS) Finnish-language app for **immigrants and new
residents of Finland**. Its single distinguishing idea: every learning card
shows Finnish in **two registers at once** —

- **kirjakieli** (written / "book" Finnish — what textbooks teach)
- **puhekieli** (spoken / "street" Finnish — what people actually say)

— joined by a visual connector, with the exact words that change between the
two registers **flagged in azure**. This register pairing is the heart of the
product and must survive implementation intact.

This bundle covers the brand system (color, type, components) and the five core
screens: **Onboarding, Day One Sprint, Daily Session, Language Island (speaking),
Progress Dashboard.**

## About the Design Files
The files in this bundle are **design references created in HTML/React (via
in-browser Babel)** — prototypes showing intended look and behavior, **not
production code to ship directly.** They are built as a pannable "design canvas"
hosting live iPhone frames; that canvas/frame scaffolding (`design-canvas.jsx`,
`ios-frame.jsx`) is **presentation chrome only and should NOT be recreated** in
the product.

Your task: **recreate these screens in the target codebase's environment** using
its established patterns. The natural target is **React Native / Expo** (or
SwiftUI) for an iOS app. If no codebase exists yet, React Native + Expo is the
recommended choice. Port the *components and screens* (everything in `brand/ps-*`),
not the canvas harness.

## Fidelity
**High-fidelity (hifi).** Final colors, typography, spacing, component design,
copy, and interaction states are all specified here and in the source. Recreate
the UI faithfully. The one caveat: the glossy speech-bubble graphics are CSS/SVG
stand-ins for **real 3D rendered assets** — see Assets.

## Design Direction (the "Snow" theme)
White-surface, soft-shadow, rounded modern app UI. Calm white ground, confident
cool accents (violet / teal / azure), pastel color-block cards, glossy 3D
speech bubbles as hero imagery, solid-black pill buttons. Geometric display type
(Poppins) over a neutral grotesque body (Switzer).

> NOTE: An earlier lavender "glassmorphism" variant was explored and **dropped**.
> Ignore any lingering `--lilac`, `--glass-*`, or `ps-theme-snow` *wrapper*
> indirection — in the product, **white is simply the base theme.** The
> `ps-theme-snow` class in the prototype only existed to override the abandoned
> lavender base; bake its values straight into your root tokens (listed below).

---

## Design Tokens

### Color
| Token | Hex | Role |
|---|---|---|
| Snow white | `#FFFFFF` | App background (primary) |
| Off-white grad bottom | `#F1F0F6` | Subtle bg gradient foot (`linear-gradient(180deg,#FFF 0%,#FAF9FC 58%,#F1F0F6 100%)`) |
| Card white | `#FFFFFF` | All card surfaces |
| Card hairline | `rgba(26,22,52,0.07)` | 1px card border |
| Card edge / divider | `rgba(26,22,52,0.09)` | Hairline rules, dotted connector |
| Well / track fill | `#ECEBF2` | Progress-bar tracks, recessed wells |
| Ink | `#1B1A20` | Primary text, pill buttons, active states |
| Ink-2 | `#56525E` | Secondary text |
| Ink-3 | `#8B8798` | Muted text, captions, labels |
| On-dark | `#F6F4FB` | Text on ink/colored fills |
| **Violet** | `#6B46C1` | **Kirjakieli (written register)** — dot, label, accent btn |
| Violet wash | `rgba(107,70,193,0.10)` | Written register background tint |
| Violet line | `rgba(107,70,193,0.22)` | Written register border |
| **Teal** | `#1F7C8E` | **Puhekieli (spoken register)** — band, dot, label |
| Teal wash | `rgba(31,124,142,0.10)` | Spoken register band background |
| Teal line | `rgba(31,124,142,0.22)` | Spoken register band border |
| **Azure flag** | `#2F5AD6` | **The changed tokens between registers** (reserved!) |
| Azure flag wash | `rgba(47,90,214,0.14)` | Highlight behind flagged words |
| Steel (card) | `#C4D2E6` / ink `#415A72` | Pastel stat card |
| Mint (card) | `#CCDFD3` / ink `#4C6B57` | Pastel stat card |
| Lavender (card) | `#D6D0E8` / ink `#5A4F86` | Pastel stat/hero card |

**Speech-bubble gradient stops** (cool family; used as `from`/`to` per bubble):
`#4FB0C8` (teal-light), `#2F86C2` (blue), `#6B4FC6` (violet), `#383583` (indigo).

> **Reserved-color rule:** Azure `#2F5AD6` marks **one thing only** — the words
> that morph between kirjakieli and puhekieli. Never use it decoratively.

### Typography
- **Display / headings:** **Poppins** (Google Fonts), weights 400–800. Round
  geometric. Used for titles, numbers, button labels.
- **Body / UI:** **Switzer** (Fontshare), weights 400–700. Neutral grotesque.
- Scale (px / weight / line-height / letter-spacing):
  - Display: 44 / 700 / 0.98 / -0.035em
  - Title-1: 33 / 700 / 1.0 / -0.03em
  - Title-2: 24 / 600 / 1.05 / -0.02em
  - Heading: 19 / 600 / 1.15 / -0.01em
  - Body-L: 16 / 500 / 1.5
  - Body: 14.5 / 500 / 1.5
  - Caption: 13 / 500 / 1.4 (color Ink-3)
  - Label: 11 / 600 / +0.09em / UPPERCASE (color Ink-3)
  - Numbers use tabular-nums.

### Spacing
4px base scale: 4, 8, 12, 16, 20, 24, 32, 40, 56.

### Radii (rounded, app-like)
sm 14 · md 20 · lg 26 · xl 32 · 2xl 38 · pill 999. Buttons & nav are full pills.

### Shadows (soft, cool, on white)
- sh-1: `0 2px 8px rgba(38,33,70,.06), 0 1px 2px rgba(38,33,70,.05)`
- sh-2: `0 8px 24px rgba(38,33,70,.08), 0 2px 6px rgba(38,33,70,.05)`
- sh-3: `0 18px 44px rgba(38,33,70,.12), 0 6px 14px rgba(38,33,70,.07)`

### Motion
Quiet. 150 ms ease, opacity/color/1px-translate only. **No bounce, no scale-up.**
Press = `scale(0.97)` on tappable rows, `translateY(1px)` on buttons.

---

## Core Component: RegisterCard (the product's signature)
Shows one phrase in both registers. **Get this right above all else.**

Structure (top to bottom):
1. **Gloss row** (optional): English translation in italic caption (Ink-2),
   left; small glass/outline badge (e.g. "Arki · daily") right.
2. **Body** = a left **connector rail** + the two register blocks:
   - Rail: a violet dot (top) and a teal dot (bottom) joined by a vertical
     **dotted line** (`repeating-linear-gradient`, edge color), 14px wide column.
   - **Kirjakieli block:** label "Kirjakieli" with a violet dot (`RegDot`),
     then the sentence in **Poppins 600, 20–23px, Ink**. Optional round white
     play button (violet icon) at right.
   - **Puhekieli block:** sits in a **teal-washed inset band** (teal wash bg,
     teal line border, radius md). Label "Puhekieli" with teal dot, then the
     sentence in **Switzer 600, 18–21px, Ink**. Optional play button (teal).
3. In **both** sentences, the words that differ between registers are wrapped in
   the **azure flag** style: azure text, weight 700, with an azure-wash rounded
   highlight behind them.

Card itself: white, 1px hairline border, radius xl (32), shadow sh-2, padding 18–22.

Example phrase data (token = a word; `hot:true` = azure-flagged):
- gloss "I am at home" · kirja: **Minä** **olen** kotona · puhe: **Mä** **oon** kotona
- gloss "Do you want to come along?" · kirja: **Haluatko** tulla mukaan? · puhe: **Haluuks** **sä** tulla mukaan?
- gloss "He / she goes to the shop" · kirja: **Hän** menee kauppaan · puhe: **Se** menee kauppaan
- gloss "Are you hungry?" · kirja: **Onko** **sinulla** nälkä? · puhe: **Onks** **sulla** nälkä?
- gloss "This food is good" · kirja: **Tämä** ruoka on hyvää · puhe: **Tää** ruoka on hyvää
(Bolded = `hot` azure-flagged tokens.)

## Other shared components
- **Btn** — pill button. Variants: `primary` (ink fill, on-dark text),
  `light` (white fill, hairline border), `accent` (violet fill),
  `rose`→now teal fill (record action), `ghost` (transparent). Sizes default
  (min-h 54) / sm (min-h 42). Optional leading/trailing icon. Min hit target 44.
- **IconBtn** — circular icon button, tones `glass`(white), `ink`, `solid`(white).
- **SpeakerBtn** — round audio button; white with violet (kirja) or teal (puhe)
  icon; fills with the register color while playing.
- **Tabs** — pill segmented control; active segment = ink fill, on-dark text.
- **Bar** — progress bar; value 0–100, register-colored fill, `#ECEBF2` track.
- **Ring** — circular progress (SVG); used for mastered count.
- **Steps** — segmented step indicator (active segment wider, ink fill).
- **Orb / OrbCluster** — glossy 3D **speech bubbles** (SVG; rounded bubble +
  tail + top-left highlight + drop shadow). The large bubble shows three white
  typing dots. The wordmark logo is a single bubble-with-dots + "Puhu**Scribe**".
- **Label / RegDot / Sentence** — typographic primitives (see source).

---

## Screens

### 01 · Onboarding
3-step welcome carousel, white bg.
- **Top bar:** wordmark (left), "Ohita" (Skip) text button (right).
- **Steps indicator** below it.
- **Step 1 (Welcome):** large speech-bubble cluster (~220px) centered; eyebrow
  label "Tervetuloa · Welcome" (violet); Display title "Puhu niin kuin *täällä*
  puhutaan" (the word *täällä* in violet); body-L subtext (Ink-2, max 300px).
- **Step 2 (Why two registers):** Title-1 "Books teach one Finnish. The street
  speaks another."; body; a live **RegisterCard** (the "Minä olen kotona" pair).
- **Step 3 (Day One intro):** bubble cluster; centered Title-1 "150 words. One
  sitting."; body; three glass chips: "Recognise", "No typing", "One sitting".
- **Bottom CTA row:** back `IconBtn` (steps 2+) + full-width primary button
  ("Jatka" / on last step "Aloita Day One", sparkle icon). Advances to Day One.

### 02 · Day One Sprint
An accelerated, one-time first-session activation event. ~150 words seen in
waves; per word: a mnemonic card, then a recognition quiz. No typing.
- **Header:** close `IconBtn` (→ Daily), centered "Day One · Aalto N / 8" wave
  label (violet), "M/150" counter (ink). Gradient progress bar
  (violet→teal) under it.
- **Mnemonic phase (card):** white card, radius 2xl. Top = pastel-tinted hero
  panel (lavender tint) with a speech-bubble cluster + "Muistikuva · mnemonic"
  label + "[ 3D render ]" placeholder caption. Below: the word in Poppins 700
  ~44px + IPA (mono-ish caption); the English gloss in quotes; an **azure-wash
  sound-bridge row** (sparkle icon + bridge sentence); a register mini-row
  "Kirja → Puhe" (single words; "· sama" when identical). Full-width primary
  "Testaa minua" advances to quiz.
- **Quiz phase:** "Tunnista · Recognise" label; a glossy bubble; the Finnish
  word in Poppins 700 ~46px; prompt "Mitä tämä tarkoittaa?"; four option
  buttons (white, hairline). On pick: correct → violet wash/border/check;
  wrong choice → azure-flag wash/border/×. Then a primary "jatka" button
  increments the mastered counter and loads the next word.
- Example words: kahvi (coffee), koti (home), ruoka (food), kauppa (shop),
  terve (hi/hello), each with an English sound-bridge mnemonic.

### 03 · Daily Session
The recurring review loop. Mechanic = **phrases mastered** count.
- **Header:** eyebrow "Huomenta · Tiistai" (violet) + Title-1 "Päivän sessio";
  streak pill (flame icon + "12") at right.
- **Mastered strip:** white card; "Phrases mastered" caption + big number; a
  violet progress bar (value = mastered/1200).
- **Session progress:** Steps indicator + "i/N".
- **Card:** a **RegisterCard** (with audio) for the current phrase, badge
  "Arki · daily"; caption "Tap a register to hear it".
- **Actions:** "Vielä harjoittelen" (light) + "Osaan" (accent/check). "Osaan"
  increments mastered; both advance. After the last phrase → **completion
  state**: bubble cluster, "Sessio valmis" / "Hyvää työtä.", a mastered +
  streak stat card, and "Kielisaari" / "Edistyminen" buttons.

### 04 · Language Island (speaking — shadowing)
A **shadowing** exercise, NOT conversational. Learner sees a sentence in both
registers, hears the kirjakieli audio, then records themselves repeating it.
- **Hero band (top ~230px):** deep violet→indigo gradient with a speech-bubble
  cluster bleeding off the right and a faint ring lower-left. On it: back
  `IconBtn` (solid); a dark-frosted **"Saari 3 / 8"** progress pill (island N of
  8) — readable over the bubbles; eyebrow "Varjostus · Shadowing"; Title-1
  "Toista ääneen" (white).
- **Shadowing card** (white, radius 2xl, shadow sh-3): header row "You are
  shadowing" + a violet "Kirjakieli" tag, with the English gloss at right (this
  marks WHICH register is the active target). Then the **kirjakieli** sentence
  large (Poppins 600 ~26px) with `RegDot`. Below, a quieter **teal-band**
  puhekieli line (so both registers always show). Then an audio row: a 48px
  `SpeakerBtn` (kirja) + an animated 22-bar **waveform** (animates while
  playing) + "0:03" duration.
- **Record control (bottom):** large 80px round button — ink when idle (mic
  icon), **teal** while recording (stop square, teal-wash ring halo); caption
  shows "● Nauhoitetaan 1.2s, tap to stop" live timer. On stop → **review
  state**: a violet-wash success card ("Hyvä ääntämys" + "Close match to the
  native clip" + a playback `SpeakerBtn`), then "Uudelleen" (light/mic) +
  "Seuraava" (primary) buttons.

### 05 · Progress Dashboard
- **Header:** Title-1 "Kesäkuu 2026" + chevron; a "+" `IconBtn` (solid) right.
- **Calendar day row:** white card; 7 day columns (label + date number); the
  selected day is an **ink pill** (white text); tapping changes selection.
- **Mastered hero card:** lavender pastel block; a faint bubble cluster bleeds
  top-right; a violet **Ring** ("847 / of 1200") at left; right column = label
  "Phrases mastered", Poppins 700 ~18px "Conversational foundations" (must NOT
  clip — give it its own flex column, `min-width:0`, balanced wrap), "+34 this
  week" caption.
- **Register balance card:** white; two labeled bars — "Kirjakieli · understood"
  78% (violet) and "Puhekieli · spoken" 52% (teal); caption nudging more
  speaking practice. (This visualizes the core register theme as a metric.)
- **Stat tiles row:** three pastel cards (steel/mint/lavender): "12 day streak"
  (flame), "3 islands" (island), "34 this week" (sparkle).
- **Weekly activity:** white card; 7 vertical bars (min/day); the selected day's
  bar is ink, others violet-tint.
- **Recently mastered:** two rows (white cards): a check icon, the kirjakieli
  phrase (Poppins 600) over its puhekieli form (teal), English gloss at right.

### Global: Bottom Navigation
Floating **frosted white pill** centered above the home indicator, three round
tabs (cards / island / chart icons). Active tab = ink-filled circle, white icon.
Present on Daily, Island, Progress (the "app" screens); absent on Onboarding and
Day One (focused flows).

---

## Interactions & Behavior
- **Onboarding:** next/back step the carousel; Skip and last-step CTA jump to
  Day One. State: current step index.
- **Day One:** `phase` (card|quiz), `idx` (word), `picked` (quiz answer),
  `mastered` counter. Quiz disables options after a pick and reveals correct
  (violet) / wrong (azure). Continue → next word, phase back to card.
- **Daily:** `i` (phrase index), `playing` (which register's audio is animating;
  auto-clears ~1100ms), `mastered`, `done`. "Osaan" +1 mastered. Last → done
  state with summary + nav buttons.
- **Island:** `st` state machine: idle → playing (native clip, ~1400ms) ;
  idle → recording (live timer interval) → review → idle. Waveform animates
  only while playing. Record button toggles record/stop.
- **Progress:** `day` selected index drives both the calendar pill and which
  weekly-activity bar is inked. Mostly presentational.
- **Audio/record are simulated** in the prototype (timeouts/intervals). Wire to
  real TTS / native clips and microphone capture + pronunciation scoring in
  production. The "Close match" review is a placeholder for real scoring.

## State Management
Each screen is self-contained React state (see source). In production, lift
shared state to app level: mastered-count, streak, current island/wave, per-day
activity, and per-phrase register-mastery (kirjakieli vs puhekieli %). Audio
playback and microphone/recording need real platform APIs.

## Content / Localization
All UI copy is in Finnish with light English glosses; treat strings as
localizable. The example Finnish register pairs above are real and accurate —
keep them. Topics: daily life, greetings, home, food. No em-dashes are required
by any brand rule here (that was a different, now-removed design system).

## Assets
- **Speech bubbles / orbs:** currently glossy **SVG** stand-ins (in
  `ps-components.jsx`). Intended as **real 3D rendered images** (the cool
  violet/teal/indigo glossy bubble look). Replace with rendered PNGs/WebP at
  the hero slots (Onboarding, Day One mnemonic hero, Island hero, Progress hero,
  completion). Each hero has a placeholder caption like "[ 3D render ]".
- **Fonts:** Poppins (Google Fonts), Switzer (Fontshare). Bundle equivalents in
  the app (e.g. Expo Google Fonts for Poppins; self-host Switzer).
- **Icons:** simple inline thin-line SVGs (in `ps-components.jsx`, the `icons`
  map). Swap for the codebase's icon set (matching ~1.8px stroke). Never color
  icons azure.
- No third-party brand assets are used in this design.

## Files in this bundle
- `PuhuScribe v2.html` — entry; the design canvas hosting all 5 screens + brand
  panels. **Canvas/frame harness is presentation only — do not port.**
- `brand/tokens.css` — all design tokens + base element styles. **Source of
  truth for color/type/spacing/radii/shadows.** (Ignore the `--lilac`/`--glass`
  and `.ps-theme-snow` indirection; use the Snow values as your base.)
- `brand/ps-components.jsx` — shared components (RegisterCard, Btn, IconBtn,
  SpeakerBtn, Tabs, Bar, Ring, Steps, Orb/OrbCluster, icons, primitives).
- `brand/ps-shell.jsx` — wordmark, screen scaffold, bottom nav, screen router.
- `brand/ps-brandsheet.jsx` — the brand-spec panels (reference for tokens/specimens).
- `brand/ps-screens-flow.jsx` — Onboarding + Day One Sprint.
- `brand/ps-screens-app.jsx` — Daily + Island + Progress.
- `ios-frame.jsx`, `design-canvas.jsx` — **harness only; do not port.**

## Implementation suggestion
Target **React Native + Expo** (iOS-first). Map tokens to a theme object,
RegisterCard to a reusable component, the icon map to your icon set, and the
SVG bubbles to rendered image assets. Recreate screens 01–05 and the floating
tab bar. Preserve the register pairing, the azure reserved-flag rule, the quiet
motion, and the exact Finnish copy.
