# Security review: 12-units-1-3

Diff reviewed: `git diff origin/main...HEAD` at eb9a499 (code, workflow, seed, tests in full; drafts, run logs and the AI call log sampled).

## Findings

None at must fix or should fix.

- note, `worker/patterns.ts` (`tokens()`): the tokens read has no `status`/approved filter of its own. It relies on database rules and on the line ids already being approved lines from the learner's own met dialogues. Forms are also filtered to approved. No leak found, but the protection is in the database rules.
- note, `supabase/seeds/browser/020_test_fixture_units_2_3.sql`: inserts units and forms marked `approved` with `approval_ref 'test-fixture:not-reviewed:...'`. This is fine as long as browser seeds are never applied to production.

## Checked and passing

- `/api/patterns` (`worker/api.ts`): GET only, needs sign-in, reads with the learner's own token, and checks the `session` parameter against a UUID pattern. A session that belongs to someone else is ignored because `mySessions` only returns the learner's own sessions. Nothing is written.
- No draft audio or draft Finnish under `public/`. Drafts and review pages stay in `content/drafts/`. No migration changes.
- `content/logs/ai-calls.jsonl`: 78 entries, each with model, tokens and `cost_usd`. No keys and no learner data.
- Run logs hold only progress lines. No keys, tokens or emails found in added lines.
- CI pytest still runs with network off and the API keys removed from the environment (`checks.yml`).

## For the owner to look at closely

- The database rules on `tokens` and `cards` (jobs 3 and 8). The panel's privacy depends on them.
- Before publishing, confirm the publish step only takes reviewer-approved drafts. That step was not exercised here because dialogue 6 is not drafted yet.

Result: pass
