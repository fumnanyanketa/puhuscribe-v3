# Job 4-tooling: summary

Stage: waiting for the owner to approve the spec and choose option A, B or C for the Claude Code stop check.

Flag raised to "look closely" on the spec writer's advice: the database apply run order and a possible Claude Code settings change.

Owner decisions (20 October 2026):
- Spec approved.
- Claude Code stop check: option B, builder agent only. .claude/settings.json changes only as the spec's exact JSON for option B; the progress-log hook stays.
Builder started.

Build round 1 done (3856fcf, PR #11, run 39436405999 attempt 2; attempt 1 failed only on a slow test-project save). Commit check 12-13 s for one TypeScript file, 2.6 s for factory-only. CI stop-check failure traced to Linux node_modules symlinks and fixed.
Manager to-dos at merge: run npm ci in the main checkout so the shared git hook points at main; prove main runs no longer cancel each other and the apply queue works; never run `npx lefthook uninstall` (it rewrites .claude/settings.json).

Review round 1: design pass (5 should-fix: principles as P1-P5 bullets, banned colon reveals and groups of three in Writing rules, clearer messages in commit-tool.ts and stop-checks.ts), security pass (2 should-fix: fail closed when lefthook is missing via assert_lefthook_installed, a test refusing ai/remotes/extends keys in lefthook.yml; note: drop --verbose from the commit gitleaks run). Round 2 sent to the builder.

Round 2 (c1666b1, run 39441123835, green on first attempt): all seven review fixes. Manager decision on security note 4: the stop check keeps exiting 1 (non-blocking) when it crashes or times out, so a broken stop check cannot trap the builder; the commit check and GitHub still catch problems. No second review round: round 2 only applied the reviewers' own items.
Merge order (because commits now fail closed without lefthook): merge, run npm ci in the main checkout, then remove the worktree.

Evaluator round 1: fail on statement 6 (the path test skips root-level files such as lefthook.yml, ruff.toml) and statement 13 (with gitleaks missing, the commit also prints the "found a secret" fail_text, a false alarm). Gaps: stop-check timing for a typical change missing from build.md; the stop check's --redact is not pinned by a test. Round 3 sent to the builder.

Round 3 (a2765ee, run 39449697080 attempt 2; attempt 1 failed only on a slow test-project save): root files checked by the AGENTS.md test (break-proven), no false "secret found" message when gitleaks is missing (exit code 3 only), stop-check timing 11 s recorded, --redact pinned. Evaluator re-check started.

## Approval summary (20 October 2026)

What changed, in plain words:
1. The house rules (AGENTS.md) now describe the real setup, list everything that is "Not in v3.0", and point to a conventions document; a test fails if either goes out of date.
2. Every commit is checked first (formatting fixed, code quality, types, Python, secret scan): about 11 seconds for a code change, 2 seconds for notes. A missing tool refuses the commit with the free install line.
3. The builder agent gets a quick check each time it stops (your option B); your own sessions are unaffected.
4. Runs on the main version no longer cancel each other, and database updates queue one at a time.
5. Still €0 a month.

Evidence: factory/jobs/4-tooling/evidence/ (start with r3-13-eval-local-missing-tools-and-secret-advice.txt, r3-break-6-eval-root-files.txt, r3-15-eval-local-stop-check.txt)
Checks: all green on PR #11 (run 39449697080).
Reviews: design pass, security pass (round 1), fixes in round 2.
Evaluator: failed round 1 (root files unchecked, false "secret found" message), passed after round 3.
At merge: run npm ci in the main checkout before removing the worktree; prove main runs no longer cancel each other.
Flag: look closely: Claude Code settings change (option B) and the database apply run order.

Open items: the slow test-database saves (hit three rounds in a row; owner chose to check the Supabase logs first); lefthook's own "can't find" message mentions skip options AGENTS.md forbids.

Merge proof (20 October 2026): two main-branch runs ran at the same time, 39473186890 (the merge, 0a6831c) and 39473417606 (close-out, 4e5535b). Neither was cancelled, both passed, and both database apply jobs ran one after the other. Statement 17 is fully proven.
