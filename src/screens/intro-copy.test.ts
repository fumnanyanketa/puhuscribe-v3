import { describe, expect, it } from 'vitest'
import { canDoSentence } from './intro-copy.ts'

describe('the recap card words', () => {
  it('[intro 2] the "I can" line reads as one sentence from the road data', () => {
    // As the road's rows hold it (supabase/migrations/20261101120100_load_road_stops.sql).
    expect(canDoSentence("say who I am and where I'm from, and ask the same.")).toBe(
      "I can say who I am and where I'm from, and ask the same.",
    )
    expect(canDoSentence('order something, ask the price, and say thanks')).toBe(
      'I can order something, ask the price, and say thanks.',
    )
    // A text that already starts with "I can" is not doubled.
    expect(canDoSentence('I can ask where something is.')).toBe('I can ask where something is.')
    expect(canDoSentence('  I can say thanks  ')).toBe('I can say thanks.')
  })
})
