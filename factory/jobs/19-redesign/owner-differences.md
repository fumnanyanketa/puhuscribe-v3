# Round 6: make the app match the drawings

On 2 November 2026 the owner looked at the app beside the drawings and asked for every difference they did not approve to be fixed: "Let it look exactly like the drawing that we had." The manager compared all 34 pairs in `evidence/` (`NN-*-drawing.png` against `NN-*-app-webkit.png`, or `-app-chromium.png` for Say it, since this WebKit has no recorder). This file is the work list.

## The rule for this round

- The drawings are the source: `design-drafts/v1-screens.html` and `design-drafts/road-journey.html`. Read their CSS, not only the pictures. Match layout, positions, proportions, shapes, edges, shadows, icon styles, text weight and which elements exist. Sizes follow the spec's type table (drawing size x 1.25, with the floors of call 2).
- Only these differences stay, because the owner approved them in the spec or in "Owner's answers": the colour darkening of call 2 and the type floors; Poppins (call 3); light only (call 4); flat mint buttons, no gradient (call 5); one line at a time in Hear it (call 6); review count and minutes, finish chips (call 7); Continue on Stop finished (call 8); the guest line and the Privacy notice link on day one (call 9); the short speaking consent sheet (call 10); "B2" without "YKI" (call 13); the protected texts of statement 3; the "Where the build differs" list items 2, 3, 4, 7, 8, 9; real stop names and real lines instead of the drawings' sample words.
- The protected texts stay word for word, but they must be small and quiet as call 9 says: 12 px (the floor), quiet colour, centred where the drawing centres its small text. They must not look like body copy.
- Anything the app shows that the drawing does not, and that is not in the list above, goes. If it carries a status for screen readers (for example "Line 1 of 3."), keep it visually hidden. If it carries a function, give the function the drawing's own control (see each screen).
- Measure, do not eyeball: put the drawing and the app at the same width and check positions.

## Everywhere

1. **Progress bars and lesson segments.** Drawing: solid pills, unfilled part pale white (no outline), filled part mint. App: hollow pills with a mint outline. Match the drawing on the road top bar, the bottom card's lesson segments and every lesson progress bar. If the pale track fails a contrast floor for non-text marks, use the lightest mint track that passes, still without an outline.
2. **Secondary buttons** ("Got it", "Not now", "Leave", "Keep my account", "Play mine", "Try again", ä and ö keys, the code boxes). Drawing: white or milky pill with a very pale edge or soft shadow. App: a strong 2 px mint outline. Use the drawing's pale edge.
3. **Text fields** (email, code boxes, feedback, Keep it answer). Drawing: milky field with a soft shadow, no visible outline, placeholder text inside ("Your email", "What worked, what didn't, what broke."). App: white field with a mint outline and a bold label above. Use the drawing's field. The label becomes the placeholder plus a visually hidden label. Focus may show the mint edge.
4. **Quiet text buttons** ("How it works", "Why does it change?", "Send a new code", "Start as a guest instead", "I don't remember", "I can't speak right now"). Match each drawing: some are mint with no underline ("Why does it change?"), some are small, quiet and underlined. App versions are larger and darker.
5. **Headings.** Screen titles in the drawings ("What does Maria ask?", "Create your account", "Type the missing word", "Welcome back") are medium weight and ink. App headings are bold 600. Use the drawing's weight on every screen.
6. **The cross and back buttons.** Drawing: a small white round (about 26 px drawn) with a soft shadow. App: 44 px round. Keep a 44 px tap area but draw the visible round at the drawing's size.
7. **Page title next to the back button.** The drawings show it on Voice settings, Download my data, Send feedback and Your account. The app is missing it on Download my data. Match each drawing.
8. **Landscape band.** The heading sits below the band in the drawings. On Understand it and Keep it the app's heading and "Word 1 of 1." touch the band. Match the drawing's spacing.

## The road (screens 02 to 06)

9. **Scene height.** The app's fells, sun and horizon sit about 75 px lower than the drawing, leaving an empty band under the top bar. Move the scene up so the B1, B2 and A2 flags and the sun sit where the drawing has them.
10. **Sun.** Match the drawing's sun size and its wide soft glow.
11. **Road bend.** Put `BEND` back to the drawn 34. Match the road's width at the sun and at the bottom, and let the road run on behind the bottom card as drawn.
12. **Upcoming signs.** Drawing: a small milky pill with the stop name only, quiet text, no number, one line. App: a large pill with a number badge, wrapping to two lines. Remove the number from upcoming signs, use the drawing's size and padding, keep names on one line (shrink to the floor if needed, never wrap), and place them where the drawing places them, higher and smaller toward the horizon.
13. **Signs must not cover the sun, its "A1" or the fell labels.**
14. **Done signs.** Drawing: the tick sits in a small white rounded square. App: a bare tick.
15. **Current marker.** Drawing: a white dot on a mint disc with a wide pale mint halo ring around it. App: a small dot with no halo.
16. **Bottom card.** Drawing: slightly see-through milky card (the road shows faintly through it at the bottom), "Stop 3 · lesson 2 of 4" with a middle dot. App: opaque white, "Stop 3, lesson 3 of 4". Use the middle dot as drawn, on every card state, and the drawing's card translucency.
17. **Day one card.** "Have an account? Sign in" is centred as drawn. The guest line and the Privacy notice link sit under it, small (12 px), quiet and centred.
18. **Review card.** The count tile's number is peach deep as drawn (the app's is ink).
19. **Done for today.** Drawing: "Done for today" with "Next lesson tomorrow". App: "Your next review is tomorrow." Use the drawing's wording unless it would be untrue; say in build.md which state shows which line.

## Lesson screens (07 to 14, 26 to 28, 32 to 34)

20. **Hear it tip (07).** The legend dots and text, and "Got it" (white pill with a soft shadow, no mint outline), as drawn.
21. **Word card (08).** The close cross sits in a white round. "Why does it change?" is mint with no underline. Remove the visible "Plays the whole line." (keep it in the buttons' accessible names). "Patterns you've seen" stays (approved) but styled like "Why does it change?". Show the meaning's context in grey after the meaning as drawn ("as in "those strawberries"") if the data has it; if not, say so in build.md.
22. **Understand it (09).** Show the step name "Understand" at the top right, like every other step. The line card has its play button on the left as drawn. Answer options as drawn: white pills, with the chosen one getting a mint edge and a mint tick. Remove the visible "Choose what the line means." unless it is the rule the spec keeps; if it is, make it small and quiet.
23. **Say it (11).** The mic button has the drawing's double soft halo. "Tap and say the line" as drawn. Remove the visible "Line 1 of 3." (keep it visually hidden).
24. **Say it, try again (34).** Drawing: the peach note sits above the mic, there are no "Play mine" and "Try again" buttons, and Next line is pale until the learner tries again. Match it, or say in build.md which job's rule needs the buttons.
25. **Say it, clear (33).** "That was clear." left-aligned with the tick, as drawn.
26. **Lesson finished (13, 14).** No top bar with the cross, progress bar and "Lesson finished". The sentence card shows only the spoken line, centred and bold, with the English under it, as drawn (no speaker, no written line, no play buttons). The word chips are small, at most five, then a "+N" chip, as drawn. The guest's save note card ("Create an account to save your progress." with a "Create account" pill) shows as drawn. The bottom line is small, quiet and centred under Done: "Saved on this device." for a guest and "Saved to your account." when signed in.
27. **Keep it (26).** The heading "Type the missing word" sits at the top as drawn. Remove the visible "Word 1 of 1." (keep it visually hidden). The card shows the spoken and the written line, each with its blank, as drawn, with no play button. The input is the drawing's milky field. ä and ö are plain white rounds.
28. **Keep it, right and close (27, 28).** Keep the heading and the input showing what the learner typed: right gets a mint edge and a mint tick inside the field, as drawn. The answer word is highlighted in peach in both lines. Right shows "Right. Same in both." (or the drawing's equivalent when the forms differ), small and centred above Next. Close shows the peach note "Close. It has a double l: kortilla." style, under the field. Remove "The word is ... in spoken and written Finnish." and "You wrote ..." as visible text (keep them visually hidden if the spec needs them for screen readers).

## Account and other pages (15 to 25, 31)

29. **Account (15, 16).** The avatar is smaller with a mint ring and a grey letter, overlapping the landscape band as drawn. "Speaking feedback" shows "On" with no chevron. The guest's save note is the peach bar from the owner's answers: "Create an account to save your progress." with a plain "Create" text button, as drawn (the app still says "Add your email to keep your progress." with an "Add" pill; this wording was replaced by the owner on 1 November). "Delete my account" shows at the bottom for a guest as drawn. Signed in: "Sign out · Delete my account" with the dot, Sign out not underlined.
30. **Create account (17).** Field and Send code as drawn: the field under the subtitle, Send code at the bottom of the screen. The two protected warnings stay, small and quiet (12 px), under the field. "We send you a 6-digit code." is the drawing's subtitle; if the longer sentence is a protected text, keep it small and quiet instead. The Privacy notice link: small and quiet at the bottom, or removed if no rule needs it on this screen.
31. **Enter the code (18).** "Sent to alex@example.com" as the subtitle, as drawn. Six code boxes at the drawing's size. "Send a new code" is the small underlined link under the boxes; while it waits, it is greyed and reads the wait ("Send a new code in 0:45"). Confirm sits at the bottom, pale until six digits are in. Remove the "Use another email address" pill (the back button does it) and the separate wait sentence. Same rule for the Privacy notice link as item 30.
32. **Sign in (19).** Title "Welcome back", subtitle "Enter your email for a code.", the drawn field, Send code at the bottom, "Start as a guest instead" small and underlined under it. Same rule for the Privacy notice link.
33. **Voice settings (20).** Two separate milky cards as drawn: "Speaking feedback" with its switch, and "Keep my recordings" with "So I can hear my progress. 90 days." and its switch. Remove "Your voice settings are shown below." The longer consent wording moves behind the privacy page, as call 10 did for the speaking sheet, unless it is a protected text; then it shows small and quiet under the card. "My recordings" shows only when there are kept recordings. "Delete my recordings" is the milky button at the bottom as drawn, when there is something to delete.
34. **Download ready (21).** Title "Download my data" next to the back button. "Your file is ready" with no full stop, as drawn.
35. **Delete my account (22).** Keep it a page (approved), but draw it as the drawn bottom sheet: the account page dimmed behind, with the sheet at the bottom and its handle. The delete warning stays word for word (protected).
36. **Privacy notice (23).** The title "Privacy notice" in the page, large and quiet green as drawn, not in the header. Section headings in mint as drawn. The voice details from call 10 sit behind a "More about your voice" tap in the "Your voice" section, so the first layer reads as drawn (call 11).
37. **Send feedback (24).** The heading "What should we know?", then the drawn milky box with its placeholder, Send at the bottom. The protected privacy line sits small and quiet under the box. The character count shows only when 100 or fewer are left.
38. **No connection (25).** The drawing's soft mint cloud with the peach slash, not a line icon. "Try again" is the full width mint button as drawn. "Your progress is safe. Try again when you're online." as drawn.
39. **Something went wrong (31).** Matches, apart from the approved missing line.

## How to prove it

- Retake every app screenshot at 375 x 812 in WebKit and Chromium, and add a side by side picture per screen (drawing left, app right, same width) to `evidence/round6-pairs/`.
- Write in build.md, per item above, what changed or why it could not match.
- Update the design tests that pin the old look only where this list changes the look on purpose. No test that protects text, focus, contrast or behaviour may be weakened.
