// Every published dialogue is one the owner approved, and every approved
// dialogue is published (job go-live).
//
// A dialogue reaches a Supabase project only through its publish migration,
// supabase/migrations/<time>_publish_<slug with underscores>.sql, made by
// `python scripts/generate/pipeline.py publish-part` from the owner's approval
// file content/approvals/part-<n>.json. The live workflow (.github/workflows/live.yml)
// runs this check, with no secret, before it applies anything to the live
// project. It finds:
//   - an approved dialogue with no publish migration,
//   - a publish migration whose dialogue no approval file lists,
//   - two publish migrations for one dialogue,
//   - an approval file that cannot be read or lists no dialogue.
// The audio is checked by scripts/ci/check-published-audio.ts.
import { readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'

const APPROVAL_FILE = /^part-[1-6]\.json$/
const PUBLISH_MIGRATION = /^\d{14}_publish_([a-z0-9_]+)\.sql$/
const SLUG = /^[a-z0-9]+(-[a-z0-9]+)*$/

/** Every dialogue slug the owner approved, by the approval file that lists it. */
export function approvedDialogues(approvalsDir: string): { slugs: Map<string, string>; problems: string[] } {
  const slugs = new Map<string, string>()
  const problems: string[] = []
  for (const name of readdirSync(approvalsDir).sort()) {
    if (!APPROVAL_FILE.test(name)) continue
    let approval: { dialogues?: unknown; approved_line?: unknown }
    try {
      approval = JSON.parse(readFileSync(join(approvalsDir, name), 'utf8')) as typeof approval
    } catch {
      problems.push(`${name} is not valid JSON`)
      continue
    }
    if (typeof approval.approved_line !== 'string' || approval.approved_line.trim() === '') {
      problems.push(`${name} has no approval line from the owner`)
      continue
    }
    const dialogues = approval.dialogues
    if (typeof dialogues !== 'object' || dialogues === null || Object.keys(dialogues).length === 0) {
      problems.push(`${name} lists no dialogue`)
      continue
    }
    for (const slug of Object.keys(dialogues)) {
      if (!SLUG.test(slug)) problems.push(`${name} lists "${slug}", which is not a dialogue slug`)
      else slugs.set(slug, name)
    }
  }
  return { slugs, problems }
}

/** The dialogue slug of every publish migration, with the migration file names. */
export function publishedDialogues(migrationsDir: string): Map<string, string[]> {
  const found = new Map<string, string[]>()
  for (const name of readdirSync(migrationsDir).sort()) {
    const match = PUBLISH_MIGRATION.exec(name)
    if (!match?.[1]) continue
    const slug = match[1].replace(/_/g, '-')
    found.set(slug, [...(found.get(slug) ?? []), name])
  }
  return found
}

export function checkApprovedDialogues(approvalsDir: string, migrationsDir: string): string[] {
  const { slugs: approved, problems } = approvedDialogues(approvalsDir)
  const published = publishedDialogues(migrationsDir)
  for (const [slug, file] of approved) {
    if (!published.has(slug)) problems.push(`${slug} is approved in ${file} but has no publish migration`)
  }
  for (const [slug, files] of published) {
    if (!approved.has(slug))
      problems.push(`${files.join(', ')} publishes ${slug}, which no approval file lists`)
    if (files.length > 1)
      problems.push(`${slug} has ${String(files.length)} publish migrations: ${files.join(', ')}`)
  }
  return problems
}

if (import.meta.main) {
  const problems = checkApprovedDialogues('content/approvals', 'supabase/migrations')
  for (const problem of problems) console.error(problem)
  if (problems.length === 0) {
    const count = approvedDialogues('content/approvals').slugs.size
    console.log(
      `Every one of the ${String(count)} approved dialogues has one publish migration, and no other dialogue is published.`,
    )
  }
  process.exit(problems.length === 0 ? 0 : 1)
}
