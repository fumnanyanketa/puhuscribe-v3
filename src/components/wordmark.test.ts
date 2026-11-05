import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'
import { Wordmark } from './Wordmark.tsx'
import { WORDMARK } from './wordmark-paths.ts'

// Labels in brackets are the numbered items of the owner's brief for fast route intro-logo
// (factory/jobs/intro-logo/build.md lists them): [intro-logo 1] the Wordmark component draws the new
// outlined logo, W4 of 5 November 2026, with no text element and the fell A and the bubble present.

const markup = (height?: number) => renderToStaticMarkup(createElement(Wordmark, height ? { height } : {}))

/** The x and y numbers of an outline, in pairs where the path gives pairs (M, L, Q, A ends). */
function numbers(d: string): number[] {
  return (d.match(/-?\d*\.?\d+/g) ?? []).map(Number)
}

describe('the Aleksi wordmark (W4)', () => {
  it('[intro-logo 1] is drawn from outlines only: one svg named Aleksi, paths, and no text element', () => {
    const html = markup()
    expect(html.match(/<svg/g)).toHaveLength(1)
    expect(html).toContain('role="img"')
    expect(html).toContain('aria-label="Aleksi"')
    expect(html).not.toMatch(/<text|<tspan|<foreignObject|<use/)
    // Nothing of the old mark is left: no sprout tile, no leaves, no round dot on the i.
    expect(html).not.toMatch(/<rect|<circle|<ellipse/)
    expect(html.match(/<path/g)).toHaveLength(3)
  })

  it('[intro-logo 1] draws the fell A, the letters and the speech bubble, each in its own path', () => {
    const html = markup()
    expect(html).toContain(`data-part="fell" d="${WORDMARK.fell}"`)
    expect(html).toContain(`data-part="letters" d="${WORDMARK.letters}"`)
    expect(html).toContain(`data-part="bubble" d="${WORDMARK.bubble}"`)
  })

  it('[intro-logo 1] the A is a fell: one closed outline with a rounded peak, flat feet and no crossbar', () => {
    const fell = WORDMARK.fell
    // One outline (one M, one Z): an A with a crossbar has a second outline, its counter.
    expect(fell.match(/M/g)).toHaveLength(1)
    expect(fell.match(/Z/g)).toHaveLength(1)
    // The peak is an arc (the soft rounded top); the feet sit flat on the baseline (H between them).
    expect(fell).toMatch(/A5\.2 5\.2 0 0 1/)
    const baseline = 46.5
    const ys = numbers(fell.replace(/A5\.2 5\.2 0 0 1/, 'L')).filter((_, i) => i % 2 === 1)
    expect(Math.max(...ys)).toBe(baseline)
    expect(fell).toMatch(new RegExp(`L[\\d.]+ ${String(baseline)}H[\\d.]+L`))
    // As heavy as the other letters: the l's stem is 10.19 wide; each leg is cut 11.72 wide on the baseline.
    expect(fell).toContain('M0 46.5')
    expect(fell).toContain('L11.72 46.5Z')
  })

  it('[intro-logo 1] the dot of the i is a speech bubble above the i stem, with a tail toward it', () => {
    const bubble = numbers(WORDMARK.bubble)
    const xs = bubble.filter((_, i) => i % 2 === 0)
    // The i stem is the last outline of the letters: from x 156.67 to 166.86, from y 17.33 down.
    const stem = /M([\d.]+) ([\d.]+)V[\d.]+H([\d.]+)V[\d.]+Z$/.exec(WORDMARK.letters)
    expect(stem).not.toBeNull()
    const [right, top, left] = [Number(stem?.[1]), Number(stem?.[2]), Number(stem?.[3])]
    expect(right - left).toBeCloseTo(10.19, 1)
    // The bubble sits over the stem and ends above it; its tail's tip points down toward the stem.
    expect(Math.min(...xs)).toBeLessThan(right)
    expect(Math.max(...xs)).toBeGreaterThan(left)
    const tail = /L([\d.]+) ([\d.]+)V/.exec(WORDMARK.bubble)
    expect(Number(tail?.[2])).toBeLessThan(top)
    expect(Number(tail?.[2])).toBeGreaterThan(12)
  })

  it('[intro-logo 1] keeps its proportions at any height', () => {
    const html = markup(40)
    expect(html).toContain(`viewBox="0 0 ${String(WORDMARK.width)} ${String(WORDMARK.height)}"`)
    expect(html).toContain('height="40"')
    expect(html).toContain(`width="${String((40 * WORDMARK.width) / WORDMARK.height)}"`)
  })

  it('[intro-logo 1] takes its two colours from tokens: ink for the letters, mint for the bubble', () => {
    const css = readFileSync('src/components/Wordmark.module.css', 'utf8')
    expect(css).toMatch(/\.letters\s*\{\s*fill:\s*var\(--color-text\);/)
    expect(css).toMatch(/\.bubble\s*\{\s*fill:\s*var\(--color-mint\);/)
  })

  it('[intro-logo 1] the brand files hold the same outlines, light and dark, with no text', () => {
    const light = readFileSync('design/assets/wordmark.svg', 'utf8')
    const dark = readFileSync('design/assets/wordmark-dark.svg', 'utf8')
    for (const [file, ink, mint] of [
      [light, '#1b2a26', '#1e856f'],
      [dark, '#f4faf8', '#74bba9'],
    ] as const) {
      expect(file).not.toMatch(/<text|<tspan/)
      expect(file).toContain(`<path fill="${ink}" d="${WORDMARK.fell}"/>`)
      expect(file).toContain(`<path fill="${ink}" d="${WORDMARK.letters}"/>`)
      expect(file).toContain(`<path fill="${mint}" d="${WORDMARK.bubble}"/>`)
    }
  })
})
