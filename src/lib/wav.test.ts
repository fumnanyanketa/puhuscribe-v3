import { describe, expect, it } from 'vitest'
import {
  SPEECH_SAMPLE_RATE,
  encodeWav,
  fromBase64,
  isSpeechWav,
  mixToMono,
  readWav,
  resample,
  toBase64,
} from './wav.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.

function tone(seconds: number, rate: number, hertz = 440): Float32Array {
  const samples = new Float32Array(Math.round(seconds * rate))
  for (let i = 0; i < samples.length; i += 1) samples[i] = 0.5 * Math.sin((2 * Math.PI * hertz * i) / rate)
  return samples
}

describe('the WAV writer', () => {
  it('[speak 9] writes a 44 byte RIFF header for 16 kHz mono 16 bit PCM, then the samples', () => {
    const wav = encodeWav(new Float32Array([0, 0.5, -0.5, 1, -1, 2, -2]))
    expect(wav.length).toBe(44 + 7 * 2)
    const view = new DataView(wav.buffer)
    expect(String.fromCharCode(...wav.subarray(0, 4))).toBe('RIFF')
    expect(view.getUint32(4, true)).toBe(36 + 14)
    expect(String.fromCharCode(...wav.subarray(8, 16))).toBe('WAVEfmt ')
    expect(view.getUint32(16, true)).toBe(16)
    expect(view.getUint16(20, true)).toBe(1)
    expect(view.getUint16(22, true)).toBe(1)
    expect(view.getUint32(24, true)).toBe(16_000)
    expect(view.getUint32(28, true)).toBe(32_000)
    expect(view.getUint16(32, true)).toBe(2)
    expect(view.getUint16(34, true)).toBe(16)
    expect(String.fromCharCode(...wav.subarray(36, 40))).toBe('data')
    expect(view.getUint32(40, true)).toBe(14)
    // Samples, clipped to -1 and 1.
    expect([0, 1, 2, 3, 4, 5, 6].map((i) => view.getInt16(44 + i * 2, true))).toEqual([
      0, 16384, -16384, 32767, -32768, 32767, -32768,
    ])
  })

  it('[speak 9] [speak 14] what it writes is exactly what the Worker accepts', () => {
    const wav = encodeWav(tone(1.25, SPEECH_SAMPLE_RATE))
    const info = readWav(wav)
    expect(info).toEqual({
      format: 1,
      channels: 1,
      sampleRate: 16_000,
      bitsPerSample: 16,
      dataOffset: 44,
      dataBytes: 40_000,
      durationMs: 1250,
    })
    expect(isSpeechWav(info, 10_000)).toBe(true)
  })

  it('[speak 9] base64 goes there and back unchanged, also for a full 10 seconds', () => {
    const wav = encodeWav(tone(10, SPEECH_SAMPLE_RATE))
    expect(wav.length).toBe(320_044)
    const text = toBase64(wav)
    expect(fromBase64(text)).toEqual(wav)
    expect(fromBase64('not base64!')).toBeNull()
    expect(fromBase64('abc')).toBeNull()
  })
})

describe('the resampler', () => {
  it('[speak 9] turns 48 kHz into 16 kHz with a third of the samples, keeping the tone', () => {
    const input = tone(0.5, 48_000)
    const output = resample(input, 48_000, 16_000)
    expect(output.length).toBe(8000)
    // The same 440 Hz tone, sampled at 16 kHz, within the small loss of the averaging filter.
    const expected = tone(0.5, 16_000)
    let worst = 0
    for (let i = 10; i < output.length - 10; i += 1) {
      worst = Math.max(worst, Math.abs((output[i] ?? 0) - (expected[i + 0] ?? 0) * 0.99))
    }
    expect(worst).toBeLessThan(0.05)
  })

  it('[speak 9] turns 44.1 kHz into 16 kHz, and 8 kHz up into 16 kHz', () => {
    expect(resample(tone(1, 44_100), 44_100, 16_000).length).toBe(16_000)
    const up = resample(new Float32Array([0, 1, 0, -1]), 8000, 16_000)
    expect(Array.from(up)).toEqual([0, 0.5, 1, 0.5, 0, -0.5, -1, -1])
  })

  it('[speak 9] leaves 16 kHz alone and mixes stereo to mono by averaging', () => {
    const same = tone(0.1, 16_000)
    expect(resample(same, 16_000, 16_000)).toBe(same)
    expect(Array.from(mixToMono([new Float32Array([1, 0, 0.5]), new Float32Array([0, 0, 0.5])]))).toEqual([
      0.5, 0, 0.5,
    ])
    expect(mixToMono([])).toEqual(new Float32Array(0))
  })
})

describe('the upload check', () => {
  function header(change: (view: DataView) => unknown, seconds = 1): Uint8Array {
    const wav = encodeWav(tone(seconds, SPEECH_SAMPLE_RATE))
    change(new DataView(wav.buffer))
    return wav
  }

  it('[speak 14] refuses anything that is not a RIFF WAVE file', () => {
    expect(readWav(new Uint8Array(10))).toBeNull()
    expect(
      readWav(
        header((view) => {
          view.setUint8(0, 0x58)
        }),
      ),
    ).toBeNull()
    expect(
      readWav(
        header((view) => {
          view.setUint8(8, 0x58)
        }),
      ),
    ).toBeNull()
    expect(readWav(new TextEncoder().encode('OggS'.padEnd(100, '\u0000')))).toBeNull()
  })

  it('[speak 14] refuses a format other than PCM, 16 kHz, mono, 16 bit, and anything over 10 seconds or empty', () => {
    expect(
      isSpeechWav(
        readWav(
          header((view) => {
            view.setUint16(20, 3, true)
          }),
        ),
        10_000,
      ),
    ).toBe(false)
    expect(
      isSpeechWav(
        readWav(
          header((view) => {
            view.setUint32(24, 44_100, true)
          }),
        ),
        10_000,
      ),
    ).toBe(false)
    expect(
      isSpeechWav(
        readWav(
          header((view) => {
            view.setUint16(22, 2, true)
          }),
        ),
        10_000,
      ),
    ).toBe(false)
    expect(
      isSpeechWav(
        readWav(
          header((view) => {
            view.setUint16(34, 8, true)
          }),
        ),
        10_000,
      ),
    ).toBe(false)
    expect(isSpeechWav(readWav(encodeWav(tone(10.01, SPEECH_SAMPLE_RATE))), 10_000)).toBe(false)
    expect(isSpeechWav(readWav(encodeWav(tone(10, SPEECH_SAMPLE_RATE))), 10_000)).toBe(true)
    expect(isSpeechWav(readWav(encodeWav(new Float32Array(0))), 10_000)).toBe(false)
  })
})
