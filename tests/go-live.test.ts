import { mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { afterEach, describe, expect, it } from 'vitest'
import { checkApprovedDialogues } from '../scripts/ci/check-approved-dialogues.ts'
import { checkLiveBuild, LIVE_ROUTES } from '../scripts/ci/check-live-build.ts'
import { checkLiveMigrations, remoteVersions } from '../scripts/ci/check-live-migrations.ts'
import { checkLiveSettings, dbUrlNamesProject, projectRef } from '../scripts/ci/check-live-settings.ts'

// Job go-live: the app on https://meetaleksi.com with its own live Supabase project.
// Labels are the numbered items of the manager's brief (factory/jobs/go-live/build.md):
// [go-live 1] the manual live workflow and the production Worker config,
// [go-live 2] the app changes for production (landing address, cookie, privacy notice).

const read = (path: string) => readFileSync(path, 'utf8').replace(/\r\n/g, '\n')

/** wrangler.jsonc without its comments and trailing commas. */
function jsonc(text: string): Record<string, unknown> {
  return JSON.parse(
    text
      .replace(/\/\*[\s\S]*?\*\//g, '')
      .replace(/^\s*\/\/.*$/gm, '')
      .replace(/,(\s*[}\]])/g, '$1'),
  ) as Record<string, unknown>
}

/** A workflow file split into its jobs, as tests/checks-workflow.test.ts does. */
function jobs(text: string): Map<string, string> {
  const start = text.indexOf('\njobs:\n')
  const found = new Map<string, string>()
  let current: string | undefined
  let lines: string[] = []
  for (const line of text.slice(start + 7).split('\n')) {
    const name = /^ {2}([a-z0-9-]+):$/.exec(line)
    if (name?.[1]) {
      if (current) found.set(current, lines.join('\n'))
      current = name[1]
      lines = []
    } else lines.push(line)
  }
  if (current) found.set(current, lines.join('\n'))
  return found
}

const temps: string[] = []
function temp(): string {
  const dir = mkdtempSync(join(tmpdir(), 'go-live-'))
  temps.push(dir)
  return dir
}
afterEach(() => {
  for (const dir of temps.splice(0)) rmSync(dir, { recursive: true, force: true })
})

describe('the landing page address', () => {
  it('[go-live 2] og:url is https://meetaleksi.com/ and the old address is gone', () => {
    const landing = read('landing.html')
    expect(landing).toContain('<meta property="og:url" content="https://meetaleksi.com/" />')
    expect(landing).not.toContain('puhuscribe.exentrik.co')
  })
})

describe('the production Worker in wrangler.jsonc', () => {
  const config = jsonc(read('wrangler.jsonc'))
  const production = (config.env as Record<string, Record<string, unknown>>).production

  it('[go-live 1] is "aleksi" on meetaleksi.com and www.meetaleksi.com, with no workers.dev or preview address', () => {
    expect(production?.name).toBe('aleksi')
    expect(production?.workers_dev).toBe(false)
    expect(production?.preview_urls).toBe(false)
    expect(production?.routes).toEqual(LIVE_ROUTES)
    expect(production?.vars).toEqual({ CANONICAL_HOST: 'meetaleksi.com' })
  })

  it('[go-live 1] the top level is still the preview Worker, with no route of its own', () => {
    expect(config.name).toBe('puhuscribe-preview')
    expect(config).not.toHaveProperty('routes')
    expect(config).not.toHaveProperty('vars')
  })
})

describe('the live workflow', () => {
  const text = read('.github/workflows/live.yml')
  const all = jobs(text)
  const header = text.slice(0, text.indexOf('\njobs:\n'))

  it('[go-live 1] starts only by hand, with one task per run', () => {
    const on = header.slice(header.indexOf('\non:\n'), header.indexOf('\npermissions:'))
    expect(on).toContain('workflow_dispatch:')
    expect(on).not.toMatch(/\n {2}(push|pull_request|pull_request_target|schedule|workflow_run):/)
    expect(on).toContain('options: [migrations, content, app]')
    expect([...all.keys()]).toEqual(['approved', 'migrations', 'content', 'app'])
  })

  it('[go-live 1] every job runs only on main, and each task waits for the approved content check', () => {
    for (const [id, job] of all) expect(job, id).toMatch(/\n {4}if: github\.ref == 'refs\/heads\/main'/)
    for (const id of ['migrations', 'content', 'app']) {
      expect(all.get(id), id).toContain('needs: [approved]')
      expect(all.get(id), id).toContain(`inputs.task == '${id}'`)
    }
    expect(all.get('approved')).toContain('run: node scripts/ci/check-approved-dialogues.ts')
    expect(all.get('approved')).toContain('run: node scripts/ci/check-published-audio.ts')
  })

  it('[go-live 1] never loads a seed or fixture file, and never writes to the database by hand', () => {
    expect(text).not.toMatch(/seeds\/|seed\.sql|db reset|\bpsql\b|db seed/)
    expect(all.get('migrations')).toContain(
      'run: supabase db push --db-url "$SUPABASE_DB_URL" --yes --include-all',
    )
  })

  it('[go-live 1] the live database password is only in the Supabase CLI steps of jobs that run no package code', () => {
    const lines = text.split('\n')
    const at = lines.flatMap((line, i) => (line.includes('secrets.SUPABASE_LIVE_DB_URL') ? [i] : []))
    expect(at.length).toBe(5)
    for (const i of at) {
      const line = lines[i] ?? ''
      if (line.trim().startsWith('LIVE_DB_URL:')) continue
      expect(line).toBe('          SUPABASE_DB_URL: ${{ secrets.SUPABASE_LIVE_DB_URL }}')
      expect(lines[i + 1]).toMatch(
        /^ {8}run: (\||supabase (db push|migration list) --db-url "\$SUPABASE_DB_URL")/,
      )
    }
    for (const [id, job] of all) {
      if (job.includes('SUPABASE_LIVE_DB_URL')) {
        expect(['migrations', 'content'], id).toContain(id)
        expect(job, id).not.toMatch(/npm (ci|install)|npx /)
      }
    }
    expect(header).not.toContain('secrets.')
  })

  it('[go-live 1] the app is built for production with the design pages off, checked, then deployed', () => {
    const app = all.get('app') ?? ''
    expect(app).toContain(
      "CLOUDFLARE_ENV: production\n          VITE_DESIGN_REFERENCE: '0'\n        run: npm run build",
    )
    expect(app).toContain('run: node scripts/ci/check-live-build.ts')
    expect(app).toContain('npx wrangler deploy --secrets-file "$secrets_file"')
    expect(app.indexOf('check-live-build.ts')).toBeLessThan(app.indexOf('wrangler deploy'))
    expect(app).toContain('SUPABASE_URL: ${{ secrets.SUPABASE_LIVE_URL }}')
    expect(app).toContain('SUPABASE_PUBLISHABLE_KEY: ${{ secrets.SUPABASE_LIVE_PUBLISHABLE_KEY }}')
    expect(app).not.toContain('SUPABASE_TEST_PUBLISHABLE_KEY')
    expect(app).not.toMatch(/SPEECH_FEEDBACK_PROVIDER|speech-fixture|preview-alias|versions upload/)
  })

  it('[go-live 1] every action is pinned to a full commit, with its version in a comment', () => {
    const uses = [...text.matchAll(/uses: (\S+)(.*)/g)]
    expect(uses.length).toBeGreaterThan(0)
    for (const [, action = '', comment = ''] of uses) {
      expect(action).toMatch(/@[0-9a-f]{40}$/)
      expect(comment).toMatch(/^ # v\d/)
    }
  })

  it('[go-live 1] no other workflow receives a live secret', () => {
    for (const name of readdirSync('.github/workflows').filter((file) => file !== 'live.yml'))
      expect(read(join('.github/workflows', name)), name).not.toContain('SUPABASE_LIVE_')
  })
})

describe('the approved dialogues check', () => {
  function folders(approvals: Record<string, unknown>, migrations: string[]) {
    const root = temp()
    mkdirSync(join(root, 'approvals'))
    mkdirSync(join(root, 'migrations'))
    for (const [name, body] of Object.entries(approvals))
      writeFileSync(join(root, 'approvals', name), JSON.stringify(body))
    for (const name of migrations) writeFileSync(join(root, 'migrations', name), '-- made up\n')
    return checkApprovedDialogues(join(root, 'approvals'), join(root, 'migrations'))
  }
  const part = (slugs: string[]) => ({
    approved_line: 'Yes, it can go live.',
    dialogues: Object.fromEntries(slugs.map((slug) => [slug, 'a'.repeat(64)])),
  })

  it('[go-live 1] passes on this repository: every approved dialogue has one publish migration', () => {
    expect(checkApprovedDialogues('content/approvals', 'supabase/migrations')).toEqual([])
  })

  it('[go-live 1] passes when approvals and publish migrations match', () => {
    expect(
      folders({ 'part-1.json': part(['a-cold-morning']) }, ['20261102000000_publish_a_cold_morning.sql']),
    ).toEqual([])
  })

  it('[go-live 1] finds an approved dialogue with no publish migration', () => {
    expect(folders({ 'part-1.json': part(['a-cold-morning']) }, [])).toEqual([
      'a-cold-morning is approved in part-1.json but has no publish migration',
    ])
  })

  it('[go-live 1] finds a publish migration no approval lists, and two for one dialogue', () => {
    const problems = folders({ 'part-1.json': part(['a-cold-morning']) }, [
      '20261102000000_publish_a_cold_morning.sql',
      '20261102000100_publish_a_cold_morning.sql',
      '20261102000200_publish_not_approved.sql',
    ])
    expect(problems).toContain(
      '20261102000200_publish_not_approved.sql publishes not-approved, which no approval file lists',
    )
    expect(problems.some((problem) => problem.startsWith('a-cold-morning has 2 publish migrations'))).toBe(
      true,
    )
  })

  it('[go-live 1] an approval file with no owner line counts for nothing', () => {
    const problems = folders({ 'part-1.json': { dialogues: { 'a-cold-morning': 'x' } } }, [
      '20261102000000_publish_a_cold_morning.sql',
    ])
    expect(problems).toContain('part-1.json has no approval line from the owner')
    expect(problems).toContain(
      '20261102000000_publish_a_cold_morning.sql publishes a-cold-morning, which no approval file lists',
    )
  })
})

describe('the live settings check', () => {
  const live = `https://${'a'.repeat(20)}.supabase.co`
  const test = `https://${'b'.repeat(20)}.supabase.co`
  const pooler = `postgresql://postgres.${'a'.repeat(20)}:made-up@aws-0-eu-central-1.pooler.supabase.com:5432/postgres`

  it('[go-live 1] passes when the live address and connection string name one project that is not the test project', () => {
    expect(
      checkLiveSettings({ LIVE_SUPABASE_URL: live, LIVE_DB_URL: pooler, TEST_SUPABASE_URL: test }),
    ).toEqual([])
    expect(checkLiveSettings({ LIVE_SUPABASE_URL: live, TEST_SUPABASE_URL: test })).toEqual([])
    expect(
      dbUrlNamesProject(
        `postgresql://postgres:made-up@db.${'a'.repeat(20)}.supabase.co:5432/postgres`,
        'a'.repeat(20),
      ),
    ).toBe(true)
  })

  it('[go-live 1] refuses the test project as the live one', () => {
    expect(checkLiveSettings({ LIVE_SUPABASE_URL: test, TEST_SUPABASE_URL: test })).toEqual([
      'The live project address is the test project. Nothing was changed.',
    ])
  })

  it('[go-live 1] refuses a connection string for another project, and missing or malformed addresses', () => {
    const other = pooler.replace('a'.repeat(20), 'b'.repeat(20))
    expect(
      checkLiveSettings({ LIVE_SUPABASE_URL: live, LIVE_DB_URL: other, TEST_SUPABASE_URL: test }),
    ).toEqual(['The live database connection string does not name the same project as SUPABASE_LIVE_URL.'])
    expect(checkLiveSettings({ TEST_SUPABASE_URL: test })).toHaveLength(1)
    expect(checkLiveSettings({ LIVE_SUPABASE_URL: live })).toHaveLength(1)
    expect(projectRef('https://example.com')).toBeNull()
  })

  it('[go-live 1] never prints a value: every message is fixed text', () => {
    const secretish = 'postgresql://postgres.zzzzzzzzzzzzzzzzzzzz:hunter2-made-up@host/postgres'
    const problems = checkLiveSettings({
      LIVE_SUPABASE_URL: live,
      LIVE_DB_URL: secretish,
      TEST_SUPABASE_URL: test,
    })
    expect(problems.join(' ')).not.toMatch(/hunter2|zzzz|aaaa|bbbb/)
  })
})

describe('the live migrations check', () => {
  const listing = [
    '',
    '   Local          | Remote         | Time (UTC)          ',
    '  ----------------|----------------|---------------------',
    '   20261019183410 | 20261019183410 | 2026-10-19 18:34:10 ',
    '   20261102000000 |                | 2026-11-02 00:00:00 ',
  ].join('\n')

  function migrations(names: string[]) {
    const dir = temp()
    for (const name of names) writeFileSync(join(dir, name), '-- made up\n')
    return dir
  }

  it('[go-live 1] reads only the Remote column of the Supabase CLI table', () => {
    expect([...remoteVersions(listing)]).toEqual(['20261019183410'])
  })

  it('[go-live 1] finds a migration, such as a publish migration, that is not live yet', () => {
    const dir = migrations(['20261019183410_create_visits.sql', '20261102000000_publish_a_cold_morning.sql'])
    const { problems, summary } = checkLiveMigrations(listing, dir)
    expect(problems).toEqual([
      '20261102000000_publish_a_cold_morning.sql is not in the live project yet. Run the "migrations" task.',
    ])
    expect(summary).toBe('1 migrations in the live project; 0 of the 1 publish migrations are among them.')
  })

  it('[go-live 1] passes when every migration is live, and finds one the branch does not have', () => {
    const dir = migrations(['20261019183410_create_visits.sql'])
    expect(checkLiveMigrations(listing, dir).problems).toEqual([])
    const extra = listing + '\n                  | 20261231000000 | 2026-12-31 00:00:00 '
    expect(checkLiveMigrations(extra, dir).problems).toEqual([
      "The live project has migration 20261231000000, which is not in this branch's supabase/migrations/.",
    ])
  })

  it('[go-live 1] an empty listing is a failure, not a pass', () => {
    expect(checkLiveMigrations('', migrations([])).problems).toEqual([
      'The migration list shows no migration in the live project.',
    ])
  })
})

describe('the live build check', () => {
  function build(config: Record<string, unknown>, files: Record<string, string>) {
    const root = temp()
    mkdirSync(join(root, '.wrangler', 'deploy'), { recursive: true })
    mkdirSync(join(root, 'dist', 'worker'), { recursive: true })
    mkdirSync(join(root, 'dist', 'client', 'assets'), { recursive: true })
    writeFileSync(
      join(root, '.wrangler', 'deploy', 'config.json'),
      JSON.stringify({ configPath: '../../dist/worker/wrangler.json' }),
    )
    writeFileSync(
      join(root, 'dist', 'worker', 'wrangler.json'),
      JSON.stringify({ assets: { directory: '../client' }, ...config }),
    )
    for (const [name, body] of Object.entries(files)) writeFileSync(join(root, 'dist', 'client', name), body)
    return checkLiveBuild(root)
  }
  const good = {
    name: 'aleksi',
    workers_dev: false,
    preview_urls: false,
    routes: LIVE_ROUTES,
    vars: { CANONICAL_HOST: 'meetaleksi.com' },
  }
  const landing = '<meta property="og:url" content="https://meetaleksi.com/" />'

  it('[go-live 1] passes on the live Worker with no design pages', () => {
    expect(build(good, { 'landing.html': landing, 'assets/index.js': 'app' })).toEqual([])
  })

  it('[go-live 1] refuses the preview Worker config', () => {
    const problems = build(
      { name: 'puhuscribe-preview', workers_dev: true, preview_urls: true },
      { 'landing.html': landing },
    )
    expect(problems).toContain('The built Worker is not named aleksi. Was CLOUDFLARE_ENV=production set?')
    expect(problems).toContain('The built Worker would get a workers.dev address.')
    expect(problems).toContain('The built Worker would get preview addresses.')
  })

  it('[go-live 1] refuses design pages, the fake speech provider and the old landing address', () => {
    const problems = build(
      { ...good, vars: { CANONICAL_HOST: 'meetaleksi.com', SPEECH_FEEDBACK_PROVIDER: 'fake' } },
      {
        'landing.html': '<meta property="og:url" content="https://puhuscribe.exentrik.co/" />',
        'assets/DesignReference.js': 'Design reference',
      },
    )
    expect(problems).toContain(
      'The built Worker sets variables other than CANONICAL_HOST: CANONICAL_HOST, SPEECH_FEEDBACK_PROVIDER',
    )
    expect(problems.some((problem) => problem.includes('holds design page text'))).toBe(true)
    expect(problems).toContain('landing.html has no og:url of https://meetaleksi.com/.')
  })
})
