import { describe, expect, it } from 'vitest'
import { handleApi, type ApiDeps } from './api.ts'
import { DatabaseUnavailable } from './learner-db.ts'
import { roadStop, visitorStop, type RoadDb, type RoadStop } from './road.ts'
import { ENV, PUBLISHABLE, cookieHeader, fakeSupabase, get, post } from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/20-a1-road/spec.md that each test protects: [a1-road N].
// GET /api/road with a fake database. The database's own rules (what counts as ready or done)
// are proved in supabase/tests/database/a1_road.test.sql; here the route's rules are.

const COLUMNS = [
  'stop_number',
  'stop_slug',
  'title_en',
  'can_do_en',
  'part_number',
  'part_title_en',
  'dialogues_total',
  'dialogues_ready',
  'dialogues_done',
  'review_forms_total',
  'review_forms_reviewed',
  'lessons_total',
  'lessons_done',
  'live',
].sort()

function row(n: number, extra: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    stop_number: n,
    stop_slug: `stop-${String(n)}`,
    title_en: `Stop ${String(n)}`,
    can_do_en: 'say something.',
    part_number: 1,
    part_title_en: 'First words',
    dialogues_total: 3,
    dialogues_ready: n === 1 ? 3 : 0,
    dialogues_done: n === 1 ? 2 : 0,
    review_forms_total: n === 1 ? 5 : 0,
    review_forms_reviewed: 0,
    lessons_total: 4,
    lessons_done: n === 1 ? 2 : 0,
    live: n === 1,
    ...extra,
  }
}

function fakeDb(rows: unknown[] | Error, calls: string[] = []): RoadDb {
  return {
    road: () => {
      calls.push('road')
      return rows instanceof Error ? Promise.reject(rows) : Promise.resolve(rows)
    },
  }
}

async function account(): Promise<{ cookie: string; fetch: ApiDeps['fetch'] }> {
  const supabase = fakeSupabase()
  const res = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
  return { cookie: cookieHeader(res), fetch: supabase.fetch }
}

describe('GET /api/road', () => {
  it('[a1-road 29] with no sign in it answers 200 with the 14 columns and no progress, and asks the learner database nothing', async () => {
    const calls: string[] = []
    const supabase = fakeSupabase()
    const progress = [row(1, { dialogues_done: 3, review_forms_reviewed: 5, lessons_done: 4 }), row(2)]
    const res = await handleApi(get('/api/road'), ENV, {
      fetch: supabase.fetch,
      roadDb: () => fakeDb([row(1)], calls),
      roadVisitorDb: () => fakeDb(progress),
    })
    expect(res.status).toBe(200)
    const body = await res.json<{ stops: RoadStop[] }>()
    expect(body.stops.map((s) => s.stop_number)).toEqual([1, 2])
    for (const stop of body.stops) {
      expect(Object.keys(stop).sort()).toEqual(COLUMNS)
      expect([stop.dialogues_done, stop.review_forms_reviewed, stop.lessons_done]).toEqual([0, 0, 0])
    }
    expect(body.stops[0]).toMatchObject({ dialogues_ready: 3, review_forms_total: 5, live: true })
    expect(calls).toEqual([])
    expect(res.headers.get('set-cookie')).toBeNull()
    expect(res.headers.get('cache-control')).toMatch(/no-store|no-cache|private/)
    expect(supabase.requests).toEqual([])
  })

  it('[a1-road 29] reads public.road_for_visitors() with the publishable key and nothing else: no Auth call, no write, no cookie', async () => {
    const supabase = fakeSupabase()
    supabase.rest = () =>
      new Response(JSON.stringify([row(1, { dialogues_done: 2 })]), {
        status: 200,
        headers: { 'content-type': 'application/json' },
      })
    const res = await handleApi(get('/api/road'), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(200)
    const body = await res.json<{ stops: RoadStop[] }>()
    expect(body.stops[0]?.dialogues_done).toBe(0)
    expect(supabase.requests).toHaveLength(1)
    const call = supabase.requests[0]
    expect(call?.url.pathname).toBe('/rest/v1/rpc/road_for_visitors')
    expect(call?.headers.get('apikey')).toBe(PUBLISHABLE)
    expect(call?.headers.get('authorization')).toBe(`Bearer ${PUBLISHABLE}`)
    expect(supabase.requests.some((r) => r.url.pathname.startsWith('/auth/'))).toBe(false)
    expect(supabase.issued).toEqual([])
    expect(supabase.userIds).toEqual([])
    expect(res.headers.get('set-cookie')).toBeNull()
  })

  it('[a1-road 29] an invalid or an ended sign in is a visitor: 200, no progress, no cookie change, the learner database is not asked', async () => {
    const supabase = fakeSupabase()
    const created = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
    const cookie = cookieHeader(created)
    supabase.users.clear()
    for (const header of ['puhuscribe-auth=not-a-session', cookie]) {
      const calls: string[] = []
      const res = await handleApi(get('/api/road', header), ENV, {
        fetch: supabase.fetch,
        roadDb: () => fakeDb([row(1)], calls),
        roadVisitorDb: () => fakeDb([row(1, { dialogues_done: 1 })]),
      })
      expect(res.status).toBe(200)
      const body = await res.json<{ stops: RoadStop[] }>()
      expect(body.stops[0]?.dialogues_done).toBe(0)
      expect(res.headers.get('set-cookie')).toBeNull()
      expect(calls).toEqual([])
    }
  })

  it('[a1-road 29] a signed in learner still gets their own progress and never the visitor rows', async () => {
    const { cookie, fetch } = await account()
    const visitorCalls: string[] = []
    const res = await handleApi(get('/api/road', cookie), ENV, {
      fetch,
      roadDb: () => fakeDb([row(1)]),
      roadVisitorDb: () => fakeDb([row(1)], visitorCalls),
    })
    const body = await res.json<{ stops: RoadStop[] }>()
    expect(body.stops[0]).toMatchObject({ dialogues_done: 2, lessons_done: 2 })
    expect(visitorCalls).toEqual([])
  })

  it('[a1-road 29] a fault stays a 503 with no detail, for a visitor, for a learner and when sign in is down', async () => {
    const boom = new Error('connection to db.internal:5432 refused, password=hunter2')
    for (const failure of [new DatabaseUnavailable(), boom]) {
      const res = await handleApi(get('/api/road'), ENV, {
        fetch: fakeSupabase().fetch,
        roadVisitorDb: () => fakeDb(failure),
      })
      expect(res.status).toBe(503)
      const text = await res.text()
      expect(JSON.parse(text)).toEqual({ error: 'not_available' })
      expect(text).not.toMatch(/hunter2|5432|internal/)
    }
    const supabase = fakeSupabase()
    const created = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
    supabase.down = true
    const down = await handleApi(get('/api/road', cookieHeader(created)), ENV, {
      fetch: supabase.fetch,
      roadVisitorDb: () => fakeDb([row(1)]),
    })
    expect(down.status).toBe(503)
    expect(await down.json()).toEqual({ error: 'not_available' })
    const missing = await handleApi(get('/api/road'), {}, { fetch: fakeSupabase().fetch })
    expect(missing.status).toBe(503)
  })

  it('[a1-road 29] a row of the wrong shape is a fault for a visitor too, and progress is zeroed', () => {
    expect(() => visitorStop(row(1, { live: 'yes' }))).toThrow(DatabaseUnavailable)
    expect(
      visitorStop(row(1, { dialogues_done: 9, review_forms_reviewed: 9, lessons_done: 9 })),
    ).toMatchObject({
      dialogues_done: 0,
      review_forms_reviewed: 0,
      lessons_done: 0,
      dialogues_ready: 3,
    })
  })

  it('[a1-road 7] changes nothing: a POST is refused and asks no database', async () => {
    const { cookie, fetch } = await account()
    const calls: string[] = []
    const res = await handleApi(post('/api/road', { cookie }), ENV, {
      fetch,
      roadDb: () => fakeDb([row(1)], calls),
    })
    expect(res.status).toBe(405)
    expect(calls).toEqual([])
  })

  it('[a1-road 7] answers the stops of the function, in order, with the 14 columns', async () => {
    const { cookie, fetch } = await account()
    const rows = [row(1), row(2), row(3)]
    const res = await handleApi(get('/api/road', cookie), ENV, { fetch, roadDb: () => fakeDb(rows) })
    expect(res.status).toBe(200)
    const body = await res.json<{ stops: RoadStop[] }>()
    expect(Object.keys(body)).toEqual(['stops'])
    expect(body.stops.map((s) => s.stop_number)).toEqual([1, 2, 3])
    for (const stop of body.stops) expect(Object.keys(stop).sort()).toEqual(COLUMNS)
    expect(body.stops[0]).toMatchObject({
      dialogues_ready: 3,
      dialogues_done: 2,
      live: true,
      lessons_total: 4,
    })
    expect(res.headers.get('cache-control')).toMatch(/no-store|no-cache|private/)
  })

  it('[a1-road 7] answers nothing but the columns: no user id, no card number, no extra field', async () => {
    const { cookie, fetch } = await account()
    const leaky = row(1, { user_id: '11111111-1111-4111-8111-111111111111', card_number: 7, form_id: 99 })
    const res = await handleApi(get('/api/road', cookie), ENV, { fetch, roadDb: () => fakeDb([leaky]) })
    const text = await res.text()
    expect(res.status).toBe(200)
    expect(text).not.toContain('user_id')
    expect(text).not.toContain('11111111-1111')
    expect(text).not.toContain('card_number')
    expect(text).not.toContain('form_id')
    expect(Object.keys((JSON.parse(text) as { stops: RoadStop[] }).stops[0] ?? {}).sort()).toEqual(COLUMNS)
  })

  it('[a1-road 7] a fault answers 503 with no detail', async () => {
    const { cookie, fetch } = await account()
    for (const failure of [
      new DatabaseUnavailable(),
      new Error('connection to db.internal:5432 refused, password=hunter2'),
    ]) {
      const res = await handleApi(get('/api/road', cookie), ENV, { fetch, roadDb: () => fakeDb(failure) })
      expect(res.status).toBe(503)
      const text = await res.text()
      expect(JSON.parse(text)).toEqual({ error: 'not_available' })
      expect(text).not.toMatch(/hunter2|5432|internal/)
    }
  })

  it('[a1-road 7] a row of the wrong shape is a fault, not an answer', () => {
    for (const bad of [
      null,
      'text',
      row(1, { live: 'yes' }),
      row(1, { stop_number: -1 }),
      row(1, { title_en: 4 }),
    ]) {
      expect(() => roadStop(bad)).toThrow(DatabaseUnavailable)
    }
    const missing = Object.fromEntries(Object.entries(row(1)).filter(([key]) => key !== 'lessons_done'))
    expect(() => roadStop(missing)).toThrow(DatabaseUnavailable)
  })

  it('[a1-road 7] reads public.road() with the learner token and the publishable key, and writes nothing', async () => {
    const supabase = fakeSupabase()
    const created = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
    const cookie = cookieHeader(created)
    supabase.rest = () =>
      new Response(JSON.stringify([row(1)]), { status: 200, headers: { 'content-type': 'application/json' } })
    supabase.requests.length = 0
    const res = await handleApi(get('/api/road', cookie), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(200)
    const rest = supabase.requests.filter((r) => r.url.pathname.startsWith('/rest/v1/'))
    expect(rest).toHaveLength(1)
    const call = rest[0]
    expect(call?.url.pathname).toBe('/rest/v1/rpc/road')
    expect(call?.headers.get('apikey')).toBe(PUBLISHABLE)
    const bearer = call?.headers.get('authorization') ?? ''
    expect(bearer).toMatch(/^Bearer /)
    expect(supabase.issued).toContain(bearer.replace('Bearer ', ''))
    // A call to a function is the only database request, so nothing was inserted, updated or deleted.
    expect(rest.every((r) => r.url.pathname === '/rest/v1/rpc/road')).toBe(true)
  })
})
