import { describe, expect, it } from 'vitest'
import { INTRO_KEY, offersIntro, readIntro, saveIntro, type StorageSource } from './intro-answers.ts'

// Unit tests of the first-open questions' storage (fast route "intro", owner's
// plan of 3 November 2026). [intro N] is the plan's item number.

function memory(): { source: StorageSource; data: Map<string, string> } {
  const data = new Map<string, string>()
  return {
    data,
    source: () => ({
      getItem: (key: string) => data.get(key) ?? null,
      setItem: (key: string, value: string) => {
        data.set(key, value)
      },
    }),
  }
}

const throwing: StorageSource = () => {
  throw new Error('SecurityError')
}

const refusing: StorageSource = () => ({
  getItem: () => {
    throw new Error('blocked')
  },
  setItem: () => {
    throw new Error('QuotaExceededError')
  },
})

describe('intro answers on the phone', () => {
  it('[intro 3] keeps the two answers under one key and reads them back', () => {
    const { source, data } = memory()
    expect(saveIntro({ seen: true, reason: 'family-and-friends', time: 'evening' }, source)).toBe(true)
    expect(JSON.parse(data.get(INTRO_KEY) ?? '')).toEqual({
      seen: true,
      reason: 'family-and-friends',
      time: 'evening',
    })
    expect(readIntro(source)).toEqual({ seen: true, reason: 'family-and-friends', time: 'evening' })
  })

  it('[intro 1] a skipped question stores no answer for it', () => {
    const { source } = memory()
    saveIntro({ seen: true }, source)
    expect(readIntro(source)).toEqual({ seen: true })
  })

  it('[intro 4] a phone with nothing stored has not seen the questions', () => {
    expect(readIntro(memory().source)).toEqual({ seen: false })
  })

  it('[intro 3] storage that throws on reach, read or write never breaks the flow', () => {
    expect(readIntro(throwing)).toEqual({ seen: false })
    expect(saveIntro({ seen: true, reason: 'work' }, throwing)).toBe(false)
    expect(readIntro(refusing)).toEqual({ seen: false })
    expect(saveIntro({ seen: true, time: 'morning' }, refusing)).toBe(false)
    expect(readIntro(() => null)).toEqual({ seen: false })
    expect(saveIntro({ seen: true }, () => null)).toBe(false)
  })

  it('[intro 3] broken or unexpected stored values are ignored, never shown or trusted', () => {
    const { source, data } = memory()
    data.set(INTRO_KEY, '{not json')
    expect(readIntro(source)).toEqual({ seen: false })
    data.set(INTRO_KEY, JSON.stringify({ seen: 'yes' }))
    expect(readIntro(source)).toEqual({ seen: false })
    data.set(INTRO_KEY, JSON.stringify(null))
    expect(readIntro(source)).toEqual({ seen: false })
    data.set(INTRO_KEY, JSON.stringify({ seen: true, reason: '<b>x</b>', time: 'midnight' }))
    expect(readIntro(source)).toEqual({ seen: true })
  })

  it('[intro 4] only a new visitor on the day one card is offered the questions', () => {
    expect(offersIntro('day-one', false, { seen: false })).toBe(true)
    // Once per phone.
    expect(offersIntro('day-one', false, { seen: true })).toBe(false)
    // A guest session that ended on this phone is a returning learner.
    expect(offersIntro('day-one', true, { seen: false })).toBe(false)
    // Anyone with a guest session or an account sees another card.
    for (const kind of ['lesson', 'review', 'stop-finished', 'done', 'message']) {
      expect(offersIntro(kind, false, { seen: false })).toBe(false)
    }
  })
})
