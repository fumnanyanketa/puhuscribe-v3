// Makes a self-signed certificate for https://localhost, used only by the
// local browser test server (playwright.config.ts starts `vite preview` over
// HTTPS with it). The sign in cookies are always Secure, and WebKit drops
// Secure cookies on plain http://localhost (checked 21 October 2026 with
// Playwright's WebKit; factory/jobs/8-first-session/build.md), so the tests
// run over HTTPS instead of weakening the cookie.
//   node scripts/ci/test-https-cert.ts
// The files go to .wrangler/test-https/ (git ignored), are made once, last 30
// days and are worth nothing outside this machine. Needs openssl (Git for
// Windows and GitHub's Ubuntu runners have it). Prints only the folder.
import { execFileSync } from 'node:child_process'
import { existsSync, mkdirSync, statSync } from 'node:fs'

export const TEST_HTTPS_DIR = '.wrangler/test-https'
export const TEST_HTTPS_KEY = `${TEST_HTTPS_DIR}/key.pem`
export const TEST_HTTPS_CERT = `${TEST_HTTPS_DIR}/cert.pem`

const MAX_AGE_MS = 20 * 24 * 60 * 60 * 1000

function fresh(path: string): boolean {
  return existsSync(path) && Date.now() - statSync(path).mtimeMs < MAX_AGE_MS
}

if (!fresh(TEST_HTTPS_KEY) || !fresh(TEST_HTTPS_CERT)) {
  mkdirSync(TEST_HTTPS_DIR, { recursive: true })
  execFileSync(
    'openssl',
    [
      'req',
      '-x509',
      '-newkey',
      'rsa:2048',
      '-nodes',
      '-keyout',
      TEST_HTTPS_KEY,
      '-out',
      TEST_HTTPS_CERT,
      '-days',
      '30',
      '-subj',
      '/CN=localhost',
      '-addext',
      'subjectAltName=DNS:localhost,IP:127.0.0.1',
    ],
    { stdio: 'ignore' },
  )
}
console.log(`Test HTTPS certificate ready in ${TEST_HTTPS_DIR}`)
