import { VISIT_KEY } from '../src/lib/aleksi-intro.ts'

// Fast route intro-visit (owner, 5 November 2026): once the road has opened, the tab's sessionStorage holds
// one key, the visit marker, with only the time of the last use in it (src/lib/aleksi-intro.ts). The browser
// tests that check "nothing is stored" count every other key as before, and count the marker too when it
// holds anything but digits, so it can never carry anything else.

/** A page expression: the keys in localStorage and sessionStorage, leaving out a visit marker that holds only a time. */
export const STORED_BESIDES_VISIT = `localStorage.length + Object.keys(sessionStorage).filter(
  (key) => !(key === ${JSON.stringify(VISIT_KEY)} && /^[0-9]+$/.test(sessionStorage.getItem(key) || ''))
).length`

/** A page expression: the keys in sessionStorage alone, leaving out a visit marker that holds only a time. */
export const SESSION_BESIDES_VISIT = `Object.keys(sessionStorage).filter(
  (key) => !(key === ${JSON.stringify(VISIT_KEY)} && /^[0-9]+$/.test(sessionStorage.getItem(key) || ''))
).length`

/** A page expression: the visit marker's value, or null. */
export const VISIT_VALUE = `sessionStorage.getItem(${JSON.stringify(VISIT_KEY)})`
