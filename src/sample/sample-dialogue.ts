// SAMPLE CONTENT, AWAITING THE NATIVE REVIEWER.
//
// These two lines are only for the design sample at /sample/hear-it (job
// 5-design-system, round 1). They are lines 1 and 2 of
// docs/risk-tests/test-2-voice-lines.md, which the native reviewer has not
// checked yet. They are not learning content: the real unit 1 dialogue comes
// from the content pipeline and reaches learners only after review (AGENTS.md,
// "Nothing unapproved is served"). The sample page is built only in
// development and in preview builds (src/main.tsx).

export const SAMPLE_REVIEW_STATUS = 'awaiting the native reviewer' as const

export interface Word {
  /** The word itself, without punctuation. */
  text: string
  /** Punctuation that follows the word, shown outside its highlight. */
  after?: string
  /** True for the words that change between spoken and written Finnish. */
  changes?: boolean
}

export interface DialogueLine {
  speaker: string
  spoken: Word[]
  written: Word[]
}

export const SAMPLE_DIALOGUE: DialogueLine[] = [
  {
    speaker: 'Alex',
    spoken: [
      { text: 'Moi', after: '!', changes: true },
      { text: 'Mä', changes: true },
      { text: 'oon', changes: true },
      { text: 'Alex', after: '.' },
    ],
    written: [
      { text: 'Hei', after: '!', changes: true },
      { text: 'Minä', changes: true },
      { text: 'olen', changes: true },
      { text: 'Alex', after: '.' },
    ],
  },
  {
    speaker: 'Sanna',
    spoken: [
      { text: 'Mist', changes: true },
      { text: 'sä', changes: true },
      { text: 'oot', changes: true },
      { text: 'kotoisin', after: '?' },
    ],
    written: [
      { text: 'Mistä', changes: true },
      { text: 'sinä', changes: true },
      { text: 'olet', changes: true },
      { text: 'kotoisin', after: '?' },
    ],
  },
]
