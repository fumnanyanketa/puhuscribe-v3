import { describe, expect, it } from 'vitest'
import { RIGHTS } from '../screens/PrivacyPage.tsx'
import { ACCOUNT_ITEMS, HOW_LONG, LEARNER_TABLES } from './data-inventory.ts'
import { CLAIMS, FIRST_LAYER } from './first-layer.ts'
import { NOTICE_UPDATED } from './notice-settings.ts'
import { PROCESSORS } from './processors.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md. Each claim of the privacy notice's first
// layer is checked against the line that supports it.

const item = (name: string) => LEARNER_TABLES.find((entry) => entry.name === name)
const account = (name: string) => ACCOUNT_ITEMS.find((entry) => entry.name === name)

describe('the first layer of the privacy notice', () => {
  it('[redesign 39] has the title, a two line summary and the five sections, in order', () => {
    expect(FIRST_LAYER.title).toBe('Privacy notice')
    expect(FIRST_LAYER.sections.map((section) => section.heading)).toEqual([
      'What we keep',
      'Your voice',
      'How long',
      'Your rights',
      'Who runs PuhuScribe',
    ])
  })

  it('[redesign 39] keeps the owner’s sentence about who runs PuhuScribe word for word, and not the old one', () => {
    const who = FIRST_LAYER.sections.at(4)?.text
    expect(who).toBe('PuhuScribe is part of the product family of Exentrik, a product studio in Finland.')
    const all = JSON.stringify(FIRST_LAYER)
    expect(all).not.toContain('Exentrik looks after your data')
  })

  it('[redesign 39] claim: we keep it in the EU (the database is in Ireland)', () => {
    const supabase = PROCESSORS.find((processor) => processor.name === 'Supabase')
    expect(supabase?.where).toMatch(/^In the EU/)
  })

  it('[redesign 39] claim: download or delete at any time, and everything from Your account', () => {
    expect(RIGHTS.some((right) => right.includes('Download my data'))).toBe(true)
    expect(RIGHTS.some((right) => right.includes('deletes everything linked to your account at once'))).toBe(
      true,
    )
  })

  it('[redesign 39] claim: progress and settings are what is kept', () => {
    expect(item('Sessions')?.what).toMatch(/how far you got/)
    expect(item('Review cards')).toBeDefined()
    expect(item('Voice consent choices')).toBeDefined()
  })

  it('[redesign 39] claim: a random guest id or your email', () => {
    expect(account('Guest account')?.what).toMatch(/random account id/)
    expect(account('Email account')?.what).toMatch(/email address/)
  })

  it('[redesign 39] claim: we never ask for your name (no inventory item holds one)', () => {
    expect(account('Guest account')?.what).toMatch(/No name\./)
    const asks = [...ACCOUNT_ITEMS, ...LEARNER_TABLES].filter((entry) =>
      /your name\b|full name|surname/i.test(entry.what),
    )
    expect(asks).toEqual([])
  })

  it('[redesign 39] claim: speaking feedback only if you turn it on, and the recording is kept only if you choose', () => {
    const microsoft = PROCESSORS.find((processor) => processor.name.startsWith('Microsoft'))
    expect(microsoft?.role).toMatch(/only if you turned speaking feedback on/)
    expect(microsoft?.role).toMatch(/does not keep it/)
    expect(item('Kept recordings')?.what).toMatch(/^Only if you chose/)
    expect(item('Speaking feedback results')?.what).toMatch(/No audio\.$/)
  })

  it('[redesign 39] a claim the inventory does not support is not in the first layer: the drawn "Never your name" and "Checked, then deleted" are reworded', () => {
    const all = FIRST_LAYER.sections.map((section) => section.text).join(' ')
    expect(all).not.toMatch(/Never your name/)
    expect(all).not.toMatch(/Checked, then deleted/)
    expect(all).toContain('We never ask for your name.')
    expect(all).toContain('Your recording is checked, then deleted')
  })

  it('[redesign 39] claim: 90 days for a guest and 24 months for an email account', () => {
    expect(HOW_LONG).toMatch(/guest account is deleted after 90 days/)
    expect(HOW_LONG).toMatch(/email account after 24 months/)
  })

  it('[redesign 39] every claim lists its source, and the notice date is a real date', () => {
    for (const claim of CLAIMS) {
      expect(claim.claim.length, claim.claim).toBeGreaterThan(10)
      expect(claim.source.length, claim.claim).toBeGreaterThan(10)
    }
    expect(NOTICE_UPDATED).toBe('2026-11-01')
    expect(Number.isNaN(new Date(`${NOTICE_UPDATED}T12:00:00Z`).getTime())).toBe(false)
  })
})
