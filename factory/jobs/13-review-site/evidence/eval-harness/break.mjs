// Evaluator scratch: break one protection at a time in this scratch clone, run the site's tests, restore.
import { readFileSync, writeFileSync } from 'node:fs'
import { execSync } from 'node:child_process'
const breaks = [
  ['6', 'Token check replaced by "always allow"', 'review-site/handler.ts', 'export async function hasValidAccessToken(\n  request: Request,\n  env: ReviewEnv,\n  keys: KeySource,\n): Promise<boolean> {', 'export async function hasValidAccessToken(\n  request: Request,\n  env: ReviewEnv,\n  keys: KeySource,\n): Promise<boolean> {\n  return true'],
  ['6', 'Audience check removed', 'review-site/handler.ts', '      audience: aud,\n', ''],
  ['6', 'Issuer check removed', 'review-site/handler.ts', '      issuer: teamDomain,\n', ''],
  ['6', 'Expiry no longer required', 'review-site/handler.ts', "      requiredClaims: ['exp'],\n", ''],
  ['6', 'Algorithm list removed (exploratory: is it the only rule refusing alg none / ES256?)', 'review-site/handler.ts', "      algorithms: ['RS256'],\n", ''],
  ['6', 'Missing settings no longer refuse (team domain shape check dropped)', 'review-site/handler.ts', '  if (!TEAM_DOMAIN.test(teamDomain) || !AUD_TAG.test(aud)) return false', '  if (!AUD_TAG.test(aud)) return false'],
  ['7', 'POST allowed through', 'review-site/handler.ts', "if (method !== 'GET' && method !== 'HEAD') {", "if (method !== 'GET' && method !== 'HEAD' && method !== 'POST') {"],
  ['7', 'Path allow list removed (any path goes to the assets)', 'review-site/handler.ts', "  return path === '/' ||", "  return true || path === '/' ||"],
  ['5', 'X-Robots-Tag dropped', 'review-site/handler.ts', "  'X-Robots-Tag': 'noindex, nofollow, noarchive',\n", ''],
  ['5', 'Review pages get the strict site policy (overrides job 7 policy)', 'review-site/handler.ts', 'const csp = REVIEW_PAGE.test(url.pathname) ? PAGE_CSP : SITE_CSP', 'const csp = SITE_CSP'],
  ['8', 'A console.log of the request added', 'review-site/handler.ts', '  const method = request.method\n', '  const method = request.method\n  console.log(request.url)\n'],
  ['9', 'workers.dev address switched on', 'review-site/wrangler.jsonc', '"workers_dev": false', '"workers_dev": true'],
  ['8', 'Observability switched on', 'review-site/wrangler.jsonc', '"enabled": false', '"enabled": true'],
  ['2', 'Build copies draft.json too', 'scripts/review-site/build.ts', "    for (const r of d.rounds) copyFileSync(r.source, join(out, d.slug, `round-${String(r.round)}.html`))", "    for (const r of d.rounds) copyFileSync(r.source, join(out, d.slug, `round-${String(r.round)}.html`))\n    copyFileSync(join(root, 'content', 'drafts', d.slug, 'draft.json'), join(out, d.slug, 'draft.json'))"],
  ['3', 'Symlink check removed', 'scripts/review-site/build.ts', "    if (stat.isSymbolicLink()) throw new ReviewSiteError(`${where}/${name} is a symlink.`)\n", ''],
  ['3', 'Size limit check removed', 'scripts/review-site/build.ts', '    if (stat.size > MAX_PAGE_BYTES) {', '    if (false) {'],
  ['3', 'Duplicate slug check removed', 'scripts/review-site/build.ts', '    if (seen.has(slug)) throw', '    if (false) throw'],
  ['4', 'Title no longer escaped', 'scripts/review-site/build.ts', '${escapeHtml(dialogue.title)}', '${dialogue.title}'],
  ['10', 'Deploy job no longer limited to main', '.github/workflows/review-site.yml', " && github.ref == 'refs/heads/main'", ''],
  ['10', 'Deploy concurrency may cancel a running deploy', '.github/workflows/review-site.yml', '      group: review-site-deploy\n      cancel-in-progress: false', '      group: review-site-deploy\n      cancel-in-progress: true'],
  ['11', 'Deploy step no longer refuses an empty AUD', '.github/workflows/review-site.yml', '          [ -n "$ACCESS_AUD" ] || missing+=(REVIEW_ACCESS_AUD)\n', ''],
  ['10', 'A secret given to the build job dry run', '.github/workflows/review-site.yml', '        run: npx wrangler deploy --dry-run', '        env:\n          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_REVIEW_API_TOKEN }}\n        run: npx wrangler deploy --dry-run'],
]
const out = []
for (const [n, label, file, from, to] of breaks) {
  const orig = readFileSync(file, 'utf8')
  const text = orig.replace(/\r\n/g, '\n')
  if (!text.includes(from)) { out.push(`[site ${n}] ${label}: BREAK NOT APPLIED (text not found)`); continue }
  writeFileSync(file, text.replace(from, to))
  let res
  try {
    execSync('npx vitest run scripts/review-site review-site tests/review-site.test.ts', { stdio: 'pipe' })
    res = 'all tests still PASS (protection not caught)'
  } catch (e) {
    const s = String(e.stdout)
    const failed = [...s.matchAll(/(?:×|FAIL)\s+([^\n]*\[site \d+\][^\n]*)/g)].map((m) => m[1].replace(/\s+\d+ms$/, '').trim())
    const summary = (s.match(/Tests\s+([^\n]*)/) || [])[1]
    res = `RED. ${summary}\n      ${[...new Set(failed)].slice(0, 6).join('\n      ')}`
  } finally {
    writeFileSync(file, orig)
  }
  out.push(`[site ${n}] ${label}: ${res}`)
}
console.log(out.join('\n'))
