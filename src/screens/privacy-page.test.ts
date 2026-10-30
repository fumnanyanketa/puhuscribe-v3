import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import {
  ACCOUNT_ITEMS,
  HOW_LONG,
  LEARNER_TABLES,
  NOT_LINKED_ITEMS,
  OWNER_TABLES,
  USER_TABLES,
} from '../privacy/data-inventory.ts'
import { RESPONSIBLE } from '../privacy/notice-settings.ts'
import { PROCESSORS } from '../privacy/processors.ts'
import { COMPLAINT_URL, NOT_LINKED_RIGHTS, PrivacyPage, RIGHTS, SECTION_HEADINGS } from './PrivacyPage.tsx'

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
      "When you open PuhuScribe, we add one to a count for your country and the day. The country comes from your internet address. Cloudflare, which runs the app, sees that address because it delivers the page to you. PuhuScribe's database does not keep it. We store no cookie, identifier or browser details for this.",
    )
    expect(page).toContain(
      'Legal reason: Our legitimate interest in knowing how many people use the app and from where (GDPR Article 6(1)(f)).',
    )
    expect(page).toContain(
      'How long: Kept as daily totals with no personal data for as long as the service runs, whether or not you delete your account.',
    )
  })

  // Round 2 (design review finding 4): Cloudflare handles the address, so
  // only PuhuScribe's own database can be said not to keep it.
  it('[analytics 29] says the internet address is not kept by PuhuScribe, without claiming nobody sees it', () => {
    expect(page).not.toContain('which we do not keep')
    const visit = NOT_LINKED_ITEMS.find((item) => item.name === 'Visit count')
    expect(visit?.what).toContain("PuhuScribe's database does not keep it.")
    expect(visit?.what).toMatch(/Cloudflare, which runs the app, sees that address/)
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
      'When the app breaks, it records the error, the file and line, the screen, the app version and a short browser label such as "Safari 17, iOS". A report is not linked to your account.',
    )
    expect(page).toContain(
      'Legal reason: Our legitimate interest in keeping the app working (GDPR Article 6(1)(f)).',
    )
    expect(page).toContain('How long: Deleted after 30 days, whether or not you delete your account.')
    expect(html).toContain('data-inventory="not-linked"')
  })

  // Round 2 (design review finding 2): the cleaning removes known shapes and
  // whatever is typed into a field on the page (src/lib/crash-reporter.ts,
  // src/lib/crash-clean.ts, worker/crash.ts). It cannot promise that nothing
  // the learner typed or said ever appears, so the notice says what is removed.
  it('[analytics 29] [analytics 25] says what is removed from a crash report, and claims no more', () => {
    expect(page).not.toMatch(/nothing you typed or said/i)
    const crash = NOT_LINKED_ITEMS.find((item) => item.name === 'Crash reports')
    expect(crash?.what).toContain(
      'Before your browser sends a report, it removes from the error message any text typed into a box on the screen.',
    )
    expect(crash?.what).toContain(
      'Before a report is saved, we also remove anything shaped like an email address, an id, a sign in token or a long number, and replace ids in the screen address.',
    )
  })

  // Round 2 (design review finding 1): the visit count and crash reports are
  // not linked to an account, so deleting an account does not delete them.
  it('[analytics 29] "How long we keep it" says account deletion leaves the visit count and crash reports, and how long each is kept', () => {
    expect(HOW_LONG).not.toContain('deletes everything at once')
    expect(HOW_LONG).toContain('Deleting your account deletes everything linked to it at once.')
    expect(HOW_LONG).toContain(
      'The visit count and crash reports are not linked to any account, so deleting your account does not change them.',
    )
    expect(HOW_LONG).toContain('Crash reports are deleted after 30 days.')
    expect(HOW_LONG).toContain(
      'The visit count is kept as daily totals with no personal data for as long as the service runs.',
    )
    expect(page).toContain(HOW_LONG)
  })

  // Round 2 (design review findings 1 and 16): the rights say what happens
  // when someone asks about data that cannot be linked to them.
  it('[analytics 29] the rights say deletion covers what is linked to the account, and what happens with a request about visits or crashes', () => {
    expect(RIGHTS.join(' ')).not.toContain('deletes everything at once')
    expect(RIGHTS).toContain(
      'Have your data deleted ("Delete my account" on your account page deletes everything linked to your account at once).',
    )
    expect(page).toContain(NOT_LINKED_RIGHTS)
    expect(NOT_LINKED_RIGHTS).toBe(
      'The visit count and crash reports cannot be linked to you. If you ask to see or delete your part of them, we cannot find it, and we will tell you so. Crash reports are deleted after 30 days in any case.',
    )
  })

  // Round 2 (design review finding 3): the owner list row is not learning
  // progress and no learner asked for it.
  it('[analytics 29] [analytics 16] shows "Owner page access" under its own lead in, with legitimate interest as its legal reason', () => {
    const owner = USER_TABLES.find((item) => item.table === 'private.owners')
    expect(owner?.legal).toBe(
      'Our legitimate interest in keeping the owner page private (GDPR Article 6(1)(f)).',
    )
    expect(OWNER_TABLES).toEqual([owner])
    expect(LEARNER_TABLES.map((item) => item.table)).not.toContain('private.owners')
    expect(USER_TABLES).toEqual([...LEARNER_TABLES, ...OWNER_TABLES])
    const learnerList = /data-inventory="tables">(.*?)<\/ul>/s.exec(html)?.[1] ?? ''
    const ownerList = /data-inventory="owner">(.*?)<\/ul>/s.exec(html)?.[1] ?? ''
    expect(learnerList).toContain('Feedback you send')
    expect(learnerList).not.toContain('Owner page access')
    expect(ownerList).toContain('Owner page access')
    expect(page).toContain("Only for the app's owner: Owner page access")
    expect(page).toContain('Your learning and what you send us: Sessions')
    expect(page).not.toContain('Your learning progress:')
  })

  it('[analytics 29] adds no new processor: crash reports stay in the Supabase database in the EU', () => {
    expect(PROCESSORS.map((p) => p.name)).toEqual(['Supabase', 'Cloudflare', 'Microsoft (Azure Speech)'])
    expect(PROCESSORS.find((p) => p.name === 'Supabase')?.modules).toContain('crash-reports.ts')
    expect(NOT_LINKED_ITEMS.map((item) => item.name)).toEqual(['Visit count', 'Crash reports'])
  })
})
