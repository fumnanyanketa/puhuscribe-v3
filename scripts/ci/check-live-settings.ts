// Before the live workflow (.github/workflows/live.yml) touches anything, this
// checks that its settings point at the live Supabase project and not at the
// test project (job go-live). It catches a secret pasted into the wrong name.
//
// Read from the environment, never from a file:
//   LIVE_SUPABASE_URL   the live project's address (https://<ref>.supabase.co), required
//   LIVE_DB_URL         the live database connection string, optional; when set it must
//                       name the same project
//   TEST_SUPABASE_URL   the test project's address, required; the live one must differ
// Prints only which rule failed, never a value or a project ref.

const PROJECT_URL = /^https:\/\/([a-z0-9]{20})\.supabase\.co\/?$/

/** The project ref of a Supabase project address, or null when it is not one. */
export function projectRef(url: string | undefined): string | null {
  return PROJECT_URL.exec(url?.trim() ?? '')?.[1] ?? null
}

/**
 * True when the connection string is for this project: the session or
 * transaction pooler names the user postgres.<ref>, the direct connection the
 * host db.<ref>.supabase.co.
 */
export function dbUrlNamesProject(dbUrl: string, ref: string): boolean {
  let url: URL
  try {
    url = new URL(dbUrl.trim())
  } catch {
    return false
  }
  if (url.protocol !== 'postgresql:' && url.protocol !== 'postgres:') return false
  return decodeURIComponent(url.username) === `postgres.${ref}` || url.hostname === `db.${ref}.supabase.co`
}

export function checkLiveSettings(env: Record<string, string | undefined>): string[] {
  const problems: string[] = []
  const live = projectRef(env.LIVE_SUPABASE_URL)
  const test = projectRef(env.TEST_SUPABASE_URL)
  if (live === null)
    problems.push(
      'The live project address (SUPABASE_LIVE_URL) is missing or is not https://<ref>.supabase.co.',
    )
  if (test === null)
    problems.push('The test project address (SUPABASE_TEST_URL) is missing, so the two cannot be told apart.')
  if (live !== null && test !== null && live === test)
    problems.push('The live project address is the test project. Nothing was changed.')
  const dbUrl = env.LIVE_DB_URL
  if (dbUrl !== undefined && live !== null) {
    if (dbUrl.trim() === '')
      problems.push('The live database connection string (SUPABASE_LIVE_DB_URL) is empty.')
    else if (!dbUrlNamesProject(dbUrl, live))
      problems.push(
        'The live database connection string does not name the same project as SUPABASE_LIVE_URL.',
      )
  }
  return problems
}

if (import.meta.main) {
  const problems = checkLiveSettings(process.env)
  for (const problem of problems) console.error(problem)
  if (problems.length === 0)
    console.log('The live settings name the live project, and it is not the test project.')
  process.exit(problems.length === 0 ? 0 : 1)
}
