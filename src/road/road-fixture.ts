import type { RoadStop } from '../lib/road-types.ts'

// A FIXTURE FOR TESTS AND /design-reference ONLY (job 19-redesign, statement
// 19). It stands in for the stops job 20-a1-road provides until that job is
// merged, and it is never imported by code a learner runs: a normal build
// holds none of it (tests/design-build.test.ts looks for the marker below).
// The names and "I can" sentences are English text from docs/curriculum-a1.md.
// The one sample line is the PRD's own unit 1 example and is not reviewed
// content.

export const ROAD_FIXTURE_MARKER = 'puhuscribe-road-fixture-not-for-learners'

const NAMES: readonly (readonly [number, string, string, number])[] = [
  [1, 'Meeting people', "say who I am and where I'm from, and ask the same", 1],
  [2, 'At the caf\u00e9', 'order something, ask the price, say thanks', 1],
  [3, 'At the grocery store', 'ask where something is and follow simple directions', 1],
  [4, 'Numbers, prices and paying', 'ask what something costs and pay by card or cash', 1],
  [5, 'Getting around by bus and tram', 'ask which bus goes where and buy a ticket', 1],
  [6, 'Small talk: weather and the weekend', 'talk about the weather and what I did', 1],
  [7, 'Asking for help', "say I don't understand and ask someone to repeat or slow down", 2],
  [8, 'Making a plan', 'suggest a time, accept and say no politely', 2],
  [9, 'Times and appointments', 'tell the time and book an appointment', 2],
  [10, 'At the pharmacy', 'say what is wrong and ask for something for it', 2],
  [11, 'Home and neighbours', 'say where I live and greet my neighbours', 2],
  [12, 'Shopping for clothes', 'ask for a size and colour and try something on', 2],
  [13, 'At the health centre', 'book a visit and describe where it hurts', 3],
  [14, 'Phone calls and messages', 'start and end a phone call and leave a message', 3],
  [15, 'The bank and Kela', 'ask about a form and say what I need', 3],
  [16, 'Collecting a parcel', 'pick up a parcel and spell my name', 3],
  [17, 'Lunch out', 'read a lunch menu and order politely', 3],
  [18, 'Housing and repairs', 'report that something is broken', 3],
  [19, 'First day at work', 'introduce myself at work and ask where things are', 4],
  [20, 'Talking about family', 'say who is in my family', 4],
  [21, 'School and daycare', 'talk to the daycare about pick up times', 4],
  [22, 'Free time and hobbies', 'say what I like doing', 4],
  [23, 'Cooking at home', 'make a shopping list and follow a simple recipe', 4],
  [24, 'How you feel', 'say how I feel and ask how someone is', 4],
  [25, 'Coffee break and sauna', 'join a coffee break and accept a sauna invitation', 5],
  [26, 'Holidays', 'talk about juhannus and joulu and give dates', 5],
  [27, 'Seasons and the dark winter', 'talk about the seasons and the weather over a year', 5],
  [28, 'At the library', 'get a library card and borrow a book', 5],
  [29, 'Out in nature', 'plan a walk in the forest and talk about berries', 5],
  [30, 'Invitations and celebrations', 'accept an invitation and thank the host', 5],
  [31, 'Directions in the city', 'ask the way and follow left, right and straight on', 6],
  [32, 'Problems and returns', 'return something and explain the problem', 6],
  [33, 'My past', 'say where I lived and worked before', 6],
  [34, 'My plans', 'talk about tomorrow and next week', 6],
  [35, 'My work and skills', 'say what I do and what I can do', 6],
  [36, 'A day in my life', 'tell someone about my day from morning to evening', 6],
]

/** Every stop of the A1 road with the given number of lessons finished at each stop. */
export function roadFixture(done: Record<number, number> = {}): RoadStop[] {
  return NAMES.map(([number, name, canDo, part]) => ({
    number,
    name,
    canDo: `I can ${canDo}.`,
    part,
    lessons: 4,
    lessonsDone: Math.min(4, done[number] ?? 0),
    ...(number === 1
      ? {
          sampleLine: {
            words: [
              { text: 'Mä', changes: true },
              { text: 'oon', changes: true },
              { text: 'Maria', changes: false },
            ],
          },
        }
      : {}),
  }))
}

/** Stops 1 and 2 finished and two lessons of stop 3 (the drawing "Journey, three stops later"). */
export const ROAD_MID = roadFixture({ 1: 4, 2: 4, 3: 2 })
/** Nothing done: the day one road. */
export const ROAD_DAY_ONE = roadFixture()
