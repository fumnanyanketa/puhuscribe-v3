# Summary: 10-speaking-feedback (Speaking feedback and voice consent, Say it)

Round 3, 26 October 2026. GA job. Flag: **look closely** (recordings and consent, learner data, a paid service).

## What changed for a learner

1. A new step, Say it, comes after Understand it. The learner hears each line, records a few seconds, and gets one short kind hint, such as "Close. Try the double k."
2. Before the first recording, a plain screen says what is recorded, where it goes and that it is deleted. No microphone request happens until they press "Turn on speaking feedback". "Not now" still lets them say the lines aloud without feedback.
3. The recording is thrown away as soon as the feedback is ready. Only the text the service heard and the result are kept, for 90 days. Keeping recordings is a separate box, off by default.
4. Voice settings at /voice show both choices and turn each off with one press, deleting kept recordings and transcripts at once.
5. Spoken answers in daily review (statement 21) wait for job 9's merge and are not built yet.

## Proof

- Preview link: none yet (repository secrets not set). The evaluator ran the built app locally with the recorded fake speech service; the real Azure service was never called.
- Evidence: `factory/jobs/10-speaking-feedback/evidence/`, evaluation `evaluation.md`: 22 of 23 testable statements pass, 0 fail, statement 21 deferred. Chromium at 375 x 812.
- Security review: pass, 0 must fix, 1 should fix, 3 notes (`review-security.md`).
- Design review: pass, 0 must fix, 2 should fix (`review-design.md`). Should-fix items are in `factory/todo.md`.
- GitHub checks: run 40366546462 on head afc9aa7 green in Chromium and WebKit (231 passed). Two things came out of the first WebKit runs: the test's fake microphone now stands in for the recorder that Playwright's Linux WebKit lacks (test code only), and a real bug: when the 10 second stop timer fired a little late, the recording came out just over 10 seconds and the server refused it with "could not be checked". The recorder now cuts to exactly 10 seconds before sending, with two unit tests. "Preview link" fails until the secrets exist.
- Builder notes: `build.md`, with the round 3 section and the statement 16 red run output in the evidence folder.

## Things to look at closely

- **Costs money.** The limit of 40 speech checks per learner per 10 minutes can be beaten by sending requests in parallel, because the slot is counted before the Azure call and written after it. One learner could run up more paid calls than intended. Reviewer rating: should fix. Say "fix it now" if you want that closed before merge; otherwise it rides the to-do list.
- With the fake service the consent screen names no region, only "in the EU". With the real service it names the region from the settings.
- The 90 day clean up and the account deletion remove transcripts and recordings. Job 11's data export must include these two new tables (noted for job 11).
- The branch carries the manager's main fixes (AGENTS.md word budget, dependency update, browser job timeout and runner image).

## Approval

This is a GA job: approve with your own written "approved" line, `/factory approve 10-speaking-feedback`, or send it back with `/factory rework 10-speaking-feedback <note>`.
