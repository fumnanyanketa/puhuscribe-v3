import { describe, expect, it } from 'vitest'
import { handleApi } from './api.ts'
import { ENV, PUBLISHABLE, cookieHeader, fakeSupabase, post, type RecordedRequest } from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects.
// The real database module (worker/learner-db.ts) against a fake Supabase:
// every read and write goes out with the learner's own token, so the
// database's approval rules decide what comes back.

function rows(body: unknown): Response {
  return new Response(JSON.stringify(body), { status: 200, headers: { 'content-type': 'application/json' } })
}

// What PostgREST would return to this learner: the approval rules already
// applied, so the draft form 99 is missing from forms.
function restAnswers(request: RecordedRequest): Response | undefined {
  const table = request.url.pathname.replace('/rest/v1/', '')
  if (table === 'units') return rows([{ id: 7, position: 1, title_en: 'Unit', can_do_en: 'Can do.' }])
  if (table === 'dialogues') return rows([{ id: 5, unit_id: 7, position: 1, title_en: 'Dialogue' }])
  if (table === 'sessions' && request.method === 'GET') return rows([])
  if (table === 'sessions' && request.method === 'POST') {
    return rows({
      id: '00000000-0000-4000-8000-000000000001',
      dialogue_id: 5,
      step_reached: null,
      started_at: '2026-10-21T12:00:00Z',
      ended_at: null,
    })
  }
  if (table === 'dialogue_lines') {
    return rows([
      {
        id: 9,
        position: 1,
        speaker: 'A',
        text_puhe: 'Kiva tavata!',
        text_kirja: 'Hauska tavata!',
        gloss_en: 'Nice to meet you!',
        audio_puhe_key: 'k/1-puhe.mp3',
        audio_kirja_key: 'k/1-kirja.mp3',
      },
    ])
  }
  if (table === 'tokens') {
    return rows([
      { line_id: 9, register: 'puhe', position: 1, surface: 'Kiva', form_id: 1 },
      { line_id: 9, register: 'puhe', position: 2, surface: 'tavata', form_id: 99 },
      { line_id: 9, register: 'kirja', position: 1, surface: 'Hauska', form_id: 2 },
      { line_id: 9, register: 'kirja', position: 2, surface: 'tavata', form_id: 99 },
    ])
  }
  if (table === 'forms') {
    return rows([
      {
        id: 1,
        lemma: 'kiva',
        surface_kirja: 'kiva',
        surface_puhe: 'kiva',
        form_name_en: 'Nice',
        why_en: 'Why.',
      },
      {
        id: 2,
        lemma: 'hauska',
        surface_kirja: 'hauska',
        surface_puhe: 'hauska',
        form_name_en: 'Nice',
        why_en: 'Why.',
      },
    ])
  }
  if (table === 'rpc/complete_session') return new Response(null, { status: 204 })
  return undefined
}

async function signedInLearner() {
  const supabase = fakeSupabase()
  supabase.rest = restAnswers
  const res = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
  const accessToken = supabase.issued[0] ?? ''
  return { supabase, cookie: cookieHeader(res), accessToken }
}

describe('reading content as the learner', () => {
  it('[session 7] every database request carries the learner token and the publishable key, nothing stronger', async () => {
    const { supabase, cookie, accessToken } = await signedInLearner()
    const res = await handleApi(post('/api/sessions/today', { cookie }), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(200)
    const rest = supabase.requests.filter((r) => r.url.pathname.startsWith('/rest/v1/'))
    // The first reads run side by side, so the list is compared in sorted order. Fast route
    // hear-and-say added the learner's cards (they pick the recap's key lines), and fast route
    // islands reads the readable dialogues (units and dialogues) a second time to find the stop's
    // island step.
    expect(rest.map((r) => `${r.method} ${r.url.pathname}`).sort()).toEqual([
      'GET /rest/v1/cards',
      'GET /rest/v1/dialogue_lines',
      'GET /rest/v1/dialogues',
      'GET /rest/v1/dialogues',
      'GET /rest/v1/forms',
      'GET /rest/v1/sessions',
      'GET /rest/v1/tokens',
      'GET /rest/v1/units',
      'GET /rest/v1/units',
      'POST /rest/v1/sessions',
    ])
    for (const request of rest) {
      expect(request.headers.get('authorization')).toBe(`Bearer ${accessToken}`)
      expect(request.headers.get('apikey')).toBe(PUBLISHABLE)
    }
  })

  it('[session 6] [session 7] the new session row is sent with only its dialogue, never a user id', async () => {
    const { supabase, cookie } = await signedInLearner()
    await handleApi(post('/api/sessions/today', { cookie }), ENV, { fetch: supabase.fetch })
    const insert = supabase.requests.find(
      (r) => r.method === 'POST' && r.url.pathname === '/rest/v1/sessions',
    )
    expect(JSON.parse(insert?.body ?? 'null')).toEqual({ dialogue_id: 5 })
  })

  it('[session 7] [session 12] a form the database does not return is not in the answer, and its word is plain text', async () => {
    const { supabase, cookie } = await signedInLearner()
    const res = await handleApi(post('/api/sessions/today', { cookie }), ENV, { fetch: supabase.fetch })
    const body = await res.json<{ lines: { spoken: { text: string; form?: unknown }[] }[] }>()
    expect(body.lines[0]?.spoken[1]).toEqual({ text: 'tavata', after: '!' })
    expect(body.lines[0]?.spoken[0]?.form).toBeDefined()
  })

  it('[session 15] the finish calls public.complete_session once with the session id, as the learner', async () => {
    const { supabase, cookie, accessToken } = await signedInLearner()
    const id = '00000000-0000-4000-8000-000000000001'
    const res = await handleApi(post(`/api/sessions/${id}/complete`, { cookie }), ENV, {
      fetch: supabase.fetch,
    })
    expect(res.status).toBe(200)
    const calls = supabase.requests.filter((r) => r.url.pathname === '/rest/v1/rpc/complete_session')
    expect(calls).toHaveLength(1)
    expect(JSON.parse(calls[0]?.body ?? 'null')).toEqual({ session_id: id })
    expect(calls[0]?.headers.get('authorization')).toBe(`Bearer ${accessToken}`)
  })
})

// Labels [word-meanings N] are this quick-lane fix (3 November 2026): the word
// card's two English meanings, which job 20-a1-road stored on every road form
// (forms.meaning_en and forms.lemma_meaning_en), reach the session answer.
// 1: a form with both meanings sends both. 2: a form with none sends neither.
//
// This fake answers like PostgREST: it returns only the columns the Worker
// asked for, so a query that leaves the meanings out gets none back.
const FORM_RECORDS: Record<string, unknown>[] = [
  {
    id: 1,
    lemma: 'kiva',
    surface_kirja: 'kiva',
    surface_puhe: 'kiva',
    form_name_en: 'Nice',
    why_en: 'Why.',
    meaning_en: 'nice',
    lemma_meaning_en: 'nice, pleasant',
  },
  {
    // An older form (job 12) with no meanings.
    id: 2,
    lemma: 'hauska',
    surface_kirja: 'hauska',
    surface_puhe: 'hauska',
    form_name_en: 'Nice',
    why_en: 'Why.',
    meaning_en: null,
    lemma_meaning_en: null,
  },
]

function selectedColumns(request: RecordedRequest, records: Record<string, unknown>[]): Response {
  const wanted = (request.url.searchParams.get('select') ?? '').split(',').map((name) => name.trim())
  return rows(records.map((record) => Object.fromEntries(wanted.map((name) => [name, record[name]]))))
}

async function learnerWithMeanings() {
  const supabase = fakeSupabase()
  supabase.rest = (request) =>
    request.url.pathname === '/rest/v1/forms' ? selectedColumns(request, FORM_RECORDS) : restAnswers(request)
  const res = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
  return { supabase, cookie: cookieHeader(res) }
}

interface MeaningAnswer {
  lines: {
    spoken: { text: string; form?: Record<string, unknown> }[]
    written: { form?: Record<string, unknown> }[]
  }[]
}

describe('word meanings on the word card', () => {
  it('[word-meanings 1] a road form sends what it means in the line and what its dictionary form means', async () => {
    const { supabase, cookie } = await learnerWithMeanings()
    const res = await handleApi(post('/api/sessions/today', { cookie }), ENV, { fetch: supabase.fetch })
    expect(res.status).toBe(200)
    const body = await res.json<MeaningAnswer>()
    expect(body.lines[0]?.spoken[0]?.form).toEqual({
      lemma: 'kiva',
      formName: 'Nice',
      why: 'Why.',
      spoken: 'kiva',
      written: 'kiva',
      meaning: 'nice',
      baseMeaning: 'nice, pleasant',
    })
    const forms = supabase.requests.find((r) => r.url.pathname === '/rest/v1/forms')
    const columns = (forms?.url.searchParams.get('select') ?? '').split(',').map((name) => name.trim())
    expect(columns).toEqual(expect.arrayContaining(['meaning_en', 'lemma_meaning_en']))
  })

  it('[word-meanings 2] a form with no meanings sends neither field, so the card shows no empty line', async () => {
    const { supabase, cookie } = await learnerWithMeanings()
    const res = await handleApi(post('/api/sessions/today', { cookie }), ENV, { fetch: supabase.fetch })
    const body = await res.json<MeaningAnswer>()
    const form = body.lines[0]?.written[0]?.form
    expect(form?.lemma).toBe('hauska')
    expect(form).not.toHaveProperty('meaning')
    expect(form).not.toHaveProperty('baseMeaning')
  })
})
