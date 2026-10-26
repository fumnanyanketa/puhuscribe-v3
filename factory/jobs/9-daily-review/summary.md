# Summary: 9-daily-review (Daily review, Keep it)

Round 2, 26 October 2026. Flag: **look closely** (learner data).

## What changed for a learner

1. Words met in a dialogue come back from the next day as that dialogue's line with the word missing, with the English meaning and the audio.
2. The learner types the missing word ("Type ä" and "Type ö" buttons help) and always sees the right word after answering. A missed word comes back once more in the same run.
3. v2's grader marks the answer and v2's scheduler sets the next date. No self rating, no counts, no streaks.
4. Review is the Keep it step at the end of today's session, or the whole session when no new dialogue is ready.
5. When nothing is due, the front door says so and names the next review day.

## Proof

- Preview link: none yet (repository secrets not set). The evaluator ran the built app locally with a throwaway database.
- Evidence: `factory/jobs/9-daily-review/evidence/`, evaluation `factory/jobs/9-daily-review/evaluation.md`: 21 of 21 statements pass, 0 failures, Chromium at 375 x 812, two test learners, axe clean in light and dark.
- Security review: pass, 0 must fix, 0 should fix, 2 notes (`review-security.md`).
- Design review: pass, 0 must fix, 1 should fix sent to `factory/todo.md` (`review-design.md`).
- GitHub checks on head d1d73ce (run 40364402722): all green, browser tests in Chromium and WebKit included. "Preview link" fails until the repository secrets exist.
- Builder notes: `build.md`. Statement 18's red scratch run is linked there.

## Things to look at closely

- Typed answers are graded but never stored, by design. Confirm that is what you want.
- The answer route grades any card the learner owns, even one already done today (a second browser tab gets a second grade). It only ever touches the learner's own data. Noted as a to-do item.
- The branch carries two manager fixes from main: shorter lesson lines in AGENTS.md (word budget) and the wrangler and miniflare update that clears today's npm audit findings.

## Approval

Approve with `/factory approve 9-daily-review`, or send it back with `/factory rework 9-daily-review <note>`.
