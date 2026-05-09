#!/usr/bin/env bash
set -euo pipefail

# install-skills.sh — install or update honzik-skills into ~/.claude/skills/.
#
# Cross-platform: copies files (no symlinks). Works on Linux, macOS, BSD,
# and Windows under Git Bash / MSYS2 / Cygwin / WSL.
#
# Usage:
#   install-skills.sh                       Install from local source.
#   install-skills.sh --from-github [REF]   Install from GitHub (REF: branch,
#                                           tag, or commit; default: main).
#   install-skills.sh -h | --help           Show this help.
#
# Local source resolution (without --from-github):
#   1. The git checkout this script lives in.
#   2. An installed honzik-skills plugin under ~/.claude.
#
# When invoked via `curl ... | bash`, --from-github is enabled automatically.

PLUGIN_NAME="honzik-skills"
GITHUB_REPO="hsmejky/skills"
DEST="$HOME/.claude/skills"

FROM_GITHUB=0
GITHUB_REF="main"

# Detect curl-pipe (no script file on disk) and default to remote mode.
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR=""
  FROM_GITHUB=1
fi

print_help() {
  sed -n '/^# install-skills.sh/,/^$/p' "${BASH_SOURCE[0]}" 2>/dev/null \
    | sed 's/^# \{0,1\}//' \
    || cat <<'EOF'
install-skills.sh — install or update honzik-skills into ~/.claude/skills/.
Run with --from-github to fetch from GitHub.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --from-github)
      FROM_GITHUB=1
      # Optional positional REF — only consume if the next arg doesn't look like a flag.
      if [ $# -gt 1 ] && [ "${2#-}" = "$2" ]; then
        GITHUB_REF="$2"
        shift
      fi
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      echo "Run with --help for usage." >&2
      exit 2
      ;;
  esac
  shift
done

is_honzik_plugin_dir() {
  local manifest="$1/.claude-plugin/plugin.json"
  [ -f "$manifest" ] || return 1
  grep -q "\"name\"[[:space:]]*:[[:space:]]*\"$PLUGIN_NAME\"" "$manifest" 2>/dev/null
}

resolve_source_local() {
  # 1. Repo source: parent of scripts/ is the repo root if we're in a checkout.
  if [ -n "$SCRIPT_DIR" ]; then
    local repo
    repo="$(cd -P "$SCRIPT_DIR/.." && pwd)"
    if is_honzik_plugin_dir "$repo" && [ -d "$repo/skills" ]; then
      printf '%s\n' "$repo"
      return 0
    fi
  fi

  # 2. Plugin install: scan ~/.claude for our manifest. Different Claude Code
  # versions place plugins in different subdirs, so we just look for the
  # manifest by name rather than hardcoding the layout.
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

download_to() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$out" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$out" "$url"
  else
    echo "error: need curl or wget to download from GitHub." >&2
    return 1
  fi
}

TMPDIR_DOWNLOAD=""
cleanup() {
  if [ -n "$TMPDIR_DOWNLOAD" ] && [ -d "$TMPDIR_DOWNLOAD" ]; then
    rm -rf "$TMPDIR_DOWNLOAD"
  fi
}
trap cleanup EXIT

resolve_source_github() {
  # GitHub serves tarballs at /archive/<ref>.tar.gz for any branch, tag, or sha.
  local url="https://github.com/$GITHUB_REPO/archive/$GITHUB_REF.tar.gz"
  TMPDIR_DOWNLOAD="$(mktemp -d 2>/dev/null)" \
    || TMPDIR_DOWNLOAD="$(mktemp -d -t honzik-skills.XXXXXX)"
  echo "downloading $url" >&2
  download_to "$url" "$TMPDIR_DOWNLOAD/skills.tar.gz"
  tar -xzf "$TMPDIR_DOWNLOAD/skills.tar.gz" -C "$TMPDIR_DOWNLOAD"
  rm -f "$TMPDIR_DOWNLOAD/skills.tar.gz"

  # GitHub names the top-level dir <repo>-<ref> with slashes mangled, so we
  # find the single extracted dir rather than guess.
  local extracted
  extracted="$(find "$TMPDIR_DOWNLOAD" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  if [ -z "$extracted" ] \
     || ! is_honzik_plugin_dir "$extracted" \
     || [ ! -d "$extracted/skills" ]; then
    echo "error: extracted tarball doesn't look like the $PLUGIN_NAME repo." >&2
    return 1
  fi
  printf '%s\n' "$extracted"
}

if [ "$FROM_GITHUB" = 1 ]; then
  SOURCE_ROOT="$(resolve_source_github)"
else
  if ! SOURCE_ROOT="$(resolve_source_local)"; then
    echo "error: could not locate $PLUGIN_NAME source locally." >&2
    echo "Run from a git checkout, install the plugin, or pass --from-github." >&2
    exit 1
  fi
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
