import { AxeBuilder } from '@axe-core/playwright'
import { expect, test, type Page } from '@playwright/test'
import { linesOf, one, sessionsOf, sql, userIdOf } from './db.ts'
import { microphoneCalls, microphoneReleased, stubMicrophone, useSpeechFixture } from './microphone.ts'
import {
  finishHearIt,
  finishUnderstandIt,
  scrollsSideways,
  serveTone,
  startSession,
  tabTo,
} from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.
//
// Phone size against the built app, the throwaway local Supabase with the
// test fixture unit, and the Worker running the fake speech provider
// (SPEECH_FEEDBACK_PROVIDER=fake, set only in the pull request browser job).
// The microphone is a generated tone (e2e/microphone.ts), never speech. The
// fake answers each check from a recorded fixture picked with a test header;
// with no fixture named it answers as if it heard the line exactly.

const NOTICE_VERSION = 'voice-2026-10.1'
const RECORD = 'Record yourself saying the line'

async function toSayIt(page: Page) {
  await startSession(page)
  const userId = await userIdOf(page.context())
  const session = sessionsOf(userId)[0]
  const lines = linesOf(session?.dialogueId ?? '')
  const glossOf = (lineId: string) => lines.find((line) => line.id === lineId)?.gloss ?? ''
  await finishHearIt(page)
  await finishUnderstandIt(page, glossOf)
  return { userId, sessionId: session?.id ?? '', lines }
}

const consentHeading = (page: Page) => page.getByRole('heading', { level: 1, name: 'Speaking feedback' })
const status = (page: Page) => page.getByRole('status')

async function turnOn(page: Page, keep = false) {
  await expect(consentHeading(page)).toBeVisible()
  if (keep) await page.getByRole('checkbox').check()
  await page.getByRole('button', { name: 'Turn on speaking feedback' }).click()
  await expect(page.getByRole('heading', { level: 1, name: 'Say it' })).toBeVisible()
}

/** Records about a second of the tone, stops, and waits for the result. */
async function recordOnce(page: Page, ms = 1_200) {
  await page.getByRole('button', { name: RECORD }).click()
  await expect(page.getByRole('button', { name: /^Stop recording/ })).toBeVisible()
  await page.waitForTimeout(ms)
  await page.getByRole('button', { name: /^Stop recording/ }).click()
  await expect(page.getByRole('button', { name: RECORD })).toBeVisible({ timeout: 20_000 })
}

test.describe('speaking feedback', { tag: '@seed' }, () => {
  test.beforeEach(async ({ page }) => {
    await serveTone(page)
  })

  test('[speak 1] [speak 2] the consent screen comes first, asks for nothing, and Turn on records the choice with the text version', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    const { userId } = await toSayIt(page)
    await expect(consentHeading(page)).toBeVisible()
    await expect(page.getByText('Say it, step 3 of 3', { exact: true })).toBeVisible()
    for (const text of [
      'records your voice only while the record button is on, for a few seconds per line.',
      "through PuhuScribe's server to Microsoft's speech service in the EU",
      'PuhuScribe deletes it as soon as your feedback is ready.',
      'That text is deleted after 90 days.',
      'You can change both choices at any time in Voice settings.',
    ]) {
      await expect(page.getByText(text, { exact: false })).toBeVisible()
    }
    const box = page.getByRole('checkbox', {
      name: 'Keep my recordings so I can hear my progress. We keep your first and latest try of each line for 90 days. You can delete them at any time.',
    })
    await expect(box).not.toBeChecked()
    await expect(page.getByRole('button', { name: 'Not now' })).toBeVisible()
    expect(await microphoneCalls(page)).toBe(0)
    expect(one(`select count(*) from public.consents where user_id = :'uid'`, { uid: userId })).toBe('0')

    await turnOn(page)
    expect(await microphoneCalls(page)).toBe(0)
    expect(
      sql(`select kind, granted, notice_version from public.consents where user_id = :'uid'`, {
        uid: userId,
      }),
    ).toEqual([['voice_processing', 't', NOTICE_VERSION]])
    await recordOnce(page)
    expect(await microphoneCalls(page)).toBe(1)
  })

  test('[speak 2] a ticked box adds the retention row as well', async ({ page }) => {
    await stubMicrophone(page, 'tone')
    const { userId } = await toSayIt(page)
    await turnOn(page, true)
    expect(
      sql(`select kind, granted, notice_version from public.consents where user_id = :'uid' order by kind`, {
        uid: userId,
      }),
    ).toEqual([
      ['voice_processing', 't', NOTICE_VERSION],
      ['voice_recording_retention', 't', NOTICE_VERSION],
    ])
  })

  test('[speak 3] after "Not now" each line can be said out loud, nothing is recorded or sent, and the quiet link opens the consent screen', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    const speech: string[] = []
    page.on('request', (r) => {
      if (new URL(r.url()).pathname.startsWith('/api/speech')) speech.push(r.url())
    })
    const { userId, lines } = await toSayIt(page)
    await page.getByRole('button', { name: 'Not now' }).click()
    await expect(page.getByText('Say the line out loud after the voice.', { exact: true })).toBeVisible()
    await expect(page.getByRole('button', { name: RECORD })).toHaveCount(0)
    await expect(page.getByRole('button', { name: 'Play the spoken line' })).toBeVisible()
    await page.getByRole('button', { name: 'Turn on speaking feedback' }).click()
    await expect(consentHeading(page)).toBeVisible()
    await page.getByRole('button', { name: 'Not now' }).click()
    for (let i = 1; i < lines.length; i += 1) await page.getByRole('button', { name: 'Next line' }).click()
    await page.getByRole('button', { name: 'Continue' }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    expect(await microphoneCalls(page)).toBe(0)
    expect(speech).toEqual([])
    expect(one(`select count(*) from public.speaking_attempts where user_id = :'uid'`, { uid: userId })).toBe(
      '0',
    )
    expect(sessionsOf(userId)[0]?.step).toBe('say')
  })

  test('[speak 5] [speak 6] [speak 15] [speak 17] a whole dialogue, one try per line: feedback, no transcript in any answer, attempts stored, no audio kept', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    const bodies: string[] = []
    page.on('response', (res) => {
      if (new URL(res.url()).pathname === '/api/speech/say') {
        void res.text().then(
          (text) => bodies.push(text),
          () => undefined,
        )
      }
    })
    const { userId, lines } = await toSayIt(page)
    await turnOn(page)
    expect(sessionsOf(userId)[0]?.step).toBe('understand')
    for (let i = 0; i < lines.length; i += 1) {
      const line = lines[i]
      await expect(page.locator('[data-say-line]')).toHaveAttribute('data-say-line', line?.id ?? '')
      await expect(page.locator('[data-say-line] [lang="fi"]').first()).toHaveText(
        (line?.puhe ?? '').replace(/\s+/g, ' '),
      )
      // "Next line" comes only after a try.
      await expect(
        page.getByRole('button', { name: i === lines.length - 1 ? 'Continue' : 'Next line' }),
      ).toHaveCount(0)
      await recordOnce(page)
      await expect(status(page)).toHaveText('Yes, that was clear.')
      await expect(page.getByRole('button', { name: 'Try again' })).toBeVisible()
      await page.getByRole('button', { name: i === lines.length - 1 ? 'Continue' : 'Next line' }).click()
    }
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    expect(sessionsOf(userId)[0]?.step).toBe('say')
    expect(await microphoneReleased(page)).toBe(true)

    expect(bodies).toHaveLength(lines.length)
    for (const body of bodies) expect(Object.keys(JSON.parse(body) as object)).toEqual(['feedbackClass'])
    const attempts = sql(
      `select line_id, length(transcript) > 0, feedback_class, provider, audio_ms > 0 from public.speaking_attempts
        where user_id = :'uid' order by created_at`,
      { uid: userId },
    )
    expect(attempts).toEqual(lines.map((line) => [line.id, 't', 'clear', 'fake', 't']))
    expect(one(`select count(*) from public.kept_recordings where user_id = :'uid'`, { uid: userId })).toBe(
      '0',
    )
  })

  test('[speak 5] leaving at Say it resumes there, and after Say it resumes at the finish screen', async ({
    page,
  }) => {
    const { userId, lines } = await toSayIt(page)
    const leave = async () => {
      await page.getByRole('link', { name: 'Leave session' }).click()
      await page.waitForURL((url) => url.pathname === '/')
      await page.getByRole('button', { name: "Continue today's session" }).click()
      await page.waitForURL('**/session')
    }
    await leave()
    await expect(consentHeading(page)).toBeVisible()
    await page.getByRole('button', { name: 'Not now' }).click()
    await page.route('**/api/sessions/*/complete', (route) => route.abort('failed'))
    for (let i = 1; i < lines.length; i += 1) await page.getByRole('button', { name: 'Next line' }).click()
    await page.getByRole('button', { name: 'Continue' }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    await leave()
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    expect(sessionsOf(userId)[0]).toMatchObject({ step: 'say', ended: false })
  })

  test('[speak 6] "I can\'t speak right now" skips the rest of Say it without recording', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    const { userId } = await toSayIt(page)
    await turnOn(page)
    await page.getByRole('button', { name: "I can't speak right now" }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
    expect(await microphoneCalls(page)).toBe(0)
    expect(sessionsOf(userId)[0]?.step).toBe('say')
  })

  test('[speak 7] each result gets its one kind message, Finnish words from the line marked as Finnish, and no score or transcript', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    const fixture = await useSpeechFixture(page)
    const { lines } = await toSayIt(page)
    expect(lines[0]?.puhe).toBe('Moi! Mä oon Alex.')
    await turnOn(page)
    const rows: [string, 'neutral' | 'gentle', string, string | null][] = [
      ['line1-clear', 'neutral', 'Yes, that was clear.', null],
      ['line1-double', 'gentle', 'Close. Try the double o.', 'o'],
      ['line1-single', 'gentle', 'Close. Try a single l.', 'l'],
      ['line1-vowel', 'gentle', 'Close. Try ä instead of a.', 'ä'],
      ['line1-missing', 'gentle', 'Close. Try it again with oon.', 'oon'],
      ['line1-off', 'gentle', 'Close. Listen to oon once more, then try again.', 'oon'],
      ['line1-flagged', 'gentle', 'Close. Listen to oon once more, then try again.', 'oon'],
      ['line1-try-again', 'gentle', 'Listen to the line once more, then try again.', null],
      ['not-heard', 'gentle', 'That was too quiet to hear. Try again a little closer to the phone.', null],
    ]
    for (const [name, tone, text, finnish] of rows) {
      fixture.set(name)
      await recordOnce(page)
      await expect(status(page), name).toHaveText(text)
      await expect(status(page), name).toHaveAttribute('data-tone', tone)
      if (finnish) await expect(status(page).locator('[lang="fi"]').first(), name).toHaveText(finnish)
      else await expect(status(page).locator('[lang="fi"]'), name).toHaveCount(0)
      await expect(
        page.getByText(/score|percent|%|mistake|\d+ (of|\/) \d+ (right|correct)/i),
        name,
      ).toHaveCount(0)
      // The transcripts of the fixtures are never on the page.
      await expect(page.getByText(/moi mä on alex|moi ma oon alex|moi mä alex/i), name).toHaveCount(0)
    }
  })

  test('[speak 8] "Play my recording" plays from memory; nothing goes to any browser store, and the recording goes with the line', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    const { lines } = await toSayIt(page)
    await turnOn(page)
    await recordOnce(page)
    const play = page.getByRole('button', { name: 'Play my recording' })
    await expect(play).toBeVisible()
    await play.click()
    const stores = await page.evaluate<Record<string, number>>(`(async () => ({
      local: localStorage.length,
      session: sessionStorage.length,
      indexed: 'databases' in indexedDB ? (await indexedDB.databases()).length : 0,
      caches: (await caches.keys()).length,
    }))()`)
    expect(stores).toEqual({ local: 0, session: 0, indexed: 0, caches: 0 })
    if (lines.length > 1) {
      await page.getByRole('button', { name: 'Next line' }).click()
      await expect(play).toHaveCount(0)
    }
  })

  test('[speak 9] a browser without recording says so, and Continue still works', async ({ page }) => {
    await stubMicrophone(page, 'none')
    const { lines } = await toSayIt(page)
    await turnOn(page)
    await expect(page.getByText('Recording is not available in this browser.', { exact: true })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Recording is not available' })).toBeDisabled()
    for (let i = 1; i < lines.length; i += 1) await page.getByRole('button', { name: 'Next line' }).click()
    await page.getByRole('button', { name: 'Continue' }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
  })

  test('[speak 9] refused microphone access says how to turn it on, and Next line still works', async ({
    page,
  }) => {
    await stubMicrophone(page, 'denied')
    await toSayIt(page)
    await turnOn(page)
    await page.getByRole('button', { name: RECORD }).click()
    await expect(status(page)).toHaveText(
      'Microphone access is off. You can turn it on in your browser settings, or carry on without recording.',
    )
    await expect(status(page)).toHaveAttribute('data-tone', 'problem')
    await expect(page.getByRole('button', { name: 'Recording is not available' })).toBeDisabled()
    await expect(page.getByRole('button', { name: /^(Next line|Continue)$/ })).toBeVisible()
  })

  test('[speak 9] going to the background throws the recording away and says so', async ({ page }) => {
    await stubMicrophone(page, 'tone')
    const speech: string[] = []
    page.on('request', (r) => {
      if (new URL(r.url()).pathname === '/api/speech/say') speech.push(r.url())
    })
    await toSayIt(page)
    await turnOn(page)
    await page.getByRole('button', { name: RECORD }).click()
    await expect(page.getByRole('button', { name: /^Stop recording/ })).toBeVisible()
    await page.evaluate(
      "Object.defineProperty(document, 'visibilityState', { value: 'hidden', configurable: true }); document.dispatchEvent(new Event('visibilitychange'))",
    )
    await expect(status(page)).toHaveText(
      'Recording stopped because the app was in the background. Try again.',
    )
    await expect(page.getByRole('button', { name: RECORD })).toBeVisible()
    expect(await microphoneReleased(page)).toBe(true)
    expect(speech).toEqual([])
  })

  test('[speak 9] a try shorter than half a second is not heard, with no call to the server', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    const speech: string[] = []
    page.on('request', (r) => {
      if (new URL(r.url()).pathname === '/api/speech/say') speech.push(r.url())
    })
    await toSayIt(page)
    await turnOn(page)
    await recordOnce(page, 50)
    await expect(status(page)).toHaveText(
      'That was too quiet to hear. Try again a little closer to the phone.',
    )
    expect(speech).toEqual([])
    expect(await microphoneReleased(page)).toBe(true)
  })

  test('[speak 6] [speak 9] recording shows the time and stops by itself at 10 seconds', async ({ page }) => {
    test.setTimeout(60_000)
    await stubMicrophone(page, 'tone')
    await toSayIt(page)
    await turnOn(page)
    await page.getByRole('button', { name: RECORD }).click()
    await expect(page.getByRole('button', { name: /^Stop recording, [1-9] seconds? recorded/ })).toBeVisible({
      timeout: 3_000,
    })
    await expect(status(page)).toHaveText('Yes, that was clear.', { timeout: 20_000 })
  })

  test('[speak 13] without the speech service, Say it says it is not available and Continue still works', async ({
    page,
  }) => {
    await page.route('**/api/voice', (route) =>
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          available: false,
          region: null,
          processing: 'not_asked',
          retention: false,
          recordings: [],
        }),
      }),
    )
    const { lines } = await toSayIt(page)
    await expect(
      page.getByText('Speaking feedback is not available right now.', { exact: true }),
    ).toBeVisible()
    await expect(page.getByRole('button', { name: 'Recording is not available' })).toBeDisabled()
    for (let i = 1; i < lines.length; i += 1) await page.getByRole('button', { name: 'Next line' }).click()
    await page.getByRole('button', { name: 'Continue' }).click()
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
  })

  test('[speak 4] [speak 19] Voice settings: kept recordings listed and playable; turning keep off deletes them; turning feedback off clears transcripts', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    const { userId, lines } = await toSayIt(page)
    await turnOn(page, true)
    await recordOnce(page)
    await expect(status(page)).toHaveText('Yes, that was clear.')
    await page.getByRole('button', { name: 'Try again' }).click()
    await expect(page.getByRole('button', { name: /^Stop recording/ })).toBeVisible()
    await page.waitForTimeout(1_000)
    await page.getByRole('button', { name: /^Stop recording/ }).click()
    await expect(status(page)).toHaveText('Yes, that was clear.', { timeout: 20_000 })
    expect(
      sql(`select slot from public.kept_recordings where user_id = :'uid' order by slot`, {
        uid: userId,
      }).flat(),
    ).toEqual(['first', 'latest'])

    // Linked from Say it and from the front door.
    await page.getByRole('link', { name: 'Voice settings' }).click()
    await page.waitForURL('**/voice')
    await expect(page.getByRole('heading', { level: 1, name: 'Voice settings' })).toBeVisible()
    const items = page.locator('[data-recording-id]')
    await expect(items).toHaveCount(2)
    await expect(items.first().locator('[lang="fi"]')).toHaveText(lines[0]?.puhe ?? '')
    await expect(items.first()).toContainText('Latest try')
    const id = (await items.first().getAttribute('data-recording-id')) ?? ''
    const res = await page.request.get(`/api/voice/recordings/${id}`)
    expect(res.status()).toBe(200)
    expect(res.headers()['cache-control']).toBe('private, no-store')
    expect(res.headers()['content-type']).toBe('audio/wav')
    await items.first().getByRole('button', { name: 'Play your recording' }).click()

    await items
      .first()
      .getByRole('button', { name: /^Delete this recording/ })
      .click()
    await expect(items).toHaveCount(1)
    expect(one(`select count(*) from public.kept_recordings where user_id = :'uid'`, { uid: userId })).toBe(
      '1',
    )

    await page.getByRole('button', { name: 'Stop keeping my recordings' }).click()
    await expect(page.getByText('You have no kept recordings.', { exact: true })).toBeVisible()
    expect(one(`select count(*) from public.kept_recordings where user_id = :'uid'`, { uid: userId })).toBe(
      '0',
    )
    expect(
      one(
        `select granted from public.consents where user_id = :'uid' and kind = 'voice_recording_retention' order by created_at desc, id desc limit 1`,
        { uid: userId },
      ),
    ).toBe('f')

    expect(
      one(`select count(*) from public.speaking_attempts where user_id = :'uid' and transcript <> ''`, {
        uid: userId,
      }),
    ).not.toBe('0')
    await page.getByRole('button', { name: 'Turn off speaking feedback' }).click()
    await expect(page.getByRole('button', { name: 'Turn on speaking feedback' })).toBeVisible()
    expect(
      one(`select count(*) from public.speaking_attempts where user_id = :'uid' and transcript <> ''`, {
        uid: userId,
      }),
    ).toBe('0')
    // Feedback classes stay: they hold no voice.
    expect(
      one(`select count(*) from public.speaking_attempts where user_id = :'uid'`, { uid: userId }),
    ).not.toBe('0')
    expect(
      one(
        `select granted from public.consents where user_id = :'uid' and kind = 'voice_processing' order by created_at desc, id desc limit 1`,
        { uid: userId },
      ),
    ).toBe('f')

    // Turning it on again from here shows the consent text first.
    await page.getByRole('button', { name: 'Turn on speaking feedback' }).click()
    await expect(page.getByRole('heading', { level: 2, name: 'Speaking feedback' }).last()).toBeVisible()
    await expect(page.getByRole('checkbox')).not.toBeChecked()
    await page.getByRole('button', { name: 'Turn on speaking feedback' }).click()
    await expect(page.getByRole('button', { name: 'Turn off speaking feedback' })).toBeVisible()

    await page.goto('/')
    await expect(page.getByRole('link', { name: 'Voice settings' })).toBeVisible()
  })

  test('[speak 3] [speak 4] after withdrawing, Say it shows the lines to say out loud', async ({ page }) => {
    await stubMicrophone(page, 'tone')
    await toSayIt(page)
    await turnOn(page)
    await page.goto('/voice')
    await page.getByRole('button', { name: 'Turn off speaking feedback' }).click()
    await expect(page.getByRole('button', { name: 'Turn on speaking feedback' })).toBeVisible()
    await page.goto('/session')
    await expect(page.getByText('Say the line out loud after the voice.', { exact: true })).toBeVisible()
    await expect(page.getByRole('button', { name: RECORD })).toHaveCount(0)
  })

  test('[speak 19] another learner cannot fetch a kept recording: the answer is the same 404 as a missing one', async ({
    page,
    browser,
  }) => {
    await stubMicrophone(page, 'tone')
    const { userId } = await toSayIt(page)
    await turnOn(page, true)
    await recordOnce(page)
    await expect(status(page)).toHaveText('Yes, that was clear.')
    const id = one(`select id from public.kept_recordings where user_id = :'uid'`, { uid: userId })
    expect(id).not.toBe('')

    const other = await browser.newContext({
      ignoreHTTPSErrors: true,
      baseURL: test.info().project.use.baseURL,
    })
    const b = await other.newPage()
    await b.goto('/')
    await b.getByRole('button', { name: 'Start', exact: true }).click()
    await b.waitForURL('**/session')
    const theirs = await b.request.get(`/api/voice/recordings/${id}`)
    const missing = await b.request.get('/api/voice/recordings/00000000-0000-4000-8000-000000000000')
    expect(theirs.status()).toBe(404)
    expect(missing.status()).toBe(404)
    expect(await theirs.text()).toBe(await missing.text())
    await other.close()
  })

  test('[speak 25] Say it and Voice settings fit 320 px and 200 percent text, with large enough tap areas', async ({
    page,
  }) => {
    await stubMicrophone(page, 'tone')
    await toSayIt(page)
    const check = async (label: string) => {
      for (const [width, text] of [
        [320, '100%'],
        [375, '200%'],
      ] as const) {
        await page.setViewportSize({ width, height: 812 })
        await page.addStyleTag({ content: `html { font-size: ${text} !important; }` })
        expect(await scrollsSideways(page), `${label} at ${String(width)} px, text ${text}`).toBe(false)
        await page.addStyleTag({ content: 'html { font-size: 100% !important; }' })
      }
      await page.setViewportSize({ width: 375, height: 812 })
      for (const control of await page.locator('button, a, input').all()) {
        if (!(await control.isVisible())) continue
        const box = await control.boundingBox()
        const inLine = (await control.locator('xpath=ancestor::*[@lang="fi"]').count()) > 0
        const name = (await control.getAttribute('aria-label')) ?? (await control.innerText())
        expect(box?.height ?? 0, `${label}: ${name}`).toBeGreaterThanOrEqual(44)
        expect(box?.width ?? 0, `${label}: ${name}`).toBeGreaterThanOrEqual(inLine ? 24 : 44)
      }
    }
    await expect(consentHeading(page)).toBeVisible()
    await check('consent')
    await turnOn(page, true)
    await recordOnce(page)
    await check('Say it after a try')
    await page.goto('/voice')
    await expect(page.locator('[data-recording-id]')).toHaveCount(1)
    await check('Voice settings')
  })

  test('[speak 25] the whole flow, recording included, works with the keyboard alone', async ({
    page,
  }, testInfo) => {
    await stubMicrophone(page, 'tone')
    const { lines } = await toSayIt(page)
    await expect(consentHeading(page)).toBeVisible()
    const box = page.getByRole('checkbox')
    await tabTo(page, box, testInfo)
    await page.keyboard.press('Space')
    await expect(box).toBeChecked()
    await tabTo(page, page.getByRole('button', { name: 'Turn on speaking feedback' }), testInfo)
    await page.keyboard.press('Enter')
    for (let i = 0; i < lines.length; i += 1) {
      await tabTo(page, page.getByRole('button', { name: RECORD }), testInfo)
      await page.keyboard.press('Enter')
      const stop = page.getByRole('button', { name: /^Stop recording/ })
      await expect(stop).toBeVisible()
      await page.waitForTimeout(1_000)
      await stop.focus()
      await page.keyboard.press('Enter')
      await expect(status(page)).toHaveText('Yes, that was clear.', { timeout: 20_000 })
      const next = page.getByRole('button', { name: i === lines.length - 1 ? 'Continue' : 'Next line' })
      await tabTo(page, next, testInfo)
      await page.keyboard.press('Enter')
    }
    await expect(page.getByRole('heading', { level: 1, name: 'Now you can say this.' })).toBeVisible()
  })

  for (const scheme of ['light', 'dark'] as const) {
    test(`[speak 25] axe finds no WCAG A or AA problem on the new screens, ${scheme}`, async ({ page }) => {
      await page.emulateMedia({ colorScheme: scheme })
      await stubMicrophone(page, 'tone')
      const fixture = await useSpeechFixture(page)
      const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa']
      const scan = async (label: string) => {
        await page.evaluate('document.fonts.ready')
        const result = await new AxeBuilder({ page }).withTags(TAGS).analyze()
        expect(
          result.violations.map(
            (v) => `${label} ${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`,
          ),
        ).toEqual([])
      }
      await toSayIt(page)
      await expect(consentHeading(page)).toBeVisible()
      await scan('consent')
      await turnOn(page, true)
      await scan('Say it, ready')
      fixture.set('line1-double')
      await recordOnce(page)
      await expect(status(page)).toHaveAttribute('data-tone', 'gentle')
      await scan('Say it, gentle feedback')
      await page.goto('/voice')
      await expect(page.locator('[data-recording-id]')).toHaveCount(1)
      await scan('Voice settings')
    })
  }
})
