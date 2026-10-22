// Turns a branch name into a Cloudflare version alias for the preview link:
// lowercase letters, numbers and dashes, starting with a letter, and short
// enough that <alias>-puhuscribe-preview fits in one 63 character address part.
// Usage in the workflow: BRANCH=factory/1-stack node scripts/ci/preview-alias.ts

const MAX_ALIAS_LENGTH = 30

export function previewAlias(branch: string): string {
  let alias = branch
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+/, '')
    .slice(0, MAX_ALIAS_LENGTH)
    .replace(/-+$/, '')
  if (!/^[a-z]/.test(alias)) alias = `b-${alias}`.slice(0, MAX_ALIAS_LENGTH).replace(/-+$/, '')
  return alias
}

if (import.meta.main) {
  const branch = process.env.BRANCH
  if (!branch) {
    console.error('BRANCH is not set.')
    process.exit(1)
  }
  console.log(previewAlias(branch))
}
