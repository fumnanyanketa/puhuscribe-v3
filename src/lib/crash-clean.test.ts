import { describe, expect, it } from 'vitest'
import {
  browserLabel,
  cleanFrames,
  cleanName,
  cleanPath,
  cleanText,
  ownBrowserFile,
  ownWorkerFile,
  parseStack,
  withoutValues,
} from './crash-clean.ts'

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md that each test protects.
// The cleaning a crash report goes through, in the browser and again in the Worker.

describe('cleanText', () => {
  it('[analytics 25] removes email addresses, ids, tokens, digit runs of 6 or more and query strings', () => {
    expect(cleanText('no access for maija.meikalainen@example.fi today')).toBe('no access for [email] today')
    expect(cleanText('session 0F8E2B44-6A71-4C3E-9D55-1B2C3D4E5F60 broke')).toBe('session [id] broke')
    expect(cleanText('bad eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.abcDEF123_- token')).toBe('bad [token] token')
    expect(cleanText('key AbCdEfGhIjKlMnOpQrStUvWxYzAbCdEfGhIj here')).toBe('key [token] here')
    expect(cleanText('code 1234567 and 12345')).toBe('code [number] and 12345')
    expect(cleanText('GET https://x.example/a/b?code=1&e=2#top failed')).toBe(
      'GET https://x.example/a/b failed',
    )
  })

  it('[analytics 25] folds line breaks and control characters, and cuts at 300 characters', () => {
    expect(cleanText('one\ntwo\t\u0000three')).toBe('one two three')
    expect(Array.from(cleanText('ä'.repeat(400)))).toHaveLength(300)
  })

  it('[analytics 25] withoutValues replaces what the learner typed, wherever it appears', () => {
    expect(withoutValues('Could not grade Talossa for line 2', ['talossa', ''])).toBe(
      'Could not grade [typed] for line 2',
    )
    expect(withoutValues('a (b) c', ['(b)'])).toBe('a [typed] c')
    // One character is too short to look for.
    expect(withoutValues('a b', ['a'])).toBe('a b')
  })
})

describe('cleanName and cleanPath', () => {
  it('[analytics 25] keeps an error name only with a safe shape', () => {
    expect(cleanName('TypeError')).toBe('TypeError')
    expect(cleanName('bad name')).toBe('Error')
    expect(cleanName('<script>')).toBe('Error')
    expect(cleanName(42)).toBe('Error')
    expect(cleanName('E'.repeat(81))).toBe('Error')
  })

  it('[analytics 25] replaces every id in the path with :id and drops the query and fragment', () => {
    expect(cleanPath('/session')).toBe('/session')
    expect(cleanPath('/')).toBe('/')
    expect(cleanPath('/api/sessions/0f8e2b44-6a71-4c3e-9d55-1b2c3d4e5f60/step')).toBe(
      '/api/sessions/:id/step',
    )
    expect(cleanPath('/api/voice/recordings/123')).toBe('/api/voice/recordings/:id')
    expect(cleanPath('/a/abc1234567/b')).toBe('/a/:id/b')
    expect(cleanPath('/a/Zx9Zx9Zx9Zx9Zx9Zx9/b')).toBe('/a/:id/b')
    expect(cleanPath('/account?email=a@b.co#x')).toBe('/account')
    expect(cleanPath('/a/b c/d')).toBe('/a/:id/d')
    expect(cleanPath('no-slash')).toBe('/')
    expect(cleanPath(null)).toBe('/')
  })
})

describe('stack frames', () => {
  const ORIGIN = 'https://puhuscribe.example'

  it('[analytics 25] reads Chrome and Safari stacks', () => {
    expect(
      parseStack(
        'TypeError: x\n    at onClick (https://puhuscribe.example/assets/index-AbC.js:1:200)\n    at https://puhuscribe.example/assets/index-AbC.js:3:4',
      ),
    ).toEqual([
      { url: 'https://puhuscribe.example/assets/index-AbC.js', line: 1, column: 200, fn: 'onClick' },
      { url: 'https://puhuscribe.example/assets/index-AbC.js', line: 3, column: 4, fn: '' },
    ])
    expect(
      parseStack('onClick@https://puhuscribe.example/assets/index-AbC.js:1:200\n@https://x.example/a.js:2:3'),
    ).toEqual([
      { url: 'https://puhuscribe.example/assets/index-AbC.js', line: 1, column: 200, fn: 'onClick' },
      { url: 'https://x.example/a.js', line: 2, column: 3, fn: '' },
    ])
    expect(parseStack(undefined)).toEqual([])
  })

  it('[analytics 25] keeps only the app own bundle files, at most 10, with safe function names', () => {
    const own = (url: string) => ownBrowserFile(url, ORIGIN)
    expect(own('https://puhuscribe.example/assets/index-AbC.js')).toBe('/assets/index-AbC.js')
    expect(own('/assets/index-AbC.js')).toBe('/assets/index-AbC.js')
    expect(own('https://evil.example/assets/index-AbC.js')).toBeNull()
    expect(own('https://puhuscribe.example/src/main.tsx')).toBeNull()
    expect(own('chrome-extension://abc/assets/x.js')).toBeNull()
    const many = Array.from({ length: 12 }, (_, i) => ({
      url: `${ORIGIN}/assets/a.js`,
      line: i,
      column: 1,
      fn: i === 0 ? 'learner@example.com' : 'f<x> y',
    }))
    const frames = cleanFrames(many, own)
    expect(frames).toHaveLength(10)
    expect(frames[0]).toEqual({ file: '/assets/a.js', line: 0, column: 1, fn: '' })
    expect(frames[1]?.fn).toBe('f<x> y')
  })

  it('[analytics 25] a Worker frame keeps only its bundle file name, never a package', () => {
    expect(ownWorkerFile('file:///srv/worker/index.js')).toBe('index.js')
    expect(ownWorkerFile('/x/node_modules/jose/a.js')).toBeNull()
    expect(ownWorkerFile('node:internal/process')).toBeNull()
  })
})

describe('browserLabel', () => {
  it('[analytics 25] gives a coarse browser and system label and nothing else from the user agent', () => {
    expect(
      browserLabel(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1',
      ),
    ).toBe('Safari 17, iOS')
    expect(
      browserLabel(
        'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.6723.58 Mobile Safari/537.36',
      ),
    ).toBe('Chrome 130, Android')
    expect(
      browserLabel(
        'Mozilla/5.0 (Linux; Android 13; SM-A536B) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/25.0 Chrome/121.0.0.0 Mobile Safari/537.36',
      ),
    ).toBe('Samsung Internet 25, Android')
    expect(
      browserLabel('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:131.0) Gecko/20100101 Firefox/131.0'),
    ).toBe('Firefox 131, Windows')
    expect(browserLabel(null)).toBe('Unknown')
    for (const label of ['Safari 17, iOS', browserLabel('anything at all')]) {
      expect(label).toMatch(/^[A-Za-z0-9 .,()/-]{1,40}$/)
    }
  })
})
