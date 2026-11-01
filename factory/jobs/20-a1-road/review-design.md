# Design and learner review: job 20-a1-road

Reviewer: design review. Head reviewed: 0315f11. No screens changed, so this reviews the learner facing content only.

## What I read

- All 1,032 meanings in `content/road/word-notes.tsv` (skimmed), and about 330 of the why lines in full, spread over the whole file (every 9th, 13th and 17th row, plus every genitive, adessive, inessive, essive and imperative row).
- Mechanical check of every why line that says "Speech drops the last vowel / last a / last ä / the end" against the written and spoken columns.
- About 80 lemma meanings in `content/road/glossary.tsv` (every 13th and 17th row, plus targeted ones). I found no wrong lemma meaning in that sample.
- All 36 stop titles and "I can" lines, the 6 part titles (in `supabase/migrations/20261101120100_load_road_stops.sql`; `content/road/stops.json` holds only settings), all 133 rows of `content/road/manual-readings.tsv`.
- 11 whole dialogues from `content/drafts/*/draft.json`, spread over all six parts (spoken, written and English).
- Banned writing: no em or en dashes in the three files, no hype words, no "not X but Y". No memory tricks in the why lines. No dialect found in the spoken forms (mä, sä, mun, oon, mist, -ks, -ii are standard Helsinki spoken Finnish).

The Finnish content and the English glosses of the 11 dialogues are good. Stop titles and "I can" lines are literal and plain. The problems are in the word card text.

## Must fix

1. `form-aa8e1d0f22c9` (lisää, dictionary form lisä, partitive singular). Meaning "add" and the why "This is how you tell someone to add: lisää. It comes from lisätä." are wrong for this form. It is used as "more" in three dialogues: "Haluatko sinä lisää?" (dinner-is-ready 5), "opiskella lisää suomea" (next-year 2), "Heitänkö minä lisää löylyä?" (sauna-at-the-cottage 1). The "add water" form is the separate row `form-0f2b13a77e10`, which is correct.
   Fix: meaning `more`, why `Lisä, extra, takes -ä here: lisää means 'more'. People say it the same way.`

2. `form-a2a7fb70527b` (tule, imperative present tense, 2nd person singular). Meaning "come (after not)" and why "After ei (not), the verb loses its ending: tulee becomes tule" are wrong. This form is used for the plain command in "Tule sisään" (at-the-party 1), "Tule vain" (a-language-cafe-at-oodi 7) and "Tule meidän mökillemme" (midsummer-plans 7). There is no ei in those lines. The "after not" row is the manual reading `a-sick-child/3/7`, which has its own form id.
   Fix: meaning `come`, why `Tulla, to come. To tell one person to come, use tule. Speech says tuu.`

3. `form-6623d0c4b9e8` (kotona). The why says "The t of koti changes and an o is added." Neither is true: the t stays, and the i of koti turns into o.
   Fix: `Koti with -na means 'at home': kotona. The i of koti turns into o before the ending. You hear it every day.`

4. `form-ba63b5995fe7` (hitaammin, "Voitko sinä puhua vähän hitaammin?"). The form name on the card would read "comparative, instructive plural" (Voikko's raw tag). A beginner cannot use that and it is not what the word is. Row 131 (vähemmän) already gets the right treatment.
   Fix: add a manual reading for sorry-i-didnt-understand line 4, form name `comparative, adverb`, dictionary form hidas (or hitaasti if the owner prefers), and keep the meaning "more slowly".

5. `form-fc6219c3121b` (voi in "Voi ei!"). The card says dictionary form voida and form name "present tense, 3rd person singular", while the why says "not the verb voida". The card contradicts itself.
   Fix: add a manual reading that makes it an interjection (dictionary form `voi`, form name `interjection`), as already done for näkemiin and kuulemiin. Keep meaning "oh" and the why.

## Should fix

6. `form-90c207b76ecc` (voitko). Meaning "could you?" is wrong for voitko. It means "can you?" and "could you?" is voisitko. The sister rows say `voinko` = "can I?" and `voit` = "you can". A learner who later meets voisitko will be confused.
   Fix: meaning `can you?`. (The English line gloss "Could you speak...?" can stay, it is natural English.)

7. `form-adcb32712443` (hänellä, meaning "does he have") and `form-a9fe1350b93e` (meillä, meaning "do we have"). The word is not a question; the card should say what the word means. The row for teillä already says "you have".
   Fix: `he or she has` (hänellä), `we have` (meillä).

8. Wrong rule in 59 why lines (one shared problem, one fix). The text says "Speech drops the last vowel", "the last a", "the last ä" or "the end", but speech drops two letters: -ssa and -ssä become -s, -lla and -llä become -l, and mutta becomes mut. Example: `form-d53af38ffdce` tuolla > tuol: "Speech drops the last vowel: tuol" would give tuoll by its own rule. A beginner who follows the sentence gets the wrong word. Examples: `form-f177cddd7c31` mutta>mut, `form-25ac6c76f4b0` tässä>täs, `form-2f61aaedd09f` maidolla>maidol, `form-7ea1fd2e4fc3` talossa>talos, `form-87b291dcab91` kerroksessa>kerrokses (says "last a"), `form-84e1296c6d52` ylimmässä>ylimmäs, `form-d81708dfc306` päässä>pääs (says "drops the end").
   Fix: write the real rule with the endings, for example `Speech shortens -lla to -l: tuolla becomes tuol.` and `Speech shortens -ssa to -s: talossa becomes talos.` Keep "drops the last vowel" only where one letter goes (mistä>mist, hyvältä>hyvält, 44 rows are correct). The script can find the 59 rows: the written and spoken columns differ in the last two letters, ending in sa, sä, la, lä or ta. All 59 ids:
   form-f177cddd7c31, form-25ac6c76f4b0, form-2f61aaedd09f, form-d53af38ffdce, form-2661e101e057, form-a54598413b94, form-7b2dc9156681, form-0fd3b38079dc, form-5982de53b4d1, form-0adf6867ada5, form-1b8704bc3c91, form-daee785cf008, form-73c5475313cb, form-5166646a9be8, form-d8d880fe357d, form-87b291dcab91, form-32cbb4c9a5c5, form-7ea1fd2e4fc3, form-fe4a40637188, form-84e1296c6d52, form-de597eea4acd, form-3777b263067c, form-e0fff25131bf, form-b87213b6ed5e, form-290cda423243, form-3f61e1a0c95f, form-fe490b0ce11e, form-c32307f62411, form-a5623edee8b5, form-d81708dfc306, form-010b2ddc6d88, form-f472eda46936, form-efa645fca980, form-f52a6eb064fb, form-aa5fee5dd7b4, form-68a8e27ce903, form-a9fe1350b93e, form-6913547d4c5b, form-6debbc157c4d, form-deb1f8f69fd9, form-d98fbee7d5d9, form-b342202c09b1, form-747f91da16f3, form-11490962728d, form-393179c8b612, form-e068cd14094b, form-9b45c353e900, form-4766ad1f011b, form-b394c1645ef2, form-93e419d51820, form-ca5fbcee777a, form-94ae68ff18ca, form-34199f1ea70b, form-1781e6e182a0, form-9b2e89310018, form-1123dd726c67, form-b8f606123345, form-df893cd83caf, form-c5bf45063f6f.

9. Four verb rows hide a consonant change.
   - `form-e7b0def56866` näytät: "Näyttää drops the last ä and takes -t" gives näyttät. Fix: `Näyttää becomes näytä- (tt turns to t) and takes -t for 'you': näytät.`
   - `form-efd71ca8dad8` täytät: same problem. Fix: `Täyttää becomes täytä- (tt turns to t) and takes -t for 'you': täytät. It means turning an age.`
   - `form-2d42ecff1379` kävele: "drops the ending: kävellä becomes kävele" is not what happens (an e appears). Fix: `To tell one person to walk, use kävele. It comes from kävellä, with one l.`
   - `form-bcbc840c68eb` käänny: "drops the ending: käänny" misses nt to nn. Fix: `Kääntyä, to turn. To tell one person to turn, use käänny: the nt becomes nn.`

10. Partitive plural is explained five different ways. 13 rows say "An open number of things takes -ita / Describing an open number of things takes -ja" (for example `form-ea29d573798b` helppoja, `form-beb4218dfba2` mustikoita, `form-05532514e827` kynttilöitä, `form-fadae9bebf98` marjoja). "Open number" is not plain English for a beginner. Other rows say "an amount you don't count" (perunoita, porkkanoita, korvapuusteja, kokkoja, laatikoita), "in a question about any", "Asking which ones" and "part of a group". The same change should read the same way on every card.
    Fix: use the plain wording that already exists, `some, not an exact number`, for all of them, for example `Plural 'some' takes -ja: helppo becomes helppoja.` and `Plural 'some' takes -ita: mustikka becomes mustikoita, kk turning into k.`

## Notes

- `form-5df29264208f` onneksi has meaning "(congratulations)". Fine as part of "onneksi olkoon", but the word alone means "luckily". Consider `luckily (in onneksi olkoon, congratulations)`.
- `form-8d5b7d527ca0` saa has meaning "may (be)". Hard to read on a card. Consider `may (in Mitä saa olla?)`.
- Meanings in the pattern "the door's (next to the door)", "my husband's (with my husband)", `form-ea9917b227c3`, `form-84a435b7ff95`, `form-8ba45f54b531`, `form-08a391170527`, `form-749e7cd18313`: correct, but heavy. They are the only rows that carry two meanings in one cell. Consider showing only the second part, which is what the learner meets in the line.
- Form names such as "past active participle, nominative singular" (ymmärtänyt, tiennyt, asunut, käynyt, ollut) and "past passive participle" are correct but are grammar terms a total beginner has no use for. They are the rows listed in `manual-readings.tsv`, so the names were chosen on purpose. If the card allows, `past form (as in en ymmärtänyt)` is easier. Not blocking.
- The why lines mix `People say it the same way` (25) and `Speech says it the same way` (3). Pick one.
- The why lines start with a lowercase word in about 20 rows (for example `form-c6e5d9835929` leikkaa "leikata, to cut."). Capitalise.
- Part titles: "First words", "Finnish life" and "Getting things done" are looser than the stop titles. The owner's rule is literal titles. Owner's call; not blocking.
- Manual readings (`content/road/manual-readings.tsv`): the form names are sensible ("present tense, negative form", "adverb", "interjection", "past active participle", "comparative, adverb"). The negative rows are consistent with "after ei the verb drops its ending". Only hitaammin and voi (above) are missing.
- Stop titles and "I can" lines: no em dashes, no hype, no "not X but Y", no habitual groups of three except the natural "left, right and straight on" in stop 31. They fit the writing rules.
- Spoken Finnish: all spoken forms I read are standard Helsinki spoken (mä, sä, mun, mul, oon, ootsä, mist, täs, kerrokses, kahen, seittemän, kakskyt, vaikeeta, santsia, diili, synttärit, kans). No dialect.

## Count

Sample: about 330 why lines read in full and 1,032 meanings skimmed, about 80 lemma meanings, 11 dialogues, all 133 manual readings.

- Wrong or contradictory rows: 5 (items 1 to 5).
- Misleading meaning: 3 (item 6 and 7).
- Wrong why wording shared by many rows: 59 (item 8), plus 4 verb rows (item 9).
- Inconsistent plain wording: 13 rows (item 10).
- Wrong lemma meanings in the glossary sample: 0.

Result: changes needed
