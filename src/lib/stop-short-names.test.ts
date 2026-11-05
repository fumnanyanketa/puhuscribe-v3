import { describe, expect, it } from 'vitest'
import { roadFixture } from '../road/road-fixture.ts'
import { STOP_SHORT_NAMES, stopShortName } from './stop-short-names.ts'

describe('stop short names', () => {
  it('[road-signs 1] every one of the 36 stops has a short name of at most 16 characters', () => {
    const stops = roadFixture({})
    expect(stops).toHaveLength(36)
    for (const stop of stops) {
      const short = STOP_SHORT_NAMES[stop.number]
      expect(short.length, `stop ${String(stop.number)}`).toBeGreaterThan(0)
      expect(short.length, short).toBeLessThanOrEqual(16)
    }
    expect(Object.keys(STOP_SHORT_NAMES)).toHaveLength(36)
  })

  it('[road-signs 1] the short name is used when there is one, and the full name is the fallback', () => {
    expect(stopShortName(4, 'Numbers, prices and paying')).toBe('Paying')
    expect(stopShortName(99, 'A stop with no short name')).toBe('A stop with no short name')
  })
})
