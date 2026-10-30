import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { handleRequest, type WorkerEnv } from './index.ts'
import { ROBOT_PATTERNS, countsAsVisit, isRobot, visitCountry } from './visits.ts'
import { ENV, ORIGIN, PUBLISHABLE, fakeSupabase, type FakeSupabase } from './test-fakes.ts'

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md that each test protects.
// The visit count: what counts as one visit, the country, and that counting
// never changes or slows the page.

const BROWSER =
  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1'
const OLD_ANDROID =
  'Mozilla/5.0 (Linux; Android 9; SM-J530F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.136 Mobile Safari/537.36'

const ARRIVAL: Record<string, string> = {
  accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  'user-agent': BROWSER,
  'sec-fetch-site': 'none',
  'sec-fetch-dest': 'document',
  'sec-fetch-mode': 'navigate',
}

function page(
  path: string,
  headers: Record<string, string | null> = {},
  init: RequestInit = {},
  country?: unknown,
): Request {
  const all = new Headers()
  for (const [name, value] of Object.entries({ ...ARRIVAL, ...headers }))
    if (value !== null) all.set(name, value)
  const request = new Request(`${ORIGIN}${path}`, { ...init, headers: all })
  if (country !== undefined) Object.defineProperty(request, 'cf', { value: { country } })
  return request
}

// Each rule: one request that counts and one that does not (statement 1).
const CASES: { name: string; request: () => Request; counts: boolean }[] = [
  { name: 'a typed address or bookmark of / (Sec-Fetch-Site none)', request: () => page('/'), counts: true },
  {
    name: 'a reload of / (Sec-Fetch-Site none)',
    request: () => page('/', { 'cache-control': 'max-age=0' }),
    counts: true,
  },
  {
    name: 'a link from another site',
    request: () => page('/', { 'sec-fetch-site': 'cross-site' }),
    counts: true,
  },
  {
    name: 'a link from a sister site',
    request: () => page('/session', { 'sec-fetch-site': 'same-site' }),
    counts: true,
  },
  {
    name: 'a move from / to /session inside the app',
    request: () => page('/session', { 'sec-fetch-site': 'same-origin', referer: `${ORIGIN}/` }),
    counts: false,
  },
  {
    name: 'an old browser with no Sec-Fetch-* headers arriving from a search engine',
    request: () =>
      page('/', {
        'sec-fetch-site': null,
        'sec-fetch-dest': null,
        'sec-fetch-mode': null,
        'user-agent': OLD_ANDROID,
        referer: 'https://www.google.com/',
      }),
    counts: true,
  },
  {
    name: 'an old browser with no Sec-Fetch-* headers and no Referer',
    request: () => page('/', { 'sec-fetch-site': null, 'sec-fetch-dest': null, 'user-agent': OLD_ANDROID }),
    counts: true,
  },
  {
    name: 'an old browser moving inside the app (Referer from this address)',
    request: () =>
      page('/account', { 'sec-fetch-site': null, 'sec-fetch-dest': null, referer: `${ORIGIN}/session` }),
    counts: false,
  },
  { name: 'HEAD of /', request: () => page('/', {}, { method: 'HEAD' }), counts: false },
  { name: 'POST to /', request: () => page('/', {}, { method: 'POST', body: '{}' }), counts: false },
  { name: '/api/today', request: () => page('/api/today'), counts: false },
  { name: 'a file, /assets/index.js', request: () => page('/assets/index.js'), counts: false },
  { name: 'a path that is not a page, /about', request: () => page('/about'), counts: false },
  { name: 'every page route counts: /account/email', request: () => page('/account/email'), counts: true },
  { name: 'no text/html in Accept', request: () => page('/', { accept: 'application/json' }), counts: false },
  { name: 'no Accept header', request: () => page('/', { accept: null }), counts: false },
  { name: 'Sec-Fetch-Dest iframe', request: () => page('/', { 'sec-fetch-dest': 'iframe' }), counts: false },
  {
    name: 'Sec-Fetch-Dest empty (a script fetch)',
    request: () => page('/', { 'sec-fetch-dest': 'empty' }),
    counts: false,
  },
  {
    name: 'a prefetch (Sec-Purpose)',
    request: () => page('/', { 'sec-purpose': 'prefetch' }),
    counts: false,
  },
  {
    name: 'a prerender (Sec-Purpose)',
    request: () => page('/', { 'sec-purpose': 'prefetch;prerender' }),
    counts: false,
  },
  { name: 'a prefetch (Purpose)', request: () => page('/', { purpose: 'prefetch' }), counts: false },
  { name: 'no User-Agent', request: () => page('/', { 'user-agent': null }), counts: false },
  {
    name: 'a link preview robot',
    request: () =>
      page('/', {
        'user-agent': 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)',
      }),
    counts: false,
  },
  {
    name: 'Slack link preview',
    request: () => page('/', { 'user-agent': 'Slackbot-LinkExpanding 1.0 (+https://api.slack.com/robots)' }),
    counts: false,
  },
  { name: 'curl', request: () => page('/', { 'user-agent': 'curl/8.7.1' }), counts: false },
  {
    name: 'a headless browser',
    request: () =>
      page('/', {
        'user-agent':
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/130.0.0.0 Safari/537.36',
      }),
    counts: false,
  },
  {
    name: 'an unknown Sec-Fetch-Site value',
    request: () => page('/', { 'sec-fetch-site': 'something' }),
    counts: false,
  },
]

describe('what counts as one visit', () => {
  for (const { name, request, counts } of CASES) {
    it(`[analytics 1] ${name}: ${counts ? 'counted' : 'not counted'}`, () => {
      expect(countsAsVisit(request())).toBe(counts)
    })
  }

  it('[analytics 1] the robot list holds the spec list exactly, and each entry is caught ignoring case', () => {
    expect(ROBOT_PATTERNS).toEqual([
      'bot',
      'crawl',
      'spider',
      'slurp',
      'preview',
      'facebookexternalhit',
      'embedly',
      'curl',
      'wget',
      'python',
      'httpclient',
      'java/',
      'go-http-client',
      'node-fetch',
      'axios',
      'headless',
      'lighthouse',
      'pingdom',
      'uptime',
      'monitor',
    ])
    for (const pattern of ROBOT_PATTERNS)
      expect(isRobot(`Something ${pattern.toUpperCase()}/1.0`), pattern).toBe(true)
    expect(isRobot(BROWSER)).toBe(false)
    expect(isRobot(OLD_ANDROID)).toBe(false)
  })
})

describe('the country', () => {
  it('[analytics 2] is request.cf.country when it is two capital letters', () => {
    expect(visitCountry(page('/', {}, {}, 'FI'))).toBe('FI')
    expect(visitCountry(page('/', {}, {}, 'SE'))).toBe('SE')
  })

  it('[analytics 2] a missing value, or anything else, is stored as XX; XX and T1 stay as they are', () => {
    expect(visitCountry(page('/'))).toBe('XX')
    expect(visitCountry(page('/', {}, {}, null))).toBe('XX')
    expect(visitCountry(page('/', {}, {}, 'fi'))).toBe('XX')
    expect(visitCountry(page('/', {}, {}, 'FIN'))).toBe('XX')
    expect(visitCountry(page('/', {}, {}, 42))).toBe('XX')
    expect(visitCountry(page('/', {}, {}, 'XX'))).toBe('XX')
    expect(visitCountry(page('/', {}, {}, 'T1'))).toBe('T1')
  })
})

// The Worker entry point with a stand in for the built files and a database fake.

const PAGE_HTML =
  '<!doctype html><html><head><title>PuhuScribe</title></head><body><div id="root"></div></body></html>'
let assetAnswers: Response[] = []

function assets(): Fetcher {
  return {
    fetch: vi.fn(() => {
      const answer = new Response(PAGE_HTML, {
        status: 200,
        headers: {
          'content-type': 'text/html; charset=utf-8',
          etag: '"abc"',
          'cache-control': 'public, max-age=0',
        },
      })
      assetAnswers.push(answer)
      return Promise.resolve(answer)
    }),
    connect: vi.fn(),
  }
}

function context() {
  const waits: Promise<unknown>[] = []
  return { waits, ctx: { waitUntil: (promise: Promise<unknown>) => void waits.push(promise) } }
}

let supabase: FakeSupabase
let env: WorkerEnv
const written: string[] = []

beforeEach(() => {
  assetAnswers = []
  written.length = 0
  supabase = fakeSupabase()
  supabase.rest = (request) =>
    request.url.pathname === '/rest/v1/rpc/count_visit' ? new Response(null, { status: 204 }) : undefined
  env = { ...ENV, ASSETS: assets() }
  for (const method of ['log', 'info', 'warn', 'error', 'debug', 'trace'] as const) {
    vi.spyOn(console, method).mockImplementation((...args: unknown[]) => {
      written.push(args.map(String).join(' '))
    })
  }
})

afterEach(() => {
  vi.restoreAllMocks()
})

function countCalls() {
  return supabase.requests.filter((r) => r.url.pathname === '/rest/v1/rpc/count_visit')
}

describe('the Worker counts an arrival after answering the page', () => {
  it('[analytics 2] [analytics 4] adds one for the country, and the call carries only the country', async () => {
    const { waits, ctx } = context()
    const res = await handleRequest(
      page(
        '/',
        { cookie: 'puhuscribe-auth=secret-looking-value', 'cf-connecting-ip': '203.0.113.9' },
        {},
        'FI',
      ),
      env,
      { fetch: supabase.fetch },
      ctx,
    )
    expect(res.status).toBe(200)
    await Promise.all(waits)
    const calls = countCalls()
    expect(calls).toHaveLength(1)
    const [call] = calls
    expect(call?.method).toBe('POST')
    expect(call?.url.toString()).toBe('https://fake-ref.supabase.co/rest/v1/rpc/count_visit')
    expect(JSON.parse(call?.body ?? '')).toEqual({ p_country: 'FI' })
    // Only the publishable key and the content type: no cookie, address, user agent, referer or sign in.
    expect([...(call?.headers.keys() ?? [])].sort()).toEqual(['apikey', 'content-type'])
    expect(call?.headers.get('apikey')).toBe(PUBLISHABLE)
    expect(call?.body).not.toContain('203.0.113.9')
  })

  it('[analytics 2] a page with no country data is counted as XX', async () => {
    const { waits, ctx } = context()
    await handleRequest(
      page('/session', { 'sec-fetch-site': 'cross-site' }),
      env,
      { fetch: supabase.fetch },
      ctx,
    )
    await Promise.all(waits)
    expect(countCalls().map((c) => JSON.parse(c.body) as unknown)).toEqual([{ p_country: 'XX' }])
  })

  it('[analytics 1] [analytics 3] a move inside the app, a file and an API call are not counted', async () => {
    const { waits, ctx } = context()
    await handleRequest(
      page('/session', { 'sec-fetch-site': 'same-origin' }, {}, 'FI'),
      env,
      { fetch: supabase.fetch },
      ctx,
    )
    await handleRequest(page('/api/health', {}, {}, 'FI'), env, { fetch: supabase.fetch }, ctx)
    const file = await handleRequest(
      page('/assets/index.js', {}, {}, 'FI'),
      env,
      { fetch: supabase.fetch },
      ctx,
    )
    await Promise.all(waits)
    expect(countCalls()).toHaveLength(0)
    // A file never reaches the Worker in production (run_worker_first); here it is not served.
    expect(file.status).toBe(404)
  })

  it('[analytics 3] answers a page route with the built page from env.ASSETS', async () => {
    const res = await handleRequest(page('/privacy'), env, { fetch: supabase.fetch }, context().ctx)
    expect(await res.text()).toBe(PAGE_HTML)
    expect(assetAnswers).toHaveLength(1)
  })

  it('[analytics 4] the page answer is exactly what env.ASSETS returned: no added header or cookie', async () => {
    const { ctx } = context()
    const res = await handleRequest(page('/', {}, {}, 'FI'), env, { fetch: supabase.fetch }, ctx)
    expect(res).toBe(assetAnswers[0])
    expect([...res.headers.keys()].sort()).toEqual(['cache-control', 'content-type', 'etag'])
    expect(res.headers.get('set-cookie')).toBeNull()
  })

  it('[analytics 4] a failing database changes nothing in the page and writes no log line', async () => {
    supabase.rest = () => new Response('{"message":"down"}', { status: 500 })
    const { waits, ctx } = context()
    const res = await handleRequest(page('/', {}, {}, 'FI'), env, { fetch: supabase.fetch }, ctx)
    expect(res).toBe(assetAnswers[0])
    expect(await res.text()).toBe(PAGE_HTML)
    await expect(Promise.all(waits)).resolves.toBeDefined()
    expect(written).toEqual([])
  })

  it('[analytics 4] a database fetch that throws is dropped silently', async () => {
    const { waits, ctx } = context()
    const res = await handleRequest(
      page('/', {}, {}, 'FI'),
      env,
      { fetch: () => Promise.reject(new TypeError('network down')) },
      ctx,
    )
    expect(res.status).toBe(200)
    await expect(Promise.all(waits)).resolves.toBeDefined()
    expect(written).toEqual([])
  })

  it('[analytics 4] a database that hangs does not hold the page back: the count runs after the answer', async () => {
    const { waits, ctx } = context()
    let started = false
    const res = await handleRequest(
      page('/', {}, {}, 'FI'),
      env,
      {
        fetch: () => {
          started = true
          return new Promise<Response>(() => undefined)
        },
      },
      ctx,
    )
    expect(res).toBe(assetAnswers[0])
    expect(await res.text()).toBe(PAGE_HTML)
    expect(waits).toHaveLength(1)
    expect(started).toBe(true)
    expect(written).toEqual([])
  })
})
