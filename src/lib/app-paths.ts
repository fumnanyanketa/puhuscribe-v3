// The app's page paths in one place (job 19-redesign, statement 45). Files
// this job adds take their paths from here and hold none of their own. If
// job 17 moves the app under /learn, the paths change here (or come from job
// 17's helper), and the files that only got a new look keep the strings they
// had.

export const PATHS = {
  home: '/',
  session: '/session',
  account: '/account',
  accountEmail: '/account/email',
  accountDelete: '/account/delete',
  signIn: '/sign-in',
  privacy: '/privacy',
  voice: '/voice',
  feedback: '/feedback',
} as const
