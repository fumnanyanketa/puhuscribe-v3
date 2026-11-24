import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { cleanPath } from '../src/lib/crash-clean.ts'
import { MAX_REVIEW_NOTE, parseReviewAnswer, reviewPlaceOf } from '../src/lib/review-link.ts'
import { handleApi } from './api.ts'
import { handleRequest, type WorkerEnv } from './index.ts'
import { isPageRoute, RUN_WORKER_FIRST } from './page-routes.ts'
import { isReviewLinkRoute, newReviewToken, withAudioPaths } from './review-links.ts'
import { ENV, ORIGIN, PUBLISHABLE, fakeSupabase, type FakeSupabase } from './test-fakes.ts'

// Labels [review-links N] are the "Done when" statement numbers from
// factory/jobs/review-links/spec.md that each test protects.
// The reviewer's side of the private review links: /api/review/<secret>...,
// answered as anon through the three database doors, and the /review/ pages.

const TOKEN = 'A'.repeat(21) + '_' + 'b'.repeat(20) + '-'
const WRONG = 'Z'.repeat(43)

const OVERVIEW = {
  batch: 1,
  dialogues: [
    { id: 11, position: 1, title: 'A new colleague', stop: 'Meeting people', lines: 6, answered: 0 },
  ],
}
const DIALOGUE = {
  id: 11,
  position: 1,
  of: 27,
  title: 'A new colleague',
  stop: 'Meeting people',
  previous: null,
  next: 12,
  lines: [
    {
      id: 101,
      position: 1,
      speaker: 'Pekka',
      spoken: 'Moi! Mä oon Pekka.',
      written: 'Hei! Minä olen Pekka.',
      english: "Hi! I'm Pekka.",
      spoken_audio: 'meeting-people/1-puhe-0123456789ab.mp3',
      written_audio: 'meeting-people/1-kirja-0123456789ab.mp3',
      answer: null,
      note: null,
    },
  ],
}

let supabase: FakeSupabase
let rpcAnswer: (name: string, body: Record<string, unknown>) => unknown
const written: string[] = []

function rpcCalls(name?: string) {
  return supabase.requests.filter((r) =>
    name ? r.url.pathname === `/rest/v1/rpc/${name}` : r.url.pathname.startsWith('/rest/v1/rpc/'),
  )
}

beforeEach(() => {
  supabase = fakeSupabase()
  rpcAnswer = (name, body) => {
    if (body.p_token !== TOKEN) return name === 'review_link_answer' ? 'no_link' : null
    if (name === 'review_link_overview') return OVERVIEW
    if (name === 'review_link_dialogue') return body.p_dialogue_id === 11 ? DIALOGUE : null
    if (name === 'review_link_answer') return body.p_line_id === 101 ? 'saved' : 'not_in_batch'
    return undefined
  }
  supabase.rest = (request) => {
    const name = request.url.pathname.replace('/rest/v1/rpc/', '')
    const value = rpcAnswer(name, JSON.parse(request.body || '{}') as Record<string, unknown>)
    if (value === undefined) return undefined
    return new Response(JSON.stringify(value), {
      status: 200,
      headers: { 'content-type': 'application/json' },
    })
  }
  written.length = 0
  for (const method of ['log', 'info', 'warn', 'error', 'debug', 'trace'] as const) {
    vi.spyOn(console, method).mockImplementation((...args: unknown[]) => {
      written.push(args.map(String).join(' '))
    })
  }
})

afterEach(() => {
  vi.restoreAllMocks()
})

const get = (path: string, headers: Record<string, string> = {}) =>
  handleApi(new Request(`${ORIGIN}${path}`, { headers }), ENV, { fetch: supabase.fetch })

const answer = (body: unknown, token = TOKEN, headers: Record<string, string> = {}) =>
  handleApi(
    new Request(`${ORIGIN}/api/review/${token}/answers`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', ...headers },
      body: typeof body === 'string' ? body : JSON.stringify(body),
    }),
    ENV,
    { fetch: supabase.fetch },
  )

function expectPrivate(res: Response) {
  expect(res.headers.get('cache-control')).toBe('no-store')
  expect(res.headers.get('x-robots-tag')).toBe('noindex, nofollow')
  expect(res.headers.get('referrer-policy')).toBe('no-referrer')
  expect(res.headers.get('set-cookie')).toBeNull()
}

describe('the link secret', () => {
  it('[review-links 2] a new secret is 32 random bytes as 43 base64url characters, different every time', () => {
    const made = new Set(Array.from({ length: 200 }, () => newReviewToken()))
    expect(made.size).toBe(200)
    for (const token of made) {
      expect(token).toMatch(/^[A-Za-z0-9_-]{43}$/)
      const bytes = atob(token.replace(/-/g, '+').replace(/_/g, '/') + '=')
      expect(bytes.length).toBe(32)
    }
  })

  it('[review-links 2] the secret is asked of the database as it is, which hashes it; the Worker keeps nothing', async () => {
    const res = await get(`/api/review/${TOKEN}`)
    expect(res.status).toBe(200)
    const [call] = rpcCalls('review_link_overview')
    expect(JSON.parse(call?.body ?? '{}')).toEqual({ p_token: TOKEN })
    expect(call?.headers.get('apikey')).toBe(PUBLISHABLE)
    expect(call?.headers.get('authorization')).toBeNull()
  })

  it('[review-links 2] a wrong, deleted or malformed secret all get the same 404, and a malformed one reaches no database', async () => {
    const answers: string[] = []
    for (const path of [
      `/api/review/${WRONG}`,
      '/api/review/short',
      `/api/review/${TOKEN}x`,
      `/api/review/${TOKEN.slice(0, 42)}=`,
      `/api/review/${WRONG}/dialogues/11`,
      `/api/review/${TOKEN}/dialogues/12`,
      `/api/review/${TOKEN}/dialogues/abc`,
      `/api/review/${TOKEN}/dialogues/0`,
      `/api/review/${TOKEN}/other`,
    ]) {
      const res = await get(path)
      expect(res.status, path).toBe(404)
      expectPrivate(res)
      answers.push(JSON.stringify(await res.json()))
    }
    expect(new Set(answers)).toEqual(new Set(['{"error":"link_not_found"}']))
    // Only the well formed secrets were asked about.
    for (const call of rpcCalls())
      expect((JSON.parse(call.body) as { p_token: string }).p_token).toMatch(/^[A-Za-z0-9_-]{43}$/)
  })

  it('[review-links 2] the address check keeps /api/review/answer for the learner daily review', () => {
    expect(isReviewLinkRoute('/api/review/answer')).toBe(false)
    expect(isReviewLinkRoute(`/api/review/${TOKEN}`)).toBe(true)
  })

  it('[review-links 2] a crash report never carries the secret: the page path hides it', () => {
    expect(cleanPath(`/review/${TOKEN}/11`)).toBe('/review/:id/:id')
    expect(cleanPath(`/api/review/${TOKEN}/answers`)).toBe('/api/review/:id/answers')
  })
})

describe('what a link shows', () => {
  it('[review-links 3] the list is the database batch as it is, privately', async () => {
    const res = await get(`/api/review/${TOKEN}`)
    expect(res.status).toBe(200)
    expectPrivate(res)
    expect(await res.json()).toEqual(OVERVIEW)
  })

  it('[review-links 3] a dialogue gives each line spoken, written, English and the same /audio/ paths the app plays', async () => {
    const res = await get(`/api/review/${TOKEN}/dialogues/11`)
    expect(res.status).toBe(200)
    expectPrivate(res)
    const body = await res.json<{ lines: Record<string, unknown>[] }>()
    expect(body.lines[0]).toEqual({
      id: 101,
      position: 1,
      speaker: 'Pekka',
      spoken: 'Moi! Mä oon Pekka.',
      written: 'Hei! Minä olen Pekka.',
      english: "Hi! I'm Pekka.",
      spokenAudio: '/audio/meeting-people/1-puhe-0123456789ab.mp3',
      writtenAudio: '/audio/meeting-people/1-kirja-0123456789ab.mp3',
      answer: null,
      note: null,
    })
    expect(JSON.parse(rpcCalls('review_link_dialogue')[0]?.body ?? '{}')).toEqual({
      p_token: TOKEN,
      p_dialogue_id: 11,
    })
  })

  it('[review-links 3] an audio key that could leave /audio/ gets no audio', () => {
    const out = withAudioPaths({
      lines: [{ spoken_audio: '../secret.mp3', written_audio: 'ok/1.mp3' }],
    }) as { lines: Record<string, unknown>[] }
    expect(out.lines[0]).toEqual({ spokenAudio: null, writtenAudio: '/audio/ok/1.mp3' })
  })

  it('[review-links 3] the reads accept only GET', async () => {
    const res = await handleApi(
      new Request(`${ORIGIN}/api/review/${TOKEN}`, { method: 'POST', body: '{}' }),
      ENV,
      { fetch: supabase.fetch },
    )
    expect(res.status).toBe(405)
  })

  it('[review-links 2] when the database cannot answer, 503 and nothing else', async () => {
    supabase.rest = () => new Response('{}', { status: 500 })
    const res = await get(`/api/review/${TOKEN}`)
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'not_available' })
  })
})

describe('saving an answer', () => {
  it('[review-links 4] each of the three answers is saved through the database as anon', async () => {
    for (const choice of ['correct', 'needs_fix', 'not_sure']) {
      const res = await answer({ lineId: 101, answer: choice, note: null })
      expect(res.status, choice).toBe(200)
      expectPrivate(res)
      expect(await res.json()).toEqual({ saved: true })
    }
    const calls = rpcCalls('review_link_answer').map((c) => JSON.parse(c.body) as Record<string, unknown>)
    expect(calls.map((c) => c.p_answer)).toEqual(['correct', 'needs_fix', 'not_sure'])
    expect(calls[0]).toEqual({ p_token: TOKEN, p_line_id: 101, p_answer: 'correct', p_note: null })
    expect(rpcCalls('review_link_answer')[0]?.headers.get('apikey')).toBe(PUBLISHABLE)
  })

  it('[review-links 4] a note goes only with Needs a fix, trimmed, with its line breaks as \\n', async () => {
    await answer({ lineId: 101, answer: 'needs_fix', note: '  Use "sä".\r\nNot "sinä".  ' })
    await answer({ lineId: 101, answer: 'correct', note: 'dropped' })
    await answer({ lineId: 101, answer: 'needs_fix', note: '   ' })
    const notes = rpcCalls('review_link_answer').map(
      (c) => (JSON.parse(c.body) as { p_note: unknown }).p_note,
    )
    expect(notes).toEqual(['Use "sä".\nNot "sinä".', null, null])
  })

  it('[review-links 4] a note of exactly 500 characters is sent, 501 is refused before the database', async () => {
    expect(
      (await answer({ lineId: 101, answer: 'needs_fix', note: 'ä'.repeat(MAX_REVIEW_NOTE) })).status,
    ).toBe(200)
    expect(
      (await answer({ lineId: 101, answer: 'needs_fix', note: '😀'.repeat(MAX_REVIEW_NOTE) })).status,
    ).toBe(200)
    const long = await answer({ lineId: 101, answer: 'needs_fix', note: 'ä'.repeat(MAX_REVIEW_NOTE + 1) })
    expect(long.status).toBe(400)
    expect(await long.json()).toEqual({ error: 'bad_input', field: 'note' })
    expect(rpcCalls('review_link_answer')).toHaveLength(2)
  })

  it('[review-links 4] anything but the three answers, an odd line id or a control character is refused, saving nothing', async () => {
    const bad: [unknown, string][] = [
      [{ lineId: 101, answer: 'wrong' }, 'answer'],
      [{ lineId: 101, answer: 'Correct' }, 'answer'],
      [{ lineId: 101 }, 'answer'],
      [{ lineId: '101', answer: 'correct' }, 'line'],
      [{ lineId: 0, answer: 'correct' }, 'line'],
      [{ lineId: 1.5, answer: 'correct' }, 'line'],
      [{ answer: 'correct' }, 'line'],
      [{ lineId: 101, answer: 'needs_fix', note: 'Tab\there' }, 'note'],
      [{ lineId: 101, answer: 'needs_fix', note: 7 }, 'note'],
      ['not json', 'line'],
      [null, 'line'],
    ]
    for (const [body, field] of bad) {
      const res = await answer(body)
      expect(res.status, JSON.stringify(body)).toBe(400)
      expect(await res.json()).toEqual({ error: 'bad_input', field })
    }
    expect(rpcCalls('review_link_answer')).toEqual([])
  })

  it('[review-links 4] a line outside the batch, and a wrong or malformed secret, get the same 404', async () => {
    const outside = await answer({ lineId: 999, answer: 'correct' })
    expect(outside.status).toBe(404)
    expect(await outside.json()).toEqual({ error: 'link_not_found' })
    expect((await answer({ lineId: 101, answer: 'correct' }, WRONG)).status).toBe(404)
    expect((await answer({ lineId: 101, answer: 'correct' }, 'short')).status).toBe(404)
    expect(rpcCalls('review_link_answer')).toHaveLength(2)
  })

  it('[review-links 4] only POST with JSON from this same address, and a body of at most 4 KB', async () => {
    expect(
      (
        await handleApi(
          new Request(`${ORIGIN}/api/review/${TOKEN}/answers`, {
            method: 'POST',
            headers: { 'content-type': 'text/plain' },
            body: '{}',
          }),
          ENV,
          { fetch: supabase.fetch },
        )
      ).status,
    ).toBe(415)
    expect(
      (await answer({ lineId: 101, answer: 'correct' }, TOKEN, { origin: 'https://evil.example' })).status,
    ).toBe(403)
    expect((await answer({ lineId: 101, answer: 'needs_fix', note: 'x'.repeat(5000) })).status).toBe(413)
    expect((await get(`/api/review/${TOKEN}/answers`)).status).toBe(405)
    expect(rpcCalls('review_link_answer')).toEqual([])
  })

  it('[review-links 9] when the database says the minute limit is reached, 429 limit', async () => {
    rpcAnswer = () => 'limit'
    const res = await answer({ lineId: 101, answer: 'correct' })
    expect(res.status).toBe(429)
    expect(await res.json()).toEqual({ error: 'limit' })
  })

  it('[review-links 4] an answer the database does not know is 503, never a save', async () => {
    rpcAnswer = () => 'something else'
    expect((await answer({ lineId: 101, answer: 'correct' })).status).toBe(503)
  })

  it('[review-links 7] reads no sign in cookie and sets none, and writes nothing to the log', async () => {
    const cookie = 'sb-fake-ref-auth-token=base64-abc; aleksi_guest=1'
    const res = await get(`/api/review/${TOKEN}`, { cookie })
    expect(res.status).toBe(200)
    expect(res.headers.get('set-cookie')).toBeNull()
    expect(supabase.requests.filter((r) => r.url.pathname.startsWith('/auth/'))).toEqual([])
    await answer({ lineId: 101, answer: 'needs_fix', note: 'Secret note' })
    expect(written.join('\n')).not.toContain(TOKEN)
    expect(written.join('\n')).not.toContain('Secret note')
  })
})

describe('the page rules', () => {
  it('[review-links 4] the page and the Worker share one rule for an answer', () => {
    expect(parseReviewAnswer({ lineId: 3, answer: 'not_sure', note: 'x' })).toEqual({
      lineId: 3,
      answer: 'not_sure',
      note: null,
    })
  })

  it('[review-links 2] a page address is a list, a dialogue, or a broken link', () => {
    expect(reviewPlaceOf(`/review/${TOKEN}`)).toEqual({ kind: 'list', token: TOKEN })
    expect(reviewPlaceOf(`/review/${TOKEN}/11`)).toEqual({ kind: 'dialogue', token: TOKEN, dialogueId: 11 })
    for (const path of [
      '/review',
      '/review/short',
      `/review/${TOKEN}/0`,
      `/review/${TOKEN}/x`,
      `/review/${TOKEN}/11/2`,
    ])
      expect(reviewPlaceOf(path), path).toEqual({ kind: 'broken' })
  })
})

describe('the /review/ pages', () => {
  const PAGE =
    '<!doctype html><html><head><meta name="robots" content="noindex, follow"></head><body></body></html>'
  let env: WorkerEnv
  let served: string[]

  beforeEach(() => {
    served = []
    env = {
      ...ENV,
      ASSETS: {
        fetch: (input: RequestInfo | URL) => {
          served.push(new URL(input instanceof Request ? input.url : String(input)).pathname)
          return Promise.resolve(
            new Response(PAGE, {
              status: 200,
              headers: { 'content-type': 'text/html; charset=utf-8', etag: '"x"' },
            }),
          )
        },
        connect: vi.fn(),
      },
    }
  })

  it('[review-links 7] every /review/ address runs the Worker first, never a public file', () => {
    expect(RUN_WORKER_FIRST).toContain('/review/*')
    expect(isPageRoute(`/review/${TOKEN}`)).toBe(true)
    expect(isPageRoute(`/review/${TOKEN}/11`)).toBe(true)
  })

  it('[review-links 7] the page is the app shell, noindex, never cached, sends no Referer and sets no cookie', async () => {
    const ctx = { waits: [] as Promise<unknown>[] }
    const res = await handleRequest(
      new Request(`${ORIGIN}/review/${TOKEN}`, { headers: { cookie: 'sb-fake-ref-auth-token=x' } }),
      env,
      { fetch: supabase.fetch },
      { waitUntil: (p) => void ctx.waits.push(p) },
    )
    expect(res.status).toBe(200)
    expect(await res.text()).toBe(PAGE)
    expectPrivate(res)
    expect(res.headers.get('etag')).toBeNull()
    expect(served).toEqual([`/review/${TOKEN}`])
    // Not counted as a visit, and no database or sign in lookup at all.
    expect(ctx.waits).toEqual([])
    expect(supabase.requests).toEqual([])
  })

  it('[review-links 7] a wrong secret gets the same page: the page itself shows "This link does not work"', async () => {
    const res = await handleRequest(new Request(`${ORIGIN}/review/short`), env, { fetch: supabase.fetch })
    expect(res.status).toBe(200)
    expect(await res.text()).toBe(PAGE)
    expect(supabase.requests).toEqual([])
  })

  it('[review-links 7] only GET and HEAD', async () => {
    const res = await handleRequest(
      new Request(`${ORIGIN}/review/${TOKEN}`, { method: 'POST', body: 'x' }),
      env,
      { fetch: supabase.fetch },
    )
    expect(res.status).toBe(405)
    expect(served).toEqual([])
  })
})
