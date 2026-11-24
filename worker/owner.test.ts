import { createLocalJWKSet, exportJWK, generateKeyPair, SignJWT, type CryptoKey, type JWK } from 'jose'
import { beforeAll, beforeEach, describe, expect, it, vi, type Mock } from 'vitest'
import { accessKeys } from '../review-site/handler.ts'
import { OWNER_HOST_ATTRIBUTE, OWNER_HOST_MARK } from '../src/lib/owner-host.ts'
import { handleApi } from './api.ts'
import { handleRequest, type WorkerEnv } from './index.ts'
import { ACCESS_REFUSED, ownerHostname, ownerKeySource, type OwnerDeps } from './owner.ts'
import {
  ENV,
  ORIGIN,
  PUBLISHABLE,
  cookieHeader,
  fakeSupabase,
  post,
  type FakeSupabase,
} from './test-fakes.ts'

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md that each test protects.
// The owner page's own hostname: what it answers, the Access token check (job
// 13's), the owner's own sign in, and the private headers. The Access team's
// signing key is made locally for each run.

const OWNER_HOST = 'owner.puhuscribe.example'
const OWNER = `https://${OWNER_HOST}`
const TEAM = 'https://made-up-team.cloudflareaccess.com'
const AUD = 'b'.repeat(64)
const PAGE_HTML =
  '<!doctype html>\n<html lang="en">\n  <head><title>PuhuScribe</title></head>\n  <body><div id="root"></div></body>\n</html>\n'
// The same page as the owner host serves it: marked, so the crash reporter
// sends Cloudflare Access's cookie (src/lib/crash-reporter.ts).
const MARKED_HTML = PAGE_HTML.replace('<html lang="en">', '<html data-puhuscribe-host="owner" lang="en">')

let privateKey: CryptoKey
let otherKey: CryptoKey
let jwk: JWK
let localKeys: ReturnType<typeof createLocalJWKSet>

beforeAll(async () => {
  const pair = await generateKeyPair('RS256', { extractable: true })
  privateKey = pair.privateKey
  otherKey = (await generateKeyPair('RS256')).privateKey
  jwk = { ...(await exportJWK(pair.publicKey)), kid: 'made-up-kid', alg: 'RS256', use: 'sig' }
  localKeys = createLocalJWKSet({ keys: [jwk] })
})

interface TokenOptions {
  key?: CryptoKey
  issuer?: string
  audience?: string
  expires?: string | number
}

async function token(options: TokenOptions = {}): Promise<string> {
  return new SignJWT({ type: 'app' })
    .setProtectedHeader({ alg: 'RS256', kid: 'made-up-kid' })
    .setIssuer(options.issuer ?? TEAM)
    .setAudience(options.audience ?? AUD)
    .setIssuedAt()
    .setExpirationTime(options.expires ?? '1h')
    .sign(options.key ?? privateKey)
}

let supabase: FakeSupabase
let env: WorkerEnv
let deps: OwnerDeps
let dashboardAnswer: unknown
let assetsFetch: Mock<() => Promise<Response>>
const NUMBERS = { active_learners: 3, computed_at: '2026-10-30T10:00:00Z' }

function assets(): Fetcher {
  assetsFetch = vi.fn<() => Promise<Response>>(() =>
    Promise.resolve(
      new Response(PAGE_HTML, { status: 200, headers: { 'content-type': 'text/html; charset=utf-8' } }),
    ),
  )
  return { fetch: assetsFetch, connect: vi.fn() }
}

beforeEach(() => {
  supabase = fakeSupabase()
  dashboardAnswer = NUMBERS
  supabase.rest = (request) => {
    if (request.url.pathname === '/rest/v1/rpc/count_visit') return new Response(null, { status: 204 })
    if (request.url.pathname === '/rest/v1/rpc/owner_dashboard') {
      return new Response(JSON.stringify(dashboardAnswer), {
        status: 200,
        headers: { 'content-type': 'application/json' },
      })
    }
    if (request.url.pathname === '/rest/v1/rpc/report_crash') {
      return new Response('true', { status: 200, headers: { 'content-type': 'application/json' } })
    }
    return undefined
  }
  env = {
    ...ENV,
    ASSETS: assets(),
    OWNER_HOSTNAME: OWNER_HOST,
    OWNER_ACCESS_TEAM_DOMAIN: TEAM,
    OWNER_ACCESS_AUD: AUD,
  }
  deps = { fetch: supabase.fetch, accessKeys: () => localKeys }
})

async function ownerRequest(
  path: string,
  init: RequestInit & { jwt?: string | null; cookie?: string; extra?: Record<string, string> } = {},
): Promise<Request> {
  const headers = new Headers(init.extra ?? {})
  const jwt = init.jwt === undefined ? await token() : init.jwt
  if (jwt !== null) headers.set('Cf-Access-Jwt-Assertion', jwt)
  if (init.cookie) headers.set('cookie', init.cookie)
  if (init.body !== undefined && !headers.has('content-type')) headers.set('content-type', 'application/json')
  return new Request(`${OWNER}${path}`, { method: init.method ?? 'GET', headers, body: init.body })
}

async function signedInCookie(): Promise<string> {
  const guest = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
  return cookieHeader(guest)
}

function context() {
  const waits: Promise<unknown>[] = []
  return { waits, ctx: { waitUntil: (promise: Promise<unknown>) => void waits.push(promise) } }
}

function expectPrivate(res: Response) {
  expect(res.headers.get('x-robots-tag')).toBe('noindex, nofollow')
  expect(res.headers.get('cache-control')).toBe('private, no-store')
  expect(res.headers.get('referrer-policy')).toBe('no-referrer')
  expect(res.headers.get('content-security-policy')).toContain("frame-ancestors 'none'")
  expect(res.headers.get('access-control-allow-origin')).toBeNull()
}

describe('the owner host answers only its own routes', () => {
  it('[analytics 13] serves /learn/owner and /learn/sign-in from the built page', async () => {
    for (const path of ['/learn/owner', '/learn/sign-in']) {
      const res = await handleRequest(await ownerRequest(path), env, deps)
      expect(res.status, path).toBe(200)
      expect(await res.text()).toBe(MARKED_HTML)
    }
  })

  // Round 2 (security note 1): the page needs to know it is on the owner host,
  // so its crash reports carry the Access cookie there and nowhere else.
  it('[analytics 27] marks the owner host page as the owner host, with no stale length or ETag', async () => {
    assetsFetch.mockImplementation(() =>
      Promise.resolve(
        new Response(PAGE_HTML, {
          status: 200,
          headers: {
            'content-type': 'text/html; charset=utf-8',
            'content-length': String(new TextEncoder().encode(PAGE_HTML).length),
            etag: '"abc"',
          },
        }),
      ),
    )
    for (const path of ['/learn/owner', '/learn/sign-in']) {
      const res = await handleRequest(await ownerRequest(path), env, deps)
      expect(res.status, path).toBe(200)
      const body = await res.text()
      expect(body, path).toContain(`<html ${OWNER_HOST_ATTRIBUTE}="${OWNER_HOST_MARK}" lang="en">`)
      expect(res.headers.get('content-length'), path).toBeNull()
      expect(res.headers.get('etag'), path).toBeNull()
      expect(res.headers.get('content-type'), path).toBe('text/html; charset=utf-8')
      expectPrivate(res)
    }
  })

  it('[analytics 27] leaves an answer that is not a page untouched', async () => {
    assetsFetch.mockImplementation(() => Promise.resolve(new Response(null, { status: 304 })))
    const res = await handleRequest(await ownerRequest('/learn/owner'), env, deps)
    expect(res.status).toBe(304)
    expect(await res.text()).toBe('')
  })

  it('[analytics 4] [analytics 27] the app host serves /learn/owner byte for byte, without the owner host mark', async () => {
    const res = await handleRequest(new Request(`${ORIGIN}/learn/owner`), env, deps)
    expect(res.status).toBe(200)
    expect(await res.text()).toBe(PAGE_HTML)
  })

  // Since job 17-landing-page the app's pages live under /learn (src/lib/app-paths.ts). The landing
  // page at "/" is never served on the owner host, and the old /owner and /sign-in forward too.
  it('[analytics 13] sends every other page route to /learn/owner', async () => {
    for (const path of [
      '/',
      '/learn',
      '/learn/session',
      '/learn/voice',
      '/learn/account',
      '/learn/account/email',
      '/learn/account/delete',
      '/learn/privacy',
      '/learn/feedback',
      '/owner',
    ]) {
      const res = await handleRequest(await ownerRequest(path), env, deps)
      expect(res.status, path).toBe(302)
      expect(res.headers.get('location'), path).toBe('/learn/owner')
    }
    const signIn = await handleRequest(await ownerRequest('/sign-in'), env, deps)
    expect(signIn.status).toBe(302)
    expect(signIn.headers.get('location')).toBe('/learn/sign-in')
  })

  it('[analytics 13] answers 404 to every /api route that is not on its list', async () => {
    for (const [path, method] of [
      ['/api/today', 'GET'],
      ['/api/guest', 'POST'],
      ['/api/sessions/today', 'POST'],
      ['/api/feedback', 'POST'],
      ['/api/account/export', 'GET'],
      ['/api/account/delete', 'POST'],
      ['/api/voice', 'GET'],
      ['/api/owner', 'GET'],
      ['/api/owner/other', 'GET'],
    ] as const) {
      const res = await handleRequest(
        await ownerRequest(path, { method, body: method === 'POST' ? '{}' : undefined }),
        env,
        deps,
      )
      expect(res.status, path).toBe(404)
    }
    expect(supabase.requests.filter((r) => r.url.pathname === '/auth/v1/signup')).toHaveLength(0)
  })

  it('[analytics 13] answers the listed /api routes: health, me, sign in, sign out and crash', async () => {
    expect((await handleRequest(await ownerRequest('/api/health'), env, deps)).status).toBe(200)
    expect((await handleRequest(await ownerRequest('/api/me'), env, deps)).status).toBe(200)
    const signIn = await handleRequest(
      await ownerRequest('/api/sign-in', { method: 'POST', body: '{"email":"x"}' }),
      env,
      deps,
    )
    expect(signIn.status).toBe(400)
    const verify = await handleRequest(
      await ownerRequest('/api/sign-in/verify', { method: 'POST', body: '{"email":"x"}' }),
      env,
      deps,
    )
    expect(verify.status).toBe(400)
    const signOut = await handleRequest(
      await ownerRequest('/api/sign-out', { method: 'POST', body: '{}' }),
      env,
      deps,
    )
    expect(signOut.status).toBe(401)
    const crash = await handleRequest(
      await ownerRequest('/api/crash', {
        method: 'POST',
        body: JSON.stringify({
          source: 'browser',
          name: 'Error',
          message: 'm',
          frames: [],
          path: '/learn/owner',
        }),
      }),
      env,
      deps,
    )
    expect(crash.status).toBe(204)
  })

  it('[analytics 13] on the app host, /api/owner/* gets 404', async () => {
    for (const path of ['/api/owner/dashboard', '/api/owner']) {
      const res = await handleRequest(new Request(`${ORIGIN}${path}`), env, deps)
      expect(res.status, path).toBe(404)
    }
  })

  it('[analytics 13] with any of the three settings missing, no host is the owner host', async () => {
    for (const missing of ['OWNER_HOSTNAME', 'OWNER_ACCESS_TEAM_DOMAIN', 'OWNER_ACCESS_AUD'] as const) {
      const partial: WorkerEnv = { ...env, [missing]: '' }
      expect(ownerHostname(partial), missing).toBeNull()
      const withoutToken = await handleRequest(
        await ownerRequest('/api/owner/dashboard', { jwt: null }),
        partial,
        deps,
      )
      // Answered as the app host would: the owner route does not exist there.
      expect(withoutToken.status, missing).toBe(404)
      const omitted = Object.fromEntries(
        Object.entries(env).filter(([name]) => name !== missing),
      ) as WorkerEnv
      expect(ownerHostname(omitted), missing).toBeNull()
    }
    expect(ownerHostname(env)).toBe(OWNER_HOST)
  })
})

describe('lock two: the Worker checks the Access token on every request', () => {
  const refusals: { name: string; jwt: () => Promise<string | null> }[] = [
    { name: 'no header', jwt: () => Promise.resolve(null) },
    { name: 'a malformed token', jwt: () => Promise.resolve('not-a-token') },
    { name: 'a wrong signature', jwt: () => token({ key: otherKey }) },
    { name: 'a wrong audience', jwt: () => token({ audience: 'c'.repeat(64) }) },
    { name: 'a wrong issuer', jwt: () => token({ issuer: 'https://other-team.cloudflareaccess.com' }) },
    { name: 'an expired token', jwt: () => token({ expires: Math.floor(Date.now() / 1000) - 60 }) },
  ]

  for (const { name, jwt } of refusals) {
    it(`[analytics 14] ${name} gets 403 with one plain line, for pages and /api alike`, async () => {
      for (const path of ['/learn/owner', '/api/owner/dashboard', '/api/me', '/learn/session']) {
        const res = await handleRequest(await ownerRequest(path, { jwt: await jwt() }), env, deps)
        expect(res.status, path).toBe(403)
        expect(res.headers.get('content-type')).toBe('text/plain; charset=utf-8')
        expect(await res.text()).toBe(`${ACCESS_REFUSED}\n`)
        expectPrivate(res)
      }
      expect(assetsFetch).not.toHaveBeenCalled()
    })
  }

  it('[analytics 14] a valid token goes on', async () => {
    const res = await handleRequest(await ownerRequest('/learn/owner'), env, deps)
    expect(res.status).toBe(200)
  })

  it('[analytics 14] normally uses the team keys from Cloudflare, never the local test keys', () => {
    const live = { ...env, OWNER_ACCESS_LOCAL_JWKS: JSON.stringify({ keys: [jwk] }) }
    expect(ownerKeySource(live)).toBe(accessKeys)
    expect(ownerKeySource(env)).toBe(accessKeys)
  })

  it('[analytics 14] the local test keys are used only when the owner host is this computer', async () => {
    const local: WorkerEnv = {
      ...env,
      OWNER_HOSTNAME: '127.0.0.1',
      OWNER_ACCESS_LOCAL_JWKS: JSON.stringify({ keys: [jwk] }),
    }
    const request = new Request('https://127.0.0.1:4173/learn/owner', {
      headers: { 'Cf-Access-Jwt-Assertion': await token() },
    })
    const res = await handleRequest(request, local, { fetch: supabase.fetch })
    expect(res.status).toBe(200)
    const broken = await handleRequest(
      new Request('https://127.0.0.1:4173/learn/owner', {
        headers: { 'Cf-Access-Jwt-Assertion': await token() },
      }),
      { ...local, OWNER_ACCESS_LOCAL_JWKS: 'not json' },
      { fetch: supabase.fetch },
    )
    expect(broken.status).toBe(403)
  })
})

describe('lock three: the owner signs in with their own account', () => {
  it('[analytics 15] without a sign in, the dashboard answers 401', async () => {
    const res = await handleRequest(await ownerRequest('/api/owner/dashboard'), env, deps)
    expect(res.status).toBe(401)
    expect(await res.json()).toEqual({ error: 'signed_out' })
  })

  it('[analytics 15] an account not on the owner list gets 403 not_owner and no number', async () => {
    dashboardAnswer = null
    const cookie = await signedInCookie()
    const res = await handleRequest(await ownerRequest('/api/owner/dashboard', { cookie }), env, deps)
    expect(res.status).toBe(403)
    expect(await res.json()).toEqual({ error: 'not_owner' })
  })

  it('[analytics 15] the owner gets the numbers, asked of owner_dashboard() with the owner own token and the publishable key', async () => {
    const cookie = await signedInCookie()
    const res = await handleRequest(await ownerRequest('/api/owner/dashboard', { cookie }), env, deps)
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual(NUMBERS)
    const call = supabase.requests.find((r) => r.url.pathname === '/rest/v1/rpc/owner_dashboard')
    expect(call?.headers.get('apikey')).toBe(PUBLISHABLE)
    const bearer = (call?.headers.get('authorization') ?? '').replace(/^Bearer /, '')
    expect(supabase.issued).toContain(bearer)
  })

  it('[analytics 15] a database fault answers 503', async () => {
    supabase.rest = () => new Response('{"message":"down"}', { status: 500 })
    const cookie = await signedInCookie()
    const res = await handleRequest(await ownerRequest('/api/owner/dashboard', { cookie }), env, deps)
    expect(res.status).toBe(503)
  })
})

describe('owner host answers are private', () => {
  it('[analytics 18] every kind of answer carries the private headers', async () => {
    const cookie = await signedInCookie()
    const answers = [
      await handleRequest(await ownerRequest('/learn/owner'), env, deps),
      await handleRequest(await ownerRequest('/learn/session'), env, deps),
      await handleRequest(await ownerRequest('/api/today'), env, deps),
      await handleRequest(await ownerRequest('/api/health'), env, deps),
      await handleRequest(await ownerRequest('/api/owner/dashboard', { cookie }), env, deps),
      await handleRequest(await ownerRequest('/learn/owner', { jwt: null }), env, deps),
    ]
    for (const res of answers) expectPrivate(res)
  })

  it('[analytics 18] the dashboard accepts only GET', async () => {
    const cookie = await signedInCookie()
    for (const method of ['POST', 'PUT', 'DELETE']) {
      const res = await handleRequest(
        await ownerRequest('/api/owner/dashboard', { method, cookie, body: '{}' }),
        env,
        deps,
      )
      expect(res.status, method).toBe(405)
    }
  })

  it('[analytics 18] the dashboard refuses another origin, the app host included, by Origin or Sec-Fetch-Site', async () => {
    const cookie = await signedInCookie()
    for (const extra of [
      { origin: ORIGIN },
      { origin: 'https://evil.example' },
      { 'sec-fetch-site': 'same-site' },
      { 'sec-fetch-site': 'cross-site' },
    ] as Record<string, string>[]) {
      const res = await handleRequest(
        await ownerRequest('/api/owner/dashboard', { cookie, extra }),
        env,
        deps,
      )
      expect(res.status, JSON.stringify(extra)).toBe(403)
      expect(res.headers.get('access-control-allow-origin')).toBeNull()
    }
    const same = await handleRequest(
      await ownerRequest('/api/owner/dashboard', {
        cookie,
        extra: { origin: OWNER, 'sec-fetch-site': 'same-origin' },
      }),
      env,
      deps,
    )
    expect(same.status).toBe(200)
  })
})

describe('the owner host is not counted', () => {
  it('[analytics 7] requests to the owner host never call count_visit, even when served', async () => {
    const { waits, ctx } = context()
    for (const path of ['/learn/owner', '/learn/sign-in', '/', '/learn/session', '/owner']) {
      const request = await ownerRequest(path, {
        extra: {
          accept: 'text/html',
          'user-agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) Version/17.4 Mobile/15E148 Safari/604.1',
          'sec-fetch-site': 'none',
          'sec-fetch-dest': 'document',
        },
      })
      Object.defineProperty(request, 'cf', { value: { country: 'FI' } })
      const res = await handleRequest(request, env, deps, ctx)
      expect([200, 302], path).toContain(res.status)
    }
    await Promise.all(waits)
    expect(supabase.requests.filter((r) => r.url.pathname === '/rest/v1/rpc/count_visit')).toHaveLength(0)
  })
})

// Fast route reviewers: labels [reviewers N] are the "Done when" statement numbers from
// factory/jobs/reviewers/spec.md. The owner's list of reviewer sign ups and its Delete.
describe('the owner page reviewer sign ups', () => {
  const ROW = {
    id: '0b7e2c1a-8f3d-4c2b-9a1e-5d6f7a8b9c0d',
    name: 'Aino Virtanen',
    email: 'aino@example.fi',
    thanks_name: null,
    created_at: '2026-11-24T10:00:00+00:00',
  }
  let listAnswer: unknown
  let deleteAnswer: unknown
  let deleted: unknown[]

  beforeEach(() => {
    listAnswer = [ROW]
    deleteAnswer = true
    deleted = []
    const before = supabase.rest
    supabase.rest = (request) => {
      const reply = (value: unknown) =>
        new Response(JSON.stringify(value), { status: 200, headers: { 'content-type': 'application/json' } })
      if (request.url.pathname === '/rest/v1/rpc/owner_reviewer_signups') return reply(listAnswer)
      if (request.url.pathname === '/rest/v1/rpc/owner_delete_reviewer_signup') {
        deleted.push(JSON.parse(request.body))
        return reply(deleteAnswer)
      }
      return before?.(request)
    }
  })

  const remove = async (body: unknown, cookie?: string, extra?: Record<string, string>) =>
    handleRequest(
      await ownerRequest('/api/owner/reviewers/delete', {
        method: 'POST',
        body: JSON.stringify(body),
        ...(cookie ? { cookie } : {}),
        ...(extra ? { extra } : {}),
      }),
      env,
      deps,
    )

  it('[reviewers 5] the owner gets every sign up, asked of owner_reviewer_signups() with the owner own token', async () => {
    const cookie = await signedInCookie()
    const res = await handleRequest(await ownerRequest('/api/owner/reviewers', { cookie }), env, deps)
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ signups: [ROW] })
    expectPrivate(res)
    const call = supabase.requests.find((r) => r.url.pathname === '/rest/v1/rpc/owner_reviewer_signups')
    expect(call?.headers.get('apikey')).toBe(PUBLISHABLE)
    const bearer = (call?.headers.get('authorization') ?? '').replace(/^Bearer /, '')
    expect(supabase.issued).toContain(bearer)
  })

  it('[reviewers 5] without a sign in 401, and an account not on the owner list 403 with no row', async () => {
    expect((await handleRequest(await ownerRequest('/api/owner/reviewers'), env, deps)).status).toBe(401)
    listAnswer = null
    const cookie = await signedInCookie()
    const res = await handleRequest(await ownerRequest('/api/owner/reviewers', { cookie }), env, deps)
    expect(res.status).toBe(403)
    expect(await res.json()).toEqual({ error: 'not_owner' })
  })

  it('[reviewers 5] without the Access token, the list and Delete answer 403 and reach no database', async () => {
    const cookie = await signedInCookie()
    const list = await handleRequest(
      await ownerRequest('/api/owner/reviewers', { cookie, jwt: null }),
      env,
      deps,
    )
    expect(list.status).toBe(403)
    const del = await handleRequest(
      await ownerRequest('/api/owner/reviewers/delete', {
        method: 'POST',
        body: JSON.stringify({ id: ROW.id }),
        cookie,
        jwt: null,
      }),
      env,
      deps,
    )
    expect(del.status).toBe(403)
    expect(deleted).toEqual([])
  })

  it('[reviewers 5] the app host has no owner reviewer routes', async () => {
    const res = await handleRequest(new Request(`${ORIGIN}/api/owner/reviewers`), env, deps)
    expect(res.status).toBe(404)
  })

  it('[reviewers 5] Delete removes one sign up by its id, only for the owner', async () => {
    const cookie = await signedInCookie()
    const res = await remove({ id: ROW.id }, cookie)
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ deleted: true })
    expect(deleted).toEqual([{ p_id: ROW.id }])
    expectPrivate(res)
    deleteAnswer = false
    expect((await remove({ id: ROW.id }, cookie)).status).toBe(404)
    deleteAnswer = null
    const notOwner = await remove({ id: ROW.id }, cookie)
    expect(notOwner.status).toBe(403)
    expect(await notOwner.json()).toEqual({ error: 'not_owner' })
  })

  it('[reviewers 5] Delete refuses a missing or odd id, GET, another site and no sign in, deleting nothing', async () => {
    const cookie = await signedInCookie()
    for (const body of [{}, { id: 'all' }, { id: `${ROW.id}' or 1=1` }, { id: 7 }]) {
      expect((await remove(body, cookie)).status, JSON.stringify(body)).toBe(400)
    }
    expect(
      (await handleRequest(await ownerRequest('/api/owner/reviewers/delete', { cookie }), env, deps)).status,
    ).toBe(405)
    expect((await remove({ id: ROW.id }, cookie, { origin: 'https://evil.example' })).status).toBe(403)
    expect((await remove({ id: ROW.id }, cookie, { 'sec-fetch-site': 'cross-site' })).status).toBe(403)
    expect((await remove({ id: ROW.id })).status).toBe(401)
    expect(deleted).toEqual([])
  })

  it('[reviewers 5] the list refuses another site and accepts only GET', async () => {
    const cookie = await signedInCookie()
    const cross = await handleRequest(
      await ownerRequest('/api/owner/reviewers', { cookie, extra: { 'sec-fetch-site': 'cross-site' } }),
      env,
      deps,
    )
    expect(cross.status).toBe(403)
    const post = await handleRequest(
      await ownerRequest('/api/owner/reviewers', { method: 'POST', body: '{}', cookie }),
      env,
      deps,
    )
    expect(post.status).toBe(405)
  })
})

// Fast route review-links: labels [review-links N] are the "Done when" statement numbers from
// factory/jobs/review-links/spec.md. The owner's "Send review link", the links' progress and
// the answers to look at.
describe('the owner page review links', () => {
  const SIGNUP = '0b7e2c1a-8f3d-4c2b-9a1e-5d6f7a8b9c0d'
  const TOKEN = 'T'.repeat(43)
  const LINK_ROW = {
    id: '5a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d',
    signup_id: SIGNUP,
    batch: 2,
    sent_at: '2026-11-24T12:00:00+00:00',
    lines: 210,
    answered: 40,
  }
  const OVERVIEW = { links: [LINK_ROW], answers: [] }
  let created: unknown
  let createCalls: Record<string, unknown>[]
  let removed: Record<string, unknown>[]
  let overviewAnswer: unknown
  let emails: { to: { name: string; email: string }; link: string }[]
  let emailWorks: boolean

  beforeEach(() => {
    created = {
      found: true,
      id: LINK_ROW.id,
      batch: 2,
      sent_at: LINK_ROW.sent_at,
      name: 'Aino Virtanen',
      email: 'aino@example.fi',
    }
    createCalls = []
    removed = []
    overviewAnswer = OVERVIEW
    emails = []
    emailWorks = true
    env = { ...env, BREVO_API_KEY: 'test-brevo-key', CANONICAL_HOST: 'meetaleksi.com' }
    deps = {
      ...deps,
      reviewToken: () => TOKEN,
      reviewLinkEmail: (_env, to, link) => {
        emails.push({ to, link })
        return Promise.resolve(emailWorks)
      },
    }
    const before = supabase.rest
    supabase.rest = (request) => {
      const reply = (value: unknown) =>
        new Response(JSON.stringify(value), { status: 200, headers: { 'content-type': 'application/json' } })
      if (request.url.pathname === '/rest/v1/rpc/owner_review_overview') return reply(overviewAnswer)
      if (request.url.pathname === '/rest/v1/rpc/owner_create_review_link') {
        createCalls.push(JSON.parse(request.body) as Record<string, unknown>)
        return reply(created)
      }
      if (request.url.pathname === '/rest/v1/rpc/owner_delete_review_link') {
        removed.push(JSON.parse(request.body) as Record<string, unknown>)
        return reply(true)
      }
      return before?.(request)
    }
  })

  const send = async (body: unknown, cookie?: string, extra?: Record<string, string>) =>
    handleRequest(
      await ownerRequest('/api/owner/review-links/send', {
        method: 'POST',
        body: JSON.stringify(body),
        ...(cookie ? { cookie } : {}),
        ...(extra ? { extra } : {}),
      }),
      env,
      deps,
    )

  it('[review-links 1] one press records the batch and sends one email with the link on the public address', async () => {
    const cookie = await signedInCookie()
    const res = await send({ signupId: SIGNUP, batch: 2 }, cookie)
    expect(res.status).toBe(201)
    expectPrivate(res)
    expect(await res.json()).toEqual({ sent: true, id: LINK_ROW.id, batch: 2, sent_at: LINK_ROW.sent_at })
    expect(createCalls).toEqual([{ p_signup_id: SIGNUP, p_batch: 2, p_token: TOKEN }])
    expect(emails).toEqual([
      {
        to: { name: 'Aino Virtanen', email: 'aino@example.fi' },
        link: `https://meetaleksi.com/review/${TOKEN}`,
      },
    ])
    expect(removed).toEqual([])
    const call = supabase.requests.find((r) => r.url.pathname === '/rest/v1/rpc/owner_create_review_link')
    const bearer = (call?.headers.get('authorization') ?? '').replace(/^Bearer /, '')
    expect(supabase.issued).toContain(bearer)
  })

  it('[review-links 2] the secret never comes back to the owner page', async () => {
    const cookie = await signedInCookie()
    const res = await send({ signupId: SIGNUP, batch: 2 }, cookie)
    expect(await res.text()).not.toContain(TOKEN)
  })

  it('[review-links 1] without the Brevo settings nothing is recorded or sent, and the answer says so', async () => {
    env = { ...env, BREVO_API_KEY: '' }
    const cookie = await signedInCookie()
    const res = await send({ signupId: SIGNUP, batch: 1 }, cookie)
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'email_not_set' })
    expect(createCalls).toEqual([])
    expect(emails).toEqual([])
    const list = await handleRequest(await ownerRequest('/api/owner/review-links', { cookie }), env, deps)
    expect((await list.json<{ emailReady: boolean }>()).emailReady).toBe(false)
  })

  it('[review-links 1] when Brevo does not take the email, the new link is deleted again', async () => {
    emailWorks = false
    const cookie = await signedInCookie()
    const res = await send({ signupId: SIGNUP, batch: 3 }, cookie)
    expect(res.status).toBe(502)
    expect(await res.json()).toEqual({ error: 'not_sent' })
    expect(removed).toEqual([{ p_link_id: LINK_ROW.id }])
  })

  it('[review-links 1] "Send review link" can be pressed again: each send makes a new link', async () => {
    let n = 0
    deps = { ...deps, reviewToken: () => String(n++).padStart(43, 'k') }
    const cookie = await signedInCookie()
    expect((await send({ signupId: SIGNUP, batch: 1 }, cookie)).status).toBe(201)
    expect((await send({ signupId: SIGNUP, batch: 1 }, cookie)).status).toBe(201)
    expect(createCalls.map((c) => c.p_token)).toEqual(['k'.repeat(42) + '0', 'k'.repeat(42) + '1'])
    expect(emails[0]?.link).not.toBe(emails[1]?.link)
  })

  it('[review-links 1] a batch outside 1 to 4, an odd id, another site, GET or no sign in records nothing', async () => {
    const cookie = await signedInCookie()
    for (const body of [
      { signupId: SIGNUP, batch: 0 },
      { signupId: SIGNUP, batch: 5 },
      { signupId: SIGNUP, batch: '1' },
      { signupId: SIGNUP, batch: 1.5 },
      { signupId: 'all', batch: 1 },
      { batch: 1 },
    ])
      expect((await send(body, cookie)).status, JSON.stringify(body)).toBe(400)
    expect(
      (await send({ signupId: SIGNUP, batch: 1 }, cookie, { origin: 'https://evil.example' })).status,
    ).toBe(403)
    expect(
      (await send({ signupId: SIGNUP, batch: 1 }, cookie, { 'sec-fetch-site': 'cross-site' })).status,
    ).toBe(403)
    expect(
      (await handleRequest(await ownerRequest('/api/owner/review-links/send', { cookie }), env, deps)).status,
    ).toBe(405)
    expect((await send({ signupId: SIGNUP, batch: 1 })).status).toBe(401)
    expect(createCalls).toEqual([])
    expect(emails).toEqual([])
  })

  it('[review-links 1] an account not on the owner list gets 403, and a sign up that is gone 404, with no email', async () => {
    const cookie = await signedInCookie()
    created = null
    const notOwner = await send({ signupId: SIGNUP, batch: 1 }, cookie)
    expect(notOwner.status).toBe(403)
    expect(await notOwner.json()).toEqual({ error: 'not_owner' })
    created = { found: false }
    expect((await send({ signupId: SIGNUP, batch: 1 }, cookie)).status).toBe(404)
    expect(emails).toEqual([])
  })

  it('[review-links 1] without the Access token nothing is recorded or sent', async () => {
    const cookie = await signedInCookie()
    const res = await handleRequest(
      await ownerRequest('/api/owner/review-links/send', {
        method: 'POST',
        body: JSON.stringify({ signupId: SIGNUP, batch: 1 }),
        cookie,
        jwt: null,
      }),
      env,
      deps,
    )
    expect(res.status).toBe(403)
    expect(createCalls).toEqual([])
    expect(emails).toEqual([])
  })

  it('[review-links 1] without CANONICAL_HOST (a local run) the link uses the request address', async () => {
    env = { ...env, CANONICAL_HOST: '' }
    const cookie = await signedInCookie()
    await send({ signupId: SIGNUP, batch: 1 }, cookie)
    expect(emails[0]?.link).toBe(`${OWNER}/review/${TOKEN}`)
  })

  it('[review-links 6] the owner gets every link with its progress and the answers, and whether email works', async () => {
    const cookie = await signedInCookie()
    const res = await handleRequest(await ownerRequest('/api/owner/review-links', { cookie }), env, deps)
    expect(res.status).toBe(200)
    expectPrivate(res)
    expect(await res.json()).toEqual({ ...OVERVIEW, emailReady: true })
    overviewAnswer = null
    const notOwner = await handleRequest(await ownerRequest('/api/owner/review-links', { cookie }), env, deps)
    expect(notOwner.status).toBe(403)
    expect((await handleRequest(await ownerRequest('/api/owner/review-links'), env, deps)).status).toBe(401)
  })

  it('[review-links 6] the app host has no owner review link routes', async () => {
    for (const path of ['/api/owner/review-links', '/api/owner/review-links/send']) {
      const res = await handleRequest(new Request(`${ORIGIN}${path}`), env, deps)
      expect(res.status, path).toBe(404)
    }
    expect(createCalls).toEqual([])
  })

  it('[review-links 6] the list refuses another site and accepts only GET', async () => {
    const cookie = await signedInCookie()
    const cross = await handleRequest(
      await ownerRequest('/api/owner/review-links', { cookie, extra: { 'sec-fetch-site': 'cross-site' } }),
      env,
      deps,
    )
    expect(cross.status).toBe(403)
    const post = await handleRequest(
      await ownerRequest('/api/owner/review-links', { method: 'POST', body: '{}', cookie }),
      env,
      deps,
    )
    expect(post.status).toBe(405)
  })
})
