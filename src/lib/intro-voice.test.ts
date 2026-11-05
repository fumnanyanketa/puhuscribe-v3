import { describe, expect, it } from 'vitest'
import { CLIP_MS, GREETING_AUDIO, JOURNEY_AUDIO } from './aleksi-intro.ts'
import {
  GONE_AT,
  GREETING_AT,
  IntroVoice,
  LEAVE_AT,
  playIntro,
  ROAD_AT,
  SILENT_TAIL_MS,
  SPOKEN_AT,
  STALL_MS,
  WRITTEN_AT,
  type IntroScene,
  type SayResult,
  type VoiceElement,
  type VoiceState,
  type VoiceTimers,
} from './intro-voice.ts'

// Labels in brackets are the numbered "Done when" items of fast route intro-logo, version E, listed in
// factory/jobs/intro-logo/build.md: [intro-logo 3] the intro plays on its own; [intro-logo 4] it tries to play
// the greeting with no tap; [intro-logo 5] when play is refused, the first tap starts the voice;
// [intro-logo 6] only two clips; [intro-logo 7] no clip overlaps another; [intro-logo 8] the speaker's states,
// and nothing mutes the sound; [intro-logo 9] Skip stops it. The browser tests in e2e/intro-logo.spec.ts
// check the same in Chromium and WebKit.

async function flush() {
  for (let i = 0; i < 8; i++) await Promise.resolve()
}

/** A clock and timers the test moves by hand. */
function fakeTime(): VoiceTimers & { advance: (ms: number) => Promise<void> } {
  let now = 0
  let next = 1
  const due = new Map<number, { at: number; run: () => void }>()
  return {
    now: () => now,
    set: (run, ms) => {
      const id = next++
      due.set(id, { at: now + ms, run })
      return id
    },
    clear: (id) => {
      due.delete(id)
    },
    advance: async (ms) => {
      const until = now + ms
      for (;;) {
        await flush()
        const first = [...due.entries()].sort((a, b) => a[1].at - b[1].at).slice(0, 1)
        const [id, timer] = first[0] ?? [0, { at: Infinity, run: () => undefined }]
        if (timer.at > until) break
        due.delete(id)
        now = timer.at
        timer.run()
      }
      now = until
      await flush()
    },
  }
}

interface Played {
  src: string
  muted: boolean
  at: number
}

/** An audio element that records each play() with its clip, whether it was muted and the time it was at. */
function fakeAudio(opts: { refuseUntilTap?: boolean } = {}) {
  const listeners = new Map<string, Set<() => void>>()
  const plays: Played[] = []
  let tapped = false
  let mutedEver = false
  const element: VoiceElement & { pauses: number } = {
    src: '',
    muted: false,
    currentTime: 0,
    preload: '',
    pauses: 0,
    play() {
      if (this.muted) mutedEver = true
      plays.push({ src: this.src, muted: this.muted, at: this.currentTime })
      return opts.refuseUntilTap && !tapped ? Promise.reject(new Error('NotAllowedError')) : Promise.resolve()
    },
    pause() {
      this.pauses += 1
    },
    addEventListener(type, listener) {
      const set = listeners.get(type) ?? new Set()
      set.add(listener)
      listeners.set(type, set)
    },
    removeEventListener(type, listener) {
      listeners.get(type)?.delete(listener)
    },
  }
  const fire = (type: 'ended' | 'error') => {
    for (const listener of [...(listeners.get(type) ?? [])]) listener()
  }
  return {
    element,
    plays,
    fire,
    tap: () => {
      tapped = true
    },
    mutedEver: () => mutedEver || element.muted,
  }
}

/** The page's taps, driven by the test. */
function fakeTaps() {
  const handlers = new Set<() => void>()
  return {
    source: (onTap: () => void) => {
      handlers.add(onTap)
      return () => {
        handlers.delete(onTap)
      }
    },
    tap: () => {
      for (const handler of [...handlers]) handler()
    },
    listening: () => handlers.size,
  }
}

function setup(opts: { refuseUntilTap?: boolean } = {}) {
  const time = fakeTime()
  const audio = fakeAudio(opts)
  const taps = fakeTaps()
  let made = 0
  const voice = new IntroVoice(
    () => {
      made += 1
      return audio.element
    },
    time,
    taps.source,
  )
  const states: VoiceState[] = []
  voice.subscribe((state) => states.push(state))
  return {
    time,
    audio,
    taps,
    voice,
    states,
    made: () => made,
    tap: () => {
      audio.tap()
      taps.tap()
    },
  }
}

/** The states told to the speaker, without repeats in a row. */
const changes = (states: VoiceState[]) => states.filter((state, i) => state !== states[i - 1])

describe('the intro voice', () => {
  it('[intro-logo 4] plays the clip at once, with no tap and nothing muted, and ends when the clip ends', async () => {
    const t = setup()
    expect(t.made()).toBe(0)
    let result: SayResult | null = null
    void t.voice.say(GREETING_AUDIO).then((r) => (result = r))
    await flush()
    expect(t.audio.plays).toEqual([{ src: GREETING_AUDIO, muted: false, at: 0 }])
    expect(t.voice.state).toBe('playing')
    await t.time.advance(3000)
    expect(result).toBeNull()
    t.audio.fire('ended')
    await flush()
    expect(result).toBe('ended')
    expect(t.voice.state).toBe('idle')
    expect(t.taps.listening()).toBe(0)
  })

  it('[intro-logo 5] when play is refused, the first tap plays the clip inside the tap, from where the scenes are', async () => {
    const t = setup({ refuseUntilTap: true })
    void t.voice.say(GREETING_AUDIO)
    await flush()
    expect(t.voice.state).toBe('waiting-for-tap')
    expect(t.taps.listening()).toBe(1)
    await t.time.advance(1200)
    t.tap()
    await flush()
    expect(t.audio.plays.at(-1)).toEqual({ src: GREETING_AUDIO, muted: false, at: 1.2 })
    expect(t.voice.state).toBe('playing')
    // The tap is heard once: the page stops listening, and the next clip plays at its time with no tap.
    expect(t.taps.listening()).toBe(0)
    void t.voice.say(JOURNEY_AUDIO)
    await flush()
    expect(t.audio.plays.at(-1)).toEqual({ src: JOURNEY_AUDIO, muted: false, at: 0 })
  })

  it('[intro-logo 5] a tap with less than 0.9 s of the refused clip left plays nothing, and the next clip still plays', async () => {
    const t = setup({ refuseUntilTap: true })
    void t.voice.say(GREETING_AUDIO)
    await flush()
    await t.time.advance((CLIP_MS[GREETING_AUDIO] ?? 0) - SILENT_TAIL_MS + 1)
    const before = t.audio.plays.length
    t.tap()
    await flush()
    expect(t.audio.plays).toHaveLength(before)
    expect(t.voice.state).toBe('idle')
    void t.voice.say(JOURNEY_AUDIO)
    await flush()
    expect(t.audio.plays.at(-1)).toEqual({ src: JOURNEY_AUDIO, muted: false, at: 0 })
  })

  it('[intro-logo 5] with no tap at all, a refused clip is waited out for its length and the intro goes on', async () => {
    const t = setup({ refuseUntilTap: true })
    let result: SayResult | null = null
    void t.voice.say(JOURNEY_AUDIO).then((r) => (result = r))
    await t.time.advance((CLIP_MS[JOURNEY_AUDIO] ?? 0) - 10)
    expect(result).toBeNull()
    await t.time.advance(10)
    expect(result).toBe('waited')
    // "Tap to hear" stays until a tap, even between clips.
    expect(t.voice.state).toBe('waiting-for-tap')
  })

  it('[intro-logo 7] both clips play on one element, and a new clip stops the one before it first', async () => {
    const t = setup()
    void t.voice.say(GREETING_AUDIO)
    await flush()
    const pausesBefore = t.audio.element.pauses
    // The journey line starts while the greeting file is still in its silent end: the greeting is stopped first.
    void t.voice.say(JOURNEY_AUDIO)
    await flush()
    expect(t.audio.element.pauses).toBe(pausesBefore + 1)
    expect(t.made()).toBe(1)
    expect(t.audio.plays.map((p) => p.src)).toEqual([GREETING_AUDIO, JOURNEY_AUDIO])
  })

  it('[intro-logo 8] the speaker states: waiting for a tap when refused, playing once the tap starts it, idle when it ends', async () => {
    const t = setup({ refuseUntilTap: true })
    void t.voice.say(GREETING_AUDIO)
    await flush()
    expect(changes(t.states)).toEqual(['waiting-for-tap'])
    t.tap()
    await flush()
    t.audio.fire('ended')
    await flush()
    expect(changes(t.states)).toEqual(['waiting-for-tap', 'idle', 'playing', 'idle'])
  })

  it('[intro-logo 8] nothing in the voice mutes the sound or offers to turn it off', async () => {
    const t = setup({ refuseUntilTap: true })
    void t.voice.say(GREETING_AUDIO)
    await flush()
    t.tap()
    await flush()
    void t.voice.say(JOURNEY_AUDIO)
    await flush()
    t.audio.fire('ended')
    await flush()
    expect(t.audio.mutedEver()).toBe(false)
    expect(t.audio.plays.every((p) => !p.muted)).toBe(true)
    const methods = Object.getOwnPropertyNames(IntroVoice.prototype)
    expect(methods.filter((name) => /mute|turnoff|turnon|sound|volume/i.test(name))).toEqual([])
  })

  it('[intro-logo 9] stop ends the clip at once and pauses it', async () => {
    const t = setup()
    let result: SayResult | null = null
    void t.voice.say(GREETING_AUDIO).then((r) => (result = r))
    await flush()
    t.voice.stop()
    await flush()
    expect(result).toBe('stopped')
    expect(t.audio.element.pauses).toBe(1)
    t.audio.fire('ended')
    await flush()
    expect(result).toBe('stopped')
  })

  it('[intro-logo 3] a clip that never ends is given up after its length and five seconds', async () => {
    const t = setup()
    let result: SayResult | null = null
    void t.voice.say(JOURNEY_AUDIO).then((r) => (result = r))
    await t.time.advance((CLIP_MS[JOURNEY_AUDIO] ?? 0) + STALL_MS - 1)
    expect(result).toBeNull()
    await t.time.advance(1)
    expect(result).toBe('waited')
  })
})

describe('the intro timeline', () => {
  /** Runs playIntro with waits the test releases, and logs every step. */
  function run(opts: { live?: () => boolean } = {}) {
    const log: string[] = []
    const waits: (() => void)[] = []
    const result = playIntro({
      show: (scene: IntroScene) => log.push(`show ${scene}`),
      // The greeting is never finished here: the timeline must not wait for it.
      say: (clip) => {
        log.push(`say ${clip}`)
        return new Promise<SayResult>(() => undefined)
      },
      wait: (ms) =>
        new Promise<void>((resolve) => {
          log.push(`wait ${String(ms)}`)
          waits.push(resolve)
        }),
      road: () => log.push('road'),
      live: opts.live ?? (() => true),
    })
    return { log, waits, result }
  }

  async function releaseAll(r: ReturnType<typeof run>) {
    for (let i = 0; i < 20; i++) {
      await flush()
      r.waits.shift()?.()
    }
  }

  it('[intro-logo 3] [intro-logo 6] runs on its own: logo, spoken line, greeting, written line (never said), card leaving, road', async () => {
    const r = run()
    await releaseAll(r)
    expect(await r.result).toBe(true)
    expect(r.log).toEqual([
      'show splash',
      `wait ${String(SPOKEN_AT)}`,
      'show spoken',
      `wait ${String(GREETING_AT - SPOKEN_AT)}`,
      `say ${GREETING_AUDIO}`,
      `wait ${String(WRITTEN_AT - GREETING_AT)}`,
      'show written',
      `wait ${String(LEAVE_AT - WRITTEN_AT)}`,
      'show leaving',
      `wait ${String(ROAD_AT - LEAVE_AT)}`,
      'road',
      `wait ${String(GONE_AT - ROAD_AT)}`,
      'show gone',
    ])
  })

  it('[intro-logo 3] the moments are the owner’s quickest timing: card 0.65 s, greeting 0.95 s, written 2.35 s, out 4.15 s, road 4.2 s', () => {
    expect([SPOKEN_AT, GREETING_AT, WRITTEN_AT, LEAVE_AT, ROAD_AT]).toEqual([650, 950, 2350, 4150, 4200])
  })

  it('[intro-logo 9] once skipped, nothing more is shown or said', async () => {
    let live = true
    const r = run({ live: () => live })
    await flush()
    r.waits.shift()?.()
    await flush()
    live = false
    await releaseAll(r)
    expect(await r.result).toBe(false)
    expect(r.log).toEqual([
      'show splash',
      `wait ${String(SPOKEN_AT)}`,
      'show spoken',
      `wait ${String(GREETING_AT - SPOKEN_AT)}`,
    ])
  })
})
