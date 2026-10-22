import type { Page, TestInfo } from '@playwright/test'

// Records how long each call to the app's own /api/* took, as one line in the
// test output, so slow saves on the test project can be measured (job
// 3-data-model round 3). Only the method, the path, the status, the browser and
// the milliseconds are written: no address, header, body or secret.
// Requests a test holds on purpose (page.route) include that hold in their time;
// the test name says which tests hold requests.
export function recordApiTimings(page: Page, testInfo: TestInfo): void {
  const write = (path: string, method: string, outcome: string, ms: number) => {
    console.log(
      `API timing | ${testInfo.project.name} | ${method} ${path} | ${outcome} | ${String(Math.round(ms))} ms | ${testInfo.title}`,
    )
  }
  page.on('requestfinished', (request) => {
    const path = new URL(request.url()).pathname
    if (!path.startsWith('/api/')) return
    const timing = request.timing()
    void request.response().then((response) => {
      write(path, request.method(), String(response?.status() ?? 'no answer'), timing.responseEnd)
    })
  })
  page.on('requestfailed', (request) => {
    const path = new URL(request.url()).pathname
    if (!path.startsWith('/api/')) return
    write(path, request.method(), 'failed', request.timing().responseEnd)
  })
}
