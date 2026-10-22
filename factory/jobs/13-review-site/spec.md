# Job 13-review-site: Private review site for the native reviewer

Factory job, not a scope item. Needs a decision. Not GA (`"ga": false`), but the threat model is answered on the manager's request. Date: 22 October 2026. Builds on jobs 1-stack (preview Worker, Access, service token), 4-tooling (workflow and test conventions) and 7-content-pipeline (review pages and review files) as merged on main. Test label: `[site N]`.

## Summary for the owner

1. Your reviewer gets a link, `https://puhuscribe.exentrik.co`, instead of a file. The site holds only the review pages for dialogues you list, one page per round.
2. A Cloudflare login lock (Access) lets in only you and your reviewer. Each of you types your email and gets a one-time code. You type both emails into Cloudflare yourself; they are never written into the code.
3. The reviewer still presses "Download my review" and sends you the file the way you agree. Nothing is uploaded to the site.
4. When a new round's page reaches main for a listed dialogue, the site updates by itself. Adding a dialogue to the list is your instruction to the manager.
5. Cost is €0. If exentrik.co's DNS is not in the PuhuScribe Cloudflare account, you choose one extra step (owner's call 1): the "one CNAME record" route does not work with the login lock on the free plan.

## What it is

A small private website that shows the native reviewer the review pages the content pipeline already makes. The reviewer opens a link on a phone or computer, signs in with an emailed code, reviews the dialogue, downloads the review file and sends it to the owner. Nobody else can open the site, and search engines are told to stay away.

## Done when

Checked by a command, by the GitHub checks, or on the live site. Tests carry `[site N]`. "The list" is `review-site/dialogues.json`. "The site" is `https://puhuscribe.exentrik.co` (or the address owner's call 1 picks). "Listed page" means a `content/drafts/<slug>/review/round-<n>.html` committed on main for a slug on the list.

### Built and proven before merge (local and pull request checks)

1. **The list.** `review-site/dialogues.json` holds only dialogue slugs, for example `{"dialogues": ["meeting-people-new-colleague"]}`, and nothing else (no names, no emails). Its first content follows owner's call 2. `docs/content-pipeline.md` says only the manager edits it, on the owner's instruction, like `content/reviews/`.
2. **The build copies only listed pages.** `npm run build:review-site` (script `scripts/review-site/build.ts`, run directly by Node 24) writes `dist-review/` with exactly these files: `index.html`, `robots.txt`, and every listed page at `<slug>/round-<n>.html`, byte for byte (same SHA-256 as the committed file). A Vitest test on a fixture folder proves the output file list equals that set exactly, that an unlisted slug's page is absent, and that `draft.json`, `check-report.json`, `run.log`, `audio/*.mp3`, `review/round-<n>.json`, briefs and anything in `content/reviews/` are never copied. `dist-review/` is git ignored.
3. **The build refuses bad input.** It exits non-zero, writes nothing and names the cause when: a listed slug does not match `^[a-z0-9]+(-[a-z0-9]+)*$`, is listed twice, or has no review page; a page file is a symlink, is over 25 MiB (the Workers per-file limit), or is not named `round-<n>.html`. One Vitest test per case.
4. **The index page.** `index.html` lists each listed dialogue by its English title (`brief.dialogue.title_en` in `draft.json`) and slug, with one link per round to `/<slug>/round-<n>`. A round with a returned file at `content/reviews/<slug>/round-<n>.json` on main says "Review received". The newest round without one says "Waiting for your review". Two or three plain sentences say what to do: open the waiting round, make the choices, press "Download my review", send the file back the way you agreed. Titles are escaped (a fixture title holding `<script>` is printed as text). The page has no script, loads nothing from the network, uses the review page's own system fonts and colours, follows the banned list in `AGENTS.md`, and has no sideways scroll at 375 px (Playwright, Chromium and WebKit).
5. **Search engines kept out.** `robots.txt` is `User-agent: *` and `Disallow: /`. Every response from the Worker, including 403, 404 and 405, carries `X-Robots-Tag: noindex, nofollow, noarchive`, `Cache-Control: private, no-store`, `Referrer-Policy: no-referrer`, `X-Content-Type-Options: nosniff`, and a `Content-Security-Policy` with `frame-ancestors 'none'`. On the index page that policy is `default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'`. Review pages keep their own built-in policy from job 7 unchanged; the Worker adds only `frame-ancestors 'none'` to them.
6. **A second lock inside the Worker.** `review-site/worker.ts` runs before every file (`run_worker_first: true`). It serves a file only when the `Cf-Access-Jwt-Assertion` header holds a token signed by the team's Access keys (fetched from `<team domain>/cdn-cgi/access/certs`), with issuer equal to the team domain and audience equal to this Access application's AUD tag. Otherwise it answers 403 with one plain line and no file. When either setting is missing it answers 403 to everything. Vitest, with a locally made key: no header, a malformed token, a wrong signature, a wrong audience, a wrong issuer and an expired token each get 403; a valid token gets the file. Evidence shows the tests going red when the check is replaced by "always allow".
7. **Read only.** Only `GET` and `HEAD` are answered; every other method gets 405. A path with no file gets 404 with no list of files. Vitest, and checked locally with `wrangler dev`.
8. **No logs of who signed in.** The review Worker has `observability` turned off and contains no `console` call. It never reads the email inside the token. A Vitest test checks both.
9. **Its own Worker.** `review-site/wrangler.jsonc` names a new Worker, `puhuscribe-review`, with assets from `dist-review/`, `html_handling` left at its default (so `/<slug>/round-1` serves `round-1.html`), `not_found_handling` `none`, `workers_dev: false`, `preview_urls: false`, no secrets and no binding other than the assets. In branch A or C it has one route, `{ "pattern": "puhuscribe.exentrik.co", "custom_domain": true }`. A Vitest test reads the config. The app's `wrangler.jsonc` and the `puhuscribe-preview` Worker are unchanged.
10. **One workflow, deploys only from main.** `.github/workflows/review-site.yml`:
    - On a pull request that touches the site's files, it builds, runs the site's tests and runs `wrangler deploy --dry-run`, with no secret.
    - On a push to main touching `review-site/**`, `scripts/review-site/**`, `content/drafts/*/review/**`, `content/reviews/**` or the workflow itself, and on a manual start, the deploy job runs only when the ref is `refs/heads/main` and the actor is not Dependabot.
    - `permissions: contents: read`; `persist-credentials: false`; third-party actions pinned to a full commit with the version in a comment; its own concurrency group that never cancels a running deploy.
    - Secrets reach only the deploy step and the live test step.
    A Vitest test checks this shape, as `tests/checks-workflow.test.ts` does for the checks. A manual start from another branch shows the deploy job skipped (run link in `build.md`).
11. **Settings without emails.** Two GitHub variables, `REVIEW_ACCESS_TEAM_DOMAIN` and `REVIEW_ACCESS_AUD`, reach the Worker as plain variables at deploy (`--var`). They are identifiers, not secrets. The deploy step refuses to run when either is empty. Branch A needs no new secret: it reuses `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CF_ACCESS_CLIENT_ID` and `CF_ACCESS_CLIENT_SECRET`. A Vitest test finds no email-shaped string in `review-site/`, `scripts/review-site/` or the workflow. `.env.example` and `docs/content-pipeline.md` name both variables.
12. **A new round goes up by itself, only when listed.** With the list holding slug A, committing a new `round-2.html` for A puts it in the build at `A/round-2.html`; committing a round page for unlisted slug B adds nothing. Vitest on the build, and proven live by statement 16.

### Proven on the live site after merge

Deployment happens only from main, so these run in the first main run of the workflow and in the owner's own check. The manager keeps the feature `failing` until that run is green (see Risks).

13. **Access is set up with only two people.** One Access self-hosted application covers the whole hostname. Its login method is One-time PIN. One Allow policy includes exactly the owner's chosen email and the reviewer's email, typed in the Zero Trust dashboard by the owner, or by the manager in the browser pane with the owner signed in. One Service Auth policy includes the existing evaluator service token. There is no "Everyone" rule and no Bypass rule. Evidence is a screenshot with every email address hidden.
14. **Not reachable without Access.** After each deploy, Playwright (`e2e/review-site.spec.ts`, tag `@review-site`, skipped unless `REVIEW_SITE_URL` is set) runs on Chromium and WebKit at 375 x 812:
    - An anonymous browser context, with the config's headers cleared, opens `/`, a listed page and `/robots.txt`. Each lands on a `*.cloudflareaccess.com` address and shows no dialogue title or Finnish text. The test asserts no service token header went out.
    - An anonymous request with redirects off gets 302, 401 or 403 on the same paths, and the body holds no draft text.
15. **Open with the service token, and nothing else served.** In the same run, with the service token:
    - The index lists every listed dialogue. Each listed page opens with its own title.
    - The page requests nothing except its own address (plus `data:` and `blob:`).
    - A generic fill (every Approve, every Sounds right, the dialogue approved, reviewer code `TEST`) downloads a file with `format` `puhuscribe-review-1` and the right slug and round. The file stays in the runner's temporary folder and is never uploaded or committed.
    - The headers in statement 5 are present.
    - `/content/drafts/<slug>/draft.json`, `/<slug>/audio/1-puhe.mp3`, `/<slug>/round-1.json`, `/review-site/dialogues.json` and an unlisted slug's page each get 404.
16. **The first real page is live.** If owner's call 2 is A, `https://puhuscribe.exentrik.co/meeting-people-new-colleague/round-1` serves the committed round 1 page, same SHA-256.
17. **No other address serves the site.** `https://puhuscribe-review.<account subdomain>.workers.dev/` serves no review content (branch A or C). The test reads the subdomain from a GitHub variable, never from code.
18. **The owner gets in.** The owner opens the site in a private window, asks for a code, receives it by email, signs in and sees the index. Evidence is a screenshot with the email hidden. The reviewer's first sign in is the owner's to arrange.
19. **Test files hold no secret.** Playwright runs with the token headers set, so no trace, HAR file or HTML report is written (existing `playwright.config.ts`). `scripts/ci/check-files-for-secrets.ts` checks `test-results` for `CF_ACCESS_CLIENT_ID` and `CF_ACCESS_CLIENT_SECRET` before only `.png` and `.webm` files are uploaded.
20. **Written down, and €0.** `docs/content-pipeline.md` steps 5 and 6 say: list the slug (owner's instruction), the page goes live after the commit reaches main, the owner sends the link `https://puhuscribe.exentrik.co/<slug>/round-<n>`, the reviewer's file comes back by the owner's channel, and only the manager adds it to `content/reviews/`. `docs/conventions.md` adds the `review-site/` folder and the `[site N]` label. The README running costs list adds the `puhuscribe-review` Worker (Workers Free, €0) and Access (Zero Trust Free, 2 of 50 seats, €0).

Product rules from `AGENTS.md` that apply: nothing unapproved is served to a learner (this site serves drafts to the reviewer only and is not the app); no learner data; no keys or tokens in code, logs or chat; client facing text in English; no placeholders; never weaken a test; pinned actions; never skip a check; never choose an email for the owner.

## Threat model

**Worst thing a malicious person could do here.**
- Use the Cloudflare token to change the Access policy or put their own page at `puhuscribe.exentrik.co`, and phish the reviewer under the owner's domain. The token (Workers edit, which also covers Access application edits, per the lessons in `AGENTS.md`) already exists and lives only in GitHub secrets. This job's deploy runs only on main. The Worker's own token check (6) stops an accidental open policy or a deleted Access app from exposing the pages, but cannot stop someone who holds the token and redeploys.
- Plant script in drafted text so it runs in the reviewer's browser on the owner's domain. Defences: job 7's page escapes all text and allows only its own hashed script; the index escapes titles and has no script; no page can be framed (5).
- Read unpublished drafts. Low harm: they hold no personal data and no secret. Defences: Access, the Worker's token check, noindex.
- Send the owner a forged review file. Unchanged from job 7: fingerprints, the reviewer code, and only the manager adds files to `content/reviews/`.

**Data we must protect.** The reviewer's email. It is personal data and lives only in the Access policy and in Cloudflare's Access sign-in records. It never goes in the repository, a commit, a log, a test or an evidence file. The owner's email, likewise. The Cloudflare token and the service token, as today.

**What the system refuses, even if asked nicely.**
- Serving any file that is not a listed page, the index or `robots.txt`.
- Serving anything without a valid Access token for this application.
- Any write: no upload, no form post, no method other than `GET` and `HEAD`.
- Deploying from a branch other than main or from a pull request.
- Being indexed or framed.
- A Bypass or "Everyone" rule in the Access application.
- Writing an email address into the repository, a log or chat output.

## Decision

### Where `exentrik.co` lives decides how the address is attached

| Branch | What the builder does | What the owner does |
|---|---|---|
| **A. exentrik.co is an active zone in the same Cloudflare account as `puhuscribe-preview`** | Adds the custom domain route to `review-site/wrangler.jsonc`. Cloudflare creates the DNS record and the certificate itself (Workers custom domains docs). | Confirms there is no existing DNS record named `puhuscribe` (a custom domain cannot be made on a hostname that already has a CNAME record). Creates the Access app (13). If the existing token is refused when it attaches the domain, widens it for the exentrik.co zone or attaches the domain once in the dashboard. |
| **B. exentrik.co's DNS is at another host** | Nothing until owner's call 1 is made. | Makes owner's call 1. |
| **C. exentrik.co is on Cloudflare, in a different account** | Same as A, in the account owner's call 1 picks. | Makes owner's call 1. |

The brief's branch B, "one CNAME record the owner adds", does not work with the login lock on the free plan. These are the reasons, from Cloudflare's docs:
- Access requires that "Domains must belong to an active zone in your Cloudflare account".
- Worker custom domains and routes need an active Cloudflare zone.
- A partial (CNAME) zone setup "is only available to customers on a Business or Enterprise plan".
- Delegating only the subdomain to Cloudflare (subdomain setup) is Enterprise only.
- A Pages project does accept a CNAME from outside DNS, but Access then cannot protect that hostname, so the drafts would be public.

That route is refused.

### Choices

| Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|
| Where the site runs | A new Worker `puhuscribe-review` with static assets and a small script, deployed only from main | A path such as `/review` on `puhuscribe-preview` | The preview Worker holds test database secrets and gets a version from every pull request branch, so a branch alias could serve review pages. Its Access policy would also have to let the reviewer into every app preview |
| Second lock | The Worker checks the Access token (Cloudflare's documented method, `jose` library as in Cloudflare's own Worker example) | Static files only, with headers from a `_headers` file | Cloudflare recommends checking the token at the origin. Without it, a deleted Access app or an open policy would expose the pages at once, and the first deploy would be open if it ran before the Access app existed |
| How the reviewer's file comes back | The page's existing "Download my review", and the reviewer sends the file by the owner's chosen channel | An upload route on the site | An upload needs storage (R2, KV or D1) and a write rule, or a GitHub write token inside a public-facing Worker. It would bypass the rule that only the manager adds files to `content/reviews/`. It is more build and more risk than a download, and job 7's page and tests stay unchanged with the download |
| How the reviewer signs in | Access One-time PIN: type an email, get a code | The login method the preview app uses today ("Cloudflare") | The 1-stack evaluation found that method shows no email code option. A reviewer without a Cloudflare account could not get in |
| Who is allowed, and where that is stored | Typed into the Access policy in the Zero Trust dashboard, never in the repository | A GitHub variable that a workflow writes into the policy through the API | GitHub variables are not masked in logs, and the workflow would need a token that can edit Access policies in CI |
| Service token for the live tests | Reuse the existing evaluator token, added as a Service Auth policy | A new token for this site | One more secret pair for no gain: that token already opens previews, which hold more than this site. Service tokens use no seat |
| How a new round is published | Automatic on a push to main, limited to listed slugs, plus a manual start for a redeploy | A manual workflow the manager starts each round | The owner's real gate is the list. A manual run adds a step every round. Nothing is sent to the reviewer automatically either way: the owner sends the link |
| How pages are told apart | `/<dialogue-slug>/round-<n>`, plus an index with each round's status. The page's own title and download file name already carry the slug and round | One page per dialogue that always shows the latest round | Earlier rounds would vanish while the reviewer may still have them open, and a link would change meaning between rounds |
| Session length | 24 hours (set in the Access app) | 1 week | A review takes 20 to 30 minutes. A shorter session means a lost phone stays signed in for less time. Cloudflare's default value was not confirmed |
| `robots.txt` placement | Inside the site, behind Access, plus `X-Robots-Tag` on every response | A Bypass rule so crawlers can read `robots.txt` | Any Bypass rule is a hole in the lock. Crawlers only ever reach the Access sign-in page |

### Facts checked today

| Fact | Source |
|---|---|
| Zero Trust Free plan: $0, 50 users | Cloudflare Zero Trust plans page |
| A seat is used at a person's first Access sign-in and kept until they are removed from the organisation. Service tokens use no seat. Revoking a session does not free the seat | Cloudflare seat management docs |
| Static asset requests are free and unlimited. Requests that run the Worker first count against Workers Free's 100,000 requests a day | Workers static assets billing page; Workers limits |
| A static file may be up to 25 MiB; up to 20,000 files per version on Workers Free | Workers limits |
| `_headers` rules do not apply to responses made by Worker code, so the Worker sets the headers itself | Workers static assets headers page |
| Access sends the token in `Cf-Access-Jwt-Assertion`. Issuer is the team domain and audience is the app's AUD tag. Keys rotate every 6 weeks, so fetch them, never hard code them | Access token validation docs |
| One-time PIN codes are emailed by Cloudflare and expire after 10 minutes | Access One-time PIN docs |

Not verified: whether Access adds `Cf-Access-Jwt-Assertion` to service token requests (statement 15 fails if it does not, and the builder reports it); whether the existing "Edit Cloudflare Workers" token may attach a custom domain on exentrik.co; whether a Worker custom domain needs the zone in the Worker's own account (the docs say "a zone you do not own" is refused); Cloudflare's default Access session length; whether Workers Logs would record request headers (avoided by turning logs off); the sender address of the One-time PIN email.

## Out of scope

- The app on this domain, the app's own domain or an "Otso" name.
- Any upload route, server-side storage, reviewer accounts or saving review choices on the server.
- Sending anything to the reviewer automatically: no email, no notification.
- Changing job 7's review page, the review file format or the pipeline.
- Any learner-facing page, learner data, analytics or third-party script.
- Design research or a new visual direction. The index borrows the review page's look.
- Editing the `puhuscribe-preview` Worker, its Access app or its policy.
- Moving exentrik.co's DNS. If owner's call 1 picks that, the owner does it as a separate step with the manager's checklist.
- Anything on the PRD's "Not in v3.0" list. In particular no Owner Insights dashboard: the index shows round status only, with no reviewer statistics.

## Build plan

1. **Build script, list and index.** Covers 1 to 4 and 12.
2. **Worker and config.** Token check, headers, read only, 404, no logs, and the wrangler config. Check locally with `wrangler dev` against `dist-review/`. Covers 5 to 9.
3. **Workflow.** Pull request dry run, main-only deploy, live tests with the upload guard, and the shape test. Covers 10, 11 and 19, plus 14 to 17 written and run locally where they can be.
4. **Owner setup** (owner, about 15 minutes, with the builder's click steps): the DNS answer and owner's call 1; the Access app with One-time PIN, both emails, the service token policy and a 24 hour session; the two GitHub variables. Covers 13.
5. **After merge.** The first main run deploys and runs the live tests. Then the owner signs in and the docs are finished. Covers 16, 17, 18 and 20.

Dependencies: the DNS answer the manager is checking; the owner's Access setup before the merge (the Worker refuses everything until the variables exist, so an early deploy shows only 403); the reviewer's email from the owner. The pull request preview link from job 1 does not cover this site.

## Risks and flags

- **Look closely: Cloudflare Access and a public domain.** A login lock on the owner's own domain. A mistake in the policy would expose drafts under exentrik.co. Statements 6, 13 and 14 cover it.
- **Look closely: personal data of the reviewer.** Their email sits in Cloudflare's Access policy and sign-in records. The Zero Trust plans page lists log retention of up to 24 hours on the free plan; whether that covers Access sign-in records was not verified, and Cloudflare does not keep this in the EU on the free plan as far as I know (not verified). The owner should tell the reviewer that Cloudflare handles the sign-in. No privacy notice is built in this job.
- **Look closely: unpublished Finnish content.** The site shows AI-drafted Finnish that the reviewer has not approved. It is for review only and never reaches a learner.
- **Live statements prove only after merge.** Deployment is main-only by the owner's rule, so statements 13 to 18 cannot be shown before the owner approves the merge. The evaluator checks statements 1 to 12 and the workflow before the merge. The manager should keep `review-site` at `failing` after the merge until the first main run and the owner's sign-in check pass. If they fail, the job reopens.
- **The existing token's reach.** The preview job on pull requests already holds `CLOUDFLARE_API_TOKEN`, which can edit Workers and Access apps. If branch A needs the token widened to the exentrik.co zone, a branch could misuse it on that zone too. Prefer attaching the domain once in the dashboard over widening the token, if the builder finds the token is refused.
- **DNS move risk (owner's call 1, B1 or C2).** Changing nameservers moves every record of exentrik.co, including email if it runs on that domain. Cloudflare's scan "is not guaranteed to find all existing DNS records", and an active DNSSEC must be turned off first or the domain can become unreachable.
- **Seats.** Each person who signs in once keeps a seat until removed. When the reviewer stops, remove them from the Zero Trust users list as well as the policy.
- **Running costs.** €0 expected: Workers Free, Zero Trust Free, a few GitHub minutes per deploy.

## Owner's calls

None of these is decided. Each has a recommendation.

**1. If exentrik.co is not in the PuhuScribe Cloudflare account.** Needed only if the manager's check finds branch B or C.

If the DNS is at another host (branch B):
- B1. Move exentrik.co's DNS to Cloudflare, free plan, in the PuhuScribe account: change two nameservers at the registrar. You get the exact address you chose. Every record of the domain moves too, including email; the manager lists them first for you to confirm. Takes about 30 minutes plus propagation.
- B2. Use the Worker's own address for now, for example `puhuscribe-review.<your subdomain>.workers.dev`, behind the same Access lock. No DNS change, and it can ship today. The link looks technical. Switching to exentrik.co later is one config line.
- B3. Use another domain that is already on Cloudflare in this account. No DNS change, but it is not the address you chose.
- Recommendation: B1, if exentrik.co carries no email or you are happy to check the record list once. Otherwise B2 now and B1 later.

If exentrik.co is on Cloudflare in another account (branch C):
- C1. Run the review Worker and its Access app in that account. That needs a new API token limited to that account (two new GitHub secrets, `REVIEW_CLOUDFLARE_API_TOKEN` and `REVIEW_CLOUDFLARE_ACCOUNT_ID`), its own free Zero Trust organisation, and a new service token. No DNS change.
- C2. Move the zone into the PuhuScribe account. The nameservers change, and the records are exported and imported.
- Recommendation: C1. No DNS change, and the token that can touch exentrik.co stays apart from the one every pull request uses.

**2. Put the first draft on the site at merge.**
- A. List `meeting-people-new-colleague`, so round 1 (committed, not yet reviewed) is live when the job merges and you can send the link straight away. Statement 16 proves it.
- B. Merge with an empty list. The index says nothing is waiting, and you list the first dialogue later.
- Recommendation: A. It is the page your reviewer needs next, and it proves the site end to end.

**Owner inputs (not choices):**
- The reviewer's email. Give it only when typing it into Access, never in a file.
- Which of your emails to put in the policy. The manager will ask; it never picks one.
- About 15 minutes in the Zero Trust dashboard, or let the manager do it in the browser pane while you are signed in.

## Sources

- `AGENTS.md`, `factory/run-plan.md`, `.claude/skills/factory/SKILL.md`
- Job specs and files: `factory/jobs/1-stack/spec.md`, `factory/jobs/1-stack/evaluation.md` (Access login method note), `factory/jobs/7-content-pipeline/spec.md`, `docs/content-pipeline.md`, `docs/conventions.md`, `.github/workflows/checks.yml` (preview job), `wrangler.jsonc`, `playwright.config.ts`, `e2e/health.spec.ts` (`@preview` Access tests), `content/drafts/meeting-people-new-colleague/review/round-1.html`
- PRD sections 7.5 and 9: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- Workers custom domains: https://developers.cloudflare.com/workers/configuration/routing/custom-domains/
- Access self-hosted application prerequisites: https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/self-hosted-public-app/
- Access token validation: https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/authorization-cookie/validating-json/
- One-time PIN: https://developers.cloudflare.com/cloudflare-one/identity/one-time-pin
- Seat management: https://developers.cloudflare.com/cloudflare-one/team-and-resources/users/seat-management/
- Zero Trust plans: https://www.cloudflare.com/plans/sase-zero-trust.md
- Partial (CNAME) setup: https://developers.cloudflare.com/dns/zone-setups/partial-setup/
- Subdomain setup: https://developers.cloudflare.com/dns/zone-setups/subdomain-setup/setup/
- Pages custom domains: https://developers.cloudflare.com/pages/configuration/custom-domains/
- Workers static assets: https://developers.cloudflare.com/workers/static-assets/ , billing: https://developers.cloudflare.com/workers/static-assets/billing-and-limitations/ , headers: https://developers.cloudflare.com/workers/static-assets/headers/ , HTML handling: https://developers.cloudflare.com/workers/static-assets/routing/advanced/html-handling/
- Workers limits: https://developers.cloudflare.com/workers/platform/limits/
- Adding a domain to Cloudflare: https://developers.cloudflare.com/fundamentals/manage-domains/add-site/
- Moving a domain between accounts: https://developers.cloudflare.com/fundamentals/manage-domains/move-domain/

Result: ready for owner approval

## Manager addendum (22 October 2026): the owner's answers

- **DNS case C1.** The manager checked Cloudflare in the owner's Chrome. `exentrik.co` is in the Cloudflare account the owner's Exentrik account (account id <account id>), which has no Workers yet and no Zero Trust set up, and uses Email Routing. The PuhuScribe previews run in a different account (workers.dev subdomain `fumnanya`). The owner chose to build the review site in the Exentrik account: its own Worker `puhuscribe-review`, its own Access lock, and its own narrow API token and account id stored as new GitHub secrets (name them `CLOUDFLARE_REVIEW_API_TOKEN` and `CLOUDFLARE_REVIEW_ACCOUNT_ID`, separate from the existing `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`). Nothing else on `exentrik.co` may change, email routing included.
- **Owner's call 2.** Approved: list `meeting-people-new-colleague` in `review-site/dialogues.json` at launch.
- **Owner setup (done by the owner, guided by the manager, before the first deploy):** switch on free Zero Trust in the Exentrik account; create one API token limited to Workers Scripts edit and what a custom domain on this one zone needs; add the two GitHub secrets; type the allowed emails into the Access policy in the dashboard. The builder builds everything that does not need these (dry run deploy, the Worker, its tests) and lists exactly what waits.
