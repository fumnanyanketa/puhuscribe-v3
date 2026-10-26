import { expect, test, type Page } from '@playwright/test'
import { one, sessionsOf, userIdOf } from './db.ts'
import { microphoneCalls, stubMicrophone } from './microphone.ts'
import {
  answerItem,
  cardOf,
  dayLater,
  finishFirstSession,
  itemFormId,
  logsOf,
  nextItem,
  throughUnderstandIt,
} from './review-helpers.ts'
import { serveTone } from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.
//
// Spoken answers in daily review, at phone size against the built app, the
// throwaway local Supabase and the Worker running the fake speech provider.
// The microphone is a generated tone (e2e/microphone.ts), never speech; with
// no fixture named the fake answers as if it heard the word exactly.

const RECORD = 'Record yourself saying the line'
const STOP = /^Stop recording/

/** Turns speaking feedback on for the signed in learner, as the consent screen does. */
async function turnOnSpeaking(page: Page) {
  const status = await page.evaluate(async () => {
    const res = await fetch('/api/voice/consent', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ choice: 'turn_on', keepRecordings: false }),
    })
    return res.status
  })
  expect(status).toBe(200)
}

/** A day later: Start, through Hear it, Understand it and Say it, to the first Keep it item. */
async function toKeepIt(page: Page, speaking: boolean) {
  const { userId } = await finishFirstSession(page)
  if (speaking) await turnOnSpeaking(page)
  dayLater(userId)
  await page.reload()
  await page.getByRole('button', { name: 'Start', exact: true }).click()
  await page.waitForURL('**/session')
  await throughUnderstandIt(page, userId)
  await expect(page.getByRole('heading', { level: 1, name: 'Keep it' })).toBeVisible()
  return userId
}

async function sayIt(page: Page) {
  await page.getByRole('button', { name: RECORD }).click()
  await expect(page.getByRole('button', { name: STOP })).toBeVisible()
  await page.waitForTimeout(1_200)
  await page.getByRole('button', { name: STOP }).click()
}

test.describe('spoken answers in review', { tag: '@seed' }, () => {
  test.beforeEach(async ({ page }) => {
    await serveTone(page)
  })

  test('[speak 21] every second item is spoken, graded by the class table, and saved with mode spoken', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    const userId = await toKeepIt(page, true)
    expect(await microphoneCalls(page)).toBe(0)

    // Item 1 is typed: no record button.
    await expect(page.getByLabel('Type the missing word', { exact: true })).toBeVisible()
    await expect(page.getByRole('button', { name: RECORD })).toHaveCount(0)
    const first = await answerItem(page, 'right')
    await nextItem(page)

    // Item 2 is spoken: a record button and no typing field.
    await expect(page.getByRole('button', { name: RECORD })).toBeVisible()
    await expect(page.getByLabel('Type the missing word', { exact: true })).toHaveCount(0)
    await expect(page.getByRole('status')).toHaveText('Say the missing word.')
    const second = await itemFormId(page)
    await sayIt(page)
    await expect(page.locator(`[data-review-feedback="${second}"]`)).toBeVisible({ timeout: 20_000 })
    await expect(page.getByRole('status')).toHaveText('Yes, that was clear.')

    // Review log: the first typed, the second spoken, both Good, and the card
    // changed by the same engine.
    const logs = logsOf(userId)
    expect(logs.find((l) => l.formId === first)).toMatchObject({ mode: 'typed', rating: 3 })
    expect(logs.find((l) => l.formId === second)).toMatchObject({ mode: 'spoken', rating: 3 })
    const card = cardOf(userId, second)
    expect(card?.reps).toBe(1)
    expect(card?.due).toBe(logs.find((l) => l.formId === second)?.due)
    expect(card?.due).toBeGreaterThan(Date.now())
    // The answer holds no transcript, and the attempt row holds a class and no session or line.
    expect(
      one(
        `select count(*) from public.speaking_attempts
          where user_id = :'uid' and form_id = :fid and session_id is null and line_id is null
            and feedback_class = 'clear'`,
        { uid: userId, fid: second },
      ),
    ).toBe('1')
    expect(one(`select count(*) from public.kept_recordings where user_id = :'uid'`, { uid: userId })).toBe(
      '0',
    )
    expect(sessionsOf(userId).some((s) => !s.ended)).toBe(true)
  })

  test('[speak 21] with speaking feedback off every item is typed and the microphone is never asked', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    await toKeepIt(page, false)
    for (let i = 0; i < 2; i += 1) {
      await expect(page.getByLabel('Type the missing word', { exact: true })).toBeVisible()
      await expect(page.getByRole('button', { name: RECORD })).toHaveCount(0)
      await answerItem(page, 'right')
      await nextItem(page)
    }
    expect(await microphoneCalls(page)).toBe(0)
  })

  test('[speak 21] a refused microphone switches the item to typing, and the item is graded as typed', async ({
    page,
  }) => {
    await stubMicrophone(page, 'denied')
    const userId = await toKeepIt(page, true)
    await answerItem(page, 'right')
    await nextItem(page)
    await page.getByRole('button', { name: RECORD }).click()
    await expect(page.getByLabel('Type the missing word', { exact: true })).toBeVisible()
    await expect(page.getByRole('status')).toHaveText(
      'We could not hear that. Type the missing word instead.',
    )
    const second = await answerItem(page, 'right')
    expect(logsOf(userId).find((l) => l.formId === second)).toMatchObject({ mode: 'typed', rating: 3 })
    expect(await userIdOf(page.context())).toBe(userId)
  })
})
