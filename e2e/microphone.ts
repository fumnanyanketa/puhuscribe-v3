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

export type Microphone = 'tone' | 'denied' | 'none'

export async function stubMicrophone(page: Page, kind: Microphone): Promise<void> {
  // A string, as the browser test project has no DOM types.
  await page.addInitScript(`(() => {
    const mode = ${JSON.stringify(kind)};
    window.__micCalls = 0;
    window.__micStreams = [];
    if (mode === 'none') { window.MediaRecorder = undefined; return; }
    const devices = navigator.mediaDevices;
    if (!devices) return;
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
