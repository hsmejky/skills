#!/usr/bin/env bash
set -euo pipefail

# install-skills.sh — install or update honzik-skills into ~/.claude/skills/.
#
# Cross-platform: copies files (no symlinks). Works on Linux, macOS, BSD,
# and Windows under Git Bash / MSYS2 / Cygwin / WSL.
#
# Source resolution, in order:
#   1. The git checkout this script lives in (if invoked from the repo).
#   2. An installed honzik-skills plugin found anywhere under ~/.claude
#      (e.g. one installed via `/plugin install honzik-skills@honzik-skills`).
#
# Re-run any time to update; existing skill folders are replaced.

PLUGIN_NAME="honzik-skills"
SCRIPT_DIR="$(cd -P "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude/skills"

is_honzik_plugin_dir() {
  local manifest="$1/.claude-plugin/plugin.json"
  [ -f "$manifest" ] || return 1
  grep -q "\"name\"[[:space:]]*:[[:space:]]*\"$PLUGIN_NAME\"" "$manifest" 2>/dev/null
}

resolve_source() {
  # 1. Repo source: parent of scripts/ is the repo root if we're in a checkout.
  local repo
  repo="$(cd -P "$SCRIPT_DIR/.." && pwd)"
  if is_honzik_plugin_dir "$repo" && [ -d "$repo/skills" ]; then
    printf '%s\n' "$repo"
    return 0
  fi

  # 2. Plugin install: scan ~/.claude for our manifest. We don't hardcode the
  # plugin layout — different Claude Code versions place plugins in different
  # subdirs, so we just look for the manifest by name.
  local found=""
  if [ -d "$HOME/.claude" ]; then
    while IFS= read -r f; do
      case "$f" in
        */.claude-plugin/plugin.json) ;;
        *) continue ;;
      esac
      if grep -q "\"name\"[[:space:]]*:[[:space:]]*\"$PLUGIN_NAME\"" "$f" 2>/dev/null; then
        found="$(dirname "$(dirname "$f")")"
        break
      fi
    done < <(find "$HOME/.claude" -maxdepth 6 -name plugin.json -type f 2>/dev/null)
  fi

  if [ -n "$found" ] && [ -d "$found/skills" ]; then
    printf '%s\n' "$found"
    return 0
  fi

  return 1
}

if ! SOURCE_ROOT="$(resolve_source)"; then
  echo "error: could not locate $PLUGIN_NAME source." >&2
  echo "Run from a git checkout, or install the plugin first:" >&2
  echo "  /plugin install $PLUGIN_NAME@$PLUGIN_NAME" >&2
  exit 1
fi

echo "source: $SOURCE_ROOT"
echo "dest:   $DEST"

mkdir -p "$DEST"

# Refuse to write into a destination that resolves into the source itself
# (would clobber source files). `cd -P` is POSIX and resolves symlinks,
# unlike GNU-only `readlink -f`.
DEST_REAL="$(cd -P "$DEST" 2>/dev/null && pwd)" || DEST_REAL=""
case "$DEST_REAL" in
  "$SOURCE_ROOT"|"$SOURCE_ROOT"/*)
    echo "error: $DEST resolves into the source ($DEST_REAL). Remove it and re-run." >&2
    exit 1
    ;;
esac

# `!` is POSIX (vs. GNU `-not`); `-print0` is supported by both GNU and BSD find.
find "$SOURCE_ROOT/skills" -name SKILL.md ! -path '*/node_modules/*' -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  rm -rf "$target"
  cp -R "$src" "$target"
  echo "installed $name"
done

echo "done."
