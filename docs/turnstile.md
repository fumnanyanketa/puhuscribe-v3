# The bot check on Start (Cloudflare Turnstile)

Owner's choice, 3 November 2026. Every guest account is made through `POST /api/guest`, and Supabase counts every anonymous sign in under the Worker's address. A script calling that route could use up the shared limit and stop real learners from starting. Cloudflare Turnstile now checks for bots before a guest account is made.

## What happens

1. A learner who is not signed in presses Start on the day one card.
2. The browser loads Turnstile's script from `challenges.cloudflare.com`. It is never loaded on page load, and never for a learner who is already signed in.
3. Turnstile runs out of sight. Most learners see nothing except the busy Start button. When Cloudflare decides a learner must act, its "Verify you are human" box appears inside the road card, above Start, with one quiet line saying why.
4. The browser sends Start again with the token. The Worker checks the token with Cloudflare (siteverify) and only then makes the guest.
5. If the check fails, the card says so kindly and Start can be pressed again. If the check cannot load or Cloudflare cannot be reached, no guest is made and the card asks the learner to check the connection.

Signing in with email is unchanged and has no Turnstile step.

The code is in `worker/providers/human-check.ts` (the only file that talks to Turnstile from the Worker), `worker/api.ts` (the guest route) and `src/lib/human-check.ts` (the browser side).

## Keys

| Name | What it is | Where it lives |
| --- | --- | --- |
| `TURNSTILE_SITE_KEY` | The widget's site key. Public: every visitor's browser receives it. | GitHub secret, written to the Worker at each upload. The Worker hands it to the browser when a new guest presses Start. |
| `TURNSTILE_SECRET` | The widget's secret key. Never leaves the Worker. | GitHub secret, written to the Worker at each upload. |

The two are used only as a pair. Until both exist, local runs and the `*.fumnanya.workers.dev` previews use Cloudflare's published test keys, which always pass, so nothing breaks before the widget exists. On any other address (the future live domain), a Worker without the pair makes no new guests at all, so a live app can never run with a check that always passes.

The site key is not baked into the browser build. The build's secret check refuses any value whose name contains `KEY`, and keeping both keys on the Worker means the site key and the secret always match.

## Create the widget (owner, about 5 minutes)

1. Sign in at [dash.cloudflare.com](https://dash.cloudflare.com) to the account that runs `puhuscribe-preview`.
2. In the left sidebar, open **Application security** and choose **Turnstile**. If you cannot find it, open `https://dash.cloudflare.com/?to=/:account/turnstile`.
3. Click **Add widget**.
4. **Widget name**: `PuhuScribe Start`.
5. **Hostname management**: click **Add hostnames** and add these, one at a time, without `https://`:
   - `fumnanya.workers.dev` (this covers `main-puhuscribe-preview.fumnanya.workers.dev` and every pull request preview, because a hostname covers its subdomains)
   - the live domain, `meetaleksi.com` (job go-live); you can add it later in the widget's **Settings**
   If Cloudflare refuses `fumnanya.workers.dev`, add `main-puhuscribe-preview.fumnanya.workers.dev` instead; pull request previews would then fail the check once the real keys are set, so tell the manager.
6. **Widget mode**: choose **Managed**. The app already asks Cloudflare to stay hidden unless a learner must act.
7. **Pre-clearance**: leave it off (choose **No**).
8. Click **Create**.
9. The next page shows the **Site key** and the **Secret key**. Keep this page open for the next step. Do not paste either key into chat.

## Store the two keys in GitHub (owner, 2 minutes)

In a terminal in the project folder, run each command. Each one asks for the value and hides it as you paste, so it never appears on screen or in chat.

```
gh secret set TURNSTILE_SITE_KEY --repo fumnanyanketa/puhuscribe-v3
gh secret set TURNSTILE_SECRET --repo fumnanyanketa/puhuscribe-v3
```

Paste the **Site key** at the first prompt and the **Secret key** at the second, pressing Enter after each. To check they exist (names only, never values):

```
gh secret list --repo fumnanyanketa/puhuscribe-v3
```

The next push to main writes both into the main link's Worker version, and every new pull request preview gets them too. Nothing else needs changing.

## At go live

The live Worker, `aleksi` on `meetaleksi.com` (job go-live), gets the same pair from the same two GitHub secrets: the "app" task of `.github/workflows/live.yml` writes them into each deploy and refuses to deploy when either is missing. `meetaleksi.com` must be in the widget's hostnames. The Worker checks that every token was made on the address the request came to, so a token from a preview, or from `www.meetaleksi.com`, is refused on `meetaleksi.com`; the live Worker sends every `www` page to `meetaleksi.com` first, so learners only ever get tokens made there. Without the pair the live app refuses to make guests, on purpose.

## Content Security Policy

The app's pages send no Content Security Policy today, so nothing blocks Turnstile and no change was needed. If one is added later, the app's page routes must allow `https://challenges.cloudflare.com` in `script-src` and `frame-src` (Cloudflare's [CSP reference](https://developers.cloudflare.com/turnstile/reference/content-security-policy/)). `connect-src` needs nothing extra because pre-clearance is off. The owner page and the `/api/*` answers do not need it.

## Privacy

The privacy notice's Cloudflare entry says Turnstile checks the Start button for bots and lists what it reads (internet address, the browser's User-Agent and TLS fingerprint, and the site key with this site's address), per Cloudflare's [Turnstile privacy addendum](https://www.cloudflare.com/turnstile-privacy-policy/) (last updated 18 June 2025). The Worker sends Cloudflare only the secret and the token, not the learner's internet address, and logs nothing about the check.

## Cloudflare's test keys

From [Cloudflare's testing page](https://developers.cloudflare.com/turnstile/troubleshooting/testing/). These are public and safe to keep in code.

| Key | Behaviour |
| --- | --- |
| Site key `1x00000000000000000000AA` | Always passes (the default locally and on previews) |
| Site key `3x00000000000000000000FF` | Always asks the learner to tick the box, useful to see the check inside the card |
| Site key `2x00000000000000000000AB` | Always fails |
| Secret `1x0000000000000000000000000000000AA` | Always passes the dummy token (the default locally and on previews) |

A real secret key refuses the dummy token, so test keys and real keys cannot be mixed.
