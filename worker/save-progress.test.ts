import { describe, expect, it, vi } from 'vitest'
import type { ReadySession } from '../src/lib/session-types.ts'
import { handleApi, type ApiDeps } from './api.ts'
import {
  ENV,
  cookieHeader,
  fakeDb,
  fakeSupabase,
  post,
  sampleContent,
  sampleDialogue,
  type FakeDb,
  type RecordedRequest,
} from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/18-save-progress/spec.md that each test protects.
// The extra field of the complete answer, with a fake learner database and,
// where the learner's token matters, the real database module against a fake
// Supabase.

async function readySession(
  steps: readonly string[] = ['hear', 'understand'],
): Promise<{ db: FakeDb; cookie: string; deps: ApiDeps; id: string }> {
  const db = fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, sampleContent()]]))
  const supabase = fakeSupabase()
  const deps: ApiDeps = { fetch: supabase.fetch, learnerDb: () => db }
  const guest = await handleApi(post('/api/guest'), ENV, deps)
  const cookie = cookieHeader(guest)
  const res = await handleApi(post('/api/sessions/today', { cookie }), ENV, deps)
  const id = (await res.json<ReadySession>()).session.id
  for (const step of steps) {
    await handleApi(post(`/api/sessions/${id}/step`, { cookie, body: JSON.stringify({ step }) }), ENV, deps)
  }
  return { db, cookie, deps, id }
}

function complete(id: string, cookie: string) {
  return post(`/api/sessions/${id}/complete`, { cookie })
}

describe('the answer to POST /api/sessions/<id>/complete', () => {
  it('[save-progress 3] stays {"saved":true} when the database says the note is not due', async () => {
    const { db, cookie, deps, id } = await readySession()
    const res = await handleApi(complete(id, cookie), ENV, deps)
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ saved: true })
    expect(db.noteAsked).toEqual([id])
  })

  it('[save-progress 3] adds "saveNote":"first" when the database says the note is due', async () => {
    const { db, cookie, deps, id } = await readySession()
    db.note = 'first'
    const res = await handleApi(complete(id, cookie), ENV, deps)
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ saved: true, saveNote: 'first' })
  })

  it('[save-progress 3] [save-progress 8] adds "saveNote":"reminder" for the reminder', async () => {
    const { db, cookie, deps, id } = await readySession()
    db.note = 'reminder'
    const res = await handleApi(complete(id, cookie), ENV, deps)
    expect(await res.json()).toEqual({ saved: true, saveNote: 'reminder' })
  })

  it('[save-progress 3] asks the database only after complete_session succeeded, never before or without it', async () => {
    const { db, cookie, deps, id } = await readySession()
    const events: string[] = []
    const complete_ = db.completeSession
    const note_ = db.saveProgressNote
    db.completeSession = async (session) => {
      events.push('complete')
      return complete_(session)
    }
    db.saveProgressNote = async (session) => {
      events.push('note')
      return note_(session)
    }
    await handleApi(complete(id, cookie), ENV, deps)
    expect(events).toEqual(['complete', 'note'])
  })

  it('[save-progress 3] does not ask when the session is not found, not ready or the save failed', async () => {
    const { db, cookie, deps, id } = await readySession()
    // Not found: a session id that is not the learner's.
    const other = '00000000-0000-4000-8000-0000000000ff'
    expect((await handleApi(complete(other, cookie), ENV, deps)).status).toBe(404)
    // The save fails.
    db.failNext = true
    expect((await handleApi(complete(id, cookie), ENV, deps)).status).toBe(503)
    expect(db.noteAsked).toEqual([])
  })

  it('[save-progress 3] does not ask when the session has not reached Understand it', async () => {
    const { db, cookie, deps, id } = await readySession(['hear'])
    db.note = 'first'
    const res = await handleApi(complete(id, cookie), ENV, deps)
    expect(res.status).toBe(409)
    expect(await res.json()).toEqual({ error: 'step_out_of_order' })
    expect(db.noteAsked).toEqual([])
  })

  it('[save-progress 3] a database function that throws gives the plain answer with status 200, and the session is still saved', async () => {
    const { db, cookie, deps, id } = await readySession()
    db.note = 'first'
    db.noteFails = true
    const res = await handleApi(complete(id, cookie), ENV, deps)
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ saved: true })
    expect(db.completed).toEqual([id])
    expect(db.noteAsked).toEqual([id])
  })

  it('[save-progress 3] the status, headers and cookies are the same with and without the note', async () => {
    const plain = await readySession()
    const withNote = await readySession()
    withNote.db.note = 'first'
    const a = await handleApi(complete(plain.id, plain.cookie), ENV, plain.deps)
    const b = await handleApi(complete(withNote.id, withNote.cookie), ENV, withNote.deps)
    expect(b.status).toBe(a.status)
    const names = (res: Response) =>
      [...res.headers.keys()].filter((name) => name !== 'content-length').sort()
    expect(names(b)).toEqual(names(a))
    expect(b.headers.get('content-type')).toBe(a.headers.get('content-type'))
    expect(b.headers.get('cache-control')).toBe(a.headers.get('cache-control'))
    expect(b.headers.getSetCookie().length).toBe(a.headers.getSetCookie().length)
  })

  it('[save-progress 3] adds no route: the note cannot be asked for on its own', async () => {
    const { db, cookie, deps, id } = await readySession()
    db.note = 'first'
    for (const path of [
      `/api/sessions/${id}/note`,
      `/api/sessions/${id}/save-note`,
      '/api/save-note',
      '/api/note',
    ]) {
      for (const method of ['GET', 'POST']) {
        const request =
          method === 'GET'
            ? new Request(`https://puhuscribe.example${path}`, { headers: { cookie } })
            : post(path, { cookie })
        const res = await handleApi(request, ENV, deps)
        expect(res.status, `${method} ${path}`).toBe(404)
      }
    }
    expect(db.noteAsked).toEqual([])
  })
})

describe('a learner who is not signed in', () => {
  it('[save-progress 6] gets 401 as in job 8, no saveNote, and the database function is never called', async () => {
    const db = fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, sampleContent()]]))
    db.note = 'first'
    const supabase = fakeSupabase()
    const res = await handleApi(complete('00000000-0000-4000-8000-000000000001', ''), ENV, {
      fetch: supabase.fetch,
      learnerDb: () => db,
    })
    expect(res.status).toBe(401)
    const body = await res.json<Record<string, unknown>>()
    expect(body).toEqual({ error: 'signed_out' })
    expect(body).not.toHaveProperty('saveNote')
    expect(db.noteAsked).toEqual([])
    expect(db.completed).toEqual([])
  })

  it('[save-progress 6] a cookie for an account that no longer exists gets 401 and no call to the function', async () => {
    const { db, cookie, id } = await readySession()
    db.note = 'first'
    // A different Supabase that has never heard of this learner: the cookie cannot be renewed.
    const supabase = fakeSupabase()
    const res = await handleApi(complete(id, cookie), ENV, { fetch: supabase.fetch, learnerDb: () => db })
    expect(res.status).toBe(401)
    expect(db.noteAsked).toEqual([])
  })
})

describe('finishing the same first session twice', () => {
  it('[save-progress 7] answers with the note both times, because the first answer may never have reached the screen', async () => {
    const { db, cookie, deps, id } = await readySession()
    db.note = 'first'
    const first = await handleApi(complete(id, cookie), ENV, deps)
    const second = await handleApi(complete(id, cookie), ENV, deps)
    expect(await first.json()).toEqual({ saved: true, saveNote: 'first' })
    expect(await second.json()).toEqual({ saved: true, saveNote: 'first' })
    expect(db.noteAsked).toEqual([id, id])
  })
})

// The real database module against a fake Supabase ----------------------------------

function rpcAnswer(value: unknown, status = 200) {
  return (request: RecordedRequest): Response | undefined => {
    if (request.url.pathname === '/rest/v1/rpc/complete_session') return new Response(null, { status: 204 })
    if (request.url.pathname === '/rest/v1/rpc/save_progress_note') {
      return new Response(JSON.stringify(value), {
        status,
        headers: { 'content-type': 'application/json' },
      })
    }
    return undefined
  }
}

async function signedInLearner(value: unknown, status = 200) {
  const supabase = fakeSupabase()
  supabase.rest = rpcAnswer(value, status)
  const guest = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
  return { supabase, cookie: cookieHeader(guest), accessToken: supabase.issued[0] ?? '' }
}

describe('the real database module', () => {
  const id = '00000000-0000-4000-8000-000000000001'

  it('[save-progress 3] asks public.save_progress_note once, after complete_session, with the learner token and only the session id', async () => {
    const { supabase, cookie, accessToken } = await signedInLearner('first')
    const res = await handleApi(complete(id, cookie), ENV, { fetch: supabase.fetch })
    expect(await res.json()).toEqual({ saved: true, saveNote: 'first' })
    const rpcs = supabase.requests.filter((r) => r.url.pathname.startsWith('/rest/v1/rpc/'))
    expect(rpcs.map((r) => r.url.pathname)).toEqual([
      '/rest/v1/rpc/complete_session',
      '/rest/v1/rpc/save_progress_note',
    ])
    const note = rpcs[1]
    expect(JSON.parse(note?.body ?? 'null')).toEqual({ p_session_id: id })
    expect(note?.headers.get('authorization')).toBe(`Bearer ${accessToken}`)
  })

  it('[save-progress 3] the reminder reaches the answer', async () => {
    const { supabase, cookie } = await signedInLearner('reminder')
    const res = await handleApi(complete(id, cookie), ENV, { fetch: supabase.fetch })
    expect(await res.json()).toEqual({ saved: true, saveNote: 'reminder' })
  })

  it('[save-progress 3] an answer of none, or any word the Worker does not know, gives the plain answer', async () => {
    for (const value of ['none', 'something else', null, 7]) {
      const { supabase, cookie } = await signedInLearner(value)
      const res = await handleApi(complete(id, cookie), ENV, { fetch: supabase.fetch })
      expect(res.status).toBe(200)
      expect(await res.json(), String(value)).toEqual({ saved: true })
    }
  })

  it('[save-progress 3] a database error from the function gives the plain answer with status 200', async () => {
    const { supabase, cookie } = await signedInLearner({ message: 'boom' }, 500)
    const res = await handleApi(complete(id, cookie), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ saved: true })
  })

  it('[save-progress 6] with no sign in the function is never reached', async () => {
    const supabase = fakeSupabase()
    supabase.rest = rpcAnswer('first')
    const res = await handleApi(complete(id, ''), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(401)
    expect(supabase.requests.filter((r) => r.url.pathname.startsWith('/rest/v1/'))).toEqual([])
  })

  it('[save-progress 3] nothing is written to the log', async () => {
    const spies = (['log', 'info', 'warn', 'error', 'debug'] as const).map((name) =>
      vi.spyOn(console, name).mockImplementation(() => undefined),
    )
    try {
      const failing = await signedInLearner({ message: 'boom' }, 500)
      await handleApi(complete(id, failing.cookie), ENV, { fetch: failing.supabase.fetch })
      const ok = await signedInLearner('first')
      await handleApi(complete(id, ok.cookie), ENV, { fetch: ok.supabase.fetch })
      for (const spy of spies) expect(spy).not.toHaveBeenCalled()
    } finally {
      for (const spy of spies) spy.mockRestore()
    }
  })
})
