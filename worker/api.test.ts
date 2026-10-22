import { describe, expect, it, vi } from 'vitest'
import { handleApi, type ApiDeps, type ApiEnv } from './api.ts'
import { handleRequest } from './index.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/1-stack/spec.md that each test protects.

const ORIGIN = 'http://localhost:5173'
const PROJECT = 'https://example-ref.supabase.co'
const KEY = 'publishable-test-value'
const noEnv: ApiEnv = {}
const configured: ApiEnv = { SUPABASE_URL: PROJECT, SUPABASE_PUBLISHABLE_KEY: KEY }

function req(path: string, init: RequestInit = {}): Request {
  return new Request(`${ORIGIN}${path}`, init)
}

async function bodyOf(res: Response): Promise<Record<string, unknown>> {
  return res.json<Record<string, unknown>>()
}

function answering(status: number, body = '{"errors":[]}', contentType = 'application/json') {
  return vi.fn<ApiDeps['fetch']>(() =>
    Promise.resolve(new Response(body, { status, headers: { 'content-type': contentType } })),
  )
}

describe('/api/health', () => {
  it('[2] returns JSON from the Worker with status ok', async () => {
    const res = await handleApi(req('/api/health'), noEnv)
    expect(res.status).toBe(200)
    expect(res.headers.get('content-type')).toMatch(/^application\/json/)
    const body = await bodyOf(res)
    expect(body.status).toBe('ok')
    expect(body.service).toBe('puhuscribe')
  })

  it('[2] is reached through the Worker entry point for /api/* paths', async () => {
    const res = await handleRequest(req('/api/health'), noEnv)
    expect(res.status).toBe(200)
    expect((await bodyOf(res)).status).toBe('ok')
  })

  it('[2] is never cached', async () => {
    const res = await handleApi(req('/api/health'), noEnv)
    expect(res.headers.get('cache-control')).toBe('no-store')
  })

  it('[2] answers HEAD requests without a body', async () => {
    const res = await handleApi(req('/api/health', { method: 'HEAD' }), noEnv)
    expect(res.status).toBe(200)
    expect(await res.text()).toBe('')
  })
})

describe('/api/health database check', () => {
  it('[13] reports the database as not configured when no test project is set', async () => {
    const res = await handleApi(req('/api/health'), noEnv)
    expect((await bodyOf(res)).database).toBe('not_configured')
  })

  it('[13] reports the database as reachable after a real query through the project API', async () => {
    const fetchSpy = answering(200)
    const res = await handleApi(req('/api/health'), configured, { fetch: fetchSpy })
    expect((await bodyOf(res)).database).toBe('reachable')
    expect(fetchSpy).toHaveBeenCalledTimes(1)
    const [url, init] = fetchSpy.mock.calls[0] ?? []
    expect(url).toBe(`${PROJECT}/graphql/v1`)
    expect(init?.method).toBe('POST')
    expect(new Headers(init?.headers).get('apikey')).toBe(KEY)
    expect(new Headers(init?.headers).get('authorization')).toBeNull()
  })

  it('[13] tolerates a trailing slash on the project address', async () => {
    const fetchSpy = answering(200)
    await handleApi(req('/api/health'), { ...configured, SUPABASE_URL: `${PROJECT}/` }, { fetch: fetchSpy })
    expect(fetchSpy.mock.calls[0]?.[0]).toBe(`${PROJECT}/graphql/v1`)
  })

  it('[13] reports unreachable when the project answers with an error', async () => {
    const res = await handleApi(req('/api/health'), configured, { fetch: answering(503) })
    expect((await bodyOf(res)).database).toBe('unreachable')
  })

  it('[13] reports unreachable when the answer is not JSON', async () => {
    const res = await handleApi(req('/api/health'), configured, {
      fetch: answering(200, '<html>maintenance</html>', 'text/html'),
    })
    expect((await bodyOf(res)).database).toBe('unreachable')
  })

  it('[13] reports unreachable when the request fails or times out', async () => {
    const throwing = vi.fn<ApiDeps['fetch']>(() => Promise.reject(new Error('network down')))
    const res = await handleApi(req('/api/health'), configured, { fetch: throwing })
    expect((await bodyOf(res)).database).toBe('unreachable')
  })

  it('[13] gives the check a time limit', async () => {
    const fetchSpy = answering(200)
    await handleApi(req('/api/health'), configured, { fetch: fetchSpy })
    expect(fetchSpy.mock.calls[0]?.[1]?.signal).toBeInstanceOf(AbortSignal)
  })

  it('[8] never sends the key, the project address or upstream text back in the response', async () => {
    const res = await handleApi(req('/api/health'), configured, { fetch: answering(503, 'upstream detail') })
    const text = await res.text()
    expect(text).not.toContain(KEY)
    expect(text).not.toContain('example-ref')
    expect(text).not.toContain('upstream detail')
  })

  it('[2] HEAD requests do not query the database', async () => {
    const fetchSpy = answering(200)
    await handleApi(req('/api/health', { method: 'HEAD' }), configured, { fetch: fetchSpy })
    expect(fetchSpy).not.toHaveBeenCalled()
  })
})

describe('cross site rules for /api/*', () => {
  it('[8] does not send Access-Control-Allow-Origin, even when another site asks', async () => {
    const res = await handleApi(req('/api/health', { headers: { Origin: 'https://evil.example' } }), noEnv)
    expect(res.headers.get('access-control-allow-origin')).toBeNull()
  })

  it('[8] refuses cross site preflight requests without any CORS header', async () => {
    const res = await handleApi(
      req('/api/health', {
        method: 'OPTIONS',
        headers: { Origin: 'https://evil.example', 'Access-Control-Request-Method': 'GET' },
      }),
      noEnv,
    )
    expect(res.status).toBe(405)
    expect(res.headers.get('allow')).toBe('GET, HEAD')
    expect(res.headers.get('access-control-allow-origin')).toBeNull()
  })

  it('[8] answers unknown /api routes with a JSON 404 and no CORS header', async () => {
    const res = await handleApi(
      req('/api/does-not-exist', { headers: { Origin: 'https://evil.example' } }),
      noEnv,
    )
    expect(res.status).toBe(404)
    expect(res.headers.get('access-control-allow-origin')).toBeNull()
    expect((await bodyOf(res)).error).toBe('not_found')
  })

  it('[8] the Worker entry point sends non /api paths nowhere near the API', async () => {
    const res = await handleRequest(req('/apiary'), noEnv)
    expect(res.status).toBe(404)
    expect(await res.text()).toBe('Not found')
  })
})
