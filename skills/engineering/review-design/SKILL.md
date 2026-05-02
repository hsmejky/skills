---
name: review-design
description: Review a design artifact (decision log from /grill-me, or a freeform design doc) for internal soundness before planning. Checks resolved-vs-open branches, internal consistency, reasoning quality, scope, coverage, and unaddressed concerns. Standalone reviewer — does not proceed to /to-issues. Use when user says "review my design", "review the decisions", "review the design doc", "check my design", "is this design sound", "review what we decided", "audit the design", "check the decision log", "is anything missing from the design", "review my approach before planning", "deep design review", "thorough design review".
---

# Review Design

Reviews a design artifact for internal soundness before planning. No code involved.

Two valid input shapes:
- **Decision log** from `/grill-me` — Q/Decision/Reason format
- **Freeform design doc** — colleague's design, PRD, RFC, or anything design-shaped (decisions + scope + constraints, optionally with schemas/APIs/diagrams)

When exploring the codebase, look for whatever the repo uses to capture domain language and architectural decisions (e.g. `CONTEXT.md`, `GLOSSARY.md`, `docs/adr/`, or whatever `CLAUDE.md` points at). If found, use that vocabulary.

## Inputs

- File path to the design artifact, or inline content
- No args → look for a recently written design file (`*design*.md`, `*grilling*.md`, `.scratch/*.md`); ask if ambiguous

## Step 1 — Locate output

Check the invoking prompt and `CLAUDE.md` for where the report should go:

- A **file path** the user specified — write the markdown there.
- **Inline in the conversation** — print the report back. **Default.**
- A **directory convention** the user has — write inside it.

Default to inline. Only ask if the invocation hints at saving but doesn't say where.

## Step 2 — Read the artifact

Read the design and any docs it references (assignment, requirements, related ADRs). Identify shape: pure decision log, freeform design, or hybrid.

## Step 3 — Review

Run all sections. If a section doesn't apply to this artifact shape (e.g. "schema soundness" on a pure decision log), say so and skip.

### 3.1 Resolution
- **Unresolved branches** — questions raised but not decided
- **Hand-waved decisions** — decided without a real reason ("we'll figure it out", "TBD")
- **Implicit assumptions** — decisions that depend on something not stated

### 3.2 Internal consistency
- **Contradictions** — decisions that conflict with each other
- **Reasoning chain** — decisions that reference earlier decisions correctly
- **Scope drift** — later decisions widening scope that earlier ones bounded

### 3.3 Reasoning quality
- **Real reasons vs vibes** — each decision has a "because" that survives questioning
- **Alternatives considered** — decisions that ruled out specific alternatives, not just picked one
- **Reversibility** — load-bearing decisions flagged as hard-to-undo where relevant

### 3.4 Scope
- **In-scope clear** — what the work covers is stated
- **Out-of-scope clear** — what is explicitly NOT being done is stated
- **Boundary** — any items that are ambiguous (in or out?)

### 3.5 Coverage (gates the next phase)
- **Sufficient for `/to-issues`** — can a planner actually slice this into vertical cuts?
- **Sufficient for `/tdd`** — is the contract / interface / behavior clear enough to write tests against?
- **Missing dimensions** — design ignores concerns that will bite in implementation:
  - error handling, failure modes
  - security (authn/authz, input handling, secrets) — flag if the work obviously needs it
  - performance / scale — flag if obvious scale concerns
  - observability — how will we know it's working in prod?
  - migrations / rollout — if data or schema involved
  - backwards compat — if public surface involved

### 3.6 Schemas / APIs / diagrams (if present)
Skip if not in artifact.
- Match decisions
- Consistent with each other
- Concrete enough to slice against

### 3.7 Typos / Other

## Step 4 — Report

Write in same language as the design.

Header:
- Reviewed: `{file | inline}`
- Shape: `decision log | freeform design | hybrid`
- Sections: list run vs skipped with reason

Number all issues sequentially (1, 2, 3 …).

Issue format: `N. **[type]** [section or anchor]` — description.

Sections:
```
### Resolution
### Internal consistency
### Reasoning quality
### Scope
### Coverage
### Schemas / APIs / diagrams (if present)
### Typos / Other
```

Empty sections say "no issues". Skipped sections show skip reason.

End with verdict: **Approved** / **Approved with minor remarks** / **Changes requested**.

Emit to the target chosen in Step 1.

## Step 5 — Suggest next step

After the report, append a one-line suggestion based on verdict:

- **Approved** or **Approved with minor remarks** → `next: /to-issues to plan, or refine the design first?`
- **Changes requested** → `next: refine the design (re-run /grill-me on the open branches?) before /to-issues.`
