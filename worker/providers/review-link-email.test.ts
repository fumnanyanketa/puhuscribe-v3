import { describe, expect, it } from 'vitest'
import {
  ALERT_SENDER,
  BREVO_SEND_URL,
  REVIEW_LINK_SUBJECT,
  reviewLinkEmailReady,
  reviewLinkText,
  sendReviewLinkEmail,
} from './feedback-alert.ts'

// Labels [review-links N] are the "Done when" statement numbers from
// factory/jobs/review-links/spec.md that each test protects.
// The review link email: the owner's words, word for word, from Aleksi to the
// sign up's own address through Brevo, and nothing without BREVO_API_KEY.
// The feedback and reviewer alert tests (feedback-alert.test.ts) are unchanged.

const LINK = 'https://meetaleksi.com/review/' + 'a'.repeat(43)

function recorder(status = 201) {
  const calls: { url: string; init: RequestInit | undefined }[] = []
  const fetchImpl = (input: RequestInfo | URL, init?: RequestInit) => {
    calls.push({ url: input instanceof Request ? input.url : input.toString(), init })
    return Promise.resolve(new Response('{"messageId":"x"}', { status }))
  }
  return { calls, fetchImpl }
}

describe('the review link email', () => {
  it("[review-links 1] the text is the owner's, word for word, with the name and the link", () => {
    expect(REVIEW_LINK_SUBJECT).toBe('Your Aleksi review link')
    expect(reviewLinkText('Aino', LINK)).toBe(
      [
        'Hi Aino,',
        '',
        'Thank you for offering to help check the Finnish in Aleksi.',
        '',
        `Here is your private review link: ${LINK}`,
        '',
        'It has 27 short dialogues. For each line you can listen to the audio, read it in spoken and written Finnish, and mark it Correct, Needs a fix or Not sure. Your answers save as you go, so you can stop and come back with the same link.',
        '',
        'Please keep the link to yourself, since anyone who has it can add answers.',
        '',
        'Kiitos!',
        'Fumnanya',
      ].join('\n'),
    )
  })

  it('[review-links 1] goes from Aleksi <hello@meetaleksi.com> to the sign up email through Brevo, once', async () => {
    const { calls, fetchImpl } = recorder()
    const sent = await sendReviewLinkEmail(
      { BREVO_API_KEY: 'test-brevo-key', FEEDBACK_ALERT_TO: 'owner@example.com' },
      fetchImpl,
      { name: 'Aino', email: 'aino@example.fi' },
      LINK,
    )
    expect(sent).toBe(true)
    expect(calls).toHaveLength(1)
    expect(calls[0]?.url).toBe(BREVO_SEND_URL)
    expect(new Headers(calls[0]?.init?.headers).get('api-key')).toBe('test-brevo-key')
    expect(JSON.parse(calls[0]?.init?.body as string)).toEqual({
      sender: { name: 'Aleksi', email: 'hello@meetaleksi.com' },
      to: [{ email: 'aino@example.fi' }],
      subject: 'Your Aleksi review link',
      textContent: reviewLinkText('Aino', LINK),
    })
    expect(ALERT_SENDER).toEqual({ name: 'Aleksi', email: 'hello@meetaleksi.com' })
  })

  it('[review-links 1] without BREVO_API_KEY nothing is sent, and the owner page can tell', async () => {
    const { calls, fetchImpl } = recorder()
    expect(reviewLinkEmailReady({})).toBe(false)
    expect(reviewLinkEmailReady({ BREVO_API_KEY: '  ' })).toBe(false)
    expect(reviewLinkEmailReady({ BREVO_API_KEY: 'x' })).toBe(true)
    expect(await sendReviewLinkEmail({}, fetchImpl, { name: 'Aino', email: 'aino@example.fi' }, LINK)).toBe(
      false,
    )
    expect(calls).toEqual([])
  })

  it('[review-links 1] needs no owner inbox, and has no gap: two sends in a row both go', async () => {
    const { calls, fetchImpl } = recorder()
    const env = { BREVO_API_KEY: 'x' }
    expect(await sendReviewLinkEmail(env, fetchImpl, { name: 'A', email: 'a@example.fi' }, LINK)).toBe(true)
    expect(await sendReviewLinkEmail(env, fetchImpl, { name: 'B', email: 'b@example.fi' }, LINK)).toBe(true)
    expect(calls).toHaveLength(2)
  })

  it('[review-links 1] a refusal or no connection is false, never a throw', async () => {
    expect(
      await sendReviewLinkEmail(
        { BREVO_API_KEY: 'x' },
        recorder(400).fetchImpl,
        { name: 'A', email: 'a@example.fi' },
        LINK,
      ),
    ).toBe(false)
    const broken = () => Promise.reject(new Error('offline'))
    expect(
      await sendReviewLinkEmail({ BREVO_API_KEY: 'x' }, broken, { name: 'A', email: 'a@example.fi' }, LINK),
    ).toBe(false)
  })
})
