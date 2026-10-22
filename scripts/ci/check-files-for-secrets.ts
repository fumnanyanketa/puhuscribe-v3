// Runs before every artifact upload in the GitHub checks. Fails if any file in
// the given folders contains the value of one of the named environment
// variables, including inside zip files (Playwright traces are zips).
// Prints file names and variable names only, never a value.
//
// Usage: node scripts/ci/check-files-for-secrets.ts --env NAME [--env NAME ...] <path> [<path> ...]
// Every named variable must be set (a missing one means the guard would check
// nothing). Paths that do not exist are skipped.
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { inflateRawSync } from 'node:zlib'

const MIN_SECRET_LENGTH = 8

export interface Needle {
  name: string
  value: Buffer
}

export interface Finding {
  file: string
  name: string
}

// The entries of a zip file, decompressed. Handles stored and deflated
// entries, which is what Playwright and most tools write.
export function zipEntries(zip: Buffer): { name: string; data: Buffer }[] {
  const EOCD = 0x06054b50
  let eocd = -1
  for (let i = zip.length - 22; i >= Math.max(0, zip.length - 65_557); i--) {
    if (zip.readUInt32LE(i) === EOCD) {
      eocd = i
      break
    }
  }
  if (eocd < 0) throw new Error('not a zip file')
  const count = zip.readUInt16LE(eocd + 10)
  let pointer = zip.readUInt32LE(eocd + 16)
  const entries: { name: string; data: Buffer }[] = []
  for (let n = 0; n < count; n++) {
    if (zip.readUInt32LE(pointer) !== 0x02014b50) throw new Error('bad zip directory')
    const method = zip.readUInt16LE(pointer + 10)
    const compressedSize = zip.readUInt32LE(pointer + 20)
    const nameLength = zip.readUInt16LE(pointer + 28)
    const extraLength = zip.readUInt16LE(pointer + 30)
    const commentLength = zip.readUInt16LE(pointer + 32)
    const localHeader = zip.readUInt32LE(pointer + 42)
    const name = zip.subarray(pointer + 46, pointer + 46 + nameLength).toString('utf8')
    const localNameLength = zip.readUInt16LE(localHeader + 26)
    const localExtraLength = zip.readUInt16LE(localHeader + 28)
    const start = localHeader + 30 + localNameLength + localExtraLength
    const raw = zip.subarray(start, start + compressedSize)
    if (method === 0) entries.push({ name, data: raw })
    else if (method === 8) entries.push({ name, data: inflateRawSync(raw) })
    else throw new Error(`zip entry ${name} uses compression method ${String(method)}`)
    pointer += 46 + nameLength + extraLength + commentLength
  }
  return entries
}

function isZip(content: Buffer): boolean {
  return content.length >= 4 && content.readUInt32LE(0) === 0x04034b50
}

export function findSecretsInContent(file: string, content: Buffer, needles: Needle[]): Finding[] {
  const findings: Finding[] = []
  for (const { name, value } of needles) {
    if (content.includes(value)) findings.push({ file, name })
  }
  if (isZip(content)) {
    let entries: { name: string; data: Buffer }[]
    try {
      entries = zipEntries(content)
    } catch {
      // A zip this guard cannot read cannot be proven clean.
      return [...findings, { file, name: 'unreadable zip file' }]
    }
    for (const entry of entries) {
      findings.push(...findSecretsInContent(`${file}!${entry.name}`, entry.data, needles))
    }
  }
  return findings
}

function filesUnder(path: string): string[] {
  if (!existsSync(path)) return []
  if (!statSync(path).isDirectory()) return [path]
  return readdirSync(path).flatMap((name) => filesUnder(join(path, name)))
}

export function scan(paths: string[], needles: Needle[]): Finding[] {
  return paths.flatMap(filesUnder).flatMap((file) => findSecretsInContent(file, readFileSync(file), needles))
}

function main(argv: string[]): number {
  const names: string[] = []
  const paths: string[] = []
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i] ?? ''
    if (arg === '--env') names.push(argv[++i] ?? '')
    else paths.push(arg)
  }
  if (names.length === 0 || paths.length === 0) {
    console.error('Usage: check-files-for-secrets.ts --env NAME [--env NAME ...] <path> [<path> ...]')
    return 2
  }
  const needles: Needle[] = []
  for (const name of names) {
    const value = process.env[name]?.trim() ?? ''
    if (value.length < MIN_SECRET_LENGTH) {
      console.error(`${name} is not set (or too short to check), so the files cannot be checked for it.`)
      return 2
    }
    needles.push({ name, value: Buffer.from(value, 'utf8') })
  }
  const findings = scan(paths, needles)
  const scanned = paths.flatMap(filesUnder).length
  if (findings.length > 0) {
    console.error('These files must not be uploaded. They contain a secret value:')
    for (const { file, name } of findings) console.error(`  ${file}: ${name}`)
    return 1
  }
  console.log(`No secret values found in ${String(scanned)} files (checked ${names.join(', ')}).`)
  return 0
}

if (import.meta.main) process.exit(main(process.argv.slice(2)))
