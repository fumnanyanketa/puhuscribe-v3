import { existsSync, readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'

export const ROOT = join(import.meta.dirname, '..', '..')

// Files these checks never open. .env.cloudflare holds the owner's Cloudflare
// token for account setup; neither Vite nor Wrangler reads it, so it cannot
// reach a build, and agents must not read it.
const NEVER_READ = new Set(['.env.example', '.env.cloudflare'])

// Local env files that Vite or Wrangler may read: .env, .env.local,
// .env.<mode>, .dev.vars and friends. .env.example holds names only.
export function localEnvFiles(root: string = ROOT): string[] {
  return readdirSync(root)
    .filter((name) => (name.startsWith('.env') || name.startsWith('.dev.vars')) && !NEVER_READ.has(name))
    .map((name) => join(root, name))
}

export function readIfExists(path: string): string {
  return existsSync(path) ? readFileSync(path, 'utf8') : ''
}
