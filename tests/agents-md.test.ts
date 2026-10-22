import { spawnSync } from 'node:child_process'
import { existsSync, readdirSync, readFileSync } from 'node:fs'
import { dirname, join, normalize } from 'node:path'
import { describe, expect, it } from 'vitest'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/4-tooling/spec.md that each test protects.
//
// AGENTS.md is read into every AI session, and docs/conventions.md holds the
// detail it links to. These tests keep both honest: every path and npm script
// they name must exist, the binding product lists must be there word for word,
// AGENTS.md must stay short, and no "Lessons learned" line may be removed.

const read = (path: string) => readFileSync(path, 'utf8').replace(/\r\n/g, '\n')
const agents = read('AGENTS.md')
const conventions = read('docs/conventions.md')
const readme = read('README.md')
const scripts = (JSON.parse(read('package.json')) as { scripts: Record<string, string> }).scripts

// Paths written down for a folder that a later job creates. Each entry says
// which job makes it; remove it from this list once the folder exists.
const PLANNED = new Map([['worker/providers/', 'the first job that adds a voice, speech or AI provider']])

// The text of one `## ` section, without its heading line.
function section(text: string, heading: string): string {
  const start = text.indexOf(`\n## ${heading}\n`)
  if (start === -1) throw new Error(`No "## ${heading}" section`)
  const body = text.slice(start + `\n## ${heading}\n`.length)
  const next = body.search(/^## /m)
  return next === -1 ? body : body.slice(0, next)
}

function ignoredByGit(path: string): boolean {
  return spawnSync('git', ['check-ignore', '--quiet', '--no-index', path]).status === 0
}

// A code span with no slash is a root file when it ends in one of the file
// types this repository uses (`lefthook.yml`) or starts with a dot
// (`.prettierignore`). Ordinary words and dotted names such as
// `request.jwt.claims` match neither.
const FILE_TYPES = /\.(md|ts|tsx|js|mjs|cjs|json|jsonc|ya?ml|toml|ini|sql|py|txt|tsv|csv|html|sh)$/

function looksLikeRootFile(span: string): boolean {
  // A bare file type such as `.ts` names a kind of file, not a file.
  if (/^\.[a-z]+$/.test(span) && FILE_TYPES.test(span)) return false
  return /^\.?[\w.-]+$/.test(span) && (span.startsWith('.') || FILE_TYPES.test(span))
}

// Files every factory job keeps in factory/jobs/<job-id>/, often named without
// the folder. They count as present when at least one job has them.
const JOB_FILES = new Set([
  'build.md',
  'spec.md',
  'summary.md',
  'evaluation.md',
  'review-security.md',
  'review-design.md',
])

function isJobFile(path: string): boolean {
  return (
    JOB_FILES.has(path) &&
    readdirSync('factory/jobs', { withFileTypes: true }).some(
      (job) => job.isDirectory() && existsSync(join('factory/jobs', job.name, path)),
    )
  )
}

// Repository paths named in a markdown file: every `code span` that looks like
// a path (has a slash, or is a root file name as above; no spaces, no
// placeholder such as <job-id>, no glob), and every relative markdown link.
// Code spans are read from the repository root; links from the file's own
// folder, as a markdown viewer reads them. Only existence is checked (a stat);
// no file is opened, so a named `.env.example` is never read.
function pathsIn(file: string, text: string): string[] {
  const found: string[] = []
  for (const [, span = ''] of text.matchAll(/`([^`\n]+)`/g)) {
    if (/[\s<>*{}|$@]/.test(span)) continue
    if (!span.includes('/')) {
      if (looksLikeRootFile(span)) found.push(span)
      continue
    }
    if (span.startsWith('/') || /^[A-Za-z]:\//.test(span) || span.includes('://')) continue
    // A web address such as github.com/owner/repo, not a file.
    if (/^[a-z0-9-]+(\.[a-z0-9-]+)*\.(com|org|io|dev|fi|ai|net)\//i.test(span)) continue
    found.push(span.replace(/#.*$/, ''))
  }
  for (const [, link = ''] of text.matchAll(/\]\(([^)\s]+)\)/g)) {
    if (/^(https?:|mailto:|#)/.test(link)) continue
    found.push(normalize(join(dirname(file), link.replace(/#.*$/, ''))).replace(/\\/g, '/'))
  }
  return found
}

function missingPaths(file: string, text: string): string[] {
  return pathsIn(file, text).filter(
    (path) => !existsSync(path) && !ignoredByGit(path) && !PLANNED.has(path) && !isJobFile(path),
  )
}

function npmScriptsIn(text: string): string[] {
  const names = [...text.matchAll(/\bnpm run ([A-Za-z0-9:_-]+)/g)].map(([, name = '']) => name)
  if (/\bnpm test\b/.test(text)) names.push('test')
  return names
}

// PRD section 4.1, "Not in v3.0", word for word (all 12 items).
const NOT_IN_V3_0 = [
  'Day One Sprint as the front door',
  'Vocabulary bank with a 2,000-word target',
  'Practice hub as four separate modes (Speak/Listen/Write/Read)',
  'Grammar Stage 2 as standalone lessons',
  'Sentence Bank / language islands as a top-level surface (→ paid tier, v3.2)',
  'Converse tutor "Otso" as a standalone surface (→ appears inside the loop from unit 4; open-ended mode is paid tier)',
  'Rank titles, confetti, milestone ladder, journey stage map',
  'Bilingual / Finnish-only toggle',
  'Mnemonics',
  'YKI-specific content and skill tagging',
  'Native app store builds (Capacitor path stays documented)',
  'Owner Insights dashboard beyond a minimal tester count',
]

const FIVE_PRINCIPLES = [
  "short dialogues just above the learner's level, never word lists",
  'spaced retrieval scheduled automatically with no self rating',
  'task based units tied to an A1 "can do" statement',
  'the learner says it back every session and gets feedback',
  'spoken Finnish (puhekieli) first, written Finnish (kirjakieli) alongside, both with audio',
]

// The 17 "Lessons learned" lines as they stood when job 4-tooling started.
// New lines may be added below them; none of these may change or go.
const LESSONS = [
  '- Test debug files (Playwright traces, HAR files, HTML reports) record request headers. Never keep them while a secret header is set, and scan every file for secret values before any upload. (1-stack, security review)',
  '- A test meant to act as a stranger must clear any headers the test config adds for everyone, and should assert no pass was sent. (1-stack, builder)',
  '- Never choose an email address for the owner. Ask which one to use, every time. (1-stack, owner)',
  '- Supabase\'s free plan offers only broad regions such as "Europe", not a specific city; check the assigned country is in the EU. (1-stack, owner setup)',
  '- When a check fails, find the cause from evidence before reporting one. A guess about timing was wrong; the cause was a test bug. (1-stack, manager)',
  '- Cloudflare\'s "Workers Scripts: Edit" permission also covers Access application edits, so a Workers key can change login locks. (1-stack, manager)',
  '- Never search, grep or print files matching .env*. Job worktrees hold a copy of .env.local, and a broad search printed a database password. Use git grep or exclude .env*. (2-smoke, security review)',
  '- New Supabase tables give the API roles no access by default (since May 2026). Write every grant and revoke out in the migration, and test them. (2-smoke, spec)',
  '- Pin third-party GitHub Actions that receive secrets to a full commit SHA, with the version in a comment. (2-smoke, security review)',
  '- In the Workers runtime, read (and cap) a request body before answering, or the next request on that connection can fail locally. (2-smoke, builder)',
  '- Browser features new since 2022 (such as AbortSignal.timeout) need a fallback; learners use older phones. (2-smoke, design review)',
  '- A test can pass for the wrong reason. Prove each protection by breaking it on purpose and watching its test go red, and make sure no other rule can refuse the same action. (3-data-model, evaluator)',
  '- When approved content is withdrawn, clear its approval; going live again needs a new reviewer reference. (3-data-model, evaluator)',
  "- Database types must be the Supabase CLI's exact output, never written by hand. (3-data-model, builder)",
  '- Keep earlier rounds in build.md in a short section; overwriting them lost proof links. (3-data-model, evaluator)',
  '- Two Postgres read rules that look at each other loop forever; enforce such rules at write time instead. (3-data-model, builder)',
  '- After a merge, do not push to main until the merge run has finished: the checks cancel an older run on the same branch, which cancelled the first database apply. (3-data-model, manager)',
]

describe('AGENTS.md describes the real project', () => {
  it('[tooling 2] states the real stack, matching the README stack table', () => {
    const stack = section(agents, 'Stack')
    for (const term of [
      'React 19',
      'Vite',
      'TypeScript (strict)',
      'single page app',
      'Cloudflare Worker',
      '`/api/*`',
      'Supabase',
      'EU',
      'Node 24',
      'npm',
      'Vitest',
      'Playwright',
      'Python 3.12',
    ]) {
      expect(stack, term).toContain(term)
    }
    const readmeStack = section(readme, 'Stack')
    for (const term of [
      'React 19',
      'Vite',
      'TypeScript (strict)',
      'single page app',
      'Cloudflare Worker',
      '`/api/*`',
      'Supabase',
      'EU',
      'Node 24',
      'npm',
      'Vitest',
      'Playwright',
      'Python 3.12',
    ]) {
      expect(readmeStack, term).toContain(term)
    }
  })

  it('[tooling 2] keeps the five principles', () => {
    // One sub-bullet each, labelled P1 to P5 in the PRD's order.
    FIVE_PRINCIPLES.forEach((principle, i) => {
      const line = `  - P${String(i + 1)}. ${principle.charAt(0).toUpperCase()}${principle.slice(1)}.\n`
      expect(agents, principle).toContain(line)
    })
  })

  it('[tooling 2] lists all 12 "Not in v3.0" items from PRD section 4.1 word for word, and no streaks', () => {
    for (const item of NOT_IN_V3_0) expect(agents, item).toContain(`  - ${item}\n`)
    expect(agents).toMatch(/no streaks/i)
  })

  it('[tooling 2] no longer says it will be expanded once the app is scaffolded', () => {
    expect(agents).not.toContain('expands it once the app is scaffolded')
    expect(agents).not.toMatch(/Scope item 2 \(Coding standards & tooling\) expands it/)
  })
})

describe('AGENTS.md carries the project rules', () => {
  const rules = section(agents, 'Project rules')

  it('[tooling 3] GA features answer the three threat model questions and need the owner\'s dated "approved" line', () => {
    expect(rules).toContain('`"ga": true` in `factory/features.json`')
    expect(rules).toContain('What is the worst thing a malicious person could do here?')
    expect(rules).toContain('What data are we storing that we must protect?')
    expect(rules).toContain('What should the system refuse to do even if asked nicely?')
    expect(rules).toMatch(/`summary\.md` records the owner's own written "approved" line with the date/)
  })

  it('[tooling 3] proof lives in the evidence folder, is never deleted and never holds a secret', () => {
    expect(rules).toContain('`factory/jobs/<job-id>/evidence/`')
    expect(rules).toMatch(/never deleted/)
    expect(rules).toMatch(/never holds a secret/)
  })

  it('[tooling 3] debug triage names the three kinds and what to do for each', () => {
    expect(rules).toContain(
      '**A real bug.** Reproduce it, prove the cause from evidence, make the smallest fix',
    )
    expect(rules).toMatch(/a test that fails without the fix/)
    expect(rules).toContain('**A confused session.** Stop and start a fresh one.')
    expect(rules).toContain('**A wrong earlier decision.** Stop and send it back to the spec.')
  })

  it('[tooling 3] output style: short plain sentences, terms explained, no em dashes or hyphens as punctuation', () => {
    expect(rules).toMatch(/Plain short sentences/)
    expect(rules).toMatch(/Explain a technical term the first time/)
    expect(rules).toMatch(/Report in a few lines/)
    expect(section(agents, 'Writing rules (app text, docs, summaries)')).toContain(
      'No em dashes, and no hyphens used as punctuation.',
    )
  })

  it('[tooling 3] the writing rules ban colon reveals and habitual groups of three, and AGENTS.md uses no colon openers', () => {
    const writing = section(agents, 'Writing rules (app text, docs, summaries)')
    expect(writing).toContain('No colon reveals such as "Here\'s the thing:".')
    expect(writing).toContain('No habitual groups of three')
    // Outside code, quotes and the lessons, no sentence leads into a reveal
    // with a colon. List lead-ins and labels in bold are fine.
    const prose = agents
      .slice(0, agents.indexOf('\n## Lessons learned'))
      .replace(/`[^`]*`/g, '')
      .replace(/"[^"]*"/g, '')
      .split('\n')
      .filter((line) => !line.startsWith('#'))
    expect(prose.filter((line) => /\w: \w/.test(line))).toEqual([])
  })

  it('[tooling 3] never skip the checks', () => {
    expect(rules).toContain('`git commit --no-verify`')
    expect(rules).toContain('`LEFTHOOK=0`')
    expect(rules).toMatch(/no editing a check to make it pass/)
    expect(rules).toMatch(/If a check is wrong, say so in the job notes/)
  })
})

describe('AGENTS.md stays short', () => {
  it('[tooling 4] the Conventions section is at most 25 lines and links docs/conventions.md', () => {
    const body = section(agents, 'Conventions').replace(/\n+$/, '')
    expect(body.split('\n').length).toBeLessThanOrEqual(25)
    expect(body).toContain('docs/conventions.md')
  })

  it('[tooling 4] [tooling 6] the whole file stays under 2,200 words', () => {
    expect(agents.split(/\s+/).filter(Boolean).length).toBeLessThan(2200)
  })

  it('[tooling 4] [tooling 6] keeps all 17 "Lessons learned" lines unchanged', () => {
    const lines = section(agents, 'Lessons learned').split('\n')
    for (const lesson of LESSONS) expect(lines, lesson).toContain(lesson)
  })
})

describe('docs/conventions.md records the conventions the code follows', () => {
  const topics = [
    'Folder layout',
    'Naming',
    'Test labels',
    'Migrations and pgTAP',
    'Provider modules',
    'Secrets',
    'Files imported from v2',
    'Evidence folders',
    'build.md',
  ]

  it.each(topics)('[tooling 5] "%s" has a section with at least one real example file', (topic) => {
    const files = pathsIn('docs/conventions.md', section(conventions, topic)).filter(
      (path) => existsSync(path) && !path.endsWith('/'),
    )
    expect(files.length).toBeGreaterThan(0)
  })

  it('[tooling 5] has the "Checks and where they run" table: before a commit, when an agent stops, on GitHub', () => {
    const checks = section(conventions, 'Checks and where they run')
    expect(checks).toMatch(/^\| .*Before a commit.* \|$/m)
    expect(checks).toMatch(/^\| .*When a builder agent stops.* \|$/m)
    expect(checks).toMatch(/^\| .*On GitHub.* \|$/m)
  })

  it("[tooling 5] names each job's test label", () => {
    const labels = section(conventions, 'Test labels')
    for (const label of ['`[N]`', '`[smoke N]`', '`[data N]`', '`[tooling N]`'])
      expect(labels).toContain(label)
  })
})

describe('both files stay true to the repository', () => {
  it.each([
    ['AGENTS.md', agents],
    ['docs/conventions.md', conventions],
  ])('[tooling 6] every path written in %s exists', (file, text) => {
    expect(pathsIn(file, text).length).toBeGreaterThan(5)
    expect(missingPaths(file, text)).toEqual([])
  })

  it.each([
    ['AGENTS.md', agents],
    ['docs/conventions.md', conventions],
    ['README.md', readme],
  ])('[tooling 6] every npm script named in %s is in package.json', (_file, text) => {
    expect(npmScriptsIn(text).filter((name) => !(name in scripts))).toEqual([])
  })

  it('[tooling 6] the path check really catches a missing path', () => {
    const text = 'See `docs/no-such-file.md`, `src/` and [the plan](../docs/plan.md).'
    expect(missingPaths('docs/conventions.md', text)).toEqual(['docs/no-such-file.md'])
  })

  it('[tooling 6] root files without a slash are checked too, and ordinary words are not', () => {
    const text =
      'Run `lefthook-gone.yml` with `ruff.toml`, `.prettierignore`, `.no-such-dotfile` and `build.md`; ' +
      'set `request.jwt.claims`, call `auth.uid()`, use `npm`, `main`, `2.2.2`, `.ts`, `.jsonc` and `*.test.ts`.'
    expect(pathsIn('AGENTS.md', text)).toEqual([
      'lefthook-gone.yml',
      'ruff.toml',
      '.prettierignore',
      '.no-such-dotfile',
      'build.md',
    ])
    expect(missingPaths('AGENTS.md', text)).toEqual(['lefthook-gone.yml', '.no-such-dotfile'])
  })

  it('[tooling 6] the root files named today are among the paths checked', () => {
    expect(pathsIn('AGENTS.md', agents)).toContain('lefthook.yml')
    for (const name of ['ruff.toml', 'eslint.config.js', '.prettierignore', '.env.example']) {
      expect(pathsIn('docs/conventions.md', conventions)).toContain(name)
    }
  })

  it('[tooling 6] planned paths are only for folders that do not exist yet', () => {
    for (const path of PLANNED.keys()) expect(existsSync(path), path).toBe(false)
  })
})

describe('one command runs the fast code checks', () => {
  it('[tooling 7] npm run check:code runs the type check, lint and format check in that order', () => {
    expect(scripts['check:code']).toBe('npm run typecheck && npm run lint && npm run format:check')
  })

  it('[tooling 7] the README command table lists it', () => {
    expect(readme).toMatch(/^\| `npm run check:code` +\| .+ \|$/m)
  })
})
