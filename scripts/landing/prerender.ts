// Draws the landing page into its built HTML (job 17-landing-page). Runs after `vite build`:
// builds src/landing/render.tsx for Node with Vite, renders the page to HTML with React, and puts
// it inside <div id="root"> of dist/client/landing.html. The page then reads without script, and
// the first paint needs no script. It also preloads the one font file the headline uses.
// Usage: node scripts/landing/prerender.ts
import react from '@vitejs/plugin-react'
import { existsSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs'
import { join, resolve } from 'node:path'
import { pathToFileURL } from 'node:url'
import { build } from 'vite'

const CLIENT = resolve('dist/client')
const PAGE = join(CLIENT, 'landing.html')
const SSR_OUT = resolve('node_modules/.cache/landing-ssr')

if (!existsSync(PAGE)) {
  console.error('landing:prerender: dist/client/landing.html does not exist. Run vite build first.')
  process.exit(1)
}

rmSync(SSR_OUT, { recursive: true, force: true })
await build({
  configFile: false,
  logLevel: 'warn',
  plugins: [react()],
  build: {
    ssr: 'src/landing/render.tsx',
    outDir: SSR_OUT,
    emptyOutDir: true,
    rollupOptions: { output: { entryFileNames: 'render.mjs' } },
  },
})

const { renderLanding } = (await import(pathToFileURL(join(SSR_OUT, 'render.mjs')).href)) as {
  renderLanding: () => string
}
const body = renderLanding()

let html = readFileSync(PAGE, 'utf8')
const slot = /<div id="root">[\s\S]*?<\/div>/
if (!slot.test(html)) {
  console.error('landing:prerender: no <div id="root"> in landing.html.')
  process.exit(1)
}
html = html.replace(slot, () => `<div id="root">${body}</div>`)

// The headline is Poppins 600 and the text under it Poppins 400: preload their Latin files so the
// first screen shows in its own font without waiting for the style sheet to ask for them.
const fonts = readdirSync(join(CLIENT, 'assets')).filter((name) =>
  /^poppins-latin-(400|600)-normal-.*\.woff2$/.test(name),
)
for (const font of fonts) {
  if (html.includes(font)) continue
  html = html.replace(
    '</title>',
    `</title>
    <link rel="preload" href="/assets/${font}" as="font" type="font/woff2" crossorigin />`,
  )
}

writeFileSync(PAGE, html)
rmSync(SSR_OUT, { recursive: true, force: true })
console.log(
  `landing:prerender: drew the page into dist/client/landing.html (${String(body.length)} characters).`,
)
