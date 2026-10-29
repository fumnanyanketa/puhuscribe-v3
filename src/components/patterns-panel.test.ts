import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import { App } from '../App.tsx'
import type { PatternsAnswer } from '../lib/patterns-types.ts'
import type { ReadySession } from '../lib/session-types.ts'
import { SessionFlow } from '../screens/SessionFlow.tsx'
import { SESSION_STEPS } from '../screens/session-steps.ts'
import type { WordCardData } from './finnish.ts'
import {
  PATTERNS_ERROR,
  PATTERNS_INTRO,
  PATTERNS_TITLE,
  PatternsPanel,
  type PatternsState,
} from './PatternsPanel.tsx'
import { WordCard } from './WordCard.tsx'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/12-units-1-3/spec.md that each test protects.
// The "Patterns you've seen" button and panel, rendered to markup in Node.
// Opening, focus and closing in a real browser are in e2e/patterns.spec.ts.

const CARD: WordCardData = {
  word: 'kahvia',
  baseForm: 'kahvi',
  formName: 'partitive singular',
  why: 'Some coffee, an amount of it.',
  spoken: { text: 'kahvii', audio: '/audio/a.mp3' },
  written: { text: 'kahvia', audio: '/audio/b.mp3' },
}

const ANSWER: PatternsAnswer = {
  groups: [
    {
      formName: 'partitive singular',
      forms: [
        {
          lemma: 'kahvi',
          spoken: 'kahvii',
          written: 'kahvia',
          why: 'Some coffee, an amount of it.',
          line: {
            spoken: 'Saisinks kahvii?',
            written: 'Saisinko kahvia?',
            spokenAudio: '/audio/unit/1-puhe.mp3',
            writtenAudio: '/audio/unit/1-kirja.mp3',
          },
        },
      ],
    },
    {
      formName: 'present tense, 3rd person singular',
      forms: [
        {
          lemma: 'olla',
          spoken: 'on',
          written: 'on',
          why: 'Is, for one thing.',
          line: {
            spoken: 'Se on neljä euroo.',
            written: 'Se on neljä euroa.',
            spokenAudio: '/audio/unit/4-puhe.mp3',
            writtenAudio: '/audio/unit/4-kirja.mp3',
          },
        },
      ],
    },
  ],
}

function card(onPatterns?: (formName: string, button: HTMLButtonElement) => void): string {
  return renderToStaticMarkup(
    createElement(WordCard, { data: CARD, onClose: () => undefined, ...(onPatterns ? { onPatterns } : {}) }),
  )
}

function panel(state: PatternsState): string {
  return renderToStaticMarkup(
    createElement(PatternsPanel, {
      open: true,
      focusGroup: 'partitive singular',
      state,
      onClose: () => undefined,
      onRetry: () => undefined,
    }),
  )
}

/**
 * The visible text of some markup, without the elements marked lang="fi" and
 * without the stored "why" lines and form names. Form names come from the
 * form tag table and can hold a digit ("3rd person"); statement 13 lists them
 * among the panel's allowed text.
 */
function textOutside(markup: string, whys: readonly string[]): string {
  let html = markup
  // Remove every element marked lang="fi" (they hold no nested lang="fi").
  html = html.replace(/<(\w+)[^>]*lang="fi"[^>]*>[\s\S]*?<\/\1>/g, ' ')
  let text = html
    .replace(/<[^>]+>/g, ' ')
    .replace(/&#x27;/g, "'")
    .replace(/&amp;/g, '&')
  for (const why of whys) text = text.split(why).join(' ')
  return text.replace(/\s+/g, ' ').trim()
}

describe('the word card button', () => {
  it('[units 9] without the prop the card is unchanged: no button, no new text', () => {
    const plain = card()
    expect(plain).not.toContain('Patterns')
    expect(plain).not.toContain('aria-haspopup')
  })

  it('[units 9] with the prop the card shows the text button "Patterns you\'ve seen" under its facts', () => {
    const markup = card(() => undefined)
    const at = markup.indexOf('Patterns you&#x27;ve seen')
    expect(at).toBeGreaterThan(markup.indexOf('</dl>'))
    expect(at).toBeLessThan(markup.indexOf('Spoken'))
    expect(markup).toMatch(/<button[^>]*aria-haspopup="dialog"[^>]*>(<[^>]+>)*Patterns you&#x27;ve seen/)
  })
})

describe('one way in', () => {
  it('[units 9] the panel is not a step: the step list holds loop steps only', () => {
    const loop = ['Hear it', 'Understand it', 'Say it', 'Keep it', 'Use it']
    for (const step of SESSION_STEPS) expect(loop).toContain(step.name)
    expect(SESSION_STEPS.map((s) => s.name).join(' ')).not.toMatch(/pattern/i)
  })

  it('[units 9] the panel has no address of its own and no link on the front door', () => {
    const front = renderToStaticMarkup(createElement(App, { path: '/' }))
    expect(renderToStaticMarkup(createElement(App, { path: '/patterns' }))).toBe(front)
    expect(front).not.toMatch(/pattern/i)
  })

  it('[units 9] a session holds the closed panel, and nothing about patterns shows until a card asks', () => {
    const session: ReadySession = {
      state: 'ready',
      session: { id: '00000000-0000-4000-8000-000000000001', step: null },
      unit: { title: 'Unit', canDo: 'Can do.' },
      dialogue: { title: 'Dialogue' },
      lines: [
        {
          id: 1,
          speaker: 'A',
          gloss: 'Hi.',
          spokenAudio: '/audio/a.mp3',
          writtenAudio: '/audio/b.mp3',
          spoken: [{ text: 'Moi', after: '!' }],
          written: [{ text: 'Hei', after: '!' }],
        },
      ],
    }
    const markup = renderToStaticMarkup(
      createElement(SessionFlow, {
        steps: SESSION_STEPS,
        session,
        position: { kind: 'step', index: 0 },
        onStepDone: () => Promise.resolve(true),
      }),
    )
    expect(markup).toContain('data-testid="patterns-panel"')
    expect(markup).not.toContain(PATTERNS_TITLE.replace("'", '&#x27;'))
  })
})

describe('the panel', () => {
  it('[units 10] shows the title, the intro line, each group by form name, both shapes labelled and marked Finnish', () => {
    const markup = panel({ kind: 'ready', answer: ANSWER })
    expect(markup).toContain(PATTERNS_TITLE.replace("'", '&#x27;'))
    expect(markup).toContain(PATTERNS_INTRO)
    expect(markup.indexOf('partitive singular')).toBeLessThan(
      markup.indexOf('present tense, 3rd person singular'),
    )
    expect(markup).toContain('<p class="_labelSpoken')
    expect(markup).toMatch(/lang="fi"[^>]*>kahvii</)
    expect(markup).toMatch(/lang="fi"[^>]*>kahvia</)
    expect(markup).toMatch(/lang="fi"[^>]*>Saisinks kahvii\?</)
    expect(markup).toMatch(/lang="fi"[^>]*>Saisinko kahvia\?</)
    expect(markup).toMatch(/<dd lang="fi">kahvi<\/dd>/)
    expect(markup).toContain('Some coffee, an amount of it.')
    expect(markup).toContain('aria-label="Play the spoken line"')
    expect(markup).toContain('aria-label="Play the written line"')
  })

  it('[units 13] has no counts, scores, progress, dates or practice: no digit outside the Finnish and the why lines', () => {
    const markup = panel({ kind: 'ready', answer: ANSWER })
    const stored = [
      'Some coffee, an amount of it.',
      'Is, for one thing.',
      ...ANSWER.groups.map((g) => g.formName),
    ]
    const text = textOutside(markup, stored)
    expect(text).toContain('Base form')
    expect(text).not.toMatch(/\d/)
    expect(text).not.toMatch(/learned|due|score|streak|progress|practice|quiz|record/i)
    expect(markup).not.toMatch(/<(progress|meter|input|textarea)\b/)
  })

  it('[units 14] a failed load says "Could not load your patterns." with "Try again"', () => {
    const markup = panel({ kind: 'error' })
    expect(markup).toContain(PATTERNS_ERROR)
    expect(markup).toContain('Try again')
    expect(markup).not.toContain('Spoken')
  })
})
