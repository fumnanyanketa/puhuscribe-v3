import { describe, expect, it } from 'vitest'
import { ACCOUNT_BEFORE_LESSON, forwardFor, isBeforeFirstLesson, PATHS } from './app-paths.ts'

// Fast route signup-choice, "Done when" 8: only the exact ?then=lesson switches the email screen to its
// first lesson mode, and the address it opens is fixed here.

describe('the first lesson mode of "Create your account"', () => {
  it('[signup-choice 8] opens at the fixed account email address with ?then=lesson', () => {
    expect(ACCOUNT_BEFORE_LESSON).toBe(`${PATHS.accountEmail}?then=lesson`)
    expect(ACCOUNT_BEFORE_LESSON).toBe('/learn/account/email?then=lesson')
  })

  it('[signup-choice 8] is on only for then=lesson exactly', () => {
    expect(isBeforeFirstLesson('?then=lesson')).toBe(true)
    expect(isBeforeFirstLesson('?x=1&then=lesson')).toBe(true)
    for (const search of [
      '',
      '?',
      '?then=',
      '?then=Lesson',
      '?then=lesson2',
      '?then=https://example.com',
      '?next=lesson',
    ])
      expect(isBeforeFirstLesson(search), search).toBe(false)
  })
})

// Fast route reviewers ("Done when" 1 in factory/jobs/reviewers/spec.md): the public reviewer page lives
// outside /learn, and the app shell keeps it instead of sending it to the landing page.
describe('the reviewer page address', () => {
  it('[reviewers 1] is /reviewers, and the app shell stays there', () => {
    expect(PATHS.reviewers).toBe('/reviewers')
    expect(forwardFor('/reviewers', '', '')).toBeNull()
    expect(forwardFor('/reviewers', '?from=video', '#form')).toBeNull()
  })

  it('[reviewers 1] other addresses outside /learn still go to the landing page or their new address', () => {
    expect(forwardFor('/reviewers/extra', '', '')).toBe(PATHS.landing)
    expect(forwardFor('/reviewer', '', '')).toBe(PATHS.landing)
    expect(forwardFor('/privacy', '', '')).toBe(PATHS.privacy)
    expect(forwardFor('/learn/privacy', '', '')).toBeNull()
  })
})
