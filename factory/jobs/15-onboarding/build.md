# Build notes, job 15-onboarding, round 1

Branch `factory/15-onboarding`, built in `.worktrees/15-onboarding` from main at `dba9e08`. These notes sit in the branch (as `factory/jobs/14-analytics/build.md` did) so they merge with the job. Test label: `[onboarding N]`.

## What I built

A new visitor now sees a short welcome on the front door, between the lead sentence ("A session is one short Finnish dialogue...") and the Start button. It has the heading "Welcome to PuhuScribe", two plain sentences, two bands labelled "Spoken" and "Written", and one closing sentence. The words are the approved draft, 73 words, with no Finnish. The Spoken band uses the same teal band and label colour as the Hear it screen, and the Written label uses the same violet. Nothing in the block can be tapped. Start is the way on, and the guest line ("Starting creates a guest account...") is still the very next thing under Start.

Who sees it: only a visitor with no account on the phone. The front door already asks `GET /api/today` who is signed in. The welcome shows when the answer says nobody is signed in, it is not the "ended" answer (a guest or email account that was deleted or signed out elsewhere), and the address carries no `?notice=` message. Until that answer arrives the welcome is not in the page at all, so it cannot flash for a returning learner. If the request fails, the welcome shows and Start fails in job 8's own words. Nothing is stored to remember that the welcome was seen: no cookie, no local storage, no database column, no new request.

Files, all new unless marked:

- `src/screens/welcome-copy.ts`: every word of the welcome, as exported constants (the owner edits them here at approval).
- `src/screens/Welcome.tsx` and `src/screens/Welcome.module.css`: the block, from existing tokens only.
- `src/screens/FrontDoor.tsx` (changed, 5 lines of logic plus a header comment) and `src/screens/FrontDoor.module.css` (changed, one margin rule): the rule for when it shows, and where.
- `src/design-reference/DesignReference.tsx` (changed): a "Welcome block" section.
- `design.md` (changed): the "Welcome block" entry. `docs/conventions.md` (changed): the `[onboarding N]` row.
- Tests: `src/screens/welcome-copy.test.ts`, `tests/onboarding-rules.test.ts`, `e2e/onboarding.spec.ts`.
- `factory/jobs/15-onboarding/evidence/hallway-test.md`: the hallway test pack for the owner (statement 12). It says "Status: not run yet." Nothing in it is marked as passed.

No Worker, database, package, `wrangler.jsonc` or `src/privacy` file changed, so the privacy notice and the data inventory are unchanged and the README's running costs stay at €0.

## Earlier tests I changed

None. The expected list was empty and it is. No existing test, helper or snapshot was edited, loosened or deleted. Job 8's `[session 1]`, `[session 3]`, `[session 22]` and `[smoke 1]`, job 11's front door and `/account` tests and job 14's `tests/analytics-rules.test.ts` all ran green on GitHub (run below).

## Where I departed from the spec wording, and why

1. **A notice with a key the app does not know.** The spec says the welcome is hidden when "the address carries no `?notice=` message". I read "message" literally: the rule uses `noticeFrom(...) === null`, so `/?notice=anything-else` (no message shown) still shows the welcome. The three real notices (`signed-out`, `signed-out-email`, `deleted`) hide it. This is one line in `FrontDoor.tsx` if the owner wants any `?notice=` to hide it.
2. **"`/design-reference` shows the block in light and dark."** The reference page follows the phone's light or dark setting for every section, so the block shows in whichever the phone is set to, and the browser test checks both settings. I did not add a second forced dark copy on the same page, because that would repeat the dark token values in CSS.
3. **Statement 7's `git diff --stat main...HEAD` command is a Vitest test that cannot run on GitHub.** GitHub checks out one commit with no `main` branch, so the test skips there (its title then says so). It ran here, green, and a test that adds a comment to `worker/api.ts` on purpose turns it red. After the merge, `main...HEAD` is empty by itself. Next to it, tests that always run check that no file in `worker/`, `supabase/`, `src/privacy/` or `wrangler.jsonc` mentions the welcome, that the welcome's source touches no storage and makes no request, and that the front door still holds exactly its two `callApi` calls.
4. **Statement 5, the "ended" guest and the email account's signed out state, have two kinds of test.** Real accounts (the `@seed` and `@email` tests: a guest back by Leave session, a guest deleted in the database, an email account, an email account after Sign out) and tests that answer `GET /api/today` with the Worker's own `ended` and `account: "email"` shapes. The second kind also runs against the test project and preview links, where there is no database to make accounts in. Their names say "standing in for".
5. **Contrast is measured, not only left to axe.** axe reports text that sits straight on the page's white to lilac fade as "needs review" and does not fail it. A heading set to a near invisible colour passed the axe test in my break run (`evidence/break-10-low-contrast-heading.txt`, first attempt). So `[onboarding 10]` also has a test that measures each piece of text in the welcome against the solid colour behind it, or against the worst of the page's three ground colours, and needs 4.5 to 1. Axe stays in as the spec asks.
6. **Hallway test sheet extras.** The marking guide gives three passing and three failing answers for each of the two questions (six and six), not three and three in all. The stopwatch rule adds a cap: if a person has not reached the line after 120 seconds, write 120 and take the phone back. The sheet's opening words tell the person about the guest account and the 90 day deletion, as the spec's Risks section asks.
7. **First Tab stop.** In Chromium the test presses Tab once and expects Start. In WebKit it uses the `tabTo` helper, because WebKit skips buttons on Tab unless a system setting allows it. In both browsers a structural check also confirms Start is the first control in the page's order.
8. **Where the notes and evidence live.** The spec's wording and earlier jobs put `build.md` and the evidence inside the branch. I did the same, so they are not in the main checkout and do not clash on merge.

## Done when, and the tests that protect each

`[onboarding N]` is in each test name. Browser tests run in Chromium and WebKit at 375 x 812. Tests marked @seed or @email need the throwaway local database and run only on GitHub's pull request check.

| N | What | Tests |
| --- | --- | --- |
| 1 | Order: wordmark, heading, lead, welcome, Start, guest line (directly under Start), "I already have an account", links | `e2e/onboarding.spec.ts` "the front door shows, in order ...". Structure check in `tests/onboarding-rules.test.ts` ("sits in the intro ...") |
| 2 | The words, one file, 80 words at most, writing rules, banned words, Spoken and Written labels; the page shows that text and no other | `src/screens/welcome-copy.test.ts` (10 tests, with "catches" tests for each rule); browser "shows exactly the words of welcome-copy.ts and no other text" |
| 3 | Two bands in order, Hear it colours, computed in light and dark, no azure | browser "the Spoken band, then the Written band ..." (light, dark); CSS token check in `tests/onboarding-rules.test.ts` |
| 4 | No controls, no `lang`, no question, no ä ö å | browser "holds no button, link, input ..."; `tests/onboarding-rules.test.ts` (copy file letters, component tags) |
| 5 | Only new visitors | browser: new visitor sees it; three notices; ended and email signed out (standing in); signed in start and continue (standing in); @seed: guest back by Leave session, guest deleted in the database; @seed @email: email account and after Sign out |
| 6 | No flash, offline is fine | browser: delayed answer for a guest (standing in) and a real guest (@seed), never in the page, checked with a MutationObserver from before load; aborted request shows the welcome and Start's own failure message |
| 7 | Nothing stored or sent | browser: only the page's files and `GET /api/today`, same address, no cookie, empty local and session storage, no IndexedDB or cache before Start; @seed: the same at `/session` after Start, only the sign in cookies; `tests/onboarding-rules.test.ts`: the diff command, no mention in Worker, database, notice, no storage or request in the source |
| 8 | One tap to the first line, under 10 seconds | @seed browser "a new visitor presses Start once ..." reads the first approved line from the database, expects its spoken text, play controls, and records the time (0.37 s Chromium, 0.56 s WebKit on GitHub). @seed "loading the front door still creates no account" |
| 9 | Start and the guest line fit at 375 x 812, light and dark | browser "the whole Start button and the whole guest line are on the first screen" (both schemes) and "on a smaller phone ... Start stays reachable by keyboard before the links". Measured: Start bottom 709 px, guest line bottom 784 px, of 812 |
| 10 | Accessibility | browser: no sideways scroll at 320 px and 200 percent, with a 80 letter word; Start at least 44 px; one h1 then the welcome h2; first Tab stop; axe light and dark; text contrast 4.5 to 1; explicit token colours on every button; no animation or transition and reduced motion leaves the page unchanged |
| 11 | Design rules | browser: no picture, icon, emoji, uppercase, carousel, accent border, table style, gradient, shadow, transform; `tests/onboarding-rules.test.ts` (styles); existing `tests/design-css.test.ts`, `tests/design-rules.test.ts`, `tests/design-tokens.test.ts`, and `[smoke 1]` unchanged and green |
| 12 | Hallway test | Build side only: `evidence/hallway-test.md`, checked by 8 tests in `tests/onboarding-rules.test.ts` (the words said, the stopwatch rule, both questions word for word, three pass and three fail answers per question, five empty rows with every named column, status "not run yet", no name column, writing rules). **The test itself is not run and not marked passed. The owner runs it.** |
| 13 | Records | `design.md` entry, `/design-reference` section (browser tests, both schemes), conventions row, README costs unchanged, all checked in `tests/onboarding-rules.test.ts` |

## Checks I ran

On this computer (no Docker, so no database and no `@seed` or `@email` tests):

- `npm run check:code` (type check, lint, format check): pass. `evidence/local-checks-code.txt`.
- `npx vitest run`: 80 files, 1091 tests passed, 2 skipped (the Switzer font tests). `evidence/local-vitest-all.txt`.
- `VITE_DESIGN_REFERENCE=1 npm run build`, then `npx playwright test --grep-invert "@seed|@email"`: 240 passed, 28 skipped, 2 failed. The two failures are the health tests that expect `/api/health` to report the test project as reachable, which needs a database this computer does not have; I did not run them on main. They passed in the full run on GitHub. `evidence/local-playwright-new-visitor.txt`.
- Lefthook ran on every commit (type check, lint, Prettier, gitleaks): pass. No `--no-verify`.

On GitHub, `gh workflow run checks.yml --ref factory/15-onboarding`:

- Run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41243855040: **success**, all jobs. Browser tests against the local Supabase: 464 passed, 31 skipped, 0 failed, Chromium and WebKit, including every `@seed` and `@email` onboarding test. Unit tests, pgTAP, pytest, secret scan, dependency check, type check, lint and format all green. The jobs that need the test project or preview keys were skipped by design. `evidence/ci-r1-41243855040-checks.txt`.

- Run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41247997929 on the final tip (the same code, plus these notes and the evidence): the first attempt failed on one existing test, job 5's `[design 12] Play lights each spoken word in turn, Pause holds it, and the end is announced` in WebKit (it expected the held word to be "Mä" or "oon" and read "Alex", a timing slip on the design sample page, which this job does not touch; the same test passed in the first run above). I re-ran the failed job without changing anything and the run is **success**. I did not edit that test. It is worth the evaluator's attention as a possible flaky test of job 5.

No pull request was opened.

## Breaking each protection on purpose

Each protection was broken on purpose and its own test watched going red, then the break was undone (`git checkout`, or a reset for the one committed break). Each file in `evidence/` names what was broken, shows the diff, and lists what went red.

Local, Chromium for the browser tests, plus Vitest where a file test also covers it (34 break runs, `evidence/break-<statement>-<name>.txt`):

| Statement | Breaks (all went red) |
| --- | --- |
| 1 | welcome moved below Start; a sentence put between Start and the guest line |
| 2 | hidden extra text in the region; the word "quiz" in the copy; ten more words (over 80); an em dash in the copy |
| 3 | Written label loses its violet; the Spoken band gets the azure wash |
| 4 | a Skip button in the block; `lang="fi"` on a sentence; the letter ä in the copy file |
| 5 | "ended" dropped from the rule; notice dropped from the rule; welcome for every loaded view |
| 6 | welcome while loading; a failed request treated as an ended guest |
| 7 | a local storage write; a second `GET /api/today`; a comment added to `worker/api.ts` and committed |
| 9 | 150 px of extra space below the welcome |
| 10 | heading made an h3; a transition added; a near invisible heading colour (first run passed, which led to the contrast test, then red); reduced motion changes a colour; Start's text colour set to a non token colour |
| 11 | uppercase labels; a 4 px violet bar down the Written part; an emoji in the heading |
| 12 | "Use this app as you like." changed; a result row filled in; status changed to "passed" |
| 13 | reference page section renamed; `design.md` entry renamed; conventions row changed |

Some breaks are also caught by a second test (for example an uppercase label turns both my browser test and the existing `[design 18]` red). I list that in each file. The `@seed` and `@email` tests cannot run here, so they were broken on GitHub:

- https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41245097012 (branch `scratch/15-onboarding-red-seeded`, never merged): the rule for who sees the welcome made "every loaded view", and Start wrote to session storage. Result: failure, as intended. All the real account tests for statements 5 and 6 went red in both browsers (guest back by Leave session, guest deleted, delayed guest, email account), the test for statements 7 and 8 went red on the storage check, and so did the Vitest rule tests. Two earlier tests went red on that break, job 9's `[review 4]` (the welcome's word "review" appeared on a signed in front door) and job 10's `[speak 8]` (it forbids any browser storage). `evidence/break-ci-5-6-7-seeded-welcome-and-storage.txt`.
- https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41247541802 (branch `scratch/15-onboarding-red-slow`, never merged): after the guest account is made, Start waits 10.5 seconds before opening the session. Only the test for statements 7 and 8 went red, in both browsers (10.96 s against the 10 second limit, 74 other onboarding tests green). The same test measured 0.37 s and 0.56 s in the green run. That branch also edits the workflow to run only the onboarding spec, because a 10.5 second wait in every session start pushed the full suite past the job's 30 minute limit (the first try, run 41245142051, was cancelled at 30 minutes before it reached the test and proves nothing). `evidence/break-ci-8-slow-start.txt`.

## Unfinished or uncertain

- **Statement 12 is the owner's.** The hallway test needs 5 adults, about 40 minutes and a link that opens on a phone (a preview link waits for the Cloudflare preview keys, the live app waits for the go live job). Until the sheet is filled in the job cannot be approved. I have not marked anything passed.
- **The welcome wording is the approved draft, unchanged.** The owner approves the final wording at final approval, and may swap the second paragraph for v2's "Books teach one Finnish. The street speaks another." in `src/screens/welcome-copy.ts`; the word, punctuation and Finnish letter rules re-run on any edit.
- **The fit was measured with the fallback font.** The private Switzer font files are not in the public repository, and the throwaway database browser job runs without them (`docs/fonts.md`), so every number above (Start bottom 709 px, guest line bottom 784 px of 812) was measured with Poppins as the body font. Switzer is usually narrower, so the real fit should be equal or better, but I have not measured it. The evaluator can check on a preview link, which has Switzer.
- **The 28 px of room under the guest line is all there is.** A phone with a shorter viewport than 812 px will scroll, as statement 9 allows. The spec's order of trimming applies if a later change needs room: spacing first, then the third paragraph, never the guest line.
- **Statement 7's diff test is skipped on GitHub** (point 3 above). The evaluator should run `npx vitest run tests/onboarding-rules.test.ts` in the worktree.
- **The `@email` test relies on Mailpit** as job 11's tests do. It passed on GitHub.
- **The written part is not a filled band.** The Written part has no wash, as in Hear it, so the two bands differ by the teal fill and the violet label. If the design reviewer wants it drawn as a second filled band, that is one CSS rule.

## Lessons for the manager to consider adding to `AGENTS.md`

I did not edit `AGENTS.md`.

- axe does not fail text that sits on a background image or gradient; it reports it as "needs review". On this app's page fade, measure the real colours as well (`[onboarding 10]`).
- A break script that commits must add only the file it broke. `git add -A` swept the untracked evidence files into the break commit and the reset deleted them (recovered from the dangling commit with `git checkout <commit> -- <folder>`).
- On a Windows checkout git may give Markdown and other non-app files CRLF endings, so a test that reads such a file and splits on `\n` must normalise the line endings first.
- `Locator.evaluate` with a string does not call it as a function (it returns nothing). Mark the element, then run a page level expression, or write a real function.

## How to run it locally

1. In `.worktrees/15-onboarding`: `npm ci`, then `VITE_DESIGN_REFERENCE=1 npm run build`.
2. See it: `npx vite preview --port 4173`, then open https://localhost:4173/ in a private window (it uses a self signed certificate; the reference page is at `/design-reference`). A fresh window shows the welcome; after pressing Start and coming back it does not.
3. Words and file rules: `npx vitest run src/screens/welcome-copy.test.ts tests/onboarding-rules.test.ts`.
4. Browser tests with no database: `npx playwright test e2e/onboarding.spec.ts --grep-invert "@seed|@email"`. The `@seed` and `@email` ones need the local Supabase from Docker, so run them with the pull request check.
5. Hallway test: `factory/jobs/15-onboarding/evidence/hallway-test.md`.

Result: checks pass
