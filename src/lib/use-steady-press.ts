import { useRef, type PointerEvent } from 'react'

// A fast double tap on "Next line" used to move two lines, so a line could be
// skipped without being read (job 19-redesign, round 4, evaluator). A press is
// ignored when it is the second click of a double click, or a finger tap that
// follows another tap within STEADY_MS. A press after a pause counts, and so
// does every press made by a mouse one at a time.

export const STEADY_MS = 450

export function useSteadyPress() {
  const lastTap = useRef(0)
  const finger = useRef(false)
  return {
    /** Put on the button: remembers whether the press is a finger. */
    onPointerDown: (event: PointerEvent) => {
      finger.current = event.pointerType === 'touch'
    },
    /** Call first in the click handler. False means ignore this press. */
    accept: (event?: { detail: number }): boolean => {
      if (event && event.detail > 1) return false
      const now = Date.now()
      if (finger.current && now - lastTap.current < STEADY_MS) return false
      lastTap.current = now
      return true
    },
  }
}
