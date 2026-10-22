import { spawnSync } from 'node:child_process'
import { randomBytes } from 'node:crypto'
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { dirname, join } from 'node:path'
import { afterEach, describe, expect, it } from 'vitest'
import { INSTALL, LEAKS_FOUND, missingMessage, SECRET_FOUND_ADVICE } from './commit-tool.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/4-tooling/spec.md that each test protects.
//
// The commit check starts gitleaks and ruff through commit-tool.ts. These tests
// run it with a PATH that holds only Node, so neither tool (nor Python) can be
// found, and check that the commit is refused with one line naming the free
// install command.

const TOOL = join(import.meta.dirname, 'commit-tool.ts')
const onlyNode = { ...process.env, PATH: dirname(process.execPath), Path: dirname(process.execPath) }

function run(...args: string[]) {
  return spawnSync(process.execPath, [TOOL, ...args], { encoding: 'utf8', env: onlyNode })
}

describe('a missing tool fails safely and says how to fix it', () => {
  it.each(Object.keys(INSTALL) as (keyof typeof INSTALL)[])(
    '[tooling 13] refuses the commit with one line naming the install command when %s is missing',
    (tool) => {
      const result = run(tool, '--help')
      expect(result.status).toBe(1)
      const lines = `${result.stdout}${result.stderr}`.trim().split('\n')
      expect(lines).toEqual([missingMessage(tool)])
      expect(lines[0]).toContain(INSTALL[tool])
    },
  )

  it('[tooling 13] names the commands the README lists for the one time installs', () => {
    expect(INSTALL.gitleaks).toBe('winget install --id Gitleaks.Gitleaks -e')
    expect(INSTALL.ruff).toContain('-r scripts/requirements-dev.txt')
  })

  it('[tooling 13] the README "Run it locally" section lists both one time installs', () => {
    const readme = readFileSync('README.md', 'utf8')
    const runLocally = readme.slice(
      readme.indexOf('## Run it locally'),
      readme.indexOf('## Database changes'),
    )
    expect(runLocally).toContain(`\`${INSTALL.gitleaks}\``)
    expect(runLocally).toContain(`\`${INSTALL.ruff}\``)
  })

  it('[tooling 13] the refusal says what to do after installing', () => {
    for (const tool of Object.keys(INSTALL) as (keyof typeof INSTALL)[]) {
      expect(missingMessage(tool)).toMatch(/ Then commit again\.$/)
    }
  })

  it('[tooling 13] a commit is refused when the git hook cannot find lefthook itself', () => {
    const lefthook = readFileSync('lefthook.yml', 'utf8')
    expect(lefthook).toMatch(/^assert_lefthook_installed: true$/m)
  })

  it('[tooling 9] the secret scan stays redacted and prints no matched line', () => {
    const lefthook = readFileSync('lefthook.yml', 'utf8')
    const scan = lefthook.split(/\r?\n/).find((line) => line.includes('commit-tool.ts gitleaks'))
    expect(scan).toContain('--redact')
    expect(scan).not.toMatch(/--verbose|\s-v(\s|$)/)
  })

  it('[tooling 13] refuses an unknown tool name', () => {
    expect(run('curl', 'https://example.com').status).toBe(2)
  })
})

describe('the secret advice appears only for a real finding', () => {
  const hasGitleaks = spawnSync('gitleaks', ['version']).status === 0
  const scanArgs = [
    'git',
    '--pre-commit',
    '--staged',
    '--redact',
    '--no-banner',
    '--exit-code',
    String(LEAKS_FOUND),
  ]
  const dirs: string[] = []

  afterEach(() => {
    for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true })
  })

  function repoWith(content: string): string {
    const dir = mkdtempSync(join(tmpdir(), 'puhuscribe-commit-tool-'))
    dirs.push(dir)
    spawnSync('git', ['init', '-q'], { cwd: dir })
    writeFileSync(join(dir, 'staged.ts'), content)
    spawnSync('git', ['add', 'staged.ts'], { cwd: dir })
    return dir
  }

  function scan(cwd: string, extra: string[] = []) {
    const result = spawnSync(process.execPath, [TOOL, 'gitleaks', ...scanArgs, ...extra], {
      cwd,
      encoding: 'utf8',
    })
    return { status: result.status, output: `${result.stdout}${result.stderr}` }
  }

  it('[tooling 13] lefthook.yml asks gitleaks for the finding exit code and sets no fail_text on the scan', () => {
    const lefthook = readFileSync('lefthook.yml', 'utf8').replace(/\r\n/g, '\n')
    const job = lefthook.slice(lefthook.indexOf('- name: secrets'))
    expect(job).toContain(`commit-tool.ts gitleaks ${scanArgs.join(' ')}`)
    expect(lefthook).not.toMatch(/^\s*fail_text:/m)
  })

  it('[tooling 13] a missing gitleaks gives only the install line, never the secret advice', () => {
    const result = run('gitleaks', ...scanArgs)
    expect(result.status).toBe(1)
    expect(`${result.stdout}${result.stderr}`).not.toContain(SECRET_FOUND_ADVICE)
  })

  it.skipIf(!hasGitleaks)(
    '[tooling 9] a made-up key is refused with the advice, and its value is never printed',
    () => {
      const key = ['gh', 'p_'].join('') + randomBytes(64).toString('hex').slice(0, 36)
      const result = scan(repoWith(`export const githubToken = '${key}'\n`))
      expect(result.status).toBe(1)
      expect(result.output).toContain(SECRET_FOUND_ADVICE)
      expect(result.output).not.toContain(key)
    },
  )

  it.skipIf(!hasGitleaks)('[tooling 13] a clean change passes with no advice', () => {
    const result = scan(repoWith("export const greeting = 'hei'\n"))
    expect(result.status).toBe(0)
    expect(result.output).not.toContain(SECRET_FOUND_ADVICE)
  })

  it.skipIf(!hasGitleaks)('[tooling 13] a gitleaks failure that is not a finding gets no advice', () => {
    // A config file that does not exist. gitleaks stops with its own error
    // (exit 1), which is not a finding.
    const result = scan(repoWith("export const greeting = 'hei'\n"), ['--config', 'no-such-config.toml'])
    expect(result.status).toBe(1)
    expect(result.output).not.toContain(SECRET_FOUND_ADVICE)
  })
})
