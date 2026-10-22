// Reads PuhuScribe v2's starter sentences and pronunciation data, applies the
// native reviewer's corrections, and writes the SQL that loads them into the
// reference tables (job 3-data-model, "Done when" 15 and 16).
//
// Everything here is pure: text in, text out. build.ts does the file work.
import { createHash } from 'node:crypto'

/** The v2 commit job 1-stack imported from (docs/v2-imports.md). */
export const V2_COMMIT = '9c8d0a083d6209e0135efe20f88db99ff9c867e4'

/** The two v2 files this job reads, with their git blob hashes at V2_COMMIT. */
export const V2_FILES = {
  sentences: {
    v2Path: 'supabase/seeds/05_island_sentences.sql',
    copy: 'content/v2-starter/from-v2/05_island_sentences.sql',
    blob: 'f2aad90c0e8315d8836b09f3a08d101945300f99',
  },
  ipa: {
    v2Path: 'supabase/migrations/20260607000003_word_ipa_from_kaikki.sql',
    copy: 'content/v2-starter/from-v2/20260607000003_word_ipa_from_kaikki.sql',
    blob: '96218d52597100e07b4f99ed2cc5a817bdcab06e',
  },
} as const

export const STARTER_SOURCE = 'v2-starter'
export const STARTER_COUNT = 104
export const IPA_COUNT = 514
export const IPA_SOURCE = 'English Wiktionary via kaikki.org'
export const IPA_LICENCE = 'CC BY-SA 4.0'
export const CORRECTIONS_FILE = 'content/v2-starter/corrections.tsv'
export const CORRECTIONS_HEADER = 'sentence\tregister\tbefore\tafter'

export interface StarterSentence {
  /** 1 to N, in the order of the v2 file. */
  ref: number
  kirja: string
  puhe: string
  en: string
  /** Which registers a correction changed. */
  corrected: Register[]
}

export type Register = 'puhe' | 'kirja'

export interface Correction {
  /** Line number in the corrections file, for error messages. */
  line: number
  sentence: number
  register: Register
  before: string
  after: string
}

export interface LemmaIpa {
  lemma: string
  ipa: string
}

/** git's blob hash of a file's bytes, the same as `git hash-object`. */
export function gitBlobHash(bytes: Uint8Array): string {
  return createHash('sha1')
    .update(`blob ${String(bytes.length)}\0`)
    .update(bytes)
    .digest('hex')
}

function unquote(sqlLiteralBody: string): string {
  return sqlLiteralBody.replace(/''/g, "'")
}

const LITERAL = "'((?:[^']|'')*)'"
const SENTENCE_ROW = new RegExp(
  `^  \\(${LITERAL}, ${LITERAL}, ${LITERAL}, 'A1', \\(SELECT id FROM topics WHERE slug = 'arki'\\)\\)([,;])$`,
)

/**
 * Reads the sentence rows of v2's supabase/seeds/05_island_sentences.sql (or a
 * fixture in the same shape). Every line between the INSERT INTO sentences line
 * and the row ending in ";" must be a comment or a row; anything else stops the
 * import, so a changed file cannot be half read.
 */
export function parseStarterSeed(sql: string): StarterSentence[] {
  const lines = sql.replace(/\r\n/g, '\n').split('\n')
  const start = lines.findIndex((line) =>
    line.startsWith('INSERT INTO sentences (kirjakieli, puhekieli, translation_en, level, topic_id) VALUES'),
  )
  if (start < 0) throw new Error('No "INSERT INTO sentences" line found')
  const rows: StarterSentence[] = []
  let ended = false
  for (let i = start + 1; i < lines.length && !ended; i++) {
    const line = lines[i] ?? ''
    if (/^\s*--/.test(line)) continue
    const match = SENTENCE_ROW.exec(line)
    if (!match) throw new Error(`Line ${String(i + 1)} is not a sentence row: ${line}`)
    rows.push({
      ref: rows.length + 1,
      kirja: unquote(match[1] ?? ''),
      puhe: unquote(match[2] ?? ''),
      en: unquote(match[3] ?? ''),
      corrected: [],
    })
    ended = match[4] === ';'
  }
  if (!ended) throw new Error('The sentence insert never ends with ";"')
  return rows
}

/**
 * Reads the corrections file: a header line, then one tab separated row per
 * change: sentence number, register (puhe or kirja), the text before (exactly
 * as in v2) and the text after.
 */
export function parseCorrections(tsv: string): Correction[] {
  const lines = tsv.replace(/\r\n/g, '\n').split('\n')
  if (lines.at(-1) === '') lines.pop()
  if (lines[0] !== CORRECTIONS_HEADER) {
    throw new Error(`The first line must be the header "${CORRECTIONS_HEADER.replace(/\t/g, '<tab>')}"`)
  }
  return lines.slice(1).map((text, i) => {
    const line = i + 2
    const cells = text.split('\t')
    if (cells.length !== 4)
      throw new Error(`Line ${String(line)}: expected 4 tab separated cells, found ${String(cells.length)}`)
    const [sentence, register, before, after] = cells as [string, string, string, string]
    if (!/^[1-9][0-9]*$/.test(sentence))
      throw new Error(`Line ${String(line)}: "${sentence}" is not a sentence number`)
    if (register !== 'puhe' && register !== 'kirja') {
      throw new Error(`Line ${String(line)}: register must be puhe or kirja, not "${register}"`)
    }
    if (before.trim() === '' || after.trim() === '')
      throw new Error(`Line ${String(line)}: before and after must not be empty`)
    if (before === after) throw new Error(`Line ${String(line)}: before and after are the same`)
    return { line, sentence: Number(sentence), register, before, after }
  })
}

/**
 * Applies the corrections. Each "before" must match the v2 text exactly, and a
 * sentence's register may be corrected only once, so the file cannot be
 * applied to the wrong text or in the wrong order.
 */
export function applyCorrections(sentences: StarterSentence[], corrections: Correction[]): StarterSentence[] {
  const out = sentences.map((s) => ({ ...s, corrected: [...s.corrected] }))
  const seen = new Set<string>()
  for (const c of corrections) {
    const key = `${String(c.sentence)} ${c.register}`
    if (seen.has(key)) throw new Error(`Line ${String(c.line)}: sentence ${key} is corrected twice`)
    seen.add(key)
    const target = out[c.sentence - 1]
    if (!target) throw new Error(`Line ${String(c.line)}: there is no sentence ${String(c.sentence)}`)
    if (target[c.register] !== c.before) {
      throw new Error(
        `Line ${String(c.line)}: sentence ${key} "before" does not match v2 exactly.\n  v2:     ${JSON.stringify(target[c.register])}\n  before: ${JSON.stringify(c.before)}`,
      )
    }
    target[c.register] = c.after
    target.corrected.push(c.register)
  }
  return out
}

const IPA_ROW = new RegExp(`^UPDATE words SET ipa = ${LITERAL} WHERE base_form = ${LITERAL};$`)

/** Reads the 514 lemma to IPA pairs from v2's word_ipa_from_kaikki migration. */
export function parseIpaMigration(sql: string): LemmaIpa[] {
  const out: LemmaIpa[] = []
  const seen = new Set<string>()
  for (const [i, line] of sql.replace(/\r\n/g, '\n').split('\n').entries()) {
    if (line === '' || line.startsWith('--')) continue
    const match = IPA_ROW.exec(line)
    if (!match) throw new Error(`Line ${String(i + 1)} is not an IPA update: ${line}`)
    const lemma = unquote(match[2] ?? '')
    if (seen.has(lemma)) throw new Error(`Line ${String(i + 1)}: lemma "${lemma}" appears twice`)
    seen.add(lemma)
    out.push({ lemma, ipa: unquote(match[1] ?? '') })
  }
  return out
}

/** A SQL string literal. Refuses control characters, which no row should hold. */
export function sqlText(value: string): string {
  for (const char of value) {
    const code = char.codePointAt(0) ?? 0
    if (code < 0x20 || code === 0x7f) throw new Error(`Control character in ${JSON.stringify(value)}`)
  }
  return `'${value.replace(/'/g, "''")}'`
}

/** Sorts by Unicode code point, the same order as Postgres `collate "C"` for these texts. */
function byCodePoint(a: string, b: string): number {
  return a < b ? -1 : a > b ? 1 : 0
}

/**
 * The fingerprint the pgTAP tests compare with the database:
 * md5(string_agg(lemma || E'\t' || ipa, E'\n' order by lemma collate "C")).
 */
export function ipaFingerprint(entries: LemmaIpa[]): string {
  const text = [...entries]
    .sort((a, b) => byCodePoint(a.lemma, b.lemma))
    .map((e) => `${e.lemma}\t${e.ipa}`)
    .join('\n')
  return createHash('md5').update(text, 'utf8').digest('hex')
}

/**
 * The same kind of fingerprint for sentences:
 * md5(string_agg(source_ref || E'\t' || text_kirja || E'\t' || text_puhe || E'\t' || gloss_en,
 *     E'\n' order by source_ref::int)).
 */
export function sentenceFingerprint(sentences: StarterSentence[]): string {
  const text = [...sentences]
    .sort((a, b) => a.ref - b.ref)
    .map((s) => [String(s.ref), s.kirja, s.puhe, s.en].join('\t'))
    .join('\n')
  return createHash('md5').update(text, 'utf8').digest('hex')
}

export interface SentenceLoadOptions {
  /** The `source` column, for example "v2-starter". */
  source: string
  /** Where the rows came from, written into each row's note. */
  origin: string
  /** The corrections file that was applied, written into each row's note. */
  correctionsFile: string
  /** Comment lines at the top of the SQL file (without "-- "). */
  header: string[]
}

/** An upsert keyed on (source, source_ref), so loading twice changes nothing. */
export function renderSentenceLoad(sentences: StarterSentence[], options: SentenceLoadOptions): string {
  const rows = sentences.map((s) => {
    const note =
      `${options.origin}, row ${String(s.ref)}; ` +
      (s.corrected.length > 0
        ? `corrected (${s.corrected.join(', ')}) from ${options.correctionsFile}`
        : `no correction in ${options.correctionsFile}`)
    return `  (${[sqlText(options.source), sqlText(String(s.ref)), sqlText(s.kirja), sqlText(s.puhe), sqlText(s.en), sqlText(note)].join(', ')})`
  })
  return [
    ...options.header.map((line) => (line === '' ? '--' : `-- ${line}`)),
    '',
    'insert into public.source_sentences (source, source_ref, text_kirja, text_puhe, gloss_en, note) values',
    rows.join(',\n'),
    'on conflict (source, source_ref) do update set',
    '  text_kirja = excluded.text_kirja,',
    '  text_puhe = excluded.text_puhe,',
    '  gloss_en = excluded.gloss_en,',
    '  note = excluded.note;',
    '',
  ].join('\n')
}

/** An upsert keyed on the lemma, so loading twice changes nothing. */
export function renderIpaLoad(entries: LemmaIpa[], header: string[]): string {
  const rows = entries.map(
    (e) => `  (${[sqlText(e.lemma), sqlText(e.ipa), sqlText(IPA_SOURCE), sqlText(IPA_LICENCE)].join(', ')})`,
  )
  return [
    ...header.map((line) => (line === '' ? '--' : `-- ${line}`)),
    '',
    'insert into public.lemma_ipa (lemma, ipa, source, licence) values',
    rows.join(',\n'),
    'on conflict (lemma) do update set',
    '  ipa = excluded.ipa,',
    '  source = excluded.source,',
    '  licence = excluded.licence;',
    '',
  ].join('\n')
}
