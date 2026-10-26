// 16 kHz mono 16 bit WAV: the one audio format sent for speaking feedback
// (factory/jobs/10-speaking-feedback/spec.md, "Done when" 9 and 14). The
// browser turns its recording into it (mixToMono, resample, encodeWav); the
// Worker checks every upload with readWav before anything else sees it.
// Pure functions, no browser or Worker API.

export const SPEECH_SAMPLE_RATE = 16_000
/** 16 kHz, 2 bytes a sample: bytes of audio per millisecond. */
export const BYTES_PER_MS = (SPEECH_SAMPLE_RATE * 2) / 1000

export interface WavInfo {
  /** 1 means PCM. */
  format: number
  channels: number
  sampleRate: number
  bitsPerSample: number
  /** Where the samples start, and how many bytes of them there are. */
  dataOffset: number
  dataBytes: number
  durationMs: number
}

function text(bytes: Uint8Array, at: number): string {
  return String.fromCharCode(bytes[at] ?? 0, bytes[at + 1] ?? 0, bytes[at + 2] ?? 0, bytes[at + 3] ?? 0)
}

/** Reads a RIFF WAVE file's format and data chunks, or null when it is not one. */
export function readWav(bytes: Uint8Array): WavInfo | null {
  if (bytes.length < 44 || text(bytes, 0) !== 'RIFF' || text(bytes, 8) !== 'WAVE') return null
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength)
  let format: Omit<WavInfo, 'dataOffset' | 'dataBytes' | 'durationMs'> | null = null
  let at = 12
  while (at + 8 <= bytes.length) {
    const id = text(bytes, at)
    const size = view.getUint32(at + 4, true)
    const body = at + 8
    if (id === 'fmt ' && size >= 16 && body + 16 <= bytes.length) {
      format = {
        format: view.getUint16(body, true),
        channels: view.getUint16(body + 2, true),
        sampleRate: view.getUint32(body + 4, true),
        bitsPerSample: view.getUint16(body + 14, true),
      }
    }
    if (id === 'data') {
      if (!format) return null
      const dataBytes = Math.min(size, bytes.length - body)
      const bytesPerSecond = format.sampleRate * format.channels * (format.bitsPerSample / 8)
      return {
        ...format,
        dataOffset: body,
        dataBytes,
        durationMs: bytesPerSecond > 0 ? Math.round((dataBytes / bytesPerSecond) * 1000) : 0,
      }
    }
    at = body + size + (size % 2)
  }
  return null
}

/** True for PCM, 16 kHz, mono, 16 bit, with some audio and at most `maxMs` of it. */
export function isSpeechWav(info: WavInfo | null, maxMs: number): info is WavInfo {
  return (
    info !== null &&
    info.format === 1 &&
    info.sampleRate === SPEECH_SAMPLE_RATE &&
    info.channels === 1 &&
    info.bitsPerSample === 16 &&
    info.dataBytes > 0 &&
    info.dataBytes % 2 === 0 &&
    info.durationMs <= maxMs
  )
}

/** The average of every channel, sample by sample. */
export function mixToMono(channels: readonly Float32Array[]): Float32Array {
  const first = channels.at(0)
  if (!first) return new Float32Array(0)
  if (channels.length === 1) return first
  const mono = new Float32Array(first.length)
  for (const channel of channels) {
    for (let i = 0; i < mono.length; i += 1) mono[i] = (mono[i] ?? 0) + (channel[i] ?? 0) / channels.length
  }
  return mono
}

/**
 * Changes the sample rate. Going down, each new sample is the average of the
 * old samples it covers (a simple filter against aliasing); going up, it is
 * a straight line between the two nearest old samples.
 */
export function resample(samples: Float32Array, from: number, to: number): Float32Array {
  if (from === to) return samples
  const length = Math.floor((samples.length * to) / from)
  const out = new Float32Array(length)
  const ratio = from / to
  for (let i = 0; i < length; i += 1) {
    if (ratio > 1) {
      const start = Math.floor(i * ratio)
      const end = Math.max(start + 1, Math.floor((i + 1) * ratio))
      let sum = 0
      for (let j = start; j < end && j < samples.length; j += 1) sum += samples[j] ?? 0
      out[i] = sum / (Math.min(end, samples.length) - start)
    } else {
      const at = i * ratio
      const left = Math.floor(at)
      const right = Math.min(left + 1, samples.length - 1)
      const share = at - left
      out[i] = (samples[left] ?? 0) * (1 - share) + (samples[right] ?? 0) * share
    }
  }
  return out
}

/** A 16 bit mono PCM WAV of the samples (each from -1 to 1, clipped). */
export function encodeWav(samples: Float32Array, sampleRate = SPEECH_SAMPLE_RATE): Uint8Array {
  const bytes = new Uint8Array(44 + samples.length * 2)
  const view = new DataView(bytes.buffer)
  const write = (at: number, value: string) => {
    for (let i = 0; i < value.length; i += 1) bytes[at + i] = value.charCodeAt(i)
  }
  write(0, 'RIFF')
  view.setUint32(4, 36 + samples.length * 2, true)
  write(8, 'WAVE')
  write(12, 'fmt ')
  view.setUint32(16, 16, true)
  view.setUint16(20, 1, true)
  view.setUint16(22, 1, true)
  view.setUint32(24, sampleRate, true)
  view.setUint32(28, sampleRate * 2, true)
  view.setUint16(32, 2, true)
  view.setUint16(34, 16, true)
  write(36, 'data')
  view.setUint32(40, samples.length * 2, true)
  for (let i = 0; i < samples.length; i += 1) {
    const clipped = Math.max(-1, Math.min(1, samples[i] ?? 0))
    view.setInt16(44 + i * 2, Math.round(clipped < 0 ? clipped * 0x8000 : clipped * 0x7fff), true)
  }
  return bytes
}

/** Base64 of the bytes, in pieces so a long recording does not overflow the call stack. */
export function toBase64(bytes: Uint8Array): string {
  let binary = ''
  for (let i = 0; i < bytes.length; i += 0x8000) {
    binary += String.fromCharCode(...bytes.subarray(i, i + 0x8000))
  }
  return btoa(binary)
}

/** The bytes of a base64 string, or null when it is not valid base64. */
export function fromBase64(value: string): Uint8Array | null {
  if (!/^[A-Za-z0-9+/]*={0,2}$/.test(value) || value.length % 4 !== 0) return null
  try {
    const binary = atob(value)
    const bytes = new Uint8Array(binary.length)
    for (let i = 0; i < binary.length; i += 1) bytes[i] = binary.charCodeAt(i)
    return bytes
  } catch {
    return null
  }
}
