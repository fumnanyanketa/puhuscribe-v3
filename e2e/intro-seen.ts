import type { BrowserContext, Page } from '@playwright/test'
import { VISIT_KEY } from '../src/lib/aleksi-intro.ts'

// Aleksi's intro comes before the road for everyone except a signed in email account with a finished
// stop (fast routes intro-rule and intro-stop, owner's rules of 4 November 2026), at the start of each visit
// (fast route intro-visit, 5 November 2026). The phone keeps no "met" flag, so the browser tests of the road
// and the lessons cannot mark the phone in advance. Until fast route intro-logo this pressed "Nice to meet
// you" as soon as the intro appeared. That screen is gone: the new intro (5 November 2026) plays Aleksi's
// voice after a tap, about 15 seconds, or goes straight to its end state on Skip or with reduced motion.
// So instead this starts the tab's visit before the page loads, as if the learner had met Aleksi earlier in
// this visit: the road opens straight away, with its opening animation when motion is on, as after the old
// "Nice to meet you", and with no intro bubble. The marker holds only a time, like the app's own. A visit
// marker the test or the app already wrote is left as it is.
// e2e/aleksi-intro.spec.ts, e2e/intro-visit.spec.ts and e2e/intro-logo.spec.ts test the intro itself and
// do not use this (mockHome with met: false, or test.use({ introSeen: false })).

export async function markIntroSeen(target: Page | BrowserContext): Promise<void> {
  // A string, because the browser's own names are not in the tests' TypeScript settings.
  await target.addInitScript({
    content: `(() => {
      try {
        if (sessionStorage.getItem(${JSON.stringify(VISIT_KEY)}) === null)
          sessionStorage.setItem(${JSON.stringify(VISIT_KEY)}, String(Date.now()))
      } catch {}
    })()`,
  })
}
