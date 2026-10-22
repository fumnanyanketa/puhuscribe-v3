// Runs before every build: fails if any variable whose name says it is secret
// starts with VITE_. Vite copies VITE_ variables into the browser files.
import { readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { localEnvFiles, readIfExists, ROOT } from './env-files.ts'
import { findUnsafeViteNames, namesFromEnvFile, viteNamesUsedInSource } from './secrets.ts'

function sourceFiles(dir: string): string[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name)
    if (statSync(path).isDirectory()) return sourceFiles(path)
    return /\.(ts|tsx|js|jsx)$/.test(name) ? [path] : []
  })
}

const names = new Set<string>(Object.keys(process.env))
for (const file of [join(ROOT, '.env.example'), ...localEnvFiles()]) {
  for (const name of namesFromEnvFile(readIfExists(file))) names.add(name)
}
for (const file of sourceFiles(join(ROOT, 'src'))) {
  for (const name of viteNamesUsedInSource(readFileSync(file, 'utf8'))) names.add(name)
}

const unsafe = findUnsafeViteNames(names)
if (unsafe.length > 0) {
  console.error('Secret looking variables must not start with VITE_ (Vite sends them to the browser):')
  for (const name of unsafe) console.error(`  ${name}`)
  process.exit(1)
}
console.log(`check:env-names passed (${String(names.size)} variable names checked).`)
