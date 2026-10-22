// A short generated tone for the reference page's play controls, never speech
// (factory/jobs/5-design-system/spec.md, "Done when" 12). A 16 bit mono WAV,
// which Chromium and WebKit both play, made in the browser as a blob URL.

export function toneUrl(seconds = 0.6, hertz = 440): string {
  const rate = 8000
  const samples = Math.round(rate * seconds)
  const buffer = new ArrayBuffer(44 + samples * 2)
  const view = new DataView(buffer)
  const text = (at: number, value: string) => {
    for (let i = 0; i < value.length; i += 1) view.setUint8(at + i, value.charCodeAt(i))
  }
  text(0, 'RIFF')
  view.setUint32(4, 36 + samples * 2, true)
  text(8, 'WAVE')
  text(12, 'fmt ')
  view.setUint32(16, 16, true)
  view.setUint16(20, 1, true) // PCM
  view.setUint16(22, 1, true) // mono
  view.setUint32(24, rate, true)
  view.setUint32(28, rate * 2, true)
  view.setUint16(32, 2, true)
  view.setUint16(34, 16, true)
  text(36, 'data')
  view.setUint32(40, samples * 2, true)
  for (let i = 0; i < samples; i += 1) {
    // A soft start and end, so the tone does not click.
    const fade = Math.min(1, i / 400, (samples - i) / 400)
    view.setInt16(44 + i * 2, Math.round(Math.sin((2 * Math.PI * hertz * i) / rate) * 8000 * fade), true)
  }
  return URL.createObjectURL(new Blob([buffer], { type: 'audio/wav' }))
}
