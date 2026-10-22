// Builds the private review site for the native reviewer (job 13-review-site,
// "Done when" 1 to 4 and 12). Run directly by Node 24: npm run build:review-site
//
// It reads the list of dialogues in review-site/dialogues.json and writes
// dist-review/ with exactly: index.html, robots.txt and every review page of a
// listed dialogue at <slug>/round-<n>.html, copied byte for byte from
// content/drafts/<slug>/review/round-<n>.html. Nothing else from content/ is
// copied: no draft.json, check report, log, audio, round-<n>.json, brief or
// returned review file. content/reviews/ is only read, to show each round's
// status on the index page.
//
// Every input is checked before anything is written. On a problem the script
// names the cause, writes nothing and exits with code 1.
import {
  copyFileSync,
  existsSync,
  lstatSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from 'node:fs'
import { join, resolve } from 'node:path'

export const SLUG = /^[a-z0-9]+(-[a-z0-9]+)*$/
const PAGE_NAME = /^round-([1-9][0-9]*)\.html$/
// Cloudflare Workers refuse a static file over 25 MiB.
export const MAX_PAGE_BYTES = 25 * 1024 * 1024

export class ReviewSiteError extends Error {}

export interface Round {
  round: number
  source: string
  reviewed: boolean
}

export interface Dialogue {
  slug: string
  title: string
  rounds: Round[]
}

export interface BuildResult {
  files: string[]
  dialogues: Dialogue[]
}

export function readList(root: string): string[] {
  const path = join(root, 'review-site', 'dialogues.json')
  let parsed: unknown
  try {
    parsed = JSON.parse(readFileSync(path, 'utf8'))
  } catch {
    throw new ReviewSiteError('review-site/dialogues.json is missing or is not valid JSON.')
  }
  if (
    typeof parsed !== 'object' ||
    parsed === null ||
    Array.isArray(parsed) ||
    Object.keys(parsed).join() !== 'dialogues'
  ) {
    throw new ReviewSiteError('review-site/dialogues.json must hold only {"dialogues": [ ...slugs ]}.')
  }
  const list = (parsed as { dialogues: unknown }).dialogues
  if (!Array.isArray(list) || !list.every((slug) => typeof slug === 'string')) {
    throw new ReviewSiteError('"dialogues" in review-site/dialogues.json must be a list of dialogue slugs.')
  }
  const seen = new Set<string>()
  for (const slug of list) {
    if (!SLUG.test(slug)) {
      throw new ReviewSiteError(
        `The listed slug ${JSON.stringify(slug)} is not lower case letters and digits joined by single hyphens.`,
      )
    }
    if (seen.has(slug)) throw new ReviewSiteError(`The slug ${slug} is listed twice.`)
    seen.add(slug)
  }
  return list
}

function readTitle(root: string, slug: string): string {
  const path = join(root, 'content', 'drafts', slug, 'draft.json')
  let draft: unknown
  try {
    draft = JSON.parse(readFileSync(path, 'utf8'))
  } catch {
    throw new ReviewSiteError(`content/drafts/${slug}/draft.json is missing or is not valid JSON.`)
  }
  const title = (draft as { brief?: { dialogue?: { title_en?: unknown } } } | null)?.brief?.dialogue?.title_en
  if (typeof title !== 'string' || title.trim() === '') {
    throw new ReviewSiteError(`content/drafts/${slug}/draft.json has no brief.dialogue.title_en.`)
  }
  return title
}

function readRounds(root: string, slug: string): Round[] {
  const folder = join(root, 'content', 'drafts', slug, 'review')
  const where = `content/drafts/${slug}/review`
  if (!existsSync(folder))
    throw new ReviewSiteError(`The listed slug ${slug} has no review page (no ${where}/).`)
  if (!lstatSync(folder).isDirectory()) {
    throw new ReviewSiteError(`${where} is not a plain folder (a symlink or a file).`)
  }
  const rounds: Round[] = []
  for (const name of readdirSync(folder).sort()) {
    if (!name.toLowerCase().endsWith('.html')) continue
    const match = PAGE_NAME.exec(name)
    if (!match?.[1]) throw new ReviewSiteError(`${where}/${name} is not named round-<n>.html.`)
    const source = join(folder, name)
    const stat = lstatSync(source)
    if (stat.isSymbolicLink()) throw new ReviewSiteError(`${where}/${name} is a symlink.`)
    if (!stat.isFile()) throw new ReviewSiteError(`${where}/${name} is not a file.`)
    if (stat.size > MAX_PAGE_BYTES) {
      throw new ReviewSiteError(`${where}/${name} is over 25 MiB, the largest file a Worker may serve.`)
    }
    const round = Number(match[1])
    const reviewed = existsSync(join(root, 'content', 'reviews', slug, `round-${String(round)}.json`))
    rounds.push({ round, source, reviewed })
  }
  if (rounds.length === 0)
    throw new ReviewSiteError(`The listed slug ${slug} has no review page in ${where}/.`)
  return rounds.sort((a, b) => a.round - b.round)
}

// content/drafts and each listed dialogue's folder must be plain folders. A
// symlink there would let the build read pages from outside the drafts.
function checkDraftFolders(root: string, slug: string): void {
  for (const where of ['content/drafts', `content/drafts/${slug}`]) {
    const folder = join(root, ...where.split('/'))
    if (!existsSync(folder))
      throw new ReviewSiteError(`The listed slug ${slug} has no drafts folder (${where}/).`)
    if (!lstatSync(folder).isDirectory()) {
      throw new ReviewSiteError(`${where} is not a plain folder (a symlink or a file).`)
    }
  }
}

export function readDialogues(root: string): Dialogue[] {
  return readList(root).map((slug) => {
    checkDraftFolders(root, slug)
    return { slug, title: readTitle(root, slug), rounds: readRounds(root, slug) }
  })
}

export function escapeHtml(text: string): string {
  return text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;')
}

export type RoundStatus = 'Review received' | 'Waiting for your review' | 'Not reviewed'

// A round with a returned file says "Review received". The newest round without
// one is the one to review now. An older round without a file was never sent
// back, which the pipeline does not expect; it says so plainly.
export function roundStatuses(rounds: Round[]): RoundStatus[] {
  const waiting = rounds.findLast((r) => !r.reviewed)
  return rounds.map((r) =>
    r.reviewed ? 'Review received' : r === waiting ? 'Waiting for your review' : 'Not reviewed',
  )
}

// The page borrows the review page's own system fonts and colours (job 7).
// No script, nothing loaded from the network.
const STYLE = `:root { color-scheme: light; }
* { box-sizing: border-box; }
body { margin: 0; background: #faf9fc; color: #1b1a20;
  font: 16px/1.5 system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; }
main { max-width: 760px; margin: 0 auto; padding: 32px 20px 96px; }
h1 { font-size: 28px; line-height: 1.2; margin: 0 0 12px; font-weight: 650; letter-spacing: -0.01em; }
h2 { font-size: 20px; line-height: 1.3; margin: 0 0 4px; font-weight: 650; }
p { margin: 0 0 12px; }
h1, h2, p, li, a { overflow-wrap: anywhere; }
.intro { color: #56525e; margin: 0 0 32px; }
.dialogue { background: #ffffff; border-radius: 14px; padding: 20px; margin: 0 0 16px;
  box-shadow: 0 1px 2px #1a16341a; }
.slug { color: #56525e; font-size: 14px; margin: 0 0 12px; }
ul { list-style: none; margin: 0; padding: 0; }
li { display: flex; flex-wrap: wrap; align-items: center; gap: 4px 16px; min-height: 44px; }
a { color: #1f42ac; font-weight: 600; text-decoration: underline; text-underline-offset: 3px;
  display: inline-block; padding: 10px 0; }
a:focus-visible { outline: 3px solid #1f42ac; outline-offset: 2px; border-radius: 4px; }
.waiting { font-weight: 600; }
.status { color: #56525e; }
.waiting .status { color: #1b1a20; }`

export function indexHtml(dialogues: Dialogue[]): string {
  const sections = dialogues.map((dialogue) => {
    const statuses = roundStatuses(dialogue.rounds)
    const items = dialogue.rounds.map((round, i) => {
      const status = statuses[i] ?? 'Not reviewed'
      const href = `/${dialogue.slug}/round-${String(round.round)}`
      const cls = status === 'Waiting for your review' ? ' class="waiting"' : ''
      // The dialogue title is part of the link's name for screen readers, so two
      // dialogues never give two links that both read only "Round 1".
      const name = `Round ${String(round.round)}, ${escapeHtml(dialogue.title)}`
      return `<li${cls}><a href="${href}" aria-label="${name}">Round ${String(round.round)}</a> <span class="status">${status}</span></li>`
    })
    return `<section class="dialogue" aria-labelledby="d-${dialogue.slug}">
<h2 id="d-${dialogue.slug}">${escapeHtml(dialogue.title)}</h2>
<p class="slug">Dialogue: ${dialogue.slug}</p>
<ul>
${items.join('\n')}
</ul>
</section>`
  })
  const body =
    dialogues.length === 0 ? '<p>Nothing is waiting for your review right now.</p>' : sections.join('\n')
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex, nofollow, noarchive">
<title>PuhuScribe review</title>
<style>
${STYLE}
</style>
</head>
<body>
<main>
<h1>Dialogues to review</h1>
<p class="intro">Open the round that says "Waiting for your review" and make a choice for every item on the page. When you are done, press "Download my review" at the end of the page and send the saved file back the way you agreed.</p>
${body}
</main>
</body>
</html>
`
}

export const ROBOTS_TXT = 'User-agent: *\nDisallow: /\n'

// Checks everything first, then replaces `out` with the new site. On bad input
// it writes nothing and removes any older build, so a stale site cannot be
// deployed by mistake.
export function buildReviewSite(root: string, out: string): BuildResult {
  let dialogues: Dialogue[]
  try {
    dialogues = readDialogues(root)
  } catch (error) {
    rmSync(out, { recursive: true, force: true })
    throw error
  }
  const files = ['index.html', 'robots.txt']
  for (const d of dialogues) for (const r of d.rounds) files.push(`${d.slug}/round-${String(r.round)}.html`)

  rmSync(out, { recursive: true, force: true })
  mkdirSync(out, { recursive: true })
  writeFileSync(join(out, 'index.html'), indexHtml(dialogues))
  writeFileSync(join(out, 'robots.txt'), ROBOTS_TXT)
  for (const d of dialogues) {
    mkdirSync(join(out, d.slug), { recursive: true })
    for (const r of d.rounds) copyFileSync(r.source, join(out, d.slug, `round-${String(r.round)}.html`))
  }
  return { files: files.sort(), dialogues }
}

function main(): void {
  const root = process.cwd()
  const out = resolve(root, 'dist-review')
  try {
    const { files } = buildReviewSite(root, out)
    console.log(`Review site built in dist-review/ with ${String(files.length)} files:`)
    for (const file of files) console.log(`  ${file}`)
  } catch (error) {
    if (error instanceof ReviewSiteError) {
      console.error(`Review site not built: ${error.message}`)
      process.exit(1)
    }
    throw error
  }
}

if (import.meta.main) main()
