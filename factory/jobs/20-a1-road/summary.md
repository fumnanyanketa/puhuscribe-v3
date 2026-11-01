# Job 20: The 36-stop A1 road

Flag: look closely. It adds database tables and a public read for visitors, and it decides what Finnish a learner is taught. Cost so far is $0.66 (the AI meaning check, run once). Voicing the whole road uses about 51,000 of the 500,000 free Azure characters this month, so it costs nothing.

## What changes for you and your learners

1. The road exists in the database: 6 parts and 36 stops, each with its title and its "I can" line. The home screen from job 19 reads it.
2. Someone who has not signed in sees the whole road with no progress. Nothing is stored about them, no cookie is set and no account is made.
3. All 108 dialogues (102 written by Claude, 6 from before) pass the automatic checks. Voikko (the Finnish word analyser) knows every word, every word fits the level of its part, and the AI check found no line where the spoken and written Finnish mean different things. The checks led to 351 small repairs to Claude's Finnish, each listed with its reason in `content/road/fixes.md`.
4. Every word has a word card: its English meaning, the meaning of its dictionary form, and a short "why it looks like this" line. Claude wrote all of them in the session. A reviewer read about 330 of them, and Claude fixed the 225 rows it flagged.
5. Nothing is live yet. A part goes into the app only after it is voiced and you approve it in your own words. Your approval locks that part's lines, audio and word cards, so nothing can change after you approve it.

## Checks and review

- GitHub checks on branch `factory/20-a1-road`: all green on run 41346798223. 314 Python tests, 1,094 database tests, and the browser tests in Chromium and WebKit at phone size.
- Every protection was broken on purpose and its own test went red (`evidence/` holds each round's proofs).
- Security review: pass. Its two suggestions went in: your approval also covers the audio and word links, and the free voice counter cannot fall behind.
- Content review: the dialogues, stop titles and spoken Finnish were good. The word card fixes it asked for are done.
- Evaluator: pass after one re-check. 26 of 29 statements pass. Statements 21, 22 and 28 can only be proven once parts are voiced, approved and published, which comes after this merge.

## Decisions the manager made on your behalf

- About 135 words had to have their reading set by hand, because Voikko reads them wrongly in context ("varata ajan" is "book an appointment", not "I drive"). They are listed in `content/road/manual-readings.tsv`.
- The level cap for parts 4 and 5 is 2,500 common words instead of 2,000, because of everyday words such as "boil", "peel" and "renew". This follows the spec's own rule.
- Where an older dialogue and the road share a word, the road's reviewed word card wins.
- Visitors can read the road (statement 29, added after job 19 needed it).

## Small things noted, not fixed

- Three word cards could be worded better ("osaa", "huoltomiehen", and "kaukana" showing "kauas" as its dictionary form). They can be fixed before their part is approved.
- No native speaker has read the content yet. That follows your decision to launch to testers first.

## What happens after you approve

1. The job is merged. Nothing becomes visible to learners.
2. The manager voices the road part by part on Azure's free tier.
3. For each part, you listen to five dialogues and write one approval line in your own words. That part then goes live.
4. After the last part, the evaluator walks one dialogue per part in the app and you write the final approved line here.
