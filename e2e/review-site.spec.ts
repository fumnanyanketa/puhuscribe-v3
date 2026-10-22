import { createHash } from 'node:crypto'
import { existsSync, readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { expect, test, type APIResponse } from '@playwright/test'

// Labels [site N] are the "Done when" statement numbers from
// factory/jobs/13-review-site/spec.md that each test protects.
//
// The live review site, after a deploy from main. Tag @review-site. Skipped
// unless REVIEW_SITE_URL is set, which only the deploy job of
// .github/workflows/review-site.yml does. That job also sets
// CF_ACCESS_CLIENT_ID and CF_ACCESS_CLIENT_SECRET to the review site's Access
// service token, so playwright.config.ts adds them to every request and writes
// no trace, HAR file or HTML report.
//
// What the site should serve is read from this checkout: the list in
// review-site/dialogues.json, each dialogue's title in its draft.json and the
// committed review pages.

const SITE = (process.env.REVIEW_SITE_URL ?? '').replace(/\/$/, '')
const SUBDOMAIN = process.env.REVIEW_WORKERS_SUBDOMAIN ?? ''

interface Listed {
  slug: string
  title: string
  finnish: string
  rounds: number[]
}

function listed(): Listed[] {
  const { dialogues } = JSON.parse(readFileSync('review-site/dialogues.json', 'utf8')) as {
    dialogues: string[]
  }
  return dialogues.map((slug) => {
    const draft = JSON.parse(readFileSync(join('content/drafts', slug, 'draft.json'), 'utf8')) as {
      brief: { dialogue: { title_en: string } }
      lines: { text_puhe: string }[]
    }
    const rounds = readdirSync(join('content/drafts', slug, 'review'))
      .flatMap((name) => /^round-(\d+)\.html$/.exec(name)?.[1] ?? [])
      .map(Number)
      .sort((a, b) => a - b)
    return { slug, title: draft.brief.dialogue.title_en, finnish: draft.lines[0]?.text_puhe ?? '', rounds }
  })
}

function committedPage(slug: string, round: number): Buffer {
  return readFileSync(join('content/drafts', slug, 'review', `round-${String(round)}.html`))
}

function sha256(data: Buffer): string {
  return createHash('sha256').update(data).digest('hex')
}

// A slug with a review page in content/drafts that is not on the list, or a
// made up one when every draft is listed.
function unlistedSlug(slugs: string[]): string {
  const found = readdirSync('content/drafts').find(
    (slug) => !slugs.includes(slug) && existsSync(join('content/drafts', slug, 'review', 'round-1.html')),
  )
  return found ?? 'not-a-listed-dialogue'
}

function expectSiteHeaders(res: APIResponse, csp: 'site' | 'page'): void {
  const headers = res.headers()
  expect(headers['x-robots-tag']).toBe('noindex, nofollow, noarchive')
  expect(headers['cache-control']).toBe('private, no-store')
  expect(headers['referrer-policy']).toBe('no-referrer')
  expect(headers['x-content-type-options']).toBe('nosniff')
  expect(headers['content-security-policy']).toBe(
    csp === 'page'
      ? "frame-ancestors 'none'"
      : "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
  )
}

test.describe('the live review site', { tag: '@review-site' }, () => {
  test.skip(!SITE, 'Runs only after a deploy, when REVIEW_SITE_URL is set')

  const dialogues = listed()
  const first = dialogues[0]
  const firstPage = first
    ? `/${first.slug}/round-${String(first.rounds[0] ?? 1)}`
    : '/no-listed-dialogue/round-1'

  // In Playwright Test, new contexts inherit the config's extraHTTPHeaders,
  // which hold the service token. Clearing them makes these contexts anonymous,
  // like a private browser window.

  test('[site 14] an anonymous visitor lands on the Access sign in page and sees no draft', async ({
    browser,
  }) => {
    const context = await browser.newContext({ extraHTTPHeaders: {} })
    const page = await context.newPage()
    const sentServiceToken: string[] = []
    page.on('request', (request) => {
      const headers = request.headers()
      if ('cf-access-client-id' in headers || 'cf-access-client-secret' in headers)
        sentServiceToken.push(request.url())
    })
    for (const path of ['/', firstPage, '/robots.txt']) {
      await page.goto(`${SITE}${path}`)
      expect(new URL(page.url()).hostname, path).toMatch(/\.cloudflareaccess\.com$/)
      const html = await page.content()
      for (const d of dialogues) {
        expect(html, path).not.toContain(d.title)
        expect(html, path).not.toContain(d.finnish)
      }
      expect(html, path).not.toContain('Dialogues to review')
    }
    expect(sentServiceToken).toEqual([])
    await context.close()
  })

  test('[site 14] anonymous requests with redirects off get 302, 401 or 403 and no draft text', async ({
    playwright,
  }) => {
    const anonymous = await playwright.request.newContext({ extraHTTPHeaders: {}, maxRedirects: 0 })
    for (const path of ['/', firstPage, '/robots.txt']) {
      const res = await anonymous.get(`${SITE}${path}`)
      expect([302, 401, 403], path).toContain(res.status())
      const body = await res.text()
      for (const d of dialogues) {
        expect(body, path).not.toContain(d.title)
        expect(body, path).not.toContain(d.finnish)
      }
    }
    await anonymous.dispose()
  })

  test('[site 15] with the service token the index lists every listed dialogue', async ({ page }) => {
    await page.goto(`${SITE}/`)
    await expect(page.getByRole('heading', { level: 1, name: 'Dialogues to review' })).toBeVisible()
    for (const d of dialogues) {
      await expect(page.getByRole('heading', { level: 2, name: d.title, exact: true })).toBeVisible()
      for (const round of d.rounds) {
        await expect(page.locator(`a[href="/${d.slug}/round-${String(round)}"]`)).toHaveCount(1)
      }
    }
  })

  test('[site 15] each listed page opens with its own title and requests nothing from elsewhere', async ({
    page,
  }) => {
    for (const d of dialogues) {
      for (const round of d.rounds) {
        const requests: string[] = []
        const listener = (request: { url: () => string }) => requests.push(request.url())
        page.on('request', listener)
        await page.goto(`${SITE}/${d.slug}/round-${String(round)}`)
        await expect(page.getByRole('heading', { level: 1, name: `Review: ${d.title}` })).toBeVisible()
        expect(await page.title()).toBe(`Review: ${d.title} (round ${String(round)})`)
        page.off('request', listener)
        const elsewhere = requests.filter((url) => !/^(data|blob):/.test(url) && new URL(url).origin !== SITE)
        expect(elsewhere).toEqual([])
      }
    }
  })

  test('[site 15] a generic fill downloads a review file with the right format, slug and round', async ({
    page,
  }) => {
    test.skip(!first, 'Nothing is listed')
    if (!first) return
    const round = first.rounds.at(-1) ?? 1
    await page.goto(`${SITE}/${first.slug}/round-${String(round)}`)
    await page.getByLabel('Your reviewer code (for example R1, not your name)').fill('TEST')
    for (const radio of await page.getByRole('radio', { name: 'Approve', exact: true }).all())
      await radio.check()
    for (const radio of await page.getByRole('radio', { name: 'Sounds right' }).all()) await radio.check()
    await page.getByRole('radio', { name: 'I approve this dialogue as a whole' }).check()
    const [download] = await Promise.all([
      page.waitForEvent('download'),
      page.getByRole('button', { name: 'Download my review' }).click(),
    ])
    expect(download.suggestedFilename()).toBe(`review-${first.slug}-round-${String(round)}.json`)
    // Read from Playwright's own temporary folder; never saved anywhere else.
    const review = JSON.parse(readFileSync(await download.path(), 'utf8')) as {
      format: string
      dialogue_slug: string
      round: number
    }
    expect(review.format).toBe('puhuscribe-review-1')
    expect(review.dialogue_slug).toBe(first.slug)
    expect(review.round).toBe(round)
    await download.delete()
  })

  test('[site 5] [site 15] the headers are present on the index, a page, robots.txt, 404 and 405', async ({
    request,
  }) => {
    const index = await request.get(`${SITE}/`)
    expect(index.status()).toBe(200)
    expectSiteHeaders(index, 'site')
    const page = await request.get(`${SITE}${firstPage}`)
    expect(page.status()).toBe(200)
    expectSiteHeaders(page, 'page')
    const robots = await request.get(`${SITE}/robots.txt`)
    expect(await robots.text()).toBe('User-agent: *\nDisallow: /\n')
    expectSiteHeaders(robots, 'site')
    const missing = await request.get(`${SITE}/nothing-here`)
    expect(missing.status()).toBe(404)
    expectSiteHeaders(missing, 'site')
    const post = await request.post(`${SITE}/`, { data: 'x' })
    expect(post.status()).toBe(405)
    expectSiteHeaders(post, 'site')
  })

  test('[site 15] drafts, audio, round files, the list and unlisted pages get 404', async ({ request }) => {
    const slug = first?.slug ?? 'no-listed-dialogue'
    const paths = [
      `/content/drafts/${slug}/draft.json`,
      `/${slug}/audio/1-puhe.mp3`,
      `/${slug}/round-1.json`,
      '/review-site/dialogues.json',
      `/${unlistedSlug(dialogues.map((d) => d.slug))}/round-1`,
    ]
    for (const path of paths) {
      const res = await request.get(`${SITE}${path}`, { maxRedirects: 0 })
      expect(res.status(), path).toBe(404)
      const body = await res.text()
      expect(body, path).toContain('<p>Not found. <a href="/"')
      expect(
        [...body.matchAll(/href="([^"]*)"/g)].map((m) => m[1]),
        path,
      ).toEqual(['/'])
    }
  })

  test('[site 16] every listed page is served byte for byte as committed', async ({ request }) => {
    for (const d of dialogues) {
      for (const round of d.rounds) {
        const res = await request.get(`${SITE}/${d.slug}/round-${String(round)}`)
        expect(res.status()).toBe(200)
        expect(sha256(await res.body())).toBe(sha256(committedPage(d.slug, round)))
      }
    }
  })

  test('[site 17] the workers.dev address serves no review content', async ({ playwright }) => {
    test.skip(!SUBDOMAIN, 'REVIEW_WORKERS_SUBDOMAIN (a GitHub variable) is not set')
    for (const headers of [{}, undefined]) {
      // Once anonymous, once with the service token from the config.
      const context = await playwright.request.newContext({
        maxRedirects: 0,
        ...(headers ? { extraHTTPHeaders: headers } : {}),
      })
      for (const path of ['/', firstPage]) {
        let body = ''
        let status = 0
        try {
          const res = await context.get(`https://puhuscribe-review.${SUBDOMAIN}.workers.dev${path}`)
          status = res.status()
          body = await res.text()
        } catch {
          // No such address at all is also no review content.
        }
        expect(status, path).not.toBe(200)
        expect(body, path).not.toContain('Dialogues to review')
        for (const d of dialogues) expect(body, path).not.toContain(d.title)
      }
      await context.dispose()
    }
  })
})
