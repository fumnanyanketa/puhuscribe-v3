import { spawnSync } from 'node:child_process'
import { createHash } from 'node:crypto'
import {
  cpSync,
  existsSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  readFileSync,
  rmSync,
  symlinkSync,
  truncateSync,
  writeFileSync,
} from 'node:fs'
import { tmpdir } from 'node:os'
import { join, relative, resolve } from 'node:path'
import { afterEach, beforeEach, describe, expect, it } from 'vitest'
import { buildReviewSite, indexHtml, MAX_PAGE_BYTES, ROBOTS_TXT, roundStatuses } from './build.ts'

// Labels [site N] are the "Done when" statement numbers from
// factory/jobs/13-review-site/spec.md that each test protects.
//
// Each test builds a made up repository in a temporary folder: two dialogues
// with drafts, audio, review pages, round files, a brief and a returned review
// file, so the build can be shown to copy only the listed review pages.

const BUILD = resolve('scripts/review-site/build.ts')

let root: string
let out: string

function write(path: string, content: string | Buffer): void {
  const full = join(root, path)
  mkdirSync(join(full, '..'), { recursive: true })
  writeFileSync(full, content)
}

function addDialogue(slug: string, title: string, rounds: number[]): void {
  write(
    `content/drafts/${slug}/draft.json`,
    JSON.stringify({ format: 'draft', brief: { dialogue: { slug, title_en: title } } }),
  )
  write(`content/drafts/${slug}/check-report.json`, '{"ok": true}')
  write(`content/drafts/${slug}/run.log`, 'made up log line')
  write(`content/drafts/${slug}/audio/1-puhe.mp3`, Buffer.from([0xff, 0xf3, 0x01]))
  write(`content/briefs/${slug}.json`, '{"brief": true}')
  for (const n of rounds) {
    write(
      `content/drafts/${slug}/review/round-${String(n)}.html`,
      `<!doctype html><title>${slug} round ${String(n)}</title>`,
    )
    write(`content/drafts/${slug}/review/round-${String(n)}.json`, '{"items": []}')
  }
}

function list(...slugs: string[]): void {
  write('review-site/dialogues.json', JSON.stringify({ dialogues: slugs }))
}

function filesIn(folder: string): string[] {
  if (!existsSync(folder)) return []
  return readdirSync(folder, { recursive: true, withFileTypes: true })
    .filter((entry) => entry.isFile())
    .map((entry) => relative(folder, join(entry.parentPath, entry.name)).replaceAll('\\', '/'))
    .sort()
}

function sha256(path: string): string {
  return createHash('sha256').update(readFileSync(path)).digest('hex')
}

function runBuild(): { status: number | null; stderr: string } {
  const result = spawnSync(process.execPath, [BUILD], { cwd: root, encoding: 'utf8' })
  return { status: result.status, stderr: result.stderr }
}

beforeEach(() => {
  root = mkdtempSync(join(tmpdir(), 'review-site-'))
  out = join(root, 'dist-review')
  addDialogue('listed-dialogue', 'A listed dialogue', [1])
  addDialogue('unlisted-dialogue', 'An unlisted dialogue', [1])
  write('content/reviews/listed-dialogue/README.md', 'not a review')
  list('listed-dialogue')
})

afterEach(() => {
  rmSync(root, { recursive: true, force: true })
})

describe('the build copies only listed pages', () => {
  it('[site 2] writes exactly index.html, robots.txt and each listed page, byte for byte', () => {
    expect(runBuild().status).toBe(0)
    expect(filesIn(out)).toEqual(['index.html', 'listed-dialogue/round-1.html', 'robots.txt'])
    expect(sha256(join(out, 'listed-dialogue/round-1.html'))).toBe(
      sha256(join(root, 'content/drafts/listed-dialogue/review/round-1.html')),
    )
    expect(readFileSync(join(out, 'robots.txt'), 'utf8')).toBe(ROBOTS_TXT)
  })

  it('[site 2] never copies an unlisted page, draft.json, the check report, the log, audio, round files, briefs or returned reviews', () => {
    write('content/reviews/listed-dialogue/round-1.json', '{"returned": true}')
    expect(runBuild().status).toBe(0)
    const built = filesIn(out)
    expect(built.some((f) => f.includes('unlisted-dialogue'))).toBe(false)
    for (const name of [
      'draft.json',
      'check-report.json',
      'run.log',
      '1-puhe.mp3',
      'round-1.json',
      'README.md',
    ]) {
      expect(
        built.some((f) => f.endsWith(name)),
        name,
      ).toBe(false)
    }
    expect(built.some((f) => f.endsWith('.json') || f.endsWith('.mp3') || f.endsWith('.log'))).toBe(false)
    expect(built.some((f) => f.startsWith('content/'))).toBe(false)
  })

  it('[site 2] replaces an older build completely, so a page removed from the list disappears', () => {
    list('listed-dialogue', 'unlisted-dialogue')
    expect(runBuild().status).toBe(0)
    expect(filesIn(out)).toContain('unlisted-dialogue/round-1.html')
    list('listed-dialogue')
    expect(runBuild().status).toBe(0)
    expect(filesIn(out)).toEqual(['index.html', 'listed-dialogue/round-1.html', 'robots.txt'])
  })

  it('[site 2] dist-review/ is ignored by git', () => {
    const ignored = spawnSync('git', ['check-ignore', '--quiet', '--no-index', 'dist-review/index.html'])
    expect(ignored.status).toBe(0)
  })
})

describe('the build refuses bad input, writes nothing and names the cause', () => {
  function expectRefused(cause: RegExp): void {
    const { status, stderr } = runBuild()
    expect(status).toBe(1)
    expect(stderr).toMatch(cause)
    expect(existsSync(out)).toBe(false)
  }

  it('[site 3] a listed slug that is not lower case words joined by hyphens', () => {
    list('Bad_Slug')
    expectRefused(/"Bad_Slug" is not lower case letters and digits joined by single hyphens/)
  })

  it('[site 3] a slug that tries to leave the drafts folder', () => {
    list('../listed-dialogue')
    expectRefused(/"..\/listed-dialogue" is not lower case/)
  })

  it('[site 3] a slug listed twice', () => {
    list('listed-dialogue', 'listed-dialogue')
    expectRefused(/The slug listed-dialogue is listed twice/)
  })

  it('[site 3] a listed slug with no review page', () => {
    write(
      'content/drafts/no-pages/draft.json',
      JSON.stringify({ brief: { dialogue: { title_en: 'No pages' } } }),
    )
    mkdirSync(join(root, 'content/drafts/no-pages/review'), { recursive: true })
    write('content/drafts/no-pages/review/round-1.json', '{}')
    list('no-pages')
    expectRefused(/The listed slug no-pages has no review page/)
  })

  it('[site 3] a listed slug with no drafts folder at all', () => {
    list('does-not-exist')
    expectRefused(/The listed slug does-not-exist has no drafts folder \(content\/drafts\/does-not-exist\/\)/)
  })

  it('[site 3] a listed dialogue folder that is a symlink to somewhere else', () => {
    const elsewhere = mkdtempSync(join(tmpdir(), 'review-site-elsewhere-'))
    try {
      mkdirSync(join(elsewhere, 'review'))
      writeFileSync(join(elsewhere, 'review', 'round-1.html'), '<p>not a listed draft</p>')
      writeFileSync(
        join(elsewhere, 'draft.json'),
        JSON.stringify({ brief: { dialogue: { title_en: 'Elsewhere' } } }),
      )
      symlinkSync(elsewhere, join(root, 'content/drafts/linked-dialogue'), 'junction')
      list('linked-dialogue')
      expectRefused(/content\/drafts\/linked-dialogue is not a plain folder \(a symlink or a file\)/)
    } finally {
      rmSync(elsewhere, { recursive: true, force: true })
    }
  })

  it('[site 3] a drafts folder that is a symlink to somewhere else', () => {
    const elsewhere = mkdtempSync(join(tmpdir(), 'review-site-drafts-'))
    try {
      cpSync(join(root, 'content/drafts'), elsewhere, { recursive: true })
      rmSync(join(root, 'content/drafts'), { recursive: true, force: true })
      symlinkSync(elsewhere, join(root, 'content/drafts'), 'junction')
      expectRefused(/content\/drafts is not a plain folder \(a symlink or a file\)/)
    } finally {
      rmSync(join(root, 'content/drafts'), { recursive: true, force: true })
      rmSync(elsewhere, { recursive: true, force: true })
    }
  })

  it('[site 3] a page file that is a symlink', () => {
    symlinkSync(
      join(root, 'content/drafts/unlisted-dialogue/review/round-1.html'),
      join(root, 'content/drafts/listed-dialogue/review/round-2.html'),
    )
    expectRefused(/content\/drafts\/listed-dialogue\/review\/round-2\.html is a symlink/)
  })

  it('[site 3] a page file over 25 MiB', () => {
    const big = join(root, 'content/drafts/listed-dialogue/review/round-2.html')
    writeFileSync(big, '')
    truncateSync(big, MAX_PAGE_BYTES + 1)
    expectRefused(/round-2\.html is over 25 MiB/)
  })

  it('[site 3] a page file of exactly 25 MiB is accepted', () => {
    const big = join(root, 'content/drafts/listed-dialogue/review/round-2.html')
    writeFileSync(big, '')
    truncateSync(big, MAX_PAGE_BYTES)
    expect(runBuild().status).toBe(0)
  })

  it.each(['round-01.html', 'Round-2.html', 'round-1-old.html', 'draft.html', 'round-0.html'])(
    '[site 3] a page file named %s, not round-<n>.html',
    (name) => {
      write(`content/drafts/listed-dialogue/review/${name}`, '<p>page</p>')
      expectRefused(new RegExp(`${name.replaceAll('.', '\\.')} is not named round-<n>\\.html`))
    },
  )

  it('[site 1] [site 3] a list file holding anything other than the slugs', () => {
    write(
      'review-site/dialogues.json',
      JSON.stringify({ dialogues: ['listed-dialogue'], reviewer: 'someone' }),
    )
    expectRefused(/must hold only/)
  })

  it('[site 3] bad input also removes an older build, so a stale site is never deployed', () => {
    expect(runBuild().status).toBe(0)
    expect(filesIn(out)).toContain('listed-dialogue/round-1.html')
    list('listed-dialogue', 'listed-dialogue')
    expect(runBuild().status).toBe(1)
    expect(existsSync(out)).toBe(false)
  })
})

describe('the index page', () => {
  it('[site 4] lists each dialogue by title and slug, with one link per round', () => {
    addDialogue('listed-dialogue', 'A listed dialogue', [1, 2, 3])
    const { dialogues } = buildReviewSite(root, out)
    const html = readFileSync(join(out, 'index.html'), 'utf8')
    expect(dialogues.map((d) => d.slug)).toEqual(['listed-dialogue'])
    expect(html).toContain('<h2 id="d-listed-dialogue">A listed dialogue</h2>')
    expect(html).toContain('Dialogue: listed-dialogue')
    for (const n of [1, 2, 3])
      expect(html).toContain(
        `<a href="/listed-dialogue/round-${String(n)}" aria-label="Round ${String(n)}, A listed dialogue">Round ${String(n)}</a>`,
      )
  })

  it('[site 4] marks returned rounds "Review received" and the newest round without a file "Waiting for your review"', () => {
    addDialogue('listed-dialogue', 'A listed dialogue', [1, 2])
    write('content/reviews/listed-dialogue/round-1.json', '{}')
    buildReviewSite(root, out)
    const html = readFileSync(join(out, 'index.html'), 'utf8')
    expect(html).toContain(
      '<li><a href="/listed-dialogue/round-1" aria-label="Round 1, A listed dialogue">Round 1</a> <span class="status">Review received</span></li>',
    )
    expect(html).toContain(
      '<li class="waiting"><a href="/listed-dialogue/round-2" aria-label="Round 2, A listed dialogue">Round 2</a> <span class="status">Waiting for your review</span></li>',
    )
  })

  it('[site 4] only one round waits, the newest without a returned file', () => {
    const rounds = [1, 2, 3].map((round) => ({ round, source: '', reviewed: round === 1 }))
    expect(roundStatuses(rounds)).toEqual(['Review received', 'Not reviewed', 'Waiting for your review'])
    const all = [1, 2].map((round) => ({ round, source: '', reviewed: true }))
    expect(roundStatuses(all)).toEqual(['Review received', 'Review received'])
  })

  it('[site 4] prints a title holding <script> as text', () => {
    addDialogue('listed-dialogue', '<script>alert("x")</script> & co', [1])
    buildReviewSite(root, out)
    const html = readFileSync(join(out, 'index.html'), 'utf8')
    expect(html).not.toContain('<script')
    expect(html).toContain('&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt; &amp; co')
  })

  it('[site 4] says what to do in plain sentences', () => {
    const html = indexHtml([])
    expect(html).toContain('Open the round that says "Waiting for your review"')
    expect(html).toContain('press "Download my review"')
    expect(html).toContain('send the saved file back the way you agreed')
    expect(html).toContain('Nothing is waiting for your review right now.')
  })

  it('[site 4] has no script and loads nothing from the network', () => {
    addDialogue('listed-dialogue', 'A listed dialogue', [1, 2])
    buildReviewSite(root, out)
    const html = readFileSync(join(out, 'index.html'), 'utf8')
    expect(html).not.toMatch(/<script|<link|<img|<iframe|@import|url\(|src=/i)
    expect(html).not.toMatch(/https?:\/\//)
    // Every link stays on the site.
    for (const [, href] of html.matchAll(/href="([^"]*)"/g)) expect(href).toMatch(/^\/[a-z0-9-]+\/round-\d+$/)
  })

  it('[site 4] follows the banned list: no em dash, no badge, no accent border, no hairline rows', () => {
    const html = indexHtml([
      { slug: 'a-b', title: 'A title', rounds: [{ round: 1, source: '', reviewed: false }] },
    ])
    expect(html).not.toContain('—')
    expect(html).not.toMatch(/border-(top|left|bottom|right)\s*:/)
    expect(html).not.toMatch(/border(-bottom)?:\s*1px/)
    expect(html).not.toMatch(/badge|pill|text-transform:\s*uppercase|gradient|backdrop-filter/i)
  })
})

describe('a new round goes up by itself, only when listed', () => {
  it('[site 12] a new round-2.html for a listed slug is in the build; a round page for an unlisted slug adds nothing', () => {
    expect(runBuild().status).toBe(0)
    expect(filesIn(out)).toEqual(['index.html', 'listed-dialogue/round-1.html', 'robots.txt'])
    write('content/drafts/listed-dialogue/review/round-2.html', '<!doctype html><title>round 2</title>')
    write('content/drafts/unlisted-dialogue/review/round-2.html', '<!doctype html><title>round 2</title>')
    expect(runBuild().status).toBe(0)
    expect(filesIn(out)).toEqual([
      'index.html',
      'listed-dialogue/round-1.html',
      'listed-dialogue/round-2.html',
      'robots.txt',
    ])
    expect(readFileSync(join(out, 'index.html'), 'utf8')).toContain('href="/listed-dialogue/round-2"')
  })
})
