# Job 2-smoke: summary

Stage: waiting for the owner to approve the spec.

Owner's calls answered (19 October 2026):
- Spec approved.
- Look: plain browser defaults for now; the design comes in job 4.
- Session replays and transcripts: keep private in the repo's recording folder.
- Automatic progress log hook: yes, after the owner sees the exact hook.
Builder started.

Review round 1: design pass (two should-fix), security pass (notes). Incident: the security reviewer's search printed the test database connection string, password included, into its own local session log. Before any replay is made from that log it must be redacted; rotating the test database password (owner's call) makes it useless. Round 2 sent to the builder for the two design should-fix items and pinning supabase/setup-cli to a commit SHA.

Owner chose (19 October 2026) to rotate the test database password later. Open item: reset it in Supabase, update .env.local and the SUPABASE_TEST_DB_URL secret. Until then, no replay may be made from the job 2 security reviewer log without redaction.

Round 2 (f8f3e0c): older-browser timeout fix, keyboard focus kept on the status line, third-party actions pinned to commit SHAs. All nine checks green (run 39309408183). Manager decision: no second review round, because round 2 only applied the reviewers' own should-fix items and made the workflow stricter; the evaluator tests the result.

## Approval summary (19 October 2026)

What changed, in plain words:
1. The front page now says "Hei!" and saves one visit each time it opens, then says "Your visit is saved."
2. If saving fails, it says so plainly and offers "Try again"; this works on older phones and with a keyboard.
3. A visit stores only a number and a time. The app can only add visits; it can never read, change or delete them.
4. 22 database security tests run on every change; a version that let strangers read visits turned them red.
5. Still €0 a month.

Preview link: https://factory-2-smoke-puhuscribe-preview.fumnanya.workers.dev
Evidence: factory/jobs/2-smoke/evidence/ (start with 12-db-count-before-after.txt, failure-path-built-webkit.webm, 12-preview-no-token.txt)
Checks: all nine green on PR #6 (run 39309408183). Red proof run for statement 9: 39306307758.
Reviews: design pass, security pass (round 1); round 2 applied their should-fix items.
Evaluator: pass on all 14 statements; one page load raised the database count by exactly one (299 to 300). Owner check pending: open the preview.
Flag: look closely: database and access rules (the first table and its rules).

Open items, not blocking this job:
- Change the test database password (a reviewer's log holds it). Owner chose later.
- /api/health says "reachable" although pg_graphql is not installed on the test project: check what it really tests in job 3.
- Before test learner data lives in the test project: apply database changes only after owner approval.
- A rate limit on saving visits, at liftoff.
