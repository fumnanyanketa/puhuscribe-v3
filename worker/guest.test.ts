import { afterEach, describe, expect, it, vi } from 'vitest'
import { handleApi } from './api.ts'
import { handleRequest } from './index.ts'
import { AUTH_COOKIE, GUEST_MAX_AGE_SECONDS } from './learner-auth.ts'
import { ENV, ORIGIN, cookieHeader, fakeSupabase, get, post, setCookies } from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects.
// The guest account and the sign in cookies, with a fake Supabase Auth.

afterEach(() => {
  vi.useRealTimers()
})

async function signUp() {
  const supabase = fakeSupabase()
  const res = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
  return { supabase, res, cookie: cookieHeader(res) }
}

describe('POST /api/guest', () => {
  it('[session 2] makes one anonymous user with the publishable key and answers 201', async () => {
    const { supabase, res } = await signUp()
    expect(res.status).toBe(201)
    const signups = supabase.requests.filter((r) => r.url.pathname === '/auth/v1/signup')
    expect(signups).toHaveLength(1)
    expect(signups[0]?.method).toBe('POST')
    expect(signups[0]?.headers.get('apikey')).toBe(ENV.SUPABASE_PUBLISHABLE_KEY)
    // No email, no password: an anonymous sign up, as signInAnonymously() sends it.
    const body = JSON.parse(signups[0]?.body ?? '{}') as Record<string, unknown>
    expect(body.email).toBeUndefined()
    expect(body.password).toBeUndefined()
    expect(supabase.userIds).toHaveLength(1)
  })

  it('[session 2] is reached through the Worker entry point', async () => {
    const supabase = fakeSupabase()
    const res = await handleRequest(post('/api/guest'), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(201)
  })

  it('[session 2] [session 3] the answer body holds no token and no user id', async () => {
    const { supabase, res } = await signUp()
    const text = await res.text()
    expect(JSON.parse(text)).toEqual({ guest: 'created' })
    for (const secret of [...supabase.issued, ...supabase.userIds]) expect(text).not.toContain(secret)
  })

  it('[session 2] the sign in cookies are HttpOnly, Secure, SameSite=Lax, Path=/, no Domain, for 90 days', async () => {
    const { res } = await signUp()
    const cookies = setCookies(res)
    expect(cookies.length).toBeGreaterThan(0)
    expect(GUEST_MAX_AGE_SECONDS).toBe(90 * 24 * 60 * 60)
    for (const cookie of cookies) {
      expect(cookie.startsWith(AUTH_COOKIE)).toBe(true)
      expect(cookie).toMatch(/;\s*HttpOnly/i)
      expect(cookie).toMatch(/;\s*Secure/i)
      expect(cookie).toMatch(/;\s*SameSite=Lax/i)
      expect(cookie).toMatch(/;\s*Path=\/(;|$)/i)
      expect(cookie).not.toMatch(/;\s*Domain=/i)
      expect(cookie).toMatch(new RegExp(`;\\s*Max-Age=${String(GUEST_MAX_AGE_SECONDS)}(;|$)`, 'i'))
    }
  })

  it('[session 2] pressing Start again with the cookie makes no second account and answers 200', async () => {
    const { supabase, cookie } = await signUp()
    const again = await handleApi(post('/api/guest', { cookie }), ENV, { fetch: supabase.fetch })
    expect(again.status).toBe(200)
    expect(await again.json()).toEqual({ guest: 'existing' })
    expect(supabase.userIds).toHaveLength(1)
    expect(supabase.requests.filter((r) => r.url.pathname === '/auth/v1/signup')).toHaveLength(1)
  })

  it('[session 5] GET is refused with 405 and makes nothing', async () => {
    const supabase = fakeSupabase()
    const res = await handleApi(get('/api/guest'), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(405)
    expect(res.headers.get('allow')).toBe('POST')
    expect(supabase.requests).toEqual([])
  })

  it('[session 5] another website (Origin header) gets 403 and nothing is made', async () => {
    const supabase = fakeSupabase()
    const res = await handleApi(post('/api/guest', { origin: 'https://evil.example' }), ENV, {
      fetch: supabase.fetch,
    })
    expect(res.status).toBe(403)
    expect(res.headers.get('access-control-allow-origin')).toBeNull()
    expect(supabase.requests).toEqual([])
  })

  it('[session 5] the same address in the Origin header is allowed', async () => {
    const supabase = fakeSupabase()
    const res = await handleApi(post('/api/guest', { origin: ORIGIN }), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(201)
  })

  it('[session 5] a plain form post (no JSON content type) gets 415 and nothing is made', async () => {
    const supabase = fakeSupabase()
    const res = await handleApi(
      post('/api/guest', { contentType: 'application/x-www-form-urlencoded', body: 'a=1' }),
      ENV,
      { fetch: supabase.fetch },
    )
    expect(res.status).toBe(415)
    expect(supabase.requests).toEqual([])
  })

  it('[session 2] answers 503 with no cookie when Supabase Auth is down', async () => {
    const supabase = fakeSupabase()
    supabase.down = true
    const res = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(503)
    expect(setCookies(res).filter((c) => !/max-age=0/i.test(c))).toEqual([])
  })
})

describe('renewing and losing the sign in', () => {
  it('[session 4] an expired access token is renewed with the refresh token, new cookies are set, and the request succeeds', async () => {
    const { supabase, cookie } = await signUp()
    vi.useFakeTimers({ toFake: ['Date'], now: Date.now() + 2 * 60 * 60 * 1000 })
    const res = await handleApi(get('/api/today', cookie), ENV, {
      fetch: supabase.fetch,
      learnerDb: () => ({
        readableDialogues: () => Promise.resolve([]),
        mySessions: () => Promise.resolve([]),
        startSession: () => Promise.reject(new Error('unused')),
        dialogueContent: () => Promise.reject(new Error('unused')),
        session: () => Promise.resolve(null),
        setStep: () => Promise.resolve(false),
        completeSession: () => Promise.resolve('not_found'),
      }),
    })
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ signedIn: true, today: 'not_ready' })
    expect(supabase.requests.filter((r) => r.url.pathname === '/auth/v1/token')).toHaveLength(1)
    const renewed = cookieHeader(res, cookie)
    expect(renewed).not.toBe(cookie)
    for (const value of setCookies(res)) expect(value).toMatch(/HttpOnly/)
  })

  it('[session 4] when renewal fails because the user was deleted, the cookies are cleared and the front door says the session ended', async () => {
    const { supabase, cookie } = await signUp()
    supabase.users.clear()
    vi.useFakeTimers({ toFake: ['Date'], now: Date.now() + 2 * 60 * 60 * 1000 })
    const res = await handleApi(get('/api/today', cookie), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ signedIn: false, ended: true })
    const cleared = setCookies(res)
    expect(cleared.length).toBeGreaterThan(0)
    for (const value of cleared) {
      expect(value).toMatch(/Max-Age=0/i)
      expect(value).toMatch(/HttpOnly/i)
    }
    expect(cookieHeader(res, cookie)).toBe('')
  })

  it('[session 4] a deleted user whose access token has not expired yet is also signed out', async () => {
    const { supabase, cookie } = await signUp()
    supabase.users.clear()
    const res = await handleApi(get('/api/today', cookie), ENV, { fetch: supabase.fetch })
    expect(await res.json()).toEqual({ signedIn: false, ended: true })
    expect(cookieHeader(res, cookie)).toBe('')
  })

  it('[session 4] a session route answers 401 session_ended and clears the cookies', async () => {
    const { supabase, cookie } = await signUp()
    supabase.users.clear()
    const res = await handleApi(post('/api/sessions/today', { cookie }), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(401)
    expect(await res.json()).toEqual({ error: 'session_ended' })
    expect(cookieHeader(res, cookie)).toBe('')
  })

  it('[session 4] after the session ended, Start makes a new guest', async () => {
    const { supabase, cookie } = await signUp()
    supabase.users.clear()
    const res = await handleApi(post('/api/guest', { cookie }), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(201)
    expect(supabase.userIds).toHaveLength(2)
    expect(cookieHeader(res, cookie)).toContain(AUTH_COOKIE)
  })

  it('[session 4] a network fault keeps the cookies and answers 503', async () => {
    const { supabase, cookie } = await signUp()
    supabase.down = true
    const res = await handleApi(get('/api/today', cookie), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(503)
    expect(setCookies(res).filter((c) => /max-age=0/i.test(c))).toEqual([])
  })

  it('[session 1] [session 4] without any cookie, the front door is told the visitor is signed out, and nothing is made', async () => {
    const supabase = fakeSupabase()
    const res = await handleApi(get('/api/today'), ENV, { fetch: supabase.fetch })
    expect(await res.json()).toEqual({ signedIn: false, ended: false })
    expect(supabase.requests).toEqual([])
    expect(setCookies(res)).toEqual([])
  })
})
