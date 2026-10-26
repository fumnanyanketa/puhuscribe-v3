# Summary: 11-accounts (Accounts and personal data)

Round 3, 26 October 2026. GA job. Flag: **look closely** (learner data, sign in, database and access rules). Stage: **blocked on one owner's call**, then your written approval.

## What you need to do

Owner's call 2: the name and contact address printed on the privacy notice (who is responsible for the data and how to reach them). Reply with the name (a person or the company) and one contact address, and say which email address to use. The builder puts them in one setting (`src/privacy/notice-settings.ts`) and the notice is complete. Nothing else is missing.

Also still yours: the owner setup steps on the Supabase test project listed in the README, and which email sender to use before real learners (recommended at launch).

## What changed for a learner

1. A guest adds their email and types a 6 digit code from the email. The account stays the same, so every session and review card stays. If the email already has an account, the code signs them into that one and the guest progress on this device is deleted, and the screen says so first.
2. On a second phone they sign in with the same email and a new code and see the same progress.
3. A privacy page at /privacy explains in plain words what is kept, why, for how long, where, and their rights. It is linked from the front door, the account page and the email screen.
4. "Download my data" gives one file with everything; "Delete my account" removes every row and signs out every device.
5. Guests are deleted after 90 days without activity, email accounts after 24 months (owner's call 3, option B, from your "all recommendations" line).

## Proof

- Preview link: none yet (repository secrets not set). The evaluator ran the built app locally with a throwaway database and a local mail catcher.
- Evidence: `factory/jobs/11-accounts/evidence/`, evaluation `evaluation.md`: 28 of 29 statements pass. The one failure is statement 16, the privacy notice, only because the responsible name and contact are empty. Checked: same account id and rows byte for byte after adding an email, the taken email path, wrong and expired codes, the 60 second resend, second device sign in, the download file (every user table, only the caller's rows, no token), deletion (0 rows left), the 90 day and 24 month clean ups, anon refused on all three functions.
- Security review: pass, 0 must fix, 0 should fix, 2 notes (`review-security.md`).
- Design review: pass, 0 must fix, 2 should fix in `factory/todo.md` (`review-design.md`).
- GitHub checks: run 40364572122 on head bfbdd5c green in Chromium and WebKit (247 passed). Round 2 fixed a race in a browser test; round 3 fixed the test helper's animation wait that WebKit aborted. "Preview link" fails until the secrets exist.
- Builder notes: `build.md`, rounds 1 to 3, with the statement 19 and 21 red runs recorded locally.

## Things to look at closely

- The clean up deletes email accounts after 24 months without activity. Say so if you would rather keep them longer.
- Each sign in code check calls Supabase twice and all learners share one limit from the Worker's address (launch item already on the list).
- Job 10's two new tables (transcripts, kept recordings) must be added to the export when the two jobs meet on main; the export test will catch it.

## Approval

After owner's call 2 is answered and built in, this GA job needs your own written "approved" line: `/factory approve 11-accounts`, or `/factory rework 11-accounts <note>`.
