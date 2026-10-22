# Content pipeline

How a Finnish dialogue is made, checked, reviewed by the native reviewer and published. Built in job 7-content-pipeline; the decision and its alternatives are in [factory/jobs/7-content-pipeline/spec.md](../factory/jobs/7-content-pipeline/spec.md#decision).

A short brief goes in. Claude drafts the dialogue in spoken Finnish (puhekieli) and written Finnish (kirjakieli) with an English meaning. Voikko checks every written word. Automatic checks run. Azure voices read both versions. The native reviewer approves or corrects every line, word card and clip in one page file and sends back a small file. Only then does the pipeline write the database change and copy the audio into the app. Nothing reaches a learner without the reviewer's file, and the database refuses anything unapproved.

## Running it

The pipeline is Python in `scripts/generate/` and needs Linux with Voikko, so it runs in the manual GitHub workflow "Content pipeline" (`.github/workflows/content-pipeline.yml`). It never runs on a pull request or a push.

1. Write a brief in `content/briefs/` (see below), commit it and push.
2. On GitHub, open Actions, choose "Content pipeline", "Run workflow", task `draft`, and the brief path, for example `content/briefs/meeting-people-new-colleague.json`.
3. When it finishes, download the `review-pack` artifact from the run page. If a check still failed after three drafting rounds, the run is red, its log lists every failing word or line, and there is no review page.
4. Commit the pack as `content/drafts/<dialogue-slug>/`: `draft.json`, `check-report.json`, `audio/`, `review/` and `run.log`. Add the lines of its `ai-calls.jsonl` to `content/logs/ai-calls.jsonl`.
5. The owner sends `review/round-1.html` to the native reviewer (nothing is sent automatically).
6. The reviewer's returned file goes to `content/reviews/<dialogue-slug>/round-1.json`. Only the manager adds files there, on the owner's instruction.
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

The estimates are replaced by the measured cost after the first real run.

## Units 1 to 3

Job 12-units-1-3 drafted the first six dialogues, two per unit, with the real workflow. They wait, unpublished, for the native reviewer's batch at the end of the MVP; the cover note for the reviewer is `content/review-batches/mvp-batch-1.md`.

| Unit | Brief | Workflow run (earlier private repository) | Logged cost |
| --- | --- | --- | --- |
| 1 | `content/briefs/meeting-people-new-colleague.json` (job 7's) | 39727012637 | $0.14 |
| 1 | `content/briefs/meeting-people-language-cafe.json` | 39740774570 | $0.30 |
| 2 | `content/briefs/ordering-coffee-at-the-counter.json` | 39741173183 | $0.20 |
| 2 | `content/briefs/ordering-coffee-paying.json` | 39741665671 | $0.21 |
| 3 | `content/briefs/grocery-store-asking-staff.json` | 39742255590 | $0.12 |
| 3 | `content/briefs/grocery-store-directions.json` | not drafted yet: GitHub did not start run 39742994155 (an account billing block), and the public repository needs its pipeline secrets first | $0.00 |

Cost per unit, measured from the log: unit 1 $0.43, unit 2 $0.41, unit 3 $0.12 so far. Azure voices cost €0 on the free tier. To sum the log per dialogue and per unit: `python scripts/generate/log_costs.py`.

`scripts/generate/test_units_1_3.py` checks the six briefs, that each unit's grammar shows up in its two drafts, and that every draft, clip and log line is in place.
