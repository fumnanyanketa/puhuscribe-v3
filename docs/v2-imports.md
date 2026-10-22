# Files imported from PuhuScribe v2

Source: https://github.com/fumnanyanketa/puhuscribe-v2 (public, read only from this project).
Commit: `9c8d0a083d6209e0135efe20f88db99ff9c867e4` (27 September 2026, "Update README.md").
Copied on 19 October 2026 by job 1-stack, straight from git (`git cat-file blob <commit>:<path>`), so line endings and bytes match v2 exactly.

## What was copied

Every file sits at the same relative path as in v2. `tests/v2-imports.test.ts` checks each file's git blob hash against v2 on every test run.

| File | What it is | v2 blob hash |
|---|---|---|
| `src/lib/fsrs/algorithm.ts` | FSRS-5 review scheduler maths (19 weights) | `a6f9a395` |
| `src/lib/fsrs/scheduler.ts` | Scheduler: turns a rating into the next review date | `56fdd8d9` |
| `src/lib/fsrs/types.ts` | Card, rating and state types | `062ef104` |
| `src/lib/fsrs/fsrs.test.ts` | 16 scheduler tests | `03548efb` |
| `src/lib/grade.ts` | Answer grader (edit distance, picks the rating; no self rating) | `aadd2bda` |
| `src/lib/grade.test.ts` | 8 grader tests | `732ce98a` |
| `scripts/generate/voikko_gate.py` | Finnish word checker (Voikko gate) | `76b05d3d` |
| `scripts/generate/generate.py` | Draft, check, redraft loop. Offline stub when no API key | `782694f0` |
| `scripts/generate/allowed_vocab.py` | Loads the allowed vocabulary list | `33cebaef` |
| `scripts/generate/test_voikko_gate.py` | 9 Voikko gate tests (real Voikko, no mocks) | `6a31856e` |
| `scripts/generate/README.md` | v2's notes on the pipeline | `6b79bbf7` |
| `scripts/requirements.txt` | Python packages for the pipeline | `49e11b8c` |
| `data/finnish_frequency_lemmas.json` | Allowed vocabulary (frequency list, Voikko checked) | `cad35358` |

## Reference data copied by job 3-data-model

Two v2 data files are copied byte for byte into `content/v2-starter/from-v2/` (not at their v2 path, so Supabase does not run them as v3 migrations). `scripts/v2-import/` checks each copy's git blob hash before use. How they are loaded: [docs/data-model.md](data-model.md#loading-v2s-data-again).

| v2 file | Copy | v2 blob hash |
|---|---|---|
| `supabase/migrations/20260607000003_word_ipa_from_kaikki.sql` | `content/v2-starter/from-v2/20260607000003_word_ipa_from_kaikki.sql` | `96218d52` |
| `supabase/seeds/05_island_sentences.sql` | Not copied yet: waits for the owner's corrections list (owner's decision of 20 October 2026) | `f2aad90c` |

## Changes to engine code

None. No import path needed changing:

- The scheduler imports its neighbours with `.js` suffixes; TypeScript's bundler module resolution (already set in `tsconfig.app.json`) resolves them.
- The grader imports `./fsrs/types` without a suffix, which the same setting resolves.
- `allowed_vocab.py` finds the data file two folders up; the folder layout matches v2.

## Settings changed so the v2 code runs unchanged

- `tsconfig.app.json`: the Cloudflare template's `verbatimModuleSyntax` and `erasableSyntaxOnly` options are off. v2's `types.ts` uses TypeScript enums and `scheduler.ts` imports types without `import type`. TypeScript `strict` stays on.
- `eslint.config.js`: three "unsafe any" rules are off for `src/lib/grade.ts` only. Its edit distance helper builds rows with `new Array(n)`.
- `ruff.toml`: for `generate.py`, line length (E501), lambda assignment (E731), two style rules (PIE810, C408); for `voikko_gate.py`, `zip()` without `strict=` (B905). The v2 Python files are also left out of `ruff format`.
- `.prettierignore`: the copied files are not reformatted.

## Not imported, on purpose

- `streak.ts`, `milestones.ts` and their tests: streaks and milestones are on the PRD's "Not in v3.0" list.
- `topic_plan.py`, `run_batch.py`: YKI topic batches, out of v3.0.
- `to_seed_sql.py`, `test_seed_sql.py`: they write v2's database tables, which v3 replaces in job 3.
- `services/voikko/`: runtime checking is v3.1.
- `workers/tts/`: v2's AI proxy. Its pattern is carried over (keys only as Worker secrets, the browser calls the app's own `/api/*`), not its code.
- `src/styles/tokens.css`: owner's call 3 on 19 October 2026. Nothing visual is imported; job 4 sets every visual value.

## Test counts

The PRD says the scheduler has "44 tests". v2 has 16 scheduler tests and 8 grader tests; the 44 likely counted every TypeScript test in v2, including the streak and milestone tests left out above. No tests were added to reach 44.

## Licence note

`data/finnish_frequency_lemmas.json` was built from wordfreq data in v2. Its licence has not been checked against `docs/content-attribution.md` yet (job 5 carries that file forward).
