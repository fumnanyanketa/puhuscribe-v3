import type { BrowserContext, Page } from '@playwright/test'
import { MET_KEY } from '../src/lib/aleksi-intro.ts'

// A new visitor meets Aleksi once per phone before the road opens (fast route
// aleksi-intro, 4 November 2026). Browser tests of the road and the lessons play
// a phone that has already met him, so the intro does not stand between them and
// the road. This marks the phone before any page script runs.
// e2e/aleksi-intro.spec.ts tests the intro itself on a phone that has not.

export async function markIntroSeen(target: Page | BrowserContext): Promise<void> {
  // A string, because the browser's own names are not in the tests' TypeScript settings.
  await target.addInitScript({
    content: `try { localStorage.setItem(${JSON.stringify(MET_KEY)}, 'yes') } catch {}`,
  })
}
