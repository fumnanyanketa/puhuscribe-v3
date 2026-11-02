# Job 19: Every screen in the approved v1 design

Flag: look closely. It changes every screen a learner sees, including the consent sheets, the account pages and the privacy notice. Cost €0: no new service, package or AI call.

## What changes for you and your learners

1. Every learner screen now looks like the drawings you approved on 1 November: the soft mint and peach wash, milky panels, fine grain, a small landscape behind each screen, mint for spoken Finnish and slate blue for written Finnish. The fonts are Poppins, and the app is light only for now.
2. The home screen is the road to the A1 sun, with the A2, B1 and B2 fells beyond it. Each stop is a sign. The card at the bottom shows Start, Continue, Review or Done for today. A first visit plays a short road animation that can be skipped.
3. The road now reads job 20's real road. A visitor who has not signed in sees it with no progress, and nothing is created until they press Start.
4. There is no daily limit. A learner can do as many sessions as they want, as you decided.
5. The lesson finished screen shows "N new words" with each new word as a tappable chip. The review card on the road shows the count and the minutes.
6. Saving progress now says "Create an account to save your progress." with a "Create account" button.
7. All the words that warn a learner or ask for consent stay word for word. A test freezes them. The speaking consent sheet is shorter, as you decided, and its details live on the privacy page.

## Checks and review

- GitHub checks on branch `factory/19-redesign`: all green on run 41424781086, first try. 720 browser tests in Chromium and WebKit at phone size, plus the unit and database tests.
- Security review: pass.
- Design review: pass after three rounds. The last fixes stopped road signs overlapping on short phones, let the word card scroll inside itself on small screens, and stopped any sentence being said twice.
- Evaluator: pass after three rounds. It found that very long Finnish words did not wrap, that Safari lost the keyboard focus after a sheet closed, a double tap that skipped a line, and two tests that failed on timing. All are fixed, and each fix was broken on purpose to prove its test goes red.

## Decisions the manager made on your behalf

- The road bends a little more than the drawing (the curve setting is 48, the drawing used 34). On a real phone the picture is larger and the bottom card hides the lowest part of the road, so 48 makes the S read as it does in the drawing. The design reviewer agreed. It is one number and can be changed back in a minute.
- A few mint, peach and slate shades are slightly darker than drawn, so text stays readable. This follows your call 2.

## Small things noted, not fixed

- On the 375 px screens a sign covers most of the "A2" label, and on the smallest screen with large text the current sign covers most of the "A1" on the sun. These are scenery labels, not buttons.
- When very large text is on, the keyboard focus outline round a tappable word runs over the text on the next row.
- The consent sheet that opens by itself in Say it has nothing that opened it, so after it closes, screen readers start from the top of the page.
- The English word meanings from job 20 are not shown on the word card yet. That is wired in a small follow-up job after this merge.

## What happens after you approve

1. The job is merged. The new look goes to the test project after the merge checks pass.
2. The manager wires job 20's word meanings into the word card.

## Owner approval
