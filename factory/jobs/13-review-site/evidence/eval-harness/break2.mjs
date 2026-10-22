import { readFileSync, writeFileSync } from 'node:fs'
import { execSync } from 'node:child_process'
const file = 'review-site/handler.ts'
const breaks = [
  ['Whole settings check removed (missing settings no longer refused up front)', '  if (!TEAM_DOMAIN.test(teamDomain) || !AUD_TAG.test(aud)) return false\n', ''],
  ['AUD shape check removed only', '  if (!TEAM_DOMAIN.test(teamDomain) || !AUD_TAG.test(aud)) return false', '  if (!TEAM_DOMAIN.test(teamDomain)) return false'],
  ['Team domain shape check removed only (second run, to show the test that names it stays green)', '  if (!TEAM_DOMAIN.test(teamDomain) || !AUD_TAG.test(aud)) return false', '  if (!AUD_TAG.test(aud)) return false'],
]
for (const [label, from, to] of breaks) {
  const orig = readFileSync(file, 'utf8'); const text = orig.replace(/\r\n/g, '\n')
  if (!text.includes(from)) { console.log(label + ': NOT APPLIED'); continue }
  writeFileSync(file, text.replace(from, to))
  try { execSync('npx vitest run review-site', { stdio: 'pipe' }); console.log(`${label}: all tests still PASS`) }
  catch (e) { const s = String(e.stdout); console.log(`${label}: RED. ${(s.match(/Tests\s+([^\n]*)/) || [])[1]}\n  ${[...new Set([...s.matchAll(/×\s+([^\n]*\[site \d+\][^\n]*)/g)].map((m) => m[1].trim()))].join('\n  ')}`) }
  finally { writeFileSync(file, orig) }
}
