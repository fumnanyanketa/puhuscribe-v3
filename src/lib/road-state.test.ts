import { describe, expect, it } from 'vitest'
import { ROAD_DAY_ONE, ROAD_MID, roadFixture } from '../road/road-fixture.ts'
import {
  accountLetter,
  currentIndex,
  dayOneLine,
  isStopFinished,
  lessonLine,
  lessonSegments,
  markerIndex,
  progressSegments,
  roadFinished,
  signWindow,
  travelled,
} from './road-state.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md.

describe('the current stop', () => {
  it('[redesign 15] is the first stop with a lesson left, and the last one when every stop is done', () => {
    expect(currentIndex(ROAD_DAY_ONE)).toBe(0)
    expect(currentIndex(ROAD_MID)).toBe(2)
    const all = roadFixture(Object.fromEntries(Array.from({ length: 36 }, (_, i) => [i + 1, 4])))
    expect(currentIndex(all)).toBe(35)
    expect(roadFinished(all)).toBe(true)
    expect(roadFinished(ROAD_MID)).toBe(false)
  })
})

describe('the five signs', () => {
  it('[redesign 13] shows the current stop first at the start, then four after it', () => {
    const { start, signs } = signWindow(ROAD_DAY_ONE, 0, false)
    expect(start).toBe(0)
    expect(signs.map((sign) => sign.stop.number)).toEqual([1, 2, 3, 4, 5])
    expect(signs.map((sign) => sign.state)).toEqual(['current', 'later', 'later', 'later', 'later'])
  })

  it('[redesign 13] shows up to two stops before the current one, and the rest after it', () => {
    const { signs } = signWindow(ROAD_MID, 2, false)
    expect(signs.map((sign) => sign.stop.number)).toEqual([1, 2, 3, 4, 5])
    expect(signs.map((sign) => sign.state)).toEqual(['done', 'done', 'current', 'later', 'later'])
    const further = signWindow(roadFixture({ 1: 4, 2: 4, 3: 4, 4: 4, 5: 4 }), 5, false)
    expect(further.signs.map((sign) => sign.stop.number)).toEqual([4, 5, 6, 7, 8])
    expect(further.signs.map((sign) => sign.state)).toEqual(['done', 'done', 'current', 'later', 'later'])
  })

  it('[redesign 13] always shows five, shifted at the end of the road', () => {
    const stops = roadFixture()
    for (const marker of [0, 1, 2, 17, 33, 34, 35]) {
      expect(signWindow(stops, marker, false).signs, String(marker)).toHaveLength(5)
    }
    const last = signWindow(stops, 35, false)
    expect(last.signs.map((sign) => sign.stop.number)).toEqual([32, 33, 34, 35, 36])
    expect(last.signs.at(-1)?.state).toBe('current')
    expect(signWindow(roadFixture().slice(0, 3), 0, false).signs).toHaveLength(3)
  })

  it('[redesign 13] names the four states in words, so colour is never the only sign', () => {
    const stops = roadFixture({ 1: 4, 2: 4 })
    const labels = signWindow(stops, 2, false).signs.map((sign) => sign.label)
    expect(labels[0]).toBe('Stop 1, Meeting people, done')
    expect(labels[2]).toBe('Stop 3, At the grocery store, current')
    expect(labels[3]).toBe('Stop 4, Numbers, prices and paying, later')
    const finished = signWindow(roadFixture({ 1: 4, 2: 4, 3: 4 }), 2, true).signs.map((sign) => sign.label)
    expect(finished[2]).toBe('Stop 3, At the grocery store, done')
    expect(finished[3]).toBe('Stop 4, Numbers, prices and paying, next')
    expect(finished[4]).toBe('Stop 5, Getting around by bus and tram, later')
  })

  it('[redesign 13] lights the next stop in peach only on the Stop finished card', () => {
    const stops = roadFixture({ 1: 4, 2: 4, 3: 4 })
    expect(isStopFinished(stops, 'start')).toBe(true)
    expect(markerIndex(stops, true)).toBe(2)
    const states = signWindow(stops, 2, true).signs.map((sign) => sign.state)
    expect(states).toEqual(['done', 'done', 'done', 'next', 'later'])
    expect(signWindow(stops, 3, false).signs.map((sign) => sign.state)).not.toContain('next')
  })
})

describe('Stop finished', () => {
  it('[redesign 15] needs a new lesson to start, a current stop with none done, and a stop before it', () => {
    const done3 = roadFixture({ 1: 4, 2: 4, 3: 4 })
    expect(isStopFinished(done3, 'start')).toBe(true)
    expect(isStopFinished(done3, 'continue')).toBe(false)
    expect(isStopFinished(done3, 'review')).toBe(false)
    expect(isStopFinished(done3, 'all_done')).toBe(false)
    expect(isStopFinished(done3, 'signed_out')).toBe(false)
    expect(isStopFinished(ROAD_DAY_ONE, 'start')).toBe(false)
    expect(isStopFinished(ROAD_MID, 'start')).toBe(false)
  })
})

describe('the progress bar and the lesson pieces', () => {
  it('[redesign 14] has 12 pieces, one per three stops, filled when all three are done', () => {
    expect(progressSegments(ROAD_DAY_ONE)).toEqual(Array.from({ length: 12 }, () => false))
    const first3 = roadFixture({ 1: 4, 2: 4, 3: 4 })
    expect(progressSegments(first3).slice(0, 2)).toEqual([true, false])
    const two = roadFixture({ 1: 4, 2: 4 })
    expect(progressSegments(two).filter(Boolean)).toHaveLength(0)
    const all = roadFixture(Object.fromEntries(Array.from({ length: 36 }, (_, i) => [i + 1, 4])))
    expect(progressSegments(all).every(Boolean)).toBe(true)
    expect(progressSegments(ROAD_MID)).toHaveLength(12)
  })

  it('[redesign 15] fills one piece per lesson done and says which lesson the learner is at', () => {
    const stop = ROAD_MID[2]
    expect(lessonSegments(stop)).toEqual([true, true, false, false])
    expect(lessonLine(stop)).toBe('Stop 3, lesson 3 of 4')
    expect(lessonLine({ ...stop, lessonsDone: 4 })).toBe('Stop 3, lesson 4 of 4')
    const first = ROAD_DAY_ONE[0]
    expect(dayOneLine(first)).toBe('Stop 1, 4 short lessons')
  })

  it('[redesign 12] the mint centre line reaches the marker and no further', () => {
    expect(travelled(ROAD_DAY_ONE, 0)).toBe(0)
    expect(travelled(ROAD_MID, 2)).toBeCloseTo(2 / 35, 5)
    expect(travelled(ROAD_MID, 35)).toBe(1)
  })
})

describe('the account button letter', () => {
  it('[redesign 14] is the first letter of the email in capitals, and G for a guest or an odd address', () => {
    expect(accountLetter('guest')).toBe('G')
    expect(accountLetter('email', 'maria@example.fi')).toBe('M')
    expect(accountLetter('email', 'ähti@example.fi')).toBe('Ä')
    expect(accountLetter('email', '')).toBe('G')
    expect(accountLetter('email', '<script>')).toBe('G')
  })
})
