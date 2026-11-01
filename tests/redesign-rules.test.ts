import { readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'

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
    expect(importers.every((path) => path.startsWith('src/design-reference/'))).toBe(true)
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
    const picture = readFileSync('src/road/RoadPicture.tsx', 'utf8')
    expect(picture).not.toMatch(/<button/)
    expect(picture).not.toMatch(/onClick/)
  })

  it('[redesign 44] the road never stores anything on the phone', () => {
    for (const path of [...screens, 'src/road/home-view.ts', 'src/lib/road-data.ts']) {
      const text = readFileSync(path, 'utf8')
      expect(text, path).not.toMatch(/localStorage|sessionStorage|indexedDB|document\.cookie/)
    }
  })
})
