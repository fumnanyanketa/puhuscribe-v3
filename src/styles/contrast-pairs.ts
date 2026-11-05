// Every text and background pairing whose contrast the app relies on, with
// its floor. design.md lists the same rows in its colour table; the unit test
// fails if the two lists differ (job 5-design-system, "Done when" 4, and job
// 19-redesign, statement 6). The reference page shows each result. The look is
// light only (owner's call 4), so each pairing is checked once.

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
  { fore: '--color-text', back: '--color-panel', min: 7, use: 'a spoken Finnish line on the line card' },
  { fore: '--color-text', back: '--color-surface', min: 7, use: 'Finnish in a sheet and in the word card' },
  { fore: '--color-text', back: '--color-spoken-soft', min: 7, use: 'the spoken word on its tile' },
  { fore: '--color-text', back: '--color-word-hover', min: 7, use: 'a Finnish word under the finger' },
  {
    fore: '--color-written',
    back: '--color-panel',
    min: 7,
    use: 'the written Finnish line on the line card',
  },
  { fore: '--color-written', back: '--color-surface', min: 7, use: 'written Finnish in a sheet' },
  { fore: '--color-written', back: '--color-written-soft', min: 7, use: 'the written word on its tile' },
  { fore: '--color-changed-text', back: '--color-changed-wash', min: 7, use: 'a changed word on its wash' },
  { fore: '--color-current-word-text', back: '--color-current-word', min: 7, use: 'the word being spoken' },
  // All other text: 4.5:1
  { fore: '--color-text-quiet', back: '--color-surface', min: 4.5, use: 'quieter text in a sheet' },
  { fore: '--color-text-quiet', back: '--color-panel', min: 4.5, use: 'quieter text on a panel' },
  {
    fore: '--color-text-quiet',
    back: '--color-wash-top',
    min: 4.5,
    use: 'quieter text on the mint end of the wash',
  },
  {
    fore: '--color-text-quiet',
    back: '--color-wash-middle',
    min: 4.5,
    use: 'quieter text in the middle of the wash',
  },
  {
    fore: '--color-text-quiet',
    back: '--color-wash-bottom',
    min: 4.5,
    use: 'quieter text on the peach end of the wash',
  },
  {
    fore: '--color-text-quiet',
    back: '--color-spoken-soft',
    min: 4.5,
    use: 'quieter text on a soft mint fill',
  },
  {
    fore: '--color-text-quiet',
    back: '--color-written-soft',
    min: 4.5,
    use: 'quieter text on the slate tile',
  },
  { fore: '--color-text', back: '--color-wash-top', min: 4.5, use: 'headings on the mint end of the wash' },
  {
    fore: '--color-text',
    back: '--color-wash-bottom',
    min: 4.5,
    use: 'headings on the peach end of the wash',
  },
  {
    fore: '--color-spoken-text',
    back: '--color-spoken-soft',
    min: 4.5,
    use: 'the "People say" label on its tile',
  },
  {
    fore: '--color-mint-deep',
    back: '--color-surface',
    min: 4.5,
    use: 'the "How it works" link and a sign number',
  },
  {
    fore: '--color-button-text',
    back: '--color-sign-board',
    min: 4.5,
    use: 'the white name on an upcoming road sign',
  },
  { fore: '--color-mint-deep', back: '--color-panel', min: 4.5, use: 'mint text on a panel' },
  { fore: '--color-mint-deep', back: '--color-mint-soft', min: 4.5, use: 'mint text on a soft mint fill' },
  { fore: '--color-peach-deep', back: '--color-surface', min: 4.5, use: 'the name on the next sign' },
  { fore: '--color-peach-deep', back: '--color-panel', min: 4.5, use: 'the next stop name on the card' },
  {
    fore: '--color-danger-ink',
    back: '--color-wash-bottom',
    min: 4.5,
    use: 'the "Delete my account" link on the peach end of the wash',
  },
  {
    fore: '--color-danger-ink',
    back: '--color-wash-middle',
    min: 4.5,
    use: 'the "Delete my account" link in the middle of the wash',
  },
  { fore: '--color-button-text', back: '--color-button', min: 4.5, use: 'text on the mint pill' },
  { fore: '--color-mint-deep', back: '--color-button-secondary', min: 4.5, use: 'text on the white pill' },
  { fore: '--color-danger-text', back: '--color-danger', min: 4.5, use: 'text on the delete pill' },
  { fore: '--color-text', back: '--color-gentle-wash', min: 4.5, use: 'a gentle note' },
  {
    fore: '--color-peach-text',
    back: '--color-gentle-wash',
    min: 4.5,
    use: 'the words of a gentle note, peach as drawn',
  },
  {
    fore: '--color-peach-text',
    back: '--color-peach-soft',
    min: 4.5,
    use: 'the review count and the guest note on the account page',
  },
  { fore: '--color-text-quiet', back: '--color-sign-num', min: 4.5, use: 'the "+6" chip of the new words' },
  { fore: '--color-problem-text', back: '--color-problem-wash', min: 4.5, use: 'a problem message' },
  // Focus, control edges, markers and the recording state: 3:1
  {
    fore: '--color-focus',
    back: '--color-wash-top',
    min: 3,
    use: 'the focus outline on the mint end of the wash',
  },
  {
    fore: '--color-focus',
    back: '--color-wash-middle',
    min: 3,
    use: 'the focus outline in the middle of the wash',
  },
  {
    fore: '--color-focus',
    back: '--color-wash-bottom',
    min: 3,
    use: 'the focus outline on the peach end of the wash',
  },
  {
    fore: '--color-focus',
    back: '--color-surface',
    min: 3,
    use: 'the focus outline in a sheet or on a card',
  },
  { fore: '--color-focus', back: '--color-panel', min: 3, use: 'the focus outline on a panel' },
  {
    fore: '--color-control-edge',
    back: '--color-surface',
    min: 3,
    use: 'the edge of a white control in a sheet',
  },
  {
    fore: '--color-control-edge',
    back: '--color-panel',
    min: 3,
    use: 'the edge of a white control on a panel',
  },
  {
    fore: '--color-control-edge',
    back: '--color-wash-top',
    min: 3,
    use: 'the edge of a white control on the mint end of the wash',
  },
  {
    fore: '--color-control-edge',
    back: '--color-wash-bottom',
    min: 3,
    use: 'the edge of a white control on the peach end of the wash',
  },
  {
    fore: '--color-mint',
    back: '--color-progress-track',
    min: 3,
    use: 'the filled part of a progress bar beside the pale part not reached',
  },
  {
    fore: '--color-mint',
    back: '--color-mint-soft',
    min: 3,
    use: 'a lesson done beside a lesson not done on the road card',
  },
  { fore: '--color-button', back: '--color-surface', min: 3, use: 'the play control in a sheet' },
  {
    fore: '--color-button',
    back: '--color-panel',
    min: 3,
    use: 'the play control and the mint pill on a panel',
  },
  {
    fore: '--color-button',
    back: '--color-wash-top',
    min: 3,
    use: 'the mint pill on the mint end of the wash',
  },
  {
    fore: '--color-current-line',
    back: '--color-panel',
    min: 3,
    use: 'the ring round the line that is playing',
  },
  { fore: '--color-peach', back: '--color-surface', min: 3, use: 'the ring round the next sign' },
  { fore: '--color-recording', back: '--color-panel', min: 3, use: 'the record control while recording' },
  {
    fore: '--color-recording-text',
    back: '--color-recording',
    min: 3,
    use: 'the wave and stop mark on the record control',
  },
  { fore: '--color-switch-off', back: '--color-surface', min: 3, use: 'a switch that is off' },
  { fore: '--color-gentle-mark', back: '--color-gentle-wash', min: 3, use: 'the mark on a gentle note' },
  {
    fore: '--color-problem-edge',
    back: '--color-problem-wash',
    min: 3,
    use: 'the edge of a problem message',
  },
]
