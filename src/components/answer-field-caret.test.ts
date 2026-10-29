import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { restoreCaretAfterLetter, type CaretField } from './answer-field-caret.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/9-daily-review/spec.md that each test protects.

function fakeField(value: string) {
  const calls: string[] = []
  const field: CaretField & { caret: number } = {
    value,
    caret: value.length,
    focus: () => {
      calls.push('focus')
    },
    setSelectionRange: (start) => {
      field.caret = start
      calls.push(`caret ${String(start)}`)
    },
  }
  return { field, calls }
}

describe('restoreCaretAfterLetter', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })
  afterEach(() => {
    vi.useRealTimers()
  })

  it('[review 9] the ä button puts the caret after the letter when nothing else is typed', () => {
    const { field, calls } = fakeField('tä')
    field.caret = 2
    restoreCaretAfterLetter(field, 'tä', 2)
    vi.runAllTimers()
    expect(calls).toEqual(['focus', 'caret 2'])
  })

  it('[review 9] letters typed right after the ä button stay where they were typed', () => {
    // The learner has "t" and taps "Type ä": the text becomes "tä", caret at 2.
    const { field } = fakeField('tä')
    restoreCaretAfterLetter(field, 'tä', 2)
    // Before the timeout fires, the learner types "l" at the end.
    field.value = 'täl'
    field.caret = 3
    vi.runAllTimers()
    expect(field.value).toBe('täl')
    expect(field.caret).toBe(3)
  })
})
