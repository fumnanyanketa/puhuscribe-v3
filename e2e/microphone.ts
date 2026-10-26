import type { Page } from '@playwright/test'

// Replaces the microphone for the speaking feedback browser tests
// (factory/jobs/10-speaking-feedback/spec.md, "Done when" 9). Never a real
// microphone and never speech: getUserMedia answers with a generated 440 Hz
// tone from the Web Audio API, so the real MediaRecorder and decode path run
// on it. The stub counts its calls and keeps each stream it handed out, so a
// test can prove no request came before consent and every track was stopped.
//
//   tone: a working microphone playing the tone
//   denied: the learner refused access (NotAllowedError)
//   none: a browser without MediaRecorder
//
// Playwright's Linux WebKit build lacks MediaRecorder or
// navigator.mediaDevices (GitHub run 40356177557: every WebKit test showed
// "Recording is not available in this browser."). Where the browser lacks
// them, and only then, the stub adds stand-ins: a mediaDevices object for the
// getUserMedia stub, and a recorder that turns the time it ran into a WAV of
// the same tone. The app's own support check, decode and WAV path still run.

export type Microphone = 'tone' | 'denied' | 'none'

export async function stubMicrophone(page: Page, kind: Microphone): Promise<void> {
  // A string, as the browser test project has no DOM types.
  await page.addInitScript(`(() => {
    const mode = ${JSON.stringify(kind)};
    window.__micCalls = 0;
    window.__micStreams = [];
    if (mode === 'none') { window.MediaRecorder = undefined; return; }
    if (!navigator.mediaDevices) {
      Object.defineProperty(navigator, 'mediaDevices', { value: {}, configurable: true });
    }
    const devices = navigator.mediaDevices;
    if (typeof window.MediaRecorder !== 'function') {
      const toneWav = (ms) => {
        const rate = 16000;
        const n = Math.round((rate * ms) / 1000);
        const view = new DataView(new ArrayBuffer(44 + n * 2));
        const text = (o, t) => { for (let i = 0; i < t.length; i += 1) view.setUint8(o + i, t.charCodeAt(i)); };
        text(0, 'RIFF'); view.setUint32(4, 36 + n * 2, true); text(8, 'WAVE'); text(12, 'fmt ');
        view.setUint32(16, 16, true); view.setUint16(20, 1, true); view.setUint16(22, 1, true);
        view.setUint32(24, rate, true); view.setUint32(28, rate * 2, true);
        view.setUint16(32, 2, true); view.setUint16(34, 16, true); text(36, 'data'); view.setUint32(40, n * 2, true);
        for (let i = 0; i < n; i += 1) view.setInt16(44 + i * 2, Math.round(Math.sin((2 * Math.PI * 440 * i) / rate) * 8000), true);
        return new Blob([view.buffer], { type: 'audio/wav' });
      };
      window.MediaRecorder = class {
        static isTypeSupported() { return false; }
        constructor(stream) { this.stream = stream; this.state = 'inactive'; this.mimeType = 'audio/wav'; }
        start() { this.state = 'recording'; this.began = Date.now(); }
        stop() {
          if (this.state === 'inactive') return;
          this.state = 'inactive';
          const data = toneWav(Date.now() - this.began);
          setTimeout(() => {
            if (this.ondataavailable) this.ondataavailable({ data });
            if (this.onstop) this.onstop();
          }, 0);
        }
      };
    }
    devices.getUserMedia = (constraints) => {
      window.__micCalls += 1;
      if (mode === 'denied' || !constraints || !constraints.audio) {
        return Promise.reject(new DOMException('Permission denied', 'NotAllowedError'));
      }
      const context = new AudioContext();
      const oscillator = context.createOscillator();
      oscillator.frequency.value = 440;
      const out = context.createMediaStreamDestination();
      oscillator.connect(out);
      oscillator.start();
      void context.resume();
      window.__micStreams.push(out.stream);
      return Promise.resolve(out.stream);
    };
  })()`)
}

/** How many times the page asked for the microphone. */
export function microphoneCalls(page: Page): Promise<number> {
  return page.evaluate<number>('window.__micCalls')
}

/** True when every track of every stream the stub handed out was stopped. */
export function microphoneReleased(page: Page): Promise<boolean> {
  return page.evaluate<boolean>(
    'window.__micStreams.every((s) => s.getTracks().every((t) => t.readyState === "ended"))',
  )
}

/** Sends the next /api/speech/say requests with this fake fixture name (only the fake provider reads it). */
export async function useSpeechFixture(page: Page): Promise<{ set: (name: string) => void }> {
  let current = 'echo'
  await page.route('**/api/speech/say', async (route) => {
    await route.continue({ headers: { ...route.request().headers(), 'x-test-speech-fixture': current } })
  })
  return {
    set(name: string) {
      current = name
    },
  }
}
