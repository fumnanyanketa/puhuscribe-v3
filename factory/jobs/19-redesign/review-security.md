# Security and privacy review: 19-redesign, round 1

Reviewed commit 44e9d3e against main (`git diff main...HEAD`), with the spec and build.md. No `.env*` file was read.

## Findings

No must fix findings.

### 1. should fix: the "Keep my recordings" text is shown nowhere, but retention consent is still stamped with its version

- File and line: `src/screens/VoiceSettings.tsx:99-104` (the switch and its hint), `src/lib/voice-consent.ts:37-38` (`keepBox`), `worker/speech.ts:190` (stamps `VOICE_NOTICE_VERSION` on every consent row).
- Risk: a learner can turn on keeping their voice recordings for 90 days without first seeing what that means, because the off hint says only "Your recordings are deleted as soon as your feedback is ready", while the consent record claims the learner saw the `keepBox` sentence.
- Why it matters: `keepBox` is frozen by `src/screens/protected-copy.test.ts` but nothing renders it. A grep of `src` finds no use outside the type and the test. Statement 29 said the unticked box and its text would be shown from "How it works", and statement 43 says protected copy may only get smaller and quieter, not disappear. The 90 day and "first and latest try" facts appear only after the switch is on (line 102), and in the hidden full notice.
- Fix: make the off hint of the Keep switch the `keepBox` sentence ("We keep your first and latest try of each line for 90 days. You can delete them at any time."), taken from `voiceNotice()`, so the words are read before the press. Also show `keepBox` in the privacy page voice section next to `changeLater` (`src/screens/PrivacyPage.tsx:97-103`). Add a test that the text is on screen.

### 2. should fix: the consent sheet carries no information, and the speech service's country is no longer shown anywhere

- File and line: `src/screens/ConsentSheet.tsx:55-80` (title, link and two buttons only), `src/screens/PrivacyPage.tsx:77` (`voiceNotice(null)`).
- Risk: "Turn on" records a granted consent from a sheet that names no processor, no purpose and no deletion rule unless the learner opens the link, so the consent is weaker as proof of an informed choice.
- Why it matters: the owner said consent details may live on the privacy page, and the page does show all four consent paragraphs word for word, so this is accepted as a design. Two gaps remain. The privacy page passes `null`, so it says "in the EU" and never the country (for example Italy), which the old consent screen did show; the `region` prop on the sheet is now used for nothing visible. Also the link opens in a new tab, so a learner who skips it sees no notice at all before the first recording.
- Fix: put one plain line on the sheet under the title, for example the first two sentences of `voiceNotice(region)` (record only while the button is on, sent to Microsoft's speech service in the EU, deleted when feedback is ready). Or keep the sheet as drawn and ask the owner to confirm in writing that a link alone is enough. Either way show the country on the privacy page, or drop the claim that it is shown.

## Checked and passing

- Statement 16 (loading creates nothing): `RoadScreen.tsx` calls only `GET /api/today`, `GET /api/road` and, for a signed in learner, `GET /api/me`. `POST /api/guest` happens only in `start()` (line 118). `GET /api/today` without a cookie returns before any database call (`worker/api.ts`, frontDoor). Test at `e2e/redesign-road.spec.ts` counts zero guest calls.
- Statement 17 (animation stores nothing): the animation is driven by a React state flag only. No storage, cookie or request is added. A grep of `src` and `worker` for `localStorage`, `sessionStorage`, `indexedDB`, `document.cookie`, `caches` and `serviceWorker` finds only a comment in `src/lib/recorder.ts`. Browser tests assert empty storage and cookies (`e2e/redesign-road.spec.ts:302,413`, `e2e/redesign-lesson.spec.ts:257`) and a rule test scans the source (`tests/redesign-rules.test.ts:110`).
- Statement 44: `git diff --stat main...HEAD -- package.json package-lock.json wrangler.jsonc supabase worker/providers worker/personal-data scripts` is empty at this head (only `index.html` changed, one meta tag). Fonts come from `@fontsource/poppins` in the bundle. The only `https://` strings in `src` are the data protection ombudsman link, a code comment, and the SVG namespace in a data URI. No CSS `url()` points off site. `e2e/redesign-road.spec.ts:406-412` checks that every request goes to the page's own origin.
- Browser calls only `/api/*`: all new calls go through `callApi`, which uses same origin `fetch`. No new Supabase or provider call from `src/`.
- New Worker reads (`worker/api.ts`, `worker/learner-db.ts:342-346`, `worker/session-plan.ts`): `reviewCount`, `firstLesson` and `newWords` use the caller's own token and rows (`cards` has an own rows read rule in `20261020090100_learner_model.sql:199`). A failing read never breaks saving. They return only approved dialogue content and counts. No new table, grant or policy.
- Protected copy (statement 43): `GUEST_LINE`, the email screen warnings, `DELETE_TEXT`, `FEEDBACK_INTRO`, all of `voiceNotice()` and the save note copy are compared word for word in `src/screens/protected-copy.test.ts`. The guest line is on the day one card (`src/road/RoadCard.tsx:83`). The delete page keeps its two press flow (page, then "Delete for good") and the full warning. "Turn on" sends `chooseVoice('turn_on', false)` from both Say it and Voice settings, so retention never turns on by default, and no microphone request happens on the sheet.
- Injection and redirects: no `dangerouslySetInnerHTML`, `innerHTML` or `eval`. Road data strings are capped and rendered as text (`src/lib/road-data.ts`). The only `location.assign` targets are fixed paths. The `?notice=` and `?from=` values are looked up in fixed lists.
- Privacy first layer (`src/privacy/first-layer.ts`): each claim is mapped to an inventory line and tested. The retention numbers (90 days guest, 24 months email) match `HOW_LONG`. The page still calls no `/api` route.

## For the owner to look at closely

- Consent. The sheet is shorter than before and the information sits one tap away in a new tab. That was your call, and it is lawful only if the privacy page voice section is clear and the learner is told to read it. Findings 1 and 2 are the smallest changes that keep the consent record honest.
- The first layer of the privacy notice does not name the controller or give a contact. "Who is responsible" and the contact address are one tap deeper, behind "Read the full notice". That is a normal layered notice, but the contact route for privacy requests is no longer visible from the first screen. The first layer's "Exentrik, a product studio in Finland" is your sentence, while the full notice names you as a person as controller. Check you are comfortable with both.
- The Worker has no site wide content security policy (only the owner page has one, `worker/owner.ts:115`). "No font or image host" is enforced by tests, not by the browser. A later job could add one.
- Statement 44 was tested against the test mocks. The real `GET /api/road` and its visitor form arrive with job 20, so the "same origin only" and "401 for visitors" checks need a re-run after that merge.

Result: pass

## Round 2 re-check (branch tip 921739a)

### Finding 1 (keepBox text): fixed

- `src/screens/VoiceSettings.tsx` now builds the Keep switch help text from `voiceNotice(state.region).keepBox`, with "On." or "Off." in front. The 90 day sentence is read before the press. `src/screens/PrivacyPage.tsx` shows `notice.keepBox` in the voice section. `e2e/redesign-pages.spec.ts` checks both the off and on text. The text the consent record is stamped with is now on screen.
- Note, not a defect: the help text reads "Off. Keep my recordings so I can hear my progress. We keep ...", which repeats the switch name. It is accurate and accessible. The design reviewer may want a smoother wording, but that is not a security matter.

### Finding 2 (country, and consent sheet): fixed for signed-in learners, sheet left as the owner chose

- `PrivacyPage.tsx` makes one `GET /api/voice` and uses only `region` from the answer. The route needs a sign in (`worker/api.ts:502`, `worker/speech.ts:119-128`, `kit.signedIn` refuses first), so a visitor gets a 401, no database call, nothing created, and reads "in the EU". The answer is the caller's own data, the request sends nothing, and nothing is stored (the page reads no cookie and writes none). The effect guard stops a second request under React strict mode. A learner who opens "How it works" from the consent sheet is signed in (a guest cookie), so they see the country.
- The sheet itself still shows only the title and link. That is the owner's decision and I do not raise it again.

### The two loosenings

1. `[accounts 16]` in `e2e/account-pages.spec.ts:106-115`: acceptable. The test went from "no /api call" to "the list of /api calls is exactly `GET /api/voice`", plus an assertion that a visitor sees "service in the EU." and that `document.cookie` is empty. It is still an equality check, so a second call, a POST or another route turns it red. It is not weakened beyond what the change needs. Keep the exact list assertion.
2. `src/privacy/processors.ts` text: acceptable and true. "In the EU. The voice section at the top of this notice names the country when you have an account." matches the behaviour. The old sentence ("named on the speaking feedback screen") was no longer true. No claim in it is stronger than the code. `NOTICE_UPDATED` already carries the 1 November 2026 date.

### Should the notice name the country for visitors too?

Not required, and I recommend against a hard coded constant. GDPR Article 13 asks for the recipient (Microsoft Azure Speech is named) and for any transfer outside the EU (there is none, and "in the EU" says so). Naming the member state is good practice, not a legal duty. Visitors also cannot give voice consent, because only a signed in learner can turn speaking feedback on, so the people who need the country can see it. A constant would be a second place that holds the region. If the Worker's region setting changes and the constant does not, the notice would state something false about where voices go, which is worse than saying "in the EU". If the owner wants it for everyone later, add a public read of the region from the same setting that picks the provider (`worker/providers/speech-feedback.ts:209`), or a test that ties a constant to that map. Leave it for a later job.

Round 2 result: pass. Nothing remains that must be fixed.

Result: pass
