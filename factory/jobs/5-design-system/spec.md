# Job 5-design-system: Design system and UI foundation

Scope item 4 in `docs/scope/scope.md`. Date: 21 October 2026. Builds on jobs 1 to 4 as merged on main. Test label: `[design N]`.

Two notes on the scope text. Scope says this item "reuses v2's palette tokens"; you decided in job 1 (call 3) to import nothing visual from v2, so every value here is new. Scope also says "mascot first"; Owner's call 2 asks whether that order still holds, because Otso only appears from unit 4 (job 12, after the MVP).

## What it is

This job gives PuhuScribe its look and its basic screen parts. You choose a design direction from researched references (Owner's call 1, which holds the research). The builder then turns it into one file of design values (colours, fonts, sizes, spacing, motion) that works in light and dark mode, a design guide (`design.md`), and the parts every session screen is built from: the session frame on a phone, buttons, the status line, a tappable Finnish line with its word card, the play control and the record control. A private reference page shows every part in every state so you, the reviewers and the evaluator can check them.

The builder does not start until you have answered calls 1 to 3.

## Done when

Each statement is checked by a command, by the GitHub checks, or by opening the page. "The reference page" means `/design-reference` (statement 16). "Phone size" means 375 x 812 CSS pixels in Chromium and WebKit, as in job 1. Tests carry `[design N]`.

1. **Direction recorded.** `design/brief.md` records the direction you chose in call 1 in one sentence, the date you chose it, the references from this spec it draws on (with links and what is borrowed from each), and your answers to calls 2 and 3. It holds no colour codes or sizes; those live in `design.md`.
2. **Assets folder.** `design/assets/` exists and holds what your answer to call 2 asks for. In the recommended option that is the PuhuScribe wordmark and the app icon source, both as SVG. `design/assets/README.md` lists each file with how it was made, its licence, and the date you approved it. No asset contains Finnish learning content.
3. **Design values in one file.** `src/styles/tokens.css` defines every colour, font family, text size, line height, weight, letter spacing, spacing step, corner radius, motion duration and easing as CSS custom properties with names that say what they are for (for example `--color-text`, `--color-surface`, `--space-4`). Dark mode declares the same colour names again inside `@media (prefers-color-scheme: dark)`. Colour values are hex. A repository test fails if any other file in `src/` contains a raw colour value (hex, `rgb(`, `hsl(`, `oklch(`).
4. **Contrast proven by a test, light and dark.** A unit test reads the values from `tokens.css` and computes the WCAG 2 contrast ratio for every text and background pairing listed in `design.md`, in both modes:
   - Finnish dialogue lines and word card text: at least 7:1;
   - all other text, including the written variant and quieter text: at least 4.5:1;
   - focus outline, control edges, the current line marker and the recording state against what touches them: at least 3:1.

   The test fails if a pairing in `design.md` is missing from the test or the other way round. Changing one value on purpose turns it red; the red run is linked in `build.md`.
5. **Fonts from the app's own address.** The fonts are your defaults unless the chosen direction says otherwise and you approved that: Geist for headings (weight 600, slightly tight letter spacing), Lexend for body text and Finnish lines, Geist Mono for numbers. They come from the pinned `@fontsource-variable/geist`, `@fontsource-variable/lexend` and `@fontsource-variable/geist-mono` packages and are built into the app. No request goes to Google Fonts or any other address. After load, a browser test checks that ä, ö, å, Ä, Ö and Å render in the chosen fonts (`document.fonts.check`). Lexend has no italic style, so `design.md` bans italics for body text. Text sizes use `rem`, so a browser text size change scales all text.
6. **The design guide.** `design.md` at the repository root covers:
   - type: which font for what, the size scale, line length for Finnish lines, how ä and ö stay readable, no italics;
   - colour: every token with its purpose and its contrast results in light and dark;
   - spacing, corner radius, motion (durations and the reduced motion rule);
   - every component with its states and when to use it;
   - how screen text is written: full sentences, gentle corrections, never shaming, the AGENTS.md writing rules;
   - the oldest browser supported (Decision table) and the CSS features that need a fallback;
   - your banned list from this spec, as rules.

   It links `design/brief.md`. The design reviewer uses it as the locked design system from this job on.
7. **Session frame on a phone.** The session frame (shown on the reference page; job 6 puts real content in it) has a top bar with the current loop step's name and a "Leave session" control, a scrolling content area, and a bottom action area. At phone size:
   - the bottom action area stays in view and clear of the iPhone home bar (`env(safe-area-inset-bottom)`);
   - nothing scrolls sideways, also at 320 px wide and with text at 200 percent;
   - the step is named in words, for example "Say it, step 3 of 5", and steps follow the loop order (Hear it, Understand it, Say it, Keep it, Use it, with Use it only when the session has it). Colour is never the only sign of the current step.
8. **Buttons.** Primary, secondary and quiet button styles. Every button and control on the reference page has a tap area of at least 44 x 44 CSS px, measured by a browser test. Each has hover, pressed, focus, disabled and busy states. A busy button keeps its size and tells screen readers what is happening.
9. **Keyboard focus.** Every control works with a keyboard alone, in reading order. Keyboard focus shows an outline at least 2 px thick with at least 3:1 contrast, in both modes, using `:focus-visible`. A browser test tabs through the reference page and checks the order and that each focused control shows the outline.
10. **Status line.** One status line component with `role="status"`. It shows one full sentence ending with a full stop, as in job 2. It has three styles: neutral, gentle correction (for the learner's attempts, for example "Close. Try the double k.") and problem (for system faults such as no connection). A learner's mistake never uses the problem style, a red colour or alarm words. The styles differ by wording and shape as well as colour.
11. **Finnish line and word card.** A dialogue line shows the spoken Finnish first and the written Finnish under it, labelled "Written" in text. Both carry `lang="fi"`. Every word is a button whose tap area is at least 44 px tall and 24 px wide. Tapping a word, or pressing Enter or Space on it, opens the word card. The card is a native `<dialog>` that rises from the bottom on a phone. It has places for the word as it appears, its base form, the name of the form, a one line "why" in English, and the spoken and written forms, each with a play control. It closes with a Close button, the Escape key, or a tap outside it. Focus moves into the card when it opens and back to the same word when it closes. The page behind cannot be used or scrolled while the card is open. Browser tests cover each of these in Chromium and WebKit.
12. **Play control.** A button that plays and pauses one audio file. States: ready, loading, playing, and "could not play" with a "Try again" action. Its accessible name says what it plays, for example "Play the spoken line". Starting one control stops any other that is playing. Audio starts only from a tap or key press, never by itself. Tests use a short generated tone, never speech.
13. **Record control, look only.** The record control's states: ready, recording (elapsed seconds in Geist Mono, and a Stop action), working, and unavailable (with a one line reason). The accessible name changes with the state. This job never asks for the microphone: a test checks that no file in `src/` calls `getUserMedia`. Recording, voice consent and feedback are job 8.
14. **Motion.** Durations and easings come from tokens. When the phone's reduce motion setting is on, nothing slides or scales; changes appear at once or fade. A browser test turns the setting on and checks the word card opens without movement.
15. **Dark mode follows the phone.** The app follows the phone's light or dark setting. There is no switch in v3.0. `index.html` has `<meta name="color-scheme" content="light dark">`. Every component on the reference page renders correctly in both modes.
16. **Reference page.** `/design-reference` shows every token (colour swatches with names and contrast results, the type scale with a Finnish type sample, spacing and radius) and every component in every state, at phone size. It exists in local development and in preview builds, where the preview workflow sets `VITE_DESIGN_REFERENCE=1`, behind the existing Cloudflare Access sign in. A test builds the app without the variable and proves the built files contain none of the reference page's code or samples. Its Finnish is limited to the PRD's own unit 1 example (*mä oon* / *minä olen*) and a type sample of letters and long words, each marked "Sample, not reviewed". No learner ever sees this page.
17. **Automatic accessibility check.** `@axe-core/playwright` runs on the reference page and the front page with the WCAG 2.0, 2.1 and 2.2 level A and AA rules, in light and dark mode, in Chromium and WebKit at phone size. It finds no violations.
18. **Banned look and old phones caught by a test.** A repository test fails if CSS in `src/` uses any of these:
    - from your banned list: `backdrop-filter`, `background-clip: text`, any gradient, `text-transform: uppercase`, a border wider than 2 px on one side only, or the fonts Inter, Space Grotesk or Bricolage Grotesque;
    - CSS newer than the oldest supported Safari without a fallback: `light-dark(`, `color-mix(`, `@starting-style`, `@property`, `@container`, or the `popover` attribute.

    Each rule is proven by a red run on purpose. Vite's `build.cssTarget` is set to the oldest supported Safari. The rest of the banned list (glow, pills, icon sprinkles, card grids, eyebrows, writing rules) is in `design.md` for the design reviewer.
19. **The front page keeps working with the new base styles.** The Hei! page picks up the base styles (fonts, colours, spacing) and nothing else about it changes. Job 2's test "[smoke 1] adds no styling" checked the browser defaults that job 2's spec kept "until job 4". It is replaced by a test labelled `[smoke 1] [design 19]` proving the page loads only its own stylesheet and font files, all from its own address, and still no images, icons or media. `build.md` lists every changed test line. Every other test from jobs 1 to 4 passes unchanged.
20. **Records and costs.** `docs/conventions.md` lists `design/`, `src/styles/` and `src/components/` with a real example file each, and adds the `[design N]` label row. New npm packages are only the three font packages and `@axe-core/playwright` (development only); any other package needs a reason in `build.md`. Running costs stay €0 a month unless you choose a paid option in call 2.

Product rules from `AGENTS.md` that apply here: spoken Finnish first, written Finnish alongside and labelled (P5); grammar is a card behind a tap; corrections are gentle and never shaming; no streaks, confetti, badges or progress maps; the learner never picks a mode; nothing unapproved is served (the reference page is never learner facing); no placeholders or fake data in the learner app; never delete or weaken a test; client facing text in English.

## Decision

The look is your call (call 1). These are the technical choices underneath any look.

| Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|
| How styles are written | Plain CSS: design values as custom properties in `tokens.css`, one CSS Module per component (built into Vite) | Tailwind CSS v4, which the PRD (7.3) names "for layout only" | Tailwind v4 "specifically depends on" Safari 16.4, Chrome 111 and Firefox 128. Job 2 taught us learners use older phones. The PRD keeps brand values in custom properties anyway, so Tailwind would only add a build tool for layout. This departs from PRD 7.3; approving this spec accepts that |
| Oldest browser supported | Safari 15.4 on iPhone (March 2022), which brings the `<dialog>` element and the `dvh` screen height unit | Safari 16.4, which would allow Tailwind v4 | iPhones whose last update is iOS 15 would get a broken app (I believe these include the iPhone 6s, 7 and first SE; not verified today). Job 16 can raise the floor with real usage data |
| Dark mode | `@media (prefers-color-scheme: dark)` declaring the same colour names again | CSS `light-dark()` | `light-dark()` needs Safari 17.5 |
| Colour values | Hex values in CSS, chosen in the OKLCH colour model so lightness steps look even (the approach Linear describes) | `oklch()` values directly in CSS | `oklch()` needs Chrome 111 on Android phones; hex works everywhere and keeps the contrast test simple |
| Fonts | Self-hosted from `@fontsource-variable` packages (OFL 1.1 licence, latin and latin-ext subsets, which include ä, ö and å) | Google Fonts links | Each visit would send the learner's IP address to Google, and job 2's test that every request goes to the app's own address would fail |
| Word card overlay | The browser's own `<dialog>` element, with focus returned to the word in our code | React Aria Components (Adobe) Modal and Dialog | A library for one component. `<dialog>` works from Safari 15.4 and gives Escape handling and an inactive background for free. We return focus ourselves, so we do not depend on browser differences. If WebKit tests show the page behind still scrolls, the builder adds a small scroll lock in code |
| Reference page | A route in the app, built only for development and previews | Storybook | A second tool chain to keep in step with Vite 8 (its Vite 8 support not checked), more check minutes, and the evaluator already tests preview links |
| Accessibility testing | `@axe-core/playwright` (Deque) inside the existing browser tests, plus keyboard tests | Checking by hand, or Lighthouse | Runs on every pull request. Automatic tools find only part of the problems, so keyboard tests and the design reviewer cover the rest |
| Contrast checking | A unit test using the WCAG 2 formula on the values in `tokens.css` | An online contrast checker used by hand | Not repeatable; values drift after the first check |

### Notes for the builder

- Put components in `src/components/` (PascalCase `.tsx` with a `.module.css` beside each) and global styles in `src/styles/`. Keep the reference page in its own folder and load it with a dynamic `import()` behind `import.meta.env.VITE_DESIGN_REFERENCE`, so production builds leave it out.
- Word buttons inside a sentence count as inline targets under WCAG 2.5.5, so they do not need 44 px of width. They still need 24 px (WCAG 2.5.8) and 44 px of height.
- Use `100dvh` with a `100vh` line before it for older browsers.
- The generated test tone should be a format both Chromium and WebKit play. If headless WebKit on GitHub's Linux runner cannot play audio, say so in `build.md` with evidence and test the states that can be tested there. Do not drop the Chromium playback test.
- Lexend is wide. Check that long Finnish words in the type sample wrap without overflowing at 320 px; tell the manager if they do not, because that becomes an owner's call on fonts.

## Out of scope

- Any real learner screen: the first session (job 6), review (job 7), speaking feedback and consent (job 8), accounts (job 9), the "Patterns you've seen" panel (job 10), the tutor step and any Otso screen (job 12), onboarding (job 13), the landing page (job 15), the install manifest, home screen icons and offline behaviour (job 16).
- Microphone access, real Finnish audio, text to speech, or any provider.
- Any Finnish learning content. The only Finnish is the marked samples on the reference page.
- A light or dark mode switch, a font size setting, or a language switch (the bilingual toggle is on the PRD's "Not in v3.0" list).
- Anything else on that list, in particular: streaks, rank titles, confetti, milestone ladders or journey maps, celebration animations, a vocabulary bank, or separate practice modes. Success states are quiet text.
- Tailwind, Storybook, a component library, an icon set, or a CSS-in-JS library.
- Generating a mascot or illustrations unless your answer to call 2 asks for them in this job.
- Any change to v2 files, the database, or the Worker's API.

## Build plan

1. **One sample first (stop for your OK).** Tokens for the chosen direction in light and dark, self-hosted fonts, and the session frame with one sample line, the play control and the record control on the reference page. Screenshots at phone size, light and dark, Chromium and WebKit, go to you. The builder stops until you approve the look or ask for changes. Covers 3, 5, 7, 15.
2. **Rules written down and tested.** The contrast test, the raw colour test, the banned look test, `design.md`, `design/brief.md`, and `design/assets/` as your call 2 answer says. Covers 1 to 4, 6, 18.
3. **The components.** Buttons, status line, Finnish line with word card, play control and record control, with focus, keyboard and reduced motion handling. Covers 8 to 14.
4. **Reference page and checks.** Build-time gating, the preview workflow variable, axe checks in both modes and both browsers, the 320 px and 200 percent text checks, the replaced smoke test, and the conventions update. Covers 16, 17, 19, 20.

Dependencies: GitHub checks, preview links and Cloudflare Access exist from job 1. No database or Worker change is needed.

## Risks and flags

- **Finnish content.** The reference page shows *mä oon* / *minä olen* (from the PRD) and a type sample, marked "Sample, not reviewed". No learner sees them and they never reach the live app, so they do not go to the native reviewer unless you want them to.
- **Images with Finnish in them.** If you later choose photos or AI images (calls 1 and 2), any Finnish visible in them (shop signs, labels) is Finnish content and goes to the reviewer. AI image tools often get Finnish words wrong.
- **Paid services.** None in the recommended path. Call 2 options B and C cost money.
- **Learner data.** None. Self-hosted fonts mean no learner IP address goes to a font service.
- **Database and access rules.** None.
- **Departure from the PRD.** No Tailwind (PRD 7.3). Approving the spec accepts it.
- **A job 2 test changes.** "[smoke 1] adds no styling" is replaced as statement 19 describes. It was written to hold only until the design job, and its other checks stay.
- **Preview workflow change.** One non-secret build variable is added to the preview build.
- **Look of the city.** Direction B borrows from the City of Helsinki's design system. Copying its colours, wave shape or logo could suggest the city endorses PuhuScribe. Helsinki Grotesk is a paid font licensed to the city, so we cannot use it.
- **Limits of automatic checks.** axe and the browser tests cannot replace a real screen reader. Five minutes with VoiceOver on your iPhone on the preview, once the components exist, would catch what they miss. Optional.

## Owner's calls

### 1. Design direction

**Two line summary.** The award galleries had almost nothing for language learning, and Pinterest showed me nothing without a login, so the strongest ideas came from the niche's best apps, Finnish public design, and calm audio and reading products. I group them into three directions and recommend A, "Calm reader with audio".

**How I researched, and what I could not see.** My web tool reads page text, not pictures. Every description below comes from the page's own text, a published case study, or design system documents, and I say which. Please open the links to see the actual look before choosing.

Gallery and library scan:
- Awwwards: the education category (31 sites) and a "language learning" search had no strong language app. The one relevant result is Senthora (reference 2).
- Godly: godly.website now redirects to recent.design, a gallery called "Recent". Its front page had nothing for education. Its one audio-related entry is a work-in-progress ElevenLabs brand identity (typographic, minimal, black and white), with no detail to borrow.
- SiteInspire: a "language" search returned architecture and studio sites only.
- Land-book and Mobbin refused my tool (403). Mobbin needs a login and a paid plan for full flows. Refero and Dribbble load by script and showed my tool nothing.
- **Pinterest blocked me.** Its search page (`pinterest.com/search/pins/?q=language learning app ui`) and its ideas page (`pinterest.com/ideas/language-learning-app-design/`) returned only the word "Pinterest" to my tool, which means a login wall or script-only page. Web searches for Pinterest pins returned no pins at all. So this spec uses no Pinterest pin, and none of the references below comes from Pinterest.
- Results in the niche are weak, so I borrowed from other fields, as your rules ask.

**Browsing Pinterest yourself (optional, before you choose).** Signed in, these searches cover what you asked for: "language learning app ui", "speaking practice app", "audio player transcript ui", "calm mobile app design", "meditation app ui", "reading app typography", "design system mobile". Two cautions from what the searches did show around Pinterest. First, much of what ranks for "language learning app" is sold UI kits (on Dribbble, Creative Market and similar) built around leaderboards, achievement badges and streaks, which your product rules ban. Second, "calm" app concepts often use exactly the cream, terracotta and sage scheme on your banned list (one example: the "Mindfy Ritual" concept at https://superdesign.dev/library/mindfy-ritual-phase-4-insight, which also has a frosted glass control). If you save pins you like, send me the pin links and I will trace each one back to its original designer or real app and add it to `design/brief.md` with both links.

Niche scan (the best language apps today, what each does well, and what PuhuScribe must avoid):

| App | Does well | Avoid |
|---|---|---|
| Speak | Speaking is the centre; "Real conversation. No pressure." | XP, streak badge and calendar, leagues with tiers, a mascot |
| Praktika | Warm "no judgement" tone; a feedback strictness choice (Soft, Balanced, Strict) | Four AI tutor avatars with portraits, a purple glow, "01 / 05" numbering |
| Babbel | Premium 2024 rebrand; photos of real learning situations | Discount banner with a countdown timer |
| Busuu | Feedback framed as confidence | Little to borrow visually |
| Duolingo | A clear, consistent brand system | Character-led "quirky" brand built on its owl, the gamified treadmill our learners quit |
| Langua (LanguaTalk) | Imports your own videos and articles | An emoji in front of every feature, a flame streak counter |
| Senthora | Words light up as you say them | Uppercase eyebrows, "01 / 04" numbering, star badges, a 7 day streak |
| Lingvis | Free and Finnish focused | Green, yellow and red colour coding of words, word lists |

#### The references

1. **Speak**. Links: https://www.speak.com/ and https://screensdesign.com/apps/speak-learn-spanish-french/ (182 captured app screens, described in text).
   What it is: the leading premium speaking app.
   Borrow: the lesson screen's shape (one phrase card, a progress line at the top, playback controls along the bottom, one large "Speak now" control), and the "Can't speak now" option, which suits a learner on a tram. Tone: short, low pressure.
   Avoid: XP, streak badge and calendar, leagues with tiers, a blue mascot (all seen in the screen captions).
2. **Senthora** (the one language app Awwwards lists). Link: https://senthora.ai
   What it is: an AI speaking tutor app.
   Borrow: in its read aloud exercise the text tracks you word by word ("Repeat until the whole paragraph lights up"). That is a strong model for Say it in job 8. Tone: "No drills. No judgment."
   Avoid: uppercase eyebrows, "01 / 04" step numbering, a "★ ONLY IN SENTHORA" badge, a 7 day streak.
3. **Babbel, 2024 rebrand by Koto Studios**. Link: https://babbel.com/press/en-us/releases/babbel-unveils-a-bold-new-chapter-a-transformational-rebranding
   What it is: Babbel's move to a premium brand (press release, February 2024).
   Borrow: one text typeface (Feature Text) used across product and marketing "to convey a premium feel"; a small set of brand elements (cut-out images, product cards, photography) used everywhere; photos of real people in real situations, which for us would mean a Helsinki café counter or a K-market aisle.
   Avoid: the orange, the discount countdown banner on babbel.com.
4. **Lingvis**, which replaced Yle Kielikoulu. Link: https://sprakkraft.org/lingvis-finland
   What it is: a free, publicly funded app for learning Finnish and Swedish from real media, aimed at migrants. It is the local alternative our learners may already know.
   Borrow: one player that reads text aloud, and practice that never interrupts reading.
   Avoid: words coloured green, yellow and red by level. That uses colour alone, judges the learner, and points to word lists.
5. **Helsinki Design System (HDS)**. Links: https://github.com/City-of-Helsinki/helsinki-design-system and a summary of its tokens at https://open-design.ai/design-system-assets/locales/fr/DESIGN-helsinki.md. The official site https://hds.hel.fi loads by script and showed my tool nothing; its WCAG 2.1 AA claim comes from the search index of hds.hel.fi.
   What it is: the City of Helsinki's open source (MIT) design system for its digital services.
   Borrow: accessibility as the floor (WCAG 2.1 AA, much of AAA); buttons at least 56 px tall; a 3 px focus outline; error messages that never rely on colour alone; near-black text (black-90); a plain, signage-like clarity that newcomers in Helsinki already see on city services.
   Avoid: its error style with a coloured border down one side (on your banned list), the paid Helsinki Grotesk font, and anything that looks like the city's own brand.
6. **Oura app, design refresh by Instrument**. Link: https://www.instrument.com/work/oura-app
   What it is: the Finnish smart ring company's app; a calm, premium daily check in.
   Borrow: three levels of detail (a quick glance, a focused view, a deep view), which map to our line, word card and "Patterns you've seen" panel; colour used only to "direct attention to what matters most"; the stated aim "lighter, faster, and more grounded".
   Avoid: score rings and rows of big numbers; we do not show the learner scores.
7. **Apple Podcasts transcripts**. Link: https://www.apple.com/newsroom/2024/03/apple-introduces-transcripts-for-apple-podcasts/
   What it is: Apple's read-along view for podcasts (March 2024).
   Borrow: "each word is highlighted" as the audio plays; tapping text plays from that point; font and contrast "designed to make long-form text easier to scan and read". Apple itself names learning a language as a use. This is the closest model for Hear it.
8. **New York Times Games app**. Links: https://techcrunch.com/?p=2675705 (redesign, March 2024) and https://www.creativereview.co.uk/new-york-times-games-wordle-crossplay-design-jonathan-knight/ (July 2026, only the opening was readable).
   What it is: the best known adult daily habit in apps: short sessions fitted into a routine (morning, coffee, commute).
   Borrow: "we used a lot of color" so each game has its own identity, with "streamlined" type; cards that show progress so you come back and finish ("Continue today's session").
   Avoid: the Leaderboard and Stats tabs.
9. **Waking Up, redesign by Partner**. Link: https://www.100archive.com/projects/waking-up
   What it is: a meditation and philosophy audio app (2021 case study).
   Borrow: the interface steps back so the content leads; the brief was for browsing to feel like walking through a modern art museum. The case study says little about type or colour.
10. **Linear, "How we redesigned the Linear UI"**. Link: https://linear.app/now/how-we-redesigned-the-linear-ui
    What it is: a work tool, included for one technique.
    Borrow: each colour theme is built from three inputs (base colour, accent colour, contrast) in the LCH colour model, cut down from 98 values. This gives even light and dark themes and a high contrast option almost for free.
    Avoid: its font (Inter, banned) and its dense developer look.

#### Three directions

All three use your default fonts: Geist 600 with slightly tight letter spacing for headings, Lexend for body text and Finnish lines, Geist Mono for numbers. Lexend was designed for easier reading (its own site cites a small study of 20 children), which suits learners. All three obey your banned list: no serif with cream and orange, no near-black with neon, no gradients, glow or frosted glass, no pills, eyebrows or accent bars, and no emoji or icon in front of every heading.

**A. Calm reader with audio** (from references 1, 6, 7, 9 and 10)
- Feel: reading along with a well made podcast. The Finnish text is the main thing on screen and there is almost no decoration.
- Colour: a cool, very light grey-white surface (never cream), ink-dark text, and one deep accent such as a dark blue-green. The accent is used only for the current line, the main control and focus. A second quiet tone marks a gentle correction. Dark mode uses a deep blue-grey (not black) with soft white text and a lighter accent. The themes are built from three inputs, as Linear does.
- Type: Finnish lines large (around 22 to 24 px), the written variant smaller under each line. Step names in Geist 600. Times and counts in Geist Mono.
- A session screen: the step name and "Leave session" at the top. The dialogue reads like a transcript; the current line sits on a soft tinted band and each word lights up as it is spoken. Below each spoken line is its written form, labelled "Written". One large play control sits at the bottom within thumb reach, and in Say it it becomes the record control. Tapping a word raises the word card from the bottom. Motion is short fades and one slide.
- For learners: best readability for ä and ö at large sizes; lightest on older phones (no images); dark mode comes naturally; easiest to keep at 7:1 contrast. Risk: it can look plain, like many minimal apps, unless the type, spacing and the word highlight are done very well. It is less distinctive in video thumbnails and on the landing page.

**B. Helsinki public service clarity** (from references 4, 5, 6 and 8)
- Feel: crisp and local, like the best Finnish public services and transit signs. High contrast, square or nearly square corners, big controls.
- Colour: white with near-black text and one strong saturated blue for actions, plus a green-teal second colour. Flat colour, no tints. Dark mode: dark navy-grey with white text and a lighter blue. It must not copy the city's palette or logo.
- Type: larger and heavier than A. Step names read like signs.
- A session screen: full-width buttons at least 56 px tall, stacked at the bottom. Each line sits in a clear block. The word card fills most of the screen with large text.
- For learners: strongest legibility in sunlight and the most accessible; feels local and trustworthy; the easiest to build well. Risk: it can feel like the official forms (Migri, Kela) that are the source of the pressure our learners feel, and it looks less premium. People may read it as a city service.

**C. Flat colour for each loop step, with real photos** (from references 1, 2, 3 and 8)
- Feel: confident and editorial, warmer and more branded. Each loop step owns one flat colour, so the learner always knows where they are. Each unit opens with a real photo of its situation.
- Colour: five muted flat step colours (no gradients), each paired with text that passes contrast, on plain light or dark surfaces. In dark mode the step colours become deeper fields with light text.
- Type: Geist 600 at large display sizes for step names and unit titles.
- A session screen: the top third is the step's colour with its name. The dialogue sits on a plain surface below. In Say it each word lights up as the speech is recognised (job 8).
- For learners: the most distinctive option and the best for video and the landing page; it shows progress through the loop without streaks. Costs: photos (your own photos cost time; commissioned photos cost money; AI photos risk wrong Finnish on signs, which counts as unreviewed Finnish); five colours in two modes are harder to keep above the contrast floor; photos add weight on older phones; colour must never be the only sign.

**Recommendation: A.** Our learners are adults under pressure who quit gamified apps. The core task is listening to and reading Finnish on a phone, often on the move, and A is built for exactly that. It needs no images, so it costs nothing, stays fast on older phones and lets the mascot decision wait. Its risk (looking plain) is fixed by craft, not by money. If you want more character, C's step colour could appear as a small touch in A's top bar; that would be your call at the sample stage.

### 2. Brand assets and the mascot, Otso

Otso is the tutor in the Use it step, which starts at unit 4 (job 12, after the MVP). No MVP screen needs him. (Otso is a traditional Finnish name for the bear.)
- **A. Type only for now.** The wordmark "PuhuScribe" set in the heading font, and an app icon made from it, both SVG. Empty, success and error states are plain, kind text. Otso is decided with job 12. Cost €0. This changes scope.md's "mascot first" order.
- **B. AI-generated Otso and a small set of state pictures now.** For example with OpenAI's image models, which you already have an account for. OpenAI's guide lists GPT Image 2 at $0.006 (low), $0.053 (medium) or $0.211 (high quality) per 1024 x 1024 image. An exploration of about 60 high quality images is about $13, more than the €10 cap you set on that account, so the cap would need raising. Midjourney starts at $10 a month according to third-party pages; its own pages refused my tool. Risks: keeping one character consistent across poses is hard, results can look AI-made, and image rights depend on each tool's terms, which I have not checked.
- **C. Commission a human illustrator** for Otso and the state pictures. Best quality and a style that is ours alone; it takes weeks, and the licence must cover app and marketing use. I could not verify a price; quotes are needed.
- Recommendation: **A** now. Decide B or C when job 12 is specced, once the look is set.

### 3. How many samples before the build

Your rules ask how many variations to build.
- **One sample** of the chosen direction (the session frame in light and dark, at phone size). You approve or adjust it, then the builder continues. This is the build plan as written.
- **Two samples** side by side, for example A and C, before you commit. This takes about one extra builder hour and costs nothing.
- Recommendation: one sample if you are sure of your pick; two if you are torn between two directions.

### 4. Spending and email

Nothing in the recommended path costs money, and no email address is needed. Call 2 options B and C, and any commissioned photos for direction C, would need your spending approval first.

## Could not verify

- The look of any reference page. My tool reads text only, so colours and layouts described above come from each page's text, case studies or design system documents.
- Pinterest: blocked without a login (search and ideas pages returned only the word "Pinterest"), and web searches surfaced no pins. No Pinterest pin was used or traced.
- Land-book, Mobbin (403), Refero and Dribbble (script only, nothing visible), hds.hel.fi (script only), oura.com (403), Midjourney's own pricing (403), openai.com pricing (403; I used OpenAI's developer guide instead).
- Whether godly.website and recent.design are the same gallery under a new name. The redirect is real; the relationship is not stated.
- HDS sizes and colour names come from a third-party summary of hds-core 5.2.2, not from HDS's own pages.
- Lexend's reading benefit rests on one small study published on its own site.
- Which iPhones stop at iOS 15.
- Whether WebKit returns focus after a `<dialog>` closes and stops the page behind from scrolling on iOS. The spec has the code do both itself.
- Whether headless WebKit on GitHub's Linux runner plays audio.
- Whether Storybook supports Vite 8.
- Illustrator and photographer rates, and the image rights terms of each AI tool.
- Whether the dots on ä and ö in Lexend and Geist stay clear at small sizes. The type sample on the reference page shows this at sample stage.

## Sources

- Tailwind CSS v4 browser support: https://tailwindcss.com/docs/compatibility
- WCAG 2.2 target size, minimum (24 px, AA): https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html
- WCAG 2.2 target size, enhanced (44 px, AAA, inline exception): https://www.w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html
- `<dialog>` support (Safari 15.4): https://caniuse.com/dialog
- `light-dark()` support (Safari 17.5): https://caniuse.com/mdn-css_types_color_light-dark
- `color-mix()` support (Safari 16.2): https://caniuse.com/mdn-css_types_color_color-mix
- `oklch()` support (Safari 15.4, Chrome 111): https://caniuse.com/mdn-css_types_color_oklch
- `dvh` support (Safari 15.4): https://caniuse.com/viewport-unit-variants
- Geist font (OFL 1.1): https://github.com/vercel/geist-font
- Fontsource font data (subsets, weights, styles, licence): https://api.fontsource.org/v1/fonts/geist, https://api.fontsource.org/v1/fonts/lexend, https://api.fontsource.org/v1/fonts/geist-mono
- npm packages (version 5.3.0, OFL 1.1): https://registry.npmjs.org/@fontsource-variable/geist/latest, https://registry.npmjs.org/@fontsource-variable/lexend/latest, https://registry.npmjs.org/@fontsource-variable/geist-mono/latest
- Lexend's purpose and study: https://www.lexend.com/
- React Aria Modal: https://react-aria.adobe.com/Modal
- axe for Playwright (Deque): https://github.com/dequelabs/axe-core-npm/blob/develop/packages/playwright/README.md
- OpenAI image prices per image and transparent backgrounds: https://developers.openai.com/api/docs/guides/image-generation
- Midjourney plans (third-party): https://eesel.ai/blog/midjourney-pricing
- Recraft licence terms (free plan images not for commercial use): https://www.recraft.ai/pricing
- Duolingo rebrand by Johnson Banks: https://www.creativereview.co.uk/duolingo-rebrand-johnson-banks/
- Praktika: https://praktika.ai/
- Busuu: https://www.busuu.com/
- Langua: https://languatalk.com/langua
- Babbel home page (discount banner): https://www.babbel.com/
- Awwwards education category: https://www.awwwards.com/websites/education/ and search: https://www.awwwards.com/websites/?text=language+learning
- Recent (godly.website redirect): http://recent.design/?ref=godly and the ElevenLabs entry: https://recent.design/i/p35y20j-elevenlabs-brand-identity
- SiteInspire search: https://www.siteinspire.com/websites?search=language
- Pinterest (blocked, tried): https://www.pinterest.com/search/pins/?q=language%20learning%20app%20ui and https://www.pinterest.com/ideas/language-learning-app-design/
- "Calm" concept showing the banned cream and terracotta scheme: https://superdesign.dev/library/mindfy-ritual-phase-4-insight
- Reference links 1 to 10 are listed with each reference above.

Result: ready for owner approval
