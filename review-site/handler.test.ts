import { createLocalJWKSet, exportJWK, generateKeyPair, SignJWT, type CryptoKey, type JWK } from 'jose'
import { afterEach, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest'
import {
  accessKeys,
  handleReviewRequest,
  hasValidAccessToken,
  PAGE_CSP,
  SITE_CSP,
  NOT_FOUND_HTML,
  type KeySource,
  type ReviewEnv,
} from './handler.ts'

// Labels [site N] are the "Done when" statement numbers from
// factory/jobs/13-review-site/spec.md that each test protects.
//
// The Access team's signing key is made locally for each run. The files are
// served by a stand in for the assets binding that knows the same paths the
// build writes, with html_handling's default behaviour for the index.

const TEAM = 'https://made-up-team.cloudflareaccess.com'
const AUD = 'a'.repeat(64)
const PAGE_HTML = '<!doctype html><title>Review round 1</title>'

let privateKey: CryptoKey
let otherKey: CryptoKey
let jwk: JWK
// The stand in for the Access team's key source is a spy, so a test can prove
// the Worker never asked for keys at all (and so never fetched them from
// anywhere) when its settings are missing or malformed.
const keys = vi.fn<KeySource>()

beforeAll(async () => {
  const pair = await generateKeyPair('RS256', { extractable: true })
  privateKey = pair.privateKey
  otherKey = (await generateKeyPair('RS256')).privateKey
  jwk = { ...(await exportJWK(pair.publicKey)), kid: 'made-up-kid', alg: 'RS256', use: 'sig' }
  const local = createLocalJWKSet({ keys: [jwk] })
  keys.mockImplementation(() => local)
})

beforeEach(() => {
  keys.mockClear()
})

afterEach(() => {
  vi.unstubAllGlobals()
})

interface TokenOptions {
  key?: CryptoKey
  issuer?: string
  audience?: string
  expires?: string | number
  noExpiry?: boolean
}

async function token(options: TokenOptions = {}): Promise<string> {
  let jwt = new SignJWT({ type: 'app' })
    .setProtectedHeader({ alg: 'RS256', kid: 'made-up-kid' })
    .setIssuer(options.issuer ?? TEAM)
    .setAudience(options.audience ?? AUD)
    .setIssuedAt()
  if (!options.noExpiry) jwt = jwt.setExpirationTime(options.expires ?? '1h')
  return jwt.sign(options.key ?? privateKey)
}

const assetsCalls: string[] = []

const FILES: Record<string, { body: string; type: string }> = {
  '/': { body: '<!doctype html><title>PuhuScribe review</title>', type: 'text/html; charset=utf-8' },
  '/robots.txt': { body: 'User-agent: *\nDisallow: /\n', type: 'text/plain; charset=utf-8' },
  '/listed-dialogue/round-1': { body: PAGE_HTML, type: 'text/html; charset=utf-8' },
}

const ASSETS = {
  fetch(input: RequestInfo | URL): Promise<Response> {
    const request = new Request(input)
    const path = new URL(request.url).pathname
    assetsCalls.push(`${request.method} ${path}`)
    if (path === '/listed-dialogue/round-1.html' || path === '/index.html') {
      const to = path === '/index.html' ? '/' : '/listed-dialogue/round-1'
      return Promise.resolve(new Response(null, { status: 307, headers: { Location: to } }))
    }
    const file = FILES[path]
    if (!file) return Promise.resolve(new Response(null, { status: 404 }))
    return Promise.resolve(new Response(file.body, { headers: { 'Content-Type': file.type, ETag: '"x"' } }))
  },
} as unknown as Fetcher

const env = { ASSETS, ACCESS_TEAM_DOMAIN: TEAM, ACCESS_AUD: AUD }

async function get(path: string, init: RequestInit & { jwt?: string } = {}, environment: ReviewEnv = env) {
  const headers = new Headers(init.headers)
  if (init.jwt) headers.set('Cf-Access-Jwt-Assertion', init.jwt)
  return handleReviewRequest(
    new Request(`https://puhuscribe.exentrik.co${path}`, { ...init, headers }),
    environment,
    keys,
  )
}

function expectSharedHeaders(res: Response): void {
  expect(res.headers.get('X-Robots-Tag')).toBe('noindex, nofollow, noarchive')
  expect(res.headers.get('Cache-Control')).toBe('private, no-store')
  expect(res.headers.get('Referrer-Policy')).toBe('no-referrer')
  expect(res.headers.get('X-Content-Type-Options')).toBe('nosniff')
  expect(res.headers.get('Content-Security-Policy')).toContain("frame-ancestors 'none'")
}

describe('the second lock: the Access token check', () => {
  it('[site 6] a valid token gets the file', async () => {
    const res = await get('/listed-dialogue/round-1', { jwt: await token() })
    expect(res.status).toBe(200)
    expect(await res.text()).toBe(PAGE_HTML)
    expect(keys).toHaveBeenCalledWith(TEAM)
  })

  it('[site 6] no header gets 403 with one plain line and no file', async () => {
    assetsCalls.length = 0
    const res = await get('/listed-dialogue/round-1')
    expect(res.status).toBe(403)
    const body = await res.text()
    expect(body).toBe('This site is private. Sign in through its Cloudflare Access page to open it.\n')
    expect(body.split('\n').filter(Boolean)).toHaveLength(1)
    expect(assetsCalls).toEqual([])
  })

  it('[site 6] a malformed token gets 403', async () => {
    for (const jwt of ['not-a-token', 'a.b.c', `${await token()}x`]) {
      expect((await get('/', { jwt })).status, jwt).toBe(403)
    }
  })

  it('[site 6] a token signed by another key gets 403', async () => {
    expect((await get('/', { jwt: await token({ key: otherKey }) })).status).toBe(403)
  })

  it('[site 6] a token for another Access application (wrong audience) gets 403', async () => {
    expect((await get('/', { jwt: await token({ audience: 'b'.repeat(64) }) })).status).toBe(403)
  })

  it('[site 6] a token from another team (wrong issuer) gets 403', async () => {
    expect(
      (await get('/', { jwt: await token({ issuer: 'https://other-team.cloudflareaccess.com' }) })).status,
    ).toBe(403)
  })

  it('[site 6] an expired token gets 403', async () => {
    const expired = await token({ expires: Math.floor(Date.now() / 1000) - 120 })
    expect((await get('/', { jwt: expired })).status).toBe(403)
  })

  it('[site 6] a token with no expiry gets 403', async () => {
    expect((await get('/', { jwt: await token({ noExpiry: true }) })).status).toBe(403)
  })

  it('[site 6] an unsigned token (alg none) gets 403', async () => {
    const [, payload] = (await token()).split('.')
    const header = btoa(JSON.stringify({ alg: 'none', kid: 'made-up-kid' })).replace(/=+$/, '')
    expect((await get('/', { jwt: `${header}.${payload ?? ''}.` })).status).toBe(403)
  })

  it('[site 6] when either setting is missing, everything gets 403 and no keys are asked for, even with a valid token', async () => {
    const jwt = await token()
    for (const missing of [
      { ASSETS, ACCESS_AUD: AUD },
      { ASSETS, ACCESS_TEAM_DOMAIN: TEAM },
      { ASSETS },
      { ASSETS, ACCESS_TEAM_DOMAIN: '', ACCESS_AUD: '' },
    ]) {
      for (const path of ['/', '/robots.txt', '/listed-dialogue/round-1']) {
        expect(
          (await get(path, { jwt }, missing)).status,
          `${path} ${JSON.stringify(Object.keys(missing))}`,
        ).toBe(403)
      }
    }
    expect(keys).not.toHaveBeenCalled()
  })

  it('[site 6] a team domain that is not a cloudflareaccess.com address is refused, so keys are never fetched elsewhere', async () => {
    // Each token is signed by the key the key source hands out and issued by the
    // same domain, so only the domain check stands between it and a 200.
    for (const domain of [
      'https://evil.example',
      'https://made-up-team.cloudflareaccess.com.evil.example',
      'http://made-up-team.cloudflareaccess.com',
      'https://made-up-team.cloudflareaccess.com/',
    ]) {
      const jwt = await token({ issuer: domain })
      const res = await get('/', { jwt }, { ASSETS, ACCESS_TEAM_DOMAIN: domain, ACCESS_AUD: AUD })
      expect(res.status, domain).toBe(403)
    }
    expect(keys).not.toHaveBeenCalled()
  })

  it('[site 6] an AUD setting that is not a 64 character tag is refused before any keys are asked for', async () => {
    for (const aud of ['not-an-aud-tag', 'A'.repeat(64), 'a'.repeat(63)]) {
      const jwt = await token({ audience: aud })
      const res = await get('/', { jwt }, { ASSETS, ACCESS_TEAM_DOMAIN: TEAM, ACCESS_AUD: aud })
      expect(res.status, aud).toBe(403)
    }
    expect(keys).not.toHaveBeenCalled()
  })

  it('[site 6] the real key source fetches the keys from <team domain>/cdn-cgi/access/certs', async () => {
    const fetched: string[] = []
    vi.stubGlobal('fetch', (input: RequestInfo | URL) => {
      fetched.push(String(input instanceof Request ? input.url : input))
      return Promise.resolve(Response.json({ keys: [jwk] }))
    })
    const request = new Request('https://puhuscribe.exentrik.co/', {
      headers: { 'Cf-Access-Jwt-Assertion': await token() },
    })
    expect(await hasValidAccessToken(request, env, accessKeys)).toBe(true)
    expect(fetched).toEqual([`${TEAM}/cdn-cgi/access/certs`])
  })
})

describe('search engines kept out, and no framing', () => {
  it('[site 5] the index gets the shared headers and the strict policy', async () => {
    const res = await get('/', { jwt: await token() })
    expect(res.status).toBe(200)
    expectSharedHeaders(res)
    expect(res.headers.get('Content-Security-Policy')).toBe(
      "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
    )
    expect(SITE_CSP).toBe(res.headers.get('Content-Security-Policy'))
  })

  it("[site 5] a review page keeps its own policy; the Worker adds only frame-ancestors 'none'", async () => {
    const res = await get('/listed-dialogue/round-1', { jwt: await token() })
    expectSharedHeaders(res)
    expect(res.headers.get('Content-Security-Policy')).toBe(PAGE_CSP)
    expect(PAGE_CSP).toBe("frame-ancestors 'none'")
    expect(await res.text()).toBe(PAGE_HTML)
  })

  it('[site 5] robots.txt, 403, 404, 405 and redirects carry the headers too', async () => {
    const jwt = await token()
    const responses = [
      await get('/robots.txt', { jwt }),
      await get('/'),
      await get('/nothing-here', { jwt }),
      await get('/', { method: 'POST', jwt }),
      await get('/listed-dialogue/round-1.html', { jwt }),
    ]
    expect(responses.map((r) => r.status)).toEqual([200, 403, 404, 405, 307])
    for (const res of responses) {
      expectSharedHeaders(res)
      expect(res.headers.get('Content-Security-Policy')).toMatch(
        /^default-src 'none'|^frame-ancestors 'none'$/,
      )
    }
    expect(await responses[0]?.text()).toBe('User-agent: *\nDisallow: /\n')
    expect(responses[4]?.headers.get('Location')).toBe('/listed-dialogue/round-1')
  })
})

describe('read only', () => {
  it.each(['POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'])(
    '[site 7] %s gets 405 and touches no file',
    async (method) => {
      assetsCalls.length = 0
      const res = await get('/listed-dialogue/round-1', { method, jwt: await token() })
      expect(res.status).toBe(405)
      expect(res.headers.get('Allow')).toBe('GET, HEAD')
      expect(assetsCalls).toEqual([])
    },
  )

  it('[site 7] HEAD is answered with the headers and no body', async () => {
    const res = await get('/listed-dialogue/round-1', { method: 'HEAD', jwt: await token() })
    expect(res.status).toBe(200)
    expect(res.headers.get('Content-Type')).toBe('text/html; charset=utf-8')
    expect(await res.text()).toBe('')
  })

  it('[site 7] a path with no file gets 404 with no list of files', async () => {
    const jwt = await token()
    for (const path of [
      '/unlisted-dialogue/round-1',
      '/content/drafts/listed-dialogue/draft.json',
      '/listed-dialogue/audio/1-puhe.mp3',
      '/listed-dialogue/round-1.json',
      '/review-site/dialogues.json',
      '/listed-dialogue/',
      '/listed-dialogue',
      '/../content/reviews/x/round-1.json',
      '/%2e%2e/content',
    ]) {
      const res = await get(path, { jwt })
      expect(res.status, path).toBe(404)
      expect(res.headers.get('Content-Type'), path).toBe('text/html; charset=utf-8')
      expect(await res.text(), path).toBe(NOT_FOUND_HTML)
    }
  })

  it('[site 7] the 404 page links back to the start page and lists no file', async () => {
    expect(NOT_FOUND_HTML).toContain('<p>Not found. <a href="/"')
    expect(NOT_FOUND_HTML).toContain('>Go to the start page</a></p>')
    expect([...NOT_FOUND_HTML.matchAll(/href="([^"]*)"/g)].map((m) => m[1])).toEqual(['/'])
    expect(NOT_FOUND_HTML).not.toMatch(/<script|src=|round-|\.json|\.mp3|dialogue/i)
    const head = await get('/nothing-here', { method: 'HEAD', jwt: await token() })
    expect(head.status).toBe(404)
    expect(await head.text()).toBe('')
  })

  it('[site 7] paths outside the site shape are refused before the assets are asked', async () => {
    assetsCalls.length = 0
    const jwt = await token()
    await get('/content/drafts/listed-dialogue/draft.json', { jwt })
    await get('/listed-dialogue/round-1.json', { jwt })
    expect(assetsCalls).toEqual([])
  })

  it('[site 7] the assets are asked with a plain GET, also for HEAD', async () => {
    assetsCalls.length = 0
    await get('/', { method: 'HEAD', jwt: await token() })
    expect(assetsCalls).toEqual(['GET /'])
  })
})
