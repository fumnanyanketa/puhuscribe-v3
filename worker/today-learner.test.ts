import { describe, expect, it } from 'vitest'
import { accountFake, type AccountFake } from './account-fakes.ts'
import { handleApi, type ApiDeps } from './api.ts'
import { finishedAStop, roadStop } from './road.ts'
import {
  ENV,
  cookieHeader,
  fakeDb,
  fakeSupabase,
  get,
  post,
  roadRow,
  sampleContent,
  sampleDialogue,
  type FakeDb,
} from './test-fakes.ts'

// Fast routes intro-rule and intro-stop (owner's rules of 4 November 2026). [intro-stop 2]: the signed
// in answer of GET /api/today says whether the learner is a guest or an email account (from Supabase
// Auth, with the learner's own token) and whether they have finished a whole stop, by the road's own
// rule (public.road() with their own token: lessons done reach the stop's lessons).

const EMAIL = 'learner-intro@example.com'

function oneUnit(): FakeDb {
  return fakeDb(
    [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2)],
    new Map([
      [1, sampleContent()],
      [2, sampleContent()],
    ]),
  )
}

/** The road with stop 1 at `done` of its 4 lessons and stop 2 untouched. */
function roadAt(db: FakeDb, done: number): FakeDb {
  db.roadRows = [roadRow(1, done), roadRow(2, 0)]
  return db
}

function finishedSession(db: FakeDb): void {
  db.sessions.push({
    id: 's-1',
    dialogueId: 1,
    step: 'understand',
    startedAt: '2026-11-04T09:00:00Z',
    endedAt: '2026-11-04T09:10:00Z',
  })
}

async function guest(db: FakeDb): Promise<{ cookie: string; deps: ApiDeps }> {
  const supabase = fakeSupabase()
  const deps: ApiDeps = { fetch: supabase.fetch, learnerDb: () => db }
  const res = await handleApi(post('/api/guest'), ENV, deps)
  expect(res.status).toBe(201)
  return { cookie: cookieHeader(res), deps }
}

/** Signs a device in to an email account through the routes, as account.test.ts does. */
async function signIn(fake: AccountFake, deps: ApiDeps): Promise<string> {
  fake.addEmailAccount(EMAIL)
  const sent = await handleApi(post('/api/sign-in', { body: JSON.stringify({ email: EMAIL }) }), ENV, deps)
  expect(sent.status).toBe(200)
  const code = fake.mail.filter((m) => m.to === EMAIL).at(-1)?.code ?? ''
  const res = await handleApi(
    post('/api/sign-in/verify', { body: JSON.stringify({ email: EMAIL, code }) }),
    ENV,
    deps,
  )
  expect(res.status).toBe(200)
  return cookieHeader(res)
}

async function emailLearner(db: FakeDb): Promise<{ cookie: string; deps: ApiDeps }> {
  const fake = accountFake()
  const deps: ApiDeps = { fetch: fake.fetch, learnerDb: () => db }
  return { cookie: await signIn(fake, deps), deps }
}

async function front(cookie: string, deps: ApiDeps) {
  const res = await handleApi(get('/api/today', cookie), ENV, deps)
  expect(res.status).toBe(200)
  return res.json<Record<string, unknown>>()
}

const stops = (...rows: Record<string, unknown>[]) => rows.map(roadStop)

describe('a finished stop', () => {
  it('[intro-stop 2] is a stop whose lessons done reach its lessons, as the road decides', () => {
    expect(finishedAStop([])).toBe(false)
    expect(finishedAStop(stops(roadRow(1, 0), roadRow(2, 0)))).toBe(false)
    expect(finishedAStop(stops(roadRow(1, 1), roadRow(2, 0)))).toBe(false)
    expect(finishedAStop(stops(roadRow(1, 3), roadRow(2, 0)))).toBe(false)
    expect(finishedAStop(stops(roadRow(1, 4), roadRow(2, 0)))).toBe(true)
    expect(finishedAStop(stops(roadRow(1, 4), roadRow(2, 2)))).toBe(true)
  })

  it('[intro-stop 2] a stop with no lessons counts as nothing finished', () => {
    expect(finishedAStop(stops(roadRow(1, 0, 0)))).toBe(false)
  })
})

describe('GET /api/today, signed in', () => {
  it('[intro-stop 2] a guest with nothing done: account guest, finishedStop false', async () => {
    const { cookie, deps } = await guest(roadAt(oneUnit(), 0))
    expect(await front(cookie, deps)).toEqual({
      signedIn: true,
      today: 'start',
      canDo: 'Can do of unit 10.',
      account: 'guest',
      finishedStop: false,
    })
  })

  it('[intro-stop 2] a guest who finished stop 1 stays a guest, with finishedStop true', async () => {
    const { cookie, deps } = await guest(roadAt(oneUnit(), 4))
    expect(await front(cookie, deps)).toMatchObject({ signedIn: true, account: 'guest', finishedStop: true })
  })

  it('[intro-stop 2] an email account with one lesson done but the stop not finished: finishedStop false', async () => {
    const db = roadAt(oneUnit(), 1)
    finishedSession(db)
    const { cookie, deps } = await emailLearner(db)
    expect(await front(cookie, deps)).toEqual({
      signedIn: true,
      today: 'start',
      canDo: 'Can do of unit 10.',
      account: 'email',
      finishedStop: false,
    })
  })

  it('[intro-stop 2] an email account with three of four lessons done: finishedStop false', async () => {
    const { cookie, deps } = await emailLearner(roadAt(oneUnit(), 3))
    expect(await front(cookie, deps)).toMatchObject({ account: 'email', finishedStop: false })
  })

  it('[intro-stop 2] an email account that finished stop 1: account email, finishedStop true', async () => {
    const { cookie, deps } = await emailLearner(roadAt(oneUnit(), 4))
    expect(await front(cookie, deps)).toMatchObject({ signedIn: true, account: 'email', finishedStop: true })
  })

  it('[intro-stop 2] both facts come with the all done and not ready states too (review: worker/review.test.ts)', async () => {
    const done = roadAt(fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, sampleContent()]])), 4)
    finishedSession(done)
    const one = await emailLearner(done)
    expect(await front(one.cookie, one.deps)).toEqual({
      signedIn: true,
      today: 'all_done',
      account: 'email',
      finishedStop: true,
    })
    const two = await guest(fakeDb())
    expect(await front(two.cookie, two.deps)).toEqual({
      signedIn: true,
      today: 'not_ready',
      account: 'guest',
      finishedStop: false,
    })
  })

  it('[intro-stop 2] a road row of the wrong shape is a fault, never a guess', async () => {
    const db = oneUnit()
    db.roadRows = [{ ...roadRow(1, 4), lessons_done: 'four' }]
    const { cookie, deps } = await emailLearner(db)
    const res = await handleApi(get('/api/today', cookie), ENV, deps)
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'not_available' })
  })

  it('[intro-stop 2] with Supabase as the learner, road() is asked with this device token and no user id from the request', async () => {
    // No fake learner database: the reads go to the fake Supabase, as in production.
    const fake = accountFake()
    const deps: ApiDeps = { fetch: fake.fetch }
    const cookie = await signIn(fake, deps)
    fake.requests.length = 0
    await handleApi(get('/api/today?user=someone-else&finishedStop=true', cookie), ENV, deps)
    const road = fake.requests.find((r) => r.url.pathname === '/rest/v1/rpc/road')
    expect(road).toBeDefined()
    expect(road?.headers.get('authorization')).toMatch(/^Bearer /)
    expect(road?.body ?? '').not.toContain('someone-else')
    expect(road?.url.search ?? '').toBe('')
  })
})
