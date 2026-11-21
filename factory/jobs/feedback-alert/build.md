# feedback-alert (fast route)

The owner's calls of 21 November 2026: switch on the owner page for the live app at `owner.meetaleksi.com`, and email the owner a short alert (screen and time, never the message) when a learner sends feedback, to the inbox she sets as a GitHub secret. Flag: look closely (a processor, Brevo, gets a new use; no learner data reaches it).

## Done when

1. A stored feedback message makes the Worker send one email through Brevo's API, from hello@meetaleksi.com, to `FEEDBACK_ALERT_TO`, with the subject "New feedback on Aleksi".
2. The email holds only the screen, the Helsinki time and the owner page link. Never the message, the account id or a token.
3. Without `BREVO_API_KEY` and `FEEDBACK_ALERT_TO` nothing is sent (local runs, previews, tests).
4. At most one alert per 30 minutes per running copy of the Worker, kept in memory only, so a burst cannot use up Brevo's 300 free emails a day that the sign in codes share.
5. A failed alert never changes the learner's answer, and nothing is logged.
6. No alert when the message is refused or the day's 5 are used. The alert runs after the answer (waitUntil).
7. The live Worker is attached to `owner.meetaleksi.com`, and the live workflow passes the three owner page settings and the Brevo pair from the `live` environment. The built config still sets no variable but `CANONICAL_HOST`.

## Round 1

- `worker/providers/feedback-alert.ts` (new), wired in `worker/feedback.ts`, `worker/api.ts`, `worker/index.ts`. Brevo lists the module in `src/privacy/processors.ts`; the learner-facing privacy text is unchanged because no learner data is sent.
- `wrangler.jsonc`, `scripts/ci/check-live-build.ts` and `tests/go-live.test.ts`: the third live address. `scripts/ci/write-test-settings.ts` and `.github/workflows/live.yml`: the five settings. README "Owner page setup" rewritten for the live app.
- A first version kept the 30 minute gap in Cloudflare's Cache API; `tests/personal-data.test.ts` [accounts 23] flags any `.put(` in worker/ as a learner file store. The gap holds no learner data, but rather than weaken that check the gap now lives in memory.
- Checks: `tsc -b` clean, ESLint clean on worker/ and src/privacy/, Vitest worker/, src/, tests/personal-data and tests/go-live: 779 passed. Three other files fail in this worktree and are untouched by this job: tests/agents-md.test.ts (AGENTS.md wording and length), tests/content-audio.test.ts (needs a build) and scripts/hooks/commit-tool.test.ts (needs gitleaks on this computer). Not run: browser tests.
- Not done: the owner's own setup (README "Owner page setup" steps 1 to 6), the live deploy, a real Brevo send.
