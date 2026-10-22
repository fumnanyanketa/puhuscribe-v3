// The app's only way to reach the server: its own /api/* routes, on the same
// address as the page. The browser never talks to Supabase and never holds a
// token; the sign in lives in cookies that page scripts cannot read.
//
// The time limit is built from AbortController and setTimeout, which every
// browser has. AbortSignal.timeout() is missing on older iOS Safari and
// Android WebViews (AGENTS.md, lesson from job 2-smoke).

const REQUEST_TIMEOUT_MS = 10_000

export interface ApiAnswer {
  status: number
  body: unknown
}

/** Calls one /api route. Returns null when the network failed or took too long. */
export async function callApi(
  path: string,
  method: 'GET' | 'POST',
  body?: unknown,
): Promise<ApiAnswer | null> {
  const controller = new AbortController()
  const timer = setTimeout(() => {
    controller.abort()
  }, REQUEST_TIMEOUT_MS)
  try {
    const res = await fetch(path, {
      method,
      headers: method === 'POST' ? { 'content-type': 'application/json' } : {},
      body: method === 'POST' ? JSON.stringify(body ?? {}) : undefined,
      credentials: 'same-origin',
      signal: controller.signal,
    })
    let parsed: unknown = null
    try {
      parsed = await res.json()
    } catch {
      parsed = null
    }
    return { status: res.status, body: parsed }
  } catch {
    return null
  } finally {
    clearTimeout(timer)
  }
}

export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null
}
