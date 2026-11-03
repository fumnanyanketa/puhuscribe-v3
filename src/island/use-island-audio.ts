import { useCallback, useEffect, useRef, useState } from 'react'
import { finished, startExclusive } from '../components/play-registry.ts'
import { pickRecordingType, recordingSupported, RecorderFailed } from '../lib/recorder.ts'

// Sound for the island card (language islands): "Play all" plays the island's clips one after the
// other, and "Say it all" records the learner saying the whole island and plays it back. The
// recording stays in this page's memory and is let go when the card closes: nothing is sent anywhere,
// as with Say it. Say it's own recorder stops at 10 seconds, which is too short for a whole island,
// so this one stops by itself at MAX_ISLAND_RECORDING_MS.

export const MAX_ISLAND_RECORDING_MS = 120_000

/** Plays a list of clips in order. A clip that cannot play is skipped. */
export function usePlaylist() {
  const audio = useRef<HTMLAudioElement | null>(null)
  const [playing, setPlaying] = useState(false)

  const stop = useCallback(() => {
    if (audio.current) {
      audio.current.onended = null
      audio.current.onerror = null
      audio.current.pause()
    }
    audio.current = null
    setPlaying(false)
  }, [])

  const play = useCallback(
    (sources: readonly string[]) => {
      stop()
      if (sources.length === 0) return
      startExclusive(stop)
      setPlaying(true)
      const element = new Audio()
      audio.current = element
      let index = 0
      const next = () => {
        if (audio.current !== element) return
        if (index >= sources.length) {
          finished(stop)
          stop()
          return
        }
        element.src = sources[index] ?? ''
        index += 1
        void element.play().catch(() => {
          if (audio.current === element && element.error) next()
        })
      }
      element.onended = next
      element.onerror = next
      next()
    },
    [stop],
  )

  useEffect(
    () => () => {
      finished(stop)
      stop()
    },
    [stop],
  )
  return { playing, play, stop }
}

export type LongRecordState = 'ready' | 'recording' | 'unavailable'

/** Records the learner for up to two minutes and plays it back from memory. */
export function useLongRecording() {
  const [state, setState] = useState<LongRecordState>(() => (recordingSupported() ? 'ready' : 'unavailable'))
  const [problem, setProblem] = useState<RecorderFailed['problem'] | null>(null)
  const [hasRecording, setHasRecording] = useState(false)
  const recorder = useRef<MediaRecorder | null>(null)
  const stream = useRef<MediaStream | null>(null)
  const url = useRef<string | null>(null)
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null)
  const playback = useRef<HTMLAudioElement | null>(null)

  const releaseStream = useCallback(() => {
    for (const track of stream.current?.getTracks() ?? []) track.stop()
    stream.current = null
    if (timer.current) clearTimeout(timer.current)
    timer.current = null
  }, [])

  const releaseRecording = useCallback(() => {
    playback.current?.pause()
    playback.current = null
    if (url.current) URL.revokeObjectURL(url.current)
    url.current = null
    setHasRecording(false)
  }, [])

  const stop = useCallback(() => {
    const current = recorder.current
    recorder.current = null
    if (current && current.state !== 'inactive') current.stop()
    releaseStream()
  }, [releaseStream])

  const start = useCallback(async () => {
    if (state !== 'ready') return
    releaseRecording()
    setProblem(null)
    let media: MediaStream
    try {
      media = await navigator.mediaDevices.getUserMedia({ audio: true })
    } catch (error) {
      const name = error instanceof DOMException ? error.name : ''
      setProblem(name === 'NotAllowedError' || name === 'SecurityError' ? 'denied' : 'unsupported')
      return
    }
    const type = pickRecordingType((t) => MediaRecorder.isTypeSupported(t))
    let made: MediaRecorder
    try {
      made = type ? new MediaRecorder(media, { mimeType: type }) : new MediaRecorder(media)
    } catch {
      for (const track of media.getTracks()) track.stop()
      setProblem('unsupported')
      return
    }
    const parts: Blob[] = []
    made.ondataavailable = (event) => {
      if (event.data.size > 0) parts.push(event.data)
    }
    made.onstop = () => {
      const blob = new Blob(parts, { type: made.mimeType !== '' ? made.mimeType : (type ?? 'audio/webm') })
      parts.length = 0
      if (blob.size > 0) {
        url.current = URL.createObjectURL(blob)
        setHasRecording(true)
      }
      setState('ready')
    }
    stream.current = media
    recorder.current = made
    made.start(250)
    setState('recording')
    timer.current = setTimeout(stop, MAX_ISLAND_RECORDING_MS)
  }, [state, releaseRecording, stop])

  const playMine = useCallback(() => {
    if (!url.current) return
    playback.current?.pause()
    playback.current = new Audio(url.current)
    void playback.current.play().catch(() => undefined)
  }, [])

  // The app going to the background stops a recording, as Say it does.
  useEffect(() => {
    const onHidden = () => {
      if (document.visibilityState === 'hidden') stop()
    }
    document.addEventListener('visibilitychange', onHidden)
    return () => {
      document.removeEventListener('visibilitychange', onHidden)
    }
  }, [stop])

  useEffect(
    () => () => {
      stop()
      releaseRecording()
    },
    [stop, releaseRecording],
  )

  return { state, problem, hasRecording, start, stop, playMine }
}
