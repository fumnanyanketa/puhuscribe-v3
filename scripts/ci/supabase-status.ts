// Reads the output of `supabase status -o env` for the throwaway local
// Supabase in the pull request browser check (factory/jobs/6-pr-local-db,
// "Done when" 2) and keeps only the two settings the Worker needs: the local
// API address and the local publishable key. The secret key, the service role
// key and the JWT secret in the same output are dropped.
// The address must be on the runner itself (127.0.0.1 or localhost), so this
// path can never point the app at a hosted database.
// Errors name variables, never a value.

const LOCAL_HOSTS = new Set(['127.0.0.1', 'localhost'])

export interface LocalSettings {
  SUPABASE_URL: string
  SUPABASE_PUBLISHABLE_KEY: string
}

function parseEnv(text: string): Map<string, string> {
  const found = new Map<string, string>()
  for (const line of text.split(/\r?\n/)) {
    const match = /^([A-Z][A-Z0-9_]*)=(.*)$/.exec(line.trim())
    if (!match?.[1]) continue
    let value = (match[2] ?? '').trim()
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) value = value.slice(1, -1)
    found.set(match[1], value)
  }
  return found
}

function isLocalAddress(value: string): boolean {
  try {
    const url = new URL(value)
    return url.protocol === 'http:' && LOCAL_HOSTS.has(url.hostname)
  } catch {
    return false
  }
}

export function localSettingsFromStatus(text: string): LocalSettings {
  const env = parseEnv(text)
  const url = env.get('API_URL')
  const key = env.get('PUBLISHABLE_KEY')
  const missing = [...(url ? [] : ['API_URL']), ...(key ? [] : ['PUBLISHABLE_KEY'])]
  if (!url || !key) {
    throw new Error(
      `supabase status did not give ${missing.join(' and ')}. Names it gave: ${[...env.keys()].sort().join(', ')}`,
    )
  }
  if (!isLocalAddress(url)) {
    throw new Error('API_URL is not a local address (http on 127.0.0.1 or localhost); refusing to use it.')
  }
  return { SUPABASE_URL: url, SUPABASE_PUBLISHABLE_KEY: key }
}
