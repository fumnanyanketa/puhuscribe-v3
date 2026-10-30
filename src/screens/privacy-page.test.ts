import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import { ACCOUNT_ITEMS, HOW_LONG, NOT_LINKED_ITEMS, USER_TABLES } from '../privacy/data-inventory.ts'
import { RESPONSIBLE } from '../privacy/notice-settings.ts'
import { PROCESSORS } from '../privacy/processors.ts'
import { COMPLAINT_URL, PrivacyPage, RIGHTS, SECTION_HEADINGS } from './PrivacyPage.tsx'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/11-accounts/spec.md that each test protects.
// The privacy notice has every section the spec asks for, rendered from the
// inventory, the processors list and the owner's settings file.

function text(html: string): string {
  return html
    .replace(/<[^>]+>/g, ' ')
    .replace(/&#x27;|&apos;|&#39;/g, "'")
    .replace(/&quot;/g, '"')
    .replace(/&amp;/g, '&')
    .replace(/\s+/g, ' ')
}

const filled = { responsibleName: 'Probe Business Oy (1234567-8)', contact: 'privacy@probe.example' }

describe('the privacy notice', () => {
  const html = renderToStaticMarkup(createElement(PrivacyPage, { responsible: filled }))
  const page = text(html)

  it('[accounts 16] has every section, each as a heading', () => {
    expect(SECTION_HEADINGS).toEqual([
      'Who is responsible',
      'What we keep and why',
      'How long we keep it',
      'Where it is kept and who processes it',
      'Cookies',
      'Your rights',
      'Age',
      'Last updated',
    ])
    for (const heading of SECTION_HEADINGS) expect(html).toMatch(new RegExp(`<h2[^>]*>${heading}</h2>`))
  })

  it('[accounts 16] names who is responsible and how to reach them, from the settings file', () => {
    expect(page).toContain('Probe Business Oy (1234567-8) is responsible for your data in PuhuScribe.')
    expect(html).toContain('href="mailto:privacy@probe.example"')
  })

  it('[accounts 16] shows the name and a mailto link taken from the settings file', () => {
    const live = renderToStaticMarkup(createElement(PrivacyPage))
    expect(text(live)).toContain(`${RESPONSIBLE.responsibleName} is responsible for your data in PuhuScribe.`)
    expect(live).toContain(`href="mailto:${RESPONSIBLE.contact}"`)
  })

  it('[accounts 16] [accounts 17] lists what is kept, why and the legal reason, from the inventory', () => {
    for (const item of [...ACCOUNT_ITEMS, ...USER_TABLES]) {
      expect(page).toContain(item.name)
      expect(page).toContain(item.what)
      expect(page).toContain(`Why: ${item.why}`)
      expect(page).toContain(`Legal reason: ${item.legal}`)
    }
    expect(page).toContain('GDPR Article 6(1)(b)')
  })

  it('[accounts 16] [accounts 24] [accounts 25] says how long, with the 90 day and 24 month rules', () => {
    expect(page).toContain(HOW_LONG)
    expect(HOW_LONG).toContain('A guest account is deleted after 90 days with no learning activity')
    expect(HOW_LONG).toContain('an email account after 24 months with no learning activity')
  })

  it('[accounts 16] [accounts 17] says where data is and who processes it, from the processors list', () => {
    for (const processor of PROCESSORS) {
      expect(page).toContain(processor.role)
      expect(page).toContain(processor.where)
    }
    expect(page).toContain('In the EU (Ireland).')
    expect(page).toContain('Supabase keeps its API and database logs for 1 day')
  })

  it('[accounts 16] says only the sign in cookies are used', () => {
    expect(page).toContain('PuhuScribe uses only the sign in cookies it needs to work.')
    expect(page).toContain('It uses no tracking or advertising cookies.')
  })

  it('[accounts 16] lists the rights, the one month answer time and the complaint to the Ombudsman', () => {
    for (const right of RIGHTS) expect(page).toContain(right)
    for (const word of ['download', 'corrected', 'deleted', 'Restrict', 'Object', 'Withdraw a consent']) {
      expect(RIGHTS.join(' ')).toContain(word)
    }
    expect(page).toContain('Requests are answered within one month.')
    expect(page).toContain("Finland's Office of the Data Protection Ombudsman")
    expect(html).toContain(`href="${COMPLAINT_URL}"`)
  })

  it('[accounts 16] says it is for adults 18 and over, and when it was last updated', () => {
    expect(page).toContain('PuhuScribe is for adults, 18 and over.')
    expect(page).toMatch(/This notice was last updated on \d{1,2} [A-Z][a-z]+ \d{4}\./)
  })

  it('[accounts 16] keeps the writing rules: no em or en dash, no hype words', () => {
    expect(page).not.toMatch(/—|–/)
    expect(page).not.toMatch(
      /seamless|unlock|elevate|empower|supercharge|game-changer|cutting-edge|effortless/i,
    )
  })

  it('[accounts 16] the contact address looks like an email address', () => {
    expect(RESPONSIBLE.contact).toMatch(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
  })
})

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md.
describe('the privacy notice, job 14-analytics', () => {
  const html = renderToStaticMarkup(createElement(PrivacyPage, { responsible: filled }))
  const page = text(html)

  it('[analytics 29] says what the visit count keeps, why, the legal reason and how long', () => {
    expect(page).toContain('Visit count')
    expect(page).toContain(
      'When you open PuhuScribe, we add one to a count for your country and the day. The country comes from your internet address, which we do not keep. We store no cookie, identifier or browser details for this.',
    )
    expect(page).toContain(
      'Legal reason: Our legitimate interest in knowing how many people use the app and from where (GDPR Article 6(1)(f)).',
    )
    expect(page).toContain('How long: Kept as daily totals.')
  })

  it('[analytics 29] [analytics 23] says what feedback keeps and that it goes with the account', () => {
    expect(page).toContain('Feedback you send')
    expect(page).toContain('The message you send, which screen you sent it from, and when.')
    expect(page).toContain(
      'How long: Stored with your account and deleted with it, including when an unused account is deleted automatically.',
    )
    expect(page).toContain(
      'Legal reason: Needed to provide the service you asked for (GDPR Article 6(1)(b)).',
    )
  })

  it('[analytics 29] says what a crash report holds, that it is not linked to the account, and 30 days', () => {
    expect(page).toContain('Crash reports')
    expect(page).toContain(
      'When the app breaks, it records the error, the file and line, the screen, the app version and a short browser label such as "Safari 17, iOS". Not linked to your account, and nothing you typed or said is included.',
    )
    expect(page).toContain(
      'Legal reason: Our legitimate interest in keeping the app working (GDPR Article 6(1)(f)).',
    )
    expect(page).toContain('How long: Deleted after 30 days.')
    expect(html).toContain('data-inventory="not-linked"')
  })

  it('[analytics 29] adds no new processor: crash reports stay in the Supabase database in the EU', () => {
    expect(PROCESSORS.map((p) => p.name)).toEqual(['Supabase', 'Cloudflare', 'Microsoft (Azure Speech)'])
    expect(PROCESSORS.find((p) => p.name === 'Supabase')?.modules).toContain('crash-reports.ts')
    expect(NOT_LINKED_ITEMS.map((item) => item.name)).toEqual(['Visit count', 'Crash reports'])
  })
})
