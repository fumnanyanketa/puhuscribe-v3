import { readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'
import { contrast, isOpaqueHex } from '../src/lib/contrast.ts'
import { CONTRAST_PAIRS } from '../src/styles/contrast-pairs.ts'
import { asMap, colourTokens } from '../src/styles/token-values.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/5-design-system/spec.md ([design N]) and
// factory/jobs/19-redesign/spec.md ([redesign N]).

const TOKENS = readFileSync('src/styles/tokens.css', 'utf8')
const DESIGN_MD = readFileSync('design.md', 'utf8')

const LIGHT = asMap(colourTokens(TOKENS))

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

interface SourceFile {
  path: string
  text: string
}

function srcFiles(dir: string, pattern: RegExp): SourceFile[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name).replaceAll('\\', '/')
    if (statSync(path).isDirectory()) return srcFiles(path, pattern)
    return pattern.test(name) && !name.endsWith('.test.ts')
      ? [{ path, text: readFileSync(path, 'utf8') }]
      : []
  })
}

describe('design tokens', () => {
  it('[design 3] [redesign 1] every colour token in tokens.css is a hex value', () => {
    const declared = [...TOKENS.matchAll(/(--color-[a-z0-9-]+):\s*([^;]+);/g)].map((m) => m[2]?.trim() ?? '')
    expect(declared.length).toBeGreaterThan(55)
    for (const value of declared) expect(value).toMatch(/^#[0-9a-f]{6}([0-9a-f]{2})?$/)
    expect(LIGHT.size).toBeGreaterThan(55)
  })

  it('[redesign 1] the look is light only: no dark block, and the page declares light', () => {
    expect(TOKENS).not.toMatch(/prefers-color-scheme/)
    expect(TOKENS).toMatch(/color-scheme:\s*light;/)
    expect(readFileSync('index.html', 'utf8')).toMatch(/<meta name="color-scheme" content="light" \/>/)
  })

  for (const { fore, back, min, use } of CONTRAST_PAIRS) {
    it(`[design 4] [redesign 6] ${use} reaches ${String(min)}:1`, () => {
      const a = LIGHT.get(fore) ?? ''
      const b = LIGHT.get(back) ?? ''
      expect(isOpaqueHex(a), `${fore} must be an opaque colour`).toBe(true)
      expect(isOpaqueHex(b), `${back} must be an opaque colour`).toBe(true)
      expect(contrast(a, b)).toBeGreaterThanOrEqual(min)
    })
  }

  it('[design 4] [redesign 6] design.md lists exactly the pairings this test checks', () => {
    const tested = CONTRAST_PAIRS.map(({ fore, back, min }) => `${fore} on ${back} at ${String(min)}`).sort()
    expect(designMdPairs()).toEqual(tested)
  })

  it('[design 4] the contrast formula matches known WCAG values', () => {
    expect(contrast('#000000', '#ffffff')).toBeCloseTo(21, 5)
    expect(contrast('#767676', '#ffffff')).toBeCloseTo(4.54, 2)
  })

  it('[design 3] no file in src/ other than tokens.css holds a raw colour value', () => {
    const raw = /#[0-9a-fA-F]{3,8}\b|\brgba?\(|\bhsla?\(|\boklch\(/
    // The landing page exception (design.md, owner's approval of 3 November 2026, job
    // 17-landing-page): its soft panel colours and shadows are named once, as --landing-*
    // properties in Landing.module.css, and its hero picture (Landing.tsx) is drawn art with SVG
    // fill, stroke and stop colours. Those two places only; the app keeps the rule.
    const allowed = (path: string, text: string) => {
      if (path === 'src/landing/Landing.module.css') return text.replace(/^\s*--landing-[\w-]+:[^;]*;/gm, '')
      if (path === 'src/landing/Landing.tsx')
        return text.replace(/\b(fill|stroke|stopColor)="#[0-9a-fA-F]{3,8}"/g, '')
      return text
    }
    const offenders = srcFiles('src', /\.(css|tsx?)$/)
      .filter((file) => file.path !== 'src/styles/tokens.css' && raw.test(allowed(file.path, file.text)))
      .map((file) => file.path)
    expect(offenders).toEqual([])
  })

  it('[redesign 1] the lilac ground, violet, teal and azure tokens are gone from src/, names and values', () => {
    const removedNames = [
      '--color-ground-top',
      '--color-ground-middle',
      '--color-ground-bottom',
      '--ground-fade',
      '--color-spoken-band',
      '--color-spoken-band-edge',
      '--color-flag-text',
      '--color-flag-wash',
    ]
    // The old violet, teal, azure and lilac values of job 5.
    const removedValues = ['#6b46c1', '#1f7c8e', '#1f42ac', '#f1f0f6', '#faf9fc', '#6b4fc6', '#4fb3c4']
    const hits: string[] = []
    for (const file of srcFiles('src', /\.(css|tsx?)$/)) {
      for (const name of removedNames) if (file.text.includes(name)) hits.push(`${name} in ${file.path}`)
      for (const value of removedValues)
        if (file.text.toLowerCase().includes(value)) hits.push(`${value} in ${file.path}`)
    }
    expect(hits).toEqual([])
  })

  it('[redesign 3] the ground wash is declared once and the grain holds no gradient', () => {
    expect([...TOKENS.matchAll(/--ground-wash:/g)]).toHaveLength(1)
    const grain = /--grain:\s*(url\("[^"]*"\))/.exec(TOKENS)?.[1] ?? ''
    expect(grain).toContain('data:image/svg+xml')
    expect(grain).not.toMatch(/gradient/i)
    expect(grain).not.toMatch(/https?:\/\/(?!www\.w3\.org)/)
  })

  it('[redesign 3] panels take their fill, edge, shadow and corner from panel tokens', () => {
    for (const name of ['--panel-fill', '--panel-edge', '--panel-shadow', '--panel-radius']) {
      expect(TOKENS, name).toContain(`${name}:`)
    }
    for (const file of srcFiles('src', /\.module\.css$/)) {
      // A class that uses the panel fill sets no shadow or corner of its own: they are
      // tokens, or the panel's own, never a number written in the component.
      for (const block of file.text.matchAll(/\.[A-Za-z]+\s*\{([^}]*var\(--panel-fill\)[^}]*)\}/g)) {
        const body = block[1] ?? ''
        expect(body, `${file.path} panel shadow`).not.toMatch(/box-shadow:\s*(?!\s|var\(|none)/)
        expect(body, `${file.path} panel corner`).not.toMatch(/border-radius:\s*[0-9.]+(px|rem|em)/)
      }
    }
  })
})

describe('type scale', () => {
  const px = (name: string): number => {
    const value = new RegExp(`${name}:\\s*([\\d.]+)rem`).exec(TOKENS)?.[1] ?? '0'
    return Number(value) * 16
  }

  it('[redesign 5] no text token is under 12 px', () => {
    const names = [...TOKENS.matchAll(/(--text-[a-z-]+):\s*[\d.]+rem/g)].map((m) => m[1] ?? '')
    expect(names.length).toBeGreaterThan(8)
    for (const name of names) expect(px(name), name).toBeGreaterThanOrEqual(12)
  })

  it('[redesign 5] reading text is at least 14 px, written Finnish 17 px and spoken Finnish 18 px', () => {
    expect(px('--text-body')).toBeGreaterThanOrEqual(14)
    expect(px('--text-reading')).toBeGreaterThanOrEqual(14)
    expect(px('--text-button')).toBeGreaterThanOrEqual(14)
    expect(px('--text-written')).toBeGreaterThanOrEqual(17)
    expect(px('--text-line')).toBeGreaterThanOrEqual(18)
    expect(px('--text-line-large')).toBeGreaterThanOrEqual(18)
    expect(px('--text-word-card')).toBeGreaterThanOrEqual(18)
  })

  it('[redesign 5] the sizes of the mock times 1.25 are as the spec table says', () => {
    expect(px('--text-title')).toBe(20)
    expect(px('--text-line')).toBe(19)
    expect(px('--text-line-large')).toBe(21)
    expect(px('--text-word-card')).toBe(32)
    expect(px('--text-button')).toBeCloseTo(14.5, 5)
    expect(px('--text-sign')).toBe(13)
  })

  it('[redesign 5] a component never sets a font size of its own: every size reads a text token', () => {
    const offenders: string[] = []
    for (const file of srcFiles('src', /\.css$/)) {
      if (file.path === 'src/styles/tokens.css') continue
      // The landing page exception (design.md, 3 November 2026): the public landing page keeps the
      // type sizes of the owner's approved design, in rem (tests/design-rules.test.ts [design 5]).
      if (file.path === 'src/landing/Landing.module.css') continue
      for (const match of file.text.matchAll(/font-size:\s*([^;]+);/g)) {
        const value = (match[1] ?? '').trim()
        if (!/^(var\(--text-[a-z-]+\)|inherit|100%|1em|0)$/.test(value))
          offenders.push(`${file.path}: ${value}`)
      }
    }
    expect(offenders).toEqual([])
  })
})

describe('colour roles', () => {
  // Statement 2 of factory/jobs/19-redesign/spec.md: mint for spoken Finnish,
  // slate for written Finnish and peach for the words that change are each used
  // only where their role says. A new use elsewhere fails until the list is
  // changed on purpose.
  const ROLES: Record<string, { tokens: string[]; files: string[] }> = {
    spoken: {
      tokens: ['--color-spoken', '--color-spoken-text', '--color-spoken-soft'],
      files: [
        'src/components/FinnishLine.module.css',
        'src/components/GapLine.module.css',
        'src/components/PatternsPanel.module.css',
        'src/components/WordCard.module.css',
        'src/sample/HearItSample.module.css',
        // The landing page's spoken examples (job 17-landing-page).
        'src/landing/Landing.module.css',
        // The recap's cover box, drawn like the spoken line's box (fast route hear-and-say).
        'src/screens/Screens.module.css',
      ],
    },
    written: {
      tokens: ['--color-written', '--color-written-soft'],
      files: [
        'src/components/FinnishLine.module.css',
        'src/components/GapLine.module.css',
        'src/components/PatternsPanel.module.css',
        'src/components/PlayControl.module.css',
        'src/components/WordCard.module.css',
        'src/design-reference/DesignReference.module.css',
        'src/sample/HearItSample.module.css',
        // The finish screen's written line (job 8, statement 14), drawn small under the spoken one in round 6.
        'src/screens/Screens.module.css',
        // The island card's written lines (fast route islands) and the landing page's written examples.
        'src/island/Island.module.css',
        'src/landing/Landing.module.css',
      ],
    },
    changed: {
      tokens: ['--color-changed-text', '--color-changed-wash'],
      files: [
        'src/components/FinnishLine.module.css',
        'src/road/RoadPicture.module.css',
        'src/sample/HearItSample.module.css',
        // The landing page's examples mark the words that change (job 17-landing-page).
        'src/landing/Landing.module.css',
      ],
    },
  }

  function filesUsing(tokens: string[]): string[] {
    return srcFiles('src', /\.(css|tsx?)$/)
      .filter((file) => file.path !== 'src/styles/tokens.css')
      .filter((file) => tokens.some((token) => file.text.includes(`var(${token})`)))
      .map((file) => file.path)
      .sort()
  }

  for (const [role, { tokens, files }] of Object.entries(ROLES)) {
    it(`[redesign 2] the ${role} role tokens are used only in the files that may use them`, () => {
      expect(filesUsing(tokens)).toEqual([...files].sort())
    })
  }
})
