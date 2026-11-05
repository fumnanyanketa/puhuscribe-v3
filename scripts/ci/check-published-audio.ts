// Audio exists only for approved lines (job 7-content-pipeline, "Done when" 17).
//
// The app serves each published line's audio from public/audio/<key>, at
// /audio/<key>. A key is <dialogue-slug>/<line>-<register>-<first 12
// characters of the file's SHA-256>.mp3 and appears only in a publish
// migration (supabase/migrations/*_publish_*.sql), which approves the line in
// the same step. This check finds:
//   - a file under public/audio/ that no publish migration names,
//   - a file whose SHA-256 does not start with the 12 characters in its name,
//   - a published key with no file.
// tests/content-audio.test.ts runs it on the repository on every pull request.
//
// Word clips (job word-audio) live apart, at public/audio/words/<key>.mp3, where
// the key is the 64 hex request hash of the voice and the word's text. They are
// approved in content/approvals/part-<n>-words.json, not by a migration. When
// the approvals folder and the clip source folder are given, this check also
// finds:
//   - a word clip no owner approval lists,
//   - a word clip whose bytes differ from content/word-audio/<key>.mp3,
//   - an approved word key with no file.
// Without them every file under words/ fails, so nothing is served unapproved.
//
// Island clips (fast route "islands") live at public/audio/islands/<key>.mp3,
// where the key is the same 64 hex request hash. They are approved through
// src/lib/islands-data.json: its keys count only when the data was made from
// the islands.md the owner approved (its source_sha256 equals the SHA-256 in
// content/approvals/islands.json), as src/lib/islands.ts also requires. When the
// island data file and its clip source folder are given, this check finds:
//   - an island clip the approved island data does not list,
//   - an island clip whose bytes differ from content/island-audio/<key>.mp3,
//   - an approved island key with no file.
// Without them every file under islands/ fails.
//
// Aleksi's greeting (fast route aleksi-intro, 4 November 2026) lives at
// public/audio/aleksi/greeting-<12 hex>.mp3, read by the male voice Harri. It is
// approved only by content/approvals/aleksi-greeting.json, which the manager
// adds on the owner's own written line: {"format":
// "puhuscribe-owner-approval-aleksi-greeting-1", "approval": "<the owner's line>",
// "date": "YYYY-MM-DD", "file": "aleksi/greeting-<12 hex>.mp3", "sha256": "<64 hex>"}.
// This check finds:
//   - a file under aleksi/ that the approval does not name, or no approval at all,
//   - a greeting whose SHA-256 differs from the approved one,
//   - an approved greeting with no file.
//
// Aleksi's other intro clip (fast route intro-logo, 5 November 2026), his journey line, lives at
// public/audio/aleksi/journey-<12 hex>.mp3. He says the spoken form only (owner, 5 November 2026), so there
// is no clip of the written greeting: a file such as aleksi/greeting-written-<12 hex>.mp3 is refused like any
// other unapproved file under aleksi/. The journey clip is approved only by content/approvals/aleksi-intro.json,
// which the manager adds on the owner's own written line: {"format": "puhuscribe-owner-approval-aleksi-intro-1",
// "approval": "<the owner's line>", "date": "YYYY-MM-DD", "clips": [{"file": "aleksi/journey-<12 hex>.mp3",
// "sha256": "<64 hex>"}]}. This check finds an intro clip the approval does not name, one whose SHA-256
// differs, and an approved intro clip with no file.
import { createHash } from 'node:crypto'
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join, relative } from 'node:path'

const WORD_FILE = /^words\/([0-9a-f]{64})\.mp3$/
const ISLAND_FILE = /^islands\/([0-9a-f]{64})\.mp3$/
const WORD_KEY = /^[0-9a-f]{64}$/
const GREETING_FILE = /^aleksi\/greeting-[0-9a-f]{12}\.mp3$/
const INTRO_FILE = /^aleksi\/journey-[0-9a-f]{12}\.mp3$/

/** Aleksi's other intro clips the owner approved, file to SHA-256; none without a complete approval. */
export function approvedIntroClips(approvalsDir: string | undefined): Map<string, string> {
  const clips = new Map<string, string>()
  if (!approvalsDir) return clips
  const path = join(approvalsDir, 'aleksi-intro.json')
  if (!existsSync(path)) return clips
  const approval = JSON.parse(readFileSync(path, 'utf8')) as Record<string, unknown>
  const { format, approval: line, date, clips: listed } = approval
  if (format !== 'puhuscribe-owner-approval-aleksi-intro-1') return clips
  if (typeof line !== 'string' || line.trim() === '') return clips
  if (typeof date !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(date)) return clips
  if (!Array.isArray(listed)) return clips
  for (const clip of listed as unknown[]) {
    if (typeof clip !== 'object' || clip === null) continue
    const { file, sha256 } = clip as Record<string, unknown>
    if (
      typeof file === 'string' &&
      INTRO_FILE.test(file) &&
      typeof sha256 === 'string' &&
      WORD_KEY.test(sha256)
    )
      clips.set(file, sha256)
  }
  return clips
}

/** The greeting clip the owner approved, with its SHA-256, or null without a complete approval. */
export function approvedGreeting(approvalsDir: string | undefined): { file: string; sha256: string } | null {
  if (!approvalsDir) return null
  const path = join(approvalsDir, 'aleksi-greeting.json')
  if (!existsSync(path)) return null
  const approval = JSON.parse(readFileSync(path, 'utf8')) as Record<string, unknown>
  const { format, approval: line, date, file, sha256 } = approval
  if (format !== 'puhuscribe-owner-approval-aleksi-greeting-1') return null
  if (typeof line !== 'string' || line.trim() === '') return null
  if (typeof date !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(date)) return null
  if (typeof file !== 'string' || !GREETING_FILE.test(file)) return null
  if (typeof sha256 !== 'string' || !WORD_KEY.test(sha256)) return null
  return { file, sha256 }
}

/** The word clip keys the owner approved, from every content/approvals/part-<n>-words.json. */
export function approvedWordKeys(approvalsDir: string | undefined): Set<string> {
  const keys = new Set<string>()
  if (!approvalsDir || !existsSync(approvalsDir)) return keys
  for (const name of readdirSync(approvalsDir)) {
    if (!/^part-[1-6]-words\.json$/.test(name)) continue
    const approval = JSON.parse(readFileSync(join(approvalsDir, name), 'utf8')) as { keys?: unknown }
    if (!Array.isArray(approval.keys)) continue
    for (const key of approval.keys as unknown[])
      if (typeof key === 'string' && WORD_KEY.test(key)) keys.add(key)
  }
  return keys
}

interface IslandData {
  format?: unknown
  source_sha256?: unknown
  stops?: { audio?: { spoken?: unknown; written?: unknown }[] }[]
  closing?: { audio?: { spoken?: unknown; written?: unknown } }
}

/**
 * The island clip keys of the island data file, or none when the data was not
 * made from the islands.md the owner approved (content/approvals/islands.json).
 */
export function approvedIslandKeys(
  approvalsDir: string | undefined,
  dataPath: string | undefined,
): Set<string> {
  const keys = new Set<string>()
  if (!approvalsDir || !dataPath) return keys
  const approvalPath = join(approvalsDir, 'islands.json')
  if (!existsSync(approvalPath) || !existsSync(dataPath)) return keys
  const approval = JSON.parse(readFileSync(approvalPath, 'utf8')) as { format?: unknown; sha256?: unknown }
  const data = JSON.parse(readFileSync(dataPath, 'utf8')) as IslandData
  if (approval.format !== 'puhuscribe-owner-approval-islands-1' || typeof approval.sha256 !== 'string')
    return keys
  if (data.format !== 'puhuscribe-islands-1' || data.source_sha256 !== approval.sha256) return keys
  const pairs = [...(data.stops ?? []).flatMap((stop) => stop.audio ?? []), data.closing?.audio ?? {}]
  for (const pair of pairs)
    for (const key of [pair.spoken, pair.written])
      if (typeof key === 'string' && WORD_KEY.test(key)) keys.add(key)
  return keys
}

export const AUDIO_KEY = /'([a-z0-9]+(?:-[a-z0-9]+)*\/[1-9][0-9]*-(?:puhe|kirja)-([0-9a-f]{12})\.mp3)'/g

export function publishedKeys(migrationsDir: string): Set<string> {
  const keys = new Set<string>()
  if (!existsSync(migrationsDir)) return keys
  for (const name of readdirSync(migrationsDir)) {
    if (!/_publish_[a-z0-9_]+\.sql$/.test(name)) continue
    const sql = readFileSync(join(migrationsDir, name), 'utf8')
    for (const match of sql.matchAll(AUDIO_KEY)) keys.add(match[1] ?? '')
  }
  return keys
}

function filesUnder(dir: string): string[] {
  if (!existsSync(dir)) return []
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name)
    return statSync(path).isDirectory() ? filesUnder(path) : [path]
  })
}

export function checkPublishedAudio(
  audioDir: string,
  migrationsDir: string,
  approvalsDir?: string,
  wordSourceDir?: string,
  islands?: { data: string; sourceDir: string },
): string[] {
  const problems: string[] = []
  const keys = publishedKeys(migrationsDir)
  const wordKeys = approvedWordKeys(approvalsDir)
  const islandKeys = approvedIslandKeys(approvalsDir, islands?.data)
  const greeting = approvedGreeting(approvalsDir)
  const introClips = approvedIntroClips(approvalsDir)
  const foundIntro = new Set<string>()
  let foundGreeting = false
  const found = new Set<string>()
  const foundWords = new Set<string>()
  const foundIslands = new Set<string>()
  for (const path of filesUnder(audioDir)) {
    const key = relative(audioDir, path).split('\\').join('/')
    if (INTRO_FILE.test(key)) {
      const approvedHash = introClips.get(key)
      if (!approvedHash) {
        problems.push(`${key} is not an intro clip the owner approved (content/approvals/aleksi-intro.json)`)
        continue
      }
      foundIntro.add(key)
      if (createHash('sha256').update(readFileSync(path)).digest('hex') !== approvedHash)
        problems.push(`${key} differs from the approved intro clip (its SHA-256 differs)`)
      continue
    }
    if (key.startsWith('aleksi/')) {
      if (key !== greeting?.file) {
        problems.push(
          `${key} is not the greeting the owner approved (content/approvals/aleksi-greeting.json)`,
        )
        continue
      }
      foundGreeting = true
      if (createHash('sha256').update(readFileSync(path)).digest('hex') !== greeting.sha256)
        problems.push(`${key} differs from the approved greeting (its SHA-256 differs)`)
      continue
    }
    if (key.startsWith('islands/')) {
      const islandKey = ISLAND_FILE.exec(key)?.[1]
      if (!islandKey || !islandKeys.has(islandKey)) {
        problems.push(`${key} is not an island clip of the approved island lines`)
        continue
      }
      foundIslands.add(islandKey)
      const source = islands ? join(islands.sourceDir, `${islandKey}.mp3`) : ''
      if (!source || !existsSync(source) || !readFileSync(source).equals(readFileSync(path)))
        problems.push(`${key} differs from its clip in content/island-audio/`)
      continue
    }
    if (key.startsWith('words/')) {
      const wordKey = WORD_FILE.exec(key)?.[1]
      if (!wordKey || !wordKeys.has(wordKey)) {
        problems.push(`${key} is not a word clip the owner approved`)
        continue
      }
      foundWords.add(wordKey)
      const source = wordSourceDir ? join(wordSourceDir, `${wordKey}.mp3`) : ''
      if (!source || !existsSync(source) || !readFileSync(source).equals(readFileSync(path)))
        problems.push(`${key} differs from its clip in content/word-audio/`)
      continue
    }
    found.add(key)
    if (!keys.has(key)) {
      problems.push(`${key} is not the audio of a line any publish migration approves`)
      continue
    }
    const digest = createHash('sha256').update(readFileSync(path)).digest('hex')
    const named = /-([0-9a-f]{12})\.mp3$/.exec(key)?.[1]
    if (!named || !digest.startsWith(named))
      problems.push(`${key} does not match its name (its SHA-256 differs)`)
  }
  for (const key of keys) {
    if (!found.has(key)) problems.push(`${key} is published but public/audio/${key} is missing`)
  }
  for (const key of wordKeys) {
    if (!foundWords.has(key)) problems.push(`words/${key}.mp3 is approved but its file is missing`)
  }
  for (const key of islandKeys) {
    if (!foundIslands.has(key)) problems.push(`islands/${key}.mp3 is approved but its file is missing`)
  }
  if (greeting && !foundGreeting) problems.push(`${greeting.file} is approved but its file is missing`)
  for (const file of introClips.keys()) {
    if (!foundIntro.has(file)) problems.push(`${file} is approved but its file is missing`)
  }
  return problems
}

if (import.meta.main) {
  const problems = checkPublishedAudio(
    'public/audio',
    'supabase/migrations',
    'content/approvals',
    'content/word-audio',
    { data: 'src/lib/islands-data.json', sourceDir: 'content/island-audio' },
  )
  for (const problem of problems) console.error(problem)
  if (problems.length === 0)
    console.log('Every published audio file matches its key and every key has its file.')
  process.exit(problems.length === 0 ? 0 : 1)
}
