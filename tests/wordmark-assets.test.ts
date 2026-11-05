import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'
import { WORDMARK } from '../src/components/wordmark-paths.ts'

// Fast route intro-logo, item 1 of the owner's brief (factory/jobs/intro-logo/build.md): the Aleksi wordmark
// W4 takes its colours from tokens, and the brand files in design/assets/ hold the same outlines as the app,
// light and dark, with no text. The drawing itself is tested in src/components/wordmark.test.ts.

describe('the Aleksi wordmark files', () => {
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
