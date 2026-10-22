# Job 3-data-model: evaluation, round 2 (build round 4)

Evaluator, 20 October 2026. Branch `factory/3-data-model` at `a779ac0`, freshly cloned into the evaluator's scratch folder.

- Green run 39418210776, attempt 2. Attempt 1 failed only the preview, on slow test project saves.
- New red run 39418235616.

How this was tested. This job has no screen, so no statement can be driven in a browser, and none was. There is no Docker or Postgres on this computer, and nothing touched the hosted test project, Cloudflare or GitHub state. Database statements were judged three ways:

- reading every migration and pgTAP test;
- asking of each test "would it fail if the rule were missing?";
- the CI database job logs.

The fresh clone passes `npm ci`, build, typecheck, lint, format check and the unit tests (214). Round 4 changed only `docs/data-model.md`, the content migration and three pgTAP files. So the round 1 evidence for the unchanged statements still holds; round 1 files have no prefix, round 4 files start with `r4-`.

## Statements

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `evidence/01-14-sql-review.txt`, `evidence/r4-18-ci-database-job.txt` | Exactly the 12 tables in `public`, 6 enums, exact columns. `visits` and its 22 tests are unchanged. |
| 2 | pass | `evidence/r4-02-06-grants-and-reapproval.txt` | New catalogue test: the only column grants in `public` are exactly the 40 learner write grants, all to `authenticated`. I counted them against the migration. The round 1 gap is closed. `private.approval_history` is closed to all three API roles. |
| 3 | pass | `evidence/02-local-checks.txt`, `evidence/03-types-break-tests.txt`, `evidence/r4-18-ci-database-job.txt` | No public column changed in round 4. The CI types comparison printed no difference. |
| 4 | pass | `evidence/01-14-sql-review.txt` | Unchanged: each missing part is refused. |
| 5 | pass | `evidence/01-14-sql-review.txt` | Unchanged: learners read only approved content with approved parents. `anon` is refused. |
| 6 | pass | `evidence/r4-02-06-grants-and-reapproval.txt` | Approved content is still frozen. Withdrawing an approval now clears `approved_at` and `approval_ref` and keeps the old pair in history. Old-reference and status-only re-approval are refused. Test gaps for units and forms are listed below. |
| 7 | pass | `evidence/01-14-sql-review.txt` | Unchanged. |
| 8 | pass | `evidence/r4-08-card-test-isolation.txt` | The cross-learner card tests now use `met-but-no-card`, a form both learners met and neither has a card for. Only the user id check can refuse them now. The builder's mutation note fits the file's test numbering. |
| 9 | pass | `evidence/01-14-sql-review.txt` | Unchanged. |
| 10 | pass | `evidence/01-14-sql-review.txt` | Unchanged. |
| 11 | pass | `evidence/01-14-sql-review.txt` | Unchanged. |
| 12 | pass | `evidence/01-14-sql-review.txt` | Unchanged. |
| 13 | pass | `evidence/01-14-sql-review.txt` | Unchanged. |
| 14 | pass | `evidence/01-14-sql-review.txt` | Unchanged. Retiring now also clears the approval, and the delete tests still pass in CI. |
| 15 | waiting for owner | `evidence/15-16-loader-tamper-and-v2-match.txt` | Waits for the owner's corrections list. The loader is ready and tested on fixtures. |
| 16 | pass | `evidence/15-16-loader-tamper-and-v2-match.txt`, `evidence/r4-18-ci-database-job.txt` | Loader files unchanged. In CI the second load still gives 514 rows and the same fingerprint. |
| 17 | pass | `evidence/r4-17-red-run.txt` | Red run 39418235616 was cut from `a779ac0` (current code). Six tests failed and the apply job was skipped. It is linked in `build.md`. PR #10 is closed and the branch is gone from GitHub. |
| 18 | pass in CI; hosted part proven at merge | `evidence/r4-18-ci-database-job.txt` | CI applies the migrations, runs 413 pgTAP tests, loads again and runs them again. The fixture loads twice to 3 rows. The types match. All checks are green on attempt 2. No test was deleted or weakened. The test project push and its second run happen only at merge. |
| 19 | pass | `evidence/r4-19-docs.txt`, `evidence/19-20-docs-and-costs.txt` | The docs now say a form needs `form_name_en` and `why_en`, and describe how approvals are withdrawn and renewed. Two wording issues are listed below. |
| 20 | pass | `evidence/19-20-docs-and-costs.txt`, `evidence/r4-19-docs.txt` | No package, service or cost change. |

## Failures

None in this round.

## Gaps (passing, but less tested than claimed)

- **Re-approval tests do not cover all four tables.** Lines and dialogues are fully tested: fields cleared, status-only refused, old reference refused, new reference works. Forms test clearing on retire and the old reference, but not status-only re-approval. Units have none of these tests. By reading, units and forms behave the same, because all four tables share one trigger and the same check constraint. But a future change to one table's trigger or constraint would go unnoticed.
- **The builder's statement 8 mutation run cannot be reproduced from the repository.** It ran on PGlite in the builder's scratch folder, not on Supabase Postgres, and is not in CI. Its reported test numbers (71 and 93, plus five count tests) match the file and my own reading.
- **Statement 18, hosted part.** The tests insert users into `auth.users` with only an id. They now also write to `private.approval_history`. Both are proven only at merge. If either fails there, the apply job goes red after `db push` has already applied the migrations.
- **Statement 15.** Only fixture data has been through a database. The real 104-row migration and its tests come after the owner's corrections list.

## Odd, not failures

- **"Needs a new time" is not enforced.** The docs and `build.md` say re-approval needs a new time. Withdrawing clears `approved_at`, so some time must be given, but any value is accepted, including the old one. Only the reference must be new.
- **The "never used" reference check is an exact string match.** `review 4 ` with a trailing space counts as new. A draft row that nothing references can be deleted and re-inserted under a new id, and then reuse a reference. Both are edge cases.
- **Job 5 needs more than the docs say.** The trigger is not security definer, so it runs as whoever updates the content. A non-owner pipeline role in job 5 needs USAGE on `private`, INSERT and SELECT on `approval_history`, and row level security policies for both, or BYPASSRLS. The docs say only "permission to add rows". With an INSERT policy but no SELECT policy, the "already used" check would silently pass old references.
- **CI still needed a re-run.** Attempt 1 failed only the preview, on slow test project saves. This is known and reported to the owner.

## Round 1 findings (build round 3, `2a21230`)

Round 1 ended with `Result: fail` on two statements. Both are fixed in round 4.

- **Statement 8.** The cross-learner card tests used a form the inserter never met, so they passed even without the user id check (`evidence/08-card-cross-learner-test-gap.txt`). Fixed with the `met-but-no-card` form.
- **Statement 17.** The red run (39387964441, round 1 code) was not linked in `build.md` after rounds 2 and 3 overwrote it (`evidence/17-red-run.txt`). Fixed with a new red run on current code, linked in `build.md`.

Round 1 gaps and oddities, and what happened to them:

- **Stray column grants (statement 2).** Fixed by the new catalogue test.
- **Re-approval reusing the old approval.** Fixed by clearing the approval on withdraw, keeping history, and requiring a new reference.
- **The docs left out form approval needs.** Fixed.
- **The over-strong migration comment about form approval.** Fixed.
- **`build.md` had lost the red run link and the check minutes.** Fixed: about 14 billed minutes per pull request run.
- **Still open:** statement 15 waits for the owner, statement 18's hosted part waits for merge, and test project saves are slow.

## Evidence files

Round 4:

- `evidence/r4-02-local-checks.txt`
- `evidence/r4-02-06-grants-and-reapproval.txt`
- `evidence/r4-08-card-test-isolation.txt`
- `evidence/r4-17-red-run.txt`
- `evidence/r4-18-ci-database-job.txt`
- `evidence/r4-19-docs.txt`

Round 1, still valid for unchanged parts:

- `evidence/01-14-sql-review.txt`
- `evidence/02-local-checks.txt`
- `evidence/03-types-break-tests.txt`
- `evidence/08-card-cross-learner-test-gap.txt`
- `evidence/15-16-loader-tamper-and-v2-match.txt`
- `evidence/17-red-run.txt`
- `evidence/18-ci-database-job.txt`
- `evidence/18-ci-run-summary.txt`
- `evidence/19-20-docs-and-costs.txt`

Result: pass
