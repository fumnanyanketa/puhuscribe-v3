// Builds the SQL that loads PuhuScribe v2's reference data (job 3-data-model).
// How and when to run each command: docs/data-model.md, "Loading v2's data again".
//
//   node scripts/v2-import/build.ts copy ipa --v2-clone <path>
//   node scripts/v2-import/build.ts copy sentences --v2-clone <path>
//       Copies one v2 file, byte for byte, from a local clone of v2 at the
//       pinned commit into content/v2-starter/from-v2/.
//   node scripts/v2-import/build.ts ipa
//       Writes the lemma_ipa load migration from the copied v2 file.
//   node scripts/v2-import/build.ts sentences --out supabase/migrations/<timestamp>_load_v2_starter_sentences.sql
//       Writes the source_sentences load migration from the copied v2 file and
//       content/v2-starter/corrections.tsv. Owner's decision of 20 October 2026:
//       not before the reviewer has checked the typed corrections list.
//   node scripts/v2-import/build.ts fixture
//       Writes the load SQL for the made-up fixture sentences used by the tests.
import { execFileSync } from 'node:child_process'
import { mkdirSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import {
  FIXTURE,
  fixtureLoadText,
  IPA_MIGRATION,
  ipaMigrationText,
  ROOT,
  starterLoadText,
} from './generate.ts'
import { gitBlobHash, V2_COMMIT, V2_FILES } from './v2-starter.ts'

function write(path: string, text: string): void {
  mkdirSync(dirname(join(ROOT, path)), { recursive: true })
  writeFileSync(join(ROOT, path), text, 'utf8')
  console.log(`Wrote ${path}`)
}

function option(args: string[], name: string): string {
  const i = args.indexOf(name)
  const value = i >= 0 ? args[i + 1] : undefined
  if (!value) throw new Error(`Missing ${name} <value>`)
  return value
}

function main(args: string[]): void {
  const [command, which] = args
  if (command === 'copy' && (which === 'ipa' || which === 'sentences')) {
    const file = V2_FILES[which]
    const bytes = execFileSync('git', [
      '-C',
      option(args, '--v2-clone'),
      'cat-file',
      'blob',
      `${V2_COMMIT}:${file.v2Path}`,
    ])
    if (gitBlobHash(bytes) !== file.blob) throw new Error(`Unexpected blob for ${file.v2Path}`)
    mkdirSync(dirname(join(ROOT, file.copy)), { recursive: true })
    writeFileSync(join(ROOT, file.copy), bytes)
    console.log(`Copied ${file.v2Path} at ${V2_COMMIT} to ${file.copy}`)
  } else if (command === 'ipa') {
    write(IPA_MIGRATION, ipaMigrationText())
  } else if (command === 'sentences') {
    const out = option(args, '--out')
    if (!/^supabase\/migrations\/\d{14}_load_v2_starter_sentences\.sql$/.test(out)) {
      throw new Error('--out must be supabase/migrations/<14 digit timestamp>_load_v2_starter_sentences.sql')
    }
    write(out, starterLoadText())
  } else if (command === 'fixture') {
    write(FIXTURE.load, fixtureLoadText())
  } else {
    throw new Error(
      'Usage: build.ts copy <ipa|sentences> --v2-clone <path> | ipa | sentences --out <path> | fixture',
    )
  }
}

main(process.argv.slice(2))
