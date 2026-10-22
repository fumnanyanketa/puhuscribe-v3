// Runs after every build: fails if any browser file in dist/client contains a
// known secret name, a key shaped string, or the value of a local secret.
// Findings name the file and the variable or pattern, never the value.
// Usage: node scripts/security/check-built-secrets.ts [dir]   (default dist/client)
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join, relative } from 'node:path'
import { localEnvFiles, readIfExists, ROOT } from './env-files.ts'
import {
  findKeyPatterns,
  findSecretNamesInText,
  isSecretName,
  namesFromEnvFile,
  secretValuesFromEnvFile,
  type SecretValue,
} from './secrets.ts'

const dir = process.argv[2] ?? join(ROOT, 'dist', 'client')
if (!existsSync(dir)) {
  console.error(`check:built-secrets: ${dir} does not exist. Run the build first.`)
  process.exit(1)
}

function files(path: string): string[] {
  return readdirSync(path).flatMap((name) => {
    const full = join(path, name)
    return statSync(full).isDirectory() ? files(full) : [full]
  })
}

const envFiles = [join(ROOT, '.env.example'), ...localEnvFiles()]
const secretNames = envFiles.flatMap((file) => namesFromEnvFile(readIfExists(file))).filter(isSecretName)
const secretValues: SecretValue[] = [
  ...localEnvFiles().flatMap((file) => secretValuesFromEnvFile(readIfExists(file))),
  ...Object.entries(process.env)
    .filter(([name, value]) => isSecretName(name) && value !== undefined && value.length >= 8)
    .map(([name, value]) => ({ name, value: value ?? '' })),
]

const findings: string[] = []
const scanned = files(dir)
for (const file of scanned) {
  const text = readFileSync(file).toString('latin1')
  const where = relative(ROOT, file)
  for (const name of findSecretNamesInText(text, secretNames)) findings.push(`${where}: secret name ${name}`)
  for (const { label } of findKeyPatterns(text)) findings.push(`${where}: looks like a ${label}`)
  for (const { name, value } of secretValues) {
    if (text.includes(value)) findings.push(`${where}: contains the value of ${name}`)
  }
}

if (findings.length > 0) {
  console.error('Built browser files must not contain secrets:')
  for (const finding of findings) console.error(`  ${finding}`)
  process.exit(1)
}
console.log(`check:built-secrets passed (${String(scanned.length)} browser files scanned).`)
