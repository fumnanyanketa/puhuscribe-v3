import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'
import { filesThatRunTheWorker, outsideLoads, servedPaths } from '../scripts/security/check-built-files.ts'
import { PAGE_ROUTES, RUN_WORKER_FIRST, isPageRoute } from '../worker/page-routes.ts'

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md that each test protects.
// Repository rules for the visit count, the owner page and crash reports.

function filesUnder(dir: string, pattern: RegExp): string[] {
  if (!existsSync(dir)) return []
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name).replace(/\\/g, '/')
    if (statSync(path).isDirectory()) return name === 'node_modules' ? [] : filesUnder(path, pattern)
    return pattern.test(name) ? [path] : []
  })
}

/** wrangler.jsonc without its comments and trailing commas. */
function wrangler(): { assets?: { binding?: string; run_worker_first?: string[] } } {
  const text = readFileSync('wrangler.jsonc', 'utf8')
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/^\s*\/\/.*$/gm, '')
    .replace(/,(\s*[}\]])/g, '$1')
  return JSON.parse(text) as { assets?: { binding?: string; run_worker_first?: string[] } }
}

/** Every path src/App.tsx picks a page for, read from its `path === '...'` checks. */
function appRoutes(): string[] {
  const app = readFileSync('src/App.tsx', 'utf8')
  return [...app.matchAll(/path === '([^']+)'/g)].map((m) => m[1] ?? '')
}

describe('only page requests reach the Worker', () => {
  it('[analytics 3] wrangler.jsonc names the ASSETS binding and lists exactly /api/* and the page routes', () => {
    const assets = wrangler().assets
    expect(assets?.binding).toBe('ASSETS')
    expect(assets?.run_worker_first).toEqual([...RUN_WORKER_FIRST])
    expect(RUN_WORKER_FIRST[0]).toBe('/api/*')
  })

  it('[analytics 3] every page of src/App.tsx, and the front door at /, is a run_worker_first route', () => {
    const routes = appRoutes()
    expect(routes.length).toBeGreaterThanOrEqual(9)
    for (const route of [...routes, '/']) expect(isPageRoute(route), route).toBe(true)
    expect(routes).toContain('/feedback')
    expect(routes).toContain('/owner')
  })

  it('[analytics 3] every listed page route is a page of src/App.tsx', () => {
    const routes = appRoutes()
    for (const pattern of PAGE_ROUTES) {
      if (pattern === '/') continue
      const page = pattern.endsWith('/*')
        ? routes.some((r) => r.startsWith(pattern.slice(0, -1)))
        : routes.includes(pattern)
      expect(page, pattern).toBe(true)
    }
  })

  it('[analytics 3] no built file matches a pattern, and the check finds one that would', () => {
    // The build runs scripts/security/check-built-files.ts on dist/client
    // after every build; when a build is here, check it now too.
    if (existsSync('dist/client'))
      expect(filesThatRunTheWorker(servedPaths('dist/client'), RUN_WORKER_FIRST)).toEqual([])
    const typical = [
      '/index.html',
      '/assets/index-AbC12.js',
      '/assets/index-AbC12.css',
      '/assets/fonts/poppins.woff2',
    ]
    expect(filesThatRunTheWorker(typical, RUN_WORKER_FIRST)).toEqual([])
    expect(filesThatRunTheWorker(['/owner', '/account/photo.png', '/api/x.json'], RUN_WORKER_FIRST)).toEqual([
      '/owner',
      '/account/photo.png',
      '/api/x.json',
    ])
  })

  it('[analytics 3] [analytics 7] every build runs the built files check', () => {
    const pkg = JSON.parse(readFileSync('package.json', 'utf8')) as { scripts: Record<string, string> }
    expect(pkg.scripts.build).toMatch(/npm run check:built-files$/)
    expect(pkg.scripts['check:built-files']).toBe('node scripts/security/check-built-files.ts')
  })
})

describe('no outside counter or script', () => {
  it('[analytics 7] index.html loads nothing from another site', () => {
    expect(outsideLoads(readFileSync('index.html', 'utf8'))).toEqual([])
    if (existsSync('dist/client/index.html')) {
      expect(outsideLoads(readFileSync('dist/client/index.html', 'utf8'))).toEqual([])
    }
  })

  it('[analytics 7] the check catches a script, a style and a pixel from another site', () => {
    expect(
      outsideLoads(
        '<script src="https://counter.example/c.js"></script><link rel="stylesheet" href="//fonts.example/a.css"><img src=http://pixel.example/p.gif><script src="/assets/a.js"></script>',
      ),
    ).toEqual(['https://counter.example/c.js', '//fonts.example/a.css', 'http://pixel.example/p.gif'])
  })

  it('[analytics 30] the browser code never calls a supabase.co address', () => {
    for (const path of filesUnder('src', /\.(ts|tsx)$/)) {
      expect(readFileSync(path, 'utf8'), path).not.toMatch(/supabase\.co\b/)
    }
  })
})

describe('no anti metric', () => {
  it('[analytics 11] the owner page and owner_dashboard() never mention words learned, forms learned, streaks or screens per session', () => {
    const migration = readFileSync('supabase/migrations/20261030101645_analytics.sql', 'utf8')
    const dashboard = migration.slice(migration.indexOf('create function public.owner_dashboard()'))
    const texts = [
      readFileSync('src/screens/OwnerPage.tsx', 'utf8'),
      readFileSync('src/lib/owner-numbers.ts', 'utf8'),
      dashboard.slice(0, dashboard.indexOf('$$;')),
    ]
    for (const text of texts)
      expect(text).not.toMatch(/words? learned|forms? learned|streak|screens? per session/i)
  })
})

describe('one module for crash reports', () => {
  it('[analytics 28] no file but worker/providers/crash-reports.ts calls report_crash', () => {
    const code = [
      ...filesUnder('src', /\.(ts|tsx)$/),
      ...filesUnder('worker', /\.ts$/),
      ...filesUnder('scripts', /\.(ts|py)$/),
      ...filesUnder('e2e', /\.ts$/),
      ...filesUnder('review-site', /\.ts$/),
    ]
      // The generated database types name every function; they call nothing.
      .filter((path) => !path.endsWith('.test.ts') && path !== 'src/lib/database.types.ts')
    expect(code.length).toBeGreaterThan(20)
    const callers = code.filter((path) => readFileSync(path, 'utf8').includes('report_crash'))
    expect(callers).toEqual(['worker/providers/crash-reports.ts'])
  })
})

describe('the parallel database tests', () => {
  const workflow = readFileSync('.github/workflows/checks.yml', 'utf8').replace(/\r\n/g, '\n')

  it('[analytics 6] [analytics 22] [analytics 26] run in the database check and must all pass, none skipped', () => {
    const job = workflow.slice(workflow.indexOf('\n  database:\n'), workflow.indexOf('\n  apply-test-db:\n'))
    expect(job).toContain('- name: Parallel database tests, from two connections at once (pgTAP with dblink)')
    expect(job).toContain(
      'PGOPTIONS=\'-c puhuscribe.parallel_test_password=postgres\' psql "$LOCAL_DB_URL" --no-psqlrc --tuples-only --no-align -v ON_ERROR_STOP=1 -f supabase/tests/database/analytics_parallel.test.sql',
    )
    expect(job).toContain("grep -qx '1\\.\\.9'")
    expect(job).toContain('test "$(echo "$out" | grep -c \'^ok \')" -eq 9')
    expect(job).toContain('if echo "$out" | grep -qE \'^not ok|# SKIP|# Looks like\'; then exit 1; fi')
    expect(job.indexOf('Parallel database tests')).toBeGreaterThan(job.indexOf('run: supabase test db'))
  })
})

describe('settings and records', () => {
  it('[analytics 13] [analytics 14] .env.example names the owner page settings with no value', () => {
    const example = readFileSync('.env.example', 'utf8')
    for (const name of [
      'OWNER_HOSTNAME',
      'OWNER_ACCESS_TEAM_DOMAIN',
      'OWNER_ACCESS_AUD',
      'OWNER_ACCESS_LOCAL_JWKS',
    ]) {
      expect(example).toMatch(new RegExp(`^${name}= +# .+`, 'm'))
    }
  })

  it('[analytics 13] no live owner hostname is written into code or config', () => {
    const files = [
      'wrangler.jsonc',
      ...filesUnder('worker', /\.ts$/),
      ...filesUnder('src', /\.(ts|tsx)$/),
      ...filesUnder('e2e', /\.ts$/),
    ]
    for (const path of files)
      expect(readFileSync(path, 'utf8'), path).not.toMatch(/puhuscribe-owner\.exentrik\.co/)
  })

  it('[analytics 32] the conventions, data model and README record the job', () => {
    expect(readFileSync('docs/conventions.md', 'utf8')).toContain('| 14-analytics | `[analytics N]` |')
    const model = readFileSync('docs/data-model.md', 'utf8')
    for (const name of [
      'private.visit_tallies',
      'public.feedback',
      'private.owners',
      'private.crash_reports',
      'public.count_visit(',
      'public.report_crash(',
      'public.owner_dashboard()',
      'public.my_owner_rows()',
      'The owner page numbers',
    ]) {
      expect(model, name).toContain(name)
    }
    const readme = readFileSync('README.md', 'utf8')
    expect(readme).toContain('## Owner page setup (job 14-analytics)')
    expect(readme).toContain('insert into private.owners (user_id)')
    expect(readme).not.toMatch(/insert into private\.owners[^\n]*@[a-z0-9-]+\.[a-z]/i)
    const costs = readme.slice(readme.indexOf('## Running costs'))
    expect(costs).toMatch(/visit count[^\n]*€0/i)
  })
})
