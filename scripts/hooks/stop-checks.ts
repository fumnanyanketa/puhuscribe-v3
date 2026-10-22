// The agent stop check. Claude Code runs it each time the factory builder agent
// finishes (the SubagentStop hook in .claude/settings.json, matcher
// factory-builder, owner's call 1 = B in job 4-tooling):
//
//   node "$CLAUDE_PROJECT_DIR/scripts/hooks/stop-checks.ts" worktrees
//
// For every factory worktree (.worktrees/<job-id>) it finds the app files that
// changed since the branch left main (committed or not, plus new files git
// does not ignore) and runs the type check, lint, format check and secret scan
// on them. Exit 0 lets the agent stop. Exit 2 keeps it working and shows it
// what to fix: at most 40 lines naming the check, the file and the rule, never
// a line of a file's content, so no secret value is ever printed.
//
// - Files under factory/, recording/, docs/ and .claude/ are not app files,
//   and neither is node_modules.
// - With no main branch to compare with, committed work cannot be found, so
//   the check says so and exits 2 instead of letting the builder through.
// - .env* files are never opened, listed or printed. git already leaves out
//   ignored files such as .env.local; the name filter below is a second guard.
// - A builder whose factory/jobs/<job-id>/build.md ends with
//   "Result: blocked: <reason>" may stop with problems left.
// Spec: factory/jobs/4-tooling/spec.md, "Done when" 15.
import { spawn, spawnSync } from 'node:child_process'
import { existsSync, readdirSync, readFileSync } from 'node:fs'
import { join, relative } from 'node:path'
import { INSTALL } from './commit-tool.ts'

export const MAX_LINES = 40
export const SECRET_ADVICE =
  'If a secret was found, remove it from the file and tell the owner. Never paste its value anywhere.'
const SECRET_FOUND = /^secrets: .+ line \d+ \(/
const NOT_APP_CODE = ['factory/', 'recording/', 'docs/', '.claude/']
const GITLEAKS_AT_ONCE = 6

export interface WorktreeResult {
  id: string
  problems: string[]
}

interface Run {
  code: number
  stdout: string
  stderr: string
  missing: boolean
}

export function isAppFile(path: string): boolean {
  const normal = path.replace(/\\/g, '/')
  if (NOT_APP_CODE.some((dir) => normal.startsWith(dir))) return false
  // Installed packages. git ignores a node_modules folder, but on Linux and
  // macOS a node_modules link is a file to git and would be listed as new.
  if (/(^|\/)node_modules(\/|$)/.test(normal)) return false
  const name = normal.slice(normal.lastIndexOf('/') + 1)
  return !name.startsWith('.env')
}

// True when the last non-empty line of build.md reports the builder blocked.
export function isBlocked(buildNotes: string | undefined): boolean {
  const lines = (buildNotes ?? '').split(/\r?\n/).filter((line) => line.trim() !== '')
  return lines.at(-1)?.trim().startsWith('Result: blocked:') ?? false
}

function git(cwd: string, args: string[]): string | undefined {
  const result = spawnSync('git', args, { cwd, encoding: 'utf8', windowsHide: true })
  return result.status === 0 ? result.stdout : undefined
}

export interface ChangedFiles {
  files: string[]
  // False when the worktree has no main branch to compare with. Then only
  // uncommitted and new files were found, and the caller reports it.
  baseFound: boolean
}

// App files that differ from where the branch left main: committed, staged,
// unstaged, and untracked files that git does not ignore. Deleted files are
// left out, since there is nothing left to check.
export function changedAppFiles(worktree: string, base = 'main'): ChangedFiles {
  const mergeBase = git(worktree, ['merge-base', 'HEAD', base])?.trim()
  const tracked = git(worktree, ['diff', '--name-only', '--no-renames', '-z', mergeBase ?? 'HEAD']) ?? ''
  const untracked = git(worktree, ['ls-files', '--others', '--exclude-standard', '-z']) ?? ''
  const files = new Set([...tracked.split('\0'), ...untracked.split('\0')].filter(Boolean))
  return {
    files: [...files]
      .filter(isAppFile)
      .filter((file) => existsSync(join(worktree, file)))
      .sort(),
    baseFound: mergeBase !== undefined,
  }
}

export const NO_BASE =
  'setup: no main branch to compare with, so committed changes could not be checked (create or fetch main)'

function run(command: string, args: string[], cwd: string, input?: string): Promise<Run> {
  return new Promise((resolve) => {
    const child = spawn(command, args, { cwd, windowsHide: true })
    let stdout = ''
    let stderr = ''
    child.stdout.setEncoding('utf8').on('data', (chunk: string) => (stdout += chunk))
    child.stderr.setEncoding('utf8').on('data', (chunk: string) => (stderr += chunk))
    child.on('error', (error: NodeJS.ErrnoException) => {
      resolve({ code: 1, stdout, stderr, missing: error.code === 'ENOENT' })
    })
    child.on('close', (code) => {
      resolve({ code: code ?? 1, stdout, stderr, missing: false })
    })
    child.stdin.end(input)
  })
}

function nodeTool(worktree: string, script: string, args: string[]): Promise<Run> {
  return run(process.execPath, [join(worktree, 'node_modules', script), ...args], worktree)
}

async function typecheck(worktree: string): Promise<string[]> {
  const result = await nodeTool(worktree, 'typescript/bin/tsc', ['-b', '--pretty', 'false'])
  if (result.code === 0) return []
  const errors = [...result.stdout.matchAll(/^(.+?)\((\d+),(\d+)\): error (TS\d+):/gm)].map(
    ([, file = '', line = '', column = '', code = '']) => `typecheck: ${file}:${line}:${column} ${code}`,
  )
  return errors.length > 0 ? errors : ['typecheck: tsc -b failed (run npm run typecheck to see why)']
}

interface EslintResult {
  filePath: string
  messages: { ruleId: string | null; severity: number; line?: number; column?: number }[]
}

async function lint(worktree: string, files: string[]): Promise<string[]> {
  const result = await nodeTool(worktree, 'eslint/bin/eslint.js', [
    '--no-warn-ignored',
    '--format',
    'json',
    ...files,
  ])
  if (result.code === 0) return []
  try {
    const parsed = JSON.parse(result.stdout) as EslintResult[]
    const errors = parsed.flatMap(({ filePath, messages }) =>
      messages
        .filter((message) => message.severity === 2)
        .map((message) => {
          const file = relative(worktree, filePath).replace(/\\/g, '/')
          return `lint: ${file}:${String(message.line ?? 0)}:${String(message.column ?? 0)} ${message.ruleId ?? 'parse error'}`
        }),
    )
    if (errors.length > 0) return errors
  } catch {
    // ESLint did not finish (a config error, for example): reported below.
  }
  return ['lint: ESLint failed (run npm run lint to see why)']
}

async function format(worktree: string, files: string[]): Promise<string[]> {
  const result = await nodeTool(worktree, 'prettier/bin/prettier.cjs', [
    '--list-different',
    '--ignore-unknown',
    ...files,
  ])
  if (result.code === 0) return []
  const unformatted = result.stdout
    .split(/\r?\n/)
    .filter(Boolean)
    .map((file) => `format: ${file} (npx prettier --write ${file})`)
  // Prettier's parse errors quote the file's code, so only the name is kept.
  const unreadable = [...result.stderr.matchAll(/^\[error\] ([^:\s]+): /gm)].map(
    ([, file = '']) => `format: ${file} could not be parsed by Prettier`,
  )
  const all = [...unformatted, ...unreadable]
  return all.length > 0 ? all : ['format: Prettier failed (run npm run format:check to see why)']
}

// gitleaks for one file. --redact keeps the value out of the report, which goes
// to stdout as JSON; only its file, line and rule are ever used.
export function gitleaksArgs(file: string): string[] {
  return [
    'dir',
    file,
    '--redact',
    '--no-banner',
    '--log-level',
    'error',
    '--report-format',
    'json',
    '--report-path',
    '-',
  ]
}

interface GitleaksFinding {
  File: string
  StartLine: number
  RuleID: string
}

async function secrets(worktree: string, files: string[]): Promise<string[]> {
  const version = await run('gitleaks', ['version'], worktree)
  if (version.missing) {
    return [`secrets: gitleaks is not installed. Install it once (free) with: ${INSTALL.gitleaks}`]
  }
  const problems: string[] = []
  for (let i = 0; i < files.length; i += GITLEAKS_AT_ONCE) {
    const batch = files.slice(i, i + GITLEAKS_AT_ONCE)
    const results = await Promise.all(
      batch.map((file) => run('gitleaks', gitleaksArgs(file), worktree).then((result) => ({ file, result }))),
    )
    for (const { file, result } of results) {
      if (result.code === 0) continue
      let findings: GitleaksFinding[] = []
      try {
        findings = JSON.parse(result.stdout) as GitleaksFinding[]
      } catch {
        // No report: gitleaks itself failed on this file.
      }
      if (findings.length === 0) problems.push(`secrets: gitleaks could not scan ${file}`)
      for (const finding of findings) {
        problems.push(`secrets: ${file} line ${String(finding.StartLine)} (${finding.RuleID})`)
      }
    }
  }
  return problems
}

export async function checkWorktree(worktree: string, files: string[]): Promise<string[]> {
  if (!existsSync(join(worktree, 'node_modules'))) {
    return ['setup: node_modules is missing (run npm ci in this worktree)']
  }
  const typed = files.filter((file) => /\.(ts|tsx|json|jsonc)$/.test(file))
  const lintable = files.filter((file) => /\.(ts|tsx|js)$/.test(file))
  const checks = await Promise.all([
    typed.length > 0 ? typecheck(worktree) : [],
    lintable.length > 0 ? lint(worktree, lintable) : [],
    format(worktree, files),
    secrets(worktree, files),
  ])
  return checks.flat()
}

// The message Claude Code shows the agent: at most MAX_LINES lines.
export function report(results: WorktreeResult[]): string[] {
  const failing = results.filter(({ problems }) => problems.length > 0)
  if (failing.length === 0) return []
  const head = ['Stop check: the app files you changed have problems. Fix them, then stop again.']
  const foot = [
    'For the full messages, run npm run check:code in the worktree.',
    'If you cannot fix them, end build.md with "Result: blocked: <one line reason>".',
  ]
  if (failing.some(({ problems }) => problems.some((problem) => SECRET_FOUND.test(problem)))) {
    foot.push(SECRET_ADVICE)
  }
  const body = failing.flatMap(({ id, problems }) => [
    `.worktrees/${id}:`,
    ...problems.map((problem) => `  ${problem}`),
  ])
  const room = MAX_LINES - head.length - foot.length
  if (body.length > room) {
    const hidden = body.length - (room - 1)
    body.splice(room - 1, body.length, `  ...and ${String(hidden)} more lines`)
  }
  return [...head, ...body, ...foot]
}

// One line when the check itself breaks: the cause (an error code or name and
// its short message, which names a path at most, never file content) and what
// to do next.
export function crashMessage(error: unknown): string {
  const cause =
    error instanceof Error
      ? `${(error as NodeJS.ErrnoException).code ?? error.name}: ${error.message}`
      : 'unknown error'
  const short = cause.replace(/\s+/g, ' ').slice(0, 160)
  return `Stop check could not run (${short}). Run npm run check:code in the worktree and report the problem in build.md.`
}

function readIfExists(path: string): string | undefined {
  return existsSync(path) ? readFileSync(path, 'utf8') : undefined
}

export async function main(args: string[], env: NodeJS.ProcessEnv = process.env): Promise<number> {
  if (args[0] !== 'worktrees') {
    console.error('Usage: node scripts/hooks/stop-checks.ts worktrees')
    return 1
  }
  const root = env.CLAUDE_PROJECT_DIR ?? join(import.meta.dirname, '..', '..')
  const folder = join(root, '.worktrees')
  const ids = existsSync(folder)
    ? readdirSync(folder, { withFileTypes: true })
        .filter((entry) => entry.isDirectory() && existsSync(join(folder, entry.name, '.git')))
        .map((entry) => entry.name)
        .sort()
    : []
  const results: WorktreeResult[] = []
  for (const id of ids) {
    if (isBlocked(readIfExists(join(root, 'factory', 'jobs', id, 'build.md')))) continue
    const worktree = join(folder, id)
    const { files, baseFound } = changedAppFiles(worktree)
    // Without main the committed work cannot be found, so the builder is told
    // instead of being let through unchecked.
    const problems = [
      ...(baseFound ? [] : [NO_BASE]),
      ...(files.length > 0 ? await checkWorktree(worktree, files) : []),
    ]
    results.push({ id, problems })
  }
  const lines = report(results)
  if (lines.length === 0) return 0
  console.error(lines.join('\n'))
  return 2
}

// process.exitCode, not process.exit(): on Windows, Node 24 can abort with a
// libuv assertion (exit code 127) when process.exit() runs from a promise.
if (import.meta.main) {
  main(process.argv.slice(2)).then(
    (code) => {
      process.exitCode = code
    },
    (error: unknown) => {
      console.error(crashMessage(error))
      process.exitCode = 1
    },
  )
}
