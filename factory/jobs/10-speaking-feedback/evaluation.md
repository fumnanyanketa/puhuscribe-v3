# Evaluation: 10-speaking-feedback

Date: 26 October 2026. Tested commit `b2a6a3e`, using a clean `git archive` copy of the worktree in a scratch folder. It ran against its own local Supabase (project `puhu10eval`, ports 575xx) with every migration and the browser seed applied. The Worker used `SPEECH_FEEDBACK_PROVIDER=fake`. The app was built and served with `vite preview` over HTTPS on port 4917. A second build with no speech provider set ran on port 4918 for statement 13. I drove it with Playwright at 375 x 812 in Chromium (1243 build). The microphone was the generated 440 Hz tone from `e2e/microphone.ts`. Every learner was a test guest. Videos are in the scratch run folder. Only Chromium was tested here, because no WebKit build is installed on this machine.

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `1-consent-screen.png`, `1-consent.txt` | Consent screen appears first. There were 0 `getUserMedia` calls before consent. All the sentences are there and the box starts unticked. |
| 2 | pass | `2-consents-rows-unticked.txt`, `2-consents-rows-ticked.txt`, `14-api-refusals.txt` | Unticked: one `voice_processing` granted row. Ticked: that row plus `voice_recording_retention`. Both carry `voice-2026-10.1`. A request that tries to send its own version gets 400. |
| 3 | pass | `3-not-now.png`, `3-quiet-turn-on-opens-consent.png`, `3-not-now.txt` | Shows "Say the line out loud after the voice." with Next line. 0 mic calls, no speech requests, no consent rows. The quiet "Turn on" link opens the consent screen. |
| 4 | pass | `4-voice-before.png`, `4-voice-keep-off.png`, `4-voice-feedback-off.png`, `4-withdraw.txt` | One press each. Turning off keep: kept recordings go to 0 and the transcripts stay. Turning off feedback: transcripts go to 0 of 4 and the classes stay. Withdrawn rows are recorded. Front door and Say it both link to /voice. |
| 5 | pass | `5a`/`5b`/`5c-step*-label.png`, `5d-finish.png`, `5e-resume-at-say-it.png`, `5-resume.txt`, `17-db.txt` | Labels read "step 1/2/3 of 3". Leaving and coming back resumes at Say it. `step_reached = say` is stored. Another learner gets 404 when posting step `say` to this session. |
| 6 | pass | `6-second-line.png`, `6-elapsed-time.png`, `6-last-line-continue.png`, `6-cant-speak.png`, `9-failures.txt` | Lines go one at a time. Elapsed time shows ("Recording 0:03"). Auto stop came at about 10.5 s. The last line shows Continue. "I can't speak right now" goes to the finish screen with no recording. |
| 7 | pass | `7-*.png`, `7-feedback-classes.txt`, `B-speech-responses.txt` | Each of the 8 rows shows its exact text in one status line. Finnish words carry `lang="fi"`. No score or transcript appears. |
| 8 | pass | `8-play-my-recording.png`, `8-storage.txt` | "Play my recording" works. localStorage, sessionStorage, IndexedDB and Cache Storage are all empty. |
| 9 | pass | `9-denied.png`, `9-none.png`, `9-short.png`, `9-background.png`, `9-failures.txt` | All 4 messages are exact. A recording under 0.5 s makes no server call. Next line or Continue is always shown. All mic tracks are stopped. |
| 10 | pass | `unit-tests-speak.txt` | 16 `[speak 10]` unit tests pass. |
| 11 | pass | `11-eval-speech.txt` | 30 of 30, 100 percent (needs 90). |
| 12 | pass | `unit-tests-speak.txt` | 17 `[speak 12]` unit and repository tests pass. The fake answers through the test header. |
| 13 | pass | `13-unavailable.png`, `13-unavailable.txt` | With no provider set: "Speaking feedback is not available right now." 0 mic calls, and Next line still works. The `eastus` refusal is covered by unit tests. |
| 14 | pass | `14-api-refusals.txt`, `14-rate-limit-message.png`, `14-oversized-body.txt` | Signed out 401. No consent 403, and 403 after withdrawal. Other origin 403. Wrong or foreign session 404. Foreign line 404. 600 KB 413. 8 kHz, stereo, 11 s and non-WAV 400. Extra `reference` key 400. The 40th check in 10 minutes gets 429 with the exact text. Refused calls added no rows. |
| 15 | pass | `B-speech-responses.txt` | Responses hold only `feedbackClass` and `hint`. |
| 16 | pass | `16-18-pgtap.txt`, `16-18-schema.txt` | `speaking_feedback.test.sql` passes. RLS is on. Grants are SELECT plus column INSERT, UPDATE on `transcript` only, and DELETE on kept recordings only. No audio column in `speaking_attempts`. |
| 17 | pass | `17-db.txt` | After a full Say it, 12 attempts have transcript and class, and `kept_recordings` has 0 rows. |
| 18 | pass | `16-18-schema.txt`, `18-backdate-rollback.txt` | The daily `pg_cron` job exists. Backdating 5 attempts in a rolled-back transaction cleared exactly 5 transcripts and kept the rows. |
| 19 | pass | `19-voice-settings-list.png`, `19-recordings.txt`, `19-learner-b-voice.png` | Shows first and latest per line, newest first, with Play, Delete and Delete all. Own fetch is 200 with `private, no-store`. Learner B gets 404 for A's id, the same as a missing id. Signed out gets 401. |
| 20 | pass | `17-db.txt`, `unit-tests-speak.txt` | One row per call with provider, `audio_ms` and `cost_usd` (0 for the fake). The cost unit test passes. |
| 21 | waits on job 9 | none | Not built, by design: job 9 is not merged. Not counted as a failure. |
| 22 | pass | `unit-tests-speak.txt` | 6 `[speak 22]` tests pass, including the exact numbers on the tone clips. Real clips wait for risk test 3. |
| 23 | pass | `unit-tests-speak.txt` | The workflow runs only on `workflow_dispatch`. Its fixtures say they come from the documentation. |
| 24 | pass | `unit-tests-speak.txt`, build output | The log unit tests pass, and `check:built-secrets` passed on 28 files. |

## Failures

None.

## Odd things that are not failures

- A 5 MB body to `/api/speech/say` got a 500 "TypeError: fetch failed" from `vite preview`'s local runtime, not the 413. Job 8's `/api/guest` does the same with a 600 KB body (413, 500, 413). So this looks like the local runtime, not this job's code. Bodies just over the cap reliably got 413. Worth checking on a preview link.
- With the fake provider there is no region setting, so the consent screen says only "in the EU" and names no region. The text that names a region (such as "Ireland") could not be seen here.
- Refreshing mid recording drops the attempt silently and Say it reloads at line 1. Nothing is sent or stored (`E-refresh-mid-recording.png`).
- After Continue or "I can't speak right now", the finish screen ends the session. Coming back then starts a new Hear it. The "step `say`, not ended" resume case could not be reached in the UI.
- With the browser seed loaded, the full `supabase test db` run fails 2 `content_publish` (job 7) checks, because the seed fixture has no review file. CI runs pgTAP without that seed.
- 17 unit tests fail in a copy that is not a git repository, because they need git. All 740 pass in the worktree itself.
- Not tested here: WebKit, and the real Azure path.

Result: pass
