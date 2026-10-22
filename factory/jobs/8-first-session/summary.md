# Job 8: First session loop (Hear it, Understand it)

Flag: look closely. It stores learner data, adds sign in (as a guest) and changes the database access rules. It adds no new paid service and costs 0 euro.

## What changes for a learner

1. A visitor opens the app and starts as a guest. No email, no form. The app signs them in behind the scenes and keeps them signed in for 90 days with a cookie that the page's own scripts cannot read.
2. They hear the first dialogue line by line in spoken Finnish, with the written Finnish labelled underneath. They can tap any word for its card: base form, which form it is, one line of why, both registers.
3. They answer a short check of 2 to 3 taps, with kind wording when they miss, and finish with the one sentence they can now say.
4. When they finish, the app saves the session, a review card for each form they met, and one `first_session_completed` event, all in one step. A retry saves nothing twice.
5. The old Hei! page and its visit counter are gone. The place for the Say it step is built and waiting, so job 10 only adds to a list.

## Checks and review

- GitHub checks on pull request 18 (head `35cb006`): all green. 170 browser tests in Chromium and WebKit at phone size, 450 database tests, 534 unit tests. A pull request run bills about 15 to 18 minutes.
- Security review: pass, no must-fix. Its should-fix items and one launch decision (how many guests Supabase will let in per hour from the app's address) are in `factory/todo.md`.
- Design review: one must-fix (punctuation could wrap onto its own line next to a Finnish word) and nine smaller items. All fixed in round 2.
- Evaluator (round 1): two must-fix (a database test that passed for the wrong reason, and stale notes). Both fixed in round 2. The builder proved the new tests go red when the protection is removed.
- Round 2 was not re-tested by a fresh evaluator. It is proven by the builder's red runs and by GitHub's green checks.
- Evidence folder: `factory/jobs/8-first-session/evidence/`. Reports: `review-security.md`, `review-design.md`, `evaluation.md`.

## Be aware

- The test project now has anonymous sign-ins on, with a limit of 100 per hour. Previews stay behind Cloudflare Access.
- Real content: the browser tests use a clearly named test fixture in a throwaway database only. A real learner sees the app's own dialogue only after job 7's pipeline publishes one that your native reviewer approved. Until then the front door says nothing is ready.
- Nobody outside the team should use the app until job 11 adds the privacy notice, export and delete.
- The first merge push runs the database changes against the shared test project once.

## Your approval

This is a GA job. It is done only when you write "approved" with the date.

Owner approval, written in chat on 22 October 2026: "Approved job 8, the first session loop, 22 October 2026. Merge it into main. I accept that real content only appears after job 7 publishes a reviewer approved dialogue."

Result: approved.
