# Job 4-tooling: build notes, round 3

Builder, 20 October 2026. Branch `factory/4-tooling`, tip `a2765ee`. Draft pull request: https://github.com/fumnanyanketa/puhuscribe-v3/pull/11

**Every check is green on the tip:** https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39449697080 (attempt 2; preview job https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39449697080/job/118724834527). Attempt 1 failed only the preview: the first Chromium test stayed on "Saving your visit." for about 10 seconds, then showed "not saved". This is the same slow test project save as in rounds 1 and 2. All other jobs passed, including the Browser tests job of the same run, and this job changes no app or Worker code.

Round 3 fixes the evaluator's two failures (statements 6 and 13) and two gaps (`evaluation.md`).

## What changed this round

1. **Statement 6: root files are now checked.** `tests/agents-md.test.ts` used to check only code spans with a slash. Now a code span with no slash also counts as a path when it ends in a file type this repository uses (`.md`, `.ts`, `.yml`, `.toml` and so on) or starts with a dot (`.prettierignore`).
   - Bare file types such as `.ts` are skipped. So are ordinary words and dotted names such as `request.jwt.claims` or `auth.uid()`.
   - Per job names (`build.md`, `spec.md`, `summary.md`, `evaluation.md`, `review-security.md`, `review-design.md`) count as present when at least one `factory/jobs/<job-id>/` folder has them.
   - Checked today: `lefthook.yml` and `summary.md` in AGENTS.md; `AGENTS.md`, `ruff.toml`, `eslint.config.js`, `.prettierignore`, `.env.example` and `build.md` in `docs/conventions.md`. Existence only: the test stats the path and never opens it, so `.env.example` is never read. `.env.local` is skipped as git ignored.
   - New tests: a planted text proves which spans count and which are missing; a second pins that the root files named today are in the checked list.
   - **Break proof** (`evidence/r3-break-6-root-files.txt`, throwaway branch, deleted, never pushed):
     - `lefthook.yml` renamed to `lefthook-gone.yml` in AGENTS.md text: 2 tests red.
     - `git mv ruff.toml ruff-gone.toml`: 2 tests red.
     - Back to the base: 35 passed.
2. **Statement 13: a missing gitleaks no longer reports a found secret.** The round 2 `fail_text` printed for every failure of the secrets job. It is gone.
   - `lefthook.yml` now runs gitleaks with `--exit-code 3`.
   - `commit-tool.ts` prints the advice only when gitleaks exits 3: "gitleaks found a secret in the staged changes, so this commit is refused. Remove it, tell the owner, and never paste its value anywhere. Then commit again."
   - A missing gitleaks prints only the install line. Any other gitleaks failure (exit 1) prints no advice.
   - **New tests** (`scripts/hooks/commit-tool.test.ts`, 13 tests):
     - `lefthook.yml` passes `--exit-code 3` and has no `fail_text` anywhere;
     - a missing gitleaks gives no advice;
     - in a throwaway git repository, a made-up key is refused with the advice and its value never printed;
     - a clean change passes with no advice;
     - a gitleaks error (missing config file, exit 1) gets no advice.
     - The last three need gitleaks, so they are skipped on GitHub.
   - **Proof after the fix**, in a fresh local clone (its own `.git`), on a throwaway branch, never pushed; the clone was deleted (`evidence/r3-13-local-missing-tools-refused.txt`):
     - A. gitleaks missing: refused, exit 1. The only message is the install line; there is no secret advice anywhere.
     - B. ruff missing: refused, exit 1, with the ruff install line (once per ruff job).
     - C. Made-up key with gitleaks present: refused, with the advice; the value is not in the output.
     - D. lefthook missing (`node_modules` deleted): refused, exit 1, "Can't find lefthook in PATH".
3. **Gap, statement 15 timing:** stated below in "Timings".
4. **Gap, the stop check's `--redact` is pinned.** The gitleaks arguments are now one function, `gitleaksArgs()` in `stop-checks.ts`. A `[tooling 15]` test checks that it runs `dir` on the one file, with `--redact`, the report on stdout and no `--verbose`. Removing `--redact` turns it red (`evidence/r3-break-15-redact-pinned.txt`).

## Timings on this computer (statements 11 and 15)

| What | Measured | Target |
| --- | --- | --- |
| Stop check, typical builder change (this job's 17 changed app files), round 3 | **11.0 s, 11.1 s, 11.0 s** (`evidence/r3-15-local-stop-check-timing.txt`) | under 60 s |
| Same, round 1 | 10.6 s, 10.4 s, 10.4 s (`evidence/15-local-stop-check-timing.txt`) | under 60 s |
| Stop check, no changed app files | under 2 s (asserted by a test). The evaluator measured 0.53 to 0.55 s | under 2 s |
| Commit changing one TypeScript file | 12.1 to 13.0 s (the evaluator: 11.3 to 11.6 s) | under 20 s |
| Commit of only `factory/` or `recording/` files | 2.6 to 3.1 s (the evaluator: 2.1 to 2.3 s) | under 5 s |

## Statement status

| Statement | Status and main proof |
| --- | --- |
| 1 | Met. Nothing removed or loosened; no new action |
| 2 to 5, 7 | Met. `tests/agents-md.test.ts` (35 tests) |
| 6 | Met in round 3. Root files checked; `evidence/r3-break-6-root-files.txt`, `evidence/break-6-renamed-linked-path.txt` |
| 8 | Met. `evidence/8-*`, `evidence/r2-13-npm-ci-hook-asserts.txt` |
| 9, 10 | Met. `evidence/10-*`, `evidence/r2-10-*`, `evidence/r3-13-*` (case C) |
| 11 | Met. Timings above |
| 12 | Met. `evidence/12-*`, `evidence/r2-12-*` |
| 13 | Met in round 3. `evidence/r3-13-local-missing-tools-refused.txt`; README lists both installs |
| 14 | Met. `evidence/14-18-local-repo-clean.txt` |
| 15 | Met. `scripts/hooks/stop-checks.test.ts` (32 tests); timings above; `evidence/break-15-*`, `evidence/r3-break-15-redact-pinned.txt` |
| 16 | Met. `tests/claude-settings.test.ts` |
| 17 | Met on the pull request; main part at merge (manager) |
| 18 | Met. Run 39449697080 green (attempt 2) |
| 19 | Met. €0 |

## Check results, round 3

Local (Windows 11, Node 24.14.1, lefthook 2.2.2, gitleaks 8.30.1, ruff 0.17.1):

- `npm run check:code`: exit 0.
- `npm test`: 21 files, 305 tests passed.
- `gitleaks dir factory/jobs/4-tooling/evidence --redact`: no leaks.
- Both round 3 commits went through the commit check.

GitHub: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39449697080, attempt 1 (preview slow save, above), attempt 2 all green.

Check minutes: round 3 one run plus one preview rerun, about 18. Rounds 1 and 2: about 69 and 14.

## For the manager at merge

- Merge, then run `npm ci` in the main checkout, then remove `.worktrees/4-tooling`. If the worktree is removed first, every commit on main is refused ("Can't find lefthook in PATH") until `npm ci` runs there.
- lefthook's own refusal text suggests `--no-verify` or `LEFTHOOK=0`; `AGENTS.md` forbids both.
- Statement 17's main proof: the merge push and the close-out push should both finish (`gh run list --branch main`).
- The evaluator saw `git worktree remove` fail with "Filename too long" in a deep scratch path. Check that `.worktrees/4-tooling` is really gone after removing it.

## Earlier rounds

- **Round 2**, tip `c1666b1`, run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39441123835 (green, first attempt).
  - Review fixes: `assert_lefthook_installed`, so a commit is refused when lefthook is missing; tests refusing lefthook `ai`, `remotes` and `extends`; `--verbose` dropped from the commit check's gitleaks.
  - AGENTS.md: P1 to P5, colon reveals and groups of three banned, colon openers reworded.
  - Clearer messages from `commit-tool.ts` and `stop-checks.ts`.
  - The `fail_text` added then is what caused round 3's statement 13 failure.
- **Round 1**, tip `3856fcf`, green run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39436405999 (attempt 2; attempt 1 preview slow save).
  - Built the whole spec.
  - Red run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39433075467 at `b812e66`: Linux treats a `node_modules` link as a file; fixed in `dba05c6`, proved in `evidence/r1-15-ci-symlink-cause.txt`.
  - Statement 17 proofs: cancelled run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39432949377; manual runs https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39435083037 and https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39435089156.
  - Installed ruff 0.17.1 and pip-audit 2.10.1 (`python -m pip install --user -r scripts/requirements-dev.txt`); gitleaks 8.30.1 was already installed.
  - `npx lefthook uninstall` rewrites `.claude/settings.json`; `docs/conventions.md` says not to run it.

## Still true

- Some secret tests (stop check and commit tool) are skipped on GitHub, which has no gitleaks on the unit test runner; they pass locally.
- With two builders at once, the stop check checks every factory worktree.
- The stop check exits 1 (lets the builder stop) on a crash or timeout; security note 4 was not asked for.
- Settings take effect only after merge.
- Found while testing: gitleaks 8.30.1 exits 0 when run outside a git repository. This does not affect the hook, which always runs inside one.

## How to run it locally

```
cd .worktrees/4-tooling
npm ci                      # installs packages and the pre-commit hook
npm run check:code          # type check, lint, format check
npm test                    # unit tests, including every [tooling N] test
git commit ...              # runs the commit check from lefthook.yml
CLAUDE_PROJECT_DIR=C:/Users/fumna/dev/puhuscribe-v3 node scripts/hooks/stop-checks.ts worktrees   # the stop check by hand
```

One time installs: `winget install --id Gitleaks.Gitleaks -e` and `python -m pip install --user -r scripts/requirements-dev.txt`.

Result: checks pass
