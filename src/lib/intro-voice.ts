import { finished, startExclusive } from '../components/play-registry.ts'
import { CLIP_MS, GREETING_AUDIO } from './aleksi-intro.ts'

// Aleksi's voice in the intro (fast route intro-logo, version E with its quick timing, owner approved
// 5 November 2026). The intro plays on its own with no tap, and Aleksi speaks from the start: each clip is
// played at its time. Phones that block sound before a tap (iPhones do) refuse that play(); then the first
// tap anywhere on the page plays the refused clip, inside that tap, from the point the scenes have reached,
// unless less than 0.9 s of it is left (each clip ends in about 0.9 s of silence). The same tap unlocks the
// element for the clips after it. There is no sound switch. One audio element plays both clips, so two clips
// can never overlap: saying a clip first stops any clip still playing (the greeting's silent tail when the
// journey line starts). Aleksi says two clips only, his spoken greeting and his journey line. A clip that
// cannot play is waited out for its own length; one that never ends is given up after its length plus five
// seconds, so the intro always ends.

/** What the intro needs of an audio element (HTMLAudioElement in the browser, a stand-in in the tests). */
export interface VoiceElement {
  src: string
  muted: boolean
  currentTime: number
  preload: string
  play: () => Promise<void>
  pause: () => void
  addEventListener: (type: 'ended' | 'error', listener: () => void) => void
  removeEventListener: (type: 'ended' | 'error', listener: () => void) => void
}

/**
 * How a clip finished: it played to its end, it was waited out (refused with no tap in time, or it could
 * not play), or the intro stopped it (Skip, the next clip, leaving).
 */
export type SayResult = 'ended' | 'waited' | 'stopped'

/** The clock and timers the voice uses, so the tests can drive time. */
export interface VoiceTimers {
  now: () => number
  set: (run: () => void, ms: number) => number
  clear: (handle: number) => void
}

/** Listens for the learner's first tap anywhere (or first key, for keyboards); returns the call that stops listening. */
export type TapSource = (onTap: () => void) => () => void

const browserTimers: VoiceTimers = {
  now: () => Date.now(),
  set: (run, ms) => window.setTimeout(run, ms),
  clear: (handle) => {
    window.clearTimeout(handle)
  },
}

const browserTaps: TapSource = (onTap) => {
  const listener = () => {
    onTap()
  }
  window.addEventListener('pointerdown', listener, { capture: true })
  window.addEventListener('keydown', listener, { capture: true })
  return () => {
    window.removeEventListener('pointerdown', listener, { capture: true })
    window.removeEventListener('keydown', listener, { capture: true })
  }
}

/** A clip that has not ended this long after its own length is given up. */
export const STALL_MS = 5000

/** A refused clip is not played on the first tap when less than this is left of it (its silent end). */
export const SILENT_TAIL_MS = 900

const browserAudio = (): VoiceElement => {
  const element = new Audio()
  element.preload = 'auto'
  return element
}

/**
 * What the voice is doing, for the speaker on Aleksi's card: a clip is sounding, the browser refused to play
 * and the voice waits for the first tap, or nothing.
 */
export type VoiceState = 'playing' | 'waiting-for-tap' | 'idle'

/** A clip the browser refused to play without a tap, waiting for the first tap. */
interface Refused {
  clip: string
  started: number
  resume: () => void
}

export class IntroVoice {
  private element: VoiceElement | null = null
  private current: string | null = null
  private finish: ((result: SayResult) => void) | null = null
  private refused: Refused | null = null
  private unlisten: (() => void) | null = null
  private sounding = false
  private readonly watchers = new Set<(state: VoiceState) => void>()
  private readonly make: () => VoiceElement
  private readonly timers: VoiceTimers
  private readonly taps: TapSource
  private readonly stopThis = () => {
    this.stop()
  }

  constructor(
    make: () => VoiceElement = browserAudio,
    timers: VoiceTimers = browserTimers,
    taps: TapSource = browserTaps,
  ) {
    this.make = make
    this.timers = timers
    this.taps = taps
  }

  private audio(): VoiceElement {
    this.element ??= this.make()
    return this.element
  }

  /** What the voice is doing now. Waiting for a tap shows until that tap, even between clips. */
  get state(): VoiceState {
    if (this.unlisten) return 'waiting-for-tap'
    return this.sounding ? 'playing' : 'idle'
  }

  /** Tells the watcher each time the state changes; returns the call that stops telling. */
  subscribe(watch: (state: VoiceState) => void): () => void {
    this.watchers.add(watch)
    return () => {
      this.watchers.delete(watch)
    }
  }

  private markPlaying(on: boolean) {
    this.sounding = on
    this.tell()
  }

  private tell() {
    const now = this.state
    for (const watch of this.watchers) watch(now)
  }

  /** The first tap after a refusal: plays the refused clip inside the tap, from where the scenes are. */
  private onTap = () => {
    this.unlisten?.()
    this.unlisten = null
    const refused = this.refused
    this.refused = null
    this.tell()
    refused?.resume()
  }

  /** Says one clip at its time, from its start. Any clip still playing is stopped first. */
  say(clip: string): Promise<SayResult> {
    this.stop()
    const length = CLIP_MS[clip] ?? 4000
    const started = this.timers.now()
    const element = this.audio()
    return new Promise<SayResult>((resolve) => {
      let done = false
      let pacing: number | null = null
      const end = (result: SayResult) => {
        if (done) return
        done = true
        this.timers.clear(stall)
        if (pacing !== null) this.timers.clear(pacing)
        element.removeEventListener('ended', onEnded)
        element.removeEventListener('error', onError)
        if (this.refused?.clip === clip) this.refused = null
        finished(this.stopThis)
        if (this.finish === stopNow) this.finish = null
        this.markPlaying(false)
        resolve(result)
      }
      // Waited out for the rest of the clip's own length, so the scenes keep their pace.
      const waitOut = () => {
        if (done || pacing !== null) return
        pacing = this.timers.set(
          () => {
            end('waited')
          },
          Math.max(0, started + length - this.timers.now()),
        )
      }
      const onEnded = () => {
        end('ended')
      }
      const onError = () => {
        element.pause()
        this.markPlaying(false)
        waitOut()
      }
      const stopNow = (result: SayResult) => {
        element.pause()
        end(result)
      }
      // Refused without a tap: the first tap plays it from where the scenes are, if enough of it is left.
      const onRefused = () => {
        if (done) return
        waitOut()
        this.refused = {
          clip,
          started,
          resume: () => {
            if (done) return
            const reached = this.timers.now() - started
            if (length - reached < SILENT_TAIL_MS) return
            element.currentTime = reached / 1000
            element.play().then(
              () => {
                if (!done) this.markPlaying(true)
              },
              () => undefined,
            )
          },
        }
        this.unlisten ??= this.taps(this.onTap)
        this.tell()
      }
      const stall = this.timers.set(() => {
        stopNow('waited')
      }, length + STALL_MS)
      this.finish = stopNow
      startExclusive(this.stopThis)
      if (this.current !== clip) {
        element.src = clip
        this.current = clip
      }
      // Every clip starts from its start, also after a clip that was played from part way.
      element.currentTime = 0
      element.addEventListener('ended', onEnded)
      element.addEventListener('error', onError)
      element.play().then(() => {
        if (!done) this.markPlaying(true)
      }, onRefused)
    })
  }

  /** Stops the clip that is playing, if any (Skip, or the intro leaving the page), and the wait for a tap. */
  stop(): void {
    this.finish?.('stopped')
  }

  /** The intro is over: no more waiting for a tap. */
  close(): void {
    this.stop()
    this.refused = null
    this.unlisten?.()
    this.unlisten = null
    this.tell()
  }
}

// The intro's timeline (src/screens/AleksiIntro.tsx), the owner's prototype version E with its quickest
// timing of 5 November 2026 (design-drafts/intro-flow/intro-flow-e-logo-first.html): the logo wastes no time.
// The look and motion of each scene is in the CSS; these are the moments, in milliseconds from the moment the
// intro opens. Aleksi starts speaking as the card comes in; the written line comes in while he speaks; the
// card leaves as he finishes.
// The greeting's words run from 0.25 s to 3.12 s of its 4.0 s file, the journey line's from 0.27 s to 1.76 s
// of its 2.64 s file (measured with ffmpeg's silence detection, 6 November 2026).

/** The scenes: the logo, the spoken line, the written line, the card leaving, then nothing (the road). */
export type IntroScene = 'splash' | 'spoken' | 'written' | 'leaving' | 'gone'

/** The card's scene starts while the logo leaves: the card comes in at 0.65 s. */
export const SPOKEN_AT = 650
/** His greeting, "Moi! Mä oon Aleksi.", at 0.95 s. */
export const GREETING_AT = 950
/** The dotted line draws down and the written line comes in, while he is still speaking (2.35 s). */
export const WRITTEN_AT = 2350
/** The card leaves, in 0.45 s (4.15 s). */
export const LEAVE_AT = 4150
/** The road comes in under the leaving card (4.2 s). */
export const ROAD_AT = 4200
/** The card is gone. */
export const GONE_AT = 4600

// On the road, in milliseconds from the moment the road comes in (RoadScreen).

/** His bubble with his journey line shows (4.5 s). */
export const BUBBLE_AFTER = 300
/** His journey line (4.65 s). */
export const JOURNEY_AFTER = 450
/** Start comes in about 0.3 s after his words end (4.65 s + 1.76 s + 0.3 s, so about 6.71 s). */
export const START_AFTER = 2510

export interface IntroSteps {
  show: (scene: IntroScene) => void
  say: (clip: string) => Promise<SayResult>
  wait: (ms: number) => Promise<void>
  /** The road comes in (the card is still leaving over it). */
  road: () => void
  /** False once the intro was skipped or left: nothing more happens. */
  live: () => boolean
}

/**
 * Runs the intro's scenes on their own, with no tap, up to the road. Aleksi's greeting is said at its moment;
 * the scenes do not wait for it. True when the card is gone.
 */
export async function playIntro(steps: IntroSteps): Promise<boolean> {
  steps.show('splash')
  await steps.wait(SPOKEN_AT)
  if (!steps.live()) return false
  steps.show('spoken')
  await steps.wait(GREETING_AT - SPOKEN_AT)
  if (!steps.live()) return false
  void steps.say(GREETING_AUDIO)
  await steps.wait(WRITTEN_AT - GREETING_AT)
  if (!steps.live()) return false
  steps.show('written')
  await steps.wait(LEAVE_AT - WRITTEN_AT)
  if (!steps.live()) return false
  steps.show('leaving')
  await steps.wait(ROAD_AT - LEAVE_AT)
  if (!steps.live()) return false
  steps.road()
  await steps.wait(GONE_AT - ROAD_AT)
  if (!steps.live()) return false
  steps.show('gone')
  return true
}
