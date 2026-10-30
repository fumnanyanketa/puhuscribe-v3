import { createLocalJWKSet, type JSONWebKeySet, type JWTVerifyGetKey } from 'jose'
import { accessKeys, hasValidAccessToken, type KeySource } from '../review-site/handler.ts'
import { handleApi, type ApiDeps, type ApiEnv } from './api.ts'
import { json, readBody, refuseNonGet, withCookies } from './http.ts'
import {
  endedHint,
  hasAuthCookie,
  learnerContext,
  signInState,
  supabaseSettings,
  type LearnerClient,
  type LearnerContext,
} from './learner-auth.ts'
import { isPageRoute } from './page-routes.ts'

// The owner page's own address (factory/jobs/14-analytics/spec.md, "Done
// when" 13 to 15 and 18; Decision 5).
//
// The same Worker answers a second hostname, OWNER_HOSTNAME. Its live value
// is set on the production Worker at go live (README, "Owner page setup"),
// never in code. Three locks guard it:
// 1. Cloudflare Access covers the whole hostname (set up at go live).
// 2. This Worker checks the Access token on every request, with job 13's
//    check: signed by the team's keys, issued by OWNER_ACCESS_TEAM_DOMAIN,
//    for OWNER_ACCESS_AUD, not expired. Otherwise 403 and one plain line.
// 3. The owner signs in with their own PuhuScribe account, and the database
//    function owner_dashboard() answers only for an account on the owner list
//    with a live sign in. No stronger key exists here.
//
// On the owner host only /owner, /sign-in and a few /api routes are
// answered; other pages go to /owner and other /api routes get 404. Every
// answer is kept out of search engines, caches and frames, and sends no
// Referer. Visits to this host are never counted.

export interface OwnerEnv {
  OWNER_HOSTNAME?: string
  // https://<team>.cloudflareaccess.com, a plain variable set at go live.
  OWNER_ACCESS_TEAM_DOMAIN?: string
  // The owner page's Access application AUD tag, a plain variable set at go live.
  OWNER_ACCESS_AUD?: string
  // Browser tests only: a public key set to check locally made tokens with.
  // Used only when OWNER_HOSTNAME is this computer (localhost, 127.0.0.1 or
  // [::1]), so a live Worker never trusts it.
  OWNER_ACCESS_LOCAL_JWKS?: string
}

export interface OwnerDb {
  /** The owner page's numbers, or null when this account may not see them. */
  dashboard(): Promise<unknown>
}

export class OwnerDbUnavailable extends Error {}

export function supabaseOwnerDb(client: LearnerClient): OwnerDb {
  return {
    async dashboard() {
      const { data, error } = await client.rpc('owner_dashboard')
      if (error) throw new OwnerDbUnavailable()
      return data ?? null
    },
  }
}

export interface OwnerDeps extends ApiDeps {
  /** Tests pass a local key set; normally the team's keys from Cloudflare. */
  accessKeys?: KeySource
  /** Tests pass a fake; normally Supabase, as the signed in account. */
  ownerDb?: (context: LearnerContext) => OwnerDb
}

const HOSTNAME = /^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?(\.[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?)*$/
const LOOPBACK = new Set(['localhost', '127.0.0.1', '[::1]'])

function setting(value: string | undefined): string {
  return value?.trim() ?? ''
}

/** The owner hostname, or null when any of the three settings is missing (then no host is the owner host). */
export function ownerHostname(env: OwnerEnv): string | null {
  const host = setting(env.OWNER_HOSTNAME).toLowerCase()
  if (!setting(env.OWNER_ACCESS_TEAM_DOMAIN) || !setting(env.OWNER_ACCESS_AUD)) return null
  if (host === '[::1]' || HOSTNAME.test(host)) return host
  return null
}

const refuseAll: JWTVerifyGetKey = () => Promise.reject(new Error('No keys.'))

/** Where the Access keys come from: the team's own, or the local test set on this computer only. */
export function ownerKeySource(env: OwnerEnv): KeySource {
  const local = setting(env.OWNER_ACCESS_LOCAL_JWKS)
  if (!local || !LOOPBACK.has(setting(env.OWNER_HOSTNAME).toLowerCase())) return accessKeys
  try {
    const keys = createLocalJWKSet(JSON.parse(local) as JSONWebKeySet)
    return () => keys
  } catch {
    return () => refuseAll
  }
}

const PRIVATE_HEADERS: Record<string, string> = {
  'X-Robots-Tag': 'noindex, nofollow',
  'Cache-Control': 'private, no-store',
  'Referrer-Policy': 'no-referrer',
}
export const OWNER_PAGE_CSP = "frame-ancestors 'none'"
export const OWNER_API_CSP = "default-src 'none'; frame-ancestors 'none'"

/** The same answer, with the owner host's private headers. */
export function privately(response: Response, csp: string): Response {
  const headers = new Headers(response.headers)
  for (const [name, value] of Object.entries(PRIVATE_HEADERS)) headers.set(name, value)
  headers.set('Content-Security-Policy', csp)
  headers.delete('Access-Control-Allow-Origin')
  return new Response(response.body, { status: response.status, statusText: response.statusText, headers })
}

export const ACCESS_REFUSED = 'This page is private. Sign in through its Cloudflare Access page to open it.'

/** The /api routes the owner host answers besides the dashboard: sign in, crash reports and health. */
export const OWNER_API_ROUTES: ReadonlySet<string> = new Set([
  '/api/crash',
  '/api/health',
  '/api/me',
  '/api/sign-in',
  '/api/sign-in/verify',
  '/api/sign-out',
])

const OTHER_SITES = new Set(['same-site', 'cross-site'])

// GET /api/owner/dashboard: the numbers, only for the signed in owner.
async function dashboard(request: Request, env: ApiEnv, deps: OwnerDeps): Promise<Response> {
  const refused = await refuseNonGet(request)
  if (refused) return refused
  const origin = request.headers.get('origin')
  const site = (request.headers.get('sec-fetch-site') ?? '').trim().toLowerCase()
  if ((origin !== null && origin !== new URL(request.url).origin) || OTHER_SITES.has(site)) {
    return json({ error: 'forbidden' }, 403)
  }
  if (!hasAuthCookie(request)) return json({ error: 'signed_out' }, 401)
  const settings = supabaseSettings(env)
  if (!settings) return json({ error: 'not_available' }, 503)
  const context = learnerContext(request, settings, deps.fetch)
  const state = await signInState(context)
  if (state === 'unavailable') return withCookies(json({ error: 'not_available' }, 503), context.setCookies())
  if (state === 'ended') {
    return withCookies(
      json({ error: 'session_ended', ...(await endedHint(request)) }, 401),
      context.setCookies(),
    )
  }
  if (state === 'none') return withCookies(json({ error: 'signed_out' }, 401), context.setCookies())
  try {
    const db = deps.ownerDb ? deps.ownerDb(context) : supabaseOwnerDb(context.client)
    const numbers = await db.dashboard()
    if (numbers === null) return withCookies(json({ error: 'not_owner' }, 403), context.setCookies())
    return withCookies(json(numbers), context.setCookies())
  } catch {
    return withCookies(json({ error: 'not_available' }, 503), context.setCookies())
  }
}

interface OwnerHostEnv extends ApiEnv, OwnerEnv {
  ASSETS?: Fetcher
}

function assets(env: OwnerHostEnv): Fetcher {
  if (!env.ASSETS) throw new Error('The ASSETS binding is missing.')
  return env.ASSETS
}

/** Every request to the owner host. */
export async function handleOwnerRequest(
  request: Request,
  env: OwnerHostEnv,
  deps: OwnerDeps,
): Promise<Response> {
  const keys = deps.accessKeys ?? ownerKeySource(env)
  const tokenOk = await hasValidAccessToken(
    request,
    {
      ASSETS: assets(env),
      ACCESS_TEAM_DOMAIN: env.OWNER_ACCESS_TEAM_DOMAIN,
      ACCESS_AUD: env.OWNER_ACCESS_AUD,
    },
    keys,
  )
  if (!tokenOk) {
    await readBody(request)
    const refusal = new Response(`${ACCESS_REFUSED}\n`, {
      status: 403,
      headers: { 'Content-Type': 'text/plain; charset=utf-8' },
    })
    return privately(refusal, OWNER_API_CSP)
  }
  const { pathname } = new URL(request.url)
  if (pathname === '/api/owner/dashboard')
    return privately(await dashboard(request, env, deps), OWNER_API_CSP)
  if (pathname === '/api' || pathname.startsWith('/api/')) {
    if (OWNER_API_ROUTES.has(pathname)) return privately(await handleApi(request, env, deps), OWNER_API_CSP)
    await readBody(request)
    return privately(json({ error: 'not_found' }, 404), OWNER_API_CSP)
  }
  if (pathname === '/owner' || pathname === '/sign-in') {
    return privately(await assets(env).fetch(request), OWNER_PAGE_CSP)
  }
  await readBody(request)
  if (isPageRoute(pathname)) {
    return privately(new Response(null, { status: 302, headers: { Location: '/owner' } }), OWNER_PAGE_CSP)
  }
  return privately(new Response('Not found', { status: 404 }), OWNER_PAGE_CSP)
}
