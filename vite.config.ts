import { cloudflare } from '@cloudflare/vite-plugin'
import react from '@vitejs/plugin-react'
import { execFileSync } from 'node:child_process'
import { readFileSync } from 'node:fs'
import { defineConfig } from 'vite'

// The browser tests run `vite preview` over HTTPS (PUHUSCRIBE_TEST_HTTPS=1, set
// by playwright.config.ts), with the certificate made by
// scripts/ci/test-https-cert.ts. The sign in cookies are Secure, and WebKit
// drops Secure cookies on plain http://localhost (job 8-first-session).
const testHttps =
  process.env.PUHUSCRIBE_TEST_HTTPS === '1'
    ? {
        key: readFileSync('.wrangler/test-https/key.pem'),
        cert: readFileSync('.wrangler/test-https/cert.pem'),
      }
    : undefined

// The commit this build is made from, which the Worker adds to every crash
// report (worker/app-version.ts, job 14-analytics). GitHub sets GITHUB_SHA;
// elsewhere git is asked. A build with neither says "local".
function appVersion(): string {
  const fromGitHub = process.env.GITHUB_SHA?.trim().toLowerCase().slice(0, 12) ?? ''
  if (/^[0-9a-f]{12}$/.test(fromGitHub)) return fromGitHub
  try {
    const head = execFileSync('git', ['rev-parse', '--short=12', 'HEAD'], { encoding: 'utf8' }).trim()
    return /^[0-9a-f]{7,40}$/.test(head) ? head : 'local'
  } catch {
    return 'local'
  }
}

// https://vite.dev/config/
// The Cloudflare plugin runs the Worker (worker/index.ts) inside the same dev
// server, so the page and /api/* share one address locally and in production.
export default defineConfig({
  plugins: [react(), cloudflare()],
  define: { __APP_VERSION__: JSON.stringify(appVersion()) },
  build: {
    // The oldest browser supported is Safari 15.4 on iPhone (design.md,
    // "Browsers"). CSS is built so that Safari 15.4 understands it.
    cssTarget: ['safari15.4'],
  },
  preview: { https: testHttps },
})
