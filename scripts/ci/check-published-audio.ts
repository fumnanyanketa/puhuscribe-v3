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
import { createHash } from 'node:crypto'
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join, relative } from 'node:path'

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

export function checkPublishedAudio(audioDir: string, migrationsDir: string): string[] {
  const problems: string[] = []
  const keys = publishedKeys(migrationsDir)
  const found = new Set<string>()
  for (const path of filesUnder(audioDir)) {
    const key = relative(audioDir, path).split('\\').join('/')
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
  return problems
}

if (import.meta.main) {
  const problems = checkPublishedAudio('public/audio', 'supabase/migrations')
  for (const problem of problems) console.error(problem)
  if (problems.length === 0)
    console.log('Every published audio file matches its key and every key has its file.')
  process.exit(problems.length === 0 ? 0 : 1)
}
