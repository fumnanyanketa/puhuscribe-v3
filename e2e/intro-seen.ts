import type { BrowserContext, Page } from '@playwright/test'
import { INTRO_KEY } from '../src/lib/intro-answers.ts'

// The first-open questions show once per phone (fast route "intro", 3 November
// 2026). Browser tests that press "Start" on the day one card to reach a
// session play a phone that has already been through them, so the questions do
// not stand between Start and the session. This marks them as seen before any
// page script runs. e2e/intro.spec.ts tests the questions themselves on a phone
// that has not seen them.

export async function markIntroSeen(target: Page | BrowserContext): Promise<void> {
  // A string, because the browser's own names are not in the tests' TypeScript settings.
  await target.addInitScript({
    content: `try { localStorage.setItem(${JSON.stringify(INTRO_KEY)}, ${JSON.stringify(JSON.stringify({ seen: true }))}) } catch {}`,
  })
}
