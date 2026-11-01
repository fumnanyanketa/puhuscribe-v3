# Build notes: job 20-a1-road, round 3 (the manager's two decisions and the final import)

Branch `factory/20-a1-road` (pushed, no pull request, not merged). Round 3 starts from c59db55, where the manager wrote the 89 new form rows and the 44 dictionary forms and reworded the three whys. Rounds 1 and 2 follow in short form.

## What I built, in plain English

- **Decision 1, the alias table.** The frequency list holds some words under another base form (`paljo`, `tosi`), so the correct dictionary forms `paljon` and `todella` counted as extra words and pushed the rank caps up. `content/road/list-aliases.tsv` now maps each such word to the list form of the same word, one reason per row (8 rows: `liian` to `liika`, `myöhemmin` to `myöhä`, `oikein` to `oikea`, `paljon` to `paljo`, `tietysti` to `tietty`, `todella` to `tosi`, `usein` to `usea`, `varmaan` to `varma`). A word takes the rank of its list form in `Context` (the importer) and in `check_draft` (every check run), through `aliased_ranks` in `scripts/generate/road_data.py`. A word the list already has keeps its own rank. I left out forms that are not the same word (`ilman` is not `ilma`, `pala` is not `palo`, `uusia` is not `uusi`).
- **Decision 2, `minä`.** One spelling row in `content/road/reading-overrides.tsv` makes all 179 words `minä` and `Minä` the personal pronoun (26 were the noun `minä`). The 153 position rows for `minä` that this row now covers are removed.
- **The final import** ran on GitHub (part `all`). It changed exactly the 26 words that were the noun `minä` and nothing else (checked word by word: no unplanned change). Every draft now says `"notes": "complete"` (108 of 108), the import log has 0 failures, and there are no empty rows (`needed-notes.tsv` has no entry, no empty cell in `glossary.tsv` or `word-notes.tsv`).
- **Stale row.** The manager's row for the old noun form of `minä` (form 2f3bea3d9937) is no longer used, so the importer dropped it. `word-notes.tsv` has 1,032 rows (was 1,033) and no text of another row changed. `glossary.tsv` is unchanged (767 rows).
- Five new tests (`scripts/generate/test_road_readings.py`, `[a1-road 10]`): the alias file's keys are lemmas in the drafts and its values are on the list, an alias gives its list form's rank and never replaces a listed word, the alias file refuses a wrong row, all 179 `minä` are the pronoun in the drafts, and the pronoun also wins in a real Voikko build of three dialogues. The Python test count is 299 (set in `.github/workflows/checks.yml`).

## Rank caps before and after the aliases

| Part | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| Round 1 | 2000 | 2000 | 2000 | 2000 | 2000 | 1500 |
| Round 2 (no aliases, by the rule) | 2500 | 2500 | 2000 | 4000 | 4000 | 1500 |
| Now, in `content/road/stops.json` | 2000 | 2000 | 2000 | 2000 | 2000 | 1500 |
| Lowest cap the rule would give now | 2000 | 2000 | 2000 | 2500 | 2500 | 1500 |

Parts 1, 2, 3 and 6 are back at their round 1 caps with the aliases. Parts 4 and 5 cannot return by aliasing the same word. As decided, I did not raise their caps. Three stops have more than 15 extra words at cap 2000:

- **Stop 23, part 4: 18 words.** Compared with round 1 it gained `ilman`, `keittää`, `kuoria`, `maistaa` and `pala`, and lost `kuori` and `palo` (the readings the manager's flags replaced). With `paljon` and `todella` aliased, those five stay above rank 2000 or are not on the list: `keittää` has rank 4097, `maistaa` 4263, `kuoria` 2432, `pala` 5279, and `ilman` is not on the list (the list has `ilma`, a different word).
- **Stop 26, part 5: 16 words** (`etukäteen` is the one that moved in; the list has it only as `etukäsi`).
- **Stop 28, part 5: 17 words.** It gained `keksiä` (rank 2241) and `uusia` (rank 4196).

Because of this one existing test is red, and it says so itself: `test_a1_road_13_each_part_has_the_lowest_cap_that_leaves_at_most_15_extra_words_per_stop` expects 2500 for part 4 and finds 2000. Nothing else is red. Two ways out, both the manager's call: set parts 4 and 5 to 2500 in `content/road/stops.json` (the test then passes; a rerun of `analyse` and `import` follows, about 10 minutes), or allow up to 18 extra words on a stop. I changed neither the test nor the rule.

## Which statements the new tests protect

All five carry `[a1-road 10]` (Voikko's reading for each written word, chosen by fixed rules, no AI) and sit in `scripts/generate/test_road_readings.py`. The level fit and caps are also protected by the existing `test_a1_road_12_*` and `test_a1_road_13_*` tests in `test_road_import.py`.

## Check results

All on GitHub (no Docker or Voikko here). The final run is on 9e9e3e6 plus the pruning commit that follows it (three briefs lose one extra word and the report): https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41330364917 (on 8ffd14c). Its browser job failed once on one test that reads a dialogue id from a shared database (`save-progress 19`, an empty id in a test helper, nothing to do with the road) and passed when only the failed jobs were run again

| Check | Result |
|---|---|
| Type check, lint, format (`npm run check:code`) | passed |
| Unit tests (Vitest) | passed |
| Python lint and format (ruff) | passed |
| Python tests (299, real Voikko, no network, no skips) | **298 passed, 1 failed**: `test_a1_road_13_each_part_has_the_lowest_cap_that_leaves_at_most_15_extra_words_per_stop` (parts 4 and 5 at cap 2000, see above), and nothing else |
| `pipeline.py check-committed` (all 108 drafts) | passed |
| Database tests (pgTAP, local Supabase) | passed |
| Browser tests (Playwright, local Supabase) | passed on the second attempt (see above) |
| Secret scan, dependency check | passed |

Import runs (scratch branch, deleted afterwards): the last 41330241971 (108 drafts, 0 failures), the one before 41330052372 (1 failure, the stale `minä` note row, 26 words changed), and the analysis for the caps 41329922707.

## Proof by breaking each protection

Each break was made on its own and undone.

| Protection broken | Tests that went red (besides the baseline) |
|---|---|
| An alias no longer takes its list form's rank (local) | `an_alias_takes_its_list_forms_rank_and_never_replaces_a_listed_word` |
| The alias file accepts the same word twice (local) | `the_alias_file_refuses_a_wrong_row` |
| An alias row for a word no draft uses, or whose list form is not on the list (local) | `every_alias_key_is_a_lemma_in_the_drafts_and_every_value_is_on_the_list` (and the rank test for the second) |
| The noun `minä` back in a draft, or the spelling row removed (local) | `minae_is_the_pronoun_in_every_line_of_the_drafts` |
| The `minä` row removed (GitHub run 41331399346, real Voikko) | both `minae` tests, `test_a1_road_12` (draft equals importer, report current) and the notes test |
| `check_draft` ignores the aliases (GitHub run 41331402136, real Voikko) | `test_a1_road_12_all_108_committed_drafts_pass_every_check` and both `test_a1_road_15` tests |

The baseline is the rank cap test for parts 4 and 5. The details and test names are in `factory/jobs/20-a1-road/evidence/round3-red-proofs.txt`. The two GitHub runs were cancelled after their Python job.

## Departures recorded in round 3

1. **Alias table** (`content/road/list-aliases.tsv`): 8 words take the rank of their list form. The manager's decision. It loosens the level check for those words only, in the importer and in every `check_draft` run.
2. **Parts 4 and 5 stay at cap 2000 although the rule would give 2500**, so one existing test is red until the manager chooses (above).
3. **`minä` is one spelling row**; the 153 position rows it replaces are gone.

## Unfinished or uncertain

- The one red test above (the rank cap rule for parts 4 and 5).
- Statement 28 and the voices are as in round 1: no part is approved, nothing is published.

## How to run it

- Python checks: `python -m pytest scripts/generate`; lint `python -m ruff check scripts` and `python -m ruff format --check scripts`.
- The importer on GitHub: Actions, "A1 road", task `analyse` then `import`, part `all`. To change a cap, edit `content/road/stops.json`, then rerun `analyse`, rebuild `allowed-extras.json` from its output and rerun `import`.

---

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

Result: blocked: the rank cap rule test is red for parts 4 and 5 (stops 23, 26 and 28 keep more than 15 extra words at cap 2000), pending the manager's choice; every other check passes
