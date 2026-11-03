// The words of the first-open questions and the recap card (fast route
// "intro", owner's plan of 3 November 2026). English, plain, one short line
// each. The questions and their answers are the owner's own words.

export const REASON_QUESTION = 'Why are you learning Finnish?'
export const TIME_QUESTION = 'When will you practise?'

/** The visible words beside the recap card's play button. */
export const FIRST_LINE_CAPTION = 'Your first line'
/** What the play button plays, for its screen reader name ("Play your first line"). */
export const FIRST_LINE_WHAT = 'your first line'

/** The stop's "I can" line, from the road's can do text ("say who I am" becomes "I can say who I am."). */
export function canDoSentence(canDo: string): string {
  const text = canDo.trim()
  return /[.!?]$/.test(text) ? `I can ${text}` : `I can ${text}.`
}
