import { describe, expect, it } from 'vitest'
import { Rating } from '../src/lib/fsrs/types.ts'
import type { ReviewFeedback } from '../src/lib/review-types.ts'
import type { ReviewSession } from '../src/lib/session-types.ts'
import { encodeWav, toBase64 } from '../src/lib/wav.ts'
import { handleApi, type ApiDeps } from './api.ts'
import {
  ENV,
  cookieHeader,
  countingProvider,
  fakeDb,
  fakeRecordingStore,
  fakeSpeechDb,
  fakeSupabase,
  newCard,
  post,
  sampleContent,
  sampleDialogue,
  type FakeDb,
  type FakeSpeechDb,
} from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.
// Spoken answers in daily review: POST /api/speech/recall, with a fake
// Supabase Auth, fake databases and a fake speech provider that counts calls.
// Form 2 is mä / minä (the sample dialogue of worker/test-fakes.ts).

const MINÄ = 2
const OLLA = 3
const DUE = '2026-10-21T09:00:00+00:00'

function tone(seconds: number): Uint8Array {
  const samples = new Float32Array(Math.round(seconds * 16_000))
  for (let i = 0; i < samples.length; i += 1) samples[i] = 0.3 * Math.sin((2 * Math.PI * 440 * i) / 16_000)
  return encodeWav(samples)
}
const AUDIO = toBase64(tone(1))

interface Learner {
  db: FakeDb
  speech: FakeSpeechDb
  provider: ReturnType<typeof countingProvider>
  deps: ApiDeps
  cookie: string
  sessionId: string
}

async function learner(options: { consent?: boolean; heard?: string } = {}): Promise<Learner> {
  const db = fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, sampleContent()]]))
  db.sessions.push({
    id: '00000000-0000-4000-8000-0000000000d1',
    dialogueId: 1,
    step: 'say',
    startedAt: '2026-10-21T08:00:00Z',
    endedAt: '2026-10-21T08:10:00Z',
  })
  db.queue = [MINÄ, OLLA].map((formId) => ({ formId, reps: 0, due: DUE }))
  db.cards = [MINÄ, OLLA].map((formId) => newCard(formId, DUE))
  const supabase = fakeSupabase()
  const speech = fakeSpeechDb([])
  const provider = countingProvider(() =>
    Promise.resolve({ status: 'heard' as const, heard: options.heard ?? 'mä' }),
  )
  const deps: ApiDeps = {
    fetch: supabase.fetch,
    learnerDb: () => db,
    speechDb: () => speech,
    recordingStore: () => fakeRecordingStore(speech),
    speechProvider: provider,
  }
  const cookie = cookieHeader(await handleApi(post('/api/guest'), ENV, deps))
  if (options.consent !== false)
    speech.consentRows.push({ kind: 'voice_processing', granted: true, noticeVersion: 'x' })
  const started = await handleApi(post('/api/sessions/today', { cookie }), ENV, deps)
  const sessionId = (await started.json<ReviewSession>()).session.id
  return { db, speech, provider, deps, cookie, sessionId }
}

function recallRequest(l: Learner, body: Record<string, unknown> = {}, origin?: string) {
  return post('/api/speech/recall', {
    cookie: l.cookie,
    origin,
    body: JSON.stringify({ sessionId: l.sessionId, formId: MINÄ, audio: AUDIO, ...body }),
  })
}

describe('POST /api/speech/recall', () => {
  it('[speak 21] a clear spoken answer is graded Good through the review path and saved with mode spoken', async () => {
    const l = await learner({ heard: 'mä' })
    const res = await handleApi(recallRequest(l), ENV, l.deps)
    expect(res.status).toBe(200)
    const body = await res.json<{ status: string; feedback: ReviewFeedback }>()
    expect(body.status).toBe('graded')
    expect(body.feedback.result).toBe('correct')
    expect(body.feedback.form).toEqual({ spoken: 'mä', written: 'minä' })
    expect(l.db.recorded).toHaveLength(1)
    expect(l.db.recorded[0]).toMatchObject({ p_form_id: MINÄ, p_rating: Rating.Good, p_mode: 'spoken' })
    // The reference was the form's spoken shape, from the database.
    expect(l.provider.calls[0]?.reference).toBe('mä')
  })

  it('[speak 21] the written register is accepted too', async () => {
    const l = await learner({ heard: 'minä' })
    const body = await (await handleApi(recallRequest(l), ENV, l.deps)).json<{ feedback: ReviewFeedback }>()
    expect(body.feedback.result).toBe('correct')
  })

  it('[speak 21] close is Hard and a different word is Again, by the fixed table', async () => {
    const close = await learner({ heard: 'mäh' })
    const closeBody = await (
      await handleApi(recallRequest(close), ENV, close.deps)
    ).json<{
      feedback: ReviewFeedback
    }>()
    expect(closeBody.feedback.result).toBe('close')
    expect(close.db.recorded[0]).toMatchObject({ p_rating: Rating.Hard, p_mode: 'spoken' })

    const wrong = await learner({ heard: 'kiva tavata' })
    const wrongBody = await (
      await handleApi(recallRequest(wrong), ENV, wrong.deps)
    ).json<{
      feedback: ReviewFeedback
    }>()
    expect(wrongBody.feedback.result).toBe('wrong')
    expect(wrong.db.recorded[0]).toMatchObject({ p_rating: Rating.Again, p_mode: 'spoken' })
  })

  it('[speak 21] a recording that was not heard grades nothing and the card stays as it was', async () => {
    const l = await learner({ heard: '' })
    const res = await handleApi(recallRequest(l), ENV, l.deps)
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ status: 'not_heard' })
    expect(l.db.recorded).toEqual([])
    expect(l.db.cards.find((c) => c.formId === MINÄ)).toEqual(newCard(MINÄ, DUE))
    // The call reached the service, so it is logged with its cost and counts.
    expect(l.speech.attempts).toHaveLength(1)
    expect(l.speech.attempts[0]).toMatchObject({
      sessionId: null,
      lineId: null,
      formId: MINÄ,
      feedbackClass: 'not_heard',
    })
  })

  it('[speak 21] [speak 15] the answer holds no transcript, and one attempt row is logged for a form', async () => {
    const l = await learner({ heard: 'mä' })
    const text = await (await handleApi(recallRequest(l), ENV, l.deps)).text()
    expect(text).not.toContain('"transcript"')
    expect(l.speech.attempts).toHaveLength(1)
    expect(l.speech.attempts[0]).toMatchObject({ formId: MINÄ, transcript: 'mä', provider: 'fake' })
  })

  it("[speak 21] [speak 14] refuses, before the speech service is called, each of: no consent, a session or form that is not the learner's, bad audio, extra fields", async () => {
    const noConsent = await learner({ consent: false })
    expect((await handleApi(recallRequest(noConsent), ENV, noConsent.deps)).status).toBe(403)

    const l = await learner()
    expect((await handleApi(recallRequest(l, { formId: 77 }), ENV, l.deps)).status).toBe(404)
    expect(
      (await handleApi(recallRequest(l, { sessionId: '00000000-0000-4000-8000-0000000000ff' }), ENV, l.deps))
        .status,
    ).toBe(404)
    expect((await handleApi(recallRequest(l, { audio: 'AAAA' }), ENV, l.deps)).status).toBe(400)
    expect((await handleApi(recallRequest(l, { reference: 'mä' }), ENV, l.deps)).status).toBe(400)
    expect((await handleApi(recallRequest(l, { userId: 'x' }), ENV, l.deps)).status).toBe(400)
    expect((await handleApi(recallRequest(l, {}, 'https://evil.example'), ENV, l.deps)).status).toBe(403)
    expect(l.provider.calls).toHaveLength(0)
    expect(noConsent.provider.calls).toHaveLength(0)
    expect(l.db.recorded).toEqual([])
  })

  it('[speak 21] [speak 14] counts against the same 40 checks in 10 minutes as Say it, and a failed call counts too', async () => {
    const l = await learner()
    l.provider.check = () => Promise.reject(new Error('down'))
    for (let i = 0; i < 40; i += 1) {
      expect((await handleApi(recallRequest(l), ENV, l.deps)).status).toBe(503)
    }
    const refused = await handleApi(recallRequest(l), ENV, l.deps)
    expect(refused.status).toBe(429)
    expect(l.speech.checks).toHaveLength(40)
    expect(l.db.recorded).toEqual([])
  })

  it('[speak 21] [speak 14] 60 spoken answers sent at once: at most 40 reach the speech service', async () => {
    const l = await learner()
    l.provider.check = (wav: Uint8Array, reference: string, fixture: string | null) => {
      l.provider.calls.push({ bytes: wav.length, reference, fixture })
      return new Promise((resolve) => {
        setTimeout(() => {
          resolve({ status: 'not_heard', heard: '' })
        }, 20)
      })
    }
    const answers = await Promise.all(
      Array.from({ length: 60 }, () => handleApi(recallRequest(l), ENV, l.deps)),
    )
    expect(answers.filter((a) => a.status === 429)).toHaveLength(20)
    expect(l.provider.calls).toHaveLength(40)
  })

  it('[speak 21] the typed route still refuses a spoken kind or a class from the browser', async () => {
    const l = await learner()
    for (const extra of [{ kind: 'spoken' }, { feedbackClass: 'clear' }]) {
      const res = await handleApi(
        post('/api/review/answer', {
          cookie: l.cookie,
          body: JSON.stringify({ sessionId: l.sessionId, formId: MINÄ, text: 'mä', kind: 'typed', ...extra }),
        }),
        ENV,
        l.deps,
      )
      expect(res.status).toBe(400)
    }
    expect(l.db.recorded).toEqual([])
  })
})
