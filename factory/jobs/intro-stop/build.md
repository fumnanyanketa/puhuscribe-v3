# intro-stop: build notes (fast route, 4 November 2026)

Branch `factory/intro-stop`, from `origin/main` after pull request #38 (intro-rule). Not merged.

## The owner's rule

In the owner's words, 4 November 2026: "Aleksi should stop showing up when they have finished a stop, not just a lesson, when they have completed a stop. So if they do only one lesson and leave, when they come back, they should meet Alexi again ... and then take them to where they are."

As built: the intro is skipped only for a learner who is signed in with an email account and has finished at least one whole stop (every lesson of it; stop 1, "Meeting people", has 4). Everyone else meets Aleksi each time the road opens: new visitors, guests (whatever they finished), ended sign ins, and email accounts that have not finished a stop, even with lessons done. After "Nice to meet you" the road opens at the learner's own place, with their progress.

## What was built

- **GET /api/today** replaces `finishedLesson` with `finishedStop: boolean` in the signed in answer. `account: 'email' | 'guest'` is unchanged.
- **How a finished stop is decided.** The road already decides it: a stop is done when its lessons done reach its lessons (`src/lib/road-state.ts`, `currentIndex` and `progressSegments`). Those numbers come from `public.road()` (`lessons_total` is 4 per stop; `lessons_done` is the stop's finished dialogues plus its review lesson, from the learner's own sessions and review logs). The front door now reads `public.road()` the same way GET /api/road does: with the learner's own token, through `supabaseRoadDb` (`worker/road.ts`), checked by `roadStop`. New `finishedAStop` in `worker/road.ts`: some stop with `lessons_total > 0` and `lessons_done >= lessons_total`.
- `public.road()` is already granted to `authenticated` (guests are authenticated too) and runs with the learner's own rights. No database rule, grant or migration changed.
- The road read runs alongside the two reads the route already made, so it adds one database call but no extra wait. A road row of the wrong shape is a fault (503), as on GET /api/road. The road screen already needs GET /api/road, so this adds no new way for the road to fail.
- `finishedALesson` (from intro-rule) is removed with its tests, since nothing uses it now.
- **The rule** (`showsAleksiIntro` in `src/lib/aleksi-intro.ts`): `!(signedIn && email && finishedStop === true)`. The road reads `finishedStop` only when it is exactly `true` (`src/road/home-view.ts`).

## Statements and the tests that protect them

1. Who sees the intro. `src/lib/aleksi-intro.test.ts` [intro-stop 1]: new visitor, ended guest and email, guest with and without a finished stop, email account with lessons done but no finished stop, email account with a finished stop (start, all done, review), unclear answers, and the old `finishedLesson` no longer skipping it. `e2e/aleksi-intro.spec.ts` [intro-stop 1]: each case in the browser with the road's lessons done (guest with nothing, guest who finished stop 1, email with 1 and with 3 of 4 lessons, ended guest and email) meets Aleksi and meets him again after a reload; the email account that finished stop 1 never sees him.
2. GET /api/today carries `account` and `finishedStop`, by the road's own rule. `worker/today-learner.test.ts` [intro-stop 2]: 0, 1 and 3 of 4 lessons give false, 4 gives true, a stop with no lessons gives false; a guest, an email account with one or three lessons and one that finished stop 1; all done and not ready; a wrongly shaped road row answers 503; and with Supabase as the learner, `rpc/road` is called with the device's token and nothing from the request's query. `src/road/home-view.test.ts` [intro-stop 2]: the road reads both facts and ignores odd values.
3. The phone keeps no flag (unchanged from intro-rule, [intro-rule 3] tests kept).
4. After "Nice to meet you" the road opens at the learner's own place. `e2e/aleksi-intro.spec.ts` [intro-stop 4]: an email account with one lesson done meets Aleksi, then sees stop 1 current with Start and no "Sign in". An email account that finished stop 1 goes straight to the road with stop 2 current and the opening animation.

Each protection was broken on purpose and its tests went red, then restored: "any lesson done counts" (3 Worker tests red), "a stop with no lessons counts" (1 red), the rule without the finished stop (2 unit tests red), and in the browser "every email account skips it" (the 3 email cases with lessons done red).

## Tests changed because the behaviour changed

- `worker/sessions.test.ts`, `worker/review.test.ts`, `worker/guest.test.ts`: their exact GET /api/today answers now say `finishedStop: false` in place of `finishedLesson`. Their fake learner has no road rows, so no stop is finished. `worker/guest.test.ts` passes an empty road (`roadDb`), since its hand made fake has no road call.
- `worker/test-fakes.ts`: the fake learner database answers `road()` from `roadRows` (empty unless a test fills it), and a new `roadRow` helper makes one road row.
- `e2e/aleksi-intro.spec.ts`: the per case list and the "never sees it" test use `finishedStop` and real lessons done on the road. The new [intro-stop 4] test was added.

## Checks run

- `npm run check:code`: type check and lint pass. Prettier warns only on `design-drafts/*` (CRLF in this Windows checkout, as before).
- `npx vitest run src/lib/aleksi-intro.test.ts src/road/home-view.test.ts worker/`: 27 files, 403 tests pass.
- `npm run build`: passes, with the built secrets and built files checks.
- `npx playwright test e2e/aleksi-intro.spec.ts e2e/redesign-road.spec.ts --project=chromium`: 64 passed.
- Commit hooks (Prettier, gitleaks) passed on every commit.
- Not run (tests paused until the MVP): the other browser specs, WebKit, the database tests and the evals.

## Open points

1. A stop counts as finished only when its review lesson is done too, because `public.road()` counts it as the stop's fourth lesson. A learner who finished the three dialogues of stop 1 but not its review still meets Aleksi. That is how the road itself shows the stop (not done).
2. As in intro-rule, the rule follows the account, so the same email account on a new phone also skips the intro.

## Run it locally

`npm ci`, `npm run build`, `npx vite preview`, open `/learn` at 375 px. A fresh browser sees Aleksi every time. `e2e/aleksi-intro.spec.ts` mocks each case.

Result: checks pass
