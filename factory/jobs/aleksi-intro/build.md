# aleksi-intro: build notes (fast route, 4 November 2026)

Branch `factory/aleksi-intro`, pull request https://github.com/fumnanyanketa/puhuscribe-v3/pull/37. Not merged.

## What was built

- **Landing buttons** now say "Meet Aleksi" (both buttons on the page; the top bar left in job landing-no-bar). `factory/jobs/17-landing-page/approved-copy.md` keeps the old text after "Was:".
- **Aleksi's intro screen.** A new visitor (nobody signed in on this device, no sign in ended here, and this phone has not met him) who opens the app sees the owner's "call card" design before the road: a tall rounded photo card, his name "Aleksi" in white with a small sound wave mark, the white bubble with "Moi! Mä oon Aleksi." (`lang="fi"`) and "Hi! I’m Aleksi.", a round mint play button, the line "I’ll be with you on your Finnish journey.", the mint "Nice to meet you" button with its arrow and "No account needed to start.". Built from the app's tokens, `Button` and `PlayControl`.
- **Who sees it.** It shows on `/learn` (where the landing buttons point) for a new visitor, whether they came from the landing button or typed the address. Returning learners, signed in people and a guest whose session ended here go straight to the road as before, and "Have an account? Sign in" is still on the road's day one card.
- **The photo.** The large portrait, cropped to 7:10 around the face and saved as WebP at 360, 720 and 1080 px wide (14 KB, 47 KB, 88 KB) in `public/aleksi/`, with `srcset` and `sizes`. Alt text "Aleksi, your Finnish tutor". The shade under his name is an inset shadow with a new token `--color-photo-shade`, because the CSS rules allow no gradient outside the page wash.
- **Aleksi's voice.** Harri (`fi-FI-HarriNeural`, male) reads "Moi! Mä oon Aleksi." once. New script `scripts/generate/aleksi_greeting.py` uses `providers/voice.py` unchanged (its log and monthly guards included). New task `voice-aleksi` in `.github/workflows/a1-road.yml`, the only new place that holds the Azure key. Run on this branch with `gh workflow run a1-road.yml --ref factory/aleksi-intro -f task=voice-aleksi -f part=1` (run 41846753181, success, 19 characters, free tier). The clip is `public/audio/aleksi/greeting-d4688145c5ab.mp3` (24 KB); the voice log line is committed in `content/logs/ai-calls.jsonl`.
- **Playing.** `PlayControl` has a new `tryOnOpen` option: the greeting tries once to play when the screen opens. If the browser refuses (an iPhone does without a tap, `NotAllowedError`), the button quietly stays "Play Aleksi’s greeting" with no error, and a press plays it. No loop. The sound wave mark moves only while the greeting plays, and not at all under reduced motion.
- **"Nice to meet you"** keeps one flag on the phone (`puhuscribe-aleksi-met` in localStorage, never sent) and opens the road with its opening animation, as before. If storage is blocked the visitor meets Aleksi again next time; nothing breaks.
- **Removed:** the two first-open questions and the recap card. The day one Start goes straight into the first lesson. The old answers key `puhuscribe-intro` is removed from the phone when the road opens.

## Removed with the feature (not weakened tests)

These files only covered the removed questions and recap card: `src/lib/intro-answers.ts` and `src/lib/intro-answers.test.ts`, `src/lib/intro-first-line.ts` and `tests/intro-first-line.test.ts`, `src/screens/intro-copy.ts` and `src/screens/intro-copy.test.ts` (its `canDoSentence` was used only by the recap card), `src/screens/IntroQuestion.tsx` and its CSS, `e2e/intro.spec.ts`. The recap card's branch and CSS left `src/road/RoadCard.tsx`.

## Tests changed because the behaviour changed

- `e2e/redesign-road.spec.ts` [redesign 16]: Start no longer goes through two "Skip this question" presses; it still checks no guest is made before Start.
- `e2e/redesign-road.spec.ts` [redesign 17] and [redesign 44]: "stores nothing" now leaves out the one key the test setup itself writes before the page loads (`e2e/road-mocks.ts` marks the phone as having met Aleksi, so road tests open on the road). Any key the road itself wrote still fails them.
- `e2e/intro-seen.ts`, `e2e/road-mocks.ts`, `e2e/test-base.ts`, `e2e/save-progress-helpers.ts`, `e2e/speaking-feedback.spec.ts`: the "already seen" key is now the met key.
- `scripts/generate/test_road_voice.py` [a1-road 19]: the list of steps that hold the Azure key adds the new greeting step.
- `tests/content-audio.test.ts` [content 17]: `public/aleksi/` joins the image only folders.

## New tests and what they cover

- `src/lib/aleksi-intro.test.ts`: [aleksi-intro 2] who meets Aleksi; [aleksi-intro 4] the flag, storage that throws or refuses, the old key cleared.
- `e2e/aleksi-intro.spec.ts`: [aleksi-intro 1] landing buttons; [aleksi-intro 2] everything on the screen, 44 px targets, axe, 320 px and 200 percent text, signed in and ended visitors never see it; [aleksi-intro 3] one try only, a blocked try leaves the button working; [aleksi-intro 4] "Nice to meet you" opens the road, Start goes straight to the lesson, a reload goes to the road, the old key is cleared.
- `scripts/generate/test_aleksi_greeting.py`: [aleksi-intro 3] Harri reads the exact line, one log line, no second clip, a fake clip never reaches `public/`.
- `tests/content-audio.test.ts`: [aleksi-intro 3] the greeting is served only with an owner approval file, matching bytes; a second clip, swapped bytes, a missing file, no owner line or no date each fail.

## Checks run

- `npm run check:code`: type check and lint pass. Prettier warns only on `design-drafts/*` (CRLF in this Windows checkout, as in earlier jobs; not files of this job).
- `npx vitest run`: 1267 passed, 2 failed. One is `scripts/hooks/commit-tool.test.ts` under load; alone it passes 13 of 13. The other is expected, see the first open point.
- `python -m pytest scripts/generate/test_aleksi_greeting.py scripts/generate/test_road_voice.py`: 25 passed. `python -m ruff check` and `ruff format --check` on `scripts/generate/`: pass.
- `npm run build`: passes, with the built secrets and built files checks.
- `npx playwright test e2e/aleksi-intro.spec.ts e2e/redesign-road.spec.ts --project=chromium --project=webkit`: 112 passed. Other browser specs, the database tests and the evals were not run (tests paused until the MVP, owner's instruction).
- Commit hooks (Prettier, gitleaks, and on the voice commit the same) passed on every commit.
- I looked at every screen at 375 x 812 and 320 wide in Chromium. Evidence in `factory/jobs/aleksi-intro/evidence/`: `intro-375x812.png` (taken while the greeting played, so the button shows pause), `intro-320x640.png`, `intro-320-text-200.png`, `road-after-intro-375x812.png`, `landing-button-375x812.png`. Made with `PUHUSCRIBE_EVIDENCE=1 npx playwright test e2e/aleksi-intro.spec.ts --project=chromium`.

## Open points

1. **The greeting needs a written approval before the audio check passes.** The repository rule is that no audio is served unapproved, and `scripts/ci/check-published-audio.ts` failed for any new file under `public/audio/`. I extended it so the greeting is served only when `content/approvals/aleksi-greeting.json` holds the owner's own written line. I did not write that file, because only the owner's words can approve. Until it exists, [content 17] in `tests/content-audio.test.ts` fails on this branch. The manager adds it on the owner's line:
   `{"format": "puhuscribe-owner-approval-aleksi-greeting-1", "approval": "<the owner's line, word for word>", "date": "2026-11-04", "file": "aleksi/greeting-d4688145c5ab.mp3", "sha256": "<the clip's SHA-256>"}`, where the SHA-256 comes from `sha256sum public/audio/aleksi/greeting-d4688145c5ab.mp3`.
2. **For the native reviewer.** One new learner-facing Finnish line: "Moi! Mä oon Aleksi." (spoken Finnish, shown as text and read by Harri). No other Finnish line was changed.
3. **iPhone.** Safari blocks sound that starts without a tap, so on most iPhones the greeting will not play by itself; the button shows the play triangle and plays it on a tap. Chromium here played it by itself. Playwright's WebKit on Windows cannot play MP3 at all (it shows "Could not play. Try again" for every clip in the app, not only this one), so the iPhone path was checked with a stub that refuses play as Safari does, not on a real iPhone. Please check on a phone with the preview link.
4. A visitor who opens `/learn` directly (not from the landing button) also meets Aleksi, if new. Telling the two apart would need a marker in the link; I left it out.
5. The privacy notice's cookies section mentions sign in cookies only. The phone now keeps one flag ("met Aleksi"), never sent, in place of the two stored answers. Same open point as job intro.
6. Small differences from the mockup, from using the app's own parts: the bubble's corners are the app's 18 px with a 6 px tail corner (the mockup drew 20 px), and "Nice to meet you" is the app's 52 px primary button (the mockup drew 58 px).

## Round 2: voice samples (owner: "Change the voice")

The served clip is unchanged until the owner picks. New `samples` mode in `scripts/generate/aleksi_greeting.py` and task `voice-aleksi-samples` (same workflow step and key as `voice-aleksi`). `providers/voice.py` now takes an optional SSML rate and pitch (a signed whole percent, checked) and Azure's multilingual voices, which read the text inside `<lang xml:lang='fi-FI'>`; it also reads Azure's free voice list. Without those options the request is the same as before. Run 41854407253 on this branch, artifact `road-voice-aleksi-samples-1`, 7 clips of 19 characters, 133 in all (free tier; November's voice total is now 74,448 of the 450,000 guard). The voice log is committed; the clips are not.

- `1-harri.mp3`: fi-FI-HarriNeural, as is.
- `2-harri-warmer.mp3`: fi-FI-HarriNeural, rate -8%, pitch -4%.
- `3-harri-brighter.mp3`: fi-FI-HarriNeural, rate -3%, pitch +6%.
- `4-andrew.mp3`: en-US-AndrewMultilingualNeural, Finnish through `<lang xml:lang='fi-FI'>`.
- `5-brian.mp3`: en-US-BrianMultilingualNeural, the same way.
- `6-florian.mp3`: de-DE-FlorianMultilingualNeural, the same way.
- `7-william.mp3`: en-AU-WilliamMultilingualNeural, the same way (first in name order of the other male multilingual voices that list fi-FI).

None was skipped: all named voices list fi-FI. The voice list also names these male multilingual voices with fi-FI: en-GB-Ollie, en-US-Adam, Brandon, Christopher, Davis, Derek, Dustin, Lewis, Ryan, Samuel, Steffan, es-ES-Tristan, es-MX-Jorge, fr-FR-Lucien, Remy, it-IT-Alessio, Giuseppe, Marcello, ko-KR-Hyunsu, pt-BR-Macerio, zh-CN-Yunfan, Yunxiao, Yunyi, and the Turbo voices Alloy, Echo and Onyx. New tests in `scripts/generate/test_aleksi_greeting.py` ([aleksi-intro 3]): the sample plan and its report, a voice without fi-FI skipped, the SSML for prosody and a multilingual voice, a bad prosody value refused. `pytest scripts/generate/test_aleksi_greeting.py test_content_providers.py test_road_voice.py` passes; ruff passes.

## Run it locally

`npm ci`, `npm run build`, `npx vite preview`, open `/learn` at 375 px in a fresh browser profile. To see it again, clear the site's storage.

Result: blocked: the greeting clip needs the owner's written approval file (content/approvals/aleksi-greeting.json) before the audio check passes; everything else passes.
