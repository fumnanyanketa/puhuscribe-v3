# Screen redesign drafts

The owner paused all building on 1 November 2026 to design every v1 screen first. Each draft here is a static page of phone mockups. Nothing in this folder is app code.

- `draft-1.html`: the five key screens (Welcome, Today, Hear it first time, Understand it, Session finished), each without a mascot and with Otso. Published for the owner at https://claude.ai/artifact/MbnYNYRvnvscQ2tZdBrYD4
- `draft-2.html`: the same five screens after the owner's notes: no mascot ("it doesn't work for me at all"), and the line card kept in its app style (dots joined by a dotted line, changing words marked in blue, black play buttons). The words learned count is parked by the owner. Same link, version 2.

## References

Owner's own references (shared in chat, 1 November 2026): Elingo, a purple home services app, AgriPlant, Farm2Table, LingoLink, Yatre, "8 essential app screens", memolingo, Play Language.

Real shipped apps, checked on their App Store pages on 1 November 2026:

- Speak, https://apps.apple.com/us/app/speak-language-learning/id1286609883: one big phrase per screen, single highlighted word, white cards on dark blue, a round mascot.
- Duolingo, https://apps.apple.com/us/app/duolingo-learn-languages/id570060128: thick progress bar, 2 by 2 picture answer tiles with a chunky edge, character speech bubbles, word bank chips.
- Babbel, https://apps.apple.com/us/app/babbel-language-learning/id829587759: big round microphone with rings, dialogue as chat bubbles, photo inside a rounded card. Its cream, serif and orange look is on the owner's banned list, so only the layouts are borrowed.
- Busuu, https://apps.apple.com/us/app/busuu-language-learning-app/id379968583: photo led, a chapter path with one highlighted next step.
- Praktika: store page not reached; its 4.0 redesign post is https://praktika.ai/blog/praktika-4-0

None of the five was found showing a prominent "words learned" number with a stated definition, so PuhuScribe's count is our own design.

- `draft-3.html`: the Today screen as a journey of the six units as real-life situations (PRD changed by the owner, 1 November 2026), in three one-colour palettes (lavender, lake blue, birch-forest green), each soft with no glass and with glass only on the top and bottom bars. Published at https://claude.ai/artifact/BpN2PPPXC8tRtf5mA5YxkR
- `draft-4.html`: Welcome, Today (with the journey) and Hear it in the soft milky look of the owner's gym app reference (`reference-soft-gym-app.jpg`, shared 1 November 2026), in lake blue and birch-forest green only; the owner dropped lavender. Published at https://claude.ai/artifact/VLsnPKZAw9NToeTjm1wgJj
- `draft-5.html`: draft 4 with a second, warm accent, as the owner asked ("we need a second accent color", like the reference's green and orange). Mint and peach (from the reference), lake blue and coral, forest green and orange. The first colour is for everything tappable; the warm one marks the words that change, the review count and the goal. Published at https://claude.ai/artifact/JLGD2YpyeCYubY6dmazhX5
- `draft-6.html`: one whole lesson (Hear it, word card, Understand it, Say it, Say it feedback, Keep it, Session finished) in the owner's two shortlisted pairs: mint and peach (the owner's leading choice) and lake blue and coral. Published at https://claude.ai/artifact/M1YGkx7zRfj7YXDJzW5qL6
- `draft-7-journey.html`: the journey in mint and peach (the owner's final palette, 1 November 2026) with smaller text: the route of stops, inside a stop, a locked stop, and the unlock moment. Stop and lesson names here are examples.
- `opening-animation-1.html`: two playable ideas for the first-open animation the owner asked for (where you are, where you are going, then into your first stop): one word becoming a conversation, and one line from you to A1. About 4 seconds, with Skip.
- `road-journey.html`: the owner's merge of both opening ideas on a road ("let it look more like a road", after the Yatre reference): the road runs in perspective to A1 on the horizon, stops are signs, each sign shows a line said there, then the view moves in to the first stop. Also the journey on day one and three stops later. Stop names and "24" are examples until the curriculum is decided.

## Glass and journey references (1 November 2026)

- Apple Human Interface Guidelines, Materials: glass only on controls and navigation, never on the content layer, used sparingly. https://developer.apple.com/design/human-interface-guidelines/materials
- WWDC25 "Meet Liquid Glass": no glass on glass, tint only the one main action, design a fallback for Reduce Transparency. https://developer.apple.com/videos/play/wwdc2025/219/
- Speak's December 2025 home path: one colour, one pulsing "next" marker, stops fill as they are finished. https://help.speak.com/en/articles/11430473-explore-your-new-home-screen
- Duolingo's path (2022, still current): one route, tap a locked stop to see why. https://blog.duolingo.com/new-duolingo-home-screen-design
- Transit apps (Citymapper, Transit): a dot per stop on a line that fills behind you, and a "stops left" count.
- No verified source gave palette colours; the three palettes in draft 3 are our own starting points.

## How much content A1 needs (research, 1 November 2026)

- Milton and Alexiou 2009: English A1 under 1,500 lemmas, French A1 about 1,160, Greek (heavily inflected, the closest analogue to Finnish) about 1,490. https://www.enl.auth.gr/gala/14th/Papers/English%20papers/Milton&Alexiou.pdf
- LanguageCert: about 95 guided learning hours for A1. https://www.languagecert.org/Guided-Learning-Hours
- Duolingo Finnish (third-party tracker, July 2025): 35 units, about 1,100 words, ending around A1. https://duolingodata.com/dat/fifen35v2.html
- No Finnish source gives an official A1 word count; integration training targets B1.1 in about a year. https://www.oph.fi/fi/tilastot-ja-julkaisut/julkaisut/kotoutumiskoulutuksen-opetussuunnitelman-perusteet-2022
- Working conclusion (judgment, not a published figure): about 800 to 1,000 core words for a comfortable A1 in Finnish. The PRD's v3.0 target was about 180.

## Opening animation references (1 November 2026)

- MapTiler, animated routes: a short camera move in, the route drawn, then back to the start. https://www.maptiler.com/news/2026/06/animated-routes-on-maps
- Strava Flyover (2023): show the whole route first, then move in on the dot. https://techcrunch.com/2023/11/15/strava-launches-flyover-an-aerial-3d-video-recap-of-every-outdoor-activity-you-do/
- Apple's Motion guidance: brief, never blocking, a crossfade when Reduce Motion is on. https://developer.apple.com/design/human-interface-guidelines/motion
- Accessibility rule WCAG 2.2.2: moving content that starts by itself and runs over 5 seconds needs a way to stop it, so keep it shorter and offer Skip.
