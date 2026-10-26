# Build notes: 9-daily-review (round 2, resumed)

## Earlier round (inherited)

The first builder wrote the whole feature on `factory/9-daily-review` (commits `b779cb3` and `2f85c40`, about 4,700 lines) and opened draft PR 4, but stopped before writing notes. It also made the red scratch run for statement 18 (branch `scratch/9-review-definer`, see below). The manager then merged `origin/main` into the branch (`ec9646e`, `26dad80`). Its last pull request run (https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39838838300) failed only "Unit tests (Vitest)".

## This round

I made no code change. The survey found every statement built and covered by labelled tests. The one Vitest failure does not come from this job:

- `tests/agents-md.test.ts` "[tooling 4] [tooling 6] the whole file stays under 2,200 words" fails because `AGENTS.md` on `origin/main` is 2,232 words since main commit `d199939` (three lessons learned added). This branch's `AGENTS.md` is identical to main's. Before that merge it was 2,117 words and the test passed. Main fails this test too. I did not edit the house rules from a feature branch: trimming `AGENTS.md` is for the manager on main, and this branch goes green once main is fixed and merged in again. The test itself is right and stays unchanged.

I pushed the manager's merge commit `26dad80`, which had not reached GitHub yet.

## What the feature does

Words a learner met in a dialogue come back from the next Helsinki day as a line from that dialogue with the word missing, its English gloss and its audio on press. The learner types the word (with "Type ä" and "Type ö" buttons). The Worker grades it with v2's grader against both the spoken and written shapes, schedules it with v2's FSRS, and saves card and log in one database call. The learner always sees the right word after answering, and missed words come back once more in the same run. Review is the Keep it step at the end of today's session, or a review-only session when no dialogue is ready. When nothing is due, the front door names the next review day. No counts, streaks or scores.

## Done when coverage

| # | Tests |
|---|---|
| 1 | `supabase/tests/database/daily_review.test.sql` (17 `[review 1]` cases) |
| 2 | `daily_review.test.sql` (`[review 2]`), `src/lib/review-day.test.ts` |
| 3 | `worker/review-plan.test.ts` (picker), `worker/review.test.ts` (skip with fake database) |
| 4 | `e2e/daily-review.spec.ts` (`[review 4]`, all four states) |
| 5 | `src/lib/review-day.test.ts` (month end, year end, daylight saving), `e2e/daily-review.spec.ts` |
| 6 | `e2e/daily-review.spec.ts` ("step 3 of 3", database values), `src/screens/keep-it.test.ts`; job 8's tests unchanged and green |
| 7 | `e2e/daily-review.spec.ts` (review-only session, finish screen, row) |
| 8 | `worker/review.test.ts` (no answer in the items response), `e2e/daily-review.spec.ts` (reads the response) |
| 9 | `e2e/daily-review.spec.ts` (ä button, Enter), `src/screens/keep-it.test.ts` |
| 10 | `src/lib/review-grade.test.ts` (every case listed), `worker/review.test.ts` (400 cases) |
| 11 | `daily_review.test.sql` (other learner, stale `reps`, failing log, `anon`), `e2e/daily-review.spec.ts` (two log rows, card values recomputed) |
| 12 | `e2e/daily-review.spec.ts` (all three results) |
| 13 | `src/lib/review-run.test.ts`, `e2e/daily-review.spec.ts` (one retry) |
| 14 | `e2e/daily-review.spec.ts` (leave and continue) |
| 15 | `src/screens/keep-it.test.ts` (second method renders) |
| 16 | `worker/review.test.ts` (401, 404, POST only, JSON only, other origin) |
| 17 | `worker/review.test.ts` (draft never served, `console` watched), `e2e/daily-review.spec.ts` |
| 18 | `daily_review.test.sql` (`[review 18]` settings and grants); red scratch run below |
| 19 | `tests/v2-imports.test.ts` passes; `tsconfig.engines.json` and `docs/v2-imports.md` "Settings changed" |
| 20 | `e2e/daily-review.spec.ts` (320 px, 200 percent text, 44 px targets, keyboard, axe light and dark) |
| 21 | `docs/conventions.md`, `docs/data-model.md`; README running costs still €0 |

Statement 18 red run: with `record_review` made `security definer`, https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39836041074 failed the pgTAP tests "[review 18] record_review is security invoker" and "[review 11] A cannot record a review on B's card" (tests 3, 47 to 49 and 51). The branch `scratch/9-review-definer` is still on GitHub and can be deleted.

## Checks run (worktree, 26 October 2026, Node 22)

- `npm ci`: passed.
- `npm run check:code` (type check, lint, format): passed.
- `npx vitest run`: 703 passed, 2 skipped, 1 failed (the `AGENTS.md` word count above).
- `npx supabase test db`: 7 files, 527 tests, all passed.
- `VITE_DESIGN_REFERENCE=1 npm run build`: passed, including the built secrets check.
- `npx playwright test --project=chromium` after loading `supabase/seeds/browser/*.sql`: 105 passed, 15 skipped. The empty content pass (`--grep @empty-content`): 1 passed.
- `gitleaks git --redact`: no leaks found.
- WebKit did not run here: this machine has no WebKit and only Chromium build 1243 while Playwright wants 1248. I ran Chromium through a scratch browsers folder that links 1243 under the expected name. WebKit passed on GitHub for the last pushed head (run 39838838300).
- Python checks and the dependency check were not run locally; this job changes no Python or package, and both passed on GitHub.
- Local Supabase ran from a scratch copy of `supabase/` with its own project name and ports, because another builder was starting a local Supabase under the shared name at the same time. A dead container left by job 11 was in the way at first.

New npm packages: none. One full pull request run took about 15 check minutes (run 39838838300, all jobs summed).

## Unfinished or uncertain

- Vitest stays red until `AGENTS.md` on main is trimmed under 2,200 words.
- The "Preview link" check is skipped because repository secrets are not set; not this job's to fix.

## Run it locally

1. `npm ci`, then `npx supabase start` (Docker needed).
2. `npx supabase status -o env | node scripts/ci/write-test-settings.ts env .env.local --from-supabase-status`
3. Load `supabase/seeds/browser/*.sql` with `psql`, then `npm run build && npx vite preview`.
4. Browser tests: `LOCAL_DB_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres npx playwright test e2e/daily-review.spec.ts`.

Result: blocked: Vitest fails only on main's AGENTS.md word count (2,232 over 2,200); every other check passes
