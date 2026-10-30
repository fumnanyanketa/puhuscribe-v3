import { isPageRoute } from './page-routes.ts'
import { supabaseSettings, type Fetch, type SupabaseEnv } from './learner-auth.ts'

// The visit count (factory/jobs/14-analytics/spec.md, "Done when" 1, 2 and 4).
//
// One visit is one arrival at one of the app's pages: someone came from a
// link, a bookmark, the home screen or by typing the address. Moving between
// screens inside the app, files and obvious robots do not count. The Worker
// reads the request's headers only to decide that, and passes on only the
// country Cloudflare gives. Nothing is read from or written to the visitor's
// device: no cookie, no storage, no script.

/** The obvious robots, matched in the user agent ignoring case (Decision, note 1). */
export const ROBOT_PATTERNS: readonly string[] = [
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
]

export function isRobot(userAgent: string): boolean {
  const lower = userAgent.toLowerCase()
  return ROBOT_PATTERNS.some((pattern) => lower.includes(pattern))
}

const ARRIVALS = new Set(['none', 'same-site', 'cross-site'])

/** True when a page request came from outside this address (statement 1). */
function isArrival(request: Request, origin: string): boolean {
  const site = request.headers.get('sec-fetch-site')
  if (site !== null) return ARRIVALS.has(site.trim().toLowerCase())
  // Older browsers send no Sec-Fetch-* headers: a Referer from this same
  // address means a move inside the app.
  const referer = request.headers.get('referer')
  if (referer === null || referer.trim() === '') return true
  try {
    return new URL(referer).origin !== origin
  } catch {
    return true
  }
}

function mentionsPrefetch(value: string | null): boolean {
  return value !== null && /prefetch|prerender/i.test(value)
}

/**
 * Whether this request counts as one visit. The caller checks it arrived on
 * the app host; the owner host is never counted.
 */
export function countsAsVisit(request: Request): boolean {
  if (request.method !== 'GET') return false
  const url = new URL(request.url)
  if (!isPageRoute(url.pathname)) return false
  if (!(request.headers.get('accept') ?? '').toLowerCase().includes('text/html')) return false
  const dest = request.headers.get('sec-fetch-dest')
  if (dest !== null && dest.trim().toLowerCase() !== 'document') return false
  if (
    mentionsPrefetch(request.headers.get('sec-purpose')) ||
    mentionsPrefetch(request.headers.get('purpose'))
  ) {
    return false
  }
  const userAgent = request.headers.get('user-agent')
  if (userAgent === null || userAgent.trim() === '' || isRobot(userAgent)) return false
  return isArrival(request, url.origin)
}

/**
 * The visitor's country as Cloudflare saw it: two capital letters, or T1 for
 * the Tor network. A missing value is stored as XX, Cloudflare's own "no
 * country data" (statement 2).
 */
export function visitCountry(request: Request): string {
  const country = (request as Request & { cf?: { country?: unknown } }).cf?.country
  return typeof country === 'string' && /^([A-Z]{2}|T1)$/.test(country) ? country : 'XX'
}

const COUNT_TIMEOUT_MS = 3000

/**
 * Adds one visit for the country through public.count_visit, as anon with the
 * publishable key and no sign in. The call carries the country and nothing
 * else. Any failure is dropped silently: the page was already answered.
 */
export async function countVisit(env: SupabaseEnv, fetchImpl: Fetch, country: string): Promise<void> {
  const settings = supabaseSettings(env)
  if (!settings) return
  try {
    const controller = new AbortController()
    const timer = setTimeout(() => {
      controller.abort()
    }, COUNT_TIMEOUT_MS)
    try {
      const res = await fetchImpl(`${settings.url}/rest/v1/rpc/count_visit`, {
        method: 'POST',
        headers: { apikey: settings.key, 'content-type': 'application/json' },
        body: JSON.stringify({ p_country: country }),
        signal: controller.signal,
      })
      await res.body?.cancel()
    } finally {
      clearTimeout(timer)
    }
  } catch {
    // Dropped: counting never changes or slows the page (statement 4).
  }
}
