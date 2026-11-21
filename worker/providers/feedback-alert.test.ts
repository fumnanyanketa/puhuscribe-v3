import { describe, expect, it, vi } from 'vitest'
import {
  ALERT_GAP_SECONDS,
  ALERT_SENDER,
  ALERT_SUBJECT,
  BREVO_SEND_URL,
  alertText,
  memoryGate,
  sendFeedbackAlert,
} from './feedback-alert.ts'

// Labels [feedback-alert N] are the "Done when" statement numbers in
// factory/jobs/feedback-alert/build.md that each test protects.

const ENV = {
  BREVO_API_KEY: 'test-brevo-key',
  FEEDBACK_ALERT_TO: 'owner@example.test',
  OWNER_HOSTNAME: 'owner.meetaleksi.com',
}
const AT = new Date('2026-11-21T12:32:00Z')

function brevo(status = 201) {
  const calls: { url: string; init: RequestInit; body: string }[] = []
  const fetch = vi.fn((input: string | URL | Request, init?: RequestInit) => {
    const url = input instanceof Request ? input.url : input.toString()
    calls.push({ url, init: init ?? {}, body: typeof init?.body === 'string' ? init.body : '' })
    return Promise.resolve(new Response('{}', { status }))
  })
  return { fetch, calls }
}

describe('sendFeedbackAlert', () => {
  it('[feedback-alert 1] sends one email through Brevo with the key, the sender, the owner inbox and the subject', async () => {
    const { fetch, calls } = brevo()
    expect(await sendFeedbackAlert(ENV, fetch, 'finish', AT, memoryGate())).toBe(true)
    expect(calls).toHaveLength(1)
    expect(calls[0]?.url).toBe(BREVO_SEND_URL)
    expect(calls[0]?.init.method).toBe('POST')
    expect(new Headers(calls[0]?.init.headers).get('api-key')).toBe('test-brevo-key')
    const body = JSON.parse(calls[0]?.body ?? '') as Record<string, unknown>
    expect(body.sender).toEqual(ALERT_SENDER)
    expect(body.to).toEqual([{ email: 'owner@example.test' }])
    expect(body.subject).toBe(ALERT_SUBJECT)
  })

  it('[feedback-alert 2] the text names the screen, the Helsinki time and the owner page link, and nothing else', () => {
    const text = alertText('finish', AT, 'owner.meetaleksi.com')
    expect(text).toContain('from the end of a lesson')
    expect(text).toContain('21 November')
    expect(text).toContain('14:32')
    expect(text).toContain('https://owner.meetaleksi.com/learn/owner')
    expect(alertText('account', AT, '')).not.toContain('https://')
  })

  it('[feedback-alert 2] the request never carries a message, an account id or a token', async () => {
    const { fetch, calls } = brevo()
    await sendFeedbackAlert(ENV, fetch, 'account', AT, memoryGate())
    const body = calls[0]?.body ?? ''
    expect(Object.keys(JSON.parse(body) as object).sort()).toEqual(['sender', 'subject', 'textContent', 'to'])
    const parsed = JSON.parse(body) as { textContent: string }
    expect(parsed.textContent).toBe(alertText('account', AT, 'owner.meetaleksi.com'))
    expect(body).not.toMatch(/user_id|bearer|authorization/i)
  })

  it('[feedback-alert 3] sends nothing without the key or the inbox', async () => {
    const { fetch } = brevo()
    expect(await sendFeedbackAlert({ ...ENV, BREVO_API_KEY: '' }, fetch, 'finish', AT, memoryGate())).toBe(
      false,
    )
    expect(
      await sendFeedbackAlert({ ...ENV, FEEDBACK_ALERT_TO: ' ' }, fetch, 'finish', AT, memoryGate()),
    ).toBe(false)
    expect(fetch).not.toHaveBeenCalled()
  })

  it('[feedback-alert 4] sends at most one alert per gap, and another once the gap has passed', async () => {
    const { fetch } = brevo()
    const gate = memoryGate()
    expect(await sendFeedbackAlert(ENV, fetch, 'finish', AT, gate)).toBe(true)
    const justInside = new Date(AT.getTime() + ALERT_GAP_SECONDS * 1000 - 1)
    expect(await sendFeedbackAlert(ENV, fetch, 'account', justInside, gate)).toBe(false)
    const after = new Date(AT.getTime() + ALERT_GAP_SECONDS * 1000)
    expect(await sendFeedbackAlert(ENV, fetch, 'account', after, gate)).toBe(true)
    expect(fetch).toHaveBeenCalledTimes(2)
  })

  it('[feedback-alert 4] without the settings the gap is never started', async () => {
    const { fetch } = brevo()
    const gate = memoryGate()
    await sendFeedbackAlert({}, fetch, 'finish', AT, gate)
    expect(await sendFeedbackAlert(ENV, fetch, 'finish', AT, gate)).toBe(true)
  })

  it('[feedback-alert 5] never throws: a refusal or a network failure answers false', async () => {
    expect(await sendFeedbackAlert(ENV, brevo(401).fetch, 'finish', AT, memoryGate())).toBe(false)
    const failing = vi.fn(() => Promise.reject(new Error('offline')))
    expect(await sendFeedbackAlert(ENV, failing, 'finish', AT, memoryGate())).toBe(false)
  })
})
