import { describe, expect, it } from 'vitest'
import { handleApi } from './api.ts'
import { learnerContext, supabaseSettings } from './learner-auth.ts'
import { supabaseLearnerDb } from './learner-db.ts'
import { chunks, PAGE_SIZE, readAll } from './paging.ts'
import { patternsFor, supabasePatternsDb } from './patterns.ts'
import { ENV, cookieHeader, fakeSupabase, get, post, type RecordedRequest } from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/20-a1-road/spec.md that each test protects: [a1-road N].
// The database API answers at most max_rows rows (1,000 in supabase/config.toml) and says nothing when it
// cuts an answer short. A learner who met all 108 dialogues has about 14,000 words in their lines and
// 1,300 cards. This fake PostgREST applies the same cap and records every answer it had to cut, so a read
// that is not paged shows up as a cut answer.

const MAX_ROWS = 1000
const DIALOGUES = 108
const LINES_PER_DIALOGUE = 8
const FORMS = 1300

type Row = Record<string, unknown>

interface Table {
  rows: Row[]
}

function postgrest(tables: Record<string, Table>, cut: { count: number }) {
  return (request: RecordedRequest): Response | undefined => {
    const name = request.url.pathname.replace('/rest/v1/', '')
    const table = tables[name]
    if (!table || request.method !== 'GET') return undefined
    let rows = table.rows
    const params = request.url.searchParams
    for (const [key, value] of params.entries()) {
      if (['select', 'order', 'limit', 'offset'].includes(key)) continue
      if (value.startsWith('in.(')) {
        const wanted = new Set(value.slice(4, -1).split(','))
        rows = rows.filter((row) => wanted.has(String(row[key])))
      } else if (value.startsWith('eq.')) {
        rows = rows.filter((row) => String(row[key]) === value.slice(3))
      } else if (value === 'not.is.null') {
        rows = rows.filter((row) => row[key] !== null)
      }
    }
    const order = params.get('order')
    if (order) {
      const column = order.split(',')[0]?.replace(/\.(asc|desc)$/, '') ?? ''
      rows = [...rows].sort((a, b) => {
        const x = a[column]
        const y = b[column]
        return x === y ? 0 : String(x) < String(y) ? -1 : 1
      })
    }
    const offset = Number(params.get('offset') ?? 0)
    const limit = Number(params.get('limit') ?? MAX_ROWS)
    const wanted = rows.slice(offset, offset + limit)
    const answer = wanted.slice(0, MAX_ROWS)
    // The API says nothing when it holds back rows.
    if (answer.length < wanted.length) cut.count += 1
    return new Response(JSON.stringify(answer), {
      status: 200,
      headers: { 'content-type': 'application/json' },
    })
  }
}

interface World {
  tables: Record<string, Table>
  linesOfForm: Map<number, Set<number>>
  tokensOfLine: Map<number, number>
}

function world(): World {
  const units: Row[] = []
  for (let u = 1; u <= DIALOGUES / 3; u++) {
    units.push({ id: u, position: u, title_en: `Stop ${String(u)}`, can_do_en: 'say something.' })
  }
  const dialogues: Row[] = []
  const sessions: Row[] = []
  const lines: Row[] = []
  const tokens: Row[] = []
  const linesOfForm = new Map<number, Set<number>>()
  const tokensOfLine = new Map<number, number>()
  let tokenId = 0
  for (let d = 1; d <= DIALOGUES; d++) {
    dialogues.push({
      id: d,
      unit_id: Math.ceil(d / 3),
      position: ((d - 1) % 3) + 1,
      title_en: `Dialogue ${String(d)}`,
    })
    sessions.push({
      id: `00000000-0000-4000-8000-${String(d).padStart(12, '0')}`,
      dialogue_id: d,
      step_reached: 'understand',
      started_at: `2026-10-${String(1 + (d % 28)).padStart(2, '0')}T08:00:00Z`,
      ended_at: `2026-10-${String(1 + (d % 28)).padStart(2, '0')}T08:10:00Z`,
    })
    for (let n = 1; n <= LINES_PER_DIALOGUE; n++) {
      const id = (d - 1) * LINES_PER_DIALOGUE + n
      lines.push({
        id,
        dialogue_id: d,
        position: n,
        speaker: 'Maria',
        status: 'approved',
        text_puhe: `Puhe ${String(id)}`,
        text_kirja: `Kirja ${String(id)}`,
        gloss_en: 'gloss',
        audio_puhe_key: `k${String(id)}/puhe.mp3`,
        audio_kirja_key: `k${String(id)}/kirja.mp3`,
      })
      for (let w = 1; w <= LINES_PER_DIALOGUE; w++) {
        // The first word of every line is one of 15 common forms (like olen or on), so the review
        // lesson's forms are in every line. The others cycle through the rest of the 1,300 forms.
        const formId = w === 1 ? (id % 15) + 1 : 16 + ((id * LINES_PER_DIALOGUE + w) % (FORMS - 15))
        for (const register of ['puhe', 'kirja']) {
          tokenId += 1
          tokens.push({
            id: tokenId,
            line_id: id,
            register,
            position: w,
            surface: `w${String(w)}`,
            form_id: formId,
          })
          tokensOfLine.set(id, (tokensOfLine.get(id) ?? 0) + 1)
        }
        const set = linesOfForm.get(formId) ?? new Set<number>()
        set.add(id)
        linesOfForm.set(formId, set)
      }
    }
  }
  const forms: Row[] = []
  const cards: Row[] = []
  for (let f = 1; f <= FORMS; f++) {
    forms.push({
      id: f,
      lemma: `l${String(f)}`,
      surface_kirja: `k${String(f)}`,
      surface_puhe: `p${String(f)}`,
      form_name_en: 'noun',
      why_en: 'why',
      status: 'approved',
    })
    cards.push({ form_id: f })
  }
  return {
    tables: {
      units: { rows: units },
      dialogues: { rows: dialogues },
      sessions: { rows: sessions },
      dialogue_lines: { rows: lines },
      tokens: { rows: tokens },
      forms: { rows: forms },
      cards: { rows: cards },
    },
    linesOfForm,
    tokensOfLine,
  }
}

async function learnerClient(w: World, cut: { count: number }) {
  const supabase = fakeSupabase()
  const created = await handleApi(post('/api/guest'), ENV, { fetch: supabase.fetch })
  const cookie = cookieHeader(created)
  supabase.rest = postgrest(w.tables, cut)
  const settings = supabaseSettings(ENV)
  if (!settings) throw new Error('the test environment has no Supabase settings')
  return learnerContext(get('/api/patterns', cookie), settings, supabase.fetch).client
}

describe('reads that could pass the 1,000 row cap', () => {
  it('[a1-road 23] the paging helper reads every page and cuts long lists into chunks', async () => {
    const all = Array.from({ length: PAGE_SIZE * 2 + 17 }, (_, i) => ({ i }))
    const asked: number[] = []
    const rows = await readAll(
      (from, to) => {
        asked.push(from)
        return Promise.resolve({ data: all.slice(from, to + 1), error: null })
      },
      () => new Error('failed'),
    )
    expect(rows).toHaveLength(PAGE_SIZE * 2 + 17)
    expect(asked).toEqual([0, PAGE_SIZE, PAGE_SIZE * 2])
    expect(chunks([1, 2, 3, 4, 5], 2)).toEqual([[1, 2], [3, 4], [5]])
    await expect(
      readAll(
        () => Promise.resolve({ data: null, error: { message: 'x' } }),
        () => new Error('failed'),
      ),
    ).rejects.toThrow('failed')
  })

  it('[a1-road 23] the patterns panel of a learner who met all 108 dialogues lists all 1,300 cards, and no read was cut', async () => {
    const w = world()
    const cut = { count: 0 }
    const client = await learnerClient(w, cut)
    const answer = await patternsFor(supabasePatternsDb(client), null)
    const listed = answer.groups.flatMap((group) => group.forms)
    expect(listed).toHaveLength(FORMS)
    expect(cut.count).toBe(0)
  })

  it('[a1-road 23] the review lesson material holds every line and every word of the lines that have the forms', async () => {
    const w = world()
    const cut = { count: 0 }
    const client = await learnerClient(w, cut)
    const db = supabaseLearnerDb(client)
    const formIds = Array.from({ length: 15 }, (_, i) => i + 1)
    const dialogueIds = Array.from({ length: DIALOGUES }, (_, i) => i + 1)
    const material = await db.reviewMaterial(formIds, dialogueIds)
    const expectedLines = new Set<number>()
    for (const id of formIds) for (const line of w.linesOfForm.get(id) ?? []) expectedLines.add(line)
    expect(expectedLines.size).toBeGreaterThan(0)
    expect(material.lines.map((l) => l.id).sort((a, b) => a - b)).toEqual(
      [...expectedLines].sort((a, b) => a - b),
    )
    let expectedTokens = 0
    for (const line of expectedLines) expectedTokens += w.tokensOfLine.get(line) ?? 0
    expect(material.tokens).toHaveLength(expectedTokens)
    expect(material.tokens.length).toBeGreaterThan(MAX_ROWS)
    expect(cut.count).toBe(0)
  })

  it('[a1-road 23] the sessions, dialogues and units a learner reads come back whole', async () => {
    const w = world()
    const cut = { count: 0 }
    const client = await learnerClient(w, cut)
    const db = supabaseLearnerDb(client)
    expect(await db.mySessions()).toHaveLength(DIALOGUES)
    expect(await db.readableDialogues()).toHaveLength(DIALOGUES)
    expect(cut.count).toBe(0)
  })
})
