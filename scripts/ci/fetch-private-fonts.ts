// Fills src/assets/fonts/switzer/ with the Switzer font files, which are not in
// this public repository (the ITF Free Font License forbids offering the files
// through a public repository). Full explanation: docs/fonts.md.
//
// Where the files come from, in this order:
//   1. Already in the folder and matching the known SHA-256 values: nothing to do.
//   2. FONTS_SOURCE_DIR: a local folder that holds the files (for the owner's
//      own computer).
//   3. FONTS_DEPLOY_KEY: a read only deploy key (an SSH private key) for the
//      private fonts repository, held in a GitHub secret of the same name.
//      FONTS_REPO names the repository as an SSH address.
//   4. Neither: print a notice and stop. The build then continues with the
//      fallback font stack (Poppins, then the system font), and the tests that
//      need Switzer skip themselves.
//
// The script never fails the build because fonts are missing. It refuses files
// whose SHA-256 differs from the one on record (the licence forbids changing
// them), and it never prints the key.
//
// Usage: node scripts/ci/fetch-private-fonts.ts

import { execFileSync } from 'node:child_process'
import { createHash } from 'node:crypto'
import {
  copyFileSync,
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'

export const DEFAULT_DEST = 'src/assets/fonts/switzer'
export const DEFAULT_REPO = 'git@github.com:fumnanyanketa/puhuscribe-v3-fonts.git'
export const CSS_NAME = 'switzer.css'

// SHA-256 of the files as downloaded from fontshare.com on 21 October 2026.
export const SWITZER_HASHES: Readonly<Record<string, string>> = {
  'Switzer-Regular.woff2': 'aefa3d21af6adb6dd53246ff86e1d8e7eaf36a8d792dd59136cced309e3c8862',
  'Switzer-Medium.woff2': '2ea341e35c0d0d00c13adec869b573297d25326140ca40fbe354a9bee468808e',
  'Switzer-Semibold.woff2': '04084ce10f3b185156408adf5540cabbed149e039d6f3c3e8e5b2fb17f6bdef8',
  'Switzer-Bold.woff2': '5cb009dd21317ac095104458dbca8e96b6ac41fdace80ef3b7c53833c44420c7',
  'FFL.txt': '145e7fe2429a3336ba215c070ef722000e01348a3e1baaa127e871bb5012f554',
}

const WEIGHTS: readonly (readonly [number, string])[] = [
  [400, 'Switzer-Regular.woff2'],
  [500, 'Switzer-Medium.woff2'],
  [600, 'Switzer-Semibold.woff2'],
  [700, 'Switzer-Bold.woff2'],
]

// The @font-face rules. The browser app imports this file only when it exists
// (src/main.tsx), so a checkout without the font files never asks for them.
export function switzerCss(): string {
  const faces = WEIGHTS.map(
    ([weight, file]) => `@font-face {
  font-family: 'Switzer';
  font-style: normal;
  font-weight: ${String(weight)};
  font-display: swap;
  src: url('./${file}') format('woff2');
}
`,
  )
  return `/* Made by scripts/ci/fetch-private-fonts.ts. Not committed (docs/fonts.md). */\n${faces.join('\n')}`
}

export function sha256(path: string): string {
  return createHash('sha256').update(readFileSync(path)).digest('hex')
}

// The names in `dir` that are missing or whose SHA-256 is not the one on record.
export function problems(dir: string): string[] {
  return Object.entries(SWITZER_HASHES).flatMap(([name, hash]) => {
    const path = join(dir, name)
    if (!existsSync(path)) return [`${name} is missing`]
    return sha256(path) === hash ? [] : [`${name} does not match the SHA-256 on record`]
  })
}

// Copies the files from `source` (or `source/switzer`) into `dest` and writes
// the CSS, but only when every file matches. Nothing is written otherwise.
export function install(source: string, dest: string): string[] {
  const found = problems(source)
  const dir = found.length === 0 ? source : join(source, 'switzer')
  if (found.length > 0 && problems(dir).length > 0) return found
  mkdirSync(dest, { recursive: true })
  for (const name of Object.keys(SWITZER_HASHES)) copyFileSync(join(dir, name), join(dest, name))
  writeFileSync(join(dest, CSS_NAME), switzerCss())
  return []
}

function cloneWithKey(key: string, repo: string, into: string): void {
  const keyFile = join(into, 'deploy-key')
  // An SSH key file must end with a newline; secrets often lose it.
  writeFileSync(keyFile, key.endsWith('\n') ? key : `${key}\n`, { mode: 0o600 })
  const ssh = [
    'ssh',
    '-i',
    `"${keyFile.replaceAll('\\', '/')}"`,
    '-o IdentitiesOnly=yes',
    '-o StrictHostKeyChecking=accept-new',
    `-o UserKnownHostsFile="${join(into, 'known_hosts').replaceAll('\\', '/')}"`,
  ].join(' ')
  execFileSync('git', ['clone', '--depth', '1', '--quiet', repo, join(into, 'repo')], {
    env: { ...process.env, GIT_SSH_COMMAND: ssh, GIT_TERMINAL_PROMPT: '0' },
    stdio: ['ignore', 'ignore', 'pipe'],
  })
}

function notice(message: string): void {
  const inCi = process.env.GITHUB_ACTIONS === 'true'
  console.log(inCi ? `::notice title=Switzer font files::${message}` : message)
}

function warning(message: string): void {
  const inCi = process.env.GITHUB_ACTIONS === 'true'
  console.log(inCi ? `::warning title=Switzer font files::${message}` : `Warning: ${message}`)
}

export function main(): void {
  const dest = process.env.SWITZER_DIR ?? DEFAULT_DEST
  if (problems(dest).length === 0) {
    writeFileSync(join(dest, CSS_NAME), switzerCss())
    notice(`The Switzer files are already in ${dest}. Nothing to fetch.`)
    return
  }

  const sourceDir = process.env.FONTS_SOURCE_DIR?.trim()
  const key = process.env.FONTS_DEPLOY_KEY?.trim()
  if (sourceDir) {
    const found = install(sourceDir, dest)
    if (found.length > 0) {
      warning(
        `Not installed from the local folder (${found.join('; ')}). The build continues with the fallback fonts.`,
      )
      return
    }
    notice(`Switzer installed from the local folder into ${dest}.`)
    return
  }
  if (!key) {
    notice(
      'No Switzer files and no FONTS_DEPLOY_KEY. The build continues with the fallback fonts (Poppins, then the system font). See docs/fonts.md.',
    )
    return
  }

  const work = mkdtempSync(join(tmpdir(), 'switzer-'))
  try {
    const repo = process.env.FONTS_REPO?.trim() ?? ''
    cloneWithKey(key, repo === '' ? DEFAULT_REPO : repo, work)
    const found = install(join(work, 'repo'), dest)
    if (found.length > 0) {
      warning(
        `The private fonts repository did not hold the expected files (${found.join('; ')}). The build continues with the fallback fonts.`,
      )
      return
    }
    notice(`Switzer fetched from the private fonts repository into ${dest}.`)
  } catch (error) {
    // The message of a failed clone names no secret; the key is never printed.
    const reason =
      error instanceof Error ? (error.message.split('\n').find((line) => line.trim() !== '') ?? '') : ''
    warning(`Could not fetch the Switzer files (${reason}). The build continues with the fallback fonts.`)
  } finally {
    rmSync(work, { recursive: true, force: true })
  }
}

if (import.meta.main) main()
