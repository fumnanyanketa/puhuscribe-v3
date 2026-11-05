import type { BrowserContext, Page } from '@playwright/test'
import { CLIP_MS } from '../src/lib/aleksi-intro.ts'

// Aleksi's new intro (fast route intro-logo, 5 November 2026) plays three clips after the tap on "Play with
// sound". These helpers stand in for the browser's audio playback so the tests are steady in Chromium and
// WebKit alike: each play() is recorded with its clip and whether it was muted, and "ends" after the clip's
// real length (CLIP_MS, measured with ffprobe), as a real clip would. pause() ends it at once. They also
// record when each scene of the intro first shows. e2e/intro-logo.spec.ts also runs the intro once with
// real audio in Chromium.

/** One play() call: the clip's path, whether it was muted (the unlock inside the tap), and its start and end in ms. */
export interface Played {
  src: string
  muted: boolean
  start: number
  end: number | null
}

/** When a scene first showed, in ms (performance.now()). */
export interface Seen {
  name: string
  at: number
}

/** Replaces audio playback with the stand-in and starts the scene log. Call before the page loads. */
export async function fakeIntroAudio(target: Page | BrowserContext, opts: { refuse?: boolean } = {}) {
  await target.addInitScript({
    content: `(() => {
      window.__audio = []
      window.__seen = []
      const lengths = ${JSON.stringify(CLIP_MS)}
      HTMLMediaElement.prototype.play = function () {
        const src = new URL(this.src, location.href).pathname
        const entry = { src, muted: this.muted, start: performance.now(), end: null }
        window.__audio.push(entry)
        if (this.__entry && this.__entry.end === null) this.__entry.end = performance.now()
        clearTimeout(this.__timer)
        this.__entry = entry
        if (${String(opts.refuse === true)}) {
          entry.end = entry.start
          return Promise.reject(new DOMException('blocked', 'NotAllowedError'))
        }
        this.__timer = setTimeout(() => {
          entry.end = performance.now()
          this.dispatchEvent(new Event('ended'))
        }, lengths[src] || 1000)
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
        if ([...document.querySelectorAll('button')].some((b) => (b.textContent || '').trim() === 'Play with sound'))
          seen('ask')
        const scene = document.querySelector('main[data-scene]')
        if (scene) seen('scene:' + scene.getAttribute('data-scene'))
        if (document.querySelector('ol[aria-label="Stops on your road"]')) seen('road')
        if (document.querySelector('main[data-intro="on"]')) seen('road animation')
        if (document.querySelector('[data-testid="road-bubble"][data-shown="yes"]')) seen('bubble')
        const start = [...document.querySelectorAll('[data-testid="road-start"] button')].find(
          (b) => (b.textContent || '').trim() === 'Start',
        )
        if (start && !start.closest('[data-waits]') && !document.querySelector('main[data-intro="on"]')) seen('start')
      }
      new MutationObserver(look).observe(document, { childList: true, subtree: true, attributes: true })
    })()`,
  })
}

export const played = (page: Page) => page.evaluate<Played[]>('window.__audio')
export const seen = (page: Page) => page.evaluate<Seen[]>('window.__seen')

/** When a scene first showed, or fails the test if it never did. */
export function at(log: Seen[], name: string): number {
  const found = log.find((s) => s.name === name)
  if (!found) throw new Error(`The scene "${name}" never showed. Seen: ${log.map((s) => s.name).join(', ')}`)
  return found.at
}
