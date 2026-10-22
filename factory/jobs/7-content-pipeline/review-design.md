# Design and wording review: 7-content-pipeline

Reviewer: design review, 21 October 2026. Branch `factory/7-content-pipeline`, head `9e834ef`, PR 17. Read only on code.

How I looked: I opened the fixture review page (`scripts/generate/fixtures/review/round-1.html`) from disk in Chromium at 375 x 812 and 1280 x 900, with the system set to light and to dark. I filled it in, pressed Download with nothing chosen, chose Fix, chose "Not yet", tabbed through it, and put a long Finnish word into a line. Screenshots are in the session scratchpad (`shots/phone-light-top.png`, `phone-dark-top.png`, `desktop-light-top.png`, `phone-light-errors.png`, `phone-light-fix.png`). I read `review_page.py`, `review_import.py`, the two docs, the golden set, the prompts and the unit 1 fixture answers. The design system is locked (`design.md`), so I judged against it where it makes sense for a standalone file.

## What works

- Plain two-colour page, no accent bars, no eyebrow labels, no pills except the black buttons the design system allows, no gradient, no icons, no emoji, no banned fonts. Spoken and written labels use the design system's teal and violet text colours, and the contrast values hold (the quiet text, label colours and input edges all meet the floors on white).
- Text is shown as text. A line containing `<script>` is printed.
- The sequence is easy to follow: code, lines, word cards, whole dialogue, download. Each clip has "Sounds right" and "Sounds wrong". Fix opens boxes already holding the current text, so the reviewer edits instead of retyping.
- Download is refused with a list of what is missing, in plain words that name each item ("Line 2: choose approve or fix."). Nothing overflows sideways at 375 px with real line lengths.
- Keyboard: every control is reachable with Tab in reading order, and the focus outline is a clear 3 px ring.
- Test labels `[content N]` are on every TypeScript and pgTAP test and on every pytest docstring (checked all 7 `test_content_*.py` files, 66 tests, none unlabelled). No TODO, FIXME or placeholder in the new code or docs. No test was deleted. The only edited existing check is the count guard in `checks.yml`, raised from 9 to 130 with v2's 9 still required by name, as the spec says.

## Findings

### Must fix

1. **A reviewer who wants fixes cannot say "Not yet" and still send the file.** `review_page.py` lines 222 to 225 and 249 to 253. If the reviewer chooses "Not yet" on the dialogue, Download refuses with "choose whether you approve it", and `review_import.py` line 108 refuses any file where the dialogue is not approved. So the only way to send fixes is to tick "I approve this dialogue as a whole" while also asking for changes. That is a false approval inside a gate meant to be honest, and the message for "Not yet" is wrong (they did choose). Fix: either let the file carry "not yet" when any item is marked Fix or any clip is "sounds wrong" (the pipeline then treats the dialogue as pending and asks again next round), or reword the question to "Approve the dialogue as a whole once your fixes are in. You will see it again after any fixes", and make "Not yet" a valid answer that downloads. Add an e2e test for it.

2. **Long Finnish words run out of the card and make the page scroll sideways at 375 px.** `review_page.py` STYLE, `.finnish` (line 45), the `h3` (line 36) and `.meaning`. I put a 41 letter compound in a line: the line was 406 px wide in a 295 px card, and the page was 446 px wide. Finnish compounds are normal, and the design system's rule is `overflow-wrap: anywhere` for Finnish. Fix: add `overflow-wrap: anywhere` to `.finnish`, `.meaning`, `h3` and the `.note` lines, and add a long word to the fixture so a test sees it.

### Should fix

3. **Tap targets are under 44 px.** The Play and Download buttons are 40 px tall and the "Approve", "Fix", "Sounds right" and "Sounds wrong" choices are 24 px tall (13 px circle). The design system sets 44 px both ways, and the page has a phone viewport tag, so it will be opened on phones. Fix: `button { min-height: 44px }` and give `.choice` `min-height: 44px` with padding, so the whole label is the target.

4. **The choices are not grouped for screen readers.** The radio pairs sit in plain `div`s with no `fieldset` and `legend` (`radios()`, lines 81 to 95). A screen reader hears "Sounds right, radio button" 12 times with no clip named, and "Approve" with no line named. Fix: wrap each pair in a `fieldset` with a `legend`, for example "Line 1 spoken audio" or "Line 1 text and meaning". Each "Comment (optional)" box has the same problem (three per line, all with the same name); name them "Comment on line 1 spoken audio".

5. **Fix boxes and Finnish text carry no `lang="fi"`.** Finnish is shown and edited under `lang="en"` (line 401), so the browser's spell check underlines correct Finnish words in the fix boxes and screen readers read Finnish with an English voice. Fix: `lang="fi"` on the Finnish text and on the corrected-Finnish boxes (and `spellcheck` on there). Keep the English boxes `lang="en"`.

6. **Approve and Fix do not say what they cover.** They sit under the English meaning, after two clips and three comment boxes, with no heading. The reviewer can read them as approving the audio. Fix: a short heading above them, "Is the Finnish text and its English meaning right?", and one line under the audio choices, "Rate the sound only." Also reduce the three comment boxes per line: one comment per line card is enough (the clip verdict can show a comment box only after "Sounds wrong" is chosen).

7. **The page does not warn that closing it loses everything.** Nothing is saved. A 20 to 30 minute review lost to a refresh is a real risk. Fix: one line in the intro ("Do not close or refresh this page until you have pressed Download"), and a `beforeunload` prompt once any choice has been made.

8. **"Why" is jargon on the word cards.** Lines 207 and 211 say "Why: ..." and "Corrected why (one line)". The reviewer does not know this is the sentence a learner sees on the word card. Fix: "Explanation the learner sees" and "Corrected explanation (one line)". The same words appear in `docs/content-pipeline.md` and are fine there.

9. **The reviewer code is unexplained.** "Your reviewer code (for example R1, not your name)" does not say where the code comes from, and a non-technical reviewer may not have one. Fix: "Your reviewer code. The owner gave you one, for example R1. Do not write your name." Also name who to send the file to, or say "send it back to the person who sent you this page", because "Saved as review-...json. Send this file back." leaves out to whom.

10. **Round and dialogue wording.** The second intro line reads "Unit 1: Meeting someone at work. Can do: Can introduce yourself..." (two "can"). Fix: "Unit 1: Meeting someone at work. Goal: introduce yourself, say where you are from, and ask the same." Say what the spoken and written labels mean in one line each ("Spoken Finnish is how people talk. Written Finnish is the textbook form."), since the page is the reviewer's only briefing.

11. **No sense of progress on a 4,600 px page.** On a phone the page is 4,665 px high with 24 choices. There is no count of what is left, no way to jump to an unfinished item, and the error list at the bottom (`status`, line 229) names items but does not link to them. Fix: show "9 of 24 done" near the button, and make each problem in the list a link to its card (`href="#item-line-2"`).

12. **Dark mode is not themed.** The page sets `color-scheme: light` and ignores the phone or computer setting, so it stays white in dark mode (confirmed by the dark screenshots, identical to light). It is readable, so this is not a contrast failure. Fix: if the owner wants parity, declare the design system's dark values in a `prefers-color-scheme: dark` block. If not, say in `design.md` that the review page is light only.

13. **Clips can play over each other and cannot be paused.** `audioBlock` (lines 132 to 155) starts a clip on every Play press and never stops the others, and there is no pause or progress. The design system says starting one control stops any other. Fix: pause every other clip on Play and let the same button pause.

14. **Messages for the owner use internal names.** `review_import.py` lines 87, 91, 104, 114, 121 and `publish.py` lines 221 to 237 print "item audio-2-puhe", "item line-3", "its fingerprint differs". Fix: use the page's own labels ("Line 2 spoken audio", "Line 3") and say what happened: "Line 3 changed after the reviewer saw it, so the approval no longer counts". Also line 99 to 102 says "refused" for a file that is complete and correct when a clip is marked "sounds wrong"; say "The file is fine, but line 2 spoken audio needs a native recording at ... before the next round." (AGENTS.md lesson: a message must claim only what happened.) Also tell the reviewer on the page, after "Sounds wrong", "The owner will arrange a native recording. You will see this line again."

### Notes

15. **Colours and fonts are copied by hand.** The page uses hex values that match the tokens but not their names, and `system-ui` instead of Poppins and Switzer. The standalone file cannot load fonts from the network, and embedding Switzer in a file sent to an outside person would conflict with its licence (see `design.md`), so system fonts are the right call. The focus ring is `#1f42ac` (the changed-word colour) where the design system's focus colour is `--color-focus` (#1b1a20). Suggest declaring the values once as CSS custom properties with the token names at the top of STYLE, and using the real focus colour.
16. **Firefox was not tested** although `docs/content-pipeline.md` and the spec say it opens in Firefox. Say "tested in Chrome and Safari engines" in the docs, or add Firefox.
17. **"Fix" with unchanged text is accepted** and sends the line through a whole round (`apply_fixes` marks it changed). Warn on the page when Fix is chosen and no box differs from the original.

## Docs against the writing rules

`docs/content-pipeline.md` and `docs/content-attribution.md`: no em dashes or hyphens used as punctuation, no hype words, no "not X, but Y" in the pipeline doc. Mostly clean. Should fix:

- `docs/content-attribution.md` line 3: "it describes what is actually true, not an aim: v2 once labelled..." is a "not X" framing with a colon reveal. Write: "It describes what is true today. v2 once labelled content generated by an AI as Creative Commons material, which caused its content problems."
- `docs/content-attribution.md`, "Correction carried forward with a flag: v2's file said..." is a colon reveal. Write "v2's file said ... The list v3 imported was built from wordfreq instead, so this is flagged."
- `docs/content-pipeline.md`: "Example: `content/briefs/...`" is fine as a label. Step 6 says "Only the manager adds files there", which uses a factory role word the reader may not know; write "Only the factory manager session adds files there, when the owner says so."
- The cost figure differs between files: README says about $0.25 per dialogue, `docs/content-pipeline.md` adds up to about $0.21. Use one number.
- `docs/content-pipeline.md` should say in the review page section that the reviewer needs a code and who gives it (see 9), and that fixing a line that is already published is not built.

## Finnish golden set, drafting prompts and unit 1 hint wording

I am not a native speaker, so this is a plausibility read only. It goes to the native reviewer as the build notes say (the file's `about` field already says so).

- `content/checks/judge-golden-set.json`: all 20 pairs read as correct Finnish. Spoken forms look like ordinary Helsinki speech (mä, sä, oon, oot, ootko, mul, onks, teil, tuun, Turust, Helsingis, väsyny). The planted changes are each one clear change (number, negation, pronoun, time, thing, place). Weakness, not an error: the faithful pairs are very easy and several repeat the same spoken line ("Mä en tiedä.", "Mä tuun huomenna.", "Me ollaan töissä.", "Onks teil kahvia?", "Mul on kaks lasta."), and no planted change is subtle (a tense, a plural, a polite form, an added fact, which `JUDGE_SYSTEM` also names). Suggest adding a few harder pairs before the real run, so that the judge passing the set says more.
- `drafting.py` prompts: clear and consistent with the product rules (Helsinki spoken Finnish in 2026, no dialect, never a word list, never shaming, one line "why" of at most 140 characters, no mnemonics). No problems.
- Unit 1 fixture "why" lines (`fixtures/ai/unit-1-run.json`) read plainly. One to check with the reviewer: "Kotoisin means coming from a place, as in where you grew up." is looser than the usual sense (originally from, native to). The fixture is test only and never served.
- The brief (`content/briefs/meeting-people-new-colleague.json`) is clear and matches the PRD unit 1 can-do statement. Maria asking Aino "Oletko sinä Helsingistä?" when Aino is from Helsinki is natural.

Result: changes needed
