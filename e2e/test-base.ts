import { test as base } from '@playwright/test'
import { installRoad } from './road-route.ts'

// The Playwright test every spec uses: the same as @playwright/test's, with
// GET /api/road answered by the road fixture until job 20-a1-road is merged
// (e2e/road-route.ts). A page made from the test's own context gets it.
export { expect } from '@playwright/test'
export type { Page, Locator, BrowserContext } from '@playwright/test'

// introSeen: the tab's visit starts before the page loads, as if the learner had met Aleksi earlier in
// this visit, so his intro does not stand before the road (e2e/intro-seen.ts). A spec that tests his intro
// sets test.use({ introSeen: false }).
export const test = base.extend<{ introSeen: boolean }>({
  introSeen: [true, { option: true }],
  context: async ({ context, introSeen }, use) => {
    await installRoad(context, {}, { introSeen })
    await use(context)
  },
})
