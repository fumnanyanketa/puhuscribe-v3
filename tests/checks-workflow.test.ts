import { readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/2-smoke/spec.md that each test protects.
//
// The workflow file is read as text and split into its jobs, so these tests
// need no YAML package. They guard the order of the checks and where the test
// database password may appear.

const workflow = readFileSync('.github/workflows/checks.yml', 'utf8').replace(/\r\n/g, '\n')

// supabase/setup-cli v3.0.1, pinned to its commit so a moved tag cannot swap
// the program that receives the test database password.
const SETUP_CLI = 'supabase/setup-cli@45a513f8c64c0bc8e0e3dfe572b5c95be85f6359'

function jobs(text: string): Map<string, string> {
  const body = text.slice(text.indexOf('\njobs:\n') + '\njobs:\n'.length)
  const found = new Map<string, string>()
  let current: string | undefined
  let lines: string[] = []
  for (const line of body.split('\n')) {
    const start = /^ {2}([a-z0-9-]+):$/.exec(line)
    if (start?.[1]) {
      if (current) found.set(current, lines.join('\n'))
      current = start[1]
      lines = []
    } else {
      lines.push(line)
    }
  }
  if (current) found.set(current, lines.join('\n'))
  return found
}

const all = jobs(workflow)

function job(id: string): string {
  const text = all.get(id)
  if (text === undefined) throw new Error(`No job ${id} in checks.yml`)
  return text
}

// The job's one-line `if:` condition.
function ifLine(id: string): string {
  const match = /^ {4}if: (.+)$/m.exec(job(id))
  if (!match?.[1]) throw new Error(`No one-line if in job ${id}`)
  return match[1]
}

function needsOf(id: string): string[] {
  const match = /^ {4}needs: \[([^\]]*)\]$/m.exec(job(id))
  return match?.[1] ? match[1].split(',').map((name) => name.trim()) : []
}

// Lines that run commands: `run:` lines and the block lines under them.
function commands(id: string): string {
  const out: string[] = []
  let inRun = false
  for (const line of job(id).split('\n')) {
    const run = /^ {8}run: ?(.*)$/.exec(line)
    if (run) {
      out.push(run[1] ?? '')
      inRun = true
    } else if (inRun && /^ {10}/.test(line)) {
      out.push(line)
    } else {
      inRun = false
    }
  }
  return out.join('\n')
}

describe('database check', () => {
  it('[smoke 10] has a check named "Database tests (local Supabase, pgTAP)"', () => {
    expect(job('database')).toContain('    name: Database tests (local Supabase, pgTAP)\n')
  })

  it('[smoke 10] starts a throwaway local database, applies every migration and runs supabase test db', () => {
    const run = commands('database')
    expect(run).toMatch(/^supabase db start$/m)
    expect(run).toMatch(/^supabase test db$/m)
    expect(job('database')).toContain(`uses: ${SETUP_CLI} # v3.0.1`)
  })

  it('[smoke 10] uses no secret at all', () => {
    expect(job('database')).not.toMatch(/\bsecrets\.[A-Za-z_]/)
  })
})

describe('applying migrations to the test project', () => {
  const apply = job('apply-test-db')

  it('[smoke 11] is a check named "Apply database changes to the test project"', () => {
    expect(apply).toContain('    name: Apply database changes to the test project\n')
  })

  it('[smoke 11] runs only after the database tests passed', () => {
    expect(needsOf('apply-test-db')).toEqual(['database'])
  })

  it('[smoke 11] pushes migrations with the test connection string and then runs the security tests on the test project', () => {
    const run = commands('apply-test-db')
    expect(run).toContain('supabase db push --db-url "$SUPABASE_DB_URL"')
    expect(run).toContain('supabase test db --db-url "$SUPABASE_DB_URL"')
    expect(run.indexOf('supabase db push')).toBeLessThan(run.indexOf('supabase test db'))
  })

  it('[smoke 11] runs no npm ci and no project code', () => {
    const run = commands('apply-test-db')
    expect(run).not.toMatch(/\bnpm\b|\bnpx\b|\bnode\b|\byarn\b|\bpnpm\b|\bbun\b/)
    expect(apply).not.toContain('actions/setup-node')
    const usedActions = [...apply.matchAll(/uses: (\S+)/g)].map((m) => m[1])
    expect(usedActions).toEqual(['actions/checkout@v7', SETUP_CLI])
    expect(apply).toContain('persist-credentials: false')
  })

  it('[smoke 11] passes the test database password only to the steps that need it', () => {
    const secretLines = apply.split('\n').filter((line) => line.includes('SUPABASE_TEST_DB_URL }}'))
    expect(secretLines).toHaveLength(2)
    for (const line of secretLines) {
      expect(line).toBe('          SUPABASE_DB_URL: ${{ secrets.SUPABASE_TEST_DB_URL }}')
    }
    // No job-level env block that would hand it to every step.
    expect(apply).not.toMatch(/^ {4}env:/m)
  })

  it('[smoke 11] the test database password is used by no other job', () => {
    for (const [id, text] of all) {
      if (id === 'apply-test-db') continue
      expect(text, id).not.toContain('SUPABASE_TEST_DB_URL')
    }
    expect(workflow.slice(0, workflow.indexOf('\njobs:\n'))).not.toContain('secrets.SUPABASE_TEST_DB_URL')
  })

  it('[smoke 11] is skipped for Dependabot pull requests', () => {
    // Job 3-data-model added "pushes to main only" to the same if line (see the
    // [data 18] tests below). Dependabot is still excluded on that line.
    expect(ifLine('apply-test-db')).toContain("github.actor != 'dependabot[bot]'")
  })
})

// Labels [data N] are the "Done when" statement numbers from
// factory/jobs/3-data-model/spec.md, and the owner's rule recorded in
// factory/jobs/3-data-model/summary.md (20 October 2026): database changes reach
// the shared test project only after the owner approves a job, which is when it
// is merged to main.

describe('database changes reach the test project only after owner approval', () => {
  it('[data 18] the apply job runs only on a push to main, and never for Dependabot', () => {
    expect(ifLine('apply-test-db')).toBe(
      "github.event_name == 'push' && github.ref == 'refs/heads/main' && github.actor != 'dependabot[bot]'",
    )
  })

  it('[data 18] pushes start the workflow only on main, so another branch never reaches the apply job', () => {
    const on = workflow.slice(workflow.indexOf('\non:\n'), workflow.indexOf('\nconcurrency:'))
    expect(on).toContain('\n  push:\n    branches: [main]\n')
    expect(on).toContain('\n  pull_request:\n')
  })

  it('[data 18] no other job can change a remote database', () => {
    for (const [id] of all) {
      if (id === 'apply-test-db') continue
      const run = commands(id)
      expect(run, id).not.toMatch(/db push|--db-url|--linked|supabase link|migration (up|repair)/)
    }
  })

  it('[data 18] the preview runs on a pull request only when every check passed and the test project was not changed', () => {
    const preview = job('preview')
    const condition = preview.slice(preview.indexOf('    if: >-'), preview.indexOf('    runs-on:'))
    expect(condition).toContain('!cancelled()')
    expect(condition).toContain("github.event_name == 'pull_request'")
    expect(condition).toContain("github.actor != 'dependabot[bot]'")
    for (const id of needsOf('preview')) {
      const want = id === 'apply-test-db' ? 'skipped' : 'success'
      expect(condition, id).toContain(`needs.${id}.result == '${want}'`)
    }
  })
})

describe('database check for the data model', () => {
  const run = () => commands('database')

  it('[data 15] [data 16] runs every reference data load a second time on the same database', () => {
    expect(run()).toContain('for file in supabase/migrations/*_load_v2_*.sql; do')
    expect(run()).toContain('psql "$LOCAL_DB_URL" --no-psqlrc --quiet -v ON_ERROR_STOP=1 -f "$file"')
  })

  it('[data 15] loads the made-up starter sentences twice in a rolled back transaction', () => {
    expect(run()).toContain('-f scripts/v2-import/fixtures/check-load-twice.sql')
  })

  it('[data 18] runs the pgTAP tests before and again after the second load', () => {
    const lines = run().split('\n')
    const tests = lines.flatMap((line, i) => (line === 'supabase test db' ? [i] : []))
    const reload = lines.findIndex((line) => line.includes('_load_v2_'))
    expect(tests).toHaveLength(2)
    expect(tests[0]).toBeLessThan(reload)
    expect(tests[1]).toBeGreaterThan(reload)
  })

  it('[data 3] fails when the committed database types differ from the migrated database', () => {
    expect(run()).toContain(
      'supabase gen types --lang typescript --local --schema public > "$RUNNER_TEMP/database.types.ts"',
    )
    expect(run()).toContain('diff -u src/lib/database.types.ts "$RUNNER_TEMP/database.types.ts"')
  })
})

describe('order of the checks', () => {
  // Moved by job 6-pr-local-db (statement 11): the browser tests against the
  // test project now run only after merge, in their own job. Same substance.
  it('[smoke 11] [prdb 11] the browser tests against the test project wait for the test project to be updated', () => {
    expect(needsOf('browser-test-project')).toEqual(expect.arrayContaining(['database', 'apply-test-db']))
    expect(job('browser-test-project')).toContain("needs.apply-test-db.result == 'success'")
  })

  it('[smoke 11] the preview waits for the database tests and the test project update', () => {
    expect(needsOf('preview')).toEqual(
      expect.arrayContaining([
        'code',
        'unit',
        'python',
        'database',
        'apply-test-db',
        'browser',
        'secrets',
        'dependencies',
      ]),
    )
  })
})

describe('third-party actions', () => {
  it.each([
    '.github/workflows/checks.yml',
    '.github/workflows/keep-test-db-awake.yml',
    '.github/workflows/secret-scan-notes.yml',
  ])(
    '[smoke 11] every action not made by GitHub is pinned to a full commit, with its version in a comment (%s)',
    (path) => {
      const text = readFileSync(path, 'utf8').replace(/\r\n/g, '\n')
      const thirdParty = [...text.matchAll(/uses: (\S+)(.*)$/gm)].filter(
        ([, action]) => !action?.startsWith('actions/'),
      )
      if (path.endsWith('checks.yml')) expect(thirdParty.length).toBe(3)
      for (const [line, action, comment] of thirdParty) {
        expect(action, line).toMatch(/^[\w.-]+\/[\w.-]+@[0-9a-f]{40}$/)
        expect(comment, line).toMatch(/^ # v\d+\.\d+\.\d+$/)
      }
    },
  )

  it('[smoke 11] the gitleaks action, which receives the GitHub token, is pinned too', () => {
    expect(job('secrets')).toContain(
      'uses: gitleaks/gitleaks-action@e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e # v3.0.0',
    )
  })
})

// Labels [tooling N] are the "Done when" statement numbers from
// factory/jobs/4-tooling/spec.md. At job 3's merge, a newer run on main
// cancelled an older one while it was applying database changes to the test
// project. Runs on main (and manual runs) must now all finish; pull request
// runs still replace an older run on the same pull request.

describe('main-branch runs never cancel each other; pull request runs still do', () => {
  const top = workflow.slice(workflow.indexOf('\nconcurrency:\n'), workflow.indexOf('\npermissions:'))

  it('[tooling 17] the workflow group is per branch for pull requests and per run for everything else', () => {
    expect(top).toContain(
      "\n  group: checks-${{ github.event_name == 'pull_request' && github.ref || github.run_id }}\n",
    )
  })

  it('[tooling 17] cancel-in-progress is true only for pull requests, and set nowhere else', () => {
    expect(top).toContain("\n  cancel-in-progress: ${{ github.event_name == 'pull_request' }}\n")
    expect(workflow.match(/^ *cancel-in-progress:/gm)).toHaveLength(1)
  })

  it('[tooling 17] the apply job has its own group that queues instead of cancelling', () => {
    const apply = job('apply-test-db')
    expect(apply).toMatch(/^ {4}concurrency:\n {6}group: apply-test-db\n {6}queue: max\n/m)
    expect(apply).not.toMatch(/^ *cancel-in-progress:/m)
    for (const [id, text] of all) {
      if (id !== 'apply-test-db') expect(text, id).not.toMatch(/^ {4}concurrency:/m)
    }
  })
})

// Labels [prdb N] are the "Done when" statement numbers from
// factory/jobs/6-pr-local-db/spec.md. Pull request browser tests run on a
// throwaway local Supabase inside their own runner. The test project is used
// by browser tests only after merge, once the owner-approved migrations are
// applied there.

// Every name `supabase start --exclude` accepts in Supabase CLI 2.121.0
// (`npx supabase start --help`). Postgres itself is not on the list: it always
// starts.
const CLI_SERVICES = [
  'gotrue',
  'realtime',
  'storage-api',
  'imgproxy',
  'kong',
  'mailpit',
  'postgrest',
  'postgres-meta',
  'studio',
  'edge-runtime',
  'logflare',
  'vector',
  'supavisor',
]
// Job 11-accounts added mailpit: its browser tests read sign in codes from it.
const USED_SERVICES = ['gotrue', 'kong', 'mailpit', 'postgrest']

function stepNames(id: string): string[] {
  return [...job(id).matchAll(/^ {6}- name: (.+)$/gm)].map((m) => m[1] ?? '')
}

// The job's command lines with their indentation removed.
function runText(id: string): string {
  return commands(id)
    .split('\n')
    .map((line) => line.trim())
    .join('\n')
}

// The line index in the job's commands where a pattern first appears.
function commandIndex(id: string, pattern: RegExp): number {
  return runText(id)
    .split('\n')
    .findIndex((line) => pattern.test(line))
}

const configToml = readFileSync('supabase/config.toml', 'utf8').replace(/\r\n/g, '\n')

function tomlSection(name: string): string {
  const header = `\n[${name}]\n`
  const start = configToml.indexOf(header)
  if (start < 0) throw new Error(`No [${name}] in supabase/config.toml`)
  const rest = configToml.slice(start + header.length)
  const end = rest.search(/^\[/m)
  return end < 0 ? rest : rest.slice(0, end)
}

describe('pull request browser tests on a throwaway database', () => {
  const local = () => job('browser')

  it('[prdb 1] the check is named "Browser tests (Playwright, local Supabase)"', () => {
    expect(local()).toContain('    name: Browser tests (Playwright, local Supabase)\n')
  })

  it('[prdb 1] runs on pull requests (Dependabot included) and manual runs, never on pushes to main', () => {
    expect(ifLine('browser')).toBe("github.event_name != 'push'")
    expect(local()).not.toContain('dependabot')
  })

  it('[prdb 1] starts at the same time as the database check and waits for no other job', () => {
    expect(needsOf('browser')).toEqual([])
    expect(local()).not.toMatch(/^ {4}needs:/m)
  })

  it('[prdb 1] [accounts 28] starts a local Supabase with only Postgres, kong, postgrest, gotrue and mailpit', () => {
    const match = /^npx supabase start -x ([a-z,-]+)( |$)/m.exec(runText('browser'))
    expect(match?.[1]).toBeDefined()
    const excluded = (match?.[1] ?? '').split(',')
    expect([...excluded].sort()).toEqual(CLI_SERVICES.filter((name) => !USED_SERVICES.includes(name)).sort())
    // The CLI comes from npm ci (the version pinned in package-lock.json), so
    // no third action is added to this workflow.
    expect(local()).not.toContain('supabase/setup-cli')
    expect(commandIndex('browser', /^npm ci$/)).toBeLessThan(commandIndex('browser', /^npx supabase start /))
  })

  it('[prdb 1] applies the migrations by starting from an empty database (no remote, no link)', () => {
    expect(runText('browser')).not.toMatch(
      /db push|--db-url|--linked|supabase link|migration (up|repair)|db pull/,
    )
  })

  it('[prdb 1] builds the app and runs the full Playwright suite after the database started', () => {
    const start = commandIndex('browser', /^npx supabase start /)
    const build = commandIndex('browser', /^npm run build$/)
    const tests = commandIndex('browser', /^npx playwright test$/)
    expect(start).toBeGreaterThanOrEqual(0)
    expect(build).toBeGreaterThan(start)
    expect(tests).toBeGreaterThan(build)
    expect(runText('browser')).toContain('npx playwright install --with-deps chromium webkit')
  })

  it('[prdb 2] holds no secret: no secrets. reference anywhere in the job', () => {
    expect(local()).not.toMatch(/\bsecrets\./)
    expect(local()).not.toMatch(/SUPABASE_TEST_/)
  })

  it('[prdb 2] the Worker settings come from supabase status, written by write-test-settings.ts', () => {
    expect(runText('browser')).toContain(
      'npx supabase status -o env | node scripts/ci/write-test-settings.ts env .env.local --from-supabase-status',
    )
    const settings = commandIndex('browser', /write-test-settings\.ts/)
    expect(settings).toBeGreaterThan(commandIndex('browser', /^npx supabase start /))
    expect(settings).toBeLessThan(commandIndex('browser', /^npm run build$/))
  })

  it('[prdb 2] the start output is filtered so the local keys never reach the log', () => {
    expect(runText('browser')).toMatch(/^set -o pipefail$/m)
    const filter = /^npx supabase start .*\| \{ grep -viE '([^']+)' \|\| true; \}$/m.exec(
      runText('browser'),
    )?.[1]
    expect(filter).toBeDefined()
    // The grep pattern is an extended regular expression that JavaScript reads
    // the same way. Lines shaped like the CLI 2.121.0 start table, with
    // made-up values. Round 1 printed the "Publishable" row (no "key" in it).
    const dropped = new RegExp(filter ?? '', 'i')
    for (const line of [
      '│ Publishable │ sb_publishable_madeUpValue │',
      '│ Secret      │ sb_secret_madeUpValue      │',
      '│ JWT secret  │ madeUpValue                │',
      '│ anon key    │ eyJmadeUp.madeUp.madeUp    │',
      '│ service_role key │ eyJmadeUp.madeUp.madeUp │',
      '│ Access Key  │ madeUpValue                │',
      '│ madeUpLabel │ eyJmadeUp.madeUp.madeUp    │',
      '│ madeUpLabel │ sb_madeUp                  │',
    ]) {
      expect(dropped.test(line), line).toBe(true)
    }
    for (const line of [
      'Applying migration 20261019183410_create_visits.sql...',
      'Started supabase local development setup.',
    ]) {
      expect(dropped.test(line), line).toBe(false)
    }
  })

  it('[prdb 2] keeps the report, screenshots and videos as the playwright-report download', () => {
    const upload = local().slice(local().indexOf('- name: Keep the report, screenshots and videos'))
    expect(upload).toContain('if: success() || failure()')
    expect(upload).toContain('uses: actions/upload-artifact@v7')
    expect(upload).toContain('name: playwright-report')
    expect(upload).toContain('playwright-report/')
    expect(upload).toContain('test-results/')
  })

  // Job 8-first-session dropped visits (its "Done when" 21), so the same
  // proof now counts the guest accounts the browser tests made.
  it('[prdb 3] after the tests, psql shows at least one guest account on the throwaway database', () => {
    const run = runText('browser')
    expect(run).toContain(
      'guests=$(psql "$LOCAL_DB_URL" --no-psqlrc --tuples-only --no-align -v ON_ERROR_STOP=1 -c "select count(*) from auth.users where is_anonymous")',
    )
    expect(run).toContain('if [ "$guests" -lt 1 ]; then')
    expect(commandIndex('browser', /select count\(\*\) from auth\.users where is_anonymous/)).toBeGreaterThan(
      commandIndex('browser', /^npx playwright test$/),
    )
    expect(local()).toContain('      LOCAL_DB_URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres\n')
  })

  it('[session 6] after the main run, every unit is set to draft and only the @empty-content tests run again', () => {
    const draft = commandIndex(
      'browser',
      /update public\.units set status = 'draft' where status = 'approved'/,
    )
    const empty = commandIndex(
      'browser',
      /^PUHUSCRIBE_EMPTY_CONTENT=1 npx playwright test --grep @empty-content --reporter=list --output=test-results-empty-content$/,
    )
    expect(draft).toBeGreaterThan(commandIndex('browser', /^npx playwright test$/))
    expect(empty).toBeGreaterThan(draft)
    const upload = local().slice(local().indexOf('- name: Keep the report, screenshots and videos'))
    expect(upload).toContain('test-results-empty-content/')
  })

  it('[prdb 1] opens no tunnel to the throwaway database', () => {
    expect(local()).not.toMatch(/cloudflared|ngrok|localtunnel|tailscale|ssh /)
  })
})

describe('local database permissions match the test project', () => {
  it('[prdb 6] config.toml sets auto_expose_new_tables = false under [api]', () => {
    expect(tomlSection('api')).toMatch(/^auto_expose_new_tables = false$/m)
  })
})

describe('browser test seed data', () => {
  const SEEDS = 'supabase/seeds/browser'

  it('[prdb 7] the local browser check loads every seed file in name order after the migrations and before the tests', () => {
    const run = runText('browser')
    expect(run).toContain(`files=(${SEEDS}/*.sql)`)
    expect(run).toMatch(/^export LC_ALL=C$/m)
    expect(run).toMatch(/^shopt -s nullglob$/m)
    expect(run).toContain(`echo "No browser seed files in ${SEEDS}/"`)
    expect(run).toContain('psql "$LOCAL_DB_URL" --no-psqlrc --quiet -v ON_ERROR_STOP=1 -f "$file"')
    const seed = commandIndex('browser', /files=\(supabase\/seeds\/browser/)
    expect(seed).toBeGreaterThan(commandIndex('browser', /^npx supabase start /))
    expect(seed).toBeLessThan(commandIndex('browser', /^npx playwright test$/))
    expect(stepNames('browser')).toContain('Load the browser test seed files')
  })

  it('[prdb 7] no other job loads them', () => {
    for (const [id, text] of all) {
      if (id === 'browser') continue
      expect(text, id).not.toContain('seeds/')
    }
  })

  it('[prdb 7] config.toml seed paths never include them, so supabase start and db reset do not load them', () => {
    const seed = tomlSection('db.seed')
    const paths = /^sql_paths = \[(.*)\]$/m.exec(seed)?.[1]
    expect(paths).toBeDefined()
    expect(paths).not.toContain('seeds')
    expect(paths).not.toContain('*')
  })
})

describe('browser tests against the test project after merge', () => {
  const after = () => job('browser-test-project')

  it('[prdb 8] is named "Browser tests against the test project (after merge)"', () => {
    expect(after()).toContain('    name: Browser tests against the test project (after merge)\n')
  })

  it('[prdb 8] runs only on a push to main once the apply job succeeded', () => {
    expect(needsOf('browser-test-project')).toEqual(['database', 'apply-test-db'])
    expect(ifLine('browser-test-project')).toBe(
      "github.event_name == 'push' && github.ref == 'refs/heads/main' && needs.apply-test-db.result == 'success'",
    )
  })

  it('[prdb 8] [accounts 28] runs the suite without the tests that need browser seed rows or the local mail catcher', () => {
    expect(runText('browser-test-project')).toMatch(/^npx playwright test --grep-invert "@seed\|@email"$/m)
    expect(runText('browser-test-project')).not.toContain('seeds/')
  })

  it('[prdb 8] is the only browser test job that receives the test project settings', () => {
    expect(after()).toContain('SUPABASE_URL: ${{ secrets.SUPABASE_TEST_URL }}')
    expect(after()).toContain('SUPABASE_PUBLISHABLE_KEY: ${{ secrets.SUPABASE_TEST_PUBLISHABLE_KEY }}')
    expect(job('browser')).not.toContain('SUPABASE_TEST_URL')
    expect(job('browser')).not.toContain('SUPABASE_TEST_PUBLISHABLE_KEY')
  })

  it('[prdb 8] keeps the upload guard for those two settings', () => {
    expect(runText('browser-test-project')).toContain('node scripts/ci/check-files-for-secrets.ts')
    expect(runText('browser-test-project')).toContain('--env SUPABASE_URL --env SUPABASE_PUBLISHABLE_KEY')
    expect(after()).toContain("if: (success() || failure()) && steps.upload-guard.outcome == 'success'")
  })
})

describe('preview links on pull requests that change the database', () => {
  const preview = () => job('preview')

  it('[prdb 10] the checkout has the base branch, so a three-dot diff of supabase/migrations/ works', () => {
    expect(preview()).toMatch(/uses: actions\/checkout@v7\n {8}with:\n(?: {10}.*\n)* {10}fetch-depth: 0\n/)
    expect(preview()).toContain('      BASE_SHA: ${{ github.event.pull_request.base.sha }}\n')
    expect(runText('preview')).toContain(
      'changed=$(git diff --name-only --no-renames "$BASE_SHA...HEAD" | node scripts/ci/preview-plan.ts database-changed)',
    )
  })

  it('[prdb 10] [accounts 28] a database change runs only @preview tests on the preview, otherwise the suite without @seed and @email', () => {
    const run = runText('preview')
    expect(run).toContain('if [ "$DB_CHANGED" = true ]; then')
    expect(run).toMatch(/^npx playwright test --grep @preview$/m)
    expect(run).toMatch(/^npx playwright test --grep-invert "@seed\|@email"$/m)
    expect(run).not.toMatch(/^npx playwright test$/m)
  })

  it('[prdb 10] the preview is still uploaded and the link still posted either way', () => {
    const steps = stepNames('preview')
    expect(steps).toContain('Upload a preview version of puhuscribe-preview')
    expect(steps).toContain('Post the preview link on the pull request')
    expect(preview()).not.toMatch(/^ {8}if: .*(DB_CHANGED|database-change)/m)
  })

  it('[prdb 10] the comment comes from preview-plan.ts with the run link', () => {
    expect(runText('preview')).toContain('body=$(node scripts/ci/preview-plan.ts comment)')
    expect(preview()).toContain(
      '          RUN_URL: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}\n',
    )
  })

  it('[prdb 10] the Cloudflare Access lock tests carry the @preview tag', () => {
    let lockFiles = 0
    for (const file of readdirSync('e2e').filter((name) => name.endsWith('.spec.ts'))) {
      const text = readFileSync(join('e2e', file), 'utf8')
      const lockBlocks = [...text.matchAll(/test\.describe\('private preview link'(.*)/g)]
      if (text.includes("test.skip(!onPreview, 'Only runs against a preview link')")) {
        lockFiles += 1
        expect(lockBlocks.length, file).toBeGreaterThan(0)
      }
      for (const [, rest] of lockBlocks) expect(rest, file).toContain("{ tag: '@preview' }")
    }
    expect(lockFiles).toBeGreaterThan(0)
  })
})

// The manager's extra statement for job 6-pr-local-db (recorded in its
// build.md), under statement 13 (minutes): pushes to main that change only
// factory notes or recording files skip the full checks, and keep a secret
// scan. GitHub requires no check on this repository.

describe('pushes to main that change only factory notes or recordings', () => {
  const on = workflow.slice(workflow.indexOf('\non:\n'), workflow.indexOf('\nconcurrency:'))
  const notes = readFileSync('.github/workflows/secret-scan-notes.yml', 'utf8').replace(/\r\n/g, '\n')

  it('[prdb 13] checks.yml ignores pushes to main that change only factory/ and recording/', () => {
    const push = on.slice(on.indexOf('\n  push:\n'), on.indexOf('\n  workflow_dispatch:'))
    const ignored = [...push.matchAll(/^ {6}- '([^']+)'$/gm)].map((m) => m[1])
    expect(ignored).toEqual(['factory/**', 'recording/**'])
    expect(push).toMatch(/^ {4}paths-ignore:$/m)
    expect(push).not.toMatch(/^ {4}paths:$/m)
  })

  it('[prdb 13] pull requests and manual runs are never filtered by path', () => {
    expect(on).toMatch(/\n {2}pull_request:\n {2}push:\n/)
    // Nothing is indented under workflow_dispatch, and the only path filter
    // is the one under push.
    expect(on).toMatch(/\n {2}workflow_dispatch:\n(?! {4})/)
    expect(on.match(/^ +paths(-ignore)?:/gm)).toEqual(['    paths-ignore:'])
  })

  it('[prdb 13] those pushes still get the secret scan, with the same pinned gitleaks action', () => {
    expect(notes).toContain(
      "\non:\n  push:\n    branches: [main]\n    paths:\n      - 'factory/**'\n      - 'recording/**'\n",
    )
    expect(notes).toContain(
      'uses: gitleaks/gitleaks-action@e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e # v3.0.0',
    )
    expect(notes).toContain('fetch-depth: 0')
    expect(notes).toContain('persist-credentials: false')
    expect(notes).toContain("GITLEAKS_ENABLE_COMMENTS: 'false'")
    const secrets = [...notes.matchAll(/secrets\.([A-Z_]+)/g)].map((m) => m[1])
    expect(secrets).toEqual(['GITHUB_TOKEN'])
    expect(notes).toMatch(/\npermissions:\n {2}contents: read\n/)
  })
})

// Labels [public N] are the findings of the pre-publication review
// (factory/jobs/14-public-repo/review-prepublish.md). In a public repository
// every Actions artifact can be downloaded by anyone, and the Switzer font
// files (ITF Free Font License) must not be offered that way.

// The `path:` lines of every upload-artifact step in a job.
function uploadPaths(id: string): string[] {
  const paths: string[] = []
  const lines = job(id).split('\n')
  lines.forEach((line, i) => {
    if (!line.includes('uses: actions/upload-artifact@')) return
    for (let j = i + 1; j < lines.length && !/^ {6}- /.test(lines[j] ?? ''); j++) {
      const text = lines[j] ?? ''
      const single = /^ {10}path: (?!\|)(.+)$/.exec(text)
      if (single?.[1]) paths.push(single[1].trim())
      if (/^ {10}path: \|$/.test(text)) {
        for (let k = j + 1; /^ {12}\S/.test(lines[k] ?? ''); k++) paths.push((lines[k] ?? '').trim())
      }
    }
  })
  return paths
}

const fontJobs = [...all.keys()].filter((id) => job(id).includes('fetch-private-fonts'))

describe('jobs that fetch the private fonts upload no trace and no report', () => {
  it('[public 1] the two jobs that fetch the Switzer files are found', () => {
    expect([...fontJobs].sort()).toEqual(['browser-test-project', 'preview'])
    expect(job('browser')).not.toContain('FONTS_DEPLOY_KEY')
  })

  it('[public 1] no other workflow file fetches the fonts or sees the deploy key', () => {
    for (const file of ['content-pipeline.yml', 'keep-test-db-awake.yml', 'secret-scan-notes.yml']) {
      const text = readFileSync(`.github/workflows/${file}`, 'utf8')
      expect(text, file).not.toContain('fetch-private-fonts')
      expect(text, file).not.toContain('FONTS_DEPLOY_KEY')
    }
  })

  it.each(['browser-test-project', 'preview'])(
    '[public 1] %s uploads only .png and .webm files from test-results, never a report folder',
    (id) => {
      const paths = uploadPaths(id)
      expect(paths.length, id).toBeGreaterThan(0)
      for (const path of paths) {
        expect(path, id).not.toMatch(/playwright-report/)
        expect(path, id).toMatch(/^test-results\/\*\*\/\*\.(png|webm)$/)
      }
    },
  )

  it.each(['browser-test-project', 'preview'])(
    '[public 1] %s sets PUHUSCRIBE_NO_TRACE on the step that runs Playwright, so no trace or HTML report is written',
    (id) => {
      const playwrightSteps = job(id)
        .split(/\n(?= {6}- )/)
        .filter((step) => /\bnpx playwright test\b/.test(step))
      expect(playwrightSteps.length, id).toBeGreaterThan(0)
      for (const step of playwrightSteps) {
        expect(step, id).toContain("PUHUSCRIBE_NO_TRACE: '1'")
        expect(step, id).not.toMatch(/--trace|--reporter=html/)
      }
    },
  )

  it('[public 1] the upload check can fail: a whole test-results folder upload is seen', () => {
    const before = all.get('browser-test-project') ?? ''
    all.set('browser-test-project', before.replace('test-results/**/*.png', 'test-results/'))
    try {
      expect(uploadPaths('browser-test-project')).toContain('test-results/')
    } finally {
      all.set('browser-test-project', before)
    }
  })
})

describe('pull requests from forks never run the jobs that hold secrets', () => {
  const awake = readFileSync('.github/workflows/keep-test-db-awake.yml', 'utf8').replace(/\r\n/g, '\n')
  const head = 'github.event.pull_request.head.repo.full_name == github.repository'

  it('[public 2] the preview runs only when the pull request comes from this repository', () => {
    const preview = job('preview')
    const condition = preview.slice(preview.indexOf('    if: >-'), preview.indexOf('    runs-on:'))
    expect(condition).toContain(head)
  })

  it('[public 2] the keep-awake ping skips fork pull requests but still runs on schedule and by hand', () => {
    const condition = awake.slice(awake.indexOf('    if: >-'), awake.indexOf('    runs-on:'))
    expect(condition).toContain("github.actor != 'dependabot[bot]'")
    expect(condition).toContain("github.event_name != 'pull_request' ||")
    expect(condition).toContain(head)
  })
})
