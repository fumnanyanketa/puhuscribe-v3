import { createRemoteJWKSet, jwtVerify, type JWTVerifyGetKey } from 'jose'

// What the review site's Worker, puhuscribe-review, does with each request (job
// 13-review-site, "Done when" 5 to 8). review-site/worker.ts is the entry and
// runs this before every file (run_worker_first in wrangler.jsonc). It is the
// second lock behind Cloudflare Access:
//
// 1. Only GET and HEAD are answered. Anything else gets 405.
// 2. A file is served only when the Cf-Access-Jwt-Assertion header holds a
//    token signed by the Access team's keys, issued by the team domain, for this
//    Access application (its AUD tag), and not expired. Otherwise 403. When
//    either setting is missing, everything gets 403.
// 3. Only the index, robots.txt and review pages at /<slug>/round-<n> are
//    looked up. Anything else, or a path with no file, gets a plain 404.
// 4. Every response, refusals included, tells search engines to stay away and
//    forbids framing and caching.
//
// It never reads who signed in: the token is checked, never opened for its
// claims. It writes no logs (observability is off in wrangler.jsonc).

export interface ReviewEnv {
  ASSETS: Fetcher
  // https://<team>.cloudflareaccess.com, a plain variable set at deploy.
  ACCESS_TEAM_DOMAIN?: string
  // The Access application's AUD tag, a plain variable set at deploy.
  ACCESS_AUD?: string
}

// Gives the Access team's signing keys. Tests pass a local key set.
export type KeySource = (teamDomain: string) => JWTVerifyGetKey

const TEAM_DOMAIN = /^https:\/\/[a-z0-9]+(?:-[a-z0-9]+)*\.cloudflareaccess\.com$/
const AUD_TAG = /^[0-9a-f]{64}$/
const REVIEW_PAGE = /^\/[a-z0-9]+(?:-[a-z0-9]+)*\/round-[1-9][0-9]*(?:\.html)?$/

export const SITE_CSP =
  "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'"
// Review pages carry their own policy in a meta tag (job 7). The header adds
// only what a meta tag cannot: no framing.
export const PAGE_CSP = "frame-ancestors 'none'"

const SHARED_HEADERS: Record<string, string> = {
  'X-Robots-Tag': 'noindex, nofollow, noarchive',
  'Cache-Control': 'private, no-store',
  'Referrer-Policy': 'no-referrer',
  'X-Content-Type-Options': 'nosniff',
}

const keySets = new Map<string, JWTVerifyGetKey>()

// The team's public keys, from <team domain>/cdn-cgi/access/certs. Cloudflare
// rotates them, so they are fetched (and cached by jose), never stored here.
export const accessKeys: KeySource = (teamDomain) => {
  let keys = keySets.get(teamDomain)
  if (!keys) {
    keys = createRemoteJWKSet(new URL('/cdn-cgi/access/certs', teamDomain))
    keySets.set(teamDomain, keys)
  }
  return keys
}

function isAllowedPath(path: string): boolean {
  return path === '/' || path === '/index.html' || path === '/robots.txt' || REVIEW_PAGE.test(path)
}

function withHeaders(headers: Headers, csp: string): Headers {
  for (const [name, value] of Object.entries(SHARED_HEADERS)) headers.set(name, value)
  headers.set('Content-Security-Policy', csp)
  return headers
}

function plain(status: number, line: string, method: string, extra: Record<string, string> = {}): Response {
  const headers = withHeaders(
    new Headers({ 'Content-Type': 'text/plain; charset=utf-8', ...extra }),
    SITE_CSP,
  )
  return new Response(method === 'HEAD' ? null : `${line}\n`, { status, headers })
}

// The 404 answer: one short page with a link back to the start page and no
// list of files. No script, nothing loaded; the strict site policy applies.
export const NOT_FOUND_HTML = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Not found</title>
</head>
<body style="margin: 0; padding: 32px 20px; background: #faf9fc; color: #1b1a20; font: 16px/1.5 system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
<p>Not found. <a href="/" style="color: #1f42ac; font-weight: 600;">Go to the start page</a></p>
</body>
</html>
`

function notFound(method: string): Response {
  const headers = withHeaders(new Headers({ 'Content-Type': 'text/html; charset=utf-8' }), SITE_CSP)
  return new Response(method === 'HEAD' ? null : NOT_FOUND_HTML, { status: 404, headers })
}

export async function hasValidAccessToken(
  request: Request,
  env: ReviewEnv,
  keys: KeySource,
): Promise<boolean> {
  const teamDomain = env.ACCESS_TEAM_DOMAIN ?? ''
  const aud = env.ACCESS_AUD ?? ''
  if (!TEAM_DOMAIN.test(teamDomain) || !AUD_TAG.test(aud)) return false
  const token = request.headers.get('Cf-Access-Jwt-Assertion')
  if (!token) return false
  try {
    await jwtVerify(token, keys(teamDomain), {
      issuer: teamDomain,
      audience: aud,
      algorithms: ['RS256'],
      requiredClaims: ['exp'],
    })
    return true
  } catch {
    return false
  }
}

export async function handleReviewRequest(
  request: Request,
  env: ReviewEnv,
  keys: KeySource = accessKeys,
): Promise<Response> {
  const method = request.method
  if (method !== 'GET' && method !== 'HEAD') {
    return plain(405, 'Only GET and HEAD are allowed on this site.', method, { Allow: 'GET, HEAD' })
  }
  if (!(await hasValidAccessToken(request, env, keys))) {
    return plain(403, 'This site is private. Sign in through its Cloudflare Access page to open it.', method)
  }
  const url = new URL(request.url)
  if (!isAllowedPath(url.pathname)) return notFound(method)

  // A plain GET for the file: no cookies, no conditional headers, no body.
  const asset = await env.ASSETS.fetch(new Request(url.toString(), { method: 'GET' }))
  if (asset.status === 404) return notFound(method)
  const csp = REVIEW_PAGE.test(url.pathname) ? PAGE_CSP : SITE_CSP
  const headers = withHeaders(new Headers(asset.headers), csp)
  return new Response(method === 'HEAD' ? null : asset.body, { status: asset.status, headers })
}
