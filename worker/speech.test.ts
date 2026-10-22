import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { ReadySession } from '../src/lib/session-types.ts'
import type { VoiceAnswer } from '../src/lib/speech-types.ts'
import { VOICE_NOTICE_VERSION } from '../src/lib/voice-consent.ts'
import { encodeWav, toBase64 } from '../src/lib/wav.ts'
import { handleApi, type ApiDeps } from './api.ts'
import { SpeechCheckFailed } from './providers/speech-feedback.ts'
import {
  ENV,
  cookieHeader,
  countingProvider,
  fakeDb,
  fakeRecordingStore,
  fakeSpeechDb,
  fakeSupabase,
  get,
  post,
  sampleContent,
  sampleDialogue,
  type FakeDb,
  type FakeSpeechDb,
} from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.
// The speaking feedback routes, with a fake Supabase Auth, fake databases and
// a fake speech provider that counts its calls.

const LINE = { id: 11, dialogueId: 1, spoken: 'Moi! Mä oon Alex.', written: 'Hei! Minä olen Alex.' }
const OTHER_DIALOGUE_LINE = { id: 31, dialogueId: 3, spoken: 'Kiva tavata!', written: 'Hauska tavata!' }

function tone(seconds: number): Uint8Array {
  const samples = new Float32Array(Math.round(seconds * 16_000))
  for (let i = 0; i < samples.length; i += 1) samples[i] = 0.3 * Math.sin((2 * Math.PI * 440 * i) / 16_000)
  return encodeWav(samples)
}

const AUDIO = toBase64(tone(1.5))

interface Learner {
  db: FakeDb
  speech: FakeSpeechDb
  provider: ReturnType<typeof countingProvider>
  store: ReturnType<typeof fakeRecordingStore>
  deps: ApiDeps
  cookie: string
  sessionId: string
}

async function learner(
  options: { step?: 'hear' | 'understand' | 'say'; consent?: boolean; keep?: boolean } = {},
) {
  const supabase = fakeSupabase()
  const db = fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, sampleContent()]]))
  const speech = fakeSpeechDb([LINE, OTHER_DIALOGUE_LINE])
  const store = fakeRecordingStore(speech)
  const provider = countingProvider()
  const deps: ApiDeps = {
    fetch: supabase.fetch,
    learnerDb: () => db,
    speechDb: () => speech,
    recordingStore: () => store,
    speechProvider: provider,
  }
  const guest = await handleApi(post('/api/guest'), ENV, deps)
  const cookie = cookieHeader(guest)
  const today = await handleApi(post('/api/sessions/today', { cookie }), ENV, deps)
  const sessionId = (await today.json<ReadySession>()).session.id
  const session = db.sessions[0]
  if (session) session.step = options.step ?? 'understand'
  if (options.consent !== false)
    speech.consentRows.push({ kind: 'voice_processing', granted: true, noticeVersion: 'x' })
  if (options.keep)
    speech.consentRows.push({ kind: 'voice_recording_retention', granted: true, noticeVersion: 'x' })
  return { db, speech, provider, store, deps, cookie, sessionId } satisfies Learner
}

function sayRequest(
  l: Learner,
  body: Record<string, unknown> = {},
  extra: { origin?: string; fixture?: string } = {},
) {
  const request = post('/api/speech/say', {
    cookie: l.cookie,
    origin: extra.origin,
    body: JSON.stringify({ sessionId: l.sessionId, lineId: LINE.id, audio: AUDIO, ...body }),
  })
  if (extra.fixture) request.headers.set('x-test-speech-fixture', extra.fixture)
  return request
}

describe('POST /api/speech/say', () => {
  it('[speak 14] [speak 15] [speak 20] checks the line from the database and answers the class and hint only', async () => {
    const l = await learner()
    const res = await handleApi(sayRequest(l), ENV, l.deps)
    expect(res.status).toBe(200)
    expect(res.headers.get('cache-control')).toBe('no-store')
    const body = await res.json<Record<string, unknown>>()
    expect(body).toEqual({ feedbackClass: 'clear' })
    // The reference text came from the database, never from the browser.
    expect(l.provider.calls).toEqual([{ bytes: tone(1.5).length, reference: LINE.spoken, fixture: null }])
    // One attempt row per check, with the provider, the audio length and its cost.
    expect(l.speech.attempts).toHaveLength(1)
    expect(l.speech.attempts[0]).toMatchObject({
      sessionId: l.sessionId,
      lineId: LINE.id,
      transcript: 'moi mä oon alex',
      feedbackClass: 'clear',
      provider: 'fake',
      audioMs: 1500,
      costUsd: l.provider.costUsd(1500),
    })
    expect(JSON.stringify(body)).not.toContain('moi mä oon alex')
  })

  it('[speak 15] a close try answers its hint with the word from the line, and still no transcript', async () => {
    const l = await learner()
    l.provider.check = () => Promise.resolve({ status: 'heard', heard: 'moi mä on alex' })
    const res = await handleApi(sayRequest(l), ENV, l.deps)
    const text = await res.text()
    expect(JSON.parse(text)).toEqual({ feedbackClass: 'close', hint: { kind: 'double', letter: 'o' } })
    expect(text).not.toContain('moi mä on')
  })

  it('[speak 14] refuses without a sign in (401), and never calls the speech service', async () => {
    const l = await learner()
    const res = await handleApi(sayRequest({ ...l, cookie: '' }), ENV, l.deps)
    expect(res.status).toBe(401)
    expect(l.provider.calls).toHaveLength(0)
  })

  it('[speak 14] refuses without current voice consent (403), never asked or withdrawn', async () => {
    const never = await learner({ consent: false })
    expect((await handleApi(sayRequest(never), ENV, never.deps)).status).toBe(403)
    expect(never.provider.calls).toHaveLength(0)
    const withdrawn = await learner()
    withdrawn.speech.consentRows.push({ kind: 'voice_processing', granted: false, noticeVersion: 'x' })
    expect((await handleApi(sayRequest(withdrawn), ENV, withdrawn.deps)).status).toBe(403)
    expect(withdrawn.provider.calls).toHaveLength(0)
    expect(withdrawn.speech.attempts).toHaveLength(0)
  })

  it("[speak 14] refuses a session that is someone else's, missing, not at understand, or finished (404)", async () => {
    for (const step of ['hear', 'say'] as const) {
      const l = await learner({ step })
      expect((await handleApi(sayRequest(l), ENV, l.deps)).status, step).toBe(404)
      expect(l.provider.calls).toHaveLength(0)
    }
    const other = await learner()
    const res = await handleApi(
      sayRequest(other, { sessionId: '00000000-0000-4000-8000-0000000000ff' }),
      ENV,
      other.deps,
    )
    expect(res.status).toBe(404)
    const ended = await learner()
    const row = ended.db.sessions[0]
    if (row) row.endedAt = new Date().toISOString()
    expect((await handleApi(sayRequest(ended), ENV, ended.deps)).status).toBe(404)
    expect(other.provider.calls.length + ended.provider.calls.length).toBe(0)
  })

  it("[speak 14] refuses a line that is not in the session's dialogue or not readable (404)", async () => {
    const l = await learner()
    for (const lineId of [OTHER_DIALOGUE_LINE.id, 999]) {
      expect((await handleApi(sayRequest(l, { lineId }), ENV, l.deps)).status, String(lineId)).toBe(404)
    }
    expect(l.provider.calls).toHaveLength(0)
  })

  it('[speak 14] refuses a body over 512 KB (413), read and capped before answering', async () => {
    const l = await learner()
    const res = await handleApi(sayRequest(l, { audio: 'A'.repeat(600 * 1024) }), ENV, l.deps)
    expect(res.status).toBe(413)
    expect(l.provider.calls).toHaveLength(0)
  })

  it('[speak 14] refuses audio that is not a 16 kHz mono 16 bit PCM WAV of at most 10 seconds (400)', async () => {
    const l = await learner()
    const stereo = tone(1)
    new DataView(stereo.buffer).setUint16(22, 2, true)
    const loud = tone(1)
    new DataView(loud.buffer).setUint32(24, 44_100, true)
    for (const audio of [
      'not base64!',
      toBase64(new TextEncoder().encode('OggS and some more bytes to be long enough for a header check')),
      toBase64(stereo),
      toBase64(loud),
      toBase64(tone(10.2)),
      toBase64(encodeWav(new Float32Array(0))),
    ]) {
      expect((await handleApi(sayRequest(l, { audio }), ENV, l.deps)).status).toBe(400)
    }
    expect(l.provider.calls).toHaveLength(0)
    expect(l.speech.attempts).toHaveLength(0)
  })

  it('[speak 14] refuses reference text, a user id or any other field from the browser (400)', async () => {
    const l = await learner()
    for (const extra of [{ reference: 'anything' }, { userId: 'x' }, { text: 'Moi' }]) {
      expect((await handleApi(sayRequest(l, extra), ENV, l.deps)).status).toBe(400)
    }
    for (const bad of [{ lineId: '11' }, { lineId: 0 }, { sessionId: 'nope' }, { audio: 7 }]) {
      expect((await handleApi(sayRequest(l, bad), ENV, l.deps)).status).toBe(400)
    }
    expect(l.provider.calls).toHaveLength(0)
  })

  it('[speak 14] refuses the 41st check in 10 minutes (429) with the kind message, and allows it again later', async () => {
    const l = await learner()
    let now = Date.UTC(2026, 9, 22, 12, 0, 0)
    l.deps.now = () => now
    l.speech.clock = () => now
    for (let i = 0; i < 40; i += 1) {
      expect((await handleApi(sayRequest(l), ENV, l.deps)).status).toBe(200)
      now += 10_000
    }
    const refused = await handleApi(sayRequest(l), ENV, l.deps)
    expect(refused.status).toBe(429)
    expect(await refused.json()).toEqual({
      error: 'too_many',
      message: 'You have recorded a lot in the last few minutes. Take a short break, then try again.',
    })
    expect(l.provider.calls).toHaveLength(40)
    now += 10 * 60_000
    expect((await handleApi(sayRequest(l), ENV, l.deps)).status).toBe(200)
  })

  it('[speak 14] [speak 5] refuses GET, form posts and other websites, as every changing route does', async () => {
    const l = await learner()
    expect((await handleApi(get('/api/speech/say', l.cookie), ENV, l.deps)).status).toBe(405)
    expect((await handleApi(sayRequest(l, {}, { origin: 'https://evil.example' }), ENV, l.deps)).status).toBe(
      403,
    )
    const form = post('/api/speech/say', {
      cookie: l.cookie,
      contentType: 'application/x-www-form-urlencoded',
    })
    expect((await handleApi(form, ENV, l.deps)).status).toBe(415)
    expect(l.provider.calls).toHaveLength(0)
  })

  it('[speak 13] answers 503 when speech feedback is not set up, before anything else is read', async () => {
    const l = await learner()
    l.deps.speechProvider = null
    const res = await handleApi(sayRequest(l), ENV, l.deps)
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'speech_not_available' })
  })

  it('[speak 12] a busy or failed service answers 503 and writes no attempt', async () => {
    const l = await learner()
    l.provider.check = () => Promise.reject(new SpeechCheckFailed('busy'))
    const busy = await handleApi(sayRequest(l), ENV, l.deps)
    expect(busy.status).toBe(503)
    expect(await busy.json()).toEqual({ error: 'speech_busy' })
    l.provider.check = () => Promise.reject(new SpeechCheckFailed('timeout'))
    expect(await (await handleApi(sayRequest(l), ENV, l.deps)).json()).toEqual({ error: 'speech_failed' })
    expect(l.speech.attempts).toHaveLength(0)
  })

  it('[speak 12] passes the test fixture header to the provider (only the fake reads it)', async () => {
    const l = await learner()
    await handleApi(sayRequest(l, {}, { fixture: 'line1-double' }), ENV, l.deps)
    expect(l.provider.calls[0]?.fixture).toBe('line1-double')
  })
})

describe('what happens to the audio', () => {
  const METHODS = ['log', 'info', 'warn', 'error', 'debug', 'trace'] as const
  let written: string[] = []
  const cached: unknown[] = []

  beforeEach(() => {
    written = []
    cached.length = 0
    for (const method of METHODS) {
      vi.spyOn(console, method).mockImplementation((...args: unknown[]) => {
        written.push(args.map((arg) => (typeof arg === 'string' ? arg : JSON.stringify(arg))).join(' '))
      })
    }
    const cache = {
      put: (...args: unknown[]) => {
        cached.push(args)
        return Promise.resolve()
      },
      match: () => Promise.resolve(undefined),
      delete: () => Promise.resolve(false),
    }
    vi.stubGlobal('caches', { default: cache, open: () => Promise.resolve(cache) })
  })

  afterEach(() => {
    vi.restoreAllMocks()
    vi.unstubAllGlobals()
  })

  it('[speak 17] without retention consent, the audio goes only to the speech provider: no log, cache or store', async () => {
    const l = await learner()
    await handleApi(sayRequest(l), ENV, l.deps)
    expect(l.provider.calls).toHaveLength(1)
    expect(l.store.kept).toEqual([])
    expect(l.speech.recordings).toEqual([])
    expect(cached).toEqual([])
    const everything = [...written, ...l.speech.calls].join('\n')
    expect(everything).not.toContain(AUDIO.slice(100, 200))
    expect(l.speech.calls.join('\n')).not.toMatch(/RIFF|UklGR/)
  })

  it('[speak 17] [speak 19] with retention consent, the audio also goes to the kept recordings, and nowhere else', async () => {
    const l = await learner({ keep: true })
    await handleApi(sayRequest(l), ENV, l.deps)
    expect(l.store.kept).toEqual([AUDIO])
    expect(l.speech.recordings.map((r) => r.slot)).toEqual(['first'])
    await handleApi(sayRequest(l), ENV, l.deps)
    await handleApi(sayRequest(l), ENV, l.deps)
    expect(l.speech.recordings.map((r) => r.slot).sort()).toEqual(['first', 'latest'])
    expect(cached).toEqual([])
    expect([...written, ...l.speech.calls].join('\n')).not.toContain(AUDIO.slice(100, 200))
  })

  it('[speak 24] the log holds no audio, transcript, reference text, cookie, token or user id', async () => {
    const l = await learner({ keep: true })
    l.provider.check = () => Promise.resolve({ status: 'heard', heard: 'moi mä on alex' })
    await handleApi(sayRequest(l), ENV, l.deps)
    await handleApi(sayRequest(l, { audio: 'broken!' }), ENV, l.deps)
    await handleApi(get('/api/voice', l.cookie), ENV, l.deps)
    l.provider.check = () => Promise.reject(new SpeechCheckFailed('failed'))
    await handleApi(sayRequest(l), ENV, l.deps)
    const log = written.join('\n')
    for (const value of [AUDIO.slice(0, 40), 'moi mä on alex', LINE.spoken, LINE.written, l.sessionId]) {
      expect(log).not.toContain(value)
    }
    for (const part of l.cookie.split('; ')) expect(log).not.toContain(part.split('=').slice(1).join('='))
    expect(log).not.toMatch(/cookie|authorization|bearer/i)
  })
})

async function voice(l: Learner): Promise<VoiceAnswer> {
  return (await handleApi(get('/api/voice', l.cookie), ENV, l.deps)).json<VoiceAnswer>()
}

function choose(l: Learner, body: Record<string, unknown>) {
  return handleApi(post('/api/voice/consent', { cookie: l.cookie, body: JSON.stringify(body) }), ENV, l.deps)
}

describe('voice consent', () => {
  it('[speak 1] [speak 13] GET /api/voice says whether speaking feedback is set up, where the audio goes, and the choices', async () => {
    const l = await learner({ consent: false })
    expect(await voice(l)).toEqual({
      available: true,
      region: 'Italy',
      processing: 'not_asked',
      retention: false,
      recordings: [],
    })
    l.deps.speechProvider = null
    expect((await voice(l)).available).toBe(false)
    expect((await handleApi(get('/api/voice'), ENV, l.deps)).status).toBe(401)
  })

  it("[speak 2] turning on adds a voice_processing grant, plus a retention grant only when the box was ticked, with the Worker's label", async () => {
    const plain = await learner({ consent: false })
    expect((await choose(plain, { choice: 'turn_on', keepRecordings: false })).status).toBe(200)
    expect(plain.speech.consentRows).toEqual([
      { kind: 'voice_processing', granted: true, noticeVersion: VOICE_NOTICE_VERSION },
    ])
    const ticked = await learner({ consent: false })
    const answer = await (
      await choose(ticked, { choice: 'turn_on', keepRecordings: true })
    ).json<VoiceAnswer>()
    expect(ticked.speech.consentRows).toEqual([
      { kind: 'voice_processing', granted: true, noticeVersion: VOICE_NOTICE_VERSION },
      { kind: 'voice_recording_retention', granted: true, noticeVersion: VOICE_NOTICE_VERSION },
    ])
    expect(answer).toMatchObject({ processing: 'granted', retention: true })
  })

  it('[speak 2] the browser cannot choose the version label or send anything else', async () => {
    const l = await learner({ consent: false })
    for (const body of [
      { choice: 'turn_on', noticeVersion: 'v-evil' },
      { choice: 'turn_on', keepRecordings: 'yes' },
      { choice: 'grant_everything' },
      { choice: 'turn_off', keepRecordings: true },
      { kind: 'voice_processing', granted: true },
    ]) {
      expect((await choose(l, body)).status, JSON.stringify(body)).toBe(400)
    }
    expect(l.speech.consentRows).toEqual([])
  })

  it('[speak 4] turning off speaking feedback withdraws both choices, deletes recordings and clears transcripts', async () => {
    const l = await learner({ keep: true })
    await handleApi(sayRequest(l), ENV, l.deps)
    expect(l.speech.recordings).toHaveLength(1)
    const answer = await (await choose(l, { choice: 'turn_off' })).json<VoiceAnswer>()
    expect(answer).toMatchObject({ processing: 'withdrawn', retention: false, recordings: [] })
    expect(l.speech.consentRows.slice(-2)).toEqual([
      { kind: 'voice_processing', granted: false, noticeVersion: VOICE_NOTICE_VERSION },
      { kind: 'voice_recording_retention', granted: false, noticeVersion: VOICE_NOTICE_VERSION },
    ])
    expect(l.speech.attempts.map((a) => [a.transcript, a.feedbackClass])).toEqual([['', 'clear']])
    // And no more checks.
    expect((await handleApi(sayRequest(l), ENV, l.deps)).status).toBe(403)
  })

  it('[speak 4] keeping recordings turns on and off with one press each, only while speaking feedback is on', async () => {
    const l = await learner()
    expect((await (await choose(l, { choice: 'keep_on' })).json<VoiceAnswer>()).retention).toBe(true)
    await handleApi(sayRequest(l), ENV, l.deps)
    const off = await (await choose(l, { choice: 'keep_off' })).json<VoiceAnswer>()
    expect(off).toMatchObject({ processing: 'granted', retention: false, recordings: [] })
    expect(l.speech.attempts[0]?.transcript).toBe('moi mä oon alex')
    const never = await learner({ consent: false })
    expect((await choose(never, { choice: 'keep_on' })).status).toBe(409)
    expect(never.speech.consentRows).toEqual([])
  })
})

describe('kept recordings', () => {
  it("[speak 19] are listed newest first with the line's spoken text, and play only for their owner with no-store", async () => {
    const l = await learner({ keep: true })
    await handleApi(sayRequest(l), ENV, l.deps)
    await handleApi(sayRequest(l), ENV, l.deps)
    const listed = (await voice(l)).recordings
    expect(listed.map((r) => [r.slot, r.line])).toEqual([
      ['latest', LINE.spoken],
      ['first', LINE.spoken],
    ])
    const id = listed[0]?.id ?? ''
    const res = await handleApi(get(`/api/voice/recordings/${id}`, l.cookie), ENV, l.deps)
    expect(res.status).toBe(200)
    expect(res.headers.get('content-type')).toBe('audio/wav')
    expect(res.headers.get('cache-control')).toBe('private, no-store')
    expect(new Uint8Array(await res.arrayBuffer())).toEqual(tone(1.5))

    const ranged = get(`/api/voice/recordings/${id}`, l.cookie)
    ranged.headers.set('range', 'bytes=0-1')
    const part = await handleApi(ranged, ENV, l.deps)
    expect(part.status).toBe(206)
    expect(part.headers.get('content-range')).toBe(`bytes 0-1/${String(tone(1.5).length)}`)
    expect(new Uint8Array(await part.arrayBuffer())).toEqual(new Uint8Array([0x52, 0x49]))
  })

  it("[speak 19] another learner's or a missing id answers 404, the same; no sign in answers 401", async () => {
    const owner = await learner({ keep: true })
    await handleApi(sayRequest(owner), ENV, owner.deps)
    const id = (await voice(owner)).recordings[0]?.id ?? ''
    // Learner B has their own (empty) store: the database rules hide A's rows.
    const other = await learner()
    const theirs = await handleApi(get(`/api/voice/recordings/${id}`, other.cookie), ENV, other.deps)
    const missing = await handleApi(
      get('/api/voice/recordings/00000000-0000-4000-8000-0000000000ee', other.cookie),
      ENV,
      other.deps,
    )
    expect(theirs.status).toBe(404)
    expect(missing.status).toBe(404)
    expect(await theirs.text()).toBe(await missing.text())
    expect((await handleApi(get(`/api/voice/recordings/${id}`), ENV, owner.deps)).status).toBe(401)
  })

  it('[speak 19] can be deleted one by one or all at once', async () => {
    const l = await learner({ keep: true })
    await handleApi(sayRequest(l), ENV, l.deps)
    await handleApi(sayRequest(l), ENV, l.deps)
    const [newest] = (await voice(l)).recordings
    const del = (body: unknown) =>
      handleApi(
        post('/api/voice/recordings/delete', { cookie: l.cookie, body: JSON.stringify(body) }),
        ENV,
        l.deps,
      )
    const after = await (await del({ id: newest?.id })).json<VoiceAnswer>()
    expect(after.recordings.map((r) => r.slot)).toEqual(['first'])
    expect((await (await del({ all: true })).json<VoiceAnswer>()).recordings).toEqual([])
    expect((await del({ id: 'not-a-uuid' })).status).toBe(400)
    expect((await del({ all: true, id: newest?.id })).status).toBe(400)
  })
})

describe('the Say it step in the session', () => {
  function step(l: Learner, value: string) {
    return handleApi(
      post(`/api/sessions/${l.sessionId}/step`, { cookie: l.cookie, body: JSON.stringify({ step: value }) }),
      ENV,
      l.deps,
    )
  }

  it("[speak 5] the Worker stores say only for the learner's own session at understand", async () => {
    const early = await learner({ step: 'hear' })
    expect((await step(early, 'say')).status).toBe(409)
    expect(early.db.sessions[0]?.step).toBe('hear')
    const ready = await learner()
    expect((await step(ready, 'say')).status).toBe(200)
    expect(ready.db.sessions[0]?.step).toBe('say')
    // Saying it again changes nothing.
    expect((await step(ready, 'say')).status).toBe(200)
    const res = await handleApi(
      post(`/api/sessions/${ready.sessionId}/complete`, { cookie: ready.cookie }),
      ENV,
      ready.deps,
    )
    expect(res.status).toBe(200)
  })
})
