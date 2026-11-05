import { describe, expect, it } from 'vitest'
import {
  browserSessionStorage,
  clearOldIntroKeys,
  introDue,
  keepVisit,
  markVisit,
  OLD_INTRO_KEY,
  OLD_MET_KEY,
  showsAleksiIntro,
  VISIT_GAP_MS,
  VISIT_KEY,
  visitIsLive,
  watchVisit,
  type KeyValueStore,
  type StorageSource,
  type VisitSource,
  type VisitStore,
} from './aleksi-intro.ts'
import { todayInfoFrom } from '../road/home-view.ts'

// Fast routes intro-rule and intro-stop (owner's rules of 4 November 2026). Labels: [intro-stop 1] who
// sees Aleksi's intro; [intro-rule 3] the phone keeps no "met" flag and the old keys are cleared. Each case reads a
// GET /api/today body through todayInfoFrom, as the road does.

function memory(start: Record<string, string> = {}): { store: KeyValueStore; data: Map<string, string> } {
  const data = new Map(Object.entries(start))
  return {
    data,
    store: {
      removeItem: (key) => {
        data.delete(key)
      },
    },
  }
}

const throwing: StorageSource = () => {
  throw new Error('blocked')
}

const refusing: StorageSource = () => ({
  removeItem: () => {
    throw new Error('blocked')
  },
})

const shows = (body: unknown) => showsAleksiIntro(todayInfoFrom(body))

describe('who meets Aleksi', () => {
  it('[intro-stop 1] a new visitor, with nobody signed in, sees the intro', () => {
    expect(shows({ signedIn: false, ended: false })).toBe(true)
  })

  it('[intro-stop 1] a sign in that ended sees the intro, guest or email', () => {
    expect(shows({ signedIn: false, ended: true })).toBe(true)
    expect(shows({ signedIn: false, ended: true, account: 'email' })).toBe(true)
  })

  it('[intro-stop 1] a guest sees the intro, with or without a finished stop', () => {
    expect(shows({ signedIn: true, today: 'start', account: 'guest', finishedStop: false })).toBe(true)
    expect(shows({ signedIn: true, today: 'start', account: 'guest', finishedStop: true })).toBe(true)
  })

  it('[intro-stop 1] an email account that has not finished a stop sees the intro, even with lessons done', () => {
    expect(shows({ signedIn: true, today: 'continue', account: 'email', finishedStop: false })).toBe(true)
  })

  it('[intro-stop 1] an email account that has finished a stop never sees it', () => {
    expect(shows({ signedIn: true, today: 'start', account: 'email', finishedStop: true })).toBe(false)
    expect(shows({ signedIn: true, today: 'all_done', account: 'email', finishedStop: true })).toBe(false)
    expect(shows({ signedIn: true, today: 'review', account: 'email', finishedStop: true })).toBe(false)
  })

  it('[intro-stop 1] anything unclear in the answer counts as "show the intro"', () => {
    expect(shows(null)).toBe(true)
    expect(shows({ signedIn: true, today: 'start', account: 'email' })).toBe(true)
    // The earlier fact, a finished lesson, no longer skips it.
    expect(shows({ signedIn: true, today: 'start', account: 'email', finishedLesson: true })).toBe(true)
    expect(shows({ signedIn: true, today: 'start', account: 'email', finishedStop: 'yes' })).toBe(true)
    expect(shows({ signedIn: true, today: 'start', account: 'Email', finishedStop: true })).toBe(true)
    expect(shows({ signedIn: true, today: 'nonsense', account: 'email', finishedStop: true })).toBe(true)
    // An ended sign in never skips it, whatever else the body says.
    expect(shows({ signedIn: false, ended: true, account: 'email', finishedStop: true })).toBe(true)
  })
})

describe('the keys of earlier versions', () => {
  it('[intro-rule 3] the old "met" flag and the old first-open answers are removed, and nothing else', () => {
    const { store, data } = memory({
      [OLD_INTRO_KEY]: JSON.stringify({ seen: true, reason: 'work' }),
      [OLD_MET_KEY]: 'yes',
      other: 'kept',
    })
    clearOldIntroKeys(() => store)
    expect(data.has(OLD_INTRO_KEY)).toBe(false)
    expect(data.has(OLD_MET_KEY)).toBe(false)
    expect(data.get('other')).toBe('kept')
  })

  it('[intro-rule 3] storage that throws, refuses or is missing never breaks the way to the road', () => {
    expect(() => {
      clearOldIntroKeys(throwing)
      clearOldIntroKeys(refusing)
      clearOldIntroKeys(() => null)
    }).not.toThrow()
  })
})

// Fast route intro-visit (owner, 5 November 2026): the intro shows only at the start of a visit. Labels
// [intro-visit N] are the numbered "done when" statements in factory/jobs/intro-visit/build.md.

const MINUTE = 60 * 1000
const START = Date.UTC(2026, 10, 5, 9, 0, 0)

/** A tab's sessionStorage in memory, with a count of writes. */
function tab(start: Record<string, string> = {}) {
  const data = new Map(Object.entries(start))
  let writes = 0
  const store: VisitStore = {
    getItem: (key) => data.get(key) ?? null,
    setItem: (key, value) => {
      writes += 1
      data.set(key, value)
    },
  }
  const source: VisitSource = () => store
  return { data, store, source, writes: () => writes }
}

/** A clock the test moves by hand. */
function clock(at = START) {
  let now = at
  return {
    now: () => now,
    move: (ms: number) => {
      now += ms
    },
  }
}

/** A guest and a new visitor, who would both meet Aleksi by the "who" rule, and a learner who never does. */
const GUEST = todayInfoFrom({ signedIn: true, today: 'start', account: 'guest', finishedStop: false })
const VISITOR = todayInfoFrom({ signedIn: false, ended: false })
const DONE_EMAIL = todayInfoFrom({ signedIn: true, today: 'start', account: 'email', finishedStop: true })

/** Stands in for window and document: two event targets, and the document's visibility. */
function page() {
  const win = new EventTarget()
  const doc = Object.assign(new EventTarget(), { visibilityState: 'visible' })
  const hide = () => {
    doc.visibilityState = 'hidden'
    doc.dispatchEvent(new Event('visibilitychange'))
  }
  const show = () => {
    doc.visibilityState = 'visible'
    doc.dispatchEvent(new Event('visibilitychange'))
  }
  const fire = (name: string) => win.dispatchEvent(new Event(name))
  return { win, doc, hide, show, fire }
}

describe('a visit', () => {
  it('[intro-visit 1] once "Nice to meet you" marks the visit, the road opens without the intro for the rest of the visit', () => {
    const t = tab()
    const c = clock()
    expect(introDue(GUEST, t.source, c.now)).toBe(true)
    markVisit(t.source, c.now)
    expect(t.data.get(VISIT_KEY)).toBe(String(START))
    // The learner goes into a lesson and comes back to the road ten minutes later.
    c.move(10 * MINUTE)
    expect(introDue(GUEST, t.source, c.now)).toBe(false)
    expect(introDue(VISITOR, t.source, c.now)).toBe(false)
  })

  it('[intro-visit 1] the marker holds only a time, under one key', () => {
    const t = tab()
    markVisit(t.source, () => START)
    expect([...t.data.keys()]).toEqual([VISIT_KEY])
    expect(t.data.get(VISIT_KEY)).toMatch(/^\d+$/)
  })

  it('[intro-visit 1] using the app keeps the visit going: taps, keys, hiding the page and leaving it each refresh the marker', () => {
    const t = tab()
    const c = clock()
    const p = page()
    markVisit(t.source, c.now)
    const stop = watchVisit(p.win, p.doc, t.source, c.now)
    const uses: [string, () => void][] = [
      ['a tap', () => p.fire('pointerdown')],
      ['a key', () => p.fire('keydown')],
      ['hiding the page', p.hide],
      ['leaving the page', () => p.fire('pagehide')],
    ]
    for (const [name, use] of uses) {
      c.move(50 * MINUTE)
      use()
      expect(t.data.get(VISIT_KEY), name).toBe(String(c.now()))
    }
    // Two hundred minutes in, the learner is still in the same visit.
    expect(introDue(GUEST, t.source, c.now)).toBe(false)
    stop()
    c.move(MINUTE)
    p.fire('pointerdown')
    expect(t.data.get(VISIT_KEY), 'nothing listens after the stop').toBe(String(c.now() - MINUTE))
  })

  it('[intro-visit 1] showing the page again writes nothing; only hiding it does', () => {
    const t = tab()
    const p = page()
    markVisit(t.source, () => START)
    watchVisit(p.win, p.doc, t.source, () => START + MINUTE)
    const before = t.writes()
    p.show()
    expect(t.writes()).toBe(before)
  })

  it('[intro-visit 2] a fresh open, with no marker in the tab, shows the intro', () => {
    const t = tab()
    expect(visitIsLive(t.source, () => START)).toBe(false)
    expect(introDue(GUEST, t.source, () => START)).toBe(true)
    expect(introDue(VISITOR, t.source, () => START)).toBe(true)
  })

  it('[intro-visit 2] using the app never starts a visit by itself: with no marker, taps and hiding write nothing', () => {
    const t = tab()
    const p = page()
    watchVisit(p.win, p.doc, t.source, () => START)
    keepVisit(t.source, () => START)
    p.fire('pointerdown')
    p.hide()
    p.fire('pagehide')
    expect(t.data.size).toBe(0)
    expect(introDue(GUEST, t.source, () => START)).toBe(true)
  })

  it('[intro-visit 3] under 60 minutes without use the visit goes on; at 60 minutes or more the intro shows again', () => {
    const t = tab({ [VISIT_KEY]: String(START) })
    expect(introDue(GUEST, t.source, () => START + 59 * MINUTE)).toBe(false)
    expect(introDue(GUEST, t.source, () => START + 60 * MINUTE - 1)).toBe(false)
    expect(introDue(GUEST, t.source, () => START + 60 * MINUTE)).toBe(true)
    expect(introDue(GUEST, t.source, () => START + 61 * MINUTE)).toBe(true)
    expect(introDue(GUEST, t.source, () => START + 24 * 60 * MINUTE)).toBe(true)
    expect(VISIT_GAP_MS).toBe(60 * MINUTE)
  })

  it('[intro-visit 3] after an hour away, coming back and tapping does not carry the old visit on', () => {
    const t = tab()
    const c = clock()
    const p = page()
    markVisit(t.source, c.now)
    watchVisit(p.win, p.doc, t.source, c.now)
    p.hide()
    // The phone sits in a pocket for 90 minutes, then the learner taps "Leave" in the lesson.
    c.move(90 * MINUTE)
    p.show()
    p.fire('pointerdown')
    p.fire('pagehide')
    expect(t.data.get(VISIT_KEY)).toBe(String(START))
    expect(introDue(GUEST, t.source, c.now)).toBe(true)
  })

  it('[intro-visit 3] a marker from the future (a clock set back) counts as a new visit', () => {
    const t = tab({ [VISIT_KEY]: String(START + 5 * MINUTE) })
    expect(introDue(GUEST, t.source, () => START)).toBe(true)
  })

  it('[intro-visit 4] a signed in email account with a finished stop never sees it, in a visit or not', () => {
    const fresh = tab()
    expect(introDue(DONE_EMAIL, fresh.source, () => START)).toBe(false)
    const old = tab({ [VISIT_KEY]: String(START - 3 * 60 * MINUTE) })
    expect(introDue(DONE_EMAIL, old.source, () => START)).toBe(false)
    const live = tab({ [VISIT_KEY]: String(START - MINUTE) })
    expect(introDue(DONE_EMAIL, live.source, () => START)).toBe(false)
  })

  it('[intro-visit 5] blocked, throwing or missing storage shows the intro and throws nothing', () => {
    const blocked: VisitSource = () => {
      throw new Error('blocked')
    }
    const refusing: VisitSource = () => ({
      getItem: () => {
        throw new Error('blocked')
      },
      setItem: () => {
        throw new Error('quota')
      },
    })
    const missing: VisitSource = () => null
    for (const source of [blocked, refusing, missing]) {
      expect(() => {
        markVisit(source, () => START)
        keepVisit(source, () => START)
      }).not.toThrow()
      expect(visitIsLive(source, () => START)).toBe(false)
      expect(introDue(GUEST, source, () => START)).toBe(true)
      const p = page()
      const stop = watchVisit(p.win, p.doc, source, () => START)
      expect(() => {
        p.fire('pointerdown')
        p.hide()
        p.fire('pagehide')
        stop()
      }).not.toThrow()
    }
  })

  it('[intro-visit 5] a marker that cannot be read counts as a new visit', () => {
    for (const value of ['', 'yes', 'NaN', '-5', '1.5', `${String(START)}x`, '9'.repeat(400)]) {
      const t = tab({ [VISIT_KEY]: value })
      expect(
        introDue(GUEST, t.source, () => START),
        JSON.stringify(value.slice(0, 20)),
      ).toBe(true)
    }
  })

  it('[intro-visit 5] the browser source is the tab’s sessionStorage, and null when it is missing or throws', () => {
    const holder = globalThis as { sessionStorage?: unknown }
    const had = Object.getOwnPropertyDescriptor(holder, 'sessionStorage')
    try {
      delete holder.sessionStorage
      expect(browserSessionStorage()).toBeNull()
      Object.defineProperty(holder, 'sessionStorage', {
        configurable: true,
        get: () => {
          throw new Error('SecurityError')
        },
      })
      expect(browserSessionStorage()).toBeNull()
      const { store } = tab()
      Object.defineProperty(holder, 'sessionStorage', { configurable: true, value: store })
      expect(browserSessionStorage()).toBe(store)
    } finally {
      delete holder.sessionStorage
      if (had) Object.defineProperty(holder, 'sessionStorage', had)
    }
  })
})
