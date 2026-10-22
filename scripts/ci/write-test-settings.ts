// Writes the Supabase settings for the Worker into a file on the GitHub
// runner, so values never pass through a shell command line.
//   node scripts/ci/write-test-settings.ts env  <path>   -> .env format (for the local Worker)
//   node scripts/ci/write-test-settings.ts json <path>   -> JSON (for wrangler --secrets-file)
// The values come from SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY in the
// environment (the TEST project's, from GitHub secrets), or, with
// --from-supabase-status, from `supabase status -o env` piped in on stdin (the
// throwaway local Supabase in the pull request browser check, which holds no
// secret; see scripts/ci/supabase-status.ts).
// Prints only the names and the path, never a value.
import { readFileSync, writeFileSync } from 'node:fs'
import { localSettingsFromStatus } from './supabase-status.ts'

const NAMES = ['SUPABASE_URL', 'SUPABASE_PUBLISHABLE_KEY'] as const

const [format, path, source, ...rest] = process.argv.slice(2)
if (
  (format !== 'env' && format !== 'json') ||
  !path ||
  (source !== undefined && source !== '--from-supabase-status') ||
  rest.length > 0
) {
  console.error('Usage: write-test-settings.ts env|json <path> [--from-supabase-status]')
  process.exit(1)
}

function fromEnvironment(): Record<string, string> {
  const values: Record<string, string> = {}
  for (const name of NAMES) {
    const value = process.env[name]?.trim()
    if (!value) {
      console.error(`${name} is not set.`)
      process.exit(1)
    }
    values[name] = value
  }
  return values
}

function fromSupabaseStatus(): Record<string, string> {
  try {
    return { ...localSettingsFromStatus(readFileSync(0, 'utf8')) }
  } catch (error) {
    console.error((error as Error).message)
    process.exit(1)
  }
}

const values = source === '--from-supabase-status' ? fromSupabaseStatus() : fromEnvironment()

const content =
  format === 'json'
    ? JSON.stringify(values)
    : Object.entries(values)
        .map(([name, value]) => `${name}=${value}\n`)
        .join('')
writeFileSync(path, content, { mode: 0o600 })
console.log(`Wrote ${NAMES.join(', ')} to ${path}`)
