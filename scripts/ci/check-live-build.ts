// Checks the production build before the live workflow deploys it (job go-live).
// Run after `CLOUDFLARE_ENV=production VITE_DESIGN_REFERENCE=0 npm run build`.
// It finds:
//   - a Worker config that is not the live Worker "aleksi" on meetaleksi.com and
//     www.meetaleksi.com only, with no workers.dev and no preview addresses,
//   - a Worker config that sets anything but CANONICAL_HOST, such as the fake
//     speech provider or the owner page's local test key,
//   - a design reference page or sample in the browser files,
//   - a landing page whose og:url is not https://meetaleksi.com/.
// It reads only the files the build wrote, never .env files. Prints file names
// and rule names only.
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'

export const LIVE_WORKER = 'aleksi'
export const LIVE_ROUTES = [
  { pattern: 'meetaleksi.com', custom_domain: true },
  { pattern: 'www.meetaleksi.com', custom_domain: true },
]
export const LIVE_ORIGIN = 'https://meetaleksi.com/'

/** Text only the design pages hold (the same markers as tests/design-build.test.ts). */
export const DESIGN_MARKERS = [
  'Design reference',
  'design-reference',
  'sample/hear-it',
  'sample/island',
  'Sample, not reviewed',
  'Try the states',
]

interface BuiltConfig {
  name?: unknown
  workers_dev?: unknown
  preview_urls?: unknown
  routes?: unknown
  vars?: unknown
  assets?: { directory?: unknown }
}

function allFiles(dir: string): string[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name)
    return statSync(path).isDirectory() ? allFiles(path) : [path]
  })
}

/** The Worker config the build wrote, found through .wrangler/deploy/config.json as wrangler finds it. */
export function builtConfigPath(root: string): string | null {
  const pointer = join(root, '.wrangler', 'deploy', 'config.json')
  if (!existsSync(pointer)) return null
  const { configPath } = JSON.parse(readFileSync(pointer, 'utf8')) as { configPath?: unknown }
  if (typeof configPath !== 'string') return null
  return resolve(dirname(pointer), configPath)
}

export function checkLiveBuild(root: string): string[] {
  const problems: string[] = []
  const configPath = builtConfigPath(root)
  if (configPath === null || !existsSync(configPath))
    return ['The build wrote no Worker config. Run the build first.']
  const config = JSON.parse(readFileSync(configPath, 'utf8')) as BuiltConfig
  if (config.name !== LIVE_WORKER)
    problems.push(`The built Worker is not named ${LIVE_WORKER}. Was CLOUDFLARE_ENV=production set?`)
  if (config.workers_dev !== false) problems.push('The built Worker would get a workers.dev address.')
  if (config.preview_urls !== false) problems.push('The built Worker would get preview addresses.')
  if (JSON.stringify(config.routes) !== JSON.stringify(LIVE_ROUTES))
    problems.push('The built Worker is not attached to exactly meetaleksi.com and www.meetaleksi.com.')
  const vars = typeof config.vars === 'object' && config.vars !== null ? Object.keys(config.vars) : []
  if (JSON.stringify(vars) !== JSON.stringify(['CANONICAL_HOST']))
    problems.push(`The built Worker sets variables other than CANONICAL_HOST: ${vars.join(', ')}`)
  const text = readFileSync(configPath, 'utf8')
  for (const name of ['SPEECH_FEEDBACK_PROVIDER', 'OWNER_ACCESS_LOCAL_JWKS', 'puhuscribe-preview.fumnanya'])
    if (text.includes(name)) problems.push(`The built Worker config names ${name}.`)

  const client =
    typeof config.assets?.directory === 'string' ? resolve(dirname(configPath), config.assets.directory) : ''
  if (!client || !existsSync(client)) return [...problems, 'The build wrote no browser files.']
  for (const file of allFiles(client).filter((path) => /\.(js|css|html)$/.test(path))) {
    const body = readFileSync(file, 'utf8')
    for (const marker of DESIGN_MARKERS)
      if (body.includes(marker))
        problems.push(`${file.slice(client.length + 1)} holds design page text ("${marker}").`)
  }
  const landing = join(client, 'landing.html')
  const page = existsSync(landing) ? readFileSync(landing, 'utf8') : ''
  if (!page.includes(`<meta property="og:url" content="${LIVE_ORIGIN}"`))
    problems.push('landing.html has no og:url of https://meetaleksi.com/.')
  return problems
}

if (import.meta.main) {
  const problems = checkLiveBuild('.')
  for (const problem of problems) console.error(problem)
  if (problems.length === 0)
    console.log(
      'The build is the live Worker aleksi on meetaleksi.com, with no design pages and the live landing address.',
    )
  process.exit(problems.length === 0 ? 0 : 1)
}
