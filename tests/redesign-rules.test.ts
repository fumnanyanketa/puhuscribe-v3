import { readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'
import { CONTRAST_PAIRS } from '../src/styles/contrast-pairs.ts'

// Repository rules of factory/jobs/19-redesign/spec.md. Labels in brackets are
// that spec's "Done when" statement numbers.

interface SourceFile {
  path: string
  text: string
}

function sourceFiles(dir: string): SourceFile[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name).replaceAll('\\', '/')
    if (statSync(path).isDirectory()) return sourceFiles(path)
    return /\.(css|tsx?)$/.test(name) ? [{ path, text: readFileSync(path, 'utf8') }] : []
  })
}

const SRC = sourceFiles('src')
const isTest = (path: string) => /\.test\.tsx?$/.test(path)

// The files job 19-redesign adds (statement 45). Files it only restyles keep
// their existing strings, and job 17's move then changes the constant file
// plus those strings.
const ADDED = [
  'src/road/RoadCard.tsx',
  'src/road/RoadPicture.tsx',
  'src/road/RoadTop.tsx',
  'src/road/LoadingMark.tsx',
  'src/road/home-view.ts',
  'src/screens/RoadScreen.tsx',
  'src/screens/OfflineScreen.tsx',
  'src/screens/road-copy.ts',
  'src/lib/road-data.ts',
  'src/lib/road-state.ts',
  'src/lib/road-types.ts',
  'src/components/Sheet.tsx',
  'src/components/Landscape.tsx',
]

// A quoted app path: '/account, "/session, `/learn and the others.
const QUOTED_PATH = /['"`]\/(account|session|learn|sign-in|privacy|voice|feedback)\b/

describe('paths', () => {
  it('[redesign 45] the files this job adds hold no quoted app path', () => {
    const offenders = ADDED.filter((path) => {
      const file = SRC.find((candidate) => candidate.path === path)
      expect(file, `${path} exists`).toBeDefined()
      return QUOTED_PATH.test(file?.text ?? '')
    })
    expect(offenders).toEqual([])
  })

  it('[redesign 45] the path check catches a quoted path', () => {
    expect(QUOTED_PATH.test("window.location.assign('/session')")).toBe(true)
    expect(QUOTED_PATH.test('window.location.assign(`/account/email`)')).toBe(true)
    expect(QUOTED_PATH.test('window.location.assign(PATHS.session)')).toBe(false)
  })

  it('[redesign 45] the paths come from one constant file', () => {
    const constants = readFileSync('src/lib/app-paths.ts', 'utf8')
    for (const path of [
      '/session',
      '/account',
      '/account/email',
      '/account/delete',
      '/sign-in',
      '/privacy',
    ]) {
      expect(constants).toContain(`'${path}'`)
    }
  })
})

describe('the road fixture', () => {
  it('[redesign 19] is imported only by tests and the reference page, never by a screen a learner sees', () => {
    const importers = SRC.filter(
      (file) =>
        file.text.includes('road-fixture') && !isTest(file.path) && file.path !== 'src/road/road-fixture.ts',
    ).map((file) => file.path)
    // The island design page (src/sample/IslandSample.tsx, fast route "islands") shows the road with
    // the fixture too. Like the reference page it is built only with VITE_DESIGN_REFERENCE=1
    // (src/main.tsx), and tests/design-build.test.ts proves a normal build holds neither.
    expect(importers.length).toBeGreaterThan(0)
    expect(importers.filter((path) => !/^src\/(design-reference|sample)\//.test(path))).toEqual([])
  })

  it('[redesign 19] the road screen reads stops only through loadRoad()', () => {
    const screen = readFileSync('src/screens/RoadScreen.tsx', 'utf8')
    expect(screen).toContain('loadRoad()')
    expect(screen).not.toMatch(/road-fixture/)
  })
})

describe('what the road must not hold', () => {
  const screens = ['src/screens/RoadScreen.tsx', 'src/road/RoadCard.tsx', 'src/road/RoadPicture.tsx']

  it('[redesign 13] a sign is not a button and nothing renders a name as markup', () => {
    for (const path of screens) {
      const text = readFileSync(path, 'utf8')
      expect(text, path).not.toContain('dangerouslySetInnerHTML')
      expect(text, path).not.toContain('innerHTML')
    }
    // Fast route go-back (3 November 2026, owner): a finished stop's sign can be pressed to practise
    // its lessons again, storing nothing. So exactly one button remains, drawn only for a done sign
    // when the road offers practice, and it does nothing but name the stop to onPick. Every other
    // sign is still not a button.
    const picture = readFileSync('src/road/RoadPicture.tsx', 'utf8')
    expect(picture.match(/<button/g)).toHaveLength(1)
    expect(picture.match(/onClick/g)).toHaveLength(1)
    expect(picture).toMatch(
      /\{onPick && sign\.state === 'done' \? \(\s*<button[^>]*?onClick=\{\(\) => \{\s*onPick\(sign\.stop\.number\)\s*\}\}/s,
    )
  })

  // Fast route intro-visit (owner, 5 November 2026) changed this rule: the road now keeps one thing, the
  // visit's time stamp in this tab's sessionStorage, so Aleksi's intro shows once per visit. The road's own
  // files still never reach any storage; only src/lib/aleksi-intro.ts does, and its one write is that key.
  it('[redesign 44] [intro-visit 1] the road stores nothing on the phone but the visit time, kept by src/lib/aleksi-intro.ts', () => {
    for (const path of [...screens, 'src/road/home-view.ts', 'src/lib/road-data.ts']) {
      const text = readFileSync(path, 'utf8')
      expect(text, path).not.toMatch(/localStorage|sessionStorage|indexedDB|document\.cookie/)
    }
    const visit = readFileSync('src/lib/aleksi-intro.ts', 'utf8')
    expect(visit).not.toMatch(/indexedDB|document\.cookie/)
    expect(visit.match(/\.setItem\(/g)).toEqual(['.setItem('])
    expect(visit).toContain('.setItem(VISIT_KEY, String(now()))')
  })
})

describe('small text placed straight on the wash', () => {
  it('[redesign 6] the "Delete my account" link uses a colour whose pair on the peach end of the wash is in the contrast list at 4.5 to 1', () => {
    const css = readFileSync('src/screens/Account.module.css', 'utf8')
    const block = /\.deleteLink\s*\{[^}]*?color:\s*var\((--[a-z-]+)\)/s.exec(css)
    const token = block?.[1] ?? ''
    expect(token).not.toBe('')
    const pair = CONTRAST_PAIRS.find((p) => p.fore === token && p.back === '--color-wash-bottom')
    expect(
      pair?.min,
      `${token} on the peach end of the wash must be in the contrast list`,
    ).toBeGreaterThanOrEqual(4.5)
  })

  it('[redesign 4] [redesign 41] the crash screen starts its words below the landscape, like every page', () => {
    const css = readFileSync('src/components/CrashBoundary.module.css', 'utf8')
    const page = /\.page\s*\{[^}]*\}/s.exec(css)?.[0] ?? ''
    expect(page).toMatch(/padding:\s*var\(--page-content-top\)/)
  })
})
