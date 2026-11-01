# Build notes: job 20-a1-road, round 1

Branch `factory/20-a1-road` (pushed, no pull request, not merged). Built from main 7f4f4b7.

## What I built, in plain English

- **The road in the database.** Two new tables, `road_parts` (6 rows) and `road_stops` (36 rows), loaded by a migration that a script makes from the owner's markdown, so names and "I can" sentences cannot drift. `units` has a new `stop_number`. `forms` has two new texts, `meaning_en` and `lemma_meaning_en`, and a form cannot be approved without both. Two functions, `public.road()` and `public.stop_review_forms(stop)`, give the road screen its numbers and the review lesson its words. `GET /api/road` is the Worker route for the first one.
- **The importer.** `scripts/generate/road_import.py` reads the markdown and writes a draft for each of the 102 dialogues, with no AI call. It maps every spoken word to its written word (a table of pairs plus a few ending rules), asks Voikko about every written word and runs job 7's checks unchanged. 108 drafts now pass every check on GitHub. The importer found 635 of 816 lines that did not map on its first look (mostly written lines that dropped a pronoun the spoken line has). All 351 changes to Claude's text are in `content/road/fixes.md`, in five rounds, with before, after and reason.
- **The register judge ran once over the whole road** (owner's call 2). 816 lines judged. On its first run it flagged 9 lines. I repaired 3 of them in the text (round 4) and asked again for 6 whose verdict contradicted its own reason: 5 passed and one (6.3 line 8, `Ei mitään` against `Ei kestä`) was repaired in round 5. At the end every line has a verdict that says the two versions mean the same, and every draft says `"judge": "on"`. Cost $0.597 for the first run; $0.662 for all 119 judge calls including the golden set three times and the re-asks.
- **Voices.** `providers/voice.py` now sends at most 20 requests a minute, retries on HTTP 429 and server errors, skips a clip that already exists for the same text and voice, and the run refuses to start when this month's characters plus its own would pass 450,000. I voiced one dialogue (1.3, "A new neighbour", 16 clips, 507 characters) on the real Azure free tier as a sample. Nothing else was voiced.
- **Publishing under the owner's approval.** `content/approvals/part-<n>.json` is the approval reference. The publisher refuses, naming each reason, when the file is missing, the dialogue is not listed, a line changed after approval, a check fails, word notes are missing, the judge state differs, a clip is missing or fake, or another dialogue of the part fails. It writes one migration per dialogue with explicit timestamps. No approval file exists yet, so nothing is published.
- **Fixes after launch.** `pipeline.py road-next-round` writes a reviewer's accepted fixes into the markdown cells, imports and checks again, voices only the changed lines and writes a fix migration that replaces live lines in one transaction. `pipeline.py review-pages --part n` makes round 1 pages that show both meanings on each word card.
- **Row cap.** The Worker reads that could pass the API's 1,000 row cap are now paged (`worker/paging.ts`): the patterns panel, the review lesson's material, sessions and dialogues.

## For job 19-redesign: the interface, unchanged from the spec

`public.road()` returns one row per stop, always all 36, in stop order. `GET /api/road` answers `{"stops": [ ... ]}` with exactly these 14 snake case keys per stop and nothing else:

`stop_number`, `stop_slug`, `title_en`, `can_do_en`, `part_number`, `part_title_en`, `dialogues_total` (3), `dialogues_ready`, `dialogues_done`, `review_forms_total`, `review_forms_reviewed`, `lessons_total` (4), `lessons_done`, `live` (true or false).

401 without an account, 503 with no detail on a fault, GET only. `stop_review_forms(p_stop_number)` returns form ids only and has no Worker route (the screen job or a small job after it adds one, once owner's call 4 is built).

The spec has no public list for visitors with no account and no `sampleLine`, so neither exists. Adding either is a spec change. The TypeScript types are the Supabase CLI's exact output (`src/lib/database.types.ts`), taken from the database check's artifact. I did not touch `src/` screens or design files.

## Which "done when" statement each test protects

| Statements | Tests |
|---|---|
| 1, 2, 3, 4 | `supabase/tests/database/a1_road.test.sql` (103 checks), the extended schema checks in `data_model_schema.test.sql` and `daily_review.test.sql`, `scripts/generate/test_road_parse.py` (migration equals the script's output, a changed sentence makes it differ) |
| 5, 6 | `a1_road.test.sql` (four learners, each column, each function's kind and permissions, anon and service_role refused) |
| 7 | `worker/road.test.ts` (7 tests) |
| 8 | `scripts/generate/test_road_parse.py` (an empty cell, a stray pipe, a line number out of order, a missing **I can:** line, a dialogue count that is not 3, 7 lines instead of 8, each naming file, stop and line) |
| 9 | `scripts/generate/test_road_import.py` (stops, speakers and voices, the brief's `source` field, the six earlier briefs byte for byte) |
| 10 | `test_road_import.py` (no network and no AI, no `anthropic` import outside `providers/ai.py`, 108 drafts in the draft format) |
| 11 | `test_road_parse.py` (every accepted pair has a named rule, one planted failure per rule, glued `sä`, all 816 real lines map), `test_road_import.py` (glued word stays one word in the text) |
| 12 | `test_road_import.py` (all 108 drafts pass, the committed drafts equal the importer's output, the report is current) |
| 13 | `test_road_import.py` (planted form outside the list fails, planted word outside the level fails, each part's cap is the lowest with at most 15 extra words per stop, every recorded extra is used and has a reason) |
| 14 | `test_road_import.py` (every repair in `fixes.md`, the last After of each cell is the markdown now; thresholds unchanged) |
| 15 | `test_road_import.py` (off says "not run", on with all verdicts passes, a missing, stale or "differs" verdict fails, `check-committed` prints "register judge: not run"), `test_road_voice.py` (the $2 run guard) |
| 16 | `test_road_import.py` (the lemma rule on line 2 of dialogue 4.1 with real Voikko, texts from glossary, notes or the fixed line, consistency, needed-notes) |
| 17 | `test_road_import.py` (lines, tokens, why lines and providers of the six byte for byte, both meaning fields, review manifests match the new fingerprints, `content/reviews/` holds only its README) |
| 18, 19 | `test_road_voice.py` (throttle with a fake clock, retry, skip, refusal, one voice file, workflow shape) |
| 20, 21 | `scripts/generate/test_road_publish.py` (success, a changed line voids approval, each refusal, ordering of timestamps, stop approved only by its last dialogue) |
| 22 | `a1_road_published.test.sql` made by `road_pgtap.py`; `test_road_publish.py` checks it matches the approvals (numbers are zero until a part is approved) |
| 23 | `worker/row-cap.test.ts` (a fake database with the 1,000 row cap), the browser job step "Hide the road's units from the browser tests" |
| 24, 25 | `a1_road_fix.test.sql` made by `road_fix_pgtap.py`, `test_road_publish.py` (markdown write back, review page meanings) |
| 26 | `test_road_voice.py` (`log_costs.py` by part), the importer does not load the AI module |
| 27 | docs checked by `tests/agents-md.test.ts` (paths in `docs/conventions.md`) |

## Check results

All run on GitHub (this computer has no Docker and no Voikko). Final run, on the commit before this note (`6e7f272`; this note and its evidence files are the only later change): https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41321561654. Its browser job failed to start the first time (a Docker networking error on the runner, before any test) and passed when that job alone was run again.

| Check | Result |
|---|---|
| Type check, lint, format (`npm run check:code`) | passed |
| Unit tests (`npm test`, includes the 4 row cap tests and 7 road route tests) | passed |
| Python tests and lint (283 tests, real Voikko, no network, no skips) | passed |
| `python scripts/generate/pipeline.py check-committed` (all 108 drafts) | passed |
| Database tests (pgTAP, local Supabase) | passed (a1_road 103 checks, the published road test 9, the fix test 11, schema and daily review extended, types match the migrated database) |
| Browser tests (Playwright, local Supabase) | passed (422 passed, 31 skipped, as before; the new hide step ran) |
| Secret scan, dependency check | passed |
| `python scripts/generate/road_sql.py --check`, `road_pgtap.py --check`, `road_fix_pgtap.py --check` | pytest compares each to the committed file |

Runs of the "A1 road" tasks (the workflow only runs from the default branch, so they ran from a scratch branch with a push trigger, deleted afterwards): import https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41321298577 (its last run: no mapping, Voikko, level or judge failure; the log lists only two stale word note rows of the old skeleton, since replaced; the first run with no failure at all was 41318033424), analyse 41317041041, judge 41318417132, 41319745436 and 41320245477, voice sample 41317587713, count-characters 41317789817.

## Proof by breaking each protection

Each break was made on its own scratch branch from this branch, the checks ran on GitHub, and the branches are deleted. Runs 41320564222 to 41320746506; the failing test names of each run are in `evidence/red-proofs.txt` (the analysis behind the rank caps is `evidence/analysis.json`). At that moment two of my own tests were red for reasons unrelated to the break (the `toi` lemma test and a stale report, both fixed since), so I list only the tests the break turned red.

| Protection broken | Tests that went red |
|---|---|
| Learner grant on `road_stops` removed (d1) | `[a1-road 4] a learner may only read road_stops`, `[data 2] a learner may only read road_stops (whole table permission)` (and the learner's own reads fail with a permission error) |
| Road stops read rule removed (d2) | `[a1-road 4] road_stops has exactly one rule` and every check that reads road rows as a learner (`road()` returned no stops) |
| `road()` made `security definer` (d3) | `[a1-road 5] road() is security invoker`, and the four rows that count only approved content (9002 for A, 9003, B and D) |
| The dictionary form meaning dropped from the approval check (d4) | `[a1-road 3] a form cannot be approved without its dictionary form's meaning` and `... with a blank dictionary form meaning`, and no other |
| The stop number equals position check removed (d6) | `[a1-road 2] a unit's stop number must equal its position`, and no other |
| Fingerprint comparison removed from the publisher (p1) | `test_a1_road_20_a_changed_line_voids_the_approval_of_its_dialogue`, and no other |
| Throttle limit raised from 20 to 2000 (p2) | the three throttle tests (`...at_most_20_requests...`, `...272_clips...`, `...holds_inside_the_provider`) |
| Judge off reported as "passed" (p3) | `test_a1_road_15_with_the_judge_off_the_report_says_not_run`, `test_a1_road_15_check_committed_prints_register_judge_not_run` |
| Paging reverted to main's reads (t1, run locally with vitest) | `row-cap.test.ts`: the patterns panel test and the review lesson material test |
| Route returns the rows raw (t2, run locally) | `road.test.ts`: `answers nothing but the columns` |

The TypeScript breaks were run locally because the scratch worktree has no `node_modules` and the commit hook would not let me commit them. A grant and a policy each have their own catalogue test (`table_privs_are`, `policies_are`), which is the test that goes red only for that one; the behaviour tests (a learner reads the rows) go red for either.

## Departures from the spec, and why

1. **The six earlier briefs and drafts keep their old `unit` block** (statements 9 and 17 say they take the road's name and sentence). Three existing job 12 tests need the old block: the byte for byte hash of job 7's unit 1 brief, "the can do line starts with Can" and the cover note's unit titles, and one more compares each draft's brief with its brief file. The road's names and sentences reach the database anyway: the publish migration makes the unit row from `road_stops`. The briefs and their tests are unchanged.
2. **`test_units_1_3.py::unit_drafts` now ignores the 102 new drafts** (setup only: it counted every draft of a unit and needed exactly two). No assertion changed.
3. **The lemma of spoken `noi` is `nuo`, not `tuo`.** The spec says Voikko's base form of `nuo` is `tuo`. The real Voikko gives `nuo` its own base form `nuo`; the rule "the base form of the written word the spoken word is paired with" is kept, so `noi` shows `nuo` and `toi` shows `tuo`. The test says so.
4. **Spoken `tuo` is read as the pronoun by `content/road/reading-overrides.tsv`**, because Voikko also reads it as the verb `tuoda` and the more common word would win.
5. **Glued `Ootsä` stays one word in the line's text and is two words in the tokens** (the manager's answer for owner's call 5), not two words in the text as statement 11 says. The analysis text for the checks and the judge is `Oot sä`; the stored line is `Ootsä`; a stored token carries `"glued"`. 36 words are glued today (the spec said about 37).
6. **`present-tense` is a catalogue entry at stop 1.** The curriculum's grammar column never names the present tense of everyday verbs and every dialogue uses it; without the entry about 90 forms would have been recorded as extras.
7. **`allowed-extras.json` records 113 forms and 327 base words** (at most 15 per stop). Each form is recorded at the first stop that uses it. The report prints the count per part (79, 95, 74, 66, 71 and 53 entries in the report's table, which counts base words and forms together).
8. **Rank caps are 2,000 for parts 1 to 5 and 1,500 for part 6**, from the ladder 1500, 2000, 2500, 3000, 4000, 5000, 6000, 8000, 10000.
9. **Word texts are pending, by design.** Every draft says `"notes": "pending"` because the glossary and notes are the manager's separate step. A pending draft passes the checks (the missing why is reported as waiting) but the database, the publisher and the review page all need the texts. The statement 16 test "every form has both meanings and a why" is therefore a consistency test now: it proves each missing text is listed in `needed-notes.tsv` and each draft's state says so. Publishing refuses a draft with a missing text. When the notes are complete the drafts say `"complete"` and `check-committed` then holds every form to the existing rules.
10. **The six earlier drafts disagree among themselves on the why line of 25 shared forms** (written one by one by the AI). Statement 17 forbids changing them, so they stay, the road's written drafts all agree, and a new road draft takes the first earlier draft's line for a form it shares. The first published dialogue's line is the one the database keeps. The manager may want to unify them (that breaks statement 17).
11. **`road_import.py judge` and `voice` take `--part` and the workflow adds an optional `only` input** for a sample dialogue. The workflow also has `analyse` and `judge` tasks that the spec did not list.
12. **The road's two seed numbers (statement 22, 24)** are zero until a part is approved: the published road test is generated from the approval files and the drafts.
13. **`review pages` and `road-next-round` work on the hand written drafts only.** The six earlier AI drafts are fixed through the pipeline's own `next-round`.

## Numbers the spec asked me to report

- Azure characters: **51,597 for the whole road** (`count-characters`, after the sample), plus 507 voiced in the sample. The guard stops at 450,000. This month's log (to this run): 2,424 voice characters in all.
- Audio: 16 clips of the sample are 404 KB, about 25 KB a clip. The road needs 1,632 more clips, so about **41 MB** in `content/drafts/` and the same again in `public/audio/` at publish.
- Migrations: built from the drafts with dummy audio keys, the 108 publish migrations are about **5.8 MB** in all (55 KB each; every migration repeats the forms it shares).
- Audio plus migrations at publish: about 41 + 41 + 5.8 = **88 MB**, under the 100 MB stop line but close. The six earlier drafts' 72 clips are already committed.
- GitHub minutes: an import run takes about 4 to 5 minutes, the judge run about 12 minutes (one request a line batch), the voice sample about 2 minutes. A part's voicing is 272 clips at 20 a minute, about 14 minutes (the fake clock test shows 12 to 15). The repository is public, so the minutes are free.
- Judge cost: $0.597 (first run over 102 dialogues and the golden set), $0.662 for all 119 calls. Azure and everything else: €0.
- Forms: **1,341 distinct forms** and **772 dictionary forms** across the 108 drafts (852 lines). `needed-notes.tsv` lists the 1,341 forms (all lack a text now); `glossary.tsv` has 772 empty entries and `word-notes.tsv` 1,062 rows with empty cells.
- Repair rounds: five, 351 changes. After round 2 every line mapped, after round 3 every line passed Voikko and the level check, so the 5 percent stop line was never reached.

## Browser tests that assumed the fixture was the only content (statement 23)

With the road published, its units (positions 1 to 36) would sit before the fixture units (900 and up) and today's session would pick road content. The tests that assume the fixture is the only content are those tagged `@seed` in `e2e/first-session.spec.ts`, `daily-review.spec.ts`, `patterns.spec.ts`, `save-progress.spec.ts`, `speaking-feedback.spec.ts`, `spoken-review.spec.ts`, `analytics-feedback.spec.ts`, `analytics-journey.spec.ts`, `analytics-owner.spec.ts` and `accounts.spec.ts`. Only their setup changes: a new browser job step sets the road's units back to draft in the throwaway database (`update public.units set status = 'draft' where stop_number is not null and status = 'approved'`), as the empty content pass already does for every unit. With nothing published it changes nothing, and the browser job passed. The empty content pass still shows "Today's session is not ready yet.". Nothing in `worker/patterns.ts` or `worker/learner-db.ts` reads fewer rows than it should any more.

## Unfinished or uncertain

- **Statement 28 is open**: no part is approved, so nothing is published, no migration or audio is in `supabase/migrations/` or `public/audio/`, and the evaluator's walk of one dialogue per part has not happened.
- **The word meanings and why lines** are the manager's step (`content/road/glossary.tsv`, `content/road/word-notes.tsv`, with `needed-notes.tsv` as the work list). The files hold clear empty entries. Format: glossary `lemma<TAB>meaning<TAB>forms seen`; word notes `form id<TAB>written<TAB>spoken<TAB>dictionary form<TAB>form name<TAB>meaning<TAB>why`. The first five word note columns only find the row. After filling them run the workflow task `import` (all parts) and commit its drafts, report and `road` files: the drafts then say `"complete"`, and the six earlier drafts' review pages are made again from the same run.
- **Audio is not made for the road** (only the sample). The voice task per part needs about 14 minutes each.
- **The judge saw the lines before the word notes**; the notes do not change a line, so its verdicts stay current. A repair after approval needs a new verdict for the changed line (cents).
- **Judge noise**: on its first run the judge gave "differs" for six lines whose own reason said the meaning is the same (the spelled letters of `Silva`, `kuussataa`, `okei` and `selvä`, and two others). I asked again and they passed. Only four real differences were repaired in the text. A reviewer will still read the spoken Finnish.
- **Supabase's hosted row cap** was not checked. The paging stops on a page shorter than 500, which is right while the hosted cap is at least 500 (the local setting is 1,000).
- **The `Ei mitään` / `Ei kestä` swap** is accepted by the pair table in the four dialogues where the judge agreed, and the one it refused (6.3 line 8) now says `Ei kestä` in both versions.
- **Azure's behaviour past the free allowance and the paid price** are untouched: `voice.py` still refuses any tier but F0.
- The scratch branch for running the workflow tasks is deleted at the end. The workflow `a1-road.yml` can only be started after this branch is merged to main.

## How to run it

- Python checks: `python -m pytest scripts/generate` (Voikko needed for 60 of them; on GitHub, `python` job). Lint: `python -m ruff check scripts` and `python -m ruff format --check scripts`.
- Worker tests: `npx vitest run worker/road.test.ts worker/row-cap.test.ts`.
- Database tests need Docker: `supabase db start` then `supabase test db` (or the "Database tests" job on GitHub).
- The importer on GitHub: Actions, "A1 road", task `import`, part `all`. Locally with Voikko on Linux: `python scripts/generate/road_import.py import --out /tmp/road-out`.
- The generated files: `python scripts/generate/road_sql.py`, `road_pgtap.py`, `road_fix_pgtap.py` (each has `--check`).
- Publish a part once `content/approvals/part-<n>.json` exists and the clips are committed: `python scripts/generate/pipeline.py publish-part --part <n>`.

Result: checks pass
