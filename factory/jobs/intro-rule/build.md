# intro-rule: build notes (fast route, 4 November 2026)

Branch `factory/intro-rule`, from `origin/main` after pull request #37 (aleksi-intro). Not merged.

## The owner's rule

In the owner's words, 4 November 2026: "only people who have signed in successfully and created an account, finish the lesson and have their progress saved. Those are the people that would not see the introduction from him anymore."

As built: Aleksi's intro shows every time the road opens, to everyone except a learner who is signed in with an email account (not a guest) and has finished at least one lesson. That learner goes straight to the road. A new visitor, a guest (with or without a finished lesson), a sign in that ended (guest or email) and an email account with no finished lesson all see it.

## What was built

- **GET /api/today** answers two more facts when the learner is signed in: `account: 'email' | 'guest'` and `finishedLesson: true | false`. Signed out and ended answers are unchanged.
  - `account` comes from the user Supabase Auth returns for the learner's own token (`is_anonymous`). The route already asked Auth for that user to check the sign in (`signInState`), so the new `signInCheck` in `worker/learner-auth.ts` keeps the answer instead of throwing it away. No extra call, and no user id is taken from the request. Anything other than `is_anonymous === false` counts as a guest.
  - `finishedLesson` comes from the learner's own sessions, which the route already read (`LearnerDb.mySessions`; row level security limits it to their own rows). A lesson is finished when a session of a dialogue has its end time. A finished review only session (no dialogue) does not count. New pure function `finishedALesson` in `worker/session-plan.ts`.
  - No database rule, grant or migration changed. Both facts are read with the access the route already had.
- **The road** (`src/road/home-view.ts`) reads the two facts. `email` is now true for a signed in email account too (it was only set for an ended one), and `finishedLesson` is set only when the answer says exactly `true`. Anything unclear means the intro shows.
- **The rule** is `showsAleksiIntro` in `src/lib/aleksi-intro.ts`: `!(signedIn && email && finishedLesson === true)`.
- **The "met" flag is gone.** `MET_KEY`, `hasMetAleksi` and `markMetAleksi` are removed, and "Nice to meet you" writes nothing. When the road opens, `clearOldIntroKeys` removes both the old first-open answers (`puhuscribe-intro`) and the old flag (`puhuscribe-aleksi-met`) from the phone, each in its own try, so blocked storage breaks nothing.
- **Unchanged:** after "Nice to meet you" the road opens with its opening animation (none under reduced motion).

## Statements and the tests that protect them

There was no spec for this fast route. These are the statements the tests are labelled with.

1. Who sees the intro (the rule above). `src/lib/aleksi-intro.test.ts` [intro-rule 1]: new visitor, ended guest and ended email, guest with and without a finished lesson, email with none, email with one (start, all done, review), and unclear answers. `e2e/aleksi-intro.spec.ts` [intro-rule 1]: each case in the browser, including a reload, and the email account with a finished lesson going straight to the road with no greeting played.
2. GET /api/today carries `account` and `finishedLesson`, read with the learner's own sign in. `worker/today-learner.test.ts` [intro-rule 2]: guest with none and with one, email with none and with one, all done and not ready, a finished review only session does not count, and the only Supabase call is Auth's user check with the device's token (a `user=` or `account=` query is ignored). `src/road/home-view.test.ts` [intro-rule 2]: the road reads both facts and ignores odd values.
3. The phone keeps no flag, and the old keys are cleared. `src/lib/aleksi-intro.test.ts` [intro-rule 3]. `e2e/aleksi-intro.spec.ts` [intro-rule 3]: nothing stored after "Nice to meet you", the intro shows again after a reload, and an old flag is cleared and no longer skips the intro.
4. After "Nice to meet you" the road opens with its animation. `e2e/aleksi-intro.spec.ts` [intro-rule 4], with motion turned on: Skip shows first, then the day one card, and Start goes straight into the lesson.

Each protection was broken on purpose and its test went red, then restored: Auth's answer forced to "guest" (3 Worker tests red), a review only session counted as a lesson (1 red), the rule without the finished lesson (2 red), the rule without the email check (2 red), and in the browser the rule "signed in never sees it" (the 3 signed in cases red).

## Tests changed because the behaviour changed

- `worker/sessions.test.ts` [session 6] [session 18], `worker/review.test.ts` [review 4] [review 5] [review 7] and `worker/guest.test.ts`: their exact GET /api/today answers now include `account` and `finishedLesson`, with the right value for each case. Nothing was loosened.
- `e2e/intro-seen.ts`: the shared setup used to write the "met" flag before the page loaded. With no flag, it now presses "Nice to meet you" by itself as soon as the intro appears, so the other browser tests still reach the road (which then opens with its animation, as after a real press). The greeting's one play attempt happens before the press, as for a real visitor. `e2e/test-base.ts`, `e2e/road-route.ts` and `e2e/road-mocks.ts` changed in comments only.
- `e2e/redesign-road.spec.ts` [redesign 17] [redesign 44], `e2e/save-progress-helpers.ts` and `e2e/speaking-feedback.spec.ts`: "stores nothing" counts every key again, because the key the setup used to write is gone. Stricter than before.
- `e2e/aleksi-intro.spec.ts`: the old "marks the phone" and "a reload goes straight to the road" tests are replaced by the new behaviour, and the old "signed in and ended never see it" test by the per case tests above.

## Checks run

- `npm run check:code`: type check and lint pass. Prettier warns only on `design-drafts/*` (CRLF in this Windows checkout, as in earlier jobs; not files of this job).
- `npx vitest run src/lib/aleksi-intro.test.ts src/road/home-view.test.ts worker/`: 27 files, 401 tests pass.
- `npm run build`: passes, with the built secrets and built files checks.
- `npx playwright test e2e/aleksi-intro.spec.ts e2e/redesign-road.spec.ts --project=chromium`: 62 passed.
- Commit hooks (Prettier, gitleaks) passed on every commit.
- Not run (tests paused until the MVP, owner's instruction): the other browser specs, WebKit, the database tests and the evals.

## Open points

1. The other browser specs were not run. If one breaks, the likely cause is the intro now showing (and pressing itself away) for a visitor or guest where the flag used to skip it.
2. A guest who finished a lesson and then saves progress with an email keeps the same user and sessions, so from then on they go straight to the road. That matches the owner's words ("created an account, finish the lesson and have their progress saved").
3. An email account with a finished lesson that signs in on a new phone never sees the intro there either. The rule follows the account, not the phone.

## Run it locally

`npm ci`, `npm run build`, `npx vite preview`, open `/learn` at 375 px. A fresh browser sees Aleksi every time. To see the road without him, sign in with an email account that has finished a lesson (local Supabase), or run `e2e/aleksi-intro.spec.ts`, which mocks each case.

Result: checks pass
