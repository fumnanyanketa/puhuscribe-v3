import { describe, expect, it } from 'vitest'
import { handleApi } from './api.ts'
import { canonicalRedirect } from './canonical-host.ts'
import { handleRequest } from './index.ts'
import { GUEST_ACTION, humanCheckKeys } from './providers/human-check.ts'
import { ENV, fakeSupabase } from './test-fakes.ts'

// Job go-live: the app on https://meetaleksi.com. Labels are the numbered items
// of the manager's brief, recorded in factory/jobs/go-live/build.md:
// [go-live 1] the live Worker's www name forwards to the apex,
// [go-live 3] Turnstile accepts tokens made on meetaleksi.com.

const LIVE = { ...ENV, CANONICAL_HOST: 'meetaleksi.com' }

describe('www.meetaleksi.com forwards to meetaleksi.com', () => {
  it('[go-live 1] a page on www gets a 301 to the same path and query on the apex', async () => {
    const res = await canonicalRedirect(new Request('https://www.meetaleksi.com/learn/session?x=1'), LIVE)
    expect(res?.status).toBe(301)
    expect(res?.headers.get('location')).toBe('https://meetaleksi.com/learn/session?x=1')
  })

  it('[go-live 1] a POST on www gets a 308, which keeps the method, and its body is read', async () => {
    const request = new Request('https://www.meetaleksi.com/api/guest', { method: 'POST', body: '{}' })
    const res = await canonicalRedirect(request, LIVE)
    expect(res?.status).toBe(308)
    expect(res?.headers.get('location')).toBe('https://meetaleksi.com/api/guest')
    expect(request.bodyUsed).toBe(true)
  })

  it('[go-live 1] the apex, and any address when CANONICAL_HOST is not set, are not redirected', async () => {
    expect(await canonicalRedirect(new Request('https://meetaleksi.com/learn'), LIVE)).toBeNull()
    expect(await canonicalRedirect(new Request('https://www.meetaleksi.com/learn'), {})).toBeNull()
    expect(
      await canonicalRedirect(new Request('https://main-puhuscribe-preview.fumnanya.workers.dev/'), LIVE),
    ).toBeNull()
    // Only the www name of the canonical host, not some other name ending in it.
    expect(await canonicalRedirect(new Request('https://evil-www.meetaleksi.com/'), LIVE)).toBeNull()
  })

  it('[go-live 1] the Worker entry redirects www before any route runs, and makes no guest there', async () => {
    const supabase = fakeSupabase()
    const page = await handleRequest(new Request('https://www.meetaleksi.com/'), LIVE, {
      fetch: supabase.fetch,
    })
    expect(page.status).toBe(301)
    expect(page.headers.get('location')).toBe('https://meetaleksi.com/')
    const guest = await handleRequest(
      new Request('https://www.meetaleksi.com/api/guest', {
        method: 'POST',
        headers: { 'content-type': 'application/json', origin: 'https://www.meetaleksi.com' },
        body: '{}',
      }),
      LIVE,
      { fetch: supabase.fetch },
    )
    expect(guest.status).toBe(308)
    expect(supabase.requests).toHaveLength(0)
  })
})

describe('Turnstile on meetaleksi.com', () => {
  const real = {
    ...LIVE,
    TURNSTILE_SITE_KEY: 'real-site-key-for-test',
    TURNSTILE_SECRET: 'real-secret-for-test',
  }

  function guestOnLive(token: string) {
    return new Request('https://meetaleksi.com/api/guest', {
      method: 'POST',
      headers: { 'content-type': 'application/json', origin: 'https://meetaleksi.com' },
      body: JSON.stringify({ turnstileToken: token }),
    })
  }

  it('[go-live 3] with the real keys, a token Cloudflare says was made on meetaleksi.com makes the guest', async () => {
    const supabase = fakeSupabase()
    supabase.siteverify = () =>
      Response.json({ success: true, hostname: 'meetaleksi.com', action: GUEST_ACTION, 'error-codes': [] })
    const res = await handleApi(guestOnLive('real-token'), real, { fetch: supabase.fetch })
    expect(res.status).toBe(201)
    expect(supabase.requests.filter((r) => r.url.pathname === '/auth/v1/signup')).toHaveLength(1)
  })

  it('[go-live 3] a token made on another address (the www name, a preview) is refused on meetaleksi.com', async () => {
    for (const hostname of ['www.meetaleksi.com', 'main-puhuscribe-preview.fumnanya.workers.dev']) {
      const supabase = fakeSupabase()
      supabase.siteverify = () =>
        Response.json({ success: true, hostname, action: GUEST_ACTION, 'error-codes': [] })
      const res = await handleApi(guestOnLive('real-token'), real, { fetch: supabase.fetch })
      expect(res.status, hostname).toBe(403)
      expect(
        supabase.requests.filter((r) => r.url.pathname === '/auth/v1/signup'),
        hostname,
      ).toHaveLength(0)
    }
  })

  it('[go-live 3] meetaleksi.com never falls back to the always passing test keys', () => {
    expect(humanCheckKeys({}, 'meetaleksi.com')).toBeNull()
    expect(humanCheckKeys({}, 'www.meetaleksi.com')).toBeNull()
  })
})
