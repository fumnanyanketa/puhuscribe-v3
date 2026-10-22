// Test helpers for the Worker's unit tests (not a test file itself).
// A fake Supabase that answers the Auth calls the Worker makes through
// @supabase/ssr, and records every request, plus a fake learner database.
// Nothing here is used by the app.

import type { RecordableStep } from '../src/lib/session-types.ts'
import type { ApiEnv } from './api.ts'
import type { Fetch } from './learner-auth.ts'
import type { HeardAnswer } from '../src/lib/speech-feedback.ts'
import type { SpeechProvider } from './providers/speech-feedback.ts'
import type { RecordingStore } from './recording-store.ts'
import type { AttemptRow, ConsentRow, SpeechDb, SpeechLine } from './speech-db.ts'
import type {
  CompleteResult,
  DialogueContent,
  LearnerDb,
  ReadableDialogue,
  SessionRow,
} from './learner-db.ts'

export const PROJECT = 'https://fake-ref.supabase.co'
export const PUBLISHABLE = 'sb_publishable_fake_value_for_tests'
export const ENV: ApiEnv = { SUPABASE_URL: PROJECT, SUPABASE_PUBLISHABLE_KEY: PUBLISHABLE }
export const ORIGIN = 'https://puhuscribe.example'

export interface RecordedRequest {
  method: string
  url: URL
  headers: Headers
  body: string
}

export interface FakeSupabase {
  fetch: Fetch
  requests: RecordedRequest[]
  /** Users that exist. Deleting one makes its tokens fail. */
  users: Set<string>
  /** Every access and refresh token handed out so far. */
  issued: string[]
  /** Every user id made so far. */
  userIds: string[]
  /** Makes Auth answer 503 from now on. */
  down: boolean
  /** Answers /rest/v1 requests; undefined means 404. */
  rest?: (request: RecordedRequest) => Response | undefined
}

function base64url(value: unknown): string {
  return btoa(JSON.stringify(value)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
}

export function fakeSupabase(): FakeSupabase {
  const access = new Map<string, string>()
  const refresh = new Map<string, string>()
  let counter = 0

  const fake: FakeSupabase = {
    requests: [],
    users: new Set(),
    issued: [],
    userIds: [],
    down: false,
    fetch: async (input, init) => {
      const request = new Request(input, init)
      const recorded: RecordedRequest = {
        method: request.method,
        url: new URL(request.url),
        headers: new Headers(request.headers),
        body: request.body ? await request.text() : '',
      }
      fake.requests.push(recorded)
      const answer = (status: number, body: unknown) =>
        new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
      const path = recorded.url.pathname
      if (path.startsWith('/rest/v1/')) return fake.rest?.(recorded) ?? answer(404, { message: 'not found' })
      if (fake.down) return answer(503, { message: 'unavailable' })

      const userJson = (id: string) => ({
        id,
        aud: 'authenticated',
        role: 'authenticated',
        is_anonymous: true,
        app_metadata: {},
        user_metadata: {},
        created_at: new Date().toISOString(),
      })
      const session = (id: string) => {
        counter += 1
        const now = Math.floor(Date.now() / 1000)
        const accessToken = `${base64url({ alg: 'HS256', typ: 'JWT' })}.${base64url({ sub: id, exp: now + 3600, role: 'authenticated', n: counter })}.fake-signature-${String(counter)}`
        const refreshToken = `fake-refresh-${String(counter)}-${id.slice(0, 8)}`
        access.set(accessToken, id)
        refresh.set(refreshToken, id)
        fake.issued.push(accessToken, refreshToken)
        return {
          access_token: accessToken,
          token_type: 'bearer',
          expires_in: 3600,
          expires_at: now + 3600,
          refresh_token: refreshToken,
          user: userJson(id),
        }
      }

      if (path === '/auth/v1/signup' && recorded.method === 'POST') {
        const id = crypto.randomUUID()
        fake.users.add(id)
        fake.userIds.push(id)
        return answer(200, session(id))
      }
      if (path === '/auth/v1/token' && recorded.url.searchParams.get('grant_type') === 'refresh_token') {
        const token = (JSON.parse(recorded.body || '{}') as { refresh_token?: string }).refresh_token ?? ''
        const id = refresh.get(token)
        // Refresh tokens are used once.
        refresh.delete(token)
        if (!id || !fake.users.has(id)) {
          return answer(400, {
            code: 'refresh_token_not_found',
            error_code: 'refresh_token_not_found',
            msg: 'Invalid Refresh Token: Refresh Token Not Found',
          })
        }
        return answer(200, session(id))
      }
      if (path === '/auth/v1/user' && recorded.method === 'GET') {
        const token = (recorded.headers.get('authorization') ?? '').replace(/^Bearer /, '')
        const id = access.get(token)
        if (!id || !fake.users.has(id)) {
          return answer(403, { code: 'user_not_found', error_code: 'user_not_found', msg: 'User not found' })
        }
        return answer(200, userJson(id))
      }
      return answer(404, { message: 'not found' })
    },
  }
  return fake
}

/** The Set-Cookie values of an answer. */
export function setCookies(res: Response): string[] {
  return res.headers.getSetCookie()
}

/** A Cookie request header carrying every cookie an answer set (ignoring removals). */
export function cookieHeader(res: Response, before = ''): string {
  const jar = new Map<string, string>()
  for (const part of before.split(/;\s*/).filter(Boolean)) {
    const at = part.indexOf('=')
    jar.set(part.slice(0, at), part.slice(at + 1))
  }
  for (const cookie of setCookies(res)) {
    const first = cookie.split(';')[0] ?? ''
    const at = first.indexOf('=')
    const name = first.slice(0, at)
    const value = first.slice(at + 1)
    if (/max-age=0/i.test(cookie) || value === '') jar.delete(name)
    else jar.set(name, value)
  }
  return [...jar].map(([name, value]) => `${name}=${value}`).join('; ')
}

export function post(
  path: string,
  options: { cookie?: string; origin?: string; body?: string; contentType?: string } = {},
) {
  const headers = new Headers({ 'content-type': options.contentType ?? 'application/json' })
  if (options.cookie) headers.set('cookie', options.cookie)
  if (options.origin) headers.set('origin', options.origin)
  return new Request(`${ORIGIN}${path}`, { method: 'POST', headers, body: options.body ?? '{}' })
}

export function get(path: string, cookie?: string) {
  return new Request(`${ORIGIN}${path}`, { headers: cookie ? { cookie } : {} })
}

/** A learner database in memory, standing in for Supabase as the learner. */
export interface FakeDb extends LearnerDb {
  dialogues: ReadableDialogue[]
  sessions: SessionRow[]
  content: Map<number, DialogueContent>
  completed: string[]
  failNext: boolean
}

export function fakeDb(
  dialogues: ReadableDialogue[] = [],
  content = new Map<number, DialogueContent>(),
): FakeDb {
  let started = 0
  const db: FakeDb = {
    dialogues,
    sessions: [],
    content,
    completed: [],
    failNext: false,
    readableDialogues: () => Promise.resolve([...db.dialogues]),
    mySessions: () => Promise.resolve(db.sessions.map((s) => ({ ...s }))),
    startSession: (dialogueId) => {
      started += 1
      const row: SessionRow = {
        id: `00000000-0000-4000-8000-${String(started).padStart(12, '0')}`,
        dialogueId,
        step: null,
        startedAt: new Date(Date.UTC(2026, 9, 21, 12, 0, started)).toISOString(),
        endedAt: null,
      }
      db.sessions.push(row)
      return Promise.resolve({ ...row })
    },
    dialogueContent: (dialogueId) =>
      Promise.resolve(db.content.get(dialogueId) ?? { lines: [], tokens: [], forms: [] }),
    session: (id) => Promise.resolve(db.sessions.find((s) => s.id === id) ?? null),
    setStep: (id, step: RecordableStep) => {
      const row = db.sessions.find((s) => s.id === id && s.endedAt === null)
      if (!row) return Promise.resolve(false)
      row.step = step
      return Promise.resolve(true)
    },
    completeSession: (id): Promise<CompleteResult> => {
      if (db.failNext) {
        db.failNext = false
        return Promise.reject(new Error('down'))
      }
      const row = db.sessions.find((s) => s.id === id)
      if (!row) return Promise.resolve('not_found')
      // Like public.complete_session: understand or later (Say it, job 10).
      if (row.step !== 'understand' && row.step !== 'say') return Promise.resolve('not_ready')
      row.endedAt ??= new Date().toISOString()
      db.completed.push(id)
      return Promise.resolve('saved')
    },
  }
  return db
}

/** One small readable dialogue: two lines, a name with no form, one changed word. */
export function sampleContent(): DialogueContent {
  return {
    lines: [
      {
        id: 11,
        position: 1,
        speaker: 'Speaker A',
        textPuhe: 'Moi! Mä oon Alex.',
        textKirja: 'Hei! Minä olen Alex.',
        gloss: 'Hi! I am Alex.',
        audioPuheKey: 'unit-test/1-puhe.mp3',
        audioKirjaKey: 'unit-test/1-kirja.mp3',
      },
      {
        id: 12,
        position: 2,
        speaker: 'Speaker B',
        textPuhe: 'Kiva tavata!',
        textKirja: 'Hauska tavata!',
        gloss: 'Nice to meet you!',
        audioPuheKey: 'unit-test/2-puhe.mp3',
        audioKirjaKey: 'unit-test/2-kirja.mp3',
      },
    ],
    tokens: [
      { lineId: 11, register: 'puhe', position: 1, surface: 'Moi', formId: 1 },
      { lineId: 11, register: 'puhe', position: 2, surface: 'Mä', formId: 2 },
      { lineId: 11, register: 'puhe', position: 3, surface: 'oon', formId: 3 },
      { lineId: 11, register: 'puhe', position: 4, surface: 'Alex', formId: null },
      { lineId: 11, register: 'kirja', position: 1, surface: 'Hei', formId: 4 },
      { lineId: 11, register: 'kirja', position: 2, surface: 'Minä', formId: 2 },
      { lineId: 11, register: 'kirja', position: 3, surface: 'olen', formId: 3 },
      { lineId: 11, register: 'kirja', position: 4, surface: 'Alex', formId: null },
      { lineId: 12, register: 'puhe', position: 1, surface: 'Kiva', formId: 5 },
      // Form 99 is a draft: the database does not return it, so the word is plain.
      { lineId: 12, register: 'puhe', position: 2, surface: 'tavata', formId: 99 },
      { lineId: 12, register: 'kirja', position: 1, surface: 'Hauska', formId: 6 },
      { lineId: 12, register: 'kirja', position: 2, surface: 'tavata', formId: 99 },
    ],
    forms: [
      { id: 1, lemma: 'moi', formName: 'Greeting', why: 'Why one.', surfacePuhe: 'moi', surfaceKirja: 'moi' },
      { id: 2, lemma: 'minä', formName: 'I', why: 'Why two.', surfacePuhe: 'mä', surfaceKirja: 'minä' },
      { id: 3, lemma: 'olla', formName: 'I am', why: 'Why three.', surfacePuhe: 'oon', surfaceKirja: 'olen' },
      {
        id: 4,
        lemma: 'hei',
        formName: 'Greeting',
        why: 'Why four.',
        surfacePuhe: 'hei',
        surfaceKirja: 'hei',
      },
      { id: 5, lemma: 'kiva', formName: 'Nice', why: 'Why five.', surfacePuhe: 'kiva', surfaceKirja: 'kiva' },
      {
        id: 6,
        lemma: 'hauska',
        formName: 'Nice',
        why: 'Why six.',
        surfacePuhe: 'hauska',
        surfaceKirja: 'hauska',
      },
    ],
  }
}

export function sampleDialogue(id: number, unitPosition: number, position: number): ReadableDialogue {
  return {
    id,
    position,
    title: `Dialogue ${String(id)}`,
    unitPosition,
    unitTitle: `Unit at ${String(unitPosition)}`,
    canDo: `Can do of unit ${String(unitPosition)}.`,
  }
}

// Speaking feedback fakes (job 10-speaking-feedback) --------------------------

export interface FakeAttempt extends AttemptRow {
  at: number
}

/** A speech database in memory, with the same consent rules as the migration. */
export interface FakeSpeechDb extends SpeechDb {
  consentRows: (ConsentRow & { noticeVersion: string })[]
  lines: Map<number, SpeechLine>
  attempts: FakeAttempt[]
  /** Every argument every method was called with, as JSON, to look for audio. */
  calls: string[]
  /** The clock used for new attempts. */
  clock: () => number
  /** Kept recordings of the fake store share this list, so withdrawal deletes them. */
  recordings: { id: string; lineId: number; slot: 'first' | 'latest'; createdAt: string; audio: Uint8Array }[]
}

export function fakeSpeechDb(lines: SpeechLine[] = []): FakeSpeechDb {
  const db: FakeSpeechDb = {
    consentRows: [],
    lines: new Map(lines.map((line) => [line.id, line])),
    attempts: [],
    calls: [],
    recordings: [],
    clock: () => Date.now(),
    consents() {
      db.calls.push('consents')
      const newest = (kind: ConsentRow['kind']) => db.consentRows.filter((row) => row.kind === kind).at(-1)
      const processing = newest('voice_processing')
      return Promise.resolve({
        processing: processing ? (processing.granted ? 'granted' : 'withdrawn') : 'not_asked',
        retention: newest('voice_recording_retention')?.granted === true,
      })
    },
    addConsents(rows, noticeVersion) {
      db.calls.push(JSON.stringify(['addConsents', rows, noticeVersion]))
      for (const row of rows) {
        db.consentRows.push({ ...row, noticeVersion })
        // The migration's trigger: withdrawal deletes recordings, and turning
        // speaking feedback off clears transcripts.
        if (!row.granted) db.recordings.length = 0
        if (!row.granted && row.kind === 'voice_processing') {
          for (const attempt of db.attempts) attempt.transcript = ''
        }
      }
      return Promise.resolve()
    },
    line(id) {
      db.calls.push(JSON.stringify(['line', id]))
      return Promise.resolve(db.lines.get(id) ?? null)
    },
    spokenLines(ids) {
      db.calls.push(JSON.stringify(['spokenLines', ids]))
      return Promise.resolve(
        new Map(ids.flatMap((id) => (db.lines.has(id) ? [[id, db.lines.get(id)?.spoken ?? '']] : []))),
      )
    },
    attemptsSince(since) {
      db.calls.push(JSON.stringify(['attemptsSince', since.toISOString()]))
      return Promise.resolve(db.attempts.filter((attempt) => attempt.at >= since.getTime()).length)
    },
    addAttempt(attempt) {
      db.calls.push(JSON.stringify(['addAttempt', attempt]))
      const processing = db.consentRows.filter((row) => row.kind === 'voice_processing').at(-1)
      if (!processing?.granted) return Promise.resolve(false)
      db.attempts.push({ ...attempt, at: db.clock() })
      return Promise.resolve(true)
    },
  }
  return db
}

/** A kept recordings store in memory, sharing the fake database's list and consent rows. */
export function fakeRecordingStore(db: FakeSpeechDb): RecordingStore & { kept: string[] } {
  let next = 0
  const store = {
    kept: [] as string[],
    keep(lineId: number, wavBase64: string) {
      const retention = db.consentRows.filter((row) => row.kind === 'voice_recording_retention').at(-1)
      if (!retention?.granted) return Promise.resolve(false)
      store.kept.push(wavBase64)
      const audio = Uint8Array.from(atob(wavBase64), (c) => c.charCodeAt(0))
      const first = db.recordings.find((row) => row.lineId === lineId && row.slot === 'first')
      const slot = first ? 'latest' : 'first'
      const at = db.recordings.findIndex((row) => row.lineId === lineId && row.slot === slot)
      if (at >= 0) db.recordings.splice(at, 1)
      next += 1
      db.recordings.push({
        id: `00000000-0000-4000-8000-${String(next).padStart(12, '0')}`,
        lineId,
        slot,
        createdAt: new Date(Date.UTC(2026, 9, 22, 10, 0, next)).toISOString(),
        audio,
      })
      return Promise.resolve(true)
    },
    list() {
      return Promise.resolve(
        [...db.recordings]
          .sort((a, b) => b.createdAt.localeCompare(a.createdAt))
          .map(({ id, lineId, slot, createdAt }) => ({ id, lineId, slot, createdAt })),
      )
    },
    read(id: string) {
      return Promise.resolve(db.recordings.find((row) => row.id === id)?.audio ?? null)
    },
    remove(id: string) {
      const at = db.recordings.findIndex((row) => row.id === id)
      if (at >= 0) db.recordings.splice(at, 1)
      return Promise.resolve()
    },
    removeAll() {
      db.recordings.length = 0
      return Promise.resolve()
    },
  }
  return store
}

/** A speech provider that answers from a queue and counts its calls. */
export function countingProvider(
  answer: () => Promise<HeardAnswer> = () => Promise.resolve({ status: 'heard', heard: 'moi mä oon alex' }),
): SpeechProvider & { calls: { bytes: number; reference: string; fixture: string | null }[] } {
  const provider = {
    name: 'fake' as const,
    regionName: 'Italy',
    calls: [] as { bytes: number; reference: string; fixture: string | null }[],
    costUsd: (ms: number) => Math.round((ms / 3_600_000) * 1e8) / 1e8,
    check(wav: Uint8Array, reference: string, fixture: string | null) {
      provider.calls.push({ bytes: wav.length, reference, fixture })
      return answer()
    },
  }
  return provider
}
