# Job 5-design-system: summary

Stage: waiting for the owner to choose a design direction and answer the other owner's calls.

## Manager's visual check of the references (21 October 2026)

The spec writer's tool reads page text only, so it never saw the designs. The manager opened references in a real browser:
- Speak (speak.com): light page, friendly blue, real photo with a waveform and phrase card on top. Matches the spec's description.
- Senthora (senthora.ai): dark purple background, neon mesh, gradient headline text. Its look breaks the owner's banned list (purple glow, gradient text). Only the "words light up as you read aloud" idea is worth borrowing, not the look.
- Instrument's Oura case study and Waking Up on 100 Archive: the pages loaded without visible images in the test browser; descriptions only.
- Dribbble "language learning app": mostly mascots, bright gamified kits and leaderboards. Confirms the spec writer's finding that the niche's public design work is weak.

## Pinterest (owner's request, searched signed in by the owner)

Language-learning searches returned the same gamified UI kits. Pinterest offers a "Less AI" filter because many pins are AI-made mockups, and most pins carry no source link. Three useful finds:
1. Google's AI Edge dictation app, pin https://www.pinterest.com/pin/4594938332174765184/ traced to Digital Trends: https://www.digitaltrends.com/computing/googles-new-free-dictation-app-is-the-willow-alternative-you-have-been-waiting-for/ . Borrow: a "Listening" state, the live transcript in one quiet card, two large round controls at the bottom. Avoid: the faint pastel glow behind it.
2. A calm planner concept, pin https://www.pinterest.com/pin/786863366192912852/ . No source link; the uploader says in a comment that it is their design, not verified. Borrow: a soft grey surface, generous spacing, one photo card for the day, a short greeting. Avoid: its small pills.
3. A minimal voice message row, pin https://www.pinterest.com/pin/847943436091942914/ . No source link, not traceable. Borrow: a single slim waveform with a play button for playing back what the learner said.

Look options page (21 October 2026): factory/jobs/5-design-system/look-options.html, published privately at https://claude.ai/artifact/3Tgttr32ZaLBXGXVUKoJi4 . The three directions drawn as phone screens of the same Hear it moment, plus the references with links. Made because the owner could not choose from descriptions alone.

## Owner decision (21 October 2026): use v2's look

Fumnanya rejected directions A, B and C and chose v2's own design (https://puhuscribe-v2.vercel.app and /landing; tokens in v2's src/styles/tokens.css), wanting it quickly with no heavy fine-tuning. This overrides the job 1 call to import nothing visual from v2.
Keep from v2: the white-to-lilac ground, ink colours, purple for kirjakieli (#6B46C1) and teal for puhekieli (#1F7C8E) with their tints, the azure flag for changed words (#2F5AD6), the pastel blush, mint and lavender blocks, soft white cards with soft shadows, the radii and spacing scale, black pill buttons, Poppins for headings and Switzer for body (v2's own fonts, so they replace the default Geist and Lexend), the PuhuScribe wordmark with the sprout icon.
Leave out (owner's banned list): small uppercase eyebrow labels, 01/02 numbering, the glossy and orb gradient effects, glass tokens, icon squares on every card, pills used as decoration.
Process: the builder first makes ONE sample screen (the Hear it step at 375 px, both registers, a highlighted spoken word, the audio control) and stops; the owner sees it before the rest of the design system is built.
Brand call: reuse v2's wordmark and sprout icon, flat (no gloss). Otso is decided at the tutor job. No spending.

Owner clarification (21 October 2026): v2 is a starting point, not a pixel-for-pixel copy. Take v2's colours and general layout (the dialogue card pairing written and spoken Finnish, the azure changed words, black pill buttons, white and lilac ground), then improve it, borrowing ideas from the look options page, mainly direction A's word highlighted as it is spoken, the audio player with a waveform at the bottom, and calmer spacing. The owner supplied the Claude Design handoff for v2 (copied to design/v2-handoff/ on the job branch).

Owner decisions on the sample (21 October 2026):
- Sample approved: build the rest of the design system in this look.
- Font: use Switzer for body text, like v2. The owner approved downloading it from Fontshare and accepting its ITF Free Font License (commercial use allowed; the font files must never be published openly, and must leave git if the repo ever goes public).
- Background: bring back v2's subtle white-to-lilac fade (linear-gradient 180deg, #FFFFFF 0%, #FAF9FC 58%, #F1F0F6 100%). This is an owner-approved exception to spec statement 18 for the page background only; every other gradient stays banned.

Round 2 built (0f94502, run 39618302752, all green): Switzer self-hosted unchanged with its licence, v2 page fade as the one allowed gradient, all components, reference page at /design-reference, design.md, brief, flat sprout icon and wordmark (owner has not yet seen the flat icon). Manager decision for speed (owner asked why it takes so long): reviewers and evaluator run in parallel.

Reviews round 1: design pass (should fix: record ring clipped, a first-time hint about blue words and tapping, sample top bar vs SessionFrame; best single improvement: text-height washes for changed words), security pass (notes: build-test markers from shared controls, .gitattributes binary rule too broad for FFL.txt, @axe-core/playwright only 6 days old).
Evaluator round 1: fail on 17 (Try again button contrast in WebKit dark, from browser default button styling) and 18 (banned-look test misses Inter via token or font shorthand, border-width form, uppercase in capitals, gradients in inline styles). Round 3 sent to the builder for all of these.
Manager decision: the record timer uses Switzer with tabular numbers, following the owner's choice of v2's fonts (Poppins and Switzer replace Geist, Lexend and Geist Mono).

Round 3 (a65a783, run 39630337390, all green): all 13 fixes. Text-height washes, Try again token colours with an axe test of the not-saved state, banned-look test reads tokens, shorthand, border-width lists, any case and inline styles, play control keeps focus, axe pinned to 4.13.0. The hint omits "Tap a word" because the sample's words are not buttons. Evaluator re-check started; no second review round (round 3 applied the reviewers' own items).

## Approval summary (21 October 2026)

What changed, in plain words:
1. PuhuScribe v3 now has its look: v2's colours, fonts (Poppins and Switzer) and soft white-to-lilac background, with spoken Finnish on a teal band, written Finnish in violet and the changed words in blue.
2. The building blocks every screen will use exist: the session frame, buttons, the status line, a Finnish line whose words open a card when tapped, the play control (the spoken word lights up) and the record control.
3. A reference page shows every colour, text style and component in light and dark mode; it and the sample never reach learners.
4. Automatic checks guard the look: accessibility in both modes, colour contrast, and your banned styles (only v2's page fade is allowed as a gradient).
5. Still €0 a month. Switzer is free under its licence, which forbids publishing the font files openly.

Evidence: factory/jobs/5-design-system/evidence/ (start with r3-eval-18-break-tests.txt, r3-eval-17-front-not-saved-webkit-dark.png, r3-eval-7-sample-ready-webkit-light.png)
Checks: all green on PR #12 (run 39630337390).
Reviews: design pass, security pass. Evaluator: failed round 1 (contrast gap, holes in the banned-look test), passed after round 3.
Owner to confirm at approval: the flat sprout icon (design/assets/).
Open items: VoiceOver on a real iPhone; small caps (font-variant-caps) not caught by the banned-look test; the record timer format belongs to job 8; the production build must force VITE_DESIGN_REFERENCE off at liftoff.

Overview page (21 October 2026): factory/jobs/5-design-system/overview/design-so-far.html, published privately at https://claude.ai/artifact/D7KzR1Y73h899GHX9gfJRv . Explains the sample screen, the word card, the parts catalogue in sections, the icon and name mark, what changed from v2, and the owner's choices.
