// When the road's drawn signs become number pins (the owner's choice of 2 November, "Number pins only",
// follow up 19-sign-overflow of job 19-redesign). Used by the road screen and by the road picture on the
// reference page.

/** The text size at which the drawn signs always become pins: 200 percent of the usual 16 px. */
export const PIN_TEXT_PX = 32

/** The text size of the page, in px. */
export function rootTextPx(): number {
  return parseFloat(getComputedStyle(document.documentElement).fontSize) || 16
}

/** True when a drawn sign's name takes more than one line. */
export function namesWrap(root: ParentNode | null | undefined): boolean {
  return [...(root?.querySelectorAll<HTMLElement>('[data-sign-name]') ?? [])].some((name) => {
    const line = parseFloat(getComputedStyle(name).lineHeight)
    return line > 0 && name.getBoundingClientRect().height > line * 1.5
  })
}
