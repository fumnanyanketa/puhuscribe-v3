# Combined review (design, learner experience, security): job 12-units-1-3

Reviewed head `a55be3c` on branch `factory/12-units-1-3` (draft PR 6). Read: `AGENTS.md`, `factory/jobs/12-units-1-3/spec.md`, `factory/jobs/12-units-1-3/build.md`, `design.md`, and the diff against main. I read the code and the committed content. I did not run the app or the tests, so nothing below says a browser test passes today.

## Verdict

pass

## Must fix

None.

## Should fix

1. **Records are out of date for the sixth dialogue.** `build.md` (head `ec3588b`, "5 of 6", "What waits") and the table in `docs/content-pipeline.md` lines 159 to 168 still say `grocery-store-directions` was never drafted. The branch now holds that draft, its check report, audio (12 clips), review page and log lines (commits `2869c04`, `a55be3c`). Spec statements 3, 6 and 18 need the run id and the cost in these files. Fix: add the real run id of the sixth run and its cost, and update the unit totals. `python scripts/generate/log_costs.py` now prints unit 1 $0.43, unit 2 $0.41, unit 3 $0.40, total $1.25 (the docs say unit 3 is $0.12 "so far"). Also change `build.md` so the "5 of 6" rows say 6 of 6, and note that the builder's last check results (pytest 6 failures, Playwright `[units 7] [units 5]` failure) were taken before this draft existed and need a fresh run on this head.
2. **No fresh check run on this head.** The last GitHub run in `build.md` is `40395147531` on `9b603e3`. The sixth draft landed after it. Run pytest, `check-committed` and the Playwright review page test again and record the result. I could not confirm that the 193 test count in `.github/workflows/checks.yml` is right now that all tests can pass.
3. **Repeated "Spoken" and "Written" labels in the panel.** `src/components/PatternsPanel.tsx` lines 45 to 55 and 70 to 85 show the same two labels twice in every form (once for the word form, once for the example line). A screen reader user hears "Spoken ... Written ... Spoken ... Written" with only "Where you met it" between. Sighted learners can tell them apart by position. Fix: keep the visible words, and give each pair an accessible group name, for example `role="group"` with `aria-label="This form"` and `aria-label="The line where you met it"`. This stays inside the spec's text rule because group names are not shown.

## Notes

Design system and phone layout (`src/components/PatternsPanel.module.css`, `WordCard.tsx`):
- Every custom property used in the panel's CSS exists in `src/styles/tokens.css`. No raw colours. Fonts are the design system's (Poppins headings and Finnish lines, body font for the rest). No accent bars, eyebrows, gradients, glow, emoji or badge pills. The one icon is the close cross, which matches the word card's own close control.
- The panel follows the word card's sheet style: bottom sheet with `--radius-xl` top corners, `--shadow-3`, backdrop token, reduced motion fade. It wraps Finnish with `overflow-wrap: anywhere`. The Close button moves under the title when text is large. `e2e/patterns.spec.ts` has tests for 320 px and 200 percent text, 44 px tap areas, keyboard only, and axe in light and dark mode. There is no test with a 40 letter Finnish word in the panel (an AGENTS.md lesson from job 7). The CSS covers it, so this is only a gap in proof.
- The "Patterns you've seen" button on the word card is the quiet text button variant, under the facts, with `aria-haspopup="dialog"`. Without the prop the card is unchanged.
- Focus: the title and group headings take focus with the outline removed. That is correct for headings that are not controls, but a keyboard user gets no visible mark of where focus went after the panel scrolls to a group. The next Tab lands on a visible play control, so nobody gets stuck.
- If the answer holds no groups (for example a form without audio keys is skipped), the panel shows only the title and intro line with no message. Spec statement 13 limits the panel's text, so I did not ask for new wording. The builder could ask the manager whether one plain line is allowed.

Product rules:
- Panel text holds no counts, scores, due dates, "learned" labels or practice controls. It has no address, menu entry or session step; it opens only from a word card. Groups are by form name, not by word.
- The route, `worker/patterns.ts`, reads with the learner's token, writes nothing, ignores a session id that is not a plain id, and returns Finnish, "why", form names and audio paths only (`src/lib/patterns-types.ts` has no user id or scheduling data). A session id that is not the learner's is ignored by the existing database rules and by `metSessions`.

Learner experience across units 1 to 3 (I read the Finnish only for visible problems, not for correctness):
- All six drafts have 6 lines, a spoken and a written line for each, and both audio clips exist for every line (12 clips per dialogue, none missing). Each line has an English gloss. Each draft has a spoken text that differs from the written text where it should (for example "mä oon" next to "minä olen"), so the register labels look the right way round.
- Unit 1 is titled "Meeting someone at work", but its second dialogue is at a language café. A learner who sees the unit title on that dialogue may find it odd. The native reviewer or the owner can decide whether to retitle the unit.
- `ordering-coffee-paying`: the brief's situation says Daniel asks for a tea and a bun, but the dialogue is about coffee only, and the brief's extra word list holds "tee" and "pulla" that no line uses. The dialogue still teaches asking the price and hearing "neljä euroa", but the numbers 11 to 20 listed as extra words never appear. Spec statement 2 asks only that unit grammar shows up in at least one token, so this is allowed. The reviewer may want to see a higher price for the "1 to 20" can-do.
- `grocery-store-directions` line 2 holds three short sentences (about 60 characters). It wraps to two lines on a phone at the 34 character line width. Beginners may find it long. Worth flagging to the reviewer in the batch note.
- `content/review-batches/mvp-batch-1.md` lists the six pages in order with titles, the steps, the time estimate and how to send files back, and asks for a reviewer code, not a name. It follows the writing rules.

Security checklist:
- Keys and secrets. `git grep` for key shapes (Anthropic, AWS style, GitHub tokens) over `content`, `src`, `worker`, `e2e`, `scripts`, `docs` and this job's folder found nothing. No request header names (subscription key, authorization) appear under `content/`. The log lines in `content/logs/ai-calls.jsonl` hold only time, provider, purpose, model, token counts, cost and dialogue slug. I did not open any `.env*` file.
- Workflow. `.github/workflows/content-pipeline.yml` is not changed by this job. It passes `ANTHROPIC_API_KEY` and `AZURE_SPEECH_KEY` to the step that runs the pipeline, and again to the one guard step that scans the upload for those values. No other step has them, and no `npm ci` runs there. The only workflow change in the diff is the test count in `.github/workflows/checks.yml` (138 to 193), whose Python step strips both keys.
- Browser storage. The new files `PatternsPanel.tsx`, `PatternsProvider.tsx`, `patterns-context.ts` and `patterns-types.ts` use no localStorage, sessionStorage, IndexedDB or cookies. The panel's data is fetched fresh each time it opens and held in component state only.
- Third party scripts. The diff adds no `<script>`, no external address in `src/` or `worker/`, and no change to `package.json` or `package-lock.json`.
- No publishing. The diff touches no file under `public/`, no migration, no `src/lib/database.types.ts` and no pgTAP file. `content/checks/thresholds.json` and `scripts/generate/pipeline.py` are unchanged.

Result: pass
