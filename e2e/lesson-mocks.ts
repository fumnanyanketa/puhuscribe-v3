import type { Page, Route } from '@playwright/test'
import { tone } from './session-helpers.ts'

// Answers for a lesson's reads and writes, so the redesigned lesson screens can
// be tested in every state without a database. The lines are made up for the
// test (names and English only where it can be, and one short Finnish dialogue
// that exists only in these tests and in no app build).

interface Word {
  text: string
  before?: string
  after?: string
  form?: Record<string, unknown>
}

const form = (extra: Record<string, unknown> = {}) => ({
  lemma: 'tuo',
  formName: 'Plural',
  why: 'Spoken Finnish says noi where books write nuo.',
  spoken: 'noi',
  written: 'nuo',
  ...extra,
})

const word = (text: string, f?: Record<string, unknown>, after?: string): Word => ({
  text,
  ...(f ? { form: f } : {}),
  ...(after ? { after } : {}),
})

export const MOCK_LINES = [
  {
    id: 1,
    speaker: 'Pekka',
    gloss: 'How much are those strawberries?',
    spokenAudio: '/audio/a.wav',
    writtenAudio: '/audio/b.wav',
    spoken: [
      word('Paljonks'),
      word('noi', form({ meaning: 'those', baseMeaning: 'that' })),
      word('mansikat'),
      word('maksaa', undefined, '?'),
    ],
    written: [
      word('Paljonko'),
      word('nuo', form({ meaning: 'those', baseMeaning: 'that' })),
      word('mansikat'),
      word('maksavat', undefined, '?'),
    ],
  },
  {
    id: 2,
    speaker: 'Maria',
    gloss: 'Can I pay by card?',
    spokenAudio: '/audio/a.wav',
    writtenAudio: '/audio/b.wav',
    spoken: [
      word('Voinks'),
      word('mä', form({ spoken: 'mä', written: 'minä', lemma: 'minä', formName: 'I' })),
      word('maksaa'),
      word('kortilla', undefined, '?'),
    ],
    written: [
      word('Voinko'),
      word('minä', form({ spoken: 'mä', written: 'minä', lemma: 'minä', formName: 'I' })),
      word('maksaa'),
      word('kortilla', undefined, '?'),
    ],
  },
  {
    id: 3,
    speaker: 'Pekka',
    gloss: 'Yes, of course.',
    spokenAudio: '/audio/a.wav',
    writtenAudio: '/audio/b.wav',
    spoken: [word('Joo', undefined, ','), word('totta'), word('kai', undefined, '.')],
    written: [word('Kyllä', undefined, ','), word('totta'), word('kai', undefined, '.')],
  },
]

export interface LessonMocks {
  /** The step the session has reached. */
  step?: 'hear' | 'understand' | 'say' | null
  /** Adds firstLesson: true, which shows the tip. */
  firstLesson?: boolean
  /** The voice answer. Default: speaking feedback on. */
  processing?: 'granted' | 'not_asked' | 'withdrawn'
  /** Words for the finish screen. */
  newWords?: number
  /** The save note word of the complete answer. */
  saveNote?: 'first' | 'reminder'
  /** One review item for Keep it, answered by the typed text: "maksaa" is right, "maksa" is close. */
  review?: boolean
  /** A guest or an email account, for the finish status line. */
  me?: { kind: 'guest' } | { kind: 'email'; email: string }
}

export interface LessonCalls {
  steps: string[]
  consent: Record<string, unknown>[]
  audio: string[]
  complete: number
}

const json = (route: Route, body: unknown, status = 200) =>
  route.fulfill({ status, contentType: 'application/json', body: JSON.stringify(body) })

export async function mockLesson(page: Page, mocks: LessonMocks = {}): Promise<LessonCalls> {
  const calls: LessonCalls = { steps: [], consent: [], audio: [], complete: 0 }
  const sound = tone(0.3)
  await page.route('**/api/sessions/today', (route) =>
    json(route, {
      state: 'ready',
      session: { id: 's1', step: mocks.step ?? null },
      unit: { title: 'Unit', canDo: 'Can do.' },
      dialogue: { title: 'Dialogue' },
      lines: MOCK_LINES,
      ...(mocks.firstLesson ? { firstLesson: true } : {}),
    }),
  )
  await page.route('**/api/sessions/s1/review', (route) =>
    json(route, {
      items: mocks.review
        ? [
            {
              formId: 1,
              speaker: 'Maria',
              gloss: 'Can I pay by card?',
              register: 'spoken',
              audio: '/audio/a.wav',
              words: [{ text: 'Voinks' }, { text: 'mä' }, { gap: true }, { text: 'kortilla', after: '?' }],
            },
          ]
        : [],
    }),
  )
  await page.route('**/api/review/answer', (route) => {
    const sent = route.request().postDataJSON() as { text?: string }
    const result = sent.text === 'maksaa' ? 'correct' : sent.text === 'maksa' ? 'close' : 'wrong'
    return json(route, {
      result,
      line: MOCK_LINES[1],
      marked: { spoken: [2], written: [2] },
      form: { spoken: 'maksaa', written: 'maksaa' },
    })
  })
  await page.route('**/api/sessions/s1/step', async (route) => {
    const body = route.request().postDataJSON() as { step: string }
    calls.steps.push(body.step)
    await json(route, { step: body.step })
  })
  await page.route('**/api/sessions/s1/complete', (route) => {
    calls.complete += 1
    const words = Array.from({ length: mocks.newWords ?? 0 }, (_, i) => ({
      form: form({ spoken: `sana${String(i)}`, written: `sana${String(i)}`, lemma: `sana${String(i)}` }),
      spokenAudio: '/audio/a.wav',
      writtenAudio: '/audio/b.wav',
    }))
    return json(route, {
      saved: true,
      ...(mocks.saveNote ? { saveNote: mocks.saveNote } : {}),
      ...(words.length > 0 ? { newWords: words } : {}),
    })
  })
  await page.route('**/api/voice', (route) =>
    json(route, {
      available: true,
      region: 'Italy',
      processing: mocks.processing ?? 'granted',
      retention: false,
      recordings: [],
    }),
  )
  await page.route('**/api/voice/consent', (route) => {
    calls.consent.push(route.request().postDataJSON() as Record<string, unknown>)
    return json(route, {
      available: true,
      region: 'Italy',
      processing: 'granted',
      retention: false,
      recordings: [],
    })
  })
  await page.route('**/api/me', (route) => json(route, mocks.me ?? { kind: 'guest' }))
  await page.route('**/audio/**', (route) => {
    calls.audio.push(new URL(route.request().url()).pathname)
    return route.fulfill({ status: 200, contentType: 'audio/wav', body: sound })
  })
  return calls
}
