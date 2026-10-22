// Shared rules for keeping keys out of the browser. Used by
// check-env-names.ts (before the build) and check-built-secrets.ts (after it).
// Findings name the variable or the pattern, never the secret value itself.

const SECRET_NAME_PARTS = ['KEY', 'SECRET', 'TOKEN', 'PASSWORD', 'DB_URL', 'DATABASE_URL']

export function isSecretName(name: string): boolean {
  return SECRET_NAME_PARTS.some((part) => name.includes(part))
}

// Vite copies every VITE_ variable into the browser files, so a secret must
// never carry that prefix.
export function findUnsafeViteNames(names: Iterable<string>): string[] {
  return [...new Set(names)].filter((name) => name.startsWith('VITE_') && isSecretName(name))
}

export function viteNamesUsedInSource(source: string): string[] {
  return [...new Set([...source.matchAll(/\bVITE_[A-Z0-9_]+\b/g)].map((m) => m[0]))]
}

const ENV_NAME = /\b[A-Z][A-Z0-9_]{2,}\b/g
const ASSIGNMENT = /^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=(.*)$/

// Every variable name mentioned in an env file, from assignments and from
// comments (GitHub only secrets are listed in comments in .env.example).
export function namesFromEnvFile(text: string): string[] {
  const names: string[] = []
  for (const line of text.split(/\r?\n/)) {
    const assignment = ASSIGNMENT.exec(line)
    if (assignment?.[1]) {
      names.push(assignment[1])
      const comment = (assignment[2] ?? '').split('#')[1] ?? ''
      names.push(...(comment.match(ENV_NAME) ?? []).filter(isEnvLikeName))
    } else if (line.trim().startsWith('#')) {
      names.push(...(line.match(ENV_NAME) ?? []).filter(isEnvLikeName))
    }
  }
  return [...new Set(names)]
}

function isEnvLikeName(word: string): boolean {
  return word.includes('_')
}

function unquote(raw: string): string {
  const value = raw.trim()
  const quoted = /^(['"])(.*)\1$/.exec(value)
  if (quoted) return quoted[2] ?? ''
  return (value.split(/\s+#/)[0] ?? '').trim()
}

export interface SecretValue {
  name: string
  value: string
}

export function secretValuesFromEnvFile(text: string): SecretValue[] {
  const values: SecretValue[] = []
  for (const line of text.split(/\r?\n/)) {
    const assignment = ASSIGNMENT.exec(line)
    const name = assignment?.[1]
    if (!name || !isSecretName(name)) continue
    const value = unquote(assignment[2] ?? '')
    if (value.length >= 8) values.push({ name, value })
  }
  return values
}

function escapeRegExp(text: string): string {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

export function findSecretNamesInText(text: string, secretNames: Iterable<string>): string[] {
  return [...new Set(secretNames)].filter((name) =>
    new RegExp(`(?<![A-Za-z0-9_])${escapeRegExp(name)}(?![A-Za-z0-9_])`).test(text),
  )
}

const KEY_PATTERNS: { label: string; pattern: RegExp }[] = [
  { label: 'Supabase secret key', pattern: /sb_secret_[A-Za-z0-9_-]{10,}/ },
  { label: 'JSON web token', pattern: /eyJ[A-Za-z0-9_-]{8,}\.eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}/ },
  { label: 'Anthropic key', pattern: /sk-ant-[A-Za-z0-9_-]{20,}/ },
  { label: 'AWS access key', pattern: /\b(?:AKIA|ASIA)[0-9A-Z]{16}\b/ },
  { label: 'private key', pattern: /-----BEGIN [A-Z ]*PRIVATE KEY-----/ },
  { label: 'database URL with password', pattern: /postgres(?:ql)?:\/\/[^\s:/@"'`]+:[^\s@/"'`]+@/ },
  { label: 'Cloudflare Access service token secret', pattern: /cfast_[A-Za-z0-9_-]{20,}/ },
  { label: 'GitHub token', pattern: /\bgh[pousr]_[A-Za-z0-9]{36,}\b/ },
]

export interface PatternFinding {
  label: string
}

export function findKeyPatterns(text: string): PatternFinding[] {
  return KEY_PATTERNS.filter(({ pattern }) => pattern.test(text)).map(({ label }) => ({ label }))
}
