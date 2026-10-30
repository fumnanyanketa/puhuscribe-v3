// Runs after every build (job 14-analytics, factory/jobs/14-analytics/spec.md,
// "Done when" 3 and 7). Fails when:
// - a built file's address matches a run_worker_first pattern, so a file
//   would run the Worker (and could be counted as a visit) instead of being
//   served for free;
// - a built page loads a script or style from another site, which would be an
//   outside counter or tracker.
// Usage: node scripts/security/check-built-files.ts [dir]   (default dist/client)
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join, relative, sep } from 'node:path'
import { pathToFileURL } from 'node:url'
import { matchesPattern, RUN_WORKER_FIRST } from '../../worker/page-routes.ts'

/** Every file under a folder, as the address it is served at ("/assets/index-abc.js"). */
export function servedPaths(dir: string): string[] {
  const walk = (path: string): string[] =>
    readdirSync(path).flatMap((name) => {
      const full = join(path, name)
      return statSync(full).isDirectory() ? walk(full) : [full]
    })
  return walk(dir).map((file) => `/${relative(dir, file).split(sep).join('/')}`)
}

/** The served paths that a run_worker_first pattern would send to the Worker. */
export function filesThatRunTheWorker(paths: readonly string[], patterns: readonly string[]): string[] {
  return paths.filter((path) => matchesPattern(path, patterns))
}

/** Scripts, styles and other loaded files in a page that come from another site. */
export function outsideLoads(html: string): string[] {
  const found: string[] = []
  for (const match of html.matchAll(
    /<(script|link|img|iframe)\b[^>]*?\b(src|href)\s*=\s*["']?([^"'\s>]+)/gi,
  )) {
    const address = match[3] ?? ''
    if (/^(https?:)?\/\//i.test(address)) found.push(address)
  }
  return found
}

function main(): void {
  const dir = process.argv[2] ?? join(process.cwd(), 'dist', 'client')
  if (!existsSync(dir)) {
    console.error(`check:built-files: ${dir} does not exist. Run the build first.`)
    process.exit(1)
  }
  const paths = servedPaths(dir)
  const problems = [
    ...filesThatRunTheWorker(paths, RUN_WORKER_FIRST).map(
      (path) => `${path} matches a run_worker_first pattern`,
    ),
    ...paths
      .filter((path) => path.endsWith('.html'))
      .flatMap((path) =>
        outsideLoads(readFileSync(join(dir, path), 'utf8')).map((address) => `${path} loads ${address}`),
      ),
  ]
  if (problems.length > 0) {
    for (const problem of problems) console.error(`check:built-files: ${problem}`)
    process.exit(1)
  }
  console.log(
    `check:built-files: ${String(paths.length)} files checked, none runs the Worker or loads another site.`,
  )
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) main()
