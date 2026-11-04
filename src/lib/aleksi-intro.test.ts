import { describe, expect, it } from 'vitest'
import {
  clearOldIntro,
  hasMetAleksi,
  markMetAleksi,
  MET_KEY,
  OLD_INTRO_KEY,
  showsAleksiIntro,
  type KeyValueStore,
  type StorageSource,
} from './aleksi-intro.ts'

// Fast route aleksi-intro (owner approved 4 November 2026). Labels name the item of the owner's brief.

function memory(start: Record<string, string> = {}): { store: KeyValueStore; data: Map<string, string> } {
  const data = new Map(Object.entries(start))
  return {
    data,
    store: {
      getItem: (key) => data.get(key) ?? null,
      setItem: (key, value) => {
        data.set(key, value)
      },
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
  getItem: () => {
    throw new Error('blocked')
  },
  setItem: () => {
    throw new Error('full')
  },
  removeItem: () => {
    throw new Error('blocked')
  },
})

describe('who meets Aleksi', () => {
  it('[aleksi-intro 2] only a new visitor: nobody signed in, no ended sign in, not met on this phone', () => {
    expect(showsAleksiIntro(false, false, false)).toBe(true)
    expect(showsAleksiIntro(true, false, false)).toBe(false)
    expect(showsAleksiIntro(false, true, false)).toBe(false)
    expect(showsAleksiIntro(false, false, true)).toBe(false)
  })
})

describe('the "met" flag on this phone', () => {
  it('[aleksi-intro 4] "Nice to meet you" marks the phone, and a marked phone has met Aleksi', () => {
    const { store, data } = memory()
    expect(hasMetAleksi(() => store)).toBe(false)
    expect(markMetAleksi(() => store)).toBe(true)
    expect(data.get(MET_KEY)).toBe('yes')
    expect(hasMetAleksi(() => store)).toBe(true)
  })

  it('[aleksi-intro 4] an unexpected value counts as not met', () => {
    const { store } = memory({ [MET_KEY]: 'maybe' })
    expect(hasMetAleksi(() => store)).toBe(false)
  })

  it('[aleksi-intro 4] storage that throws or refuses never breaks the way to the road', () => {
    expect(hasMetAleksi(throwing)).toBe(false)
    expect(markMetAleksi(throwing)).toBe(false)
    expect(hasMetAleksi(refusing)).toBe(false)
    expect(markMetAleksi(refusing)).toBe(false)
    expect(markMetAleksi(() => null)).toBe(false)
    expect(() => {
      clearOldIntro(throwing)
      clearOldIntro(refusing)
    }).not.toThrow()
  })
})

describe('the old first-open questions', () => {
  it('[aleksi-intro 4] their stored answers are removed and nothing else is touched', () => {
    const { store, data } = memory({
      [OLD_INTRO_KEY]: JSON.stringify({ seen: true, reason: 'work' }),
      [MET_KEY]: 'yes',
    })
    clearOldIntro(() => store)
    expect(data.has(OLD_INTRO_KEY)).toBe(false)
    expect(data.get(MET_KEY)).toBe('yes')
  })
})
