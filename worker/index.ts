import { handleApi, type ApiEnv } from './api.ts'
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
import { isPageRoute } from './page-routes.ts'
import { countsAsVisit, countVisit, visitCountry } from './visits.ts'

// The single Cloudflare Worker for PuhuScribe. wrangler.jsonc sends every
// /api/* request and the app's page routes here first (run_worker_first);
// files are served by Cloudflare without running this code.
//
// - /api/* goes to worker/api.ts, on the same address as the page.
// - A page route is answered with the built page itself (env.ASSETS), byte for
//   byte, and an arrival is counted after the answer (worker/visits.ts,
//   factory/jobs/14-analytics/spec.md, "Done when" 1 to 4).
// - The owner hostname, when it is configured, goes to worker/owner.ts.
// - An exception nobody expected answers 500 {"error":"server_error"} and is
//   reported as a crash ("Done when" 24).

export interface WorkerEnv extends ApiEnv, OwnerEnv {
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

async function route(request: Request, env: WorkerEnv, deps: OwnerDeps, ctx: WaitUntil): Promise<Response> {
  const url = new URL(request.url)
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
  if (!isPageRoute(url.pathname)) return new Response('Not found', { status: 404 })
  if (!env.ASSETS) throw new Error('The ASSETS binding is missing.')
  const page = await env.ASSETS.fetch(request)
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
