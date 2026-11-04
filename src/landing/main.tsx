import { StrictMode } from 'react'
import { createRoot, hydrateRoot } from 'react-dom/client'
import '@fontsource/poppins/400.css'
import '@fontsource/poppins/500.css'
import '@fontsource/poppins/600.css'
import '@fontsource/poppins/800.css'
import '../styles/tokens.css'
import { Landing } from './Landing.tsx'

// The landing page's script (job 17-landing-page). The built landing.html already holds the whole
// page (scripts/landing/prerender.ts), so this only attaches React to it: the hero phone's road
// animation and the scroll reveal. On a development server the HTML is empty and React draws it.

const root = document.getElementById('root')
if (!root) throw new Error('The page is missing its #root element.')

const page = (
  <StrictMode>
    <Landing />
  </StrictMode>
)

if (root.firstElementChild) hydrateRoot(root, page)
else createRoot(root).render(page)
