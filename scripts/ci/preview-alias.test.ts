import { describe, expect, it } from 'vitest'
import { previewAlias } from './preview-alias.ts'

// [12] Each branch gets a readable preview alias made from its name.

describe('previewAlias', () => {
  it('[12] turns factory branches into readable aliases', () => {
    expect(previewAlias('factory/1-stack')).toBe('factory-1-stack')
    expect(previewAlias('factory/12-tutor')).toBe('factory-12-tutor')
  })

  it('[12] keeps only lowercase letters, numbers and single dashes', () => {
    expect(previewAlias('Feature/New_Screen--Two')).toBe('feature-new-screen-two')
  })

  it('[12] starts with a letter', () => {
    expect(previewAlias('2026/fix')).toBe('b-2026-fix')
    expect(previewAlias('-/x')).toBe('x')
  })

  it('[12] stays short enough for one workers.dev address part', () => {
    const alias = previewAlias('factory/a-very-long-branch-name-that-goes-on-and-on')
    expect(alias.length).toBeLessThanOrEqual(30)
    expect(alias).not.toMatch(/-$/)
    expect(`${alias}-puhuscribe-preview`.length).toBeLessThanOrEqual(63)
  })
})
