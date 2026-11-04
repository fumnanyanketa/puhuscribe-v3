import { describe, expect, it } from 'vitest'
import {
  clearOldIntroKeys,
  OLD_INTRO_KEY,
  OLD_MET_KEY,
  showsAleksiIntro,
  type KeyValueStore,
  type StorageSource,
} from './aleksi-intro.ts'
import { todayInfoFrom } from '../road/home-view.ts'

// Fast routes intro-rule and intro-stop (owner's rules of 4 November 2026). Labels: [intro-stop 1] who
// sees Aleksi's intro; [intro-rule 3] the phone keeps no "met" flag and the old keys are cleared. Each case reads a
// GET /api/today body through todayInfoFrom, as the road does.

function memory(start: Record<string, string> = {}): { store: KeyValueStore; data: Map<string, string> } {
  const data = new Map(Object.entries(start))
  return {
    data,
    store: {
      removeItem: (key) => {
        data.delete(key)
      },
    },
  }
}

const throwing: StorageSource = () => {
  throw new Error('blocked')
}

const refusing: StorageSource = () => ({
  removeItem: () => {
    throw new Error('blocked')
  },
})

const shows = (body: unknown) => showsAleksiIntro(todayInfoFrom(body))

describe('who meets Aleksi', () => {
  it('[intro-stop 1] a new visitor, with nobody signed in, sees the intro', () => {
    expect(shows({ signedIn: false, ended: false })).toBe(true)
  })

  it('[intro-stop 1] a sign in that ended sees the intro, guest or email', () => {
    expect(shows({ signedIn: false, ended: true })).toBe(true)
    expect(shows({ signedIn: false, ended: true, account: 'email' })).toBe(true)
  })

  it('[intro-stop 1] a guest sees the intro, with or without a finished stop', () => {
    expect(shows({ signedIn: true, today: 'start', account: 'guest', finishedStop: false })).toBe(true)
    expect(shows({ signedIn: true, today: 'start', account: 'guest', finishedStop: true })).toBe(true)
  })

  it('[intro-stop 1] an email account that has not finished a stop sees the intro, even with lessons done', () => {
    expect(shows({ signedIn: true, today: 'continue', account: 'email', finishedStop: false })).toBe(true)
  })

  it('[intro-stop 1] an email account that has finished a stop never sees it', () => {
    expect(shows({ signedIn: true, today: 'start', account: 'email', finishedStop: true })).toBe(false)
    expect(shows({ signedIn: true, today: 'all_done', account: 'email', finishedStop: true })).toBe(false)
    expect(shows({ signedIn: true, today: 'review', account: 'email', finishedStop: true })).toBe(false)
  })

  it('[intro-stop 1] anything unclear in the answer counts as "show the intro"', () => {
    expect(shows(null)).toBe(true)
    expect(shows({ signedIn: true, today: 'start', account: 'email' })).toBe(true)
    // The earlier fact, a finished lesson, no longer skips it.
    expect(shows({ signedIn: true, today: 'start', account: 'email', finishedLesson: true })).toBe(true)
    expect(shows({ signedIn: true, today: 'start', account: 'email', finishedStop: 'yes' })).toBe(true)
    expect(shows({ signedIn: true, today: 'start', account: 'Email', finishedStop: true })).toBe(true)
    expect(shows({ signedIn: true, today: 'nonsense', account: 'email', finishedStop: true })).toBe(true)
    // An ended sign in never skips it, whatever else the body says.
    expect(shows({ signedIn: false, ended: true, account: 'email', finishedStop: true })).toBe(true)
  })
})

describe('the keys of earlier versions', () => {
  it('[intro-rule 3] the old "met" flag and the old first-open answers are removed, and nothing else', () => {
    const { store, data } = memory({
      [OLD_INTRO_KEY]: JSON.stringify({ seen: true, reason: 'work' }),
      [OLD_MET_KEY]: 'yes',
      other: 'kept',
    })
    clearOldIntroKeys(() => store)
    expect(data.has(OLD_INTRO_KEY)).toBe(false)
    expect(data.has(OLD_MET_KEY)).toBe(false)
    expect(data.get('other')).toBe('kept')
  })

  it('[intro-rule 3] storage that throws, refuses or is missing never breaks the way to the road', () => {
    expect(() => {
      clearOldIntroKeys(throwing)
      clearOldIntroKeys(refusing)
      clearOldIntroKeys(() => null)
    }).not.toThrow()
  })
})
