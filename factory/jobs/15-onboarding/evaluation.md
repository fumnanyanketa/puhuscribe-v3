# Evaluation: 15-onboarding, round 2 re-check

Re-checked 1 November 2026, statement 7 only, on branch `factory/15-onboarding`, tip `73c9e01` (round 1 tip was `4d46b3c`). Evidence is in `.worktrees/15-onboarding/factory/jobs/15-onboarding/evidence/`, not committed. I changed no code and ran no browser.

## Round 2 re-check

| Check | Result | Evidence | What I saw |
| --- | --- | --- | --- |
| Only the test file, build.md and evidence changed | pass | `eval-r2-diff-scope.txt` | `git diff 4d46b3c..73c9e01 --name-only` outside the evidence folder lists `build.md` and `tests/onboarding-rules.test.ts`. Zero paths under `src`, `worker`, `supabase`, `package` or `wrangler`. No app code or wording changed. |
| A branch that is not the job branch, with a `worker/api.ts` comment line committed | pass | `eval-r2-other-branch.txt` | Throwaway clone, branch `scratch/eval-r2-not-job` off the job tip. `git diff --stat main...HEAD -- worker` showed the 1 line change, and the onboarding rules test still passed (25 passed, 1 skipped). The diff check skipped itself, as intended. |
| The same change on a branch named `factory/15-onboarding` | pass | `eval-r2-job-branch.txt` | The diff check ran and failed with `worker/api.ts | 1 +` (1 failed, 25 passed). So the guard still bites on the job branch. |
| Control, job branch without the change | pass | `eval-r2-job-branch-clean.txt` | 26 passed, 0 skipped. The diff check ran and was clean. |
| GitHub run 41277646584 Vitest log | pass | `eval-r2-ci-vitest.txt` | `tests/onboarding-rules.test.ts` 26 tests, 1 skipped (the diff check, because GitHub's checkout has no main branch and no branch name). The never skipped `runsDiffCheck` test ran. 1087 passed, 7 skipped overall. |

The clone and its temporary link to `node_modules` were deleted afterwards. The real `node_modules` is intact.

The fix works. Round 1's fault is gone: on any branch other than `factory/15-onboarding` (including `main` after the merge and later jobs' branches) the diff check does not run, so a later job touching `worker/`, `supabase/` or `package.json` is not blocked by it. The never skipped test `[onboarding 7] the diff check runs only on the job branch...` covers the decision function.

Odd, not a failure:
- GitHub run 41277646584 ran on head `4d217bd`, not `73c9e01`. `git diff 4d217bd 73c9e01` shows only `build.md` changed, so the code is identical. All jobs that ran were green; the database apply, post merge browser and preview jobs were skipped as usual.
- The diff against round 1's tip also adds the round 1 evidence files (screens, `eval-*` files), which the builder committed now. They are evidence only.
- The diff check is tied to the literal branch name `factory/15-onboarding`. If the branch is renamed or the check is re-run from a differently named local branch, it silently skips. It still runs on the job branch where it matters, and the skip is named in the test title.

Statements 1 to 6 and 8 to 13: no code or wording changed since round 1, so the round 1 results stand.

Result: pass

---

# Evaluation: 15-onboarding, round 1

Evaluated 1 November 2026 on branch `factory/15-onboarding`, tip `4d46b3c`, in `.worktrees/15-onboarding`. All evidence names below are files in that worktree's `factory/jobs/15-onboarding/evidence/` folder.

The tip differs from the code that GitHub ran (`0daf958` for run 41243855040, `ab72167` for run 41247997929) only in `build.md` and evidence files. I checked with `git diff --name-only`: the only non job files changed against the branch point are `design.md`, `docs/conventions.md`, `e2e/onboarding.spec.ts`, `src/design-reference/DesignReference.tsx`, `src/screens/FrontDoor.tsx`, `src/screens/FrontDoor.module.css`, `src/screens/Welcome.tsx`, `src/screens/Welcome.module.css`, `src/screens/welcome-copy.ts`, `src/screens/welcome-copy.test.ts` and `tests/onboarding-rules.test.ts`. Main has moved on since the branch point (`dba9e08` to `ab281fc`, planning files only), and `git merge-tree` shows the branch merges into it without a conflict.

I changed no app code.

## How it was tested

There is no Docker on this machine, so the database tests and every `@seed` or `@email` test ran only on GitHub. I used five kinds of proof:

- **My own browser checks.** I ran the real front door at 375 x 812 in Chromium and WebKit against `npm run dev` on port 5195, in light and dark mode, with my own script (`eval-browser-checks.txt`). The new visitor, delayed, aborted and notice cases used the real local Worker. The signed in, ended and email cases answer `GET /api/today` with a stand-in (`page.route`) because there is no database here. Those lines are marked "standing in" in the file. Start's `/api/guest` and `/session` were stood in for in the double tap and retry checks.
- **GitHub run 41243855040.** I read its browser log myself. All 38 onboarding tests ran in each browser and passed, none skipped, including the `@seed` and `@email` ones (`eval-ci-run-41243855040-onboarding-tests.txt`). 464 passed, 31 skipped, 0 failed. The Start to first line time is 0.37 s in Chromium and 0.56 s in WebKit (`eval-ci-run-41243855040-speed.txt`).
- **The two red runs on GitHub.** I read both logs. Run 41245097012 (every loaded view shows the welcome, plus a storage write) failed the statement 5, 6, 7 and 8 tests in both browsers, and also job 9's `[review 4]` and job 10's `[speak 8]`. Run 41247541802 (Start waits 10.5 s) failed only the statement 7 and 8 test in both browsers, at 10.96 s and 10.88 s against the 10 second limit. Its two Vitest failures are in `tests/checks-workflow.test.ts` and come from the builder's workflow edit on that scratch branch, which is expected. Both scratch branches are already deleted.
- **Local Vitest.** The two onboarding files give 35 passed. Together with the three design rule files and job 14's `tests/analytics-rules.test.ts`, 166 passed and 2 skipped (the two Switzer font tests, skipped because the private font files are not in this repository) (`eval-vitest-onboarding.txt`, `eval-vitest-local.txt`).
- **My own break checks.** I broke the code in a throwaway clone outside the repository, never in the worktree. Two protections at once (the "not ended" condition of statement 5 and the Spoken label colour of statement 3) turned exactly their own tests red, and 52 other onboarding tests stayed green (`eval-break-A-D-ended-and-label-colour.txt`). I also simulated a later job to test statement 7's permanent test (failure 1).

I opened `build.md` in my first command, together with the spec, before I had tested anything. I did not let it steer my checks: the browser script, the clone breaks and the contrast sums were written from the spec. Where I agree with a builder claim I say what I re-checked.

## Results

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `eval-browser-checks.txt`, `eval-chromium-1-front-door-light.png`, `eval-webkit-1-front-door-dark.png` | Order in both browsers: wordmark, `h1` "Today's session", lead sentence, the welcome, Start, the guest line as the very next element after Start, "I already have an account", Privacy notice, Your account. Nothing sits between the welcome and Start. |
| 2 | pass | `eval-browser-checks.txt`, `eval-vitest-onboarding.txt` | The region text equals the eight constants of `welcome-copy.ts` exactly, 73 words. Ten Vitest tests cover the 80 word limit, the punctuation, hype word and banned word rules, and the two labels, each with a "catches" test. The browser test of "no other text" passed in CI in both browsers. |
| 3 | pass | `eval-browser-checks.txt`, `eval-break-A-D-ended-and-label-colour.txt` | In light and dark, the Spoken label, the Written label, the band and the sentences are the computed colours of the tokens, in both browsers. No azure anywhere in the region. Spoken comes before Written. Swapping the Spoken label to the violet token turned the colour tests red in both browsers. |
| 4 | pass | `eval-browser-checks.txt`, `eval-vitest-onboarding.txt` | 0 buttons, links, inputs, selects, text areas or tabindex elements and 0 `lang` attributes in the region. The copy file has no ä, ö or å. No question of any kind. |
| 5 | pass | `eval-browser-checks.txt`, `eval-chromium-5-guest-start.png`, `eval-chromium-5-ended.png`, `eval-chromium-5-notice-deleted.png`, `eval-ci-run-41243855040-onboarding-tests.txt`, `eval-break-A-D-ended-and-label-colour.txt` | The new visitor sees it. The three notices show their message and no welcome. A signed in guest (start, continue, review, all done, not ready), the "ended" guest and the email signed out state show no welcome (stand-in answers here, and the real accounts in CI: a guest back by Leave session, a guest deleted in the database, the email account, in both browsers). Dropping "not ended" turned the ended and email tests red. See departure 1 below. |
| 6 | pass | `eval-browser-checks.txt`, `eval-chromium-6-guest-delayed.png`, `eval-chromium-6-offline-start-fails.png` | A 2 second delay for a guest: a MutationObserver started before load never saw the welcome. For a new visitor, nothing of it is in the page at 0.7 s and it appears after the answer. With `/api/today` and `/api/guest` aborted, the welcome shows, and Start gives job 8's exact message. A retry afterwards goes on to `/session`. |
| 7 | fail | `eval-7-diff-trap-for-later-jobs.txt`, `eval-browser-checks.txt` | The behaviour holds (see below), but the test that guards the diff is a trap for every later job. See failure 1. |
| 8 | pass | `eval-ci-run-41243855040-speed.txt`, `eval-ci-run-41243855040-onboarding-tests.txt` | One press of Start, then the first approved line from the database (read by the test from the database, spoken text equal) with both play buttons, in 0.37 s and 0.56 s. The 10 second limit goes red when Start is slowed (run 41247541802). Loading `/` creates no account. I could not run this one here (it needs the database). |
| 9 | pass | `eval-browser-checks.txt`, `eval-chromium-1-front-door-light.png`, `eval-webkit-1-front-door-dark.png` | Start ends at 709 px and the whole guest line at 784 px of 812, in both browsers and both schemes. Only 28 px of room is left (see the odd items about the font). |
| 10 | pass | `eval-browser-checks.txt`, `eval-chromium-10-width-320.png`, `eval-webkit-10-width-200pct.png` | No sideways scroll at 320 px (320 of 320) or with the text at 200 percent (375 of 375). Start is 54 px tall. One `h1`, then the welcome `h2`. Start is the first Tab stop in Chromium and the first button in order in WebKit. axe found no violation in light or dark in either browser. It lists text on the page fade as "needs review", so I computed the contrast of every colour pair myself: lowest 5.67 to 1 (the violet label on the lilac end of the fade), spoken label 6.13 in light and 7.26 in dark. Zero transitions or animations, and the reduced motion screenshot is identical. Start and the quiet button have token colours in both schemes. |
| 11 | pass | `eval-browser-checks.txt`, `eval-vitest-local.txt` | No picture, icon or emoji, no uppercase text, no gradient. The only border is the 1 px full edge of the Spoken band. The three design test files and job 8's `[smoke 1]` pass unchanged. The design review is already done and passed. |
| 12 | owner to run | `hallway-test.md` | Not run, as expected. The sheet is complete. See "The hallway test sheet" below. |
| 13 | pass | `eval-13-reference-page.txt`, `eval-13-reference-welcome-webkit-dark.png`, `eval-vitest-onboarding.txt` | `design.md` has the "Welcome block" entry. A build with the reference page shows the "Welcome block" section in light and dark, in both browsers. The conventions row is there and the README is unchanged (costs stay €0). No earlier test file is changed: the diff holds only new test files. All earlier tests are green in CI. |

## Failures

### 1. Statement 7: the diff test breaks every later job that touches the Worker or the database (must fix)

Statement 7 asks that `git diff --stat main...HEAD -- worker supabase wrangler.jsonc package.json package-lock.json src/privacy` prints nothing. For this branch it does: I ran it and it printed nothing, and the changed file list above has no such file. The behaviour is right.

The problem is how it was written down. `tests/onboarding-rules.test.ts` holds this as a permanent Vitest test. It runs whenever a `main` branch exists in the checkout, and it skips on GitHub, where there is none. After this job merges, every later job's branch is compared with main, and any later job that changes `worker/`, `supabase/` or `package.json` fails this test on its builder's computer. Jobs 16 and 18 are open and both change those folders. The rule "never delete or weaken a test" then leaves the later builder no clean way out.

To reproduce: clone the repository, point `main` at `4d46b3c`, make a branch, add one comment line to `worker/api.ts`, commit, and run `npx vitest run tests/onboarding-rules.test.ts`. Result: `[onboarding 7] git diff --stat main...HEAD ...` fails with `worker/api.ts | 1 +` (`eval-7-diff-trap-for-later-jobs.txt`). The same test is green on this branch.

Smallest fix, as I see it: run that one check only while this job's own branch is checked out (compare `git rev-parse --abbrev-ref HEAD` with `factory/15-onboarding`), and skip it everywhere else, with the skip stated in the test title. The tests next to it that always run (nothing in `worker/`, `supabase/`, `src/privacy/` or `wrangler.jsonc` mentions the welcome, no storage and no request in the welcome's source, the front door still makes exactly two `callApi` calls) already guard the same property after the merge. This is a test design fault, not a spec change, so it goes back to the builder.

## The builder's six departures from the spec wording

1. **An unknown `?notice=` key still shows the welcome.** Spec: "the address carries no `?notice=` message". The three real notices hide it, and `/?notice=zzz` shows no message and shows the welcome (checked, both browsers). That is a fair reading, because no message is on screen, and it is the better outcome for a visitor who arrives from a campaign link with extra parameters. Accepted. One line in `FrontDoor.tsx` would change it if the owner wants any `?notice=` to hide it.
2. **The reference page follows the phone's light or dark setting instead of showing both at once.** Every other section of that page does the same, and the browser tests check both settings. Accepted.
3. **The `main...HEAD` check skips on GitHub.** Accepted as a way to run it, not as written (failure 1).
4. **Two kinds of test for the ended and email states.** Real accounts in CI and stand-in answers for preview links. The stand-in tests say so in their names. Accepted, and I re-checked both kinds pass.
5. **A contrast measurement on top of axe.** Good. I confirmed axe only flags the page fade as "needs review", and my own sums agree with the builder's test.
6. **Hallway sheet extras.** Three passing and three failing answers per question rather than three in all, and a 120 second cap. Both are additions that do not conflict with the spec. The cap cannot hide a failure, because 120 is above the 60 second bar. Accepted.

## The hallway test sheet (statement 12)

The sheet has every part the spec names: the words said to each person (including the guest account and the 90 day deletion), "Use this app as you like.", the stopwatch rule, both questions word for word, a marking guide, a 5 row table with every named column, totals and a notes box. It says "Status: not run yet", the rows are empty and there is no name column. The owner can follow it without engineering knowledge: it says what to prepare, what to say, when to start and stop the clock, how to mark an answer and what to do if the bar is missed. The pass rule per person (time and both answers) and the pass bar (4 of 5 on each) are stated twice, in plain words.

Two things for the owner, neither a failure:

- The sheet says to use "a preview link or the live app". Preview links sit behind Cloudflare Access (design.md), so a stranger's phone in a fresh private window would meet a login wall. Until the live app exists, the owner needs a way past that for each person, or the test cannot start.
- The sheet tells the owner to open the link first so the front door is on screen. If the private window is closed between people, the owner must reopen the link each time. The sheet says this, but it is easy to forget.

I cannot judge the people. The summary for the owner should say so, and the job stays at "waiting for the owner" until the filled sheet is in.

## Odd but not failures

- **Job 5's `[design 12]` test is flaky, and unrelated to this job.** In run 41247997929, attempt 1, `e2e/design-sample.spec.ts:214` expected the held word to be "Mä" or "oon" and read "Alex", in WebKit only. That test uses a fake clock on the Hear it sample page, which this job does not touch (no file of `design-sample` or its page changed), and the test's own comment says a slow runner can let the next word come early. It passed in run 41243855040 and in attempt 2 of the same run, with no code change in between. I judge it a timing flake in job 5's test. It should be noted for job 5 (the allowed words should include the words after "oon", or the pause check should read the word at the time of the click).
- **The wording test locks the approved draft.** `[onboarding 2] hold exactly the approved draft` compares the words with the draft in the spec. The owner may edit the words at approval, and that test would then fail until it is updated. The word count, punctuation and Finnish letter tests would still apply. The approver should know that a wording change needs the builder (or one edited constant in the test).
- **Only 28 px of room.** The fit was measured with the fallback font (Poppins), because the Switzer files are not in the public repository and are not here. Statement 9 passes with those numbers, and Switzer is said to be narrower, but I could not measure it. A preview link has Switzer. It is worth one look on a phone.
- **The 200 percent text check.** I approximated it with `html { font-size: 200% }` (the app sizes text in rem), not with the browser's own zoom. The builder's test does something similar in CI. Both found no sideways scroll.
- **WebKit and Tab.** WebKit skips buttons on Tab unless a system setting allows it, as the existing `tabTo` helper says. I checked the first control in the page order is Start, and that Enter on a focused Start goes on.
- **Slow network.** Chromium at 400 KB/s and 300 ms delay on the unbundled dev server: the welcome and Start were there after 13.7 s. WebKit has no throttle here, so I did not test it.
- **Requests.** A new visitor's page loads `/`, its own scripts, `/content/checks/speech-thresholds.json` (an app file loaded by earlier jobs) and `GET /api/today`, all to the app's own address. No cookie, no storage and no IndexedDB before Start. The one cookie set is by Start's real account request, not by the welcome.
- **Double tap and navigation.** A double click on Start sends one `/api/guest` request. After Back from the session page, and after a refresh, the welcome shows again, as the spec's Decision 3 says it should for someone who left without a guest account.
- **Evidence tidy up.** I deleted three files left by the stopped evaluator that I did not re-check (`eval-7-diff-break.txt` and the two `5-guest-signed-in.png` files) and renamed my own `5-guest-start.png`. The other old `eval-*` files were overwritten by my run. `design-review-screens/` is the design reviewer's folder, not mine.
- **No traces, HAR files or videos** were kept, and no secret header was set. I did not read any `.env*` file.
- **Servers.** My dev server on port 5195 and the throwaway preview on 4195 are stopped, and the throwaway clone is deleted.

## Earlier statements and tests

No earlier test or helper is changed. Job 8's `[session 1]`, `[session 3]`, `[session 22]` and `[smoke 1]`, job 11's front door and account tests, job 14's `tests/analytics-rules.test.ts` and the three design rule files pass (locally for the Vitest ones, in CI for the browser ones). All GitHub jobs are green on both runs; run 41247997929 needed the re-run described above.

Failing statements: 7

Result: rework
