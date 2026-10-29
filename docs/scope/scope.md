# Scope: PuhuScribe

PuhuScribe teaches you the Finnish people actually speak, from your first sentence, with the grammar explained honestly when you tap it. It is for adults who moved to Finland in the last 18 months, work in English, are under real pressure to speak Finnish, and have already quit a mainstream app. Version 3.0 takes a total beginner from A0 to A1.

**Source:** this scope is built from the product requirements document `PUHUSCRIBE_V3_PRD.md` (25 September 2026, in `exentrik-os/products/puhuscribe/`). When the two disagree, the PRD wins and this scope gets updated.

**Learner outcome:** after two weeks of 10 minutes a day, a total beginner can handle six everyday situations in spoken Finnish and recognise the written forms.

**North star (30 days after launch):** at least 25 percent of sign ups still active on day 7, a median session of at least 8 minutes, at least half of active learners using speak back in a session, and you finish all six units and hold a 3 minute conversation with a native speaker using only unit content, recorded for the channel.

**Build approach:** Tracer Bullet (one thin real thread through every layer first, then thicken it one strand at a time; nothing faked).
**Workflow:** Beta (after `/develop`: `/check verify`, then `/test`). The project default level of rigor. `/architect` is the recommended first stop for a feature with a real decision, but skippable when you already know the build. Features that touch sign in, personal data, or AI carry `· GA`, which adds a fresh model `/check review`, a `/warden` sweep, `/document`, and your written "approved" line before done.

_These are recommendations to keep your build orderly, not requirements. Skip anything that does not fit: if you already know how to build a feature, use `/develop` and skip `/architect`. You decide when a feature is `done`._

## Rules every feature inherits

These are not rows. They become acceptance criteria inside each spec and rules inside `AGENTS.md`.

- **Five principles, or it does not ship:** every feature serves at least one. (1) Comprehensible input just above the learner's level: short dialogues, never word lists. (2) Spaced retrieval: the learner recalls forms, scheduled automatically, no self rating. (3) Task based units: each unit is a real situation tied to an A1 "can do" statement. (4) Pushed output with feedback: the learner says it back every session. (5) Both registers from day one: spoken Finnish (puhekieli) first, written Finnish (kirjakieli) alongside, both with audio.
- **The not in v3.0 list is binding:** nothing on the PRD's section 4.1 "Not in v3.0" list gets built in this scope (no streaks or confetti, no vocabulary bank, no separate practice modes, no standalone grammar lessons, no language toggle, no mnemonics).
- **One front door, one loop:** the learner opens today's session and never picks a mode. Hear it, Understand it, Say it, Keep it, Use it. The dialogue is the unit of content; words, grammar, review, and conversation all come from it.
- **Nothing unmet is reviewed:** a form enters the review queue only after the learner has met it in a dialogue.
- **Grammar is a card behind a tap, never a lesson.** It keeps the honest grammar stance and the gentle, never shaming correction from the earlier framework.
- **AI at the edges:** AI drafts and explains. It never publishes unchecked content and never decides scheduling or grading. Every AI call is logged with its cost.
- **Nothing unapproved is served:** every Finnish line a learner sees has passed the automatic checks and your native reviewer's approval. Tutor replies are a lower trust tier: shown, never stored as learnable content, never scheduled for review.
- **Spoken Finnish scope:** standard spoken Finnish as a Helsinki adult speaks it in 2026. No regional dialects.
- **Personal data:** GDPR applies. Collect the minimum, explain why, allow export and deletion. Under 18s are out of scope for v3.0.

## At a glance

| # | Feature | Phase | Status |
|---|---------|-------|--------|
| 1 | Stack & architecture | Foundation | done |
| 2 | Coding standards & tooling | Foundation | done |
| 3 | Data model | Foundation | done |
| 4 | Design system & UI foundation | Foundation | done |
| 5 | Content pipeline & native review | Foundation | done (reviewer approval of the first dialogue moves to item 10) |
| 6 | First session loop (Hear it, Understand it) | Slice 1 | done |
| 7 | Daily review (Keep it) | Slice 2 | done |
| 8 | Speaking feedback & voice consent (Say it) | Slice 3 | done |
| 9 | Accounts & personal data | Slice 4 | planned |
| 10 | Units 1 to 3 content | Slice 5 | planned |
| 11 | Units 4 to 6 content | Slice 6 | planned |
| 12 | Tutor step (Use it) | Slice 7 | planned |
| 13 | Onboarding | Slice 8 | planned |
| 14 | Analytics, feedback & crash reporting | Slice 9 | planned |
| 15 | Landing page & waitlist | Slice 10 | planned |
| 16 | Installable app & phone performance | Slice 11 | planned |

## Foundations

### 1. Stack & architecture
Decide the whole stack in one place, starting from the PRD's proposed stack (section 7.3). Then create a new code repository with v2's proven engines imported, not rewritten: the review scheduler, answer grading, the Finnish word analysis pipeline, the AI proxy that keeps keys out of the browser, and the design tokens. Boring stack rule: prefer the established, well documented option.
**Done when:** the stack is recorded in a spec with a runner up and the reason it lost for every load bearing choice, the new repository boots locally and passes build, and the imported engines' own tests pass in it.
- [x] Decide the stack (spec): factory job 1-stack, `factory/jobs/1-stack/spec.md`
- [x] Scaffold from the decision: factory job 1-stack, merged 19 October 2026
- [x] Smoke check it runs: evaluator pass, `factory/jobs/1-stack/evaluation.md`

### 2. Coding standards & tooling
Capture conventions from the real scaffolded project into `AGENTS.md`, fold in the rules above and the project rules (your sign off on GA features, the evidence folder, threat model questions, debug triage, output style), then install lint, format, type checking, a secret scanner, and the hooks that run them.
**Done when:** root `AGENTS.md` reflects the real stack, the five principles, and the binding not in v3.0 list, and lint, format, type check, and secret scan run clean on every stop.
- [x] Capture conventions and tooling choices: factory job 4-tooling, `factory/jobs/4-tooling/spec.md`
- [x] Install the tooling: factory job 4-tooling, merged 20 October 2026
- [x] Check it runs clean: evaluator pass, `factory/jobs/4-tooling/evaluation.md`

### 3. Data model
Core entities, starting from the PRD's sketch (section 7.4): units, dialogue lines in both registers, tokens with their analysed form, forms (the thing that gets reviewed, not the dictionary word), review cards, review logs, sessions, and consents. Includes migrating v2's 104 reviewed sentences and pronunciation data, with the reviewer's marked up corrections applied first.
**Done when:** the entities support form level review scheduling, both registers with audio for each, the session step a learner reached, and voice consent, without a breaking migration later; and the 104 corrected v2 sentences load cleanly and can be loaded again without duplicates.
- [x] Design it (spec): factory job 3-data-model, `factory/jobs/3-data-model/spec.md`, merged 20 October 2026 (104 v2 sentences wait for the reviewer's corrections)

### 4. Design system & UI foundation
Visual direction, brand assets (mascot first, then every illustration in its style, then empty, success, and error states), then the token values in CSS and the art direction in `design.md`, then base components for the single loop. Reuses v2's palette tokens; the component set is new.
**Done when:** `design/brief.md` and `design/assets/` exist, `design.md` covers type, color, spacing, and components with contrast checked in light and dark, base components handle focus and keyboard, and the session screen shell works on a phone sized screen.
- [x] Gather references and generate brand assets: factory job 5-design-system (v2's look, flat sprout icon)
- [x] Design it (spec): factory job 5-design-system, merged 21 October 2026

### 5. Content pipeline & native review · needs a decision · GA
The build time factory every unit comes from. A brief (situation, can do statement, target forms) goes in; AI drafts the dialogue in written Finnish with a spoken rendering per line; word analysis checks every word and sends back anything invalid; AI writes a one line "why" per form, with the analysis as the source of truth for the form's name; the automatic checks run; your native reviewer approves line by line; audio is made for both registers; then it publishes. The spec also settles how spoken Finnish audio is made (synthetic voice tested on spoken spellings, with native recordings of about 40 lines as the fallback).
**Done when:** the first dialogue of unit 1 goes from brief to published with both registers, every word checked, the reviewer's approval recorded, and audio for both registers; the automatic checks in PRD section 8 for word validity, register faithfulness, level fit, and grammar card accuracy pass at their recorded thresholds on `/check eval`; and an unapproved line cannot reach a learner.
- [x] Design it (spec) and build it: factory job 7-content-pipeline, `factory/jobs/7-content-pipeline/spec.md`, merged 21 October 2026. The reviewer's real approval and the unit 1 publish move to item 10.

## Slice 1: First session loop

### 6. First session loop (Hear it, Understand it) · needs a decision · GA
The walking skeleton and the first real slice, merged. A visitor starts as a guest (a real account, no email yet), opens today's session, and hears unit 1's first dialogue line by line in spoken Finnish with the written variant labeled. They tap any word to see its card (base form, which form it is, one line why, both registers), answer a 2 to 3 tap comprehension check, and finish with the one sentence they can now say. The forms they met enter their review queue, and the session plus one usage event are saved. Narrow, but every layer is real.
**Done when:** a new visitor can start as a guest, finish the Hear it and Understand it steps of unit 1's first dialogue on a phone, and afterwards their session, the forms they met, and a `first_session_completed` event exist in the database.
- [x] Design it (spec) and build it: factory job 8-first-session, `factory/jobs/8-first-session/spec.md`, merged 22 October 2026.

## Slice 2: Daily review

### 7. Daily review (Keep it) · needs a decision
Thicken the review strand. Forms met so far come back when they are due: the learner hears or sees a prompt, types the Finnish, and it is graded automatically and rescheduled. No self rating. Spoken recall arrives with slice 3.
**Done when:** a learner who finished the first session sees due forms in a review the next day, every typed answer is graded, and each form is rescheduled from the result.
- [x] Design it (spec) and build it: factory job 9-daily-review, `factory/jobs/9-daily-review/spec.md`, merged 27 October 2026.

## Slice 3: Speaking feedback

### 8. Speaking feedback & voice consent (Say it) · needs a decision · GA
Thicken the speaking strand. Before the first recording, the learner reads in plain words what is recorded, where it goes, and that it is deleted. They shadow each line; the audio goes to speech recognition; the transcript comes back and is compared to the line; feedback is phrase level and kind ("Close, try the double k"). Audio is discarded by default; keeping recordings is an explicit opt in with 90 day retention and deletion. Review gains spoken recall. The speech recognition vendor is chosen by eval on 50 clips of non native learner speech, not by preference.
**Done when:** a learner gives consent, shadows every line of a dialogue and gets feedback on each, only the transcript and a feedback class are stored unless they opted in, the vendor pick meets the word error target recorded in its spec, and the feedback golden set of 30 cases passes at its recorded rate on `/check eval`.
- [x] Design it (spec) and build it: factory job 10-speaking-feedback, `factory/jobs/10-speaking-feedback/spec.md`, merged 27 October 2026.

## Slice 4: Accounts & personal data

### 9. Accounts & personal data · needs a decision · GA
Thicken sign in into full account care. A guest turns into an email account without losing progress, signs in on another device with progress synced, reads a privacy notice, exports their data, and deletes their account.
**Done when:** a guest can add an email and keep every session and review card, sign in on a second device and see the same progress, download their data, and delete their account with all personal data and recordings removed.
- [x] Design it (spec) and build it: factory job 11-accounts, `factory/jobs/11-accounts/spec.md`, merged 29 October 2026.

## Slice 5: Units 1 to 3

### 10. Units 1 to 3 content
Thicken the content strand. The rest of unit 1, then unit 2 (ordering coffee) and unit 3 (at the grocery store), all through the content pipeline and approved by your reviewer as one batch. Adds the optional "Patterns you've seen" panel that gathers the grammar cards met so far.
**Done when:** units 1 to 3 are published with every line approved and audio in both registers, a learner can run the full loop (hear, understand, say, keep) through all three, and the patterns panel lists every form met.
- [x] Build it: factory job 12-units-1-3, `factory/jobs/12-units-1-3/spec.md`, merged 29 October 2026. The native reviewer checks the six dialogues at the end of the MVP.

## Slice 6: Units 4 to 6

### 11. Units 4 to 6 content
The second review batch: unit 4 (small talk about the weather and the weekend), unit 5 (asking for help and repairing a conversation), unit 6 (making a plan with a colleague or neighbour).
**Done when:** units 4 to 6 are published with every line approved and audio in both registers, and a learner can run the loop through all six units, about 180 words and 300 forms met in context.
- [ ] Build it: `/develop units 4 to 6 content`

## Slice 7: Tutor step

### 12. Tutor step (Use it) · needs a decision · GA
Thicken the loop with its last step, from unit 4 onward. A 3 to 4 turn exchange with the tutor, Otso, limited to forms the learner has already met, with at most one small tip. Open ended conversation is a paid feature for later.
**Done when:** a learner in unit 4 or later can finish a 3 to 4 turn exchange with Otso, and on 100 generated turns at least 97 percent of words stay within the learner's met forms on `/check eval`.
- [ ] Design it (spec): `/architect tutor step`

## Slice 8: Onboarding

### 13. Onboarding · needs a decision
Thicken the front door. A short welcome that explains the loop and both registers, then lands the learner straight in today's first session. No placement test: v3.0 starts everyone at A0.
**Done when:** a first time visitor reaches their first dialogue in under one minute and can say in their own words what spoken and written Finnish mean in the app.
- [ ] Design it (spec): `/architect onboarding`

## Slice 9: Analytics, feedback & crash reporting

### 14. Analytics, feedback & crash reporting · needs a decision · GA
Count the north star, privacy respecting. Day 7 retention, median session length, and the share of active learners using speak back, plus AI cost per active learner, an in app feedback form, and crash reporting. The anti metrics (words learned, streak length, screens per session) are never tracked as goals.
**Done when:** the north star numbers and AI cost per active learner are visible on a dashboard you can open without a database query, a test learner's journey moves each number, feedback arrives where you can read it, and a forced error shows up in crash reports.
- [ ] Design it (spec): `/architect analytics, feedback & crash reporting`

## Slice 10: Landing page & waitlist

### 15. Landing page & waitlist · needs a decision
The public page that explains PuhuScribe and collects waitlist emails, including interest in the paid tier, with founding member pricing for early sign ups. Public, so search metadata and social cards matter.
**Done when:** a visitor can read what PuhuScribe is, join the waitlist with consent, and you can see the list; the page has search metadata and a social card.
- [ ] Design it (spec): `/architect landing page & waitlist`

## Slice 11: Installable app & phone performance

### 16. Installable app & phone performance
The app installs to a phone's home screen and feels quick on a mid range phone. This is the last strand before `/liftoff`, alongside your two weeks of daily use and the reviewer's second pass.
**Done when:** the app installs from the browser on Android and iPhone, and a full session runs smoothly on a mid range phone with load times inside the targets recorded in the stack spec.
- [ ] Build it: `/develop installable app & phone performance`

## Deferred
Out of scope for v3.0, kept so the plan stays honest.
- **Units 7 to 12** (v3.1)
- **Weekly conversation practice** using only known forms (v3.1) · needs a decision
- **Payments** (v3.1): the provider is chosen before v3.1 · needs a decision
- **App store builds** (v3.1) · needs a decision
- **Sentence Bank** (v3.2, paid): the learner's own life, translated and scheduled. This is where language islands now live · needs a decision
- **Unlimited open ended conversation with Otso** (v3.2, paid) · needs a decision
- **Pronunciation deep feedback** at the sound level, with progress recordings (v3.2, paid) · needs a decision
- **Offline mode** (v3.2) · needs a decision
- **YKI exam track** (v3.2 onward) · needs a decision

## Legend

**The decision box.** Every feature carries exactly one, the sub task whose label ends with `(spec)`. Its wording varies (`Design it (spec)` normally, `Decide the stack (spec)` on Stack & architecture), so skills locate it by that `(spec)` suffix, never by an exact label. Every other box is an execution box and `/architect` never ticks one.

**Feature lifecycle**: the scope updates as a feature moves; each row is what it shows and who sets it:

| State | Set by | The feature shows |
|---|---|---|
| `planned` · needs a decision | `/scope` | one box: `Design it (spec): /architect <feature>` |
| `in-progress` (designed) | **`/architect` at spec capture** | `Design it` ticked; spec linked; `Build it: /develop <feature>` + **2 to 5 milestones**; the tier's closing boxes (`Verify it` Alpha+, `Test it` Beta+, `Review it` + `Document it` GA); any surfaced follow up enrolled |
| `in-progress` (building) | `/develop` | milestone sub boxes tick one by one; code pointer filled |
| `in-progress` (verified) | `/check verify` | `Build it` + milestones ticked; `Verify it` ticked |
| `done` | **you, when you decide it is** (any skill sets it when you say so); `/sync` reconciles | boxes you ran ticked, skipped ones marked skipped; the tier's last stage (`Beta` → after `/test`; `GA` → after `/document` and your "approved" line) is the suggested point to call it done; `/sync` captures conventions |

- **Next step** = the first unticked box (always a command or a tracked milestone).
- **needs a decision** = run `/architect` first; otherwise straight to `/develop` (or `/audit` for standards & tooling). The tag drops once the spec is captured.
- **Atomic build tasks live in the spec's `## Build plan`, not here**: the scope carries only the milestone rollup.
- **Status** `planned` → `in-progress` → `done`, plus `existing` (pre workflow) and `dropped` (de scoped, kept for history). Rows are never deleted.
- **Workflow tier tag** beside a heading (`· GA`) sets that one feature's rigor above the project default; no tag inherits Beta. GA here also means `/warden` runs and a human writes "approved" plus initials in the verify report before done.
- **Project extras** beside the kit: `/canvas` makes the brand assets, `/check eval` grades AI features, `/warden` sweeps security, `/liftoff` runs the release checklist before any learner outside the team sees the app.
- **Pointer line** (`spec <n> · code in <path>`): the spec link added by `/architect`, the code path by `/develop`.
