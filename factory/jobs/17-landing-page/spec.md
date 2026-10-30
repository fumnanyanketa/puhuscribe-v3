# Job 17-landing-page: Landing page and waitlist

Scope item 15. Treated as GA (public page, personal data). Needs a decision. Date: 30 October 2026. Builds on main as merged, including 14-analytics (merged 30 October 2026) and 11-accounts. Written the same day as `15-onboarding` and `16-tutor-step`; the contract notes below keep the three apart. Test label: `[landing N]`.

## Summary for the owner

1. A public page explains PuhuScribe in plain English and has a waitlist form. I recommend it lives at `puhuscribe.exentrik.co/about` (owner's call 1). Its words are real HTML, so Google and chat apps can read them, and it has a social card (the picture shown when the link is shared).
2. A visitor types an email, ticks one unticked box to agree, and may tick a second box ("I might want a paid plan"). We send one email with a Confirm button. The address counts only after the button is pressed. Anyone can leave with a link in the email or by writing to you. The page never says whether an address is already on the list.
3. You see the list on your private owner page, in a new "Waitlist" section: the counts and the confirmed addresses. There is no export and nothing else is collected about the visitor.
4. The page and the database cost €0. The confirmation email needs a sender: €0 on some free plans, or $5 a month on Cloudflare's (owner's call 2). Nothing goes public in this job. Publishing waits for the go live job (owner's call 7).
5. Seven calls are yours: where the page lives, the email sender, what "founding member" promises, bot protection, the look (with real references), whether Exentrik appears, and when it goes public. I recommend an option for each and decide none.

## Owner's calls

**1. Where the page lives.** This changes a public address, so it is yours.

- **A. At the main address, `puhuscribe.exentrik.co`, with the app's front door moving to `puhuscribe.exentrik.co/today`.** Best for search and for people who type the name. It touches every link to the front door, the sign out and delete redirects, the home screen icon (the installable app job) and the first run welcome (`15-onboarding`), which both expect the front door at `/`. A returning learner who types the bare address gets one extra tap. Cheapest to do before those two jobs are built, but it makes this job depend on them.
- **B. At its own path, `puhuscribe.exentrik.co/about` (recommended).** Nothing in the app moves. Links, QR codes and shares point to `/about`. Search engines are told to list `/about` and not the app's front door (statement 24). A person who types the bare address still reaches the front door and the first run welcome, as `15-onboarding` promises. Moving to A later is a routing change plus the link updates.
- **C. One address, two faces.** `/` shows the page to people with no sign in cookie and the app to people with one. Returning learners get no extra tap. It breaks `15-onboarding`'s promise that a first time visitor reaches a dialogue within a minute, makes the same address show two pages, and doubles the test cases.
- Recommendation: **B**. The word `/about` is my placeholder; you can pick another word.

**2. The confirmation email and who sends it.** Sending email for real is a new service holding visitors' addresses.

- **A. Double opt in, sender chosen together with job 11's call 1 at go live (recommended).** The visitor confirms by pressing a button in one email. Needs a sender and a few DNS records on a domain you own, before the page goes public. The same sender can also send job 11's sign in codes. Prices, as I could verify on 30 October: Cloudflare Email Service sends from the Worker, but sending to any address needs the Workers Paid plan, $5 a month, which includes 3,000 emails a month and then $0.35 per 1,000 (Cloudflare docs); whether it is available on your account is unconfirmed because sources disagree on its beta status. Resend: free plan of 3,000 emails a month and 100 a day, Pro $20 a month for 50,000 (its price page); where it stores account and email data was not confirmed (job 11 found the United States). Brevo and Scaleway pages could not be read today; job 11 noted Scaleway at 300 emails included then €0.25 per 1,000 on 21 October. At the PRD's fair target of 150 sign ups, every option stays inside its free or included amount.
- **B. Single opt in, no email at all.** €0 and no new service. Anyone can type someone else's address, and you could not later show that its owner agreed. Your first announcement would be the first email those people ever get, which is the case Finnish rules treat as unsolicited marketing (KKV, Sources). Not recommended.
- Recommendation: **A**. The code sits behind one module (`worker/providers/waitlist-email.ts`), so changing sender changes that module only.

**3. What "founding member" promises.** The fair is over, so the PRD line "Waitlist sign-ups at the fair get founding-member pricing" needs a new meaning. Nothing is sold yet (payments are v3.1), and the PRD's €9.99 a month and €69 a year are a hypothesis "to test at the fair". I found no fair results in the files I read.

- **A. Say nothing about price.** The page says people on the list hear about the paid plans first. No promise, no legal exposure, less reason to join.
- **B. Promise a founding member price in words, without numbers (recommended).** For example: "People on the waitlist get a founding member price when the paid plans start. It will be lower than the public price. We tell you the exact price and how long it lasts before you pay anything." You must define, in one sentence, who qualifies and until when (my suggestion: everyone who has confirmed their address before the paid plans go on sale, with the closing date announced before it happens). You must be ready to honour it.
- **C. Show the planned prices and the discount in numbers.** Most concrete and the strongest push to join. A number shown to consumers must include VAT, and I could not check the Finnish section for that. If you later set a different public price, a fixed founding price may need to change, so a percentage is safer than a euro figure.
- Rules from EU consumer law either way (not legal advice): saying a product is available only for a short time when it is not, to force a quick decision, is banned in all circumstances (Unfair Commercial Practices Directive, Annex I point 7). Quoting a price you have no reasonable grounds to supply at is banned too (point 5). So no countdown, no "only N places left" counter, and no deadline that is not real. Lingoda's page is a good model for how to write a real offer: dates, who it covers and what it cannot be combined with, in its FAQ.
- Recommendation: **B**, with a percentage or a euro figure added only when you set the real price. I do not pick the discount.

**4. Bot protection on the form.** The risk is junk addresses and someone using the form to fill a stranger's inbox.

- **A. Our own protections only (recommended for this job).** A hidden trap field and a minimum fill time (statement 9), and caps in the database: at most 3 confirmation emails per address and 60 an hour for the whole page. No new service, no outside script, €0. A patient attacker using many addresses can use up the 60 an hour, and real visitors then wait for their email (the owner page shows the backlog).
- **B. A plus Cloudflare's Workers rate limiter per visitor address.** Stops one address hammering the form. The limit is approximate and counted per Cloudflare location. The docs do not say which plans include it or its cost, so the builder confirms before using it. The visitor's address is a counter key in Cloudflare's memory only; we store nothing.
- **C. Cloudflare Turnstile on the form.** Free plan: 20 widgets and unlimited challenges (Cloudflare docs). Best bot blocking, but the page would load a script from a Cloudflare challenge address and run checks in the visitor's browser. That breaks "no outside scripts" for this page and needs a line in the privacy notice. Job 8's launch decision (todo) must choose the same thing for guest sign in, so decide both together.
- Recommendation: **A** now. Decide C once, with job 8's launch decision, before go live.

**5. The look of the page, the Finnish on it, and the social card.** The locked design system already decides colours, type, buttons and the wordmark (`design.md`). You approved v2's look on 21 October. What is open is what carries the page.

- **5a. What carries the page.**
  - **A. Type and the register card only (recommended).** Calm single column on the lilac fade, black pill buttons, plain headings. Fast, consistent with the app, nothing to commission.
  - **B. Add real app screens.** Shows the product, but a screen shows Finnish lines that the reviewer has not approved yet, and phone mockups are a landing page cliché that cost weight on older phones.
  - **C. Add photographs of everyday Helsinki scenes.** Warm and tied to the situations, but costs money or time, weighs more on older phones (`design.md` brief), and an AI picture risks wrong Finnish on signs.
- **5b. Finnish on the page.** All of it goes to the native reviewer.
  - **A. English only, apart from two glossary words, puhekieli and kirjakieli (recommended until unit 1 is approved).** Lowest risk. The two words still go to the reviewer with the page.
  - **B. One spoken and written pair from an approved dialogue line.** Shows the product's main idea at a glance. Possible only after the reviewer approves unit 1; a test then checks the pair word for word against the published line (statement 5).
- **5c. The social card picture.**
  - **A. The wordmark and the page's one line on the lilac ground, made by a script from the real tokens (recommended).** €0, always in step with the design.
  - **B. The card with the register pair.** Needs approved Finnish.
  - **C. A designer's or photographed picture.** Costs money and weeks, and you approve each version.
- Real references, all opened on 30 October 2026 unless marked:

| Reference | Borrow | Leave out |
|---|---|---|
| Memrise, https://www.memrise.com/ | One sentence promise about real speech ("Understand native speakers. Sound more like them."); a short FAQ that answers "speaking in week one" and cost; a "Now you say it" closing prompt | Press logo strip, video led layout, the "+145 more" language picker |
| Speak, https://www.speak.com/ | No prices on the page, price only in the FAQ; the same call to action at the top and the bottom | Award badges, "15M+ downloads", the three method cards (Learn, Practice, Apply) |
| Babbel, https://www.babbel.com/ | A plain statement of the method; saying what is free (first lesson) | The promo countdown banner (the false urgency the directive bans), the "92% improved" claim, stock lifestyle photos |
| Busuu, https://www.busuu.com/ | "Speak a language in 10 minutes a day" style short time promise, only if it is true for us | "120 million learners", awards we do not have, the business section |
| Lingoda, https://www.lingoda.com/en/ | How a real offer is written: dates, who it covers, what it cannot be combined with, all in the FAQ | The sale banner, the "Hurry now!" urgency |
| Pimsleur, https://www.pimsleur.com/ | Naming the method in plain steps and saying what you do in each | "Scientifically proven" claims, the all caps banner; its page says "up to 4 users" in one place and "up to 3" in another, which is the kind of slip our claims table (below) prevents |
| Senthora, https://senthora.ai (listed on Awwwards) | A short privacy and beginner FAQ | What this page must avoid: numbered steps, six feature cards, a streak, uppercase labels |
| Halden app site, https://recent.design/i/1u0n947-halden-app-website (Godly's feed, listed as minimal, light, consumer) | The calm light single column mood | Scroll animation and the phone mockup (I could read only its listing, not the site) |

  For waitlist forms, a vendor's blog (LaunchList, not the pages themselves, which I did not open) describes Notion's early page as a logo, one sentence and an email field. I borrow the one sentence and one field idea, and leave out the queue position and referral loops (Robinhood, Dropbox in the same article), which are pressure tactics.
- Recommendation: **5a A, 5b A now and B after the reviewer approves unit 1, 5c A.** Before any screen is built you see one overview page (Build plan, step 1) and approve the look there.
- What you already have: v2's landing page, https://puhuscribe-v2.vercel.app/landing. Its page is drawn by script and I could read only its title, "Speak Finnish the way Finland speaks". That line is a strong alternative to my headline; you choose at the overview. The v2 handoff in `design/v2-handoff/` is already the source of the tokens and the wordmark. Its Finnish onboarding lines are not approved and are not reused.

**6. Whether Exentrik appears, and who is named as responsible.** The PRD gives the studio and the product different names so a spin out is clean, and the brand notes say products never carry "Exentrik". Separately, the law needs the page to name who is responsible for the addresses. Today job 11's setting names you personally.

- **A. No Exentrik on the page. The responsible line names you, as the privacy notice does today.** Nothing changes. Your personal name is public on a page people find through search.
- **B. A visible "A product by Exentrik" line.** Builds trust with the studio's audience, but it is the branding the notes rule out and it complicates a spin out.
- **C. Exentrik appears only in the responsible line, as the company that owns the product (recommended if the company, not you, is responsible).** A legal disclosure, not branding. It means changing job 11's one setting file (`src/privacy/notice-settings.ts`), with the company name and business ID from you. I could not verify whether Exentrik is registered as a company or a trading name.
- Recommendation: **C**, if the company holds the product. Either way I added no link to the YouTube channel (it is yours, not Exentrik's); tell me if you want one.

**7. When the page goes public.**

- **A. Page and app together at go live (recommended).** The page's main button is "Start your first session". The waitlist is for new units and paid plans.
- **B. Page first, waitlist only, app later.** Collects addresses sooner. The page and the consent wording must say "email me when PuhuScribe opens", which promises an opening you do not control, and the page needs a second state with its own tests (statement 6).
- Recommendation: **A**. Either way, this job only ships the page tested locally and on previews. The go live job publishes it.

**Owner inputs (not choices).** The manager asks for each; I pick none.
- The word in the page address (my placeholder is `/about`).
- The sending name and sending address on a domain you own for the confirmation email (`<sending address on the owner's domain>`), the reply address (`<owner's contact email>`) and the DNS records at go live.
- Confirm the contact printed on the page. It is the one already in the privacy notice setting; the manager asks whether it is right for waitlist requests.
- Your own address for the live check (statement 31).
- Founding member terms and figures, if you pick 3B or 3C.
- How long a confirmed address is kept. My default is 24 months after joining, the same as job 11's email accounts. Tell me if you want it shorter.
- Whether you hold fair sign ups elsewhere (paper, a spreadsheet, a form). They cannot be added to this list unless you can show each person agreed to this wording. Importing them is out of this job.
- About 20 minutes at go live for the sender, the waitlist key and one SQL line (steps in the README, written by the builder).

## What it is

A public page that explains what PuhuScribe is and lets a visitor join a waitlist for new units and the paid plans. Joining takes an email address and a yes. A confirmation email proves the address belongs to the visitor, and the visitor can leave at any time. The owner reads the list on the private owner page. The page has search metadata and a social card.

It serves P5 (it explains both registers) and P4 (it says the learner says it back) indirectly, and the five principles in its text are claims the product already keeps (claims table below). It adds nothing from the PRD's "Not in v3.0" list: no streaks, no rank titles, no confetti, no sentence bank, no Owner Insights dashboard beyond a list the scope asks for.

## Done when

Terms used below.
- **The page**: `/about`. **The confirm page**: `/about/confirm`. **The leave page**: `/about/leave`. (Names confirmed in the owner inputs.)
- **Pending address**: on the list, not yet confirmed. **Confirmed address**: the visitor pressed Confirm.
- **The fake sender**: the test stand in for the email module. It records each message so tests can read it. It is chosen only when the Worker runs locally.
- **Phone size**, **browser test** and **the fixture**: as in jobs 8, 11 and 14 (Playwright at 375 x 812 in Chromium and WebKit, against the built app and a throwaway local Supabase). Test addresses use the reserved domain `example.com`.
- **Owner host** and **app host**: as in job 14.
- Tags: **[security]**, **[personal data]** and **[Finnish content]** mark statements the reviewers and the evaluator check closely.

### The page

1. **The page is real HTML at its own address.** `GET /about` answers 200 with the finished page in the HTML itself: with scripts switched off, the heading, every section heading and the form labels are present (browser test with JavaScript disabled). `/about/confirm` and `/about/leave` answer 200 the same way. None of the three redirects. `/about/` either redirects to `/about` or serves the same page; the builder records which and a test pins it. `/about` is in `PAGE_ROUTES` and `run_worker_first`, the Worker answers it with `env.ASSETS.fetch(request)` unchanged (job 14, statement 4), and `tests/analytics-rules.test.ts` stays green without being edited. The confirm and leave pages are not Worker first, so they are never counted. On the owner host, `/about` redirects to `/owner`.
2. **One arrival counts as one visit, and nothing else about the visitor is read.** A Vitest table test shows `GET /about` with browser headers calls `count_visit` once with the country alone, and the confirm and leave pages call it never. A browser test follows a visitor through join, confirm and leave and fails if the page sets a cookie, writes local or session storage, or makes any request to another origin. Each page carries a `Content-Security-Policy` meta tag that allows only its own origin (`default-src 'none'` plus `script-src`, `style-src`, `font-src`, `img-src`, `connect-src` and `form-action` set to the page's own origin, and `base-uri 'none'`), and the browser test fails on any violation. If Vite's output cannot meet that without `'unsafe-inline'`, the builder stops and says so; the policy is not loosened. The page's script never sets `credentials: 'omit'` on a request (a unit test reads the call), because Cloudflare Access blocks such fetches on previews. **[personal data] [security]**
3. **The text is the proposed text, and it keeps the writing rules.** The page holds the sections and wording of "The page text" below, as changed by the owner at the overview. A repository test reads the built HTML and fails on: more or fewer than one `h1`; a skipped heading level; a missing `lang="en"` on the document; a word from the hype list in `AGENTS.md`; an em dash or a spaced hyphen used as punctuation; and any price, discount figure, sign up count, date or countdown unless it is written in `src/landing/offer.ts` (the one file for founding member figures, empty unless owner's call 3 is C).
4. **Every claim is true.** The evaluator walks the claims table below against the running app and records each row's proof in `build.md`. A row that fails changes the page text, not the table. Nothing is claimed that is not in the table. At go live the row about the reviewer is checked again.
5. **Finnish on the page is limited and traceable.** Every string inside a `lang="fi"` element is either `puhekieli` or `kirjakieli`, or (only if owner's call 5b is B) a pair found word for word in a published, approved dialogue line (Vitest searches the publish migrations). A repository test fails on the letters ä, ö or å in the page text outside `lang="fi"` elements. The two glossary words go to the native reviewer with the page text, and the page does not go public before the reviewer answers (go live dependency). **[Finnish content]**
6. **Only if owner's call 7 is B: two states.** One constant, `APP_IS_OPEN` in `src/landing/site.ts`. When false, the main button is "Join the waitlist", the "Start your first session" button and the free answer in the FAQ are replaced, and the consent text says "when PuhuScribe opens" (wording in the overview). A browser test covers both states. With call 7 A the constant is true and the false state does not exist.

### Joining the waitlist

7. **The form.** One text field labelled "Email address" (`type="email"`, `autocomplete="email"`, `inputmode="email"`, `maxlength="254"`), a required box and an optional box with the wording below, a trap field (statement 9) and a "Join the waitlist" button. Both boxes are unticked on a fresh load and after the browser's back and forward buttons (`autocomplete="off"` on the form; browser test reads `checked`). An empty or badly shaped address gets "Please check the email address." and no request. An unticked required box gets "Please tick the box to join the waitlist." and no request. Pressing the button while a request is running does nothing: two quick taps send one request, and the button reads "Joining the waitlist." and tells screen readers so. **[personal data]**
8. **One answer for every case.** `POST /api/waitlist` (JSON, same origin, body read and capped at 2 KB before answering) answers 202 with the same body for: a new address, a pending address, a confirmed address, an address over its cap, the whole page over its cap, a filled trap field, and a form sent too fast. Vitest with a database fake compares status and body byte for byte across all seven. The page shows the same text for all of them (below). Bad input gets 400 for a shape or a missing required box, which cannot reveal membership. The email is sent after the answer (`ctx.waitUntil`), so a slow or failing sender changes nothing the visitor sees (Vitest with a sender that hangs and one that fails). **[security] [personal data]**
9. **A trap and a clock.** The form has one hidden field a person never fills (off screen, `tabindex="-1"`, `autocomplete="off"`, hidden from assistive technology) and the script sends how many milliseconds passed since the form appeared. A filled trap, or less than 3,000 ms, or a missing value (a direct post that skipped the page) gets the same 202 answer and stores nothing. A person who fills the form normally is never refused, and axe finds no violation from the trap field. Vitest and a browser test.
10. **The confirmation email.** After a join that the database marks "send" (statement 14), the Worker sends one plain text email through `worker/providers/waitlist-email.ts` to that address only. Subject: "Confirm your email for the PuhuScribe waitlist". It holds the confirm link and the leave link (statement 11 and 12), a line saying the confirm link works for 48 hours, "If you did not ask for this, ignore this email. We delete the address within 7 days.", and the responsible name and contact from the privacy notice setting. It has no tracking pixel, no click tracking option in the request, no attachment, nothing the visitor typed other than the address, and no link to another site. Header values are checked for line breaks. The module is the only file that knows where email goes; a repository test fails if another file sends email. **[security] [personal data]**
11. **Confirming is a button, not a link that acts.** The email's link opens `https://<host>/about/confirm#t=<token>`. The token sits after the `#`, so it never reaches a server log or a `Referer`. Opening the page changes nothing (browser test: after a load with a valid token, the row is still pending). The page shows "Confirm your email", one line "Press the button to join the PuhuScribe waitlist." and a "Confirm" button. Pressing it sends `POST /api/waitlist/confirm` with the token. Success: "Thank you. You are on the waitlist." A wrong, used or expired token, or no token: "This link has expired or was already used. Go back to the waitlist to get a new one." with a link to `/about#join`. The script removes the token from the address bar after reading it. **[security]**
12. **Leaving is the same pattern.** `/about/leave#t=<token>` shows "Leave the waitlist", the line "Press the button and we delete your email address from the list." and a "Leave the waitlist" button, which sends `POST /api/waitlist/leave`. Success: "You are off the waitlist. We deleted your email address." A token that no longer matches: "This link does not work any more. If you were already removed, there is nothing more to do. Otherwise write to the contact in the privacy notice." The leave token works for pending and confirmed rows. Browser test checks the row is gone. **[personal data]**
13. **No account, no cookie.** The three `/api/waitlist*` routes never read, set or renew sign in cookies, so a visitor who is also a learner is treated like any visitor, and joining does not touch the learner's account. A learner's email and a waitlist address are never copied into each other (pgTAP, statement 17, and a Vitest check that the routes do not call the learner client). **[personal data]**

### The list and the database

14. **The list table holds an address, two choices and the proof.** `private.waitlist` has exactly these columns: `id uuid`, `email text` (unique, stored in lower case, 3 to 254 characters, one `@`), `paid_interest boolean`, `status text` (`pending` or `confirmed`), `consent_version text`, `consented_at timestamptz` (the database clock), `confirmed_at timestamptz`, `confirm_token_hash bytea`, `confirm_expires_at timestamptz`, `leave_token_hash bytea`, `emails_sent smallint` and `last_email_at timestamptz`. No API role can read or write it. A pgTAP test checks the exact column list from the catalogue, so a later column (an address, a user agent, a referrer, a source, a user id) turns it red. Tokens are stored only as SHA-256 hashes. **[personal data] [security]**
15. **One narrow door adds to the list, and only the Worker may use it.** `public.join_waitlist(p_key text, p_email text, p_paid boolean, p_version text, p_confirm_hash bytea, p_leave_hash bytea)` returns text. It is `security definer`, `search_path = ''`, execute revoked from `public`, `authenticated` and `service_role` and granted to `anon` (the Worker calls it with the publishable key). It compares the SHA-256 of `p_key` with the hash in `private.waitlist_key`. With a wrong key, or no key row, it writes nothing and returns `refused`. With a right key it validates the shapes again (a direct caller skips the Worker), then:
    - a new address is stored as pending and the function returns `send`;
    - a pending address gets its choices and tokens replaced and returns `send`, but at most 3 sends in all and at least 10 minutes apart, otherwise `wait`;
    - a confirmed address changes nothing, not even `paid_interest`, and returns `wait`;
    - when 60 sends were made in the last hour, it stores or leaves the row and returns `wait`, and the cap is counted under a lock so parallel calls cannot beat it.
    The Worker sends the email only on `send`. The result is useful only to a holder of the key, so a direct caller learns nothing about any address. pgTAP proves each branch, that `anon` cannot read the table, that two connections joining the same address make one row, that two parallel calls at the cap send at most the cap, and that a stranger's call cannot flip a confirmed address's choice. **[security] [personal data]**
16. **Confirm and leave act only on a matching token.** `public.confirm_waitlist(p_token text)` and `public.leave_waitlist(p_token text)` (same hardening, `anon` only) hash the token and match the stored hash. Confirm needs a pending row whose token has not expired (48 hours), sets `confirmed`, `confirmed_at` and clears the confirm hash, so the token works once. Leave deletes the row. Both return the same short word for a wrong token whatever the cause. pgTAP covers a right token, a wrong one, an expired one, a used one and a token from another row. **[security]**
17. **Not tied to an account.** `private.waitlist` has no `user_id` and no foreign key to `auth.users` (pgTAP catalogue check), so job 11's catalogue, export and delete tests pass unchanged, and deleting a learner's account neither deletes nor shows any waitlist row. The privacy notice says so (statement 26). **[personal data]**
18. **Old rows delete themselves.** A daily `pg_cron` job deletes pending rows older than 7 days and confirmed rows more than 24 months after `consented_at` (or the figure the owner gives). pgTAP with backdated rows: pending at 6 and 8 days, confirmed at 23 and 25 months. The schedule exists in `cron.job`. No API role can run the job. **[personal data]**
19. **The key is set up by the owner and kept out of files.** The migration creates `private.waitlist_key` empty, so every join is `refused` until a key is set (fails closed; pgTAP). `scripts/waitlist-key.ts` makes a random 32 byte key and prints it for the owner to give to `wrangler secret put WAITLIST_KEY` (a hidden prompt), and prints the one SQL line that stores only its SHA-256 for the owner to run in the Supabase SQL editor. A repository test fails if a key value is in any file. The README gives the steps. The Worker logs no key, address, token or consent value (unit test watching `console`). **[security]**
20. **Every protection is proven by breaking it.** On a scratch branch, remove each of these in turn and watch only its own test go red: the key check, the required shape checks, the pending send limit, the 10 minute gap, the hourly cap, the confirmed row guard, the token expiry, the retention job. Run links are in `build.md`. A test that can pass because another rule also refuses the same call does not count.

### The owner sees the list

21. **One function for the owner, and a route for it.** `public.owner_waitlist()`: `security definer`, `search_path = ''`, no arguments, execute for `authenticated` only. It returns nothing unless `auth.uid()` has a row in `private.owners` and the token's `session_id` is still in `auth.sessions` (job 14's rule, with its own failing test for each condition). It returns `confirmed`, `confirmed_with_paid_interest`, `pending` and `computed_at`, and the newest 200 confirmed rows (`email`, `joined` date, `paid_interest`). `GET /api/owner/waitlist` calls it with the owner's token on the owner host only. Job 14's route list test for the owner host is extended by this one route and no other, never weakened. `owner_dashboard()` is not changed, so job 14's "no email in its text" test stays green. **[security] [personal data]**
22. **A "Waitlist" section on the owner page.** Below "Crashes", `/owner` shows "Waitlist": the three counts, each with one plain sentence ("Confirmed. People who pressed Confirm.", "Confirmed, and might want a paid plan.", "Waiting for confirmation. Joined but not yet confirmed, deleted after 7 days."), then a real table of the newest 200 confirmed addresses with the date and a yes or no for the paid plan. Addresses are plain text and wrap at 375 px (a 254 character address in the test). There is no export, no delete button, no search and no chart. The browser test seeds 3 confirmed (2 with paid interest) and 2 pending, so every count is different and a swapped count turns it red. The pending addresses are never listed. **[personal data]**

### Search and sharing

23. **The head of the page.** The built `about.html` has: `<title>` of at most 60 characters, proposed as "PuhuScribe | Learn the Finnish people actually speak"; one meta description of 70 to 160 characters (proposal below); `<link rel="canonical">` with the absolute live address, taken from the one constant `SITE_ORIGIN` in `src/landing/site.ts`; `<meta name="robots" content="index, follow">`; `lang="en"`; the viewport and `color-scheme` tags as in `index.html`; an SVG favicon made from `design/assets/app-icon.svg`; Open Graph tags `og:title`, `og:description`, `og:type` (`website`), `og:url` (the canonical address), `og:image` (absolute), `og:image:width` 1200, `og:image:height` 630, `og:image:alt` and `og:site_name`; and Twitter tags `twitter:card` (`summary_large_image`), `twitter:title`, `twitter:description`, `twitter:image` and `twitter:image:alt`. No `twitter:site` (no account is named). A repository test parses the built HTML and checks each tag, each length and that every URL is absolute and starts with `SITE_ORIGIN`.
24. **Search engines see the page and not the app's front door.** `index.html` (the app's shell, used by every app page) gains `<meta name="robots" content="noindex, follow">` so search results show `/about`; the confirm and leave pages carry `noindex, nofollow`. `/robots.txt` allows everything except `/api/` and names the sitemap; it does not block app pages, because a blocked page cannot show its `noindex`. `/sitemap.xml` lists the one address `SITE_ORIGIN/about`. Tests read the three built files and fetch them from the local server. Only with owner's call 1 A does `index.html` stay indexable.
25. **The social card.** `/social-card.png` is a 1200 x 630 PNG of at most 300 KB (Facebook's recommended size is at least 1200 x 630 at about 1.91 to 1, and its limit is 8 MB; I could not read X's limits), made by `scripts/build-social-card.ts` from an HTML template that uses only token colours and Poppins, and committed. It shows the wordmark and one line of at least 64 px text, with 7:1 contrast between text and ground computed from the tokens. It shows no Finnish unless owner's call 5c is B. A test reads the PNG header for the size and the file size, fetches it from the local server (200, `image/png`) and checks `og:image` points at it. Real chat previews cannot be checked before the live address exists (statement 31).

### Privacy and shared rules

26. **The privacy notice says it plainly.** `/privacy` gains a "Waitlist" part written from the table below, and `src/privacy/data-inventory.ts` gains a `NOT_LINKED_ITEMS` entry for it, with its keeping time and how to leave (the 14-analytics lesson). `src/privacy/processors.ts` names the email sender (the new module in `worker/providers/` must be listed, or job 11's test fails). The page's consent text and footer link to `/privacy`. The footer shows the responsible name and contact read from `src/privacy/notice-settings.ts` at build time; no address is typed into the page. `PrivacyPage` tests check the new part. **[personal data]**
27. **Job 8's protections cover every new route.** The three new routes accept only `POST` with JSON (405 otherwise) and answer 403 to another site's `Origin`. No answer sends `Access-Control-Allow-Origin`. The routes exist on the app host only (the owner host answers 404 for `/api/waitlist*`). No Supabase secret key or service role key is used. The browser never holds a token for the database or calls a `supabase.co` address. Vitest. **[security]**
28. **Phone, keyboard, accessibility.** For `/about`, `/about/confirm`, `/about/leave` and the owner section, at phone size in both browsers: nothing scrolls sideways at 320 px or with text at 200 percent; every control is at least 44 x 44 (the FAQ summaries and both boxes included); each field has a visible label; everything works by keyboard alone, in reading order, with the focus outline of `design.md`; `@axe-core/playwright` finds no WCAG 2.0 to 2.2 A or AA violation in light or dark mode; every button and the form controls have explicit token colours (the job 5 lesson); a 40 letter word in the status text and in the responsible line wraps (`overflow-wrap: anywhere`). The status line is announced, and focus moves to it after a join, a confirm and a leave.
29. **Light on an older phone.** The page uses no React and no framework: the HTML, one CSS file built from the tokens and one script of at most 10 KB compressed. On a first visit with an empty cache, the bytes sent (HTML, CSS, script, fonts, favicon) are at most 150 KB compressed. In Chromium with a 4 times CPU slowdown and Lighthouse's mobile network settings (as I remember them: 1.6 Mbps down, 150 ms round trip; the builder records the exact numbers used), the largest paint comes within 2.5 seconds, the median of 5 runs (web.dev calls 2.5 seconds or less good). Fonts are served from the app's own address; without the private Switzer files the page falls back to Poppins and the system font and the tests that need Switzer skip with a reason (`docs/fonts.md`).
30. **Records and what stays green.** `docs/data-model.md` describes the table, the four functions, the key and the cleanup. `docs/conventions.md` adds the `[landing N]` row. The README lists the owner setup, the sender steps, the costs and the key script, and states running costs. `src/lib/database.types.ts` is the Supabase CLI's output. The owner page's sentence under "Visits" (job 14, statement 17) changes from "arrival at the app" to "arrival at the app or the public page", with its test updated and not weakened. Every earlier test stays green; `build.md` lists any test changed and why.

### Proven after go live (owner's call 7)

31. **Live check.** Once the live app exists, the owner opens `https://puhuscribe.exentrik.co/about` on a phone, joins with their own address, receives the email, confirms, and sees the address on the owner page. They open the leave link from the same email and see the row go. They share the page link in a chat app and in a social post draft and see the card. Evidence screenshots hide every address. The manager keeps the feature `failing` until this passes, as with jobs 13 and 14.

## The page text (proposal)

English only. The owner changes any of it at the overview. Every sentence follows the writing rules. Words in square brackets are settings, not text.

**Header.** The wordmark. No menu.

**Top.**
- Heading: "Learn the Finnish people actually speak"
- Lead: "PuhuScribe teaches spoken Finnish from your first sentence. You hear a short dialogue, check that you understood it, say it back, and meet the words again when it is time to review them."
- Main button: "Start your first session" (goes to `/`). A quiet link under it: "Join the waitlist" (goes to `#join`).

**Spoken Finnish and written Finnish, side by side.** "Most Finnish courses teach the language of books. Adults in Helsinki talk differently. Every line in PuhuScribe comes in both forms, spoken Finnish (<span lang="fi">puhekieli</span>) and written Finnish (<span lang="fi">kirjakieli</span>), and both have audio. We start with how people talk." If owner's call 5b is B, the approved pair sits here as a spoken band and a written line, labelled "Spoken" and "Written".

**One short dialogue at a time.** "Each session is one short dialogue from a real situation, such as meeting someone new or ordering a coffee. You hear it line by line. Tap any word to see its basic form and why it looks the way it does. Then you say the lines back." Next paragraph: "If you allow it, PuhuScribe listens to you say a line and tells you how close you were, in a gentle way. Your recording is not kept unless you ask us to keep it."

**Words come back when it is time.** "Words you met in a dialogue come back for a short review. The app decides when. You type the word from memory, and there is nothing to rate. There are no streaks and no points."

**Who it is for.** "PuhuScribe is for adults who have moved to Finland and want to speak Finnish with the people around them. It starts from zero, with no placement test, and works toward A1, the first level on the European scale for language skills."

**Join the waitlist** (`id="join"`). "The lessons are free. We are also planning paid plans with longer conversation practice and deeper feedback on how you sound. They are not on sale yet. Join the waitlist and we will email you about new units and about the paid plans." Then the founding member line, only as owner's call 3 decides:
- 3B: "People on the waitlist get a founding member price when the paid plans start. It will be lower than the public price. We tell you the exact price and how long it lasts before you pay anything. Everyone who has confirmed their address before [closing rule] is a founding member."
- 3C: "Planned price: [figure] a month or [figure] a year. Founding members pay [discount] for [period]. The paid plans are not on sale yet, so these figures can still change, and we confirm the final terms in writing before you pay."

Form text. Label: "Email address". Required box: "Email me about new units and the paid plans. I can leave the list at any time." (with 3B or 3C: "Email me about new units and the paid plans, including the founding member offer. I can leave the list at any time.") Optional box: "I might want a paid plan." Under the button: "We use your email only for this. See how we handle it in the privacy notice." and "PuhuScribe is for adults, 18 and over." Button: "Join the waitlist".

Status lines.
- Done, the same for every case: "Thank you. If this address is new to the list, a message is on its way. Press the button in it to confirm. No message after a few minutes? Check your spam folder."
- Could not send (network or 503), in the problem style: "We could not add you just now. Check your internet connection, then try again."
- Only with call 4 B: "Too many tries. Please wait a minute, then try again."

**Questions.** Four questions in native `details` elements, with spacing and no divider lines.
- "Is PuhuScribe really free?" "Yes. The lessons you see in the app are free. Paid plans are planned for later and are not on sale."
- "Do I have to record my voice?" "No. Speaking feedback is your choice. A screen explains what is recorded before you turn it on, and your voice stays in the EU. It is not kept unless you ask us to keep it."
- "What if I already know some Finnish?" "Everyone starts at the beginning, so you can move through the first dialogues quickly."
- "What does the waitlist do?" "We email you about new units and the paid plans, and nothing else. You confirm your address first, and you can leave at any time."

**Footer.** "PuhuScribe is for adults, 18 and over." A "Privacy notice" link. "Responsible for your data: [name from the privacy notice]. Contact: [contact from the privacy notice]." A line naming Exentrik only as owner's call 6 decides.

**Head text (proposal).** Title: "PuhuScribe | Learn the Finnish people actually speak". Description: "Learn spoken Finnish from your first sentence. Short dialogues in spoken and written Finnish, with a chance to say each line back and get feedback." Social description: "Short dialogues in spoken and written Finnish, and a chance to say each line back." Card picture text: "Learn the Finnish people actually speak". Card alt text: "PuhuScribe wordmark and the line Learn the Finnish people actually speak."

**The confirmation email.** Subject as in statement 10. Body: "You asked to join the PuhuScribe waitlist. To finish, open this link and press Confirm. It works for 48 hours. [confirm link] If you did not ask for this, ignore this email. We delete the address within 7 days. You can leave the list at any time with this link. [leave link] PuhuScribe is run by [responsible name]. Contact: [contact]." Sent from `<sending address on the owner's domain>`, name "PuhuScribe", reply to `<owner's contact email>`.

## Claims table

Each claim on the page and what makes it true. The evaluator checks every row at the end of the build and again at go live.

| Claim on the page | What makes it true | Checked against |
|---|---|---|
| Teaches spoken Finnish from the first sentence | Spoken Finnish is shown first in every dialogue | Job 8's screens |
| You hear a dialogue, check you understood it, say it back, and meet the words again in review | Hear it, Understand it, Say it and Keep it are built (jobs 8 to 10 and 9). Use it (the tutor) is not mentioned | The running app |
| Both forms have audio | Every approved line has both audio files | Published content; the reviewer has approved it before anything is served |
| Tap any word to see its basic form and why | The word card | Job 8 |
| Speaking feedback is optional; the recording is not kept unless asked; the voice stays in the EU | Job 10's consent screen and defaults; Azure EU | The voice settings screen at go live |
| Review is scheduled by the app, typed, nothing to rate, no streaks or points | Job 9 | The running app |
| Starts from zero with no placement test, works toward A1 | PRD section 4.1 | PRD |
| The lessons are free | The PRD says the loop is never gated. This is also a promise | Owner confirms at approval |
| Paid plans are planned and not on sale | Payments are v3.1 | Scope, "Deferred" |
| For adults, 18 and over | PRD section 10 | Job 8's front door line |
| The first situations include meeting someone and ordering a coffee | Units 1 and 2 | Published at go live |

The page does not say how many units exist, does not name the tutor and gives no learner numbers. Units 1 to 3 are drafted and wait for the reviewer's batch, and units 4 to 6 and the tutor step are not built.

## Privacy notice facts

The builder writes the notice text from these facts only. The owner approves the wording at final approval.

| Topic | Fact for the notice | Source |
|---|---|---|
| Waitlist | Your email address; whether you ticked "I might want a paid plan"; the time you joined; which version of the wording you saw; whether you confirmed and when; and two random codes kept in a form that cannot be turned back into the codes, so the links in our email work. Nothing else: no name, no address of your device, no browser details, no cookie. | This job |
| Why | To email you about new units and the paid plans, including any founding member offer, once you confirm. We use it for nothing else and send no newsletter. | This job |
| Legal reason | Your consent (GDPR Article 6(1)(a)). You can withdraw it at any time, as easily as you gave it. | GDPR Art. 7 |
| Not linked to an account | The waitlist is separate from learner accounts. Deleting your account does not change it, and joining it does not create an account. | This job |
| How long | A pending address is deleted after 7 days. A confirmed address is kept until you leave or 24 months after you joined, whichever is first (the owner may change this). | This job; owner input |
| How to leave or have it deleted | Every email we send has a link that removes you at once. You can also write to the contact in this notice. We answer within one month. | This job; job 11 |
| Who sends the email | The sender the owner chooses (name and location added when chosen). It receives your address and our message. | Owner's call 2 |
| Where the list is | Supabase, EU (Ireland), as for accounts | Job 11 |
| Visit count | Opening the page adds one to the daily country count, as for the app (job 14's entry applies). Cloudflare, which delivers the page, sees your internet address as with any page. | Job 14 |
| Cookies | The page sets none and stores nothing on your device. | This job |
| Under 18 | The page is for adults. | PRD section 10 |

## Threat model (GA)

**What is the worst a malicious person could do here?**
- Find out whether a named person is on the list. That matters: the audience is people who recently moved to Finland, and a list of them is sensitive context. Every answer to the visitor is the same (statement 8), the database result is useful only to the Worker's key holder (statement 15), and the table cannot be read by any API role (statement 14).
- Fill the list with other people's addresses and flood an inbox with our email. Each address can receive at most 3 emails and one every 10 minutes, the page sends at most 60 an hour, a confirmed address gets none, and the email holds no text the visitor typed (statements 10, 15). A patient attacker can still use up the 60 an hour and delay real confirmations; accepted and shown on the owner page. Owner's call 4 covers stronger options.
- Use us as a spam relay. There is no free text field, the recipient is the typed address only, and the message is fixed (statement 10).
- Read or scrape the list. Only the owner function returns addresses, behind job 14's three locks (statements 21, 22). The key guard stops direct callers from the public database address.
- Confirm or remove someone else's entry. Needs a 256 bit token from that person's inbox. Pages that act need a button press, so a mail scanner that opens links changes nothing (statements 11, 12).
- Cross site tricks. JSON only, `Origin` check, no cookies involved, no `Access-Control-Allow-Origin` (statement 27). Text from the visitor appears only as plain text on the owner page (statement 22).
- Use up the Workers Free limit of 100,000 requests a day with page loads. Possible for any public page; the same limit as job 14's note. Past it, Cloudflare stops the Worker (error 1027) unless it is set to fail open (unverified).
- Fake the consent. The boxes are unticked and the database refuses a join without the version label; but a bot can tick boxes. The confirmation step is the proof that a human with that inbox agreed.

**What data are we storing that we must protect?**
- Email addresses of people interested in learning Finnish, with consent proof and a paid plan interest flag.
- Token hashes and the key hash, which let the links and the Worker's door work.
- Nothing about the device, place or time of day of a visit beyond job 14's country tally.

**What must the system refuse even if asked nicely?**
- Showing or hinting that an address is, or is not, on the list, to anyone but the owner.
- Storing an address without the required box, or with a box pre ticked.
- Sending any email other than the confirmation (a later job sends announcements, only to confirmed addresses, each with a leave link).
- Storing a device address, user agent, referrer, source or cookie with a signup.
- Using the list for a newsletter or anything beyond what the notice says without a new, separate yes.
- Showing the list to anyone but the owner, or exporting it.
- Using a Supabase secret key or service role key, or putting the Worker key in a file or log.
- Showing a price, a deadline or a scarcity claim that is not real.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | Where the page lives | `/about` on the app address (owner's call 1, recommended) | The main address with the app moving to `/today` | It moves the front door that `15-onboarding` and the installable app job both build on, in the same weeks |
| 2 | How the page is built | Plain HTML files (`about.html`, `about/confirm.html`, `about/leave.html`) built by Vite as extra entries, with the tokens CSS and one small script | A React page in the app, with the Worker rewriting its head tags | Chat apps and some search engines read the HTML the server sends. A React page sends an empty shell, so the card and the text would be missing until a script runs. Rewriting the head in the Worker adds code that must stay in step with the page, and the page would carry the app's bundle. A separate site tool (Astro, for example) lost for adding a second build system for three pages. Cost: the page cannot reuse the React `Button`, so its CSS repeats the button look from tokens, and the existing design tests must cover that CSS file (the builder checks, and extends them without weakening) |
| 3 | File names under Cloudflare's asset rules | `about.html` for `/about` (Cloudflare's default serves `/about` from `about.html` without a redirect) | `about/index.html` | By Cloudflare's docs the default would then redirect `/about` to `/about/`, which splits the address Google sees |
| 4 | How the database knows a join came from the Worker | A random key held as a Worker secret, with only its SHA-256 stored in the database | Leave the function open to `anon`, as job 14's `count_visit` is | The Worker needs a result to decide whether to send email, and an open function would give that same result to anyone with the public database key. They could test any address. They could also fill the table directly. A Supabase secret key was also ruled out (jobs 1, 2, 8, 11) |
| 5 | How an address is confirmed | A link to a page with a Confirm button, token in the `#` part of the address | A link that confirms when opened; or a 6 digit code typed on the page | A link that acts can be used up by mail scanners (Supabase's email page, in job 11's sources). A code makes a phone user leave the mail app, find the page again and type it; for a casual waitlist that loses sign ups. The `#` part never reaches a server log or `Referer`; a `?` query would |
| 6 | The leave token | Computed by the Worker as an HMAC of the address with the key, stored only as a hash | A random token stored in plain text | A later announcement must re-create the leave link without the database holding a usable secret. Storing it plain would let a database leak remove everyone |
| 7 | Consent shape | One required box with a narrow purpose, one optional preference box, nothing pre ticked, no newsletter box | One box covering "updates and offers"; or the "existing customer" exception | Bundled consent is the pattern Article 7(2) warns about. The exception needs a purchase, and nobody has bought anything (KKV page) |
| 8 | How the owner sees the list | A "Waitlist" section on the owner page, behind job 14's three locks | Opening the table in Supabase's dashboard; or a weekly email of new sign ups | The dashboard needs your database login each time and shows every table, so one slip touches learner data. A digest needs the email sender and puts addresses in an inbox |
| 9 | Counting landing visits | Into job 14's one tally (the route is Worker first, so it counts) | A separate tally with a page column | Job 14 locked the table's columns by test. Cost: landing and app visits are one number, so joins per visit is approximate |
| 10 | The social card file | A PNG made by a script and committed | An image made on request by the Worker | A Worker would need an image library and spend its 10 ms of CPU on every share. One page needs one file |
| 11 | Email provider | Not chosen here; one module, `worker/providers/waitlist-email.ts`, with a fake for tests (owner's call 2) | Choosing now | Real prices, regions and a sending domain are yours to pick, shared with job 11's open call |
| 12 | Retention | Pending 7 days, confirmed 24 months (owner input) | Until the owner deletes | GDPR's storage limit idea; reuses job 11's 24 months |

New npm packages: none expected. New database extension: none (`pg_cron` is already on from job 11, and SHA-256 is built into Postgres).

**Notes for the builder.**
1. Cloudflare's docs describe `html_handling` for `about.html` and `about/index.html` but not both in one build. Use only `about.html`, and test status 200 with no redirect for the three addresses (`redirect: 'manual'`). Record in `build.md` how `run_worker_first` `/about` behaves with the default setting.
2. Confirm that the Cloudflare Vite plugin builds extra HTML entries (`build.rollupOptions.input`) and that the files land in `dist/` unchanged. Record it.
3. The Workers rate limit binding needs Wrangler 4.36.0 or later, if owner's call 4 is B.
4. Postgres grants `EXECUTE` on new functions to `public` by default. Revoke it in writing for each of the four new functions.
5. The consent version label: store the SHA-256 of the two consent sentences next to each label in a test file, and fail if the text changes under an old label.
6. Link origin in the email comes from a Worker variable, `WAITLIST_LINK_ORIGIN` (live: `https://puhuscribe.exentrik.co`), never from the request's own Host. Other new Worker settings: `WAITLIST_KEY` (secret), the sender's settings (named when the provider is chosen), and `WAITLIST_EMAIL_PROVIDER=fake` locally only. The fake must be impossible to select on a live host (repository test).
7. Coordinate the migration timestamp with any open job through the manager.

## Contract notes for other jobs

1. **Onboarding (`15-onboarding`)**: this job does not change `/` or the front door. The page's main button goes to `/`. If the welcome wants a link back to the page, it uses `/about`. With owner's call 1 A, the welcome moves to `/today` and the manager sequences the two jobs.
2. **Tutor step (`16-tutor-step`)**: the page names no tutor feature. If the tutor ships before the page goes public, the owner may add one sentence, which goes through the claims table.
3. **Installable app (scope item 16)**: its service worker must leave `/about`, `/about/confirm` and `/about/leave` to the network, or arrivals are not counted and updates to the page are hidden. The manifest's `start_url` is `/`. It uses `design/assets/app-icon.svg` for icons; this job adds only the SVG favicon.
4. **Analytics (14)**: the landing page is counted by the existing tally, and the owner page's sentence under "Visits" is updated (statement 30).
5. **Accounts (11)**: the email sender chosen for job 11's call 1 serves this job too. The notice's responsible name and contact (`notice-settings.ts`) are reused, never retyped.
6. **A later announcement job** (not in v3.0 scope): sends only to confirmed addresses, each message carrying the leave link, with the sender and key from this job.
7. **Go live**: attach `puhuscribe.exentrik.co`; set `WAITLIST_KEY`, `WAITLIST_LINK_ORIGIN` and the sender's settings on the production Worker; run the key SQL line on the live project; add the sender's DNS records; switch off `workers_dev` on the production Worker, so the page has one public address and no duplicate on a `workers.dev` address; check statement 31; submit the sitemap to search engines if the owner wishes.

## Banned looks, and how this page avoids each

| Easy drift on a landing page | How this page avoids it |
|---|---|
| Three feature cards in a row, identical card grids | The sections are headings with a paragraph each, in one column. The only box is the form |
| Numbered steps (01, 02, 03) | The loop is told in one sentence. No numbering |
| Stat tiles and big numbers | No numbers on the page unless the owner gives real founding figures |
| Gradient hero, purple to blue, glow, glass, gradient text | The hero is text on the page's own lilac fade, the one gradient `design.md` allows |
| Eyebrow labels | Headings only. No small uppercase labels |
| Hairline rows | The FAQ uses spacing and bold questions, with no dividers |
| Accent borders, pills everywhere | The only pills are the buttons. No coloured edge on a box |
| Icons and emoji sprinkled in | No icons outside controls, no emoji |
| Cream with serif and terracotta, near black with neon | The locked palette. Violet and teal appear only if the register pair is shown, as in the app |
| Inter, Space Grotesk, Bricolage Grotesque | Poppins and Switzer, as `design.md` |
| Fake urgency and social proof | No countdown, no "N joined", no testimonials, no press logos |

The existing banned look tests (`tests/design-css.test.ts`, `tests/design-tokens.test.ts`) must cover the new CSS. If a glob misses it, the builder extends the glob and says so in `build.md`.

## Out of scope

- Going live: the production Worker, hostnames, DNS, the live database and the key on the live project (owner's call 7).
- Sending announcements, newsletters or any email other than the confirmation. A later job.
- Payments, prices pages, checkout and any paid tier. The page promises none of it beyond what owner's call 3 allows.
- Referral loops, queue positions, counters, countdowns, testimonials, press logos, a blog, video, audio on the page, a chat widget.
- Tracking of any kind beyond job 14's country tally: no sources, no campaign tags, no A/B tests, no outside counter, no pixel, no cookie banner (nothing is set).
- Turnstile, unless owner's call 4 is C, and job 8's launch decision.
- Importing fair sign ups.
- A Finnish version of the page, a language toggle (on the PRD's "Not in v3.0" list for the app, and not wanted here), JSON-LD structured data, Search Console setup.
- A QR code maker. The owner can make a QR code of the page address with any tool.
- Changes to `/`, the front door, onboarding or the tutor step.
- From the "Not in v3.0" list: no Day One Sprint front door, no vocabulary bank, no four modes, no grammar lessons, no sentence bank page, no standalone tutor, no rank titles, confetti or milestones, no mnemonics, no YKI, no store builds, no Owner Insights beyond the list the scope asks for. No streaks.

## Build plan

1. **The look overview, before any screen.** One plain page, `factory/jobs/17-landing-page/overview/landing-look.html`, made with the real tokens and not shipped. It names each picture: 1 the top of the page at 375 px with my headline and v2's; 2 the "spoken and written" section with and without the approved pair; 3 the form in each state (empty, error, joining, done, problem); 4 the confirm and leave pages; 5 the social card at 1200 x 630 and how it would look small in a chat; 6 the owner page's Waitlist section; 7 the proposed email. It says how the pieces fit. The manager shows it to you with calls 1 to 7. Nothing else is built until you answer.
2. **Database.** One migration: `private.waitlist`, `private.waitlist_key`, the four functions, the cleanup job, grants and revokes written out. pgTAP, the scratch red runs, regenerated types, `scripts/waitlist-key.ts`. Covers 14 to 21 (database part) and 17, 18, 19, 20.
3. **Worker.** The three routes, the email module and its fake, the caps and trap checks, the owner route, quiet logs, `PAGE_ROUTES` and `wrangler.jsonc`, `robots.txt` and `sitemap.xml`. Vitest with fakes. Covers 1, 2, 8 to 13, 21, 24, 27.
4. **Pages and owner section.** The three HTML pages with CSS and script, head tags, the social card script and file, the privacy notice and processors updates, the `index.html` noindex, the owner page section and the updated visits sentence. Covers 3, 5, 7, 22, 23, 25, 26, 28, 29, 30.
5. **Browser tests and records.** Journeys in both browsers (join, confirm, leave, the same answer for a repeat, no outside request, no cookie), accessibility, performance, the owner section with known values, docs and README. Covers 1, 2, 6, 7, 11, 12, 22, 28 to 30.

**Dependencies.**
- Job 14 merged (done 30 October 2026) and job 11 merged.
- The email sender and its DNS records, chosen under owner's call 2, before the page goes public. Until then the tests use the fake sender, and no real email is sent from any test.
- Preview links still wait for the Cloudflare preview keys (todo, 29 October). Until then the evaluator runs the page locally. Previews sit behind Cloudflare Access, so the form works there, but real email and real social card checks wait for the live address.
- The live app address and live database (go live job), for statement 31.
- The native reviewer's answer on the two glossary words (and the pair, if 5b is B) before the page is public.
- The font key (`FONTS_DEPLOY_KEY`) for Switzer, or the tests that need it skip with a reason.

## Risks and flags

- **Look closely: learner data and consent.** A new list of addresses of people moving to Finland, with consent proof and a paid plan flag. Statements 7 to 20 and the threat model are the protection. The notice must be right before go live.
- **Look closely: database and access rules.** Three functions callable by `anon` (one of them key guarded) and one `security definer` function that reads addresses for the owner. The pgTAP tests and the scratch red runs (statement 20) are the main protection.
- **Look closely: a new processor and possibly a paid service.** The email sender receives every confirmed address. It is named in the notice and chosen by you (owner's call 2). Cost depends on the pick: €0 on free plans, or $5 a month for Cloudflare's Workers Paid.
- **Look closely: Finnish content.** Two glossary words on the page, and an approved pair if you choose 5b B. They go to the native reviewer. Nothing unapproved is served.
- **Legal reading.** The consent design follows the Finnish consumer authority's page (consent needed for email marketing, no pre ticked boxes) and GDPR Articles 7 and 21. The founding member wording follows the EU's rules on false offers. This is not legal advice. Before going public, a privacy and marketing professional should read the page, the notice and the offer, as jobs 11 and 14 already suggested.
- **Promises.** "The lessons are free" and any founding member offer are promises you must keep. Do not publish a deadline or a limit you will not enforce.
- **The controller's name.** The notice names you personally today. If the company owns the product, owner's call 6 C is the fix.
- **Running costs.** Page, database and cleanup €0. Page loads and the form count toward Workers Free's 100,000 requests a day. A sender: €0 on free plans within their limits (Resend free: 3,000 a month and 100 a day), or $5 a month plus $0.35 per 1,000 above 3,000 on Cloudflare. At the PRD's 150 sign ups, mail volume is tiny.
- **Visits are mixed.** Landing and app visits share one number on the owner page (Decision 9).
- **Owner page grows.** The owner page now shows addresses. It stays behind three locks and has no export, consistent with job 14's rule. The PRD's limit on an Owner Insights dashboard is respected: a list and three counts, no charts or funnels.
- **Fair sign ups.** If they exist elsewhere, they stay outside this list until their consent is shown.
- **GA.** The job is done only when `summary.md` records the owner's own written "approved" line with the date.

## Could not verify

- **v2's landing page.** It is drawn by script and I could read only its title. Duolingo's page, the same. The builder opens v2's page in a browser for the overview.
- **Award galleries.** Awwwards' education and language lists gave names only (no language app among them). Land-book returned 403. Godly redirected to recent.design, which gave titles only. SiteInspire gave names and dates. So the references above are real brand pages I opened, plus one Awwwards listed tutor and one Godly feed entry. The waitlist examples come from a vendor's blog, not the pages.
- **Email prices.** Brevo's price page could not be read and Scaleway's returned 403 today. Resend's price figures are from its page; where its data is stored was not confirmed. Cloudflare Email Service: the docs say Workers Paid is needed for any recipient and give $0.35 per 1,000 after 3,000; they do not say whether it is in beta, and a search found one source saying April 2026 beta and another saying July 2026 private beta. Whether it can also act as SMTP for Supabase (job 11) was not checked.
- **Workers rate limit binding.** Plans and cost are not stated in its docs. **Turnstile.** I read its plans page only; whether it stores anything on the device, and what the notice would need to say, was not checked.
- **Finnish law text.** The English text of section 200 of Act 917/2014 (electronic direct marketing) could not be read (the Finlex file would not open as text, and the Finnish page was cut off). I rely on the consumer authority's page and on a summary naming Chapter 24, sections 200 to 202. I did not open the ePrivacy Directive's Article 13. Whether a founding price must be shown with VAT, and the Consumer Protection Act's section numbers, were not checked. The Data Protection Ombudsman's site returned an error (as in job 11).
- **EU directive text.** I read Annex I points 5, 7 and 20 on the legislation.gov.uk copy of the adopted directive, not on EUR-Lex.
- **Social card limits.** X's pages returned errors, so its image limits are unverified. Facebook's page gave 1200 x 630, 1.91 to 1, 8 MB.
- **Cloudflare asset behaviour.** The `html_handling` table is from the docs; the exact interaction with `run_worker_first` `/about`, and whether the Vite plugin builds extra HTML entries, are for the builder to confirm.
- **Lighthouse numbers** in statement 29 are from memory; the builder records the real settings.
- **Fair results.** Whether the PRD's price hypothesis was tested, and how fair sign ups were collected, are not in the files I read.
- **Provider tracking.** Whether every sender lets open and click tracking be switched off per message or per domain was not checked.
- **Workers Free over the limit.** Whether it fails open or closed was not verified (same as job 14).

## Sources

- PRD sections 0, 2, 3, 4.1, 6, 10, 11, 13 and 14: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`
- Project: `AGENTS.md`, `docs/scope/scope.md` item 15 and "Deferred", `docs/factory-and-risk-tests-plan.md` decisions 8 and 9, `factory/todo.md` (job 8 launch decision), `factory/jobs/14-analytics/spec.md` (contract note 2, owner's call 2), `factory/jobs/11-accounts/spec.md`, `factory/jobs/12-units-1-3/spec.md` (content waits for the reviewer), `factory/jobs/13-review-site/spec.md`, `design.md`, `design/brief.md`, `design/assets/README.md`, `design/v2-handoff/README.md`, `src/App.tsx`, `src/main.tsx`, `src/screens/FrontDoor.tsx`, `src/screens/OwnerPage.tsx`, `src/privacy/`, `worker/index.ts`, `worker/http.ts`, `worker/feedback.ts`, `worker/page-routes.ts`, `wrangler.jsonc`, `index.html`, `vite.config.ts`
- Brand notes (read only): `C:/Users/fumna/dev/exentrik-os/context/brand-voice.md`, `context/exentrik.md`, `brand/README.md`
- Finnish consumer authority, inappropriate direct marketing (consent, pre ticked boxes, the customer exception): https://www.kkv.fi/en/consumer-affairs/marketing-sales-and-indicating-prices/direct-marketing/inappropriate-direct-marketing/
- Finnish Act on Electronic Communications Services 917/2014, English translation (text not read): https://www.finlex.fi/en/legislation/translations/2014/eng/917
- GDPR Article 7 (conditions for consent): https://gdpr-info.eu/art-7-gdpr/
- GDPR Article 21 (right to object to direct marketing): https://gdpr-info.eu/art-21-gdpr/
- Unfair Commercial Practices Directive, Annex I (points 5, 7, 20), legislation.gov.uk copy: https://www.legislation.gov.uk/eudr/2005/29/annex/I/adopted
- Cloudflare Email Service pricing: https://developers.cloudflare.com/email-service/platform/pricing/
- Cloudflare Workers pricing (Paid $5 a month, Free 100,000 requests a day): https://developers.cloudflare.com/workers/platform/pricing/
- Cloudflare Turnstile plans: https://developers.cloudflare.com/turnstile/plans/
- Cloudflare Workers Rate Limiting binding: https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/
- Cloudflare static assets `html_handling`: https://developers.cloudflare.com/workers/static-assets/routing/advanced/html-handling/
- Resend pricing: https://resend.com/pricing.md
- Open Graph protocol: https://ogp.me/
- Facebook sharing image guidance: https://developers.facebook.com/docs/sharing/webmasters/images/
- Google, snippets and meta descriptions: https://developers.google.com/search/docs/appearance/snippet
- Google, canonical URLs and `noindex` versus robots.txt: https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls
- web.dev, Largest Contentful Paint thresholds: https://web.dev/articles/lcp
- References opened on 30 October 2026: https://www.memrise.com/, https://www.speak.com/, https://www.babbel.com/, https://www.busuu.com/, https://www.lingoda.com/en/, https://www.pimsleur.com/, https://senthora.ai, https://recent.design/i/1u0n947-halden-app-website, https://www.awwwards.com/websites/education/, https://www.siteinspire.com/websites/categories/education
- Waitlist examples (vendor blog, pages not opened): https://getlaunchlist.com/blog/waitlist-landing-page-examples-that-convert
- v2's landing page (title only): https://puhuscribe-v2.vercel.app/landing

Result: ready for owner approval
