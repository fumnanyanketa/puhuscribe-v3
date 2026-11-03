import { expect, test } from './test-base.ts'
import { startGuest } from './account-helpers.ts'
import { useRealRoad } from './road-route.ts'
import { serveTone } from './session-helpers.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md. The road screen against the real
// GET /api/road of job 20-a1-road, with the Worker and the database behind it
// (round 4: the road ran only on the fixture before). It reads no fixture.

interface Stop {
  stop_number: number
  title_en: string
  can_do_en: string
  lessons_total: number
  lessons_done: number
}

test.describe('the road on the real route', { tag: '@seed' }, () => {
  test.skip(
    !useRealRoad,
    'Runs where a real Worker answers GET /api/road (GitHub, or PUHUSCRIBE_REAL_ROAD=1).',
  )

  test.beforeEach(async ({ page }) => {
    await serveTone(page)
  })

  test('[redesign 19] a visitor gets all the stops with no progress, and sets no cookie', async ({
    request,
  }) => {
    const answer = await request.get('/api/road')
    expect(answer.status()).toBe(200)
    expect(answer.headers()['set-cookie']).toBeUndefined()
    const { stops } = (await answer.json()) as { stops: Stop[] }
    expect(stops.length).toBeGreaterThanOrEqual(30)
    expect(stops.map((stop) => stop.stop_number)).toEqual(stops.map((_, index) => index + 1))
    for (const stop of stops) {
      expect(stop.lessons_done).toBe(0)
      expect(stop.lessons_total).toBeGreaterThan(0)
      expect(stop.title_en.length).toBeGreaterThan(0)
    }
  })

  test('[redesign 19] [redesign 10] the day one road of a visitor shows the real first stop, five signs and Start', async ({
    page,
  }) => {
    const first = ((await (await page.request.get('/api/road')).json()) as { stops: Stop[] }).stops[0]
    await page.goto('/learn')
    await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Skip' })).toHaveCount(0, { timeout: 8000 })
    await expect(page.getByRole('list', { name: 'Stops on your road' }).getByRole('listitem')).toHaveCount(5)
    await expect(page.getByRole('region', { name: 'Today' }).getByRole('heading', { level: 2 })).toHaveText(
      first?.title_en ?? '',
    )
    await expect(page.getByRole('button', { name: 'Start', exact: true })).toBeVisible()
    await expect(page.getByText(`Stop 1 · ${String(first?.lessons_total ?? '')} short lessons`)).toBeVisible()
  })

  test('[redesign 19] [redesign 14] a guest with an account reads the same stops from the learner route and sees stop 1 as the current sign', async ({
    page,
  }) => {
    await startGuest(page)
    const stops = ((await (await page.request.get('/api/road')).json()) as { stops: Stop[] }).stops
    await page.goto('/learn')
    await expect(page.getByRole('list', { name: 'Stops on your road' })).toBeVisible()
    const first = stops[0]
    const signs = page.getByRole('list', { name: 'Stops on your road' }).getByRole('listitem')
    await expect(signs.first()).toContainText(`Stop 1, ${first?.title_en ?? ''}, current`)
    await expect(page.getByRole('region', { name: 'Today' }).getByRole('heading', { level: 2 })).toHaveText(
      first?.title_en ?? '',
    )
  })
})
