import { describe, expect, it } from 'vitest'
import { accountFake, type AccountFake } from './account-fakes.ts'
import { handleApi, type ApiDeps } from './api.ts'
import type { SessionRow } from './learner-db.ts'
import { finishedALesson } from './session-plan.ts'
import {
  ENV,
  cookieHeader,
  fakeDb,
  fakeSupabase,
  get,
  post,
  sampleContent,
  sampleDialogue,
  type FakeDb,
} from './test-fakes.ts'

// Fast route intro-rule (owner's rule of 4 November 2026). [intro-rule 2]: the signed in answer of
// GET /api/today says whether the learner is a guest or an email account (from Supabase Auth, with the
// learner's own token) and whether one of their own lessons has finished (their own sessions).

const EMAIL = 'learner-intro@example.com'

function row(dialogueId: number | null, endedAt: string | null): SessionRow {
  return {
    id: `s-${String(dialogueId)}-${String(endedAt)}`,
    dialogueId,
    step: null,
    startedAt: '2026-11-04T09:00:00Z',
    endedAt,
  }
}

function oneUnit(): FakeDb {
  return fakeDb(
    [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2)],
    new Map([
      [1, sampleContent()],
      [2, sampleContent()],
    ]),
  )
}

async function guest(db: FakeDb): Promise<{ cookie: string; deps: ApiDeps }> {
  const supabase = fakeSupabase()
  const deps: ApiDeps = { fetch: supabase.fetch, learnerDb: () => db }
  const res = await handleApi(post('/api/guest'), ENV, deps)
  expect(res.status).toBe(201)
  return { cookie: cookieHeader(res), deps }
}

/** Signs a device in to an email account through the routes, as account.test.ts does. */
async function emailLearner(db: FakeDb): Promise<{ fake: AccountFake; cookie: string; deps: ApiDeps }> {
  const fake = accountFake()
  fake.addEmailAccount(EMAIL)
  const deps: ApiDeps = { fetch: fake.fetch, learnerDb: () => db }
  const sent = await handleApi(post('/api/sign-in', { body: JSON.stringify({ email: EMAIL }) }), ENV, deps)
  expect(sent.status).toBe(200)
  const code = fake.mail.filter((m) => m.to === EMAIL).at(-1)?.code ?? ''
  const res = await handleApi(
    post('/api/sign-in/verify', { body: JSON.stringify({ email: EMAIL, code }) }),
    ENV,
    deps,
  )
  expect(res.status).toBe(200)
  return { fake, cookie: cookieHeader(res), deps }
}

async function front(cookie: string, deps: ApiDeps) {
  const res = await handleApi(get('/api/today', cookie), ENV, deps)
  expect(res.status).toBe(200)
  return res.json<Record<string, unknown>>()
}

describe('a finished lesson', () => {
  it("[intro-rule 2] is one of the learner's own dialogue sessions with its end time", () => {
    expect(finishedALesson([])).toBe(false)
    expect(finishedALesson([row(1, null)])).toBe(false)
    expect(finishedALesson([row(1, null), row(2, '2026-11-04T10:00:00Z')])).toBe(true)
  })

  it('[intro-rule 2] a finished review only session (no dialogue) does not count', () => {
    expect(finishedALesson([row(null, '2026-11-04T10:00:00Z')])).toBe(false)
    expect(finishedALesson([row(null, '2026-11-04T10:00:00Z'), row(1, null)])).toBe(false)
  })
})

describe('GET /api/today, signed in', () => {
  it('[intro-rule 2] a guest with no finished lesson: account guest, finishedLesson false', async () => {
    const db = oneUnit()
    const { cookie, deps } = await guest(db)
    expect(await front(cookie, deps)).toEqual({
      signedIn: true,
      today: 'start',
      canDo: 'Can do of unit 10.',
      account: 'guest',
      finishedLesson: false,
    })
  })

  it('[intro-rule 2] a guest with a finished lesson stays a guest, with finishedLesson true', async () => {
    const db = oneUnit()
    db.sessions.push(row(1, '2026-11-04T10:00:00Z'))
    const { cookie, deps } = await guest(db)
    expect(await front(cookie, deps)).toMatchObject({
      signedIn: true,
      account: 'guest',
      finishedLesson: true,
    })
  })

  it('[intro-rule 2] an email account with no finished lesson: account email, finishedLesson false', async () => {
    const db = oneUnit()
    db.sessions.push(row(1, null))
    const { cookie, deps } = await emailLearner(db)
    expect(await front(cookie, deps)).toEqual({
      signedIn: true,
      today: 'continue',
      canDo: 'Can do of unit 10.',
      account: 'email',
      finishedLesson: false,
    })
  })

  it('[intro-rule 2] an email account with a finished lesson: account email, finishedLesson true', async () => {
    const db = oneUnit()
    db.sessions.push(row(1, '2026-11-04T10:00:00Z'))
    const { cookie, deps } = await emailLearner(db)
    expect(await front(cookie, deps)).toMatchObject({
      signedIn: true,
      account: 'email',
      finishedLesson: true,
    })
  })

  it('[intro-rule 2] both facts come with the all done and not ready states too (review: worker/review.test.ts)', async () => {
    const done = fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, sampleContent()]]))
    done.sessions.push(row(1, '2026-11-04T10:00:00Z'))
    const one = await emailLearner(done)
    expect(await front(one.cookie, one.deps)).toEqual({
      signedIn: true,
      today: 'all_done',
      account: 'email',
      finishedLesson: true,
    })
    const empty = fakeDb()
    const two = await guest(empty)
    expect(await front(two.cookie, two.deps)).toEqual({
      signedIn: true,
      today: 'not_ready',
      account: 'guest',
      finishedLesson: false,
    })
  })

  it("[intro-rule 2] the facts are read with the learner's own sign in: no user id is taken from the request", async () => {
    const db = oneUnit()
    const { fake, cookie, deps } = await emailLearner(db)
    fake.requests.length = 0
    const res = await handleApi(get(`/api/today?user=someone-else&account=email`, cookie), ENV, deps)
    expect(res.status).toBe(200)
    // The only Supabase call is Auth's own user check with this device's token.
    const paths = fake.requests.map((r) => `${r.method} ${r.url.pathname}`)
    expect(paths).toEqual(['GET /auth/v1/user'])
    expect(fake.requests[0]?.headers.get('authorization')).toMatch(/^Bearer /)
  })
})
