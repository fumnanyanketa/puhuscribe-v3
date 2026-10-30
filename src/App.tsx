import { AccountPage } from './screens/AccountPage.tsx'
import { DeletePage } from './screens/DeletePage.tsx'
import { EmailFlow } from './screens/EmailFlow.tsx'
import { FeedbackPage } from './screens/FeedbackPage.tsx'
import { FrontDoor } from './screens/FrontDoor.tsx'
import { OwnerPage } from './screens/OwnerPage.tsx'
import { PrivacyPage } from './screens/PrivacyPage.tsx'
import { SessionPage } from './screens/SessionPage.tsx'
import { VoiceSettings } from './screens/VoiceSettings.tsx'

// The app's pages, picked by the plain path check (no router,
// factory/jobs/8-first-session/spec.md, Decision 12). /session is today's
// session; /voice is Voice settings (job 10-speaking-feedback); the account
// pages and the privacy notice come from factory/jobs/11-accounts/spec.md;
// /feedback and the owner page /owner from factory/jobs/14-analytics/spec.md.
// Every page here is listed in worker/page-routes.ts (tests/analytics-rules.test.ts).
// Every other path, deep links included, shows the front door. The "Hei!"
// smoke test page of job 2-smoke is retired (job 8, statement 21).

export function App({ path }: { path: string }) {
  if (path === '/session') return <SessionPage />
  if (path === '/voice') return <VoiceSettings />
  if (path === '/account') return <AccountPage />
  if (path === '/account/email') return <EmailFlow mode="add" />
  if (path === '/account/delete') return <DeletePage />
  if (path === '/sign-in') return <EmailFlow mode="sign-in" />
  if (path === '/privacy') return <PrivacyPage />
  if (path === '/feedback') return <FeedbackPage />
  if (path === '/owner') return <OwnerPage />
  return <FrontDoor />
}
