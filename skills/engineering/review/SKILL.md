---
name: review
description: Review code against project documentation across multiple dimensions — doc fidelity, business logic, tests, simplicity, security, and (in deep mode) performance, concurrency, error handling, deps, API contract, migrations, architecture. Auto-detects which dimensions apply from the diff. The verification phase of the workflow (after /tdd), and a standalone tool for reviewing others' branches or PRs. Use when user says "review this", "review my branch", "review the branch", "review the PR", "review the changes", "review the implementation", "review what they implemented", "review against the doc", "code review", "audit this code", "deep review", "thorough review", "full review", "full audit", "deep audit", or asks to review a feature, staged changes, or two branches.
---

# Review

Two-tier review against project documentation.

- **Tier 1** — doc fidelity, business logic, tests, simplicity, security. Always runs.
- **Tier 2** — performance, concurrency, error handling, dependencies, API contract, migrations, architecture. Only runs when invocation signals deep mode (e.g. "deep review", "thorough review", "full audit") AND tier 1 verdict is not "Changes requested".

Each dimension auto-activates from diff signals. Inactive dimensions are reported as skipped with reason.

When exploring the codebase, look for whatever the repo uses to capture domain language and architectural decisions (e.g. `CONTEXT.md`, `GLOSSARY.md`, `docs/adr/`, or whatever `CLAUDE.md` points at). If found, use that vocabulary and respect those decisions. If not, proceed with the names from the code.

## Inputs

- Branch name, PR number, two branches, feature description, or no args (uses local staged + unstaged changes)
- Optional `assignment:` inline or path to doc(s) — treat inline as authoritative
- No assignment → infer from changed paths, tests, commit messages, PR description
- Deep-mode signal in invocation ("deep review", "thorough review", "full audit", etc.) → tier 2 runs after tier 1

## Step 1 — Locate output

Check the invoking prompt and `CLAUDE.md` for where the report should go. Three valid targets:

- A **file path** the user specified — write the markdown there.
- **Inline in the conversation** — print the report back, no file. **Default.**
- A **directory convention** the user has (e.g. `reviews/`, `.scratch/<branch>.md`) — write inside it.

If none of those is specified, default to inline. Only ask if the invocation hints at saving but doesn't say where.

## Step 2 — Get the diff

- Branch: `git diff {base}...{branch} --name-only` then `git diff {base}...{branch}`
- PR: resolve via `gh pr view {N}` then diff
- Local: `git diff` and `git diff --cached`
- Two branches: `git diff {a}...{b}`
- Feature description → search relevant files on filesystem

List changed files before proceeding.

## Step 3 — Read documentation

Read each relevant doc and any docs it references. Only directly relevant — not all docs. Treat assignment as docs.

If no doc found, note "no documentation — intent inferred from {tests / PR description / commit messages}". Confidence on business-logic findings is lower; document the assumption in the report header.

## Step 4 — Detect active dimensions

Scan the diff for signals. Mark each dimension **active** or **skipped (reason)**. Report header lists this map.

**Tier 1 dimensions:**
- Documentation, Business Logic, Testing, Simplicity → always active
- **Security** → active if diff touches auth, crypto, secrets, user-input handling, SQL, shell exec, deserialization, file paths from input, network calls

**Tier 2 dimensions** (deep mode only):
- **Performance** → loops over collections, DB queries, regex on user data, I/O on hot paths, large allocations
- **Concurrency** → async/await, threads, locks, channels, shared mutable state
- **Error handling / observability** → try/catch blocks, error returns, logging changes, retry logic
- **Dependencies** → `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, lockfiles
- **API contract** → exported/public symbols, route definitions, schema files, protobuf
- **Migrations** → migration files, ALTER/CREATE/DROP, data backfills
- **Architecture** → new modules, new directories, >10 file changes, cross-layer edits

## Step 5 — Tier 1 review

Run each active tier 1 dimension. Skip inactive ones with reason.

### 5.1 Documentation
Completeness · Accuracy vs code · Internal consistency · Cross-doc consistency · Typos · Other

### 5.2 Business Logic
Completeness vs doc · Edge cases from doc · Undocumented behavior · Typos · Other

### 5.3 Testing
Happy path · Failure case (correct error) · Boundaries (exact min/max) · Typos · Other

### 5.4 Simplicity (source files only, not tests)
SRP · OCP · LSP · ISP · DIP · Template Method consistency · Other

### 5.5 Security (if active)
Input validation · AuthN/AuthZ correctness · Secrets handling · Crypto misuse · Injection (SQL/shell/deser) · Sensitive data in logs · Other

## Step 6 — Tier 1 verdict + gate

Compute tier 1 verdict from findings: **Approved** / **Approved with minor remarks** / **Changes requested**.

- Deep mode not signaled → skip to Step 8
- Deep mode signaled AND verdict = "Changes requested" → skip to Step 8 (no point auditing perf on broken code; note this in the report)
- Otherwise → continue to Step 7

## Step 7 — Tier 2 review (deep mode only)

Run each active tier 2 dimension. Skip inactive ones with reason.

### 7.1 Performance
N+1 queries · hot-path allocations · unbounded loops · missing caching · blocking I/O · Other

### 7.2 Concurrency
Race conditions · lock ordering · deadlock risk · missing synchronization · async correctness · Other

### 7.3 Error handling / observability
Swallowed errors · missing context · retry logic · log levels · missing instrumentation · Other

### 7.4 Dependencies
New deps justified · version pinning · known vulns · license compatibility · Other

### 7.5 API contract
Backwards-compat breaks · undocumented breaking changes · versioning · Other

### 7.6 Migrations
Reversibility · downtime risk · data loss risk · ordering vs deploy · Other

### 7.7 Architecture
Module boundaries · coupling · layer violations · abstraction leaks · dead code introduced · Other

## Step 8 — Report

Write in same language as the reviewed documentation.

Header:
- Reviewed: `{branch | PR# | local}` against `{base}`
- Documentation: `{path | inferred from <source>}`
- Dimensions: list active vs skipped with reason
- Mode: `tier 1` or `tier 1 + tier 2 (deep)`

Number all issues sequentially across all sections (1, 2, 3 …).

Issue format:
- Documentation: `N. **[type]** [doc file]` — description
- All other: `N. **[type]** [file:line]` — description

Sections:

```
### Tier 1
#### Documentation
#### Business Logic
#### Testing
#### Simplicity
#### Security

### Tier 2 (if run)
#### Performance
#### Concurrency
#### Error handling / observability
#### Dependencies
#### API contract
#### Migrations
#### Architecture
```

If a section has no issues, say so. Skipped sections show the skip reason.

End with combined verdict: **Approved** / **Approved with minor remarks** / **Changes requested**.

Emit to the target chosen in Step 1.

## Step 9 — Suggest next step

After the report, append a one-line suggestion based on verdict:

- **Changes requested** → `next: /debug for failing checks, or /tdd to address findings?`
- **Approved with minor remarks** → `next: address remarks, or ship as-is?`
- **Approved** → silent (no suggestion needed).
