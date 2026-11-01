import { callApi, isRecord } from './api.ts'
import type { RoadStop, RoadView, SampleLine, SampleWord } from './road-types.ts'

// The road reads its stops through this one function, which calls the route
// job 20-a1-road provides, GET /api/road (factory/jobs/19-redesign/spec.md,
// statement 19). If job 20 names the route or its fields differently, only
// this file changes. It accepts the answer as a list or as { stops }, with
// the field names of the interface (number, name, canDo, part, lessons,
// lessonsDone) or the column names of job 20's road() function (stop_number,
// title_en, can_do_en, part_number, lessons_total, lessons_done).
//
// Every string is plain text: it is capped here and rendered as text only.

export const ROAD_ROUTE = '/api/road'

const MAX_NAME = 80
const MAX_CAN_DO = 200
const MAX_WORD = 40

function integer(value: unknown, min: number, max: number): number | null {
  return typeof value === 'number' && Number.isInteger(value) && value >= min && value <= max ? value : null
}

function text(value: unknown, max: number): string | null {
  if (typeof value !== 'string') return null
  const trimmed = value.trim()
  return trimmed.length > 0 && trimmed.length <= max ? trimmed : null
}

function pick(row: Record<string, unknown>, ...keys: string[]): unknown {
  for (const key of keys) if (key in row) return row[key]
  return undefined
}

function sampleLineOf(value: unknown): SampleLine | undefined {
  if (!isRecord(value) || !Array.isArray(value.words) || value.words.length === 0) return undefined
  const words: SampleWord[] = []
  for (const word of value.words as unknown[]) {
    if (!isRecord(word)) return undefined
    const wordText = text(word.text, MAX_WORD)
    if (wordText === null) return undefined
    words.push({ text: wordText, changes: word.changes === true })
  }
  return words.length <= 12 ? { words } : undefined
}

function stopOf(row: unknown): RoadStop | null {
  if (!isRecord(row)) return null
  const number = integer(pick(row, 'number', 'stop_number'), 1, 99)
  const name = text(pick(row, 'name', 'title_en'), MAX_NAME)
  const canDo = text(pick(row, 'canDo', 'can_do_en'), MAX_CAN_DO)
  const part = integer(pick(row, 'part', 'part_number'), 1, 99)
  const lessons = integer(pick(row, 'lessons', 'lessons_total'), 1, 12)
  if (number === null || name === null || canDo === null || part === null || lessons === null) return null
  const done = integer(pick(row, 'lessonsDone', 'lessons_done'), 0, lessons)
  if (done === null) return null
  const sample = sampleLineOf(row.sampleLine)
  return { number, name, canDo, part, lessons, lessonsDone: done, ...(sample ? { sampleLine: sample } : {}) }
}

/** The stops of an answer, or null when it is not a clean list of stops in order. */
export function parseRoad(body: unknown): RoadView | null {
  const list: unknown = Array.isArray(body) ? body : isRecord(body) ? body.stops : undefined
  if (!Array.isArray(list) || list.length === 0 || list.length > 99) return null
  const stops: RoadStop[] = []
  for (const row of list as unknown[]) {
    const stop = stopOf(row)
    if (!stop) return null
    const before = stops.at(-1)
    if (before && stop.number <= before.number) return null
    stops.push(stop)
  }
  return { stops }
}

/** Reads the road. Null when it could not be read: no answer, not 200, or a body that is not a clean list. */
export async function loadRoad(): Promise<RoadView | null> {
  const answer = await callApi(ROAD_ROUTE, 'GET')
  if (answer?.status !== 200) return null
  return parseRoad(answer.body)
}
