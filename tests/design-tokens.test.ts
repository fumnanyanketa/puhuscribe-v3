import { readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'
import { contrast, isOpaqueHex } from '../src/lib/contrast.ts'
import { CONTRAST_PAIRS } from '../src/styles/contrast-pairs.ts'
import { asMap, colourTokens } from '../src/styles/token-values.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/5-design-system/spec.md.

const TOKENS = readFileSync('src/styles/tokens.css', 'utf8')
const DESIGN_MD = readFileSync('design.md', 'utf8')

const { light, dark } = colourTokens(TOKENS)
const LIGHT = asMap(light)
const DARK = asMap(dark)

// The rows of design.md's contrast table: | `--fore` | `--back` | 7:1 | use |
function designMdPairs(): string[] {
  const rows: string[] = []
  for (const match of DESIGN_MD.matchAll(
    /^\|\s*`(--color-[a-z0-9-]+)`\s*\|\s*`(--color-[a-z0-9-]+)`\s*\|\s*(\d(?:\.\d)?):1\s*\|/gm,
  )) {
    rows.push(`${match[1] ?? ''} on ${match[2] ?? ''} at ${match[3] ?? ''}`)
  }
  return rows.sort()
}

describe('design tokens', () => {
  it('[design 3] light and dark declare the same colour names, all as hex', () => {
    expect(LIGHT.size).toBeGreaterThan(30)
    expect([...DARK.keys()].sort()).toEqual([...LIGHT.keys()].sort())
  })

  it('[design 3] every colour token in tokens.css is a hex value', () => {
    const declared = [...TOKENS.matchAll(/(--color-[a-z0-9-]+):\s*([^;]+);/g)].map((m) => m[2]?.trim() ?? '')
    expect(declared.length).toBeGreaterThan(60)
    for (const value of declared) expect(value).toMatch(/^#[0-9a-f]{6}([0-9a-f]{2})?$/)
  })

  for (const [mode, values] of [
    ['light', LIGHT],
    ['dark', DARK],
  ] as const) {
    for (const { fore, back, min, use } of CONTRAST_PAIRS) {
      it(`[design 4] ${mode}: ${use} reaches ${String(min)}:1`, () => {
        const a = values.get(fore) ?? ''
        const b = values.get(back) ?? ''
        expect(isOpaqueHex(a), `${fore} must be an opaque colour`).toBe(true)
        expect(isOpaqueHex(b), `${back} must be an opaque colour`).toBe(true)
        expect(contrast(a, b)).toBeGreaterThanOrEqual(min)
      })
    }
  }

  it('[design 4] design.md lists exactly the pairings this test checks', () => {
    const tested = CONTRAST_PAIRS.map(({ fore, back, min }) => `${fore} on ${back} at ${String(min)}`).sort()
    expect(designMdPairs()).toEqual(tested)
  })

  it('[design 4] the contrast formula matches known WCAG values', () => {
    expect(contrast('#000000', '#ffffff')).toBeCloseTo(21, 5)
    expect(contrast('#767676', '#ffffff')).toBeCloseTo(4.54, 2)
  })

  it('[design 3] no file in src/ other than tokens.css holds a raw colour value', () => {
    const raw = /#[0-9a-fA-F]{3,8}\b|\brgba?\(|\bhsla?\(|\boklch\(/
    const offenders: string[] = []
    const walk = (dir: string) => {
      for (const name of readdirSync(dir)) {
        const path = join(dir, name)
        if (statSync(path).isDirectory()) walk(path)
        else if (
          /\.(css|tsx?)$/.test(name) &&
          !name.endsWith('.test.ts') &&
          path !== join('src', 'styles', 'tokens.css')
        ) {
          if (raw.test(readFileSync(path, 'utf8'))) offenders.push(path)
        }
      }
    }
    walk('src')
    expect(offenders).toEqual([])
  })
})
