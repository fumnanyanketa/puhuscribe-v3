import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { FSRS } from '../src/lib/fsrs/scheduler.ts'
import { Rating } from '../src/lib/fsrs/types.ts'
import type { ReviewFeedback, ReviewItemsAnswer } from '../src/lib/review-types.ts'
import type { ReadySession, ReviewSession } from '../src/lib/session-types.ts'
import { handleApi, type ApiDeps } from './api.ts'
import { toCard } from './review-schedule.ts'
import {
  ENV,
  cookieHeader,
  fakeDb,
  fakeSupabase,
  get,
  newCard,
  post,
  sampleContent,
  sampleDialogue,
  type FakeDb,
  type FakeSupabase,
} from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/9-daily-review/spec.md that each test protects.
// The Keep it routes, with a fake Supabase Auth and a fake learner database.
//
// The sample dialogue (worker/test-fakes.ts): line 11 "Moi! Mä oon Alex." /
// "Hei! Minä olen Alex." and line 12 "Kiva tavata!" / "Hauska tavata!".
// Forms: 1 moi, 2 minä (mä / minä), 3 olla (oon / olen), 4 hei (written only),
// 5 kiva, 6 hauska. Form 99 is a draft: the database does not return it.

const MINÄ = 2
const OLLA = 3
const HEI = 4
const DRAFT = 99
const UNMET = 77
const DUE = '2026-10-21T09:00:00+00:00'

interface Learner {
  db: FakeDb
  supabase: FakeSupabase
  cookie: string
  deps: ApiDeps
}

/** A learner who finished dialogue 1 yesterday, with cards for the given forms in the queue. */
async function learner(
  queue: number[] = [MINÄ, OLLA],
  dialogues = [sampleDialogue(1, 10, 1)],
): Promise<Learner> {
  const db = fakeDb(dialogues, new Map([[1, sampleContent()]]))
  db.sessions.push({
    id: '00000000-0000-4000-8000-0000000000d1',
    dialogueId: 1,
    step: 'understand',
    startedAt: '2026-10-21T08:00:00Z',
    endedAt: '2026-10-21T08:10:00Z',
  })
  db.queue = queue.map((formId) => ({ formId, reps: 0, due: DUE }))
  db.cards = queue.map((formId) => newCard(formId, DUE))
  const supabase = fakeSupabase()
  const deps: ApiDeps = { fetch: supabase.fetch, learnerDb: () => db }
  const res = await handleApi(post('/api/guest'), ENV, deps)
  return { db, supabase, cookie: cookieHeader(res), deps }
}

async function body<T>(res: Response): Promise<T> {
  return res.json<T>()
}

/** Starts today's session: a review only one, since dialogue 1 is the only one and it is finished. */
async function reviewOnly(l: Learner): Promise<string> {
  const res = await handleApi(post('/api/sessions/today', { cookie: l.cookie }), ENV, l.deps)
  const answer = await body<ReviewSession>(res)
  expect(answer.state).toBe('review')
  return answer.session.id
}

function answerBody(sessionId: string, formId: number, text: string, extra: Record<string, unknown> = {}) {
  return JSON.stringify({ sessionId, formId, text, kind: 'typed', ...extra })
}

function answerPost(l: Learner, sessionBody: string, origin?: string) {
  return post('/api/review/answer', { cookie: l.cookie, body: sessionBody, origin })
}

describe('which cards come up', () => {
  it('[review 3] [review 8] the items are the queue, in order, each in a line the learner met', async () => {
    const l = await learner([OLLA, MINÄ, HEI])
    const id = await reviewOnly(l)
    const res = await handleApi(get(`/api/sessions/${id}/review`, l.cookie), ENV, l.deps)
    expect(res.status).toBe(200)
    const { items } = await body<ReviewItemsAnswer>(res)
    expect(items.map((item) => [item.formId, item.register])).toEqual([
      [OLLA, 'spoken'],
      [MINÄ, 'spoken'],
      [HEI, 'written'],
    ])
    expect(items[0]).toEqual({
      formId: OLLA,
      speaker: 'Speaker A',
      gloss: 'Hi! I am Alex.',
      register: 'spoken',
      audio: '/audio/unit-test/1-puhe.mp3',
      words: [{ text: 'Moi', after: '!' }, { text: 'Mä' }, { gap: true }, { text: 'Alex', after: '.' }],
    })
  })

  it('[review 3] a card with no line the learner met, or whose form is not readable, is skipped: not shown, not graded, not changed', async () => {
    const l = await learner([UNMET, DRAFT, MINÄ])
    const id = await reviewOnly(l)
    const { items } = await body<ReviewItemsAnswer>(
      await handleApi(get(`/api/sessions/${id}/review`, l.cookie), ENV, l.deps),
    )
    expect(items.map((item) => item.formId)).toEqual([MINÄ])
    for (const formId of [UNMET, DRAFT]) {
      const res = await handleApi(answerPost(l, answerBody(id, formId, 'mä')), ENV, l.deps)
      expect(res.status, String(formId)).toBe(404)
    }
    expect(l.db.recorded).toEqual([])
    expect(l.db.cards.find((c) => c.formId === UNMET)).toEqual(newCard(UNMET, DUE))
  })

  it('[review 3] lines of a dialogue the learner only heard are not used', async () => {
    const l = await learner([MINÄ])
    const finished = l.db.sessions[0]
    if (finished) finished.step = 'hear'
    // With nothing met, nothing is reviewable, so no review only session starts.
    const res = await handleApi(post('/api/sessions/today', { cookie: l.cookie }), ENV, l.deps)
    expect(await body<{ state: string }>(res)).toEqual({ state: 'all_done' })
    expect(l.db.sessions).toHaveLength(1)
  })

  it('[review 8] [review 17] the items hold no answer and no draft content', async () => {
    const l = await learner([MINÄ, OLLA, 5])
    const id = await reviewOnly(l)
    const text = await (await handleApi(get(`/api/sessions/${id}/review`, l.cookie), ENV, l.deps)).text()
    const { items } = JSON.parse(text) as ReviewItemsAnswer
    expect(items.map((item) => item.formId)).toEqual([MINÄ, OLLA, 5])
    // Each item: not its own form's shapes, in any case; never the written line.
    const shapes: Record<number, string[]> = { [MINÄ]: ['mä', 'minä'], [OLLA]: ['oon', 'olen'], 5: ['kiva'] }
    for (const item of items) {
      const own = JSON.stringify(item).toLowerCase()
      for (const shape of shapes[item.formId] ?? [])
        expect(own, String(item.formId)).not.toContain(`"${shape}"`)
    }
    for (const hidden of ['Hei', 'Minä olen', 'olen', 'Hauska']) expect(text).not.toContain(hidden)
    expect(text).not.toMatch(/lemma|formName|"why"|surface|reps|stability|due/)
    // The draft form 99 (tavata) is plain text in its line and never a form.
    expect(text).not.toMatch(/"formId":99/)
  })
})

describe('GET /api/sessions/<id>/review', () => {
  it('[review 16] answers 401 without a sign in', async () => {
    const l = await learner()
    const id = await reviewOnly(l)
    const res = await handleApi(get(`/api/sessions/${id}/review`), ENV, l.deps)
    expect(res.status).toBe(401)
  })

  it("[review 16] answers 404 for a session that is not the learner's", async () => {
    const l = await learner()
    const res = await handleApi(
      get('/api/sessions/00000000-0000-4000-8000-0000000000ff/review', l.cookie),
      ENV,
      l.deps,
    )
    expect(res.status).toBe(404)
  })

  it('[review 16] changes nothing and refuses POST', async () => {
    const l = await learner()
    const id = await reviewOnly(l)
    const res = await handleApi(post(`/api/sessions/${id}/review`, { cookie: l.cookie }), ENV, l.deps)
    expect(res.status).toBe(405)
    expect(res.headers.get('allow')).toBe('GET')
  })

  it('[review 6] a new dialogue session learns as it loads whether it ends with Keep it, and changes nothing', async () => {
    const l = await learner([MINÄ], [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2)])
    l.db.content.set(2, sampleContent())
    const ready = await body<ReadySession>(
      await handleApi(post('/api/sessions/today', { cookie: l.cookie }), ENV, l.deps),
    )
    expect(ready.state).toBe('ready')
    const res = await handleApi(get(`/api/sessions/${ready.session.id}/review`, l.cookie), ENV, l.deps)
    expect(res.status).toBe(200)
    expect((await body<ReviewItemsAnswer>(res)).items.map((item) => item.formId)).toEqual([MINÄ])
    expect(l.db.recorded).toEqual([])
    expect(l.db.sessions.find((s) => s.id === ready.session.id)?.step).toBeNull()
    // With nothing reviewable, no items: the session is Hear it and Understand it, as in job 8.
    l.db.queue = []
    const none = await handleApi(get(`/api/sessions/${ready.session.id}/review`, l.cookie), ENV, l.deps)
    expect(await body<ReviewItemsAnswer>(none)).toEqual({ items: [] })
  })

  it('[review 7] a finished session has no items', async () => {
    const l = await learner([MINÄ])
    const res = await handleApi(
      get('/api/sessions/00000000-0000-4000-8000-0000000000d1/review', l.cookie),
      ENV,
      l.deps,
    )
    expect(res.status).toBe(409)
  })
})

describe('POST /api/review/answer', () => {
  it('[review 10] [review 11] grades with v2, schedules with v2 and saves once through record_review', async () => {
    const l = await learner([MINÄ])
    const id = await reviewOnly(l)
    const before = { ...newCard(MINÄ, DUE) }
    const startedAt = Date.now()
    const res = await handleApi(answerPost(l, answerBody(id, MINÄ, 'minä')), ENV, l.deps)
    expect(res.status).toBe(200)
    const feedback = await body<ReviewFeedback>(res)
    expect(feedback.result).toBe('correct')
    expect(feedback.form).toEqual({ spoken: 'mä', written: 'minä' })
    expect(feedback.marked).toEqual({ spoken: [1], written: [1] })
    expect(feedback.line.written.map((w) => w.text)).toEqual(['Hei', 'Minä', 'olen', 'Alex'])
    expect(l.db.recorded).toHaveLength(1)
    const saved = l.db.recorded[0]
    expect(saved?.p_rating).toBe(Rating.Good)
    expect(saved?.p_mode).toBe('typed')
    expect(saved?.p_expected_reps).toBe(0)
    // The same engine, at the stored review time, gives exactly the stored values.
    const at = new Date(saved?.p_review_time ?? '')
    expect(at.getTime()).toBeGreaterThanOrEqual(startedAt - 1)
    const { card, log } = new FSRS().schedule(toCard(before), Rating.Good, at)
    expect(saved).toMatchObject({
      p_due: card.due.toISOString(),
      p_stability: card.stability,
      p_difficulty: card.difficulty,
      p_reps: card.reps,
      p_lapses: card.lapses,
      p_state: 'learning',
      p_last_review: at.toISOString(),
      p_log_state: 'new',
      p_log_due: log.due.toISOString(),
      p_log_elapsed_days: log.elapsed_days,
      p_log_scheduled_days: log.scheduled_days,
    })
  })

  it('[review 10] close gives Hard, wrong and empty give Again', async () => {
    const l = await learner([MINÄ, OLLA, HEI])
    const id = await reviewOnly(l)
    const results: string[] = []
    for (const [formId, text] of [
      [MINÄ, 'mina'],
      [OLLA, 'kiva'],
      [HEI, ''],
    ] as const) {
      const res = await handleApi(answerPost(l, answerBody(id, formId, text)), ENV, l.deps)
      results.push((await body<ReviewFeedback>(res)).result)
    }
    expect(results).toEqual(['close', 'wrong', 'wrong'])
    expect(l.db.recorded.map((r) => r.p_rating)).toEqual([Rating.Hard, Rating.Again, Rating.Again])
  })

  it('[review 10] the request carries no rating, card value or user id: any other field, long text or another kind answers 400', async () => {
    const l = await learner([MINÄ])
    const id = await reviewOnly(l)
    const bad = [
      answerBody(id, MINÄ, 'minä', { rating: 4 }),
      answerBody(id, MINÄ, 'minä', { userId: '00000000-0000-4000-8000-0000000000aa' }),
      answerBody(id, MINÄ, 'minä', { reps: 0 }),
      answerBody(id, MINÄ, 'minä', { due: DUE }),
      answerBody(id, MINÄ, 'a'.repeat(101)),
      JSON.stringify({ sessionId: id, formId: MINÄ, text: 'minä', kind: 'spoken' }),
      JSON.stringify({ sessionId: id, formId: MINÄ, kind: 'typed' }),
      JSON.stringify({ sessionId: id, formId: String(MINÄ), text: 'minä', kind: 'typed' }),
      JSON.stringify({ sessionId: 'not-a-session', formId: MINÄ, text: 'minä', kind: 'typed' }),
      JSON.stringify([id, MINÄ, 'minä', 'typed']),
      'not json',
    ]
    for (const request of bad) {
      const res = await handleApi(answerPost(l, request), ENV, l.deps)
      expect(res.status, request).toBe(400)
    }
    expect(l.db.recorded).toEqual([])
    const ok = await handleApi(answerPost(l, answerBody(id, MINÄ, 'a'.repeat(100))), ENV, l.deps)
    expect(ok.status).toBe(200)
  })

  it('[review 11] a card that changed since it was read answers 409 and writes nothing', async () => {
    const l = await learner([MINÄ])
    const id = await reviewOnly(l)
    const stored = l.db.cards[0]
    l.db.card = () => Promise.resolve(stored ? { ...stored, reps: 5 } : null)
    const res = await handleApi(answerPost(l, answerBody(id, MINÄ, 'minä')), ENV, l.deps)
    expect(res.status).toBe(409)
    expect(await body<unknown>(res)).toEqual({ error: 'card_changed' })
    expect(l.db.recorded).toEqual([])
    expect(l.db.cards[0]).toEqual(newCard(MINÄ, DUE))
  })

  it('[review 16] answers 401 without a sign in, and saves nothing', async () => {
    const l = await learner([MINÄ])
    const id = await reviewOnly(l)
    const res = await handleApi(
      post('/api/review/answer', { body: answerBody(id, MINÄ, 'minä') }),
      ENV,
      l.deps,
    )
    expect(res.status).toBe(401)
    expect(l.db.recorded).toEqual([])
  })

  it("[review 16] answers 404 for a session that is not the learner's, and saves nothing", async () => {
    const l = await learner([MINÄ])
    await reviewOnly(l)
    const res = await handleApi(
      answerPost(l, answerBody('00000000-0000-4000-8000-0000000000ff', MINÄ, 'minä')),
      ENV,
      l.deps,
    )
    expect(res.status).toBe(404)
    expect(l.db.recorded).toEqual([])
  })

  it('[review 16] accepts only POST with JSON from this site', async () => {
    const l = await learner([MINÄ])
    const id = await reviewOnly(l)
    const fromElsewhere = await handleApi(
      answerPost(l, answerBody(id, MINÄ, 'minä'), 'https://evil.example'),
      ENV,
      l.deps,
    )
    expect(fromElsewhere.status).toBe(403)
    const form = await handleApi(
      post('/api/review/answer', {
        cookie: l.cookie,
        body: answerBody(id, MINÄ, 'minä'),
        contentType: 'text/plain',
      }),
      ENV,
      l.deps,
    )
    expect(form.status).toBe(415)
    const viaGet = await handleApi(get('/api/review/answer', l.cookie), ENV, l.deps)
    expect(viaGet.status).toBe(405)
    expect(l.db.recorded).toEqual([])
    for (const res of [fromElsewhere, form, viaGet])
      expect(res.headers.get('access-control-allow-origin')).toBeNull()
  })

  it('[review 16] never sends a user id to the database: the update is found by form, as the learner', async () => {
    const l = await learner([MINÄ])
    const id = await reviewOnly(l)
    await handleApi(answerPost(l, answerBody(id, MINÄ, 'minä')), ENV, l.deps)
    const sent = JSON.stringify(l.db.recorded)
    for (const userId of l.supabase.userIds) expect(sent).not.toContain(userId)
    expect(Object.keys(l.db.recorded[0] ?? {}).some((key) => /user/i.test(key))).toBe(false)
  })

  it('[review 6] a dialogue session before Understand it cannot be answered in', async () => {
    const l = await learner([MINÄ], [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2)])
    l.db.content.set(2, sampleContent())
    const ready = await body<ReadySession>(
      await handleApi(post('/api/sessions/today', { cookie: l.cookie }), ENV, l.deps),
    )
    const res = await handleApi(answerPost(l, answerBody(ready.session.id, MINÄ, 'minä')), ENV, l.deps)
    expect(res.status).toBe(409)
    expect(l.db.recorded).toEqual([])
  })
})

describe('POST /api/sessions/<id>/review/done', () => {
  it('[review 7] a review only session gets step keep and its end time, and no complete_session', async () => {
    const l = await learner([MINÄ])
    const id = await reviewOnly(l)
    const res = await handleApi(post(`/api/sessions/${id}/review/done`, { cookie: l.cookie }), ENV, l.deps)
    expect(res.status).toBe(200)
    expect(await body<unknown>(res)).toEqual({ step: 'keep', ended: true })
    const row = l.db.sessions.find((s) => s.id === id)
    expect(row?.step).toBe('keep')
    expect(row?.endedAt).not.toBeNull()
    expect(Date.parse(row?.endedAt ?? '')).toBeGreaterThan(Date.parse(row?.startedAt ?? ''))
    expect(l.db.completed).toEqual([])
    const again = await handleApi(post(`/api/sessions/${id}/review/done`, { cookie: l.cookie }), ENV, l.deps)
    expect(again.status).toBe(200)
    expect(l.db.kept).toHaveLength(1)
  })

  it('[review 6] a dialogue session at Understand it gets step keep and stays open for complete_session', async () => {
    const l = await learner([MINÄ], [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2)])
    l.db.content.set(2, sampleContent())
    const ready = await body<ReadySession>(
      await handleApi(post('/api/sessions/today', { cookie: l.cookie }), ENV, l.deps),
    )
    const id = ready.session.id
    const early = await handleApi(post(`/api/sessions/${id}/review/done`, { cookie: l.cookie }), ENV, l.deps)
    expect(early.status).toBe(409)
    for (const step of ['hear', 'understand']) {
      await handleApi(
        post(`/api/sessions/${id}/step`, { cookie: l.cookie, body: JSON.stringify({ step }) }),
        ENV,
        l.deps,
      )
    }
    const done = await handleApi(post(`/api/sessions/${id}/review/done`, { cookie: l.cookie }), ENV, l.deps)
    expect(await body<unknown>(done)).toEqual({ step: 'keep', ended: false })
    const row = l.db.sessions.find((s) => s.id === id)
    expect(row?.step).toBe('keep')
    expect(row?.endedAt).toBeNull()
    const complete = await handleApi(post(`/api/sessions/${id}/complete`, { cookie: l.cookie }), ENV, l.deps)
    expect(complete.status).toBe(200)
    expect(l.db.completed).toEqual([id])
  })

  it("[review 16] answers 401 without a sign in, 404 for a session that is not the learner's, 403 from another site", async () => {
    const l = await learner([MINÄ])
    const id = await reviewOnly(l)
    expect((await handleApi(post(`/api/sessions/${id}/review/done`), ENV, l.deps)).status).toBe(401)
    expect(
      (
        await handleApi(
          post('/api/sessions/00000000-0000-4000-8000-0000000000ff/review/done', { cookie: l.cookie }),
          ENV,
          l.deps,
        )
      ).status,
    ).toBe(404)
    expect(
      (
        await handleApi(
          post(`/api/sessions/${id}/review/done`, { cookie: l.cookie, origin: 'https://evil.example' }),
          ENV,
          l.deps,
        )
      ).status,
    ).toBe(403)
    expect((await handleApi(get(`/api/sessions/${id}/review/done`, l.cookie), ENV, l.deps)).status).toBe(405)
    expect(l.db.kept).toEqual([])
  })
})

describe("the front door and today's session", () => {
  it('[review 4] a new dialogue with cards reviewable: start, with review', async () => {
    const l = await learner([MINÄ], [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2)])
    l.db.content.set(2, sampleContent())
    const res = await handleApi(get('/api/today', l.cookie), ENV, l.deps)
    expect(await body<unknown>(res)).toEqual({
      signedIn: true,
      today: 'start',
      canDo: 'Can do of unit 10.',
      review: true,
    })
  })

  it("[review 4] a new dialogue with nothing reviewable: job 8's answer, no review", async () => {
    const l = await learner([], [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2)])
    l.db.content.set(2, sampleContent())
    const res = await handleApi(get('/api/today', l.cookie), ENV, l.deps)
    expect(await body<unknown>(res)).toEqual({ signedIn: true, today: 'start', canDo: 'Can do of unit 10.' })
  })

  it('[review 4] [review 7] no new dialogue but cards reviewable: review, then continue for the unfinished review session', async () => {
    const l = await learner([MINÄ])
    expect(await body<unknown>(await handleApi(get('/api/today', l.cookie), ENV, l.deps))).toEqual({
      signedIn: true,
      today: 'review',
    })
    const id = await reviewOnly(l)
    expect(l.db.sessions.filter((s) => s.dialogueId === null)).toHaveLength(1)
    expect(await body<unknown>(await handleApi(get('/api/today', l.cookie), ENV, l.deps))).toEqual({
      signedIn: true,
      today: 'continue',
    })
    // Start again reuses the unfinished review only session.
    expect(await reviewOnly(l)).toBe(id)
    expect(l.db.sessions.filter((s) => s.dialogueId === null)).toHaveLength(1)
  })

  it('[review 5] nothing new and nothing reviewable: all done, with the next review day from the database', async () => {
    const l = await learner([])
    l.db.next = { today: '2026-10-22', day: '2026-10-24' }
    expect(await body<unknown>(await handleApi(get('/api/today', l.cookie), ENV, l.deps))).toEqual({
      signedIn: true,
      today: 'all_done',
      nextReview: { today: '2026-10-22', day: '2026-10-24' },
    })
    const res = await handleApi(post('/api/sessions/today', { cookie: l.cookie }), ENV, l.deps)
    expect(await body<unknown>(res)).toEqual({ state: 'all_done' })
    expect(l.db.sessions).toHaveLength(1)
  })

  it("[review 6] today's dialogue session is answered exactly as in job 8, with or without cards", async () => {
    const withCards = await learner([MINÄ], [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2)])
    withCards.db.content.set(2, sampleContent())
    const ready = await body<Record<string, unknown>>(
      await handleApi(post('/api/sessions/today', { cookie: withCards.cookie }), ENV, withCards.deps),
    )
    const without = await learner([], [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2)])
    without.db.content.set(2, sampleContent())
    const plain = await body<Record<string, unknown>>(
      await handleApi(post('/api/sessions/today', { cookie: without.cookie }), ENV, without.deps),
    )
    expect(Object.keys(ready).sort()).toEqual(['dialogue', 'lines', 'session', 'state', 'unit'])
    expect({ ...ready, session: null }).toEqual({ ...plain, session: null })
  })
})

describe('the Worker log during review', () => {
  const METHODS = ['log', 'info', 'warn', 'error', 'debug', 'trace'] as const
  let written: string[] = []

  beforeEach(() => {
    written = []
    for (const method of METHODS) {
      vi.spyOn(console, method).mockImplementation((...args: unknown[]) => {
        written.push(args.map((arg) => (typeof arg === 'string' ? arg : JSON.stringify(arg))).join(' '))
      })
    }
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('[review 17] holds no typed answer, cookie, token or user id after a whole review and its faults', async () => {
    const l = await learner([MINÄ, OLLA])
    await handleApi(get('/api/today', l.cookie), ENV, l.deps)
    const id = await reviewOnly(l)
    await handleApi(get(`/api/sessions/${id}/review`, l.cookie), ENV, l.deps)
    const typed = 'kissanpentuxyz'
    await handleApi(answerPost(l, answerBody(id, MINÄ, typed)), ENV, l.deps)
    l.db.failNext = true
    await handleApi(answerPost(l, answerBody(id, OLLA, `${typed}2`)), ENV, l.deps)
    await handleApi(answerPost(l, answerBody(id, OLLA, `${typed}3`, { rating: 4 })), ENV, l.deps)
    await handleApi(post(`/api/sessions/${id}/review/done`, { cookie: l.cookie }), ENV, l.deps)

    const log = written.join('\n')
    const forbidden = [
      typed,
      ...l.supabase.issued,
      ...l.supabase.userIds,
      ...l.cookie.split('; ').map((part) => part.split('=').slice(1).join('=')),
      id,
    ].filter(Boolean)
    for (const value of forbidden) expect(log).not.toContain(value)
    expect(log).not.toMatch(/cookie|authorization|bearer/i)
  })

  it('[review 17] the typed answer is not kept: nothing saved holds it', async () => {
    const l = await learner([MINÄ])
    const id = await reviewOnly(l)
    const typed = 'kissanpentuxyz'
    const res = await handleApi(answerPost(l, answerBody(id, MINÄ, typed)), ENV, l.deps)
    expect(res.status).toBe(200)
    expect(JSON.stringify(l.db.recorded)).not.toContain(typed)
    expect(JSON.stringify(l.db.cards)).not.toContain(typed)
    expect(JSON.stringify(l.db.sessions)).not.toContain(typed)
  })
})
