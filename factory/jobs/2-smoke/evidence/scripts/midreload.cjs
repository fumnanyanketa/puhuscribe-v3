// Investigate: reload while the first POST /api/visits is still waiting.
// usage: node midreload.cjs <baseURL> <browser> <useRoute 0|1>
const pw = require(
  'C:/Users/fumna/AppData/Local/Temp/claude/C--Users-fumna-dev-puhuscribe-v3/4c61d26d-55cf-47da-8e64-ec4ef75e493b/scratchpad/app/node_modules/@playwright/test',
)
const [, , baseURL, browserName, useRoute] = process.argv
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))
;(async () => {
  const browser = await pw[browserName].launch()
  const context = await browser.newContext({ viewport: { width: 375, height: 812 } })
  const page = await context.newPage()
  const t0 = Date.now()
  const log = (m) => console.log(`${String(Date.now() - t0).padStart(5)}ms ${m}`)
  page.on('request', (r) => r.url().includes('/api/visits') && log(`request ${r.method()} ${r.url()}`))
  page.on('requestfinished', (r) => r.url().includes('/api/visits') && log(`finished ${r.method()}`))
  page.on('requestfailed', (r) => r.url().includes('/api/visits') && log(`failed ${r.failure()?.errorText}`))
  page.on('response', (r) => r.url().includes('/api/visits') && log(`response ${r.status()}`))
  if (useRoute === '1') {
    let n = 0
    await page.route('**/api/visits', async (route) => {
      n += 1
      const me = n
      log(`route handler #${me}`)
      if (me === 1) await sleep(3000)
      await route.continue().catch((e) => log(`continue #${me} threw ${e.message.split('\n')[0]}`))
    })
  }
  await page.goto(baseURL + '/')
  log('loaded 1, status=' + (await page.getByRole('status').textContent()))
  await sleep(300)
  await page.reload()
  log('reloaded, status=' + (await page.getByRole('status').textContent()))
  await page.getByRole('status').filter({ hasText: 'Your visit is saved.' }).waitFor({ timeout: 15000 })
  log('status saved')
  await sleep(4000)
  log('end')
  await browser.close()
})()
