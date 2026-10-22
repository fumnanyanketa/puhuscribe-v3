import { readdirSync, readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'
import { FIXTURE, fixtureLoadText, IPA_MIGRATION, ipaMigrationText, readV2Copy } from './generate.ts'
import {
  applyCorrections,
  gitBlobHash,
  IPA_COUNT,
  ipaFingerprint,
  parseCorrections,
  parseIpaMigration,
  parseStarterSeed,
  V2_FILES,
} from './v2-starter.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/3-data-model/spec.md. These tests tie the committed SQL to its
// sources: if a load migration's rows differ from v2 (plus the corrections), or
// a pgTAP fingerprint differs from v2, a test here fails.

describe('v2 pronunciation data', () => {
  it("[data 16] the copy of v2's IPA file is byte for byte the file at the pinned v2 commit", () => {
    expect(gitBlobHash(readFileSync(V2_FILES.ipa.copy))).toBe(V2_FILES.ipa.blob)
  })

  it("[data 16] v2's file holds 514 distinct lemma to IPA pairs", () => {
    const entries = parseIpaMigration(readV2Copy('ipa'))
    expect(entries).toHaveLength(IPA_COUNT)
    expect(new Set(entries.map((e) => e.lemma)).size).toBe(IPA_COUNT)
    expect(entries[0]).toEqual({ lemma: 'hei', ipa: '/ˈhei̯/' })
  })

  it('[data 16] the committed load migration is exactly what the script makes from v2', () => {
    expect(readFileSync(IPA_MIGRATION, 'utf8')).toBe(ipaMigrationText())
  })

  it('[data 16] the migration loads the same 514 rows as v2, no more and no fewer', () => {
    const migration = readFileSync(IPA_MIGRATION, 'utf8')
    const rows = [
      ...migration.matchAll(/^ {2}\('((?:[^']|'')*)', '((?:[^']|'')*)', '[^']*', '[^']*'\),?$/gm),
    ].map((m) => ({ lemma: (m[1] ?? '').replace(/''/g, "'"), ipa: (m[2] ?? '').replace(/''/g, "'") }))
    expect(rows).toEqual(parseIpaMigration(readV2Copy('ipa')))
  })

  it("[data 16] the pgTAP fingerprint is the one computed from v2's file", () => {
    const fingerprint = ipaFingerprint(parseIpaMigration(readV2Copy('ipa')))
    const pgtap = readFileSync('supabase/tests/database/data_model_reference.test.sql', 'utf8')
    expect(pgtap).toContain(`array['${fingerprint}']`)
    expect(pgtap).toContain('array[514::bigint]')
  })
})

describe('starter sentence loader on made-up fixture data', () => {
  it('[data 15] the committed fixture load SQL is exactly what the script makes from the fixture files', () => {
    expect(readFileSync(FIXTURE.load, 'utf8')).toBe(fixtureLoadText())
  })

  it("[data 15] the load-twice check expects the fixture's row count and its fingerprint after corrections", () => {
    const corrected = applyCorrections(
      parseStarterSeed(readFileSync(FIXTURE.seed, 'utf8')),
      parseCorrections(readFileSync(FIXTURE.corrections, 'utf8')),
    )
    const check = readFileSync('scripts/v2-import/fixtures/check-load-twice.sql', 'utf8')
    const fingerprint = /Fingerprint after corrections: ([0-9a-f]{32})/.exec(fixtureLoadText())?.[1]
    expect(fingerprint).toMatch(/^[0-9a-f]{32}$/)
    expect(check).toContain(`if fingerprint <> '${fingerprint ?? ''}' then`)
    expect(check).toContain(`if loaded <> ${String(corrected.length)} then`)
    expect(check).toContain(`where source = '${FIXTURE.source}'`)
    expect(check.match(/^\\i scripts\/v2-import\/fixtures\/load\.fixture\.sql$/gm)).toHaveLength(2)
    expect(check).toMatch(/^begin;$/m)
    expect(check).toMatch(/^rollback;$/m)
  })
})

describe("owner's decision of 20 October 2026", () => {
  it("[data 15] waiting for the owner's corrections list: no migration loads the 104 starter sentences yet", () => {
    // When the reviewer has checked the typed corrections, the next round copies
    // v2's sentence file, runs `build.ts sentences`, and replaces this test with
    // the same checks the IPA data has above.
    const loading = readdirSync('supabase/migrations').filter((name) => {
      const sql = readFileSync(`supabase/migrations/${name}`, 'utf8').replace(/--.*$/gm, '')
      return /\b(insert\s+into|update|copy|merge\s+into)\s+(public\.)?source_sentences\b/i.test(sql)
    })
    expect(loading).toEqual([])
    expect(readdirSync('supabase/migrations').filter((name) => name.includes('starter_sentences'))).toEqual(
      [],
    )
  })
})
