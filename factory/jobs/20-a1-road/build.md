# Build notes: job 20-a1-road, round 5 (fixes from the security and design reviews)

Branch `factory/20-a1-road` (pushed, no pull request, not merged). Round 5 starts from cfe05ac, where the manager rewrote 225 word note rows. I did not change those texts. Both review files, `factory/jobs/20-a1-road/review-security.md` (pass, two should fix) and `factory/jobs/20-a1-road/review-design.md` (changes needed, all in the word card texts), are committed with this work. Rounds 4, 3, 2 and 1 follow in short form.

## What I built, in plain English

- **hitaammin (design item 4).** A manual reading by position for `sorry-i-didnt-understand`, line 4, word 5: dictionary form `hidas`, form name "comparative, adverb" (tag `CLASS=seikkasana;COMPARISON=comparative`), like `vähemmän`. Voikko only offers the instructive plural.
- **en voi.** A manual reading by position for "Minä en voi syödä maitotuotteita" (`is-there-milk-in-it`, line 3, word 3): `voida`, "present tense, negative form". The third person rows of `voi` (form-fc6219c3121b) stay the verb, as the manager asked.
- **Design item 5 ("Voi ei!"), confirmed.** No cry uses form-fc6219c3121b. All 12 words `Voi` that are the cry (for example `Voi ei`, `Voi harmi`, `Voi anteeksi`) use the interjection row. Form-fc6219c3121b is now used by exactly two lines, both the verb: "Lääkäri voi nähdä sinut" (`booking-a-visit` 7) and "Milloin hän voi tulla?" (`a-broken-washing-machine` 6). A test fixes this.
- **Security should fix 1, the approval fingerprint.** `road_fingerprint` in `scripts/generate/road_publish.py` now also covers each line's speaker, the SHA-256 of each of the two clips, which written word links to which form, and which spoken word renders which written word. A clip voiced again, a swapped speaker or a moved word link after the owner approved now makes publishing refuse ("changed after the owner approved it") and writes nothing.
- **Security should fix 2, the voice log.** The `voice` task now refuses to start when `content/logs/ai-calls.jsonl` has changes git does not hold (changed, staged or new), because the character guard counts what the checkout holds. The workflow file's comment and `docs/content-pipeline.md` say that the manager commits the voice log after every voice run and before the next one. Outside a git working tree (a temporary folder in a test) the check does nothing.
- **Retry-After.** A wait that Azure asks for is cut to 60 seconds at most (`MAX_RETRY_WAIT_SECONDS` in `scripts/generate/providers/voice.py`), the same as the back off.
- **Import (part all).** `analyse` gave the same caps as before (2000, 2000, 2000, 2500, 2500, 1500). The import changed two words, the two above, and nothing else. The importer dropped the manager's row for the old hitaammin form (form-ba63b5995fe7, no longer used).

## The two word note rows

The import of round 5 left two forms without text (hitaammin as hidas and en voi as voida). The manager wrote both in 79f6eea. A final import (part `all`, run 41341183266) then gave 108 of 108 drafts with `"notes": "complete"`, 0 failures, no changed word and an empty `content/road/needed-notes.tsv`.

## Question from the manager: did the broken-guard test call Azure?

No. It used a fake and spent nothing. When I broke the voice log guard on purpose on this computer, the test gave `cmd_voice` a stand-in object (`types.SimpleNamespace`) as the voice provider, so no Azure provider was built, no key or region was read, and no network call was made (the Azure provider is only made by `voice_module.get_provider()`, which `cmd_voice` skips when a provider is passed). The stand-in wrote no log line either. So 0 characters were sent, and nothing needs adding to `content/logs/ai-calls.jsonl`: it is byte for byte what it was (`git diff 0315f11 HEAD -- content/logs` and the same for every `content/drafts/*/audio` folder are empty). What the broken guard did write was fake or empty audio files and `draft.json` edits into this working folder only; I restored them with `git checkout` before any commit, and none reached the branch. On GitHub the guard was never broken (the only break there was the fingerprint). The free tier is therefore untouched by this: the month's logged voice use stays at the sample's 507 characters of the 500,000 allowance (the log's own total this month), and the 450,000 stop line is unchanged.

## Which tests protect it

| Where | Tests |
|---|---|
| `scripts/generate/test_road_publish.py`, `[a1-road 20]` (2 new) | each of five edits alone (the `puhe` clip hash, the `kirja` clip hash, a speaker, a written word's form, a spoken word's link) changes the fingerprint and a copy does not; after approval each edit makes publishing refuse, naming the changed fingerprint, and nothing is written |
| `scripts/generate/test_road_voice.py`, `[a1-road 18]` (4 new) | a `Retry-After` of a day waits 60 seconds; a voice log that is new, or changed after it was committed, refuses (in a real temporary git repository), and a committed log passes; `cmd_voice` refuses before it voices; the workflow and the docs say the manager commits the voice log and when |
| `scripts/generate/test_road_readings.py`, `[a1-road 10]` (3 new) | hitaammin is hidas, "comparative, adverb"; en voi is voida, "present tense, negative form"; form-fc6219c3121b is used only by the two verb lines and every cry has the interjection row (12) |

The Python test count is 308 (set in `.github/workflows/checks.yml`).

## Check results

All on GitHub. The final run is on 724e0fb: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41339331848

| Check | Result |
|---|---|
| Type check, lint, format (`npm run check:code`) | passed |
| Unit tests (Vitest) | passed |
| Python lint and format (ruff) | passed |
| Python tests (308, real Voikko, no network, no skips) | passed |
| `pipeline.py check-committed` (all 108 drafts) | passed |
| Database tests (pgTAP, local Supabase) | passed |
| Browser tests (Playwright, local Supabase) | passed |
| Secret scan, dependency check | passed |

## Proof by breaking each protection

Details and test names are in `factory/jobs/20-a1-road/evidence/round5-red-proofs.txt`. Each break was made on its own and undone.

| Protection broken | Tests that went red |
|---|---|
| The clip hashes, the speakers, the written word links or the spoken word links left out of the fingerprint (4 local breaks) | `the_fingerprint_covers_each_clip_speaker_and_word_link`, each time |
| The whole fingerprint put back to round 4 (GitHub run 41339362359, real Voikko) | `a_changed_clip_speaker_or_word_link_voids_the_approval` and the fingerprint test |
| The voice log check does nothing, or does not see a new log (local) | `a_voice_log_with_uncommitted_changes_stops_the_voice_task` and `the_voice_task_refuses_before_it_voices...` |
| `cmd_voice` does not call the check (local) | `the_voice_task_refuses_before_it_voices_when_the_log_is_not_committed` |
| The `Retry-After` wait is not capped (local) | `a_retry_after_header_is_capped_at_60_seconds` |

While making these proofs, the test of `cmd_voice` showed a danger: with its guard broken, it voiced the real drafts with the fake provider into the working folder. I restored the folder at once (`git checkout` and removing the new audio folders) and changed the test so that it names no draft (`only="no-such-draft"`): a broken guard now voices nothing.

## Departures

1. **Statement 20 changes its wording.** It said the approval fingerprint is "a SHA-256 of every line's three texts and every form's texts". It is now a SHA-256 of every line's three texts and speaker, the hash of each line's two clips, the word links of both registers, and every form's texts. Voicing a line again therefore voids that dialogue's approval, and a new approval reference is needed (the security review's finding 1, the manager's decision).
2. **Statement 18 gains a rule.** The voice task refuses to start when the voice log in the working tree has uncommitted changes (the security review's finding 2). The process rule that the manager commits the log after every voice run and before the next is in the workflow comment, `docs/content-pipeline.md` and here.
3. **Two more manual readings** (hitaammin and en voi), so `content/road/manual-readings.tsv` now has 135 rows.

## Not changed, from the reviews

- **Security notes 1 and 3 to 10.** Actions are pinned by tag like the other workflows (note 1), the judge limit can overshoot by a cent (note 4), a manual reading widens Voikko's check in the open, so the owner should read `manual-readings.tsv` before approving (note 5), the visitor road function can be called repeatedly (note 7), a stale cookie stays after an ended session (note 8), and the approval file is only a process lock (note 10). Note 3, the `Retry-After` cap, is done. None of the others was asked for.
- **Design items 6 to 10 and the notes** are word card texts and form names, the manager's. The review says the form names of participles ("past active participle, nominative singular") are correct but heavy for a beginner. They come from the manual readings, chosen on purpose.

---

# Rounds 4 and 3 in short

**Round 4 (statement 29, visitors read the road).** The manager's amendment is statement 29 in `spec.md` (the 401 wording of statement 7 is marked replaced). `public.road_for_visitors()` (migration `20261101120200_road_for_visitors.sql`) returns the 14 columns of `road()` with `dialogues_done`, `review_forms_reviewed` and `lessons_done` always 0. It takes no user, counts approved content only, is `security definer` with an empty search path and `stable`, and is granted to `anon` for that function only. `GET /api/road` with no session, or an expired or invalid one, answers 200 with those rows (no account, no Auth call, no write, no cookie); a signed in learner still gets `road()`; a fault is a 503 with no detail. 6 Worker tests replaced the old 401 test, 20 pgTAP checks were added (123 in all), each protection was broken on purpose (`evidence/round4-red-proofs.txt`). Final checks run 41335613077, all green. A visitor answer after an ended sign in drops the cookie clearing, as statement 29 says no cookie.

**Round 3 (aliases, minä, caps).** `content/road/list-aliases.tsv` (8 rows with a reason each: `paljon` to `paljo`, `todella` to `tosi`, `liian` to `liika`, `usein` to `usea`, `oikein` to `oikea`, `varmaan` to `varma`, `tietysti` to `tietty`, `myöhemmin` to `myöhä`) gives a word the rank of its list form in the importer and in every `check_draft` run. One spelling row makes all 179 `minä` the pronoun. Parts 1, 2, 3 and 6 returned to their round 1 caps; parts 4 and 5 could not (stops 23, 26 and 28 kept more than 15 extra words at cap 2000) and by the manager's decision are at 2500, the rule's own result. Final caps 2000, 2000, 2000, 2500, 2500, 1500 (round 2 without aliases had 2500, 2500, 2000, 4000, 4000, 1500). 5 tests (`[a1-road 10]`), red proofs in `evidence/round3-red-proofs.txt`, final checks 41334188420 all green, every draft complete at that time.

# Round 2 in short (readings that did not fit the line)

The manager's 164 reading flags (`factory/jobs/20-a1-road/reading-flags.tsv`) were applied: 150 rows accepted (102 form rows as flagged, 13 with a small change in wording, 35 lemma rows), 13 accepted for some lines only (5 form rows and 8 lemma rows, where the flag was wrong for the other lines), 1 rejected (`tulossa`: Voikko's noun `tulo` is right, the MA-infinitive of tulla is `tulemassa`). The decision for every row is in `factory/jobs/20-a1-road/evidence/round2-flag-decisions.tsv`. 488 of the 497 flagged words changed, plus 10 words from lemma rows the form rows did not list, 498 in all.

What was built: `content/road/reading-overrides-by-position.tsv` (one word in one line, keyed by dialogue slug, line and word position), a `voikko` or `manual` source and a reason on every row of both override files, `ManualReadingGate` (job 7's checks accept a manual reading for its own spelling only), stale keys as an import failure, and `content/road/manual-readings.tsv` (made by the importer). 11 tests in `scripts/generate/test_road_readings.py`; each protection was broken on purpose and went red (`factory/jobs/20-a1-road/evidence/round2-red-proofs.txt`, with GitHub runs 41327962899 and 41327966107). Round 2 runs: final checks 41327917649, imports 41326768502, 41327137277 and 41327308210, analysis 41326553911, probe of Voikko's readings 41325913527.

Departures from round 2 that still stand: manual readings exist (133 words, listed below); the negative form is named "present tense, negative form" because the name is built from the tag; `kuusi` is a spelling row pinning the number six; Voikko's own reading was used for `ilman` (adposition), `tiistaisin` and `omakannasta` (`omakanta`); the override files are not listed in `content/road/fixes.md` because every row has its own reason.

Seen and not changed in round 2, still open: four forms after a negation keep the plain present or conditional reading because Voikko's tag already allows the negative (`Perjantai ei käy`, `Minä en voi syödä`, `Ei olisi tarvinnut`, `Ei pitäisi`).

## Manual readings (133 words, 54 combinations; exact places in `content/road/manual-readings.tsv`)

| Written word | Dictionary form | Form name | Times | Reason |
| --- | --- | --- | --- | --- |
| asunut | asua | past active participle, nominative singular | 2 | lemma should be asua, not asunut |
| erikseen | erikseen | adverb | 2 | 'erikseen' is the adverb 'separately' |
| etukäteen | etukäteen | adverb | 1 | the adverb 'in advance' |
| kenen | kuka | genitive singular | 1 | kenen is the form of kuka; ken is old-fashioned |
| kestä | kestää | present tense, negative form | 5 | Ei kestä is the negative form, not an order |
| kotona | koti | essive singular | 5 | kotona is at home, from koti |
| kovin | kovin | adverb | 1 | means very |
| kuulemiin | kuulemiin | interjection | 3 | fixed phone goodbye |
| käynnisty | käynnistyä | present tense, negative form | 1 | after ei: negative form, not a command |
| käynyt | käydä | past active participle, nominative singular | 2 | dictionary form should be the verb käydä |
| lapseni | lapsi | genitive singular, with the possessive ending for my | 1 | with kanssa: genitive, not nominative |
| lapseni | lapsi | nominative plural, with the possessive ending for my | 3 | my children (spoken mun lapset) |
| laske | laskea | present tense, negative form | 1 | after ei: negative form, not a command |
| leikkaa | leikata | imperative present tense, 2nd person singular | 1 | a command: cut them |
| lennä | lentää | present tense, negative form | 1 | en lennä = I'm not flying |
| lisää | lisätä | imperative present tense, 2nd person singular | 1 | lisää vettä = add water |
| luonani | luona | adverb, with the possessive ending for my | 2 | luona = at; luokse = to |
| löydä | löytää | present tense, negative form | 1 | en löydä is the negative form |
| mahtavaa | mahtava | partitive singular | 3 | plain adjective 'fantastic' |
| malta | malttaa | present tense, negative form | 1 | after en: negative form, not a command |
| mieheni | mies | genitive singular, with the possessive ending for my | 1 | with kanssa: genitive, not nominative |
| mukana | mukana | adverb | 1 | 'passi mukana' is mukana 'with you', its own adverb |
| neulomista | neulominen | partitive singular | 1 | noun 'knitting' from neuloa; not neuloma |
| näe | nähdä | present tense, negative form | 1 | en näe is the negative form |
| näkemiin | näkemiin | interjection | 2 | a goodbye word |
| ole | olla | present tense, negative form | 8 | Ei ole is the negative form |
| ollenkaan | ollenkaan | adverb | 2 | fixed adverb 'at all', not a form of olla |
| ollut | olla | past active participle, nominative singular | 2 | 'olet ollut kipeä' is 'you have been ill' |
| osaa | osata | present tense, negative form | 2 | en osaa = I can't, verb osata |
| paljon | paljon | adverb | 17 | kiitos paljon, a lot |
| paljonko | paljon | adverb, with the question ending -ko/-kö | 7 | how much: paljon plus -ko |
| parasta | paras | partitive singular | 1 | paras = best; parka = poor thing |
| pitänyt | pitää | past active participle, nominative singular | 1 | dictionary form should be pitää |
| pääsekään | päästä | present tense, negative form, with -kaan/-kään | 1 | en pääsekään is the negative form, not an order |
| sattunut | sattua | past active participle, nominative singular | 1 | dictionary form should be the verb sattua |
| sovittu | sopia | past passive participle, nominative singular | 1 | dictionary form should be the verb sopia |
| suljettu | sulkea | past passive participle, nominative singular | 1 | dictionary form should be the verb sulkea |
| takaisin | takaisin | adverb | 4 | means back (change back) |
| tarvinnut | tarvita | past active participle, nominative singular | 1 | lemma should be tarvita, not tarvinnut |
| tarvitse | tarvita | present tense, negative form | 3 | 'Ei tarvitse' is the negative, not a command |
| tiedä | tietää | present tense, negative form | 1 | en tiedä = I don't know |
| tiennyt | tietää | past active participle, nominative singular | 1 | dictionary form should be the verb tietää |
| tietysti | tietysti | adverb | 2 | the adverb 'of course' |
| todella | todella | adverb | 22 | means really |
| toimi | toimia | present tense, negative form | 2 | 'ei toimi' is 'doesn't work', present |
| tule | tulla | present tense, negative form | 1 | ei tule = won't come, not a command |
| usein | usein | adverb | 1 | the adverb 'often' |
| vanhempani | vanhempi | nominative plural, with the possessive ending for my | 1 | parents, not 'older' |
| varmaan | varmaan | adverb | 1 | adverb 'probably', not varma 'into sure' |
| varovainen | varovainen | nominative singular | 1 | plain adjective 'careful', not a participle |
| viikkosi | viikko | genitive singular, with the possessive ending for your | 1 | object of muistatko: genitive, not nominative |
| vähemmän | vähän | comparative, adverb | 1 | adverb 'less'; genitive singular is wrong |
| ymmärrä | ymmärtää | present tense, negative form | 1 | 'en ymmärrä' is the negative, not a command |
| ymmärtänyt | ymmärtää | past active participle, nominative singular | 1 | dictionary form should be the verb ymmärtää |

## Earlier rounds (short)

Round 1 (commit 9fbb60b, all GitHub checks green on run 41321561654): the road in the database (`road_parts`, `road_stops`, `road()`, `stop_review_forms`, `GET /api/road`), the importer and its checks for all 108 dialogues, the register judge run once ($0.66), the voice throttle and one voiced sample, the owner approval file and the publisher, the fix path after launch, and the paged Worker reads. Its full text, the red proofs with their run numbers (41320564222 to 41320746506, in `factory/jobs/20-a1-road/evidence/red-proofs.txt`), and the numbers it reported (51,597 voice characters, about 88 MB of audio and migrations at publish) are in `git show 9fbb60b:factory/jobs/20-a1-road/build.md`. The interface for job 19-redesign, `public.road()` and `GET /api/road` with its 14 keys, has not changed.

Round 1 departures that still stand: the six earlier drafts keep their old unit block; `noi` has the lemma `nuo`; glued `Ootsä` is one word in the text and two in the tokens; `present-tense` is a catalogue entry at stop 1; the six earlier drafts disagree on the why line of 25 shared forms; `judge` and `voice` take `--part`; the road's seed numbers are zero until a part is approved. Round 1 run links: import 41321298577, analyse 41317041041, judge 41318417132, 41319745436 and 41320245477, voice sample 41317587713, count-characters 41317789817.

Result: checks pass
