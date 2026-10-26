// The shapes a Finnish line and its word cards are built from
// (design.md, "Finnish line and word card").

export interface FormWithAudio {
  /** The form itself, in Finnish. */
  text: string
  /** The audio file of that form. */
  audio: string
}

export interface WordCardData {
  /** The word as it appears in the line. */
  word: string
  /** Its base form, as a dictionary lists it. */
  baseForm: string
  /** The name of the form, in English. */
  formName: string
  /** One line in English on why it looks like this. */
  why: string
  spoken: FormWithAudio
  written: FormWithAudio
}

export interface LineWord {
  /** The word, without punctuation. */
  text: string
  /** Punctuation before the first word of a line, shown outside its button. */
  before?: string
  /** Punctuation that follows the word, shown outside its button. */
  after?: string
  /** True for the words that change between spoken and written Finnish. */
  changes?: boolean
  /** True for the answer word after a review (job 9-daily-review): underlined, and named so in words. */
  marked?: boolean
  /** The word's card. A word without one (such as a name) is plain text, not a button. */
  card?: WordCardData
}
