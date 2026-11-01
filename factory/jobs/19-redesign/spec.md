# Job 19-redesign: Rebuild every learner screen in the approved design

Not in `docs/scope/scope.md`: the owner's redesign of 1 November 2026. GA, because it touches the consent sheet, the privacy notice, sign in, download and deletion, which are all learner data screens. Needs a decision. Date: 1 November 2026. Builds on main as merged, including jobs 8 to 12, 14 and 18. Job 15 was closed as superseded and is not built on. Runs beside `20-a1-road`, which supplies the stops. Job 17 (landing page, app moved under `/learn`) and job 16 (Use it with Otso) are held. Test label: `[redesign N]`.

## Summary for the owner

1. Every learner screen is rebuilt to look like the mock pages you approved on 1 November: the soft mint and peach wash, milky panels, fine grain, the small landscape behind each screen, slate blue for written Finnish. The home screen becomes the road to the A1 sun, with the A2, B1 and B2 fells beyond it. The old front door and job 15's welcome block are gone.
2. First open plays a skippable road animation of about 4.5 seconds and ends on stop 1. It is decoration only and stores nothing, so it plays again each time someone with no account opens the app, until they press Start.
3. Behaviour does not change except where a drawing says so. All the words that warn a learner or ask for consent stay word for word, even where the mock shows a shorter line: the guest line, the two warnings on the email screens, the delete warning, the speaking consent text and the feedback privacy line. They only get smaller and quieter. A test freezes them.
4. Three things in the drawings cannot be built as drawn. The exact mint, peach and slate colours fail the contrast floors the project set in job 5, so a few are made slightly darker and shown to you beside the originals. The word card needs an English meaning for every word and no such data exists yet. The road needs the 36 stops from job 20, so this job cannot be merged before job 20.
5. Costs €0. No new service, package or AI call. The work is front end only, plus one small read in the Worker that tells the first lesson to show its tip, worked out from records that already exist. Nothing new is stored on the phone or in the database.
6. Fifteen calls are yours at the end. The biggest: where peach may appear (the drawings use it more widely than your rule), the contrast floors, dark mode, the real fonts, and whether the speaking consent sheet is allowed to show only a title and a link.

## What it is

The look of PuhuScribe changes everywhere. The learner opens a road that runs to a sunrise marked A1, walks it one stop at a time, and each lesson, account page and error screen sits in the same soft landscape. It serves P1 to P5 by carrying them unchanged in a calmer frame. It adds no learning feature.

## Done when

Terms. **The drawings**: `design-drafts/v1-screens.html` (every lesson, journey, account, privacy, feedback and error screen), `design-drafts/road-journey.html` (the road home screen and the opening animation) and `design-drafts/written-colour.html` (option A, slate blue, chosen). A drawing is named by its caption in those files, for example "Say it, try again". **Mock size**: the drawings are 280 px wide, so real sizes at 375 px are the mock's sizes times 1.25 (the owner's brief; the width ratio is 1.34, so text ends a little smaller relative to the screen than drawn). **Browser test**, **phone size** (375 x 812, Chromium and WebKit), **the fixture** (job 8's test seed) and **axe** (`@axe-core/playwright`) mean what they mean in jobs 8 and 18. **Small phone**: 375 x 667. **Road fixture**: a list of stops in `src/road/road-fixture.ts`, used by tests and `/design-reference` only (statement 19). **Protected copy**: the exact strings listed in statement 43. Tags: **[security]** and **[personal data]** mark statements the security reviewer and the evaluator check closely.

### Look and tokens

1. **The new colour tokens replace the old ones.** `src/styles/tokens.css` holds the colours of "Colour roles" below. The lilac ground, violet, teal and azure tokens are removed, not kept beside the new ones. A repository test reads `src/` and finds none of the removed token names. `tests/design-tokens.test.ts` still refuses a raw colour in any component.
2. **Each role colour is used only where its role says.** A repository test lists the files that may use the mint (spoken), slate (written) and peach (changed word) role tokens. A new use elsewhere fails until the list is changed on purpose. Browser test on a rendered line: the spoken dot is mint, the written dot and the written text are slate, a word that changes is peach on its peach wash in both lines, and no other word in the line has another colour.
3. **The ground, the grain and the panels.** One wash gradient token (`--ground-wash`, the mock's 165 degree mint to off white to peach) is declared once in `tokens.css` and used once, on `html` in `base.css`. `tests/design-css.test.ts` changes only in the name it allows (`--ground-wash` where it allowed `--ground-fade`). Every other CSS gradient, `backdrop-filter` (frosted glass) and gradient text stay refused, and all its "catches" tests stay. The fine grain is an inline SVG data address with no gradient, sits on the ground behind panels and text, and so cannot change a text contrast. Panels, sheets and cards take their fill, edge, shadow and corner from panel tokens; no component sets its own.
4. **The landscape.** A `Landscape` component draws the scene in inline SVG with no image file, no request and no third party. It has two uses. The band sits behind the top of every screen except the road, about 210 px high at 375 px, fading into the wash (the fade is drawn inside the SVG, since CSS gradients stay refused). The full road scene is statement 12. The art's colours are tokens too, in a `--land-*` group, with an evening set for statement 17. The drawing is `aria-hidden`.
5. **The type scale.** Real sizes are the mock's times 1.25, in `rem`, with these floors. No text is smaller than 12 px at default settings (the mock's 8.5 px fell labels and 9.5 px captions come up to 12 px). Any sentence of reading text is at least 14 px. Written Finnish is at least the size owner's call 2 allows. Spoken Finnish is at least 18 px. Fonts follow owner's call 3. A unit test reads the computed size of every text style on every screen and fails under the floors. The Finnish ä, ö and å test of job 5 still passes, there are no italics, and long compound words still wrap (`overflow-wrap: anywhere`).

   | Use | Mock | Real |
   |---|---|---|
   | Lesson title, sheet title | 16 | 20 |
   | Spoken line on the line card | 15 | 19 |
   | Spoken line on Understand it | 17 | 21 |
   | Word on the word card | 26 | 32 |
   | Written line | 11.5 | 14.5 as drawn, or the floor from call 2 |
   | Body and sheet text, privacy paragraphs | 10.5 to 12.5 | 14 to 15.5 |
   | Button text | 11.5 | 14.5 |
   | Sign names | 10.5 | 13 |
   | Hints, speaker name, captions, fell labels | 8.5 to 10 | 12 to 12.5 |
6. **Contrast.** `src/styles/contrast-pairs.ts` lists every text and mark pairing of the new look, with the floors of owner's call 2, in light mode (and dark if call 4 says so). The test fails if `design.md`'s table and the list differ, as it does today. By my hand calculation, not run through the project's test, these pairs in the drawings are under their floor and are the ones to expect: white on the mint button (about 3.9 to 1, needs 4.5), peach deep on peach soft (about 4.0), slate on slate soft (about 4.4), written slate on white (about 5.3, needs 7 for Finnish lines), quiet text on the mint end of the wash (about 3.9). The builder darkens the least needed and `/design-reference` shows each changed colour beside the drawn one.
7. **Buttons and controls** (owner's call 5). The primary button is a mint pill with the small arrow circle, 52 px tall and never under 44 px. The secondary is the white pill with a mint edge, the quiet one is underlined text, and a danger pill (deep peach, for "Delete for good") is added. Every button has explicit token colours in WebKit as well (job 5's lesson), a visible focus outline of at least 3 to 1 on whatever it sits on, and a 1 px press.
8. **`design.md` and `/design-reference`.** `design.md` is rewritten from the approved screens: the "Redesign under way" section becomes the current look, and the type, colour, contrast, component and banned sections are updated. The owner's banned list stays in it. `/design-reference` shows every new part in each state: the tokens and type scale, panels, buttons, the three status line styles, the landscape band, the line card, the tip, the word card, the three sheets, the road in each state and each sign state, the progress bars, the avatar, switches, the answer rows, the field and the record control states.
9. **Design tests change only where the look changed on purpose.** The expected list is `tests/design-css.test.ts` (the allowed name), `tests/design-tokens.test.ts` with `src/styles/contrast-pairs.ts` and `token-values.ts` (the values), `tests/design-rules.test.ts` (the font and size checks), and the design reference browser tests. `build.md` lists each change and why. No test is removed or weakened, and no "catches" probe is dropped.

### The road

10. **The road is the home screen.** At the app's home address the road replaces the front door. Gone from that screen: the wordmark header, "Today's session", the lead sentence, the can do line, the link list and job 15's welcome block. The Voice settings, Privacy notice and Send feedback links now live on the account page. Browser test: none of those strings appear on the home screen. A visually hidden heading "Your road to A1" is its one `h1`.
11. **While it loads** the home screen shows the sprout mark and three fading dots (the drawing "Opening"), then the road. The mark's colour follows owner's call 14.
12. **What is drawn.** The sky, the A1 sun low on the horizon with "A1" on it, three fells beyond it with summit flags and the labels A2, B1 and B2, a pine ridge, and the road winding in perspective toward the sun. The stretch of road the learner has travelled has a mint centre line. A pulsing "you" marker sits on the road at the current stop. The scene is drawn in the mock's 280 x 620 box, scaled to the screen width and anchored so the sun sits at the same height on every phone. The fell labels are real text. The B2 label wording is owner's call 13. The pulse stops under reduced motion.
13. **Stops are signs.** Five signs show at a time: the current stop, up to two before it, and the rest after it, shifted so five always show (at the start the current stop is first). Each sign is a number and a name. Four states: done (filled mint with a tick), current (ringed, number in mint), next (a peach ring, the one the learner reaches next) and later (quiet). Names come from stop data and are rendered as text, never as HTML. The five form one ordered list named "Stops on your road" and each item reads like "Stop 3, Grocery store, current" to a screen reader. Signs are not buttons: no drawing shows one doing anything, and tapping one does nothing.
14. **The top** holds only the progress bar and the account button. The bar has 12 segments (owner's call 12). The button is a 44 px round, named "Your account", opens the account page, and shows the first letter of the learner's email, or a G for a guest. The letter comes from the existing `GET /api/me`, called once after the road is drawn and only when a learner is signed in. If it fails, a plain person mark shows. No new route.
15. **The bottom card, by state.** One milky card at the bottom. Button names and actions are the existing ones.
    - No account on this device (day one): stop 1's name, "Stop 1, N short lessons", "Start", and "Have an account? Sign in" (opens sign in). Under them, small, the protected guest line and a "Privacy notice" link (owner's call 9).
    - Start or continue: the stop's name, "Stop 3, lesson 2 of 4", the lesson segments, and "Start" or "Continue". "Start" still sends `POST /api/guest` and goes to the session. "Continue" goes to the session.
    - Review only: "Review" and "Start review". Any count or minutes on it follow owner's call 7.
    - Done for today: the evening sky, "Done for today", "Next lesson tomorrow", a tick, and no button.
    - Stop finished: the stop's name and its can do sentence, the next stop's name, and the next sign lit in peach. Whether it has "Continue" is owner's call 8.
    - The existing messages (signed out after a guest session ended, after an email sign in ended, the notice after deleting, "not ready", "all done") show in the same card as one plain line, in the existing words.
16. **Loading creates nothing.** A browser test counts zero calls to `/api/guest` before "Start" is pressed (job 8's `[session 1]` stays green). **[personal data]**
17. **The opening animation.** It plays when this device has no account, and never for a signed in learner. About 4.5 seconds: the landscape fades in, the road draws from the bottom, the sun rises, the A2, B1 and B2 fells appear, the signs pop in, then the view moves in to stop 1 and the card rises. It ends on the day one road with stop 1 current. "Skip" is a text button of at least 44 px, first in the tab order, and ends the animation at once and moves focus to "Start". Under reduced motion the animation is replaced by a crossfade of 600 ms or less from the empty landscape to the final screen, and nothing slides, scales or draws. The animation is CSS only. Nothing hidden can be focused or tapped while it runs (hidden parts use `visibility`, not `inert`, which older Safari lacks). Screen readers get the final screen from the start; the animation layer is `aria-hidden`. Any Finnish text in it comes from stop data (statement 19) and is approved content, or the animation runs without it. Nothing is stored: no storage, no cookie, no database record. A learner with no account sees it again each visit until they press Start, which is accepted (Decision 2).
18. **Animation tests.** Browser test reads `document.getAnimations()`: the longest animation ends between 4.0 and 5.0 seconds after load. "Skip" ends all of them within 300 ms. With reduced motion on, every animation changes only opacity and ends within 600 ms. A signed in learner has no animations other than the marker's pulse. This also meets WCAG 2.2.2 (moving content that starts by itself needs a stop control when it lasts over five seconds; read on w3.org on 1 November 2026): the animation is under five seconds and still has Skip.
19. **The smallest interface this job needs from job 20.** See "Interface from job 20" below. The road reads stops through one function, `loadRoad()` in `src/lib/road-data.ts`, which calls the route job 20 provides. The road fixture exists only for tests and `/design-reference`. A build test, like `tests/design-build.test.ts`, proves a normal build contains no fixture marker string, so no fake stops can reach a learner. Until job 20 merges, every browser test of the road runs on the fixture through the Worker's test fake.
20. **Small phone and text size.** At small phone size the bottom card never covers the current sign or the "you" marker, in every card state. At 320 px wide and with text at 200 percent, nothing scrolls sideways; sign names wrap, and the card always shows the current stop's full name.

### The lesson

21. **The frame.** Every lesson screen has the landscape band, a 44 px cross in a milky round, a progress bar and the step name at the right. The bar fills by the share of the lesson done: finished steps plus the share of the current step (lines shown in Hear it and Say it, questions answered in Understand it, words done in Keep it). The step name shows as "Hear it"; the existing "Hear it, step 1 of 5" stays as the bar's accessible name. The step name is the screen's `h1` and may be visually hidden where the drawing shows only the question.
22. **Leave the lesson.** The cross opens a sheet: "Leave this lesson?", "You can carry on later from here.", "Keep going" and "Leave". "Keep going" closes it and returns focus to the cross. "Leave" goes to the road, and the lesson resumes where it was, as job 8's statement 18 says. The sheet does not appear on the finish screen, where nothing is lost. It is a native `dialog` with focus trap, Escape closes it, and the page behind cannot be used or scrolled.
23. **The line card.** The card has the speaker's name, "Line 2 of 8", the two dots joined by a dotted line (mint for spoken, slate for written), the spoken line, the written line, and a play button on each line (named "Play the spoken line" and "Play the written line", as now). There are no "Spoken" and "Written" labels. The English gloss sits inside the card under a dashed line. Changed words are peach on a peach wash in both lines. While a line plays the card shows a ring and the word "Playing" stays in words, so colour is never the only sign. Every word with word data is a button; a word without data (a name) is plain text and never a dead button.
24. **Hear it.** One line card at a time with "Next line", then "Continue" on the last line, as drawn (owner's call 6). The status line, `role="status"`, says "Line 2 of 8." Nothing plays by itself. The card shows the dialogue's lines only; the dialogue title and the can do sentence are not on this screen.
25. **The tip on a learner's first lesson.** On the learner's first lesson only, before Hear it is finished, the line card stays lit and the rest dims, with three short lines: "How people say it" (mint dot), "How it's written" (slate dot), "Tap any word to learn it" (peach ring), and a "Got it" button. It replaces the old help line and the "Blue words change" line. Whether it shows comes from one field the Worker adds to the session answer, `firstLesson`, worked out from existing session rows (the learner's only session, step not yet reached); no new table or column and nothing stored on the phone. "Got it" closes it for that screen, and a reload shows it again while the first lesson is still at Hear it. Focus moves to "Got it" when it opens and back to "Next line" when it closes; Escape closes it; Tab cannot reach the page behind. Browser tests: it shows on the first lesson, not on the second session or on a first lesson already past Hear it, and a pgTAP or Worker test proves the field uses only the caller's own rows. **[personal data]**
26. **The word card.** Tapping a word opens a bottom sheet with: the word large with a play button, its English meaning, two tiles "People say" (mint) and "Books write" (slate) each with a play button, "Dictionary form" with the base form and its meaning in plain words, and "Why does it change?" behind one more tap (the existing `why` line). Peach marks only the words that change. The card keeps its dialog behaviour from job 5 (focus in and back, Escape, tap outside, no page scroll) and the existing quiet "Patterns you've seen" button from job 12, which the drawing omits. Audio exists per line only (job 8, Decision 6), so each play button plays the whole line in its register, its name says so, and the one caption "Plays the whole line." stays. The meaning lines come from word data this job does not create (statement 27); with data present they show, and without it that line is left out and no text is invented.
27. **Word meanings need data that does not exist yet.** `WordCardData` gains optional `meaning` (what the word means in this line) and `baseMeaning` (what the dictionary form means), both plain English. This job defines the fields, reads them, and tests the card with both present and both missing. It does not add a database column or write content. Where they come from is owner's call 15 and a dependency for the manager. Browser test with a form that has them and one that does not.
28. **Understand it.** The question title, one spoken line in a milky card with one play button, and three answer rows. The existing question words ("What does this mean?"), the existing right and not right wording, and the existing rule (pressing a row answers at once) stay; the drawing's "What does Maria ask?" and "Check" are samples and are not new behaviour. A right row gets a mint edge and a tick, a tried row goes dashed and stays focusable, the others become unavailable, as in job 8. The bottom pill reads "Next" when the answer is right and is unavailable before that. The written line is not shown on this screen, as drawn; words in the spoken line stay tappable.
29. **The speaking consent sheet.** A bottom sheet shows only its title ("Say it out loud"), a "How it works" link, "Turn on" and "Not now". "How it works" opens the full consent text of job 10, unchanged word for word (`src/lib/voice-consent.ts`, same version label, so the existing version test stays green), with the unticked "Keep my recordings" box and the sentence that both choices can change in Voice settings. Rules of job 10 that still hold. No microphone request before "Turn on" (browser test counts zero `getUserMedia` calls). The box is never ticked for the learner. "Turn on" records one `voice_processing` granted row, plus the retention row only if the box was ticked. "Not now" lets the learner say each line without feedback. Withdrawing is as easy as agreeing. Owner's call 10 decides whether the first layer needs one more line. **[personal data]**
30. **Say it and its states.** As drawn: the line card without play buttons, the large mint record button with rings and the hint "Tap and say the line."; while recording, the record button turns peach with a wave and the hint "Listening." and a quiet "Stop"; a clear result shows a milky card "That was clear." with the wave and "Play mine" and "Try again"; a try again result shows the gentle peach note with its open ring. Also restyled in the same look and with their existing words: loading, aloud only mode ("Say the line out loud after the voice."), recording not available, microphone off, too many tries, not checked. "I can't speak right now" stays a quiet link. "Next line" or "Continue" appears after an attempt, as job 10 set. The feedback wording of job 10 is unchanged; the drawing's samples are not new copy. **[personal data]**
31. **Keep it and its states.** As drawn: "Type the missing word", the line card with a blank, the field with its caret, the ä and ö keys (kept if they exist today), "Check" and the quiet "I don't remember". After an answer the whole line shows with the word marked, and the existing result words stay ("Yes, that is right.", the close and missed wording and "The word is ... in spoken and written Finnish"). A close or missed answer uses the gentle peach note, never red, no score, no count of mistakes. The spoken answer mode of job 10 is not drawn: it reuses the Say it record button and states and keeps its own words.
32. **Use it with Otso.** The chat is drawn but job 16 is held. Only if job 16 has merged when this job is built, the builder restyles its step to the drawing "Use it, with Otso" (bubbles, ä and ö keys, the composer). Otherwise it is out of scope and `build.md` says so.
33. **Lesson finished.** The tick orb, "Now you can say this.", the line card with its English line, job 18's save note restyled as a milky panel (its words, "Add your email" as the secondary button and "Not now" as the quiet one are unchanged, and it still hangs only on the complete answer), a quiet "Send feedback" link, "Done", and one status line: "Your progress is saved on this device." for a guest and "Your progress is saved." for an email account. The drawing's two figures ("+11 new words", "8 lines said aloud") follow owner's call 7. The save note keeps job 18's rules: not a status, alert or dialog, no focus move, and the finish screen has exactly one `role="status"`.

### Account, privacy, feedback and errors

34. **Your account is a profile page.** The landscape band, a back arrow, a large avatar (the letter as on the road), the name line ("Guest" and "Saved on this device", or the email and "Saved to your email"), a "Your journey" panel ("Stop 3 of 36", a bar, "Now: Grocery store" and "A1", from the stop data), and one settings panel with four rows: Speaking feedback (shows On or Off, opens Voice settings), Download my data, Privacy notice, Send feedback. No lines between the rows. Below: for an email account "Sign out" as small text and "Delete my account" as small text; for a guest only "Delete my account", and above the settings panel a peach note "Add your email to keep your progress." with an "Add" button named "Add your email". A guest has no Sign out, as in job 11. Every job 11 behaviour stays: the account kinds, "Sign in with your email" when there is no account, the status line for download and sign out, and the busy states.
35. **Add your email, Enter the code, Sign in.** One field and one button each, the six code boxes, "Send a new code", and "Start as a guest instead". The protected sentences stay on screen where job 11 put them: `SENDS_CODE` and `TAKEN_WARNING` on Add your email (job 18's statement 10 still holds), `GUEST_WARNING` on Sign in when this device has a guest account, `SIGN_IN_SENT`, `CODE_WORKS` and the other messages. They may be smaller and under the field, never removed or shortened. The code boxes are one `input` with `autocomplete="one-time-code"` and a visible box for each digit, or six inputs that behave as one; either way paste of a 6 digit code works and a screen reader hears one field.
36. **Voice settings.** The two switches ("Speaking feedback" and "Keep my recordings", with its one line about 90 days) are real switches with names, one press changes each, and "Delete my recordings" is a danger text button. Everything in job 10's statement 4 stays, including what withdrawing deletes.
37. **Download my data.** "Download my data" on the account page keeps its flow (preparing, ready, or could not prepare). The ready state shows in place as the drawing "Download my data" (no new address): "Your file is ready", one line, and "Download". It calls the existing download code unchanged.
38. **Delete my account.** The page keeps its address and its two steps. It looks like the drawing's sheet: the title, the protected `DELETE_TEXT` in full (which says what is deleted and to download first), "Delete for good" as the danger pill, and "Keep my account". Nothing is deleted before the second press, as in job 11.
39. **The privacy notice is a readable page.** The first layer is the drawing: the title, a two line summary, five short sections (What we keep, Your voice, How long, Your rights, Who runs PuhuScribe), a "Read the full notice" control, and "Updated" with the date. In "Who runs PuhuScribe" the owner's sentence stays word for word ("PuhuScribe is part of the product family of Exentrik, a product studio in Finland."). The sentence "Exentrik looks after your data" is gone, as the owner decided. Behind "Read the full notice" is job 11's whole notice, unchanged in content: every section heading, the inventory, the processors, the rights, the complaint link, age, and "Who is responsible" with the controller's name and contact from `src/privacy/notice-settings.ts`. Owner's call 11 decides whether the first layer also names the controller. The summary's claims are each checked against `src/privacy/data-inventory.ts` by a unit test that lists the claim and its source line; the drawing's "Never your name" and "Checked, then deleted, unless you choose to keep it" are the two to check, and a claim the inventory does not support is reworded. `NOTICE_UPDATED` is changed to the date the text changes. The page still loads without an account and calls no `/api` route. **[personal data]**
40. **Send feedback.** The back arrow with the title, "What should we know?", a text area and "Send". The protected line "Please do not include personal details." stays, small, and so do the 1,000 character limit, the sent message, and the no account message. Job 14's rules hold: one message per press, the screen value in `?from=` is the only extra stored.
41. **Errors, offline and loading.** Three drawings. "Opening" is statement 11. "No connection": a cloud with a slash, "No connection", one line and "Try again", shown when a page's first request cannot reach the app. "Something went wrong": the existing crash boundary in the new look with "Reload". The drawn lines "Your progress is safe" and "We've been told about it" are only shown where true (lesson learned in job 4): "Your progress is safe" appears on the road and account screens, where nothing waits to be saved; inside a lesson the offline screen says "Check your internet connection, then try again." The crash screen keeps its existing words and does not claim a report was sent. All other existing problem messages (not saved, not checked, could not start) keep their words and show in the problem style.
42. **The three status line styles stay distinct in shape and words.** Neutral is quiet text. Gentle is the peach soft note with an open ring, for the learner's attempts, never red. Problem is a square cornered block with an edge and a filled square, for system faults only. A learner's mistake never uses it. Colour is never the only sign.

### Kept behaviour, phone, keyboard and records

43. **Existing behaviour keeps working.** All earlier unit, database, Worker and browser tests pass unchanged except those changed on purpose. A test may change only where visible text or layout changed on purpose, and `build.md` lists each one with the reason, from this expected list: tests that read the old front door text and links, the removed "Spoken" and "Written" labels, the old help and hint lines, job 8's "Hear it" lines stacking (call 6), the step bar's visible text, "Leave session" now opening a sheet, "Continue today's session" now "Continue", job 10's route to Voice settings from the front door, and job 11's account page text. No test is deleted or weakened. A unit test freezes the protected copy by comparing it with the current text: `GUEST_LINE`, `SENDS_CODE`, `TAKEN_WARNING`, `GUEST_WARNING`, `SIGN_IN_SENT`, `DELETE_TEXT`, `FEEDBACK_INTRO`, the whole of `voiceNotice()`, and job 18's `save-note-copy.ts`. Changing any of them needs the owner's approval and the version label of the voice text.
44. **Nothing new is sent, stored or installed.** For a guest from the road through a lesson to the finish screen, a browser test finds requests only to the app's own address, the same routes as today, plus `GET /api/road` (job 20), and no request to any font or image host. `document.cookie` holds only the sign in cookie, and `localStorage` and `sessionStorage` are empty. The command `git diff --stat main...HEAD -- package.json package-lock.json wrangler.jsonc supabase worker/providers worker/personal-data` prints nothing; the evaluator runs it by hand once, because a permanent check of that kind would fail later jobs (lesson from job 15). The drawings load Poppins from Google Fonts; the app must not (`design.md`, "Fonts and their licences").
45. **Paths.** Files this job adds hold no quoted app path (`'/account`, `'/session`, `'/learn`, and the same in double quotes or backticks). Paths come from one constant file, `src/lib/app-paths.ts`, or from job 17's helper if it has merged. A repository test checks the added files. Files this job only restyles keep their existing strings, and job 17's move then changes the constant file plus those strings, as it would have anyway. New tests open pages through the existing helpers in `e2e/` and check addresses with `endsWith`.
46. **Phone size.** Every screen of the drawings, at phone size in both browsers and at 320 px with text at 200 percent, shows no sideways scroll, all controls are at least 44 x 44 px, no text is under 12 px, and a 40 letter Finnish word wraps inside its box at 375 px (lesson from job 7). The lesson screens keep their action area in view on a short phone.
47. **Keyboard and screen reader.** Every control works with a keyboard in reading order and shows a focus outline. Each sheet and the tip move focus in, trap it, close with Escape where that is safe, and return focus to what opened them. Each screen has one `h1`. axe finds no WCAG 2.0 to 2.2 A or AA violation on any screen of the drawings, in every state the drawings show. With reduced motion on, nothing on any screen slides, scales, draws or pulses.
48. **Evidence.** `factory/jobs/19-redesign/evidence/` holds one screenshot at phone size, in each browser, of every screen the drawings show (about 40, named by the drawing's caption), each beside a screenshot of the same drawing taken from the static page by a Playwright script. Nothing in the evidence holds a secret. The design reviewer compares each pair against `design.md` and the banned list in `AGENTS.md`.
49. **Records.** `docs/conventions.md` adds the `[redesign N]` row. `design.md` is as in statement 8. `docs/data-model.md` says no database object was added. `design-drafts/` stays unchanged as history. The README's running costs stay at €0. `build.md` lists every changed earlier test (statements 9 and 43) and the owner's call answers it followed.
50. **Owner approval.** As a GA job, it is done only when `summary.md` records the owner's own written "approved" line with the date.

Product rules from `AGENTS.md` that apply: all five principles carried through unchanged; one front door, one loop (the road is the front door and the learner never picks a mode); grammar stays a card behind a tap and corrections stay gentle; nothing unmet is reviewed; nothing unapproved is served (statements 17, 26 and 27 add no unreviewed Finnish); GDPR minimum data and the consent rules of job 10 (statements 29, 39 and 44); no users under 18 (the guest line stays); no streaks, ranks, confetti, badges or scores (the "Not in v3.0" list is binding); agents use only the test database; no placeholders or fake data in the app (statement 19); never delete or weaken a test; client text is English.

## Colour roles

Starting values are the drawings' hex. Final values may be a little darker (statement 6, owner's call 2). Peach is used as drawn, which is wider than the rule in `design.md`'s redesign section (owner's call 1).

| Role | Drawn value | Used for |
|---|---|---|
| Mint | #23917a | everything tappable, the spoken dot, the progress fill, done signs, the record button |
| Mint deep | #1a6f5d | text on mint soft, "How it works", current sign text |
| Mint mid, mint soft | #74bba9, #d6efe7 | the dotted connector, rails, the "People say" tile, quiet edges |
| Slate | #4f6d94 | written Finnish only: the written dot and line, the "Books write" tile and its play button |
| Slate soft | #e4ebf4 | the "Books write" tile |
| Peach | #ee8763 | the words that change, the next sign's ring, the sun, fell flags, the recording state, the delete action, gentle notes |
| Peach deep, peach soft | #b8532f, #fde4d8 | text on peach soft, the gentle note, the save note, the changed word wash |
| Ink, quiet | #1b2a26, #637570 | text |
| Wash stops | #cbede1, #f7f8f6, #fbe2d1 | the page wash |
| Travelled road | #8ce6cb | the mint centre line |

## Where the build differs from the drawings, and why

These are not defects. The evaluator checks each is as written here.

1. The four protected texts and the consent text stay longer than the drawings show (summary point 3).
2. Understand it keeps its question and rule, not the sample question and "Check".
3. The word card's play buttons play the whole line, and it keeps "Patterns you've seen".
4. Delete my account stays a page with its own address, styled as the drawn sheet. Download ready shows in place.
5. The review count, the finish figures, the Continue on Stop finished, one line at a time in Hear it, and the B2 label follow owner's calls 7, 8, 6 and 13.
6. Colours are slightly darker where the drawings fail the floors; sizes follow call 2.
7. The grain sits behind panels and text, not over everything as in the mock.
8. The two error lines that claim something are shown only where true (statement 41).
9. The sample sentences in the drawings (names, "Meeting people", "Grocery store", "Voinks mä maksaa kortilla?") are not copy. Stop names come from job 20 and lines from approved content.

## Interface from job 20

The smallest this job needs, as TypeScript in `src/lib/road-types.ts`. Job 20 provides the data and a route; this job does not design the database.

- `RoadStop`: `number` (1 to 36, the sign's number), `name` (the sign), `canDo` (the "I can" sentence), `part` (1 to 6, for the account page), `lessons` (how many lessons the stop has), `lessonsDone` (0 to `lessons`).
- `RoadView`: `stops`, all stops of the A1 leg in order. For a visitor with no account the same list with every `lessonsDone` at 0 and nothing personal in it, so the day one road can draw before sign in.
- Optional `sampleLine` on a stop: one spoken Finnish line from that stop's own approved dialogue, with its changed words marked. Only the opening animation uses it. Without it the animation shows no speech bubbles.
- Derived here, not given: the current stop (the first with `lessonsDone` below `lessons`); the window of five signs; the lesson segments; "Stop finished" (today is done and the current stop has `lessonsDone` 0 after stop 1). Today's state (start, continue, review, all done, not ready) is the existing `GET /api/today`.
- Route: `GET /api/road`, learner's own progress, no learner id in the request. If job 20 names it differently, only `loadRoad()` changes.
- Until job 20 merges, the road works on `src/road/road-fixture.ts` through the Worker's test fake. This job cannot merge to main before job 20, because the home screen would have no stops.
- Word meanings (statement 27) are a separate gap: `meaning` and `baseMeaning` per word form, from owner's call 15.

## Threat model

**What is the worst a malicious person could do here?**
- Put markup in a stop name, can do sentence or email and have it run in another learner's road or avatar. Every such string is rendered as text; the SVG is built only from fixed shapes and numbers (statements 13 and 14).
- Trick the consent sheet into recording without a real choice, for example by a hidden second step or a pre-ticked box. Statement 29 keeps job 10's rules and tests.
- Weaken a destructive flow in the restyle: delete without the second press, sign in that deletes guest progress without the warning. Statements 35 and 38 keep the words and steps, and statement 43 freezes the copy.
- Use the first lesson field or the avatar request to read another learner's data. Both use the caller's own token and rows (statements 14 and 25).
- Use the opening animation or any screen to load something from a third party. Statement 44 forbids any request off the app's address.

**What data are we storing that we must protect?**
- Nothing new. No table, column, cookie, local storage, log line or analytics event is added. The first open animation and the first lesson tip are worked out from account state and existing rows, never remembered on the phone (Decisions 2 and 3). The account page shows the learner's own email and the road their own progress, and the road fixture holds no real person.

**What must the system refuse even if asked nicely?**
- Showing fixture stops, sample Finnish or "Sample, not reviewed" text to a learner (statements 19 and 17).
- Storing an "animation seen" or "tip seen" mark on the phone or in the database.
- Asking for the microphone before "Turn on", or turning speaking feedback on from a pre-ticked box.
- Removing or shortening the protected copy, or claiming something untrue such as "We've been told about it".
- Loading fonts, images or scripts from any other address.
- Counts, scores, streaks, ranks, confetti or loss wording.

## Decision

| # | Choice | Pick | Runner up | Why the runner up lost |
|---|---|---|---|---|
| 1 | How the road and landscape are drawn | Inline SVG for the art, real HTML for signs, labels and cards, all colours as tokens | Pre rendered images, or a Lottie animation | Images are separate files that scale badly with text size and cannot take token colours or the evening set. Lottie adds a package and a runtime for one animation. Signs as HTML text keep names readable, wrapping at 200 percent text and available to screen readers |
| 2 | How the opening animation knows it is "first open" | It plays when this device has no account, and never otherwise | A flag kept in device storage or in the database | Storage on the phone breaks the rule, kept by jobs 14, 15 and 18, that the app writes only the sign in cookie, and job 15 found the EU rule on device storage for "seen" flags unsettled (I did not read the EDPB text). A database flag adds a learner table with an export entry, a notice line and access rules for a decoration. The cost of my pick is that a visitor who does not press Start sees it again, which is accepted because Skip is one tap |
| 3 | How the tip knows it is the first lesson | A `firstLesson` field the Worker adds to the session answer, read from existing rows | Device storage, or a new "tip seen" row | Same reasons as row 2. The field is like job 18's note: the database already knows this is the learner's only session. A reload at Hear it shows the tip again, which is accepted |
| 4 | How the animation is made | CSS keyframes in the component, with a reduced motion block | A script library such as GSAP or Motion, or a video | A library is a new package and a new licence for 4.5 seconds of fades and moves. A video is a large file with no text size or reduced motion control. CSS keyframes run in Safari 15.4 and let `prefers-reduced-motion` swap the animation for a crossfade in one place |
| 5 | Old tokens | Replaced | Kept beside the new ones, with a switch | Two looks in one app doubles the contrast list and the tests, and the owner chose one look |
| 6 | How "as drawn" is checked | Role, size and contrast tests plus paired screenshots reviewed by the design reviewer | Pixel comparison against the drawings | The drawings are static pages at 280 px with larger gaps and different fonts; a pixel diff would fail on every harmless difference and prove little |
| 7 | Tip and sheets | Native `dialog` or the same focus rules as the word card | A custom overlay | The word card already proves the dialog pattern on Safari 15.4 (job 5); the tip needs the same page lock and focus return |

New npm packages: none. New Worker routes: none in this job (`GET /api/road` is job 20's). New database objects: none expected; if the builder finds one is needed, they stop and report.

### Notes for the builder

- Build in the order of the plan. After milestone 1 the old screens still run in the new colours, so every later milestone can be checked on its own.
- Reuse what exists: `SessionFrame`, `Button`, `StatusLine`, `WordCard`, `FinnishLine`, `AnswerChoices`, `PlayControl`, `RecordControl`, `SaveNote`. Restyle and recompose them; keep their props and behaviour.
- The mocks use `mask-image` with a CSS gradient for the band's fade and a giant `box-shadow` for the tip's dimming. Neither passes the design tests or old phones as is. Draw the fade inside the SVG and dim with a real scrim element.
- The mocks use Poppins from Google Fonts. The app serves its own fonts only.
- Two things the CSS tests refuse and the mocks use: gradients on the pill and the progress fill (owner's call 5) and `backdrop-filter` (not used by the mocks, stays refused).
- The word card and line card keep job 8's rule that a word and its punctuation never wrap apart.

## Out of scope

- Job 20's content and database: the 36 stops, 144 lessons, dialogues, stop names and the can do sentences. Any Finnish text. The word meaning content (owner's call 15).
- Job 16 (Use it with Otso) unless it has merged first (statement 32), and anything about the tutor's rules or cost.
- Job 17's landing page, the move under `/learn`, and any marketing screen.
- Dark mode, unless owner's call 4 says build it.
- Day One Sprint, a vocabulary bank, a practice hub of modes, standalone grammar lessons, the sentence bank, ranks, confetti, a milestone ladder, a bilingual toggle, mnemonics, YKI content or skill tagging, native app builds, an owner dashboard beyond job 14's. No streaks.
- A words learned count, parked by the owner on 1 November 2026. A review due count, unless call 7 says so.
- Word level audio. Audio stays per line.
- Tapping a sign to open a stop, or any stop list, map or screen not drawn.
- The end of the road (stop 36 finished, the sun reached) and the "not ready" state have no drawing. They use the evening card and their existing sentences until the owner draws them.
- New routes, new tables, new cookies, storage, analytics events, or a new third party.
- Changing the speaking, grading, scheduling, account or deletion rules of jobs 8 to 14.
- Editing anything in `design-drafts/`.

## Build plan

1. **Tokens and parts.** New tokens and fonts, the wash, grain and panels, the type scale, the `Landscape` band, `Button`, `StatusLine`, `SessionFrame` (with the leave sheet), the contrast list, `design.md`, `/design-reference`, and the changed design tests. Old screens run in the new colours. Covers 1 to 9, 21 and 22 (frame part), 42, 47 in part.
2. **The road.** `src/lib/road-types.ts`, `loadRoad()`, the fixture and its build test, the scene, signs, states, bottom cards, the account button, the loading screen, the animation and its tests, replacing the front door. Covers 10 to 20.
3. **The lesson.** Line card, Hear it, the tip and the `firstLesson` field, the word card, Understand it, the consent sheet, Say it states, Keep it states, finished screen with the save note, and Use it if job 16 has landed. Covers 23 to 33.
4. **Account and the rest.** Account profile, email screens, Voice settings, download, delete, the privacy notice with its claim test, feedback, and the error, offline and loading screens. Covers 34 to 41.
5. **Sweep and records.** Browser tests of every drawn screen in both browsers, the phone, small phone, 320 px and 200 percent checks, axe, reduced motion, the protected copy test, the paths test, the evidence screenshots, the list of changed earlier tests, docs. Covers 43 to 50.

**Dependencies.**
- Job 20 (`20-a1-road`, in parallel): the stops, `GET /api/road` and its public form for visitors. This job cannot merge before it. If job 20 does not supply `sampleLine`, the animation drops its bubbles.
- Job 17: the move under `/learn` is not built. Statement 45 covers it. If job 17 merges first it updates the helpers it already updates and this job rebases.
- Job 16: held. Statement 32.
- Word meaning data (statement 27): the manager must place it in job 20 or its own job before the word card can show meanings.
- Preview links wait on the Cloudflare preview keys (todo). Until they exist, the owner and the design reviewer look at the app locally with the throwaway database and the fixture, as in earlier jobs.
- Mailpit in the local check (job 11) for the `@email` tests that already exist and must stay green.
- Switzer: the private font files, only if owner's call 3 keeps Switzer.
- Owner's calls 1 to 15 answered before the build of the screens they touch.

## Risks and flags

- **Look closely: consent.** The sheet shows only a title and a link at first (statement 29). The full text and every rule of job 10 are kept, but whether that is enough to count as informed consent is a legal question I cannot settle. Owner's call 10.
- **Look closely: learner data.** The avatar shows the learner's email letter, the account page shows the email, and download and delete are restyled. Nothing new is stored. The security reviewer checks that the first lesson field and the road route use only the caller's own rows, and that stop text cannot run as markup.
- **Look closely: the privacy notice.** The first layer is new text, and the owner removed a sentence. Layered notices are accepted practice, and a summary of the Article 29 Working Party's transparency guidance (WP260 rev.01) says the first layer should name the controller; I could not read the guidance itself on 1 November 2026 and could not confirm whether it also wants contact details there (summary only: https://natlawreview.com/article/article-29-working-party-releases-guideline-wp260-transparency-under-gdpr). Owner's call 11. This is not legal advice, and `src/privacy/notice-settings.ts` currently names a person, not Exentrik.
- **Look closely: Finnish content.** The opening animation and the word card show Finnish. Both are limited to approved content or left out (statements 17, 26 and 27). Test fixtures use the existing fixture dialogues, and any fixture Finnish stays out of the production build (statement 19).
- **Contrast and size floors.** The drawings fail several of the project's own floors (statements 5 and 6). Owner's call 2.
- **The drawings contradict earlier rules in five places.** Peach wider than the rule (call 1), a due count and minutes on review and two figures on the finish screen (call 7), a Continue on Stop finished against one session a day (call 8), one line at a time in Hear it against job 8 (call 6), and the speaking sheet against job 10's first screen (call 10). Each is a call, and until answered the build follows the recommendation.
- **Job 20 is a hard dependency.** Without its stops the home screen has nothing to draw. The manager decides the merge order.
- **Old phones.** The drawings use CSS the design tests may refuse (gradients, mask, blend modes). The builder checks each against Safari 15.4, which I did not do here, and the design CSS test stays the judge.
- **Big change, many tests.** Statement 43 lists the expected test changes. If the diff or the list grows past it, the builder stops and reports.
- **Running costs.** None. No paid service, no AI call. The work adds no package.

## Owner's calls

No new design direction is asked. The direction was approved on 1 November and the references behind it are in `design-drafts/README.md`. These calls are where the approved drawings, the written rules and the earlier jobs disagree or say nothing. Until answered, the build follows the recommendation.

**1. Where may peach appear?** Your rule in `design.md` says peach only for the words that change. The drawings also use it for the next sign, the sun and fell flags, the recording state, gentle notes, the save note, the delete action and the error mark.
- A. As drawn, and `design.md` is reworded to list these uses (recommended). The road and the warm notes keep their warmth.
- B. Follow the rule. Everything else warm becomes mint or a neutral grey. Peach then means one thing, but the road loses its warm destination and gentle notes lose their friendliness.
- C. A middle way: peach for changed words, the sun and flags, and gentle notes, everything else mint.

**2. The drawn colours and sizes miss the project's own floors. What should give?** White on the mint button is about 3.9 to 1 (floor 4.5), peach text on its wash about 4.0, slate about 4.4 to 5.3 (floor 7 for Finnish lines), and the written line at 14.5 px is under the 17 px floor.
- A. Keep every floor. A few colours get slightly darker, written Finnish is at least 16 px, and you see each changed colour beside the original (recommended). Easier to read for people new to Finnish; a little less soft than drawn.
- B. Lower only the Finnish floors to the standard 4.5 to 1 and 14.5 px. Closer to the drawings; harder on small ä and ö dots, and some colours still need darkening to pass the accessibility check.
- C. Keep the drawn colours exactly. The automatic accessibility check fails, so this is not buildable without removing that check, and I advise against it.

**3. Which fonts?** The drawings use Poppins for everything. The app uses Poppins for headings and Switzer for body text, and the Switzer files are kept out of this public repository by licence.
- A. Poppins everywhere, as drawn (recommended). It is the look you approved, it removes the private font step from the redesign, and previews and tests look the same as live.
- B. Keep Poppins and Switzer. Switzer's body text will differ from the drawings, and previews without the private files show Poppins anyway.
- C. Your usual Geist and Lexend. A new look you have not seen on these screens.

**4. Dark mode.** The drawings are light only. Today the app follows the phone's dark setting.
- A. Light only for now, and the app declares itself light so the phone does not darken it by itself (recommended). Quickest. Learners with a dark phone see a light app.
- B. Draw and build dark versions of every screen in this job. Needs a dark drawing from you first, since I will not invent one, and roughly doubles the contrast list and the screenshots.
- C. Keep the old dark colours on the new layout. A look you have not approved.

**5. Buttons.** The drawings give the primary pill a soft gradient and a glow shadow. Your banned list includes glowing buttons.
- A. Flat mint pill with a plain soft shadow (recommended). Keeps the design tests and your banned list as they are.
- B. As drawn, with the gradient and tinted glow. The allowed gradient list grows by one, and the pills come near your "glow" rule.

**6. Hear it: one line or the whole conversation?** The drawing shows one line card at a time. Job 8 stacks each new line under the earlier ones, so the learner sees the conversation build up.
- A. One line at a time, as drawn (recommended). Calm, and what you approved. The learner no longer sees the earlier lines on screen.
- B. Stacked, as built. Keeps the conversation visible, which helps follow who said what, but it is the crowded look you disliked.

**7. Numbers in the drawings.** The review card shows a count and "About 4 minutes", and Lesson finished shows "+11 new words" and "8 lines said aloud". Job 9 says no count of due words appears anywhere, job 8 says no counts on the finish screen, and you parked the words learned count.
- A. Leave all of it out (recommended). The review card shows "Review" and the button, and the finish screen drops the two figures. No new database reads, and no backlog pressure.
- B. Build them as drawn. Needs new reads in the database and Worker, and reverses job 9's rule for the review count.
- C. Minutes only, from a fixed rule, no counts.

**8. Can a learner go on to the next stop on the same day?** The Stop finished drawing has "Continue", and the Done for today drawing says the next lesson is tomorrow. Today the app has one session a day.
- A. One lesson a day (recommended). Stop finished shows "Next lesson tomorrow" in the evening sky, with the next sign lit and no button.
- B. Allow more. Stop finished has "Continue" in the day sky. This changes the daily rule of jobs 8 and 9 and the pacing job 20 plans.

**9. The day one card and its legal line.** The drawing shows only the stop, "Start" and "Sign in". The app must still say that starting makes a guest account and that PuhuScribe is for adults.
- A. Keep job 8's guest line word for word, small, under the buttons, with a "Privacy notice" link (recommended).
- B. Shorter wording of your own, such as "Starting makes a guest account on this device. For adults, 18 and over." You approve the exact words, and they become the new protected copy.

**10. The speaking consent sheet shows only a title and a link first.** The full text is one tap away and unchanged.
- A. As drawn (recommended on look, not on law). It is the calmest. Whether a title and a link is enough information at the moment of agreeing is a legal question I cannot settle.
- B. As drawn, but "Turn on" first opens "How it works", and a second press confirms. Safer for consent, one more tap, and an extra step before the first recording.
- C. Put one short plain line back under the title ("Your voice goes to a speech service in the EU, then is deleted."). You removed a sentence like it on 1 November, so this reverses your choice.
- Recommendation: A if you accept the legal risk, otherwise C.

**11. The privacy page's first layer and the name it prints.** The drawing says "PuhuScribe is part of the product family of Exentrik, a product studio in Finland." The full notice behind it names the controller from `src/privacy/notice-settings.ts`, which today is a person.
- A. First layer exactly as drawn. The controller is named one tap deeper.
- B. As drawn, plus one small line naming the controller and a link to the contact address (recommended). A summary of the EU guidance says the first layer should name the controller (see Risks).
- Owner input either way: the legal name to print as controller, and its business ID if there is one. If Exentrik is the business, say so and I will use that name. I will not choose it.

**12. What one segment of the progress bar means.** The drawings show 12 segments; the A1 leg has 36 stops.
- A. One segment per three stops, filled when all three are done (recommended). Matches the drawing.
- B. One segment per stop, 36 thin segments. Exact, and busier.
- C. A smooth bar. Always right, and the segment look is lost.

**13. The B2 fell is labelled "B2 · YKI" in the drawing.** "YKI specific content and skill tagging" is on the PRD's "Not in v3.0" list.
- A. Label it "B2" only (recommended). Respects the list.
- B. Keep "B2 · YKI". A label is not content, but it points at an exam the PRD defers, so the PRD owner (you) confirms it.

**14. The brand mark's colour.** The drawing of the loading screen shows the sprout mark on a mint tile. The app's mark is on a violet tile, chosen on 21 October.
- A. Mint, as drawn (recommended). The violet leaves the app.
- B. Keep violet on the mark only. The mark then clashes with the new palette.

**15. Word meanings and word audio.** The word card in the drawing needs an English meaning for every word and for its dictionary form. No such data exists, and audio exists per line only.
- A. Add `meaning` and `baseMeaning` to the content job 20 writes, in the same pass, reviewed like the rest (recommended). The card is complete at launch. Job 20 grows.
- B. A separate small job after job 20. Job 20 stays small, but the word card launches without meanings and I will not invent any.
- Word audio on single words: not in this job. Whole line audio stays. Adding word audio later is a content and cost decision for you.

**Owner inputs (not choices):** the controller's legal name for call 11, and approval of any wording changed by calls 9 and 10.

## Could not verify

- Every contrast figure in statement 6 and the colour of the grain over text. They are my hand calculations; the project's test is the judge.
- Whether each CSS feature the drawings use (`inset`, `mask-image`, `clip-path`, the `translate` and `scale` properties, `mix-blend-mode`) works on Safari 15.4. The design CSS test only refuses a named list.
- What the Article 29 Working Party's guidance requires on the first layer of a notice, beyond the summary I read.
- The EDPB's text on device storage (job 15 cites it; I did not read it).
- Whether job 20 will offer a public stop list for visitors with no account, `sampleLine`, and the route name.
- Whether job 17 or job 16 merge before this job is built.
- The first lesson field's exact query; it needs a look at job 8's session code when building.

## Sources

- Project: `AGENTS.md`, `design.md`, `design-drafts/README.md`, `design-drafts/v1-screens.html`, `design-drafts/road-journey.html`, `design-drafts/written-colour.html`, `factory/progress.md` (owner decisions from 1 November 2026), `factory/jobs/18-save-progress/spec.md`, `factory/jobs/10-speaking-feedback/spec.md`, `factory/jobs/11-accounts/spec.md`, `factory/jobs/9-daily-review/spec.md`, `factory/jobs/8-first-session/spec.md`, `factory/jobs/16-tutor-step/spec.md`, `src/App.tsx`, `src/main.tsx`, `src/screens/` (FrontDoor, FinishScreen, SaveNote, HearIt, UnderstandIt, SayIt, KeepIt, LineCard, AccountPage, PrivacyPage, FeedbackPage, EmailFlow, DeletePage, VoiceConsent), `src/components/` (SessionFrame, WordCard), `src/lib/voice-consent.ts`, `src/lib/session-types.ts`, `src/privacy/notice-settings.ts`, `tests/design-css.test.ts`, `src/styles/tokens.css`
- PRD: `C:/Users/fumna/dev/exentrik-os/products/puhuscribe/PUHUSCRIBE_V3_PRD.md` (the "Not in v3.0" list, as copied into `AGENTS.md`)
- WCAG 2.2, Understanding Success Criterion 2.2.2 Pause, Stop, Hide (read 1 November 2026): https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html
- Article 29 Working Party transparency guidelines WP260 rev.01 (summary only; the guideline itself, https://www.edpb.europa.eu/system/files/2023-09/wp260rev01_en.pdf, was in the search results and not read): https://natlawreview.com/article/article-29-working-party-releases-guideline-wp260-transparency-under-gdpr

Result: ready for owner approval

## Owner's answers (1 November 2026)

Recorded by the manager from the owner's own words in chat. These replace the recommendations above where they differ.

- **1. Peach:** A, as drawn; `design.md` lists the uses. (Recommended default; the owner asked the manager to decide the remaining design points: "Decide about the design.")
- **2. Floors:** A, keep every floor; show each changed colour beside the original. (Recommended default.)
- **3. Fonts:** A, Poppins everywhere. (Recommended default.)
- **4. Dark mode:** A, light only for now. (Recommended default.)
- **5. Buttons:** A, flat mint pill. (Recommended default.)
- **6. Hear it:** A, one line at a time. (Recommended default.)
- **7. Numbers:** the review card shows the count and the minutes, as drawn ("it looks good on the review waiting on the road"). Lesson finished uses option C of `design-drafts/numbers-question.html`: a panel headed "N new words" with the new words as tappable chips, no "lines said aloud" box. Signed-in learners see no save note.
- **8. Pacing:** no daily limit ("anyone who wants to do more than one session a day is free to do so"). Stop finished keeps its Continue button; Done for today appears only when no lesson or review is left.
- **9. Legal line:** A, keep job 8's guest line, small. (Recommended default.)
- **10. Speaking consent:** as drawn, title, How it works, Turn on, Not now; the details live on the privacy page ("it can be on the privacy page."), and How it works opens that section.
- **11. Privacy first layer:** as drawn; the controller stays the owner as a person for now ("Keep me for now"), named one tap deeper as today.
- **12. Progress bar:** A, one segment per three stops. (Recommended default.)
- **13. B2 label:** A, "B2" only. (Recommended default.)
- **14. Brand mark:** mint ("Mint, as drawn (Recommended)").
- **15. Word meanings:** in job 20, written by Claude in working sessions.
- **Save note wording (new):** "Create an account to save your progress." with a "Create account" button, centred. This replaces job 18's "Add your email to save your progress." and its button; the email screen's title becomes "Create your account". The save-note copy test changes to the new words as an owner's change, listed in build.md.
