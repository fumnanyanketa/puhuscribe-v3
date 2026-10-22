# Job 1-stack: security and privacy review, round 2

Reviewer: security. 19 October 2026. Branch `factory/1-stack` at `0eeae15`, pull request #1. I read `AGENTS.md`, `spec.md`, `build.md` (round 2), `summary.md` and the full diff against main. I did not read `.env.local` or `.env.cloudflare`, ran nothing against Cloudflare or Supabase, and printed no secret value. I checked GitHub artifacts by metadata only.

## Round 1 findings and how each was resolved

1. **Must fix: the evaluator's Access service token was in plain text in uploaded Playwright traces.** Resolved.
   - The manager deleted the artifacts, rotated the token and revoked Access sessions. The artifact list now shows no `playwright-report-preview` artifact from any run. The only artifacts left are run 39295790830's guarded uploads and the gitleaks reports.
   - The builder fixed the cause:
     - With the token headers set, `playwright.config.ts` writes no trace, no HAR and no HTML report. `tests/playwright-config.test.ts` guards this.
     - The preview job uploads only `*.png` and `*.webm`.
     - `scripts/ci/check-files-for-secrets.ts` runs before both uploads. It looks inside zip files, fails safe on a zip it cannot read, refuses to run with an empty variable, and prints names only. Each upload runs only when the guard passed.
2. **Should fix: the CI Cloudflare token could edit Access apps and service tokens.** Mostly resolved.
   - The token was replaced with Account > Workers Scripts > Edit only. It got a 403 on a service token delete.
   - `.env.example` line 20 is fixed.
   - The remaining risk is judged below.
3. **Note: GitHub token left in `.git/config` during the preview job.** Resolved. `persist-credentials: false` is set on all 7 checkouts.

## Findings, round 2

No must fix findings.

### Should fix: a CI token for the whole Cloudflare account, given to code from any pushed branch

- **Where:** `.github/workflows/checks.yml`, the preview job's upload step (`CLOUDFLARE_API_TOKEN`).
- **Risk:**
  - Workers Scripts Edit cannot be limited to one Worker. Any branch's workflow or package code can upload a new version of every Worker on the account. A rogue version of v2's Worker could read v2's live Anthropic, Azure and Resend keys from its environment and send them out. The same applies to the production Worker once it exists, which conflicts with "agents never get live keys".
  - If the manager's reading is right, the token can also change Access applications on the account.
- **On the manager's Access test:** A 404 on deleting an app id that does not exist does not prove the token can edit Access. Cloudflare may look up the id before it checks permission. Either way, the account-wide Worker reach above is the larger risk.
- **Fix:** Move `puhuscribe-preview` and its Access application to a separate Cloudflare account used only for previews. Zero Trust Free is per account, so the cost stays at €0. Create the CI token there, so it cannot reach v2, other client work, or the future production Worker. If v2's Worker and other Access-protected sites are not on this account, this drops to a note. Decide before liftoff either way.

### Judgement on the remaining Access risk

The existing no-sign-in tests are not enough on their own as a defence. They run only from the branch's own code in the same job that holds the token, so a harmful branch can change or skip them. They do catch accidental drift.

Today the impact is small. The preview holds only the test project's publishable key, which is designed to be public, and no learner data.

Should fix, cheap, before the evaluator or any test learner data relies on the gate: a daily scheduled workflow, run from main's code with no secrets. It requests the main preview address and one alias address with no token, and fails unless it gets a 302 to `cloudflareaccess.com`. A branch cannot change scheduled workflow code without a merge the owner approves. If Cloudflare offers Access configuration change alerts on the free plan, turning them on would add an independent signal. I did not verify that.

## Look at closely even though it passes

- **The guard only matches exact values.** It finds the raw value, which suits Cloudflare's alphanumeric token strings. Base64-encoded or split copies would pass unnoticed. The real protection is that the preview job uploads only pixels and writes no trace, HAR or report.
- **Local runs with the token.** Someone who runs `npx playwright test --trace on` with the token variables set overrides the config and writes a trace to disk. That file stays local, but it should not be committed or shared. The evaluator should not pass `--trace` against the preview.
- **Job logs.** Playwright's list reporter can print request call logs on errors. GitHub masks the registered secrets in job logs, so the values appear as `***`.
- **gitleaks reports.** The SARIF reports are kept until January 2027. The one from scratch run 39278766728 refers to the made-up key only.
- **Carried over from round 1, unchanged:**
  - `SUPABASE_TEST_DB_URL` is a GitHub secret no workflow uses.
  - Only the two Supabase test values may ever become Dependabot secrets.
  - Keep secrets switched off for fork pull requests.
  - Cache or rate limit `/api/health` before a public production Worker.
  - Check where Workers observability logs are stored before learner data arrives.
  - `scripts/requirements.txt` uses unpinned `>=` ranges.

Result: pass
