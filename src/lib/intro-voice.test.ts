import { describe, expect, it } from 'vitest'
import { CLIP_MS, GREETING_AUDIO, GREETING_WRITTEN_AUDIO, JOURNEY_AUDIO } from './aleksi-intro.ts'
import {
  GREETING_AT,
  HOLD_MS,
  IntroVoice,
  LEAVE_MS,
  playCard,
  STALL_MS,
  WRITTEN_AT,
  type CardScene,
  type SayResult,
  type VoiceElement,
  type VoiceTimers,
} from './intro-voice.ts'

// Labels in brackets are the numbered items of the owner's brief for fast route intro-logo, listed in
// factory/jobs/intro-logo/build.md: [intro-logo 2] nothing plays before the tap; [intro-logo 3] after the
// tap the scenes and the three clips run in order, no clip starting before the one before it has ended.
// The browser tests in e2e/intro-logo.spec.ts check the same in Chromium and WebKit.

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
        await Promise.resolve()
        await Promise.resolve()
        const first = [...due.entries()].sort((a, b) => a[1].at - b[1].at).slice(0, 1)
        const [id, timer] = first[0] ?? [0, { at: Infinity, run: () => undefined }]
        if (timer.at > until) break
        due.delete(id)
        now = timer.at
        timer.run()
      }
      now = until
      await Promise.resolve()
      await Promise.resolve()
    },
  }
}

interface Played {
  src: string
  muted: boolean
}

/** An audio element that records each play() with the clip and whether it was muted. */
function fakeAudio(opts: { refuse?: boolean } = {}) {
  const listeners = new Map<string, Set<() => void>>()
  const plays: Played[] = []
  const element: VoiceElement & { pauses: number } = {
    src: '',
    muted: false,
    currentTime: 0,
    preload: '',
    pauses: 0,
    play() {
      plays.push({ src: this.src, muted: this.muted })
      return opts.refuse ? Promise.reject(new Error('NotAllowedError')) : Promise.resolve()
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
  return { element, plays, fire }
}

const flush = async () => {
  for (let i = 0; i < 6; i++) await Promise.resolve()
}

describe('the intro voice', () => {
  it('[intro-logo 2] makes and plays nothing until the tap unlocks it', async () => {
    let made = 0
    const audio = fakeAudio()
    const voice = new IntroVoice(() => {
      made += 1
      return audio.element
    }, fakeTime())
    voice.stop()
    await flush()
    expect(made).toBe(0)
    expect(audio.plays).toEqual([])
    // The tap: one muted start of the first clip, so the browser allows the clips that follow.
    voice.unlock(GREETING_AUDIO)
    await flush()
    expect(made).toBe(1)
    expect(audio.plays).toEqual([{ src: GREETING_AUDIO, muted: true }])
    expect(audio.element.muted).toBe(false)
    expect(audio.element.pauses).toBe(1)
  })

  it('[intro-logo 3] a clip is said aloud on the same element and ends only when the clip ends', async () => {
    const time = fakeTime()
    const audio = fakeAudio()
    const voice = new IntroVoice(() => audio.element, time)
    voice.unlock(GREETING_AUDIO)
    let result: SayResult | null = null
    void voice.say(GREETING_AUDIO).then((r) => (result = r))
    await flush()
    expect(audio.plays.at(-1)).toEqual({ src: GREETING_AUDIO, muted: false })
    await time.advance(3000)
    expect(result).toBeNull()
    audio.fire('ended')
    await flush()
    expect(result).toBe('ended')
    // The next clip is set on the same element.
    void voice.say(JOURNEY_AUDIO)
    await flush()
    expect(audio.plays.at(-1)).toEqual({ src: JOURNEY_AUDIO, muted: false })
  })

  it('[intro-logo 3] a clip that cannot play is waited out for its own length, then the intro goes on', async () => {
    const time = fakeTime()
    const audio = fakeAudio({ refuse: true })
    const voice = new IntroVoice(() => audio.element, time)
    let result: SayResult | null = null
    void voice.say(GREETING_WRITTEN_AUDIO).then((r) => (result = r))
    await time.advance((CLIP_MS[GREETING_WRITTEN_AUDIO] ?? 0) - 10)
    expect(result).toBeNull()
    await time.advance(10)
    expect(result).toBe('failed')
  })

  it('[intro-logo 3] a clip that never ends is given up after its length and five seconds', async () => {
    const time = fakeTime()
    const audio = fakeAudio()
    const voice = new IntroVoice(() => audio.element, time)
    let result: SayResult | null = null
    void voice.say(JOURNEY_AUDIO).then((r) => (result = r))
    await time.advance((CLIP_MS[JOURNEY_AUDIO] ?? 0) + STALL_MS - 1)
    expect(result).toBeNull()
    await time.advance(1)
    expect(result).toBe('failed')
    expect(audio.element.pauses).toBe(1)
  })

  it('[intro-logo 4] stop ends the clip at once and pauses it', async () => {
    const audio = fakeAudio()
    const voice = new IntroVoice(() => audio.element, fakeTime())
    let result: SayResult | null = null
    void voice.say(GREETING_AUDIO).then((r) => (result = r))
    await flush()
    voice.stop()
    await flush()
    expect(result).toBe('stopped')
    expect(audio.element.pauses).toBe(1)
    // A late "ended" from the stopped clip changes nothing.
    audio.fire('ended')
    await flush()
    expect(result).toBe('stopped')
  })
})

describe('the lesson card scenes', () => {
  /** Runs playCard with clips that end only when the test says, and logs every step. */
  function run(opts: { live?: () => boolean } = {}) {
    const log: string[] = []
    const pending: { clip: string; end: (r: SayResult) => void }[] = []
    const waits: { ms: number; done: () => void }[] = []
    const result = playCard({
      show: (scene: CardScene) => log.push(`show ${scene}`),
      say: (clip) =>
        new Promise<SayResult>((resolve) => {
          log.push(`say ${clip}`)
          pending.push({
            clip,
            end: (r) => {
              log.push(`ended ${clip}`)
              resolve(r)
            },
          })
        }),
      wait: (ms) =>
        new Promise<void>((resolve) => {
          log.push(`wait ${String(ms)}`)
          waits.push({ ms, done: resolve })
        }),
      live: opts.live ?? (() => true),
    })
    return { log, pending, waits, result }
  }

  it('[intro-logo 3] runs spoken line, greeting, written line, written greeting, then leaves, each clip after the last has ended', async () => {
    const r = run()
    await flush()
    expect(r.log).toEqual(['show spoken', `wait ${String(GREETING_AT)}`])
    r.waits.shift()?.done()
    await flush()
    expect(r.log.at(-1)).toBe(`say ${GREETING_AUDIO}`)
    // Nothing else happens while the greeting is still playing.
    await flush()
    expect(r.log.at(-1)).toBe(`say ${GREETING_AUDIO}`)
    r.pending.shift()?.end('ended')
    await flush()
    expect(r.log.slice(-2)).toEqual(['show written', `wait ${String(WRITTEN_AT)}`])
    r.waits.shift()?.done()
    await flush()
    expect(r.log.at(-1)).toBe(`say ${GREETING_WRITTEN_AUDIO}`)
    r.pending.shift()?.end('ended')
    await flush()
    r.waits.shift()?.done()
    await flush()
    r.waits.shift()?.done()
    expect(await r.result).toBe(true)
    expect(r.log).toEqual([
      'show spoken',
      `wait ${String(GREETING_AT)}`,
      `say ${GREETING_AUDIO}`,
      `ended ${GREETING_AUDIO}`,
      'show written',
      `wait ${String(WRITTEN_AT)}`,
      `say ${GREETING_WRITTEN_AUDIO}`,
      `ended ${GREETING_WRITTEN_AUDIO}`,
      `wait ${String(HOLD_MS)}`,
      'show leaving',
      `wait ${String(LEAVE_MS)}`,
    ])
  })

  it('[intro-logo 4] once skipped, nothing more is shown or said', async () => {
    let live = true
    const r = run({ live: () => live })
    await flush()
    r.waits.shift()?.done()
    await flush()
    live = false
    r.pending.shift()?.end('stopped')
    expect(await r.result).toBe(false)
    expect(r.log).toEqual([
      'show spoken',
      `wait ${String(GREETING_AT)}`,
      `say ${GREETING_AUDIO}`,
      `ended ${GREETING_AUDIO}`,
    ])
  })
})
