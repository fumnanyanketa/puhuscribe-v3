import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import { App } from '../App.tsx'
import { NO_ACCOUNT_ITEMS, REVIEWER_CONTACT, HOW_LONG } from '../privacy/data-inventory.ts'
import { PROCESSORS } from '../privacy/processors.ts'
import { PrivacyPage, REVIEWER_RIGHTS } from './PrivacyPage.tsx'
import { SignupList, signupsOf, type ReviewerSignupRow } from './OwnerReviewers.tsx'
import {
  CHECK_FAILED_REVIEWERS,
  CHECK_UNAVAILABLE_REVIEWERS,
  FIELD_PROBLEMS,
  LIMIT_REACHED,
  NOT_SAVED,
  NOT_SENT,
  REVIEWERS_SENT,
  ReviewersPage,
  problemOf,
} from './ReviewersPage.tsx'

// Labels [reviewers N] are the "Done when" statement numbers from
// factory/jobs/reviewers/spec.md that each test protects.
// The reviewer sign up page's words, its error lines, the owner's list and the
// privacy notice's new lines.

function text(html: string): string {
  return html
    .replace(/<[^>]+>/g, ' ')
    .replace(/&#x27;|&apos;|&#39;/g, "'")
    .replace(/&quot;/g, '"')
    .replace(/&amp;/g, '&')
    .replace(/\s+/g, ' ')
    .trim()
}

describe('the reviewer sign up page', () => {
  const html = renderToStaticMarkup(createElement(ReviewersPage))
  const page = text(html)

  it('[reviewers 1] shows the owner words of the spec, word for word', () => {
    for (const words of [
      'Please help us review the Finnish language in Aleksi',
      "Aleksi teaches puhekieli and kirjakieli, so if Finnish is your first language, I'd love your help checking it.",
      "After you sign up, I'll email you a short list of phrases from the app. You tell me anything that sounds wrong or unnatural.",
      'Your name',
      'Your email',
      'Name for the thank-you in my next video (optional)',
      "Leave it empty if you'd rather not be named.",
      'Sign up',
      'I use these details only to contact you about reviewing and to thank you. I keep them until the review is done, and you can ask me to delete them any time at hello@meetaleksi.com.',
    ]) {
      expect(page).toContain(words)
    }
    expect(REVIEWERS_SENT).toBe("Thank you. I'll email you the phrases soon.")
  })

  it('[reviewers 1] has one h1, a label for each of the three fields and a link to the privacy notice', () => {
    expect(html.match(/<h1[\s>]/g)).toHaveLength(1)
    expect(html).toMatch(/<h1[^>]*>Please help us review the Finnish language in Aleksi<\/h1>/)
    expect(html.match(/<label /g)).toHaveLength(3)
    expect(html.match(/<input /g)).toHaveLength(3)
    expect(html).toContain('type="email"')
    expect(html).toContain('href="/learn/privacy"')
    expect(page).toContain('Read the privacy notice')
  })

  it('[reviewers 1] the app shell draws it at /reviewers, outside /learn', () => {
    expect(text(renderToStaticMarkup(createElement(App, { path: '/reviewers' })))).toContain(
      'Please help us review the Finnish language in Aleksi',
    )
  })

  it('[reviewers 1] keeps the writing rules: no em or en dash, no hype words', () => {
    expect(page).not.toMatch(/—|–/)
    expect(page).not.toMatch(
      /seamless|unlock|elevate|empower|supercharge|game-changer|cutting-edge|effortless/i,
    )
  })
})

describe('the reviewer sign up page error lines', () => {
  it('[reviewers 8] each answer gets the line for what happened, and only that', () => {
    expect(problemOf(null)).toBe(NOT_SENT)
    expect(problemOf({ status: 400, body: { error: 'bad_input', field: 'name' } })).toBe(FIELD_PROBLEMS.name)
    expect(problemOf({ status: 400, body: { error: 'bad_input', field: 'email' } })).toBe(
      FIELD_PROBLEMS.email,
    )
    expect(problemOf({ status: 400, body: { error: 'bad_input', field: 'thanks_name' } })).toBe(
      FIELD_PROBLEMS.thanks_name,
    )
    expect(problemOf({ status: 429, body: { error: 'limit' } })).toBe(LIMIT_REACHED)
    expect(problemOf({ status: 403, body: { error: 'check_failed' } })).toBe(CHECK_FAILED_REVIEWERS)
    expect(problemOf({ status: 503, body: { error: 'check_unavailable' } })).toBe(CHECK_UNAVAILABLE_REVIEWERS)
    expect(problemOf({ status: 503, body: { error: 'not_available' } })).toBe(NOT_SAVED)
    expect(problemOf({ status: 500, body: null })).toBe(NOT_SAVED)
  })

  it('[reviewers 8] a line about the connection is used only when no answer came back', () => {
    expect(NOT_SENT).toMatch(/internet connection/)
    expect(NOT_SAVED).not.toMatch(/internet connection/)
    expect(LIMIT_REACHED).not.toMatch(/internet connection|you already/i)
  })
})

describe('the owner page reviewer sign ups', () => {
  const rows: ReviewerSignupRow[] = [
    {
      id: '0b7e2c1a-8f3d-4c2b-9a1e-5d6f7a8b9c0d',
      name: 'Aino <b>Virtanen</b>',
      email: 'aino@example.fi',
      thanks_name: 'Aino V',
      created_at: '2026-11-24T10:00:00+00:00',
    },
    {
      id: '1c8f3d2b-9a4e-4d3c-8b2f-6e7a8b9c0d1e',
      name: 'Eero',
      email: 'eero@example.fi',
      thanks_name: null,
      created_at: '2026-11-23T10:00:00+00:00',
    },
  ]
  const html = renderToStaticMarkup(
    createElement(SignupList, { rows, onDelete: () => Promise.resolve(null) }),
  )
  const page = text(html)

  it('[reviewers 5] shows each sign up in the order given (newest first), with name, email, thank-you name and date', () => {
    expect(page.indexOf('Aino')).toBeLessThan(page.indexOf('Eero'))
    for (const words of [
      'aino@example.fi',
      'Thank-you name: Aino V.',
      'eero@example.fi',
      'No thank-you name.',
    ])
      expect(page).toContain(words)
    expect(page).toContain('Signed up on 24 Nov 2026, 12:00.')
  })

  it('[reviewers 5] shows what was typed as plain text, never as HTML', () => {
    expect(html).not.toContain('<b>')
    expect(html).toContain('&lt;b&gt;')
  })

  it('[reviewers 5] has a Delete for each sign up, named for screen readers', () => {
    expect(html.match(/>Delete</g)).toHaveLength(2)
    expect(html).toContain('aria-label="Delete the sign-up from Eero"')
    expect(page).not.toContain('Delete for good')
  })

  it('[reviewers 5] reads only a well formed list from the Worker', () => {
    expect(signupsOf({ signups: rows })).toEqual(rows)
    expect(signupsOf({ signups: [{ id: 'x' }] })).toBeNull()
    expect(signupsOf(null)).toBeNull()
    expect(
      text(
        renderToStaticMarkup(createElement(SignupList, { rows: [], onDelete: () => Promise.resolve(null) })),
      ),
    ).toBe('No sign-ups yet.')
  })
})

describe('the privacy notice and the reviewer sign ups', () => {
  const page = text(renderToStaticMarkup(createElement(PrivacyPage)))

  it('[reviewers 7] says what is kept, why, the legal reason and how long, under its own lead in', () => {
    const item = NO_ACCOUNT_ITEMS.find((i) => i.name === 'Reviewer sign-ups')
    expect(item).toBeDefined()
    expect(item?.what).toMatch(/your name, your email address, the name you gave for the thank-you/)
    expect(item?.what).toContain('It is not linked to any account.')
    expect(item?.keep).toMatch(/^Until the owner deletes it\./)
    expect(item?.keep).toContain('hello@meetaleksi.com')
    expect(page).toContain('From people with no account: Reviewer sign-ups')
    for (const part of [
      item?.what,
      `Why: ${item?.why ?? ''}`,
      `Legal reason: ${item?.legal ?? ''}`,
      `How long: ${item?.keep ?? ''}`,
    ])
      expect(page).toContain(part)
  })

  it('[reviewers 7] says how long and how to ask for deletion, in "How long" and "Your rights"', () => {
    expect(REVIEWER_CONTACT).toBe('hello@meetaleksi.com')
    expect(HOW_LONG).toContain('Reviewer sign-ups are not linked to any account either.')
    expect(HOW_LONG).toContain(
      'kept until the owner deletes them, or sooner if you ask at hello@meetaleksi.com.',
    )
    expect(REVIEWER_RIGHTS).toBe(
      'If you signed up to help check the Finnish, write to hello@meetaleksi.com to see, correct or delete your sign-up.',
    )
    expect(page).toContain(REVIEWER_RIGHTS)
  })

  it('[reviewers 7] names the Turnstile check on the sign up form under Cloudflare', () => {
    const cloudflare = PROCESSORS.find((p) => p.name === 'Cloudflare')
    expect(cloudflare?.details?.join(' ')).toContain(
      'The reviewer sign-up form at meetaleksi.com/reviewers runs the same check before a sign-up is saved.',
    )
  })
})
