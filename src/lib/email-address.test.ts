import { describe, expect, it } from 'vitest'
import { MAX_EMAIL_LENGTH, cleanCode, cleanEmail } from './email-address.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/11-accounts/spec.md that each test protects.

describe('cleanEmail', () => {
  it('[accounts 4] accepts an address shaped like an email, trimmed and in lower case', () => {
    expect(cleanEmail(' Learner-A@Example.com ')).toBe('learner-a@example.com')
    expect(cleanEmail('a.b+c@mail.example.fi')).toBe('a.b+c@mail.example.fi')
  })

  it('[accounts 4] refuses an empty, too long or badly shaped address', () => {
    const long = `${'a'.repeat(MAX_EMAIL_LENGTH - 'example.com'.length)}@example.com`
    expect(long.length).toBe(MAX_EMAIL_LENGTH + 1)
    const bad = [
      '',
      '   ',
      'learner',
      'learner@',
      '@example.com',
      'learner@example',
      'a b@example.com',
      'a@b@example.com',
      'learner@example.',
      'learner\u0000@example.com',
      long,
      null,
      42,
    ]
    for (const value of bad) expect(cleanEmail(value), String(value)).toBeNull()
    expect(
      cleanEmail(`${'a'.repeat(MAX_EMAIL_LENGTH - 'example.com'.length - 1)}@example.com`),
    ).not.toBeNull()
  })
})

describe('cleanCode', () => {
  it('[accounts 5] accepts 6 digits, with spaces removed, and nothing else', () => {
    expect(cleanCode('123456')).toBe('123456')
    expect(cleanCode(' 123 456 ')).toBe('123456')
    for (const bad of ['12345', '1234567', 'abcdef', '12345a', '', null]) expect(cleanCode(bad)).toBeNull()
  })
})
