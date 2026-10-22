# Job 12-units-1-3: Units 1 to 3 content

Scope item 10. Routine tier, flagged look closely (Finnish content, paid services, reads learner data). Date: 21 October 2026. Builds on jobs 3, 5, 7 and 8 as merged on main, and on jobs 9 and 10 for the full loop test. Test label: `[units N]`.

## Summary for the owner

1. This job uses the content pipeline from job 7 to draft six dialogues: two for unit 1 (meeting people), two for unit 2 (ordering coffee) and two for unit 3 (at the grocery store).
2. Every draft passes the automatic checks and gets audio in spoken and written Finnish, then waits as review pages for your native reviewer, who checks all six in one batch at the end of the MVP (about 2 to 3 hours, my estimate).
3. Nothing reaches a learner until the reviewer approves. The job merges with everything else finished, and its last statement, "published", stays pending the reviewer.
4. It also adds the "Patterns you've seen" panel: from any word card, one tap shows every word form the learner has met, grouped by pattern, each with the line where they met it.
5. Running cost is about $0.50 of Anthropic use per unit and €0 for voices (my estimate from job 7's numbers). One call for you: whether units go live together or one by one after review.

## What it is

PuhuScribe's first three real situations, written as short dialogues in spoken and written Finnish with audio, ready for the native reviewer. Plus a small optional panel that gathers the grammar cards a learner has met so far, so they can see patterns across dialogues without a grammar lesson.

It serves P1 (short dialogues), P3 (each unit tied to an A1 "can do"), P5 (both registers with audio) and, through the loop it feeds, P2 and P4.

## Done when

Terms. "The pipeline", "the workflow", "the review page" and "the Python check" are job 7's. "Kirja" is written Finnish, "puhe" is spoken Finnish. "Browser test" means Playwright at 375 x 812 in Chromium and WebKit against the built app and a throwaway local Supabase (job 6). "The fixture" is job 8's test seed plus the one in statement 15. Each statement's test carries `[units N]`.

### The content (needs job 7 merged and its two keys set)

1. **Six briefs.** `content/briefs/` holds one brief per dialogue in job 7's brief format, every field filled:

   | Unit | Dialogue | Situation for the brief |
   |---|---|---|
   | 1 | 1 | Job 7's merged brief, unchanged: meeting someone at work, saying your name and where you are from |
   | 1 | 2 | At a language café: saying where you live and where you are from, asking the other person back |
   | 2 | 1 | At a café counter: ordering a coffee and a pastry, saying thanks |
   | 2 | 2 | Same café: asking the price, hearing it in euros (1 to 20), paying, saying thanks |
   | 3 | 1 | In a grocery store: asking a staff member where something is and whether they have it |
   | 3 | 2 | Same store: understanding a short answer with simple directions (over there, here, on the shelf, to the checkout) |

   Unit titles and "can do" lines (English, shown to learners) follow the wording style of job 7's unit 1 brief. Proposed for units 2 and 3: "Ordering coffee and a pastry", "I can order simple items, ask the price and say thanks"; "At the grocery store", "I can ask where something is and understand simple directions." Each brief has 6 to 8 lines, two speakers with an English role label and a different Azure fi-FI voice each, and asks for standard spoken Finnish as a Helsinki adult speaks it in 2026, no dialect, no dated slang. Names in the dialogues work for any learner. The pipeline accepts all six briefs.
2. **Grammar lists are cumulative and the unit's grammar shows up.** Each brief's grammar list holds its unit's grammar from PRD section 6 plus every earlier unit's list (unit 1: olla present, personal pronouns, -ssa/-sta, -ko/-kö questions; unit 2 adds partitive singular, numbers 1 to 20, saisinko; unit 3 adds missä on, -lla/-lle, tuolla and tässä). Words outside the frequency cap that the situation needs (for example coffee, bun, oat milk, shelf, checkout) are on the brief's extra list. A new pytest proves each brief's list contains the earlier units' lists, and that across a unit's two committed drafts every grammar item of that unit appears in at least one kirja token. The item to form tag mapping is one table in that test, written from job 7's documented tag format.
3. **Each dialogue drafted by the real workflow.** For each brief, one green run of the "Content pipeline" workflow with the real Anthropic and Azure providers. From each run's artifact the draft, the check report, the review page, the draft audio and the run's log lines are committed in the folders `docs/content-pipeline.md` names, never under `public/`. `build.md` links every run, including failed ones.
4. **The automatic checks pass on all six, at the recorded thresholds.** On the pull request the Python check passes for every committed draft: every kirja word valid in Voikko (100 percent), every puhe word linked or marked spoken only, level fit 100 percent, grammar cards match Voikko 100 percent, every line judged faithful, every token's text in order in its line (job 7 statements 7 to 11 and 21). `content/checks/thresholds.json` is byte for byte the same as on main.
5. **Audio in both registers for every line.** Every line of every draft has a puhe clip and a kirja clip in its review pack, in the speaker's voice from the brief. No file under `public/audio/` belongs to these drafts (job 7's audio test passes).
6. **Every call logged, cost reported per unit.** `content/logs/ai-calls.jsonl` holds one line per AI and voice call of this job's runs. `build.md` gives the total in US dollars for each unit and for the job, summed from the log with one documented command. If this job's logged AI total passes $5, the builder stops and reports to the manager before any further run.
7. **Review pages ready, as one batch.** Six round 1 review pages, one per dialogue, are committed and open from disk in current Chrome, Safari and Firefox with nothing loaded from the network (job 7's page test run on these six files). `content/review-batches/mvp-batch-1.md` is a short English cover note for the reviewer: the six pages in order with each dialogue's English title, what to do on each, the time estimate, and how to send the files back (to the owner, who passes them on). Review files use a reviewer code such as `R1`, never a name or email.
8. **Nothing is published before approval.** This job's merge adds no publish migration and no `public/audio/` file for these dialogues. On the test project after merge, units 1 to 3 do not appear and the app shows job 8's "not ready" state for a new guest (evaluator, on the preview).

### The patterns panel (needs job 8 merged)

9. **One way in, behind a tap.** When a word card opens inside a session, it shows a text button "Patterns you've seen" under its facts. `WordCard` gets one optional prop for this; without it the card is unchanged, and the job 5 tests and design pages stay green and unchanged. The panel has no address of its own, no link on the front door or any menu, and is not a step in the session's step list (unit test: the step list is unchanged).
10. **What the panel shows.** A sheet in the word card's style, titled "Patterns you've seen", with the line "Word forms from the dialogues you have met, grouped by pattern." One group per form name (`form_name_en`), and under it each form with its spoken and written shape (labelled "Spoken" and "Written", `lang="fi"`), its base form, its "why", and one line where the learner met it, in both registers with "Play the spoken line" and "Play the written line" controls. Closing it (Close, Escape, tap outside) returns to the word card with focus on the button. Browser test checks every field against the database.
11. **Exactly the forms met, nothing else.** The panel lists the approved forms the learner has a card for, plus the approved forms of the session they are in. It never lists a form whose status is draft or retired, a form only in a dialogue they have not met, or another learner's forms. The example line comes only from a dialogue they finished Understand it in, or the current one: the earliest such line by unit, dialogue and line position. Browser tests with two learners on the fixture, plus Worker unit tests with a fake database, cover each case.
12. **Order and focus.** Groups are ordered by when the learner first met a form of that pattern (oldest first), forms inside a group the same way, ties by base form. Opened from a word card, the panel scrolls to that form's group and moves focus to its heading. Unit test for the ordering function; browser test for focus.
13. **A card, never a lesson or a list to study.** The panel shows no counts, totals, scores, progress, due dates or "learned" labels, and has no practice, quiz or record control. Its only text is the title, the intro line, labels, form names, the stored "why" lines, the Finnish and the error line. A browser test reads the panel's text outside the Finnish and the "why" lines and finds no digit.
14. **The route reads only the learner's own data.** `GET /api/patterns` with an optional session id returns the panel's data. It reads with the learner's own token through the existing database rules, uses no secret key, changes nothing, answers 401 without an account, and returns no user id, card scheduling numbers or audio storage details beyond the line's audio keys. A session id that is not the learner's is ignored (same answer as none). If loading fails, the panel shows "Could not load your patterns." with "Try again". This job adds no table, column, view, rule, grant or function; `src/lib/database.types.ts` and every pgTAP file are unchanged.
15. **Test content for three units, only in throwaway databases.** `supabase/seeds/test-fixture-units-2-3.sql` adds two test units (slugs `test-fixture-unit-2` and `test-fixture-unit-3`, positions 901 and 902), one approved dialogue each, using lines 6 to 8 and 9 to 10 of `docs/risk-tests/test-2-voice-lines.md`, with `approval_ref` starting `test-fixture:not-reviewed` and audio keys starting `test-fixture/`. Form names and "why" lines are written by the builder and marked as fixture. Job 8's repository tests are extended to this file: no migration contains `test-fixture`, the checks workflow never applies seeds to the test project, the built app contains none of its Finnish.
16. **The full loop runs through three units.** One browser test on the fixture: a guest does today's session in each of the three test units in order (Hear it, Understand it, Say it with job 10's recorded fake, finish); with the clock moved one day, the review (job 9) offers due forms from all three units and grades each typed answer; the panel then lists every form met in the three dialogues and none from the fixture's unmet dialogue. Needs jobs 9 and 10 merged.
17. **Phone, keyboard, accessibility.** For the panel at phone size: nothing scrolls sideways at 320 px wide or with text at 200 percent; every control's tap area is at least 44 x 44; it works by keyboard alone; `@axe-core/playwright` finds no WCAG 2.0 to 2.2 A or AA violation in light and dark mode. All tests from jobs 1 to 11 stay green and unchanged.
18. **Records.** `docs/conventions.md` adds the `[units N]` label row. `docs/content-pipeline.md` adds a short "Units 1 to 3" section listing the briefs, the runs and the cost per unit. The README running costs list is unchanged.

### Published (pending the reviewer)

19. **Units 1 to 3 published on the reviewer's approval.** Pending the reviewer. After the reviewer returns a file for each of the six dialogues, the manager adds them to `content/reviews/` on the owner's instruction. Fixes are applied and only changed lines go back to the reviewer, until every item is approved. The pipeline then writes the publish migrations and copies the approved audio. When the owner approves that merge (owner's call 1 sets how many merges), the test project holds units 1 to 3 with every line approved and audio in both registers; job 7's pgTAP and audio tests pass for all six dialogues; and on the preview the evaluator runs one dialogue per unit through Hear it, Understand it, Say it and the next day's review, and sees the panel list every form met. Until then this statement is open, and the manager records it as open in `factory/features.json` and `factory/todo.md`.

Product rules from `AGENTS.md` that apply: nothing unapproved is served; AI drafts and is logged with its cost, and never publishes; both registers with audio; dialogues, never word lists; every unit tied to an A1 "can do"; standard Helsinki spoken Finnish, no dialect; grammar is a card behind a tap, never a lesson; one front door, the learner never picks a mode; nothing unmet is reviewed; agents use only the test database; no keys in code, logs or chat; never delete or weaken a test; no placeholders; client text in English; the "Not in v3.0" list and no streaks.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | Dialogues per unit | Two, 6 to 8 lines each (six dialogues for units 1 to 3) | Three per unit | Six units of three is 18 sessions, which does not fit the learner outcome of two weeks at one session a day; two per unit is 12. Three would also add about half again to the reviewer's time. Consequence: about 25 new forms per dialogue against the PRD's ~300 over six units (my arithmetic), dense for total beginners. The level fit check and the reviewer guard it; units 4 to 6 can add a third dialogue if the reviewer finds them too dense |
| 2 | Where the panel opens | A text button inside the word card, wherever a word card appears | A link on the front door or the finish screen | A front door link makes the panel a second place to go, which the loop forbids and which drifts toward the banned standalone grammar lessons and practice hub. The PRD calls it optional and says grammar is a card behind a tap |
| 3 | What "met so far" means | Forms with a card, plus the current session's forms | Forms with a card only | Cards are made only when a session finishes (job 8), so during a learner's first session the panel would miss the very dialogue they are reading |
| 4 | How forms are grouped | By form name, such as "partitive singular" | By base word | Grouping by word turns the panel into a vocabulary list, close to the banned vocabulary bank. Grouping by form name is what makes it a pattern |
| 5 | Context and audio in the panel | Each form shows one line where the learner met it, with both play controls | The form alone | Forms alone are a word list (P1) without audio (P5). Audio exists per line only, so the line is also the only way to play anything |
| 6 | How the panel reads the data | The Worker reads cards, forms, tokens and lines with the learner's token through the existing rules | A new database view or function | A view or function needs a migration, grants and pgTAP, and turns this into a database access job, for no gain: the existing rules already allow every read |
| 7 | How the full loop is proven before review | Two more fixture units in throwaway databases (statement 15) | A local seed built from the six drafts marked approved | Marking unreviewed drafts approved, even locally, is the bypass job 7 refuses. The fixture uses only lines already in the repository |
| 8 | Keeping review pages until the reviewer works | Committed to the repository | Left as workflow artifacts | GitHub deletes artifacts after a retention period (90 days by default, as far as I know, not re-checked today), and the batch waits for the end of the MVP |

Pipeline settings are job 7's: Claude Opus 5.5 drafts and writes "why" lines, Sonnet 5.5 judges, Azure fi-FI neural voices read both registers. Providers stay provisional: risk test 2 may change the voice provider after the MVP.

### Running cost (the number to watch)

| Item | Per unit (two dialogues) | Units 1 to 3 |
|---|---|---|
| Anthropic API, first runs | about $0.50 (job 7's estimate of $0.25 per dialogue) | about $1.50 |
| Anthropic API, if every dialogue needs two full reruns | about $1.50 | about $4.50 |
| Reviewer fix rounds (changed lines only) | a few cents | a few cents |
| Azure voices | €0 (about 2,000 characters against 500,000 free a month) | €0 |
| GitHub check minutes | a few minutes per run, inside the free 2,000 a month | same |
| Native reviewer | about 40 to 60 minutes per unit (job 7's 20 to 30 minutes per dialogue) | about 2 to 3 hours, paid as you agree with them |

Prices read today: Opus 5.5 is $4 per million input tokens and $20 per million output tokens; Sonnet 5.5 is $2 and $10 (Anthropic pricing page). Azure's free allowance is 0.5 million neural characters a month; its paid price is not shown on its page. All per dialogue figures are estimates; the log measures the real cost and `build.md` reports it. The stop line is $5 for this job (statement 6), inside the $10 monthly limit job 7 recommends.

## Out of scope

- Units 4 to 6, the tutor step, Otso in any form (later jobs).
- Changing the pipeline's checks, thresholds, brief format, review page or publish step. If a brief needs a field the format lacks, stop and tell the manager.
- Any table, column, view, rule, grant or function; any change to the dialogue contract shared by jobs 7 and 8 (word timings, a key line marker, authored comprehension questions).
- Pattern level explanations written as new content (one "why" per pattern). It needs a new content type and reviewer time.
- Loading v2's 104 starter sentences, and showing IPA.
- From the "Not in v3.0" list: no vocabulary bank, word counts or "words learned"; no standalone grammar lessons (the panel is reference behind a tap only); no practice modes or mode picker; no streaks, rank titles, confetti, milestone ladder or journey map; no bilingual or Finnish-only toggle; no mnemonics in any "why"; no YKI content or tags; no language islands.

## Build plan

1. **Briefs and the coverage test.** Five new briefs, cumulative grammar lists, the pytest in statement 2. Needs job 7 merged. Covers 1, 2.
2. **Real runs and the batch.** Run the workflow on all six briefs, adjust briefs (never checks) and rerun until green, commit the outputs, sum the cost, write the cover note. Needs the Anthropic and Azure keys from job 7's owner's calls as GitHub secrets. Covers 3 to 8.
3. **Patterns panel.** `/api/patterns`, the ordering function, the panel component, the word card button, the second fixture, unit and browser tests. Needs job 8 merged. Covers 9 to 15, 17.
4. **Full loop test and records.** Needs jobs 9 and 10 merged. Covers 16, 18.
5. **Publish, after the reviewer.** A later round of this job, or a small follow-up job, once the reviewer's files arrive. Covers 19.

Dependency note for the manager: the run plan lists only job 7 as "needs first", but milestones 3 and 4 also need jobs 8, 9 and 10 merged. Milestones 1 and 2 can start as soon as job 7 merges.

## Risks and flags

- **Look closely: Finnish learning content.** Six AI drafted dialogues, their "why" lines and synthetic audio. They sit unreviewed in the repository until the reviewer's batch. The fixture adds builder written form names for unreviewed test lines, in throwaway databases only.
- **Look closely: paid services.** Six to about eighteen pipeline runs on the owner's Anthropic key. Estimated $1.50 to $4.50, stop line $5.
- **Look closely: learner data.** The panel route reads each learner's own cards and sessions. No new rules; Worker unit tests and two-learner browser tests cover the reads.
- **Spoken audio may be rejected.** No voice provider claims to handle spoken Finnish (risk test 2). If the reviewer marks clips "sounds wrong", those lines need native recordings, which cost money (owner's call 2). If risk test 2 later changes the voice provider, every clip is remade and the reviewer approves the audio again.
- **Density.** Two dialogues per unit may carry too many new forms for a total beginner (Decision 1). The reviewer's comments decide whether units 4 to 6 change.
- **Brief format limits.** If job 7's grammar list cannot express a cumulative list or an item such as "numbers 1 to 20", the builder stops and tells the manager rather than loosening a check.
- **Voikko and the coverage test.** Words such as "tässä" may analyse as a form of "tämä"; the mapping table in statement 2 must follow Voikko's real readings, checked against the committed drafts.
- **Re-publishing trap and fake review files.** Both are job 7's risks and apply at statement 19: only the manager adds review files, on the owner's instruction.
- **Processing outside the EU.** Briefs go to Anthropic's global service. They hold no learner data.

## Owner's calls

The reviewer is already arranged (factory plan decision 3, pay agreed by you directly), and the batch goes to them at the end of the MVP as you chose for job 7. Nothing is sent on your behalf.

**1. How units go live after the reviewer approves (publishing).**
- A. All three units in one merge, once every line of all six dialogues is approved. One approval from you; nobody sees anything until the slowest dialogue is fixed.
- B. Each unit in its own merge as soon as both its dialogues are approved. Up to three approvals from you; unit 1 can go live while unit 3 waits for a fix, and a learner never sees half a unit.
- C. Each dialogue as soon as it is approved. Up to six approvals; a learner could finish a unit's first dialogue and find the second missing.
- Recommendation: B.

**2. Only if it happens: spending beyond this job's line.**
- If the logged cost passes $5, or the reviewer rejects synthetic spoken audio so lines need native recordings (job 7 estimated €150 to €600 for about 40 lines, unverified), the job stops and the manager brings you the options then. Nothing to decide now.

## Could not verify

- The cost per dialogue (job 7's estimate; the log measures it).
- Azure's paid neural voice price.
- How the synthetic voices sound on spoken spellings (risk test 2).
- GitHub's default artifact retention of 90 days for this repository.
- Whether job 7's brief format can hold every PRD grammar item as written.
- Whether the owner has already set the two keys from job 7's owner's calls.

## Sources

- PRD sections 3, 4.1, 5, 6, 7.5, 8, 9: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- `docs/scope/scope.md` items 5 and 10; `factory/run-plan.md`; `docs/factory-and-risk-tests-plan.md` decisions 8 and 9
- `factory/jobs/7-content-pipeline/spec.md` with its addendum; `factory/jobs/8-first-session/spec.md` with its addendum; `factory/jobs/3-data-model/spec.md`, `docs/data-model.md`; `factory/progress.md` (21 October, reviewer approval at the end)
- `docs/risk-tests/test-2-voice-lines.md`; `src/components/WordCard.tsx`; job 5 reference 6 (Oura: line, card, panel as three levels of detail)
- Anthropic pricing, read 21 October 2026: https://platform.claude.com/docs/en/about-claude/pricing
- Azure Speech pricing (0.5 million free neural characters a month; paid price blank), read 21 October 2026: https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/

Result: ready for owner approval
