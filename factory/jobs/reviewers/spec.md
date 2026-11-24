# reviewers (fast route): the native-speaker reviewer sign-up page

Owner's calls of 24 November 2026. Her talk video (002) asks native Finnish speakers to help check the Finnish in Aleksi, through a link in the description. She chose a page on meetaleksi.com instead of the planned Google Form ("Create a form on the website").

Flag: look closely. This stores personal data (name and email) of people with no account, adds a database table and its access rules, and adds a public form that anyone can send.

## The owner's choices

- Address: `meetaleksi.com/reviewers`, a public page next to the landing page, outside `/learn`.
- No account needed. The Cloudflare Turnstile bot check that guards "Start" guards this form too.
- No "Finnish checked by" credits page. The thank-you is in her next video only.
- Sign-ups are kept until she deletes them. No automatic deletion. A reviewer can ask for deletion sooner through hello@meetaleksi.com.
- She gets the same short email alert as for feedback when someone signs up: no name or email in it, at most one alert per 30 minutes.
- The credit question asks for an optional name for the thank-you in her next video.

## The page text (the owner reviews it before the build is approved)

- Title: "Please help us review the Finnish language in Aleksi"
- Intro: "Aleksi teaches puhekieli. If Finnish is your first language, I'd love your help checking it."
- Next steps: "After you sign up, I'll email you a short list of phrases from the app. You tell me anything that sounds wrong or unnatural."
- Fields:
  - "Your name"
  - "Your email"
  - "Name for the thank-you in my next video (optional)", with the hint "Leave it empty if you'd rather not be named."
- Button: "Sign up"
- Small print: "I use these details only to contact you about reviewing and to thank you. I keep them until the review is done, and you can ask me to delete them any time at hello@meetaleksi.com." Followed by a link to the privacy notice.
- After sending: "Thank you. I'll email you the phrases soon."

## Done when

1. `meetaleksi.com/reviewers` shows the page above on a phone (375 x 812) and on a desktop, in the app's locked design system, with no account and no cookie set before Send.
2. Send saves one row (name, email, optional thank-you name, time) in a new table, after the server checks a Turnstile token. With no valid token, nothing is saved.
3. The server checks the input. The name is 1 to 100 characters, the email is a valid address of at most 254 characters, and the thank-you name is at most 100 characters. It refuses anything else, and it refuses more than a small number of sign-ups from one address per day.
4. The new table gives the browser roles (anon, authenticated) no access at all. Only the Worker's server role writes the rows, and the owner reads them. pgTAP tests prove each rule.
5. The owner page (`owner.meetaleksi.com/learn/owner`) lists the sign-ups, newest first, with name, email, thank-you name and date. Each sign-up has a Delete button that removes it after a confirmation.
6. A sign-up sends the same kind of short alert as feedback ("New reviewer sign-up on Aleksi"), sharing the 30 minute gap logic. The alert holds no name or email. Without the Brevo settings, nothing is sent.
7. The privacy notice and `src/privacy/data-inventory.ts` describe the new data: what is kept, why, how long ("until the owner deletes it"), and how to ask for deletion.
8. The Send button ignores taps while sending. An error line claims only what happened.

## Not in this job

- A credits page.
- Sending reviewers the phrases (she does that by email herself).
