// Prints only counts: how many values in .env.local look like a Supabase secret
// key (sb_secret_...) or a Supabase personal access token (sbp_...). No names, no values.
const fs = require('fs')
const text = fs.readFileSync('C:/Users/fumna/dev/puhuscribe-v3/.worktrees/2-smoke/.env.local', 'utf8')
let entries = 0
let secretKeys = 0
let pats = 0
for (const raw of text.split(/\r?\n/)) {
  const m = raw.match(/^\s*[A-Za-z_][A-Za-z0-9_]*\s*=\s*(.*)$/)
  if (!m) continue
  entries += 1
  const v = m[1].trim().replace(/^["']|["']$/g, '')
  if (/sb_secret_/.test(v)) secretKeys += 1
  if (/(^|[^A-Za-z0-9])sbp_/.test(v)) pats += 1
}
console.log(`.env.local entries: ${entries}; values containing sb_secret_: ${secretKeys}; values containing sbp_: ${pats}`)
