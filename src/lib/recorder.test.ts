import { describe, expect, it } from 'vitest'
import { RECORDING_TYPES, capToLimit, pickRecordingType } from './recorder.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.

describe('the recording format', () => {
  it('[speak 9] tries the formats in the fixed order', () => {
    expect(RECORDING_TYPES).toEqual([
      'audio/webm;codecs=opus',
      'audio/mp4',
      'audio/webm',
      'audio/ogg;codecs=opus',
    ])
  })

  it('[speak 9] picks the first format the browser accepts', () => {
    expect(pickRecordingType(() => true)).toBe('audio/webm;codecs=opus')
    // Older Safari: mp4 only.
    expect(pickRecordingType((type) => type === 'audio/mp4')).toBe('audio/mp4')
    expect(pickRecordingType((type) => type.startsWith('audio/ogg'))).toBe('audio/ogg;codecs=opus')
    expect(pickRecordingType(() => false)).toBeNull()
  })

  it('[speak 9] a browser that throws for a format it does not know moves on to the next', () => {
    expect(
      pickRecordingType((type) => {
        if (type.includes('webm')) throw new Error('unknown')
        return true
      }),
    ).toBe('audio/mp4')
  })
})

describe('the 10 second limit', () => {
  it('[speak 9] a recording that ran a little past 10 seconds is cut to exactly 10 seconds', () => {
    expect(capToLimit(new Float32Array(16_000 * 10 + 800)).length).toBe(160_000)
  })
  it('[speak 9] a recording within the limit is left as it is', () => {
    const samples = new Float32Array(16_000 * 3)
    expect(capToLimit(samples)).toBe(samples)
  })
})
