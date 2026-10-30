# Job 14: Visitor count by country, owner page, feedback and crash reports

Flag: look closely. It stores new data about learners (feedback, crash reports, a visit count), adds database access rules, and adds a private owner page. Cost is 0 euro: everything lives in our own EU database and Worker.

## What changes for you and your learners

1. Every arrival at the app adds one to a daily total for that visitor's country, with Finland shown on its own. Nothing personal is kept: no internet address, cookie or browser details, only "30 October, Finland, 9".
2. You get a private owner page at `puhuscribe-owner.exentrik.co` (set up at go live) with the launch numbers for the last 30 days: active learners, day 7 return, median session length, speak back share and AI cost per learner, plus visits by day and by country. Three locks guard it: the Cloudflare login, a check in the Worker, and your own PuhuScribe account on the owner list.
3. Learners can send you feedback from the app, up to 5 messages a day. You read them on the owner page, shown exactly as typed.
4. When something breaks on a learner's screen, a cleaned crash report goes to our own database. Typed answers, emails, ids and long numbers are removed, and reports are deleted after 30 days.
5. The privacy notice explains all of this, dated 30 October 2026. Its wording needs your approval (below).

## Checks and review

- GitHub checks on branch `factory/14-analytics`: all green on run 41062289293 (head `0fd1065`; later commits add only notes and evidence). 1,052 unit tests, 903 database tests plus 9 two-connection tests, 388 browser tests in Chromium and WebKit at phone size.
- Security review: pass, no must fix. Four notes; one (crash reports from the owner page would have been blocked by the Cloudflare login) was fixed in round 2, the rest are in `factory/todo.md`.
- Design review: round 1 changes needed (the privacy notice wrongly said everything is deleted with the account). Fixed in round 2 and passed on re-check.
- Evaluator: round 2 failed on two items (a cost test that could never fail, and a double tap storing feedback twice). Both fixed in round 3, each proven with a red GitHub run (41062406257 and 41062162179), and a fresh evaluator re-check passed. 32 of 33 statements pass; statement 33 can only be proven after go live.
- Every owner page lock was removed on purpose, one at a time, and only its own test went red.
- Preview link: none, because the Cloudflare preview keys are not on the repository yet. The evaluator used the GitHub runs and its own browser runs at 375 x 812.
- Evidence folder: `factory/jobs/14-analytics/evidence/`. Reports: `security-review.md`, `design-review.md`, `evaluation.md`, `build.md`.
- Screenshots for you: `recording/screenshots/108-14-analytics-owner-page.png` and `recording/screenshots/108-14-analytics-privacy-notice.png`.

## Privacy wording for you to approve

- Visit totals are "kept as daily totals with no personal data for as long as the service runs". The spec set no limit. A limit such as 25 months would be a small change.
- If someone asks to see or delete their visit or crash data, the notice says we cannot find it, because it is not linked to anyone, and we tell them so.
- The crash report text lists what is removed before saving.
- The heading "Your learning progress" is now "Your learning and what you send us", and the owner list has its own heading "Only for the app's owner".

## What waits for go live (a separate job)

- The live app at `puhuscribe.exentrik.co`, the live EU database, and the Cloudflare login for the owner page.
- You add your own email to the owner list yourself; the README has the one line to type. No email is in the code.
- Statement 33 is proven then.

## Your approval

GA job, so it needs your own written "approved" line with the date before it merges.
