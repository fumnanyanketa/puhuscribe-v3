import { describe, expect, it } from 'vitest'
import type { FormRow, SessionRow, TokenRow } from './learner-db.ts'
import {
  feedbackLine,
  metDialogues,
  pickLine,
  reviewItem,
  type MetDialogue,
  type ReviewLineRow,
  type ReviewMaterial,
} from './review-plan.ts'
import { sampleDialogue } from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/9-daily-review/spec.md that each test protects.
// Which line a review card is asked in, and what the browser gets of it.

function line(id: number, dialogueId: number, position: number, puhe: string, kirja: string): ReviewLineRow {
  return {
    id,
    dialogueId,
    position,
    speaker: `Speaker ${String(id)}`,
    textPuhe: puhe,
    textKirja: kirja,
    gloss: `Meaning of line ${String(id)}.`,
    audioPuheKey: `unit-test/${String(id)}-puhe.mp3`,
    audioKirjaKey: `unit-test/${String(id)}-kirja.mp3`,
  }
}

function words(lineId: number, register: 'puhe' | 'kirja', list: [string, number | null][]): TokenRow[] {
  return list.map(([surface, formId], i) => ({ lineId, register, position: i + 1, surface, formId }))
}

function form(id: number, puhe: string, kirja: string): FormRow {
  return {
    id,
    lemma: kirja,
    formName: `Form ${String(id)}`,
    why: 'Why.',
    surfacePuhe: puhe,
    surfaceKirja: kirja,
  }
}

const MINÄ = 2
const OLLA = 3
const HEI = 4

// Line 101: "Moi! Mä oon Alex." / "Hei! Minä olen Alex."
// Line 102: "Mä oon täällä, mä." / "Minä olen täällä, minä." (minä twice)
// Line 201: written-only link for form 4 (hei), in an earlier unit.
function material(): ReviewMaterial {
  return {
    lines: [
      line(101, 1, 1, 'Moi! Mä oon Alex.', 'Hei! Minä olen Alex.'),
      line(102, 1, 2, 'Mä oon täällä, mä.', 'Minä olen täällä, minä.'),
      line(201, 2, 1, 'Moi!', 'Hei!'),
    ],
    tokens: [
      ...words(101, 'puhe', [
        ['Moi', 1],
        ['Mä', MINÄ],
        ['oon', OLLA],
        ['Alex', null],
      ]),
      ...words(101, 'kirja', [
        ['Hei', HEI],
        ['Minä', MINÄ],
        ['olen', OLLA],
        ['Alex', null],
      ]),
      ...words(102, 'puhe', [
        ['Mä', MINÄ],
        ['oon', OLLA],
        ['täällä', 9],
        ['mä', MINÄ],
      ]),
      ...words(102, 'kirja', [
        ['Minä', MINÄ],
        ['olen', OLLA],
        ['täällä', 9],
        ['minä', MINÄ],
      ]),
      ...words(201, 'puhe', [['Moi', 1]]),
      ...words(201, 'kirja', [['Hei', HEI]]),
    ],
    forms: [
      form(1, 'moi', 'moi'),
      form(MINÄ, 'mä', 'minä'),
      form(OLLA, 'oon', 'olen'),
      form(HEI, 'hei', 'hei'),
      form(9, 'täällä', 'täällä'),
    ],
  }
}

/** Dialogue 1 in unit 20, dialogue 2 in unit 10 (so dialogue 2 comes first by unit). */
const MET = new Map<number, MetDialogue>([
  [1, { unitPosition: 20, position: 1 }],
  [2, { unitPosition: 10, position: 1 }],
])

function session(id: number, dialogueId: number | null, step: SessionRow['step']): SessionRow {
  return {
    id: `00000000-0000-4000-8000-${String(id).padStart(12, '0')}`,
    dialogueId,
    step,
    startedAt: '2026-10-21T08:00:00Z',
    endedAt: null,
  }
}

function lineAt(m: ReviewMaterial, index: number): ReviewLineRow {
  const found = m.lines[index]
  if (!found) throw new Error('No such line in the test material.')
  return found
}

describe('metDialogues', () => {
  it('[review 3] only readable dialogues where a session reached at least Understand it', () => {
    const dialogues = [sampleDialogue(1, 10, 1), sampleDialogue(2, 10, 2), sampleDialogue(3, 10, 3)]
    const sessions = [
      session(1, 1, 'understand'),
      session(2, 2, 'hear'),
      session(3, 3, null),
      session(4, null, 'keep'),
      // A session of a dialogue that is no longer readable counts for nothing.
      session(5, 77, 'keep'),
    ]
    expect([...metDialogues(dialogues, sessions).keys()]).toEqual([1])
    expect([...metDialogues(dialogues, [...sessions, session(6, 2, 'say')]).keys()]).toEqual([1, 2])
    expect([...metDialogues(dialogues, [session(7, 3, 'keep')]).keys()]).toEqual([3])
  })
})

describe('pickLine', () => {
  it('[review 3] prefers a line whose spoken words link to the form, even in a later unit', () => {
    // Form 1 (moi) links from the spoken words of 101 (unit 20) and 201 (unit 10): 201 wins by unit.
    expect(pickLine(1, material(), MET)).toMatchObject({ line: { id: 201 }, register: 'puhe' })
    // Form 4 (hei) links only from written words: the written line, by unit position.
    expect(pickLine(HEI, material(), MET)).toMatchObject({ line: { id: 201 }, register: 'kirja' })
    // With only dialogue 1 met, hei comes from line 101's written words.
    const onlyFirst = new Map([[1, { unitPosition: 20, position: 1 }]])
    expect(pickLine(HEI, material(), onlyFirst)).toMatchObject({ line: { id: 101 }, register: 'kirja' })
  })

  it('[review 3] a spoken link beats a written only link that comes earlier', () => {
    const m = material()
    // Form 4 now also links from the spoken words of line 102 (unit 20), later than 201 (unit 10).
    m.tokens = m.tokens.map((t) =>
      t.lineId === 102 && t.register === 'puhe' && t.position === 3 ? { ...t, formId: HEI } : t,
    )
    expect(pickLine(HEI, m, MET)).toMatchObject({ line: { id: 102 }, register: 'puhe' })
  })

  it('[review 3] ties go to the lowest unit position, then dialogue position, then line position', () => {
    // minä links from the spoken words of 101 and 102, both in dialogue 1: the lower line position wins.
    expect(pickLine(MINÄ, material(), MET)).toMatchObject({ line: { id: 101 }, register: 'puhe' })
    // Same unit, two dialogues: the lower dialogue position wins.
    const sameUnit = new Map([
      [1, { unitPosition: 10, position: 2 }],
      [2, { unitPosition: 10, position: 1 }],
    ])
    expect(pickLine(1, material(), sameUnit)).toMatchObject({ line: { id: 201 } })
    const swapped = new Map([
      [1, { unitPosition: 10, position: 1 }],
      [2, { unitPosition: 10, position: 2 }],
    ])
    expect(pickLine(1, material(), swapped)).toMatchObject({ line: { id: 101 } })
  })

  it('[review 3] only lines of met dialogues count', () => {
    expect(pickLine(OLLA, material(), new Map([[2, { unitPosition: 10, position: 1 }]]))).toBeNull()
    expect(pickLine(OLLA, material(), new Map())).toBeNull()
  })

  it('[review 3] a form that is not readable, or with no line, gives no line', () => {
    const m = material()
    m.forms = m.forms.filter((f) => f.id !== OLLA)
    expect(pickLine(OLLA, m, MET)).toBeNull()
    expect(pickLine(555, material(), MET)).toBeNull()
  })

  it('[review 3] a line that cannot be split into its words is passed over', () => {
    const m = material()
    m.lines = m.lines.map((l) => (l.id === 101 ? { ...l, textPuhe: 'Something else entirely.' } : l))
    expect(pickLine(MINÄ, m, MET)).toMatchObject({ line: { id: 102 } })
  })
})

describe('reviewItem', () => {
  it('[review 8] every word of the form in that register becomes a gap; punctuation stays', () => {
    const m = material()
    const picked = { line: lineAt(m, 1), register: 'puhe' as const }
    expect(reviewItem(MINÄ, picked, m.tokens)).toEqual({
      formId: MINÄ,
      speaker: 'Speaker 102',
      gloss: 'Meaning of line 102.',
      register: 'spoken',
      audio: '/audio/unit-test/102-puhe.mp3',
      words: [{ gap: true }, { text: 'oon' }, { text: 'täällä', after: ',' }, { gap: true, after: '.' }],
    })
  })

  it('[review 8] holds no form surface, no gapped word and no text of the other register', () => {
    const m = material()
    const picked = { line: lineAt(m, 0), register: 'puhe' as const }
    const item = reviewItem(OLLA, picked, m.tokens)
    const text = JSON.stringify(item)
    expect(text).not.toMatch(/"oon"|"olen"/)
    expect(text).not.toContain('Hei! Minä olen Alex.')
    for (const shown of ['Hei', 'Minä', 'olen']) expect(item?.words).not.toContainEqual({ text: shown })
    expect(text).not.toMatch(/lemma|formName|why|surface/)
  })

  it('[review 8] a written prompt uses the written line and its audio', () => {
    const m = material()
    const picked = { line: lineAt(m, 2), register: 'kirja' as const }
    expect(reviewItem(HEI, picked, m.tokens)).toMatchObject({
      register: 'written',
      audio: '/audio/unit-test/201-kirja.mp3',
      words: [{ gap: true, after: '!' }],
    })
  })
})

describe('feedbackLine', () => {
  it('[review 12] gives the whole line in both registers and marks the answer words in each', () => {
    const m = material()
    const picked = { line: lineAt(m, 1), register: 'puhe' as const }
    const shown = feedbackLine(MINÄ, picked, m)
    expect(shown?.marked).toEqual({ spoken: [0, 3], written: [0, 3] })
    expect(shown?.line.spoken.map((w) => w.text)).toEqual(['Mä', 'oon', 'täällä', 'mä'])
    expect(shown?.line.written.map((w) => w.text)).toEqual(['Minä', 'olen', 'täällä', 'minä'])
    expect(shown?.line.spoken[0]?.form).toMatchObject({ spoken: 'mä', written: 'minä' })
  })
})
