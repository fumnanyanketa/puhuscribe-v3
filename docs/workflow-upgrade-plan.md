# Workflow upgrade plan

Date: 2026-10-05. Status: proposed, awaiting your go.

This plan compares our drafted skills kit with the released open source kit at
github.com/jsmastery-pro/skills, and says what we should change before we
continue with PuhuScribe Phase 3.

## The short version

The released kit is the same workflow we drafted from, but it has been tested
and grown by about ten times. Our drafts total about 7,000 words. The released
kit totals about 78,000 words across 9 skills, with mode files, templates,
guides, and two helper agents. It also ships a size budget checker and a
portability checker, and it installs with one command.

Recommendation: adopt the released kit as our base, keep five of our own
additions as project local extras, and migrate our plan.md into the kit's scope
format. Do not patch our drafts line by line. The kit has already done that
work.

## What the released kit does that our drafts do not

These are the mechanisms that matter, in order of impact on PuhuScribe.

1. The value sourcing gate. Architect's spec template has a table with three
   columns: action, value produced, source. Every value a feature shows or
   computes must name where it comes from. Develop reruns that check before
   writing any code. A value with no source is an owed decision, and develop
   stops. The kit says plainly not to use a judgment question, because the
   model will call a real decision "just wiring". Our develop gate is exactly
   that judgment question.

2. Assumed specs. When you override the gate and build anyway, develop writes
   a small spec marked Assumed with the assumption, who authorized it, and the
   code it touches. It never blocks done, but scope and sync keep surfacing it
   as decision debt until architect ratifies it. Our override lives only in the
   chat report, which is lost.

3. Build approach. Scope asks you to pick one of four delivery shapes and
   records it in the scope header: Tracer Bullet (a thin real thread through
   every layer, nothing faked), Skateboard (smallest usable product), Facade
   (all screens on mock data first, wire later), Journey (one complete user
   path at a time). The pick changes how architect orders build tasks and how
   develop binds screens to backends. Our plan has no approach.

4. Workflow tier. Scope also asks how much checking the project wants by
   default: Prototype (develop only), Alpha (adds check verify), Beta (adds
   test), GA (adds a different model review plus document). Any feature can
   override. This replaces our light, medium, heavy weights, but with a clear
   mapping: our heavy rows become GA tags.

5. Cross model critic on specs. At Beta and GA, architect offers to run an
   independent model over the spec to find values with no source and choices
   the builder would otherwise invent. Always offered, never run on its own.

6. Different model review, mechanically. Check review spawns a subagent with
   an explicit model field, maps the author model to a different one, and
   refuses to review with the same model. Our draft only says "use a different
   model" and hopes.

7. Senior backend defaults inside develop. Apply migrations and confirm the
   tables exist. Idempotency keys for side effects. Authorization per
   resource. Paginate every list. Rate limit public endpoints. Secrets from
   environment with a loud failure if missing. Delete replaced code. Safety
   pass at the end.

8. Design system inside develop. Four routes: design tool, pasted image,
   existing system, or create one. Creating one computes WCAG contrast ratios
   for light and dark before writing any CSS and fixes failures instead of
   noting them. Token values live in CSS, art direction lives in design.md.

9. Helper agents. A scout (cheap model, read only) maps the code before a
   build so the main thread does not drown in file dumps. A researcher (cheap
   model, read only) checks current docs and finds skills or connectors, but
   only after you say yes to a search.

10. Smaller things that add up: audit runs after the scaffold on greenfield
    so it reads a real project; nested AGENTS.md for monorepos; test asks
    whether you even want a test runner and remembers the answer in JSON;
    document has templates and creates the pull request through gh; debug
    pins observed, expected, and reproduction up front and uses git bisect.

## What our drafts have that the released kit dropped

Not everything we have is obsolete. These are worth keeping.

- Check eval mode: golden sets, pass rate bar, trajectory scoring. The kit has
  nothing for grading an AI feature. FLOW is an AI feature, and it is the
  heart of PuhuScribe. We need this.
- Warden: a secret and dependency scan. The kit folds security into develop's
  safety pass and the review rubric, but has no scanner. Keep it.
- Liftoff: the pre release checklist and small circle release. The kit has no
  release step. Keep it.
- Canvas design mode: research the look, generate brand assets in order,
  mascot first. The kit's develop creates a design system from a mood or
  reference, but it does not generate illustrations or a mascot. Keep canvas
  for assets, and let develop own design.md and the CSS tokens. Drop canvas
  drift mode; the kit's review rubric covers it.
- Heavy feature sign off. The kit lets you declare done at any tier. For
  accounts, personal data, and analytics we should keep the rule that a human
  writes "approved" plus initials before done. This becomes a project rule in
  AGENTS.md, not a skill edit.
- Durable evidence. The kit's verify keeps no files. We should keep
  docs/evidence/ for GA features so "did this ever work" has an answer.
  Also a project rule.
- The three threat model questions in architect, and the three way debug
  triage (real bug, polluted session, wrong decision). Both become short
  rules in AGENTS.md so the kit's skills pick them up.
- The success line as a required scope question. Already answered for
  PuhuScribe, so no action.

## The plan, in order

| # | Step | Status | Done when |
|---|------|--------|-----------|
| 1 | Make the project a git repository and commit the current state | planned | `git log` shows one commit holding our drafts, plan.md, and docs |
| 2 | Archive our drafts to docs/archive/skills-v1/ | planned | the 14 draft folders are copied there and the copy is committed |
| 3 | Install the released kit with `npx skills@latest add jsmastery-pro/skills -a claude-code` | planned | .claude/skills holds the 9 released skills and Claude Code lists them after restart |
| 4 | Restore our four extras beside the kit: check eval mode, warden, liftoff, canvas (design mode only) | planned | the extras load without name clashes and eval is reachable from /check |
| 5 | Add the two helper agents (scout, researcher) to .claude/agents/ | planned | both appear in the agent list |
| 6 | Migrate docs/plan.md to docs/scope/scope.md in the kit's format | planned | the scope has a build approach, a workflow tier, foundation rows, phase groups, and all ten features plus the backlog item |
| 7 | Write the project rules file seed for AGENTS.md | planned | the heavy sign off, evidence folder, threat model questions, debug triage, and output style rules are written down ready for /audit |
| 8 | Update docs/skills-plan.md to track the new kit plus extras | planned | each row names the skill's source (kit or ours) and its test status |
| 9 | Resume the playbook at Phase 3 with the kit's /architect for the stack | planned | docs/specs/0001 exists with a value sourcing table and a proposed stack |

Steps 1 to 5 are mechanical and can run in one sitting. Step 6 needs two
decisions from you. Step 7 is writing. Step 9 is where PuhuScribe work
restarts.

## Decisions made (2026-10-05)

1. Build approach: Tracer Bullet.
2. Workflow tier: Beta as the project default. GA tags on FLOW, Accounts and
   sign in, and Analytics.
3. Extras kept: check eval mode, warden, liftoff, canvas design mode.
   Dropped: canvas drift mode, fleet, nightshift. The fleet and nightshift
   drafts stay in the archive only.

The reasoning for each is below.

1. Build approach for PuhuScribe. Recommended: Tracer Bullet. FLOW is the
   heart and the riskiest part. A walking skeleton that goes shell, stub sign
   in, one real FLOW turn, one analytics event, proves the whole system early.
   The kit also names Tracer Bullet as its default for a production build.
   The alternative is Skateboard, which would ship a usable FLOW only product
   first. It is faster to a demo but delays the data and account plumbing
   that four of our ten rows depend on.

2. Workflow tier. Recommended: Beta as the project default, with GA tags on
   FLOW, Accounts, and Analytics. Beta runs verify and tests on every feature.
   GA adds the different model review and the document step where money,
   logins, or personal data are involved. This matches our heavy weights.

3. Keep or drop our extras. Recommended: keep check eval, warden, liftoff,
   and canvas design mode. Drop canvas drift. Keep fleet and nightshift as
   gated files since they cost nothing until invoked.

## Migration notes for plan.md

The kit's scope format needs these additions to what plan.md has today.

- Header lines for build approach and workflow tier.
- Foundation rows the kit always expects: Stack and architecture, Coding
  standards and tooling, Data model (never skipped), Design system, Walking
  skeleton. Today the stack is only a note at the bottom.
- Phase groups instead of one flat table: Foundations, Slice 1, Slice 2,
  Deferred.
- Each feature as a section with intent, one done when line, and checkbox
  steps where every box is a command. The next step is always the first
  unticked box.
- Statuses planned, in-progress, done, existing, dropped. Rows are never
  deleted.
- Cross cutting concerns scope never asked us: accessibility, Finnish and
  English interface language, GDPR and cookie consent. These matter for an
  app in Finland and should become rows or AGENTS.md rules.
- Our north star and the two rails note have no slot in the template. Keep
  them as header prose. The rails become acceptance criteria in each spec.

Our "Needs decision" text moves into the specs. Our backlog table becomes a
Deferred list. Our weights become tier tags.

## What does not change

The Builder's Playbook phases still hold. Phase 1 is locked. Phase 2 is done
and only changes format. Phase 3 starts with the kit's /architect instead of
ours. The project brain still lives in files, and the app still gets built in
VS Code later. We are swapping the tools, not the method.
