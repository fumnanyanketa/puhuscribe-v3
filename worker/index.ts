import { handleApi, type ApiEnv } from './api.ts'
import { canonicalRedirect, type CanonicalHostEnv } from './canonical-host.ts'
import { reportWorkerCrash } from './crash.ts'
import { json, readBody } from './http.ts'
import {
  handleOwnerRequest,
  OWNER_API_CSP,
  ownerHostname,
  privately,
  type OwnerDeps,
  type OwnerEnv,
} from './owner.ts'
import { isPageRoute, LANDING_FILE_ROUTES } from './page-routes.ts'
import { countsAsVisit, countVisit, visitCountry } from './visits.ts'

// The single Cloudflare Worker for PuhuScribe. wrangler.jsonc sends every
// /api/* request and the app's page routes here first (run_worker_first);
// files are served by Cloudflare without running this code.
//
// - /api/* goes to worker/api.ts, on the same address as the page.
// - "/" is the public landing page (landing.html, job 17-landing-page), and the
//   app's pages live under /learn.
// - A page route is answered with the built page itself (env.ASSETS), byte for
//   byte, and an arrival is counted after the answer (worker/visits.ts,
//   factory/jobs/14-analytics/spec.md, "Done when" 1 to 4).
// - On the live Worker, www.meetaleksi.com is sent to meetaleksi.com first
//   (worker/canonical-host.ts, job go-live).
// - The owner hostname, when it is configured, goes to worker/owner.ts.
// - An exception nobody expected answers 500 {"error":"server_error"} and is
//   reported as a crash ("Done when" 24).

export interface WorkerEnv extends ApiEnv, OwnerEnv, CanonicalHostEnv {
  ASSETS?: Fetcher
}

type WaitUntil = Pick<ExecutionContext, 'waitUntil'>

const defaultDeps: OwnerDeps = { fetch: (input, init) => fetch(input, init) }

// Without a Workers context (some unit tests), work that would run after the
// answer just runs, and its failure is ignored.
const noContext: WaitUntil = {
  waitUntil: (promise) => {
    promise.catch(() => undefined)
  },
}

function isApi(pathname: string): boolean {
  return pathname === '/api' || pathname.startsWith('/api/')
}

/**
 * The public landing page at "/" (job 17-landing-page): the built file
 * landing.html, answered unchanged. The app shell stays index.html, so every
 * address under /learn keeps working as Cloudflare's single page app fallback.
 * Only GET and HEAD reach it.
 */
async function landingPage(request: Request, assets: Fetcher): Promise<Response> {
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    await readBody(request)
    return new Response('Method not allowed', { status: 405, headers: { Allow: 'GET, HEAD' } })
  }
  return assets.fetch(new Request(new URL('/landing', request.url), request))
}

async function route(request: Request, env: WorkerEnv, deps: OwnerDeps, ctx: WaitUntil): Promise<Response> {
  const url = new URL(request.url)
  const toApex = await canonicalRedirect(request, env)
  if (toApex !== null) return toApex
  const owner = ownerHostname(env)
  if (owner !== null && url.hostname === owner) return handleOwnerRequest(request, env, deps)
  if (isApi(url.pathname)) {
    // The owner's routes exist only on the owner host.
    if (url.pathname === '/api/owner' || url.pathname.startsWith('/api/owner/')) {
      await readBody(request)
      return json({ error: 'not_found' }, 404)
    }
    return handleApi(request, env, deps)
  }
  // The built landing file has one public address, "/" (job 17-landing-page).
  if ((LANDING_FILE_ROUTES as readonly string[]).includes(url.pathname) || url.pathname === '/landing.html') {
    await readBody(request)
    return new Response(null, { status: 301, headers: { Location: '/' } })
  }
  if (!isPageRoute(url.pathname)) return new Response('Not found', { status: 404 })
  if (!env.ASSETS) throw new Error('The ASSETS binding is missing.')
  const page = url.pathname === '/' ? await landingPage(request, env.ASSETS) : await env.ASSETS.fetch(request)
  if (page.status < 400 && countsAsVisit(request)) {
    ctx.waitUntil(countVisit(env, deps.fetch, visitCountry(request)))
  }
  return page
}

export async function handleRequest(
  request: Request,
  env: WorkerEnv,
  deps: OwnerDeps = defaultDeps,
  ctx: WaitUntil = noContext,
): Promise<Response> {
  try {
    return await route(request, env, deps, ctx)
  } catch (error) {
    ctx.waitUntil(reportWorkerCrash(error, request, env, deps.fetch))
    const answer = json({ error: 'server_error' }, 500)
    const owner = ownerHostname(env)
    return owner !== null && new URL(request.url).hostname === owner
      ? privately(answer, OWNER_API_CSP)
      : answer
  }
}

export default {
  fetch(request, env, ctx) {
    // Secrets set on the Worker (or in .env.local locally) arrive in env.
    return handleRequest(request, env, defaultDeps, ctx)
  },
} satisfies ExportedHandler<WorkerEnv>
