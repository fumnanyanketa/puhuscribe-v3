# Job 7-content-pipeline: Content pipeline and native review

Scope item 5. Needs a decision. GA. Date: 21 October 2026. Builds on jobs 1-stack, 3-data-model and 4-tooling as merged on main. Runs in parallel with `8-first-session`. Test label: `[content N]`.

## Summary for the owner

1. This job builds the machine every Finnish dialogue comes from. A short brief goes in, Claude drafts the dialogue in spoken and written Finnish, Voikko checks every written word, automatic checks run, and Azure voices record both versions.
2. Your native reviewer gets one page file per round. They listen, approve or correct each line, and send back a small file. Nothing reaches a learner without that file.
3. Publishing is a database change that lands only when you approve the merge. Audio of approved lines is served by the app itself, at no cost.
4. It needs two keys from you (Anthropic for drafting, Azure for voices). Running cost is cents per dialogue on Anthropic and €0 on Azure's free allowance.
5. The real proof is unit 1's first dialogue, start to finish. That needs your reviewer for about 20 to 30 minutes now instead of at the end of the MVP (owner's call 3).

## What it is

Every lesson in PuhuScribe is a short dialogue. This job builds the tool that turns a brief ("meeting someone at work, introduce yourself, say where you are from") into a dialogue a learner can use, with spoken and written Finnish, an English meaning, a short explanation for every word form and audio for both versions. A native Finnish speaker approves every line before anything is published, and the database refuses anything they have not approved.

## Done when

Each statement is checked by a command, by the GitHub checks, or on the preview link. Tests carry `[content N]`. "Kirja" means written Finnish (kirjakieli), "puhe" means spoken Finnish (puhekieli). "The pipeline" means the new Python code in `scripts/generate/` (the v2 files there stay byte for byte unchanged).

1. **The brief.** `content/briefs/` holds the brief for unit 1's first dialogue, written from PRD section 6 unit 1: unit slug, position, English title, the "can do" statement, the situation, the unit's grammar list (olla present, personal pronouns, -ssa/-sta, -ko/-kö questions), a word frequency rank cap, any extra allowed base forms, the speakers with an English role label and a voice each, and a line count from 4 to 8. The pipeline refuses a brief with a missing field.
2. **One run, brief to review pack.** A manual GitHub workflow, "Content pipeline", takes a brief path and runs on Linux with Voikko: draft, Voikko check, redraft with the rejected words named (at most 3 rounds, as in v2's loop), forms and "why" lines, automatic checks, audio for both registers, review pack. Its result is a downloadable artifact holding the draft, the check report, the audio, the review page and the run's log lines. The artifact passes `scripts/ci/check-files-for-secrets.ts` before upload. If any check still fails after the last round, the run fails with a plain list of each failing word or line and makes no review pack. The workflow runs only on manual start, never on a pull request or push.
3. **AI sits behind one module.** `scripts/generate/providers/ai.py` is the only new file that imports the `anthropic` package or calls an AI address (a test checks every Python file except the unchanged v2 imports). The provider is picked by one variable, `AI_PROVIDER` (`anthropic` or `fake`). The `fake` provider replays recorded responses so every test runs offline, with the network switched off as in today's Python check.
4. **Every AI call is logged with its cost.** Each call appends one line to `content/logs/ai-calls.jsonl`: time, purpose (draft, why, judge), model, input and output tokens, cost in US dollars from a dated price table in the module that cites Anthropic's pricing page, and the dialogue slug. The log write happens inside the module, so no call can skip it. pytest proves one call writes exactly one line, the cost matches the table, and the line holds no key and no prompt text.
5. **Voice sits behind one module.** `scripts/generate/providers/voice.py` is the only new file that calls a voice service. `VOICE_PROVIDER` picks `azure` or `fake`. Azure is called through its REST endpoint for the resource's EU region, with each speaker's fi-FI voice from the brief and the format `audio-24khz-48kbitrate-mono-mp3` (v2's working settings). Text is XML escaped before it goes into the request (pytest with `<`, `&` and quotes). Each synthesis is logged in the same log with its character count and cost.
6. **Native recordings can replace a synthetic line.** An mp3 at `content/recordings/<dialogue-slug>/<line>-<register>.mp3` replaces the synthetic audio for that line and register. The review page marks it "native recording". pytest covers it.
7. **Word validity, 100 percent.** Every kirja word analyses in Voikko through v2's `VoikkoGate`. A planted invented word fails the check (pytest with real Voikko).
8. **Spoken words are accounted for.** Every puhe word is linked to the kirja word it renders, or marked spoken only. Spoken only words get no form and are listed for the reviewer. A broken link (a missing or doubled kirja word) fails the check.
9. **Level fit, 100 percent.** Every kirja base form, apart from names, is inside the brief's frequency rank cap (from `data/finnish_frequency_lemmas.json`) or on the brief's extra list, and every form is on the unit's grammar list. A planted out of level word and a planted out of list form each fail the check.
10. **Grammar cards match Voikko, 100 percent.** A form's tag is built only from one of Voikko's own readings of that word. The AI may choose among Voikko's readings and may never add one. The form's English name comes from the tag through a fixed table in code; a Voikko value the table does not know fails the check instead of guessing. Each "why" is one line of at most 140 characters (the database's own limit) and names no grammar term other than the form's own. Planted failures for each rule are refused.
11. **Register faithfulness, at least 98 percent by the judge.** An AI judge says for each line whether the spoken and written versions mean the same. With 4 to 8 lines, 98 percent means every line. Each verdict is stored with the line's content fingerprint, and the check fails when a line changed after it was judged. The judge is proven on a golden set of 20 pairs, 10 faithful and 10 with a planted change of meaning (a number, a negation, a swapped pronoun): it must catch all 10 changed pairs and accept at least 9 of the 10 faithful ones. The result goes in the evidence folder. The reviewer's approval of every line covers the PRD's "100 percent on the reviewed sample".
12. **Thresholds are recorded and run on every pull request.** `content/checks/thresholds.json` records the PRD section 8 thresholds above. The Python check runs statements 7 to 11 offline on every committed draft and published dialogue, and a failure turns the pull request red. The count guard "All 9 Voikko gate tests ran and passed" is raised to the new total; no test is removed.
13. **The review page.** The pipeline writes one self contained HTML file per review round. It opens from disk in current desktop Chrome, Safari and Firefox and loads nothing from the network. Per line it shows the speaker, the spoken text with a play button, the written text with a play button and the English meaning; per form it shows the base form, the form name and the "why". Each item has approve, fix (with a box for the corrected text) and a comment box. Each audio clip has "sounds right" or "sounds wrong". There is one approval for the dialogue as a whole and a field for the reviewer code. "Download my review" saves a JSON file that carries each item's content fingerprint. All drafted text is shown as text, never run as code: a Playwright test opens a page whose line contains `<script>` and sees it printed. The page follows the banned list in `AGENTS.md`.
14. **Reading the review back.** The pipeline reads a returned file from `content/reviews/<dialogue-slug>/` and refuses it, with a plain reason, when an item is missing, a fingerprint does not match the current draft, a fix is still open, an audio clip is marked "sounds wrong", or the reviewer code is empty. When the reviewer wrote fixes, the pipeline applies them, runs the checks and the audio again for the changed lines only, and writes a next round page holding only those lines (PRD section 9, "re-approval of changed lines only").
15. **Publishing.** Only when every check passes and the review file covers every item does the pipeline write `supabase/migrations/<timestamp>_publish_<dialogue_slug>.sql` and copy the reviewed audio to `public/audio/<key>`. The key is `<dialogue-slug>/<line number>-<register>-<first 12 characters of the file's SHA-256>.mp3`. Each `approval_ref` is the review file path plus the item id, so each approval reference is new. The migration follows the order in `docs/data-model.md` (forms, lines with their words, dialogue, unit). pytest shows each missing precondition writes nothing.
16. **Published content reads correctly, and only approved content.** In the database check, after every migration, a pgTAP test acting as a learner reads unit 1, its first dialogue and every line with both texts, the meaning, both audio keys and an `approval_ref` pointing at the review file; every word that links to a form links to an approved form with a name and a "why". A draft line added inside the test cannot be read. The workflow runs every `*_publish_*.sql` a second time and the tests then pass unchanged. pgTAP also covers re-approving a unit and a form (setting back to draft clears the approval, approving again needs a new reference), the open item in `factory/todo.md`.
17. **Audio exists only for approved lines.** A Vitest test checks that every file under `public/audio/` is named by an approved line's key in a publish migration, that its SHA-256 matches its name, and that every published key has its file. Nothing under `content/` reaches the built app. On the preview link, each published key plays at `/audio/<key>`.
18. **Unit 1's first dialogue goes from brief to published for real.** With the owner's keys and the reviewer's real file (owner's calls 1 to 3), the workflow run, the returned review file, the publish migration and the audio are committed. `build.md` links the run and lists the total cost from the log. After the owner approves the merge, the apply job puts it in the test project and its pgTAP run passes there.
19. **The shared shape is untouched.** This job adds no table, column, type, rule, grant or function. `src/lib/database.types.ts` and the existing pgTAP files are unchanged and pass. No `/api` route and no browser code calls an AI or voice service.
20. **It is written down.** `docs/content-pipeline.md` explains how to run it, where each file lives, the form tag format, the audio key format and the `/audio/` address, how a review file comes back, and the cost per dialogue. `docs/content-attribution.md` records where v3 content truly comes from (carried forward from v2's file at commit `9c8d0a0`, with the Kotus ban kept). `docs/conventions.md`, `docs/data-model.md` and `.env.example` name the build time provider modules, the new variable names and that no pipeline database role exists. The README running costs list adds Anthropic (pay per use) and Azure Speech (free allowance).

Product rules from `AGENTS.md` that apply: nothing unapproved is served; AI drafts and explains but never publishes unchecked content, and every AI call is logged with its cost; both registers with audio (P5); short dialogues, never word lists (P1); every unit tied to an A1 "can do" (P3); spoken Finnish means standard Helsinki speech in 2026, no dialect; grammar is a one line card, never a lesson; v2 files unchanged; agents use only the test database; no keys in code, logs or chat; never delete or weaken a test; no placeholders.

## Threat model (GA)

**Worst thing a malicious person could do here.**
- Get wrong or offensive Finnish in front of learners: by editing a publish migration, swapping an audio file, writing a fake review file, or steering the AI through a brief. Defences: the database refuses unapproved rows (job 3); review files are bound to content fingerprints (14); audio names carry their own hash and a test checks them (17); publishing reaches any database only through an owner approved merge; the reviewer reads every line.
- Steal the Anthropic or Azure key and run up bills. Defences: keys live only in GitHub secrets and reach only the pipeline workflow's steps; no public route calls a paid service; spending caps on both accounts (owner's calls 1 and 2).
- Plant script in drafted text that runs when the reviewer opens the page. Defence: everything is escaped and the page loads nothing from the network (13).

**Data we must protect.** The two API keys. The test database password, which this job never needs. The reviewer's identity: review files hold a reviewer code (for example `R1`), never a name or email. No learner data is read, sent or stored by this job.

**What the system refuses, even if asked nicely.**
- Publishing a line, form, dialogue or unit without a matching, current review file entry.
- Publishing content that failed any automatic check. There is no override switch.
- A form name the AI chose that is not one of Voikko's readings.
- Sending learner data, or anything from the learner tables, to an AI or voice service.
- Running against any database other than through migrations, or against the live database.
- Copying draft audio into `public/`.
- Printing or logging a key.

## Decision

### Choices

| Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|
| Where the AI drafting code lives | `scripts/generate/providers/ai.py`, called by the Python pipeline at build time. This is the "one AI client file in `scripts/generate/` for build time" job 1-stack planned | `worker/providers/ai.ts` behind an `/api` route the pipeline calls | Voikko and the redraft loop are Python. An `/api` route would put a paid AI call on the internet although no learner ever triggers drafting. Runtime AI arrives with the tutor (job 12), which creates `worker/providers/ai.ts` then |
| Who drafts | Claude through the Anthropic API: `claude-opus-5-5` for drafting and "why" lines, `claude-sonnet-5-5` for the judge, structured JSON outputs (generally available on the Claude API, `output_config.format`) | The builder agent writes the draft itself inside its Claude Code session | No per call cost log (an AGENTS rule), and not repeatable for units 2 to 6. Opus over Sonnet for drafting because reviewer time costs far more than the cents saved |
| AI service | Anthropic API, global processing (owner's call 1) | Amazon Bedrock EU endpoint (job 1-stack's recommendation for the app's AI) | Drafting sends only content briefs, never personal data, so EU processing adds nothing yet; Bedrock needs a new AWS account. Anthropic's API offers only `global` or `us` inference today. The EU question stays open for the tutor (job 12). Note: 1-stack's caveat that Bedrock lacks structured outputs may be out of date; the structured outputs page now lists Amazon Bedrock |
| Where the pipeline runs | A manual GitHub workflow on Linux, keys from GitHub secrets | WSL on the owner's computer | Voikko needs Linux (job 1-stack). WSL is not known to be installed and builders work on Windows. The workflow keeps keys off every laptop and gives each run a link for `build.md` |
| How spoken Finnish audio is made | Azure neural fi-FI voices (`fi-FI-NooraNeural`, `fi-FI-HarriNeural`, `fi-FI-SelmaNeural`) reading the spoken spelling, one voice per speaker, both registers. Native recordings replace any line the reviewer rejects (6). Provisional: risk test 2 after the MVP may change the provider, which then changes `voice.py` only | Native recordings for every line now | Decision 8 of the factory plan names Azure as provisional. Recordings need a booked voice actor, cost an unverified €150 to €600 for about 40 lines, and slow every content change |
| Where audio lives | Static files in `public/audio/`, served by the Worker at `/audio/<key>`, copied there only for approved lines | A Supabase Storage bucket | Uploading needs a storage key agents must never hold, plus storage access rules. Workers static files are free and cached. Six units of audio is a few megabytes (my estimate) |
| How the reviewer approves | A self contained HTML page per round, opened from disk, returning a JSON file (13, 14). PRD 7.5 allows "a review UI (or a markdown table, as in v2)" | A shared spreadsheet | No audio next to each line, and free text edits cannot be checked. v2 used a table and its reviewer's corrections were never recorded (job 3-data-model) |
| | | A review page on the preview Worker behind Cloudflare Access | Needs a table for results, the reviewer's email in the Access rule, and more build. Revisit if the reviewer cannot use a file |
| How content reaches the database | A generated upsert migration, applied by the existing workflow when the owner approves the merge | A pipeline database role writing directly | A new credential, new grants on `private.approval_history`, and content would reach the test project before the owner approves (breaks the owner's rule from job 3) |
| Form tag format | A canonical string built from Voikko attributes in fixed order (word class, case, number, person, mood, tense, negative, possessive, comparison, participle, question clitic `KYSYMYSLIITE`, focus), documented in `docs/content-pipeline.md`. The full reading also goes in `forms.analysis` | The raw Voikko reading as the key | Raw readings carry fields like `STRUCTURE` and `FSTOUTPUT` that differ between Voikko versions, so the same form could get two keys |
| Cost log | `content/logs/ai-calls.jsonl` in the repository | A database table | Build time calls involve no learner, the file is reviewable in git, and adding a table would change the shape job 8 builds on. Job 14 can read the file |

### What carries over from v2

| v2 piece | Use |
|---|---|
| `voikko_gate.py` (`VoikkoGate`) | Imported unchanged for word validity |
| `allowed_vocab.py`, `data/finnish_frequency_lemmas.json` | Imported unchanged for the rank cap |
| `generate.py` | Not called. Its loop shape (draft, check, name the rejected words, redraft, at most 3 retries) and its few shot pairs are the model for the new code. It stays unchanged and unused |
| v2 Worker's Azure call (`workers/tts/src/worker.js`) | Pattern only: REST endpoint per region, `Ocp-Apim-Subscription-Key`, XML escaping, mp3 24 kHz 48 kbit |
| `docs/content-attribution.md` | Carried forward into v3's own file (20) |

New Python packages, if any, go in a new `scripts/requirements-pipeline.txt` that pip-audit also checks; `scripts/requirements.txt` is a v2 file and stays unchanged. The Anthropic SDK version must support `output_config` (the v2 file only says `anthropic>=0.40`).

### Running cost

| Item | Cost |
|---|---|
| Anthropic API | Opus 5.5 is $4 per million input tokens and $20 per million output tokens; Sonnet 5.5 is $2 and $10 (Anthropic pricing page, read today). My estimate for one dialogue, with three draft rounds, the "why" lines and the judge: about $0.25. Six units: a few dollars |
| Azure neural voices | Free allowance: 0.5 million characters a month (Azure pricing page). One dialogue is under 1,000 characters for both registers. The paid price could not be read from Azure's page |
| GitHub check minutes | A few minutes per pipeline run, inside the free 2,000 a month |
| Audio hosting | €0 (Workers static files) |

## Out of scope

- The rest of unit 1, units 2 and 3, and the "Patterns you've seen" panel (job `12-units-1-3`).
- Any learner screen. Job 8 shows the content.
- Any change to tables, columns, rules or the published dialogue shape. If one seems needed, stop and tell the manager.
- Word timings for highlighting words as the audio plays (see Risks).
- Any `/api` route, runtime AI, runtime voice or the tutor (job 12). A hosted Voikko service (v3.1).
- A full admin app or a hosted review site.
- Loading v2's 104 starter sentences (waits on the reviewer's corrections, job 3). The pipeline does not read `source_sentences` yet.
- Showing IPA to learners.
- Anything on the PRD's "Not in v3.0" list. In particular: no vocabulary list or word count shown to learners, no mnemonics in a "why" line, no standalone grammar lesson, no YKI tags, no language toggle.

## Build plan

1. **Providers and the log.** `ai.py`, `voice.py`, their `fake` versions, recorded responses, the cost log, the price table, `.env.example`. Covers 3 to 6.
2. **Analysis and checks.** Voikko readings to form tags, the form name table, puhe to kirja links, level fit, "why" rules, the judge and its golden set, `thresholds.json`, the Python check wiring and the raised count guard. Covers 7 to 12.
3. **Draft loop and the workflow.** Brief format and the unit 1 brief, drafting prompts, redraft loop, audio, the manual workflow and its artifact guard. Covers 1, 2.
4. **Review page and review import.** Covers 13, 14.
5. **Publishing.** Migration generator, audio copy, pgTAP, the second publish run in the database check, the audio test. Covers 15 to 17, 19.
6. **The real run and docs.** Needs owner's calls 1 to 3: run the workflow on the unit 1 brief, send the page through the owner, read back the reviewer's file, publish. Covers 18, 20.

Dependencies: milestones 1 to 5 run on the `fake` providers and need nothing from the owner. Milestone 6 needs the two keys as GitHub secrets and the reviewer's file. The preview link and GitHub checks exist from job 1.

## Risks and flags

- **Look closely: Finnish learning content.** This job produces the first Finnish a learner will see. The reviewer approves every line, each "why" and the audio. The judge's golden set is also Finnish written by AI; its labels are planted changes of meaning and should be shown to the reviewer once.
- **Look closely: paid services.** Two new keys and pay per use AI. Cents per dialogue, but a leaked key could cost more until the caps stop it.
- **Look closely: database.** No new rules, but this job writes the first real content into the test project, at merge.
- **Contract with job 8 (for the manager).** Job 8 needs two facts it cannot get from the data model: audio plays at `/audio/` plus the line's audio key, and real content reaches the test project only when this job merges with the reviewer's approval. Until then job 8 must use its clearly named test seed. Also, job 5's chosen design lights up each word as it is spoken; that needs word timings, and the data model has no place for them. Azure gives word timings through its Speech SDK, not through the REST call this job uses (not tested). One option that changes no table is a small timings file beside each audio file. The manager should settle this with job 8 before either builds it.
- **Reviewer timing conflicts with the run plan.** The run plan has the reviewer approve all Finnish at the end. The scope's "done when" needs one real approval in this job (owner's call 3).
- **Synthetic spoken Finnish may be rejected.** No voice provider claims to handle puhekieli (factory plan, test 2). If the reviewer marks clips "sounds wrong", those lines need native recordings, which cost money and an owner's call.
- **Re-publishing trap.** The database refuses new words on an approved line even inside `insert ... on conflict do nothing`, because that check runs before Postgres looks for a conflict. The publish migration must check whether the dialogue is already published before inserting words, or the second run in statement 16 fails.
- **A fake review file.** An agent could write a review file itself. The rule: only the manager adds files to `content/reviews/`, on the owner's instruction, and the job summary lists each file with its date for the owner to confirm. This is a process rule, not a technical lock.
- **Workflow secrets.** A manual workflow can be started from any branch, so a branch could change the workflow to read the keys. The repository is private and caps limit the damage. Restricting the secrets to main (GitHub environments) was not checked for this plan.
- **Secret scanner and fingerprints.** Long hex fingerprints in JSON may look like keys to gitleaks. If it flags them, stop and ask the manager; do not change the scanner's rules alone.
- **Licence.** `data/finnish_frequency_lemmas.json` says its frequencies come from wordfreq, whose data is CC BY-SA 4.0 (wordfreq README), while v2's attribution file says Leipzig is the only frequency source. The list is used only at build time to choose words and is never shipped. Not checked with a lawyer.
- **Processing outside the EU.** The Anthropic API runs globally. Fine for content briefs. It must never receive learner data; the tutor decides its provider separately.

## Owner's calls

None of these is decided. Each has a recommendation.

**1. The AI key for drafting (spends money).** Answers job 1-stack's open call 1 for build time only.
- A. A new Anthropic API key for v3 in your existing Anthropic account, with a monthly spend limit (for example $10). Costs about $0.25 per dialogue (my estimate). Costs show apart from v2. You paste it with `gh secret set ANTHROPIC_API_KEY`, which asks for the value so it never appears in chat.
- B. Reuse v2's Anthropic key. No setup. v2's Worker still lets any website use that key with no sign in (found in job 1-stack), so v3's costs would mix with whatever happens there.
- C. Amazon Bedrock in the EU. A new AWS account and setup now, for no privacy gain at build time.
- Recommendation: A. API use is billed separately from your Claude Max plan, as far as I know (not re-checked today).

**2. The Azure voice resource (an account step, €0 expected).** Job 10 needs an Azure Speech resource in the EU too, so one resource serves both.
- A. A new Speech resource for v3 in North Europe (Ireland, where your test database is and where v2's voices ran), on the free tier if Azure allows it, with the €10 budget alert from decision 7. Shared with job 10.
- B. Reuse v2's Speech resource. No setup, but v2's open Worker route can use up its free allowance, and costs mix.
- Recommendation: A. If Azure refuses a second free resource on your subscription (I could not verify that rule), choose pay as you go with the budget alert; the paid voice price could not be read from Azure's page.

**3. When your reviewer approves the first dialogue (reviewer time and pay).**
- A. Now: one dialogue of 4 to 8 lines, its word cards and audio, about 20 to 30 minutes (my estimate). The job finishes as the scope says, job 8 gets real content in the test database, and the review page is tried before the bigger batch.
- B. With the end of MVP batch, as the run plan says. The job merges with the pipeline proven on test data only, the first dialogue stays unpublished, statement 18 moves to job `12-units-1-3`, and the scope line is changed. Job 8 works on its test seed until then.
- Recommendation: A. You send the page file to the reviewer yourself; nothing is sent on your behalf.

## Could not verify

- Azure's paid neural voice price, and whether a subscription may hold more than one free Speech resource.
- How Azure's synthetic voices sound on spoken spellings such as "mä oon" (risk test 2 answers this).
- Whether v2's Anthropic and Azure keys are still active.
- Whether GitHub environments can restrict these secrets to main on your plan.
- That Claude Max does not cover API calls (my understanding).
- Word timing support through Azure's REST call (believed absent; the SDK has word boundary events).
- The cost per dialogue (estimate from token guesses; the log measures it).
- The licence fit of the wordfreq based frequency list.

## Sources

- PRD sections 3, 4.1, 6, 7.3 to 7.5, 8, 9: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- Job specs: `factory/jobs/1-stack/spec.md` (provisional providers, call 1), `factory/jobs/3-data-model/spec.md`, `docs/data-model.md`, `supabase/migrations/20261020090000_content_model.sql`
- Factory plan decisions 7 to 9: `docs/factory-and-risk-tests-plan.md`; run plan: `factory/run-plan.md`
- v2 at commit `9c8d0a0`, read only clone `C:/Users/fumna/dev/_v2-readonly`: `scripts/generate/`, `workers/tts/src/worker.js`, `docs/content-attribution.md`
- Anthropic pricing: https://platform.claude.com/docs/en/about-claude/pricing
- Anthropic data residency (`global` or `us` only): https://platform.claude.com/docs/en/manage-claude/data-residency
- Anthropic structured outputs (generally available, `output_config.format`, model list): https://platform.claude.com/docs/en/build-with-claude/structured-outputs
- Azure fi-FI voices: https://learn.microsoft.com/en-us/azure/ai-services/speech-service/language-support?tabs=tts
- Azure text to speech REST (EU endpoints, output formats): https://learn.microsoft.com/en-us/azure/ai-services/speech-service/rest-text-to-speech
- Azure Speech pricing (0.5 million free characters a month): https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/
- Voikko morphological attributes: https://github.com/voikko/corevoikko/blob/master/libvoikko/doc/morphological-analysis.txt
- wordfreq licence and sunset: https://github.com/rspeer/wordfreq

Result: ready for owner approval


## Manager addendum (21 October 2026): contract settled with job 8

- **Audio location confirmed.** Static files under `public/audio/<audio key>`, copied only for approved lines. Job 8 plays them directly at `/audio/<key>`.
- **New statement [content 21].** Each token's text appears in order in its line's text. The pipeline's checks fail a line otherwise, with a test.
- **Word timings.** Not stored and not built in this job. Job 8 highlights the whole line during playback.
- **Job 8 test seed.** Job 8 uses its own local test fixture until this job's real dialogue is merged. This job adds no table, column, type, rule, grant or function.
