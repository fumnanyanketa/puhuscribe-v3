import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import { App } from '../App.tsx'
import { forwardFor, PATHS } from '../lib/app-paths.ts'
import { HOW_LONG, NO_ACCOUNT_ITEMS } from '../privacy/data-inventory.ts'
import { PROCESSORS } from '../privacy/processors.ts'
import {
  EMAIL_NOT_SET,
  EMAIL_REFUSED,
  linkText,
  nextBatch,
  ReviewAnswersList,
  reviewLinksOf,
  sendProblemOf,
  SignupLinks,
  type ReviewAnswerRow,
  type ReviewLinkRow,
} from './OwnerReviewLinks.tsx'
import { SignupList } from './OwnerReviewers.tsx'
import { PrivacyPage } from './PrivacyPage.tsx'
import {
  asSessionLine,
  BROKEN_TITLE,
  BrokenLink,
  dialogueOf,
  LineAnswer,
  NOT_SAVED_GONE,
  NOT_SAVED_LIMIT,
  NOT_SAVED_OFFLINE,
  NOTE_TOO_LONG,
  overviewOf,
  plainWords,
  saveProblemOf,
  type ReviewLine,
} from './ReviewLinkPage.tsx'

// Labels [review-links N] are the "Done when" statement numbers from
// factory/jobs/review-links/spec.md that each test protects.
// The review pages and the owner page's review links, drawn without a browser.

const TOKEN = 'a'.repeat(43)

function text(html: string): string {
  return html
    .replace(/<[^>]+>/g, ' ')
    .replace(/&#x27;/g, "'")
    .replace(/&quot;/g, '"')
    .replace(/&amp;/g, '&')
    .replace(/\s+/g, ' ')
    .trim()
}

const LINE: ReviewLine = {
  id: 101,
  position: 1,
  speaker: 'Pekka',
  spoken: 'Moi! Mä oon Pekka.',
  written: 'Hei! Minä olen Pekka.',
  english: "Hi! I'm Pekka.",
  spokenAudio: '/audio/x/1-puhe.mp3',
  writtenAudio: '/audio/x/1-kirja.mp3',
  answer: null,
  note: null,
}

describe('the review page addresses', () => {
  it('[review-links 2] the app shell stays on a /review/ page, and the bare /review goes to the landing page', () => {
    expect(forwardFor(`/review/${TOKEN}`, '', '')).toBeNull()
    expect(forwardFor(`/review/${TOKEN}/11`, '', '')).toBeNull()
    expect(forwardFor('/review', '', '')).toBe(PATHS.landing)
  })

  it('[review-links 2] a malformed link draws only "This link does not work", with no request', () => {
    for (const path of ['/review/short', `/review/${TOKEN}/0`, `/review/${TOKEN}/1/2`]) {
      const page = text(renderToStaticMarkup(createElement(App, { path })))
      expect(page, path).toBe(BROKEN_TITLE)
    }
    expect(text(renderToStaticMarkup(createElement(BrokenLink)))).toBe('This link does not work')
  })

  it('[review-links 2] a good looking link starts by loading, never showing a reviewer before the Worker answers', () => {
    const page = text(renderToStaticMarkup(createElement(App, { path: `/review/${TOKEN}` })))
    expect(page).toContain('Loading the review.')
  })
})

describe('reading what the Worker sends', () => {
  it('[review-links 3] reads only a well formed list and dialogue', () => {
    const overview = {
      batch: 2,
      dialogues: [{ id: 1, position: 1, title: 'T', stop: 'S', lines: 6, answered: 2 }],
    }
    expect(overviewOf(overview)).toEqual(overview)
    expect(overviewOf({ batch: 2, dialogues: [{ id: 1 }] })).toBeNull()
    expect(overviewOf(null)).toBeNull()
    const dialogue = {
      id: 1,
      position: 1,
      of: 27,
      title: 'T',
      stop: 'S',
      previous: null,
      next: 2,
      lines: [LINE],
    }
    expect(dialogueOf(dialogue)).toEqual(dialogue)
    expect(dialogueOf({ ...dialogue, lines: [{ ...LINE, answer: 'maybe' }] })).toBeNull()
  })

  it('[review-links 3] each line keeps its spoken and written words with punctuation outside, as the session draws them', () => {
    expect(plainWords('Moi! Mä oon Pekka.')).toEqual([
      { text: 'Moi', after: '!' },
      { text: 'Mä' },
      { text: 'oon' },
      { text: 'Pekka', after: '.' },
    ])
    expect(plainWords('"Joo," se sanoo – okei?')).toEqual([
      { text: 'Joo', before: '"', after: ',"' },
      { text: 'se' },
      { text: 'sanoo', after: ' –' },
      { text: 'okei', after: '?' },
    ])
    const line = asSessionLine(LINE)
    expect(line.gloss).toBe("Hi! I'm Pekka.")
    expect(line.spokenAudio).toBe('/audio/x/1-puhe.mp3')
    expect(line.writtenAudio).toBe('/audio/x/1-kirja.mp3')
  })
})

describe('one line and its answers', () => {
  const draw = (line: ReviewLine) =>
    renderToStaticMarkup(
      createElement(LineAnswer, { line, count: 1, save: () => Promise.resolve({ status: 200, body: {} }) }),
    )

  it("[review-links 3] [review-links 4] shows the three answers, in the owner's words, none chosen yet", () => {
    const html = draw(LINE)
    expect(text(html)).toBe('Correct Needs a fix Not sure')
    expect(html.match(/aria-pressed="false"/g)).toHaveLength(3)
    expect(html).toContain('aria-label="Your answer for line 1"')
  })

  it('[review-links 4] a saved "Needs a fix" comes back chosen, with its note in the box and the count', () => {
    const html = draw({ ...LINE, answer: 'needs_fix', note: 'Use "sä".' })
    expect(html.match(/aria-pressed="true"/g)).toHaveLength(1)
    expect(text(html)).toContain('What should change?')
    expect(html).toContain('Use &quot;sä&quot;.</textarea>')
    expect(text(html)).toContain('9 of 500 characters')
    expect(text(html)).toContain('Save the note')
  })

  it('[review-links 4] "Correct" and "Not sure" open no note box', () => {
    for (const answer of ['correct', 'not_sure'] as const)
      expect(draw({ ...LINE, answer })).not.toContain('<textarea')
  })

  it('[review-links 4] [review-links 9] a failed save says what happened', () => {
    expect(saveProblemOf(null)).toBe(NOT_SAVED_OFFLINE)
    expect(saveProblemOf({ status: 429, body: { error: 'limit' } })).toBe(NOT_SAVED_LIMIT)
    expect(saveProblemOf({ status: 404, body: {} })).toBe(NOT_SAVED_GONE)
    expect(saveProblemOf({ status: 400, body: { field: 'note' } })).toBe(NOTE_TOO_LONG)
  })
})

describe('the owner page review links', () => {
  const LINK: ReviewLinkRow = {
    id: 'l1',
    signup_id: 's1',
    batch: 2,
    sent_at: '2026-11-24T10:00:00+00:00',
    lines: 210,
    answered: 40,
  }
  const ANSWER: ReviewAnswerRow = {
    link_id: 'l1',
    line_id: 101,
    answer: 'needs_fix',
    note: '<b>Use sä</b>',
    answered_at: '2026-11-24T11:00:00+00:00',
    name: 'Aino',
    dialogue: 'A new colleague',
    position: 2,
    speaker: 'Maria',
    spoken: 'Mä oon Maria.',
    written: 'Minä olen Maria.',
    english: "I'm Maria.",
  }

  it('[review-links 1] [review-links 6] each sign up shows its links, their progress and "Send review link" with batches 1 to 4', () => {
    const html = renderToStaticMarkup(
      createElement(SignupLinks, {
        signupId: 's1',
        name: 'Aino',
        links: [LINK],
        onSend: () => Promise.resolve({ text: '', tone: 'neutral' as const }),
      }),
    )
    const page = text(html)
    expect(page).toContain('Batch 2 sent on 24 Nov 2026, 12:00. 40 of 210 lines answered.')
    expect(page).toContain('Send review link')
    expect(html).toContain('aria-label="Send review link to Aino"')
    expect([...html.matchAll(/<option value="(\d)"/g)].map((m) => m[1])).toEqual(['1', '2', '3', '4'])
    expect(html).toMatch(/<option value="1" selected=""/)
    expect(linkText(LINK)).toBe('Batch 2 sent on 24 Nov 2026, 12:00. 40 of 210 lines answered.')
  })

  it('[review-links 1] offers the next batch not yet sent first', () => {
    expect(nextBatch([])).toBe(1)
    expect(
      nextBatch([
        { ...LINK, batch: 1 },
        { ...LINK, batch: 2 },
      ]),
    ).toBe(3)
    expect(nextBatch([1, 2, 3, 4].map((batch) => ({ ...LINK, batch })))).toBe(1)
  })

  it('[review-links 1] the sign up list draws the send control only once the links are loaded', () => {
    const row = { id: 's1', name: 'Aino', email: 'a@example.fi', thanks_name: null, created_at: LINK.sent_at }
    const without = renderToStaticMarkup(
      createElement(SignupList, { rows: [row], onDelete: () => Promise.resolve(null) }),
    )
    expect(without).not.toContain('Send review link')
    const withLinks = renderToStaticMarkup(
      createElement(SignupList, {
        rows: [row],
        onDelete: () => Promise.resolve(null),
        links: [LINK, { ...LINK, id: 'l2', signup_id: 'other' }],
        onSend: () => Promise.resolve({ text: '', tone: 'neutral' as const }),
      }),
    )
    expect(text(withLinks)).toContain('Send review link')
    expect(withLinks.match(/Batch 2 sent/g)).toHaveLength(1)
  })

  it('[review-links 1] without the Brevo settings the owner page says no link can be sent', () => {
    expect(sendProblemOf({ status: 503, body: { error: 'email_not_set' } })).toBe(EMAIL_NOT_SET)
    expect(sendProblemOf({ status: 502, body: { error: 'not_sent' } })).toBe(EMAIL_REFUSED)
    expect(EMAIL_NOT_SET).toContain('BREVO_API_KEY')
    expect(reviewLinksOf({ links: [], answers: [] })?.emailReady).toBe(false)
    expect(reviewLinksOf({ links: [], answers: [], emailReady: true })?.emailReady).toBe(true)
  })

  it('[review-links 6] "Review answers" shows the answer, the reviewer, the dialogue, the line and the note, as plain text', () => {
    const html = renderToStaticMarkup(createElement(ReviewAnswersList, { answers: [ANSWER] }))
    const page = text(html)
    for (const words of [
      'Needs a fix, from Aino',
      'A new colleague, line 2, Maria. Answered on 24 Nov 2026, 13:00.',
      'Mä oon Maria.',
      'Minä olen Maria.',
      "I'm Maria.",
      'Note: &lt;b&gt;Use sä&lt;/b&gt;',
    ])
      expect(page).toContain(words)
    expect(html).not.toContain('<b>')
    expect(text(renderToStaticMarkup(createElement(ReviewAnswersList, { answers: [] })))).toBe(
      'No answers to look at yet.',
    )
  })

  it('[review-links 6] reads only well formed links and answers', () => {
    expect(reviewLinksOf({ links: [LINK], answers: [ANSWER], emailReady: true })).toEqual({
      links: [LINK],
      answers: [ANSWER],
      emailReady: true,
    })
    expect(reviewLinksOf({ links: [{ id: 'x' }], answers: [] })).toBeNull()
    expect(reviewLinksOf({ links: [], answers: [{ ...ANSWER, answer: 'correct!' }] })).toBeNull()
  })
})

describe('the privacy notice and the review answers', () => {
  const page = text(renderToStaticMarkup(createElement(PrivacyPage)))

  it('[review-links 8] the inventory adds the review answers, kept until the owner deletes the sign-up', () => {
    const item = NO_ACCOUNT_ITEMS.find((i) => i.name === 'Review answers')
    expect(item).toBeDefined()
    expect(item?.what).toMatch(/your answer \(Correct, Needs a fix or Not sure\), the note you write/)
    expect(item?.keep).toMatch(/^Until the owner deletes the sign-up/)
    expect(item?.keep).toContain('hello@meetaleksi.com')
    for (const part of [
      item?.what,
      `Why: ${item?.why ?? ''}`,
      `Legal reason: ${item?.legal ?? ''}`,
      `How long: ${item?.keep ?? ''}`,
    ])
      expect(page).toContain(part)
    expect(HOW_LONG).toContain('Review answers are kept with the sign-up they belong to and deleted with it.')
  })

  it('[review-links 8] Brevo is named as sending the review link email, with what it receives', () => {
    const brevo = PROCESSORS.find((p) => p.name === 'Brevo')
    expect(brevo?.role).toContain('it also sends you the email with your review link')
    expect(page).toContain(brevo?.role ?? 'missing')
  })
})
