// Which checks a change needs (owner's decision of 3 November 2026: fast
// checks on every change, the full run once, by hand, before the MVP launch).
// The database tests (pgTAP on a throwaway local Supabase) run only when the
// change touches a file they depend on. Every other check runs every time.
//
// In the workflow:
//   git diff --name-only --no-renames "$BASE...HEAD" | node scripts/ci/checks-plan.ts database-tests
//     -> prints true or false
import { existsSync, readFileSync } from 'node:fs'
import { basename } from 'node:path'

// Files the database job reads or checks, besides everything under supabase/.
const DATABASE_FILES = new Set([
  // The job checks this file matches the migrated database.
  'src/lib/database.types.ts',
  // The Supabase CLI version is pinned here; a new version can change the
  // migrated database and the generated types.
  'package.json',
  'package-lock.json',
  // A change to the workflow itself runs the job it changes.
  '.github/workflows/checks.yml',
])

// The job loads scripts/v2-import/fixtures/check-load-twice.sql.
const DATABASE_FOLDERS = ['supabase/', 'scripts/v2-import/']

const GENERATORS = 'scripts/generate/'

// A Python file in scripts/generate/ writes SQL tests or migrations when its
// text names supabase/tests or supabase/migrations (as a path string or with
// pathlib), or a .sql file. On 3 November 2026 that is fixture_outputs.py,
// pipeline.py, publish.py, road_fix.py, road_fix_pgtap.py, road_forms_pgtap.py,
// road_pgtap.py, road_publish.py and road_sql.py.
export const WRITES_SQL = /supabase.{0,8}(tests|migrations)|\.sql\b/

export type ReadFile = (path: string) => string | undefined

const readIfThere: ReadFile = (path) => (existsSync(path) ? readFileSync(path, 'utf8') : undefined)

export function writesSql(path: string, read: ReadFile = readIfThere): boolean {
  if (!path.startsWith(GENERATORS) || !path.endsWith('.py')) return false
  if (basename(path).startsWith('test_')) return false
  const text = read(path)
  // A deleted generator may have written SQL; run the database tests.
  if (text === undefined) return true
  return WRITES_SQL.test(text)
}

export function needsDatabaseTests(paths: string[], read: ReadFile = readIfThere): boolean {
  return paths
    .map((path) => path.trim())
    .filter(Boolean)
    .some(
      (path) =>
        DATABASE_FILES.has(path) ||
        DATABASE_FOLDERS.some((folder) => path.startsWith(folder)) ||
        writesSql(path, read),
    )
}

if (import.meta.main) {
  if (process.argv[2] === 'database-tests') {
    console.log(String(needsDatabaseTests(readFileSync(0, 'utf8').split(/\r?\n/))))
  } else {
    console.error('Usage: checks-plan.ts database-tests')
    process.exit(1)
  }
}
