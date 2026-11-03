import { describe, expect, it } from 'vitest'
import { handleApi } from './api.ts'
import {
  GUEST_ACTION,
  humanCheckKeys,
  SITEVERIFY_URL,
  TEST_KEYS,
  TEST_SITE_KEY,
} from './providers/human-check.ts'
import { ENV, DUMMY_TURNSTILE_TOKEN, cookieHeader, fakeSupabase, post } from './test-fakes.ts'

// The bot check on the guest Start (Cloudflare Turnstile, job turnstile).
// Labels are the numbered statements in factory/jobs/turnstile/build.md.

const signups = (supabase: ReturnType<typeof fakeSupabase>) =>
  supabase.requests.filter((r) => r.url.pathname === '/auth/v1/signup')

function guestWith(body: unknown, origin?: string) {
  return post('/api/guest', { body: JSON.stringify(body), ...(origin ? { origin } : {}) })
}

describe('POST /api/guest and the Turnstile token', () => {
  it('[turnstile 2] without a token no guest is made: 403 check_needed with the public site key', async () => {
    const supabase = fakeSupabase()
    const res = await handleApi(guestWith({}), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(403)
    expect(await res.json()).toEqual({ error: 'check_needed', siteKey: TEST_SITE_KEY })
    expect(signups(supabase)).toHaveLength(0)
    expect(supabase.humanChecks).toHaveLength(0)
  })

  it('[turnstile 2] a refused token makes no guest: 403 check_failed', async () => {
    const supabase = fakeSupabase()
    const res = await handleApi(guestWith({ turnstileToken: 'made-up' }), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(403)
    expect(await res.json()).toEqual({ error: 'check_failed', siteKey: TEST_SITE_KEY })
    expect(supabase.humanChecks).toHaveLength(1)
    expect(signups(supabase)).toHaveLength(0)
  })

  it('[turnstile 2] a token that is not text, or too long, is refused without asking Cloudflare', async () => {
    for (const turnstileToken of [null, 42, '', 'x'.repeat(2049)]) {
      const supabase = fakeSupabase()
      const res = await handleApi(guestWith({ turnstileToken }), ENV, { fetch: supabase.fetch })
      expect(res.status, String(turnstileToken).slice(0, 10)).toBe(403)
      expect(supabase.humanChecks).toHaveLength(0)
      expect(signups(supabase)).toHaveLength(0)
    }
  })

  it('[turnstile 2] a passing token makes the guest; siteverify gets the secret and the token only', async () => {
    const supabase = fakeSupabase()
    const res = await handleApi(guestWith({ turnstileToken: DUMMY_TURNSTILE_TOKEN }), ENV, {
      fetch: supabase.fetch,
    })
    expect(res.status).toBe(201)
    expect(signups(supabase)).toHaveLength(1)
    const [check] = supabase.humanChecks
    expect(check?.method).toBe('POST')
    expect(check?.url.href).toBe(SITEVERIFY_URL)
    expect(JSON.parse(check?.body ?? '{}')).toEqual({
      secret: TEST_KEYS.TURNSTILE_SECRET_KEY,
      response: DUMMY_TURNSTILE_TOKEN,
    })
  })

  it('[turnstile 2] when Cloudflare cannot be reached, no guest is made: 503 check_unavailable', async () => {
    const supabase = fakeSupabase()
    supabase.siteverify = () => {
      throw new Error('network down')
    }
    const res = await handleApi(guestWith({ turnstileToken: DUMMY_TURNSTILE_TOKEN }), ENV, {
      fetch: supabase.fetch,
    })
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'check_unavailable' })
    expect(signups(supabase)).toHaveLength(0)
  })

  it('[turnstile 3] a learner who is signed in needs no token and Cloudflare is not asked', async () => {
    const supabase = fakeSupabase()
    const first = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
    const checksBefore = supabase.humanChecks.length
    const again = await handleApi(post('/api/guest', { cookie: cookieHeader(first), body: '{}' }), ENV, {
      fetch: supabase.fetch,
    })
    expect(again.status).toBe(200)
    expect(await again.json()).toEqual({ guest: 'existing' })
    expect(supabase.humanChecks).toHaveLength(checksBefore)
  })

  it('[turnstile 5] with real keys, a token from another address or another action is refused', async () => {
    const real = {
      ...ENV,
      TURNSTILE_SITE_KEY: 'real-site-key-for-test',
      TURNSTILE_SECRET_KEY: 'real-secret-for-test',
    }
    for (const [hostname, action, status] of [
      ['puhuscribe.example', GUEST_ACTION, 201],
      ['evil.example', GUEST_ACTION, 403],
      ['puhuscribe.example', 'other', 403],
    ] as const) {
      const supabase = fakeSupabase()
      supabase.siteverify = () => Response.json({ success: true, hostname, action, 'error-codes': [] })
      const res = await handleApi(guestWith({ turnstileToken: 'real-token' }), real, {
        fetch: supabase.fetch,
      })
      expect(res.status, `${hostname} ${action}`).toBe(status)
      expect(signups(supabase)).toHaveLength(status === 201 ? 1 : 0)
    }
  })

  it('[turnstile 5] a wrong secret is the app’s fault: 503, not a refusal of the learner', async () => {
    const supabase = fakeSupabase()
    supabase.siteverify = () => Response.json({ success: false, 'error-codes': ['invalid-input-secret'] })
    const res = await handleApi(guestWith({ turnstileToken: DUMMY_TURNSTILE_TOKEN }), ENV, {
      fetch: supabase.fetch,
    })
    expect(res.status).toBe(503)
    expect(signups(supabase)).toHaveLength(0)
  })
})

describe('which keys an address uses', () => {
  it('[turnstile 4] without the real pair, local and workers.dev addresses use the test keys', () => {
    for (const hostname of ['localhost', '127.0.0.1', 'main-puhuscribe-preview.fumnanya.workers.dev']) {
      expect(humanCheckKeys({}, hostname), hostname).toEqual({
        siteKey: TEST_KEYS.TURNSTILE_SITE_KEY,
        secret: TEST_KEYS.TURNSTILE_SECRET_KEY,
        test: true,
      })
    }
  })

  it('[turnstile 4] without the real pair, any other address has no check and makes no guest', async () => {
    expect(humanCheckKeys({}, 'puhuscribe.example')).toBeNull()
    expect(humanCheckKeys({ TURNSTILE_SITE_KEY: 'only-the-site-key' }, 'puhuscribe.example')).toBeNull()
    const supabase = fakeSupabase()
    const bare = { SUPABASE_URL: ENV.SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY: ENV.SUPABASE_PUBLISHABLE_KEY }
    const res = await handleApi(guestWith({ turnstileToken: DUMMY_TURNSTILE_TOKEN }), bare, {
      fetch: supabase.fetch,
    })
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'check_unavailable' })
    expect(signups(supabase)).toHaveLength(0)
  })

  it('[turnstile 4] the real pair wins everywhere, and is not treated as a test key', () => {
    const keys = humanCheckKeys({ TURNSTILE_SITE_KEY: 'site', TURNSTILE_SECRET_KEY: 'secret' }, 'localhost')
    expect(keys).toEqual({ siteKey: 'site', secret: 'secret', test: false })
  })
})
