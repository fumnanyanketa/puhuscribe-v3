# Security and privacy review: 7-content-pipeline

Reviewer: security agent, 21 October 2026. Branch `factory/7-content-pipeline`, PR 17, head `9e834ef`. Read only; no code changed. I read the spec with the manager addendum, `build.md` and the whole diff against main. `.env*` files were not opened or searched; the secret scan used `git grep` on the branch.

## Findings

No must fix findings. Six should fix findings, then notes.

### 1. Should fix: the publish migration's dollar quote can be ended by content text

- **Where.** `scripts/generate/publish.py` lines 61 and 174 (`do $publish$` ... `$publish$;`), with `sql_text` at lines 36 to 42.
- **Risk.** Any published text that contains `$publish$` ends the migration's code block early. Postgres looks for the closing tag without reading the single quotes inside, so `sql_text` quoting gives no protection there. Text that can carry it unchecked: `gloss_en`, `why_en`, spoken only words in `text_puhe`, unit and dialogue titles, speaker names. I traced the attack and it fails closed. The attacker's own quotes are doubled, so the cut off block always ends inside an open string, the block errors, and the migration stops before any following SQL runs. The result is a broken publish, not injected SQL. The quoting test (`scripts/generate/test_content_publish.py` line 190) does not cover this case.
- **Fix.** Refuse any published value that contains `$publish$`, or pick a dollar tag that is shown not to appear in the generated text. Add a test that plants it in a gloss.

### 2. Should fix: RAISE messages put words into SQL with no quoting

- **Where.** `scripts/generate/publish.py` lines 70, 83, 95 and 116 to 117. Line 116 is `raise exception 'form {form['surface_kirja']} ({form['lemma']}) exists but is not approved'`.
- **Risk.** Slugs pass a strict pattern, but `surface_kirja` and `lemma` are inserted raw. Finnish words with an apostrophe, such as `vaa'an` or `ruo'on`, are valid in Voikko, and v2's tokenizer keeps an apostrophe inside a word. A dialogue with such a word writes a migration that fails with a syntax error. A word cannot hold a space and must pass Voikko, so this cannot be used for injection, but it is the same pattern the spec asked me to check.
- **Fix.** Pass every value as a parameter, for example `raise exception 'form % (%) exists but is not approved', <sql_text(surface)>, <sql_text(lemma)>;`, and do the same for the slug messages.

### 3. Should fix: publishing skips the review file checks of statement 14

- **Where.** `scripts/generate/publish.py` lines 206 to 227 call `review_files`, `open_fixes` and `approvals` but never call `read_round` (`scripts/generate/review_import.py` line 60).
- **Risk.** If `publish` runs on a review file that never went through `next-round`, none of these is checked: the reviewer code (empty, a name or an email), the file's `dialogue_slug`, its round against the page's manifest, and items the page never showed. Approvals stay tied to fingerprints, so an edited line still cannot ride an old approval. But a file with a real name in `reviewer_code`, or with no code, can still become the `approval_ref` source.
- **Fix.** In `preconditions`, run `read_round` on every review file against its round manifest (`load_manifest`), or at least on the latest one, and add each refusal to `reasons`. Add a precondition test for an empty reviewer code and for a name-like one.

### 4. Should fix: `forms.analysis` is published without any check or approval

- **Where.** `scripts/generate/fingerprints.py` lines 286 to 289 (the form fingerprint leaves out `analysis`), `scripts/generate/content_checks.py` lines 178 to 219 (`analysis` is never compared with Voikko) and `scripts/generate/publish.py` line 106 (it is written to `public.forms.analysis`).
- **Risk.** Learners can read `public.forms` (`supabase/migrations/20261020090000_content_model.sql` line 370). An edited `draft.json` can put any JSON in `analysis`. The reviewer never sees it, no check runs on it, and the edit leaves every approval valid.
- **Fix.** In `run_checks`, require each form's `analysis` to equal the Voikko reading behind its `(lemma, form_tag)`. Or add `analysis` to the form fingerprint.

### 5. Should fix: paths taken from `draft.json` are trusted when reading and writing files

- **Where.** `scripts/generate/review_page.py` line 338 reads `draft_dir / audio["file"]`. `scripts/generate/publish.py` lines 241 and 290 to 291 read the same path and write to `public/audio/<slug>/...`. The slug comes from `draft["brief"]`, which `next-round` and `publish` never check again (`scripts/generate/pipeline.py` lines 181 and 253).
- **Risk.** The audio fingerprint covers the text and the SHA-256 but not the file path. An edited `draft.json` with `"file": "/proc/self/environ"` makes the next-round workflow base64-encode the runner's environment, both keys included, into the review page. The upload guard looks only for the raw key values, so the encoded copy would pass into the artifact. A slug such as `../../src/x` would let `publish` write outside `public/audio/`. Both need push access, and push access can already change the workflow, so this does not give anyone new power. It does remove a layer.
- **Fix.** Before reading or writing, require `audio["file"] == f"audio/{n}-{register}.mp3"`, and run `validate_brief` on `draft["brief"]` in `next-round` and `publish`.

### 6. Should fix: the pipeline's indirect Python packages are not pinned

- **Where.** `scripts/requirements-pipeline.txt` lines 5 and 6, installed at `.github/workflows/content-pipeline.yml` line 55.
- **Risk.** Only `anthropic` and `libvoikko` are pinned. The packages `anthropic` pulls in (httpx, httpcore, pydantic, pydantic-core, anyio, jiter, distro, sniffio, typing-extensions, certifi, idna, h11) resolve fresh on every run, with no hashes. They then run in the step that holds both keys. The pull request's pip-audit checks the versions picked on that day, not the ones a later pipeline run installs.
- **Fix.** Commit a full lock file with hashes (for example `pip-compile --generate-hashes`), install with `pip install --require-hashes`, and point pip-audit at the lock file.

## Notes (pass, but worth the owner's eye)

- **Anyone with write access can get the keys.** `.github/workflows/content-pipeline.yml` runs on manual start only, with `permissions: contents: read`, `persist-credentials: false`, inputs passed as environment variables and checked against a pattern, keys only in the pipeline step and the upload guard, and the upload gated on the guard's outcome. That part is good. But a manual workflow can start from any branch, and any same-repository pull request workflow can also name `secrets.ANTHROPIC_API_KEY`. So anyone with write access to the repository, agents' branches included, could read the keys. Recommendation: put the two secrets in a GitHub environment that only main can use, with the owner as required approver, if your GitHub plan offers it. Either way, set the spend caps on both accounts before adding the keys (owner's calls 1 and 2).
- **Action pins.** `actions/checkout`, `setup-python`, `setup-node` and `upload-artifact` are pinned by version tag (`@v7`), not by commit. That matches `checks.yml`, and the lessons line asks for commit pins only on third party actions. No third party action runs in this workflow.
- **Fake review files.** `content/reviews/README.md` states the rule. Nothing technical stops someone writing a review file: fingerprints can be worked out from `draft.json`, and the reviewer code is not signed. Owner: before approving the merge that publishes unit 1, compare each file in `content/reviews/<slug>/` with the file the reviewer actually sent you.
- **Fake content refusal relies on editable fields.** `scripts/generate/publish.py` lines 201 and 239 trust `providers.ai` and each clip's `provider` in `draft.json`, and no fingerprint covers either. The reviewer listening to every clip is the real guard. A cheap second guard would be to refuse any mp3 that holds the fake provider's `puhuscribe-fake-voice` tag (`scripts/generate/providers/voice.py` line 362).
- **The audio check matches keys anywhere in the file.** `scripts/ci/check-published-audio.ts` line 16 accepts a key quoted anywhere in a `*_publish_*.sql` file, comments included. Audio under `public/audio/` also stays public after its line is withdrawn in the database. Neither is a problem today because `publish.py` is the only writer.
- **Review comments are free text.** They end up in git. Ask the reviewer to keep their name and email out of comments as well as the code field.
- **Later rounds show only changed lines.** In round 2 and later, the page shows only the changed lines, but the reviewer still approves "the dialogue as a whole" (`scripts/generate/review_page.py` lines 216 to 220 and 329 to 330). Every line still has its own approval, so nothing unapproved is published. The wording overstates what the reviewer sees in that round.
- **Python packages.** `libvoikko==4.3` is a small binding that changes rarely. The Dependency check passed on PR 17 according to `build.md`. I did not run pip-audit myself.

## What I verified in the code

- **Keys.** No key, token or password appears anywhere in the branch (`git grep` for key patterns), in `.env.example`, in the fixtures, or in the temporary diagnostic workflow in commit `ee9dbc8`, which used no secrets. `ai.py` and `voice.py` read keys only from the environment. Their error messages carry only an HTTP status or connection reason. The cost log lines (`ai.py` lines 79 to 93, `voice.py` lines 287 to 301) hold time, provider, purpose, model or voice, token or character counts, cost, price date and the dialogue slug, and no key or prompt. `check-files-for-secrets.ts` runs on the whole pack, failed runs included, before upload.
- **Providers.** Azure regions are an allowlist of EU regions, so the address cannot be pointed elsewhere. SSML text and voice are XML escaped, quotes included. The browser and the Worker call no AI or voice service (`tests/content-audio.test.ts` lines 158 to 170). Only build-time content goes to Anthropic: briefs, line texts and the reviewer's corrected texts. No learner data and no reviewer code is sent. Voice work runs in Italy North (EU).
- **Prompt injection.** Brief text and reviewer fixes reach prompts (`drafting.py` line 177, `pipeline.py` line 158). Every answer is structured JSON that then passes Voikko, the level and grammar checks, the Voikko-readings-only rule for form tags, and a fingerprint-bound approval of every line. So a steered answer cannot publish on its own.
- **Review page.** The CSP is `default-src 'none'`, the script and style are allowed by hash, and only `data:` media is allowed. The data block escapes `<`, `>`, `&`, U+2028 and U+2029. All text is placed with `textContent`. The download is a local blob. Nothing is fetched or sent.
- **Review import.** It refuses a file with a missing item, a stale fingerprint, an item the page did not show, an open decision, "sounds wrong" without a recording, or an empty or name-like code. Item ids are checked against the manifest before `apply_fixes` parses them. File paths come from the slug folder, never from the file's contents.

**Can an unapproved line reach a learner?** No, and I traced it in code and tests. `publish` refuses unless every current item (each line, form, clip and the dialogue) has an approval whose fingerprint equals the current content, the dialogue approval comes from the latest round, and every check passes (`publish.py` lines 199 to 252, tests in `test_content_publish.py` lines 136 to 154). The migration approves a line only after its words are in. The database hides draft rows from learners (pgTAP `content_publish.test.sql` lines 371 to 390). Audio is copied only by `publish`, and only when every clip is approved. `check-published-audio.ts` fails a pull request that carries a stray or swapped file. Running a migration a second time returns early before any insert, so the trap noted in the spec is handled. The limits are the process rule on who writes review files, and findings 3 to 5.

## Threat model answers, checked against the code

- **What is the worst a malicious person could do?** Publish Finnish no reviewer approved, by writing a fake review file. That is stopped only by the process rule and the owner's merge approval. Editing a line, a "why" or a clip after approval is refused by fingerprints, and swapping an audio file is caught by its hash name and the audio check. Steal the keys: they are safe from logs and artifacts, but anyone with write access can reach them through a branch workflow (note above). Run script on the reviewer's computer: blocked by escaping, `textContent` and the CSP.
- **What data must we protect?** The two keys, covered above. The reviewer's identity: the code is limited to 12 letters and digits on the import path, but the publish path does not check it (finding 3), and comments are free text. No learner data is touched.
- **What must the system refuse even if asked nicely?** Unapproved or stale content: refused. Failed checks: refused, and there is no override outside tests (`allow_fake` defaults to off and `cmd_publish` never sets it). Form tags that are not a Voikko reading: refused. Draft audio in `public/`: refused. Printing a key: none found. Any database access except migrations: the pipeline has no database connection. Fake content: refused, but only through fields that can be edited (note above).

Result: pass
