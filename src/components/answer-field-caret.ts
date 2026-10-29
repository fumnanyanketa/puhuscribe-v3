// After the "Type ä" and "Type ö" buttons change the field's text, focus goes
// back to the field and the caret goes just after the new letter. This runs in
// a timeout because the field is a controlled input: React writes the new text
// into it after the click, and that write moves the caret to the end.
//
// If the learner has already typed another letter by the time the timeout
// fires, the field no longer holds the text the button made. The caret is then
// left where the learner's typing put it, so fast typing after a tap on ä is
// not scrambled.

/** The part of an input element this needs, so a test can stand in for it. */
export interface CaretField {
  value: string
  focus: () => void
  setSelectionRange: (start: number, end: number) => void
}

export function restoreCaretAfterLetter(field: CaretField, next: string, cursor: number): void {
  setTimeout(() => {
    field.focus()
    if (field.value === next) field.setSelectionRange(cursor, cursor)
  }, 0)
}
