// Shared rules for every /api/* answer and request.
// - Same origin only. No Access-Control-Allow-Origin header is ever sent, so
//   other websites cannot read these responses from a browser.
// - Responses are JSON and never cached.
// - Routes that change something accept only POST with a JSON content type,
//   and refuse a request whose Origin header names another site
//   (factory/jobs/8-first-session/spec.md, "Done when" 5).

export const API_HEADERS: HeadersInit = {
  'cache-control': 'no-store',
  'x-content-type-options': 'nosniff',
}

export function json(body: unknown, status = 200, extraHeaders: HeadersInit = {}): Response {
  const headers = new Headers(API_HEADERS)
  new Headers(extraHeaders).forEach((value, key) => {
    headers.set(key, value)
  })
  return Response.json(body, { status, headers })
}

/** Adds each Set-Cookie value to the answer. */
export function withCookies(response: Response, cookies: readonly string[]): Response {
  for (const cookie of cookies) response.headers.append('set-cookie', cookie)
  return response
}

export function isJson(contentType: string | null): boolean {
  return (contentType ?? '').split(';')[0]?.trim().toLowerCase() === 'application/json'
}

// The body is read (up to a cap) before answering. Answering with the body
// unread broke the next request on the same connection in the local Workers
// runtime (job 2-smoke). Anything larger than the cap is cancelled unread.
export const MAX_BODY_BYTES = 16 * 1024

/** Reads the body as text, or null when it is larger than the cap. */
export async function readBody(request: Request, cap = MAX_BODY_BYTES): Promise<string | null> {
  const reader: ReadableStreamDefaultReader<Uint8Array> | undefined = request.body?.getReader()
  if (!reader) return ''
  const parts: Uint8Array[] = []
  let read = 0
  try {
    for (;;) {
      const { done, value } = await reader.read()
      if (done) break
      read += value.byteLength
      if (read > cap) {
        await reader.cancel()
        return null
      }
      parts.push(value)
    }
  } catch {
    return null
  }
  const all = new Uint8Array(read)
  let at = 0
  for (const part of parts) {
    all.set(part, at)
    at += part.byteLength
  }
  return new TextDecoder().decode(all)
}

/** True when the Origin header is missing or names this same address. */
export function sameOrigin(request: Request): boolean {
  const origin = request.headers.get('origin')
  if (origin === null) return true
  return origin === new URL(request.url).origin
}

/**
 * The checks every route that changes something runs first. Returns an
 * answer to send when the request is refused, or null when it may go on. The
 * body is always read first, so a refused request still has its body drained.
 */
export async function refuseUnsafeWrite(
  request: Request,
  cap = MAX_BODY_BYTES,
): Promise<{ refused: Response; body?: undefined } | { refused: null; body: string }> {
  const body = await readBody(request, cap)
  if (request.method !== 'POST') {
    return { refused: json({ error: 'method_not_allowed' }, 405, { allow: 'POST' }) }
  }
  if (!sameOrigin(request)) return { refused: json({ error: 'forbidden' }, 403) }
  if (!isJson(request.headers.get('content-type'))) {
    return { refused: json({ error: 'unsupported_media_type' }, 415) }
  }
  if (body === null) return { refused: json({ error: 'body_too_large' }, 413) }
  return { refused: null, body }
}

/** For GET routes, which change nothing. */
export async function refuseNonGet(request: Request): Promise<Response | null> {
  await readBody(request)
  if (request.method === 'GET') return null
  return json({ error: 'method_not_allowed' }, 405, { allow: 'GET' })
}
