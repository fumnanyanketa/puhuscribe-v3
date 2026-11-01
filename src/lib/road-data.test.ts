import { afterEach, describe, expect, it, vi } from 'vitest'
import { ROAD_MID, roadFixture } from '../road/road-fixture.ts'
import { loadRoad, parseRoad } from './road-data.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md.

afterEach(() => {
  vi.unstubAllGlobals()
})

function answer(status: number, body: unknown) {
  return vi.fn(() => Promise.resolve(new Response(JSON.stringify(body), { status })))
}

describe('reading the road', () => {
  it('[redesign 19] reads stops in the interface shape, as a list or as { stops }', () => {
    expect(parseRoad({ stops: ROAD_MID })?.stops).toHaveLength(36)
    expect(parseRoad(ROAD_MID)?.stops).toHaveLength(36)
    expect(parseRoad({ stops: ROAD_MID })?.stops[2]).toMatchObject({
      number: 3,
      name: 'At the grocery store',
      lessons: 4,
      lessonsDone: 2,
    })
  })

  it("[redesign 19] reads the column names of job 20's road() function", () => {
    const rows = [
      {
        stop_number: 1,
        title_en: 'Meeting people',
        can_do_en: 'I can say who I am.',
        part_number: 1,
        lessons_total: 4,
        lessons_done: 1,
        stop_slug: 'meeting-people',
        live: true,
      },
      {
        stop_number: 2,
        title_en: 'At the café',
        can_do_en: 'I can order something.',
        part_number: 1,
        lessons_total: 4,
        lessons_done: 0,
      },
    ]
    expect(parseRoad(rows)?.stops).toEqual([
      {
        number: 1,
        name: 'Meeting people',
        canDo: 'I can say who I am.',
        part: 1,
        lessons: 4,
        lessonsDone: 1,
      },
      {
        number: 2,
        name: 'At the café',
        canDo: 'I can order something.',
        part: 1,
        lessons: 4,
        lessonsDone: 0,
      },
    ])
  })

  it('[redesign 19] refuses anything that is not a clean list of stops in order', () => {
    const [first, second] = roadFixture()
    expect(parseRoad(null)).toBeNull()
    expect(parseRoad({})).toBeNull()
    expect(parseRoad({ stops: [] })).toBeNull()
    expect(parseRoad([first, first])).toBeNull()
    expect(parseRoad([second, first])).toBeNull()
    expect(parseRoad([{ ...first, name: '' }])).toBeNull()
    expect(parseRoad([{ ...first, name: 'x'.repeat(81) }])).toBeNull()
    expect(parseRoad([{ ...first, name: 42 }])).toBeNull()
    expect(parseRoad([{ ...first, lessons: 0 }])).toBeNull()
    expect(parseRoad([{ ...first, lessonsDone: 5 }])).toBeNull()
    expect(parseRoad([{ ...first, lessonsDone: 1.5 }])).toBeNull()
    expect(parseRoad([{ ...first, number: '1' }])).toBeNull()
  })

  it('[redesign 13] [security] keeps a stop name as the text it is: markup is not interpreted here', () => {
    const [first] = roadFixture()
    const name = '<img src=x onerror=alert(1)>'
    expect(parseRoad([{ ...first, name }])?.stops[0]?.name).toBe(name)
  })

  it('[redesign 17] keeps a sample line only when every word is clean text, and drops it otherwise', () => {
    const [first] = roadFixture()
    expect(parseRoad([first])?.stops[0]?.sampleLine?.words).toHaveLength(3)
    const bad = { ...first, sampleLine: { words: [{ text: 5 }] } }
    // A bad sample line is dropped; the road itself still reads.
    expect(parseRoad([bad])?.stops[0]?.sampleLine).toBeUndefined()
    expect(parseRoad([bad])?.stops[0]?.name).toBe('Meeting people')
    const none = { ...first, sampleLine: 'nonsense' }
    expect(parseRoad([none])?.stops[0]?.sampleLine).toBeUndefined()
  })

  it('[redesign 19] loadRoad asks GET /api/road and returns null when it cannot read the road', async () => {
    const ok = answer(200, { stops: ROAD_MID })
    vi.stubGlobal('fetch', ok)
    expect((await loadRoad())?.stops).toHaveLength(36)
    expect(ok).toHaveBeenCalledWith('/api/road', expect.objectContaining({ method: 'GET' }))
    for (const status of [401, 404, 503]) {
      vi.stubGlobal('fetch', answer(status, { error: 'no' }))
      expect(await loadRoad(), String(status)).toBeNull()
    }
    vi.stubGlobal(
      'fetch',
      vi.fn(() => Promise.reject(new Error('offline'))),
    )
    expect(await loadRoad()).toBeNull()
  })
})
