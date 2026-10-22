import { createHash } from 'node:crypto'
import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { describe, expect, it } from 'vitest'

// [5] [6] The engines copied from PuhuScribe v2 stay exactly as they were at
// v2 commit 9c8d0a083d6209e0135efe20f88db99ff9c867e4. Each value is the git blob
// hash of the file in v2 (`git rev-parse <commit>:<path>`), so this test is the
// "diff against v2". If a later job changes an engine on purpose, it updates
// docs/v2-imports.md and this list in the same commit and says why.

const V2_BLOBS: Record<string, string> = {
  'src/lib/fsrs/algorithm.ts': 'a6f9a395fddf3d130ce5c7b130a78cfedd771c43',
  'src/lib/fsrs/scheduler.ts': '56fdd8d9a57f424d4c17eb5f19e4b5b3d21c1b0b',
  'src/lib/fsrs/types.ts': '062ef10413aaf1db0373f4d013b946727172131a',
  'src/lib/fsrs/fsrs.test.ts': '03548efb1fa306cdea4e38b8a50c7f8e3d1de996',
  'src/lib/grade.ts': 'aadd2bda703b4f33a562ec37177a10d0e8a353d9',
  'src/lib/grade.test.ts': '732ce98aac3c5026470fc2bb9cfad9450fbf569c',
  'scripts/generate/voikko_gate.py': '76b05d3de6c0866d16f05dbf752e42e80390afbd',
  'scripts/generate/generate.py': '782694f069ea8b3f7d1cd1b303ab44d5f7261a5d',
  'scripts/generate/allowed_vocab.py': '33cebaeff692c324566e8b62294c1bd58c3b5e83',
  'scripts/generate/test_voikko_gate.py': '6a31856e471a4e36164e90b972b6ac1c351bcbc2',
  'scripts/generate/README.md': '6b79bbf7fac77ca3ed27d98a4fbdc839f4cf3559',
  'scripts/requirements.txt': '49e11b8c216f14e11e3244c88e341764743788f8',
  'data/finnish_frequency_lemmas.json': 'cad35358a6873691005a3b5f4f221ce7b374ce66',
}

function gitBlobHash(path: string): string {
  const content = readFileSync(resolve(path))
  const header = Buffer.from(`blob ${String(content.length)}\0`)
  return createHash('sha1')
    .update(Buffer.concat([header, content]))
    .digest('hex')
}

describe('files imported from v2', () => {
  for (const [path, blob] of Object.entries(V2_BLOBS)) {
    const label = path.startsWith('src/') ? '[5]' : '[6]'
    it(`${label} ${path} is unchanged from v2`, () => {
      expect(gitBlobHash(path)).toBe(blob)
    })
  }
})
