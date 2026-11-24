import { readdirSync, readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'

// Labels [review-links N] are the "Done when" statement numbers from
// factory/jobs/review-links/spec.md that each test protects.
// Repository rules for the private review links.

function migration(): string {
  const name = readdirSync('supabase/migrations').find((f) => f.endsWith('_review_links.sql'))
  if (!name) throw new Error('The review_links migration is missing.')
  return readFileSync(`supabase/migrations/${name}`, 'utf8')
}

describe('the review links migration', () => {
  it('[review-links 5] revokes everything from every API role on both tables, turns on row level security and makes no rule', () => {
    const sql = migration()
    for (const table of ['private.review_links', 'private.review_answers']) {
      expect(sql).toContain(`revoke all on table ${table} from public, anon, authenticated, service_role;`)
      expect(sql).toContain(`alter table ${table} enable row level security;`)
    }
    expect(sql).not.toMatch(/create policy/i)
  })

  it('[review-links 5] grants only the three reviewer doors to anon and the three owner functions to authenticated', () => {
    const grants = [...migration().matchAll(/^grant .*;$/gm)].map((m) => m[0])
    expect(grants).toEqual([
      'grant execute on function public.review_link_overview(text) to anon;',
      'grant execute on function public.review_link_dialogue(text, bigint) to anon;',
      'grant execute on function public.review_link_answer(text, bigint, text, text) to anon;',
      'grant execute on function public.owner_create_review_link(uuid, integer, text) to authenticated;',
      'grant execute on function public.owner_delete_review_link(uuid) to authenticated;',
      'grant execute on function public.owner_review_overview() to authenticated;',
    ])
  })

  it('[review-links 5] revokes every new function from PUBLIC and the API roles before any grant', () => {
    const sql = migration()
    const made = [...sql.matchAll(/^create function ([\w.]+\([^)]*\))/gm)].map((m) => m[1] ?? '')
    expect(made).toHaveLength(8)
    for (const fn of made) {
      const name = fn.replace(/\(.*$/, '')
      expect(sql, name).toMatch(
        new RegExp(
          `revoke all on function ${name.replace('.', '\\.')}\\([^)]*\\) from public, anon, authenticated, service_role;`,
        ),
      )
    }
  })

  it('[review-links 2] keeps only the sha256 hash of a link secret, and a secret of 43 base64url characters', () => {
    const sql = migration()
    expect(sql).toMatch(/token_hash text not null unique check \(token_hash ~ '\^\[0-9a-f\]\{64\}\$'\)/)
    expect(sql).toContain("encode(sha256(convert_to(p_token, 'UTF8')), 'hex')")
    expect(sql).toContain("p_token ~ '^[A-Za-z0-9_-]{43}$'")
    expect(sql).not.toMatch(/^\s+token text/m)
  })

  it('[review-links 3] works the batches out from the published road content, 27 to a batch, never from a typed list', () => {
    const sql = migration()
    expect(sql).toContain('row_number() over (order by u.stop_number, d.position, d.id)')
    expect(sql).toContain('least(4, ((o.n - 1) / 27) + 1)')
    expect(sql).toContain("where d.status = 'approved' and u.stop_number is not null")
    expect(sql).not.toMatch(/slug in \(/)
  })

  it('[review-links 5] deleting a sign up deletes its links, and deleting a link deletes its answers', () => {
    const sql = migration()
    expect(sql).toContain('references private.reviewer_signups (id) on delete cascade')
    expect(sql).toContain('references private.review_links (id) on delete cascade')
  })
})

describe('the review page code', () => {
  it('[review-links 7] uses only the design tokens: no colour value and no font of its own', () => {
    for (const path of ['src/screens/ReviewLink.module.css', 'src/screens/Owner.module.css']) {
      const css = readFileSync(path, 'utf8')
      expect(css, path).not.toMatch(/#[0-9a-f]{3,8}\b|rgba?\(|hsla?\(|@font-face/i)
      // A font may only come from a token, such as var(--font-heading).
      expect(css, path).not.toMatch(/font-family:(?!\s*var\()/i)
    }
  })

  it('[review-links 7] sets no cookie and uses no browser storage', () => {
    for (const path of [
      'src/screens/ReviewLinkPage.tsx',
      'src/lib/review-link.ts',
      'worker/review-links.ts',
    ]) {
      expect(readFileSync(path, 'utf8'), path).not.toMatch(
        /document\.cookie|localStorage|sessionStorage|indexedDB|set-cookie|withCookies|learnerContext|signInState/i,
      )
    }
  })

  it('[review-links 1] only worker/providers/feedback-alert.ts names the Brevo address', () => {
    for (const path of ['worker/owner.ts', 'worker/review-links.ts', 'src/screens/OwnerReviewLinks.tsx']) {
      expect(readFileSync(path, 'utf8'), path).not.toContain('api.brevo.com')
    }
  })

  it('[review-links 7] the review pages run the Worker first and are listed the same in wrangler.jsonc', () => {
    expect(readFileSync('wrangler.jsonc', 'utf8')).toContain('"/review/*",')
    expect(readFileSync('worker/page-routes.ts', 'utf8')).toContain("'/review/*',")
  })
})
