import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { parseReviewerSignup } from '../src/lib/reviewer-signup.ts'
import { handleApi, type ApiDeps } from './api.ts'
import { handleRequest } from './index.ts'
import { TEST_SITE_KEY } from './providers/human-check.ts'
import { memoryLimiter, SIGNUPS_PER_ADDRESS_PER_DAY } from './reviewers.ts'
import {
  DUMMY_TURNSTILE_TOKEN,
  ENV,
  ORIGIN,
  PROJECT,
  PUBLISHABLE,
  fakeSupabase,
  type FakeSupabase,
} from './test-fakes.ts'

// Labels [reviewers N] are the "Done when" statement numbers from
// factory/jobs/reviewers/spec.md that each test protects.
// POST /api/reviewers: the Turnstile check before anything is saved, the field
// rules, the daily limits, no cookie, the owner's alert, and nothing in the log.

let supabase: FakeSupabase
let saved: Record<string, unknown>[]
let dbAnswer: () => Response
const written: string[] = []

beforeEach(() => {
  supabase = fakeSupabase()
  saved = []
  dbAnswer = () => new Response('true', { status: 200, headers: { 'content-type': 'application/json' } })
  supabase.rest = (request) => {
    if (request.url.pathname !== '/rest/v1/rpc/sign_up_reviewer') return undefined
    saved.push({
      ...(JSON.parse(request.body) as Record<string, unknown>),
      apikey: request.headers.get('apikey'),
    })
    return dbAnswer()
  }
  written.length = 0
  for (const method of ['log', 'info', 'warn', 'error', 'debug', 'trace'] as const) {
    vi.spyOn(console, method).mockImplementation((...args: unknown[]) => {
      written.push(args.map(String).join(' '))
    })
  }
})

afterEach(() => {
  vi.restoreAllMocks()
})

const FORM = { name: 'Aino Virtanen', email: 'aino@example.fi', thanksName: 'Aino' }

function request(body: unknown, headers: Record<string, string> = {}) {
  return new Request(`${ORIGIN}/api/reviewers`, {
    method: 'POST',
    headers: { 'content-type': 'application/json', ...headers },
    body: typeof body === 'string' ? body : JSON.stringify(body),
  })
}

function send(body: unknown, extra: Partial<ApiDeps> = {}, headers: Record<string, string> = {}) {
  return handleApi(request(body, headers), ENV, {
    fetch: supabase.fetch,
    reviewersLimiter: memoryLimiter(),
    reviewerAlert: () => Promise.resolve(true),
    ...extra,
  })
}

const withToken = (form: Record<string, unknown> = FORM) => ({
  ...form,
  turnstileToken: DUMMY_TURNSTILE_TOKEN,
})

describe('POST /api/reviewers and the Turnstile check', () => {
  it('[reviewers 2] without a token nothing is saved: 403 check_needed with the public site key', async () => {
    const res = await send(FORM)
    expect(res.status).toBe(403)
    expect(await res.json()).toEqual({ error: 'check_needed', siteKey: TEST_SITE_KEY })
    expect(saved).toHaveLength(0)
    expect(supabase.humanChecks).toHaveLength(0)
  })

  it('[reviewers 2] a refused token saves nothing: 403 check_failed', async () => {
    const res = await send({ ...FORM, turnstileToken: 'made-up' })
    expect(res.status).toBe(403)
    expect(await res.json()).toEqual({ error: 'check_failed', siteKey: TEST_SITE_KEY })
    expect(supabase.humanChecks).toHaveLength(1)
    expect(saved).toHaveLength(0)
  })

  it('[reviewers 2] a token that is not text saves nothing', async () => {
    for (const token of [123, { a: 1 }, '', 'x'.repeat(2049)]) {
      expect((await send({ ...FORM, turnstileToken: token })).status).toBe(403)
    }
    expect(saved).toHaveLength(0)
  })

  it('[reviewers 2] when the check cannot run nothing is saved: 503 check_unavailable', async () => {
    supabase.siteverify = () => new Response('down', { status: 500 })
    const res = await send(withToken())
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'check_unavailable' })
    expect(saved).toHaveLength(0)
  })

  it('[reviewers 2] a live address with no Turnstile keys saves nothing', async () => {
    const res = await handleApi(
      new Request('https://meetaleksi.com/api/reviewers', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify(withToken()),
      }),
      { SUPABASE_URL: PROJECT, SUPABASE_PUBLISHABLE_KEY: PUBLISHABLE },
      { fetch: supabase.fetch, reviewersLimiter: memoryLimiter() },
    )
    expect(res.status).toBe(503)
    expect(saved).toHaveLength(0)
  })

  it('[reviewers 2] with real keys a token must come from this address and from the reviewers form', async () => {
    const env = { ...ENV, TURNSTILE_SITE_KEY: 'real-site-key', TURNSTILE_SECRET: 'real-secret' }
    let action = 'guest'
    let hostname = 'puhuscribe.example'
    supabase.siteverify = () => Response.json({ success: true, hostname, action })
    const go = () =>
      handleApi(request(withToken()), env, { fetch: supabase.fetch, reviewersLimiter: memoryLimiter() })
    expect((await go()).status).toBe(403)
    action = 'reviewers'
    hostname = 'other.example'
    expect((await go()).status).toBe(403)
    expect(saved).toHaveLength(0)
    hostname = 'puhuscribe.example'
    expect((await go()).status).toBe(201)
    expect(saved).toHaveLength(1)
    expect(JSON.parse(supabase.humanChecks[0]?.body ?? '{}')).toEqual({
      secret: 'real-secret',
      response: DUMMY_TURNSTILE_TOKEN,
    })
  })

  it('[reviewers 2] a passed check saves one row with the name, email and thank-you name, as anon', async () => {
    const res = await send(
      withToken({ name: '  Aino Virtanen ', email: ' Aino@Example.FI ', thanksName: ' Aino ' }),
    )
    expect(res.status).toBe(201)
    expect(await res.json()).toEqual({ sent: true })
    expect(saved).toEqual([
      { p_name: 'Aino Virtanen', p_email: 'aino@example.fi', p_thanks_name: 'Aino', apikey: PUBLISHABLE },
    ])
    // As anon: the publishable key and no user token.
    const call = supabase.requests.find((r) => r.url.pathname === '/rest/v1/rpc/sign_up_reviewer')
    expect(call?.headers.get('authorization')).toBeNull()
    expect(call?.headers.get('cookie')).toBeNull()
  })

  it('[reviewers 2] an empty thank-you name is saved as none', async () => {
    expect((await send(withToken({ ...FORM, thanksName: '   ' }))).status).toBe(201)
    expect((await send(withToken({ name: 'Eero', email: 'eero@example.fi' }))).status).toBe(201)
    expect(saved.map((row) => row.p_thanks_name)).toEqual([null, null])
  })

  it('[reviewers 1] [reviewers 2] no cookie is set, with or without a sign up', async () => {
    for (const res of [await send(FORM), await send(withToken()), await send({ name: '' })]) {
      expect(res.headers.get('set-cookie')).toBeNull()
    }
  })

  it('[reviewers 2] 503 when the database cannot save, and the answer says only that', async () => {
    dbAnswer = () => new Response('{"message":"down"}', { status: 500 })
    const res = await send(withToken())
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'not_available' })
  })
})

describe('POST /api/reviewers checks the input', () => {
  const refused: [string, Record<string, unknown>, string][] = [
    ['an empty name', { ...FORM, name: '' }, 'name'],
    ['a name of spaces', { ...FORM, name: '    ' }, 'name'],
    ['no name', { email: FORM.email }, 'name'],
    ['a name that is not text', { ...FORM, name: 42 }, 'name'],
    ['a name of 101 characters', { ...FORM, name: 'a'.repeat(101) }, 'name'],
    ['a name with a new line', { ...FORM, name: 'Ai\nno' }, 'name'],
    ['an email with no @', { ...FORM, email: 'aino.example.fi' }, 'email'],
    ['an email with no dot after the @', { ...FORM, email: 'aino@localhost' }, 'email'],
    ['an email with a space', { ...FORM, email: 'ai no@example.fi' }, 'email'],
    ['an email of 255 characters', { ...FORM, email: `${'a'.repeat(244)}@example.fi` }, 'email'],
    ['no email', { name: 'Aino' }, 'email'],
    ['a thank-you name of 101 characters', { ...FORM, thanksName: 'b'.repeat(101) }, 'thanks_name'],
    ['a thank-you name that is not text', { ...FORM, thanksName: ['x'] }, 'thanks_name'],
  ]

  for (const [what, form, field] of refused) {
    it(`[reviewers 3] refuses ${what} with 400, before any check or save`, async () => {
      const res = await send(withToken(form))
      expect(res.status).toBe(400)
      expect(await res.json()).toEqual({ error: 'bad_input', field })
      expect(supabase.humanChecks).toHaveLength(0)
      expect(saved).toHaveLength(0)
    })
  }

  it('[reviewers 3] accepts exactly 100 characters for each name and 254 for the email', async () => {
    const res = await send(
      withToken({
        name: 'ä'.repeat(100),
        email: `${'a'.repeat(243)}@example.fi`,
        thanksName: '😀'.repeat(100),
      }),
    )
    expect(res.status).toBe(201)
    expect(`${'a'.repeat(243)}@example.fi`).toHaveLength(254)
  })

  it('[reviewers 3] refuses a body that is not JSON, too large, from another site or not JSON typed', async () => {
    expect((await send('not json')).status).toBe(400)
    expect((await send({ ...withToken(), padding: 'x'.repeat(5000) })).status).toBe(413)
    expect((await send(withToken(), {}, { origin: 'https://evil.example' })).status).toBe(403)
    expect((await send(withToken(), {}, { 'content-type': 'text/plain' })).status).toBe(415)
    expect(
      (await handleApi(new Request(`${ORIGIN}/api/reviewers`), ENV, { fetch: supabase.fetch })).status,
    ).toBe(405)
    expect(saved).toHaveLength(0)
  })

  it('[reviewers 3] the page and the Worker share one rule (src/lib/reviewer-signup.ts)', () => {
    expect(parseReviewerSignup({ name: ' A ', email: 'A@B.FI' })).toEqual({
      name: 'A',
      email: 'a@b.fi',
      thanksName: null,
    })
    expect(parseReviewerSignup({ name: 'A', email: 'a@b.fi', thanksName: 'x'.repeat(101) })).toEqual({
      bad: 'thanks_name',
    })
  })
})

describe('POST /api/reviewers daily limits', () => {
  it('[reviewers 3] the database daily limit answers 429 and sends no alert', async () => {
    dbAnswer = () => new Response('false', { status: 200, headers: { 'content-type': 'application/json' } })
    const alert = vi.fn(() => Promise.resolve(true))
    const res = await send(withToken(), { reviewerAlert: alert })
    expect(res.status).toBe(429)
    expect(await res.json()).toEqual({ error: 'limit' })
    expect(alert).not.toHaveBeenCalled()
  })

  it('[reviewers 3] refuses more than 5 sign ups from one internet address on one day, before any check', async () => {
    const limiter = memoryLimiter()
    const from = (address: string) =>
      send(
        withToken({ ...FORM, email: `x${String(saved.length)}@example.fi` }),
        { reviewersLimiter: limiter },
        {
          'cf-connecting-ip': address,
        },
      )
    for (let n = 0; n < SIGNUPS_PER_ADDRESS_PER_DAY; n += 1)
      expect((await from('203.0.113.9')).status).toBe(201)
    const checks = supabase.humanChecks.length
    expect((await from('203.0.113.9')).status).toBe(429)
    expect(supabase.humanChecks).toHaveLength(checks)
    expect(saved).toHaveLength(SIGNUPS_PER_ADDRESS_PER_DAY)
    expect((await from('198.51.100.7')).status).toBe(201)
  })

  it('[reviewers 3] the address count starts again on the next Helsinki day, and counts only saved sign ups', () => {
    const limiter = memoryLimiter(2)
    const evening = new Date('2026-11-24T21:30:00Z') // 23:30 in Helsinki
    const nextMorning = new Date('2026-11-24T22:30:00Z') // 00:30 the next day in Helsinki
    expect(limiter.allows('a', evening)).toBe(true)
    limiter.count('a', evening)
    limiter.count('a', evening)
    expect(limiter.allows('a', evening)).toBe(false)
    expect(limiter.allows('b', evening)).toBe(true)
    expect(limiter.allows('a', nextMorning)).toBe(true)
  })
})

describe('the owner alert after POST /api/reviewers', () => {
  it('[reviewers 6] a saved sign up starts one alert, after the answer', async () => {
    const later: Promise<unknown>[] = []
    const alert = vi.fn(() => Promise.resolve(true))
    const res = await send(withToken(), { reviewerAlert: alert, waitUntil: (work) => later.push(work) })
    expect(res.status).toBe(201)
    expect(alert).toHaveBeenCalledTimes(1)
    expect(later).toHaveLength(1)
  })

  it('[reviewers 6] no alert when the input is refused or the check fails', async () => {
    const alert = vi.fn(() => Promise.resolve(true))
    await send({ ...withToken(), name: '' }, { reviewerAlert: alert })
    await send({ ...FORM, turnstileToken: 'made-up' }, { reviewerAlert: alert })
    await send(FORM, { reviewerAlert: alert })
    expect(alert).not.toHaveBeenCalled()
  })

  it('[reviewers 6] a failing alert never changes the answer', async () => {
    const later: Promise<unknown>[] = []
    const res = await send(withToken(), {
      reviewerAlert: () => Promise.reject(new Error('Brevo is down')),
      waitUntil: (work) => later.push(work),
    })
    expect(res.status).toBe(201)
    await expect(Promise.all(later)).resolves.toEqual([false])
  })

  it('[reviewers 6] without the Brevo settings nothing is sent (the real alert, ENV has none)', async () => {
    const later: Promise<unknown>[] = []
    const res = await handleApi(request(withToken()), ENV, {
      fetch: supabase.fetch,
      reviewersLimiter: memoryLimiter(),
      waitUntil: (work) => later.push(work),
    })
    expect(res.status).toBe(201)
    await expect(Promise.all(later)).resolves.toEqual([false])
    expect(supabase.requests.some((r) => r.url.hostname === 'api.brevo.com')).toBe(false)
  })
})

describe('privacy of POST /api/reviewers', () => {
  it('[reviewers 7] writes no name, email or address to the log', async () => {
    await send(
      withToken({ name: 'Secret Name', email: 'secret@example.fi' }),
      {},
      { 'cf-connecting-ip': '203.0.113.77' },
    )
    dbAnswer = () => new Response('{"message":"down"}', { status: 500 })
    await send(withToken({ name: 'Secret Name', email: 'secret@example.fi' }))
    const log = written.join('\n')
    expect(log).not.toContain('Secret Name')
    expect(log).not.toContain('secret@example.fi')
    expect(log).not.toContain('203.0.113.77')
  })
})

describe('/reviewers, the page', () => {
  function assets() {
    const fetch = vi.fn<(req: Request) => Promise<Response>>(() =>
      Promise.resolve(
        new Response('<!doctype html><div id="root"></div>', {
          status: 200,
          headers: { 'content-type': 'text/html' },
        }),
      ),
    )
    return { fetch, connect: vi.fn() } as unknown as Fetcher & { fetch: typeof fetch }
  }

  it('[reviewers 1] the Worker answers /reviewers with the app shell, sets no cookie and needs no account', async () => {
    const ASSETS = assets()
    const res = await handleRequest(
      new Request(`${ORIGIN}/reviewers`),
      { ...ENV, ASSETS },
      { fetch: supabase.fetch },
    )
    expect(res.status).toBe(200)
    expect(res.headers.get('set-cookie')).toBeNull()
    expect(new URL(ASSETS.fetch.mock.calls[0]?.[0].url ?? 'https://none.invalid/').pathname).toBe(
      '/reviewers',
    )
    // No sign in is looked up for the page.
    expect(supabase.requests.some((r) => r.url.pathname.startsWith('/auth/'))).toBe(false)
  })
})
