---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Optionally captures resolved decisions to a markdown file. The "analyze" phase of the workflow. Use when user says "analyze how to implement X", "analyze this approach", "think through this", "how should I approach X", "best approach for X", "review my approach", "challenge my design", "design X", "ask me questions", "interrogate me about X", "what should I consider", "what am I missing", "poke holes in this", wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

## Optional output

Default: conversation only. Don't ask, don't offer.

If the invoking prompt or `CLAUDE.md` specifies a target — a file path or "inline" — capture each resolved branch as you go:

- **Question** — what was being decided
- **Decision** — what was settled on
- **Reason** — why (what made the alternatives worse)

Write at the end of the session. If the user says "save this" mid-session, ask where, then write what's been resolved so far.

Output format:

```markdown
# <topic> — design

## Q1: <question>
**Decided**: <decision>
**Reason**: <why>

## Q2: <question>
...
```

Capture resolved decisions only — unresolved or skipped branches are noise.

## Suggest next step

After capturing (or at end of inline-only sessions), append one line:

`design captured. next: /review-design to sanity-check, /to-issues to plan, or save here?`
