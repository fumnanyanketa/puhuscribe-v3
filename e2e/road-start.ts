import type { Page } from '@playwright/test'

// The road's one Start (fast route road-stops, owner approved 5 November 2026). Before a stop the learner has
// not begun, Start opens Aleksi's stop screen and its Continue does what Start did before (makes or finds the
// account, then the lesson); part way through a stop, with a session open or a review due, Start goes
// straight on. The browser tests that only need to reach the lesson press Start, and Continue when the stop
// screen shows. e2e/road-stops.spec.ts tests the stop screen itself.

export const START = { name: 'Start', exact: true } as const

/** Presses the road's Start, then the stop screen's Continue if Aleksi's stop screen opens. */
export async function pressStart(page: Page): Promise<void> {
  await page.getByRole('button', START).click()
  const stopScreen = page.getByRole('heading', { level: 1, name: /^This is stop \d+, / })
  const lesson = page.waitForURL(/\/session(\?|$)/, { timeout: 15_000 }).then(
    () => 'lesson' as const,
    () => 'none' as const,
  )
  const screen = stopScreen.waitFor({ timeout: 15_000 }).then(
    () => 'stop' as const,
    () => 'none' as const,
  )
  if ((await Promise.race([lesson, screen])) === 'stop')
    await page.getByRole('button', { name: 'Continue', exact: true }).click()
}
