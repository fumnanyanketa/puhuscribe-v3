// What each stop teaches, said to the learner (fast route road-stops, owner approved 5 November 2026). The
// road's "I can" lines are in the first person ("say who I am and where I'm from, and ask the same."). The
// stop screen has Aleksi say "Here you’ll learn to ..." with these second person lines instead. They follow
// the published stops of supabase/migrations/20261101120100_load_road_stops.sql, kept short, English only.
// src/road/stop-can-do.test.ts checks that every published stop has one.

export const STOP_CAN_DO_YOU: Readonly<Record<number, string>> = {
  1: 'say who you are and where you’re from, and ask the same',
  2: 'order something, ask the price, and say thanks',
  3: 'ask where something is and follow simple directions',
  4: 'ask what something costs and pay by card or cash',
  5: 'ask which bus or tram goes where and buy a ticket',
  6: 'talk about the weather and say what you did',
  7: 'say you don’t understand and ask someone to repeat or slow down',
  8: 'suggest a time, accept, and say no politely',
  9: 'tell the time and book an appointment',
  10: 'say what is wrong and ask for something for it',
  11: 'say where you live and talk with your neighbours',
  12: 'ask for a size and colour and try something on',
  13: 'book a visit and describe where it hurts',
  14: 'start and end a phone call and leave a message',
  15: 'ask about a form and say what you need',
  16: 'pick up a parcel and spell your name',
  17: 'read a lunch menu and order politely',
  18: 'report that something is broken',
  19: 'introduce yourself at work and ask where things are',
  20: 'say who is in your family',
  21: 'talk with the daycare and school about your children',
  22: 'say what you like doing',
  23: 'make a shopping list and follow a simple recipe',
  24: 'say how you feel and ask how someone is',
  25: 'join a coffee break and accept a sauna invitation',
  26: 'talk about Midsummer and Christmas and give dates',
  27: 'talk about the seasons and the weather over a year',
  28: 'get a library card and borrow a book',
  29: 'plan a walk in the forest and talk about berries',
  30: 'accept an invitation and thank the host',
  31: 'ask the way and follow left, right and straight on',
  32: 'return something and explain what is wrong',
  33: 'say where you lived and worked before',
  34: 'talk about tomorrow, next week and next year',
  35: 'say what you do and what you can do',
  36: 'tell someone about your day and your life here',
}

/** Aleksi's second line on the stop screen, or undefined for a stop without a line. */
export function learnLine(stop: number): string | undefined {
  const line = STOP_CAN_DO_YOU[stop]
  return line ? `Here you’ll learn to ${line}.` : undefined
}
