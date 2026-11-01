// The smallest interface the redesigned home screen needs from job 20-a1-road
// (factory/jobs/19-redesign/spec.md, "Interface from job 20"). Job 20 provides
// the stops and the route; this job reads them through loadRoad()
// (src/lib/road-data.ts) and never designs the database.

/** One word of a sample line, with the words that change between the registers marked. */
export interface SampleWord {
  text: string
  changes: boolean
}

/** One spoken Finnish line from a stop's own approved dialogue. Only the opening animation uses it. */
export interface SampleLine {
  words: SampleWord[]
}

/** One stop of the A1 road. All text is plain text and is never rendered as markup. */
export interface RoadStop {
  /** 1 to 36, the number on the sign. */
  number: number
  /** The sign's name, in English. */
  name: string
  /** The "I can" sentence of the stop, in English. */
  canDo: string
  /** 1 to 6, the part of the road (the account page shows it). */
  part: number
  /** How many lessons the stop has. */
  lessons: number
  /** 0 to `lessons`: how many the learner has finished. */
  lessonsDone: number
  /** One spoken line from the stop's approved dialogue. Without it the animation shows no speech bubbles. */
  sampleLine?: SampleLine
}

/**
 * All stops of the A1 leg in order. For a visitor with no account it is the
 * same list with every `lessonsDone` at 0 and nothing personal in it, so the
 * day one road can draw before sign in.
 */
export interface RoadView {
  stops: RoadStop[]
}

/** Today's state, as the existing GET /api/today names it. */
export type TodayState = 'start' | 'continue' | 'review' | 'all_done' | 'not_ready'
