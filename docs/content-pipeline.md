# Content pipeline

How a Finnish dialogue is made, checked, reviewed by the native reviewer and published. Built in job 7-content-pipeline; the decision and its alternatives are in [factory/jobs/7-content-pipeline/spec.md](../factory/jobs/7-content-pipeline/spec.md#decision).

A short brief goes in. Claude drafts the dialogue in spoken Finnish (puhekieli) and written Finnish (kirjakieli) with an English meaning. Voikko checks every written word. Automatic checks run. Azure voices read both versions. The native reviewer approves or corrects every line, word card and clip in one page file and sends back a small file. Only then does the pipeline write the database change and copy the audio into the app. Nothing reaches a learner without the reviewer's file, and the database refuses anything unapproved.

## Running it

The pipeline is Python in `scripts/generate/` and needs Linux with Voikko, so it runs in the manual GitHub workflow "Content pipeline" (`.github/workflows/content-pipeline.yml`). It never runs on a pull request or a push.

1. Write a brief in `content/briefs/` (see below), commit it and push.
2. On GitHub, open Actions, choose "Content pipeline", "Run workflow", task `draft`, and the brief path, for example `content/briefs/meeting-people-new-colleague.json`.
3. When it finishes, download the `review-pack` artifact from the run page. If a check still failed after three drafting rounds, the run is red, its log lists every failing word or line, and there is no review page.
4. Commit the pack as `content/drafts/<dialogue-slug>/`: `draft.json`, `check-report.json`, `audio/`, `review/` and `run.log`. Add the lines of its `ai-calls.jsonl` to `content/logs/ai-calls.jsonl`.
5. On the owner's instruction, the manager lists the dialogue slug in `review-site/dialogues.json` (once per dialogue). When that commit and the round's page `review/round-<n>.html` reach main, the review site updates by itself (see "The review site" below). The owner then sends the native reviewer the link `https://puhuscribe-review.exentrik.co/<dialogue-slug>/round-<n>`. Nothing is sent automatically.
6. The reviewer presses "Download my review" and sends the file back by the channel the owner chose. It goes to `content/reviews/<dialogue-slug>/round-<n>.json`. Only the manager adds files there, on the owner's instruction.
7. Run the workflow again with task `next-round` and the dialogue slug. If the reviewer fixed anything, it applies the fixes, checks and voices the changed lines only, and makes `review/round-2.html` with only the changed lines, their word cards and clips (PRD section 9). Repeat from step 5. If everything was approved, the log says "Ready to publish".
8. Publish on a computer with Voikko: `python scripts/generate/pipeline.py publish --draft content/drafts/<dialogue-slug>`. Commit the new migration and the audio. The content reaches the test database only when the owner approves the merge.

The GitHub check "Python tests and lint" runs `python scripts/generate/pipeline.py check-committed` on every pull request: the automatic checks, offline, on every committed draft and published dialogue.

### Settings

| Name | Where | What |
| --- | --- | --- |
| `ANTHROPIC_API_KEY` | GitHub secret | The Anthropic key for drafting. Only the pipeline step reads it |
| `AZURE_SPEECH_KEY` | GitHub secret | The Azure Speech key. Only the pipeline step reads it |
| `AZURE_SPEECH_REGION` | GitHub variable | The Speech resource's EU region, for example `northeurope` |
| `AZURE_SPEECH_TIER` | GitHub variable | `F0` for the free tier. A tier without a price in `scripts/generate/providers/voice.py` is refused |
| `AI_PROVIDER` | Set by the workflow | `anthropic`, or `fake` in tests |
| `VOICE_PROVIDER` | Set by the workflow | `azure`, or `fake` in tests |

Set a secret with `gh secret set NAME` (it asks for the value, so it never shows in chat) and a variable with `gh variable set NAME`.

## The review site

The native reviewer reads each review page on a private website, `https://puhuscribe-review.exentrik.co`, instead of opening a file. Built in job 13-review-site; the decision is in [factory/jobs/13-review-site/spec.md](../factory/jobs/13-review-site/spec.md#decision).

- **What it serves.** An index of the listed dialogues with each round's status ("Waiting for your review" or "Review received"), `robots.txt`, and each listed dialogue's review pages at `/<dialogue-slug>/round-<n>`, byte for byte as committed. Nothing else from `content/`: no draft, audio, round file, brief or returned review.
- **The list.** `review-site/dialogues.json` holds only dialogue slugs, for example `{"dialogues": ["meeting-people-new-colleague"]}`. Only the manager edits `review-site/dialogues.json`, on the owner's instruction, as with `content/reviews/`.
- **Who gets in.** Cloudflare Access with a one-time PIN sent by email. The Allow policy holds exactly the owner's chosen email and the reviewer's email, typed into the Zero Trust dashboard of the Exentrik Cloudflare account. No email address is ever written into this repository. A Service Auth policy lets the live tests in with the review site's service token.
- **What Cloudflare keeps.** Cloudflare (the Exentrik account) holds both emails in the Access policy and in its sign-in records, and it sends the one-time PIN email. Where Cloudflare keeps these records, whether they stay in the EU and for how long are not confirmed. Tell the reviewer this before their first sign-in.
- **The second lock.** The Worker `puhuscribe-review` (`review-site/worker.ts`, with its rules in `review-site/handler.ts`) serves a file only with a valid Access token for this application, answers only GET and HEAD, keeps no logs, and tells search engines to stay away on every response.
- **Build and deploy.** `npm run build:review-site` writes `dist-review/`. The workflow "Review site" (`.github/workflows/review-site.yml`) builds and dry runs it on pull requests. It deploys only from main: on a push that touches the site, a review page or `content/reviews/`, or on a manual start.
- **The reviewer's file.** The page's own "Download my review". Nothing is uploaded to the site.

### Review site settings

| Name | Where | What |
| --- | --- | --- |
| `CLOUDFLARE_REVIEW_API_TOKEN` | GitHub secret | A Cloudflare API token for the Exentrik account only, limited to editing Workers and the custom domain on exentrik.co. Only the deploy step reads it |
| `CLOUDFLARE_REVIEW_ACCOUNT_ID` | GitHub secret | The Exentrik Cloudflare account ID. Only the deploy step reads it |
| `REVIEW_CF_ACCESS_CLIENT_ID` | GitHub secret | Client ID of the review site's Access service token. Only the live test step reads it |
| `REVIEW_CF_ACCESS_CLIENT_SECRET` | GitHub secret | Client secret of that service token. Only the live test step reads it |
| `REVIEW_ACCESS_TEAM_DOMAIN` | GitHub variable | The Zero Trust team domain, `https://<team>.cloudflareaccess.com`. Reaches the Worker as `ACCESS_TEAM_DOMAIN` |
| `REVIEW_ACCESS_AUD` | GitHub variable | The Access application's AUD tag. Reaches the Worker as `ACCESS_AUD` |
| `REVIEW_WORKERS_SUBDOMAIN` | GitHub variable | The Exentrik account's workers.dev subdomain, read by one live test to prove that address serves nothing. Optional |

Until the four deploy settings (the two `CLOUDFLARE_REVIEW_` secrets and the two `REVIEW_ACCESS_` variables) exist, the deploy job skips the deploy with a notice. With only some of them set, it fails and names the missing ones. The Worker answers 403 to everything while either Access variable is missing.

When the reviewer stops reviewing, remove their email from the Allow policy and remove them from the Zero Trust users list, which frees their seat. This does not delete Cloudflare's sign-in records of their email.

## The A1 road

Built in job 20-a1-road; the decision and its alternatives are in [factory/jobs/20-a1-road/spec.md](../factory/jobs/20-a1-road/spec.md#decision). The 36 stops of the free A1 road (6 parts, [docs/curriculum-a1.md](curriculum-a1.md)) have 3 dialogues each. Claude wrote 102 of them by hand in `content/written/part-1.md` to `part-6.md` (8 lines each, with a spoken text, a written text and an English text); the other 6 are the pipeline's earlier drafts for stops 1 to 3. The hand written ones do not go through the AI drafting loop. A deterministic importer reads the markdown, the free checks run on it, the voices read it, and it goes live on the owner's written approval, part by part. A native speaker reads it after launch and the reviewer's fixes replace live lines.

### The files in `content/road/`

| File | What it holds |
| --- | --- |
| `stops.json` | For each stop its unit slug, rank cap, the grammar entries it adds and the extra base forms it allows. The rank cap is the same for every stop of a part: the lowest of 1500, 2000, 2500, 3000, 4000, 5000, 6000, 8000, 10000 that leaves each stop with at most 15 words on its extra list. `present-tense` is added at stop 1 because the curriculum's grammar column does not name the present tense of everyday verbs |
| `speakers.json` | Each named speaker's Azure voice. The same voice every time, and no two speakers of a dialogue share one |
| `spoken-forms.tsv` | The spoken and written word pairs that are not equal and that no ending rule explains, and the fillers. A reader can check each register difference here |
| `allowed-extras.json` | Base forms above the part's cap or missing from the frequency list, and forms used before the curriculum teaches them, each with its reason. Each form is recorded at the first stop that uses it |
| `reading-overrides.tsv` | A reading chosen by hand for a spelling that needs the same reading in every line (for example `minä`, `todella`). Each row says `voikko` (one of Voikko's own readings, chosen among them) or `manual` (Voikko offers no fitting reading, so the dictionary form and the form tag are written here) and gives a reason |
| `reading-overrides-by-position.tsv` | The same for one word in one line, named by dialogue slug, line number and word position (counted over the line's written words from 1) and the written word, because one spelling can need a different reading in a different line (`voi`, `tule`, `lisää`). A key that matches no word fails the import |
| `manual-readings.tsv` | Made by the importer: every word whose reading Voikko does not offer, with its place, its form name and the reason. Do not edit by hand |
| `glossary.tsv` | The English meaning of each dictionary form (`lemma_meaning_en`) |
| `word-notes.tsv` | The own meaning (`meaning_en`) and the one line "why" of each form that is not an unchanged dictionary form |
| `needed-notes.tsv` | Made by the importer: every form still missing a text, with its first line. Do not edit by hand |
| `road-report.md` | Made by the importer: for each stop each check's rate, the spoken only words, the pairs accepted by the table, the extras recorded and the number of forms; for each part the extras allowed |
| `fixes.md` | Every change made to Claude's markdown after a failing run, with the text before, the text after and the reason |

### What the importer checks

`python scripts/generate/road_import.py import --out <folder>` reads the curriculum and the six part files. It refuses, naming the file, the stop and the line, a row with an empty cell, a stray pipe, a line number out of order, a stop without its `**I can:**` line and a dialogue count that is not 3 once the six earlier drafts are counted. It then:

- maps each spoken word to the written word it renders, in order (`scripts/generate/road_mapping.py`). A pair is accepted when the words are equal ignoring case, or are in `spoken-forms.tsv`, or one ending rule applies (a dropped final letter, a dropped final vowel with a shortened double consonant, a stretched final vowel such as `euroo` for `euroa`, `-ks` for `-ko`, or a possessive ending left out after `mun`, `sun`, `meidän`, `teidän` or `sen`). Any other pair fails the line with both words named. A written word no spoken word renders fails the line. A spoken only word is accepted only as a filler. A spoken pronoun must pair with a written pronoun, so a line whose written version drops it gets the pronoun added in the markdown (a logged repair).
- splits a spoken word glued to `sä` after a verb (`Ootsä`, `Puhutsä`) into two words for the checks and the word cards, by one rule. The line is shown as written: only the tokens are two words.
- asks Voikko about every written word and chooses one of its readings by fixed rules: an override (the position file first, then the spelling file; a `manual` row is a reading Voikko lacks, and the checks accept it only for its own spelling), a name for a capital in the middle of a sentence, a reading that fits the stop's level, then the more common word. The lemma of a form is Voikko's base form of the written word the spoken word is paired with, because Voikko cannot analyse spoken Finnish.
- runs job 7's checks unchanged. A form outside the stop's grammar list or a word outside the level fails unless it is recorded in `allowed-extras.json`.
- writes `content/drafts/<slug>/draft.json` in the `puhuscribe-draft-1` format with `providers` set to `{"ai": "written", "judge": "off"}`, or `"judge": "on"` after the judge ran.

No AI call is made and no network is needed. A written draft says `"notes": "pending"` while some form still lacks a meaning or a why; such a draft passes the checks but cannot be approved or published, and the database would refuse the form.

### The register judge

It is off unless the owner turns it on. With it off the report says `register judge: not run`, never `passed`. `python scripts/generate/road_import.py judge` runs the golden set first (it must pass), then the judge on every line without a current verdict, logs every call with its cost and stops a run that reaches $2. A verdict is tied to the line's analysis text, so a changed line needs a new verdict.

### Running it on GitHub

The manual workflow "A1 road" (`.github/workflows/a1-road.yml`) has the tasks `import`, `analyse`, `count-characters`, `voice` (input part 1 to 6, optional `only` for one dialogue), `judge` and `review-pages`. It needs Linux with Voikko, so it runs on GitHub. `voice` is the only step with the Azure key and `judge` the only step with the Anthropic key. Voiced clips, changed drafts and reports come back as an artifact; the manager commits them once, under `content/drafts/<slug>/audio/`. `python scripts/generate/road_import.py count-characters` prints the exact number of characters a part needs; a run refuses to start when this month's logged characters plus the new ones would pass 450,000 (90 percent of the free allowance). Azure's free tier allows 20 requests a minute, so a part of about 270 clips takes about 15 minutes.

The manager commits the voice log (`content/logs/ai-calls.jsonl`) after every voice run and before the next one. The Azure character guard (450,000 a month) adds up the characters in that log as the checkout holds it, so a run whose log was never committed would be forgotten by the next run on a fresh checkout. The `voice` task therefore refuses to start when the log in the working tree has changes git does not hold. The free tier itself refuses calls past 500,000 characters and `voice.py` refuses any other tier, so this is a rule about the guard, not about money. A wait that Azure asks for (`Retry-After`) is never longer than 60 seconds.

One form id carries the same texts in every draft. Where the road and one of the six earlier drafts share a form, the road files (`glossary.tsv`, `word-notes.tsv`) win and the importer writes their texts into the earlier draft's form; the earlier drafts' lines, tokens, clips and the other forms' why lines are not touched. A publish migration no longer inserts a form with `on conflict do nothing`: it inserts a missing form and refuses an existing one that is not approved or has other texts, naming the form and both texts, and `publish-part` makes the same check against the form inserts of the migrations already in the repository before it writes anything.

### The owner's approval and publishing

The owner approves each part in writing. The manager adds `content/approvals/part-<n>.json` (see [data-model.md](data-model.md#the-owners-approval-file)). `python scripts/generate/pipeline.py publish-part --part <n>` then writes one migration per dialogue in stop and dialogue order, with explicit timestamps one minute apart after every migration on main, and copies the clips to `public/audio/`. It refuses, naming every reason, and writes nothing, when the approval file is missing, a dialogue is not listed or its fingerprint differs, a check fails, a clip is missing or fake, word notes are missing, the judge's state differs or a dialogue of the part fails. The unit row is made from `road_stops`, and the stop is approved only in the migration of its last dialogue.

### How a reviewer's fix comes back

The review pages are made on request: `python scripts/generate/pipeline.py review-pages --part <n>`. Each word card shows the base form and its meaning, the form name, its meaning here and the "why". The reviewer's file goes to `content/reviews/<slug>/round-<n>.json` as for any dialogue. `python scripts/generate/pipeline.py road-next-round --draft content/drafts/<slug>` writes each accepted fix into the exact markdown cell, imports and checks the dialogue again, voices only the changed lines and writes `supabase/migrations/<timestamp>_fix_<slug>_round_<n>.sql`. In one transaction the migration sets the dialogue back to draft, replaces the changed lines, their words and their audio keys, approves any new forms, then approves the lines and the dialogue with the references `content/reviews/<slug>/round-<n>.json#line-<k>`. The old references stay in `private.approval_history`, so they cannot be used again. A new form that needs texts stops the command with a list for `needed-notes.tsv`. A reviewer who approves a live line changes nothing in the database; the file in `content/reviews/` is the record that a native speaker saw it.

## Where each file lives

| Path | What |
| --- | --- |
| `content/briefs/<dialogue-slug>.json` | The brief for one dialogue |
| `content/drafts/<dialogue-slug>/` | The draft, its check report, its audio and its review pages |
| `content/reviews/<dialogue-slug>/` | The reviewer's returned files, one per round |
| `content/recordings/<dialogue-slug>/<line>-<register>.mp3` | A native recording that replaces the synthetic clip for that line and register (`puhe` or `kirja`) |
| `content/checks/thresholds.json` | The PRD section 8 thresholds the checks use |
| `content/checks/judge-golden-set.json` | The 20 pairs the register judge is proven on |
| `content/logs/ai-calls.jsonl` | One line per AI call or voice synthesis, with its cost |
| `supabase/migrations/<timestamp>_publish_<dialogue_slug>.sql` | The publish migration |
| `public/audio/<key>` | The published audio, served by the app at `/audio/<key>` |
| `scripts/generate/providers/ai.py` | The only file that calls an AI service |
| `scripts/generate/providers/voice.py` | The only file that calls a voice service |
| `scripts/generate/pipeline.py` | The command line |

Nothing under `content/` reaches the built app; only `public/` does. `tests/content-audio.test.ts` checks this.

## The brief

Example: `content/briefs/meeting-people-new-colleague.json`. Every field is needed; the pipeline refuses a brief with a missing one and names it.

| Field | What |
| --- | --- |
| `unit` | `slug`, `position`, `title_en` and the A1 "can do" statement `can_do_en` |
| `dialogue` | `slug`, `position` in the unit and `title_en` |
| `situation_en` | The situation, in English |
| `grammar` | The unit's grammar list, as ids from `GRAMMAR_CATALOGUE` in `scripts/generate/grammar.py` |
| `rank_cap` | The highest frequency rank a base form may have (`data/finnish_frequency_lemmas.json`) |
| `extra_base_forms` | Base forms allowed even above the rank cap |
| `speakers` | Each speaker's `name`, English `role_en` and Azure `voice` (`fi-FI-NooraNeural`, `fi-FI-HarriNeural` or `fi-FI-SelmaNeural`) |
| `line_count` | 4 to 8 |

Dictionary forms (nominative singular, the basic form of a verb, words that do not inflect) count as on every grammar list. Everything else needs an entry. Unit 1's entries are `olla-present`, `personal-pronouns`, `inessive-elative` and `question-clitic`. Unit 2 adds `partitive-singular`, `numbers-1-20` and `saisinko`; unit 3 adds `missa-on`, `adessive-allative` and `tuolla-tassa` (job 12-units-1-3). A brief's list holds its own unit's entries and every earlier unit's. Later units add theirs to `GRAMMAR_CATALOGUE`.

## The checks

All run offline. Thresholds are in `content/checks/thresholds.json`.

| Check | Rule | Threshold |
| --- | --- | --- |
| Word validity | Every written word analyses in Voikko through v2's `VoikkoGate` | 100 percent |
| Word order | Each word's text appears in order in its line, and the words cover the line | 100 percent |
| Spoken links | Every spoken word renders exactly one written word or is marked spoken only; every written word is rendered once | 100 percent |
| Level fit | Every written base form apart from names is inside the rank cap or on the extra list; every form is on the grammar list | 100 percent |
| Grammar cards | Each form is one of Voikko's own readings; its name comes from the tag table; its "why" is one line of at most 140 characters naming no other grammar term | 100 percent |
| Register faithfulness | The AI judge says the spoken and written versions mean the same, and no line changed after it was judged | 98 percent, which with 4 to 8 lines means every line |

The judge is proven on the golden set with `python scripts/generate/pipeline.py judge-golden --out <file>`: it must catch all 10 pairs with a planted change of meaning and accept at least 9 of the 10 faithful pairs. The reviewer's approval of every line covers the PRD's "100 percent on the reviewed sample".

## The form tag

A form tag is built only from one Voikko reading: these attributes, in this order, as `KEY=value` joined by `;`, leaving out any the reading does not have.

`CLASS`, `SIJAMUOTO`, `NUMBER`, `PERSON`, `MOOD`, `TENSE`, `NEGATIVE`, `POSSESSIVE`, `COMPARISON`, `PARTICIPLE`, `KYSYMYSLIITE`, `FOCUS`

For example "olen" is `CLASS=teonsana;NUMBER=singular;PERSON=1;MOOD=indicative;TENSE=present_simple;NEGATIVE=false`, and its English name, from the table in `scripts/generate/grammar.py`, is "present tense, 1st person singular". The full reading also goes in `forms.analysis`. Fields such as `STRUCTURE` and `FSTOUTPUT` differ between Voikko versions and are left out of the tag. A Voikko value the table does not know fails the check instead of being guessed. To see Voikko's readings of a word: `python scripts/generate/show_readings.py olen`.

## Audio

Both registers of every line are read by the speaker's Azure voice in `audio-24khz-48kbitrate-mono-mp3`. A native recording at `content/recordings/<dialogue-slug>/<line>-<register>.mp3` replaces the synthetic clip; the review page marks it "Native recording". When the reviewer marks a clip "sounds wrong", the next round waits until that recording exists.

The audio key is `<dialogue-slug>/<line number>-<register>-<first 12 characters of the file's SHA-256>.mp3`, for example `meeting-people-new-colleague/1-puhe-0123456789ab.mp3`. Publishing copies each approved clip to `public/audio/<key>`, and the app plays it at `/audio/<key>`. `tests/content-audio.test.ts` checks that every file there is named by a published key, that its SHA-256 matches its name, and that every published key has its file.

## The review page and the review file

`review/round-<n>.html` is one self contained page: it opens from disk and loads nothing from the network (the audio is inside the file). For each line it shows the speaker, the spoken and written text with a play button each, and the English meaning; for each word card the base form, the form name and the "why". Each item has Approve, Fix (with a box for the corrected text) and a comment box; each clip has "Sounds right" or "Sounds wrong"; the dialogue as a whole has one choice, "I approve this dialogue as a whole" or "Not yet"; the reviewer writes a reviewer code such as `R1`, never a name or email. "Download my review" saves `review-<dialogue-slug>-round-<n>.json`. A reviewer who marks anything Fix or Sounds wrong answers "Not yet" and sees the dialogue again in the next round; "Not yet" with nothing to change is refused, so no file carries a false approval. The page is tested in the Chrome and Safari engines (Chromium and WebKit), including at phone width; Firefox has not been tested. Nothing is saved until the download, and the page says so.

Each item in the file carries the content fingerprint (a SHA-256 of its content) the reviewer saw. The pipeline refuses a file, with a plain reason, when an item is missing, a fingerprint does not match the page, a decision is missing, a clip is marked "sounds wrong" without its native recording, or the reviewer code is empty. `review/round-<n>.json` next to each page lists the items and fingerprints that page asked about.

## Publishing

Publishing writes nothing unless every check passes, the latest review file has no open fix, and every current line, word card, clip and the dialogue as a whole is approved at its current fingerprint (the dialogue in the latest round). Drafts and audio from the fake providers are refused.

The migration follows the order in [docs/data-model.md](data-model.md): forms, then lines with their words, then the dialogue, then the unit. Each `approval_ref` is the review file path plus the item id, for example `content/reviews/meeting-people-new-colleague/round-1.json#line-3`. The unit's reference is the dialogue's. When the dialogue is already published the migration does nothing, so running it twice changes nothing; the database check runs every `*_publish_*.sql` a second time to prove it. `supabase/tests/database/content_publish.test.sql`, made by `python scripts/generate/fixture_outputs.py`, runs a made up fixture's publish migration twice and reads the result as a learner.

No pipeline database role exists. Content reaches the database only through these migrations, which the workflow applies to the test project when the owner approves a merge.

## Cost per dialogue

Every call is in `content/logs/ai-calls.jsonl` with its cost, from the dated price tables in `scripts/generate/providers/ai.py` and `scripts/generate/providers/voice.py`.

| Item | Price | Per dialogue |
| --- | --- | --- |
| Claude Opus 5.5, drafting and "why" lines | $4 per million input tokens, $20 per million output tokens (Anthropic pricing page, 21 October 2026) | About $0.24 with three drafting rounds (estimate) |
| Claude Sonnet 5.5, the judge | $2 and $10 per million | About $0.01 (estimate) |
| Total | | About $0.25 per dialogue (estimate, the same figure as the README) |
| Azure neural voices | Free allowance of 0.5 million characters a month | Under 1,000 characters, €0 |

Measured on 29 October 2026, GitHub run 40938246825 for `grocery-store-directions`: $0.16 for 15 logged calls, Azure inside the free allowance. An earlier run the same day (40937712893) missed one grammar form, so its pack was not committed.

## Units 1 to 3

Job 12-units-1-3 drafted the first six dialogues, two per unit, with the real workflow. Five runs came from the old private repository and cannot be opened from this one. The sixth was drafted on 29 October 2026 in this repository. All six wait, unpublished, for the native reviewer's batch at the end of the MVP; the cover note for the reviewer is `content/review-batches/mvp-batch-1.md`.

| Unit | Brief | Workflow run | Logged cost |
| --- | --- | --- | --- |
| 1 | `content/briefs/meeting-people-new-colleague.json` (job 7's) | 39727012637 (old private repository, cannot be opened from here) | $0.14 |
| 1 | `content/briefs/meeting-people-language-cafe.json` | 39740774570 (old private repository, cannot be opened from here) | $0.30 |
| 2 | `content/briefs/ordering-coffee-at-the-counter.json` | 39741173183 (old private repository, cannot be opened from here) | $0.20 |
| 2 | `content/briefs/ordering-coffee-paying.json` | 39741665671 (old private repository, cannot be opened from here) | $0.21 |
| 3 | `content/briefs/grocery-store-asking-staff.json` | 39742255590 (old private repository, cannot be opened from here) | $0.12 |
| 3 | `content/briefs/grocery-store-directions.json` | [40938246825](https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/40938246825) (head 8006d5a, the committed pack, commit 2869c04). An earlier run, [40937712893](https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/40937712893) (head 0acaa49), passed the pipeline but its pack was not committed: the unit 3 grammar test failed because the to-the-place form of adessive-allative, part 2, was in no written word, so the brief was changed to ask for the to-form. | $0.29 (both runs) |

Cost per unit, measured from the log: unit 1 $0.43, unit 2 $0.41, unit 3 $0.40, total $1.25. Azure voices cost €0 on the free tier. To sum the log per dialogue and per unit: `python scripts/generate/log_costs.py`.

`scripts/generate/test_units_1_3.py` checks the six briefs, that each unit's grammar shows up in its two drafts, and that every draft, clip and log line is in place.
