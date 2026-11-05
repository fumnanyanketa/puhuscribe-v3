// The live workflow's "content" task (job go-live): is every migration in the
// repository, each publish migration included, in the live project's
// migration history? The approved dialogues reach a database only through
// their publish migrations, so this is the proof that the approved content is
// live.
//
// Usage: supabase migration list --db-url "$SUPABASE_DB_URL" --output-format json 2>&1 | node scripts/ci/check-live-migrations.ts
//
// What the Supabase CLI prints (read from its source, github.com/supabase/cli,
// tags v2.121.0 and v3.0.0, apps/cli/src/commands/migration/list/ and
// apps/cli/src/shared/output/output.layer.ts):
// - With --output-format json, one JSON line on standard output. On success
//   {"migrations":[{"local":"<version or empty>","remote":"<version or empty>","time":"..."}],
//   "message":"Migrations listed"} (3.0.0 adds "target"). On failure
//   {"_tag":"Error","error":{"code":"...","message":"...","suggestion":"..."}} (3.0.0 adds
//   "target"). Notices such as "Connecting to remote database..." go to standard error.
// - Without it, a text table (Local | Remote | Time (UTC)) whose cells are wrapped in
//   backticks, an empty cell being "` `". The live runs of 5 November 2026 read 0 migrations
//   because the backticks were left on. The table is still read, as a fallback.
//
// The history holds migration versions, never learner data. The check prints counts,
// migration file names and, if the CLI failed, the error's code and its message with every
// URL, user, password and host removed. It reads SUPABASE_DB_URL, which the step already
// holds for the CLI, only to remove that URL's own parts from such a message.
import { readdirSync, readFileSync } from 'node:fs'

const VERSION = /^\d{14}$/

export interface CliError {
  code: string
  message: string
}

export interface Listing {
  versions: Set<string>
  error?: CliError
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}

function parseJsonLine(line: string): unknown {
  const trimmed = line.trim()
  if (!trimmed.startsWith('{')) return undefined
  try {
    return JSON.parse(trimmed) as unknown
  } catch {
    return undefined
  }
}

/** The remote versions and any error in the output of `supabase migration list`. */
export function readListing(listing: string): Listing {
  const lines = listing.split(/\r?\n/)
  const fromJson = new Set<string>()
  let sawJson = false
  for (const line of lines) {
    const value = parseJsonLine(line)
    if (!isRecord(value)) continue
    if (value._tag === 'Error' && isRecord(value.error)) {
      const { code, message } = value.error
      return {
        versions: new Set(),
        error: {
          code: typeof code === 'string' ? code : '',
          message: typeof message === 'string' ? message : '',
        },
      }
    }
    if (!Array.isArray(value.migrations)) continue
    sawJson = true
    for (const row of value.migrations as unknown[]) {
      if (isRecord(row) && typeof row.remote === 'string' && VERSION.test(row.remote))
        fromJson.add(row.remote)
    }
  }
  if (sawJson) return { versions: fromJson }

  // Fallback: the text table, or one version per line.
  const found = new Set<string>()
  for (const line of lines) {
    if (VERSION.test(line.trim())) {
      found.add(line.trim())
      continue
    }
    const cells = line.split(/[|│]/).map((cell) => cell.trim().replace(/^`|`$/g, '').trim())
    if (cells.length < 2) continue
    const remote = cells[1] ?? ''
    if (VERSION.test(remote)) found.add(remote)
  }
  return { versions: found }
}

/** The versions in the Remote column of `supabase migration list`, or one version per line. */
export function remoteVersions(listing: string): Set<string> {
  return readListing(listing).versions
}

/** The parts of a database URL never to print: user, password, host, and their long labels (the project ref). */
function urlParts(dbUrl: string): string[] {
  if (!dbUrl) return []
  let url: URL
  try {
    url = new URL(dbUrl)
  } catch {
    return []
  }
  const decode = (part: string) => {
    try {
      return decodeURIComponent(part)
    } catch {
      return part
    }
  }
  const whole = [url.username, url.password, url.hostname].flatMap((part) => [part, decode(part)])
  const labels = [url.username, url.hostname]
    .flatMap((part) => decode(part).split(/[.:]/))
    .filter((label) => label.length >= 12)
  return [...new Set([...whole, ...labels])]
    .filter((part) => part.length >= 3)
    .sort((a, b) => b.length - a.length)
}

/** The message with every URL, user, password, host and project ref removed. */
export function withoutConnectionDetails(message: string, dbUrl = ''): string {
  let text = message
  for (const part of urlParts(dbUrl)) text = text.split(part).join('<removed>')
  return (
    text
      // Any URL, such as a postgresql:// connection string.
      .replace(/\b[a-z][a-z0-9+.-]*:\/\/[^\s`'"]+/gi, '<url>')
      // key=value connection settings, as in `host=... user=... database=...`.
      .replace(
        /\b(host|hostaddr|user|username|password|passfile|dbname|database|port|role)=(?:"[^"]*"|'[^']*'|[^\s`'",;)]+)/gi,
        '$1=<removed>',
      )
      // for user "..." / role '...'
      .replace(/\b(user|role|database|host)\s+(?:"[^"]*"|'[^']*')/gi, '$1 <removed>')
      // IPv6 in brackets, bare IPv6, IPv4, each with an optional port.
      .replace(/\[[0-9a-f:.]+\](?::\d+)?/gi, '<host>')
      .replace(/\b(?:[0-9a-f]{1,4}:){2,7}(?::?[0-9a-f]{1,4})?\b/gi, '<host>')
      .replace(/\b\d{1,3}(?:\.\d{1,3}){3}(?::\d+)?\b/g, '<host>')
      // Host names such as db.<ref>.supabase.co or aws-0-eu-north-1.pooler.supabase.com.
      .replace(/\b(?:[a-z0-9-]+\.)+[a-z]{2,}(?::\d+)?\b/gi, '<host>')
      // A Supabase project ref: 20 lowercase letters.
      .replace(/\b[a-z]{20}\b/g, '<removed>')
      .slice(0, 600)
  )
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
  dbUrl = '',
): { problems: string[]; summary: string } {
  const { versions: remote, error } = readListing(listing)
  if (error) {
    const code = /^[A-Za-z][A-Za-z0-9_]{0,63}$/.test(error.code) ? error.code : 'unknown code'
    const message = error.message ? withoutConnectionDetails(error.message, dbUrl) : 'no message.'
    return {
      problems: [`The Supabase CLI could not list the live migrations (${code}): ${message}`],
      summary: 'The migration list could not be read.',
    }
  }
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
  const { problems, summary } = checkLiveMigrations(
    readFileSync(0, 'utf8'),
    'supabase/migrations',
    process.env.SUPABASE_DB_URL ?? '',
  )
  console.log(summary)
  for (const problem of problems) console.error(problem)
  if (problems.length === 0)
    console.log('Every migration in the repository, and so every approved dialogue, is live.')
  process.exit(problems.length === 0 ? 0 : 1)
}
