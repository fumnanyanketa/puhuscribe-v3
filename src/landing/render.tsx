import { renderToString } from 'react-dom/server'
import { Landing } from './Landing.tsx'

// The landing page as HTML, for scripts/landing/prerender.ts (job 17-landing-page). Built for
// Node only; no browser loads this file.

export function renderLanding(): string {
  return renderToString(<Landing />)
}
