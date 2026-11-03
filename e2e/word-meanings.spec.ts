import { expect, test } from './test-base.ts'
import { sessionsOf, sql, userIdOf } from './db.ts'
import { serveTone, startSession } from './session-helpers.ts'

// Labels [word-meanings N] are this quick-lane fix (3 November 2026). Job
// 20-a1-road stored two English meanings on every road form
// (forms.meaning_en and forms.lemma_meaning_en); the word card of job
// 19-redesign (statement 26) draws them. 1: tapping a word whose form has
// them shows both, exactly as the database holds them.
//
// Against the built app, its Worker and the throwaway local Supabase of the
// pull request check, so it is tagged @seed. Expected text is read from the
// database, never written here.

interface MeaningWord {
  lineId: string
  surface: string
  lemma: string
  meaning: string
  baseMeaning: string
}

/** The first spoken word of the dialogue's first line whose approved form has both meanings. */
function firstWordWithMeaning(dialogueId: string): MeaningWord | null {
  const row = sql(
    `select l.id, t.surface, f.lemma, f.meaning_en, f.lemma_meaning_en
       from public.dialogue_lines l
       join public.tokens t on t.line_id = l.id and t.register = 'puhe'
       join public.forms f on f.id = t.form_id
      where l.id = (select id from public.dialogue_lines
                     where dialogue_id = :did and status = 'approved' order by position limit 1)
        and f.status = 'approved'
        and btrim(coalesce(f.meaning_en, '')) <> ''
        and btrim(coalesce(f.lemma_meaning_en, '')) <> ''
      order by t.position limit 1`,
    { did: dialogueId },
  )[0]
  if (!row) return null
  const [lineId = '', surface = '', lemma = '', meaning = '', baseMeaning = ''] = row
  return { lineId, surface, lemma, meaning, baseMeaning }
}

function exactly(text: string): RegExp {
  return new RegExp(`^\\s*${text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\s*$`)
}

test.describe('word meanings on the word card', { tag: '@seed' }, () => {
  test.beforeEach(async ({ page }) => {
    await serveTone(page)
  })

  test('[word-meanings 1] tapping a road word shows what it means and what its dictionary form means', async ({
    page,
  }) => {
    await startSession(page)
    const userId = await userIdOf(page.context())
    const dialogueId = sessionsOf(userId)[0]?.dialogueId ?? ''
    const word = firstWordWithMeaning(dialogueId)
    expect(word, 'the first line of today’s dialogue has a word whose form has both meanings').not.toBeNull()
    if (!word) return

    const card = page.locator(`[data-line-id="${word.lineId}"]`)
    await card
      .locator('[lang="fi"]')
      .first()
      .getByRole('button', { name: word.surface, exact: true })
      .first()
      .click()
    const dialog = page.getByRole('dialog', { name: word.surface })
    await expect(dialog).toBeVisible()

    // The meaning sits on its own line under the word.
    await expect(dialog.locator('p').filter({ hasText: exactly(word.meaning) })).toBeVisible()
    // The dictionary form row holds the base form and, after it, its meaning.
    const dictionary = dialog.locator('p').filter({ hasText: 'Dictionary form' })
    await expect(dictionary).toContainText(word.lemma)
    await expect(dictionary).toContainText(word.baseMeaning)
  })
})
