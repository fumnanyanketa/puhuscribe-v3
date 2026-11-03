import { callApi, isRecord } from '../lib/api.ts'
import type { IslandEntry } from '../lib/islands.ts'
import { validEntry } from '../lib/islands.ts'
import type { IslandAnswer } from '../lib/session-types.ts'

// The island's two calls (worker/island.ts). The answer is checked here, and a line the approved data
// cannot make is dropped, so the screens only ever draw lines from content/islands/islands.md.

function entryOf(value: unknown): IslandEntry | null {
  if (!isRecord(value)) return null
  const { stop, choice, name } = value
  if (typeof stop !== 'number') return null
  if (choice !== null && typeof choice !== 'number') return null
  if (name !== undefined && typeof name !== 'string') return null
  const entry: IslandEntry = { stop, choice, ...(name === undefined ? {} : { name }) }
  return validEntry(entry) ? entry : null
}

/** The learner's island, or null when it could not be read. */
export async function loadIsland(): Promise<IslandAnswer | null> {
  const answer = await callApi('/api/island', 'GET')
  if (answer?.status !== 200 || !isRecord(answer.body)) return null
  const { lines, open } = answer.body
  if (!Array.isArray(lines) || !Array.isArray(open)) return null
  return {
    lines: lines.flatMap((line: unknown) => {
      const entry = entryOf(line)
      return entry ? [entry] : []
    }),
    open: open.filter((stop: unknown): stop is number => typeof stop === 'number' && Number.isInteger(stop)),
  }
}

export type SaveResult = 'saved' | 'signed_out' | 'failed'

/** Adds or changes the learner's line for one stop. */
export async function saveIslandLine(entry: IslandEntry): Promise<SaveResult> {
  const answer = await callApi('/api/island', 'POST', {
    stop: entry.stop,
    choice: entry.choice,
    ...(entry.name === undefined ? {} : { name: entry.name }),
  })
  if (answer?.status === 200) return 'saved'
  if (answer?.status === 401) return 'signed_out'
  return 'failed'
}
