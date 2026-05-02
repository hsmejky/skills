---
name: triage
description: Evaluate an incoming bug report or feature request — reproduce, analyze, grill the reporter for missing detail, and emit structured triage notes. Use when user says "triage this", "triage this issue", "evaluate this bug report", "is this a real bug", "is this worth fixing", "should we fix this", "review this incoming report", "what kind of issue is this", "is this a bug or enhancement", or wants to assess an incoming bug or request.
---

# Triage

Given an incoming bug report or feature request (pasted, file path, URL), evaluate it: try to reproduce, recommend a category, ask the maintainer for direction, and emit triage notes.

This skill does not depend on an issue tracker. It works on whatever the invoking prompt provides — a stack trace pasted into chat, a markdown file, a URL.

## 1. Gather context

Read the full report — body, comments, attached logs. If the source is a URL or file path, fetch and read it. Parse any prior triage notes so you don't re-ask resolved questions.

Explore the codebase relevant to the report. Look for whatever the repo uses to capture domain language and architectural decisions (e.g. `CONTEXT.md`, `GLOSSARY.md`, `docs/adr/`, or whatever `CLAUDE.md` points at). If found, use that vocabulary. If not, use the names from the code.

## 2. Reproduce (bugs only)

Before recommending or grilling, attempt reproduction:

- Read the reporter's steps
- Trace the relevant code
- Run tests or commands

Report what happened — successful repro with code path, failed repro, or insufficient detail (a strong signal that grilling is needed before any next action).

A confirmed repro makes a much stronger evaluation.

## 3. Recommend

Tell the maintainer:

- **Category**: bug / enhancement / something else
- **Reasoning**: why
- **Codebase summary**: what's relevant in the code
- **Next action**: what you'd do (grill the reporter? hand off to `/to-issues`? close as out-of-scope? defer?)

Wait for direction.

## 4. Grill (if needed)

If the report is under-specified, run a `/grill-me` session targeted at the reporter's gaps. Resolve as much as possible without their input by reading code; surface only the questions that genuinely need them.

## 5. Emit triage notes

Write triage notes to the target picked at invocation (file path, inline, or wherever the prompt directed). If no target was specified, ask once.

Use this template:

<triage-notes-template>
## Triage notes — <issue title>

**Category**: bug | enhancement | unclear
**Recommendation**: <one-line: e.g. "fix in next sprint", "needs more detail", "out of scope">

### What we've established

- point 1
- point 2

### Reproduction

<successful repro with code path | failed repro with what was tried | insufficient detail>

### Open questions for reporter

- question 1
- question 2

### Next action

<what should happen next>
</triage-notes-template>

If a question can be answered by exploring the code, do that instead of asking. Questions to the reporter must be specific and actionable, not "please provide more info".
