# Job 13: Private review site at puhuscribe.exentrik.co

Flag: look closely. It puts a website on a public domain behind a login lock (Cloudflare Access), it holds unpublished Finnish drafts, and it needs a second Cloudflare account's settings. Cost is 0 euro.

## What changes for you and your reviewer

1. Your native reviewer will open a link, `puhuscribe.exentrik.co`, instead of receiving a file. They sign in with a code Cloudflare emails to them. Only your email and theirs pass the lock.
2. The site shows one start page that lists the dialogues you choose, each round marked "Waiting for your review", "Review received" or "Not reviewed". It lists the first dialogue, `meeting-people-new-colleague`, from the start.
3. Each round opens the same review page as today. The reviewer ticks their decisions and downloads their file, and sends it to you by whatever way you choose. There is no upload route, so nothing can write into the project from the site.
4. Search engines are told to stay away, pages are not cached, and the site shows nothing for any address you did not list.
5. Nothing about the app changes. The app's own domain is still open.

## Checks and review

- GitHub checks on pull request 19 (head `b8cdf45`): all green. 560 unit tests, 72 of them for this site. The deploy step skips cleanly while the Cloudflare setup is missing, so main stays green.
- Security review: pass, no must-fix. Notes are in `factory/todo.md` (for example, anyone with write access to the repository could reach the deploy token from a branch, which GitHub's free plan cannot prevent, so the token is kept narrow).
- Design review: pass, no must-fix. Small wording items fixed or filed.
- Evaluator (round 1): two must-fix (line endings that would break the code checks on your Windows machine, and one test that passed for the wrong reason). Both fixed in round 2 and proven with red scratch runs. Round 2 was not re-tested by a fresh evaluator.
- Evidence folder: `factory/jobs/13-review-site/evidence/`. Reports: `review-security.md`, `review-design.md`, `evaluation.md`.

## What waits for you, after the merge

Statements 13 to 20 can only be proven after the first deploy. I will guide you through these one at a time in the Exentrik Cloudflare account, about 20 minutes:
1. Switch on free Zero Trust and add the one-time code login.
2. Create the lock for `puhuscribe.exentrik.co` and type in the two emails yourself. I never choose or type an email.
3. Create a narrow token and add four GitHub secrets and two variables.
4. Start the "Review site" workflow on main, then sign in once to see it work.

If Cloudflare asks for a payment card for the free Zero Trust plan, that is your decision.

## Your approval

Routine job apart from the flag, so one approval. Say "approved" with the date to merge it.

Owner approval, written in chat on 22 October 2026: "Oh, you wanted me to up 13 as well. Can you bring it up again? And let's just approve it all. I'm telling you now that you can go ahead to approve it." The manager reads this as approval of job 13 only. GA jobs still need their own written approval.

Result: approved.
