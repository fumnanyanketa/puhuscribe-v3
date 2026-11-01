# Job 18: Ask a guest to save their progress

Flag: look closely. It reads learner data to decide when to show the note. It stores nothing new. Cost is 0 euro.

## What changes for you and your learners

1. A guest who finishes their first session sees a note on the finish screen: "Add your email to save your progress." with a white "Add your email" button and a quiet "Not now".
2. The note comes back once more after the third finished session, then never again. People who already added an email never see it.
3. "Add your email" opens the email page from job 11. "Not now" replaces the note with "No problem. You can add your email later from Your account." and saves nothing.
4. "Done" stays the only black button, and it never moves.
5. Nothing new is stored. The app works out "first" or "third session" from the sessions it already keeps.

## Checks and review

- GitHub checks on branch `factory/18-save-progress`: all green on run 41248527014 (tested `c5a6610`; the head `e6953e4` adds only notes and evidence). 33 database tests, 32 browser tests for this job in Chromium and WebKit at phone size, 81 unit test files.
- Every protection was broken on purpose and its own test went red: 13 database breaks (run 41247408043), 9 local breaks, 8 browser breaks (runs 41248547803 and 41249115436), plus two more by the evaluator (run 41254250992).
- Security review: pass, nothing to fix. The note cannot reveal anything about another learner, and "Not now" writes no cookie or storage.
- Design review: pass, nothing to fix. Buttons readable in light and dark on iPhone's browser engine.
- Evaluator: pass, all 18 statements. One safety guard for the browser's Back button could not be tested automatically; it can be checked by hand on a real iPhone.
- Preview link: none, because the Cloudflare preview keys are not on the repository yet. The evaluator ran the app at 375 x 812 with stand-in answers for the database.
- Reports: `security-review.md`, `design-review.md`, `evaluation.md`, `build.md`. Evidence: `factory/jobs/18-save-progress/evidence/`.
- Screenshots for you: `recording/screenshots/110-18-save-note.png`, `110-18-after-not-now.png` and `110-18-long-line-note-below.png`.

## Points the reviewers raised for you

- The finish screen already says "Your progress is saved." at the bottom, then the note says "Add your email to save your progress." A beginner could read that as a contradiction.
- When the learned line is long (three or four lines), the note sits below the visible area and the learner must scroll to see it. With short lines it is fully visible.
- Things to watch later, no action now: the "Your account" line depends on the account page staying linked after jobs 15 and 17; if Supabase renamed its guest marker, the note would quietly stop appearing.

## Your approval

Owner approval, given in chat on 1 November 2026 through the approval questions:
- Bottom line: "\"...on this device\" (Recommended)". Guests see "Your progress is saved on this device."; signed in learners keep "Your progress is saved."
- Note place: "Keep it below (Recommended)".
- Job 18: "Approve (Recommended)". Merge after the bottom line change passes the checks.

Result: approved, 1 November 2026, subject to round 2 passing the checks.
