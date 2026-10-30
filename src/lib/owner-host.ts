// How a page knows it was served by the owner host
// (factory/jobs/14-analytics/spec.md, "Done when" 27; build.md round 2).
//
// Live, Cloudflare Access lets a request to the owner host through only when
// the browser sends Access's own cookie. The browser's crash reports go out
// without cookies on the app host (statement 25), so on the owner host they
// would be stopped. worker/owner.ts marks every page the owner host serves
// with this attribute on its <html> element, and src/lib/crash-reporter.ts
// sends same origin cookies only when the mark is there. The app host never
// adds it. Plain constants, so both the Worker and the browser can use them.

export const OWNER_HOST_ATTRIBUTE = 'data-puhuscribe-host'
export const OWNER_HOST_MARK = 'owner'
