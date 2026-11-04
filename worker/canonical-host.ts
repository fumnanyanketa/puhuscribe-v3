// One public address for the live app (job go-live). The live Worker answers
// on meetaleksi.com and on www.meetaleksi.com; every request the Worker sees
// on the www name is sent to the same path on the apex, so the sign in
// cookies, the Turnstile hostname check and the visit count only ever see one
// address. CANONICAL_HOST is a plain variable set only in the "production"
// environment of wrangler.jsonc. Without it (local runs, the previews) nothing
// is redirected.
//
// Files are served by Cloudflare without running the Worker, so a file asked
// for on the www name is still answered there. Every page a person opens ("/",
// /learn and the rest of worker/page-routes.ts) and every /api/* request runs
// the Worker first and is redirected.

import { readBody } from './http.ts'

export interface CanonicalHostEnv {
  CANONICAL_HOST?: string
}

/** The apex hostname to send www requests to, or null when none is set. */
export function canonicalHost(env: CanonicalHostEnv): string | null {
  const host = env.CANONICAL_HOST?.trim().toLowerCase()
  return host ? host : null
}

/**
 * A redirect to the apex when the request came in on www.<CANONICAL_HOST>,
 * otherwise null. GET and HEAD get a 301; any other method gets a 308, which
 * keeps the method, and its body is read first (a Workers runtime rule from job
 * 2-smoke).
 */
export async function canonicalRedirect(request: Request, env: CanonicalHostEnv): Promise<Response | null> {
  const host = canonicalHost(env)
  if (host === null) return null
  const url = new URL(request.url)
  if (url.hostname.toLowerCase() !== `www.${host}`) return null
  const target = `https://${host}${url.pathname}${url.search}`
  const keepsMethod = request.method !== 'GET' && request.method !== 'HEAD'
  if (keepsMethod) await readBody(request)
  return new Response(null, { status: keepsMethod ? 308 : 301, headers: { Location: target } })
}
