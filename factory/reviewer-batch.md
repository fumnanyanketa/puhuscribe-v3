# The list for the native reviewer

29 October 2026. The MVP is built and main is green. These six dialogues are drafted and wait for the native reviewer. Each one has a review page, one self contained file that opens from disk and plays the audio for both registers. The reviewer fills in the page and sends back a small file. A reviewer who answers "not yet, fix these" can still send the file.

| Unit | Dialogue | Review page |
|---|---|---|
| 1 Meeting someone at work | A new colleague | `content/drafts/meeting-people-new-colleague/review/round-1.html` |
| 1 Meeting someone at work | At a language café | `content/drafts/meeting-people-language-cafe/review/round-1.html` |
| 2 Ordering coffee and a pastry | At the café counter | `content/drafts/ordering-coffee-at-the-counter/review/round-1.html` |
| 2 Ordering coffee and a pastry | Asking the price and paying | `content/drafts/ordering-coffee-paying/review/round-1.html` |
| 3 At the grocery store | Asking where something is | `content/drafts/grocery-store-asking-staff/review/round-1.html` |
| 3 At the grocery store | Following simple directions | `content/drafts/grocery-store-directions/review/round-1.html` |

## How the pages reach the reviewer

- Today only the first dialogue is listed in `review-site/dialogues.json`. The private review site at puhuscribe-review.exentrik.co is built but not deployed, because the Cloudflare setup in the Exentrik account is not done.
- Until then the pages can be sent as files. Nothing is published until a reviewer approval is back, a new round is made if lines change, and the publish step runs.

## Also waiting for the reviewer

- The corrections list for the 104 sentences carried over from version 2 (job 3, statement 15). It was not found in version 2.
- The to do notes about the second brief of unit 2, which says tea and a bun while the dialogue has coffee only, are in `factory/todo.md`.
