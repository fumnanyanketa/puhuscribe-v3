import type { BrowserContext, Page } from '@playwright/test'

// Aleksi's intro comes before the road for everyone except a signed in email account with a finished
// lesson (fast route intro-rule, owner's rule of 4 November 2026). The phone keeps no "met" flag, so the
// browser tests of the road and the lessons cannot mark the phone in advance any more. Instead this
// presses "Nice to meet you" as soon as the intro appears, as a visitor would, so the intro does not
// stand between those tests and the road. The road then opens with its animation, as after a real press.
// e2e/aleksi-intro.spec.ts tests the intro itself and does not use this.

export const MEET_BUTTON = 'Nice to meet you'

export async function markIntroSeen(target: Page | BrowserContext): Promise<void> {
  // A string, because the browser's own names are not in the tests' TypeScript settings.
  await target.addInitScript({
    content: `(() => {
      const press = () => {
        for (const button of document.querySelectorAll('button')) {
          if ((button.textContent || '').trim() === ${JSON.stringify(MEET_BUTTON)}) button.click()
        }
      }
      new MutationObserver(press).observe(document, { childList: true, subtree: true })
    })()`,
  })
}
