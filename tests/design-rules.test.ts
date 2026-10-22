import { execFileSync } from 'node:child_process'
import { createHash } from 'node:crypto'
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/5-design-system/spec.md.

function files(dir: string, pattern: RegExp): string[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name)
    if (statSync(path).isDirectory()) return files(path, pattern)
    return pattern.test(name) ? [path] : []
  })
}

// SHA-256 of the Switzer files as downloaded from fontshare.com on
// 21 October 2026. The ITF Free Font License forbids changing them, which
// includes subsetting and format conversion.
const SWITZER = {
  'Switzer-Regular.woff2': 'aefa3d21af6adb6dd53246ff86e1d8e7eaf36a8d792dd59136cced309e3c8862',
  'Switzer-Medium.woff2': '2ea341e35c0d0d00c13adec869b573297d25326140ca40fbe354a9bee468808e',
  'Switzer-Semibold.woff2': '04084ce10f3b185156408adf5540cabbed149e039d6f3c3e8e5b2fb17f6bdef8',
  'Switzer-Bold.woff2': '5cb009dd21317ac095104458dbca8e96b6ac41fdace80ef3b7c53833c44420c7',
  'FFL.txt': '145e7fe2429a3336ba215c070ef722000e01348a3e1baaa127e871bb5012f554',
}

// Switzer is kept out of the public repository (docs/fonts.md). The tests that
// look at its files run when scripts/ci/fetch-private-fonts.ts has put them in
// place, and skip, with the reason in their name, when it has not.
const SWITZER_DIR = 'src/assets/fonts/switzer'
const switzerPresent = Object.keys(SWITZER).every((name) => existsSync(join(SWITZER_DIR, name)))
const itWithSwitzer = it.skipIf(!switzerPresent)
const WHEN_ABSENT = '(skipped while the Switzer files are absent, see docs/fonts.md)'

describe('fonts', () => {
  itWithSwitzer(
    `[design 5] the Switzer files are byte for byte as downloaded, with their licence ${WHEN_ABSENT}`,
    () => {
      const dir = SWITZER_DIR
      // switzer.css is made by scripts/ci/fetch-private-fonts.ts, not downloaded.
      expect(
        readdirSync(dir)
          .filter((name) => name !== 'switzer.css')
          .sort(),
      ).toEqual(Object.keys(SWITZER).sort())
      for (const [name, hash] of Object.entries(SWITZER)) {
        expect(
          createHash('sha256')
            .update(readFileSync(join(dir, name)))
            .digest('hex'),
          name,
        ).toBe(hash)
      }
    },
  )

  itWithSwitzer(
    `[design 5] git never converts the font files, and still reads their licence as text ${WHEN_ABSENT}`,
    () => {
      // src/** is marked as text with LF endings; without the font rule git
      // rewrote a byte in Switzer-Semibold.woff2 on commit (job 5, round 2).
      // The licence must stay a text diff so gitleaks scans it (round 3).
      const attributes = (path: string) =>
        execFileSync('git', ['check-attr', '-a', '--', path], { encoding: 'utf8' })
      for (const name of Object.keys(SWITZER).filter((file) => file.endsWith('.woff2'))) {
        const set = attributes(`src/assets/fonts/switzer/${name}`)
        expect(set, name).toContain('binary: set')
        expect(set, name).toContain('text: unset')
      }
      const licence = attributes('src/assets/fonts/switzer/FFL.txt')
      expect(licence).toContain('text: unset')
      expect(licence).not.toContain('binary: set')
      expect(licence).not.toContain('diff: unset')
    },
  )

  it("[design 6] the design guide and design files check out with LF, and v2's handoff is left byte for byte", () => {
    const attributes = (path: string) =>
      execFileSync('git', ['check-attr', 'text', 'eol', '--', path], { encoding: 'utf8' })
    for (const path of [
      'design.md',
      'design/brief.md',
      'design/assets/README.md',
      'design/assets/app-icon.svg',
    ]) {
      expect(attributes(path), path).toContain('text: set')
      expect(attributes(path), path).toContain('eol: lf')
    }
    expect(attributes('design/v2-handoff/README.md')).toContain('text: unset')
  })

  it('[design 5] the Switzer files stay out of git, and the app falls back to Poppins without them', () => {
    // The ITF Free Font License forbids offering the files through a public
    // repository. This test needs no font file, so it always runs.
    const tracked = execFileSync('git', ['ls-files', '--', SWITZER_DIR], { encoding: 'utf8' })
    expect(tracked.trim()).toBe('')
    expect(
      execFileSync('git', ['check-ignore', '--', `${SWITZER_DIR}/Switzer-Regular.woff2`], {
        encoding: 'utf8',
      }),
    ).toContain('Switzer-Regular.woff2')
    // The body font stack ends in Poppins and then a system font.
    const tokens = readFileSync('src/styles/tokens.css', 'utf8')
    expect(tokens).toMatch(/--font-body:\s*'Switzer',\s*'Poppins',\s*system-ui/)
    // Poppins comes from npm; the Switzer rules are not in the committed CSS.
    const fonts = readFileSync('src/styles/fonts.css', 'utf8').replace(/\/\*[\s\S]*?\*\//g, '')
    expect(fonts).toContain('@fontsource/poppins')
    expect(fonts).not.toMatch(/Switzer/)
    // The app imports the generated CSS only when it exists.
    expect(readFileSync('src/main.tsx', 'utf8')).toContain(
      "import.meta.glob('./assets/fonts/switzer/switzer.css'",
    )
  })

  it('[design 5] fonts come only from the app itself, with no italic styles', () => {
    // Comments may name the source; the rules themselves may not load from it.
    const fonts = readFileSync('src/styles/fonts.css', 'utf8').replace(/\/\*[\s\S]*?\*\//g, '')
    expect(fonts).not.toMatch(/https?:|\/\/fonts\.|fontshare|googleapis/)
    expect(fonts).not.toMatch(/font-style:\s*italic|italic\.css/)
    for (const file of files('src', /\.(css|tsx?|html)$/)) {
      expect(readFileSync(file, 'utf8'), file).not.toMatch(/fonts\.googleapis|api\.fontshare/)
    }
    expect(readFileSync('index.html', 'utf8')).not.toMatch(/fonts\.googleapis|api\.fontshare/)
  })

  it('[design 5] text sizes are in rem', () => {
    const tokens = readFileSync('src/styles/tokens.css', 'utf8')
    const sizes = [...tokens.matchAll(/--text-[a-z-]+:\s*([^;]+);/g)].map((m) => m[1] ?? '')
    expect(sizes.length).toBeGreaterThan(5)
    for (const size of sizes) expect(size).toMatch(/^\d*\.?\d+rem$/)
    for (const file of files('src', /\.css$/)) {
      expect(readFileSync(file, 'utf8'), file).not.toMatch(/font-size:\s*\d+(\.\d+)?px/)
    }
  })
})

describe('session frame', () => {
  it('[design 7] the bottom action area clears the iPhone home bar, and the frame uses dvh after vh', () => {
    const css = readFileSync('src/components/SessionFrame.module.css', 'utf8')
    expect(css).toMatch(/\.actions \{[^}]*env\(safe-area-inset-bottom/)
    expect(css).toMatch(/height: 100vh;\s*height: 100dvh;/)
    expect(readFileSync('index.html', 'utf8')).toMatch(/viewport-fit=cover/)
  })
})

describe('record control', () => {
  it('[design 13] no file in src/ asks for the microphone', () => {
    for (const file of files('src', /\.(tsx?|js)$/)) {
      expect(readFileSync(file, 'utf8'), file).not.toMatch(/getUserMedia/)
    }
  })
})

describe('motion', () => {
  it('[design 14] durations and easings in component CSS come from tokens', () => {
    for (const file of files('src', /\.css$/)) {
      if (file.endsWith('tokens.css')) continue
      const text = readFileSync(file, 'utf8')
      for (const match of text.matchAll(/(?:transition|animation)\s*:\s*([^;]+);/g)) {
        const value = match[1] ?? ''
        if (value.trim() === 'none') continue
        // Durations come from tokens only, the endless busy marks included (round 3).
        const raw = [...value.matchAll(/\b\d*\.?\d+m?s\b/g)].map((m) => m[0])
        expect(raw, `${file}: ${value}`).toEqual([])
      }
    }
  })

  it('[design 14] every component file with motion turns it off for reduce motion', () => {
    for (const file of files('src', /\.module\.css$/)) {
      const text = readFileSync(file, 'utf8')
      if (/transition:|animation:/.test(text)) {
        expect(text, file).toMatch(/@media \(prefers-reduced-motion: reduce\)/)
      }
    }
  })
})

describe('dark mode', () => {
  it('[design 15] index.html declares light and dark', () => {
    expect(readFileSync('index.html', 'utf8')).toMatch(/<meta name="color-scheme" content="light dark" \/>/)
  })
})
