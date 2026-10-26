import { MAX_RECORDING_MS } from './speech-types.ts'
import { SPEECH_SAMPLE_RATE, encodeWav, mixToMono, resample } from './wav.ts'

// The microphone recorder for Say it (factory/jobs/10-speaking-feedback/spec.md,
// "Done when" 8 and 9). It records with MediaRecorder in the first format the
// browser offers from a fixed list, decodes the result in the browser, and
// turns it into 16 kHz mono 16 bit WAV, the format Azure's short audio API
// takes. The microphone is released after every recording (every track is
// stopped). The recording stays in this page's memory only: it is never
// written to localStorage, sessionStorage, IndexedDB or the cache.
//
// The microphone is asked for only when startRecording is called, which the
// Say it screen does only after voice consent and a press of the record button.

/** The formats tried, in order (statement 9). */
export const RECORDING_TYPES = [
  'audio/webm;codecs=opus',
  'audio/mp4',
  'audio/webm',
  'audio/ogg;codecs=opus',
] as const

/** The first format the browser can record, or null. */
export function pickRecordingType(isTypeSupported: (type: string) => boolean): string | null {
  for (const type of RECORDING_TYPES) {
    try {
      if (isTypeSupported(type)) return type
    } catch {
      // Some browsers throw for a type they do not know.
    }
  }
  return null
}

export type RecorderProblem = 'unsupported' | 'denied' | 'background' | 'failed'

export class RecorderFailed extends Error {
  readonly problem: RecorderProblem
  constructor(problem: RecorderProblem) {
    super(`Recording did not work (${problem}).`)
    this.name = 'RecorderFailed'
    this.problem = problem
  }
}

export interface Recording {
  /** 16 kHz mono 16 bit WAV. */
  wav: Uint8Array
  durationMs: number
}

export interface RecorderHandle {
  /** Stops and returns the recording as WAV. */
  stop: () => Promise<Recording>
  /** Stops and throws the recording away. */
  cancel: () => void
}

type AudioContextClass = new () => AudioContext

function audioContextClass(): AudioContextClass | null {
  const scope = window as unknown as {
    AudioContext?: AudioContextClass
    webkitAudioContext?: AudioContextClass
  }
  return scope.AudioContext ?? scope.webkitAudioContext ?? null
}

/** True when this browser can record and decode on this page (a secure page with a microphone API). */
export function recordingSupported(): boolean {
  return (
    window.isSecureContext &&
    // mediaDevices can be missing (an insecure page, an older browser).
    typeof (navigator.mediaDevices as MediaDevices | undefined)?.getUserMedia === 'function' &&
    typeof window.MediaRecorder === 'function' &&
    audioContextClass() !== null
  )
}

/** Decodes any recorded format the browser can play into 16 kHz mono 16 bit WAV. */
export async function toSpeechWav(blob: Blob): Promise<Recording> {
  const Context = audioContextClass()
  if (!Context) throw new RecorderFailed('unsupported')
  const context = new Context()
  try {
    const data = await blob.arrayBuffer()
    // Older Safari only has the callback form of decodeAudioData.
    const decoded = await new Promise<AudioBuffer>((resolve, reject) => {
      const result = context.decodeAudioData(data, resolve, reject) as Promise<AudioBuffer> | undefined
      if (result && typeof result.then === 'function') result.then(resolve, reject)
    })
    const channels: Float32Array[] = []
    for (let i = 0; i < decoded.numberOfChannels; i += 1) channels.push(decoded.getChannelData(i))
    const samples = resample(mixToMono(channels), decoded.sampleRate, SPEECH_SAMPLE_RATE)
    return { wav: encodeWav(samples), durationMs: Math.round((samples.length / SPEECH_SAMPLE_RATE) * 1000) }
  } catch (error) {
    throw error instanceof RecorderFailed ? error : new RecorderFailed('failed')
  } finally {
    void context.close().catch(() => undefined)
  }
}

function release(stream: MediaStream) {
  for (const track of stream.getTracks()) track.stop()
}

/**
 * Asks for the microphone and starts recording. `onTick` gets the whole
 * seconds recorded so far; recording stops by itself after 10 seconds and
 * calls `onAutoStop` with the result. When the page goes to the background,
 * the recording is thrown away and `onInterrupted` is called.
 */
export async function startRecording(handlers: {
  onTick: (seconds: number) => void
  onAutoStop: (result: Promise<Recording>) => void
  onInterrupted: () => void
}): Promise<RecorderHandle> {
  if (!recordingSupported()) throw new RecorderFailed('unsupported')
  const type = pickRecordingType((t) => MediaRecorder.isTypeSupported(t))
  let stream: MediaStream
  try {
    stream = await navigator.mediaDevices.getUserMedia({ audio: true })
  } catch (error) {
    const name = error instanceof DOMException ? error.name : ''
    throw new RecorderFailed(
      name === 'NotAllowedError' || name === 'SecurityError' ? 'denied' : 'unsupported',
    )
  }
  let recorder: MediaRecorder
  try {
    recorder = type ? new MediaRecorder(stream, { mimeType: type }) : new MediaRecorder(stream)
  } catch {
    release(stream)
    throw new RecorderFailed('unsupported')
  }
  const parts: Blob[] = []
  const started = Date.now()
  let finished = false
  let resolveStop: (blob: Blob) => void = () => undefined
  let rejectStop: (error: Error) => void = () => undefined
  const stopped = new Promise<Blob>((resolve, reject) => {
    resolveStop = resolve
    rejectStop = reject
  })
  recorder.ondataavailable = (event) => {
    if (event.data.size > 0) parts.push(event.data)
  }
  recorder.onstop = () => {
    const recorded = recorder.mimeType !== '' ? recorder.mimeType : type
    resolveStop(new Blob(parts, { type: recorded ?? 'audio/webm' }))
  }
  recorder.onerror = () => {
    rejectStop(new RecorderFailed('failed'))
  }

  const ticker = setInterval(() => {
    handlers.onTick(Math.floor((Date.now() - started) / 1000))
  }, 250)
  const limit = setTimeout(() => {
    if (!finished) handlers.onAutoStop(handle.stop())
  }, MAX_RECORDING_MS)
  const onHidden = () => {
    if (document.visibilityState === 'hidden' && !finished) {
      handle.cancel()
      handlers.onInterrupted()
    }
  }
  document.addEventListener('visibilitychange', onHidden)

  function end() {
    finished = true
    clearInterval(ticker)
    clearTimeout(limit)
    document.removeEventListener('visibilitychange', onHidden)
    if (recorder.state !== 'inactive') recorder.stop()
    release(stream)
  }

  const handle: RecorderHandle = {
    async stop() {
      if (finished) throw new RecorderFailed('failed')
      end()
      const blob = await stopped
      parts.length = 0
      return toSpeechWav(blob)
    },
    cancel() {
      if (finished) return
      end()
      parts.length = 0
      void stopped.catch(() => undefined)
    },
  }
  recorder.start(250)
  return handle
}
