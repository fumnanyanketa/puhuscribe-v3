import { createLocalJWKSet, type JSONWebKeySet, type JWTVerifyGetKey } from 'jose'
import { accessKeys, hasValidAccessToken, type KeySource } from '../review-site/handler.ts'
import { OWNER_HOST_ATTRIBUTE, OWNER_HOST_MARK } from '../src/lib/owner-host.ts'
import { handleApi, type ApiDeps, type ApiEnv } from './api.ts'
import { json, readBody, refuseNonGet, refuseUnsafeWrite, withCookies } from './http.ts'
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
// On the owner host only /learn/owner, /learn/sign-in and a few /api routes are
// answered; other pages go to /learn/owner and other /api routes get 404. Every
// answer is kept out of search engines, caches and frames, and sends no
// Referer. Visits to this host are never counted. Its pages are marked as the
// owner host's (src/lib/owner-host.ts), so their crash reports carry the
// Access cookie that lets them through.

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

/**
 * The reviewer sign ups (fast route reviewers, "Done when" 5), through two
 * database functions that answer only the owner with a live sign in.
 */
export interface OwnerReviewersDb {
  /** Every sign up, newest first, or null when this account may not see them. */
  list(): Promise<unknown>
  /** Deletes one sign up: true when deleted, false when there was none, null when this account may not. */
  remove(id: string): Promise<boolean | null>
}

// The two functions are newer than the committed database types
// (src/lib/database.types.ts is made only by the Supabase CLI against a
// database with every migration applied, factory/jobs/reviewers/build.md), so
// they are called by name through this narrow view of the client.
type NamedRpc = (fn: string, args?: Record<string, unknown>) => PromiseLike<{ data: unknown; error: unknown }>

export function supabaseOwnerReviewersDb(client: LearnerClient): OwnerReviewersDb {
  const rpc = client.rpc.bind(client) as unknown as NamedRpc
  return {
    async list() {
      const { data, error } = await rpc('owner_reviewer_signups')
      if (error) throw new OwnerDbUnavailable()
      return data ?? null
    },
    async remove(id) {
      const { data, error } = await rpc('owner_delete_reviewer_signup', { p_id: id })
      if (error) throw new OwnerDbUnavailable()
      return typeof data === 'boolean' ? data : null
    },
  }
}

export interface OwnerDeps extends ApiDeps {
  /** Tests pass a local key set; normally the team's keys from Cloudflare. */
  accessKeys?: KeySource
  /** Tests pass a fake; normally Supabase, as the signed in account. */
  ownerDb?: (context: LearnerContext) => OwnerDb
  /** Tests pass a fake for the reviewer sign ups; normally Supabase, as the signed in account. */
  ownerReviewersDb?: (context: LearnerContext) => OwnerReviewersDb
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

const HTML_TAG = /<html(?=[\s>])/i

/**
 * The built page with its <html> element marked as served by the owner host
 * (src/lib/owner-host.ts), so the page's crash reports carry Cloudflare
 * Access's cookie. Only a 200 HTML answer is changed; the app host never
 * calls this, so its pages stay byte for byte ("Done when" 4).
 */
async function markedAsOwnerHost(page: Response): Promise<Response> {
  const type = page.headers.get('content-type') ?? ''
  if (page.status !== 200 || !type.toLowerCase().startsWith('text/html')) return page
  const html = await page.text()
  const headers = new Headers(page.headers)
  // The body changes, so its length and ETag no longer describe it.
  headers.delete('content-length')
  headers.delete('etag')
  return new Response(html.replace(HTML_TAG, `<html ${OWNER_HOST_ATTRIBUTE}="${OWNER_HOST_MARK}"`), {
    status: page.status,
    statusText: page.statusText,
    headers,
  })
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

function fromOtherSite(request: Request): boolean {
  const origin = request.headers.get('origin')
  const site = (request.headers.get('sec-fetch-site') ?? '').trim().toLowerCase()
  return (origin !== null && origin !== new URL(request.url).origin) || OTHER_SITES.has(site)
}

/**
 * The owner's own sign in, checked for every owner route: a live sign in,
 * then `run` with it. The database decides whether the account is the owner.
 */
async function asOwner(
  request: Request,
  env: ApiEnv,
  deps: OwnerDeps,
  run: (context: LearnerContext) => Promise<Response>,
): Promise<Response> {
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
    return withCookies(await run(context), context.setCookies())
  } catch {
    return withCookies(json({ error: 'not_available' }, 503), context.setCookies())
  }
}

// GET /api/owner/dashboard: the numbers, only for the signed in owner.
async function dashboard(request: Request, env: ApiEnv, deps: OwnerDeps): Promise<Response> {
  const refused = await refuseNonGet(request)
  if (refused) return refused
  if (fromOtherSite(request)) return json({ error: 'forbidden' }, 403)
  return asOwner(request, env, deps, async (context) => {
    const db = deps.ownerDb ? deps.ownerDb(context) : supabaseOwnerDb(context.client)
    const numbers = await db.dashboard()
    if (numbers === null) return json({ error: 'not_owner' }, 403)
    return json(numbers)
  })
}

function reviewersDbFor(context: LearnerContext, deps: OwnerDeps): OwnerReviewersDb {
  return deps.ownerReviewersDb ? deps.ownerReviewersDb(context) : supabaseOwnerReviewersDb(context.client)
}

// GET /api/owner/reviewers: every reviewer sign up, newest first, only for the
// signed in owner (fast route reviewers, "Done when" 5).
async function reviewerSignups(request: Request, env: ApiEnv, deps: OwnerDeps): Promise<Response> {
  const refused = await refuseNonGet(request)
  if (refused) return refused
  if (fromOtherSite(request)) return json({ error: 'forbidden' }, 403)
  return asOwner(request, env, deps, async (context) => {
    const signups = await reviewersDbFor(context, deps).list()
    if (signups === null) return json({ error: 'not_owner' }, 403)
    return json({ signups })
  })
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

// POST /api/owner/reviewers/delete {"id": "..."}: deletes one sign up, only for
// the signed in owner. The page asks for a confirmation first.
async function deleteReviewerSignup(request: Request, env: ApiEnv, deps: OwnerDeps): Promise<Response> {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  if (fromOtherSite(request)) return json({ error: 'forbidden' }, 403)
  let id: unknown
  try {
    id = (JSON.parse(write.body) as Record<string, unknown> | null)?.id
  } catch {
    id = undefined
  }
  if (typeof id !== 'string' || !UUID.test(id)) return json({ error: 'bad_id' }, 400)
  return asOwner(request, env, deps, async (context) => {
    const deleted = await reviewersDbFor(context, deps).remove(id)
    if (deleted === null) return json({ error: 'not_owner' }, 403)
    if (!deleted) return json({ error: 'not_found' }, 404)
    return json({ deleted: true })
  })
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
  if (pathname === '/api/owner/reviewers')
    return privately(await reviewerSignups(request, env, deps), OWNER_API_CSP)
  if (pathname === '/api/owner/reviewers/delete')
    return privately(await deleteReviewerSignup(request, env, deps), OWNER_API_CSP)
  if (pathname === '/api' || pathname.startsWith('/api/')) {
    if (OWNER_API_ROUTES.has(pathname)) return privately(await handleApi(request, env, deps), OWNER_API_CSP)
    await readBody(request)
    return privately(json({ error: 'not_found' }, 404), OWNER_API_CSP)
  }
  if (pathname === '/learn/owner' || pathname === '/learn/sign-in') {
    return privately(await markedAsOwnerHost(await assets(env).fetch(request)), OWNER_PAGE_CSP)
  }
  await readBody(request)
  // Every other page, the landing page and the old /owner and /sign-in included, goes to the owner
  // page (job 17-landing-page): the landing page is never served on the owner host.
  if (isPageRoute(pathname) || pathname === '/owner' || pathname === '/sign-in') {
    const to = pathname === '/sign-in' ? '/learn/sign-in' : '/learn/owner'
    return privately(new Response(null, { status: 302, headers: { Location: to } }), OWNER_PAGE_CSP)
  }
  return privately(new Response('Not found', { status: 404 }), OWNER_PAGE_CSP)
}
