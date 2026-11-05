import { finished, startExclusive } from '../components/play-registry.ts'
import { CLIP_MS, GREETING_AUDIO, GREETING_WRITTEN_AUDIO } from './aleksi-intro.ts'

// Aleksi's voice in the new intro (fast route intro-logo, owner approved 5 November 2026). Browsers play
// sound only after a tap, and an iPhone allows it only on an audio element that was started inside a tap.
// So the intro uses one audio element for all three clips: "Play with sound" starts it inside the tap
// (unlock, muted, stopped at once), and every later clip plays on that same element. Nothing is made or
// played before that tap. Each clip starts only after the one before it has ended: the scenes below wait
// for each clip's end before they go on. A clip that cannot play (no sound, a failed file) is waited out
// for its own length, so the scenes keep their pace; a clip that never ends is given up after its length
// plus five seconds, so the intro always ends.

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

/** How a clip finished: it played to its end, it could not play, or the intro stopped it (Skip, leaving). */
export type SayResult = 'ended' | 'failed' | 'stopped'

/** The clock and timers the voice uses, so the tests can drive time. */
export interface VoiceTimers {
  now: () => number
  set: (run: () => void, ms: number) => number
  clear: (handle: number) => void
}

const browserTimers: VoiceTimers = {
  now: () => Date.now(),
  set: (run, ms) => window.setTimeout(run, ms),
  clear: (handle) => {
    window.clearTimeout(handle)
  },
}

/** A clip that has not ended this long after its own length is given up. */
export const STALL_MS = 5000

const browserAudio = (): VoiceElement => {
  const element = new Audio()
  element.preload = 'auto'
  return element
}

export class IntroVoice {
  private element: VoiceElement | null = null
  private current: string | null = null
  private unlocking: Promise<void> = Promise.resolve()
  private finish: ((result: SayResult) => void) | null = null
  private readonly make: () => VoiceElement
  private readonly timers: VoiceTimers
  private readonly stopThis = () => {
    this.stop()
  }

  constructor(make: () => VoiceElement = browserAudio, timers: VoiceTimers = browserTimers) {
    this.make = make
    this.timers = timers
  }

  private audio(): VoiceElement {
    this.element ??= this.make()
    return this.element
  }

  /**
   * Called inside the learner's tap on "Play with sound", and only there: starts the one audio element
   * muted and stops it at once, so the browser lets it play the clips that follow. It also starts loading
   * the first clip.
   */
  unlock(firstClip: string): void {
    const element = this.audio()
    element.src = firstClip
    this.current = firstClip
    element.muted = true
    this.unlocking = element
      .play()
      .then(
        () => {
          element.pause()
          element.currentTime = 0
        },
        () => undefined,
      )
      .then(() => {
        element.muted = false
      })
  }

  /** Plays one clip to its end. Any clip still playing is stopped first. */
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
        finished(this.stopThis)
        if (this.finish === stopNow) this.finish = null
        resolve(result)
      }
      const onEnded = () => {
        end('ended')
      }
      // A clip that cannot play is waited out for its own length, so the scenes keep their pace.
      const onError = () => {
        if (done || pacing !== null) return
        element.pause()
        const left = Math.max(0, started + length - this.timers.now())
        pacing = this.timers.set(() => {
          end('failed')
        }, left)
      }
      const stopNow = (result: SayResult) => {
        element.pause()
        end(result)
      }
      const stall = this.timers.set(() => {
        stopNow('failed')
      }, length + STALL_MS)
      this.finish = stopNow
      startExclusive(this.stopThis)
      void this.unlocking.then(() => {
        if (done) return
        if (this.current === clip) element.currentTime = 0
        else {
          element.src = clip
          this.current = clip
        }
        element.muted = false
        element.addEventListener('ended', onEnded)
        element.addEventListener('error', onError)
        element.play().catch(onError)
      })
    })
  }

  /** Stops the clip that is playing, if any (Skip, or the intro leaving the page). */
  stop(): void {
    this.finish?.('stopped')
  }
}

// The lesson card's scenes (src/screens/AleksiIntro.tsx), as in the owner's prototype, version D
// (design-drafts/intro-flow/intro-flow-d-aleksi.html). Each scene's look and motion is in the CSS; this is
// the order and the waits. The times are in milliseconds from the start of each scene.

/** The card's scenes: the spoken line, then the written line, then the card leaves. */
export type CardScene = 'spoken' | 'written' | 'leaving'

/** The greeting starts once the card is up and the spoken line is in (the card comes in from 0.3 s to 1.0 s, the line from 1.0 s). */
export const GREETING_AT = 1100
/** The written greeting starts once the dotted line has drawn down and the written line is in (0.75 s). */
export const WRITTEN_AT = 800
/** After the written greeting ends, the card stays this long before it leaves. */
export const HOLD_MS = 500
/** The card leaves in 0.6 s; then the road opens. */
export const LEAVE_MS = 600

export interface CardSteps {
  show: (scene: CardScene) => void
  say: (clip: string) => Promise<SayResult>
  wait: (ms: number) => Promise<void>
  /** False once the intro was skipped or left: nothing more happens. */
  live: () => boolean
}

/** Runs the card's scenes and its two clips in order. True when the card has left, false when stopped. */
export async function playCard(steps: CardSteps): Promise<boolean> {
  steps.show('spoken')
  await steps.wait(GREETING_AT)
  if (!steps.live()) return false
  await steps.say(GREETING_AUDIO)
  if (!steps.live()) return false
  steps.show('written')
  await steps.wait(WRITTEN_AT)
  if (!steps.live()) return false
  await steps.say(GREETING_WRITTEN_AUDIO)
  if (!steps.live()) return false
  await steps.wait(HOLD_MS)
  if (!steps.live()) return false
  steps.show('leaving')
  await steps.wait(LEAVE_MS)
  return steps.live()
}
