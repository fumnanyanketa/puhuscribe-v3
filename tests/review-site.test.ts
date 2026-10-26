import { spawnSync } from 'node:child_process'
import { readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'

// Labels [site N] are the "Done when" statement numbers from
// factory/jobs/13-review-site/spec.md that each test protects.
//
// The review site's list, Worker config, workflow and docs, read as text. The
// workflow is split into its jobs and steps without a YAML package, as in
// tests/checks-workflow.test.ts.

const read = (path: string) => readFileSync(path, 'utf8').replace(/\r\n/g, '\n')

// JSONC to JSON: drops // and /* */ comments outside strings, then trailing commas.
function parseJsonc(text: string): unknown {
  let out = ''
  let i = 0
  let inString = false
  while (i < text.length) {
    const char = text[i] ?? ''
    const next = text[i + 1] ?? ''
    if (inString) {
      out += char
      if (char === '\\') {
        out += next
        i += 2
        continue
      }
      if (char === '"') inString = false
      i++
    } else if (char === '"') {
      inString = true
      out += char
      i++
    } else if (char === '/' && next === '/') {
      while (i < text.length && text[i] !== '\n') i++
    } else if (char === '/' && next === '*') {
      i = text.indexOf('*/', i + 2) + 2
    } else {
      out += char
      i++
    }
  }
  return JSON.parse(out.replace(/,(\s*[}\]])/g, '$1'))
}

const EMAIL = /[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}/

function filesUnder(folder: string): string[] {
  return readdirSync(folder, { recursive: true, encoding: 'utf8' })
    .map((name) => join(folder, name))
    .filter((path) => statSync(path).isFile())
}

describe('the list', () => {
  const text = read('review-site/dialogues.json')
  const list = JSON.parse(text) as Record<string, unknown>

  it('[site 1] holds only dialogue slugs, under one key', () => {
    expect(Object.keys(list)).toEqual(['dialogues'])
    const slugs = list.dialogues as unknown[]
    expect(Array.isArray(slugs)).toBe(true)
    for (const slug of slugs) expect(slug).toMatch(/^[a-z0-9]+(-[a-z0-9]+)*$/)
    expect(new Set(slugs).size).toBe(slugs.length)
    expect(text).not.toMatch(EMAIL)
    expect(text).not.toContain('@')
  })

  it("[site 1] starts with meeting-people-new-colleague (owner's call 2, A)", () => {
    expect(list.dialogues).toEqual(['meeting-people-new-colleague'])
  })

  it("[site 1] docs/content-pipeline.md says only the manager edits it, on the owner's instruction", () => {
    const docs = read('docs/content-pipeline.md')
    expect(docs).toContain(
      "Only the manager edits `review-site/dialogues.json`, on the owner's instruction, as with `content/reviews/`.",
    )
  })
})

interface WranglerConfig {
  name?: string
  main?: string
  workers_dev?: boolean
  preview_urls?: boolean
  routes?: unknown
  assets?: Record<string, unknown>
  observability?: { enabled?: boolean }
  [key: string]: unknown
}

describe('the review Worker', () => {
  const config = parseJsonc(read('review-site/wrangler.jsonc')) as WranglerConfig

  it('[site 9] is its own Worker, puhuscribe-review, serving dist-review/ through review-site/worker.ts', () => {
    expect(config.name).toBe('puhuscribe-review')
    expect(config.main).toBe('worker.ts')
    expect(config.assets).toEqual({
      directory: '../dist-review',
      binding: 'ASSETS',
      not_found_handling: 'none',
      run_worker_first: true,
    })
    // html_handling stays at its default, so /<slug>/round-1 serves round-1.html.
    expect(config.assets).not.toHaveProperty('html_handling')
  })

  it('[site 9] has no workers.dev or preview address, one custom domain route, and nothing else bound', () => {
    expect(config.workers_dev).toBe(false)
    expect(config.preview_urls).toBe(false)
    expect(config.routes).toEqual([{ pattern: 'puhuscribe.exentrik.co', custom_domain: true }])
    expect(Object.keys(config).sort()).toEqual(
      [
        '$schema',
        'name',
        'main',
        'compatibility_date',
        'workers_dev',
        'preview_urls',
        'routes',
        'assets',
        'observability',
      ].sort(),
    )
  })

  it('[site 8] keeps no logs and never reads who signed in', () => {
    expect(config.observability).toEqual({ enabled: false })
    for (const file of ['review-site/worker.ts', 'review-site/handler.ts']) {
      const code = read(file)
      expect(code, file).not.toMatch(/\bconsole\b/)
      expect(code, file).not.toMatch(/email/i)
      // The token is checked, never opened for its claims.
      expect(code, file).not.toMatch(/\.payload\b|decodeJwt|\bpayload\b/)
    }
  })

  it("[site 9] the app's wrangler.jsonc still names puhuscribe-preview and has no review site route", () => {
    const app = parseJsonc(read('wrangler.jsonc')) as WranglerConfig
    expect(app.name).toBe('puhuscribe-preview')
    expect(app.main).toBe('worker/index.ts')
    expect(app).not.toHaveProperty('routes')
    expect(read('wrangler.jsonc')).not.toContain('exentrik')
  })
})

const workflow = read('.github/workflows/review-site.yml')

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
  if (text === undefined) throw new Error(`No job ${id} in review-site.yml`)
  return text
}

function steps(jobText: string): string[] {
  const body = jobText.slice(jobText.indexOf('\n    steps:\n') + '\n    steps:\n'.length)
  return body.split(/\n(?= {6}- )/).filter((s) => s.trim().startsWith('- '))
}

function stepName(step: string): string {
  return /name: (.+)/.exec(step)?.[1] ?? /(uses|run): (.+)/.exec(step)?.[2] ?? ''
}

describe('the review site workflow', () => {
  it('[site 10] runs on pull requests and pushes to main that touch the site, and on a manual start', () => {
    const on = workflow.slice(workflow.indexOf('\non:\n'), workflow.indexOf('\npermissions:'))
    expect(on).toContain('\n  pull_request:\n')
    expect(on).toContain('\n  workflow_dispatch:\n')
    expect(on).not.toMatch(/pull_request_target|workflow_run|schedule|repository_dispatch/)
    const push = on.slice(on.indexOf('\n  push:\n'), on.indexOf('\n  workflow_dispatch:'))
    expect(push).toContain('branches: [main]')
    for (const path of [
      'review-site/**',
      'scripts/review-site/**',
      'content/drafts/*/review/**',
      'content/reviews/**',
      '.github/workflows/review-site.yml',
    ]) {
      expect(push).toContain(`- '${path}'`)
    }
  })

  it('[site 10] on a pull request it builds, runs the site tests and a deploy dry run, with no secret', () => {
    const build = job('build')
    expect(build).not.toMatch(/^ {4}if:/m)
    const run = steps(build).join('\n')
    expect(run).toContain('npm run build:review-site')
    expect(run).toContain('npx vitest run scripts/review-site review-site tests/review-site.test.ts')
    expect(run).toContain('npx wrangler deploy --dry-run --config review-site/wrangler.jsonc')
    expect(build).not.toContain('secrets.')
    expect(build).not.toContain('vars.')
  })

  it('[site 10] [public 1] in this public repository, every job that runs on a pull request (forks included) holds no secret', () => {
    expect(workflow).not.toMatch(/pull_request_target/)
    for (const [id, text] of all) {
      if (!text.includes('secrets.')) continue
      const condition = /^ {4}if: (.+)$/m.exec(text)?.[1] ?? ''
      expect(condition, id).toContain("github.event_name != 'pull_request'")
      expect(condition, id).not.toContain('||')
    }
  })

  it('[site 10] deploys only from main, never on a pull request and never for Dependabot', () => {
    const deploy = job('deploy')
    expect(deploy).toContain('    needs: [build]\n')
    const condition = /^ {4}if: (.+)$/m.exec(deploy)?.[1] ?? ''
    expect(condition).toContain("github.event_name != 'pull_request'")
    expect(condition).toContain("github.ref == 'refs/heads/main'")
    expect(condition).toContain("github.actor != 'dependabot[bot]'")
    expect(condition).not.toContain('||')
    expect(deploy).toContain('npx wrangler deploy --config review-site/wrangler.jsonc')
    expect(workflow.match(/wrangler deploy(?! --dry-run)/g)).toHaveLength(1)
  })

  it('[site 10] reads the repository only, keeps no git credentials and pins actions', () => {
    expect(workflow).toMatch(/^permissions:\n {2}contents: read$/m)
    expect(workflow).not.toMatch(/: write\b/)
    const checkouts = workflow.match(/uses: actions\/checkout@\S+/g) ?? []
    expect(checkouts.length).toBeGreaterThan(0)
    expect(workflow.match(/persist-credentials: false/g)).toHaveLength(checkouts.length)
    for (const [, action = ''] of workflow.matchAll(/uses: (\S+)(.*)/g)) {
      // GitHub's own actions by version; any other action by full commit with
      // its version in a comment.
      if (!action.startsWith('actions/')) expect(action).toMatch(/@[0-9a-f]{40}$/)
    }
    for (const line of workflow.split('\n').filter((l) => /uses: (?!actions\/)/.test(l))) {
      expect(line).toMatch(/@[0-9a-f]{40} # v\d/)
    }
  })

  it('[site 10] the deploy job has its own concurrency group that never cancels a running deploy', () => {
    const deploy = job('deploy')
    expect(deploy).toContain(
      '    concurrency:\n      group: review-site-deploy\n      cancel-in-progress: false\n',
    )
    expect(workflow).toContain(
      "group: review-site-${{ github.event_name == 'pull_request' && github.ref || github.run_id }}",
    )
  })

  it('[site 10] [site 11] secrets reach only the deploy step and the live test step', () => {
    expect(workflow.slice(0, workflow.indexOf('\njobs:\n'))).not.toContain('secrets.')
    const withSecrets = [...all].flatMap(([id, text]) =>
      steps(text)
        .filter((s) => s.includes('secrets.'))
        .map((s) => `${id}: ${stepName(s)}`),
    )
    expect(withSecrets).toEqual([
      'deploy: Deploy puhuscribe-review to the Exentrik account',
      'deploy: Live tests of the review site, with its Access service token',
    ])
    const secretNames = [...workflow.matchAll(/secrets\.([A-Z_]+)/g)].map((m) => m[1]).sort()
    expect(secretNames).toEqual([
      'CLOUDFLARE_REVIEW_ACCOUNT_ID',
      'CLOUDFLARE_REVIEW_API_TOKEN',
      'REVIEW_CF_ACCESS_CLIENT_ID',
      'REVIEW_CF_ACCESS_CLIENT_SECRET',
    ])
    // The PuhuScribe account's token and service token never reach this workflow.
    expect(workflow).not.toMatch(/secrets\.(CLOUDFLARE_API_TOKEN|CLOUDFLARE_ACCOUNT_ID|CF_ACCESS_CLIENT_)/)
    for (const id of all.keys()) expect(job(id)).not.toMatch(/^ {4}env:/m)
  })

  it('[site 11] passes the two Access settings as plain variables and refuses to deploy when either is empty', () => {
    const deploy = steps(job('deploy')).find((s) => s.includes('id: deploy')) ?? ''
    expect(deploy).toContain('ACCESS_TEAM_DOMAIN: ${{ vars.REVIEW_ACCESS_TEAM_DOMAIN }}')
    expect(deploy).toContain('ACCESS_AUD: ${{ vars.REVIEW_ACCESS_AUD }}')
    expect(deploy).toContain('--var "ACCESS_TEAM_DOMAIN:$ACCESS_TEAM_DOMAIN"')
    expect(deploy).toContain('--var "ACCESS_AUD:$ACCESS_AUD"')
    // Empty settings: no wrangler deploy is reached.
    const run = deploy.slice(deploy.indexOf('run: |'))
    const deployLine = run.indexOf('npx wrangler deploy')
    for (const guard of [
      '[ -n "$ACCESS_TEAM_DOMAIN" ] || missing+=(REVIEW_ACCESS_TEAM_DOMAIN)',
      '[ -n "$ACCESS_AUD" ] || missing+=(REVIEW_ACCESS_AUD)',
      '[ -n "$CLOUDFLARE_API_TOKEN" ] || missing+=(CLOUDFLARE_REVIEW_API_TOKEN)',
      '[ -n "$CLOUDFLARE_ACCOUNT_ID" ] || missing+=(CLOUDFLARE_REVIEW_ACCOUNT_ID)',
    ]) {
      expect(run.indexOf(guard), guard).toBeGreaterThan(-1)
      expect(run.indexOf(guard), guard).toBeLessThan(deployLine)
    }
    expect(run.indexOf('if [ ${#missing[@]} -gt 0 ]; then')).toBeLessThan(deployLine)
  })

  it('[site 10] while nothing is set up yet, the deploy is skipped with a notice and the job stays green', () => {
    const deploy = steps(job('deploy')).find((s) => s.includes('id: deploy')) ?? ''
    const skip = deploy.slice(deploy.indexOf('if [ ${#missing[@]} -eq 4 ]; then'), deploy.indexOf('fi\n'))
    expect(skip).toContain('::notice title=Review site not deployed::')
    expect(skip).toContain('echo "deployed=false" >> "$GITHUB_OUTPUT"')
    expect(skip).toContain('exit 0')
    for (const s of steps(job('deploy')).filter((x) => /Install Chromium|id: live/.test(x))) {
      expect(s).toContain("if: steps.deploy.outputs.deployed == 'true'")
    }
  })

  it('[site 14] [site 19] the live tests run only the @review-site tests, and only clean files are uploaded', () => {
    const all = steps(job('deploy'))
    const live = all.find((s) => s.includes('id: live')) ?? ''
    expect(live).toContain('REVIEW_SITE_URL: https://puhuscribe.exentrik.co')
    expect(live).toContain('CF_ACCESS_CLIENT_ID: ${{ secrets.REVIEW_CF_ACCESS_CLIENT_ID }}')
    expect(live).toContain('CF_ACCESS_CLIENT_SECRET: ${{ secrets.REVIEW_CF_ACCESS_CLIENT_SECRET }}')
    expect(live).toContain('REVIEW_WORKERS_SUBDOMAIN: ${{ vars.REVIEW_WORKERS_SUBDOMAIN }}')
    expect(live).toContain('npx playwright test --grep @review-site')
    expect(live).toContain("PUHUSCRIBE_NO_TRACE: '1'")
    expect(live).not.toMatch(/--trace|--reporter=html/)
    expect(live).toContain('node scripts/ci/check-files-for-secrets.ts')
    expect(live).toContain('--env CF_ACCESS_CLIENT_ID --env CF_ACCESS_CLIENT_SECRET')
    expect(live).toContain('test-results playwright-report')
    expect(live.indexOf('npx playwright test')).toBeLessThan(live.indexOf('check-files-for-secrets'))
    const upload = all.find((s) => s.includes('actions/upload-artifact')) ?? ''
    expect(all.indexOf(upload)).toBeGreaterThan(all.indexOf(live))
    expect(upload).toContain("steps.live.outputs.clean == 'true'")
    const paths = upload
      .slice(upload.indexOf('path: |'))
      .split('\n')
      .slice(1, 3)
      .map((l) => l.trim())
    expect(paths).toEqual(['test-results/**/*.png', 'test-results/**/*.webm'])
  })
})

describe('line endings', () => {
  // On a Windows checkout git may turn LF into CRLF, and then Prettier fails
  // npm run check:code. Every file of this job must check out with LF.
  it('[site 9] [site 10] every review site file checks out with LF on every machine', () => {
    const files = [
      ...filesUnder('review-site'),
      ...filesUnder('scripts/review-site'),
      '.github/workflows/review-site.yml',
      'e2e/review-site.spec.ts',
      'e2e/review-site-index.spec.ts',
      'tests/review-site.test.ts',
    ].map((f) => f.replaceAll('\\', '/'))
    const result = spawnSync('git', ['check-attr', 'eol', '--', ...files], { encoding: 'utf8' })
    expect(result.status).toBe(0)
    const lines = result.stdout.trim().split('\n')
    expect(lines).toHaveLength(files.length)
    for (const line of lines) expect(line).toMatch(/: eol: lf$/)
  })
})

describe('settings without emails', () => {
  it('[site 11] no email address in review-site/, scripts/review-site/ or the workflow', () => {
    const files = [
      ...filesUnder('review-site'),
      ...filesUnder('scripts/review-site'),
      '.github/workflows/review-site.yml',
      'e2e/review-site.spec.ts',
      'e2e/review-site-index.spec.ts',
    ]
    expect(files.length).toBeGreaterThan(5)
    for (const file of files) expect(read(file), file).not.toMatch(EMAIL)
  })

  it('[site 11] .env.example and docs/content-pipeline.md name both Access variables and the new secrets', () => {
    const example = read('.env.example')
    const docs = read('docs/content-pipeline.md')
    for (const name of ['REVIEW_ACCESS_TEAM_DOMAIN', 'REVIEW_ACCESS_AUD']) {
      expect(example, name).toContain(name)
      expect(docs, name).toContain(name)
    }
    for (const name of [
      'CLOUDFLARE_REVIEW_API_TOKEN',
      'CLOUDFLARE_REVIEW_ACCOUNT_ID',
      'REVIEW_CF_ACCESS_CLIENT_ID',
      'REVIEW_CF_ACCESS_CLIENT_SECRET',
      'REVIEW_WORKERS_SUBDOMAIN',
    ]) {
      expect(example, name).toContain(name)
      expect(docs, name).toContain(name)
    }
  })
})

describe('written down', () => {
  it('[site 20] docs/content-pipeline.md steps 5 and 6 send the reviewer the site link', () => {
    const docs = read('docs/content-pipeline.md')
    expect(docs).toContain('https://puhuscribe.exentrik.co/<dialogue-slug>/round-<n>')
    expect(docs).toMatch(/\n5\. .*review-site\/dialogues\.json/)
    expect(docs).toMatch(/\n6\. .*content\/reviews\/<dialogue-slug>\/round-<n>\.json/)
  })

  it('[site 20] docs/conventions.md adds the review-site/ folder and the [site N] label', () => {
    const conventions = read('docs/conventions.md')
    expect(conventions).toContain('| `review-site/` |')
    expect(conventions).toContain('| 13-review-site | `[site N]` |')
  })

  it('[site 20] the README running costs list the review Worker and Access seats at €0', () => {
    const readme = read('README.md')
    const costs = readme.slice(readme.indexOf('## Running costs'))
    expect(costs).toMatch(/`puhuscribe-review`.*Workers Free.*€0/)
    expect(costs).toMatch(/Access.*2 of 50 seats.*€0/)
  })
})
