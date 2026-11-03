import approval from '../../content/approvals/islands.json' with { type: 'json' }
import data from './islands-data.json' with { type: 'json' }

// Language islands (fast route "islands", 3 November 2026): one personal line per stop, from the
// owner-approved patterns and lists in content/islands/islands.md. scripts/generate/islands.py turns
// that file into islands-data.json, and only when its SHA-256 is the approved one. This module checks
// the same thing again: when the data file names another file than the approved one, no island loads
// at all (ISLAND_STOPS is empty), so an unapproved line can never be shown. Shared by the app and the
// Worker, so both read the same lines and lists.
//
// A learner's island is one entry per stop: the number of the choice they picked from the stop's list
// (null for the lines that have no list) and, at stop 1, the first name they typed. A name is shown as
// typed and never inflected, and it is never voiced: the stop 1 name sentence has no clip.

export interface IslandChoice {
  spoken: string
  written: string
  english: string
}

export interface IslandStop {
  stop: number
  title: string
  /** The patterns, with {gap} where the choice goes and {name} where the learner's name goes. */
  spoken: string
  written: string
  english: string
  /** The fill-in list, or null for a line with no gap. */
  list: string | null
  /** True at stop 1: the learner types a first name. */
  name: boolean
  /** True when the learner may skip the line (stop 21, children). */
  optional: boolean
  /** The clip keys of the voiced part, one per choice of the list (one for a line with no list). */
  audio: { spoken: string; written: string }[]
}

export interface IslandEntry {
  stop: number
  choice: number | null
  /** Stop 1 only. */
  name?: string
}

interface IslandData {
  format: string
  source_sha256: string
  name_max: number
  stops: IslandStop[]
  lists: Record<string, IslandChoice[]>
  closing: IslandChoice & { audio: { spoken: string; written: string } }
}

const DATA = data as IslandData

/** True only when the data file was made from the approved islands.md. */
export const ISLANDS_APPROVED =
  DATA.format === 'puhuscribe-islands-1' && DATA.source_sha256 === approval.sha256

export const ISLAND_STOPS: readonly IslandStop[] = ISLANDS_APPROVED ? DATA.stops : []

export const NAME_MAX = DATA.name_max

/** The question back at the end of the island. */
export const CLOSING = DATA.closing

export function islandStop(stop: number): IslandStop | undefined {
  return ISLAND_STOPS.find((item) => item.stop === stop)
}

export function choicesOf(stop: IslandStop): readonly IslandChoice[] {
  return stop.list ? (DATA.lists[stop.list] ?? []) : []
}

/** The address of an island clip. Published by scripts/generate/islands.py publish-islands. */
export function islandAudio(key: string): string {
  return `/audio/islands/${key}.mp3`
}

const NAME_SHAPE = /^\p{L}[\p{L}\p{M}]*(?:[ '’-]\p{L}[\p{L}\p{M}]*)*$/u

/**
 * A first name as it is kept: trimmed, single spaces, letters with a space, hyphen or apostrophe
 * between them, at most NAME_MAX characters. Null when it is not a name of that shape. The database
 * keeps its own floor of the same rule (supabase/migrations/20261103120000_island_lines.sql).
 */
export function cleanName(raw: string): string | null {
  const name = raw.normalize('NFC').trim().replace(/\s+/g, ' ')
  if (name.length === 0 || name.length > NAME_MAX) return null
  return NAME_SHAPE.test(name) ? name : null
}

/** True when the entry is one the stop's line can make: a choice from its list and a name only at stop 1. */
export function validEntry(entry: IslandEntry): boolean {
  const stop = islandStop(entry.stop)
  if (!stop) return false
  const count = choicesOf(stop).length
  if (stop.list === null ? entry.choice !== null : entry.choice === null) return false
  if (
    entry.choice !== null &&
    (!Number.isInteger(entry.choice) || entry.choice < 0 || entry.choice >= count)
  ) {
    return false
  }
  if (stop.name) return typeof entry.name === 'string' && cleanName(entry.name) === entry.name
  return entry.name === undefined
}

/** One piece of a filled line: plain pattern text, or the learner's own part (a choice or the name). */
export interface LinePiece {
  text: string
  mine?: 'choice' | 'name'
}

export interface FilledLine {
  stop: number
  spoken: LinePiece[]
  written: LinePiece[]
  english: string
  /** The clips of the voiced part. At stop 1 they leave out the name sentence. */
  spokenAudio: string
  writtenAudio: string
}

const GAP = /\{([^{}]+)\}/g

function pieces(template: string, register: 'spoken' | 'written', choice: IslandChoice | null, name: string) {
  const out: LinePiece[] = []
  let at = 0
  for (const match of template.matchAll(GAP)) {
    const index = match.index
    if (index > at) out.push({ text: template.slice(at, index) })
    if (match[1] === 'name') out.push({ text: name, mine: 'name' })
    else if (choice)
      out.push({ text: register === 'spoken' ? choice.spoken : choice.written, mine: 'choice' })
    at = index + match[0].length
  }
  if (at < template.length) out.push({ text: template.slice(at) })
  return out
}

function english(template: string, choice: IslandChoice | null, name: string): string {
  return template.replace(GAP, (_, gap: string) => {
    if (gap === 'name') return name
    const word = choice?.english ?? ''
    // "{Time of day} suits me best.": a gap written with a capital starts the sentence.
    return /^[A-Z]/.test(gap) ? word.charAt(0).toUpperCase() + word.slice(1) : word
  })
}

/** The line a stop makes from a choice and a name, or null when the entry is not one it can make. */
export function fillLine(stop: IslandStop, choice: number | null, name = ''): FilledLine | null {
  const choices = choicesOf(stop)
  const picked = choice === null || choice < 0 ? null : (choices.at(choice) ?? null)
  if (stop.list !== null && picked === null) return null
  const audio = stop.audio.at(picked === null ? 0 : (choice ?? 0))
  if (!audio) return null
  return {
    stop: stop.stop,
    spoken: pieces(stop.spoken, 'spoken', picked, name),
    written: pieces(stop.written, 'written', picked, name),
    english: english(stop.english, picked, name),
    spokenAudio: islandAudio(audio.spoken),
    writtenAudio: islandAudio(audio.written),
  }
}

/** A line's pieces as one plain text. */
export function plainLine(line: readonly LinePiece[]): string {
  return line.map((piece) => piece.text).join('')
}

/** True when the line already ends with the island's question back (stop 36 does). */
export function endsWithClosing(line: FilledLine): boolean {
  return plainLine(line.spoken).trim().endsWith(CLOSING.spoken)
}
