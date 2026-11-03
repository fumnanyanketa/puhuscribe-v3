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
import { createHash } from 'node:crypto'
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join, relative } from 'node:path'

const WORD_FILE = /^words\/([0-9a-f]{64})\.mp3$/
const WORD_KEY = /^[0-9a-f]{64}$/

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
): string[] {
  const problems: string[] = []
  const keys = publishedKeys(migrationsDir)
  const wordKeys = approvedWordKeys(approvalsDir)
  const found = new Set<string>()
  const foundWords = new Set<string>()
  for (const path of filesUnder(audioDir)) {
    const key = relative(audioDir, path).split('\\').join('/')
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
  return problems
}

if (import.meta.main) {
  const problems = checkPublishedAudio(
    'public/audio',
    'supabase/migrations',
    'content/approvals',
    'content/word-audio',
  )
  for (const problem of problems) console.error(problem)
  if (problems.length === 0)
    console.log('Every published audio file matches its key and every key has its file.')
  process.exit(problems.length === 0 ? 0 : 1)
}
