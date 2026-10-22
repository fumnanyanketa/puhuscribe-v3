import { spawnSync } from 'node:child_process'
import { randomBytes } from 'node:crypto'
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  symlinkSync,
  unlinkSync,
  writeFileSync,
} from 'node:fs'
import { tmpdir } from 'node:os'
import { dirname, join } from 'node:path'
import { afterEach, describe, expect, it } from 'vitest'
import {
  crashMessage,
  gitleaksArgs,
  isAppFile,
  isBlocked,
  MAX_LINES,
  NO_BASE,
  report,
  SECRET_ADVICE,
} from './stop-checks.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/4-tooling/spec.md that each test protects.
//
// Each test builds a small throwaway project in the system temp folder: a git
// repository on main with the factory layout, and one or more worktrees in
// .worktrees/<job-id> on factory/<job-id> branches. Each worktree reaches this
// repository's node_modules through a link, so the real TypeScript, ESLint and
// Prettier run. The made-up key is generated at run time, in the shape gitleaks
// detects, and is used nowhere else.
//
// The project's .gitignore says `node_modules/` like this repository's. On
// Windows the link is a junction, which git treats as an ignored folder. On
// Linux (the GitHub check) it is a symbolic link, which git lists as a new file,
// so there these tests also prove the stop check never treats node_modules as
// app code.

const SCRIPT = join(import.meta.dirname, 'stop-checks.ts')
const NODE_MODULES = join(process.cwd(), 'node_modules')
const GIT = ['-c', 'user.name=stop-check-test', '-c', 'user.email=', '-c', 'commit.gpgsign=false']
const hasGitleaks = spawnSync('gitleaks', ['version']).status === 0
const SLOW = 60_000

function madeUpKey(): string {
  const tail = randomBytes(64)
    .toString('base64')
    .replace(/[^A-Za-z0-9]/g, '')
    .slice(0, 36)
  return ['gh', 'p_'].join('') + tail
}

const projects: string[] = []
const links: string[] = []

afterEach(() => {
  // Remove each link first, so deleting the project can never reach into the
  // real node_modules.
  for (const link of links.splice(0)) unlinkSync(link)
  for (const project of projects.splice(0)) rmSync(project, { recursive: true, force: true })
  expect(existsSync(join(NODE_MODULES, 'typescript', 'package.json'))).toBe(true)
})

function git(cwd: string, ...args: string[]): string {
  const result = spawnSync('git', [...GIT, ...args], { cwd, encoding: 'utf8' })
  if (result.status !== 0) throw new Error(`git ${args.join(' ')}: ${result.stderr}`)
  return result.stdout
}

function write(dir: string, files: Record<string, string>): void {
  for (const [name, content] of Object.entries(files)) {
    mkdirSync(dirname(join(dir, name)), { recursive: true })
    writeFileSync(join(dir, name), content)
  }
}

function project(): string {
  const root = mkdtempSync(join(tmpdir(), 'puhuscribe-stop-check-'))
  projects.push(root)
  git(root, 'init', '-q', '-b', 'main')
  git(root, 'config', 'core.autocrlf', 'false')
  write(root, {
    '.gitignore': 'node_modules/\n.worktrees/\n.env\n.env.*\n!.env.example\n',
    'package.json': '{ "type": "module" }\n',
    'tsconfig.json': JSON.stringify({
      compilerOptions: { strict: true, noEmit: true, skipLibCheck: true, module: 'esnext', types: [] },
      include: ['src'],
    }),
    'eslint.config.js':
      "import tseslint from 'typescript-eslint'\n\nexport default tseslint.config(tseslint.configs.recommended)\n",
    '.prettierrc.json': readFileSync('.prettierrc.json', 'utf8'),
    '.prettierignore': 'factory/\ndocs/\nrecording/\n.claude/\n',
    'src/greeting.ts': "export const greeting = 'hei'\n",
  })
  git(root, 'add', '-A')
  git(root, 'commit', '-q', '-m', 'start')
  return root
}

// A factory worktree with the given files written (and committed if asked).
function worktree(root: string, id: string, files: Record<string, string>, commit = false): string {
  git(root, 'worktree', 'add', '-q', '-b', `factory/${id}`, join('.worktrees', id), 'main')
  const dir = join(root, '.worktrees', id)
  const link = join(dir, 'node_modules')
  symlinkSync(NODE_MODULES, link, 'junction')
  links.push(link)
  write(dir, files)
  if (commit) {
    git(dir, 'add', '-A')
    git(dir, 'commit', '-q', '-m', 'work')
  }
  return dir
}

function buildNotes(root: string, id: string, text: string): void {
  write(root, { [`factory/jobs/${id}/build.md`]: text })
}

function stopCheck(root: string) {
  const started = performance.now()
  const result = spawnSync(process.execPath, [SCRIPT, 'worktrees'], {
    encoding: 'utf8',
    env: { ...process.env, CLAUDE_PROJECT_DIR: root },
  })
  const output = `${result.stdout}${result.stderr}`
  return { code: result.status, output, lines: output.trimEnd().split('\n'), ms: performance.now() - started }
}

const LINT_ERROR = 'export function echo(value: any) {\n  return value\n}\n'
const TYPE_ERROR = "export const count: number = 'one'\n"
const UNFORMATTED = 'export const   greeting = {word:"hei",   times:2};\n'

describe('the agent stop check', () => {
  it('[tooling 15] with no changed app files it exits 0 in under 2 seconds', () => {
    const root = project()
    worktree(root, 'job-a', {})
    const result = stopCheck(root)
    expect(result.output).toBe('')
    expect(result.code).toBe(0)
    expect(result.ms).toBeLessThan(2000)
  })

  it(
    '[tooling 15] files under factory/, recording/, docs/ and .claude/ do not count as app files',
    () => {
      const root = project()
      const key = madeUpKey()
      worktree(root, 'job-a', {
        'factory/jobs/job-a/notes.ts': LINT_ERROR + TYPE_ERROR,
        'recording/scene.ts': UNFORMATTED,
        'docs/example.ts': `export const token = '${key}'\n`,
        '.claude/hook.ts': LINT_ERROR,
      })
      const result = stopCheck(root)
      expect(result.output).toBe('')
      expect(result.code).toBe(0)
    },
    SLOW,
  )

  it(
    '[tooling 15] a lint error in a changed file exits 2 and names the check and the file',
    () => {
      const root = project()
      worktree(root, 'job-a', { 'src/echo.ts': LINT_ERROR })
      const result = stopCheck(root)
      expect(result.code).toBe(2)
      expect(result.output).toContain('.worktrees/job-a:')
      expect(result.output).toContain('lint: src/echo.ts:1:29 @typescript-eslint/no-explicit-any')
      expect(result.lines.length).toBeLessThanOrEqual(MAX_LINES)
      expect(result.output).not.toContain(SECRET_ADVICE)
    },
    SLOW,
  )

  it(
    '[tooling 15] a type error already committed on the branch exits 2',
    () => {
      const root = project()
      worktree(root, 'job-a', { 'src/count.ts': TYPE_ERROR }, true)
      const result = stopCheck(root)
      expect(result.code).toBe(2)
      expect(result.output).toContain('typecheck: src/count.ts:1:14 TS2322')
      // The type error's message would quote code, so only its code is printed.
      expect(result.output).not.toContain("'one'")
    },
    SLOW,
  )

  it(
    '[tooling 15] a format error in a new file exits 2',
    () => {
      const root = project()
      worktree(root, 'job-a', { 'src/unformatted.ts': UNFORMATTED })
      const result = stopCheck(root)
      expect(result.code).toBe(2)
      expect(result.output).toContain('format: src/unformatted.ts')
    },
    SLOW,
  )

  it.skipIf(!hasGitleaks)(
    '[tooling 15] a made-up key in a changed file exits 2 and never prints the value',
    () => {
      const root = project()
      const key = madeUpKey()
      worktree(root, 'job-a', { 'src/token.ts': `export const githubToken = '${key}'\n` })
      const result = stopCheck(root)
      expect(result.code).toBe(2)
      expect(result.output).toContain('secrets: src/token.ts line 1 (github-pat)')
      expect(result.output).toContain(SECRET_ADVICE)
      expect(result.output).not.toContain(key)
      expect(result.output).not.toContain(key.slice(4, 20))
    },
    SLOW,
  )

  it(
    '[tooling 15] never opens, lists or prints a .env* file',
    () => {
      const root = project()
      const key = madeUpKey()
      const dir = worktree(root, 'job-a', {
        '.env.local': `GITHUB_TOKEN=${key}\nSUPABASE_TEST_DB_URL=postgresql://made-up:${key}@localhost/db\n`,
      })
      // Only the git-ignored .env.local changed: nothing to check.
      const quiet = stopCheck(root)
      expect(quiet.output).toBe('')
      expect(quiet.code).toBe(0)
      // With a real problem next to it, the report still never mentions it.
      write(dir, { 'src/echo.ts': LINT_ERROR, 'src/.env.example.ts': `export const k = '${key}'\n` })
      const loud = stopCheck(root)
      expect(loud.code).toBe(2)
      expect(loud.output).toContain('lint: src/echo.ts')
      expect(loud.output).not.toContain('.env')
      expect(loud.output).not.toContain(key)
    },
    SLOW,
  )

  it(
    '[tooling 15] lets a builder stop when its build.md ends with "Result: blocked:"',
    () => {
      const root = project()
      worktree(root, 'job-a', { 'src/echo.ts': LINT_ERROR })
      buildNotes(
        root,
        'job-a',
        '# Build notes\n\nResult: blocked: the spec asks for a table that cannot exist\n\n',
      )
      expect(stopCheck(root).code).toBe(0)
      buildNotes(root, 'job-a', '# Build notes\n\nResult: blocked: earlier\n\nResult: checks pass\n')
      expect(stopCheck(root).code).toBe(2)
    },
    SLOW,
  )

  it(
    '[tooling 15] checks each worktree on its own: a blocked one is skipped, a broken one is named',
    () => {
      const root = project()
      worktree(root, 'job-a', { 'src/echo.ts': LINT_ERROR })
      buildNotes(root, 'job-a', 'Result: blocked: waiting for the owner\n')
      worktree(root, 'job-b', { 'src/count.ts': TYPE_ERROR })
      const result = stopCheck(root)
      expect(result.code).toBe(2)
      expect(result.output).not.toContain('job-a')
      expect(result.output).toContain('.worktrees/job-b:')
    },
    SLOW,
  )

  it(
    '[tooling 15] prints at most 40 lines however many problems there are',
    () => {
      const root = project()
      const many = Array.from(
        { length: 60 },
        (_, i) => `export const value${String(i)}: any = ${String(i)}\n`,
      )
      worktree(root, 'job-a', { 'src/many.ts': many.join('') })
      const result = stopCheck(root)
      expect(result.code).toBe(2)
      expect(result.lines.length).toBeLessThanOrEqual(MAX_LINES)
      expect(result.output).toMatch(/\.\.\.and \d+ more lines/)
    },
    SLOW,
  )

  it('[tooling 15] reports a worktree with no node_modules instead of passing it', () => {
    const root = project()
    const dir = worktree(root, 'job-a', { 'src/echo.ts': LINT_ERROR })
    unlinkSync(join(dir, 'node_modules'))
    links.splice(links.indexOf(join(dir, 'node_modules')), 1)
    const result = stopCheck(root)
    expect(result.code).toBe(2)
    expect(result.output).toContain('setup: node_modules is missing')
  })

  it(
    '[tooling 15] with no main branch to compare with, it says so and exits 2 instead of passing',
    () => {
      const root = project()
      worktree(root, 'job-a', { 'src/count.ts': TYPE_ERROR }, true)
      git(root, 'branch', '-m', 'main', 'trunk')
      const result = stopCheck(root)
      expect(result.output).toContain(NO_BASE)
      expect(result.code).toBe(2)
      // Uncommitted work is still checked.
      write(join(root, '.worktrees', 'job-a'), { 'src/echo.ts': LINT_ERROR })
      expect(stopCheck(root).output).toContain('lint: src/echo.ts')
    },
    SLOW,
  )

  it('[tooling 15] refuses an unknown mode', () => {
    const result = spawnSync(process.execPath, [SCRIPT, 'main'], { encoding: 'utf8' })
    expect(result.status).toBe(1)
  })

  it('[tooling 15] when the check itself breaks, it gives the cause and the next step in one line', () => {
    const root = project()
    // .worktrees is a file here, so listing the worktrees fails.
    write(root, { '.worktrees': 'not a folder\n' })
    const result = stopCheck(root)
    expect(result.lines).toHaveLength(1)
    expect(result.output).toMatch(/^Stop check could not run \((ENOTDIR|ENOENT|EPERM)[^)]*\)\. /)
    expect(result.output).toContain(
      'Run npm run check:code in the worktree and report the problem in build.md.',
    )
    expect(result.code).toBe(1)
  })
})

describe('stop check rules', () => {
  it.each([
    ['src/App.tsx', true],
    ['worker/api.ts', true],
    ['package.json', true],
    ['factory/jobs/4-tooling/build.md', false],
    ['recording/log-turn.mjs', false],
    ['docs/conventions.md', false],
    ['.claude/settings.json', false],
    ['.env.local', false],
    ['.env.example', false],
    ['worker/.env', false],
    ['node_modules', false],
    ['node_modules/typescript/package.json', false],
    ['src/node_modules_notes.ts', true],
  ])('[tooling 15] %s counts as an app file: %s', (path, expected) => {
    expect(isAppFile(path)).toBe(expected)
  })

  it('[tooling 15] only a last line starting "Result: blocked:" lets a builder stop', () => {
    expect(isBlocked('notes\n\nResult: blocked: no test database\n')).toBe(true)
    expect(isBlocked('Result: blocked: old\nResult: checks pass\n')).toBe(false)
    expect(isBlocked('Result: checks pass')).toBe(false)
    expect(isBlocked(undefined)).toBe(false)
  })

  it('[tooling 15] the report is empty when nothing failed and never longer than 40 lines', () => {
    expect(report([{ id: 'a', problems: [] }])).toEqual([])
    const long = report([
      { id: 'a', problems: Array.from({ length: 100 }, (_, i) => `lint: f${String(i)}.ts`) },
    ])
    expect(long).toHaveLength(MAX_LINES)
    expect(long).toContain('  ...and 65 more lines')
    expect(long).not.toContain(SECRET_ADVICE)
  })

  it('[tooling 15] a secret finding adds the advice line, and the report still fits in 40 lines', () => {
    const problems = [
      'secrets: src/token.ts line 3 (github-pat)',
      ...Array.from({ length: 100 }, (_, i) => `lint: f${String(i)}.ts`),
    ]
    const long = report([{ id: 'a', problems }])
    expect(long).toHaveLength(MAX_LINES)
    expect(long.at(-1)).toBe(SECRET_ADVICE)
    // A missing gitleaks is not a finding, so it gets no advice line.
    const missing = report([{ id: 'a', problems: ['secrets: gitleaks is not installed. Install it once'] }])
    expect(missing).not.toContain(SECRET_ADVICE)
  })

  it('[tooling 15] gitleaks runs redacted, on the one file, with its report on stdout and no report file', () => {
    const args = gitleaksArgs('src/token.ts')
    expect(args.slice(0, 2)).toEqual(['dir', 'src/token.ts'])
    expect(args).toContain('--redact')
    expect(args.filter((arg) => arg.startsWith('--redact='))).toEqual([])
    expect(args[args.indexOf('--report-path') + 1]).toBe('-')
    expect(args).not.toContain('--verbose')
    expect(args).not.toContain('-v')
  })

  it('[tooling 15] the crash line names the cause and never more than a short message', () => {
    const error = Object.assign(new Error(`scandir 'C:/x/.worktrees'\n${'x'.repeat(500)}`), {
      code: 'ENOTDIR',
    })
    const line = crashMessage(error)
    expect(line).not.toContain('\n')
    expect(line).toMatch(/^Stop check could not run \(ENOTDIR: scandir/)
    expect(line.length).toBeLessThan(300)
  })
})
