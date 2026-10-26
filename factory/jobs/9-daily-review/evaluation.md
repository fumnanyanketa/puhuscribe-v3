# Evaluation: 9-daily-review (Daily review, Keep it)

Tested on 26 October 2026 at commit `d901807`, built from the worktree with `VITE_DESIGN_REFERENCE=1 npm run build` and served by `npx vite preview` on port 4719. Local Supabase ran from a scratch copy of `supabase/` (project `puhu9eval`, ports 553xx) with every migration and `supabase/seeds/browser/*.sql`. Playwright Chromium (`/opt/pw-browsers/chromium`, build 1243) at 375 x 812. Two guest learners: A (`790920d1...`) and B (`4cd7779e...`). "A day later" moved each learner's card times back 24 hours, as the spec defines. Test data only.

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `pgtap-run.txt`, `6-11-13-db-learner-A.txt`, `4a-first-day-front-door.png` | `daily_review.test.sql` ok. In the app, cards made today waited; after a day later, 12 cards came up oldest due first; the draft form never got a card; the cap of 15 held with 17 reviewable (`7-review-only-1.png`, "Word 1 of 15") |
| 2 | pass | `pgtap-run.txt`, `5-next-review-*.png` | pgTAP ok. Front door gave later today, tomorrow, Saturday 31 October and Monday 2 November correctly from the database dates |
| 3 | pass | `3-withdrawn-form-skipped.txt`, `vitest-run.txt` | Lines picked by the stated order (form 3 got line 3, not line 1). A form set back to draft dropped out of the items and its answer got 404 with no log row |
| 4 | pass | `4a-first-day-front-door.png`, `4b-day-later-dialogue2-ready.png`, `4c-review-only-front-door.png`, `5-empty-day-later-today.png` | All four states with the exact wording, one button, no count; "Continue today's session" shown for an unfinished session of either kind |
| 5 | pass | `5-empty-day-later-today.png`, `5-helsinki-boundary.png`, `5-helsinki-boundary2.png` | Wordmark, heading, both sentences, no button or extras. 23:59 Helsinki gave "tomorrow", 00:01 gave "Wednesday 28 October" |
| 6 | pass | `run2-end.png`, `6-finish-after-keep-it.png`, `6-11-13-db-learner-A.txt` | "Keep it, step 3 of 3" with cards; first session read "step 1 of 2". Row stored `step_reached = keep` and `ended_at`; Continue after Understand it resumed at Keep it |
| 7 | pass | `4c-review-only-front-door.png`, `7-review-finished.png`, `7-db-review-only-session.txt` | "Keep it, step 1 of 1", one row with empty `dialogue_id`, reused after leaving, ended with `keep`, no new usage event. Finish screen text and Done exactly as specified |
| 8 | pass | `8-prompt.png`, `8-9-20-keyboard-audio.txt` | Instruction, gloss, speaker, gapped `lang="fi"` line, gap read as "missing word", "Word 1 of 12". Items response held no gap text, no form shapes, no other register. Audio requested only on press, at `/audio/<key>` |
| 9 | pass | `9-a-button-enter.png`, `9-keyboard-a-button-enter.png`, `8-9-20-keyboard-audio.txt` | All attributes present, maxlength 100. ä and ö insert at the cursor and focus returns to the field (mouse and keyboard). Check disabled while empty; Enter submits |
| 10 | pass | `10-16-api-probes-learner-B.txt`, `vitest-run.txt` | Extra field (rating, userId), 101 characters, kind spoken, missing kind and a text form id all 400. Typing the written shape into a spoken prompt counted correct; "Helsingissa" close; extra spaces and punctuation correct |
| 11 | pass | `6-11-13-db-learner-A.txt`, `11-fsrs-replay-learner-A.txt`, `10-16-api-probes-learner-B.txt` | Ratings 3, 1, 2 logged with mode `typed`. Replaying v2's FSRS from each stored `review_time` matched every card. Three parallel identical answers gave 409, 200, 409 and one log row. pgTAP ok |
| 12 | pass | `12-correct.png`, `12-close.png`, `12-wrong.png`, `12-dont-remember.png` | Exact status texts, both registers with both play controls, word marked in both lines, shapes and "You wrote". No red, score, "wrong" or "incorrect" |
| 13 | pass | `13-retry-one-more-try.png`, `6-11-13-db-learner-A.txt` | Close and wrong items came back once after the others as "One more try at this word.", saved a second log row, never a third time in the UI |
| 14 | pass | `14-continue-front-door.png`, `14-resumed-keep-it.png` | After 5 answers, direct load, reload and Continue all showed "Word 1 of 7"; answered cards did not repeat |
| 15 | pass | `vitest-run.txt` | `[review 15]` tests pass (second method renders); only typing shows in the app |
| 16 | pass | `10-16-api-probes-learner-B.txt` | 401 signed out; 404 for A's session from B and for a random id; 405 for GET and PUT; 403 other origin; 415 text/plain |
| 17 | pass | `17-18-db-checks.txt`, `10-16-api-probes-learner-B.txt` | Draft line and draft form absent from items and answers (the draft form token carries no card). Typed answers in no table and no Worker log line; no cookie, token or user id in the log |
| 18 | pass | `17-18-db-checks.txt`, `pgtap-run.txt` | One migration, three functions, invoker, `search_path=""`, execute for authenticated only. Regenerated types are identical. Red run linked in `build.md` |
| 19 | pass | `v2-hashes-worktree.txt`, `vitest-run.txt` | `grade.ts` and `fsrs/*` unchanged from main; `tests/v2-imports.test.ts` passes. Settings change recorded in `docs/v2-imports.md` |
| 20 | pass | `20-axe-sizes-overflow.txt`, `20-light-*.png`, `20-dark-*.png` | axe: 0 violations in light and dark on front door, item and feedback. No sideways scroll at 320 px or 320 px with 200 percent text. Whole review done by keyboard |
| 21 | pass | `build.md`, docs | `[review N]` row, data model section, README €0, no new package, check minutes recorded |

## Failures

None.

## Odd but not failures

- The branch head moved to `667da4d` while I was testing (16:02 UTC): it raises wrangler and the Cloudflare Vite plugin and pins `miniflare` to a beta (`5.20261023.0-beta`) through `overrides`. That is not in `build.md`, which says the job changes no package, and I did not test that commit.
- The answer route grades any card the learner owns, even one already reviewed today or outside the run. A second tab answered the same item with 200 and wrote a second log row, and a scripted third answer was also accepted. Only the screen enforces "once per day, one retry". This only touches the learner's own data (the spec already accepts that risk), but analytics should not trust log counts.
- "Close. Check the spelling below." appears in the bottom bar, while the word it refers to is shown above it.
- Tappable words in the feedback lines (job 8's `FinnishLine`) are 44 px tall but can be 32 to 43 px wide. axe passes, and the inline text exception probably applies.
- The approved line "Mist sä oot kotoisin?" shows the draft form's word "kotoisin" as plain text with no card. This is job 8's content rule, not a leak of the draft form.
- Write routes accept a request with no Origin header (job 8's `sameOrigin`, unchanged here).
- Postgres prints floats with 15 digits, so the card values match the engine replay to within 1e-9 rather than exactly.
- I did not run WebKit (not installed) or record a video (the recording came out empty). In my run, `content_publish.test.sql` failed 2 tests only because I loaded the browser seed before `supabase test db`. Every other pgTAP file passed, and Vitest passed 704 tests.

Result: pass
