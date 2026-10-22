import { existsSync, readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { pathToFileURL } from 'node:url'
import { expect, test } from '@playwright/test'

// Labels [units N] are the "Done when" statement numbers from
// factory/jobs/12-units-1-3/spec.md that each test protects.
//
// The six round 1 review pages of units 1 to 3, as committed under
// content/drafts/<dialogue>/review/, opened from disk the way the native
// reviewer opens them. Job 7's page test (e2e/review-page.spec.ts) runs on its
// made up fixture page; this runs the same checks on the six real pages.

const DIALOGUES = [
  'meeting-people-new-colleague',
  'meeting-people-language-cafe',
  'ordering-coffee-at-the-counter',
  'ordering-coffee-paying',
  'grocery-store-asking-staff',
  'grocery-store-directions',
]

interface Draft {
  brief: { dialogue: { title_en: string } }
  lines: { n: number; speaker: string; text_puhe: string; text_kirja: string }[]
}

for (const slug of DIALOGUES) {
  test.describe(`the review page of ${slug}`, () => {
    const folder = resolve('content/drafts', slug)
    const page1 = resolve(folder, 'review/round-1.html')

    test('[units 7] [units 5] opens from disk, plays a clip and loads nothing from the network', async ({
      page,
    }) => {
      expect(existsSync(page1), `${slug}: no round 1 review page`).toBe(true)
      const draft = JSON.parse(readFileSync(resolve(folder, 'draft.json'), 'utf8')) as Draft
      const requests: string[] = []
      page.on('request', (request) => requests.push(request.url()))
      await page.goto(pathToFileURL(page1).href)
      await expect(
        page.getByRole('heading', { level: 1, name: `Review: ${draft.brief.dialogue.title_en}` }),
      ).toBeVisible()
      for (const line of draft.lines) {
        await expect(page.getByText(line.text_puhe, { exact: true }).first()).toBeVisible()
        await expect(page.getByText(line.text_kirja, { exact: true }).first()).toBeVisible()
      }
      // A clip for both registers of every line.
      await expect(page.getByRole('radio', { name: 'Sounds right' })).toHaveCount(2 * draft.lines.length)
      await page.getByRole('button', { name: 'Play the spoken audio of line 1' }).click()
      await page.getByRole('button', { name: 'Play the written audio of line 1' }).click()
      expect(requests.filter((url) => !/^(file|data|blob):/.test(url))).toEqual([])
      // The reviewer is asked for a code, never a name or an email address.
      await expect(page.getByText(/reviewer code/i).first()).toBeVisible()
      await expect(page.locator('input[type="email"]')).toHaveCount(0)
    })
  })
}
