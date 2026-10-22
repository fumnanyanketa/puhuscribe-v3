import { cloudflare } from '@cloudflare/vite-plugin'
import react from '@vitejs/plugin-react'
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

// https://vite.dev/config/
// The Cloudflare plugin runs the Worker (worker/index.ts) inside the same dev
// server, so the page and /api/* share one address locally and in production.
export default defineConfig({
  plugins: [react(), cloudflare()],
  build: {
    // The oldest browser supported is Safari 15.4 on iPhone (design.md,
    // "Browsers"). CSS is built so that Safari 15.4 understands it.
    cssTarget: ['safari15.4'],
  },
  preview: { https: testHttps },
})
