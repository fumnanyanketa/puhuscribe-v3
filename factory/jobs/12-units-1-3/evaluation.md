# Evaluation: 12-units-1-3 (Units 1 to 3 content and the "Patterns you've seen" panel)

Evaluated head `a55be3c` on branch `factory/12-units-1-3`. Date: 29 October 2026.

## How this was tested

There is no preview link and no local Supabase (Docker is not available on this PC), so the evidence comes from these sources only.

- **GitHub Checks run 40939871350** on head `a55be3c`. Vitest, type check, lint, gitleaks, dependency check and pgTAP pass. Python tests pass (193 of 193, with the content check on every committed draft). Playwright (Chromium and WebKit at 375 x 812, throwaway local Supabase) passes: 351 passed, 31 skipped, 0 failed. The "Preview link" job fails because the Cloudflare preview secrets are not set on the public repository. The two after merge jobs are skipped. Saved in `ci-run-40939871350-summary.txt` and `ci-browser-units-tests.txt`.
- **Local unit tests.** `npx vitest run` on the three job files: 28 passed (`vitest-units-tests.txt`). The full `npm test` shows 2 timeouts in `scripts/hooks/commit-tool.test.ts` while the whole suite runs at once; that file passes alone (13 of 13) and CI's Vitest job is green, so I treat it as load timing, not a defect.
- **Local pytest.** `scripts/generate/test_units_1_3.py`: 55 passed (`pytest-units-1-3.txt`). Voikko (the Finnish word analyser library) is not installed on this PC, so the Voikko gate tests error here; they pass on GitHub.
- **Direct reading of the committed content** in `content/drafts/`, `content/briefs/`, `content/logs/` and `content/review-batches/`, summed by a small read only script (`drafts-summary.json`, `drafts-overview.txt`, `briefs-overview.txt`, `cost-by-unit.txt`).
- **Git diff against `origin/main`** for the "nothing else changed" checks (`no-db-or-publish-change.txt`).

I did not run the content pipeline, did not use any key, and did not read `.env*` files. No browser was driven by me; the browser results are GitHub's Playwright results.

## Results

| # | Result | Evidence used | What I saw |
|---|---|---|---|
| 1 | Pass | `content/briefs/` read, pytest `[units 1]`, `briefs-overview.txt` | Six briefs, every field filled, 6 lines each, two speakers with two different fi-FI voices, unit titles and "can do" lines for units 1, 2 and 3. Job 7's unit 1 brief is byte for byte the one on main. |
| 2 | Pass | pytest `[units 2]` (local and GitHub), `briefs-overview.txt` | Grammar lists are cumulative (4, then 7, then 10 items). Across each unit's two drafts every grammar item appears in a kirja token, for example kahvia, neljä and Saisinko in unit 2, tuolla, tässä, hyllyllä and kassalle in unit 3. |
| 3 | Fail (records only) | `content/drafts/*/run.log`, `docs/content-pipeline.md`, `build.md`, `gh run list` | All six drafts, check reports, review pages, audio and run logs are committed, and the real providers are recorded in every draft. But `build.md` does not link the runs, including the failed ones, and still says the sixth dialogue "was never drafted". See failure 1. |
| 4 | Pass | GitHub Python job (193 passed, content check step green), `drafts-summary.json`, `git diff` of `content/checks` | Every check passes with rate 1.0 on all six (faithfulness threshold 0.98, rate 1.0). Every line judged faithful. `content/checks/thresholds.json` has no diff from main. |
| 5 | Pass | pytest `[units 5]`, `drafts-summary.json`, `git ls-files public/audio` | Each draft has 12 clips (6 puhe, 6 kirja), all present and over 1 KB, in the brief's speaker voices. No file under `public/audio/`. |
| 6 | Fail (records only) | `content/logs/ai-calls.jsonl` (94 lines), `log_costs.py` output, `build.md` | The log has 15 or 16 lines per dialogue and the command works: unit 1 $0.43, unit 2 $0.41, unit 3 $0.40, total $1.25, under the $5 line. `build.md` still reports unit 3 $0.12 and total $0.96. See failure 1. |
| 7 | Pass (Chromium and WebKit only) | Playwright `[units 7] [units 5]` x 6 in both engines, `mvp-batch-1.md` read | All six round 1 pages open from disk, play a clip and load nothing from the network. The cover note lists the six pages in order with English titles, what to do, the time estimate, how to send files back, and asks for a code such as R1. Firefox and Safari themselves were not run. |
| 8 | Not checkable now | Partial: git diff | The statement needs the preview and the test project (no preview link exists). What can be seen: the branch adds no migration, changes no `src/lib/database.types.ts` or pgTAP file, and has no `public/audio/` file. The "not ready" state for a new guest still has to be checked on a preview. |
| 9 | Pass | Vitest `patterns-panel.test.ts` `[units 9]`, Playwright `[units 9]` (both engines), diff of `WordCard.tsx` | Word card gets one optional prop and shows the text button "Patterns you've seen" only with it. No existing test file was modified, so job 5 tests are unchanged and green. The step list is unchanged and the panel has no address (page stays on `/session`). |
| 10 | Pass | Playwright `[units 10]` (both engines), Vitest `[units 10]` | Sheet titled "Patterns you've seen" with the intro line, groups by form name, "Spoken" and "Written" labels, base form, why, the line in both registers and both play controls, all compared with database rows. Close, Escape and a tap outside return to the card with focus on the button. |
| 11 | Pass | Playwright `[units 11]` two learners (both engines), `worker/patterns.test.ts` `[units 11]` | Two learners each see only their forms. Draft and retired forms, forms from unmet dialogues, and the other learner's forms never appear. The line shown is the earliest met one. |
| 12 | Pass | Vitest ordering tests `[units 12]`, Playwright `[units 9] [units 10] [units 12]` | Groups and forms ordered oldest first, ties by base form. Opening from a card scrolls to that form's group and focuses its heading. |
| 13 | Pass | Playwright `[units 13]` (both engines), Vitest `[units 13]` | No digit in the panel text outside the Finnish, form names and why lines. No input, progress, meter, practice, quiz or record control. |
| 14 | Pass | `worker/patterns.test.ts` `[units 14]`, Playwright `[units 14]` x 2 (both engines), pgTAP green, diff | `GET /api/patterns` answers 401 without an account, is read only, ignores a session id that is not the learner's, and returns no user id or scheduling numbers. A failed load shows "Could not load your patterns." with "Try again", and Try again works. No database type, migration or pgTAP file changed. |
| 15 | Pass (path differs) | `tests/test-fixture-units-2-3.test.ts` `[units 15]` (7 tests, local and CI), seed file read | Two test units (901 and 902), one approved dialogue each, `test-fixture` markers on approval references and audio keys. No migration contains `test-fixture`, no workflow applies seeds to a hosted project, the built app has none of its Finnish. The file is `supabase/seeds/browser/020_test_fixture_units_2_3.sql`, not the path in the spec; `build.md` explains why (only that folder is loaded into the browser test database). |
| 16 | Pass | Playwright `[units 16]` in Chromium and WebKit | A guest does Hear it, Understand it and Say it (job 10's fake) in four sessions covering test units 1, 2 and 3 in order. With the clock moved one day the review offers due forms from all three units and grades each answer. The panel lists every form met and none of the unmet ones. |
| 17 | Pass | Playwright `[units 17]` x 4 in both engines (320 px, 200 percent text, tap areas, keyboard only, axe light and dark); whole suite 351 passed | No sideways scrolling, tap areas large enough, works by keyboard, no axe A or AA violation in light and dark. No existing test file was changed and all jobs 1 to 11 tests pass. |
| 18 | Fail (records only) | `docs/conventions.md`, `docs/content-pipeline.md`, README diff | The `[units N]` row is in `conventions.md` and the README is unchanged. The "Units 1 to 3" section in `docs/content-pipeline.md` is out of date: it says the sixth brief was "not drafted yet", gives $0.00 for it and "unit 3 $0.12 so far". See failure 1. |
| 19 | Not checkable now | none | Needs the native reviewer's files and the later publish merge. Correctly pending; nothing is published (no publish migration, `content/reviews/` holds only its README). |

## Failures

### Failure 1: build.md and the docs were not updated after the sixth dialogue was drafted (statements 3, 6 and 18)

This is a records problem, not a content or code problem. Everything the notes describe is present in the repository.

Steps to see it:

1. Open `factory/jobs/12-units-1-3/build.md`. It says the sixth dialogue "was never drafted", lists no workflow run links (not even the failed ones), and reports unit 3 at $0.12 and the job at $0.96.
2. Run `python scripts/generate/log_costs.py`. It prints unit 3 $0.40 and total $1.25.
3. Open the "Units 1 to 3" section of `docs/content-pipeline.md`. The row for `grocery-store-directions` says "not drafted yet" with $0.00, and the paragraph below says "unit 3 $0.12 so far".

What is needed: update `build.md` (every run linked, including the failed ones; costs per unit and for the job from the documented command) and the docs section (the sixth run and the true unit totals). Public repository runs I can see are `40937712893` (head `0acaa49`) and `40938246825` (head `8006d5a`, the run behind the committed `grocery-store-directions` pack). The notes should say what the first one was. The run ids of the other five dialogues come from the earlier private repository and cannot be checked from here.

## Odd, not a failure

- **Situation text and dialogue do not match.** The brief `ordering-coffee-paying.json` says Daniel asks for a tea and a bun, but the committed dialogue has him ask for coffee, and it has no pastry. The grammar and price content still serve the statement. The native reviewer may notice.
- **The brief extra list is long for that dialogue** (14 base forms, mostly the numbers 11 to 20 and 20), yet the dialogue only says "neljä" (4). Harmless, but the list allows far more than the dialogue uses.
- **"Can do" wording** in units 2 and 3 reads "Can order simple items..." (the job 7 style) rather than the spec's proposed "I can order...". The spec says to follow unit 1's style, so this matches it.
- **Statement 16 check order.** The panel is checked at the start of the fourth session, before the final review only day, not after it as the statement words it. The set of met forms is the same at both points.
- **Statement 15 path** differs from the spec text (see table).
- **Statement 7** is proven in Chromium and WebKit. Firefox, which the statement also names, has no automated test.
- **The five older workflow runs** (private repository ids in the docs table) cannot be opened from here, so I could only check their committed outputs.
- **Preview link job fails** on the pull request because the preview secrets are not set. That is known and is not a defect of this job.

## Verdict

Result: fail
