# Summary: 12-units-1-3 (Units 1 to 3 content, Patterns you've seen)

Round 2, 26 October 2026. Flag: **look closely** (Finnish learning content, reads learner data). Stage: **blocked**, waiting on the owner.

## What is stuck

Five of the six dialogues were drafted by real pipeline runs and pass every automatic check. The sixth, `grocery-store-directions`, never ran: its run was refused on 22 October by the GitHub billing block. The content pipeline runs on main and needs the repository secrets, which do not exist on the public repository yet. Until that one run lands, the Python check and two browser tests (one per browser) stay red on pull request 6, and the job cannot finish.

## What the owner does

1. Add the repository secrets to `fumnanyanketa/puhuscribe-v3` (the five values from the archive repository, the Anthropic and Azure keys among them).
2. Tell the manager. The manager then starts one "Content pipeline" run from main for `content/briefs/grocery-store-directions.json` (about $0.25), commits its outputs and the run log, and the checks go green.

Nothing else is needed from you for this job right now.

## What is already done

1. Six briefs for units 1 to 3, with cumulative grammar lists proven by a test.
2. Five drafts with audio in both registers, review pages for the native reviewer, every call logged. Cost so far: $0.96 (unit 1 $0.43, unit 2 $0.41, unit 3 $0.12).
3. The "Patterns you've seen" panel: a card behind a tap on the word card, grouped by form, with the line where the learner met each form. Only the learner's own forms.
4. Security review: pass, 0 must fix, 2 notes. Design review: pass, 0 must fix, 3 notes (`review-security.md`, `review-design.md`, notes in `factory/todo.md`).
5. Builder notes: `build.md`. The evaluator has not run; it waits for the sixth dialogue.

## Still open after the run

- Statement 8 (evaluator on the preview, once a preview exists).
- Statement 16 (the full loop needs jobs 9 and 10 merged).
- Statement 19 (the native reviewer approves all six as one batch).
