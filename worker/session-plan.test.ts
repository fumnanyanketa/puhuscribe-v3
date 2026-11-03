import { describe, expect, it } from 'vitest'
import type { DialogueContent, FormRow, SessionRow } from './learner-db.ts'
import { audioPath, keyLinesOf, newWordsOf, pickToday, sessionLines, splitLine } from './session-plan.ts'
import { sampleContent, sampleDialogue } from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects.

function session(dialogueId: number, endedAt: string | null, startedAt = '2026-10-21T10:00:00Z'): SessionRow {
  return { id: `s-${String(dialogueId)}-${startedAt}`, dialogueId, step: null, startedAt, endedAt }
}

describe("today's dialogue", () => {
  const dialogues = [sampleDialogue(30, 2, 1), sampleDialogue(20, 1, 2), sampleDialogue(10, 1, 1)]

  it('[session 6] is the lowest unit position, then the lowest dialogue position', () => {
    const pick = pickToday(dialogues, [])
    expect(pick.kind === 'dialogue' && pick.dialogue.id).toBe(10)
  })

  it('[session 6] skips finished dialogues', () => {
    const pick = pickToday(dialogues, [session(10, '2026-10-21T11:00:00Z')])
    expect(pick.kind === 'dialogue' && pick.dialogue.id).toBe(20)
  })

  it('[session 6] [session 18] reuses the newest unfinished session of that dialogue', () => {
    const older = session(10, null, '2026-10-20T10:00:00Z')
    const newer = session(10, null, '2026-10-21T10:00:00Z')
    const pick = pickToday(dialogues, [older, newer, session(20, null)])
    expect(pick.kind === 'dialogue' && pick.open?.id).toBe(newer.id)
  })

  it('[session 6] is all_done when every dialogue is finished, and not_ready when none is readable', () => {
    const done = dialogues.map((d) => session(d.id, '2026-10-21T11:00:00Z'))
    expect(pickToday(dialogues, done)).toEqual({ kind: 'all_done' })
    expect(pickToday([], [])).toEqual({ kind: 'not_ready' })
  })
})

describe('splitting a line into its words', () => {
  it('[session 9] keeps punctuation with the word before it', () => {
    expect(
      splitLine('Moi! Mä oon Alex.', [
        { surface: 'Moi' },
        { surface: 'Mä' },
        { surface: 'oon' },
        { surface: 'Alex' },
      ]),
    ).toEqual([{ text: 'Moi', after: '!' }, { text: 'Mä' }, { text: 'oon' }, { text: 'Alex', after: '.' }])
  })

  it('[session 9] keeps punctuation before the first word', () => {
    expect(splitLine('"Moi!"', [{ surface: 'Moi' }])).toEqual([{ text: 'Moi', before: '"', after: '!"' }])
  })

  it('[session 9] refuses a line whose words are not all found, in order', () => {
    expect(splitLine('Mä oon Alex.', [{ surface: 'oon' }, { surface: 'Mä' }])).toBeNull()
    expect(splitLine('Mä oon Alex.', [{ surface: 'Mä' }, { surface: 'Alex' }])).toBeNull()
    expect(splitLine('Mä oon Alex.', [{ surface: 'Mä' }, { surface: 'oon' }])).toBeNull()
    expect(splitLine('Mä oon', [])).toBeNull()
  })

  it('[session 9] [session 12] builds both registers, with cards only for readable forms', () => {
    const lines = sessionLines(sampleContent())
    expect(lines.map((l) => l.id)).toEqual([11, 12])
    expect(lines[0]?.spoken.filter((w) => w.form).map((w) => w.text)).toEqual(['Moi', 'Mä', 'oon'])
    expect(lines[1]?.written.filter((w) => w.form).map((w) => w.text)).toEqual(['Hauska'])
  })
})

describe('audio paths', () => {
  it('[session 10] are /audio/<key> on the same address, with each part encoded', () => {
    expect(audioPath('unit-1-dialogue-1/1-puhe-0123456789ab.mp3')).toBe(
      '/audio/unit-1-dialogue-1/1-puhe-0123456789ab.mp3',
    )
    expect(audioPath('a b/c.mp3')).toBeNull()
  })

  it('[session 10] refuse a key that could leave the /audio/ folder or name another address', () => {
    for (const key of [
      '../secret.mp3',
      'a/../b.mp3',
      '/abs.mp3',
      'https://x.example/a.mp3',
      '',
      'a//b.mp3',
      './a.mp3',
    ]) {
      expect(audioPath(key), key).toBeNull()
    }
  })
})

// [word-meanings 1] and [word-meanings 2]: this quick-lane fix (3 November 2026).
describe('word meanings', () => {
  function withMeanings() {
    const content = sampleContent()
    return {
      ...content,
      forms: content.forms.map((form) =>
        form.id === 2 ? { ...form, meaning: 'I', baseMeaning: 'I, me' } : form,
      ),
    }
  }

  it('[word-meanings 1] a line word and a new word carry the form meaning and the dictionary meaning', () => {
    const content = withMeanings()
    const mä = sessionLines(content)[0]?.spoken.find((word) => word.text === 'Mä')
    expect(mä?.form).toMatchObject({ lemma: 'minä', meaning: 'I', baseMeaning: 'I, me' })
    const fresh = newWordsOf(content, [2]).find((word) => word.form.lemma === 'minä')
    expect(fresh?.form).toMatchObject({ meaning: 'I', baseMeaning: 'I, me' })
  })

  it('[word-meanings 2] a form with no meanings has neither field', () => {
    const moi = sessionLines(withMeanings())[0]?.spoken.find((word) => word.text === 'Moi')
    expect(moi?.form).toBeDefined()
    expect(moi?.form).not.toHaveProperty('meaning')
    expect(moi?.form).not.toHaveProperty('baseMeaning')
  })
})

describe("the recap's key lines", () => {
  // Five lines in shuffled positions. Each line links to the forms listed, in both registers.
  const FORMS: Record<number, number[]> = { 11: [1, 2], 12: [3, 4, 5], 13: [], 14: [6, 7], 15: [8, 9] }
  const POSITIONS: Record<number, number> = { 11: 1, 12: 2, 13: 3, 14: 4, 15: 5 }
  function content(unreadable: number[] = []): DialogueContent {
    const lineIds = [15, 13, 11, 14, 12]
    const form = (id: number): FormRow => ({
      id,
      lemma: `f${String(id)}`,
      formName: 'x',
      why: 'x',
      surfacePuhe: 'x',
      surfaceKirja: 'x',
    })
    return {
      lines: lineIds.map((id) => ({
        id,
        position: POSITIONS[id] ?? 0,
        speaker: 'A',
        textPuhe: 'x',
        textKirja: 'x',
        gloss: 'x',
        audioPuheKey: 'k',
        audioKirjaKey: 'k',
      })),
      tokens: lineIds.flatMap((lineId) =>
        (FORMS[lineId] ?? []).flatMap((formId, position) =>
          (['puhe', 'kirja'] as const).map((register) => ({
            lineId,
            register,
            position,
            surface: 'x',
            formId,
          })),
        ),
      ),
      forms: [1, 2, 3, 4, 5, 6, 7, 8, 9].filter((id) => !unreadable.includes(id)).map(form),
    }
  }

  it('[hear-and-say recap] takes the three lines with the most new forms, a tie to the earlier line, in line order', () => {
    // Line 12 has 3 new forms; 11, 14 and 15 have 2 each, so 11 and 14 win the tie over 15.
    expect(keyLinesOf(content(), [])).toEqual([11, 12, 14])
  })

  it('[hear-and-say recap] a form the learner already has a card for does not count', () => {
    // Cards for 3, 4 and 6: line 12 has 1 new form, 14 has 1; 11 and 15 have 2.
    expect(keyLinesOf(content(), [3, 4, 6])).toEqual([11, 12, 15])
  })

  it('[hear-and-say recap] a form the learner cannot read does not count', () => {
    expect(keyLinesOf(content([1, 2]), [])).toEqual([12, 14, 15])
  })

  it('[hear-and-say recap] with every form known, the recap is the first three lines', () => {
    expect(keyLinesOf(content(), [1, 2, 3, 4, 5, 6, 7, 8, 9])).toEqual([11, 12, 13])
  })
})
