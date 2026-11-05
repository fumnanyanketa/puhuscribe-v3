import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import { PrivacyPage, SECTION_HEADINGS } from './PrivacyPage.tsx'
import { GUEST_LINE } from './road-copy.ts'

// Fast route no-age-limit (owner, 5 November 2026): Aleksi has no age limit.
// [no-age-limit 1] No app text and no part of the privacy notice states one.
// tests/no-age-limit.test.ts checks every app and Worker text file as well.

const AGE_LIMIT = /18 and over|for adults/i

describe('no age limit', () => {
  it('[no-age-limit 1] the guest line says only that Start makes a guest account', () => {
    expect(GUEST_LINE).toBe('Starting creates a guest account on this device so your progress is saved.')
    expect(GUEST_LINE).not.toMatch(AGE_LIMIT)
  })

  it('[no-age-limit 1] the privacy notice has no age section and states no age limit', () => {
    const html = renderToStaticMarkup(createElement(PrivacyPage))
    expect(html).not.toMatch(AGE_LIMIT)
    expect(SECTION_HEADINGS).not.toContain('Age')
    expect(html).not.toContain('privacy-age')
  })
})
