# Build notes: 7-content-pipeline

Builder. Branch `factory/7-content-pipeline`, draft pull request https://github.com/fumnanyanketa/puhuscribe-v3/pull/17. Spec label `[content N]`.

## Round 2 (21 October 2026), tip `cc90a75`

Started from the design review (`review-design.md`, two must-fix), the security review (`review-security.md`) and the manager's list of cheap should-fix items.

- **Merged main** (job 6) into the branch with a merge commit (`6600da0`), no rebase. The only conflict was the header comment of `.github/workflows/checks.yml`; both jobs' spec lines are kept. My Python and database additions sit unchanged inside job 6's new workflow shape, and job 6's workflow tests pass.
- **Must-fix 1, "Not yet".** A reviewer who marks anything Fix or Sounds wrong now answers "Not yet" for the dialogue and can download. "Not yet" with nothing to change is refused on the page and on import, so no file has to carry a false approval. The next round always asks about the dialogue again. Tests: pytest (accepted with a fix, accepted with a wrong clip, refused with nothing to change) and Playwright (refused, then downloaded after a Sounds wrong).
- **Must-fix 2, long words.** `overflow-wrap: anywhere` on headings, paragraphs, list items, legends and labels. The fixture now holds a 61 letter compound, and a Playwright test at 375 px checks the page does not scroll sideways. Broken on purpose, the page was 622 px wide and the test went red (`evidence/r2-break-13-long-word-overflow.txt`).
- **Security.** No published text may hold `$publish$` (refused by the publish preconditions and by `sql_text`). Words reach RAISE messages as `%` parameters, so `vaa'an` cannot break the SQL. A clip path must be exactly `audio/<line>-<register>.mp3`, both when the page is made and when publishing. `next-round` and `publish` run `validate_brief` on the draft's brief again before reading or writing anything.
- **Design.** Finnish text and the corrected-Finnish boxes carry `lang="fi"` (the English box does not). Each pair of choices is a fieldset whose legend names it, for example "Line 1 spoken audio, the sound only" and "Line 1: is the Finnish text and its English meaning right?". The intro says Approve and Fix cover the text and its meaning, the sound has its own choice, and closing the page before downloading loses the work.
- **Docs.** The two colon reveals in `docs/content-attribution.md` are gone. The cost is about $0.25 per dialogue in both the README and `docs/content-pipeline.md` (which now adds up to that). The pipeline doc says the page is tested in the Chrome and Safari engines only, and explains "Not yet".
- Every other finding of both reviews is left for `factory/todo.md` (the manager adds them), including: publish not re-running `read_round`, `forms.analysis` outside the checks and the fingerprint, pinning the pipeline's indirect Python packages with hashes, tap targets, a progress count, dark mode, clip pausing, plain item names in messages, the "why" wording and the reviewer code wording.
- The Python count guard went from 130 to 138 for the 8 new pytest tests. No test was removed. One existing expectation changed with the behaviour it tests: a dialogue with no decision now reads "the dialogue as a whole has no decision (approve or not yet)" instead of "is not approved".

Round 2 checks:

- Local: `npm run check:code` passes; `npx vitest run` 29 files, 483 tests pass; `npx playwright test e2e/review-page.spec.ts` 16 pass (Chromium and WebKit); ruff check and format pass; pytest 129 pass with recorded Voikko readings (local only; see round 1 for why).
- GitHub, PR 17 at `cc90a75`: every check passes, including the preview (run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39665439419). Python ran 138 tests with real Voikko, none skipped (`evidence/r2-ci-pr17-python.txt`). The run for `d060806` was cancelled by the newer push, as the workflow intends.

## Earlier rounds

- **Round 1**, tip `9e834ef`, run https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/39658000512, all green (the preview job's first attempt hit its 15 minute limit installing browsers; the re-run passed). Built the whole pipeline: providers and cost log, the checks, the draft loop, the review page and import, publishing, the manual workflow, the pgTAP fixture and the docs. Proof: `evidence/ci-pr17-python.txt` (130 tests, real Voikko, none skipped), `evidence/ci-pr17-database.txt`, `evidence/13-review-page-fixture.png`, and the break tests `evidence/break-07-word-validity.txt`, `evidence/break-11-stale-judge-verdict.txt`, `evidence/break-13-review-page-innerhtml.txt`, `evidence/break-15-publish-unapproved-item.txt`. Voikko does not install on Windows, so local pytest ran with readings recorded from the GitHub runner (a scratch folder shim, not in the repository); GitHub is the real proof.

## What the job built (all rounds)

- `scripts/generate/`: the pipeline (brief, analysis, checks, drafting, judge, audio, review page, review import, publish, command line) and the two provider modules `providers/ai.py` and `providers/voice.py`, each with an offline fake, every call logged with its cost in `content/logs/ai-calls.jsonl`.
- `.github/workflows/content-pipeline.yml`: manual start only, tasks `draft` and `next-round`, keys only in the pipeline step and the upload guard.
- `.github/workflows/checks.yml`: content checks on committed drafts with the network off, the raised count guard, every publish migration run a second time, pip-audit on the pipeline packages.
- `content/briefs/meeting-people-new-colleague.json` (unit 1's first dialogue), `content/checks/thresholds.json`, `content/checks/judge-golden-set.json`, READMEs for drafts, reviews, recordings and logs. `content/reviews/` holds no approval.
- `supabase/tests/database/content_publish.test.sql`, `scripts/ci/check-published-audio.ts`, `tests/content-audio.test.ts`, `tests/content-pipeline-workflow.test.ts`, `e2e/review-page.spec.ts`.
- Docs: `docs/content-pipeline.md`, `docs/content-attribution.md`, and updates to `docs/conventions.md`, `docs/data-model.md`, `.env.example` and the README running costs.
- No table, column, type, rule, grant or function added.

## Tests per "done when" statement

Python tests carry the label at the start of their docstring (`scripts/generate/test_content_*.py`); TypeScript and pgTAP tests carry it in the test name.

| Statement | Tests |
| --- | --- |
| 1 brief | `test_content_brief.py` (unit 1 brief from PRD section 6; each of 15 missing fields refused; line count, voice, grammar ids) |
| 2 one run | `test_content_drafting.py` (loop in one round; rejected word named in the redraft; 3 rounds then a plain failure list; `run` writes draft, report, 12 clips, page, log and cost lines; failing run makes no pack); `tests/content-pipeline-workflow.test.ts` (manual only, inputs checked and passed as env, keys only in two steps, no npm, secret guard before upload) |
| 3 AI module | `test_content_providers.py` (only ai.py imports anthropic; AI_PROVIDER; fake replays in order) |
| 4 cost log | `test_content_providers.py` (one call, one line, table cost, no key or prompt text; unusable answer still logged; price table dated and cited) |
| 5 voice module | `test_content_providers.py` (only voice.py calls a voice service or the network; XML escaping with <, & and quotes; EU endpoint, voice, mp3 24 kHz 48 kbit; non-EU, unpriced tier, no key refused; each synthesis logged) |
| 6 native recordings | `test_content_drafting.py`, `test_content_review.py` (recording replaces the clip, page marks it, "sounds wrong" moves on only once it exists) |
| 7 word validity | `test_content_checks.py` (planted invented word, real Voikko) |
| 8 spoken links | `test_content_checks.py` (missing and doubled links; spoken only words listed, no form) |
| 9 level fit | `test_content_checks.py` (out of level word, out of list form, names exempt, a common word cannot pose as a name); `test_content_tags.py` (grammar list rules) |
| 10 grammar cards | `test_content_checks.py` (tag not a Voikko reading; reading number outside Voikko's; name not the table's; unknown Voikko value; why too long, line break, foreign term, empty); `test_content_tags.py` |
| 11 register faithfulness | `test_content_checks.py` (a "differs" verdict fails; a change after judging fails). Golden set: `content/checks/judge-golden-set.json`, `scripts/generate/judge.py`; the real run waits for the key (below) |
| 12 thresholds on every PR | `content/checks/thresholds.json`; `tests/content-pipeline-workflow.test.ts` (check-committed under `unshare --net`, guard raised with v2's 9 required) |
| 13 review page | `test_content_review.py` (self contained, CSP hashes, every item shown, text escaped, clip paths only `audio/<n>-<register>.mp3`, fixture page current); `e2e/review-page.spec.ts` (Chromium and WebKit: no network, `<script>` printed not run, choices shown, download refused until complete, download carries fingerprints, "Not yet" with a fix downloads, named groups and `lang="fi"`, a 61 letter compound wraps at 375 px) |
| 14 review import | `test_content_review.py` (12 refusal reasons, including "not yet" with nothing to change; "not yet" with a fix or a wrong clip accepted; a broken brief in next-round refused; fixes applied and only changed items in round 2; refused file writes nothing; all approved means ready) |
| 15 publishing | `test_content_publish.py` (migration, keys, refs, order; 7 missing preconditions each write nothing; `$publish$` in a gloss, a clip path outside the folder and a broken brief refused; words passed to RAISE as parameters; fake content refused; later round refs; SQL quoting) |
| 16 published content reads correctly | `supabase/tests/database/content_publish.test.sql` (23 pgTAP tests, the fixture now with a 61 letter word: fixture publish twice, learner reads, draft line hidden, re-approval of unit and form), generated by `scripts/generate/fixture_outputs.py` and kept current by `test_the_committed_pgtap_publish_test_is_current`; second run of every `*_publish_*.sql` in the database check |
| 17 audio only for approved lines | `tests/content-audio.test.ts` with `scripts/ci/check-published-audio.ts` (stray file, hash mismatch, missing file; nothing from `content/` in the app) |
| 19 shape untouched | `tests/content-audio.test.ts` (no DDL or grant in publish SQL; no AI or voice call in `src/` or `worker/`); the database check's types diff |
| 20 docs | `tests/agents-md.test.ts` keeps every path in `docs/conventions.md` real |
| 21 token order | `test_content_checks.py` (out of order words, a dropped word) |

Break tests, each protection broken on purpose and its test seen red: `evidence/r2-break-13-long-word-overflow.txt` (round 2), `evidence/break-13-review-page-innerhtml.txt`, `evidence/break-07-word-validity.txt`, `evidence/break-11-stale-judge-verdict.txt`, `evidence/break-15-publish-unapproved-item.txt`.

## Waiting on the owner (for the manager to ask; not asked in chat)

Owner's decision: the reviewer approves all Finnish at the end of the MVP, so `content/reviews/` holds no approval and no review file was faked. These statements are not met yet:

- **Keys (owner's calls 1 and 2).** The manager should ask the owner to:
  1. create an Anthropic API key for v3 with a monthly spend limit and set it with `gh secret set ANTHROPIC_API_KEY`;
  2. Azure: a main commit while I built says the Speech resource now exists (Italy North, free F0). The pipeline needs `gh secret set AZURE_SPEECH_KEY`, `gh variable set AZURE_SPEECH_REGION` with `italynorth`, and `gh variable set AZURE_SPEECH_TIER` with `F0`. `italynorth` is on the pipeline's EU region list. I did not verify that Italy North offers the fi-FI neural voices; the first run shows it (a refusal names the HTTP status). A paid tier would first need its price per character in `PRICE_PER_CHARACTER` in `scripts/generate/providers/voice.py`; the pipeline refuses an unpriced tier on purpose.
- **Statement 2, the real run:** the workflow is built and tested on fakes; a real run of the unit 1 brief waits for both keys. GitHub lists a manual workflow only once its file is on main, so the first real run happens after merge: `gh workflow run "Content pipeline" -f task=draft -f target=content/briefs/meeting-people-new-colleague.json`.
- **Statement 11, the golden set proof:** waits for the Anthropic key: `AI_PROVIDER=anthropic python scripts/generate/pipeline.py judge-golden --out factory/jobs/7-content-pipeline/evidence/11-judge-golden-set.json` (Linux, or add a task to the workflow). The golden set's Finnish was written by me and should be shown to the reviewer once.
- **Statement 17, preview playback:** pending the reviewer: there is no published audio yet, so nothing plays at `/audio/<key>`.
- **Statement 18:** pending the reviewer and the keys (moves to the end of MVP batch per the owner's decision).
- **Statement 16 for unit 1 itself:** the pgTAP reads cover every published dialogue generically and a fixture dialogue concretely; unit 1's own rows wait for its publish migration (pending the reviewer).

## Uncertain or not done

- The review page is tested in Chromium and WebKit (the project's Playwright browsers). Firefox was not tested.
- The re-publish flow for a line that is already published (data model step 2, set back to draft and approve again) is not built; the publish migration refuses a dialogue that already has lines. Fixing before publishing works through the review rounds.
- The judge golden set and the drafting prompts have not met the real model yet; the first real run may need prompt changes.
- `docs/content-attribution.md` flags that `data/finnish_frequency_lemmas.json` comes from wordfreq, not Leipzig as v2's file said. Not checked with a lawyer.
- pytest labels sit in docstrings because Python test names cannot hold brackets; `docs/conventions.md` says so.
- gitleaks did not flag the 64 character fingerprints.

## How to run it locally

- Fast checks: `npm run check:code`, `npx vitest run`.
- Review page browser test: `npx playwright test e2e/review-page.spec.ts` (needs no server if `PLAYWRIGHT_BASE_URL` is set to any address).
- Python tests need Linux with Voikko: `sudo apt-get install -y libvoikko1 voikko-fi`, `pip install -r scripts/requirements.txt -r scripts/requirements-dev.txt -r scripts/requirements-pipeline.txt`, then `python -m pytest scripts/generate`.
- Make the fixture files again after changing the review page or the publish SQL: `python scripts/generate/fixture_outputs.py`.
- See Voikko's readings of a word: `python scripts/generate/show_readings.py olen`.
- Everything else: `docs/content-pipeline.md`.

Result: checks pass
