import { describe, expect, it } from 'vitest'
import type { ReadySession } from '../src/lib/session-types.ts'
import { handleApi, type ApiDeps } from './api.ts'
import {
  ENV,
  cookieHeader,
  fakeDb,
  fakeSupabase,
  get,
  post,
  sampleContent,
  sampleDialogue,
  type FakeDb,
  type FakeSupabase,
} from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects.
// The session routes, with a fake Supabase Auth and a fake learner database.

async function learner(db: FakeDb): Promise<{ supabase: FakeSupabase; cookie: string; deps: ApiDeps }> {
  const supabase = fakeSupabase()
  const deps: ApiDeps = { fetch: supabase.fetch, learnerDb: () => db }
  const res = await handleApi(post('/api/guest'), ENV, deps)
  return { supabase, cookie: cookieHeader(res), deps }
}

function twoUnits(): FakeDb {
  // Listed out of order on purpose: unit 2 comes back first.
  const content = new Map([
    [3, sampleContent()],
    [1, sampleContent()],
    [2, sampleContent()],
  ])
  return fakeDb([sampleDialogue(3, 20, 1), sampleDialogue(2, 10, 2), sampleDialogue(1, 10, 1)], content)
}

async function today(cookie: string, deps: ApiDeps) {
  const res = await handleApi(post('/api/sessions/today', { cookie }), ENV, deps)
  return { res, body: await res.json<Record<string, unknown>>() }
}

describe('POST /api/sessions/today', () => {
  it('[session 6] picks the first readable dialogue by unit position, then dialogue position, and adds one session', async () => {
    const db = twoUnits()
    const { cookie, deps } = await learner(db)
    const { res, body } = await today(cookie, deps)
    expect(res.status).toBe(200)
    expect(body.state).toBe('ready')
    expect(db.sessions).toHaveLength(1)
    expect(db.sessions[0]?.dialogueId).toBe(1)
    expect((body as unknown as ReadySession).dialogue.title).toBe('Dialogue 1')
    expect((body as unknown as ReadySession).unit.canDo).toBe('Can do of unit 10.')
  })

  it('[session 6] [session 18] reuses the unfinished session: a second call adds no row', async () => {
    const db = twoUnits()
    const { cookie, deps } = await learner(db)
    const first = await today(cookie, deps)
    const second = await today(cookie, deps)
    expect(db.sessions).toHaveLength(1)
    expect((second.body as unknown as ReadySession).session.id).toBe(
      (first.body as unknown as ReadySession).session.id,
    )
  })

  it('[session 6] moves on to the next dialogue once a session has ended', async () => {
    const db = twoUnits()
    const { cookie, deps } = await learner(db)
    await today(cookie, deps)
    const row = db.sessions[0]
    if (row) row.endedAt = new Date().toISOString()
    await today(cookie, deps)
    expect(db.sessions.map((s) => s.dialogueId)).toEqual([1, 2])
  })

  it('[session 6] says all_done when every readable dialogue is finished', async () => {
    const db = fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, sampleContent()]]))
    const { cookie, deps } = await learner(db)
    await today(cookie, deps)
    const row = db.sessions[0]
    if (row) row.endedAt = new Date().toISOString()
    const { body } = await today(cookie, deps)
    expect(body).toEqual({ state: 'all_done' })
    const front = await handleApi(get('/api/today', cookie), ENV, deps)
    expect(await front.json()).toEqual({ signedIn: true, today: 'all_done' })
  })

  it('[session 6] says not_ready, with no Finnish, when nothing is readable', async () => {
    const db = fakeDb()
    const { cookie, deps } = await learner(db)
    const { res, body } = await today(cookie, deps)
    expect(res.status).toBe(200)
    expect(body).toEqual({ state: 'not_ready' })
    expect(db.sessions).toEqual([])
  })

  it('[session 6] never takes a user id from the request', async () => {
    const db = twoUnits()
    const { cookie, deps } = await learner(db)
    const res = await handleApi(
      post('/api/sessions/today', {
        cookie,
        body: JSON.stringify({ user_id: 'someone-else', dialogue_id: 3 }),
      }),
      ENV,
      deps,
    )
    expect(res.status).toBe(200)
    expect(db.sessions[0]?.dialogueId).toBe(1)
  })

  it('[session 6] answers 401 signed_out without a sign in, and makes nothing', async () => {
    const db = twoUnits()
    const supabase = fakeSupabase()
    const res = await handleApi(post('/api/sessions/today'), ENV, {
      fetch: supabase.fetch,
      learnerDb: () => db,
    })
    expect(res.status).toBe(401)
    expect(await res.json()).toEqual({ error: 'signed_out' })
    expect(db.sessions).toEqual([])
  })

  it('[session 9] [session 12] sends both registers as words, a name as plain text, and a word whose form is not readable as plain text', async () => {
    const db = twoUnits()
    const { cookie, deps } = await learner(db)
    const { body } = await today(cookie, deps)
    const session = body as unknown as ReadySession
    const [first, second] = session.lines
    expect(first?.spoken.map((w) => w.text)).toEqual(['Moi', 'Mä', 'oon', 'Alex'])
    expect(first?.spoken.map((w) => w.after ?? '')).toEqual(['!', '', '', '.'])
    expect(first?.spoken[1]?.form).toEqual({
      lemma: 'minä',
      formName: 'I',
      why: 'Why two.',
      spoken: 'mä',
      written: 'minä',
    })
    expect(first?.spoken[3]?.form).toBeUndefined()
    expect(first?.written.map((w) => w.text)).toEqual(['Hei', 'Minä', 'olen', 'Alex'])
    // Form 99 was not returned by the database (a draft), so tavata has no card.
    expect(second?.spoken[1]).toEqual({ text: 'tavata', after: '!' })
    expect(JSON.stringify(session)).not.toContain('"formId"')
  })

  it('[session 10] gives each line its audio at /audio/<key> on the same address', async () => {
    const db = twoUnits()
    const { cookie, deps } = await learner(db)
    const { body } = await today(cookie, deps)
    const line = (body as unknown as ReadySession).lines[0]
    expect(line?.spokenAudio).toBe('/audio/unit-test/1-puhe.mp3')
    expect(line?.writtenAudio).toBe('/audio/unit-test/1-kirja.mp3')
  })

  it('[session 9] refuses the whole session when a line cannot be split into its words', async () => {
    const content = sampleContent()
    const token = content.tokens[2]
    if (token) token.surface = 'olemme'
    const db = fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, content]]))
    const { cookie, deps } = await learner(db)
    const { res, body } = await today(cookie, deps)
    expect(res.status).toBe(500)
    expect(body).toEqual({ error: 'content_unusable' })
  })

  it('[session 3] the answer holds no token and no user id', async () => {
    const db = twoUnits()
    const { supabase, cookie, deps } = await learner(db)
    const res = await handleApi(post('/api/sessions/today', { cookie }), ENV, deps)
    const text = await res.text()
    for (const secret of [...supabase.issued, ...supabase.userIds]) expect(text).not.toContain(secret)
  })

  it('[session 5] GET is refused with 405 and adds nothing', async () => {
    const db = twoUnits()
    const { cookie, deps } = await learner(db)
    const res = await handleApi(get('/api/sessions/today', cookie), ENV, deps)
    expect(res.status).toBe(405)
    expect(db.sessions).toEqual([])
  })

  it('[session 5] a request from another website gets 403 and adds nothing', async () => {
    const db = twoUnits()
    const { cookie, deps } = await learner(db)
    const res = await handleApi(
      post('/api/sessions/today', { cookie, origin: 'https://evil.example' }),
      ENV,
      deps,
    )
    expect(res.status).toBe(403)
    expect(db.sessions).toEqual([])
  })
})

describe('GET /api/today', () => {
  it('[session 18] says continue for an unfinished session, start otherwise, and changes nothing', async () => {
    const db = twoUnits()
    const { cookie, deps } = await learner(db)
    const before = await handleApi(get('/api/today', cookie), ENV, deps)
    expect(await before.json()).toEqual({ signedIn: true, today: 'start', canDo: 'Can do of unit 10.' })
    expect(db.sessions).toEqual([])
    await today(cookie, deps)
    const after = await handleApi(get('/api/today', cookie), ENV, deps)
    expect(await after.json()).toEqual({ signedIn: true, today: 'continue', canDo: 'Can do of unit 10.' })
    expect(db.sessions).toHaveLength(1)
  })

  it('[session 5] POST is refused with 405', async () => {
    const db = twoUnits()
    const { cookie, deps } = await learner(db)
    const res = await handleApi(post('/api/today', { cookie }), ENV, deps)
    expect(res.status).toBe(405)
    expect(res.headers.get('allow')).toBe('GET')
  })
})

async function readySession(): Promise<{ db: FakeDb; cookie: string; deps: ApiDeps; id: string }> {
  const db = twoUnits()
  const { cookie, deps } = await learner(db)
  const { body } = await today(cookie, deps)
  return { db, cookie, deps, id: (body as unknown as ReadySession).session.id }
}

function step(id: string, cookie: string, value: unknown, origin?: string) {
  return post(`/api/sessions/${id}/step`, { cookie, origin, body: JSON.stringify({ step: value }) })
}

describe('POST /api/sessions/<id>/step', () => {
  it('[session 9] [session 13] records hear, then understand', async () => {
    const { db, cookie, deps, id } = await readySession()
    const hear = await handleApi(step(id, cookie, 'hear'), ENV, deps)
    expect(hear.status).toBe(200)
    expect(db.sessions[0]?.step).toBe('hear')
    const understand = await handleApi(step(id, cookie, 'understand'), ENV, deps)
    expect(understand.status).toBe(200)
    expect(db.sessions[0]?.step).toBe('understand')
  })

  it('[session 13] refuses understand before hear', async () => {
    const { db, cookie, deps, id } = await readySession()
    const res = await handleApi(step(id, cookie, 'understand'), ENV, deps)
    expect(res.status).toBe(409)
    expect(db.sessions[0]?.step).toBeNull()
  })

  it('[session 13] refuses any step beyond understand from the browser', async () => {
    const { db, cookie, deps, id } = await readySession()
    for (const value of ['say', 'keep', 'use', null, 7, 'HEAR']) {
      const res = await handleApi(step(id, cookie, value), ENV, deps)
      expect(res.status, String(value)).toBe(400)
    }
    expect(db.sessions[0]?.step).toBeNull()
  })

  it('[session 18] a step already reached changes nothing', async () => {
    const { db, cookie, deps, id } = await readySession()
    await handleApi(step(id, cookie, 'hear'), ENV, deps)
    await handleApi(step(id, cookie, 'understand'), ENV, deps)
    const again = await handleApi(step(id, cookie, 'hear'), ENV, deps)
    expect(again.status).toBe(200)
    expect(db.sessions[0]?.step).toBe('understand')
  })

  it("[session 6] someone else's or an unknown session id answers 404", async () => {
    const { cookie, deps } = await readySession()
    const res = await handleApi(step('00000000-0000-4000-8000-0000000000ff', cookie, 'hear'), ENV, deps)
    expect(res.status).toBe(404)
  })

  it('[session 5] another website gets 403 and the step is not stored', async () => {
    const { db, cookie, deps, id } = await readySession()
    const res = await handleApi(step(id, cookie, 'hear', 'https://evil.example'), ENV, deps)
    expect(res.status).toBe(403)
    expect(db.sessions[0]?.step).toBeNull()
  })

  it('[session 5] a path that is not a session id answers 404', async () => {
    const { cookie, deps } = await readySession()
    const res = await handleApi(post('/api/sessions/not-an-id/step', { cookie }), ENV, deps)
    expect(res.status).toBe(404)
  })
})

describe('POST /api/sessions/<id>/complete', () => {
  it('[session 15] saves the end of a session at understand once', async () => {
    const { db, cookie, deps, id } = await readySession()
    await handleApi(step(id, cookie, 'hear'), ENV, deps)
    await handleApi(step(id, cookie, 'understand'), ENV, deps)
    const res = await handleApi(post(`/api/sessions/${id}/complete`, { cookie }), ENV, deps)
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ saved: true })
    expect(db.completed).toEqual([id])
  })

  it('[session 16] refuses a session that has not reached understand', async () => {
    const { db, cookie, deps, id } = await readySession()
    await handleApi(step(id, cookie, 'hear'), ENV, deps)
    const res = await handleApi(post(`/api/sessions/${id}/complete`, { cookie }), ENV, deps)
    expect(res.status).toBe(409)
    expect(db.completed).toEqual([])
  })

  it('[session 15] a database fault answers 503 so the screen can offer Try again', async () => {
    const { db, cookie, deps, id } = await readySession()
    await handleApi(step(id, cookie, 'hear'), ENV, deps)
    await handleApi(step(id, cookie, 'understand'), ENV, deps)
    db.failNext = true
    const res = await handleApi(post(`/api/sessions/${id}/complete`, { cookie }), ENV, deps)
    expect(res.status).toBe(503)
    const retry = await handleApi(post(`/api/sessions/${id}/complete`, { cookie }), ENV, deps)
    expect(retry.status).toBe(200)
  })

  it('[session 5] another website gets 403 and nothing is saved', async () => {
    const { db, cookie, deps, id } = await readySession()
    await handleApi(step(id, cookie, 'hear'), ENV, deps)
    await handleApi(step(id, cookie, 'understand'), ENV, deps)
    const res = await handleApi(
      post(`/api/sessions/${id}/complete`, { cookie, origin: 'https://evil.example' }),
      ENV,
      deps,
    )
    expect(res.status).toBe(403)
    expect(db.completed).toEqual([])
  })
})

describe('every answer', () => {
  it('[session 5] no route sends Access-Control-Allow-Origin, even when another site asks', async () => {
    const { cookie, deps, id } = await readySession()
    const requests = [
      post('/api/guest', { origin: 'https://evil.example' }),
      get('/api/today', cookie),
      post('/api/sessions/today', { cookie, origin: 'https://evil.example' }),
      step(id, cookie, 'hear', 'https://evil.example'),
      post(`/api/sessions/${id}/complete`, { cookie, origin: 'https://evil.example' }),
      new Request('https://puhuscribe.example/api/guest', {
        method: 'OPTIONS',
        headers: { origin: 'https://evil.example', 'access-control-request-method': 'POST' },
      }),
    ]
    for (const request of requests) {
      const res = await handleApi(request, ENV, deps)
      expect(res.headers.get('access-control-allow-origin'), request.url).toBeNull()
      expect(res.headers.get('cache-control'), request.url).toBe('no-store')
    }
  })

  it('[session 21] unknown /api paths, and the retired /api/visits, answer 404', async () => {
    const supabase = fakeSupabase()
    for (const path of ['/api/visits', '/api/nothing', '/api', '/api/sessions']) {
      const res = await handleApi(post(path), ENV, { fetch: supabase.fetch })
      expect(res.status, path).toBe(404)
    }
    expect(supabase.requests).toEqual([])
  })

  it('[smoke 4] [session 5] a request body is read and an endless body is cut off, so the answer still comes', async () => {
    const supabase = fakeSupabase()
    let pulled = 0
    const endless = new ReadableStream<Uint8Array>({
      pull(controller) {
        pulled += 1
        controller.enqueue(new Uint8Array(1024))
      },
    })
    const request = new Request('https://puhuscribe.example/api/guest', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: endless,
      // @ts-expect-error Node needs this for a streamed request body.
      duplex: 'half',
    })
    const res = await handleApi(request, ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(413)
    expect(pulled).toBeLessThan(40)
    expect(supabase.requests).toEqual([])
  })
})

describe('request bodies', () => {
  it('[session 21] an unknown path still reads the body before answering 404', async () => {
    let pulled = 0
    const body = new ReadableStream<Uint8Array>({
      pull(controller) {
        pulled += 1
        if (pulled > 2) controller.close()
        else controller.enqueue(new Uint8Array(8))
      },
    })
    const request = new Request('https://puhuscribe.example/api/nothing', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body,
      // @ts-expect-error Node needs this for a streamed request body.
      duplex: 'half',
    })
    const res = await handleApi(request, ENV, { fetch: fakeSupabase().fetch })
    expect(res.status).toBe(404)
    expect(request.bodyUsed).toBe(true)
  })
})
