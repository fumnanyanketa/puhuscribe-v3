import { createContext, useContext } from 'react'

// How a word card inside a session opens "Patterns you've seen"
// (factory/jobs/12-units-1-3/spec.md, "Done when" 9). Only a session provides
// it, so word cards anywhere else stay as they are.

/** Opens the panel at the group of this form name; focus returns to the button on close. */
export type OpenPatterns = (formName: string, button: HTMLButtonElement) => void

export const PatternsContext = createContext<OpenPatterns | null>(null)

export function useOpenPatterns(): OpenPatterns | null {
  return useContext(PatternsContext)
}
