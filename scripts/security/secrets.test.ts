import { describe, expect, it } from 'vitest'
import {
  findKeyPatterns,
  findSecretNamesInText,
  findUnsafeViteNames,
  isSecretName,
  namesFromEnvFile,
  secretValuesFromEnvFile,
  viteNamesUsedInSource,
} from './secrets.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/1-stack/spec.md that each test protects.
//
// Key shaped test strings are assembled from pieces at run time, so this file
// does not itself contain anything a secret scanner would flag.
const fake = (prefix: string, body: string) => prefix + body

describe('secret names', () => {
  it('[8] treats KEY, SECRET, TOKEN, PASSWORD and database URLs as secret names', () => {
    expect(isSecretName('SUPABASE_PUBLISHABLE_KEY')).toBe(true)
    expect(isSecretName('CF_ACCESS_CLIENT_SECRET')).toBe(true)
    expect(isSecretName('CLOUDFLARE_API_TOKEN')).toBe(true)
    expect(isSecretName('DB_PASSWORD')).toBe(true)
    expect(isSecretName('SUPABASE_DB_URL')).toBe(true)
    expect(isSecretName('SUPABASE_URL')).toBe(false)
    expect(isSecretName('VITE_APP_NAME')).toBe(false)
  })

  it('[8] flags any VITE_ variable whose name says it is secret', () => {
    expect(
      findUnsafeViteNames([
        'VITE_SUPABASE_KEY',
        'VITE_APP_NAME',
        'SUPABASE_KEY',
        'VITE_API_TOKEN',
        'VITE_DB_URL',
      ]),
    ).toEqual(['VITE_SUPABASE_KEY', 'VITE_API_TOKEN', 'VITE_DB_URL'])
  })

  it('[8] finds VITE_ names used in browser source code', () => {
    const source = 'const a = import.meta.env.VITE_SECRET_THING\nconst b = import.meta.env.MODE'
    expect(viteNamesUsedInSource(source)).toEqual(['VITE_SECRET_THING'])
  })
})

describe('env files', () => {
  const example = [
    '# Comment mentioning CLOUDFLARE_API_TOKEN as a GitHub secret',
    'SUPABASE_URL=',
    'SUPABASE_PUBLISHABLE_KEY=   # purpose',
    'export SUPABASE_DB_URL=',
    '',
  ].join('\n')

  it('[9] reads variable names from assignments and from comments', () => {
    expect(namesFromEnvFile(example)).toEqual([
      'CLOUDFLARE_API_TOKEN',
      'SUPABASE_URL',
      'SUPABASE_PUBLISHABLE_KEY',
      'SUPABASE_DB_URL',
    ])
  })

  it('[8] collects only the values of secret named variables, never empty ones', () => {
    const local = 'SUPABASE_URL=https://x.supabase.co\nSUPABASE_PUBLISHABLE_KEY="abc123value"\nEMPTY_KEY=\n'
    expect(secretValuesFromEnvFile(local)).toEqual([
      { name: 'SUPABASE_PUBLISHABLE_KEY', value: 'abc123value' },
    ])
  })
})

describe('built browser files', () => {
  it('[8] flags a known secret name in a built file', () => {
    expect(
      findSecretNamesInText('fetch(x,{h:"SUPABASE_PUBLISHABLE_KEY"})', ['SUPABASE_PUBLISHABLE_KEY']),
    ).toEqual(['SUPABASE_PUBLISHABLE_KEY'])
  })

  it('[8] does not flag a secret name that is only part of a longer word', () => {
    expect(findSecretNamesInText('MY_SUPABASE_PUBLISHABLE_KEYS', ['SUPABASE_PUBLISHABLE_KEY'])).toEqual([])
  })

  it.each([
    ['Supabase secret key', fake('sb_' + 'secret_', 'x1'.repeat(10))],
    ['JSON web token', fake('eyJhbGciOiJIUzI1NiJ9', '.eyJyb2xlIjoic2VydmljZV9yb2xlIn0.c2lnbmF0dXJl')],
    ['Anthropic key', fake('sk-ant-', 'api03-Abcdefghijklmnopqrstuvwx')],
    ['AWS access key', fake('AKIA', 'ABCDEFGHIJKLMNOP')],
    ['private key', fake('-----BEGIN RSA ', 'PRIVATE KEY-----')],
    [
      'database URL with password',
      fake('postgresql://postgres.ref:', 'hunter2pass@aws-0-eu-central-1.pooler.supabase.com:5432/postgres'),
    ],
    ['Cloudflare Access service token secret', fake('cfast_', 'Abcdefghijklmnopqrstuvwxyz012345')],
    ['GitHub token', fake('ghp_', 'Abcdefghijklmnopqrstuvwxyz0123456789')],
  ])('[8] flags a %s pattern', (label, value) => {
    expect(findKeyPatterns(`var x="${value}";`).map((f) => f.label)).toContain(label)
  })

  it('[8] does not flag ordinary minified app code', () => {
    const code =
      'function t(e){return e.status==="ok"?"Server: ok":"Server: not reachable"}fetch("/api/health")'
    expect(findKeyPatterns(code)).toEqual([])
  })
})
