import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'
import { learnLine, STOP_CAN_DO_YOU } from '../src/road/stop-can-do.ts'

// Fast route road-stops (owner approved 5 November 2026), "Done when" 4: the stop screen says what the stop
// teaches in the second person. The stops are the published ones of the road stops migration.

const MIGRATION = 'supabase/migrations/20261101120100_load_road_stops.sql'
const published = [...readFileSync(MIGRATION, 'utf8').matchAll(/^\s*\((\d+), '[a-z-]+', \d, '/gm)].map(
  (match) => Number(match[1]),
)

describe('second person can-do lines', () => {
  it('[road-stops 4] the migration publishes 36 stops, and every one has a line, with no line for a stop that is not there', () => {
    expect(published).toEqual(Array.from({ length: 36 }, (_, i) => i + 1))
    expect(Object.keys(STOP_CAN_DO_YOU).map(Number)).toEqual(published)
    for (const stop of published) expect(learnLine(stop), String(stop)).toMatch(/^Here you’ll learn to .+\.$/)
    expect(learnLine(37)).toBeUndefined()
  })

  it('[road-stops 4] every line speaks to the learner: no "I", "my" or "myself", short, English only', () => {
    for (const [stop, line] of Object.entries(STOP_CAN_DO_YOU)) {
      expect(line, stop).not.toMatch(/\b(I|I'm|I’m|my|myself|me)\b/)
      expect(line, stop).not.toMatch(/[.!?]$/)
      expect(line.length, stop).toBeLessThanOrEqual(64)
      expect(line, stop).toMatch(/^[a-z]/)
      // No Finnish on the stop screen: the lines use only English letters.
      expect(line, stop).not.toMatch(/[äöåÄÖÅ]/)
    }
  })

  it('[road-stops 4] stop 1 says it the way the owner’s mockup does', () => {
    expect(learnLine(1)).toBe('Here you’ll learn to say who you are and where you’re from, and ask the same.')
  })
})
