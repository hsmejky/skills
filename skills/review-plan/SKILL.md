---
name: review-plan
description: Review an implementation plan (vertical-slice checklist from /to-issues, or any slice-style plan) for slicing quality before implementation. Checks vertical-vs-horizontal slicing, demoability, acceptance-criteria concreteness, dependencies, granularity, HITL/AFK marking honesty, and coverage against the design. Standalone reviewer — does not proceed to /tdd. Use when user says "review my plan", "review the plan", "check the slices", "are these slices vertical", "is this plan good", "review the implementation plan", "audit the plan", "check the breakdown", "is anything missing from the plan", "review my plan before coding", "deep plan review".
---

# Review Plan

Reviews an implementation plan for slicing quality before implementation. No code involved.

Two valid input shapes:
- **Vertical-slice plan** from `/to-issues` — H2 slice headings + checkbox acceptance criteria + HITL/AFK marking + blocked-by
- **Freeform slice plan** — any breakdown into discrete items with acceptance criteria

When exploring the codebase, look for whatever the repo uses to capture domain language and architectural decisions (e.g. `CONTEXT.md`, `GLOSSARY.md`, `docs/adr/`, or whatever `CLAUDE.md` points at). If found, use that vocabulary.

## Inputs

- File path to the plan, or inline content
- Optional: path to the **design** the plan is derived from — used for coverage check
- No args → look for a recently written plan file (`*plan*.md`, `*implementation*.md`, `.scratch/*.md`); ask if ambiguous

## Step 1 — Locate output

Check the invoking prompt and `CLAUDE.md` for where the report should go:

- A **file path** the user specified — write the markdown there.
- **Inline in the conversation** — print the report back. **Default.**
- A **directory convention** the user has — write inside it.

Default to inline. Only ask if the invocation hints at saving but doesn't say where.

## Step 2 — Read the plan + design

Read the plan and (if provided) the source design. Identify shape: strict to-issues format, freeform, or hybrid.

## Step 3 — Review

Run all sections. Skip with reason if not applicable.

### 3.1 Vertical slicing
- **Vertical, not horizontal** — each slice cuts through every relevant layer (data + API + UI + tests), not "all schema first, then all API"
- **Demoable on its own** — slice produces something verifiable when complete, not a half-built layer
- **Tracer-bullet shape** — narrow but COMPLETE path through the system

### 3.2 Acceptance criteria
- **Concrete** — observable, verifiable behavior, not vague ("works correctly", "handles edge cases")
- **Tied to behavior** — describes what the system does, not what the code looks like
- **Testable** — could be turned into a test as written

### 3.3 Dependencies
- **Blocked-by sound** — listed dependencies are real (the dependent slice genuinely needs the prereq's output)
- **No false serialization** — slices marked sequential that could actually run in parallel
- **No cycles** — A blocks B blocks A

### 3.4 Granularity
- **Not too coarse** — slice that's a week of work should split
- **Not too fine** — slice that's a one-line change should merge
- **Independently grabbable** — a contributor can pick up any AFK slice without context-loading the whole plan

### 3.5 HITL / AFK marking
- **HITL marking honest** — slices marked HITL genuinely need human interaction (UI judgment, external account, manual verification)
- **AFK marking honest** — slices marked AFK can really be taken end-to-end by an agent (clear AC, no human-in-the-loop discovery)
- **Bias toward AFK where possible** — HITL slices should justify why human is needed

### 3.6 Coverage (against design, if provided)
- **All design decisions reflected** — plan implements what was decided
- **No scope creep** — plan doesn't add work the design didn't sanction
- **Missing dimensions** — plan ignores work the design implied:
  - tests for each slice
  - migrations / rollout if data involved
  - observability if production-bound
  - error handling paths from the design
- **Cross-cutting work scheduled** — security review, perf testing, docs updates if relevant

### 3.7 Typos / Other

## Step 4 — Report

Write in same language as the plan.

Header:
- Reviewed: `{file | inline}`
- Shape: `to-issues format | freeform | hybrid`
- Design referenced: `{file | none}`
- Sections: list run vs skipped with reason

Number all issues sequentially (1, 2, 3 …).

Issue format: `N. **[type]** [Slice N or section]` — description.

Sections:
```
### Vertical slicing
### Acceptance criteria
### Dependencies
### Granularity
### HITL / AFK marking
### Coverage
### Typos / Other
```

Empty sections say "no issues". Skipped sections show skip reason.

End with verdict: **Approved** / **Approved with minor remarks** / **Changes requested**.

Emit to the target chosen in Step 1.

## Step 5 — Suggest next step

After the report, append a one-line suggestion based on verdict:

- **Approved** or **Approved with minor remarks** → `next: /tdd on slice 1, or refine the plan first?`
- **Changes requested** → `next: refine the plan (re-run /to-issues with the findings?) before /tdd.`
