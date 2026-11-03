import { useEffect } from 'react'

// The scroll reveal of the approved design (job 17-landing-page): a part below the screen fades and
// rises in as it comes into view. The page's HTML shows every part as it is, so without script,
// without IntersectionObserver or with reduced motion nothing is ever hidden. A part already on the
// screen when the page opens is left alone, so nothing visible blinks.

function reducedMotion(): boolean {
  try {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches
  } catch {
    return true
  }
}

export function useReveal(): void {
  useEffect(() => {
    if (!('IntersectionObserver' in window) || reducedMotion()) return undefined
    const parts = [...document.querySelectorAll<HTMLElement>('[data-reveal]')]
    const seen = new WeakSet<Element>()
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          const part = entry.target as HTMLElement
          if (!seen.has(part)) {
            // The first report says where the part is when the page opens.
            seen.add(part)
            if (entry.isIntersecting || entry.boundingClientRect.top < window.innerHeight) {
              observer.unobserve(part)
              continue
            }
            part.dataset.reveal = 'waiting'
            continue
          }
          if (entry.isIntersecting) {
            part.dataset.reveal = 'in'
            observer.unobserve(part)
          }
        }
      },
      { rootMargin: '0px 0px -12% 0px', threshold: 0.12 },
    )
    for (const part of parts) observer.observe(part)
    return () => {
      observer.disconnect()
    }
  }, [])
}
