import { mkdirSync } from 'node:fs'
import { resolve } from 'node:path'
import { expect, test, type Page } from '@playwright/test'
import { mockLesson } from './lesson-mocks.ts'
import { stubMicrophone } from './microphone.ts'
import { dismissTip } from './session-helpers.ts'

// The evidence of fast route stop-clearer (owner, 5 November 2026): "Hear it, say it" while recording,
// at phone size and at 320 px wide with 200% text, in Chromium. Run it on purpose:
//   npm run build
//   PUHUSCRIBE_EVIDENCE=1 PUHUSCRIBE_SHOT=after npx playwright test e2e/stop-clearer-evidence.spec.ts --project=chromium
// PUHUSCRIBE_SHOT names the files (before or after). The files go to factory/jobs/stop-clearer/evidence/.
// The page answers from the lesson mocks and the microphone is a generated tone. Nothing here holds a secret.

test.skip(process.env.PUHUSCRIBE_EVIDENCE !== '1', 'Evidence is made on purpose (PUHUSCRIBE_EVIDENCE=1).')

const OUT = resolve('factory/jobs/stop-clearer/evidence')
const WHEN = process.env.PUHUSCRIBE_SHOT ?? 'after'

async function recording(page: Page) {
  await stubMicrophone(page, 'tone')
  await mockLesson(page)
  await page.goto('/learn/session')
  await expect(page.getByRole('heading', { level: 1, name: 'Hear it' })).toBeVisible()
  await dismissTip(page)
  await page.getByRole('button', { name: 'Record yourself saying the line' }).click()
  await expect(page.getByRole('button', { name: /^Stop recording/ })).toBeVisible()
  await page.evaluate('document.fonts.ready')
  await page.waitForTimeout(700)
  mkdirSync(OUT, { recursive: true })
}

test('recording at 375 x 812', async ({ page }) => {
  await recording(page)
  await page.screenshot({ path: `${OUT}/${WHEN}-recording-375.png` })
})

test('recording at 320 wide with 200% text', async ({ page }) => {
  await page.setViewportSize({ width: 320, height: 720 })
  await page.addInitScript(
    "addEventListener('DOMContentLoaded', () => { const s = document.createElement('style'); s.textContent = 'html { font-size: 200% !important; }'; document.head.append(s) })",
  )
  await recording(page)
  // The stop link before the change, the stop pill after it, scrolled into view inside the lesson.
  await page.getByRole('button', { name: /^(Stop|Tap to stop listening)$/ }).scrollIntoViewIfNeeded()
  await page.waitForTimeout(300)
  await page.screenshot({ path: `${OUT}/${WHEN}-recording-320-large-text.png` })
})
