import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { pathToFileURL } from 'node:url'
import { expect, test, type Page } from '@playwright/test'
import { buildReviewSite } from '../scripts/review-site/build.ts'

// Labels [site N] are the "Done when" statement numbers from
// factory/jobs/13-review-site/spec.md that each test protects.
//
// The review site's index page, built by scripts/review-site/build.ts and opened
// from disk at 375 x 812 in Chromium and WebKit. One build uses this
// repository's real list (review-site/dialogues.json); the other a made up
// repository whose dialogue title holds <script> and a long Finnish compound.

const LONG = 'Lentokonesuihkuturbiinimoottoriapumekaanikkoaliupseerioppilas'
const PLANTED = `<script>document.title='script ran'</script> ${LONG}`

let folders: string[] = []

test.afterAll(() => {
  for (const folder of folders) rmSync(folder, { recursive: true, force: true })
  folders = []
})

function buildFixture(): string {
  const root = mkdtempSync(join(tmpdir(), 'review-site-e2e-'))
  folders.push(root)
  const slug = 'a-very-long-made-up-dialogue-slug-that-must-wrap-inside-its-card-at-phone-width'
  mkdirSync(join(root, 'review-site'), { recursive: true })
  writeFileSync(join(root, 'review-site/dialogues.json'), JSON.stringify({ dialogues: [slug] }))
  mkdirSync(join(root, 'content/drafts', slug, 'review'), { recursive: true })
  writeFileSync(
    join(root, 'content/drafts', slug, 'draft.json'),
    JSON.stringify({ brief: { dialogue: { slug, title_en: PLANTED } } }),
  )
  for (const n of [1, 2]) {
    writeFileSync(join(root, 'content/drafts', slug, 'review', `round-${String(n)}.html`), '<p>page</p>')
  }
  mkdirSync(join(root, 'content/reviews', slug), { recursive: true })
  writeFileSync(join(root, 'content/reviews', slug, 'round-1.json'), '{}')
  const out = join(root, 'dist-review')
  buildReviewSite(root, out)
  return pathToFileURL(join(out, 'index.html')).href
}

function buildReal(): string {
  const out = mkdtempSync(join(tmpdir(), 'review-site-real-'))
  folders.push(out)
  buildReviewSite(process.cwd(), out)
  return pathToFileURL(join(out, 'index.html')).href
}

async function open(page: Page, url: string, requests: string[]): Promise<void> {
  page.on('request', (request) => requests.push(request.url()))
  await page.setViewportSize({ width: 375, height: 812 })
  await page.goto(url)
  await expect(page.getByRole('heading', { level: 1, name: 'Dialogues to review' })).toBeVisible()
}

async function noSidewaysScroll(page: Page): Promise<void> {
  const widths = await page.evaluate<{ page: number; view: number }>(
    '({ page: document.documentElement.scrollWidth, view: document.documentElement.clientWidth })',
  )
  expect(widths.page).toBeLessThanOrEqual(widths.view)
}

test.describe('the review site index page', () => {
  test('[site 4] lists the real listed dialogue with its waiting round, at 375 px with no sideways scroll', async ({
    page,
  }) => {
    const requests: string[] = []
    await open(page, buildReal(), requests)
    await expect(page.getByRole('heading', { level: 2, name: 'A new colleague' })).toBeVisible()
    await expect(page.getByText('Dialogue: meeting-people-new-colleague')).toBeVisible()
    // Screen readers hear the dialogue too; the visible text stays "Round 1".
    const link = page.getByRole('link', { name: 'Round 1, A new colleague', exact: true })
    await expect(link).toHaveAttribute('href', '/meeting-people-new-colleague/round-1')
    await expect(link).toHaveText('Round 1')
    await expect(page.getByRole('listitem').filter({ has: link })).toContainText('Waiting for your review')
    await noSidewaysScroll(page)
    expect(requests.filter((url) => !url.startsWith('file:'))).toEqual([])
    expect(await page.locator('script').count()).toBe(0)
  })

  test('[site 4] prints a title holding <script> as text, wraps long words and shows each round status', async ({
    page,
  }) => {
    const requests: string[] = []
    await open(page, buildFixture(), requests)
    await expect(page.getByRole('heading', { level: 2 })).toHaveText(PLANTED)
    expect(await page.title()).toBe('PuhuScribe review')
    expect(await page.locator('script').count()).toBe(0)
    const items = page.getByRole('listitem')
    await expect(items.nth(0).getByRole('link', { name: `Round 1, ${PLANTED}`, exact: true })).toBeVisible()
    await expect(items.nth(0)).toContainText('Review received')
    await expect(items.nth(1).getByRole('link', { name: `Round 2, ${PLANTED}`, exact: true })).toBeVisible()
    await expect(items.nth(1)).toContainText('Waiting for your review')
    await noSidewaysScroll(page)
    expect(requests.filter((url) => !url.startsWith('file:'))).toEqual([])
  })

  test('[site 4] each round link is a tap target at least 44 px high', async ({ page }) => {
    await open(page, buildFixture(), [])
    for (const link of await page.getByRole('link').all()) {
      const box = await link.boundingBox()
      expect(box?.height ?? 0).toBeGreaterThanOrEqual(44)
    }
  })
})
