import { existsSync } from 'node:fs'

// Switzer is not in the public repository (docs/fonts.md). Tests that need it
// run when scripts/ci/fetch-private-fonts.ts has put the files in place, and
// skip with this reason when it has not.
export const switzerPresent = ['Switzer-Regular', 'Switzer-Medium', 'Switzer-Semibold', 'Switzer-Bold']
  .map((name) => `src/assets/fonts/switzer/${name}.woff2`)
  .concat('src/assets/fonts/switzer/switzer.css')
  .every((path) => existsSync(path))

export const SWITZER_SKIP_REASON =
  'The Switzer font files are not in this checkout (they are kept out of the public repository). Run node scripts/ci/fetch-private-fonts.ts, see docs/fonts.md.'
