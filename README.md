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
that the slash commands (`/diagnose`, `/tdd`, `/to-issues`, etc.) are
available across all your Claude Code sessions.

Alternatively, point Claude Code at this repo as a plugin via
`.claude-plugin/plugin.json` (the `engineering-skills` plugin), or symlink
individual skill folders into your project's `.claude/skills/` directory.

## Skills

### Engineering — daily code work

- **[diagnose](./skills/engineering/diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities by reading the code; output proposals to a markdown file or inline.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. One vertical slice at a time.
- **[to-issues](./skills/engineering/to-issues/SKILL.md)** — Break a plan into independently-grabbable vertical slices, emitted as a checkbox markdown plan.
- **[triage](./skills/engineering/triage/SKILL.md)** — Evaluate an incoming bug report or feature request — reproduce, analyze, grill, emit structured triage notes.
- **[zoom-out](./skills/engineering/zoom-out/SKILL.md)** — Higher-level map of the relevant modules and callers in an unfamiliar area of the codebase.

### Productivity — workflow tools

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication mode. ~75% token reduction.
- **[git-guardrails-claude-code](./skills/productivity/git-guardrails-claude-code/SKILL.md)** — Hooks that block dangerous git commands (push, reset --hard, clean, etc.) before they execute.
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Relentlessly interviewed about a plan or design until every branch of the decision tree is resolved. Optionally captures resolved decisions to a markdown file.
- **[write-a-skill](./skills/productivity/write-a-skill/SKILL.md)** — Create new skills with proper structure, progressive disclosure, and bundled resources.

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
