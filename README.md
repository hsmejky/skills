# Engineering Skills

Agent skills for software development that I use day-to-day. Forked from
[`mattpocock/skills`](https://github.com/mattpocock/skills) and reshaped to a
**discover-or-ask** model: skills read `CLAUDE.md` and the invoking prompt,
look around the repo for whatever exists, and ask once when context is
ambiguous. No per-repo setup step.

## Install

Clone the repo and link the skills into your local Claude Code skills
directory:

```bash
git clone https://github.com/<your-username>/skills.git
cd skills
bash scripts/link-skills.sh
```

`link-skills.sh` symlinks every `SKILL.md` folder into `~/.claude/skills/` so
that the slash commands (`/debug`, `/tdd`, `/to-issues`, etc.) are
available across all your Claude Code sessions.

Alternatively, point Claude Code at this repo as a plugin via
`.claude-plugin/plugin.json` (the `engineering-skills` plugin), or symlink
individual skill folders into your project's `.claude/skills/` directory.

## Skills

- **[caveman](./skills/caveman/SKILL.md)** — Ultra-compressed communication mode. ~75% token reduction.
- **[commit](./skills/commit/SKILL.md)** — Create one Conventional Commits commit with imperative subject ≤72 chars, no scope, no body, no co-author footer. Categorizes untracked, scans staged content for secrets and local paths, suggests splitting when diff spans multiple dirs or types.
- **[debug](./skills/debug/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[grill-me](./skills/grill-me/SKILL.md)** — Relentlessly interviewed about a plan or design until every branch of the decision tree is resolved. Optionally captures resolved decisions to a markdown file.
- **[improve-architecture](./skills/improve-architecture/SKILL.md)** — Find deepening opportunities by reading the code; output proposals to a markdown file or inline.
- **[review](./skills/review/SKILL.md)** — Two-tier review of code against project documentation. Auto-detects active dimensions (doc fidelity, business logic, tests, simplicity, security; deep mode adds perf, concurrency, error handling, deps, API contract, migrations, architecture).
- **[review-design](./skills/review-design/SKILL.md)** — Standalone reviewer for a design artifact (decision log from /grill-me, or freeform design doc). Checks resolution, consistency, reasoning, scope, coverage, unaddressed concerns.
- **[review-plan](./skills/review-plan/SKILL.md)** — Standalone reviewer for an implementation plan (vertical-slice checklist from /to-issues). Checks vertical slicing, AC concreteness, dependencies, granularity, HITL/AFK honesty, coverage against design.
- **[tdd](./skills/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. One vertical slice at a time.
- **[to-issues](./skills/to-issues/SKILL.md)** — Break a plan into independently-grabbable vertical slices, emitted as a checkbox markdown plan.
- **[triage](./skills/triage/SKILL.md)** — Evaluate an incoming bug report or feature request — reproduce, analyze, grill, emit structured triage notes.
- **[write-a-skill](./skills/write-a-skill/SKILL.md)** — Create new skills with proper structure, progressive disclosure, and bundled resources.
- **[zoom-out](./skills/zoom-out/SKILL.md)** — Higher-level map of the relevant modules and callers in an unfamiliar area of the codebase.

## Getting the most out of these skills

These skills auto-fire when Claude detects a matching phrase in your
prompt — the triggers live in each skill's `description:` field. To make
auto-fire frictionless across every session, configure your **user-level
`~/.claude/CLAUDE.md`** with the two blocks below.

### Always-on caveman

Add to `~/.claude/CLAUDE.md`:

```markdown
Default communication style: caveman mode (see /caveman skill).
Drop articles, filler, pleasantries; keep technical terms exact.
Off only when I say "normal mode".
```

This references the skill rather than inlining the rules — the skill body
still loads when invoked, so you only update rules in one place.

### Skill-trigger cheatsheet

Add to `~/.claude/CLAUDE.md`:

```markdown
## Skill triggers (auto-fire when prompt matches)

Workflow: /grill-me (analyze) → /to-issues (plan) → /tdd (implement) → /review (verify).
/debug and /triage handle bugs and incoming reports separately. /review also works standalone for reviewing colleagues' branches or PRs.

- "analyze / think through / design X / how to approach / review my
  approach / challenge / poke holes / ask me questions" → /grill-me
- "plan / make a plan / implementation plan / break into slices / split
  into steps / break down / checklist" → /to-issues
- "implement / build / add a feature / code this up / create / develop /
  make X work" → /tdd
- "review this / review the branch / review the PR / review the changes /
  code review / audit this code / deep review / thorough review /
  full audit" → /review
- "review my design / review the decisions / check my design / is this
  design sound / audit the design / review the design doc" → /review-design
- "review my plan / check the slices / are these slices vertical /
  review the implementation plan / audit the plan" → /review-plan
- "diagnose / debug / why is X failing / fix this error / X is slow"
  → /debug
- "triage / evaluate this bug report / is this worth fixing / review this
  incoming issue / what kind of issue" → /triage
- "clean up / deepen modules / audit design / architecture review / ball
  of mud" → /improve-architecture
- "zoom out / I don't understand this / explain this area / map of X /
  overview / bigger picture" → /zoom-out
- "be brief / shorter / terse / less tokens / no filler / less verbose"
  → /caveman
- "commit this / make a commit / create a commit" → /commit
- "new skill / make a skill / scaffold a skill / add slash command /
  skill template" → /write-a-skill
```

### Tuning over time

Each skill's `description:` is the source of truth for auto-fire. If a
phrasing should have fired a skill but didn't, extend that skill's
description directly. The cheatsheet above is a backstop; the descriptions
are the front line.

## Design notes

These skills follow a **discover-or-ask** model:

1. **Read `CLAUDE.md` and the invoking prompt** as the only authorities.
2. **Look around the repo** for whatever exists — git remote, an `.scratch/`
   convention, any glossary-shaped file, any ADR-shaped folder — and fall
   back to names from the code.
3. **Ask once** when discovery is ambiguous, before doing anything
   destructive (publishing files, writing back to docs).
4. **Output destinations are specified per invocation** — file path or
   inline in the conversation. Skills do not write back to project docs
   unless the user explicitly asks.

There is **no setup step** and no parallel `docs/agents/` config layer. The
upstream fork required a `/setup-matt-pocock-skills` pass that seeded
per-repo configuration; that model assumed a uniform project layout and
produced wrong output when the setup pass was skipped. Discover-or-ask
collapses to one source of truth (`CLAUDE.md`) and degrades gracefully when
context is missing.

Trade-offs accepted: no centralised issue-tracker / label / domain-layout
config; no canonical triage role names; no strict `CONTEXT.md` /
`docs/adr/` / `CONTEXT-MAP.md` layout. The skills adapt to the project
rather than the other way around.

## Credit

Forked from [`mattpocock/skills`](https://github.com/mattpocock/skills) by
Matt Pocock. The original is excellent; this fork narrows scope to my own
development workflow and removes the per-repo setup model.

## License

MIT — see [LICENSE](./LICENSE). Copyright is preserved for both the upstream
work and this fork's modifications.
