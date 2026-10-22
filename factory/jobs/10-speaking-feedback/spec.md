# Job 10-speaking-feedback: Speaking feedback and voice consent (Say it)

Scope item 8. GA. Needs a decision. Date: 21 October 2026. Builds on jobs 1 to 5 and `8-first-session` as merged on main; the review part also needs `9-daily-review` merged. Test label: `[speak N]`.

## Summary for the owner

1. A new step, Say it, comes after Understand it: the learner hears each line, records themselves saying it, and gets one short, kind hint such as "Close. Try the double k."
2. Before the first recording, a plain screen says what is recorded, where it goes (Microsoft's speech service in the EU) and that it is deleted. Nothing is recorded until they agree, and "Not now" still lets them say the lines aloud without feedback.
3. The recording is thrown away as soon as the feedback is ready. Only the text the service heard and the result are kept, and the text is deleted after 90 days. Keeping recordings to hear your progress is a separate box, off by default, for 90 days, deletable any time.
4. Daily review gets spoken answers: every second review item asks the learner to say the Finnish, graded by the same rules.
5. Uses the Azure Speech resource you are setting up for job 7. Free tier during the build; about $1 per hour of learner audio once on the paid tier. Real proof that the feedback agrees with a native ear waits for risk test 3, which may change the provider.

## What it is

The Say it step of the loop. The learner shadows each line of the dialogue: listens, records a few seconds, and gets phrase level feedback. The recording goes through PuhuScribe's Worker to a speech service that turns it into text and checks it against the approved line. Fixed, tested rules (no AI) turn that into a feedback class and one gentle hint. Voice consent is asked once, in plain words, and can be withdrawn as easily as it was given. The same machinery gives daily review its spoken answers.

It serves P4 (the learner says it back every session and gets feedback), P5 (they shadow the spoken Finnish line), and P2 (spoken recall in review, graded automatically, no self rating).

## Done when

Terms. "Phone size", "browser test", "the fixture" and "a learner" mean what job 8 defined (375 x 812 in Chromium and WebKit, Playwright against the built app and a throwaway local Supabase, job 8's test seed, a guest signed in through job 8). "The fake" is the recorded fake speech provider (statement 12). Browser tests never use a real microphone or the real speech service: they replace the microphone with a generated tone (never speech) and run the Worker with the fake. Tags: **[security]** and **[personal data]** mark statements the security reviewer and evaluator check closely.

### Voice consent

1. **Consent comes before the first recording.** The first time a learner reaches Say it with no current voice consent, the step shows the consent screen, and no microphone request is made until they agree (browser test counts zero `getUserMedia` calls before "Turn on speaking feedback" is pressed). The screen says, in plain sentences:
   - what is recorded: your voice, only while the record button is on, a few seconds per line;
   - where it goes: from this phone through PuhuScribe's server to Microsoft's speech service in the EU region named in the settings (for example "Ireland"), which turns it into text, and PuhuScribe compares that text with the line;
   - that it is deleted: Microsoft does not keep it, and PuhuScribe deletes it as soon as the feedback is ready;
   - what is kept: the text the service heard and how close it was, to check the feedback works, deleted after 90 days;
   - an unticked box, "Keep my recordings so I can hear my progress. We keep your first and latest try of each line for 90 days. You can delete them at any time.";
   - that both choices can be changed at any time in Voice settings.

   Buttons: "Turn on speaking feedback" (primary) and "Not now" (secondary). The final wording follows owner's call 2. **[personal data]**
2. **Consent is recorded as history, with the text version.** "Turn on speaking feedback" adds one `consents` row (`voice_processing`, granted), plus a `voice_recording_retention` granted row only if the box was ticked. The text lives in one file with a version label (for example `voice-2026-10.1`); the Worker writes that label and the browser cannot choose it. A unit test fails when the text changes and the label does not. A browser test checks the rows in the database. **[personal data]**
3. **"Not now" still lets the learner say it back.** After "Not now", or when the learner has withdrawn, Say it shows each line with its play controls and "Say the line out loud after the voice.", with "Next line" and a quiet "Turn on speaking feedback" that opens the consent screen. Nothing is recorded or sent. Browser test.
4. **Withdrawing is as easy as agreeing.** `/voice` (Voice settings, linked from the front door and from Say it) shows both current choices and lets the learner turn each on or off with one press. Turning off "keep my recordings" adds a withdrawn row and deletes every kept recording of theirs in the same database transaction. Turning off speaking feedback adds a withdrawn row, deletes every kept recording and clears every stored transcript of theirs, also in one transaction. Feedback classes and review results stay, because they hold no voice and are learning progress. pgTAP and a browser test. **[personal data]**

### The Say it step

5. **Say it sits in the step list.** Job 8's single step list gains Say it between Understand it and the finish screen, as job 8's statement 8 planned. The top bar reads "Hear it, step 1 of 3", "Understand it, step 2 of 3", "Say it, step 3 of 3". Finishing Say it stores `step_reached = 'say'`; the Worker accepts `say` only for the learner's own session at `understand`. Leaving and coming back resumes at Say it (step `understand`, not ended) or the finish screen (step `say`, not ended). Job 8's tests that name the step count or the resume point are updated to the new list with their labels kept, and `build.md` lists each changed line; no other job 8 test changes. Job 8's data (tables, columns, functions, `complete_session`, the fixture) is unchanged. Browser test including the database values.
6. **Shadow every line.** Say it shows the dialogue's lines one at a time with `FinnishLine` (spoken first, written labelled) and both play controls, then `RecordControl`. Recording starts on a press, shows the elapsed time, stops on a second press, and stops by itself at 10 seconds. "Next line" appears after the first attempt at a line, with any result; "Try again" stays available. On the last line the primary button reads "Continue". A quiet "I can't speak right now" skips the rest of Say it for this session without recording. Browser test runs a whole dialogue, one attempt per line.
7. **Feedback is phrase level, kind and never shaming.** Each attempt ends in exactly one `StatusLine` message, chosen by the class and hint from statement 10:

   | Result | Tone | Text |
   |---|---|---|
   | clear | neutral | "Yes, that was clear." |
   | close, doubled letter missed | gentle | "Close. Try the double k." (the letter from the line) |
   | close, single letter doubled | gentle | "Close. Try a single k." |
   | close, vowel swapped | gentle | "Close. Try ä instead of a." |
   | close, a word missing | gentle | "Close. Try it again with *oon*." (the word from the approved line) |
   | close, a word off | gentle | "Close. Listen to *oon* once more, then try again." |
   | try again | gentle | "Listen to the line once more, then try again." |
   | not heard | gentle | "That was too quiet to hear. Try again a little closer to the phone." |

   Finnish words in hints come only from the approved line, never from the transcript, and carry `lang="fi"`. No score, percentage, stars, red, count of mistakes, or transcript is shown. Browser tests cover every row with the fake.
8. **The learner can hear their own try.** After an attempt, "Play my recording" plays it from the phone's memory. The recording is released when the learner moves to the next line or leaves, and is never written to `localStorage`, `sessionStorage`, IndexedDB or the cache (browser test inspects all four). **[personal data]**
9. **Recording works with each browser's own format, and fails kindly.** The recorder picks the first format `MediaRecorder.isTypeSupported` accepts from a fixed list (`audio/webm;codecs=opus`, `audio/mp4`, `audio/webm`, `audio/ogg;codecs=opus`), decodes the result in the browser and turns it into 16 kHz mono 16-bit WAV, the format Azure's short audio API takes. Unit tests cover the WAV writer and the resampler. The microphone is released after every recording (all tracks stopped). Clear states, each with `RecordControl`'s unavailable state or a problem `StatusLine`, and "Continue" always possible:
   - no microphone support or an insecure page: "Recording is not available in this browser.";
   - permission refused: "Microphone access is off. You can turn it on in your browser settings, or carry on without recording.";
   - the app goes to the background while recording: the recording is thrown away and "Recording stopped because the app was in the background. Try again." shows;
   - shorter than half a second: treated as not heard in the browser, with no call to the server.

   Browser tests stub the microphone for each case. Chromium runs the real `MediaRecorder` and decode path on the generated tone. If Playwright's WebKit build lacks `MediaRecorder`, WebKit tests stub at the recorder module's boundary instead, and `build.md` says so. Real iPhone behaviour is not proven here (Risks).

### Feedback rules

10. **Fixed, tested rules turn the service's answer into a class.** `src/lib/speech-feedback.ts` (pure TypeScript, no network, no AI) takes the approved line in both registers and the provider's normalised answer (status, heard text, and optional per word flags) and returns one class (`clear`, `close`, `try_again`, `not_heard`) and at most one hint. It reuses v2's `normalizeAnswer` and `levenshtein` from `src/lib/grade.ts` unchanged, compares word by word, and accepts a match against either the spoken or the written line (a speech service may write "mä oon" as "minä olen"). A word the provider flags as mispronounced below a set score turns `clear` into `close`, with the hint on that word. Every number the rules use (closeness limits, the mispronunciation score) sits in `content/checks/speech-thresholds.json`, provisional until risk test 3. Unit tests cover each class and hint kind.
11. **The golden set of 30 passes at its recorded rate.** `content/checks/speaking-feedback-golden.json` holds 30 cases, each a target line (both registers), what was heard, optional word flags, the expected class and hint. Targets are lines 1 to 10 of `docs/risk-tests/test-2-voice-lines.md` (already in the repository, not reviewed, used as test data only). The cases cover at least: exact, punctuation and capitals only, spoken heard as written, a doubled consonant missed (kk, tt), a long vowel shortened (tuuli said as tuli), a single letter doubled, ä and a swapped, one word missing, one extra word, two or more words wrong, nothing heard, and a flagged mispronunciation. `npm run eval:speech` runs the set, prints the pass rate, and fails below the PRD's 90 percent (recorded in `speech-thresholds.json`); the same check runs in the pull request checks. The result goes in the evidence folder. Honest limit, written in `build.md`: the rules and the labels are both written in this job, so a pass proves the rules do what the labels say; whether the labels match a native ear is checked by the reviewer (owner's call 3) and measured on real clips in risk test 3.

### The provider and the Worker

12. **Speech feedback sits behind one module.** `worker/providers/speech-feedback.ts` is the only file that calls a speech service. `SPEECH_FEEDBACK_PROVIDER` picks `azure` or `fake`. The `azure` provider calls Azure's speech to text REST API for short audio with locale `fi-FI`, `format=detailed`, and a `Pronunciation-Assessment` header built with `JSON.stringify` (reference text, `HundredMark`, `Word` granularity, `Comprehensive`, miscue on, prosody off), a 10 second timeout using `AbortController` and a timer, and one retry on 429. It maps Azure's answer (`RecognitionStatus`, `Lexical`, word `ErrorType` and `AccuracyScore`) into the normalised answer. The `fake` replays recorded responses from `worker/providers/fixtures/speech/`, chosen by an `x-test-speech-fixture` header that only the fake reads. A repository test proves no file outside the module names an Azure address or reads the Azure key, that `wrangler.jsonc` and every deploy workflow never set `fake`, and that the `azure` provider ignores the test header. **[security]**
13. **Audio goes only to an EU region.** The resource region is a Worker setting. The `azure` provider refuses to start unless the region is on a fixed EU list (for example `northeurope`, `westeurope`, `swedencentral`, `francecentral`, `germanywestcentral`), and a unit test proves `eastus` is refused. When the key or region is missing, Say it shows `RecordControl` unavailable with "Speaking feedback is not available right now." and "Continue" still works. **[security] [personal data]**
14. **The Worker decides what is checked, never the browser.** `POST /api/speech/say` takes JSON (`sessionId`, `lineId`, the WAV as base64), keeping job 8's rule that every changing route takes only JSON `POST` with the origin check. The Worker reads the line's spoken and written text with the learner's own token, so the approval rules decide; the browser never sends reference text. It refuses, before any call to the speech service: no sign in (401); no current `voice_processing` consent (403); a session that is not the learner's or not at `understand` (404); a line that is not in that session's dialogue or not readable (404); a body over 512 KB (413, read and capped before answering); audio that is not a RIFF WAV, PCM, 16 kHz, mono, 16 bit, at most 10 seconds (400); more than 40 checks by this learner in the last 10 minutes (429, with "You have recorded a lot in the last few minutes. Take a short break, then try again."). Worker unit tests cover each refusal with a fake that counts calls and must stay at zero. **[security]**
15. **The answer holds no transcript.** The Worker answers with the class and hint only. The transcript stays on the server. Browser test inspects the response bodies.

### What is stored

16. **Only the transcript and a feedback class, unless the learner opted in.** One migration adds:
    - enum `speech_feedback_class` (`clear`, `close`, `try_again`, `not_heard`);
    - table `speaking_attempts`: `id` (uuid), `user_id` (default `auth.uid()`, references `auth.users(id)` on delete cascade), `session_id` (references `sessions(id)` on delete cascade, empty for review), `line_id` (references `dialogue_lines(id)` on delete restrict) or `form_id` (references `forms(id)` on delete restrict), exactly one of the two, `transcript` (at most 300 characters, may be empty), `feedback_class`, `provider` (a short label), `audio_ms`, `cost_usd`, `created_at` (set by the database). No audio, device, address or free text column;
    - table `kept_recordings`: `id` (uuid), `user_id` (as above), `line_id`, `slot` (`first` or `latest`, unique per learner and line, so at most two per line), `audio` (WAV bytes, at most 330,000), `created_at`;
    - all permissions removed from `anon`, `authenticated` and `service_role`, then `authenticated` may read its own rows of both tables, insert its own rows, delete its own kept recordings, and update `transcript` only to empty. Row level security on. An attempt can be added only when the learner's newest `voice_processing` consent is granted, and only for a line of their own session at `understand` or later, or a form they hold a card for. A kept recording can be added only when their newest `voice_recording_retention` consent is granted, for a line they have an attempt on.

    pgTAP proves, with learners A and B, every rule above: A cannot read B's attempts or recordings, add a row carrying B's id, B's session or a line from a session not at `understand`, add an attempt without consent or after withdrawal, add a kept recording without retention consent, add a third recording for one line, or change a transcript to anything but empty; `anon` reaches nothing; deleting a user removes both tables' rows. The job 3 table list and catalogue tests include the new tables. `src/lib/database.types.ts` is regenerated by the CLI. A scratch branch that drops the consent condition turns the database check red, and the run is linked in `build.md`. **[security] [personal data]**
17. **Audio is discarded by default.** With retention not granted, a browser test runs a full Say it and then finds attempts with transcript and class, and zero rows in `kept_recordings`. A Worker unit test proves the audio bytes are never passed to a log, the cache, or any store except the kept recordings insert. **[personal data]**
18. **Ninety days, then gone.** A function in the `private` schema deletes kept recordings older than 90 days and clears transcripts older than 90 days. A `pg_cron` job in the migration runs it daily. pgTAP backdates rows and proves the function removes exactly the old ones. **[personal data]**
19. **Kept recordings: first and latest per line, the learner's own, deletable.** With retention granted, each attempt's WAV is stored as the line's `first` if none exists, otherwise it replaces `latest`. Voice settings lists the learner's kept recordings, newest first, each with the line's spoken text, the date, "Play" and "Delete", plus "Delete all my recordings". `GET /api/voice/recordings/<id>` streams only a recording the learner's token can read, with `cache-control: private, no-store`; another learner's id answers 404, the same as a missing one. Worker unit tests and a browser test (A records, B cannot fetch A's recording). **[security] [personal data]**
20. **Every speech call is logged with its cost.** Each call that reached the speech service writes exactly one `speaking_attempts` row with `provider`, `audio_ms` and `cost_usd`, computed from a dated price table in the provider module that cites its source. Unit test: one call, one row, cost matches the table.

### Spoken recall in review

21. **Review gains spoken answers.** In job 9's review, the answer method of each due item is set by one tested rule: every second item asks for a spoken answer when speaking feedback is on and recording works on this device; otherwise the item is typed. The learner never picks a mode. A spoken item shows `RecordControl`; `POST /api/speech/recall` (same checks as statement 14, with a `formId` the learner holds a card for) sends the form's spoken shape as the reference and accepts either register. The class becomes the rating by a fixed table: `clear` to Good, `close` to Hard, `try_again` to Again. `not_heard` grades nothing and asks again; after a second `not_heard` or a recording failure, the item switches to typing. The rating is then applied through job 9's own grading path with `review_logs.mode = 'spoken'`. Unit tests cover the rule and the table; a browser test answers one spoken item with the fake and checks the review log and the card's new due date. If job 9's merged spec offers a different slot, this statement follows it and the manager is told.

### Evaluation harness, logs and records

22. **The word error harness is built; the vendor verdict waits for real clips.** `npm run eval:speech-wer -- <folder>` reads a manifest (clip file, reference line, the reviewer's "said correctly" or "not correct, and where" label, and whether a length mistake was planted) from a folder outside the repository or ignored by git (it refuses any other folder), runs each clip through the provider module, and writes per clip word error rate, overall word error rate, agreement with the reviewer, and length mistakes caught, with no transcript text in the output. A test runs it on five generated tone clips with recorded fake answers and checks the exact numbers. `speech-thresholds.json` records the PRD target (word error rate below 25 percent on 50 non native clips) and risk test 3's bar (at least 85 percent agreement with the reviewer). The 50 clip run, and therefore "the vendor pick meets the word error target", happens in risk test 3; `build.md` says so and the manager updates the scope line.
23. **Real Azure answers replace the hand-made fixtures when the key exists.** A manual GitHub workflow, "Speech fixtures", sends three synthetic clips (fixture lines voiced by Azure text to speech, never a human voice) through the `azure` provider and commits their answers, with no key or header, as the fake's fixtures. Until the owner's key exists, the fixtures are built from the response shape in Microsoft's documentation and each file says so. The workflow runs only on manual start.
24. **Logs and secrets.** The Worker logs no audio, transcript, reference text, cookie, token, user id or address (unit test watches `console`). The Azure key exists only as a Worker secret and a GitHub secret, under the names job 7 uses for the same resource. The built file secret checks still pass. **[security]**
25. **Phone, keyboard, accessibility.** Every new screen at phone size: no sideways scrolling at 320 px or with text at 200 percent; tap areas at least 44 x 44; the whole flow, recording included, works by keyboard alone; every feedback message is announced through the status line; `@axe-core/playwright` finds no WCAG 2.0 to 2.2 A or AA violation in light and dark mode. All earlier tests stay green, apart from the job 8 lines statement 5 names.
26. **Records.** `docs/conventions.md` adds the `[speak N]` label row and names `worker/providers/speech-feedback.ts`. `docs/data-model.md` describes both new tables, the clean up job and the consent effects. `docs/speaking-feedback.md` explains the flow, the rules, the thresholds, how to run both evals, and how to swap the provider. The README running costs list adds Azure speech to text. `.env.example` names the new variables.

Product rules from `AGENTS.md` that apply: P4, P5 and P2 as above; one front door and no mode picking; gentle corrections, never shaming; AI never grades (no AI is used); every speech call logged with cost; nothing unapproved is served (reference text and hint words come from approved lines); GDPR minimum data, export and deletion possible (the new tables cascade with the user); audio discarded by default and kept only by opt in, in the EU; no users under 18 (job 8's front door line); the speech provider sits behind one module; agents use only the test database; no placeholders; never delete or weaken a test except as statement 5 states; client facing text in English; the "Not in v3.0" list is binding.

## Threat model (GA)

**What is the worst a malicious person could do here?**
- Listen to another learner's voice or read their transcripts. Stopped by row level security on both tables, unguessable ids, the Worker reading with the learner's own token, `no-store` answers, and 404 for anything not theirs (16, 19).
- Use PuhuScribe's Azure key as a free pronunciation service, or run up the bill. The browser never sends reference text (only approved lines or the learner's own forms), audio is capped at 10 seconds and 512 KB, each learner gets 40 checks per 10 minutes, the Azure free tier stops at its allowance, and the paid tier has your budget alert. Many guest accounts could still multiply the per learner cap; that is job 8's open guest abuse decision, due before launch.
- Crash or slow the Worker with huge or malformed uploads. The body is read and capped first, and only a well formed short WAV reaches the provider.
- Forge their own attempts or review results by calling Supabase directly with their own cookie. Possible only on their own rows, as job 8 already allows for cards; it harms only their own progress.
- Get a recording kept without consent, or kept forever. The database refuses kept recordings without current retention consent, withdrawal deletes them in the same transaction, and the daily job removes anything past 90 days.

**What data are we storing that we must protect?**
- Voice audio: in the Worker's memory during one request, and in `kept_recordings` only for learners who opted in (first and latest per line, 90 days).
- Transcripts (90 days), feedback classes, the cost of each call, and the consent history.
- The Azure key.
- The app never uses a voice to identify anyone, so recordings are not processed as biometric data in the sense of GDPR Article 4(14). This is not legal advice.

**What must the system refuse even if asked nicely?**
- Asking for the microphone or calling the speech service before voice consent, or after it is withdrawn.
- Checking any text the browser sends, or a line the learner has not reached.
- Storing audio without retention consent, keeping more than two recordings per line, or keeping any past 90 days.
- Sending audio to a region outside the EU, or to any service except through the provider module.
- Writing audio, transcripts, tokens, user ids or addresses to any log.
- Showing a score, a red mark, a transcript, or a count of mistakes.
- Letting AI decide a class or a rating.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | Speech provider for the MVP | Azure pronunciation assessment, scripted (the line is the reference), `fi-FI`, through `worker/providers/speech-feedback.ts`. Provisional per factory plan decision 8; risk test 3 may swap it by changing this one module | Plain transcription from another vendor compared to the line (OpenAI, Soniox, ElevenLabs Scribe, the risk test 3 candidates) | The factory plan and job 1-stack name Azure as provisional, the resource is shared with job 7, and it adds word level flags on top of the transcript. Risk test 3 compares all of them on real clips; deciding before that would be preference, which PRD rule 16.2 forbids |
| 2 | Which Azure API | Speech to text REST API for short audio, called from the Worker with the key as a Worker secret | Azure Speech SDK in the browser with a 10 minute token from the Worker | Microsoft suggests the REST API only when the SDK cannot be used. The SDK would send audio straight from the phone to Azure, breaking the same address rule from jobs 1 and 2, and the Worker could no longer enforce consent, caps and the reference text. Short audio REST takes up to 30 seconds for pronunciation assessment, enough for 2 to 6 second lines |
| 3 | Audio format | Record with `MediaRecorder` in whatever format the browser offers, decode in the browser, send 16 kHz mono 16 bit WAV | Capture raw samples with an `AudioWorklet` and skip `MediaRecorder` | `MediaRecorder` is the documented recording API in Safari 14.1 and later and in Chrome; only the container differs (mp4 and AAC on older Safari, WebM and Opus on Chrome and Safari 18.4 and later). Raw capture needs more of our own code and meets iPhone sample rate quirks. Azure's short audio API takes only WAV PCM or Ogg Opus at 16 kHz, and a Worker cannot decode AAC, so the browser converts |
| 4 | Sending audio | JSON with the WAV as base64 | A raw `audio/wav` body | Keeps job 8's rule that every changing route is JSON only, which forces a browser preflight from other sites. Costs a third more bytes (about 430 KB at the 10 second cap) |
| 5 | What decides the feedback | Fixed rules on the transcript, word by word, against both registers, with Azure's word flags only able to turn `clear` into `close` | Azure's overall pronunciation score with cut-offs | Transcript comparison is what PRD 4.1 names for v3.0 and works with any provider risk test 3 picks. A single score cannot say which word to try again, and no study of Azure's scores on Finnish learners exists (factory plan, test 3) |
| 6 | Where opted in recordings live | A `kept_recordings` table in the EU Supabase project, behind its row level security, capped at first and latest per line | Cloudflare R2 bucket with EU jurisdiction and a 90 day expiry rule | R2 needs a new service and, by third-party accounts, a payment method on file (an owner's call), and job 11 would have to delete files separately at account deletion. In the database, account deletion and withdrawal remove recordings by the existing cascade and the same transaction. Supabase Storage lost too: it has no expiry rule, deleting files needs its API (not SQL), and Supabase refuses to delete a user who owns Storage objects. Consequence: about 15 MB per heavily opted in learner, so the free 500 MB holds about 30 of them; move to R2 before launch if many opt in (Risks) |
| 7 | Transcript retention | 90 days, then cleared; feedback classes stay | Kept until the account is deleted | GDPR's storage limitation. 90 days matches the recordings promise, so the consent text states one number. Owner's call 2 can change it |
| 8 | How spoken recall picks its items | Every second due item, when speaking feedback is on and recording works | Let the learner choose to type or say each item | The learner never picks a mode (AGENTS.md). The fallback to typing after a failure is a recovery, not a choice |
| 9 | The "can't speak now" exit | A quiet "I can't speak right now" that skips Say it for this session | No exit | Learners use the app on buses and at work. Duolingo has the same exit for speaking exercises (Android Authority, 10 August 2026). Use is visible in the attempts table for job 14's "uses speak back" number |

New npm packages: none planned. If the builder adds one, `build.md` gives the reason.

## Out of scope

- Sound level (phoneme) feedback, pronunciation scores, progress charts or recordings comparison views. "Pronunciation deep feedback" is paid tier, v3.2.
- Showing the transcript to the learner.
- The 50 clip vendor bake off and any provider change (risk test 3). Real learner clips, the reviewer's labelling page.
- The privacy notice, data export, account deletion screens, email accounts (job `11-accounts`); this job's tables cascade so that job can rely on them.
- Analytics dashboards and new usage events (job 14). Rate limiting by address, CAPTCHA or Turnstile (job 8's pre-launch decision).
- The tutor (job 12) and any AI call. Native recordings of lines.
- Offline recording or a queue for later sending (v3.2 offline mode).
- Install to home screen and iPhone standalone fixes (job 16 and risk test 1).
- From the "Not in v3.0" list: no streaks, scores, rank titles, confetti or milestone ladder; no practice hub or separate Speak mode (Say it lives only inside the loop and review); no bilingual or Finnish-only toggle; no YKI content.

## Build plan

1. **Database.** Enum, both tables, grants and rules, consent effects on withdrawal, the 90 day function and its `pg_cron` job, pgTAP, regenerated types, the red scratch run. Covers 4, 16, 18, part of 19.
2. **Rules and evals.** `speech-feedback.ts`, hint texts, thresholds file, golden set and `eval:speech`, the word error harness and its tone test. Covers 7 (texts), 10, 11, 22.
3. **Provider and Worker.** The provider module with `azure` and `fake`, region list, fixtures from the documented shape, `/api/speech/say`, `/api/voice/*` consent and recordings routes, caps and refusals, cost rows, quiet logs. Covers 2, 12 to 15, 17, 19, 20, 24.
4. **Screens.** Consent screen, Say it in the step list, recorder module (format pick, decode, resample, WAV), feedback, "Play my recording", Voice settings, the job 8 test updates. Covers 1, 3 to 9, 25.
5. **Spoken recall.** Needs `9-daily-review` merged. Covers 21.
6. **Live fixtures and records.** The "Speech fixtures" workflow once the key exists, docs. Covers 23, 26.

**Dependencies.**
- `8-first-session` merged (step list, sessions, front door, sign in). `9-daily-review` merged for milestone 5 only.
- `6-pr-local-db` for browser tests on a throwaway local Supabase, as in job 8.
- The owner's Azure Speech resource and key (owner's call 1) for milestone 6 and for the preview. Milestones 1 to 5 run on the fake and wait for nothing.
- Migration timestamp coordinated by the manager with jobs 9 and 11.
- `pg_cron` must be available on the test project and in the local Supabase. If it is not, the builder stops and tells the manager (fallback: a daily GitHub workflow calling the function through the database connection, as the keep awake workflow does).

## Risks and flags

- **Look closely: recordings, consent and learner data.** First job that touches voice. Covered by statements 1 to 4, 8, 13 to 19, 24 and the threat model.
- **Look closely: database and access rules.** Two new tables, a trigger on `consents`, a scheduled job.
- **Look closely: paid service.** Azure speech to text bills per audio hour on the paid tier.
- **Look closely: Finnish content.** Hint texts make claims about Finnish sounds ("try the double k"), and the golden set holds unreviewed Finnish from the voice test sheet as test data. Both go to the native reviewer (owner's call 3). The golden set never reaches a learner.
- **iPhone microphone (risk test 1).** Not proven by this job: whether `getUserMedia` keeps its permission in an installed iPhone app, whether Safari's own mp4 recordings decode with `decodeAudioData` on every iOS version we support (Safari 15.4 and later), what happens with Bluetooth headsets, and whether Playwright's WebKit can record at all. The design limits the damage: format is detected at run time, the microphone is released after each try, background interrupts are handled, and every failure lets the learner continue. Recommended: the owner tries Say it once on their own iPhone on the preview after merge.
- **Accuracy is unproven.** No independent test of any provider on Finnish learner speech exists (factory plan, test 3). Azure may recognise spoken Finnish as written Finnish, which is why both registers count as a match. Length mistakes such as *tuli* for *tuuli* may slip through when the service leans on the reference text. Wrong feedback teaches mistakes, so risk test 3 should run soon after the MVP.
- **Free tier handles one check at a time.** Azure's free tier allows one concurrent speech to text request, and this limit cannot be raised. A second learner recording at the same moment gets the "busy" message after one retry. Fine for the build, not for any group of learners (owner's call 1).
- **Running cost may exceed the PRD estimate.** The PRD guessed €0.30 to €0.40 a month per active learner for speech. At $1.00 an hour (Azure retail price for North Europe), about 80 seconds of audio a day (six lines with retries plus spoken review, my estimate) is about $0.65 a month per daily learner, close to the PRD's whole €0.75 target. Whether Azure bills short requests by the second was not verified. The cost column makes the real number visible.
- **Audio passes through Cloudflare's nearest data centre.** The Worker runs where the learner is. For learners in Finland that is in the EU; a learner travelling outside the EU passes their audio, in memory only, through a data centre there. Pinning Workers to the EU was not found on the free plan (job 1-stack). The privacy notice in job 11 should say so.
- **Database size.** Opted in recordings live in the database (Decision 6). Free plan: about 30 heavily opted in learners; Pro (8 GB): about 500. The recording store sits behind one module (`worker/recording-store.ts`) so it can move to R2 later.
- **Guest abuse multiplies the speech cap.** Inherits job 8's open decision (Turnstile or similar) before launch.
- **Deleted guests keep a valid token for minutes.** Supabase says an access token stays usable until it expires after the user is deleted. A deleted learner's recordings are gone with the cascade, so nothing is exposed; noted for job 11.

## Owner's calls

**1. The Azure Speech resource and its tier (spends money; shared with job 7).** You are already being asked for one EU resource in job 7's call 2. This adds which tier.
- A. Free tier (F0) now: 5 hours of speech to text a month, €0, one check at a time. Switch to pay as you go before any learner outside the team uses Say it. Free tier limits cannot be raised.
- B. Pay as you go (S0) from the start with the €10 budget alert from decision 7: $1.00 per audio hour, 100 checks at a time. A few cents during the build.
- C. Reuse v2's resource. v2's open Worker route can use up its allowance and costs mix.
- Recommendation: A for the build, then B before the first outside learners. Whether one subscription may hold a free resource for both voices and speech, or only one free Speech resource, I could not verify; if Azure refuses, take B.

**2. What the consent promises.** The wording in statement 1 is a draft for you to approve. The one real choice is what happens to transcripts.
- A. Keep transcripts 90 days to check the feedback works, then clear them (as drafted). One number for everything in the consent text.
- B. Do not store transcripts at all, only the feedback class. Least data. You lose the ability to see what the service heard when a learner says the feedback was wrong.
- C. Keep transcripts until the account is deleted. Most data, weakest under GDPR's storage limitation.
- Recommendation: A.

**3. When your native reviewer checks the hint wording and the 30 golden cases (reviewer time).**
- A. In the end of MVP batch with the other Finnish (the run plan's default). About 15 minutes extra, my estimate. The job merges with labels marked "not reviewed".
- B. Now, before the build. Delays nothing else but adds a separate request to your reviewer.
- Recommendation: A.

No design direction is needed: every screen uses job 5's components (`RecordControl`, `StatusLine`, `FinnishLine`, `PlayControl`, `Button`, `SessionFrame`).

## Could not verify

- Whether Safari's `MediaRecorder` output decodes with `decodeAudioData` on every supported iOS version, and whether Safari before 18.4 offers only mp4 for audio (one third-party guide says so).
- Whether an installed iPhone web app keeps the microphone permission between launches.
- Whether Playwright's WebKit build supports `MediaRecorder`.
- How Azure transcribes spoken Finnish spellings ("mä oon"), and how its `fi-FI` scores behave on beginners.
- Azure's billing granularity for short requests, and whether a subscription may hold more than one free Speech resource.
- Whether `pg_cron` is available on the Supabase free plan (Supabase's pages do not say) and in the local CLI stack.
- The largest request body Supabase's API accepts for a 330 KB recording sent through it.
- That Microsoft's standard Data Protection Addendum covers this resource (expected for Azure; not re-read today).
- Whether R2 requires a payment method on file (third-party sources only).

## Sources

- PRD sections 3, 4.1, 5, 8, 10, 12, 16: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- Factory plan, risk test 3 and decisions 8 and 9: `docs/factory-and-risk-tests-plan.md`; run plan: `factory/run-plan.md`
- Job specs: `factory/jobs/1-stack/spec.md` (provisional providers), `factory/jobs/3-data-model/spec.md`, `factory/jobs/7-content-pipeline/spec.md` (shared Azure resource), `factory/jobs/8-first-session/spec.md` (step list, sign in, origin rule, fixture); `supabase/migrations/20261020090100_learner_model.sql`; `design.md` (record control, status line, screen text); `src/components/RecordControl.tsx`; `src/lib/grade.ts`
- Azure speech to text REST API for short audio (formats, 30 second limit for pronunciation assessment, header parameters, response fields, status values): https://learn.microsoft.com/en-us/azure/ai-services/speech-service/rest-speech-to-text-short
- Azure pronunciation assessment (scripted mode, miscue, prosody en-US only, phoneme names en-US only, billed as speech to text): https://learn.microsoft.com/en-us/azure/ai-services/speech-service/how-to-pronunciation-assessment and https://learn.microsoft.com/en-us/azure/ai-services/speech-service/pronunciation-assessment-tool
- Azure Speech quotas (free tier one concurrent request, not adjustable; standard 100): https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-services-quotas-and-limits
- Azure Speech pricing page (free tier 5 audio hours a month; paid prices not shown on the page): https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/
- Azure retail prices API, North Europe, "S1 Speech To Text" $1.00 per hour, read 21 October 2026: https://prices.azure.com/api/retail/prices?$filter=armRegionName%20eq%20'northeurope'%20and%20contains(productName,%20'Speech')
- Azure speech to text data privacy (real time audio processed in memory, not stored; pronunciation assessment not retained): https://learn.microsoft.com/en-us/azure/ai-foundry/responsible-ai/speech-service/speech-to-text/data-privacy-security
- Supabase, deleting Storage objects (API only, no expiry feature): https://supabase.com/docs/guides/storage/management/delete-objects
- Supabase, managing user data (users owning Storage objects cannot be deleted; tokens valid until expiry): https://supabase.com/docs/guides/auth/managing-user-data
- Supabase Cron: https://supabase.com/docs/guides/cron
- Cloudflare R2 jurisdictions and lifecycle rules: https://developers.cloudflare.com/r2/reference/data-location/ and https://developers.cloudflare.com/r2/buckets/object-lifecycles/
- R2 payment method (third-party): https://dev.to/leonwong282/the-complete-beginners-guide-to-cloudflare-r2-image-hosting-2025-2g4k
- MDN `MediaRecorder.isTypeSupported()`: https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder/isTypeSupported_static
- Safari `MediaRecorder` formats by version (third-party): https://www.buildwithmatija.com/blog/md/iphone-safari-mediarecorder-audio-recording-transcription
- WebKit bug 185448 (getUserMedia in home screen apps, fixed): https://bugs.webkit.org/show_bug.cgi?id=185448
- Duolingo's skip for speaking exercises: https://androidauthority.com/duolingo-undo-skip-speaking-button-3696590
- GDPR Article 7 (withdrawal as easy as giving consent): https://gdpr-info.eu/art-7-gdpr/ ; Article 4(14) (biometric data): https://gdpr-info.eu/art-4-gdpr/

Result: ready for owner approval
