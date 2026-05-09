Skills live flat under `skills/`. Each skill is its own folder containing `SKILL.md`.

Every skill must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

## Local install / update

`scripts/install-skills.sh` copies skills into `~/.claude/skills/`. It is cross-platform (Linux, macOS, BSD, Windows under Git Bash / MSYS2 / Cygwin / WSL) and idempotent — re-run it to update.

Three modes:

1. **Local source (default).** Resolves to either the git checkout the script lives in, or an installed `honzik-skills` plugin found anywhere under `~/.claude` (located by scanning for `.claude-plugin/plugin.json` with `"name": "honzik-skills"`).
2. **GitHub source.** `--from-github [REF]` downloads `<repo>/archive/<REF>.tar.gz` (default `main`; works for branches, tags, or commit SHAs), extracts it, and installs from there.
3. **Curl-pipe.** When invoked via `curl ... | bash` (no script file on disk), `--from-github` is enabled automatically.

When adding a new skill, no script changes are needed — `install-skills.sh` discovers skills by walking `skills/**/SKILL.md`. Just remember the README + `plugin.json` entries above.
