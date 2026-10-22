# Job 3-data-model: summary

Stage: waiting for the owner to approve the spec and answer 4 owner calls.

Manager note: the spec's flag about "book fair visitors from 22 October" is outdated. Per the owner's decision of 18 October 2026, v3 has no fair. The guest sign-in limit (30 per hour per IP) still matters at launch.

Owner's calls answered (20 October 2026):
- Call 1, corrections to the 104 sentences: the owner will find the reviewer's marked-up list. The builder types the fixes into content/v2-starter/corrections.tsv; the reviewer checks the typing. Until the list arrives, nothing from the 104 loads into the test project.
- Call 2, role of the 104: reference only. Any line reused in a v3 dialogue is re-approved by the reviewer in that dialogue.
- Call 3, IPA: import the 514 entries into a closed reference table, with source and licence recorded.
- Call 4, unused guest accounts: deleted after 90 days without activity (implemented in job 9).
- Database changes reach the shared test project only after owner approval (on merge to main), from this job on.
Spec approved. Builder started.

Build round 1 done (d6e8724, run 39405544151): all checks green, 371 pgTAP tests. Statement 15 waits for the owner's corrections list; statement 18's hosted part is proven only at merge (the apply job now runs only on main).
Manager correction: the two flaky browser tests were not an ordering race as the manager guessed. Evidence (trace: 503 after 3009 ms) shows the test project sometimes takes over 3 seconds to insert a visit, hitting job 2's 3 second Worker limit. Open decision for the owner: give the insert more time, or accept occasional re-runs.
Open factory design item: from job 6, pull-request browser tests that need tables not yet merged cannot run against the shared test project; option: run pull-request browser tests against a local Supabase.

Review round 1: design pass (4 should-fix), security pass (3 should-fix). Round 2 sent to the builder for design 1-4 and security 2-3. Security 1 (move SUPABASE_TEST_DB_URL into a GitHub Environment limited to main) needs GitHub environments on a private repository, which GitHub Free does not offer (Pro or Team required): owner's call.

Round 2 (5cbb66e): all six review fixes made; every check green except the preview, which failed three times on job 2 visit tests because the test project sometimes needs over 3 seconds to save a visit.
Owner decisions (20 October 2026):
- GitHub lock (security item 1): stay on GitHub Free for now; revisit before real learners arrive.
- Visit save limit: raise the Worker's limit from 3 to 8 seconds (the page's own limit stays 10). Done in job 3 round 3 because it blocks this job's preview check.
- Pull-request browser tests against a throwaway local database: yes, as its own factory job before job 6 (added to features.json as pr-local-db).

Round 3 (2a21230): save limit 8 s, tests wait up to 11 s for a save, API timing lines added. All checks green on run 39412590921 (attempt 3; two re-runs needed).
Finding (not caused by job 3): saves to the test project are usually ~370 ms, but after the connection is idle about 1 in 6 takes over 1 s and about 1 in 25 hangs past 8 s (seen from GitHub's runner, the preview, and locally from Finland, so not region or load). Likely connection setup to the free Supabase project after idle. Owner decision needed: check the Supabase logs, a safe single retry in the Worker, compare a paid compute size, or accept. The planned pr-local-db factory job removes most of this flakiness from pull-request checks.
Manager decision: security re-review of rounds 2 and 3 (substantive database changes) runs in parallel with the evaluator; the design reviewer's own fixes are not re-reviewed.

Security re-review of rounds 2 and 3: pass.
Evaluator round 1: fail on statements 8 (the cross-learner card tests use an unmet form, so they would pass even without the user_id check) and 17 (red run link lost from build.md). Gap on statement 2 (column-level grants not tested). Real hole found: un-approving keeps approved_at and approval_ref, so edited content can be re-approved with the old approval without the reviewer. Round 4 sent to the builder for all of these.

Round 4 (a779ac0): statement 8 tests now use a met form (mutation-proven), new red run 39418235616 on current code, column-grant tests, approvals cleared on withdrawal with history in private.approval_history and a new reference required to re-approve (mutation-proven), docs fixed. 413 pgTAP tests. All checks green on run 39418210776 (attempt 2; attempt 1 failed only on test-project save hangs). Evaluator re-check started; no separate security round, the evaluator checks the new trigger and private table.

## Approval summary (20 October 2026)

What changed, in plain words:
1. The database for all learning content and learner progress now exists, with 413 automatic tests of its rules.
2. Learners can only ever see Finnish your native reviewer approved, and only their own progress.
3. A word comes up for review only after the learner met it in a dialogue; edited Finnish needs a fresh approval before it can go live again.
4. Deleting an account removes everything about that person; no voice recordings are stored.
5. Still €0 a month.

Not visible to learners yet: this job has no screens. Job 6 (first session loop) is the first that uses these tables.
Evidence: factory/jobs/3-data-model/evidence/ (start with r4-02-06-grants-and-reapproval.txt, r4-08-card-test-isolation.txt, r4-17-red-run.txt)
Checks: all green on PR #8 (run 39418210776). Red proof on current code: run 39418235616.
Reviews: design pass (round 1, fixes made in round 2); security pass (round 1, and again for rounds 2 and 3).
Evaluator: failed round 1 on weak proof (statements 8 and 17) and found the re-approval gap; passed after round 4.
Waiting: statement 15 (the owner's corrections list for v2's 104 sentences); statement 18's run on the hosted test project happens at merge and will be watched.
Flag: look closely: database and access rules, learner data, Finnish learning content.

Open items, not blocking this job:
- Test-project saves hang now and then (about 1 in 25 after idle): owner decision pending.
- For job 5: re-approval tests for units and forms, enforcing a new approval time, and the pipeline role's exact permissions on private.approval_history.
- GitHub lock for the test database secret (owner chose free for now).
- Change the test database password (owner chose later).

Merge run (20 October 2026): main run 39422934043 applied the four new migrations to the test project and all 413 pgTAP tests passed there ("Result: PASS"), so statement 18 is fully proven. The first merge run (39422805727) was cancelled because the manager pushed close-out notes to main while it ran (cancel-in-progress).
