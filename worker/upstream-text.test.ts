import { describe, expect, it } from 'vitest'
import { handleApi } from './api.ts'
import type { Fetch } from './learner-auth.ts'
import { ENV, PROJECT, PUBLISHABLE, cookieHeader, fakeSupabase, get, post } from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md, and, for the protection moved from the
// retired worker/visits.test.ts (statement 21), factory/jobs/2-smoke/spec.md.
// When Supabase fails with text that holds the project address and the key,
// none of it reaches the answer: the Worker answers with its own short JSON.

const LEAK = `upstream said: ${PROJECT}/rest/v1 key=${PUBLISHABLE} Bearer secret-looking-token`

function leaking(base: Fetch, which: 'signup' | 'user' | 'rest', status: number): Fetch {
  return async (input, init) => {
    const url = new URL(new Request(input, init).url)
    const hit =
      (which === 'signup' && url.pathname === '/auth/v1/signup') ||
      (which === 'user' && url.pathname === '/auth/v1/user') ||
      (which === 'rest' && url.pathname.startsWith('/rest/v1/'))
    if (!hit) return base(input, init)
    return new Response(JSON.stringify({ message: LEAK, msg: LEAK, code: 'XX000', hint: LEAK }), {
      status,
      headers: { 'content-type': 'application/json' },
    })
  }
}

function expectNoUpstreamText(text: string) {
  expect(text).not.toContain(PROJECT)
  expect(text).not.toContain('fake-ref')
  expect(text).not.toContain(PUBLISHABLE)
  expect(text).not.toContain('upstream said')
  expect(text).not.toContain('secret-looking-token')
}

async function signedIn() {
  const supabase = fakeSupabase()
  const res = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
  return { supabase, cookie: cookieHeader(res) }
}

const SESSION = '00000000-0000-4000-8000-000000000001'

describe('Supabase failure text never reaches the answer', () => {
  for (const status of [400, 500]) {
    it(`[smoke 6] [session 2] POST /api/guest when sign up fails with ${String(status)}`, async () => {
      const supabase = fakeSupabase()
      const res = await handleApi(post('/api/guest'), ENV, {
        fetch: leaking(supabase.fetch, 'signup', status),
      })
      expect(res.status).toBe(503)
      expectNoUpstreamText(await res.text())
    })
  }

  it('[smoke 6] [session 4] GET /api/today when Supabase Auth fails', async () => {
    const { supabase, cookie } = await signedIn()
    const res = await handleApi(get('/api/today', cookie), ENV, {
      fetch: leaking(supabase.fetch, 'user', 500),
    })
    expect(res.status).toBe(503)
    expectNoUpstreamText(await res.text())
  })

  it('[smoke 6] [session 6] GET /api/today and POST /api/sessions/today when the database fails', async () => {
    const { supabase, cookie } = await signedIn()
    const fetch = leaking(supabase.fetch, 'rest', 500)
    for (const request of [get('/api/today', cookie), post('/api/sessions/today', { cookie })]) {
      const res = await handleApi(request, ENV, { fetch })
      expect(res.status, request.url).toBe(503)
      expectNoUpstreamText(await res.text())
    }
  })

  it('[smoke 6] [session 15] the step and complete routes when the database fails', async () => {
    const { supabase, cookie } = await signedIn()
    const fetch = leaking(supabase.fetch, 'rest', 500)
    for (const request of [
      post(`/api/sessions/${SESSION}/step`, { cookie, body: JSON.stringify({ step: 'hear' }) }),
      post(`/api/sessions/${SESSION}/complete`, { cookie }),
    ]) {
      const res = await handleApi(request, ENV, { fetch })
      expect(res.status, request.url).toBe(503)
      expectNoUpstreamText(await res.text())
    }
  })
})
