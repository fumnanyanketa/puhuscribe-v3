import { ISLAND_STOPS, cleanName, islandStop, validEntry, type IslandEntry } from '../src/lib/islands.ts'
import type { IslandAnswer } from '../src/lib/session-types.ts'
import { json, refuseNonGet, refuseUnsafeWrite, withCookies } from './http.ts'
import type { LearnerClient, LearnerContext } from './learner-auth.ts'
import {
  AccountGone,
  DatabaseUnavailable,
  type LearnerDb,
  type ReadableDialogue,
  type SessionRow,
} from './learner-db.ts'

// The learner's island (fast route "islands", 3 November 2026).
//
// GET /api/island: the learner's own island lines, and the stops whose line they may add or change.
// POST /api/island with {"stop", "choice", "name"}: adds or changes the learner's line for one stop.
//
// Every read and write is made with the learner's own token, so the database's lock decides what is
// seen (public.island_lines: only the learner's own rows). The user id is never sent: the database
// takes it from the token. A guest's island is kept on the guest account like their progress, and an
// email added later keeps the same account, so the island moves with it.
//
// Only a line the approved data can make is stored (src/lib/islands.ts validEntry): a choice from the
// stop's list, and a first name at stop 1 only. No other text is accepted. A stop's line can be added
// once the learner has reached Say it in every dialogue of the stop (its Use it step comes after Say it
// in the stop's last lesson). Nothing here is logged.

export const MAX_ISLAND_BODY_BYTES = 1024

export interface IslandDb {
  /** The learner's own island lines, by stop. */
  myIslandLines: () => Promise<IslandEntry[]>
  /** Adds or changes the learner's line for one stop. */
  saveIslandLine: (entry: IslandEntry) => Promise<void>
}

const FOREIGN_KEY_VIOLATION = '23503'
const UNIQUE_VIOLATION = '23505'

interface IslandRecord {
  stop_number: number
  choice: number | null
  first_name: string | null
}

function toEntry(row: IslandRecord): IslandEntry {
  return {
    stop: row.stop_number,
    choice: row.choice,
    ...(row.first_name === null ? {} : { name: row.first_name }),
  }
}

export function supabaseIslandDb(client: LearnerClient): IslandDb {
  return {
    async myIslandLines() {
      const { data, error } = await client
        .from('island_lines')
        .select('stop_number, choice, first_name')
        .order('stop_number')
      if (error) throw new DatabaseUnavailable()
      return data.map(toEntry)
    },

    async saveIslandLine(entry) {
      const values = { choice: entry.choice, first_name: entry.name ?? null }
      const update = async () => {
        const result = await client
          .from('island_lines')
          .update(values)
          .eq('stop_number', entry.stop)
          .select('stop_number')
        if (result.error) throw new DatabaseUnavailable()
        return result.data.length === 1
      }
      if (await update()) return
      const { error } = await client.from('island_lines').insert({ stop_number: entry.stop, ...values })
      if (!error) return
      // Two tabs adding the same stop at once: the other one won, so this one changes it.
      if (error.code === UNIQUE_VIOLATION && (await update())) return
      if (error.code === FOREIGN_KEY_VIOLATION) throw new AccountGone()
      throw new DatabaseUnavailable()
    },
  }
}

const REACHED_SAY = new Set(['say', 'keep', 'use'])

/**
 * The stops whose island line the learner may add or change: every stop with a line whose readable
 * dialogues (at least one) all have a session of the learner's that reached Say it or ended.
 */
export function openStops(dialogues: readonly ReadableDialogue[], sessions: readonly SessionRow[]): number[] {
  const reached = new Set(
    sessions.flatMap((s) =>
      s.dialogueId !== null && (s.endedAt !== null || (s.step !== null && REACHED_SAY.has(s.step)))
        ? [s.dialogueId]
        : [],
    ),
  )
  return ISLAND_STOPS.flatMap((stop) => {
    const mine = dialogues.filter((d) => d.stopNumber === stop.stop)
    return mine.length > 0 && mine.every((d) => reached.has(d.id)) ? [stop.stop] : []
  })
}

/**
 * The stop whose island step a session ends with: the session's dialogue is the last readable
 * dialogue of a road stop that has an island line. Undefined otherwise.
 */
export function islandStopFor(
  dialogue: ReadableDialogue,
  dialogues: readonly ReadableDialogue[],
): number | undefined {
  const stop = dialogue.stopNumber
  if (stop === null || stop === undefined || !islandStop(stop)) return undefined
  const last = Math.max(...dialogues.filter((d) => d.stopNumber === stop).map((d) => d.position))
  return dialogue.position === last ? stop : undefined
}

/** The body of POST /api/island, or null when it is not one the approved data can make. */
export function parseIslandEntry(body: string): IslandEntry | null {
  let parsed: unknown
  try {
    parsed = JSON.parse(body)
  } catch {
    return null
  }
  if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) return null
  const { stop, choice, name, ...rest } = parsed as Record<string, unknown>
  if (Object.keys(rest).length > 0) return null
  if (typeof stop !== 'number' || !Number.isInteger(stop)) return null
  if (choice !== null && (typeof choice !== 'number' || !Number.isInteger(choice))) return null
  let cleaned: string | undefined
  if (name !== undefined) {
    if (typeof name !== 'string') return null
    cleaned = cleanName(name) ?? undefined
    if (cleaned === undefined) return null
  }
  const entry: IslandEntry = { stop, choice, ...(cleaned === undefined ? {} : { name: cleaned }) }
  return validEntry(entry) ? entry : null
}

export interface IslandKit {
  signedIn: (
    request: Request,
  ) => Promise<
    { context: LearnerContext; refused: null } | { context: LearnerContext | null; refused: Response }
  >
  islandDb: (context: LearnerContext) => IslandDb
  learnerDb: (context: LearnerContext) => LearnerDb
}

async function readIsland(request: Request, kit: IslandKit): Promise<Response> {
  const refusedMethod = await refuseNonGet(request)
  if (refusedMethod) return refusedMethod
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  try {
    const learner = kit.learnerDb(context)
    const [lines, dialogues, sessions] = await Promise.all([
      kit.islandDb(context).myIslandLines(),
      learner.readableDialogues(),
      learner.mySessions(),
    ])
    // A row the approved data cannot make (a list changed since) is left out, never shown.
    const answer: IslandAnswer = { lines: lines.filter(validEntry), open: openStops(dialogues, sessions) }
    return withCookies(json(answer), context.setCookies())
  } catch {
    return withCookies(json({ error: 'not_available' }, 503), context.setCookies())
  }
}

async function saveIsland(request: Request, kit: IslandKit): Promise<Response> {
  const write = await refuseUnsafeWrite(request, MAX_ISLAND_BODY_BYTES)
  if (write.refused) return write.refused
  const entry = parseIslandEntry(write.body)
  if (!entry) return json({ error: 'bad_request' }, 400)
  const { context, refused } = await kit.signedIn(request)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const learner = kit.learnerDb(context)
    const [dialogues, sessions] = await Promise.all([learner.readableDialogues(), learner.mySessions()])
    if (!openStops(dialogues, sessions).includes(entry.stop)) return done({ error: 'stop_not_reached' }, 409)
    await kit.islandDb(context).saveIslandLine(entry)
    return done({ saved: true })
  } catch (error) {
    if (error instanceof AccountGone) {
      context.clearCookies()
      return withCookies(json({ error: 'session_ended' }, 401), context.setCookies())
    }
    return done({ error: 'not_available' }, 503)
  }
}

/** GET or POST /api/island. */
export function islandRoute(request: Request, kit: IslandKit): Promise<Response> {
  return request.method === 'POST' ? saveIsland(request, kit) : readIsland(request, kit)
}
