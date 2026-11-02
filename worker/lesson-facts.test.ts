import { describe, expect, it } from 'vitest'
import type { CompleteAnswer, ReadySession } from '../src/lib/session-types.ts'
import { handleApi, type ApiDeps } from './api.ts'
import { MAX_NEW_WORDS, newWordsOf } from './session-plan.ts'
import {
  ENV,
  cookieHeader,
  fakeDb,
  fakeSupabase,
  post,
  sampleContent,
  sampleDialogue,
  type FakeDb,
} from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md. Two small reads of the learner's own rows:
// whether today's session is the first lesson (the tip, statement 25) and which
// cards a lesson added (the chips on the finish screen, statement 33).

async function start(
  dialogues = [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2)],
): Promise<{ db: FakeDb; cookie: string; deps: ApiDeps }> {
  const content = new Map([
    [1, sampleContent()],
    [2, sampleContent()],
  ])
  const db = fakeDb(dialogues, content)
  const supabase = fakeSupabase()
  const deps: ApiDeps = { fetch: supabase.fetch, learnerDb: () => db }
  const guest = await handleApi(post('/api/guest'), ENV, deps)
  return { db, cookie: cookieHeader(guest), deps }
}

async function today(cookie: string, deps: ApiDeps) {
  const res = await handleApi(post('/api/sessions/today', { cookie }), ENV, deps)
  return res.json<ReadySession>()
}

async function step(id: string, name: string, cookie: string, deps: ApiDeps) {
  await handleApi(
    post(`/api/sessions/${id}/step`, { cookie, body: JSON.stringify({ step: name }) }),
    ENV,
    deps,
  )
}

describe('the first lesson field', () => {
  it('[redesign 25] is true on the learner’s first lesson, also when the page is loaded again at Hear it', async () => {
    const { cookie, deps } = await start()
    const first = await today(cookie, deps)
    expect(first.firstLesson).toBe(true)
    const again = await today(cookie, deps)
    expect(again.session.id).toBe(first.session.id)
    expect(again.firstLesson).toBe(true)
  })

  it('[redesign 25] is gone once Hear it is finished', async () => {
    const { cookie, deps } = await start()
    const first = await today(cookie, deps)
    await step(first.session.id, 'hear', cookie, deps)
    const back = await today(cookie, deps)
    expect(back.session.id).toBe(first.session.id)
    expect(back.firstLesson).toBeUndefined()
  })

  it('[redesign 25] is absent on the second session', async () => {
    const { db, cookie, deps } = await start()
    const first = await today(cookie, deps)
    await step(first.session.id, 'hear', cookie, deps)
    await step(first.session.id, 'understand', cookie, deps)
    await handleApi(post(`/api/sessions/${first.session.id}/complete`, { cookie }), ENV, deps)
    expect(db.sessions).toHaveLength(1)
    const second = await today(cookie, deps)
    expect(second.session.id).not.toBe(first.session.id)
    expect(second.firstLesson).toBeUndefined()
  })

  it('[redesign 25] [personal data] reads only the caller’s own session rows: another learner’s sessions never make it false', async () => {
    const mine = fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, sampleContent()]]))
    const theirs = fakeDb([sampleDialogue(1, 10, 1)], new Map([[1, sampleContent()]]))
    await theirs.startSession(1)
    await theirs.startSession(1)
    const supabase = fakeSupabase()
    // Each learner's token reaches their own rows, as the database's access rules do.
    const deps: ApiDeps = { fetch: supabase.fetch, learnerDb: () => mine }
    const guest = await handleApi(post('/api/guest'), ENV, deps)
    const res = await today(cookieHeader(guest), deps)
    expect(res.firstLesson).toBe(true)
    expect(mine.sessions).toHaveLength(1)
    expect(theirs.sessions).toHaveLength(2)
  })
})

describe('the new words of a finished lesson', () => {
  async function finished(setup: (db: FakeDb) => void) {
    const { db, cookie, deps } = await start()
    const session = await today(cookie, deps)
    await step(session.session.id, 'hear', cookie, deps)
    await step(session.session.id, 'understand', cookie, deps)
    setup(db)
    const res = await handleApi(post(`/api/sessions/${session.session.id}/complete`, { cookie }), ENV, deps)
    return { db, res, answer: await res.json<CompleteAnswer>() }
  }

  it('[redesign 33] names the forms the lesson added, each once, with the audio of its first line', async () => {
    const { db, answer } = await finished((fake) => {
      fake.newCards = [3, 2, 5]
    })
    expect(answer.saved).toBe(true)
    expect(answer.newWords?.map((word) => word.form.spoken)).toEqual(['mä', 'oon', 'kiva'])
    expect(answer.newWords?.[0]).toEqual({
      form: { lemma: 'minä', formName: 'I', why: 'Why two.', spoken: 'mä', written: 'minä' },
      spokenAudio: '/audio/unit-test/1-puhe.mp3',
      writtenAudio: '/audio/unit-test/1-kirja.mp3',
    })
    expect(answer.newWords?.[2]?.spokenAudio).toBe('/audio/unit-test/2-puhe.mp3')
    expect(db.newCardsAsked).toHaveLength(1)
    expect(db.newCardsAsked[0]).toBe(db.sessions[0]?.endedAt)
  })

  it('[redesign 33] says nothing about new words when the lesson added none', async () => {
    const { answer } = await finished(() => undefined)
    expect(answer).toEqual({ saved: true })
  })

  it('[redesign 33] a failing read of the new words can never break saving', async () => {
    const { res, answer, db } = await finished((fake) => {
      fake.newCardsFail = true
    })
    expect(res.status).toBe(200)
    expect(answer).toEqual({ saved: true })
    expect(db.completed).toHaveLength(1)
  })

  it('[redesign 33] keeps the note and the words side by side', async () => {
    const { answer } = await finished((fake) => {
      fake.note = 'first'
      fake.newCards = [1]
    })
    expect(answer.saveNote).toBe('first')
    expect(answer.newWords).toHaveLength(1)
  })

  it('[redesign 33] a form the database does not return is left out, and the list is capped', () => {
    const content = sampleContent()
    expect(newWordsOf(content, [99, 1]).map((word) => word.form.lemma)).toEqual(['moi'])
    const many = {
      ...content,
      forms: Array.from({ length: 40 }, (_, i) => ({
        id: 1000 + i,
        lemma: `l${String(i)}`,
        formName: 'x',
        why: 'y',
        surfacePuhe: `p${String(i)}`,
        surfaceKirja: `k${String(i)}`,
      })),
      tokens: Array.from({ length: 40 }, (_, i) => ({
        lineId: 11,
        register: 'puhe' as const,
        position: i + 1,
        surface: `p${String(i)}`,
        formId: 1000 + i,
      })),
    }
    const ids = many.forms.map((form) => form.id)
    expect(newWordsOf(many, ids)).toHaveLength(MAX_NEW_WORDS)
  })
})
