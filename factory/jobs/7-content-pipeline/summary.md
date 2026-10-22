# Job 7: Content pipeline and native review

Flag: look closely. It handles Finnish learning content, a paid service (AI and voice, both with spending limits) and the rule that nothing unapproved reaches a learner.

## What changes for a learner

1. Nothing yet in the app. This job builds the machine that makes the Finnish: you write a short brief (a situation and a "can do" line), Claude drafts the dialogue in written and spoken Finnish, a Finnish word checker (Voikko) tests every word and sends bad ones back, and a Microsoft voice reads both versions aloud.
2. Your native reviewer gets one web page per round. For each line they approve, fix or comment, and they rate each audio clip. They send back one small file. Edited text cannot ride an old approval, because every approval is tied to the exact text.
3. Only fully approved lines are published, and only then does their audio reach the app. An unapproved line cannot be read by a learner.
4. Every AI and voice call is written to a cost log. Estimate: about 25 cents per dialogue. Both keys have spending limits and live only in GitHub.
5. Cost for the machine itself is 0 euro. The Azure voice uses the free tier in Italy North (EU).

## Checks and review

- GitHub checks on pull request 17 (head `cc90a75`): all green, including the Python tests with real Voikko (138, none skipped) and the database tests, which publish twice and get the same result.
- Security review: pass. Six small fixes, three of them done in round 2, the rest in `factory/todo.md`.
- Design review: two must-fix problems found and fixed in round 2 (a reviewer who wanted fixes could not download without a false "approve", and long Finnish words ran out of the card on a phone). Smaller items fixed or filed.
- Evaluator: pass on the final head. It broke seven protections on purpose and each test went red.
- Evidence folder: `factory/jobs/7-content-pipeline/evidence/`. Reports: `review-security.md`, `review-design.md`, `evaluation.md`.

## What is still open, by design

- The real keyed run (a real dialogue drafted by Claude and voiced by Azure) can only start after this job is merged, because GitHub only offers a manual workflow once its file is on main. I will run it right after the merge. It will show whether Italy North really offers Finnish voices. If it does not, we move the voice resource to another allowed EU region and nothing else changes.
- Statement 18 (the reviewer's real approval and the unit 1 publish) waits for your native reviewer. You chose to have them review everything at the end of the MVP, so it moves to job 12.
- Firefox is untested for the review page. Real Safari playback is unverified.

## Your approval

This is a GA job. It is done only when you write "approved" below with the date. The question to answer: do you accept that the keyed run and the reviewer's approval come after the merge?

Owner approval, written in chat on 21 October 2026: "Approved job 7, the content pipeline, 21 October 2026. Merge it into main. I accept that the real keyed run and the reviewer's approval come after the merge."

Result: approved.
