import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'
import {
  applyCorrections,
  CORRECTIONS_HEADER,
  parseCorrections,
  parseIpaMigration,
  parseStarterSeed,
  renderIpaLoad,
  renderSentenceLoad,
  sqlText,
  type StarterSentence,
} from './v2-starter.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/3-data-model/spec.md. Owner's decision of 20 October 2026: the
// starter sentence loader is tested with made-up fixture data only, until the
// reviewer's corrections to v2's 104 sentences arrive.

const fixtureSeed = readFileSync('scripts/v2-import/fixtures/v2-seed.fixture.sql', 'utf8')
const fixtureCorrections = readFileSync('scripts/v2-import/fixtures/corrections.fixture.tsv', 'utf8')
const row = (k: string, p: string, e: string) =>
  `  ('${k}', '${p}', '${e}', 'A1', (SELECT id FROM topics WHERE slug = 'arki'))`
const seed = (...rows: string[]) =>
  ['INSERT INTO sentences (kirjakieli, puhekieli, translation_en, level, topic_id) VALUES', ...rows].join(
    '\n',
  )
const tsv = (...rows: string[]) => [CORRECTIONS_HEADER, ...rows].join('\n') + '\n'

describe('reading the starter sentences in v2 shape', () => {
  it('[data 15] reads every row in order, numbering them from 1, skipping comment lines', () => {
    expect(parseStarterSeed(fixtureSeed)).toEqual([
      {
        ref: 1,
        kirja: 'Fixture written one.',
        puhe: 'Fixture spoken one.',
        en: 'Fixture English one.',
        corrected: [],
      },
      {
        ref: 2,
        kirja: "Fixture written two's.",
        puhe: "Fixture spoken two's.",
        en: "Fixture English two's.",
        corrected: [],
      },
      {
        ref: 3,
        kirja: 'Fixture written three.',
        puhe: 'Fixture spoken three.',
        en: 'Fixture English three.',
        corrected: [],
      },
    ])
  })

  it('[data 15] stops on a line it does not understand, so a changed file is never half read', () => {
    expect(() => parseStarterSeed(seed(row('a', 'b', 'c') + ',', "  ('a', 'b', 'c', 'A2', null);"))).toThrow(
      /Line 3 is not a sentence row/,
    )
  })

  it('[data 15] stops when the insert never ends', () => {
    expect(() => parseStarterSeed(seed(row('a', 'b', 'c') + ','))).toThrow(/never ends/)
  })

  it('[data 15] stops when there is no sentence insert at all', () => {
    expect(() => parseStarterSeed('select 1;')).toThrow(/No "INSERT INTO sentences" line/)
  })
})

describe('the corrections file', () => {
  const sentences = parseStarterSeed(fixtureSeed)

  it("[data 15] content/v2-starter/corrections.tsv is the header line only, waiting for the owner's list", () => {
    const text = readFileSync('content/v2-starter/corrections.tsv', 'utf8')
    expect(text).toBe(`${CORRECTIONS_HEADER}\n`)
    expect(parseCorrections(text)).toEqual([])
  })

  it('[data 15] applies each correction to the named sentence and register', () => {
    const corrected = applyCorrections(sentences, parseCorrections(fixtureCorrections))
    expect(corrected[0]).toMatchObject({
      puhe: 'Fixture spoken one, corrected.',
      kirja: 'Fixture written one.',
      corrected: ['puhe'],
    })
    expect(corrected[1]).toMatchObject({ corrected: [] })
    expect(corrected[2]).toMatchObject({ kirja: 'Fixture written three, corrected.', corrected: ['kirja'] })
    // The input is not changed.
    expect(sentences[0]?.puhe).toBe('Fixture spoken one.')
  })

  it.each([
    ['a trailing space', 'Fixture spoken one. '],
    ['a different capital letter', 'fixture spoken one.'],
    ['the other register', 'Fixture written one.'],
  ])('[data 15] fails when "before" differs from v2 by %s', (_label, before) => {
    expect(() => applyCorrections(sentences, parseCorrections(tsv(`1\tpuhe\t${before}\tNew text.`)))).toThrow(
      /does not match v2 exactly/,
    )
  })

  it('[data 15] fails for a sentence number that does not exist', () => {
    expect(() => applyCorrections(sentences, parseCorrections(tsv('4\tpuhe\tx\ty')))).toThrow(/no sentence 4/)
  })

  it('[data 15] fails when the same sentence and register is corrected twice', () => {
    const twice = tsv('1\tpuhe\tFixture spoken one.\tA.', '1\tpuhe\tA.\tB.')
    expect(() => applyCorrections(sentences, parseCorrections(twice))).toThrow(/corrected twice/)
  })

  it.each([
    ['a missing header', 'sentence register before after\n', /first line must be the header/],
    ['a wrong register', tsv('1\tspoken\ta\tb'), /register must be puhe or kirja/],
    ['a missing cell', tsv('1\tpuhe\ta'), /expected 4 tab separated cells/],
    ['an extra cell', tsv('1\tpuhe\ta\tb\tc'), /expected 4 tab separated cells/],
    ['a sentence that is not a number', tsv('one\tpuhe\ta\tb'), /not a sentence number/],
    ['an empty "after"', tsv('1\tpuhe\ta\t '), /must not be empty/],
    ['"after" equal to "before"', tsv('1\tpuhe\ta\ta'), /are the same/],
  ])('[data 15] refuses a file with %s', (_label, text, error) => {
    expect(() => parseCorrections(text)).toThrow(error)
  })

  it('[data 15] reads Windows line endings the same way', () => {
    expect(parseCorrections(fixtureCorrections.replace(/\n/g, '\r\n'))).toEqual(
      parseCorrections(fixtureCorrections),
    )
  })
})

describe('the load SQL', () => {
  const one: StarterSentence[] = [{ ref: 1, kirja: "It's", puhe: 'p', en: 'e', corrected: ['puhe'] }]

  it('[data 15] upserts the sentences keyed on (source, source_ref), so a second load adds no duplicates', () => {
    const sql = renderSentenceLoad(one, { source: 's', origin: 'o', correctionsFile: 'c.tsv', header: ['h'] })
    expect(sql).toContain(
      'insert into public.source_sentences (source, source_ref, text_kirja, text_puhe, gloss_en, note) values',
    )
    expect(sql).toContain("  ('s', '1', 'It''s', 'p', 'e', 'o, row 1; corrected (puhe) from c.tsv')")
    expect(sql).toContain('on conflict (source, source_ref) do update set')
    expect(sql.startsWith('-- h\n')).toBe(true)
  })

  it('[data 16] upserts the IPA keyed on the lemma, with source and licence', () => {
    const sql = renderIpaLoad([{ lemma: 'hei', ipa: '/ˈhei̯/' }], [])
    expect(sql).toContain("  ('hei', '/ˈhei̯/', 'English Wiktionary via kaikki.org', 'CC BY-SA 4.0')")
    expect(sql).toContain('on conflict (lemma) do update set')
  })

  it('[data 15] [data 16] quotes apostrophes and refuses control characters', () => {
    expect(sqlText("a'b")).toBe("'a''b'")
    expect(() => sqlText('a\nb')).toThrow(/Control character/)
    expect(() => sqlText('a\tb')).toThrow(/Control character/)
  })
})

describe('reading v2 pronunciation data', () => {
  it('[data 16] reads UPDATE lines and skips comments and blank lines', () => {
    const sql =
      "-- header\n\nUPDATE words SET ipa = '/a/' WHERE base_form = 'a';\nUPDATE words SET ipa = '/b''/' WHERE base_form = 'b';\n"
    expect(parseIpaMigration(sql)).toEqual([
      { lemma: 'a', ipa: '/a/' },
      { lemma: 'b', ipa: "/b'/" },
    ])
  })

  it('[data 16] stops on any other line, and on a lemma seen twice', () => {
    expect(() => parseIpaMigration("UPDATE words SET ipa = '/a/' WHERE id = 1;")).toThrow(/not an IPA update/)
    const twice =
      "UPDATE words SET ipa = '/a/' WHERE base_form = 'a';\nUPDATE words SET ipa = '/b/' WHERE base_form = 'a';"
    expect(() => parseIpaMigration(twice)).toThrow(/appears twice/)
  })
})
