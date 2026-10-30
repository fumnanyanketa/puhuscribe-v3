import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { FEEDBACK_LIMIT_TEXT } from '../src/lib/feedback-types.ts'
import { handleApi } from './api.ts'
import { ENV, ORIGIN, cookieHeader, fakeSupabase, post, type FakeSupabase } from './test-fakes.ts'

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md that each test protects.
// POST /api/feedback: job 8's protections, the length rules, the daily limit
// answer, and nothing in the log.

let supabase: FakeSupabase
let inserts: { body: string; authorization: string | null }[]
let limitReached: boolean
const written: string[] = []

beforeEach(() => {
  supabase = fakeSupabase()
  inserts = []
  limitReached = false
  written.length = 0
  supabase.rest = (request) => {
    if (request.url.pathname !== '/rest/v1/feedback' || request.method !== 'POST') return undefined
    inserts.push({ body: request.body, authorization: request.headers.get('authorization') })
    if (limitReached) {
      return new Response(
        JSON.stringify({ code: 'P0001', message: 'feedback_daily_limit', hint: 'At most 5 messages a day.' }),
        { status: 400, headers: { 'content-type': 'application/json' } },
      )
    }
    return new Response(null, { status: 201 })
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

async function learnerCookie(): Promise<string> {
  return cookieHeader(await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch }))
}

function send(body: unknown, options: { cookie?: string; origin?: string; contentType?: string } = {}) {
  return handleApi(
    post('/api/feedback', { ...options, body: typeof body === 'string' ? body : JSON.stringify(body) }),
    ENV,
    { fetch: supabase.fetch },
  )
}

describe('POST /api/feedback', () => {
  it('[analytics 22] stores a message with the learner own token and answers 201', async () => {
    const cookie = await learnerCookie()
    const res = await send({ screen: 'account', message: '  The audio was too quiet.  ' }, { cookie })
    expect(res.status).toBe(201)
    expect(await res.json()).toEqual({ sent: true })
    expect(inserts).toHaveLength(1)
    expect(JSON.parse(inserts[0]?.body ?? '')).toEqual({
      screen: 'account',
      message: 'The audio was too quiet.',
    })
    expect(supabase.issued).toContain((inserts[0]?.authorization ?? '').replace(/^Bearer /, ''))
  })

  it('[analytics 22] takes each of the three screens', async () => {
    const cookie = await learnerCookie()
    for (const screen of ['front_door', 'account', 'finish']) {
      expect((await send({ screen, message: 'ok' }, { cookie })).status, screen).toBe(201)
    }
  })

  it('[analytics 22] answers 400 to an empty, blank or too long message, or an unknown screen, and stores nothing', async () => {
    const cookie = await learnerCookie()
    for (const [body, error] of [
      [{ screen: 'account', message: '' }, 'bad_message'],
      [{ screen: 'account', message: '    ' }, 'bad_message'],
      [{ screen: 'account', message: 'a'.repeat(1001) }, 'bad_message'],
      [{ screen: 'account', message: 'ä'.repeat(1001) }, 'bad_message'],
      [{ screen: 'account' }, 'bad_message'],
      [{ screen: 'settings', message: 'hi' }, 'bad_screen'],
      ['not json', 'bad_message'],
    ] as const) {
      const res = await send(body, { cookie })
      expect(res.status, JSON.stringify(body).slice(0, 40)).toBe(400)
      expect(await res.json()).toEqual({ error })
    }
    expect(inserts).toHaveLength(0)
  })

  it('[analytics 22] takes a message of exactly 1,000 characters', async () => {
    const cookie = await learnerCookie()
    expect((await send({ screen: 'finish', message: 'ö'.repeat(1000) }, { cookie })).status).toBe(201)
  })

  it('[analytics 22] answers 429 with the gentle line when the day 5 messages are used', async () => {
    const cookie = await learnerCookie()
    limitReached = true
    const res = await send({ screen: 'finish', message: 'one more' }, { cookie })
    expect(res.status).toBe(429)
    expect(await res.json()).toEqual({ error: 'feedback_limit', message: FEEDBACK_LIMIT_TEXT })
    expect(FEEDBACK_LIMIT_TEXT).toBe('You have sent 5 messages today. Please try again tomorrow.')
  })

  it('[analytics 22] reads and caps the body at 8 KB before answering', async () => {
    const cookie = await learnerCookie()
    const res = await send(JSON.stringify({ screen: 'account', message: 'x'.repeat(9000) }), { cookie })
    expect(res.status).toBe(413)
    expect(inserts).toHaveLength(0)
  })

  it('[analytics 30] accepts only POST with JSON from this site', async () => {
    const cookie = await learnerCookie()
    const get = await handleApi(new Request(`${ORIGIN}/api/feedback`, { headers: { cookie } }), ENV, {
      fetch: supabase.fetch,
    })
    expect(get.status).toBe(405)
    const foreign = await send(
      { screen: 'account', message: 'hi' },
      { cookie, origin: 'https://evil.example' },
    )
    expect(foreign.status).toBe(403)
    expect(foreign.headers.get('access-control-allow-origin')).toBeNull()
    const plain = await send({ screen: 'account', message: 'hi' }, { cookie, contentType: 'text/plain' })
    expect(plain.status).toBe(415)
    expect(inserts).toHaveLength(0)
  })

  it('[analytics 19] [analytics 22] without an account, answers 401 and stores nothing', async () => {
    const res = await send({ screen: 'account', message: 'hi' })
    expect(res.status).toBe(401)
    expect(inserts).toHaveLength(0)
  })

  it('[analytics 22] a database fault answers 503', async () => {
    const cookie = await learnerCookie()
    supabase.rest = () => new Response('{"message":"down"}', { status: 500 })
    expect((await send({ screen: 'account', message: 'hi' }, { cookie })).status).toBe(503)
  })

  it('[analytics 30] writes no feedback text, user id or token to the log', async () => {
    const cookie = await learnerCookie()
    await send({ screen: 'account', message: 'private words about my day' }, { cookie })
    limitReached = true
    await send({ screen: 'account', message: 'private words again' }, { cookie })
    const log = written.join('\n')
    expect(log).not.toContain('private words')
    for (const id of supabase.userIds) expect(log).not.toContain(id)
    for (const value of supabase.issued) expect(log).not.toContain(value)
  })
})
