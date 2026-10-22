# The Skills Starter Kit

Fourteen skills implementing the Builder's Playbook, ready for Claude Code.

## What is in here

```
skills-starter-kit/
  README.md            this file
  SKILL-TEMPLATE.md    the house style every skill was built from
  skills-plan.md       the build and testing tracker (rows now "drafted")
  skills/
    audit/       the rulebook writer
    scope/       the planner
    architect/   the decision partner
    canvas/      the designer (modes: design, drift)
    develop/     the builder (with the famous gate)
    check/       the prover (modes: verify, review, eval)
    test/        the safety net writer
    warden/      the security guard
    document/    the historian
    liftoff/     the launch director
    sync/        the librarian
    debug/       the detective
    fleet/       ADVANCED: parallel agents (gated, adopt late)
    nightshift/  ADVANCED: bounded overnight loops (gated, adopt late)
```

## Install (Claude Code)

1. Create your project repo (or open an existing one).
2. Copy the whole skills/ folder into the project as .claude/skills/
   so you end up with .claude/skills/audit/SKILL.md and so on.
   Claude Code discovers them automatically.
3. Also copy skills-plan.md, SKILL-TEMPLATE.md, and your reference docs
   (the playbook HTML, merge-map.md, the field map) into docs/.
4. Commit. The files are the memory; sessions are disposable.

## First session prompt

"Read everything in docs/ and list the skills you can see. We work by the
playbook: new project starts with /scope, then /architect for the stack,
then /develop scaffold, then /audit, then /canvas design. Start with /scope."

## Important honesty note

These fourteen skills are DRAFTED, not yet TESTED. The working agreement in
skills-plan.md still applies: run each skill on 2 or 3 real prompts, watch
what it actually does, refine, and only then call its row done. Expect to
edit these files; that is the process working, not the process failing.
Every lesson learned goes back into SKILL-TEMPLATE.md so the next edit
starts smarter.

## The pipeline at a glance

Once per project:
/scope -> /architect (stack) -> /develop (scaffold) -> /audit -> /canvas design

Every feature:
/architect -> /develop -> /check verify -> /test -> /check review
(+ /warden scan for heavy) -> /document -> /sync -> fresh session

Before users: /liftoff
Anything broken, anytime: /debug
Much later, gated: /fleet, /nightshift
