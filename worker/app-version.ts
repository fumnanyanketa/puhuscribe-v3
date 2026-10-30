// The app version a crash report carries: the commit the build was made from
// (factory/jobs/14-analytics/spec.md, "Done when" 25). vite.config.ts writes
// it into the build as __APP_VERSION__; a build without one, and the unit
// tests, say "local".

declare const __APP_VERSION__: string | undefined

const VERSION = /^([0-9a-f]{7,40}|local)$/

export function appVersion(): string {
  const version = typeof __APP_VERSION__ === 'string' ? __APP_VERSION__ : ''
  return VERSION.test(version) ? version : 'local'
}
