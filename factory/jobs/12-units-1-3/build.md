# Build notes: 12-units-1-3 (Units 1 to 3 content)

Branch `factory/12-units-1-3`, draft PR 6. Pushed head `ec3588b`.

## Earlier rounds (short)

- Round 1 (earlier builder, private repository, no notes written). Wrote the six briefs, the coverage pytest (`scripts/generate/test_units_1_3.py`), the cost summer (`scripts/generate/log_costs.py`), the Patterns you've seen panel (`worker/patterns.ts`, `src/components/PatternsPanel.tsx`, the optional `WordCard` prop), the second fixture, browser tests, the cover note and the docs sections. Five of the six dialogues were drafted by real workflow runs and committed. The sixth (`grocery-store-directions`) was never drafted: GitHub did not start run 39742994155 (an account billing block). The work moved to the public repository in commit `0f75545`.

## This round (resume)

- Merged origin/main. The conflict in `docs/conventions.md` kept both rows (`[units N]` and `[site N]`).
- Cherry-picked the manager's AGENTS.md fix (`96bcdd8`), so `tests/agents-md.test.ts` passes again (main itself was at 2,232 words).
- Found the cause of the red "Python tests and lint" check from the failed run log (run 39837554500): every failure is the missing sixth dialogue (`grocery-store-directions: draft.json is missing`, `unit 3 has 1 committed drafts; it needs two`). These are correct tests of statements 2 to 7. I did not weaken or skip them. They turn green only when the real run for that brief is committed.
- The count step in `.github/workflows/checks.yml` still expected 138 tests. Raised to 193 (job 12 adds 55; nothing removed, the 9 Voikko gate tests still required).

## Done when, and the tests that cover them

| # | Statement | Tests | State |
|---|---|---|---|
| 1 | Six briefs | `scripts/generate/test_units_1_3.py` `[units 1]` (3) | Pass |
| 2 | Cumulative grammar, unit grammar shows up | `test_units_1_3.py` `[units 2]` (5) | Pass for units 1 and 2; unit 3 fails until draft 6 exists |
| 3 | Each dialogue from a real run | `test_units_1_3.py` `[units 3]` | 5 of 6 pass; waits on the real run |
| 4 | Automatic checks pass at the thresholds | `[units 4]`; `pipeline.py check-committed` | 5 of 5 committed drafts pass every check; thresholds file unchanged |
| 5 | Audio in both registers | `[units 5]`; `e2e/units-review-pages.spec.ts` | 5 of 6; waits on the real run |
| 6 | Every call logged, cost per unit | `[units 6]`; `log_costs.py` | 5 of 6 logged; waits on the real run |
| 7 | Review pages and cover note | `[units 7]`; `e2e/units-review-pages.spec.ts` | 5 of 6 pages; cover note committed |
| 8 | Nothing published before approval | evaluator on the preview | No publish migration, no `public/audio/` file for these drafts |
| 9 to 14 | Panel: entry, content, scope, order, no counts, route | `worker/patterns.test.ts`, `src/components/patterns-panel.test.ts`, `e2e/patterns.spec.ts` | Pass (Chromium locally) |
| 15 | Fixture for units 2 and 3 | `tests/test-fixture-units-2-3.test.ts` `[units 15]` | Pass. Note: the file is `supabase/seeds/browser/020_test_fixture_units_2_3.sql`, not `supabase/seeds/test-fixture-units-2-3.sql`, because only that folder is loaded into the throwaway browser test database |
| 16 | Full loop through three units | none yet | Blocked: needs jobs 9 (daily review) and 10 (Say it), which are not built |
| 17 | Phone, keyboard, axe | `e2e/patterns.spec.ts` `[units 17]` | Pass (Chromium locally) |
| 18 | Records | `docs/conventions.md` row, `docs/content-pipeline.md` "Units 1 to 3" | Done; README costs unchanged |
| 19 | Published after review | none | Pending the reviewer |

## Checks run (Node 22, Python 3.13 locally; CI uses Node 24 and Python 3.12)

- `npm run check:code`: pass.
- `npx vitest run`: 45 files, 661 passed, 2 skipped.
- `ruff check scripts`, `ruff format --check scripts`: pass.
- `python -m pytest scripts/generate`: 187 passed, 6 failed. All 6 are the missing `grocery-store-directions` draft.
- `python scripts/generate/pipeline.py check-committed`: all 5 committed drafts pass every check.
- `npx supabase test db` (local, own ports): 6 files, 475 tests, pass.
- `npx playwright test --project=chromium` against the built app and a local Supabase with both seed files: 110 passed, 15 skipped, 1 failed (`[units 7] [units 5]` for `grocery-store-directions`: no round 1 review page). WebKit is not installed here, so WebKit runs only on GitHub. Locally I used the preinstalled Chromium 1243 and separate ports through uncommitted edits, now reverted.
- Commit hook (lefthook with gitleaks and ruff) ran on every commit.

## AI cost from the log

`python scripts/generate/log_costs.py`: unit 1 $0.43, unit 2 $0.41, unit 3 $0.12, total $0.96. Well under the $5 stop line.

## What waits

- **Real pipeline run for `content/briefs/grocery-store-directions.json`** (statements 2 to 7 for unit 3). Once the Anthropic and Azure secrets are set on the public repository, the manager triggers the "Content pipeline" workflow from main for that one brief, and commits its draft, check report, review page, audio and run log into `content/drafts/grocery-store-directions/` plus its lines in `content/logs/ai-calls.jsonl`, then adds the run id to `docs/content-pipeline.md`. Expected extra cost about $0.25. After that the Python check and the `[units 7]` browser test should go green.
- Statement 8: evaluator on the preview (the preview link needs its secrets).
- Statement 16: jobs 9 and 10.
- Statement 19: the native reviewer.

## How to run it locally

`npm ci`; `npx supabase start`; load `supabase/seeds/browser/*.sql` with psql; write settings with `npx supabase status -o env | node scripts/ci/write-test-settings.ts env .env.local --from-supabase-status`; `VITE_DESIGN_REFERENCE=1 npm run build`; `LOCAL_DB_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres npx playwright test`. The panel opens from any word card inside a session ("Patterns you've seen").

Result: blocked: Python check stays red until the real pipeline run for grocery-store-directions is committed (needs the repository secrets)
