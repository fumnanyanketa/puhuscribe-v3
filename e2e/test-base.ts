import { test as base } from '@playwright/test'
import { installRoad } from './road-route.ts'

// The Playwright test every spec uses: the same as @playwright/test's, with
// GET /api/road answered by the road fixture until job 20-a1-road is merged
// (e2e/road-route.ts). A page made from the test's own context gets it.
export { expect } from '@playwright/test'
export type { Page, Locator, BrowserContext } from '@playwright/test'

export const test = base.extend({
  context: async ({ context }, use) => {
    await installRoad(context)
    await use(context)
  },
})
