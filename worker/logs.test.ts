import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { ReadySession } from '../src/lib/session-types.ts'
import { handleApi, type ApiDeps } from './api.ts'
import {
  ENV,
  cookieHeader,
  fakeDb,
  fakeSupabase,
  get,
  post,
  sampleContent,
  sampleDialogue,
} from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects.
// The Worker writes no cookie, token, user id, IP address or request header
// to its logs. Every console method is watched while a learner goes through
// every route, including the faults.

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
  vi.useRealTimers()
})

describe('the Worker log', () => {
  it('[session 19] holds no cookie, token, user id, IP address or header after a whole session and its faults', async () => {
    const supabase = fakeSupabase()
    const db = fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, sampleContent()]]))
    const deps: ApiDeps = { fetch: supabase.fetch, learnerDb: () => db }
    const address = '203.0.113.77'
    const extra = {
      'cf-connecting-ip': address,
      'x-forwarded-for': address,
      'user-agent': 'Probe/1.0 (secret-agent)',
    }
    const withHeaders = (request: Request) => {
      for (const [name, value] of Object.entries(extra)) request.headers.set(name, value)
      return request
    }

    const guest = await handleApi(withHeaders(post('/api/guest')), ENV, deps)
    const cookie = cookieHeader(guest)
    await handleApi(withHeaders(get('/api/today', cookie)), ENV, deps)
    const today = await handleApi(withHeaders(post('/api/sessions/today', { cookie })), ENV, deps)
    const id = (await today.json<ReadySession>()).session.id
    for (const step of ['hear', 'understand']) {
      await handleApi(
        withHeaders(post(`/api/sessions/${id}/step`, { cookie, body: JSON.stringify({ step }) })),
        ENV,
        deps,
      )
    }
    db.failNext = true
    await handleApi(withHeaders(post(`/api/sessions/${id}/complete`, { cookie })), ENV, deps)
    await handleApi(withHeaders(post(`/api/sessions/${id}/complete`, { cookie })), ENV, deps)
    await handleApi(withHeaders(post('/api/guest', { cookie, origin: 'https://evil.example' })), ENV, deps)
    // Renewal, then a lost sign in, then Auth down.
    vi.useFakeTimers({ toFake: ['Date'], now: Date.now() + 2 * 60 * 60 * 1000 })
    await handleApi(withHeaders(get('/api/today', cookie)), ENV, deps)
    supabase.users.clear()
    await handleApi(withHeaders(get('/api/today', cookie)), ENV, deps)
    supabase.down = true
    await handleApi(withHeaders(post('/api/guest')), ENV, deps)

    const log = written.join('\n')
    const forbidden = [
      ...supabase.issued,
      ...supabase.userIds,
      ...cookie.split('; ').map((part) => part.split('=').slice(1).join('=')),
      address,
      'secret-agent',
      id,
    ].filter(Boolean)
    expect(forbidden.length).toBeGreaterThan(4)
    for (const value of forbidden) expect(log).not.toContain(value)
    expect(log).not.toMatch(/cookie|authorization|bearer/i)
  })
})
