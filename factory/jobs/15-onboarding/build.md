# Build notes, job 15-onboarding, round 2

Branch `factory/15-onboarding`. These notes sit in the branch, as earlier jobs' did. Test label: `[onboarding N]`.

## Round 2: what the evaluator found and what I changed

**The fault (statement 7).** The check `git diff --stat main...HEAD -- worker supabase wrangler.jsonc package.json package-lock.json src/privacy` in `tests/onboarding-rules.test.ts` was a permanent test that ran wherever a `main` branch exists. After job 15 merges, any later job that touches those paths (jobs 16 and 18 do) would fail it on its own branch. The evaluator reproduced this (`evidence/eval-7-diff-trap-for-later-jobs.txt`).

**The fix.** The diff check now runs only on the branch `factory/15-onboarding`, and only when a `main` branch exists to compare with. The rule is one small function, `runsDiffCheck(branch, base)`, with its own test (`[onboarding 7] the diff check runs only on the job branch ...`) that is never skipped. It says yes for `factory/15-onboarding` with a base, and no for `main`, `factory/16-tutor-step`, `factory/18-save-progress`, a scratch branch, a detached head and a missing base. Where the diff check is skipped its title says so. Nothing was deleted or weakened: the always-run tests beside it that guard the same property after the merge are untouched (no mention of the welcome in `worker/`, `supabase/`, `src/privacy`, `wrangler.jsonc`; the route list; no storage or request in the welcome's source; the front door's two `callApi` calls). The welcome wording is unchanged. No other file changed except the test and these notes.

**Proof, both saved:**

- On the job branch, a committed comment line in `worker/api.ts` still turns the diff check red (`AssertionError`, 1 failed, 25 passed), then reset: `evidence/break-7-job-branch-r2.txt`.
- On a throwaway local branch made from the same tip (not main, deleted afterwards), the same change no longer fails anything: the diff test is skipped, the rule test and the rest pass (25 passed, 1 skipped): `evidence/break-7-other-branch-r2.txt`.

**Evidence kept.** The evaluator's `eval-*` files and the design reviewer's `design-review-screens/` folder were untracked in the worktree. I scanned the text files for email addresses and for key, token and password shapes (none found; the word "token" only appears in test names such as "explicit token colours"), listed the screens folder (screenshots of the app and the reference page, no text files), and committed all of it to the branch.

**Checks.** On this computer: `npx tsc -b`, `npx eslint tests`, and `npx vitest run tests/onboarding-rules.test.ts` (26 tests pass) are clean; lefthook ran on each commit (no `--no-verify`). Full checks on GitHub, `gh workflow run checks.yml --ref factory/15-onboarding`: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41277646584, **success**, all jobs (Unit tests, pgTAP, pytest, secret scan, dependency check, type check, lint, format and the browser tests against the local Supabase all green; the jobs that need the test project or preview keys skipped by design). The Vitest job skips the diff test there, as GitHub has no main branch

**Not changed, as asked.** The welcome wording stays as approved in the spec. The reviewer's suggestion about the word "forms" is the owner's decision and is not applied.

**Evaluator's other findings.** Everything else passed; statement 12 is the owner's to run (`evidence/hallway-test.md`, still "Status: not run yet.").

## Round 1, short

- **Built:** a welcome block on the front door for a new visitor, between the lead sentence and Start: `src/screens/welcome-copy.ts` (the 73 words), `Welcome.tsx` and `Welcome.module.css` (tokens only), the show rule in `FrontDoor.tsx` (signed out, not ended, no `?notice=` message, only after `/api/today` answers), a "Welcome block" section on `/design-reference`, a `design.md` entry and the `[onboarding N]` row in `docs/conventions.md`. Nothing is stored or sent. No Worker, database, package, `wrangler.jsonc` or `src/privacy` file changed. No earlier test was changed.
- **Tests:** `src/screens/welcome-copy.test.ts`, `tests/onboarding-rules.test.ts`, `e2e/onboarding.spec.ts` (Chromium and WebKit at 375 x 812; the `@seed` and `@email` ones run on GitHub only). Statement 12's pack is `evidence/hallway-test.md`, not run, not marked passed.
- **Round 1 runs:** https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41243855040 success (browser tests 464 passed, 31 skipped, 0 failed); final round 1 tip https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41247997929 success after a re-run of one failed job, job 5's `[design 12]` in WebKit, a timing slip on a page this job does not touch (possible flaky test of job 5). Locally: `npm run check:code` clean, Vitest 80 files passed, Playwright without database tests 240 passed (the 2 failures were the health tests that need a database).
- **Break runs:** 34 local runs in `evidence/break-<statement>-<name>.txt`; two on GitHub, https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41245097012 (welcome for every view and a storage write: all real account tests for statements 5, 6, 7 and 8 went red) and https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41247541802 (Start waits 10.5 s: only the test for statements 7 and 8 went red, 10.96 s against 10). Scratch branches `scratch/15-onboarding-red-seeded` and `scratch/15-onboarding-red-slow` are on the remote and must never be merged.
- **Departures from the spec wording:** an unknown `?notice=` key still shows the welcome; `/design-reference` shows the block in the phone's current light or dark setting (browser tests check both); the `@seed` and `standing in for` tests both cover the ended and email cases; contrast is also measured because axe only marks text on the page fade as "needs review"; the hallway sheet gives three pass and three fail answers per question and a 120 second cap; first Tab stop is checked with a real Tab in Chromium and `tabTo` in WebKit.
- **Uncertain:** fit was measured with the fallback font (Start bottom 709 px, guest line bottom 784 px of 812), since Switzer is not in the public repository; the Written part has no filled wash, as in Hear it.

## Lessons for the manager to consider adding to `AGENTS.md`

I did not edit `AGENTS.md`.

- axe does not fail text that sits on a background image or gradient; it reports it as "needs review". On this app's page fade, measure the real colours as well (`[onboarding 10]`).
- A break script that commits must add only the file it broke. `git add -A` swept the untracked evidence files into the break commit and the reset deleted them (recovered from the dangling commit with `git checkout <commit> -- <folder>`).
- On a Windows checkout git may give Markdown and other non-app files CRLF endings, so a test that reads such a file and splits on `\n` must normalise the line endings first.
- A check that compares against main (such as `git diff main...HEAD`) must run only on its own job branch. A permanent version fails every later job's branch that touches the same paths (found by the evaluator in round 1, fixed in round 2).
- `Locator.evaluate` with a string does not call it as a function (it returns nothing). Mark the element, then run a page level expression, or write a real function.

## How to run it locally

1. In `.worktrees/15-onboarding`: `npm ci`, then `VITE_DESIGN_REFERENCE=1 npm run build`.
2. See it: `npx vite preview --port 4173`, then open https://localhost:4173/ in a private window (it uses a self signed certificate; the reference page is at `/design-reference`). A fresh window shows the welcome; after pressing Start and coming back it does not.
3. Words and file rules: `npx vitest run src/screens/welcome-copy.test.ts tests/onboarding-rules.test.ts`.
4. Browser tests with no database: `npx playwright test e2e/onboarding.spec.ts --grep-invert "@seed|@email"`. The `@seed` and `@email` ones need the local Supabase from Docker, so run them with the pull request check.
5. Hallway test: `factory/jobs/15-onboarding/evidence/hallway-test.md`.


Result: checks pass
