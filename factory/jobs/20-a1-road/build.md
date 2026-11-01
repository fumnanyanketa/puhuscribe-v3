# Build notes: job 20-a1-road, round 2 (readings that did not fit the line)

Branch `factory/20-a1-road` (pushed, no pull request, not merged). Round 2 is the manager's rework note: fix the Voikko misreadings listed in `factory/jobs/20-a1-road/reading-flags.tsv`, then run the full import. It starts from f82ab95 (the manager's word notes). Round 1 is summarised at the end.

## What I built, in plain English

- **A reading for one word in one line.** The importer already had `content/road/reading-overrides.tsv`, one reading per spelling. The same spelling needs different readings in different lines (`voi`, `tule`, `lisää`, `maksaa`), so there is now `content/road/reading-overrides-by-position.tsv`. A row names the dialogue, the line, the word's place in the line (counted over the written words from 1) and the written word. The position row wins over the spelling row. Both files use the same columns for the reading: dictionary form, form tag, `voikko` or `manual`, and a reason.
- **Two kinds of row, kept honest.** A `voikko` row must name one of Voikko's own readings of that word. A `manual` row is for a reading Voikko does not offer (a fixed adverb, a greeting, the negative form), and it must not be one Voikko does offer. The importer refuses a row of the wrong kind, so the manual list stays a list of what Voikko really lacks. A manual row can never be a name. Nothing here uses AI.
- **The checks accept a manual reading, for its own spelling only.** Job 7's checks, unchanged, accept a form only if it is one of the gate's readings. `check_draft` now gives them a gate that adds the manual readings written for that spelling (`ManualReadingGate` in `scripts/generate/road_checks.py`) and passes everything else through. No check, threshold or other test was edited.
- **Stale rows are an import failure.** A position row whose dialogue, line or word position does not exist, or whose word differs from the word written there, and a spelling row no dialogue uses, are listed in the import log and fail the run and a test.
- **A list of what was written by hand.** The importer writes `content/road/manual-readings.tsv` (place, word, dictionary form, form tag, form name, reason for every word whose reading Voikko lacks) and a test compares the committed file with what the importer makes.
- **The corrections.** 47 spellings and 252 single words carry a reading in the two files (`content/road/reading-overrides.tsv`, `content/road/reading-overrides-by-position.tsv`). The import changed 498 words of 3,868 in the 102 written drafts and nothing else (checked: every changed word is covered by a row, no unplanned change). 133 of those words carry a manual reading.
- **The import was run again on GitHub** (task `import`, part `all`, from a scratch branch). The word notes were rebuilt by the importer: texts of unchanged form ids and dictionary forms are exactly the manager's, rows for forms and dictionary forms that no longer exist are gone, and new forms have empty rows.

## What was decided for each flag

The decision for every row of `reading-flags.tsv` is in `factory/jobs/20-a1-road/evidence/round2-flag-decisions.tsv` (what was asked, what was done, how many lines changed, why). In short:

| | Rows | |
|---|---|---|
| Form rows accepted as flagged | 102 | |
| Form rows accepted, with a different reading than the flag wrote | 13 | see below |
| Form rows accepted for some lines only | 5 | `voi` (two forms), `tule`, `lisää`, `maksaa` |
| Form rows rejected | 1 | `tulossa` |
| Lemma rows accepted | 35 | |
| Lemma rows accepted for some forms, the others are right as they were | 8 | `ilma`, `sata`, `tuoda`, `se`, `kuu`, `koe`, `lisä`, `osa` |
| Lemma rows rejected | 0 | |

So 164 rows, 150 accepted as asked or with a small change in wording, 13 accepted in part and 1 rejected. 488 of the 497 flagged words changed, and 9 stayed because the flag was wrong for them (below).

**Rejected.** `tulossa` ("Selvä, tulossa!", form 7eae52). The flag asks for the MA-infinitive of tulla. The MA-infinitive inessive of tulla is `tulemassa`. `tulossa` is the inessive of the noun `tulo` (on its way), which is what Voikko reads, so the card would have named a form the word is not. Voikko's reading stays and the meaning note already written for this form still fits.

**Accepted for some lines only, where the flag was wrong for the others.**

- `voi` (fc6219, 12 lines). 10 are the cry. `Lääkäri voi nähdä sinut` is the verb voida and `Minä en voi syödä` is voida after en (Voikko's own tag already says it can also be negative). Both stay.
- `voi` (dc3e1f, 3 lines). `Voi anteeksi` and `Voi ei` are the cry. `Milloin hän voi tulla?` is the verb voida (the old imperative was wrong, the flag's cry is wrong too), so it is voida, present tense, 3rd person singular.
- `tule` (a2a7fb, 4 lines). Only `Hän ei tule päiväkotiin` is the negative form. `Tule vain`, `Tule sisään` and `Tule meidän mökillemme` are commands and stay imperative.
- `lisää` (aa8e1d, 4 lines). Only `lisää vettä` (add water) is the verb lisätä. The other three mean "more" (the noun lisä, partitive) and stay.
- `maksaa` (145f27, 6 lines). `Voinko minä maksaa kortilla` is the A-infinitive, as flagged. The other five (`se maksaa`, `paljonko se maksaa`) are present tense, 3rd person singular.

**Checked carefully, as the manager asked.** `uitteko` accepted as the past (the English says "did you swim", and `uitte` is the same in present and past). `tuulista` accepted (the partitive of tuulinen). `helpoin` accepted (the superlative of helppo). `mukana` accepted as its own adverb, a manual reading because Voikko only offers `mukaan`. `varovainen` accepted (the plain adjective, not the participle).

**Accepted with a different reading than the flag wrote.**

- Nine form rows the flag calls "negative form" or "negative form (connegative)" (`kestä` twice, `ole`, `löydä`, `näe`, `pääsekään`, `osaa`, `tiedä`, `lennä`), the one line of `tule`, and the seven the flag already called "present tense, negative form" now all have one tag, `CLASS=teonsana;MOOD=indicative;TENSE=present_simple;NEGATIVE=true`. The form name table builds the name from the tag, so the card says "present tense, negative form". The flag's own wording could not be built from any tag.
- `ilman`: Voikko offers `ilman`, adposition, so that is used (the flag said adverb). `tiistaisin`: Voikko offers the adverb `tiistaisin`, so the dictionary form is `tiistaisin` (the flag said tiistai). `omakannasta`: Voikko offers `omakanta` in lower case, as it gives `omakela`, so that is used (the flag said OmaKanta). `vähemmän`: the table names it "comparative, adverb".

**Found in the lemma rows, not in the form rows.** Five forms the lemma rows name were not in the form rows and are fixed: `kuuluu` (kuulua), `Laita` (laittaa), `Keksi` (keksiä), `kuori` (kuoria), each a Voikko reading, and `kotona` (koti, five lines, a manual reading). `kuusi` is the number six in all 6 lines (a pin, see the departures).

**Seen and not changed, for the manager to decide.**

- 26 words `minä` are read as the noun `minä` (nominative singular), not as the pronoun the other 153 get. Nothing is wrong on the card (the dictionary form is `minä`), but the form name differs. A spelling row for `minä` would make all 179 the pronoun.
- Four forms after a negation are still read as the plain present or conditional because Voikko's tag already allows the negative (`Perjantai ei käy`, `Minä en voi syödä`, `Ei olisi tarvinnut`, `Ei pitäisi`).
- Three word notes the manager wrote fail the rule that a why line holds no memory trick. See "Unfinished" below.

## Manual readings, a departure from "Voikko's own reading"

The manager's note allows a manual reading with its lemma, form tag and reason, and asks for each to be listed here. 133 words carry one, 54 distinct combinations. The exact place of each word, with its form tag and reason, is in `content/road/manual-readings.tsv` (made by the importer). Voikko offers the correct form name for none of these.

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

## A consequence the manager should know: rank caps and extra words changed

The frequency list holds dictionary forms as its tagger wrote them, so it has `paljo` (rank 59), `tosi` (49) and `ilma` (136), but not `paljon`, `todella`, `voi`, `ilman`, `noin`, `takaisin`, `kovin`, `liian`, `eli`, `usein`, `oikein`, `ollenkaan` or `varmaan`. Before, Voikko's wrong readings sat on list words. Now the correct dictionary forms are words the list does not have, and each counts as an extra word of its stop. The importer's own rule (docs/content-pipeline.md, statement 13) picks, for each part, the lowest rank cap that leaves every stop at most 15 extra words. Run again on the new readings it gives:

| Part | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| Rank cap before | 2000 | 2000 | 2000 | 2000 | 2000 | 1500 |
| Rank cap now | 2500 | 2500 | 2000 | 4000 | 4000 | 1500 |

I applied the rule as written (`content/road/stops.json`, `content/road/allowed-extras.json`, which now records 353 base words and 107 forms). Raising a cap to 4000 lets more words of rank 2000 to 4000 pass the level check in parts 4 and 5 without being listed. The other way out is to allow more than 15 extra words in a stop (at most 20 would keep every cap as it was) or to give the list a small table of dictionary forms that count as list words (paljon as paljo, todella as tosi). Both change the spec's rule, so I did not choose either. It is the manager's call, and a rerun of `analyse` and `import` after the change takes about 10 minutes.

The cap and extras change could have flipped other automatic readings. I compared every word of every written draft before and after the import: the only words that changed are the 498 covered by a row. One word (`kuusi` in line 7 of `a-headache`) flipped by itself with the new extras, which is why `kuusi` now has a spelling row.

## Word notes: what was kept, dropped and is new

- Kept exactly as the manager wrote them: 944 form rows and 723 dictionary form meanings, no text changed (compared with f82ab95).
- Dropped because the form or the dictionary form no longer exists: 118 form rows and 49 dictionary forms.
- New and empty: **89 form rows** in `content/road/word-notes.tsv` (meaning and why empty) and **44 dictionary forms** in `content/road/glossary.tsv` (meaning empty). `content/road/needed-notes.tsv` is the work list: **110 forms** (89 with their own meaning and why, 26 of them also lacking the dictionary form meaning, plus 21 plain dictionary forms that need only the dictionary form meaning).
- The 44 new dictionary forms are `eli`, `erikseen`, `etukäteen`, `ilman`, `ilmata`, `juuri`, `kannu`, `keittää`, `keksiä`, `kokeilla`, `kovin`, `kuin`, `kuoria`, `kuulemiin`, `kuulua`, `liian`, `lisätä`, `luona`, `maistaa`, `mukana`, `myöhemmin`, `neulominen`, `noin`, `näkemiin`, `oikein`, `ollenkaan`, `omakanta`, `pala`, `paljon`, `paras`, `perillä`, `sulaa`, `takaisin`, `tietysti`, `tiistaisin`, `tila`, `todella`, `tuulinen`, `usein`, `uusia`, `vanhempi`, `varmaan`, `viesti` and `voi`.
- 16 drafts say `"notes": "complete"` and 92 say `"pending"` (they hold at least one new empty row).
- I wrote no meaning and no why.

## Which "done when" statement each new test protects

All new tests are in `scripts/generate/test_road_readings.py` and carry `[a1-road 10]` (statement 10, Voikko's reading for each written word, chosen by fixed rules and no AI). The Python test count is now 294 (was 283), set in `.github/workflows/checks.yml`.

| Test | Proves |
|---|---|
| `ajan_in_varata_ajan_is_aika_not_ajaa` (real Voikko) | `varata ajan` reads aika, genitive singular |
| `voi_is_oh_in_its_own_line_and_the_verb_in_another` (real Voikko) | `Voi harmi` is the cry and `Lääkäri voi nähdä sinut` is the verb voida |
| `ei_kesta_is_a_negative_form_not_an_order` (real Voikko) | `Ei kestä` is "present tense, negative form", not imperative |
| `sataako_is_sataa_to_rain_not_sata_a_hundred` (real Voikko) | `sataako` is sataa with the question ending |
| `every_override_key_matches_a_real_token_in_the_drafts` | no stale key in either file |
| `a_stale_key_is_found` | a wrong word, a missing line and an unused spelling are each reported |
| `a_voikko_row_needs_a_reading_voikko_has_and_a_manual_row_needs_one_it_lacks` | the two kinds of row are kept apart |
| `the_override_files_refuse_a_wrong_row` | unknown tag, no reason, wrong source, repeated key, manual name, non number position |
| `a_manual_reading_passes_the_checks_only_for_its_own_spelling` | the gate adds a manual reading for its spelling and nothing else |
| `the_manual_readings_file_is_what_the_importer_lists` | `manual-readings.tsv` equals the importer's list from the committed drafts |
| `only_the_rejected_flags_are_still_in_the_drafts` | every flagged form is gone except the four whose flag was not accepted in full |

Existing tests also protect the result: `test_a1_road_12_*` (all 108 drafts pass every check, the committed drafts equal what the importer makes, the report is current), `test_a1_road_13_*` (each part's cap is the lowest with at most 15 extra words per stop, every recorded extra is used) and `test_a1_road_16_*` (notes consistent, needed-notes current).

## Check results

All run on GitHub (this computer has no Docker and no Voikko). The final run is on the commit `5032ed1`, the commit before this note: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41327917649 (the whole workflow, run once)

| Check | Result |
|---|---|
| Type check, lint, format (`npm run check:code`) | passed |
| Unit tests (Vitest) | passed |
| Python lint and format (ruff) | passed |
| Python tests (294, real Voikko, no network, no skips) | **293 passed, 1 failed**: `test_a1_road_16_notes_are_consistent_and_what_is_missing_is_listed`, on the three word notes under "Unfinished" below, and nothing else |
| `pipeline.py check-committed` (all 108 drafts, the step after the tests) | passed |
| Database tests (pgTAP, local Supabase) | passed |
| Browser tests (Playwright, local Supabase) | passed |
| Secret scan, dependency check | passed |

The importer, run on GitHub from a scratch branch (the workflow only runs from the default branch), deleted afterwards. The last import run is https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41327308210 and its log lists only the three word notes below (no mapping, Voikko, level or register failure; 108 drafts). The two earlier import runs were 41326768502 (it showed the `kuusi` flip) and 41327137277 (the base for the final files; the extras were pruned by one stale entry after it). The analysis for the new caps is run 41326553911 and the probe of Voikko's readings for the flagged words is run 41325913527.

## Proof by breaking each protection

Details and test names are in `factory/jobs/20-a1-road/evidence/round2-red-proofs.txt`. Each break was made on its own and undone.

| Protection broken | Tests that went red (besides the one baseline failure) |
|---|---|
| The stale check returns nothing (local) | `a_stale_key_is_found` |
| A stale row added to the position file (local) | `every_override_key_matches_a_real_token_in_the_drafts` |
| The two kinds of row no longer checked (local) | `a_voikko_row_needs_a_reading_voikko_has_and_a_manual_row_needs_one_it_lacks` |
| The loader accepts a manual name (local) | `the_override_files_refuse_a_wrong_row` |
| The gate adds no manual reading, and the gate adds them for every word (local) | `a_manual_reading_passes_the_checks_only_for_its_own_spelling` for each |
| A row removed from `manual-readings.tsv` (local) | `the_manual_readings_file_is_what_the_importer_lists` |
| `ajan` as ajaa put back in a draft (local) | `only_the_rejected_flags_are_still_in_the_drafts` |
| The position file is ignored (GitHub run 41327962899, real Voikko) | `sataako_is_sataa...`, `voi_is_oh...`, `the_manual_readings_file_is_what_the_importer_lists`, and `test_a1_road_12` (draft equals importer, report current) |
| The checks get no manual readings (GitHub run 41327966107, real Voikko) | `a_manual_reading_passes_the_checks_only_for_its_own_spelling`, `test_a1_road_12_all_108_committed_drafts_pass_every_check`, both `test_a1_road_15` tests and the report test |

The baseline failure is `test_a1_road_16_notes_are_consistent_and_what_is_missing_is_listed`, red with no break at all because of the three word notes below. In the position break `ajan` did not go red: with the new extras Voikko's automatic choice for `ajan` is already aika, so its row is a pin and not a change. The two GitHub runs were cancelled after their Python job; only that job was read.

## Departures from the spec and from the manager's note, and why

1. **Manual readings exist** (133 words, listed above). The spec says each word has one of Voikko's own readings. The checks see them through `ManualReadingGate`, which loosens "is one of Voikko's readings" for those spellings and nothing else.
2. **The negative form is named "present tense, negative form"**, not "negative form" or "negative form (connegative)": the name is built from the tag and nothing else can produce the flag's wording.
3. **Rank caps rose for parts 1, 2, 4 and 5** (section above), by the rule as written.
4. **`kuusi` is a spelling row** that pins the number six in all 6 lines. Without it a cap change flipped one automatic choice.
5. **Voikko's own reading was preferred over the flag's wording** for `ilman` (adposition), `tiistaisin` (adverb, dictionary form tiistaisin) and `omakannasta` (`omakanta`), as the manager's note says to choose among Voikko's readings where one fits.
6. **`tulossa` is not changed, and five other flags are applied only to the lines they are right for** (section above).
7. **These changes are not listed in `content/road/fixes.md`.** That file is for repairs to the markdown tables after a failing run (statement 14); the override files are road files that record their own reason on every row.

## Unfinished or uncertain

- **Three of the manager's word notes fail the no memory trick rule**, so one test is red (`test_a1_road_16_notes_are_consistent_and_what_is_missing_is_listed`, the importer's log line "a mnemonic or memory trick is not allowed"). I kept their text exactly as asked. The rows are in `content/road/word-notes.tsv`: line 863 (`suomalaiselta`) and line 864 (`kesältä`), whose why says `'sounds like'` for the verb kuulostaa, and line 945 (`muistatko`), whose why says "muistaa means to remember". The rule's word list is `remember`, `mnemonic`, `memorize`, `think of`, `sounds like`, `imagine` (`scripts/generate/road_data.py`). The three lines are not memory tricks, but the rule is a word list, so they need other words, for example "kuulostaa means to sound, ..." and "muistaa means to keep in mind". With those three rows reworded, every check passes. The rule's own `grammar.why_problems` check, which the manager ran, does not include this word list.
- **The new empty rows** (89 forms, 44 dictionary forms) are the manager's step, as above.
- **Statement 28 and the voices** are as in round 1: no part is approved, nothing is published, only the sample dialogue was voiced.

## How to run it

- Python checks: `python -m pytest scripts/generate` (Voikko needed for 64 of them). Lint: `python -m ruff check scripts` and `python -m ruff format --check scripts`.
- The importer on GitHub: Actions, "A1 road", task `import`, part `all` (or `analyse` first, to redo the caps after a change to the readings). The result goes into `content/drafts/` and `content/road/`.
- A new correction: add a row to `content/road/reading-overrides.tsv` (the same reading in every line) or to `content/road/reading-overrides-by-position.tsv` (one word in one line), choose `voikko` or `manual`, give a reason, run the import. The importer refuses a row of the wrong kind or a stale key.

## Earlier rounds (short)

Round 1 (commit 9fbb60b, all GitHub checks green on run 41321561654): the road in the database (`road_parts`, `road_stops`, `road()`, `stop_review_forms`, `GET /api/road`), the importer and its checks for all 108 dialogues, the register judge run once ($0.66), the voice throttle and one voiced sample, the owner approval file and the publisher, the fix path after launch, and the paged Worker reads. Its full text, the red proofs with their run numbers (41320564222 to 41320746506, in `factory/jobs/20-a1-road/evidence/red-proofs.txt`), and the numbers it reported (51,597 voice characters, about 88 MB of audio and migrations at publish) are in `git show 9fbb60b:factory/jobs/20-a1-road/build.md`. The interface for job 19-redesign, `public.road()` and `GET /api/road` with its 14 keys, has not changed.

Round 1 departures that still stand: the six earlier drafts keep their old unit block; `noi` has the lemma `nuo`; glued `Ootsä` is one word in the text and two in the tokens; `present-tense` is a catalogue entry at stop 1; the six earlier drafts disagree on the why line of 25 shared forms; `judge` and `voice` take `--part`; the road's seed numbers are zero until a part is approved. Round 1 run links: import 41321298577, analyse 41317041041, judge 41318417132, 41319745436 and 41320245477, voice sample 41317587713, count-characters 41317789817.

Result: blocked: three word notes the manager wrote fail the no memory trick rule (word-notes.tsv lines 863, 864 and 945), so one Python test is red; every other check passes
