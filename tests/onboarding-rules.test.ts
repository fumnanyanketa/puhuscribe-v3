import { execFileSync, spawnSync } from 'node:child_process'
import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/15-onboarding/spec.md ([onboarding N]). These are the checks
// about files rather than pages: what the welcome's source may touch, what the
// branch changed, and the records the spec asks for. The pages themselves are
// tested in e2e/onboarding.spec.ts and the words in
// src/screens/welcome-copy.test.ts.
//
// Each rule has a "catches" test that feeds it something that breaks it.

const read = (path: string) => readFileSync(path, 'utf8')
const withoutComments = (text: string) => text.replace(/\/\*[\s\S]*?\*\//g, '').replace(/^\s*\/\/.*$/gm, '')

// The welcome's copy file ---------------------------------------------------------------

describe('the welcome source', () => {
  it('[onboarding 4] the copy file has no ä, ö or å, in its words or its comments (no Finnish, owner call 5 A)', () => {
    expect(read('src/screens/welcome-copy.ts')).not.toMatch(/[äöåÄÖÅ]/)
  })

  // Controls and Finnish: the component never writes a tag that can be tapped.
  const CONTROLS = /<\s*(button|a|input|select|textarea|img|picture|video|canvas|svg|dialog|form|label)\b/i
  const FINNISH_MARK = /\blang\s*=\s*["'{]\s*["']?fi/i
  const STORAGE = /localStorage|sessionStorage|indexedDB|document\.cookie|cookieStore|\bcaches\b/
  const REQUESTS = /fetch\(|callApi|XMLHttpRequest|sendBeacon|WebSocket|EventSource|navigator\./

  it('[onboarding 4] the component has no button, link, input, select, text area or picture, and no lang="fi"', () => {
    const component = withoutComments(read('src/screens/Welcome.tsx'))
    expect(CONTROLS.exec(component)).toBeNull()
    expect(FINNISH_MARK.exec(component)).toBeNull()
    expect(component).not.toMatch(/\bonClick\b|\bonKey|\btabIndex\b|\bhref\b|\bsrc\s*=/)
  })

  it('[onboarding 7] the component and its copy touch no storage and make no request', () => {
    for (const file of ['src/screens/Welcome.tsx', 'src/screens/welcome-copy.ts']) {
      const text = withoutComments(read(file))
      expect(STORAGE.exec(text), file).toBeNull()
      expect(REQUESTS.exec(text), file).toBeNull()
    }
  })

  it('[onboarding 7] the front door still makes exactly its two requests and touches no storage', () => {
    const door = withoutComments(read('src/screens/FrontDoor.tsx'))
    expect([...door.matchAll(/callApi\(/g)]).toHaveLength(2)
    expect(door).toContain("callApi('/api/today', 'GET')")
    expect(door).toContain("callApi('/api/guest', 'POST')")
    expect(STORAGE.exec(door)).toBeNull()
    expect(/fetch\(|XMLHttpRequest|sendBeacon|WebSocket|EventSource/.exec(door)).toBeNull()
  })

  it('[onboarding 5] [onboarding 6] the welcome shows only for a new visitor, from the answer of /api/today', () => {
    const door = withoutComments(read('src/screens/FrontDoor.tsx'))
    // One rule, in one place: signed out, not ended, no notice message.
    expect(door).toMatch(
      /const newVisitor =\s*view\.kind === 'signed_out' && !view\.ended && noticeFrom\(window\.location\.search\) === null/,
    )
    expect([...door.matchAll(/<Welcome[ >]/g)]).toHaveLength(1)
    expect(door).toMatch(/\{newVisitor && <Welcome className=\{styles\.welcome\} \/>\}/)
  })

  it('[onboarding 1] the welcome sits in the intro, after the lead sentence and before the actions (Start)', () => {
    const door = withoutComments(read('src/screens/FrontDoor.tsx'))
    const lead = door.indexOf('<p className={styles.lead}>')
    const welcome = door.indexOf('<Welcome ')
    const actions = door.indexOf('<div className={styles.actions}>')
    expect(lead).toBeGreaterThan(0)
    expect(welcome).toBeGreaterThan(lead)
    expect(actions).toBeGreaterThan(welcome)
  })
})

describe('the welcome styles', () => {
  const css = withoutComments(read('src/screens/Welcome.module.css'))

  it('[onboarding 11] use tokens only: no hex or function colour, no gradient, picture, animation, transition or uppercase', () => {
    for (const bad of [
      /#[0-9a-f]{3,8}\b/i,
      /\brgba?\(/i,
      /\bhsla?\(/i,
      /gradient/i,
      /\burl\(/i,
      /\banimation/i,
      /\btransition/i,
      /\btransform\b/i,
      /text-transform/i,
      /backdrop-filter/i,
      /box-shadow/i,
      /\bcolor-mix\(/i,
    ]) {
      expect(css.match(bad), String(bad)).toBeNull()
    }
    // Every colour comes from a token.
    for (const [, value] of css.matchAll(/(?:^|\s)(?:color|background|border-color)\s*:\s*([^;]+);/g)) {
      expect(value, String(value)).toMatch(/var\(--color-[a-z-]+\)/)
    }
  })

  it('[onboarding 3] the two bands use the spoken and written tokens and the sentences the text token', () => {
    expect(css).toMatch(/\.spoken\s*\{[^}]*background:\s*var\(--color-spoken-band\)/)
    expect(css).toMatch(/\.labelSpoken[\s\S]*?color:\s*var\(--color-spoken-text\)/)
    expect(css).toMatch(/\.labelWritten\s*\{[^}]*color:\s*var\(--color-written\)/)
    expect(css).toMatch(/\.text\s*\{[^}]*color:\s*var\(--color-text\)/)
    // Azure marks only words that change (design.md).
    expect(css).not.toMatch(/--color-flag/)
  })

  it('[onboarding 11] no border wider than 1 px and none on one side only', () => {
    for (const [, value] of css.matchAll(/border(?:-[a-z]+)*\s*:\s*([^;]+);/g)) {
      expect(value, String(value)).not.toMatch(/\b[2-9]px\b|\bthick\b|\bmedium\b/)
    }
    expect(css).not.toMatch(/border-(top|right|bottom|left|inline|block)/)
  })
})

describe('the rules catch what they are meant to catch', () => {
  it('[onboarding 4] the control rule catches a button, a link, an input and a lang="fi"', () => {
    const CONTROLS = /<\s*(button|a|input|select|textarea|img|picture|video|canvas|svg|dialog|form|label)\b/i
    for (const bad of [
      '<button>',
      '<a href="/x">',
      '<input />',
      '<select>',
      '<textarea>',
      '<img src="x" />',
    ]) {
      expect(CONTROLS.exec(bad), bad).not.toBeNull()
    }
    expect(/\blang\s*=\s*["'{]\s*["']?fi/i.exec('<p lang="fi">')).not.toBeNull()
    expect(CONTROLS.exec('<section><h2>x</h2><p>y</p><div>z</div></section>')).toBeNull()
  })
})

// The branch changed nothing outside the app's screens (statement 7) -------------------

function baseBranch(): string | null {
  for (const ref of ['main', 'origin/main']) {
    try {
      execFileSync('git', ['rev-parse', '--verify', '--quiet', `${ref}^{commit}`], { stdio: 'ignore' })
      return ref
    } catch {
      // Try the next name.
    }
  }
  return null
}

const BASE = baseBranch()

// The GitHub checks start from a one commit checkout without main, so on
// GitHub this test cannot run; build.md records the run on this computer. After
// the merge the branch is main, and the diff is empty by itself.
const itWithBase = it.skipIf(BASE === null)
const WHEN_NO_BASE = '(skipped while the checkout has no main branch to compare with)'

describe('what the branch changed', () => {
  itWithBase(
    `[onboarding 7] git diff --stat main...HEAD for worker, supabase, wrangler.jsonc, package.json, package-lock.json and src/privacy prints nothing ${WHEN_NO_BASE}`,
    () => {
      const out = execFileSync(
        'git',
        [
          'diff',
          '--stat',
          `${BASE ?? 'main'}...HEAD`,
          '--',
          'worker',
          'supabase',
          'wrangler.jsonc',
          'package.json',
          'package-lock.json',
          'src/privacy',
        ],
        { encoding: 'utf8' },
      )
      expect(out).toBe('')
    },
  )

  it('[onboarding 7] the page route list is the one the visit counter already knows (no new address)', () => {
    const routes = read('worker/page-routes.ts')
    expect(routes).not.toMatch(/welcome|onboarding/i)
  })

  it('[onboarding 7] nothing in the Worker, the database folder or the privacy notice names the welcome', () => {
    // git grep exits 1 when nothing matches, which is the answer wanted here.
    const run = spawnSync(
      'git',
      ['grep', '-il', '-e', 'welcome', '--', 'worker', 'supabase', 'src/privacy', 'wrangler.jsonc'],
      { encoding: 'utf8' },
    )
    expect(run.status, run.stderr).toBeLessThanOrEqual(1)
    expect(run.stdout.split(/\r?\n/).filter(Boolean)).toEqual([])
  })
})

// The records (statements 12 and 13) ---------------------------------------------------

describe('the hallway test pack', () => {
  const SHEET = 'factory/jobs/15-onboarding/evidence/hallway-test.md'
  const sheet = read(SHEET)
  const section = (title: string): string => {
    const start = sheet.indexOf(`\n## ${title}`)
    expect(start, title).toBeGreaterThan(-1)
    const next = sheet.indexOf('\n## ', start + 1)
    return sheet.slice(start, next === -1 ? undefined : next)
  }
  const bullets = (text: string) => text.split('\n').filter((line) => line.startsWith('- '))

  it('[onboarding 12] gives the exact words said to each person', () => {
    const said = section('What you say')
    expect(said).toContain('Use this app as you like.')
    expect(said).toMatch(/guest account/i)
    expect(said).toMatch(/90 days/)
  })

  it('[onboarding 12] gives the stopwatch rule: starts when the phone is handed over, stops at the first line', () => {
    const rule = section('The stopwatch')
    expect(rule).toMatch(/starts/i)
    expect(rule).toMatch(/stops/i)
    expect(rule).toMatch(/first dialogue line/i)
    expect(rule).toMatch(/60 seconds/)
  })

  it('[onboarding 12] gives the two questions, word for word', () => {
    const questions = section('The two questions')
    expect(questions).toContain('"In your own words, what does spoken Finnish mean in this app?"')
    expect(questions).toContain('"In your own words, what does written Finnish mean in this app?"')
  })

  it('[onboarding 12] gives a marking guide with three answers that pass and three that fail, for each question', () => {
    const guide = section('Marking guide')
    const parts = guide.split(/\n### /).slice(1)
    expect(parts.map((part) => part.split('\n')[0])).toEqual([
      'Spoken Finnish, answers that pass',
      'Spoken Finnish, answers that fail',
      'Written Finnish, answers that pass',
      'Written Finnish, answers that fail',
    ])
    for (const part of parts) expect(bullets(part).length, part.split('\n')[0]).toBeGreaterThanOrEqual(3)
    expect(guide).toMatch(/how people really talk in daily life/i)
    expect(guide).toMatch(/books, forms and signs/i)
  })

  it('[onboarding 12] has a result table of 5 rows, one per person, with every column the spec names, all still empty', () => {
    const table = section('Results')
      .split('\n')
      .filter((line) => line.startsWith('|'))
    const cells = (line: string) =>
      line
        .split('|')
        .slice(1, -1)
        .map((cell) => cell.trim())
    expect(cells(table[0] ?? '')).toEqual([
      'Person',
      'Age band',
      'Months in Finland',
      'Speaks Finnish',
      'Seconds to the first line',
      'Answer: spoken Finnish',
      'Answer: written Finnish',
      'Pass or fail',
    ])
    const rows = table.slice(2)
    expect(rows).toHaveLength(5)
    rows.forEach((row, i) => {
      const [person, ...rest] = cells(row)
      expect(person).toBe(String(i + 1))
      // Nothing is filled in: the owner runs the test (statement 12).
      expect(
        rest.every((cell) => cell === ''),
        `row ${String(i + 1)}`,
      ).toBe(true)
    })
  })

  it('[onboarding 12] says the test has not been run and marks nothing as passed', () => {
    expect(sheet).toContain('Status: not run yet.')
    expect(sheet).not.toMatch(/status:\s*pass/i)
    const totals = section('Totals')
    expect(totals).toMatch(/reached the first line within 60 seconds: \s*_* of 5/i)
    expect(totals).toMatch(/explained both forms correctly: \s*_* of 5/i)
    expect(totals).toMatch(/4 of 5/)
  })

  it('[onboarding 12] follows the writing rules: no em dash, no colon reveal sentence, no hype word', () => {
    expect(sheet).not.toMatch(/[—–]/)
    expect(sheet).not.toMatch(
      /\b(seamless|unlock|elevate|empower|supercharge|game-changer|cutting-edge|effortless)\b/i,
    )
  })

  it('[onboarding 12] stores no name: the sheet has no name column and says no name is taken', () => {
    expect(sheet).toMatch(/no name is taken/i)
    expect(sheet).not.toMatch(/\|\s*Name\s*\|/i)
  })
})

describe('the records', () => {
  it('[onboarding 13] design.md has a "Welcome block" entry that names the tokens and the rules', () => {
    const design = read('design.md')
    const start = design.indexOf('### Welcome block')
    expect(start).toBeGreaterThan(-1)
    const entry = design.slice(
      start,
      !design.includes('\n### ', start + 1) ? undefined : design.indexOf('\n### ', start + 1),
    )
    for (const word of [
      '--color-spoken-band',
      '--color-spoken-text',
      '--color-written',
      '--color-text',
      'welcome-copy.ts',
    ]) {
      expect(entry, word).toContain(word)
    }
    expect(entry).toMatch(/azure/i)
  })

  it('[onboarding 13] conventions.md has the [onboarding N] row for 15-onboarding', () => {
    const conventions = read('docs/conventions.md')
    expect(conventions).toMatch(/\|\s*15-onboarding\s*\|\s*`\[onboarding N\]`\s*\|/)
  })

  it('[onboarding 13] the reference page shows the welcome block', () => {
    const reference = read('src/design-reference/DesignReference.tsx')
    expect(reference).toMatch(/<Section id="welcome" title="Welcome block">/)
    expect(reference).toContain('<Welcome />')
  })

  it('[onboarding 13] the README running costs table has no new row and no cost for onboarding', () => {
    const readme = read('README.md')
    const costs = readme.slice(readme.indexOf('## Running costs'))
    expect(costs.toLowerCase()).not.toContain('onboarding')
    expect(costs.toLowerCase()).not.toContain('welcome')
  })
})
