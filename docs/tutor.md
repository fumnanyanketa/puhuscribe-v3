# The tutor, Otso (job 16-tutor-step)

From stop 4 of the road a lesson ends with a short chat with Otso, under "Use it", after Keep it and before the island step. Spec: `factory/jobs/16-tutor-step/spec.md` and the owner's answers of 3 November 2026 at its end.

## The flow

1. The session answer carries `stop` from stop 4. The app asks `GET /api/tutor?session=<id>`, which says what the step shows: the consent screen, the guest card ("Add your email to talk with Otso"), the chat, or nothing (no key, Otso turned off, or today's cap reached).
2. Otso opens with an approved line of today's dialogue: the first line ending with a question mark, else the first line (`pickOpening` in `src/lib/tutor-words.ts`, used by both the app and the Worker).
3. The learner answers three times, typed or spoken. A spoken answer goes to `POST /api/tutor/transcribe`, which uses the speech module's plain transcription mode and needs a voice consent of version `voice-2026-11.1` or later (its text names this use). The text comes back to the learner to check.
4. `POST /api/tutor/turn` checks the request, reserves a call in the database (`public.reserve_tutor_call`), asks the AI (`worker/providers/ai.ts`), and checks the answer: every word a met form (`checkReply`), every neighbouring pair found in a met approved line (the phrase rule). Two retries name the failing words and pairs; then an approved line of today's dialogue is served.
5. Nothing of the chat is stored. Each call leaves one `tutor_calls` row with its model, tokens and cost.

## The settings

- Phrase rule: `content/checks/tutor-thresholds.json`, `min_pair_coverage_per_sentence` (1.0 strict, 0.75 middle, 0 off).
- Limits: one row in `private.tutor_limits`. For example, to raise the monthly cap: `update private.tutor_limits set monthly_usd = 50, daily_usd = 1.6667;`
- Model: `TUTOR_MODEL` and the dated price table in `worker/providers/ai.ts`. Models that need the provider to keep conversations are refused.
- Otso's portrait: `public/otso/avatar.webp` (AI-made, supplied by the owner). Without it a mint "O" stands in.

## The quality check

`node scripts/tutor-eval/run.ts` runs 34 scripted exchanges (`content/checks/tutor-eval-scenarios.json`, 102 learner replies) on the approved road dialogues. With `AI_PROVIDER=fake` it costs nothing and proves the harness; with the key it runs the live model. On GitHub it is the manual workflow "Tutor eval". Results go to `factory/jobs/16-tutor-step/evidence/`.

## Swapping the provider

Change `worker/providers/ai.ts` only: it is the one file that names an AI service or reads its key. Add the new company to `src/privacy/processors.ts` and the privacy notice in the same change.
