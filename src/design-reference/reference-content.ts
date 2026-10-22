// SAMPLE CONTENT FOR THE REFERENCE PAGE, NOT REVIEWED.
//
// Spec statement 16 (factory/jobs/5-design-system/spec.md) limits the
// reference page's Finnish to the PRD's own unit 1 example (mä oon / minä
// olen) and a type sample of letters and long words, each marked "Sample, not
// reviewed" on the page. The audio is a generated tone, never speech. This
// page is built only in development and preview builds (src/main.tsx).

import type { LineWord, WordCardData } from '../components/finnish.ts'
import { toneUrl } from './tone.ts'

export const TONE = toneUrl()
export const SECOND_TONE = toneUrl(0.6, 523)
/** A source no browser can play, to show "Could not play". */
export const BROKEN_AUDIO = 'data:audio/wav;base64,AAAA'

function card(
  word: string,
  baseForm: string,
  formName: string,
  why: string,
  spoken: string,
  written: string,
): WordCardData {
  return {
    word,
    baseForm,
    formName,
    why,
    spoken: { text: spoken, audio: TONE },
    written: { text: written, audio: SECOND_TONE },
  }
}

const MINA = card('mä', 'minä', 'Personal pronoun, "I"', 'Spoken Finnish shortens minä to mä.', 'mä', 'minä')
const OLEN = card(
  'oon',
  'olla',
  'olla ("to be"), "I" form, present',
  'Spoken Finnish shortens olen to oon.',
  'oon',
  'olen',
)

export const SPOKEN_EXAMPLE: LineWord[] = [
  { text: 'Mä', changes: true, card: { ...MINA, word: 'Mä' } },
  { text: 'oon', changes: true, card: OLEN },
]

export const WRITTEN_EXAMPLE: LineWord[] = [
  { text: 'Minä', changes: true, card: { ...MINA, word: 'Minä' } },
  { text: 'olen', changes: true, card: { ...OLEN, word: 'olen' } },
]

export const TYPE_SAMPLE_LETTERS = 'ä ö å Ä Ö Å'
export const TYPE_SAMPLE_WORDS = ['maahanmuuttovirasto', 'kotoutumiskoulutus', 'työttömyysturvailmoitus']
