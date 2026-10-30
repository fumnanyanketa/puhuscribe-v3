import { defineConfig, devices, type ReporterDescription } from '@playwright/test'

// Browser tests run against the BUILT app with its Worker (`vite preview` runs
// dist/ in the local Workers runtime). Run `npm run build` first.
// Phone size 375 x 812 on Chromium and on WebKit (the closest stand in for
// iPhone Safari). Screenshots and video are kept for every test.
//
// To test a preview link instead, set PLAYWRIGHT_BASE_URL to it. When
// CF_ACCESS_CLIENT_ID and CF_ACCESS_CLIENT_SECRET are set (the evaluator's
// Cloudflare Access service token), every request carries them so Access lets
// the tests through.
//
// Those two headers must never be written to a file. Traces, HAR files and the
// HTML report can all hold request headers (a trace leaked the token once), so
// with the headers set: no trace, no HAR, no HTML report. Screenshots and
// videos hold pixels only.

const PORT = 4173
// The local test server runs over HTTPS with a self-signed certificate
// (scripts/ci/test-https-cert.ts): the sign in cookies are Secure, and WebKit
// drops Secure cookies on plain http://localhost (job 8-first-session).
const LOCAL = `https://localhost:${String(PORT)}`
const phone = { viewport: { width: 375, height: 812 }, isMobile: false, hasTouch: true }
const JOURNEY = /analytics-journey\.spec\.ts$/

const accessId = process.env.CF_ACCESS_CLIENT_ID
const accessSecret = process.env.CF_ACCESS_CLIENT_SECRET
const usesAccessToken = Boolean(accessId && accessSecret)
const accessHeaders: Record<string, string> =
  accessId && accessSecret ? { 'CF-Access-Client-Id': accessId, 'CF-Access-Client-Secret': accessSecret } : {}

// PUHUSCRIBE_NO_TRACE=1 is set in every CI job that has the private Switzer font
// files. A trace or an HTML report holds every file the page loaded, fonts
// included, and a public repository's Actions artifacts are public.
const noTrace = process.env.PUHUSCRIBE_NO_TRACE === '1'
const keepsNoDebugFiles = usesAccessToken || noTrace

const reporter: ReporterDescription[] =
  process.env.CI && !keepsNoDebugFiles ? [['list'], ['html', { open: 'never' }]] : [['list']]

export default defineConfig({
  testDir: 'e2e',
  forbidOnly: Boolean(process.env.CI),
  retries: 0,
  reporter,
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL ?? LOCAL,
    // Only the local server's own self-signed certificate; preview links have real ones.
    ignoreHTTPSErrors: !process.env.PLAYWRIGHT_BASE_URL,
    extraHTTPHeaders: accessHeaders,
    screenshot: 'on',
    video: 'on',
    trace: keepsNoDebugFiles ? 'off' : 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', testIgnore: JOURNEY, use: { ...devices['Desktop Chrome'], ...phone } },
    { name: 'webkit', testIgnore: JOURNEY, use: { ...devices['Desktop Safari'], ...phone } },
    // Job 14-analytics, "Done when" 12: the owner page journey reads totals
    // that every other test also moves (visits, learners, sessions), so it
    // runs alone, after both browsers have finished.
    {
      name: 'journey',
      testMatch: JOURNEY,
      dependencies: ['chromium', 'webkit'],
      use: { ...devices['Desktop Chrome'], ...phone },
    },
  ],
  webServer: process.env.PLAYWRIGHT_BASE_URL
    ? undefined
    : {
        command: `node scripts/ci/test-https-cert.ts && npx vite preview --port ${String(PORT)} --strictPort`,
        env: { PUHUSCRIBE_TEST_HTTPS: '1' },
        url: `${LOCAL}/api/health`,
        ignoreHTTPSErrors: true,
        reuseExistingServer: !process.env.CI,
        timeout: 60_000,
      },
})
