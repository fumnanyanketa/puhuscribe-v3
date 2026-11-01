# Job 15: A short welcome on the front door

Routine job, one approval. Stores nothing and sends nothing. Cost is 0 euro.

## What changes for you and your learners

1. A new visitor who is not signed in sees a short welcome between the opening sentence and Start. It is your approved 73 word draft, with no Finnish and nothing to tap.
2. It explains the session, then shows "Spoken" in the teal band and "Written" under it, with the same colours as the Hear it step.
3. Signed in learners, people whose guest account ended, and people arriving with a message (such as "your account was deleted") do not see it.
4. On a 375 x 812 phone, Start and the guest line stay on screen without scrolling. Start to the first dialogue line takes under a second.
5. Nothing is stored, no cookie is set, and no server or database file changed.

## Checks and review

- GitHub checks on branch `factory/15-onboarding`: all green on round 2, run 41277646584. Round 1 runs 41243855040 and 41247997929 were also green (the second after one retry of an older, unrelated test that is known to be flaky).
- The builder broke every protection on purpose, 36 times in all, and each time its own test went red.
- Combined design and security review: pass. All five security items pass.
- Evaluator: round 1 failed statement 7. A test meant to prove "no server files changed" would have failed every later job after the merge. Round 2 fixed it so it runs only on job 15's own branch, and the re-check passed. Statements 1 to 11 and 13 pass.
- Statement 12, the hallway test with 5 adults, is yours to run. The sheet is `evidence/hallway-test.md`.
- Preview link: none, because the Cloudflare preview keys are not on the repository yet.
- Reports: `design-review.md`, `evaluation.md`, and `build.md` in the branch. Evidence: `factory/jobs/15-onboarding/evidence/`.
- Screenshots for you: `recording/screenshots/111-15-welcome.png`, `111-15-welcome-dark.png` and `111-15-welcome-small-phone.png`.

## Points the reviewers raised for you

- The word "forms" is used twice with two meanings: "Every line comes in two forms" and then "in books and on forms". The reviewer suggests "on official papers" for the second.
- On a smaller phone (iPhone SE size, 375 x 667) Start is below the visible area until the learner scrolls. The design only promises the 375 x 812 size.
- The hallway test needs a link a stranger can open. Preview links sit behind the Cloudflare login, and the live app is not set up yet.

## Your approval

Waiting for the owner's approval.
