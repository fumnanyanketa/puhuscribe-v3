// Where the word error harness may read clips from
// (factory/jobs/10-speaking-feedback/spec.md, "Done when" 22). Learner and
// reviewer clips must never be committed, so the folder must be outside the
// repository, or inside it but ignored by git. Any other folder is refused.
// Plain Node, so the command line script can run it directly.

import { existsSync, realpathSync, statSync } from 'node:fs'
import { isAbsolute, relative, resolve } from 'node:path'

export type ClipFolderProblem = 'missing' | 'not_a_folder' | 'tracked_by_git'

/**
 * Null when the folder may be used. `isIgnored` answers whether git ignores a
 * path inside the repository (git check-ignore).
 */
export function clipFolderProblem(
  folder: string,
  repoRoot: string,
  isIgnored: (path: string) => boolean,
): ClipFolderProblem | null {
  const path = resolve(folder)
  if (!existsSync(path)) return 'missing'
  if (!statSync(path).isDirectory()) return 'not_a_folder'
  const real = realpathSync(path)
  const inside = relative(realpathSync(repoRoot), real)
  const outside = inside.startsWith('..') || isAbsolute(inside)
  if (outside) return null
  return isIgnored(real) ? null : 'tracked_by_git'
}

export const CLIP_FOLDER_MESSAGES: Record<ClipFolderProblem, string> = {
  missing: 'The clip folder does not exist.',
  not_a_folder: 'The clip path is a file, not a folder.',
  tracked_by_git:
    'The clip folder is inside the repository and not ignored by git. Use a folder outside the repository, or one git ignores, so no clip is ever committed.',
}
