// Evaluator's own browser drive for job 2-smoke. Not part of the repo.
// usage: node drive.cjs <baseURL> <chromium|webkit> <mode> <outDir> <label>
const path = require('path')
const fs = require('fs')
const pw = require(
  'C:/Users/fumna/AppData/Local/Temp/claude/C--Users-fumna-dev-puhuscribe-v3/4c61d26d-55cf-47da-8e64-ec4ef75e493b/scratchpad/app/node_modules/@playwright/test',
)

const [, , baseURL, browserName, mode, outDir, label] = process.argv
fs.mkdirSync(outDir, { recursive: true })
const SAVING = 'Saving your visit.'
const SAVED = 'Your visit is saved.'
const NOT_SAVED = 'Your visit was not saved. Check your internet connection, then try again.'
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))
const results = []
function record(name, ok, detail) {
  results.push({ name, ok, detail })
  console.log(`${ok ? 'PASS' : 'FAIL'} [${browserName} ${label}] ${name} :: ${typeof detail === 'string' ? detail : JSON.stringify(detail)}`)
}

async function newPage(browser, opts = {}) {
  const context = await browser.newContext({
    viewport: { width: 375, height: 812 },
    hasTouch: true,
    ...(opts.video ? { recordVideo: { dir: outDir, size: { width: 375, height: 812 } } } : {}),
  })
  const page = await context.newPage()
  const posts = []
  const requests = []
  const consoleProblems = []
  page.on('request', (r) => {
    if (!r.url().startsWith('data:')) requests.push(`${r.method()} ${r.url()} [${r.resourceType()}]`)
    if (r.method() === 'POST' && new URL(r.url()).pathname === '/api/visits') posts.push(Date.now())
  })
  page.on('console', (m) => {
    if (m.type() === 'error' || m.type() === 'warning') consoleProblems.push(`${m.type()}: ${m.text()}`)
  })
  page.on('pageerror', (e) => consoleProblems.push(`pageerror: ${e.message}`))
  return { context, page, posts, requests, consoleProblems }
}

async function statusText(page) {
  return (await page.getByRole('status').textContent())?.trim()
}

async function waitStatus(page, text, timeout = 15000) {
  await page.getByRole('status').filter({ hasText: text }).waitFor({ timeout })
}

;(async () => {
  const browser = await pw[browserName].launch()
  try {
    if (mode === 'once') {
      // One single page load, for the database before/after count.
      const s = await newPage(browser)
      await s.page.goto(baseURL + '/')
      await waitStatus(s.page, SAVED)
      await sleep(3000)
      await s.page.screenshot({ path: path.join(outDir, `${label}.png`) })
      record('one load, posts', s.posts.length === 1, { posts: s.posts.length, status: await statusText(s.page) })
      record('console clean', s.consoleProblems.length === 0, s.consoleProblems)
      await s.context.close()
    }

    if (mode === 'full') {
      // 1. Page content and no styling
      {
        const s = await newPage(browser, { video: true })
        // hold the answer so "Saving your visit." can be captured
        let held = true
        await s.page.route('**/api/visits', async (route) => {
          if (held) await sleep(2500)
          await route.continue()
        })
        await s.page.goto(baseURL + '/')
        await waitStatus(s.page, SAVING, 2000)
        await s.page.screenshot({ path: path.join(outDir, `3-saving-${label}.png`) })
        record('saving message shows first', (await statusText(s.page)) === SAVING, await statusText(s.page))
        record('no Try again while saving', (await s.page.getByRole('button').count()) === 0, '')
        await waitStatus(s.page, SAVED)
        await sleep(1500)
        await s.page.screenshot({ path: path.join(outDir, `1-hei-saved-${label}.png`) })
        const dom = await s.page.evaluate(() => {
          const h = [...document.querySelectorAll('h1,h2,h3,h4,h5,h6')]
          return {
            headings: h.map((x) => ({ tag: x.tagName, text: x.textContent, lang: x.getAttribute('lang') })),
            htmlLang: document.documentElement.lang,
            title: document.title,
            statusCount: document.querySelectorAll('[role="status"]').length,
            statusTag: document.querySelector('[role="status"]')?.tagName,
            styleSheets: document.styleSheets.length,
            styleEls: document.querySelectorAll('style, link[rel~="stylesheet"], [style], [class]').length,
            media: document.querySelectorAll('img, svg, picture, video, canvas, object, embed').length,
            icons: [...document.querySelectorAll('link[rel~="icon"]')].map((l) => l.getAttribute('href')),
            fontFamily: getComputedStyle(document.body).fontFamily,
            color: getComputedStyle(document.body).color,
            bg: getComputedStyle(document.body).backgroundColor,
            bodyText: document.body.innerText,
            mainHTML: document.querySelector('#root')?.innerHTML,
          }
        })
        fs.writeFileSync(path.join(outDir, `1-dom-${label}.json`), JSON.stringify(dom, null, 2))
        record(
          'one h1 "Hei!" with lang=fi',
          dom.headings.length === 1 && dom.headings[0].text === 'Hei!' && dom.headings[0].lang === 'fi',
          dom.headings,
        )
        record('title PuhuScribe', dom.title === 'PuhuScribe', dom.title)
        record('one status line', dom.statusCount === 1, dom.statusTag)
        record(
          'no styling',
          dom.styleSheets === 0 && dom.styleEls === 0 && dom.media === 0 && dom.icons.every((h) => h === 'data:,'),
          { sheets: dom.styleSheets, styleEls: dom.styleEls, media: dom.media, icons: dom.icons, font: dom.fontFamily },
        )
        const resTypes = s.requests.filter((r) => /\[(stylesheet|font|image|media)\]/.test(r))
        record('no stylesheet/font/image requests', resTypes.length === 0, resTypes)
        const origin = new URL(s.page.url()).origin
        const foreign = s.requests.filter((r) => !r.split(' ')[1].startsWith(origin))
        record('all requests same origin, none to supabase', foreign.length === 0, foreign)
        fs.writeFileSync(path.join(outDir, `2-requests-${label}.txt`), s.requests.join('\n') + '\n')
        record('one POST on first load', s.posts.length === 1, s.posts.length)
        record('console clean on load', s.consoleProblems.length === 0, s.consoleProblems)
        held = false
        const snap = await s.page.locator('body').ariaSnapshot()
        fs.writeFileSync(path.join(outDir, `1-aria-${label}.txt`), snap + '\n')
        // reloads
        for (let i = 2; i <= 3; i++) {
          await s.page.reload()
          await waitStatus(s.page, SAVED)
          await sleep(1500)
          record(`reload ${i - 1}: posts total ${i}`, s.posts.length === i, s.posts.length)
        }
        // deep link then back: a fresh document load sends one; a back to the page (maybe bfcache)
        await s.page.goto(baseURL + '/some/deep/link')
        await waitStatus(s.page, SAVED)
        await sleep(1000)
        const afterDeep = s.posts.length
        await s.page.goBack()
        await sleep(2500)
        const afterBack = s.posts.length
        record('deep link loads app, one POST', afterDeep === 4, { afterDeep })
        record('back navigation', true, { afterBack, status: await statusText(s.page) })
        const vid = s.page.video()
        await s.context.close()
        if (vid) fs.renameSync(await vid.path(), path.join(outDir, `main-path-${label}.webm`))
      }

      // 2. Blocked request, then Try again by keyboard, focus on status
      {
        const s = await newPage(browser, { video: true })
        let calls = 0
        await s.page.route('**/api/visits', async (route) => {
          calls += 1
          if (calls === 1) return route.abort('failed')
          await sleep(1200)
          return route.continue()
        })
        await s.page.goto(baseURL + '/')
        await waitStatus(s.page, NOT_SAVED)
        await sleep(500)
        await s.page.screenshot({ path: path.join(outDir, `3-not-saved-${label}.png`) })
        record('failure message exact', (await statusText(s.page)) === NOT_SAVED, await statusText(s.page))
        const btn = s.page.getByRole('button', { name: 'Try again' })
        record('Try again visible after failure', await btn.isVisible(), '')
        await s.page.keyboard.press('Tab')
        let focusedBtn = await s.page.evaluate(() => document.activeElement?.textContent)
        const tabWorked = focusedBtn === 'Try again'
        if (!tabWorked) await btn.focus()
        await s.page.screenshot({ path: path.join(outDir, `3-focus-try-again-${label}.png`) })
        await s.page.keyboard.press('Enter')
        await waitStatus(s.page, SAVING, 1000)
        const focusDuring = await s.page.evaluate(() => document.activeElement?.getAttribute('role'))
        await s.page.screenshot({ path: path.join(outDir, `3-retry-saving-${label}.png`) })
        await waitStatus(s.page, SAVED)
        await sleep(1000)
        const focusAfter = await s.page.evaluate(() => document.activeElement?.getAttribute('role'))
        await s.page.screenshot({ path: path.join(outDir, `3-retry-saved-${label}.png`) })
        record('keyboard Try again -> saving -> saved, one new POST', s.posts.length === 2, {
          posts: s.posts.length,
          tabReachedButton: tabWorked,
          focusDuring,
          focusAfter,
        })
        record('focus on status line after Try again', focusDuring === 'status' && focusAfter === 'status', {
          focusDuring,
          focusAfter,
        })
        record('button gone after save', (await btn.count()) === 0, '')
        record('console during failure path', true, s.consoleProblems)
        const vid = s.page.video()
        await s.context.close()
        if (vid) fs.renameSync(await vid.path(), path.join(outDir, `failure-path-${label}.webm`))
      }

      // 3. Double tap on Try again
      {
        const s = await newPage(browser)
        let calls = 0
        await s.page.route('**/api/visits', async (route) => {
          calls += 1
          if (calls === 1) return route.abort('failed')
          await sleep(800)
          return route.continue()
        })
        await s.page.goto(baseURL + '/')
        await waitStatus(s.page, NOT_SAVED)
        const box = await s.page.getByRole('button', { name: 'Try again' }).boundingBox()
        await s.page.mouse.dblclick(box.x + box.width / 2, box.y + box.height / 2)
        await waitStatus(s.page, SAVED)
        await sleep(1500)
        record('double click Try again sends one POST', s.posts.length === 2, { posts: s.posts.length })
        // tap twice via touchscreen
        await s.context.close()
      }
      {
        const s = await newPage(browser)
        let calls = 0
        await s.page.route('**/api/visits', async (route) => {
          calls += 1
          if (calls === 1) return route.abort('failed')
          await sleep(800)
          return route.continue()
        })
        await s.page.goto(baseURL + '/')
        await waitStatus(s.page, NOT_SAVED)
        const box = await s.page.getByRole('button', { name: 'Try again' }).boundingBox()
        await Promise.all([
          s.page.touchscreen.tap(box.x + box.width / 2, box.y + box.height / 2),
          s.page.touchscreen.tap(box.x + box.width / 2, box.y + box.height / 2),
        ])
        await waitStatus(s.page, SAVED)
        await sleep(1500)
        record('double tap Try again sends one POST', s.posts.length === 2, { posts: s.posts.length })
        await s.context.close()
      }

      // 4. Try again while the network is still down: fails again, button back
      {
        const s = await newPage(browser)
        await s.page.route('**/api/visits', (route) => route.abort('internetdisconnected'))
        await s.page.goto(baseURL + '/')
        await waitStatus(s.page, NOT_SAVED)
        await s.page.getByRole('button', { name: 'Try again' }).click()
        await waitStatus(s.page, NOT_SAVED)
        await sleep(500)
        record(
          'Try again while still offline fails again with button',
          (await s.page.getByRole('button', { name: 'Try again' }).count()) === 1 && s.posts.length === 2,
          { posts: s.posts.length },
        )
        await s.context.close()
      }

      // 5. 503 answer
      {
        const s = await newPage(browser)
        await s.page.route('**/api/visits', (route) =>
          route.fulfill({ status: 503, contentType: 'application/json', body: '{"error":"visit_not_saved"}' }),
        )
        await s.page.goto(baseURL + '/')
        await waitStatus(s.page, NOT_SAVED)
        await s.page.screenshot({ path: path.join(outDir, `3-503-${label}.png`) })
        record('503 shows failure + Try again', (await s.page.getByRole('button', { name: 'Try again' }).count()) === 1, '')
        await s.context.close()
      }
      // 5b. 201 but garbage body / 200
      {
        const s = await newPage(browser)
        await s.page.route('**/api/visits', (route) => route.fulfill({ status: 200, contentType: 'text/html', body: '<html>Access</html>' }))
        await s.page.goto(baseURL + '/')
        await waitStatus(s.page, NOT_SAVED)
        record('200 HTML (e.g. a login page) is treated as not saved', true, await statusText(s.page))
        await s.context.close()
      }

      // 6. Slow answer 4 s
      {
        const s = await newPage(browser)
        await s.page.route('**/api/visits', async (route) => {
          await sleep(4000)
          await route.continue()
        })
        const t0 = Date.now()
        await s.page.goto(baseURL + '/')
        await waitStatus(s.page, SAVING, 2000)
        await sleep(3000)
        const mid = await statusText(s.page)
        await waitStatus(s.page, SAVED, 12000)
        record('slow 4s: saving at 3s then saved', mid === SAVING, { mid, ms: Date.now() - t0 })
        await s.context.close()
      }

      // 7. Refresh mid step: reload while the first answer is held
      {
        const s = await newPage(browser)
        let n = 0
        await s.page.route('**/api/visits', async (route) => {
          n += 1
          if (n === 1) {
            await sleep(3000)
            return route.continue().catch(() => {})
          }
          return route.continue()
        })
        await s.page.goto(baseURL + '/')
        await waitStatus(s.page, SAVING, 2000)
        await s.page.reload()
        await waitStatus(s.page, SAVED)
        await sleep(3500)
        record('reload mid save: one POST per load (2 loads)', s.posts.length === 2, {
          posts: s.posts.length,
          status: await statusText(s.page),
        })
        await s.context.close()
      }

      // 8. Slow network (Chromium only, real throttling)
      if (browserName === 'chromium') {
        const s = await newPage(browser)
        const cdp = await s.context.newCDPSession(s.page)
        await cdp.send('Network.enable')
        await cdp.send('Network.emulateNetworkConditions', {
          offline: false,
          latency: 2000,
          downloadThroughput: (400 * 1024) / 8,
          uploadThroughput: (400 * 1024) / 8,
        })
        const t0 = Date.now()
        await s.page.goto(baseURL + '/', { timeout: 60000 })
        await waitStatus(s.page, SAVED, 30000)
        record('slow 3G-like network: saved', true, { ms: Date.now() - t0, posts: s.posts.length })
        await s.context.close()
      }

      // 9. API probes from outside the page
      {
        const ctx = await pw.request.newContext({ baseURL })
        const probes = []
        const show = async (name, res) => {
          const h = res.headers()
          probes.push({
            name,
            status: res.status(),
            allow: h.allow,
            acao: h['access-control-allow-origin'],
            ctype: h['content-type'],
            cache: h['cache-control'],
            body: (await res.text()).slice(0, 80),
          })
        }
        await show('GET', await ctx.get('/api/visits'))
        await show('PUT json', await ctx.put('/api/visits', { headers: { 'content-type': 'application/json' }, data: '{}' }))
        await show('DELETE', await ctx.delete('/api/visits'))
        await show('OPTIONS preflight from other site', await ctx.fetch('/api/visits', { method: 'OPTIONS', headers: { origin: 'https://evil.example', 'access-control-request-method': 'POST', 'access-control-request-headers': 'content-type' } }))
        await show('POST form', await ctx.post('/api/visits', { form: { visited_at: '2020-01-01' }, headers: { origin: 'https://evil.example' } }))
        await show('POST text/plain', await ctx.post('/api/visits', { headers: { 'content-type': 'text/plain' }, data: '{}' }))
        await show('POST no content type', await ctx.fetch('/api/visits', { method: 'POST', data: Buffer.from('{}') }))
        await show('POST application/jsonx', await ctx.post('/api/visits', { headers: { 'content-type': 'application/jsonx' }, data: '{}' }))
        await show('POST JSON with chosen time (body ignored)', await ctx.post('/api/visits', { headers: { 'content-type': 'application/json', origin: 'https://evil.example' }, data: { visited_at: '2020-01-01T00:00:00Z', id: 1 } }))
        await show('POST JSON empty body', await ctx.post('/api/visits', { headers: { 'content-type': 'application/json' } }))
        await show('GET /api/health', await ctx.get('/api/health'))
        fs.writeFileSync(path.join(outDir, `4-api-probes-${label}.json`), JSON.stringify(probes, null, 2))
        for (const p of probes) console.log(`   probe ${p.name}: ${p.status} allow=${p.allow ?? '-'} acao=${p.acao ?? '-'} ${p.body}`)
        await ctx.dispose()
      }
    }
  } finally {
    await browser.close()
    fs.writeFileSync(path.join(outDir, `results-${browserName}-${label}.json`), JSON.stringify(results, null, 2))
  }
})().catch((e) => {
  console.error('DRIVE ERROR', e.message)
  process.exit(1)
})
