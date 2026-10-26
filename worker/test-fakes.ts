// Test helpers for the Worker's unit tests (not a test file itself).
// A fake Supabase that answers the Auth calls the Worker makes through
// @supabase/ssr, and records every request, plus a fake learner database.
// Nothing here is used by the app.

import type { NextReview } from '../src/lib/review-types.ts'
import type { RecordableStep } from '../src/lib/session-types.ts'
import type { ApiEnv } from './api.ts'
import type { Fetch } from './learner-auth.ts'
import type {
  CardRow,
  CompleteResult,
  DialogueContent,
  FormRow,
  LearnerDb,
  QueueCard,
  ReadableDialogue,
  RecordReviewArgs,
  ReviewDb,
  SessionRow,
  TokenRow,
} from './learner-db.ts'
import type { ReviewLineRow } from './review-plan.ts'

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
export interface FakeDb extends LearnerDb, ReviewDb {
  dialogues: ReadableDialogue[]
  sessions: SessionRow[]
  content: Map<number, DialogueContent>
  completed: string[]
  failNext: boolean
  // The Keep it step (job 9-daily-review). Empty unless a test fills them.
  /** What public.review_queue returns, in order. */
  queue: QueueCard[]
  /** The learner's cards. */
  cards: CardRow[]
  /** What public.next_review_day gives. */
  next: NextReview | null
  /** Every public.record_review call that saved. */
  recorded: RecordReviewArgs[]
  /** Every finishKeep call, as [session id, end time]. */
  kept: [string, string | null][]
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
    queue: [],
    cards: [],
    next: null,
    recorded: [],
    kept: [],
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
      // As public.complete_session: at least Understand it (Keep it comes later, job 9).
      if (row.dialogueId === null || row.step === null || row.step === 'hear')
        return Promise.resolve('not_ready')
      row.endedAt ??= new Date().toISOString()
      db.completed.push(id)
      return Promise.resolve('saved')
    },
    reviewQueue: (limit) => Promise.resolve(db.queue.slice(0, Math.max(0, Math.min(limit, 15)))),
    nextReviewDay: () => Promise.resolve(db.next),
    // As the database does it: the approved lines of the given dialogues that
    // link to the forms, every word of those lines, and their readable forms.
    reviewMaterial: (formIds, dialogueIds) => {
      const lines: ReviewLineRow[] = []
      const tokens: TokenRow[] = []
      const forms = new Map<number, FormRow>()
      for (const [dialogueId, content] of db.content) {
        if (!dialogueIds.includes(dialogueId)) continue
        for (const line of content.lines) {
          const own = content.tokens.filter((t) => t.lineId === line.id)
          if (!own.some((t) => t.formId !== null && formIds.includes(t.formId))) continue
          lines.push({ ...line, dialogueId })
          tokens.push(...own)
          for (const t of own) {
            const form = content.forms.find((f) => f.id === t.formId)
            if (form) forms.set(form.id, form)
          }
        }
      }
      return Promise.resolve({ lines, tokens, forms: [...forms.values()] })
    },
    card: (formId) => {
      const row = db.cards.find((c) => c.formId === formId)
      return Promise.resolve(row ? { ...row } : null)
    },
    recordReview: (args) => {
      if (db.failNext) {
        db.failNext = false
        return Promise.reject(new Error('down'))
      }
      const row = db.cards.find((c) => c.formId === args.p_form_id && c.reps === args.p_expected_reps)
      if (!row) return Promise.resolve(false)
      Object.assign(row, {
        due: args.p_due,
        stability: args.p_stability,
        difficulty: args.p_difficulty,
        elapsedDays: args.p_elapsed_days,
        scheduledDays: args.p_scheduled_days,
        reps: args.p_reps,
        lapses: args.p_lapses,
        state: args.p_state,
        lastReview: args.p_last_review,
      })
      db.recorded.push(args)
      return Promise.resolve(true)
    },
    startReviewSession: () => {
      started += 1
      const row: SessionRow = {
        id: `00000000-0000-4000-8000-${String(started).padStart(12, '0')}`,
        dialogueId: null,
        step: null,
        startedAt: new Date(Date.UTC(2026, 9, 21, 12, 0, started)).toISOString(),
        endedAt: null,
      }
      db.sessions.push(row)
      return Promise.resolve({ ...row })
    },
    finishKeep: (id, endedAt) => {
      const row = db.sessions.find((s) => s.id === id && s.endedAt === null)
      if (!row) return Promise.resolve(false)
      row.step = 'keep'
      if (endedAt !== null) row.endedAt = endedAt
      db.kept.push([id, endedAt])
      return Promise.resolve(true)
    },
  }
  return db
}

/** A new card with the database's default values (createEmptyCard), for a form. */
export function newCard(formId: number, due = '2026-10-21T09:00:00+00:00'): CardRow {
  return {
    formId,
    due,
    stability: 0,
    difficulty: 0,
    elapsedDays: 0,
    scheduledDays: 0,
    reps: 0,
    lapses: 0,
    state: 'new',
    lastReview: null,
  }
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
