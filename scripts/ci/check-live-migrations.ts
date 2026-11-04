// The live workflow's "content" task (job go-live): is every migration in the
// repository, each publish migration included, in the live project's
// migration history? The approved dialogues reach a database only through
// their publish migrations, so this is the proof that the approved content is
// live.
//
// Usage: npx supabase migration list --db-url "$SUPABASE_DB_URL" | node scripts/ci/check-live-migrations.ts
// It reads the table the Supabase CLI prints (Local | Remote | Time) and looks
// only at the Remote column. That history holds migration versions, never
// learner data. It prints counts and migration file names, nothing else.
import { readdirSync, readFileSync } from 'node:fs'

const VERSION = /^\d{14}$/

/** The versions in the Remote column of `supabase migration list`. */
export function remoteVersions(listing: string): Set<string> {
  const found = new Set<string>()
  for (const line of listing.split(/\r?\n/)) {
    const cells = line.split('|').map((cell) => cell.trim())
    if (cells.length < 2) continue
    const remote = cells[1] ?? ''
    if (VERSION.test(remote)) found.add(remote)
  }
  return found
}

/** The migration files of the repository, by version. */
export function localMigrations(migrationsDir: string): Map<string, string> {
  const found = new Map<string, string>()
  for (const name of readdirSync(migrationsDir).sort()) {
    const version = /^(\d{14})_.+\.sql$/.exec(name)?.[1]
    if (version) found.set(version, name)
  }
  return found
}

export function checkLiveMigrations(
  listing: string,
  migrationsDir: string,
): { problems: string[]; summary: string } {
  const remote = remoteVersions(listing)
  const local = localMigrations(migrationsDir)
  const problems: string[] = []
  if (remote.size === 0) problems.push('The migration list shows no migration in the live project.')
  for (const [version, name] of local) {
    if (!remote.has(version))
      problems.push(`${name} is not in the live project yet. Run the "migrations" task.`)
  }
  for (const version of remote) {
    if (!local.has(version))
      problems.push(
        `The live project has migration ${version}, which is not in this branch's supabase/migrations/.`,
      )
  }
  const publish = [...local.values()].filter((name) => name.includes('_publish_'))
  const live = publish.filter((name) => remote.has(name.slice(0, 14)))
  return {
    problems,
    summary: `${String(remote.size)} migrations in the live project; ${String(live.length)} of the ${String(publish.length)} publish migrations are among them.`,
  }
}

if (import.meta.main) {
  const { problems, summary } = checkLiveMigrations(readFileSync(0, 'utf8'), 'supabase/migrations')
  console.log(summary)
  for (const problem of problems) console.error(problem)
  if (problems.length === 0)
    console.log('Every migration in the repository, and so every approved dialogue, is live.')
  process.exit(problems.length === 0 ? 0 : 1)
}
