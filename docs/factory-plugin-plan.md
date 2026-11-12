# Plan: the software factory as a free, open source plugin

Owner decision, 12 November 2026. Not started. **Remind the owner of this plan when she says it's time to compile the screenshots and videos for this project** (see "Project rules" in `AGENTS.md`).

## What we're making

The software factory that built this app (`.claude/skills/factory/`, the five `factory-*` agents in `.claude/agents/`, the board and the dashboard in `factory/`) packaged as a **Claude Code plugin** that anyone can install with one command.

- **Free and open source.** It won't be sold. People can change it however they like.
- **Who it's for:** people at the owner's level, or a little behind her: building with AI agents without an engineering background. Very advanced developers aren't the audience.
- **What it does for them:** their idea goes in at one end, and a finished app comes out at the other, built with proper agentic engineering they can trust.

## What it takes

1. **Strip out what belongs only to this app:** learner data and voice consent flags, Finnish content and the native reviewer, Supabase, Azure, Cloudflare and the app's own scope. Keep the line itself: spec, the owner's spec OK, build, automatic checks, reviews, evaluation, the owner's approval, merge, lessons learned, plus faster mode and parallel mode.
2. **Add a setup step** (for example `/factory start`) that interviews the person about their idea and writes their project's rules file, so the factory works on a new idea from an empty folder.
3. **Bundle it as a plugin:** the manager skill, the five agents, the dashboard, and the skills the factory depends on, with a short guide.
4. **Test it on one very simple idea**, from an empty folder, the way a viewer would use it.
5. **Publish what we document here.** The plugin and the video are about the factory as used on this language app. People with other ideas adapt it themselves.

## Hand-over to publishing (the last step of the project)

When the project is done and the owner says to compile everything, the agent here packages it all for the publishing side (the `Publishing` repo, `youtube/002-aleksi/`), so a proper video and post can be made from it without coming back here. The hand-over includes:

- **The story:** `recording/scenes.md` in order, with what happened, why, and the commit for each scene.
- **All screenshots** from `recording/screenshots/` and every job's evidence folder, named by scene.
- **All videos and screen recordings** made during the build.
- **How the factory works:** a plain-English explanation of the line, the agents, the two approvals and the modes, with the dashboard pictures.
- **The numbers:** jobs run, rounds, approvals, time taken, from `factory/board.json` and `factory/progress.md`.
- **The lessons learned** from `AGENTS.md`, and what went wrong along the way.
- **The plugin:** where it lives, how to install it, and what was stripped out.
- **The app:** what Aleksi does today (from `landing-copy-brief.md`), its status and its address.

The confirmed story brief for the video is already in `Publishing/youtube/002-aleksi/story-brief.md`.
