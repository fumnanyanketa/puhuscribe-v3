// Open the preview link with no token and screenshot what a stranger sees. No form is touched.
const pw = require(
  'C:/Users/fumna/AppData/Local/Temp/claude/C--Users-fumna-dev-puhuscribe-v3/4c61d26d-55cf-47da-8e64-ec4ef75e493b/scratchpad/app/node_modules/@playwright/test',
)
const [, , url, outDir] = process.argv
;(async () => {
  for (const name of ['chromium', 'webkit']) {
    const browser = await pw[name].launch()
    const context = await browser.newContext({ viewport: { width: 375, height: 812 }, hasTouch: true })
    const page = await context.newPage()
    const visitPosts = []
    page.on('request', (r) => r.url().includes('/api/visits') && visitPosts.push(r.url()))
    await page.goto(url)
    await page.waitForLoadState('networkidle').catch(() => {})
    const host = new URL(page.url()).hostname
    const hei = await page.getByRole('heading', { name: 'Hei!', exact: true }).count()
    const saved = await page.getByText('Your visit is saved.', { exact: true }).count()
    console.log(`${name}: landed on host ${host}; "Hei!" headings ${hei}; "Your visit is saved." ${saved}; visit posts ${visitPosts.length}`)
    await page.screenshot({ path: `${outDir}/12-preview-no-token-access-page-${name}.png` })
    await browser.close()
  }
})()
