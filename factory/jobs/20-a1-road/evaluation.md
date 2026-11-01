# Evaluation: job 20-a1-road

Evaluated head `91da275` on branch `factory/20-a1-road`. Spec first, `build.md` read only after testing.

How I tested. This job builds no screen, so there is nothing to drive in a browser at 375 x 812. The browser statements are covered by the existing Playwright suite, whose result I read from the last full GitHub run (https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41341321317, head `91da275`, all jobs green: pgTAP 1,087 tests, Python 308 tests with no skips, Vitest, Playwright 422 passed and 2 passed in the no content pass, gitleaks, dependency check). Locally I ran Vitest (1,106 passed; 2 failures in `scripts/hooks/commit-tool.test.ts` are 5 second timeouts of the gitleaks tests on this slow Windows machine, they pass on GitHub and have nothing to do with this job), the Python tests that do not need Voikko (205 passed, 94 skipped because Voikko only exists on GitHub), the importer's offline commands, and four skeptic harnesses of my own whose outputs are in `evidence/`. No `.env*` file was read, no debug files kept, no code edited. Real Voikko could not run here, so the three skeptic tests of the publisher ran with the Voikko check stubbed to "ok" so that only the rule under test could refuse (stated again where it matters).

## Results by statement

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `evidence/1-2-road-load-generator-check.txt` | `road_sql.road_sql()` output equals the committed `20261101120100_load_road_stops.sql` byte for byte. 6 parts, 36 stops. Stop 4 is "Numbers, prices and paying", part 1 is "First words". Slugs of stops 1 to 3 kept. Tables allow numbers past 6 and 36 (no upper check). |
| 2 | pass | GitHub run 41341321317 pgTAP step | `units.stop_number` unique, equals position, fixtures keep it null. Red proof for the equality check in `evidence/red-proofs.txt` (d6). |
| 3 | pass | same run; "committed types match the migrated database" step green | Both texts exist, approval needs both, checks for 60 characters and control characters. Frozen test now covers both columns. I read the migration; I did not re-break it. |
| 4 | pass | same run; `evidence/red-proofs.txt` d1, d2 | Revokes, grant to `authenticated` only, row level security, one policy per table. Red proofs name only their own tests. I did not repeat the breaks myself. |
| 5 | pass | pgTAP `a1_road.test.sql` green; `evidence/red-proofs.txt` d2, d3 | `road()` is `security invoker`, empty search path, 14 columns, all 36 stops, counts only. Two learner tests and the "goes red if made `security definer`" test exist and went red when broken. |
| 6 | pass | same | `stop_review_forms` requires a card and a finished session that contains the form, first met in the stop. Cases for met, unmet, earlier stop, other learner exist in pgTAP. |
| 7 | pass (with statement 29 replacing the 401 wording) | `evidence/29-visitor-road-skeptic.txt`; `worker/road.test.ts` 12 tests pass | 14 keys only, 503 with no detail, POST refused (405, no database call). |
| 8 | pass | `evidence/8-parse-skeptic-refusals.txt` | On a copy of the markdown, an empty cell, a stray pipe, a swapped line number, a missing **I can:** line and a 7 line dialogue were each refused with file, stop, dialogue and line named. Unchanged markdown parses to 36 stops. A `<script>` tag in a cell is accepted as plain text (escaping is at display and publish). |
| 9 | pass | Python run, brief tests unchanged; diff of `content/road/stops.json`, `speakers.json` | Existing brief tests unchanged and green. `source` field added. Speakers file present. |
| 10 | pass | run 41341321317; `evidence/12-register-line-sample-40.txt` | 108 drafts. 102 carry `{"ai": "written", "judge": "on"}` (the owner chose the judge on), 6 are the earlier AI drafts. Pytest runs the importer offline with no key. |
| 11 | pass | Python tests green (planted failures per rule); `content/road/road-report.md` | `spoken_pairs` 3,868 items at rate 1.0000. 263 accepted pairs in `spoken-forms.tsv`. 40 line sample (`evidence/12-register-line-sample-40.txt`) reads as natural spoken and written pairs; I found no swapped meaning. |
| 12 | pass | `check-committed` step green with "passes every check" for each draft; `git diff main...HEAD -- content/checks scripts/generate/content_checks.py` is empty | All six check families at 1.0000 on the road. `thresholds.json` and `content_checks.py` are untouched. See odd item 2 about how the 1.0000 was reached. |
| 13 | pass | `content/road/allowed-extras.json`, report | Largest extras list for any stop is 15 base forms. Caps 2000, 2000, 2000, 2500, 2500, 1500. Parts 4 and 5 are at 2500 because the rule's own result needed it (disclosed in `build.md` round 3, manager's decision). Report prints extras per part. |
| 14 | pass | `content/road/fixes.md`, `git diff --stat` | No threshold, check or existing test changed. Departure: 135 hand written Voikko readings and 8 list aliases are road files with their own reasons, not rows of `fixes.md` (disclosed). |
| 15 | pass | `content/logs/ai-calls.jsonl` (119 judge rows); run log | Judge on for all 816 new lines, each with a verdict and fingerprint, 0 unfaithful. 119 judge calls logged (golden set included), total judge cost $0.66, under the $2 stop. Pytest covers off, on, on with a missing verdict. |
| 16 | pass, with one departure | `evidence/16-word-card-sample-30.txt`, `content/road/needed-notes.tsv` (empty) | 1,332 forms, 767 dictionary forms, every form has both meanings and a why; 0 empty, 0 over 60 or 140 characters, 0 dictionary form with two meanings. Lemma rule: `noi` shows `nuo`/`tuo` as the spec says. Departure: the same form id does not carry the same why in every draft (22 forms, see odd item 3). Sample of 30: no outright wrong row, 2 small doubts (odd item 4). |
| 17 | pass | pytest `test_a1_road_17_*` green | Earlier 6 drafts keep their lines, tokens, why lines and 72 clips (hash tests). |
| 18 | pass | `evidence/18-count-characters.txt` | Offline `count-characters` prints 51,077 for the road (parts 7,075 / 8,322 / 8,897 / 8,450 / 9,174 / 9,159), far under 450,000. This month's logged voice use is 507 characters. Fake clock tests for 20 per minute, retry, skip and refusal pass. The Azure key reaches only the voice step. A real Azure call was proven only on the one sample dialogue (`a-new-neighbour`, 16 clips). |
| 19 | **fail** (one clause), and the workflow itself cannot be proven yet | `.github/workflows/a1-road.yml` lines 60, 67, 71, 146 | The statement says "actions pinned to a full commit". The file uses `actions/checkout@v7`, `setup-python@v7`, `setup-node@v7`, `upload-artifact@v7`, the same as `content-pipeline.yml`. `build.md` lists this under "not changed" and not as a departure. Also, `gh run list --workflow a1-road.yml` answers 404 because the workflow is not on `main`, so it has never run; every import, judge and voice run so far went through a scratch workflow. 101 of the 102 new dialogues have no audio yet (`content/drafts/*/audio` exists only for the 7 voiced drafts), so the 15 minute per part voice run and the real audio size are untested. |
| 20 | pass | `evidence/21-publish-skeptic-refusals.txt` | See the skeptic section. Each refusal named its reason and wrote 0 migrations and 0 clips. The fingerprint is wider than the spec says (departure 1 in `build.md`, accepted below). |
| 21 | cannot prove yet | `evidence/21-publish-skeptic-refusals.txt` (control row) | The publisher works on a real draft: control run wrote one migration with explicit timestamp `20261102000200`, 16 clips copied, forms, unit from `road_stops`, "already published, nothing to do" guard at the top. The 108 migrations, the match test against them and the total size do not exist until the manager adds approval files. The 88 MB estimate (41 MB drafts + 41 MB public + 5.8 MB SQL) is built from 25 KB per clip of one sample, close to the 100 MB stop line. |
| 22 | cannot prove yet | `supabase/tests/database/a1_road_published.test.sql` | The file is generated from the approval files; today its counts are all 0 (0 stops, 0 dialogues, 0 lines, 0 live), so it only proves that nothing is readable and that a draft line is not readable. It cannot yet prove 36 / 108 / 852. |
| 23 | pass | run 41341321317; `worker/row-cap.test.ts` 8 tests pass locally | Reads are paged (`worker/paging.ts`, page 500). A red proof for removing paging exists in the round 1 notes. Existing assertions untouched; only fixture inserts of pgTAP files gained the two meaning texts and schema lists gained the new tables and columns (I read the whole diff of removed lines). The browser step "Hide the road's units" ran green, but with no road unit published it hides nothing yet, so the real regression is only provable after publish. Hosted row cap not checked (as the spec says). Browser result: 422 passed, 31 skipped; I did not compare the skipped count with `main`. |
| 24 | pass | pgTAP `a1_road_fix.test.sql` green; `test_a1_road_24_*` | `pipeline.py road-next-round` exists. Not run end to end on a real review file because none exists. |
| 25 | pass | `test_a1_road_25_*` green | Review pages show both meanings next to name and why. |
| 26 | pass | `python scripts/generate/log_costs.py` output | Road totals per part print (part 1 shows 2,424 characters because the October sample is counted). No Anthropic call from the import. |
| 27 | pass | `.gitattributes` lines 29 to 32; `docs/data-model.md` line 150; `docs/content-pipeline.md` line 63; `docs/conventions.md` line 67; README rows 99 and 100 | All present. |
| 28 | open (owner's) | n/a | See "What the owner will need to do". |
| 29 | pass | `evidence/29-visitor-road-skeptic.txt`; `worker/road.test.ts`; `20261101120200_road_for_visitors.sql` | See the skeptic section. |

## Failures with steps to reproduce

**Statement 19, clause "actions pinned to a full commit".**
1. Open `.github/workflows/a1-road.yml`.
2. Lines 60, 67, 71 and 146 use `@v7` tags, not 40 character commit hashes.
3. Compare with the statement, and with the lesson in `AGENTS.md` about pinning actions that receive secrets (the voice and judge steps hold the keys in the same job; the upload step does not).
Fix is small (pin the four actions), or the manager amends the statement to say "same as the content pipeline". It is the manager's choice, not the builder's.

The same statement also has a part I cannot prove: the workflow has never run, because GitHub only runs a manual workflow that exists on `main`. Reproduce: `gh run list --workflow a1-road.yml --repo fumnanyanketa/puhuscribe-v3` answers HTTP 404. The first real run will happen after merge, on the manager's start.

## The three skeptic tests

1. **A draft with a missing note is refused by publish.** On a copy of the real voiced draft with approval made for that very text, a blank `meaning_en`, a blank `why_en` and an absent `lemma_meaning_en` each gave "1 word cards still miss a meaning or a why line", with 0 migrations and 0 clips written. The control (approved, complete) published. (`evidence/21-publish-skeptic-refusals.txt`. The Voikko check was stubbed here so that only the note rule could refuse.) Passes.
2. **A visitor reading the road gets zero progress and no cookie.** I fed the Worker a database that lies, returning full progress and an extra `user_id`. With no cookie and with a garbage cookie, `GET /api/road` answered 200, the 14 keys only, `dialogues_done`, `review_forms_reviewed` and `lessons_done` all 0, `Set-Cookie` null, `user_id` gone, and the only outgoing call was `POST /rest/v1/rpc/road_for_visitors` (no Auth call, no write). A POST was refused with 405 and no call. (`evidence/29-visitor-road-skeptic.txt`.) Passes.
3. **A swapped audio hash after approval is refused.** Swapping the bytes of a clip without touching `draft.json` gave "the audio file audio/3-puhe.mp3 changed after it was made". Swapping the bytes and also rewriting the hash in `draft.json` gave "dialogue a-new-neighbour changed after the owner approved it: its fingerprint differs". A changed line text, a clip from the fake voice, a judge state that differs from the approval, an empty approval line with a bad date, and a missing approval file were each refused too, all with nothing written. Passes.

## Departures in build.md: honest and acceptable?

- **Fingerprint wider than the spec (statement 20).** Honest, and better: it also covers speakers, both clip hashes and the word links. Consequence for the owner: re-voicing a line after approval voids that dialogue's approval, so approve after voicing. Accepted.
- **Voice log must be committed before the next voice run (statement 18).** Honest, process rule documented. Accepted.
- **135 manual readings (build.md says 133 in one place, 135 in another; the file has 135 rows, I counted) and 8 list aliases.** Disclosed in `build.md` and flagged by the security review as widening Voikko's check. This is the biggest softening of "Voikko knows every written word": for those spellings the importer accepts a reading a person wrote. Acceptable only if the owner reads `content/road/manual-readings.tsv` before approving, as the security review advises. I rate it acceptable, with that condition.
- **Parts 4 and 5 at rank cap 2500.** Honest, follows the rule.
- **The six earlier drafts disagree on the why line of shared forms.** Disclosed as 25 forms in round 1; today I count 22. See odd item 3.
- **Builder reports "Actions are pinned by tag like the other workflows" under "not changed".** It is a real mismatch with statement 19 and should have been listed as a departure. Not accepted as written (see the failure).
- Tests of earlier jobs were changed only for setup (the two new meaning texts, the new tables and columns in table lists). I read every removed line in `e2e`, `tests`, `*.test.ts`, `scripts/generate/test_*.py` and `supabase/tests`. No assertion weakened.

## Word card data: sample of 30 and glossary

`evidence/16-word-card-sample-30.txt` holds 30 random forms (fixed seed) with the first dialogue line each appears in. I checked each meaning, dictionary form meaning and why against the line:

- 28 of 30 are right and read well for a beginner. The spoken to written explanations are correct (`kattoo` for `katsomaan`, `tultiin` for `tulimme`, `ilmanen` for `ilmainen`, `eiks` for `eikö`, `tos` for `tuossa`, `sun työpiste` for `työpisteesi`).
- Doubt 1: `rikkaus` has the dictionary meaning "wealth, a gift". A gift is not a sense of `rikkaus`; the English line "Two languages are a gift" is idiomatic, but the dictionary card should say wealth or richness.
- Doubt 2: `kaukana` shows the dictionary form `kauas` (Voikko's base form, a different adverb: "to a far place"). It is Voikko's own answer and follows the lemma rule, but a learner will see an unfamiliar word as the dictionary form.
- Glossary: 30 random rows of 767 (`content/road/glossary.tsv`) are all correct (for example `kallis` expensive, `juotava` something to drink, `vaikka` for example, say, although). Its meanings are consistent with the forms: no dictionary form has two different meanings across drafts.
- Whole road checks I ran on all 1,332 forms: no empty text, no meaning over 60 characters, no why over 140, no dash punctuation, one meaning per dictionary form.
- The 40 line register sample (`evidence/12-register-line-sample-40.txt`): spoken and written versions agree in meaning on all 40. One wording doubt: `tohtori` used for a doctor in `at-the-doctors` line 8 is rare in everyday Finnish (`lääkäri` is usual); it is not wrong.

## Odd, not failures

1. 101 of the 102 new dialogues have no audio yet, and `a1-road.yml` has never run. Both are expected before the manager starts voicing, but statement 28's "owner hears five dialogues" depends on them.
2. Every check family is at exactly 1.0000. That is true by construction: failures were repaired in Claude's own markdown, and anything Voikko could not read got a hand written reading. The rates therefore show that the text now passes, not that Voikko independently liked it. The owner should weigh them with the manual readings file in mind.
3. For 22 forms the why text in the six earlier AI drafts differs from the road's text (for example `mä`, `kyllä`, `onko`). The publisher inserts forms with `on conflict do nothing`, so the first published dialogue's text is the one stored, and a later dialogue's differing text is dropped silently, while each dialogue's approval fingerprint covers its own text. For the first stop this is the earlier draft's AI text. The spec's "one form id carries the same texts in every draft" test is in practice a test that the id equals the identity hash, plus a separate check that meanings agree. Worth deciding before publishing: which text should win.
4. The publish timestamps start at `20261102000000`. Any migration that job 19 or another job adds after that time but before the road is published would apply before the road's migrations, which is fine, but a later one that needs road rows must come after `20261102010700` (36 stops x 3 dialogues, one per minute).
5. The Worker visitor route makes one Auth call per request for a browser that still holds an ended session cookie (security review note 8). The visitor function scans approved tokens on each call (note 7). Neither is a data risk.
6. Local Vitest: the two gitleaks tests of `scripts/hooks/commit-tool.test.ts` time out on this Windows machine.
7. Browser run: 31 skipped tests, count not compared with `main`.
8. The judge found 0 unfaithful lines in 816. The judge is the same model family as the author, so a clean sheet is weaker evidence than it looks. The spec already says nothing replaces the native reviewer.

## What the owner will need to do (statement 28)

1. Listen to a sample (the spec says five dialogues) once the voices have run, and read the check numbers in `content/road/road-report.md`.
2. Read `content/road/manual-readings.tsv` (135 hand written readings) and `content/road/allowed-extras.json`, because they are where the automatic checks were widened.
3. Decide on the 22 differing why lines (odd item 3) and the two word card doubts.
4. Approve part by part, in his own written words, one line per part. The manager then adds `content/approvals/part-<n>.json`; nothing publishes without it, and it must be made after voicing because the fingerprint covers the clips.
5. After each part's migrations and audio are on the preview, the evaluator walks one dialogue of a stop from each part through Hear it, Understand it, Say it and the next day's review. Then `summary.md` carries the owner's own "approved" line with the date (GA).

Result: fail
