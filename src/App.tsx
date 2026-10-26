import { FrontDoor } from './screens/FrontDoor.tsx'
import { SessionPage } from './screens/SessionPage.tsx'
import { VoiceSettings } from './screens/VoiceSettings.tsx'

// The app's pages, picked by the plain path check (no router: a few paths,
// factory/jobs/8-first-session/spec.md, Decision 12). /session is today's
// session; /voice is Voice settings (job 10-speaking-feedback); every other
// path, deep links included, shows the front door.
// The "Hei!" smoke test page of job 2-smoke is retired (statement 21).

export function App({ path }: { path: string }) {
  if (path === '/session') return <SessionPage />
  if (path === '/voice') return <VoiceSettings />
  return <FrontDoor />
}
