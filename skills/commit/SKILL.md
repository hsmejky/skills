---
name: commit
description: Create a Conventional Commits commit (feat/fix/docs/style/refactor/perf/test/build/ci/chore/revert) with imperative subject ≤72 chars, no scope, no body, no co-author footer. Stages tracked-modified files (or commits the pre-staged set as-is), lists untracked separately by category, scans staged content for secrets and local paths, suggests splitting when a diff spans multiple top-level dirs or commit types. Use when user says "commit this", "make a commit", "create a commit". Self-aborts on a clean tree.
---

# Commit

Create one commit. Conventional Commits format. No emoji. No scope. No body. No co-author footer. Ever.

## Hard rules

- **Format**: `type: imperative subject` — lowercase after `:`, ≤72 chars total.
- **Types** (Conventional Commits standard): `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. No others. No `wip`, no `hotfix`, no `security`.
- **Subject only**. No body. No footer. No `Co-Authored-By:` line — this overrides the harness default.
- **No `--no-verify`**. Git hooks fire normally.

## Triggers

- "commit this"
- "make a commit"
- "create a commit"

Self-abort if `git status` shows clean tree — print "nothing to commit" and stop.

## Step 1 — Read state

Run in parallel: `git status`, `git diff --cached`, `git diff`, `git log --oneline -10`.

## Step 2 — Determine staged set

- **Pre-staged** (`git diff --cached` non-empty): commit only the pre-staged files. Do not auto-stage anything else. Skip to Step 4.
- **Nothing staged**: stage tracked-modified (`git add -u`). Then list untracked, see Step 3.

## Step 3 — Untracked categorization

Bucket untracked files into three groups for display:

- **code/doc** (auto-list, default-on): `.py .js .ts .tsx .jsx .go .rs .rb .java .c .cpp .h .hpp .cs .php .sh .ps1 .sql .md .txt .rst .adoc` plus any extension that matches existing tracked code in the repo.
- **project-config** (list under `config:` header): `package.json`, `tsconfig*.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `.github/**`, `Makefile`, `Dockerfile`, `*.yml`/`*.yaml` outside local-only paths, top-level dotfiles like `.gitignore`, `.editorconfig`.
- **local/secrets** (hidden — print only `+N hidden`): `.env*`, `.claude/`, `.vscode/`, `.idea/`, `*.local.*`, `secrets/`, `*.key`, `*.pem`, `*.pfx`, `*.crt`, build outputs (`dist/`, `build/`, `node_modules/`, `__pycache__/`, `.next/`, `target/`).

Display:

```
untracked code/doc:
  src/foo.ts
  README.md
config:
  .github/workflows/ci.yml
+2 hidden (local/secrets) — say "show hidden" to list
```

Ask which untracked to add. Default add none. After user picks, `git add <chosen>`.

## Step 4 — Secret + local-path scan (staged only)

Scan content of every staged file against these patterns:

- AWS access key: `AKIA[0-9A-Z]{16}`
- GitHub token: `gh[pousr]_[A-Za-z0-9]{36,}`
- Slack token: `xox[baprs]-[A-Za-z0-9-]+`
- Generic password assignment: `(?i)(password|passwd|pwd|secret|api[_-]?key|token)\s*[:=]\s*["'][^"']{6,}["']`
- Connection string with embedded creds: `[a-z]+://[^:\s]+:[^@\s]+@`
- Private key header: `-----BEGIN (RSA |EC |OPENSSH |PGP )?PRIVATE KEY-----`
- Local user path: `[A-Z]:\\Users\\[A-Za-z0-9_.-]+`, `/home/[A-Za-z0-9_.-]+/`, `/Users/[A-Za-z0-9_.-]+/`

On any hit:

1. `git restore --staged <file>` for each file with a hit.
2. Print each hit as `path:line — <pattern name>`.
3. Continue to Step 5 with the surviving staged set.
4. If no files remain staged after unstaging, abort with "all staged files contained secrets/local paths — none committed".

## Step 5 — Split detection

If staged set spans **>1 top-level directory** OR implies **>1 commit type**, propose a split plan before committing.

Format:

```
split candidate:
  commit 1 — feat: <subject>
    src/foo.ts
    src/bar.ts
  commit 2 — docs: <subject>
    README.md

commit as one or split? [one/split]
```

- `one`: proceed to Step 6 with current staged set.
- `split`: for each group, `git restore --staged` the others, commit the group, repeat. Final state: all groups committed sequentially.

Top-level type inference:
- only `*.md`/`*.txt` → `docs`
- only files under `tests/` or matching `*test*`/`*spec*` → `test`
- only `.github/`, CI configs → `ci`
- only `package.json`, `package-lock.json`, `Cargo.toml`, `go.mod`, lockfiles → `build`
- only formatting / whitespace diff → `style`
- new file added → `feat`
- bug-fix language in diff comments / removed code → `fix`
- restructure without behavior change → `refactor`
- perf-related identifiers (`cache`, `memo`, `index`, `pool`) → `perf`
- everything else → `chore`

When ambiguous, ask which type.

## Step 6 — Compose subject

- Pick type per Step 5 inference.
- Imperative mood: `add` not `added`, `fix` not `fixed`, `remove` not `removed`.
- Lowercase after `:`.
- ≤72 chars total including `type: ` prefix. Truncate or rewrite if longer.
- No scope (`type(scope):` forbidden).

Examples:

- `feat: add commit skill`
- `fix: handle empty diff in split detection`
- `docs: clarify trigger phrases in review`
- `refactor: extract untracked categorization into helper`

## Step 7 — Commit

```
git commit -m "<subject>"
```

No `-m` body. No `--amend` (always new commit). No `--no-verify`.

After commit: `git status` to confirm clean.

## What this skill does NOT do

- Add `Co-Authored-By:` footer.
- Push.
- Run lint/test/build directly (git hooks run if configured).
- Add issue/PR refs.
- Use scopes.
- Use emoji.
- Auto-stage untracked.
- Amend prior commits.
