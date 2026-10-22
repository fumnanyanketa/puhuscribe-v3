# Evaluation: 7-content-pipeline

Evaluator, 21 October 2026. PR 17, branch `factory/7-content-pipeline`.

**Which code was tested.** I was given head `9e834ef`. While I tested, the builder pushed round 2 (`d060806`, then `cc90a75` at 22:52). I tested `9e834ef` first, then ran every test again on `cc90a75`, the current head. This report is about `cc90a75`. Round 1 results are kept in `evidence/eval-at-9e834ef/`. I read `build.md` only after testing.

**How I tested.** I made a clean copy of each head with `git archive`, so nothing came from the working folder. I ran pytest with the keys unset and the network blocked by a proxy pointed at a closed port. Voikko does not install on Windows, so the 64 Voikko tests skip on this machine and the 7 v2 gate tests error. The GitHub Python check runs all 138 tests with real Voikko and no network, and none is skipped. I tested the review page with Playwright in Chromium and WebKit, at 375 x 812 and at 1280 x 800. I broke protections only in the scratch copies. Nothing was pushed, and I did not touch main, the shared test project or the live database. I did not read any `.env*` file and did not use the Access service token, because no audio is published yet, so there was nothing to play on the preview. The scripts I wrote are in the session scratchpad (`harness/`). Their output is in `evidence/`.

## Results

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `eval-12-local-pytest-offline.txt`, `eval-ci-python-log-cc90a75.txt` | The unit 1 brief has every field from PRD section 6. All 15 missing-field tests and the line count, voice and grammar id tests pass locally and on GitHub. |
| 2 | pass on fakes; real run pending keys and merge | `eval-break-02-manual-only.txt`, `eval-ci-python-log-cc90a75.txt` | The workflow only starts by hand. Keys reach only the pipeline step and the upload guard. The secret guard runs before upload. The draft loop stops after 3 rounds, gives a plain list of failures and makes no pack (pytest on GitHub). Adding a `pull_request` trigger turned the workflow test red. The real keyed run has not happened. Both keys are GitHub secrets now and both variables are set (`italynorth`, `F0`). GitHub only starts a manual workflow once its file is on main, so the run can only happen after merge. |
| 3 | pass | `eval-break-03-ai-one-module.txt` | Only `providers/ai.py` imports `anthropic`. When I added `import anthropic` to `judge.py`, the test went red. It went green again after I reverted. |
| 4 | pass | `eval-break-04-cost-log.txt` | One call writes one log line with the table's cost and no key or prompt text. When I removed the log write, 3 tests went red. Model ids and prices ($4/$20 Opus 5.5, $2/$10 Sonnet 5.5) match Anthropic's current table. |
| 5 | pass; live Azure call pending | `eval-break-05-ssml-escape.txt`, `eval-5-azure-italy-north-docs.txt` | `<`, `&` and quotes are escaped before the request. When I removed the escaping, the test went red. Microsoft's docs list Italy North with neural text to speech, give its REST endpoint as `italynorth.tts.speech.microsoft.com/cognitiveservices/v1` (the same shape `voice.py` builds) and accept the mp3 format the pipeline asks for. Whether a fi-FI voice really answers from the owner's F0 resource is unverified until the first run. |
| 6 | pass | `eval-ci-python-log-cc90a75.txt` | The native recording tests pass with real Voikko on GitHub. |
| 7 | pass | `eval-ci-python-log-cc90a75.txt`, builder's `break-07-word-validity.txt` | A planted invented word fails, tested with real Voikko on GitHub. |
| 8 | pass | `eval-ci-python-log-cc90a75.txt` | The missing-link and doubled-link tests and the spoken-only listing pass on GitHub. |
| 9 | pass | `eval-ci-python-log-cc90a75.txt` | The out-of-level word and out-of-list form tests pass on GitHub. |
| 10 | pass | `eval-ci-python-log-cc90a75.txt`, `eval-12-local-pytest-offline.txt` | The tag table tests pass locally. The Voikko reading and "why" tests pass on GitHub. |
| 11 | pass for the stale-verdict check; golden set pending keys | `eval-ci-python-log-cc90a75.txt`, builder's `break-11-stale-judge-verdict.txt` | A line that changed after it was judged fails. The golden set has 10 faithful and 10 changed pairs, each change labelled. The proof run needs the Anthropic key, and the workflow has no task to run it (see should-fix 3). |
| 12 | pass | `eval-ci-python-log-cc90a75.txt`, `eval-12-check-committed-exit-codes.txt` | GitHub ran 138 tests with no failures and none skipped, and the 9 v2 Voikko gate tests are still required. `check-committed` runs with the network off. With a failing draft it exits 1, and with a publish that has no committed draft it also exits 1. No committed draft exists yet, so on the PR it only prints "No committed drafts yet". |
| 13 | pass in Chromium and WebKit; Firefox not tested | `13-review-page-top-chromium-375.png`, `13-review-page-top-webkit-375.png`, `13-review-page-full-*.png`, `13-review-not-yet-chromium-375.png`, `13-review-downloaded-*.png`, `13-review-hostile-text-chromium.png`, `13-review-hostile-text-top-chromium-375.png`, `13-review-main-path-chromium-375.webm`, `eval-13-review-page-browser-log.txt`, `eval-13-14-download-read-back.txt`, `eval-break-13-escapes.txt`, `eval-break-13-nocsp.txt` | The page made no network requests. It has no sideways scroll at 375 or 1280. Every item has its choices. Download is refused until every item has a decision and there is a reviewer code. Every downloaded file was read back and accepted by the pipeline. A hostile page with `<script>`, `<img onerror>` and `<!--` in 8 fields printed them as text, with no new elements, no dialogs and the title unchanged. When I removed both escapes, all 16 e2e tests went red (with and without the Content Security Policy). Firefox is not installed here. |
| 14 | pass | `eval-14-15-17-adversarial-harness.txt` | Refused with plain reasons: wrong fingerprint, text edited after review, missing line, item list not a list, not JSON, wrong format, no round, two files for one round, empty code, code of spaces, email as code, blank fix, "sounds wrong" with no recording, "Not yet" with nothing to fix. Accepted: "Not yet" with a fix (round 1's dead end is gone). A 40 MB file was also accepted; there is no size limit. |
| 15 | pass | `eval-14-15-17-adversarial-harness.txt` | Refused, writing nothing and creating no `public/audio`: fake draft and audio, an unapproved line, a clip marked "sounds wrong", a line edited after approval, a swapped audio file, a dialogue left "Not yet", a second publish. But see should-fix 1 and 2: publish accepts a file the read-back step refuses, and fake content whose labels were edited. |
| 16 | pass for the fixture; unit 1 rows pending the reviewer | `eval-ci-database-log-cc90a75.txt` | The pgTAP run passes before and after every migration is loaded again (436 tests, 23 of them for this job). The fixture publish runs twice ("already published; nothing to do"). A learner can read it, cannot read a draft line, and re-approval needs a new reference. The database check's step that publishes every `*_publish_*.sql` again currently finds no file. |
| 17 | pass; preview playback pending the reviewer | `eval-break-17-audio-hash.txt`, `eval-14-15-17-adversarial-harness.txt`, `eval-17-preview-and-published-files.txt` | When I removed the hash comparison, the Vitest audio test went red. No audio of an unapproved line reached `public/audio` in any refused case. The branch has no `public/` file and no publish migration. Without a token the preview returns a 302 to Access. |
| 18 | pending the reviewer | `build.md`, `factory/progress.md` | The owner chose the end-of-MVP review (call 3, option B), so this statement moves to job 12. No review file was written or faked; `content/reviews/` holds only its README. |
| 19 | pass | `eval-ci-database-log-cc90a75.txt` | Compared with main, the only file changed under `supabase/`, `src/`, `worker/` or `public/` is the new pgTAP test. The database types diff passes on GitHub. The Vitest check for DDL and AI calls passes. |
| 20 | pass | (git grep of the docs) | `docs/content-pipeline.md`, `docs/content-attribution.md` (v2 `9c8d0a0`, Kotus still banned, wordfreq flagged), conventions, data model, `.env.example` names and the README cost rows are all present. |
| 21 | pass | `eval-ci-python-log-cc90a75.txt` | The out-of-order word and dropped word tests pass on GitHub. |

Protections I broke on purpose, each seen red and then green after revert: [content 2], [content 3], [content 4], [content 5], [content 13] (two ways) and [content 17]. Removing only the `<` escape left the page safe and the tests green, which is correct: `>` is still escaped, so `</script>` cannot end the data block (`eval-break-13-lt-only-still-safe.txt`).

## Failures

None of the 21 statements failed on `cc90a75`.

At `9e834ef` there was one real failure, which round 2 fixed. A reviewer who marked a fix and answered "Not yet" for the whole dialogue could not download at all; the page kept asking them to choose. The proof is in `eval-at-9e834ef/13-review-not-yet-blocked-chromium-375.png`. On `cc90a75` that file downloads and is accepted (`eval-13-14-download-read-back.txt`).

## Should-fix (not failures)

1. **Publish does not run the read-back checks on the review file.** I gave the publish step a fully approving file with an empty reviewer code, one with `anna@example.fi` as the code, and one naming another dialogue. All three published the migration and the audio. Steps: run `scratchpad/harness/adversarial.py`, section "Publish step: files the read-back step refuses". This matters because the threat model says a review file holds a reviewer code and never a name or email, and publish is the last gate. Make publish run `read_round` on each round's file. The builder lists this for `factory/todo.md`.
2. **Fake content is detected only by its labels.** I took a fake draft, changed `providers.ai` to `anthropic` and each clip's `provider` to `azure`, and it published. The copied file still carries the `puhuscribe-fake-voice` marker. Checking for that marker in `publish.py` and in `check-published-audio.ts` would close this.
3. **The golden-set proof (11) and publishing have no route that can actually run.** `judge-golden` needs the Anthropic key, which lives only as a GitHub secret, and the workflow has no `judge-golden` task. `publish` needs Linux with Voikko, and no machine here has it (no WSL, no Docker), and the workflow has no publish task. Add both as workflow tasks, or say in the docs where they run.
4. **No repository test shows `check-committed` turning red.** My stubbed check shows it exits 1, but no committed test would catch someone breaking it.
5. **A confusing refusal message.** A file whose `round` is the string `"1"` is refused with "the file is for round 1, the page was round 1". `check-committed` prints "FAILS every check" when only one check failed. AGENTS.md says a message must claim only what happened.

## Odd but not failing

- The README cost rows still say "key not created yet" and "resource not created yet". Both keys are GitHub secrets now (Anthropic at 18:39Z, Azure at 19:42Z) and the Azure resource exists. `.env.example` and `docs/content-pipeline.md` give `northeurope` as the example region; the owner chose `italynorth`.
- WebKit on Windows could not play the fake test clip (media error 4, "NotSupportedError") with or without the page's Content Security Policy. Chromium played it (`eval-13-webkit-audio-codec-check.txt`). The cause is this WebKit build or the silent fake clip, not the page. Real Safari playing real Azure audio is unverified because there is no Mac here.
- WebKit logs "Refused to apply a stylesheet" Content Security Policy errors. The page's own style still applies (`13-review-page-top-webkit-375.png`). These are probably WebKit's built-in media styles.
- Double-clicking "Download my review" saves two identical files. A reviewer who downloads more than once gets several files with the same name, and the browser renames the later ones, so they could send back the wrong one.
- If a review file lists the same item twice, the last entry wins.
- Refreshing the page loses all choices. The page now says so.
- GitHub still lists the removed workflow "Voikko readings (temporary)". It ran once, used no secrets, and its file is gone from the branch. The owner can disable it in Actions.
- The golden set alternates faithful and changed pairs in a fixed order. A judge could pick up the pattern. Shuffling it would make the proof stronger.
- The spec says that under option B the scope line for statement 18 moves to job 12. I did not check whether `docs/scope/scope.md` was changed.
- Every GitHub check on `cc90a75` is green, the preview job included. The two jobs that only run after merge were skipped.

Result: pass

Must-fix: none. The pending items are the keyed runs for statements 2, 5 and 11, and the reviewer's file for statements 16 (unit 1 rows), 17 (preview playback) and 18.
