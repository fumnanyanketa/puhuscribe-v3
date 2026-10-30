// Makes a local stand in for the owner page's Cloudflare Access key, for the
// browser tests only (factory/jobs/14-analytics/spec.md, "Done when" 14 and
// 27; "Dependencies": the owner host is tested locally with a locally made
// Access key).
//
//   node scripts/ci/test-owner-access.ts >> .env.local
//
// Writes a new RSA key pair to .wrangler/test-owner-access/ (git ignores
// .wrangler/): the private key, which e2e/owner-helpers.ts signs test tokens
// with, and the made-up team domain and AUD tag. Prints the four Worker
// variables for .env.local: the owner host is 127.0.0.1 (the app host stays
// localhost), and the Worker checks tokens against the printed public key set.
// worker/owner.ts trusts that key set only while OWNER_HOSTNAME is this
// computer, so it can never open a live owner page. Nothing printed is secret.
import { randomBytes } from 'node:crypto'
import { mkdirSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'
import { exportJWK, generateKeyPair } from 'jose'

export const TEST_OWNER_DIR = join('.wrangler', 'test-owner-access')
export const TEST_OWNER_HOST = '127.0.0.1'
export const TEST_TEAM_DOMAIN = 'https://puhuscribe-test.cloudflareaccess.com'

const { publicKey, privateKey } = await generateKeyPair('RS256', { extractable: true })
const kid = randomBytes(8).toString('hex')
const publicJwk = { ...(await exportJWK(publicKey)), kid, alg: 'RS256', use: 'sig' }
const privateJwk = { ...(await exportJWK(privateKey)), kid, alg: 'RS256' }
const aud = randomBytes(32).toString('hex')

mkdirSync(TEST_OWNER_DIR, { recursive: true })
writeFileSync(
  join(TEST_OWNER_DIR, 'access.json'),
  JSON.stringify({ host: TEST_OWNER_HOST, teamDomain: TEST_TEAM_DOMAIN, aud, privateJwk }),
  { mode: 0o600 },
)

process.stdout.write(
  [
    `OWNER_HOSTNAME=${TEST_OWNER_HOST}`,
    `OWNER_ACCESS_TEAM_DOMAIN=${TEST_TEAM_DOMAIN}`,
    `OWNER_ACCESS_AUD=${aud}`,
    `OWNER_ACCESS_LOCAL_JWKS='${JSON.stringify({ keys: [publicJwk] })}'`,
    '',
  ].join('\n'),
)
