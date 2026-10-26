import { classifySpeech } from '../src/lib/speech-feedback.ts'
import {
  MAX_RECORDING_MS,
  MAX_SAY_BODY_BYTES,
  SPEECH_RATE_LIMIT,
  VOICE_CHOICES,
  type SayAnswer,
  type VoiceAnswer,
  type VoiceChoice,
} from '../src/lib/speech-types.ts'
import { VOICE_NOTICE_VERSION } from '../src/lib/voice-consent.ts'
import { fromBase64, isSpeechWav, readWav } from '../src/lib/wav.ts'
import { json, refuseNonGet, refuseUnsafeWrite, withCookies } from './http.ts'
import type { Fetch, LearnerContext } from './learner-auth.ts'
import { DatabaseUnavailable, type LearnerDb, type ReviewDb } from './learner-db.ts'
import { answer as answerReview, recallTarget } from './review.ts'
import {
  SpeechCheckFailed,
  speechProvider,
  type SpeechEnv,
  type SpeechProvider,
} from './providers/speech-feedback.ts'
import { supabaseRecordingStore, type RecordingStore } from './recording-store.ts'
import { supabaseSpeechDb, type ConsentRow, type SpeechDb } from './speech-db.ts'

// The speaking feedback routes (factory/jobs/10-speaking-feedback/spec.md,
// "Done when" 2, 4, 13 to 17, 19 and 20). They follow job 8's rules: every
// route that changes something takes only JSON POST from this same address,
// every answer is JSON and never cached (except the recording file, which is
// private and never stored), and every database call runs with the learner's
// own token.
//
// POST /api/speech/say decides what is checked: it reads the line from the
// database, so the browser never sends reference text. Every refusal happens
// before the speech service is called. The answer holds the feedback class and
// hint only; the transcript stays on the server. The audio is held in memory
// for this one request: it goes to the speech provider, and to the kept
// recordings only when the learner opted in. This file writes nothing to the
// log.

export interface SpeechDeps {
  fetch: Fetch
  /** Tests pass fakes; normally these are Supabase, as the learner. */
  speechDb?: (context: LearnerContext) => SpeechDb
  recordingStore?: (context: LearnerContext) => RecordingStore
  /** Tests pass a fake provider, or null for "not set up". */
  speechProvider?: SpeechProvider | null
}

/** What the speech routes need from the API module. */
export interface RouteKit {
  signedIn: (
    request: Request,
  ) => Promise<
    { context: LearnerContext; refused: null } | { context: LearnerContext | null; refused: Response }
  >
  learnerDb: (context: LearnerContext) => LearnerDb
  reviewDb: (context: LearnerContext) => ReviewDb
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
/** The largest WAV accepted: 10 seconds of 16 kHz mono 16 bit audio plus room for its header. */
const MAX_WAV_BYTES = 330_000

function providerFor(env: SpeechEnv, deps: SpeechDeps): SpeechProvider | null {
  return deps.speechProvider !== undefined ? deps.speechProvider : speechProvider(env, deps.fetch)
}

function speechDbFor(context: LearnerContext, deps: SpeechDeps): SpeechDb {
  return deps.speechDb ? deps.speechDb(context) : supabaseSpeechDb(context.client)
}

function storeFor(context: LearnerContext, deps: SpeechDeps): RecordingStore {
  return deps.recordingStore ? deps.recordingStore(context) : supabaseRecordingStore(context.client)
}

function fault(error: unknown): Response {
  if (error instanceof DatabaseUnavailable) return json({ error: 'not_available' }, 503)
  return json({ error: 'not_available' }, 503)
}

function parseObject(body: string): Record<string, unknown> | null {
  try {
    const parsed: unknown = JSON.parse(body)
    return typeof parsed === 'object' && parsed !== null && !Array.isArray(parsed)
      ? (parsed as Record<string, unknown>)
      : null
  } catch {
    return null
  }
}

function onlyKeys(value: Record<string, unknown>, allowed: readonly string[]): boolean {
  return Object.keys(value).every((key) => allowed.includes(key))
}

async function voiceAnswer(
  provider: SpeechProvider | null,
  db: SpeechDb,
  store: RecordingStore,
): Promise<VoiceAnswer> {
  const [consents, listed] = await Promise.all([db.consents(), store.list()])
  const lines = await db.spokenLines([...new Set(listed.map((row) => row.lineId))])
  return {
    available: provider !== null,
    region: provider?.regionName ?? null,
    processing: consents.processing,
    retention: consents.retention,
    recordings: listed.map((row) => ({
      id: row.id,
      line: lines.get(row.lineId) ?? null,
      slot: row.slot,
      createdAt: row.createdAt,
    })),
  }
}

/** GET /api/voice: the learner's two choices, whether speaking feedback is set up, and their kept recordings. */
export async function voiceState(
  request: Request,
  env: SpeechEnv,
  deps: SpeechDeps,
  kit: RouteKit,
): Promise<Response> {
  const notGet = await refuseNonGet(request)
  if (notGet) return notGet
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  try {
    const answer = await voiceAnswer(
      providerFor(env, deps),
      speechDbFor(context, deps),
      storeFor(context, deps),
    )
    return withCookies(json(answer), context.setCookies())
  } catch (error) {
    return withCookies(fault(error), context.setCookies())
  }
}

function parseChoice(body: string): { choice: VoiceChoice; keepRecordings: boolean } | null {
  const value = parseObject(body)
  if (!value || !onlyKeys(value, ['choice', 'keepRecordings'])) return null
  const choice = VOICE_CHOICES.find((c) => c === value.choice)
  if (!choice) return null
  if (value.keepRecordings !== undefined && typeof value.keepRecordings !== 'boolean') return null
  if (value.keepRecordings !== undefined && choice !== 'turn_on') return null
  return { choice, keepRecordings: value.keepRecordings === true }
}

/**
 * POST /api/voice/consent with {"choice": ...}. Every choice adds consents
 * rows in one statement, with the Worker's version label of the consent text.
 * Withdrawing deletes kept recordings (and, for speaking feedback, clears
 * transcripts) in the same transaction, by the database's own trigger.
 * - turn_on (with keepRecordings true or false): speaking feedback on, and
 *   the box's choice for keeping recordings.
 * - turn_off: speaking feedback off, and keeping recordings off with it.
 * - keep_on, keep_off: keeping recordings, while speaking feedback is on.
 */
export async function voiceConsent(
  request: Request,
  env: SpeechEnv,
  deps: SpeechDeps,
  kit: RouteKit,
): Promise<Response> {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const asked = parseChoice(write.body)
  if (!asked) return json({ error: 'bad_request' }, 400)
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const db = speechDbFor(context, deps)
    const now = await db.consents()
    const rows: ConsentRow[] = []
    if (asked.choice === 'turn_on') {
      rows.push({ kind: 'voice_processing', granted: true })
      if (asked.keepRecordings || now.retention) {
        rows.push({ kind: 'voice_recording_retention', granted: asked.keepRecordings })
      }
    } else if (asked.choice === 'turn_off') {
      rows.push({ kind: 'voice_processing', granted: false })
      if (now.retention) rows.push({ kind: 'voice_recording_retention', granted: false })
    } else {
      if (now.processing !== 'granted') return done({ error: 'speaking_feedback_off' }, 409)
      rows.push({ kind: 'voice_recording_retention', granted: asked.choice === 'keep_on' })
    }
    await db.addConsents(rows, VOICE_NOTICE_VERSION)
    return done(await voiceAnswer(providerFor(env, deps), db, storeFor(context, deps)))
  } catch (error) {
    return withCookies(fault(error), context.setCookies())
  }
}

/** POST /api/voice/recordings/delete with {"id": "<uuid>"} or {"all": true}. */
export async function deleteRecordings(
  request: Request,
  env: SpeechEnv,
  deps: SpeechDeps,
  kit: RouteKit,
): Promise<Response> {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const value = parseObject(write.body)
  const one =
    value && onlyKeys(value, ['id']) && typeof value.id === 'string' && UUID.test(value.id) ? value.id : null
  const all = value !== null && onlyKeys(value, ['all']) && value.all === true
  if (!one && !all) return json({ error: 'bad_request' }, 400)
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  try {
    const store = storeFor(context, deps)
    if (one) await store.remove(one)
    else await store.removeAll()
    const answer = await voiceAnswer(providerFor(env, deps), speechDbFor(context, deps), store)
    return withCookies(json(answer), context.setCookies())
  } catch (error) {
    return withCookies(fault(error), context.setCookies())
  }
}

/**
 * GET /api/voice/recordings/<id>: one of the learner's own kept recordings,
 * as WAV, private and never stored by a cache. Another learner's id answers
 * 404, the same as a missing one. Byte ranges are served, as Safari asks for
 * them before playing.
 */
export async function playRecording(
  request: Request,
  deps: SpeechDeps,
  kit: RouteKit,
  id: string,
): Promise<Response> {
  const notGet = await refuseNonGet(request)
  if (notGet) return notGet
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  let audio: Uint8Array | null
  try {
    audio = await storeFor(context, deps).read(id)
  } catch (error) {
    return withCookies(fault(error), context.setCookies())
  }
  if (!audio) return withCookies(json({ error: 'not_found' }, 404), context.setCookies())
  const headers = new Headers({
    'content-type': 'audio/wav',
    'cache-control': 'private, no-store',
    'x-content-type-options': 'nosniff',
    'accept-ranges': 'bytes',
  })
  const range = /^bytes=(\d*)-(\d*)$/.exec(request.headers.get('range') ?? '')
  if (range && (range[1] || range[2])) {
    const size = audio.length
    let start = range[1] ? Number(range[1]) : size - Number(range[2])
    let end = range[1] && range[2] ? Number(range[2]) : size - 1
    start = Math.max(0, start)
    end = Math.min(size - 1, end)
    if (start > end || start >= size) {
      headers.set('content-range', `bytes */${String(size)}`)
      return withCookies(new Response(null, { status: 416, headers }), context.setCookies())
    }
    headers.set('content-range', `bytes ${String(start)}-${String(end)}/${String(size)}`)
    return withCookies(
      new Response(audio.slice(start, end + 1), { status: 206, headers }),
      context.setCookies(),
    )
  }
  return withCookies(new Response(audio, { status: 200, headers }), context.setCookies())
}

interface SayRequest {
  sessionId: string
  lineId: number
  audio: string
}

function parseSay(body: string): SayRequest | null {
  const value = parseObject(body)
  if (!value || !onlyKeys(value, ['sessionId', 'lineId', 'audio'])) return null
  const { sessionId, lineId, audio } = value
  if (typeof sessionId !== 'string' || !UUID.test(sessionId)) return null
  if (typeof lineId !== 'number' || !Number.isSafeInteger(lineId) || lineId < 1) return null
  if (typeof audio !== 'string' || audio.length === 0) return null
  return { sessionId, lineId, audio }
}

const TOO_MANY = 'You have recorded a lot in the last few minutes. Take a short break, then try again.'

/** POST /api/speech/say with {"sessionId", "lineId", "audio"} (the WAV as base64). */
export async function say(
  request: Request,
  env: SpeechEnv,
  deps: SpeechDeps,
  kit: RouteKit,
): Promise<Response> {
  const write = await refuseUnsafeWrite(request, MAX_SAY_BODY_BYTES)
  if (write.refused) return write.refused
  const asked = parseSay(write.body)
  if (!asked) return json({ error: 'bad_request' }, 400)
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const provider = providerFor(env, deps)
    if (!provider) return done({ error: 'speech_not_available' }, 503)
    const db = speechDbFor(context, deps)
    const consents = await db.consents()
    if (consents.processing !== 'granted') return done({ error: 'no_voice_consent' }, 403)
    const session = await kit.learnerDb(context).session(asked.sessionId)
    if (session?.step !== 'understand' || session.endedAt !== null) {
      return done({ error: 'not_found' }, 404)
    }
    const line = await db.line(asked.lineId)
    if (line?.dialogueId !== session.dialogueId) return done({ error: 'not_found' }, 404)
    const wav = fromBase64(asked.audio)
    const info = wav ? readWav(wav) : null
    if (!wav || wav.length > MAX_WAV_BYTES || !isSpeechWav(info, MAX_RECORDING_MS)) {
      return done({ error: 'bad_audio' }, 400)
    }
    // The slot is taken before the speech service is asked, in one database
    // step, and never given back: a failed call counts, and parallel requests
    // cannot get past the limit.
    if (!(await db.reserveCheck(SPEECH_RATE_LIMIT.checks, SPEECH_RATE_LIMIT.minutes))) {
      return done({ error: 'too_many', message: TOO_MANY }, 429)
    }

    let heard
    try {
      heard = await provider.check(wav, line.spoken, request.headers.get('x-test-speech-fixture'))
    } catch (error) {
      const busy = error instanceof SpeechCheckFailed && error.fault === 'busy'
      return done({ error: busy ? 'speech_busy' : 'speech_failed' }, 503)
    }
    const feedback = classifySpeech({ spoken: line.spoken, written: line.written }, heard)
    const saved = await db.addAttempt({
      sessionId: session.id,
      lineId: line.id,
      formId: null,
      transcript: heard.heard,
      feedbackClass: feedback.feedbackClass,
      provider: provider.name,
      audioMs: info.durationMs,
      costUsd: provider.costUsd(info.durationMs),
    })
    if (!saved) return done({ error: 'no_voice_consent' }, 403)
    if (consents.retention) {
      try {
        await storeFor(context, deps).keep(line.id, asked.audio)
      } catch {
        // Keeping a copy is optional; the feedback still goes back.
      }
    }
    const answer: SayAnswer = feedback.hint
      ? { feedbackClass: feedback.feedbackClass, hint: feedback.hint }
      : { feedbackClass: feedback.feedbackClass }
    return done(answer)
  } catch (error) {
    return withCookies(fault(error), context.setCookies())
  }
}

// Spoken recall in review (statement 21) -----------------------------------------------

interface RecallRequest {
  sessionId: string
  formId: number
  audio: string
}

function parseRecall(body: string): RecallRequest | null {
  const value = parseObject(body)
  if (!value || !onlyKeys(value, ['sessionId', 'formId', 'audio'])) return null
  const { sessionId, formId, audio } = value
  if (typeof sessionId !== 'string' || !UUID.test(sessionId)) return null
  if (typeof formId !== 'number' || !Number.isSafeInteger(formId) || formId < 1) return null
  if (typeof audio !== 'string' || audio.length === 0) return null
  return { sessionId, formId, audio }
}

/**
 * POST /api/speech/recall with {"sessionId", "formId", "audio"} (the WAV as
 * base64). The same checks as /api/speech/say, in the same order, before the
 * speech service is asked; the reference is the form's spoken shape and either
 * register is accepted. The class becomes the rating by a fixed table
 * (src/lib/review-grade.ts) and goes through job 9's own answer path with mode
 * spoken. A recording that was not heard grades nothing: the answer says so
 * and the card is untouched. The answer holds no transcript.
 */
export async function recall(
  request: Request,
  env: SpeechEnv,
  deps: SpeechDeps,
  kit: RouteKit,
): Promise<Response> {
  const write = await refuseUnsafeWrite(request, MAX_SAY_BODY_BYTES)
  if (write.refused) return write.refused
  const asked = parseRecall(write.body)
  if (!asked) return json({ error: 'bad_request' }, 400)
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const provider = providerFor(env, deps)
    if (!provider) return done({ error: 'speech_not_available' }, 503)
    const db = speechDbFor(context, deps)
    const consents = await db.consents()
    if (consents.processing !== 'granted') return done({ error: 'no_voice_consent' }, 403)
    const target = await recallTarget(
      kit.learnerDb(context),
      kit.reviewDb(context),
      asked.sessionId,
      asked.formId,
    )
    if (target.kind === 'not_found') return done({ error: 'not_found' }, 404)
    if (target.kind === 'not_ready') return done({ error: 'step_out_of_order' }, 409)
    const wav = fromBase64(asked.audio)
    const info = wav ? readWav(wav) : null
    if (!wav || wav.length > MAX_WAV_BYTES || !isSpeechWav(info, MAX_RECORDING_MS)) {
      return done({ error: 'bad_audio' }, 400)
    }
    if (!(await db.reserveCheck(SPEECH_RATE_LIMIT.checks, SPEECH_RATE_LIMIT.minutes))) {
      return done({ error: 'too_many', message: TOO_MANY }, 429)
    }
    let heard
    try {
      heard = await provider.check(wav, target.form.spoken, request.headers.get('x-test-speech-fixture'))
    } catch (error) {
      const busy = error instanceof SpeechCheckFailed && error.fault === 'busy'
      return done({ error: busy ? 'speech_busy' : 'speech_failed' }, 503)
    }
    const feedback = classifySpeech(target.form, heard)
    const saved = await db.addAttempt({
      sessionId: null,
      lineId: null,
      formId: asked.formId,
      transcript: heard.heard,
      feedbackClass: feedback.feedbackClass,
      provider: provider.name,
      audioMs: info.durationMs,
      costUsd: provider.costUsd(info.durationMs),
    })
    if (!saved) return done({ error: 'no_voice_consent' }, 403)
    if (feedback.feedbackClass === 'not_heard') return done({ status: 'not_heard' })
    const outcome = await answerReview(
      kit.learnerDb(context),
      kit.reviewDb(context),
      {
        sessionId: asked.sessionId,
        formId: asked.formId,
        answer: { kind: 'spoken', feedbackClass: feedback.feedbackClass },
      },
      new Date(),
    )
    if (outcome.kind === 'not_found') return done({ error: 'not_found' }, 404)
    if (outcome.kind === 'not_ready') return done({ error: 'step_out_of_order' }, 409)
    if (outcome.kind === 'changed') return done({ error: 'card_changed' }, 409)
    return done({ status: 'graded', feedback: outcome.feedback })
  } catch (error) {
    return withCookies(fault(error), context.setCookies())
  }
}
