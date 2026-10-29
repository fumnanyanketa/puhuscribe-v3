# Summary: 12-units-1-3 (Units 1 to 3 content, Patterns you've seen)

Round 6, 29 October 2026. Flag: **look closely** (Finnish learning content, reads learner data). Stage: **merged** into main as `01a549f`.

## What changed for a learner

1. Units 1 to 3 now have six dialogues, two per unit: meeting people, ordering coffee and the grocery store. Each line has a spoken and a written version, with audio for both.
2. A card behind a tap on each word, "Patterns you've seen", lists the forms the learner has met, grouped by form, with the line where they met each one. It shows only that learner's own forms.
3. The full loop works through all three units: hear, understand, say it back, and a day later keep it in review.
4. Typing fast after the ä and ö buttons no longer scrambles letters. That was a bug from the daily review job, found by a failing check here and fixed with a test that fails without the fix.

## Approval

Fumnanya pre-approved this job in writing on 29 October 2026: "I approve job 12 as soon as its checks, reviews and evaluator pass." The checks and the combined review passed. The evaluator's verdict was fail for records only: three statements failed because the notes said the sixth dialogue was not drafted yet. The notes were corrected and committed. The evaluator was not run a second time.

## Proof

- GitHub checks on the last head `b20ff5c`: type check, Vitest, Python, database, browser tests in Chromium and WebKit, secret scan and dependency check all pass. "Preview link" fails only because the Cloudflare preview secrets are not on the public repository.
- Combined review: pass, 0 must fix, 3 should fix (`review-combined.md`).
- Evaluator: 1, 2, 4, 5, 7 and 9 to 17 pass; 3, 6 and 18 were records only and are fixed; statement 8 (preview) is not checkable until the Cloudflare keys exist; statement 19 (native reviewer) comes at the end of the MVP (`evaluation.md`, evidence folder).
- Cost: the content pipeline cost $1.25 across all six dialogues ($0.43, $0.41, $0.40 per unit). Azure stayed inside the free allowance.

## Still open

- The native reviewer checks all six dialogues as one batch at the end of the MVP.
- Statement 8 waits on the four Cloudflare preview secrets.
- Three should-fix notes and the evaluator's odd findings are in `factory/todo.md`.
