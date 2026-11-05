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

/**
 * The room a sign takes on the road: its board and, when it has one, its picture above it (fast route
 * road-stops), as one box. The road screen keeps these boxes apart, inside the screen and clear of the sun.
 */
export function signBox(item: Element): DOMRect | undefined {
  const board = item.querySelector('[data-sign-board]')?.getBoundingClientRect()
  if (!board) return undefined
  const picture = item.querySelector('[data-sign-picture]')?.getBoundingClientRect()
  if (!picture || picture.width === 0 || picture.height === 0) return board
  const left = Math.min(board.left, picture.left)
  const top = Math.min(board.top, picture.top)
  return new DOMRect(
    left,
    top,
    Math.max(board.right, picture.right) - left,
    Math.max(board.bottom, picture.bottom) - top,
  )
}

/** The boxes a sign takes on the road, each on its own: its board, and its picture when it has one. */
export function signParts(item: Element): DOMRect[] {
  return [item.querySelector('[data-sign-board]'), item.querySelector('[data-sign-picture]')]
    .map((part) => part?.getBoundingClientRect())
    .filter((box): box is DOMRect => box !== undefined && box.width > 0 && box.height > 0)
}
