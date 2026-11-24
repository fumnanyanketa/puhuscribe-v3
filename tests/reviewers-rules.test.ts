import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'

// Labels [reviewers N] are the "Done when" statement numbers from
// factory/jobs/reviewers/spec.md that each test protects.
// Repository rules for the reviewer sign up page at /reviewers.

describe('the reviewer sign up page code', () => {
  it('[reviewers 1] uses only the design tokens: no colour value and no font of its own', () => {
    const css = readFileSync('src/screens/Reviewers.module.css', 'utf8')
    expect(css).not.toMatch(/#[0-9a-f]{3,8}\b|rgba?\(|hsla?\(|font-family|@font-face/i)
  })

  it('[reviewers 1] sets no cookie and uses no browser storage', () => {
    for (const path of [
      'src/screens/ReviewersPage.tsx',
      'src/lib/reviewer-signup.ts',
      'worker/reviewers.ts',
    ]) {
      expect(readFileSync(path, 'utf8'), path).not.toMatch(
        /document\.cookie|localStorage|sessionStorage|indexedDB|set-cookie|withCookies/i,
      )
    }
  })

  it('[reviewers 6] only worker/providers/feedback-alert.ts names the Brevo address', () => {
    for (const path of ['worker/reviewers.ts', 'worker/api.ts', 'src/screens/ReviewersPage.tsx']) {
      expect(readFileSync(path, 'utf8'), path).not.toContain('api.brevo.com')
    }
  })

  it('[reviewers 4] the migration revokes everything from every API role and grants only the three functions', () => {
    const sql = readFileSync('supabase/migrations/20261124104750_reviewer_signups.sql', 'utf8')
    expect(sql).toContain(
      'revoke all on table private.reviewer_signups from public, anon, authenticated, service_role;',
    )
    expect(sql).toContain('alter table private.reviewer_signups enable row level security;')
    const grants = [...sql.matchAll(/^grant .*;$/gm)].map((m) => m[0])
    expect(grants).toEqual([
      'grant execute on function public.sign_up_reviewer(text, text, text) to anon;',
      'grant execute on function public.owner_reviewer_signups() to authenticated;',
      'grant execute on function public.owner_delete_reviewer_signup(uuid) to authenticated;',
    ])
    expect(sql).not.toMatch(/create policy/i)
  })
})
