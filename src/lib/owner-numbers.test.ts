import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import { OwnerPage } from '../screens/OwnerPage.tsx'
import {
  costText,
  countryName,
  dayText,
  isOwnerNumbers,
  medianText,
  retentionText,
  speakBackText,
} from './owner-numbers.ts'

// Labels [analytics N] are the "Done when" statement numbers from
// factory/jobs/14-analytics/spec.md that each test protects.
// How the owner page writes each number.

describe('the owner page numbers', () => {
  it('[analytics 17] day 7 retention is "x percent (a of b learners)"', () => {
    expect(retentionText({ retained: 1, cohort: 4, percent: 25 })).toBe('25 percent (1 of 4 learners)')
    expect(retentionText({ retained: 0, cohort: 0, percent: null })).toBe(
      'No learner has reached day 7 yet (0 of 0 learners)',
    )
  })

  it('[analytics 17] the median session is "m minutes, from n finished sessions"', () => {
    expect(medianText({ minutes: 10.5, used: 6, left_out: 2 })).toBe('10.5 minutes, from 6 finished sessions')
    expect(medianText({ minutes: 9, used: 1, left_out: 0 })).toBe('9 minutes, from 1 finished session')
    expect(medianText({ minutes: null, used: 0, left_out: 3 })).toBe('No finished sessions yet')
  })

  it('[analytics 17] speak back is "x percent (a of b)"', () => {
    expect(speakBackText({ count: 2, base: 5, percent: 40 })).toBe('40 percent (2 of 5)')
    expect(speakBackText({ count: 0, base: 0, percent: null })).toBe('No active learners yet (0 of 0)')
  })

  it('[analytics 17] the cost is "$t in total, $p per active learner", in US dollars as recorded', () => {
    expect(costText({ total: 0.005, per_active_learner: 0.001 })).toBe(
      '$0.005 in total, $0.001 per active learner',
    )
    expect(costText({ total: 1.5, per_active_learner: 0.75 })).toBe(
      '$1.50 in total, $0.75 per active learner',
    )
    expect(costText({ total: 0, per_active_learner: null })).toBe('$0.00 in total, none per active learner')
  })

  it('[analytics 17] countries have English names, XX is "Unknown" and T1 "Tor network", else the code', () => {
    expect(countryName('FI')).toBe('Finland')
    expect(countryName('SE')).toBe('Sweden')
    expect(countryName('XX')).toBe('Unknown')
    expect(countryName('T1')).toBe('Tor network')
    expect(countryName('not a code')).toBe('not a code')
  })

  it('[analytics 17] a day is written short, as the Helsinki date it is', () => {
    expect(dayText('2026-10-30')).toBe('Fri 30 Oct')
  })

  it('[analytics 17] the page checks the answer has every number before it draws', () => {
    expect(isOwnerNumbers({})).toBe(false)
    expect(isOwnerNumbers(null)).toBe(false)
  })

  it('[analytics 17] the page loads with no number drawn, and offers no chart, filter, date picker or export', () => {
    const html = renderToStaticMarkup(createElement(OwnerPage))
    expect(html).toContain('Owner page')
    expect(html).not.toMatch(/<canvas|<select|type="date"|Export|Download/i)
  })
})
