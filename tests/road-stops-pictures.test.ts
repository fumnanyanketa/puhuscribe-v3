import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { describe, expect, it } from 'vitest'
import { STOP_PICTURE_RATIOS, stopPicture, stopPictureRatio } from '../src/road/stop-pictures.ts'

// Fast route road-stops (owner approved 5 November 2026), "Done when" 1: every stop shows its own picture.
// The pictures are public/stops/01.svg to 36.svg.

const NUMBERS = Array.from({ length: 36 }, (_, i) => i + 1)
const fileOf = (stop: number) => `public${stopPicture(stop) ?? ''}`

describe('stop pictures', () => {
  it('[road-stops 1] every one of the 36 stops has its own picture file, and no two stops share one', () => {
    expect(Object.keys(STOP_PICTURE_RATIOS).map(Number)).toEqual(NUMBERS)
    const addresses = NUMBERS.map((stop) => stopPicture(stop))
    expect(new Set(addresses).size).toBe(36)
    for (const stop of NUMBERS) {
      expect(stopPicture(stop)).toBe(`/stops/${String(stop).padStart(2, '0')}.svg`)
      expect(existsSync(fileOf(stop)), fileOf(stop)).toBe(true)
    }
    expect(stopPicture(37)).toBeUndefined()
    expect(stopPicture(0)).toBeUndefined()
  })

  it('[road-stops 1] each picture is a small plain SVG drawing: no script, no link outside itself, under 20 kB', () => {
    for (const stop of NUMBERS) {
      const text = readFileSync(fileOf(stop), 'utf8')
      expect(text.startsWith('<svg'), fileOf(stop)).toBe(true)
      // Links only inside the drawing (a gradient pointing at another, "#a"), never to another file.
      expect(text, fileOf(stop)).not.toMatch(/<script|\son\w+=|href="(?!#)|<image|<foreignObject/i)
      expect(statSync(fileOf(stop)).size, fileOf(stop)).toBeLessThan(20_000)
    }
  })

  it('[road-stops 1] each ratio matches its file, so the road keeps the right room before a picture loads', () => {
    for (const stop of NUMBERS) {
      const box = /viewBox="([^"]+)"/
        .exec(readFileSync(fileOf(stop), 'utf8'))?.[1]
        ?.split(/\s+/)
        .map(Number)
      const [, , width = 0, height = 1] = box ?? []
      expect(stopPictureRatio(stop), fileOf(stop)).toBeCloseTo(width / height, 2)
    }
    expect(stopPictureRatio(99)).toBe(1)
  })

  it('[road-stops 1] the source and licence of the pictures are written down, and public/stops holds the pictures only', () => {
    const readme = readFileSync('design/stop-pictures/README.md', 'utf8')
    expect(readme).toContain('https://undraw.co')
    expect(readme).toMatch(/licen[cs]e/i)
    expect(readdirSync('public/stops').sort()).toEqual(
      NUMBERS.map((stop) => `${String(stop).padStart(2, '0')}.svg`),
    )
  })
})
