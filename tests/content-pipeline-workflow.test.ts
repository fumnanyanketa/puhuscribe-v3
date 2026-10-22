import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'

// Labels [content N] are the "Done when" statement numbers from
// factory/jobs/7-content-pipeline/spec.md that each test protects.
//
// The workflow files are read as text, as in tests/checks-workflow.test.ts.

const pipeline = readFileSync('.github/workflows/content-pipeline.yml', 'utf8').replace(/\r\n/g, '\n')
const checks = readFileSync('.github/workflows/checks.yml', 'utf8').replace(/\r\n/g, '\n')

// The steps of the pipeline job, each as its own text block.
function steps(text: string): string[] {
  const body = text.slice(text.indexOf('\n    steps:\n') + '\n    steps:\n'.length)
  return body.split(/\n(?= {6}- )/).filter((step) => step.trim().startsWith('- '))
}

function step(name: string): string {
  const found = steps(pipeline).find((s) => s.includes(`name: ${name}`))
  if (!found) throw new Error(`No step "${name}"`)
  return found
}

function job(text: string, id: string): string {
  const start = text.indexOf(`\n  ${id}:\n`)
  if (start < 0) throw new Error(`No job ${id}`)
  const rest = text.slice(start + 1)
  const next = rest.slice(1).search(/\n {2}[a-z0-9-]+:\n/)
  return next < 0 ? rest : rest.slice(0, next + 1)
}

describe('the content pipeline workflow', () => {
  it('[content 2] is called "Content pipeline" and runs only on manual start, never on a pull request or push', () => {
    expect(pipeline).toMatch(/^name: Content pipeline$/m)
    const on = pipeline.slice(pipeline.indexOf('\non:\n'), pipeline.indexOf('\npermissions:'))
    expect(on).toContain('\n  workflow_dispatch:\n')
    expect(on).not.toMatch(
      /\n {2}(push|pull_request|pull_request_target|schedule|workflow_run|repository_dispatch):/,
    )
  })

  it('[content 2] takes the brief path as an input and checks it before use', () => {
    expect(pipeline).toContain('content/briefs/<slug>.json')
    expect(step('Check the inputs')).toContain('^content/briefs/[a-z0-9]+(-[a-z0-9]+)*\\.json$')
  })

  it('[content 2] runs on Linux with Voikko and the real providers', () => {
    expect(pipeline).toContain('runs-on: ubuntu-latest')
    expect(pipeline).toContain('libvoikko1 voikko-fi')
    const run = step('Run the pipeline')
    expect(run).toContain('AI_PROVIDER: anthropic')
    expect(run).toContain('VOICE_PROVIDER: azure')
    expect(run).toContain('python scripts/generate/pipeline.py run --brief "$TARGET"')
  })

  it('[content 2] the inputs reach the shell only as environment variables', () => {
    for (const s of steps(pipeline)) {
      const run = s.slice(s.indexOf('run:'))
      if (s.includes('run:')) expect(run, s).not.toContain('${{ inputs.')
    }
  })

  it('[content 2] the keys reach only the pipeline step and the upload guard', () => {
    const withSecrets = steps(pipeline).filter((s) => s.includes('secrets.'))
    expect(withSecrets.map((s) => /name: (.+)/.exec(s)?.[1])).toEqual([
      'Run the pipeline',
      'Check the files to upload hold no secret value',
    ])
    expect(pipeline.slice(0, pipeline.indexOf('\njobs:\n'))).not.toContain('secrets.')
    expect(pipeline).not.toMatch(/^ {4}env:/m)
  })

  it('[content 2] runs no npm install and no package code next to the keys, and uses only GitHub actions', () => {
    const code = pipeline
      .split('\n')
      .filter((line) => !line.trim().startsWith('#'))
      .join('\n')
    expect(code).not.toMatch(/\bnpm\b|\bnpx\b|\byarn\b|\bpnpm\b/)
    const actions = [...pipeline.matchAll(/uses: (\S+)/g)].map((m) => m[1] ?? '')
    expect(actions.every((a) => a.startsWith('actions/'))).toBe(true)
    expect(pipeline).toContain('persist-credentials: false')
    expect(pipeline).toMatch(/^permissions:\n {2}contents: read$/m)
  })

  it('[content 2] the artifact passes check-files-for-secrets.ts before it is uploaded', () => {
    const all = steps(pipeline)
    const guard = all.findIndex((s) => s.includes('id: upload-guard'))
    const upload = all.findIndex((s) => s.includes('actions/upload-artifact'))
    expect(guard).toBeGreaterThan(-1)
    expect(upload).toBeGreaterThan(guard)
    expect(all[guard]).toContain('node scripts/ci/check-files-for-secrets.ts')
    expect(all[guard]).toContain('--env ANTHROPIC_API_KEY --env AZURE_SPEECH_KEY')
    expect(all[upload]).toContain("steps.upload-guard.outcome == 'success'")
  })
})

describe('the pull request checks run the content checks', () => {
  const python = job(checks, 'python')
  const database = job(checks, 'database')

  it('[content 12] the Python check runs the content checks on every committed draft with the network off', () => {
    expect(python).toContain('python scripts/generate/pipeline.py check-committed')
    const line = python.split('\n').findIndex((l) => l.includes('pipeline.py check-committed'))
    expect(python.split('\n')[line - 1]).toContain('sudo unshare --net')
  })

  it('[content 12] the count guard is raised to the new total and still requires the 9 Voikko gate tests', () => {
    expect(python).not.toContain('All 9 Voikko gate tests ran and passed')
    expect(python).toMatch(/name: All \d+ Python tests ran and passed \(the 9 Voikko gate tests among them\)/)
    const total = /All (\d+) Python tests/.exec(python)?.[1]
    expect(Number(total)).toBeGreaterThan(9)
    expect(python).toContain(
      `assert counts == {"tests": ${String(total)}, "failures": 0, "errors": 0, "skipped": 0}, counts`,
    )
    expect(python).toContain('assert len(v2) == 9, v2')
  })

  it('[content 16] the database check runs every publish migration a second time before the pgTAP tests run again', () => {
    expect(database).toContain('for file in supabase/migrations/*_publish_*.sql; do')
    const lines = database.split('\n')
    const again = lines.findIndex((l) => l.includes('_publish_*.sql'))
    const tests = lines.flatMap((l, i) => (l.endsWith('supabase test db') ? [i] : []))
    expect(tests.at(-1)).toBeGreaterThan(again)
  })

  it('[content 12] pip-audit also checks the pipeline packages', () => {
    expect(job(checks, 'dependencies')).toContain(
      'pip-audit -r scripts/requirements.txt -r scripts/requirements-pipeline.txt',
    )
  })
})
