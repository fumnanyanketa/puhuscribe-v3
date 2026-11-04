import type { LearnerClient } from './learner-auth.ts'
import { DatabaseUnavailable } from './learner-db.ts'

// GET /api/road: one row per stop of the A1 road with the learner's own lesson progress
// (factory/jobs/20-a1-road/spec.md, "Done when" 5, 7 and 29).
//
// A visitor with no sign in (or an expired or invalid one) gets the same rows with no progress,
// from public.road_for_visitors(), which takes no user (statement 29). The Worker also sets the
// three progress columns to 0 itself, so no database answer can ever carry progress to a visitor.
//
// The row is read with the learner's own token through public.road(), which runs with the
// learner's own rights (security invoker): only approved content is counted, and only the
// learner's own sessions and review logs. Nothing is written. The route answers the 14 columns
// of the function and nothing else: no user id, no card numbers, no Finnish text. A row that has
// any other shape is a fault, not an answer.

export interface RoadStop {
  stop_number: number
  stop_slug: string
  title_en: string
  can_do_en: string
  part_number: number
  part_title_en: string
  dialogues_total: number
  dialogues_ready: number
  dialogues_done: number
  review_forms_total: number
  review_forms_reviewed: number
  lessons_total: number
  lessons_done: number
  live: boolean
}

export interface RoadAnswer {
  stops: RoadStop[]
}

export interface RoadDb {
  /** Every stop of the road, in stop order, as public.road() returns them. */
  road: () => Promise<unknown[]>
}

type TextColumn = 'stop_slug' | 'title_en' | 'can_do_en' | 'part_title_en'
type CountColumn =
  | 'stop_number'
  | 'part_number'
  | 'dialogues_total'
  | 'dialogues_ready'
  | 'dialogues_done'
  | 'review_forms_total'
  | 'review_forms_reviewed'
  | 'lessons_total'
  | 'lessons_done'

/** Keeps exactly the 14 columns, in a fixed order. Anything else in a row is dropped, and a row
 * with a missing or wrongly typed column is refused. */
export function roadStop(row: unknown): RoadStop {
  if (typeof row !== 'object' || row === null) throw new DatabaseUnavailable()
  const source = row as Partial<Record<keyof RoadStop, unknown>>
  const text = (key: TextColumn): string => {
    const value = source[key]
    if (typeof value !== 'string') throw new DatabaseUnavailable()
    return value
  }
  const count = (key: CountColumn): number => {
    const value = source[key]
    if (typeof value !== 'number' || !Number.isInteger(value) || value < 0) throw new DatabaseUnavailable()
    return value
  }
  if (typeof source.live !== 'boolean') throw new DatabaseUnavailable()
  return {
    stop_number: count('stop_number'),
    stop_slug: text('stop_slug'),
    title_en: text('title_en'),
    can_do_en: text('can_do_en'),
    part_number: count('part_number'),
    part_title_en: text('part_title_en'),
    dialogues_total: count('dialogues_total'),
    dialogues_ready: count('dialogues_ready'),
    dialogues_done: count('dialogues_done'),
    review_forms_total: count('review_forms_total'),
    review_forms_reviewed: count('review_forms_reviewed'),
    lessons_total: count('lessons_total'),
    lessons_done: count('lessons_done'),
    live: source.live,
  }
}

export async function roadFor(db: RoadDb): Promise<RoadAnswer> {
  return { stops: (await db.road()).map(roadStop) }
}

/**
 * Whether the learner has finished at least one whole stop, by the road's own rule: a stop is done
 * when its lessons done reach its lessons (src/lib/road-state.ts, currentIndex and progressSegments).
 * public.road() counts a stop's finished dialogues plus its review lesson against its 4 lessons, from
 * the learner's own sessions and review logs. Aleksi's intro reads it (fast route intro-stop).
 */
export function finishedAStop(stops: readonly RoadStop[]): boolean {
  return stops.some((stop) => stop.lessons_total > 0 && stop.lessons_done >= stop.lessons_total)
}

/** The same rows for a visitor: the three progress columns are always 0, whatever the database says. */
export function visitorStop(row: unknown): RoadStop {
  return { ...roadStop(row), dialogues_done: 0, review_forms_reviewed: 0, lessons_done: 0 }
}

export async function visitorRoadFor(db: RoadDb): Promise<RoadAnswer> {
  return { stops: (await db.road()).map(visitorStop) }
}

export function supabaseVisitorRoadDb(client: LearnerClient): RoadDb {
  return {
    async road() {
      const { data, error } = await client.rpc('road_for_visitors')
      if (error) throw new DatabaseUnavailable()
      return data
    },
  }
}

export function supabaseRoadDb(client: LearnerClient): RoadDb {
  return {
    async road() {
      const { data, error } = await client.rpc('road')
      if (error) throw new DatabaseUnavailable()
      return data
    },
  }
}
