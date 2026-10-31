# Specs waiting for you (written 30 October 2026)

Three specs are ready for your approval. They are written for jobs 15, 16 and 17. Nothing is built yet. Each job waits for your answers below before its builder starts.

**How to answer.** Reply in this session, from your phone. Short answers work, for example "15: all recommended" or "16: call 1 B, rest recommended". I record your words here with the date and push them.

**Checked against.** The PRD (`exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md`), `AGENTS.md`, the scope and the specs of jobs 8 to 14. I read every spec as the factory manager would. None needed to go back to the writer. In spec 17 I removed one stray label at the end of statement 23 myself. It meant nothing and changed nothing else.

**Calls that touch more than one job.**
- The email sender. Job 11 left it open, and job 17's waitlist needs it too. One choice serves both.
- Protection against fake guest accounts (job 8's launch decision). Job 16 limits Otso to email accounts until you choose it, and job 17's call 4 points to the same choice.
- The welcome (job 15) stays on the app's front door at `/`, as long as you pick `/about` for the landing page (job 17, call 1).

---

## Job 15: Onboarding (scope item 13)

Full spec: `factory/jobs/15-onboarding/spec.md`. Not GA. Cost €0.

**In five lines**
1. A new visitor sees a short welcome (73 words) on the front door, right above Start.
2. It says what a session is. Two plain bands, "Spoken" and "Written", show what the two forms of Finnish mean here.
3. One tap on Start opens the first dialogue line. Nothing is asked, so there is no quiz or level question, and everyone starts at the beginning.
4. Only people with no account on that phone see it. Nothing new is stored, so the privacy notice does not change.
5. Whether people really understand it is tested by you with 5 adults and a stopwatch, about 40 minutes.

**Done when**
1. The welcome sits between the front door's opening sentence and Start, in a fixed order.
2. Its words are exactly the approved draft, 80 words at most, and they follow the writing rules.
3. The Spoken and Written bands use the same colours as the Hear it screen, in light and dark mode.
4. It has no buttons, links, questions or Finnish of its own.
5. Only new visitors see it. Returning learners, email accounts and signed out notices do not.
6. It never flashes up for a returning learner, and it still works when the network fails.
7. Nothing is stored on the phone or in the database, and no new route, table or setting is added.
8. One tap on Start reaches the first dialogue line, within 10 seconds on the test setup.
9. Start and the age line fit on a 375 x 812 phone screen without scrolling.
10. Keyboard, screen readers, large text and dark mode all work, with no accessibility errors.
11. The design rules and the banned looks list hold.
12. The hallway test with 5 adults passes. You run it with a script and sheet the builder writes.
13. Records are updated and every earlier test stays green.

**Your calls**

1. *How should the welcome appear?*
   - A. One block on the front door, above Start (recommended). Nothing that works today changes.
   - B. Two screens on their own page with Skip. Bigger text, but one or two more taps, and 32 test openings to update.
   - C. No welcome. The explanation goes inside the first Hear it step instead.

2. *What should it look like?*
   - A. The existing design only, with no new pictures (recommended). Costs nothing.
   - B. One drawn picture. Needs an illustrator or generated art, and you see an overview page first.

3. *How is the "18 and over" rule shown?*
   - A. Keep the existing line right under Start (recommended). No extra tap, no data.
   - B. A tick box "I am 18 or older" before Start works. One more tap at the moment speed matters.
   - C. Ask for an age or birth year. Collects personal data, and a child can type any number. Not recommended.

4. *When does the hallway test happen?*
   - A. After the build and before you approve (recommended). The job waits for your filled sheet.
   - B. Approve on the automatic checks, run the test during your two weeks of daily use.
   - C. An AI reads the welcome instead. Cheap, but it tells us nothing about real people.
   - The proposed pass bar is 4 of 5 people reaching the first line within 60 seconds, and 4 of 5 explaining both forms correctly. You can change it.

5. *Any Finnish in the welcome?*
   - A. None (recommended). Nothing goes to the native reviewer.
   - B. The two names, puhekieli and kirjakieli. They go to the reviewer.
   - C. A Finnish example pair. It is new Finnish, and visitors without an account cannot see approved lines yet. Not recommended.

**What I need from you (not choices)**
- Approve the welcome wording at final approval. You may swap in v2's line "Books teach one Finnish. The street speaks another."
- 5 adults and about 40 minutes for the hallway test, plus a link that opens on a phone. That link waits for the Cloudflare preview keys or the go live job.

---

## Job 16: Tutor step, Use it with Otso (scope item 12)

Full spec: `factory/jobs/16-tutor-step/spec.md`. GA, so you approve the spec now and write "approved" at the end.

**In five lines**
1. From unit 4, a session ends with a short typed chat with Otso. He opens with a line from today's dialogue, then three replies each way. He may end with one tip, which is always a line your reviewer approved.
2. Code checks every Otso reply before the learner sees it. Each word must be a form the learner has met. A reply that fails is tried twice more, then replaced by an approved line.
3. The AI never grades, never schedules reviews, and nothing typed in the chat is stored anywhere. Only a cost line per AI call is kept, and the owner page already adds it up.
4. This is a new paid service and a new company that sees what learners type. With the small model it costs about €0.06 per active learner a month (€6 for 100 learners). A database spending cap stops all Otso calls when it is reached.
5. Units 4 to 6 are not built yet. The job is built and tested on test units with a fake AI. The real quality check runs once you set up the AI account, and the check on real unit 4 waits for scope item 11.

**Done when**
1. Use it appears as the last step only from unit 4, and only when the AI is set up, the learner agreed, and they are under the day's limit.
2. There is no Otso page or menu. It exists only inside the loop.
3. Finishing or skipping the step is saved, and coming back resumes correctly.
4. If the AI is down or a limit is reached, a kind line shows and the session carries on.
5. The learner agrees before the first message, on a plain screen that says what is sent, where it goes, and what is kept.
6. Turning Otso off on the account page is one tap and works at once.
7. The exchange has a fixed shape: an approved opening, three replies, a closing line.
8. The learner types up to 120 characters, with ä and ö buttons. Double taps send once.
9. AI lines are marked "Made by AI. Not checked by a person." Approved lines are marked differently. Tapping a word opens its approved card.
10. At most one tip, which the AI picks from a list of approved lines. It never writes one.
11. Nothing is graded. No score, no "wrong", and no review card or log is created from the chat.
12. Every word Otso shows is a form the learner met, checked in code without Voikko.
13. A phrase rule also checks that neighbouring words appeared together in an approved line. Its strictness is one number you approve.
14. A reply that fails is retried twice, then replaced by an approved line. The failed text never reaches the learner.
15. The optional English meaning is short, plain and labelled as AI.
16. The AI never receives the learner's id, email, name or address.
17. Every refusal (no sign in, no consent, wrong session, too long, too many) happens before any AI call.
18. Twelve hostile messages, such as "ignore your rules", cannot get an unmet word on screen.
19. Limits and the spending cap are enforced in the database before each call, and parallel requests cannot beat them.
20. Cost attacks such as parallel requests, long texts and replays stop early.
21. Logs hold nothing from the chat, and the AI keys stay secret.
22. One new table holds a cost line per AI call, with no text, under strict access rules.
23. Nothing the learner typed or Otso said is stored on the phone, in the database, or in crash reports.
24. The new table is in the learner's data download, is deleted with the account, and shows on the owner page's cost line.
25. The AI company is named in the privacy notice's processor list.
26. All AI calls go through one module, with a fake for tests.
27. Only EU regions are allowed, and no model that keeps conversations is used.
28. A 100 reply quality check is built and proved on the fake.
29. On the real model, at least 97 percent of words stay within met forms. Waits for your call 1 and the AI key.
30. Hostile replies and a second, Voikko based reading are reported alongside.
31. The check is rerun on real units 4 to 6. Waits for scope item 11.
32. Phone, keyboard and accessibility checks pass.
33. Records and costs are documented.
34. Otso looks exactly as you choose in call 4, and nothing more.

**Your calls**

1. *Which AI company writes Otso's lines, and where?* This is a new paid service. The house rule says learner data stays in the EU.
   - A. Claude through Amazon's Bedrock service in an EU region (recommended). You need a new AWS account with a card, about 30 to 45 minutes of setup. The small model is tried first, and the larger one only if the small one fails the quality check.
   - B. Anthropic's own service, with the key you already use for drafting. No new account, but it processes in the US or worldwide, which breaks the EU rule for typed text.
   - C. Microsoft's Azure in an EU zone. Microsoft is already in the notice for speech. Prices could not be read.
   - D. Mistral, a French company. Finnish quality and data terms are unknown.
   - Monthly cost with option A, each learner using it once a day: 10 learners about €0.60, 100 about €6, 1,000 about €57 with the small model. The larger model costs about 20 times that. Amazon's own EU prices could not be read, so these use Anthropic's list prices plus the 10 percent EU surcharge Anthropic states.

2. *Who writes Otso's Finnish?* This is the trust call. Every word being one the learner met does not make the sentence good Finnish.
   - A. The AI writes freely, inside the word check. Most natural, but no person reads it.
   - B. Approved lines only. Nothing wrong can show, but it feels scripted, needs new reviewed content, and sends the spec back for a rewrite.
   - C. The AI writes freely, plus the phrase rule (recommended). It starts strict, and your reviewer reads 30 sample lines (about 20 minutes) before launch. The quality check shows how often each strictness level falls back to an approved line, so you choose with numbers.

3. *How does the learner answer?*
   - A. Typed (recommended).
   - B. Typed or spoken. About €0.13 more per learner a month, a new consent from everyone, and wrong transcripts can confuse Otso.
   - C. Tap one of a few approved replies. Nothing typed leaves the phone, but it is a menu, and less real speaking practice.

4. *Otso's look, voice and tone.* The name is fixed by the PRD.
   - Look: A. name only (recommended), B. name and a small flat bear mark, C. a portrait or animated avatar. B and C start with an overview page for you.
   - Voice for AI lines: A. none for now (recommended; the opening and tip still have audio), B. the phone's own voice, C. Azure voice at about €0.06 per learner a month.
   - Tone: warm, patient, short sentences, never says the learner is wrong. A playful tone is one line to change.
   - The spec calls Otso "he". Tell me if you want otherwise.
   - No audio on AI lines and no written line under them is the weakest fit with principle 5 (both registers with audio). The spec flags it. Tapping any word still shows both registers.

5. *Limits and who may use it.*
   - Chats per learner per day: 1, 2 (recommended) or 5.
   - Who: everyone, or email accounts only until the fake account decision is made (recommended).
   - Monthly spending cap for everyone: €10 (recommended for testing, about 175 daily learners), €50 or €150. You raise it with one database line.

**Decided in the spec, for you to check.** Consent before first use, following the voice consent pattern. A fixed three reply chat. No written Finnish line under Otso's replies. An AI English meaning behind a tap, labelled as AI.

**What I need from you (not choices)**
- The AWS account steps, if you pick call 1 A. The builder writes click steps. Keys go straight into secrets, never into chat.

---

## Job 17: Landing page and waitlist (scope item 15)

Full spec: `factory/jobs/17-landing-page/spec.md`. Public, so treated as GA. You approve the spec now and write "approved" at the end.

**In five lines**
1. A public page explains PuhuScribe in plain English, with search details and a social card (the picture shown when the link is shared). Recommended address: `puhuscribe.exentrik.co/about`.
2. A visitor types an email, ticks one unticked box to agree, and may tick "I might want a paid plan". One email with a Confirm button proves the address is theirs, and every email has a leave link.
3. The page never reveals whether an address is already on the list. Unconfirmed addresses delete themselves after 7 days. Confirmed ones are kept for 24 months unless you choose otherwise.
4. You see the counts and confirmed addresses in a new "Waitlist" section of your private owner page. There is no export.
5. The page and database cost €0. The confirmation email needs a sender. Nothing goes public in this job; publishing waits for the go live job.

**Done when**
1. The page is real HTML at its own address, readable with scripts off, and counted like any app visit.
2. No cookie, no device storage and no outside requests. A strict security policy allows only the page's own files.
3. The text is the approved text and follows the writing rules. No price, date or count appears unless you set it.
4. Every claim on the page is checked against the running app.
5. Finnish on the page is limited to approved words and goes to the native reviewer.
6. Only if you choose call 7 B: a second "app not open yet" version of the page.
7. The form has one email field, an unticked consent box and an optional box. Double taps send once.
8. Every join gets the same answer, whether the address is new, already on the list, or blocked.
9. A hidden trap field and a minimum fill time stop simple robots without bothering people.
10. One plain confirmation email, with no tracking and no outside links.
11. Confirming needs a button press, so mail scanners that open links cannot confirm for someone.
12. Leaving works the same way, and the address is deleted.
13. The waitlist never touches learner accounts or sign in.
14. The list table holds only the address, two choices, consent proof and scrambled link codes.
15. Only the app's own server can add to the list, with caps per address and per hour.
16. Confirm and leave act only on a matching code from that person's email.
17. The list is separate from accounts, so deleting an account does not touch it.
18. Old rows delete themselves daily.
19. The server's key is set up by you and never stored in a file.
20. Each protection is proven by breaking it on purpose and watching its own test fail.
21. Only you can read the list, through job 14's three locks.
22. A "Waitlist" section on the owner page shows three counts and the newest 200 confirmed addresses.
23. Search titles, descriptions and social sharing tags are complete and correct.
24. Search engines are pointed at the page, and the app's own pages are kept out of search results.
25. A social card picture, 1200 x 630, made from the design tokens.
26. The privacy notice gains a waitlist part, including how long addresses are kept and how to leave.
27. Job 8's protections cover the new routes.
28. Phone, keyboard and accessibility checks pass, and long words wrap.
29. The page is light. At most 150 KB on a first visit, and it shows within 2.5 seconds on a slow phone.
30. Records are updated and every earlier test stays green.
31. Live check after go live. You join with your own address, confirm, see it on the owner page, and leave.

**Your calls**

1. *Where does the page live?* This changes a public address.
   - A. The main address, with the app moving to `/today`. Best for search, but it moves the front door that jobs 15 and 16 build on.
   - B. Its own path, `puhuscribe.exentrik.co/about` (recommended). Nothing in the app moves. "about" is a placeholder word you can change.
   - C. One address showing the page or the app, depending on whether you are signed in. It breaks job 15's one minute promise.

2. *Confirmation email and sender.* A sender is a new service holding visitors' addresses.
   - A. Send one confirmation email, with the sender chosen together with job 11's sign in emails at go live (recommended). Free plans cover the PRD's 150 sign ups. Resend is free up to 3,000 a month. Cloudflare's is $5 a month on its paid plan.
   - B. No email at all. Free, but anyone can add a stranger's address, and you could not prove consent later. Not recommended.

3. *What does "founding member" promise?* The fair is over, and nothing is sold yet.
   - A. Say nothing about price. No promise, but less reason to join.
   - B. Promise a founding member price in words, with no numbers (recommended). For example "lower than the public price, terms told before you pay". You define who qualifies and until when, and you must honour it.
   - C. Show the planned prices (€9.99 a month, €69 a year in the PRD) and a discount. Most concrete, but prices shown to consumers must include VAT, and you are bound to them.
   - Whichever you pick, EU law bans false deadlines and "only N left" pressure, so the page has none.

4. *Protection against robots on the form.*
   - A. Our own protections: a trap field, a fill time and database caps (recommended now). Costs nothing and needs no new service.
   - B. A, plus Cloudflare's rate limiter. Its plan and cost are not confirmed.
   - C. Cloudflare Turnstile. Best blocking, but it loads an outside script. Decide it together with job 8's guest account decision.

5. *The look.* You see one overview page with every picture named before anything is built.
   - What carries the page: A. type and the spoken and written card only (recommended), B. real app screens, C. photographs.
   - Finnish on the page: A. English only, plus the words puhekieli and kirjakieli (recommended until unit 1 is approved), B. one approved spoken and written pair once the reviewer approves unit 1.
   - Social card picture: A. the wordmark and one line, made from the design tokens (recommended), B. with a Finnish pair, C. a designer's or photographed picture.
   - The spec includes 8 real references with what to borrow. The award galleries (Awwwards, Godly, Land-book, SiteInspire) mostly gave names only or blocked access, so the references are mostly real language app pages. v2's landing page could not be read either. Its title, "Speak Finnish the way Finland speaks", is offered as an alternative headline.

6. *Does Exentrik appear?*
   - A. No. The responsible line names you personally, as the privacy notice does today. Your name is public on a page people find through search.
   - B. A visible "A product by Exentrik" line. It goes against the separate names rule in the PRD.
   - C. Exentrik only in the responsible line, as the company that owns the product (recommended, if the company holds it). This needs its legal name and business ID from you.

7. *When does the page go public?*
   - A. Together with the app at go live (recommended).
   - B. The page first, with the waitlist only. Collects addresses sooner, but the page needs a second version.

**What I need from you (not choices)**
- The word in the page address, if not "about".
- The sending name and address on your own domain for the confirmation email, and the reply address. Placeholders are in the spec. I will not choose an email address.
- Confirm the contact printed on the page. It is the one already in the privacy notice.
- How long confirmed addresses are kept, if not 24 months.
- Whether you hold book fair sign ups somewhere else. They cannot be added unless each person agreed to this wording.
- Founding member terms, if you pick 3 B or C.
- About 20 minutes at go live.

---

## Your decisions

Recorded here word for word, with the date, as you give them.

_None yet._
