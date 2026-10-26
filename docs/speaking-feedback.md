# Speaking feedback

How Say it gives a learner feedback on their spoken Finnish, and how to check and change it. Spec: `factory/jobs/10-speaking-feedback/spec.md`.

## The flow

1. Say it comes after Understand it. The first time, the learner sees the consent screen (text and version label in `src/lib/voice-consent.ts`). Nothing asks for the microphone until they press "Turn on speaking feedback". "Not now" shows each line to say out loud, with no recording.
2. The learner presses the record button. `src/lib/recorder.ts` records with `MediaRecorder` in the first format the browser offers, decodes it in the browser and turns it into 16 kHz mono 16 bit WAV. The microphone is released after every try. A recording stops by itself at 10 seconds; one shorter than half a second counts as not heard and is never sent.
3. The app sends the WAV as base64 JSON to `POST /api/speech/say` with the session and line ids. The Worker (`worker/speech.ts`) checks the sign in, the consent, the session step, the line, the body size, the audio format and the rate limit before anything reaches the speech service. The limit is 40 checks in 10 minutes. The slot is taken in one database step (`public.reserve_speech_check`) before the speech service is asked and is never given back, so parallel requests cannot beat the limit and a failed call counts too. It reads the line's text itself, so the browser never sends reference text.
4. The provider (`worker/providers/speech-feedback.ts`) sends the audio to Azure's speech to text REST API for short audio in an EU region and maps the answer into a plain shape: status, heard text and word flags.
5. The rules (`src/lib/speech-feedback.ts`, no AI) compare the heard text with the line, word by word, against both the spoken and the written line, and pick one class and at most one hint.
6. The Worker stores one `speaking_attempts` row (transcript, class, provider, audio length, cost) and answers with the class and hint only. With "keep my recordings" on, it also stores the WAV as the line's first or latest try.
7. The app shows one status line message. "Play my recording" plays the try from the page's memory.

Voice settings at `/voice` show both choices, each changed with one press, and the kept recordings with Play and Delete. Withdrawing deletes recordings (and, for speaking feedback, clears transcripts) in the same database transaction.

## The rules and their numbers

Every number the rules use is in `content/checks/speech-thresholds.json`: how many word errors still count as close, how far a word may be off, and the mispronunciation score below which a flagged word turns `clear` into `close`. They are provisional until risk test 3 measures them on real learner clips.

| Class | Message |
| --- | --- |
| clear | Yes, that was clear. |
| close | One hint: a doubled letter, a single letter, a vowel, a missing word or a word that was off |
| try_again | Listen to the line once more, then try again. |
| not_heard | That was too quiet to hear. Try again a little closer to the phone. |

Finnish words in hints always come from the approved line, never from what the service heard.

## Running the evals

- `npm run eval:speech` runs the 30 golden cases in `content/checks/speaking-feedback-golden.json` through the rules and fails below 90 percent. The pull request checks run it too. The rules and the labels were written in the same job, so a pass proves the rules do what the labels say; whether the labels match a native ear is the reviewer's check and risk test 3's.
- `npm run eval:speech-wer -- <folder>` runs real clips through the provider and reports word error rate and agreement with the reviewer, with no transcript in the output. The folder must be outside the repository or ignored by git. It holds a manifest of clip file, reference line, the reviewer's label and whether a length mistake was planted. The 50 clip run belongs to risk test 3.

## Testing without the real service

Set `SPEECH_FEEDBACK_PROVIDER=fake` (only in the pull request browser job and locally). The fake replays answers from `worker/providers/fixtures/speech/`, picked by the `x-test-speech-fixture` request header, which only the fake reads. With no header it answers as if it heard the line exactly. The manual workflow "Speech fixtures" replaces the three `recorded-line-*` files with Azure's real answers to synthetic clips once the key exists.

## Swapping the provider

Change `worker/providers/speech-feedback.ts` only: add a provider that returns the same plain answer shape and its cost per call, and pick it with `SPEECH_FEEDBACK_PROVIDER`. The rules, the Worker routes and the app stay as they are. `tests/speech-provider-rules.test.ts` checks that no other file calls a speech service.

## Spoken answers in daily review

In Keep it, every second item (the 2nd, 4th and so on of the run) asks the learner to say the missing word, when speaking feedback is on and recording works on the device (`src/lib/answer-mode.ts`). The learner never picks. The app sends the WAV to `POST /api/speech/recall` with the session and form ids. The Worker uses the same checks and the same limit as Say it, takes the form's spoken shape from the database as the reference and accepts either register. The class becomes the rating by one table (`src/lib/review-grade.ts`): clear is Good, close is Hard, try again is Again. A recording that was not heard grades nothing and is asked for again; after a second one, or any recording failure, the item switches to typing. The rating is saved through the same path as a typed answer, with `review_logs.mode = 'spoken'`.
