import { MAX_RECORDING_MS, MAX_SAY_BODY_BYTES, SPEECH_RATE_LIMIT } from '../src/lib/speech-types.ts'
import { TUTOR_NOTICE_VERSION } from '../src/lib/tutor-consent.ts'
import type {
  TutorHistoryItem,
  TutorOffer,
  TutorReply,
  TutorState,
  TutorTip,
  TutorTranscript,
  TutorTurnAnswer,
} from '../src/lib/tutor-types.ts'
import {
  checkReply,
  cleanMeaning,
  cleanReply,
  metLanguage,
  pickFallback,
  pickOpening,
  TUTOR_ATTEMPTS,
  TUTOR_TURNS,
  type MetLanguage,
} from '../src/lib/tutor-words.ts'
import type { SessionWord, WordForm } from '../src/lib/session-types.ts'
import { TUTOR_VOICE_VERSIONS } from '../src/lib/voice-consent.ts'
import { fromBase64, isSpeechWav, readWav } from '../src/lib/wav.ts'
import { json, refuseNonGet, refuseUnsafeWrite, withCookies } from './http.ts'
import type { Fetch, LearnerContext } from './learner-auth.ts'
import { DatabaseUnavailable, type FormRow, type ReadableDialogue } from './learner-db.ts'
import { metSessions } from './patterns.ts'
import { aiProvider, type AiEnv, type AiProvider } from './providers/ai.ts'
import {
  SpeechCheckFailed,
  speechProvider,
  type SpeechEnv,
  type SpeechProvider,
} from './providers/speech-feedback.ts'
import { audioPath } from './session-plan.ts'
import { supabaseSpeechDb, type SpeechDb } from './speech-db.ts'
import { buildPrompt, parseOtso } from './tutor-prompt.ts'
import { supabaseTutorDb, type TutorDb, type TutorLineRow } from './tutor-db.ts'

// The tutor step, Otso (factory/jobs/16-tutor-step/spec.md, with the owner's answers of 3 November
// 2026). Routes:
// - GET  /api/tutor[?session=<id>]  the learner's choice, and what that session's step shows;
// - POST /api/tutor/consent         {"choice": "on" | "off"}, one consents row;
// - POST /api/tutor/turn            one learner reply, Otso's answer;
// - POST /api/tutor/transcribe      a spoken answer, turned into text for the learner to check.
//
// Every route follows job 8's rules: JSON POST from this same address for every change, the learner's
// own token for every read and write, and 404 for a session that is not the learner's. Every refusal
// happens before the AI or speech service is called. Every AI call first reserves a slot in the
// database (public.reserve_tutor_call), which enforces the daily and monthly caps.
//
// Nothing is stored: not the learner's reply, the transcript, the prompt or Otso's answer. The chat
// lives in the page's memory and is checked again here on every turn. The only row written per call
// is its cost row, with no text. This file writes nothing to the log.

export type TutorEnv = AiEnv & SpeechEnv

export interface TutorDeps {
  fetch: Fetch
  /** Tests pass fakes; normally these are Supabase, as the learner. */
  tutorDb?: (context: LearnerContext) => TutorDb
  speechDb?: (context: LearnerContext) => SpeechDb
  /** Tests pass a fake provider, or null for "not set up". */
  aiProvider?: AiProvider | null
  speechProvider?: SpeechProvider | null
}

export interface TutorKit {
  signedIn: (
    request: Request,
  ) => Promise<
    { context: LearnerContext; refused: null } | { context: LearnerContext | null; refused: Response }
  >
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
/** The tutor's request bodies are small: 8 KB at most (statement 17). */
const MAX_TURN_BODY_BYTES = 8 * 1024
/** The same WAV limit as Say it. */
const MAX_WAV_BYTES = 330_000
const LOOP_ORDER = ['hear', 'understand', 'say', 'keep', 'use'] as const
/** The first road stop with Otso's step (owner: "units 4 to 6" now means stops 4 onwards). */
export const FIRST_TUTOR_STOP = 4
const MAX_TIP_LINES = 12

function providerFor(env: TutorEnv, deps: TutorDeps): AiProvider | null {
  return deps.aiProvider !== undefined ? deps.aiProvider : aiProvider(env, deps.fetch)
}

function speechFor(env: TutorEnv, deps: TutorDeps): SpeechProvider | null {
  return deps.speechProvider !== undefined ? deps.speechProvider : speechProvider(env, deps.fetch)
}

function dbFor(context: LearnerContext, deps: TutorDeps): TutorDb {
  return deps.tutorDb ? deps.tutorDb(context) : supabaseTutorDb(context.client)
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

/** True when a road stop has Otso's step. Stops 1, 2 and 3 do not; 4 and later do. */
export function tutorStop(stop: number | null | undefined): boolean {
  return typeof stop === 'number' && stop >= FIRST_TUTOR_STOP
}

// What the learner has met, for one session -------------------------------------------------------------

interface Material {
  current: ReadableDialogue
  /** Today's dialogue's approved lines, in order. */
  lines: TutorLineRow[]
  met: MetLanguage
  /** Allowed words, for the prompt. */
  words: string[]
  examples: string[]
  /** Met forms by their lowercased spoken shape, for the word cards of Otso's AI lines. */
  formsBySpoken: Map<string, FormRow[]>
  /** Approved lines Otso may point to at the end, today's first. */
  tipLines: TutorLineRow[]
}

function atUnderstandOrLater(step: string | null): boolean {
  return (
    step !== null &&
    LOOP_ORDER.indexOf(step as (typeof LOOP_ORDER)[number]) >= LOOP_ORDER.indexOf('understand')
  )
}

/**
 * Reads what the learner has met, as they may read it: the forms they have a card for, the forms and
 * lines of today's dialogue, and the approved lines of every dialogue they finished Understand it in.
 * Null when the session is not the learner's, has ended, is before Understand it or is below stop 4.
 */
async function materialFor(db: TutorDb, sessionId: string): Promise<Material | null> {
  const [dialogues, sessions, cardFormIds] = await Promise.all([
    db.readableDialogues(),
    db.mySessions(),
    db.cardFormIds(),
  ])
  const session = sessions.find((s) => s.id === sessionId)
  if (session?.dialogueId == null || session.endedAt !== null || !atUnderstandOrLater(session.step)) {
    return null
  }
  const byId = new Map(dialogues.map((d) => [d.id, d]))
  const current = byId.get(session.dialogueId)
  if (!current || !tutorStop(current.stopNumber)) return null
  const { met } = metSessions(sessions, sessionId)
  const metIds = [
    ...new Set(met.flatMap((s) => (s.dialogueId !== null && byId.has(s.dialogueId) ? [s.dialogueId] : []))),
  ]
  const allLines = await db.lines(metIds)
  const lines = allLines.filter((l) => l.dialogueId === current.id).sort((a, b) => a.position - b.position)
  if (lines.length === 0) return null
  // Tokens of today's dialogue only: its forms join the met forms, and its words with no form (names) are allowed.
  const tokens = await db.tokens(lines.map((l) => l.id))
  const formIds = new Set(cardFormIds)
  for (const token of tokens) if (token.formId !== null) formIds.add(token.formId)
  const forms = formIds.size === 0 ? [] : await db.forms([...formIds].sort((a, b) => a - b))
  const names = [
    ...new Set(allLines.map((l) => l.speaker)),
    ...tokens.filter((t) => t.register === 'puhe' && t.formId === null).map((t) => t.surface),
  ]
  const metLang = metLanguage({
    spokenForms: forms.map((f) => f.surfacePuhe),
    names,
    lines: allLines.map((l) => l.spoken),
  })
  const formsBySpoken = new Map<string, FormRow[]>()
  for (const form of forms) {
    const key = form.surfacePuhe.toLocaleLowerCase('fi-FI')
    formsBySpoken.set(key, [...(formsBySpoken.get(key) ?? []), form])
  }
  // Other met lines, the most recent dialogues first, for examples and tips.
  const order = (l: TutorLineRow) => {
    const d = byId.get(l.dialogueId)
    return [d?.unitPosition ?? 0, d?.position ?? 0, -l.position]
  }
  const others = allLines
    .filter((l) => l.dialogueId !== current.id)
    .sort((a, b) => {
      const [ua, da, la] = order(a)
      const [ub, dbb, lb] = order(b)
      return (ub ?? 0) - (ua ?? 0) || (dbb ?? 0) - (da ?? 0) || (lb ?? 0) - (la ?? 0)
    })
  const usable = (l: TutorLineRow) =>
    audioPath(l.audioPuheKey) !== null && audioPath(l.audioKirjaKey) !== null
  return {
    current,
    lines,
    met: metLang,
    words: [...metLang.words],
    examples: [...lines, ...others].map((l) => l.spoken),
    formsBySpoken,
    tipLines: [...lines, ...others].filter(usable).slice(0, MAX_TIP_LINES),
  }
}

// GET /api/tutor --------------------------------------------------------------------------------------------

/** GET /api/tutor[?session=<id>]: the learner's choice, and with a session, what its step shows. */
export async function tutorState(
  request: Request,
  env: TutorEnv,
  deps: TutorDeps,
  kit: TutorKit,
): Promise<Response> {
  const notGet = await refuseNonGet(request)
  if (notGet) return notGet
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  const asked = new URL(request.url).searchParams.get('session')
  const sessionId = asked !== null && UUID.test(asked) ? asked : null
  try {
    const db = dbFor(context, deps)
    const available = providerFor(env, deps) !== null
    const [consents, guest] = await Promise.all([db.consents(), db.isGuest()])
    const state: TutorState = {
      available,
      consent: consents.tutor,
      guest,
      speech: speechFor(env, deps) !== null,
      voiceForTutor:
        consents.voice !== null &&
        consents.voice.granted &&
        TUTOR_VOICE_VERSIONS.includes(consents.voice.version),
    }
    if (sessionId !== null) state.offer = await offerFor(db, sessionId, state)
    return withCookies(json(state), context.setCookies())
  } catch (error) {
    return withCookies(fault(error), context.setCookies())
  }
}

async function offerFor(db: TutorDb, sessionId: string, state: TutorState): Promise<TutorOffer> {
  if (!state.available || state.consent === 'withdrawn') return 'none'
  const [session, dialogues] = await Promise.all([db.session(sessionId), db.readableDialogues()])
  if (session?.dialogueId == null || session.endedAt !== null) return 'none'
  const dialogue = dialogues.find((d) => d.id === session.dialogueId)
  if (!dialogue || !tutorStop(dialogue.stopNumber)) return 'none'
  if (state.guest) return 'guest'
  if (!(await db.allowance())) return 'cap'
  return state.consent === 'granted' ? 'ready' : 'consent'
}

// POST /api/tutor/consent ----------------------------------------------------------------------------------

/** POST /api/tutor/consent with {"choice": "on" | "off"}: one ai_tutor consents row, with the Worker's version label. */
export async function tutorConsent(request: Request, deps: TutorDeps, kit: TutorKit): Promise<Response> {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const value = parseObject(write.body)
  if (!value || !onlyKeys(value, ['choice']) || (value.choice !== 'on' && value.choice !== 'off')) {
    return json({ error: 'bad_request' }, 400)
  }
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  try {
    const db = dbFor(context, deps)
    await db.addTutorConsent(value.choice === 'on', TUTOR_NOTICE_VERSION)
    const consents = await db.consents()
    return withCookies(json({ consent: consents.tutor }), context.setCookies())
  } catch (error) {
    return withCookies(fault(error), context.setCookies())
  }
}

// POST /api/tutor/turn -------------------------------------------------------------------------------------

interface TurnRequest {
  sessionId: string
  reply: string
  history: TutorHistoryItem[]
}

/** The turn's body, or 'too_many' for a fourth reply, or null for a bad shape (statement 17). */
export function parseTurn(body: string): TurnRequest | 'too_many' | null {
  const value = parseObject(body)
  if (!value || !onlyKeys(value, ['sessionId', 'reply', 'history'])) return null
  const { sessionId, reply, history } = value
  if (typeof sessionId !== 'string' || !UUID.test(sessionId)) return null
  const cleaned = cleanReply(reply)
  if (cleaned === null) return null
  if (!Array.isArray(history)) return null
  const items: TutorHistoryItem[] = []
  for (const item of history as unknown[]) {
    if (typeof item !== 'object' || item === null || Array.isArray(item)) return null
    const record = item as Record<string, unknown>
    if (!onlyKeys(record, ['you', 'otso'])) return null
    const you = cleanReply(record.you)
    const otso = record.otso
    if (you === null || typeof otso !== 'string' || otso.length > 300) return null
    items.push({ you, otso })
  }
  if (items.length >= TUTOR_TURNS) return 'too_many'
  return { sessionId, reply: cleaned, history: items }
}

const CAP = (): Response => json({ error: 'tutor_cap' }, 429)

/** Otso's AI line as words; a word that matches exactly one met form opens that form's card. */
export function aiWords(text: string, formsBySpoken: ReadonlyMap<string, readonly FormRow[]>): SessionWord[] {
  const words: SessionWord[] = []
  for (const chunk of text.trim().split(/\s+/u)) {
    const match = /^([^\p{L}]*)([\p{L}'-]*[\p{L}])?([^\p{L}]*)$/u.exec(chunk)
    const core = match?.[2]
    if (!match || !core) {
      const last = words[words.length - 1]
      if (last) last.after = `${last.after ?? ''}${chunk}`
      continue
    }
    const candidates = formsBySpoken.get(core.toLocaleLowerCase('fi-FI')) ?? []
    const form = candidates.length === 1 ? candidates[0] : undefined
    const card: WordForm | undefined = form
      ? {
          lemma: form.lemma,
          formName: form.formName,
          why: form.why,
          spoken: form.surfacePuhe,
          written: form.surfaceKirja,
          ...(form.meaning ? { meaning: form.meaning } : {}),
          ...(form.baseMeaning ? { baseMeaning: form.baseMeaning } : {}),
        }
      : undefined
    words.push({
      text: core,
      ...(match[1] ? { before: match[1] } : {}),
      ...(match[3] ? { after: match[3] } : {}),
      ...(card ? { form: card } : {}),
    })
  }
  return words
}

function tipOf(line: TutorLineRow): TutorTip | undefined {
  const spokenAudio = audioPath(line.audioPuheKey)
  const writtenAudio = audioPath(line.audioKirjaKey)
  if (!spokenAudio || !writtenAudio) return undefined
  return { spoken: line.spoken, written: line.written, gloss: line.gloss, spokenAudio, writtenAudio }
}

/** POST /api/tutor/turn with {"sessionId", "reply", "history"}. */
export async function tutorTurn(
  request: Request,
  env: TutorEnv,
  deps: TutorDeps,
  kit: TutorKit,
): Promise<Response> {
  const write = await refuseUnsafeWrite(request, MAX_TURN_BODY_BYTES)
  if (write.refused) return write.refused
  const asked = parseTurn(write.body)
  if (asked === 'too_many') return json({ error: 'exchange_finished' }, 409)
  if (!asked) return json({ error: 'bad_request' }, 400)
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const provider = providerFor(env, deps)
    if (!provider) return done({ error: 'not_available' }, 503)
    const db = dbFor(context, deps)
    const [consents, guest] = await Promise.all([db.consents(), db.isGuest()])
    if (consents.tutor !== 'granted') return done({ error: 'no_tutor_consent' }, 403)
    if (guest) return done({ error: 'email_needed' }, 403)
    const material = await materialFor(db, asked.sessionId)
    if (!material) return done({ error: 'not_found' }, 404)
    // Every earlier Otso line must still pass the word check: the app holds the chat, the Worker trusts none of it.
    if (asked.history.some((item) => !checkReply(item.otso, material.met, 0).ok)) {
      return done({ error: 'bad_request' }, 400)
    }
    const turn = asked.history.length + 1
    const closing = turn >= TUTOR_TURNS
    const opening = pickOpening(material.lines)
    if (!opening) return done({ error: 'not_found' }, 404)
    const tipLines = closing ? material.tipLines : []
    const fixture = request.headers.get('x-test-tutor-fixture')

    let retry: { outside: string[]; unmetPairs: string[] } | null = null
    for (let attempt = 1; attempt <= TUTOR_ATTEMPTS; attempt += 1) {
      const callId = await db.reserve(asked.sessionId, turn, attempt)
      if (callId === null) {
        if (attempt === 1) return withCookies(CAP(), context.setCookies())
        break
      }
      const prompt = buildPrompt({
        unitTitle: material.current.unitTitle,
        canDo: material.current.canDo,
        dialogue: material.lines.map((l) => ({ speaker: l.speaker, spoken: l.spoken })),
        role: opening.speaker,
        words: material.words,
        examples: material.examples,
        opening: opening.spoken,
        history: asked.history,
        reply: asked.reply,
        turn,
        tipLines: tipLines.map((l) => l.spoken),
        retry,
      })
      let answer
      try {
        answer = await provider.reply(prompt, fixture)
      } catch {
        await finishQuietly(db, callId, {
          outcome: 'provider_error',
          provider: provider.name,
          model: provider.model,
          inputTokens: 0,
          outputTokens: 0,
          costUsd: 0,
        })
        // Trouble on the first try: Otso is not available (statement 4). On a retry: an approved line.
        if (attempt === 1) return done({ error: 'ai_failed' }, 503)
        break
      }
      const parsed = parseOtso(answer.raw)
      const check = parsed ? checkReply(parsed.reply, material.met) : null
      const ok = check?.ok === true
      await finishQuietly(db, callId, {
        outcome: ok ? 'served' : 'failed_check',
        provider: provider.name,
        model: answer.model,
        inputTokens: answer.inputTokens,
        outputTokens: answer.outputTokens,
        costUsd: answer.costUsd,
      })
      if (ok && parsed) {
        const meaning = cleanMeaning(parsed.meaning)
        const otso: TutorReply = {
          kind: 'ai',
          text: parsed.reply.trim(),
          words: aiWords(parsed.reply, material.formsBySpoken),
          ...(meaning ? { meaning } : {}),
        }
        const tipLine =
          closing && parsed.tip >= 1 && parsed.tip <= tipLines.length ? tipLines[parsed.tip - 1] : undefined
        const tip = tipLine ? tipOf(tipLine) : undefined
        const answerBody: TutorTurnAnswer = { turn, otso, closing, ...(tip ? { tip } : {}) }
        return done(answerBody)
      }
      // The next try names the offending words and pairs, never the learner's text.
      retry = { outside: check?.outside ?? [], unmetPairs: check?.unmetPairs ?? [] }
    }
    // Three failed tries, or a failure on a retry: an approved line of today's dialogue (statement 14).
    const used = [
      opening.id,
      ...material.lines.filter((l) => asked.history.some((h) => h.otso === l.spoken)).map((l) => l.id),
    ]
    const fallback = pickFallback(material.lines, used)
    const otso: TutorReply = fallback ? { kind: 'line', lineId: fallback.id } : { kind: 'end' }
    const answerBody: TutorTurnAnswer = { turn, otso, closing: closing || !fallback }
    return done(answerBody)
  } catch (error) {
    return withCookies(fault(error), context.setCookies())
  }
}

async function finishQuietly(db: TutorDb, callId: string, result: Parameters<TutorDb['finish']>[1]) {
  try {
    await db.finish(callId, result)
  } catch {
    // The slot is already counted against the caps; a missing cost line must not break the chat.
  }
}

// POST /api/tutor/transcribe ---------------------------------------------------------------------------------

function parseTranscribe(body: string): { sessionId: string; audio: string } | null {
  const value = parseObject(body)
  if (!value || !onlyKeys(value, ['sessionId', 'audio'])) return null
  const { sessionId, audio } = value
  if (typeof sessionId !== 'string' || !UUID.test(sessionId)) return null
  if (typeof audio !== 'string' || audio.length === 0) return null
  return { sessionId, audio }
}

const TOO_MANY = 'You have recorded a lot in the last few minutes. Take a short break, then try again.'

/**
 * POST /api/tutor/transcribe with {"sessionId", "audio"} (16 kHz WAV as base64): plain transcription
 * through the speech module (owner's call 3, answer B). Needs the tutor consent and a voice consent
 * whose text names this use. The text goes back to the learner, who checks it and sends it as their
 * reply; nothing is stored, and the speech check slot (job 10's rate limit) holds no content.
 */
export async function tutorTranscribe(
  request: Request,
  env: TutorEnv,
  deps: TutorDeps,
  kit: TutorKit,
): Promise<Response> {
  const write = await refuseUnsafeWrite(request, MAX_SAY_BODY_BYTES)
  if (write.refused) return write.refused
  const asked = parseTranscribe(write.body)
  if (!asked) return json({ error: 'bad_request' }, 400)
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const speech = speechFor(env, deps)
    if (!speech) return done({ error: 'speech_not_available' }, 503)
    const db = dbFor(context, deps)
    const [consents, guest] = await Promise.all([db.consents(), db.isGuest()])
    if (consents.tutor !== 'granted' || guest) return done({ error: 'no_tutor_consent' }, 403)
    const voice = consents.voice
    if (!voice?.granted || !TUTOR_VOICE_VERSIONS.includes(voice.version)) {
      return done({ error: 'no_voice_consent' }, 403)
    }
    const [session, dialogues] = await Promise.all([db.session(asked.sessionId), db.readableDialogues()])
    const dialogue =
      session?.dialogueId == null || session.endedAt !== null || !atUnderstandOrLater(session.step)
        ? undefined
        : dialogues.find((d) => d.id === session.dialogueId)
    if (!dialogue || !tutorStop(dialogue.stopNumber)) {
      return done({ error: 'not_found' }, 404)
    }
    const wav = fromBase64(asked.audio)
    const info = wav ? readWav(wav) : null
    if (!wav || wav.length > MAX_WAV_BYTES || !isSpeechWav(info, MAX_RECORDING_MS)) {
      return done({ error: 'bad_audio' }, 400)
    }
    const speechDb = deps.speechDb ? deps.speechDb(context) : supabaseSpeechDb(context.client)
    if (!(await speechDb.reserveCheck(SPEECH_RATE_LIMIT.checks, SPEECH_RATE_LIMIT.minutes))) {
      return done({ error: 'too_many', message: TOO_MANY }, 429)
    }
    let heard
    try {
      heard = await speech.transcribe(wav, request.headers.get('x-test-speech-fixture'))
    } catch (error) {
      const busy = error instanceof SpeechCheckFailed && error.fault === 'busy'
      return done({ error: busy ? 'speech_busy' : 'speech_failed' }, 503)
    }
    const answer: TutorTranscript =
      heard.status === 'heard' ? { status: 'heard', text: heard.text.slice(0, 120) } : { status: 'not_heard' }
    return done(answer)
  } catch (error) {
    return withCookies(fault(error), context.setCookies())
  }
}
