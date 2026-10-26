import { readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.
// Rules about where the speech service may be called from, and where the
// fake provider may be switched on.

const MODULE = 'worker/providers/speech-feedback.ts'

function codeFiles(dir: string): string[] {
  return readdirSync(dir, { recursive: true, encoding: 'utf8' })
    .filter((file) => /\.(ts|tsx|js|mjs)$/.test(file))
    .map((file) => join(dir, file).replace(/\\/g, '/'))
}

// Every code file of the app, the Worker, the scripts and the browser tests.
// Unit test files are left out: they assert the address the module calls.
// The Python content pipeline (scripts/generate/) has its own voice module,
// checked by scripts/generate/test_content_providers.py.
const FILES = ['src', 'worker', 'scripts', 'e2e', 'tests']
  .flatMap(codeFiles)
  .filter((file) => !file.startsWith('scripts/generate/') && !/\.test\.tsx?$/.test(file))

describe('one module calls the speech service', () => {
  it('[speak 12] no file but the provider module names an Azure speech address', () => {
    expect(FILES.length).toBeGreaterThan(40)
    expect(FILES).toContain(MODULE)
    const named = FILES.filter((file) =>
      /speech\.microsoft\.com|cognitiveservices|api\.cognitive\.microsoft/i.test(readFileSync(file, 'utf8')),
    )
    expect(named).toEqual([MODULE])
  })

  it('[speak 12] [speak 24] no file but the provider module reads the Azure key; the preview set up only hands it to the Worker as a secret', () => {
    const named = FILES.filter((file) => readFileSync(file, 'utf8').includes('AZURE_SPEECH_KEY'))
    expect(named.sort()).toEqual([MODULE, 'scripts/ci/write-test-settings.ts'].sort())
    // write-test-settings.ts copies the value into the Worker's secrets file
    // and prints only names; it never calls a speech service.
    expect(readFileSync('scripts/ci/write-test-settings.ts', 'utf8')).not.toMatch(/fetch\(|https:/)
  })

  it('[speak 12] the provider module is the only one that sends the key header', () => {
    const named = FILES.filter((file) => /Ocp-Apim-Subscription-Key/i.test(readFileSync(file, 'utf8')))
    expect(named).toEqual([MODULE])
  })
})

// The workflow file is read as text and split into its jobs (as
// tests/checks-workflow.test.ts does), so no YAML package is needed.
function jobs(text: string): Map<string, string> {
  const body = text.replace(/\r\n/g, '\n')
  const start = body.indexOf('\njobs:\n')
  const found = new Map<string, string>()
  if (start === -1) return found
  let current: string | undefined
  let lines: string[] = []
  for (const line of body.slice(start + 7).split('\n')) {
    const name = /^ {2}([a-z0-9-]+):$/.exec(line)
    if (name?.[1]) {
      if (current) found.set(current, lines.join('\n'))
      current = name[1]
      lines = []
    } else {
      lines.push(line)
    }
  }
  if (current) found.set(current, lines.join('\n'))
  return found
}

describe('the fake provider never reaches a deployed Worker', () => {
  it('[speak 12] wrangler.jsonc does not set the speech provider at all', () => {
    expect(readFileSync('wrangler.jsonc', 'utf8')).not.toMatch(/SPEECH_FEEDBACK_PROVIDER|fake/i)
  })

  it('[speak 12] no job that uploads or deploys the Worker sets the fake provider', () => {
    const workflows = readdirSync('.github/workflows').filter((name) => /\.ya?ml$/.test(name))
    let deployJobs = 0
    for (const name of workflows) {
      for (const [id, text] of jobs(readFileSync(join('.github/workflows', name), 'utf8'))) {
        if (!/wrangler (versions upload|deploy)|wrangler-action/.test(text)) continue
        deployJobs += 1
        expect(text, `${name} ${id}`).not.toMatch(/SPEECH_FEEDBACK_PROVIDER/)
        expect(text, `${name} ${id}`).not.toMatch(/speech-fixture/)
      }
    }
    expect(deployJobs).toBeGreaterThan(0)
  })

  it('[speak 12] the fake is switched on only in the pull request browser tests, on the runner', () => {
    const checks = jobs(readFileSync('.github/workflows/checks.yml', 'utf8'))
    const setting = [...checks]
      .filter(([, text]) => text.includes('SPEECH_FEEDBACK_PROVIDER'))
      .map(([id]) => id)
    expect(setting).toEqual(['browser'])
    expect(checks.get('browser')).toContain('echo "SPEECH_FEEDBACK_PROVIDER=fake" >> .env.local')
  })
})
