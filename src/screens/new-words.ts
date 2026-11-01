import { isRecord } from '../lib/api.ts'
import type { WordCardData } from '../components/finnish.ts'
import type { NewWord } from '../lib/session-types.ts'

// The new words of a finished lesson (job 19-redesign, statement 33): the
// answer of POST /api/sessions/<id>/complete lists the words the lesson added
// to the learner's review. Every field is checked before it is used, and an
// audio address must be a path under /audio/ on this app's own address, so a
// wrong answer can never make the page load a file from anywhere else.

const MAX_NEW_WORDS = 24
const MAX_TEXT = 120
const AUDIO_PATH = /^\/audio\/[A-Za-z0-9][A-Za-z0-9._%/-]*$/

function text(value: unknown): string | null {
  return typeof value === 'string' && value.length > 0 && value.length <= MAX_TEXT ? value : null
}

function optionalText(value: unknown): string | undefined | null {
  if (value === undefined) return undefined
  return text(value)
}

function audio(value: unknown): string | null {
  return typeof value === 'string' && AUDIO_PATH.test(value) && !value.includes('..') ? value : null
}

function newWord(value: unknown): NewWord | null {
  if (!isRecord(value) || !isRecord(value.form)) return null
  const lemma = text(value.form.lemma)
  const formName = text(value.form.formName)
  const why = text(value.form.why)
  const spoken = text(value.form.spoken)
  const written = text(value.form.written)
  const meaning = optionalText(value.form.meaning)
  const baseMeaning = optionalText(value.form.baseMeaning)
  const spokenAudio = audio(value.spokenAudio)
  const writtenAudio = audio(value.writtenAudio)
  if (!lemma || !formName || !why || !spoken || !written || !spokenAudio || !writtenAudio) return null
  if (meaning === null || baseMeaning === null) return null
  return {
    form: {
      lemma,
      formName,
      why,
      spoken,
      written,
      ...(meaning ? { meaning } : {}),
      ...(baseMeaning ? { baseMeaning } : {}),
    },
    spokenAudio,
    writtenAudio,
  }
}

/** The new words of a complete answer, or an empty list when there are none or the answer is odd. */
export function newWordsFrom(body: unknown): NewWord[] {
  if (!isRecord(body) || !Array.isArray(body.newWords) || body.newWords.length > MAX_NEW_WORDS) return []
  const words: NewWord[] = []
  for (const item of body.newWords as unknown[]) {
    const word = newWord(item)
    if (!word) return []
    words.push(word)
  }
  return words
}

/** "1 new word" or "11 new words": the count is the number of chips, never more. */
export function newWordsHeading(count: number): string {
  return `${String(count)} new ${count === 1 ? 'word' : 'words'}`
}

/** What a chip's word card shows: the word as the learner met it, in both registers. */
export function cardOf(word: NewWord): WordCardData {
  return {
    word: word.form.spoken,
    baseForm: word.form.lemma,
    formName: word.form.formName,
    why: word.form.why,
    ...(word.form.meaning ? { meaning: word.form.meaning } : {}),
    ...(word.form.baseMeaning ? { baseMeaning: word.form.baseMeaning } : {}),
    spoken: { text: word.form.spoken, audio: word.spokenAudio },
    written: { text: word.form.written, audio: word.writtenAudio },
  }
}
