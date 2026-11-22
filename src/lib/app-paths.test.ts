import { describe, expect, it } from 'vitest'
import { ACCOUNT_BEFORE_LESSON, isBeforeFirstLesson, PATHS } from './app-paths.ts'

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
