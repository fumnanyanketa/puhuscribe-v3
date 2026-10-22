# Job 3-data-model: build notes, round 4

Builder, 20 October 2026. Branch `factory/3-data-model`, tip `a779ac0`. Draft pull request: https://github.com/fumnanyanketa/puhuscribe-v3/pull/8

**Every check is green:** run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39418210776 (attempt 2). Attempt 1 failed only the preview, on slow saves to the test project (see "Test project slowness").

Round 4 fixes what the evaluator found (`evaluation.md`, `evidence/08-card-cross-learner-test-gap.txt`).

## What changed this round

1. **Statement 8: the cross-learner card tests now prove the user id check.**
   - There is a new test form, `met-but-no-card`, on the approved line of the main dialogue. A and B both reach "understand" there, and neither ever gets a card for it.
   - The two tests "A cannot add a card carrying B's user id" and "B cannot add a card carrying A's user id" now use that form instead of `form_unmet`. So the met-before-reviewed rule allows them, and only the user id check can refuse them.
   - **Mutation proof.** I removed `user_id = (select auth.uid()) and` from the card insert rule (local PGlite with pgTAP, in my scratch folder; not committed). Both tests went red: learner tests 71 and 93. Five other learner tests also went red, because the wrongly added cards changed row counts. With the rule restored, all 108 learner tests pass.
2. **Statement 17: new red run on the current code.**
   - https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39418235616 (database job: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39418235616/job/118612407223).
   - Scratch pull request #10 (branch `factory/3-data-model-red`, cut from `a779ac0`) added a rule letting any learner read every card.
   - Six tests failed: learner tests 51, 55, 77, 81 and 99, and schema test 130. The browser and preview jobs were skipped, and the apply job was skipped, as on every pull request.
   - PR #10 is closed and its branch deleted.
3. **Statement 2: column-level grants are pinned exactly.**
   - A catalogue test in `data_model_schema.test.sql` lists every column-level grant in `public` for anon, authenticated, service_role and PUBLIC. It must equal exactly the 40 learner write grants, all to authenticated.
   - **Mutation proof.** Each of these stray grants turned that test red:
     - `grant select (slug) on units to anon`;
     - `grant update (text_puhe) on dialogue_lines to authenticated`.
   - Three more tests check that the new `private.approval_history` table is closed to anon, authenticated and service_role.
4. **"Nothing unapproved is served": every approval must be a new one.**
   - **Withdrawing.** Setting an approved unit, dialogue, line or form back to draft, or retiring it, now clears `approved_at` and `approval_ref` in the same step. The old pair goes into `private.approval_history`, a new table in the schema the API does not expose, closed to every API role, with row level security on.
   - **Approving again** needs a new time (the existing check refuses a missing one) and a reference that row has never had.
   - Nothing else may change in the step that leaves "approved", as before.
   - **New tests:**
     - both fields are cleared when a line or a dialogue goes back to draft, and when a form is retired;
     - re-approving a line or a dialogue with its status alone is refused;
     - re-approving with its old reference is refused (line, dialogue, and a retired form);
     - re-approving with a new reference works.
   - **Mutation proof.** Restoring the old trigger turned 10 tests red.
   - **For job 5:** its pipeline role will need permission to add rows to `private.approval_history`.
   - No public column changed, so the generated types did not change. The CI comparison passed.
5. **Docs and comments.**
   - `docs/data-model.md` now states that a form needs `form_name_en` and `why_en` to be approved.
   - It describes how approvals are withdrawn and renewed.
   - The pipeline order now says each re-approval needs a new review reference.
   - The migration comment on the "words link to approved forms" rule now says it holds at the moment of approval. A form set back to draft later hides that word's card.

## Statement status

| # | Status | Main proof |
| --- | --- | --- |
| 1 | Met | `data_model_schema.test.sql`: exact tables, enums, columns |
| 2 | Met | schema tests: table, column (exact, all roles, from the catalogue), sequence permissions; RLS everywhere; exact rules |
| 3 | Met | `src/lib/database-types.test.ts`; generated types equal the CLI output in CI; card defaults equal `createEmptyCard()` |
| 4 | Met | content tests: each missing part refused; words must link to approved forms; one line "why" |
| 5 | Met | content tests: learner reads only approved content with approved parents; whole dialogues only; anon refused |
| 6 | Met | content tests: approved content frozen; un-approve, change, approve again with a new review only |
| 7 | Met | content and reference tests |
| 8 | Met | learner tests, both ways round; the card tests now isolate the user id check |
| 9 | Met | learner tests, including the round 2 cases for learner C |
| 10 to 14 | Met | learner and schema tests |
| 15 | **Waiting for the owner's corrections list** | loader and checks built and tested on made-up fixtures; `content/v2-starter/corrections.tsv` is the header only; no migration loads the 104 |
| 16 | Met on the throwaway database | v2 import tests; 514 rows and fingerprint after the second load |
| 17 | Met | red run 39418235616 on the current code (above); round 1's red run 39387964441 is kept under "Earlier rounds" |
| 18 | Met for pull requests; the test project part happens at merge | database job steps all pass; see "Open items" |
| 19 | Met | `docs/data-model.md`, README link |
| 20 | Met | no new service or paid plan; README "Running costs" still €0 |

## Check results

Local (Windows, Node 24.14.1):

- `npm run typecheck`, `npm run lint`, `npm run format:check`: exit 0.
- `npm test`: 17 files, 214 tests passed.
- pgTAP on local PGlite: 413 tests passed (112 content, 108 learners, 25 reference, 146 schema, 22 visits). The GitHub check is the reference.

GitHub run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39418210776 at `a779ac0`:

- **Database tests (local Supabase, pgTAP):** succeeded on both attempts, with 413 tests, before and after the second load. The fixture loaded twice, and the types match the CLI output. https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39418210776/job/118612322788
- **Apply database changes to the test project:** skipped, as the owner's rule requires on a pull request.
- **Browser tests:** succeeded. https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39418210776/job/118613069397
- **Preview link:**
  - Attempt 1 failed: three WebKit tests in a row got 503 after 8060, 9564 and 9131 ms.
  - Attempt 2 passed: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39418210776/job/118615790728
- **Other checks:** all succeeded:
  - Type check, lint, format
  - Unit tests
  - Python tests and lint
  - Secret scan
  - Dependency check

**Check minutes per pull request run:** about 14 billed minutes, with each job rounded up to the minute (attempt 1 of this run). A re-run of the preview adds about 4. Every service is still on its free plan.

| Job | Minutes |
| --- | --- |
| Database tests | 2 |
| Browser tests | 3 |
| Preview | 4 |
| Type check, lint, format | 1 |
| Unit tests | 1 |
| Python tests and lint | 1 |
| Secret scan | 1 |
| Dependency check | 1 |
| Apply job | 0 (skipped on pull requests) |

## Test project slowness (from round 3, still true)

- **The cause is the test project.** Saves to the Supabase test project sometimes hang for more than 8 seconds, and the Worker then answers 503 as designed. It happens through the local Worker in Finland, the runner's Worker and the preview Worker alike. It is not load, and it is not specific to writing.
- **This round's attempt 1** hit three hangs in a row, which suggests the slowness comes in episodes.
- **Measured in round 3** (48 saves the tests did not hold):

  | Measure | Result |
  | --- | --- |
  | Typical save | about 370 ms |
  | Over 1 second | 17% |
  | Failed at 8 seconds | 4% |
  | First save after 90 s idle (local) | once 7.16 s |

- **Decision for the manager or owner:**
  - check the Supabase logs at the times in the "API timing" lines;
  - add a Worker retry (it needs an id that makes a retry safe);
  - try a paid compute size;
  - or accept re-runs.

## Open items

- **The test project part of statement 18 happens only at merge.** That includes whether the hosted `postgres` role may insert test users into `auth.users` inside the rolled back tests.
- **Statement 15 waits for the owner's corrections list.**
- **Security item 1 (a GitHub Environment for the test database secret)** is the owner's call; it needs a paid GitHub plan.
- **Job 6 and later jobs:** a pull request's browser tests and preview see only tables from approved jobs.

## Earlier rounds

- **Round 1** (tip `d6e8724`):
  - Built the content, learner and reference tables, rules and pgTAP tests (371).
  - Built the scheduler type match, the v2 loader (IPA loaded, the 104 sentences waiting) and the "apply only on main" workflow rule.
  - Docs written.
  - First red run for statement 17: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39387964441 (scratch PR #9, closed, branch deleted).
  - The two browser failures were traced to 503s after the Worker's 3 second limit.
  - Green run: 39405544151.
- **Round 2** (tip `5cbb66e`):
  - Six review fixes:
    - whole dialogues only;
    - `units.title_fi` dropped;
    - lines need approved forms;
    - the one line "why" capped at 140 characters;
    - consent text version limited to a short label;
    - more refused card cases.
  - Database and browser checks green, but the preview was red on all three attempts from test project slowness, so the result was "blocked".
- **Round 3** (tip `2a21230`):
  - The owner raised the Worker's visit save limit from 3 to 8 seconds.
  - The job 2 unit test now proves 8 seconds, plus three new slow-save tests.
  - Browser waits for a real save went to 11 seconds (`e2e/health.spec.ts` line 31; `e2e/visits.spec.ts` lines 21, 83, 101, 107, 125, 149, 177, 249, 263).
  - "API timing" lines were added to every browser test, and the timings were measured.
  - Green run: 39412590921 (attempt 3).

## How to run it locally

From `C:/Users/fumna/dev/puhuscribe-v3/.worktrees/3-data-model` (Node 24; `.env.local` holds the test project settings):

```
npm ci
npm test
npm run typecheck
npm run build && npx playwright test
```

With Docker: `npx supabase db start` then `npx supabase test db` runs the 413 database tests.

Result: checks pass
