import { readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'

// Statement 18 of factory/jobs/5-design-system/spec.md: the banned look and
// CSS newer than the oldest supported Safari (15.4) are refused in src/.
// One owner-approved exception (21 October 2026, summary.md): v2's white to
// lilac fade, declared once as --ground-fade in tokens.css and used only as
// the page background in base.css. Every other gradient is refused.
//
// Each rule is proven by the "catches" tests below, which feed it a line that
// breaks it and expect a finding.

interface SourceFile {
  path: string
  text: string
}

function sourceFiles(dir: string, pattern: RegExp): SourceFile[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name).replaceAll('\\', '/')
    if (statSync(path).isDirectory()) return sourceFiles(path, pattern)
    return pattern.test(name) && !name.endsWith('.test.ts')
      ? [{ path, text: readFileSync(path, 'utf8') }]
      : []
  })
}

function withoutComments(css: string): string {
  return css.replace(/\/\*[\s\S]*?\*\//g, '')
}

const TOKENS_PATH = 'src/styles/tokens.css'
const BASE_PATH = 'src/styles/base.css'

// The one allowed gradient: the --ground-fade declaration in tokens.css.
function allowedGradients(file: SourceFile): number {
  if (file.path !== TOKENS_PATH) return 0
  return [...withoutComments(file.text).matchAll(/--ground-fade:\s*linear-gradient\(/g)].length
}

/** Width of one border width token in px, or null when the token is not a width. */
function widthOf(token: string): number | null {
  const value = token.toLowerCase()
  if (value === '0') return 0
  if (value === 'thin') return 1
  if (value === 'medium') return 3
  if (value === 'thick') return 5
  const px = /^(\d*\.?\d+)px$/.exec(value)
  if (px) return Number(px[1])
  const em = /^(\d*\.?\d+)r?em$/.exec(value)
  if (em) return Number(em[1]) * 16
  return null
}

/** The widest width named anywhere in a border value (a shorthand or a width). */
function widestIn(value: string): number {
  const widths = value
    .trim()
    .split(/\s+/)
    .map(widthOf)
    .filter((width): width is number => width !== null)
  return widths.length > 0 ? Math.max(...widths) : 0
}

interface Declaration {
  property: string
  value: string
}

// CSS declarations, and the style objects of .tsx files read the same way
// (fontFamily becomes font-family, WebkitBackgroundClip becomes
// -webkit-background-clip). Property names are lower case; values keep case.
function declarations(file: SourceFile, text: string): Declaration[] {
  if (file.path.endsWith('.css')) {
    return [...text.matchAll(/(--[\w-]+|[a-zA-Z-]+)\s*:\s*([^;{}]+)/g)].map((m) => ({
      property: (m[1] ?? '').toLowerCase(),
      value: (m[2] ?? '').trim(),
    }))
  }
  return [...text.matchAll(/['"]?(--[\w-]+|[a-zA-Z]+)['"]?\s*:\s*(['"`])([^'"`]*)\2/g)].map((m) => {
    const key = m[1] ?? ''
    const property = key.startsWith('--')
      ? key.toLowerCase()
      : key.replace(/[A-Z]/g, (c) => `-${c.toLowerCase()}`).replace(/^webkit-/, '-webkit-')
    return { property, value: (m[3] ?? '').trim() }
  })
}

const ONE_SIDE = /^border-(top|right|bottom|left|inline-start|inline-end|block-start|block-end)(-width)?$/
const SIDE_LISTS = /^border(-inline|-block)?-width$/
const BANNED_FONT = /(^|[\s,'"])(inter|space grotesk|bricolage grotesque)(?=$|[\s,'"!])/i
const NEWER_CSS = [
  [/light-dark\(/i, 'light-dark()'],
  [/color-mix\(/i, 'color-mix()'],
  [/@starting-style/i, '@starting-style'],
  [/@property/i, '@property'],
  [/@container/i, '@container'],
  [/:popover-open/i, ':popover-open'],
] as const

function findBannedCss(files: SourceFile[]): string[] {
  const found: string[] = []
  for (const file of files) {
    const isCss = file.path.endsWith('.css')
    const text = isCss ? withoutComments(file.text) : file.text
    const say = (rule: string) => found.push(`${file.path}: ${rule}`)

    for (const { property, value } of declarations(file, text)) {
      if (/^(-webkit-)?backdrop-filter$/.test(property)) say('backdrop-filter (glass)')
      if (/^(-webkit-)?background-clip$/.test(property) && /\btext\b/i.test(value))
        say('background-clip: text (gradient text)')
      if (property === 'text-transform' && /uppercase/i.test(value))
        say('text-transform: uppercase (eyebrows)')
      if (ONE_SIDE.test(property) && widestIn(value) > 2)
        say(`a border wider than 2 px on one side (${property}: ${value})`)
      if (SIDE_LISTS.test(property)) {
        const known = value
          .trim()
          .split(/\s+/)
          .map(widthOf)
          .filter((width): width is number => width !== null)
        if (known.length > 1 && Math.max(...known) > 2 && new Set(known).size > 1)
          say(`a border wider than 2 px on one side (${property}: ${value})`)
      }
      // Any font list: font-family, the font shorthand, and custom properties
      // such as --font-heading that components read their font from.
      if (
        (property === 'font-family' || property === 'font' || property.startsWith('--')) &&
        BANNED_FONT.test(value)
      )
        say(`a banned font (${property}: ${value})`)
    }

    const gradients = [...text.matchAll(/gradient\(/gi)].length
    if (gradients > allowedGradients(file)) say('a gradient other than the page background fade')
    if (text.includes('var(--ground-fade)') && file.path !== BASE_PATH)
      say('--ground-fade used outside the page background')

    for (const [pattern, name] of NEWER_CSS) {
      if (pattern.test(text)) say(`${name}, newer than Safari 15.4`)
    }
    if (!isCss && /\spopover(=|\s|>|\/)/.test(text)) say('the popover attribute, newer than Safari 15.4')
  }
  return found
}

describe('banned look and CSS for old phones', () => {
  it('[design 18] no CSS or component in src/ uses anything on the list', () => {
    const files = sourceFiles('src', /\.(css|tsx)$/)
    expect(files.length).toBeGreaterThan(10)
    expect(findBannedCss(files)).toEqual([])
  })

  it('[design 18] the page background fade is declared once, in tokens.css, and used only in base.css', () => {
    const tokens = readFileSync(TOKENS_PATH, 'utf8')
    expect(allowedGradients({ path: TOKENS_PATH, text: tokens })).toBe(1)
    expect(readFileSync(BASE_PATH, 'utf8')).toMatch(/background-image:\s*var\(--ground-fade\)/)
  })

  it('[design 18] Vite builds CSS for Safari 15.4', () => {
    expect(readFileSync('vite.config.ts', 'utf8')).toMatch(/cssTarget:\s*\[\s*'safari15\.4'\s*\]/)
  })

  const css = (text: string, path = 'src/components/Probe.module.css') => findBannedCss([{ path, text }])
  const tsx = (text: string) => findBannedCss([{ path: 'src/components/Probe.tsx', text }])

  for (const [rule, probe] of [
    ['backdrop-filter', '.a { backdrop-filter: blur(10px); }'],
    ['background-clip: text', '.a { background-clip: text; }'],
    ['a linear gradient', '.a { background: linear-gradient(red, blue); }'],
    ['a radial gradient', '.a { background: radial-gradient(red, blue); }'],
    ['text-transform: uppercase', '.a { text-transform: uppercase; }'],
    ['a 3 px top border', '.a { border-top: 3px solid; }'],
    ['a 4 px left border', '.a { border-left: 4px solid var(--x); }'],
    ['a thick right border', '.a { border-right-width: thick; }'],
    ['a 0.25rem bottom border', '.a { border-bottom: 0.25rem solid; }'],
    ['a border with the width last', '.a { border-inline-start: solid var(--x) 6px; }'],
    ['Inter', ".a { font-family: 'Inter', sans-serif; }"],
    ['Space Grotesk', '.a { font-family: Space Grotesk; }'],
    ['Bricolage Grotesque', ".a { font-family: 'Bricolage Grotesque'; }"],
    ['light-dark()', '.a { color: light-dark(#000, #fff); }'],
    ['color-mix()', '.a { color: color-mix(in srgb, red, blue); }'],
    ['@starting-style', '@starting-style { .a { opacity: 0; } }'],
    ['@property', '@property --x { syntax: "<length>"; }'],
    ['@container', '@container (min-width: 1px) { .a { color: red; } }'],
    ['--ground-fade outside base.css', '.a { background-image: var(--ground-fade); }'],
    // Round 3, from the evaluator's break tests (evidence/18-eval-break-tests.txt)
    ['a banned font in a font token (C)', ":root { --font-heading: 'Inter', system-ui, sans-serif; }"],
    ['a banned font in the font shorthand (D)', '.a { font: 600 1rem Inter, sans-serif; }'],
    ['a lower case banned font in a token', ':root { --font-body: inter; }'],
    [
      'a thick one-side border through border-width (J)',
      '.a { border-style: solid; border-width: 0 0 0 6px; }',
    ],
    ['a thick inline border through border-inline-width', '.a { border-inline-width: 0 4px; }'],
    ['text-transform: UPPERCASE in capitals (H)', '.a { text-transform: UPPERCASE; }'],
    ['TEXT-TRANSFORM in capitals', '.a { TEXT-TRANSFORM: uppercase; }'],
    ['a gradient in capitals', '.a { background: Linear-Gradient(red, blue); }'],
    ['-webkit-backdrop-filter', '.a { -webkit-backdrop-filter: blur(4px); }'],
  ] as const) {
    it(`[design 18] catches ${rule}`, () => {
      expect(css(probe).length).toBeGreaterThan(0)
    })
  }

  it('[design 18] catches a second gradient in tokens.css', () => {
    const tokens = readFileSync(TOKENS_PATH, 'utf8')
    expect(
      css(`${tokens}\n.a { background: linear-gradient(red, blue); }`, TOKENS_PATH).length,
    ).toBeGreaterThan(0)
  })

  for (const [rule, probe] of [
    ['a gradient in an inline style (I)', "const s = { background: 'linear-gradient(red, blue)' }"],
    ['a gradient in a template string', 'const s = { backgroundImage: `radial-gradient(${a}, ${b})` }'],
    ['textTransform uppercase in an inline style', "const s = { textTransform: 'uppercase' }"],
    ['backdropFilter in an inline style', "const s = { backdropFilter: 'blur(8px)' }"],
    ['WebkitBackgroundClip text in an inline style', "const s = { WebkitBackgroundClip: 'text' }"],
    ['a thick one-side border in an inline style', "const s = { borderLeft: '6px solid' }"],
    ['a banned font in an inline font shorthand', "const s = { font: '600 1rem Space Grotesk' }"],
    ['a banned font in an inline custom property', "const s = { '--font-heading': 'Bricolage Grotesque' }"],
    ['color-mix in an inline style', "const s = { color: 'color-mix(in srgb, red, blue)' }"],
  ] as const) {
    it(`[design 18] catches ${rule} in a component`, () => {
      expect(tsx(probe).length).toBeGreaterThan(0)
    })
  }

  it('[design 18] catches the popover attribute and a banned font in a component', () => {
    expect(tsx('<div popover="auto">x</div>').length).toBeGreaterThan(0)
    expect(tsx("const s = { fontFamily: 'Inter' }").length).toBeGreaterThan(0)
  })

  it('[design 18] allows a 2 px border on one side, equal widths all round, and words that only contain a font name', () => {
    expect(
      css('.a { border-left: 2px dotted var(--x); border: 1px solid var(--y); border-width: 2px 2px; }'),
    ).toEqual([])
    expect(css(":root { --font-body: 'Switzer', 'Poppins', system-ui; --x: interval; }")).toEqual([])
    expect(tsx("const label = { title: 'International students' }")).toEqual([])
  })
})
