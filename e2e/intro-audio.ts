import type { BrowserContext, Page } from '@playwright/test'
import { CLIP_MS } from '../src/lib/aleksi-intro.ts'

// Aleksi's intro (fast route intro-logo, version E, 5 November 2026) plays his two clips on its own, with no
// tap. These helpers stand in for the browser's audio playback so the tests are steady in Chromium and WebKit
// alike: each play() is recorded with its clip, whether it was muted, the time in the clip it started from,
// and when it started and ended. A clip "ends" after the rest of its real length (CLIP_MS, measured with
// ffprobe), as a real clip would; pause() ends it at once. With `refuseUntilTap`, play() is refused, as an
// iPhone does, until the first tap or key on the page. They also record when each scene of the intro first
// shows. e2e/intro-logo.spec.ts also runs the intro once with real audio in Chromium.

/** One play() call: the clip's path, whether it was muted, where in the clip it started (s), and its start and end (ms). */
export interface Played {
  src: string
  muted: boolean
  from: number
  refused: boolean
  start: number
  end: number | null
}

/** When a scene first showed, in ms (performance.now()). */
export interface Seen {
  name: string
  at: number
}

/** Replaces audio playback with the stand-in and starts the scene log. Call before the page loads. */
export async function fakeIntroAudio(target: Page | BrowserContext, opts: { refuseUntilTap?: boolean } = {}) {
  await target.addInitScript({
    content: `(() => {
      window.__audio = []
      window.__seen = []
      let tapped = false
      const tap = () => { tapped = true }
      window.addEventListener('pointerdown', tap, { capture: true })
      window.addEventListener('keydown', tap, { capture: true })
      const lengths = ${JSON.stringify(CLIP_MS)}
      // The position the app asks for, as it asks (a browser may ignore a seek in a clip it cannot seek).
      const time = Object.getOwnPropertyDescriptor(HTMLMediaElement.prototype, 'currentTime')
      Object.defineProperty(HTMLMediaElement.prototype, 'currentTime', {
        configurable: true,
        get() { return time.get.call(this) },
        set(value) { this.__asked = value; time.set.call(this, value) },
      })
      HTMLMediaElement.prototype.play = function () {
        const src = new URL(this.src, location.href).pathname
        const from = this.__asked || 0
        const refused = ${String(opts.refuseUntilTap === true)} && !tapped
        const entry = { src, muted: this.muted, from, refused, start: performance.now(), end: null }
        window.__audio.push(entry)
        if (this.__entry && this.__entry.end === null) this.__entry.end = performance.now()
        clearTimeout(this.__timer)
        this.__entry = entry
        if (refused) {
          entry.end = entry.start
          return Promise.reject(new DOMException('blocked', 'NotAllowedError'))
        }
        this.__timer = setTimeout(() => {
          entry.end = performance.now()
          this.dispatchEvent(new Event('ended'))
        }, Math.max(0, (lengths[src] || 1000) - from * 1000))
        return Promise.resolve()
      }
      HTMLMediaElement.prototype.pause = function () {
        clearTimeout(this.__timer)
        if (this.__entry && this.__entry.end === null) this.__entry.end = performance.now()
      }
      const seen = (name) => {
        if (!window.__seen.some((s) => s.name === name)) window.__seen.push({ name, at: performance.now() })
      }
      const look = () => {
        if (document.querySelector('[data-testid="intro-logo"]')) seen('logo')
        const scene = document.querySelector('[data-scene]')
        if (scene) seen('scene:' + scene.getAttribute('data-scene'))
        const speaker = document.querySelector('[data-testid="intro-speaker"]')
        if (speaker) seen('speaker:' + speaker.getAttribute('data-state'))
        if (document.querySelector('ol[aria-label="Stops on your road"]')) seen('road')
        if (document.querySelector('main[data-intro="on"]')) seen('road animation')
        if (document.querySelector('[data-testid="road-bubble"][data-shown="yes"]')) seen('bubble')
        const start = [...document.querySelectorAll('[data-testid="road-start"] button')].find(
          (b) => (b.textContent || '').trim() === 'Start',
        )
        if (start && !start.closest('[data-waits]')) seen('start')
      }
      new MutationObserver(look).observe(document, { childList: true, subtree: true, attributes: true })
    })()`,
  })
}

export const played = (page: Page) => page.evaluate<Played[]>('window.__audio')
export const seen = (page: Page) => page.evaluate<Seen[]>('window.__seen')

/** The plays that sounded (not refused), in order. */
export const sounded = (log: Played[]) => log.filter((entry) => !entry.refused)

/** When a scene first showed, or fails the test if it never did. */
export function at(log: Seen[], name: string): number {
  const found = log.find((s) => s.name === name)
  if (!found) throw new Error(`The scene "${name}" never showed. Seen: ${log.map((s) => s.name).join(', ')}`)
  return found.at
}
