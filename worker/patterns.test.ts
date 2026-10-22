import { describe, expect, it } from 'vitest'
import type { PatternsAnswer } from '../src/lib/patterns-types.ts'
import { handleApi, type ApiDeps } from './api.ts'
import type { FormRow, ReadableDialogue, SessionRow } from './learner-db.ts'
import { buildPatterns, type PatternLineRow, type PatternTokenRow, type PatternsDb } from './patterns.ts'
import {
  ENV,
  PUBLISHABLE,
  cookieHeader,
  fakeSupabase,
  get,
  post,
  sampleDialogue,
  type RecordedRequest,
} from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/12-units-1-3/spec.md that each test protects.
// GET /api/patterns, the "Patterns you've seen" panel, with a fake database
// that applies the same rules as the real one: a learner reads only approved
// content and only their own sessions and cards.

interface WorldForm extends FormRow {
  status: 'approved' | 'draft' | 'retired'
}
interface WorldSession extends SessionRow {
  user: string
}

interface World {
  dialogues: (ReadableDialogue & { approved: boolean })[]
  lines: PatternLineRow[]
  tokens: PatternTokenRow[]
  forms: WorldForm[]
  sessions: WorldSession[]
  cards: { user: string; formId: number }[]
}

const S1 = '00000000-0000-4000-8000-000000000001'
const S2 = '00000000-0000-4000-8000-000000000002'
const S3 = '00000000-0000-4000-8000-000000000003'
const OTHER = '00000000-0000-4000-8000-000000000009'

function form(
  id: number,
  lemma: string,
  formName: string,
  status: WorldForm['status'] = 'approved',
): WorldForm {
  return {
    id,
    lemma,
    formName,
    why: `Why of ${lemma}.`,
    surfacePuhe: `${lemma}-puhe`,
    surfaceKirja: `${lemma}-kirja`,
    status,
  }
}

function line(id: number, dialogueId: number, position: number): PatternLineRow {
  return {
    id,
    dialogueId,
    position,
    textPuhe: `Spoken line ${String(id)}`,
    textKirja: `Written line ${String(id)}`,
    audioPuheKey: `unit-test/${String(id)}-puhe.mp3`,
    audioKirjaKey: `unit-test/${String(id)}-kirja.mp3`,
  }
}

function session(
  id: string,
  user: string,
  dialogueId: number,
  step: SessionRow['step'],
  startedAt: string,
  ended = false,
): WorldSession {
  return { id, user, dialogueId, step, startedAt, endedAt: ended ? startedAt : null }
}

// Three units of one dialogue each (ids 1, 2, 3), plus dialogue 4 in unit 3
// that nobody has met and dialogue 5 that is not approved.
function world(): World {
  return {
    dialogues: [
      { ...sampleDialogue(1, 1, 1), approved: true },
      { ...sampleDialogue(2, 2, 1), approved: true },
      { ...sampleDialogue(3, 3, 1), approved: true },
      { ...sampleDialogue(4, 3, 2), approved: true },
      { ...sampleDialogue(5, 3, 3), approved: false },
    ],
    lines: [
      line(11, 1, 1),
      line(12, 1, 2),
      line(21, 2, 1),
      line(22, 2, 2),
      line(31, 3, 1),
      line(41, 4, 1),
      line(51, 5, 1),
    ],
    tokens: [
      { lineId: 11, formId: 101 }, // minä: I
      { lineId: 12, formId: 102 }, // olla: present
      { lineId: 12, formId: 101 },
      { lineId: 21, formId: 201 }, // kahvi: partitive
      { lineId: 22, formId: 202 }, // pulla: partitive
      { lineId: 21, formId: 102 },
      { lineId: 22, formId: 203 }, // draft form
      { lineId: 31, formId: 301 }, // hylly: adessive
      { lineId: 31, formId: 302 }, // retired form
      { lineId: 41, formId: 401 }, // only in the unmet dialogue 4
      { lineId: 51, formId: 501 }, // only in the draft dialogue 5
    ],
    forms: [
      form(101, 'minä', 'nominative singular'),
      form(102, 'olla', 'present tense, 1st person singular'),
      form(201, 'kahvi', 'partitive singular'),
      form(202, 'pulla', 'partitive singular'),
      form(203, 'leipä', 'partitive singular', 'draft'),
      form(301, 'hylly', 'adessive singular'),
      form(302, 'kassa', 'allative singular', 'retired'),
      form(401, 'tuo', 'adessive singular'),
      form(501, 'tämä', 'inessive singular'),
    ],
    sessions: [],
    cards: [],
  }
}

/** The database as one learner sees it through the access rules. */
function asLearner(w: World, user: string, calls: string[] = []): PatternsDb {
  const readable = () => w.dialogues.filter((d) => d.approved)
  return {
    readableDialogues: () => {
      calls.push('dialogues')
      return Promise.resolve(readable().map((d) => sampleDialogue(d.id, d.unitPosition, d.position)))
    },
    mySessions: () => {
      calls.push('sessions')
      return Promise.resolve(
        w.sessions
          .filter((s) => s.user === user)
          .map((s) => ({
            id: s.id,
            dialogueId: s.dialogueId,
            step: s.step,
            startedAt: s.startedAt,
            endedAt: s.endedAt,
          })),
      )
    },
    cardFormIds: () => {
      calls.push('cards')
      return Promise.resolve(w.cards.filter((c) => c.user === user).map((c) => c.formId))
    },
    lines: (ids) => {
      calls.push('lines')
      const ok = new Set(readable().map((d) => d.id))
      return Promise.resolve(w.lines.filter((l) => ids.includes(l.dialogueId) && ok.has(l.dialogueId)))
    },
    tokens: (ids) => {
      calls.push('tokens')
      return Promise.resolve(w.tokens.filter((t) => ids.includes(t.lineId)))
    },
    forms: (ids) => {
      calls.push('forms')
      return Promise.resolve(
        w.forms
          .filter((f) => ids.includes(f.id) && f.status === 'approved')
          .map((f) => ({
            id: f.id,
            lemma: f.lemma,
            formName: f.formName,
            why: f.why,
            surfacePuhe: f.surfacePuhe,
            surfaceKirja: f.surfaceKirja,
          })),
      )
    },
  }
}

async function guest(): Promise<{ cookie: string; deps: (db: PatternsDb) => ApiDeps }> {
  const supabase = fakeSupabase()
  const res = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
  return { cookie: cookieHeader(res), deps: (db) => ({ fetch: supabase.fetch, patternsDb: () => db }) }
}

async function ask(w: World, user: string, query = ''): Promise<{ status: number; body: PatternsAnswer }> {
  const { cookie, deps } = await guest()
  const res = await handleApi(get(`/api/patterns${query}`, cookie), ENV, deps(asLearner(w, user)))
  return { status: res.status, body: await res.json<PatternsAnswer>() }
}

function lemmas(answer: PatternsAnswer): string[] {
  return answer.groups.flatMap((g) => g.forms.map((f) => f.lemma))
}

// Learner A finished unit 1 and unit 2 (cards for their approved forms) and is
// now in unit 3's session at Hear it. Learner B finished only dialogue 4.
function twoLearners(): World {
  const w = world()
  w.sessions.push(
    session(S1, 'A', 1, 'understand', '2026-10-20T08:00:00Z', true),
    session(S2, 'A', 2, 'understand', '2026-10-21T08:00:00Z', true),
    session(S3, 'A', 3, 'hear', '2026-10-22T08:00:00Z'),
    session(OTHER, 'B', 4, 'understand', '2026-10-19T08:00:00Z', true),
  )
  w.cards.push(
    { user: 'A', formId: 101 },
    { user: 'A', formId: 102 },
    { user: 'A', formId: 201 },
    { user: 'A', formId: 202 },
    { user: 'B', formId: 401 },
  )
  return w
}

describe('GET /api/patterns', () => {
  it('[units 14] answers 401 without an account, and asks no database', async () => {
    const calls: string[] = []
    const supabase = fakeSupabase()
    const res = await handleApi(get('/api/patterns'), ENV, {
      fetch: supabase.fetch,
      patternsDb: () => asLearner(world(), 'A', calls),
    })
    expect(res.status).toBe(401)
    expect(calls).toEqual([])
  })

  it('[units 14] only GET: a POST changes nothing and is refused', async () => {
    const { cookie, deps } = await guest()
    const calls: string[] = []
    const res = await handleApi(post('/api/patterns', { cookie }), ENV, deps(asLearner(world(), 'A', calls)))
    expect(res.status).toBe(405)
    expect(calls).toEqual([])
  })

  it('[units 11] lists the forms the learner has a card for plus the current session forms', async () => {
    const { status, body } = await ask(twoLearners(), 'A', `?session=${S3}`)
    expect(status).toBe(200)
    expect(lemmas(body).sort()).toEqual(['hylly', 'kahvi', 'minä', 'olla', 'pulla'])
  })

  it('[units 11] never lists a draft or retired form, a form only in an unmet dialogue, or another learner form', async () => {
    const { body } = await ask(twoLearners(), 'A', `?session=${S3}`)
    const listed = lemmas(body)
    expect(listed).not.toContain('leipä') // draft
    expect(listed).not.toContain('kassa') // retired
    expect(listed).not.toContain('tuo') // only in dialogue 4, which learner A has not met (learner B's card)
    expect(listed).not.toContain('tämä') // only in a dialogue that is not approved
  })

  it('[units 11] without a session id, only the carded forms are listed', async () => {
    const { body } = await ask(twoLearners(), 'A')
    expect(lemmas(body).sort()).toEqual(['kahvi', 'minä', 'olla', 'pulla'])
  })

  it('[units 11] [units 14] a session id that is not the learner own is ignored, as is a value that is not an id', async () => {
    const none = await ask(twoLearners(), 'A')
    const other = await ask(twoLearners(), 'A', `?session=${OTHER}`)
    const junk = await ask(twoLearners(), 'A', '?session=../../etc')
    expect(other.body).toEqual(none.body)
    expect(junk.body).toEqual(none.body)
    // Learner B sees only their own card's form, never learner A's.
    const b = await ask(twoLearners(), 'B', `?session=${S3}`)
    expect(lemmas(b.body)).toEqual(['tuo'])
  })

  it('[units 11] the line is the earliest met one by unit, dialogue and line position, never from an unmet dialogue', async () => {
    const w = twoLearners()
    // Form 101 (minä) is also in dialogue 4, which learner A has not met.
    w.tokens.push({ lineId: 41, formId: 101 })
    const { body } = await ask(w, 'A', `?session=${S3}`)
    const forms = body.groups.flatMap((g) => g.forms)
    expect(forms.find((f) => f.lemma === 'minä')?.line.spoken).toBe('Spoken line 11')
    // olla is in line 12 (unit 1) and line 21 (unit 2): unit 1 comes first.
    expect(forms.find((f) => f.lemma === 'olla')?.line).toEqual({
      spoken: 'Spoken line 12',
      written: 'Written line 12',
      spokenAudio: '/audio/unit-test/12-puhe.mp3',
      writtenAudio: '/audio/unit-test/12-kirja.mp3',
    })
  })

  it('[units 11] a dialogue whose session never finished Understand it gives no line and no form', async () => {
    const w = world()
    w.sessions.push(session(S1, 'A', 1, 'hear', '2026-10-20T08:00:00Z'))
    const { body } = await ask(w, 'A')
    expect(body.groups).toEqual([])
  })

  it('[units 14] the answer holds no user id, no session id, no card numbers and no storage details', async () => {
    const { body } = await ask(twoLearners(), 'A', `?session=${S3}`)
    const text = JSON.stringify(body)
    for (const banned of [
      'user',
      'session',
      'due',
      'stability',
      'difficulty',
      'reps',
      'lapses',
      'Key',
      'status',
      S3,
      '"id"',
    ]) {
      expect(text).not.toContain(banned)
    }
    const form = body.groups[0]?.forms[0]
    expect(Object.keys(form ?? {}).sort()).toEqual(['lemma', 'line', 'spoken', 'why', 'written'])
    expect(Object.keys(form?.line ?? {}).sort()).toEqual(['spoken', 'spokenAudio', 'written', 'writtenAudio'])
  })

  it('[units 14] a database fault answers 503 and nothing else', async () => {
    const { cookie, deps } = await guest()
    const db = asLearner(twoLearners(), 'A')
    db.cardFormIds = () => Promise.reject(new Error('down'))
    const res = await handleApi(get('/api/patterns', cookie), ENV, deps(db))
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'not_available' })
  })
})

describe('the order of the panel', () => {
  it('[units 12] groups by form name, oldest first met, forms inside the same way, ties by base form', () => {
    const w = twoLearners()
    // pulla and kahvi are both first met in unit 2 (same session): tie by base form.
    const answer = buildPatterns({
      dialogues: w.dialogues,
      sessions: w.sessions.filter((s) => s.user === 'A'),
      currentSessionId: S3,
      cardFormIds: [202, 201, 102, 101],
      lines: w.lines.filter((l) => [1, 2, 3].includes(l.dialogueId)),
      tokens: w.tokens,
      forms: w.forms.filter((f) => f.status === 'approved'),
    })
    expect(answer.groups.map((g) => g.formName)).toEqual([
      'nominative singular',
      'present tense, 1st person singular',
      'partitive singular',
      'adessive singular',
    ])
    expect(answer.groups[2]?.forms.map((f) => f.lemma)).toEqual(['kahvi', 'pulla'])
  })

  it('[units 12] a group is placed by its oldest form, even when a newer form of it comes first in the list', () => {
    const dialogues = [sampleDialogue(1, 1, 1), sampleDialogue(2, 2, 1)]
    const sessions: SessionRow[] = [
      {
        id: S1,
        dialogueId: 1,
        step: 'understand',
        startedAt: '2026-10-20T08:00:00Z',
        endedAt: '2026-10-20T08:10:00Z',
      },
      {
        id: S2,
        dialogueId: 2,
        step: 'understand',
        startedAt: '2026-10-21T08:00:00Z',
        endedAt: '2026-10-21T08:10:00Z',
      },
    ]
    const forms = [
      form(3, 'b-word', 'translative singular'),
      form(1, 'c-word', 'essive singular'),
      form(2, 'a-word', 'translative singular'),
    ]
    const answer = buildPatterns({
      dialogues,
      sessions,
      currentSessionId: null,
      cardFormIds: [1, 2, 3],
      lines: [line(10, 1, 1), line(20, 2, 1)],
      tokens: [
        { lineId: 20, formId: 3 },
        { lineId: 20, formId: 1 },
        { lineId: 10, formId: 2 },
      ],
      forms,
    })
    expect(answer.groups.map((g) => g.formName)).toEqual(['translative singular', 'essive singular'])
    expect(answer.groups[0]?.forms.map((f) => f.lemma)).toEqual(['a-word', 'b-word'])
  })
})

describe('the real database module', () => {
  function rows(body: unknown): Response {
    return new Response(JSON.stringify(body), {
      status: 200,
      headers: { 'content-type': 'application/json' },
    })
  }
  function rest(request: RecordedRequest): Response | undefined {
    const table = request.url.pathname.replace('/rest/v1/', '')
    if (table === 'units') return rows([{ id: 7, position: 1, title_en: 'Unit', can_do_en: 'Can do.' }])
    if (table === 'dialogues') return rows([{ id: 5, unit_id: 7, position: 1, title_en: 'Dialogue' }])
    if (table === 'sessions') {
      return rows([
        {
          id: S1,
          dialogue_id: 5,
          step_reached: 'hear',
          started_at: '2026-10-21T12:00:00Z',
          ended_at: null,
        },
      ])
    }
    if (table === 'cards') return rows([])
    if (table === 'dialogue_lines') {
      return rows([
        {
          id: 9,
          dialogue_id: 5,
          position: 1,
          text_puhe: 'Kiva tavata!',
          text_kirja: 'Hauska tavata!',
          audio_puhe_key: 'k/1-puhe.mp3',
          audio_kirja_key: 'k/1-kirja.mp3',
        },
      ])
    }
    if (table === 'tokens') return rows([{ line_id: 9, form_id: 1 }])
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
      ])
    }
    return undefined
  }

  it('[units 14] reads only, with the learner token and the publishable key, and never asks for card numbers', async () => {
    const supabase = fakeSupabase()
    supabase.rest = rest
    const signIn = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
    const accessToken = supabase.issued[0] ?? ''
    const res = await handleApi(get(`/api/patterns?session=${S1}`, cookieHeader(signIn)), ENV, {
      fetch: supabase.fetch,
    })
    expect(res.status).toBe(200)
    const body = await res.json<PatternsAnswer>()
    expect(body.groups.map((g) => g.forms.map((f) => f.lemma))).toEqual([['kiva']])
    const calls = supabase.requests.filter((r) => r.url.pathname.startsWith('/rest/v1/'))
    expect(calls.map((r) => `${r.method} ${r.url.pathname}`).sort()).toEqual([
      'GET /rest/v1/cards',
      'GET /rest/v1/dialogue_lines',
      'GET /rest/v1/dialogues',
      'GET /rest/v1/forms',
      'GET /rest/v1/sessions',
      'GET /rest/v1/tokens',
      'GET /rest/v1/units',
    ])
    for (const call of calls) {
      expect(call.headers.get('authorization')).toBe(`Bearer ${accessToken}`)
      expect(call.headers.get('apikey')).toBe(PUBLISHABLE)
    }
    const cards = calls.find((r) => r.url.pathname === '/rest/v1/cards')
    expect(cards?.url.searchParams.get('select')).toBe('form_id')
    // Forms and lines are asked for approved rows only, on top of the database rules.
    expect(calls.find((r) => r.url.pathname === '/rest/v1/forms')?.url.searchParams.get('status')).toBe(
      'eq.approved',
    )
    expect(
      calls.find((r) => r.url.pathname === '/rest/v1/dialogue_lines')?.url.searchParams.get('status'),
    ).toBe('eq.approved')
  })
})
