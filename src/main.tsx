import { lazy, StrictMode, Suspense } from 'react'
import { createRoot } from 'react-dom/client'
import { App } from './App.tsx'
import './styles/tokens.css'
import './styles/fonts.css'
import './styles/base.css'

// Switzer (body text) is not in this public repository. When the files were
// fetched (scripts/ci/fetch-private-fonts.ts, docs/fonts.md) this glob finds the
// generated switzer.css and imports it. When they were not, the glob finds
// nothing and the body text uses the fallback fonts.
import.meta.glob('./assets/fonts/switzer/switzer.css', { eager: true })

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

const path = window.location.pathname.replace(/\/+$/, '')
let page = <App path={path} />
if (HearItSample && path === '/sample/hear-it') page = <HearItSample />
if (DesignReference && path === '/design-reference') page = <DesignReference />

createRoot(root).render(
  <StrictMode>
    <Suspense fallback={null}>{page}</Suspense>
  </StrictMode>,
)
