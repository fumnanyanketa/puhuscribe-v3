import { lazy, StrictMode, Suspense } from 'react'
import { createRoot } from 'react-dom/client'
import { App } from './App.tsx'
import { CrashBoundary } from './components/CrashBoundary.tsx'
import { forwardFor } from './lib/app-paths.ts'
import { installCrashReporter } from './lib/crash-reporter.ts'
import './styles/tokens.css'
import './styles/fonts.css'
import './styles/base.css'

// Errors nobody caught are reported without anything that identifies the learner (job 14-analytics).
installCrashReporter()

const root = document.getElementById('root')
if (!root) throw new Error('The page is missing its #root element.')

// The design pages (job 5-design-system): the reference page and the Hear it
// sample. They exist only in local development and in builds made with
// VITE_DESIGN_REFERENCE=1 (the GitHub checks and preview links). In any other
// build this condition is false when Vite builds the app, so their code and
// their unreviewed Finnish are left out of the files
// (tests/design-build.test.ts proves it).
const designPagesOn = import.meta.env.DEV || import.meta.env.VITE_DESIGN_REFERENCE === '1'
const HearItSample = designPagesOn ? lazy(() => import('./sample/HearItSample.tsx')) : null
const DesignReference = designPagesOn ? lazy(() => import('./design-reference/DesignReference.tsx')) : null
// The island step and card with the approved lines and no database (language islands).
const IslandSample = designPagesOn ? lazy(() => import('./sample/IslandSample.tsx')) : null

const path = window.location.pathname.replace(/\/+$/, '')
let page = <App path={path} />
if (HearItSample && path === '/sample/hear-it') page = <HearItSample />
if (DesignReference && path === '/design-reference') page = <DesignReference />
if (IslandSample && path === '/sample/island') page = <IslandSample />
const designPage = page.type !== App

// The app lives under /learn (job 17-landing-page). An old address forwards to
// its new one before anything is drawn, so the old page never flashes, and any
// other address outside /learn goes to the landing page. The target comes from
// a fixed map in src/lib/app-paths.ts, never from the address itself. The
// Worker answers "/" with the landing page, so the shell meets "/" only on a
// development server, where it stays put instead of reloading forever.
const forward =
  designPage || path === '' ? null : forwardFor(path, window.location.search, window.location.hash)
if (forward !== null) {
  window.location.replace(forward)
} else {
  createRoot(root).render(
    <StrictMode>
      <CrashBoundary>
        <Suspense fallback={null}>{page}</Suspense>
      </CrashBoundary>
    </StrictMode>,
  )
}
