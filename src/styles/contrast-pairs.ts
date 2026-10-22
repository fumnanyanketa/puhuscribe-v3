// Every text and background pairing whose contrast the app relies on, with
// its floor. design.md lists the same rows in its colour table; the unit test
// fails if the two lists differ (factory/jobs/5-design-system/spec.md, "Done
// when" 4). The reference page shows each result in light and dark.

export interface ContrastPair {
  /** The text, mark or edge colour token. */
  fore: string
  /** The colour token it sits on. */
  back: string
  /** The lowest contrast ratio allowed. */
  min: 7 | 4.5 | 3
  /** What the pairing is, in plain English. */
  use: string
}

export const CONTRAST_PAIRS: ContrastPair[] = [
  // Finnish lines and word card text: 7:1
  { fore: '--color-text', back: '--color-spoken-band', min: 7, use: 'a spoken Finnish line on its band' },
  { fore: '--color-text', back: '--color-surface', min: 7, use: 'Finnish on a card and in the word card' },
  { fore: '--color-text', back: '--color-word-hover', min: 7, use: 'a Finnish word under the finger' },
  { fore: '--color-flag-text', back: '--color-flag-wash', min: 7, use: 'a changed word on its wash' },
  { fore: '--color-current-word-text', back: '--color-current-word', min: 7, use: 'the word being spoken' },
  // All other text: 4.5:1
  {
    fore: '--color-text-quiet',
    back: '--color-surface',
    min: 4.5,
    use: 'the written line and quieter text on a card',
  },
  {
    fore: '--color-text-quiet',
    back: '--color-ground-top',
    min: 4.5,
    use: 'quieter text at the top of the page',
  },
  {
    fore: '--color-text-quiet',
    back: '--color-ground-middle',
    min: 4.5,
    use: 'quieter text in the middle of the page',
  },
  {
    fore: '--color-text-quiet',
    back: '--color-ground-bottom',
    min: 4.5,
    use: 'quieter text at the bottom of the page',
  },
  { fore: '--color-text', back: '--color-ground-top', min: 4.5, use: 'headings at the top of the page' },
  {
    fore: '--color-text',
    back: '--color-ground-bottom',
    min: 4.5,
    use: 'headings at the bottom of the page',
  },
  {
    fore: '--color-spoken-text',
    back: '--color-spoken-band',
    min: 4.5,
    use: 'the "Spoken" label on its band',
  },
  { fore: '--color-written', back: '--color-surface', min: 4.5, use: 'the "Written" label on a card' },
  { fore: '--color-button-text', back: '--color-button', min: 4.5, use: 'text on the black pill' },
  { fore: '--color-text', back: '--color-button-secondary', min: 4.5, use: 'text on the white pill' },
  { fore: '--color-text', back: '--color-gentle-wash', min: 4.5, use: 'a gentle correction' },
  { fore: '--color-problem-text', back: '--color-problem-wash', min: 4.5, use: 'a problem message' },
  // Focus, control edges, markers and the recording state: 3:1
  {
    fore: '--color-focus',
    back: '--color-ground-top',
    min: 3,
    use: 'the focus outline at the top of the page',
  },
  {
    fore: '--color-focus',
    back: '--color-ground-bottom',
    min: 3,
    use: 'the focus outline at the bottom of the page',
  },
  { fore: '--color-focus', back: '--color-surface', min: 3, use: 'the focus outline on a card or a bar' },
  { fore: '--color-focus', back: '--color-spoken-band', min: 3, use: 'the focus outline on the spoken band' },
  {
    fore: '--color-control-edge',
    back: '--color-surface',
    min: 3,
    use: 'the edge of a white control on a card',
  },
  {
    fore: '--color-control-edge',
    back: '--color-ground-bottom',
    min: 3,
    use: 'the edge of a white control on the page',
  },
  { fore: '--color-button', back: '--color-surface', min: 3, use: 'the play control on a card or a bar' },
  { fore: '--color-button', back: '--color-ground-bottom', min: 3, use: 'a black pill on the page' },
  {
    fore: '--color-current-line',
    back: '--color-surface',
    min: 3,
    use: 'the ring round the line that is playing',
  },
  { fore: '--color-recording', back: '--color-surface', min: 3, use: 'the record control while recording' },
  {
    fore: '--color-recording-text',
    back: '--color-recording',
    min: 3,
    use: 'the stop mark on the record control',
  },
  {
    fore: '--color-gentle-mark',
    back: '--color-gentle-wash',
    min: 3,
    use: 'the mark on a gentle correction',
  },
  {
    fore: '--color-problem-edge',
    back: '--color-problem-wash',
    min: 3,
    use: 'the edge of a problem message',
  },
]
