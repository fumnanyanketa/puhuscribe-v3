# Design brief

The direction behind PuhuScribe v3's look, from job 5-design-system. The values themselves are in [design.md](../design.md); this file holds the decisions and their sources only.

## The direction

PuhuScribe v3 uses v2's own look, improved: v2's register card, colours, fonts and black pill buttons, with the spoken word lit as the audio plays, an audio player at the bottom, and calmer spacing.

- Chosen by the owner, Fumnanya, on 21 October 2026, after seeing three drawn directions (A, B and C on the look options page, `factory/jobs/5-design-system/look-options.html`) and rejecting all three in favour of v2's design.
- Owner's clarification the same day: v2 is a starting point, not a copy. Take its colours and general layout, then improve them with ideas from the look options page, mainly direction A.
- The owner approved the sample screen (the Hear it step, `/sample/hear-it`) on 21 October 2026, with two changes: Switzer for body text, like v2, and v2's white to lilac fade back on the page background.
- The full record is in `factory/jobs/5-design-system/summary.md`.

## What it draws on

| Source                                                             | Link                                                                                                                                          | What is borrowed                                                                                                                                                                                                                                                                                    |
| ------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PuhuScribe v2                                                      | https://puhuscribe-v2.vercel.app and https://puhuscribe-v2.vercel.app/landing, plus the owner's Claude Design handoff in `design/v2-handoff/` | The register card pairing written and spoken Finnish with a connector, the azure flag on changed words, the white to lilac ground, ink colours, violet and teal registers, soft white cards and shadows, the radius and spacing scale, black pill buttons, Poppins and Switzer, the sprout wordmark |
| Apple Podcasts transcripts (spec reference 7)                      | https://www.apple.com/newsroom/2024/03/apple-introduces-transcripts-for-apple-podcasts/                                                       | Each word lit as the audio reaches it                                                                                                                                                                                                                                                               |
| Speak (spec reference 1)                                           | https://www.speak.com/                                                                                                                        | One phrase in focus, playback controls along the bottom within thumb reach                                                                                                                                                                                                                          |
| Google AI Edge dictation app (Pinterest find 1)                    | https://www.digitaltrends.com/computing/googles-new-free-dictation-app-is-the-willow-alternative-you-have-been-waiting-for/                   | Large round controls at the bottom, the text in one quiet card                                                                                                                                                                                                                                      |
| Minimal voice message row (Pinterest find 3, source not traceable) | https://www.pinterest.com/pin/847943436091942914/                                                                                             | One slim waveform beside a play button                                                                                                                                                                                                                                                              |
| Oura app by Instrument (spec reference 6)                          | https://www.instrument.com/work/oura-app                                                                                                      | Colour used only to direct attention; a quick view, a focused view (the word card) and a deep view                                                                                                                                                                                                  |
| Helsinki Design System (spec reference 5)                          | https://github.com/City-of-Helsinki/helsinki-design-system                                                                                    | Accessibility as the floor, a thick focus outline, messages that never rely on colour alone. Not its look or palette                                                                                                                                                                                |

What is left out of v2, by the owner's banned list: small uppercase labels, 01 and 02 numbering, the glossy speech bubbles and orb gradients, glass effects, icon squares on every card, decorative pills, and the streak counter.

## Answers to the owner's calls

- **Call 1, the direction:** v2's look, improved, as above.
- **Call 2, brand assets and the mascot:** reuse v2's wordmark and sprout icon, flat with no gloss (`design/assets/`). No mascot now; Otso is decided with the tutor job (job 12). No spending.
- **Call 3, samples before the build:** one sample (the Hear it step), which the owner approved on 21 October 2026 before the rest was built.
- **Spending and email:** nothing paid. Switzer is free under the ITF Free Font License, which the owner approved accepting on 21 October 2026.
