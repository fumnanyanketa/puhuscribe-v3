# Security review: 11-accounts

Reviewed: branch factory/11-accounts at b04cad0, diff against origin/main (the manager's AGENTS.md and wrangler/miniflare commits are left out).

## Findings

No must fix and no should fix findings.

- note: supabase/migrations/20261022072911_accounts.sql:84-108. `export_my_data()` does not call `private.sign_in_is_live()`. A token that was signed out, but has not expired yet, can still read its own rows if it calls PostgREST directly. The read rules already allow that same token to read those rows, so no one gets more than they could already see. The Worker's route checks `my_account()` first (worker/account.ts:469). Fix (optional): add `and private.sign_in_is_live()` to keep it consistent with the other two functions.
- note: worker/account.ts:372-400. One code check makes two `verifyOtp` calls (email change, then sign in). Every learner reaches Supabase from the Worker's address and shares the 30 per 5 minutes verification limit, so one person can use it up for everyone. The spec already lists this under "Shared limits before launch". It must be part of the launch decision.

## Checked and passing

- `my_account()` and `delete_my_account()`: `security definer`, `search_path = ''`, no arguments, act only on `auth.uid()`, require a live `auth.sessions` row. Only `authenticated` can execute them; `anon`, `public` and `service_role` have that right revoked (migration lines 199-208). The clean up and helper functions are revoked from every API role.
- Email flow: 409 for an email account (account.ts:221, 258, 366, 429). The same `CODE_SENT_ANSWER` is returned for new, taken and unknown addresses, and no cookie is written after `updateUser`, so the cookies do not reveal which case it was. `shouldCreateUser: false` is set. No token or user id is returned; the only user id leaves in the learner's own download. An accepted email change for a different user id is thrown away (account.ts:374). `enable_confirmations = true`.
- Guest to email keeps the same auth.users row (updateUser plus a verified email change). A switch or a second device deletes the guest with the guest's own token before the new cookies are adopted. If that delete fails, the new sign in is ended.
- Delete: file stores first, then the database. The cascades remove every user table row. The 90 day clean up skips users with stored files and runs in pg_cron with no secret key in a new place.
- Export: `cache-control: no-store`, attachment, rows filtered on `auth.uid()` and read under the read rules.
- No secret or service role key, no `console` logging, no `dangerouslySetInnerHTML`, no browser call to supabase.co. The redirects go to fixed paths only.
- No new dependencies from this job.

## For the owner to look at closely

- `delete_inactive_guests()` also deletes email accounts after 24 months with no activity (owner's call 3). Confirm this matches your decision and that the privacy page states it.
- The local auth rate limits in config.toml were raised (email_sent 60, sign_in_sign_ups and token_verifications 120). This affects local only, but check that the hosted project keeps its own values.
- Before launch, the shared per-address Supabase limits (above) and the choice of email sender.

Result: pass
