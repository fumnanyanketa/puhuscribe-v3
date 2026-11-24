# review-links (fast route): one-click review links for native-speaker reviewers

Owner's calls of 24 November 2026. People sign up at `meetaleksi.com/reviewers` (job reviewers, live). The old private review site needs each reviewer's email added by hand in Cloudflare Access, and only has pages for 6 of the app's 108 dialogues. She wants no hand work: one click on her owner page sends a reviewer their own private link.

Flag: look closely. This adds secret links (a capability token), a public review page reachable only with a valid token, new tables for reviewers' answers, and an email sent from Aleksi to a person with no account.

## The owner's choices

- Each sign-up on the owner page gets a "Send review link" button. She picks a batch, clicks, and the reviewer gets an email with their own private link. Nothing else to do: no Cloudflare step.
- The 108 live dialogues are split into **4 batches of 27**, in the order a learner meets them on the road. Batch 1 is the first 27, and so on. The batches are worked out from the live content, never typed by hand.
- Answers are **saved automatically** as the reviewer goes. They can stop and come back with the same link. No download, no emailing a file back.
- Deleting the sign-up on the owner page turns the link off and deletes that reviewer's answers.

## What the reviewer sees

The link opens `meetaleksi.com/review/<token>`. No account and no sign in.
- A short intro and the list of the batch's 27 dialogues, each marked "Not started", "In progress" or "Done".
- Each dialogue page lists every line. For each line:
  - the Finnish line in spoken form (puhekieli) and written form (kirjakieli)
  - the English meaning
  - a Play button for the line's audio, the same audio file the app plays
  - three answers: **Correct**, **Needs a fix**, **Not sure**. "Needs a fix" opens a box for what should change, up to 500 characters.
- Each answer saves on tap, and the page says "Saved". A failed save says so and keeps what they typed.

## What the owner sees

- On each sign-up: the batch sent, when, and how many lines are answered.
- A "Review answers" section: every "Needs a fix" and "Not sure" answer, newest first, with the dialogue, the line, the reviewer's note and the reviewer's name.
- "Send review link" can be pressed again to send another batch to the same person. Each send makes a new link.

## The email (the owner approves this text before going live)

- From: Aleksi <hello@meetaleksi.com>. Replies reach the owner.
- Subject: "Your Aleksi review link"
- Body:

  > Hi {name},
  >
  > Thank you for offering to help check the Finnish in Aleksi.
  >
  > Here is your private review link: {link}
  >
  > It has 27 short dialogues. For each line you can listen to the audio, read it in spoken and written Finnish, and mark it Correct, Needs a fix or Not sure. Your answers save as you go, so you can stop and come back with the same link.
  >
  > Please keep the link to yourself, since anyone who has it can add answers.
  >
  > Kiitos!
  > Fumnanya

## Done when

1. The owner page shows "Send review link" with a batch choice (1 to 4) on each sign-up. One click sends one email through Brevo with the text above, and records the batch and time. Without the Brevo settings nothing is sent, and the owner page says so.
2. The link holds a random secret of at least 128 bits. Only its hash is stored. A wrong, deleted or malformed token gets the same plain "This link does not work" page, and never reveals whether a reviewer exists.
3. The review page shows exactly the token's batch: 27 dialogues for batches 1 to 3, and the rest in batch 4. Each line has spoken, written, English and Play, from the live content.
4. Each answer saves on tap through the Worker. The Worker checks the token, the line belongs to the batch, the answer is one of three, and the note is at most 500 characters. Changing an answer replaces the old one.
5. The browser roles have no direct access to the new tables. pgTAP tests prove each rule. Deleting a sign-up removes its links and answers.
6. The owner page lists "Needs a fix" and "Not sure" answers, and shows progress per sign-up.
7. The review pages are `noindex`, send no learner cookie, and work at 375 x 812 and 320 px at 200 percent text.
8. The privacy notice and data inventory add the review answers: kept until the owner deletes the sign-up.
9. Rate limits keep one token from sending more than a reasonable number of answers per minute.

## Not in this job

- Retiring the old review site (`review-site/`). It stays as it is.
- Changing any lesson content from the answers. The owner decides fixes separately.
