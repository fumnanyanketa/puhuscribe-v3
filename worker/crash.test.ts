import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { handleApi } from './api.ts'
import { handleRequest, type WorkerEnv } from './index.ts'
import { DatabaseUnavailable } from './learner-db.ts'
import { sendCrashReport } from './providers/crash-reports.ts'
import {
  ENV,
  ORIGIN,
  PUBLISHABLE,
  cookieHeader,
  fakeDb,
  fakeSupabase,
  post,
  type FakeSupabase,
} from './test-fakes.ts'

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md that each test protects.
// Crash reports: the allow list, the cleaning, the one provider module, the
// Worker's own exceptions, and nothing in the log.

const SAFARI =
  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1'
const SESSION_ID = '0f8e2b44-6a71-4c3e-9d55-1b2c3d4e5f60'
// A made up value shaped like a sign in token (three base64url parts).
const SAMPLE_JWT = ['eyJhbGciOiJIUzI1NiJ9', 'eyJzdWIiOiJhYmMifQ', 'c2lnbmF0dXJlLXRoYXQtaXMtbG9uZw'].join('.')

let supabase: FakeSupabase
let stored: Record<string, unknown>[]
const written: string[] = []

beforeEach(() => {
  supabase = fakeSupabase()
  stored = []
  written.length = 0
  supabase.rest = (request) => {
    if (request.url.pathname !== '/rest/v1/rpc/report_crash') return undefined
    stored.push(JSON.parse(request.body) as Record<string, unknown>)
    return new Response('true', { status: 200, headers: { 'content-type': 'application/json' } })
  }
  for (const method of ['log', 'info', 'warn', 'error', 'debug', 'trace'] as const) {
    vi.spyOn(console, method).mockImplementation((...args: unknown[]) => {
      written.push(args.map(String).join(' '))
    })
  }
})

afterEach(() => {
  vi.restoreAllMocks()
})

function report(body: unknown, headers: Record<string, string> = {}) {
  const request = post('/api/crash', { body: typeof body === 'string' ? body : JSON.stringify(body) })
  request.headers.set('user-agent', SAFARI)
  for (const [name, value] of Object.entries(headers)) request.headers.set(name, value)
  return handleApi(request, ENV, { fetch: supabase.fetch })
}

const GOOD = {
  source: 'browser',
  name: 'TypeError',
  message: 'undefined is not an object',
  frames: [{ file: '/assets/index-AbC12.js', line: 3, column: 1200, fn: 'onClick' }],
  path: '/session',
}

describe('POST /api/crash takes only the allow list', () => {
  it('[analytics 25] stores a good report with the app version and a coarse browser label, and answers 204', async () => {
    const res = await report(GOOD)
    expect(res.status).toBe(204)
    expect(stored).toEqual([
      {
        p_source: 'browser',
        p_name: 'TypeError',
        p_message: 'undefined is not an object',
        p_frames: [{ file: '/assets/index-AbC12.js', line: 3, column: 1200, fn: 'onClick' }],
        p_path: '/session',
        p_app_version: 'local',
        p_browser: 'Safari 17, iOS',
      },
    ])
  })

  it('[analytics 25] refuses any field outside the allow list, and a source other than browser', async () => {
    for (const body of [
      { ...GOOD, answer: 'talossa' },
      { ...GOOD, userId: SESSION_ID },
      { ...GOOD, userAgent: SAFARI },
      { ...GOOD, source: 'worker' },
      { ...GOOD, frames: [{ ...GOOD.frames[0], value: 'typed text' }] },
      { ...GOOD, frames: new Array(11).fill(GOOD.frames[0]) },
      { ...GOOD, message: 42 },
      [GOOD],
      'not json',
    ]) {
      const res = await report(body)
      expect(res.status, JSON.stringify(body).slice(0, 60)).toBe(400)
    }
    expect(stored).toEqual([])
  })

  it('[analytics 25] stores no email, token, id or query string: the message and path are cleaned', async () => {
    await report({
      ...GOOD,
      message: `Failed for learner@example.com with ${SAMPLE_JWT} on session ${SESSION_ID}, code 123456, at https://puhuscribe.example/api/x?code=999&email=a@b.co#frag`,
      path: `/api/sessions/${SESSION_ID}/step?token=${SAMPLE_JWT}#x`,
    })
    const text = JSON.stringify(stored)
    for (const secret of [
      'learner@example.com',
      SAMPLE_JWT,
      SESSION_ID,
      '123456',
      'code=999',
      'a@b.co',
      '#frag',
      'token=',
    ]) {
      expect(text, secret).not.toContain(secret)
    }
    expect(stored[0]?.p_path).toBe('/api/sessions/:id/step')
    expect(stored[0]?.p_message).toBe(
      'Failed for [email] with [token] on session [id], code [number], at https://puhuscribe.example/api/x',
    )
  })

  it('[analytics 25] keeps only frames of the app own bundle files, at most 10', async () => {
    await report({
      ...GOOD,
      frames: [
        { file: 'https://evil.example/assets/x.js', line: 1, column: 1, fn: 'a' },
        { file: '/assets/index-AbC12.js', line: 2, column: 3, fn: 'b' },
        { file: '/node_modules/react.js', line: 1, column: 1, fn: 'c' },
        { file: 'chrome-extension://abc/x.js', line: 1, column: 1, fn: 'd' },
        { file: '/assets/vendor-Xy9.js', line: 4, column: 5, fn: 'learner@example.com' },
      ],
    })
    expect(stored[0]?.p_frames).toEqual([
      { file: '/assets/index-AbC12.js', line: 2, column: 3, fn: 'b' },
      { file: '/assets/vendor-Xy9.js', line: 4, column: 5, fn: '' },
    ])
  })

  it('[analytics 25] [analytics 30] never reads or renews the sign in cookies, and sets none', async () => {
    const cookie = cookieHeader(await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch }))
    const before = supabase.requests.length
    const res = await report(GOOD, { cookie })
    expect(res.status).toBe(204)
    expect(res.headers.get('set-cookie')).toBeNull()
    const calls = supabase.requests.slice(before)
    expect(calls.map((c) => c.url.pathname)).toEqual(['/rest/v1/rpc/report_crash'])
    expect([...(calls[0]?.headers.keys() ?? [])].sort()).toEqual(['apikey', 'content-type'])
    expect(calls[0]?.headers.get('apikey')).toBe(PUBLISHABLE)
    expect(calls[0]?.body).not.toContain(SAFARI)
  })

  it('[analytics 25] [analytics 30] reads the body, caps it at 8 KB, and accepts only POST with JSON from this site', async () => {
    expect((await report({ ...GOOD, message: 'x'.repeat(9000) })).status).toBe(413)
    expect((await report(GOOD, { origin: 'https://evil.example' })).status).toBe(403)
    expect((await report(GOOD, { 'content-type': 'text/plain' })).status).toBe(415)
    const get = await handleApi(new Request(`${ORIGIN}/api/crash`), ENV, { fetch: supabase.fetch })
    expect(get.status).toBe(405)
    expect(stored).toEqual([])
  })

  it('[analytics 28] the provider never throws: a fault or a dropped report is just false', async () => {
    const clean = {
      source: 'browser' as const,
      name: 'Error',
      message: 'm',
      frames: [],
      path: '/',
      appVersion: 'local',
      browser: 'Safari 17, iOS',
    }
    expect(await sendCrashReport(ENV, () => Promise.reject(new Error('down')), clean)).toBe(false)
    expect(
      await sendCrashReport(ENV, () => Promise.resolve(new Response('false', { status: 200 })), clean),
    ).toBe(false)
    expect(
      await sendCrashReport(ENV, () => Promise.resolve(new Response('{}', { status: 500 })), clean),
    ).toBe(false)
    expect(await sendCrashReport({}, supabase.fetch, clean)).toBe(false)
    expect(await sendCrashReport(ENV, supabase.fetch, clean)).toBe(true)
  })
})

describe('an exception inside the Worker', () => {
  function context() {
    const waits: Promise<unknown>[] = []
    return { waits, ctx: { waitUntil: (promise: Promise<unknown>) => void waits.push(promise) } }
  }

  it('[analytics 24] [analytics 27] a route that throws answers 500 server_error and the report reaches the database fake', async () => {
    const env: WorkerEnv = {
      ...ENV,
      ASSETS: {
        fetch: () => {
          const error = new TypeError(`Cannot read the page for learner@example.com ${SESSION_ID}`)
          error.stack = `TypeError: x\n    at route (file:///worker/index.js:40:11)\n    at node:internal/process:1:1\n    at handleRequest (/srv/index.js:55:20)`
          throw error
        },
        connect: () => undefined,
      } as unknown as Fetcher,
    }
    const { waits, ctx } = context()
    const request = new Request(`${ORIGIN}/account/${SESSION_ID}?x=1`, { headers: { 'user-agent': SAFARI } })
    const res = await handleRequest(request, env, { fetch: supabase.fetch }, ctx)
    expect(res.status).toBe(500)
    expect(await res.json()).toEqual({ error: 'server_error' })
    await Promise.all(waits)
    expect(stored).toHaveLength(1)
    expect(stored[0]).toMatchObject({
      p_source: 'worker',
      p_name: 'TypeError',
      p_message: 'Cannot read the page for [email] [id]',
      p_path: '/account/:id',
      p_app_version: 'local',
      p_browser: 'Safari 17, iOS',
      p_frames: [
        { file: 'index.js', line: 40, column: 11, fn: 'route' },
        { file: 'index.js', line: 55, column: 20, fn: 'handleRequest' },
      ],
    })
    expect(written).toEqual([])
  })

  it('[analytics 24] a handled answer such as 503 not_available is not a crash', async () => {
    const cookie = cookieHeader(await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch }))
    const db = fakeDb([], new Map())
    db.readableDialogues = () => Promise.reject(new DatabaseUnavailable())
    const { waits, ctx } = context()
    const res = await handleRequest(
      new Request(`${ORIGIN}/api/today`, { headers: { cookie } }),
      { ...ENV },
      { fetch: supabase.fetch, learnerDb: () => db },
      ctx,
    )
    expect(res.status).toBe(503)
    await Promise.all(waits)
    expect(stored).toEqual([])
  })
})
