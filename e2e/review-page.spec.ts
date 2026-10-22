import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { pathToFileURL } from 'node:url'
import { expect, test, type Page } from '@playwright/test'

// Labels [content N] are the "Done when" statement numbers from
// factory/jobs/7-content-pipeline/spec.md that each test protects.
//
// The native reviewer's page is one HTML file opened from disk. This opens the
// page the pipeline makes for its made up fixture dialogue
// (scripts/generate/fixture_outputs.py keeps it current; pytest fails if it is
// not). One line of the fixture holds <script> on purpose.

const PAGE = pathToFileURL(resolve('scripts/generate/fixtures/review/round-1.html')).href
const PLANTED = "<script>document.title='script ran'</script>"

async function openPage(page: Page, requests: string[]) {
  page.on('request', (request) => requests.push(request.url()))
  await page.goto(PAGE)
  await expect(page.getByRole('heading', { level: 1, name: 'Review: pgtap publish fixture' })).toBeVisible()
}

test.describe('the review page', () => {
  test('[content 13] opens from disk and loads nothing from the network', async ({ page }) => {
    const requests: string[] = []
    await openPage(page, requests)
    await page.getByRole('button', { name: 'Play the spoken audio of line 1' }).click()
    expect(requests.filter((url) => !/^(file|data|blob):/.test(url))).toEqual([])
  })

  test('[content 13] drafted text that contains <script> is printed, never run', async ({ page }) => {
    await openPage(page, [])
    await expect(page.getByText(PLANTED).first()).toBeVisible()
    expect(await page.title()).toBe('Review: pgtap publish fixture (round 1)')
    await expect(page.getByText("(it's a test of <b>escaping</b> & quotes)")).toBeVisible()
  })

  test('[content 13] shows each line, word card and clip with its choices', async ({ page }) => {
    await openPage(page, [])
    await expect(page.getByRole('heading', { name: 'Line 1, Aino (pgtap speaker one)' })).toBeVisible()
    await expect(page.getByText('Mä oon Aino.')).toBeVisible()
    await expect(page.getByText('Minä olen Aino.')).toBeVisible()
    await expect(page.getByText("English meaning: pgtap fixture: I'm Aino.")).toBeVisible()
    await expect(page.getByText('Spoken only words (no written partner): No')).toBeVisible()
    await expect(page.getByText('Form: present tense, 1st person singular')).toBeVisible()
    await expect(page.getByText('Base form: pgtap-olla').first()).toBeVisible()
    await expect(page.getByRole('radio', { name: 'Sounds right' })).toHaveCount(4)
    await expect(page.getByRole('radio', { name: 'Sounds wrong' })).toHaveCount(4)
    await expect(page.getByRole('radio', { name: 'Approve', exact: true })).toHaveCount(7)
    await expect(page.getByRole('radio', { name: 'Fix', exact: true })).toHaveCount(7)
    await expect(page.getByRole('radio', { name: 'I approve this dialogue as a whole' })).toHaveCount(1)
  })

  test('[content 13] refuses to save until every item has a decision and the code is filled in', async ({
    page,
  }) => {
    await openPage(page, [])
    await page.getByRole('button', { name: 'Download my review' }).click()
    await expect(page.getByRole('status')).toContainText('Not saved yet')
    await expect(page.getByRole('status')).toContainText('Write your reviewer code')
    await expect(page.getByRole('status')).toContainText('Line 1: choose approve or fix.')
  })

  test('[content 13] "Download my review" saves every decision with each item\'s fingerprint', async ({
    page,
  }) => {
    await openPage(page, [])
    await page.getByLabel('Your reviewer code (for example R1, not your name)').fill('R1')
    for (const radio of await page.getByRole('radio', { name: 'Approve', exact: true }).all())
      await radio.check()
    for (const radio of await page.getByRole('radio', { name: 'Sounds right' }).all()) await radio.check()
    await page.getByRole('radio', { name: 'Fix', exact: true }).first().check()
    const fix = page.getByLabel('Corrected English meaning').first()
    await fix.fill('pgtap fixture: I am Aino.')
    await page.getByRole('radio', { name: 'I approve this dialogue as a whole' }).check()
    const [download] = await Promise.all([
      page.waitForEvent('download'),
      page.getByRole('button', { name: 'Download my review' }).click(),
    ])
    expect(download.suggestedFilename()).toBe('review-pgtap-publish-fixture-round-1.json')
    const path = await download.path()
    const review = JSON.parse(readFileSync(path, 'utf8')) as {
      format: string
      dialogue_slug: string
      round: number
      reviewer_code: string
      items: {
        id: string
        fingerprint: string
        decision?: string
        verdict?: string
        fix?: Record<string, string>
      }[]
    }
    expect(review.format).toBe('puhuscribe-review-1')
    expect(review.dialogue_slug).toBe('pgtap-publish-fixture')
    expect(review.reviewer_code).toBe('R1')
    expect(review.items).toHaveLength(2 + 4 + 5 + 1)
    for (const item of review.items) expect(item.fingerprint).toMatch(/^[0-9a-f]{64}$/)
    const line1 = review.items.find((item) => item.id === 'line-1')
    expect(line1?.decision).toBe('fix')
    expect(line1?.fix?.gloss_en).toBe('pgtap fixture: I am Aino.')
    expect(line1?.fix?.text_kirja).toBe('Minä olen Aino.')
    expect(
      review.items.filter((item) => item.id.startsWith('audio-')).every((item) => item.verdict === 'right'),
    ).toBe(true)
    expect(review.items.find((item) => item.id === 'dialogue')?.decision).toBe('approve')
  })

  test('[content 13] [content 14] a reviewer who asks for a fix answers "Not yet" and can still download', async ({
    page,
  }) => {
    await openPage(page, [])
    await page.getByLabel('Your reviewer code (for example R1, not your name)').fill('R1')
    for (const radio of await page.getByRole('radio', { name: 'Approve', exact: true }).all())
      await radio.check()
    for (const radio of await page.getByRole('radio', { name: 'Sounds right' }).all()) await radio.check()
    await page.getByRole('radio', { name: 'Not yet' }).check()
    await page.getByRole('button', { name: 'Download my review' }).click()
    await expect(page.getByRole('status')).toContainText(
      'you chose Not yet, but nothing is marked Fix or Sounds wrong',
    )
    await page
      .getByRole('group', { name: 'Line 2 written audio, the sound only' })
      .getByRole('radio', { name: 'Sounds wrong' })
      .check()
    const [download] = await Promise.all([
      page.waitForEvent('download'),
      page.getByRole('button', { name: 'Download my review' }).click(),
    ])
    const review = JSON.parse(readFileSync(await download.path(), 'utf8')) as {
      items: { id: string; decision?: string; verdict?: string }[]
    }
    expect(review.items.find((item) => item.id === 'dialogue')?.decision).toBe('not-yet')
    expect(review.items.find((item) => item.id === 'audio-2-kirja')?.verdict).toBe('wrong')
  })

  test('[content 13] each pair of choices is a named group, and Finnish is marked as Finnish', async ({
    page,
  }) => {
    await openPage(page, [])
    for (const name of [
      'Line 1 spoken audio, the sound only',
      'Line 1: is the Finnish text and its English meaning right?',
      'Word card olen: is it right?',
      'The dialogue as a whole',
    ]) {
      await expect(page.getByRole('group', { name, exact: true })).toBeVisible()
    }
    await expect(page.locator('p.finnish[lang="fi"]')).toHaveCount(4)
    await page.getByRole('radio', { name: 'Fix', exact: true }).first().check()
    await expect(page.getByLabel('Corrected written Finnish').first()).toHaveAttribute('lang', 'fi')
    await expect(page.getByLabel('Corrected English meaning').first()).not.toHaveAttribute('lang', 'fi')
    await expect(page.getByText('Closing or refreshing this page before then loses your work.')).toBeVisible()
  })

  test('[content 13] a long Finnish compound wraps inside its card at 375 px', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 })
    await openPage(page, [])
    await expect(
      page.getByText('Lentokonesuihkuturbiinimoottoriapumekaanikkoaliupseerioppilas').first(),
    ).toBeVisible()
    const widths = await page.evaluate<{ page: number; view: number }>(
      '({ page: document.documentElement.scrollWidth, view: document.documentElement.clientWidth })',
    )
    expect(widths.page).toBeLessThanOrEqual(widths.view)
  })
})
