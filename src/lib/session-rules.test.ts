import { describe, expect, it } from 'vitest'
import { pickFinishLine, pickQuestions, reviewableForms } from './session-rules.ts'
import type { SessionLine, SessionWord } from './session-types.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects.

function word(text: string, withForm: boolean): SessionWord {
  return withForm
    ? { text, form: { lemma: text, formName: 'Form', why: 'Why.', spoken: text, written: `${text}x` } }
    : { text }
}

/** A line with `formWords` words that have forms, then `plain` words without. */
function line(id: number, formWords: number, plain: number, gloss = `Meaning ${String(id)}`): SessionLine {
  const spoken = [
    ...Array.from({ length: formWords }, (_, i) => word(`w${String(id)}f${String(i)}`, true)),
    ...Array.from({ length: plain }, (_, i) => word(`w${String(id)}p${String(i)}`, false)),
  ]
  return {
    id,
    speaker: 'S',
    gloss,
    spokenAudio: '/audio/a',
    writtenAudio: '/audio/b',
    spoken,
    written: spoken,
  }
}

describe('the comprehension questions (Decision 4)', () => {
  const lines = [line(1, 1, 3), line(2, 3, 0), line(3, 2, 0), line(4, 3, 1), line(5, 0, 1)]

  it('[session 13] asks about the lines with the most reviewable words, up to three, in dialogue order', () => {
    const questions = pickQuestions(lines, 'session-a')
    expect(questions.map((q) => q.line.id)).toEqual([2, 3, 4])
  })

  it('[session 13] breaks ties in favour of the earlier line', () => {
    const tied = [line(1, 2, 0), line(2, 2, 0), line(3, 2, 0), line(4, 2, 0)]
    expect(pickQuestions(tied, 'x').map((q) => q.line.id)).toEqual([1, 2, 3])
  })

  it("[session 13] offers the line's own meaning and up to two other meanings from the dialogue", () => {
    for (const question of pickQuestions(lines, 'session-a')) {
      expect(question.choices).toHaveLength(3)
      expect(question.choices[question.answer]).toBe(question.line.gloss)
      expect(new Set(question.choices).size).toBe(3)
      for (const choice of question.choices) expect(lines.map((l) => l.gloss)).toContain(choice)
    }
  })

  it('[session 13] gives the same questions in the same order for the same session, every time', () => {
    expect(pickQuestions(lines, 'session-a')).toEqual(pickQuestions(lines, 'session-a'))
    const orders = new Set(
      ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].map((id) =>
        JSON.stringify(pickQuestions(lines, id).map((q) => q.choices)),
      ),
    )
    expect(orders.size).toBeGreaterThan(1)
  })

  it('[session 13] works with a one or two line dialogue', () => {
    expect(pickQuestions([line(1, 1, 0)], 's')[0]?.choices).toEqual(['Meaning 1'])
    const two = pickQuestions([line(1, 1, 0), line(2, 1, 0)], 's')
    expect(two.map((q) => q.choices.length)).toEqual([2, 2])
  })

  it('[session 13] never offers the right meaning twice when two lines share it', () => {
    const same = [line(1, 2, 0, 'Hi.'), line(2, 1, 0, 'Hi.'), line(3, 1, 0, 'Bye.')]
    const first = pickQuestions(same, 's').at(0)
    expect(first?.choices.filter((c) => c === 'Hi.')).toHaveLength(1)
  })

  it('[session 13] counts each different form once, in both registers', () => {
    const repeated: SessionLine = { ...line(1, 2, 0), written: line(1, 2, 0).spoken }
    expect(reviewableForms(repeated)).toBe(2)
  })
})

describe('the sentence you can now say (Decision 5)', () => {
  it('[session 14] is the shortest line with at least two words that have forms', () => {
    const lines = [line(1, 1, 0), line(2, 2, 3), line(3, 2, 1), line(4, 3, 0)]
    expect(pickFinishLine(lines)?.id).toBe(3)
  })

  it('[session 14] gives ties to the earlier line', () => {
    expect(pickFinishLine([line(1, 2, 1), line(2, 3, 0)])?.id).toBe(1)
  })

  it('[session 14] falls back to the shortest line with one such word, then to the shortest line', () => {
    expect(pickFinishLine([line(1, 1, 3), line(2, 1, 1), line(3, 0, 1)])?.id).toBe(2)
    expect(pickFinishLine([line(1, 0, 3), line(2, 0, 2)])?.id).toBe(2)
    expect(pickFinishLine([])).toBeNull()
  })
})
