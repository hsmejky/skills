---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable vertical slices, emitted as a checkbox markdown plan. The "plan" phase of the workflow. Use when user says "plan this", "make a plan", "implementation plan", "break this down", "break into slices", "split this up", "list the steps", "what are the steps", "create a checklist", "checklist for X", or wants to convert a plan into slices, tickets, or a working checklist.
---

# To Issues

Break a plan into independently-grabbable slices using tracer bullets (thin vertical cuts through every layer).

## 1. Locate the output

Check the invoking prompt and `CLAUDE.md` for where the output should go. Three valid targets:

- A **file path** the user specified — write the markdown there.
- **Inline in the conversation** — print the markdown back, no file.
- A **directory convention** the user has (e.g. `.scratch/<feature>.md`, `plans/`, `docs/work/`) — write inside it.

If none of those is specified, ask once before drafting:

> Where should the plan land — a file path, or just print it back here?

## 2. Gather context

Work from whatever is in the conversation. If the user passes a file path or URL as an argument, read it first.

## 3. Draft vertical slices

Each slice is a **tracer bullet** — a thin cut through every layer (schema, API, UI, tests), demoable on its own. Mark each slice **HITL** (needs human interaction) or **AFK** (an agent can take it end-to-end). Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

## 4. Quiz the user

Show the proposed breakdown as a numbered list. For each slice:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices must complete first
- **User stories covered**: which user stories this addresses (if the source had them)

Ask:

- Granularity right? (too coarse / too fine)
- Dependencies right?
- HITL/AFK marking right?

Iterate until the user approves.

## 5. Emit

Write the approved breakdown using this template, to the target picked in step 1:

<plan-template>
# <feature> — implementation plan

## Slice 1 — <title> (AFK | HITL)
**What to build**: <one-paragraph description of the end-to-end behavior, not layer-by-layer implementation>
**Blocked by**: none | Slice <N>

- [ ] <acceptance criterion 1>
- [ ] <acceptance criterion 2>

## Slice 2 — <title> (AFK | HITL)
...
</plan-template>

Slices are H2 headings so they fold cleanly. Each slice gets its own checkbox group. The user works the plan top-down, ticking criteria as slices land.
