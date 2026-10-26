import { describe, expect, it } from 'vitest'
import { answerModeFor } from './answer-mode.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.

const ON = { speakingOn: true, recordingWorks: true, switchedToTyping: false }

describe('the answer method of a review item', () => {
  it('[speak 21] every second item is spoken when speaking feedback is on and recording works', () => {
    const modes = [0, 1, 2, 3, 4, 5].map((position) => answerModeFor({ position, ...ON }))
    expect(modes).toEqual(['typed', 'spoken', 'typed', 'spoken', 'typed', 'spoken'])
  })

  it('[speak 21] every item is typed when speaking feedback is off, not set up, or recording does not work', () => {
    for (const position of [0, 1, 2, 3]) {
      expect(answerModeFor({ position, ...ON, speakingOn: false })).toBe('typed')
      expect(answerModeFor({ position, ...ON, recordingWorks: false })).toBe('typed')
    }
  })

  it('[speak 21] an item that switched to typing after a failure stays typed', () => {
    expect(answerModeFor({ position: 1, ...ON, switchedToTyping: true })).toBe('typed')
  })
})
