# Build notes: job 20-a1-road, round 6 (fixes from the evaluation)

Branch `factory/20-a1-road` (pushed, no pull request, not merged). Round 6 starts from 62434e4 (the manager's rikkaus meaning in `glossary.tsv`) and answers `factory/jobs/20-a1-road/evaluation.md` (a fail on one clause of statement 19, and one odd item). Earlier rounds follow in short form.

## What I fixed

- **Statement 19, the actions are pinned (fixed).** The four actions in `.github/workflows/a1-road.yml` are now pinned to full commit hashes with their version in a comment: `actions/checkout` 3d3c42e5aac5ba805825da76410c181273ba90b1 (v7.0.1), `actions/setup-python` 6d4fd22b20465ccc0f7354476588e8df7c9ca0e0 (v7.1.0), `actions/setup-node` 949feb2413d6458794dcd2491c4babbbce0c15c1 (v7.1.0), `actions/upload-artifact` cf430e030ddbb5b0abf93d22962f4752f3646cd9 (v7.0.2). Each is the commit the `v7` tag pointed to today. The round 5 note that said "actions are pinned by tag like the other workflows" is withdrawn: it was a departure and is now fixed. The other workflows still use tags. A new test checks that every `uses:` in `a1-road.yml` is `owner/name@` plus 40 hex characters with a version comment.
- **Amendment to statement 17 (one text per shared form).** `spec.md` carries the manager's amendment under the manager's amendment heading, and statement 17 points to it. For a form id that the road shares with an earlier draft, the road's texts (meaning, dictionary form meaning, why) win. The importer now reads those texts from the road files only (it no longer lets an earlier draft's own text win) and writes them into the earlier drafts' shared forms. The same holds for a form that two of the earlier drafts share, so that one form id carries the same texts in every draft (the check `lemma_consistency` no longer excuses the earlier drafts, and found 9 such disagreements before this was added). The earlier drafts' lines, tokens and clips, and the why lines of the forms that no other draft has, stay byte for byte (the test hashes them again). No reviewer file exists for them (`content/reviews/` holds only its README; that test stays). The import after the change rewrote the why of 49 distinct forms in the six earlier drafts (the 22 the evaluation counted, the forms two earlier drafts share, and others the road also has), and the road drafts that had inherited an earlier draft's AI text: all 108 draft files changed, texts only, no reading and no line.
- **The publisher refuses, it does not skip.** In a road publish migration a form is inserted only when it does not exist (`on conflict do nothing` is gone for the road), an existing form must be approved, and an existing form must carry exactly the texts of the draft (name, why, meaning, dictionary meaning). Otherwise the migration stops with a message that names the form and both sets of texts (`publish.road_form_lines`). `pipeline.py publish-part` also reads the form inserts of the migrations already in the repository (`road_publish.form_conflicts`) and refuses before it writes anything: no migration and no clip. The job 7 publisher keeps its old text, because its fixtures are compared byte for byte. The reviewer's fix migration (`road_fix.py`) still uses `on conflict do nothing` for the forms a fix adds; it is not part of this change.
- **A real database test of the form insert.** `supabase/tests/database/a1_road_forms.test.sql` (7 checks, made by `scripts/generate/road_forms_pgtap.py` from the same lines) runs those lines against the real `public.forms` table: a new form is inserted, the same form with the same texts goes through, another why is refused naming the form and both texts, the stored text stays, and an unapproved existing form is refused. Before this the road's publish SQL had only been compared as text.
- **Import (part all, last 41346642513).** 108 drafts, 0 failures, every draft `"notes": "complete"`, `needed-notes.tsv` empty (header only), no word changed reading. No row needed text.

## Which tests protect it

| Where | Tests |
|---|---|
| `test_road_voice.py`, `[a1-road 19]` (1 new) | every `uses:` in the workflow is a 40 character hash with a version comment |
| `test_road_import.py`, `[a1-road 17]` (1 new, 1 renewed) | every form id in more than one draft has identical meaning, dictionary meaning, why and name in all of them (at least 22 shared with the road), and the shared forms carry the road files' why; the six earlier drafts keep their lines, clips, providers, names and the why of every form no other draft has |
| `test_road_publish.py`, `[a1-road 17]` (4 new) | the form SQL has no `on conflict` and holds the refusal and the unapproved check; an earlier migration with other texts is found, naming the form, the migration and both texts, and the same texts, an older insert without meanings and another form are handled; publish refuses with 0 migrations and 0 clips written when an earlier migration holds one of its forms with another why (and publishes without that migration); `a1_road_forms.test.sql` equals its generator |
| `supabase/tests/database/a1_road_forms.test.sql` (7 checks) | the form insert against the real table |

The Python test count is 314 (set in `.github/workflows/checks.yml`).

## Check results

All on GitHub. The final run is on 9804065: https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41344630877

| Check | Result |
|---|---|
| Type check, lint, format (`npm run check:code`) | passed |
| Unit tests (Vitest) | passed |
| Python lint and format (ruff) | passed |
| Python tests (314, real Voikko, no network, no skips) | passed |
| `pipeline.py check-committed` (all 108 drafts) | passed |
| Database tests (pgTAP, includes the 7 checks of `a1_road_forms.test.sql`) | passed |
| Browser tests (Playwright, local Supabase) | passed |
| Secret scan, dependency check | passed |

Import runs (scratch branch, deleted afterwards): the last 41344334114 (0 failures); the first, 41344162942, showed the 9 disagreements between earlier drafts that led to the extra rule.

## Proof by breaking each protection

Details in `factory/jobs/20-a1-road/evidence/round6-red-proofs.txt`.

| Protection broken | Tests that went red |
|---|---|
| An action on a tag, a hash without its version comment, a hash of 39 characters (3 local breaks) | the pinning test, each time |
| The repository form check finds nothing, or compares only the why (local) | `an_earlier_migration_with_other_texts_for_a_form_is_found` |
| The road form lines skip or `on conflict` again (local) | `the_form_sql_refuses_other_texts_and_no_longer_skips_them` and the pgTAP generator test |
| An earlier draft holds an AI text for a shared form (local) | the identical texts test and the review manifest test |
| The repository check is left out of the publisher (GitHub run 41344746188, real Voikko) | `publish_refuses_a_form_an_earlier_migration_inserted_with_other_texts` (1 of 314) |
| The refusal is taken out of the SQL (GitHub run 41344762072, real Postgres) | check 5 of `a1_road_forms.test.sql` ("another why is refused"), and none of the other 6 |

One break is not red by itself: letting the importer read an earlier draft's text first again passes all tests, because the earlier drafts committed now already hold the road's texts. The identical texts test and the one that fails when an earlier draft holds an AI text are what guard it.

## Departures and notes

1. **Statement 17 is amended** as above (the manager's decision). The earlier drafts' shared forms change, and their review pages and manifests were made again.
2. **The refusal check is also wider than the manager's words**: it covers a form that two earlier drafts share, so that every draft agrees.
3. **The road files win for every form they hold (the manager's decision after round 6).** A form that only an earlier draft uses and that has a row in `word-notes.tsv` (for example tuolla, form-d53af38ffdce) now takes the road files' texts too, and so does a plain dictionary form of a lemma in `glossary.tsv`. The rule is `has_road_texts` in `road_import.py`; the amendment to statement 17 in `spec.md` says so. The earlier drafts' lines, tokens, clips and providers stay byte for byte (checked on the import: unchanged in all six); six more forms changed text (1 or 2 in four of the drafts), their review pages and manifests were made again. A form the road files do not hold keeps its why (today none: every form of the six drafts is held).
4. **Action pinning** is fixed for `a1-road.yml` only.
5. **The workflow has still never run** (a manual workflow runs only from `main`), as the evaluation says.

---

# Round 5 in short (fixes from the security and design reviews)

Both review files are committed (`review-security.md`: pass with two should fix; `review-design.md`: word card texts, the manager's). Manual readings for hitaammin (`hidas`, "comparative, adverb") and for "Minä en voi syödä" (`voida`, "present tense, negative form"); no cry uses form-fc6219c3121b (its two lines are verbs). The approval fingerprint (`road_fingerprint`) now also covers each line's speaker, the hash of both clips and the word links of both registers (statement 20, a departure). The voice task refuses to start when `content/logs/ai-calls.jsonl` has uncommitted changes, and the workflow comment, `docs/content-pipeline.md` and this file say the manager commits the voice log after every voice run and before the next. `Retry-After` is capped at 60 seconds. 9 tests, red proofs in `evidence/round5-red-proofs.txt`, final checks 41341321317 all green, 108 of 108 drafts complete after the manager's two notes. When a test of `cmd_voice` was broken on purpose it used a stand-in provider, not Azure: 0 characters, the voice log unchanged (507 characters used this month); the test now names no draft, so a broken guard voices nothing.

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
