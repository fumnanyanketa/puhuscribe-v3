import { PATHS } from './lib/app-paths.ts'
import { AccountPage } from './screens/AccountPage.tsx'
import { DeletePage } from './screens/DeletePage.tsx'
import { EmailFlow } from './screens/EmailFlow.tsx'
import { FeedbackPage } from './screens/FeedbackPage.tsx'
import { OwnerPage } from './screens/OwnerPage.tsx'
import { PrivacyPage } from './screens/PrivacyPage.tsx'
import { RoadScreen } from './screens/RoadScreen.tsx'
import { SessionPage } from './screens/SessionPage.tsx'
import { VoiceSettings } from './screens/VoiceSettings.tsx'

// The app's pages, picked by the plain path check (no router,
// factory/jobs/8-first-session/spec.md, Decision 12). /session is today's
// session; /voice is Voice settings (job 10-speaking-feedback); the account
// pages and the privacy notice come from factory/jobs/11-accounts/spec.md;
// /feedback and the owner page /owner from factory/jobs/14-analytics/spec.md.
// Every page here is listed in worker/page-routes.ts (tests/analytics-rules.test.ts).
// Since job 17-landing-page every page lives under /learn (src/lib/app-paths.ts)
// and the main address "/" is the public landing page (landing.html).
// Every other path, deep links included, shows the road, the home screen
// (job 19-redesign). The "Hei!"
// smoke test page of job 2-smoke is retired (job 8, statement 21).

export function App({ path }: { path: string }) {
  if (path === PATHS.session) return <SessionPage />
  if (path === PATHS.voice) return <VoiceSettings />
  if (path === PATHS.account) return <AccountPage />
  if (path === PATHS.accountEmail) return <EmailFlow mode="add" />
  if (path === PATHS.accountDelete) return <DeletePage />
  if (path === PATHS.signIn) return <EmailFlow mode="sign-in" />
  if (path === PATHS.privacy) return <PrivacyPage />
  if (path === PATHS.feedback) return <FeedbackPage />
  if (path === PATHS.owner) return <OwnerPage />
  return <RoadScreen />
}
