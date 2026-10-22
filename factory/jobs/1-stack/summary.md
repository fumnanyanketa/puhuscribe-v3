# Job 1-stack: summary

Stage: waiting for the owner to approve the spec.

Manager notes on the spec:
- The spec's line "The repository's GitHub remote exists but has never been pushed to" is out of date. The repo was pushed on 19 October 2026.
- The wrong v2 path the spec found in AGENTS.md was the manager's mistake and is now corrected.

Owner's calls answered (19 October 2026):
- Call 2, GitHub plan: stay on GitHub Free. The manager confirms checks are green before merging.
- Call 3, v2 colours: import nothing visual now. Drop "Done when" statement 7 and the tokens.css import from the build plan. Job 4 sets every visual value.
- Calls 1 (Claude provider) and 4 (live database) are not needed for this job and stay open.

Spec approved by Fumnanya on 19 October 2026. Builder started.

Build round 1 finished: milestones 1, 2, 3 and the checks are done, all six GitHub checks green on draft PR #1, and both fail-on-purpose proofs went red. Waiting on the owner account setup in build.md, "Owner setup steps".

Region (19 October 2026): Supabase's free plan offers only general regions ("Europe"), not Frankfurt. Fumnanya recreated the project under "Europe"; Supabase assigns the country. Accepted as long as the assigned country is in the EU. Statement 13's "Frankfurt" becomes "an EU country assigned under the Europe region". The live project at liftoff (Pro plan) can pick a specific region.

Owner setup done (19 October 2026), mostly by the manager:
- Supabase test project created by the owner (Europe general region, landed in West EU Ireland, eu-west-1). Values pasted by the owner into the worktree .env.local; the manager validated them and set the three SUPABASE_TEST_* GitHub secrets without printing them.
- Zero Trust was already on. The owner created one custom API token (Workers Scripts Edit, Access Apps and Policies Edit, Access Service Tokens Edit, Account Settings Read). With it the manager created the placeholder Worker puhuscribe-preview on fumnanya.workers.dev with preview links on, the service token puhuscribe-evaluator, and the Access application covering the workers.dev host and *-host, with policies Owner (allow the owner's chosen email) and Evaluator (service auth). Unauthenticated requests get a 302 to the Access login.
- GitHub secrets set: CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID, CF_ACCESS_CLIENT_ID, CF_ACCESS_CLIENT_SECRET.
- Note: the CI token is broader than the spec's Workers-only template because it also did the Access setup. Narrowing it is a later tidy-up.

Preview login email (19 October 2026): the owner chose <owner email>. The Access "Owner" policy now allows only that address. Always ask the owner before using any email address.

Build done (round 1). All seven GitHub jobs green on PR #1 run 39293664978. The earlier red preview run was a test bug (the anonymous test carried the service token header), fixed without weakening the test; not Access timing as the manager first guessed. Open later items: owner sign-in check on the preview (statement 12, done at owner approval), Dependabot secrets, and a deploy-on-main step.

Review round 1: design pass. Security: changes needed. The evaluator service token secret was saved in plain text in Playwright traces uploaded as GitHub artifacts (private repo). Manager actions: deleted every Playwright report and trace artifact in the repo, rotated the puhuscribe-evaluator service token and updated CF_ACCESS_CLIENT_SECRET, revoked existing Access sessions on the preview app. Builder round 2 fixes the cause.

Cloudflare CI key (19 October 2026): CLOUDFLARE_API_TOKEN in GitHub replaced with puhuscribe-ci (Account, Workers Scripts, Edit only). Tested: it cannot delete service tokens (403). Cloudflare includes Access application edits in Workers Scripts Edit (a delete of a nonexistent Access app returned 404, not 403), so a narrower key is not possible; residual risk accepted for now and guarded by the preview job's no-sign-in tests. The broader setup key (puhuscribe-factory) is kept only in the git-ignored worktree file for manager setup work; the owner may delete it after job 1.

## Approval summary (19 October 2026)

What changed, in plain words:
1. The new app exists: an empty page that runs on your computer and online, with a server part that reports "Server: ok" and "database: reachable".
2. v2's review scheduler, answer grader and Finnish word checker are copied unchanged, and their own tests pass (110 tests in total).
3. Every change now runs 8 automatic checks on GitHub, including a secret scan; planting a fake key and breaking a test both turned the checks red, as they should.
4. Every branch gets its own private preview link behind a Cloudflare login; strangers are sent to the login page.
5. Everything runs on free plans: €0 a month.

Preview link: https://factory-1-stack-puhuscribe-preview.fumnanya.workers.dev
Evidence: factory/jobs/1-stack/evidence/ (start with 12-preview-access-login-no-token.png, 12-ci-preview-app-with-service-token-webkit.png, 10-ci-pr-checks.txt)
Checks: all green on PR #1 (run 39295790830; the preview job also passed again with the narrow Cloudflare key). Red proof runs for statement 11: 39278766728 (secret scan) and 39278776200 (unit tests).
Reviews: design pass (round 1); security changes needed in round 1 (pass leaked into test debug files, fixed and pass replaced), pass in round 2.
Evaluator: pass on all statements except 7 (dropped by the owner). Statement 12's owner sign-in is pending the owner's own check.
Flag: look closely: database and access rules (test database and the preview login lock).

Open items, not blocking this job:
- Owner sign-in check: the Access page offers "Cloudflare" as its login method; the owner confirms their chosen email gets in.
- Security idea 1 (before liftoff): move previews to a separate Cloudflare account, because the Workers key can reach every Worker on this account.
- Security idea 2: a daily check from main's code that the preview links still ask for a login.
- Dependabot pull requests need the two test database values as Dependabot secrets.
- A deploy step for main, the README note about building after .env.local exists, and the spec's leftover "Frankfurt" wording.
- The setup key puhuscribe-factory can be deleted in Cloudflare after approval.

Owner sign-in check (19 October 2026): passed. Fumnanya signed in on the preview link and saw "PuhuScribe" and "Server: ok" (evidence/12-owner-signed-in.png). Statement 12 fully met.
