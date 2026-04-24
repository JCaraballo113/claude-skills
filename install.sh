#!/usr/bin/env bash
# Install (copy) skills from this repo into ~/.claude/skills/ (global)
# or ./.claude/skills/ (project). Each installed skill carries a marker
# file (.installed-from) so `--uninstall` knows what this repo owns and
# won't touch skills from other sources.
#
# Usage:
#   ./install.sh                              # install all skills globally
#   ./install.sh --global                     # (same as default)
#   ./install.sh --project                    # install into $(pwd)/.claude/skills/
#   ./install.sh <name>                       # install one skill (global)
#   ./install.sh --project <name>             # install one skill into current project
#   ./install.sh --uninstall [--global|--project] [name...]
#
# Re-running install overwrites files owned by this repo. To sync updates
# pulled from origin: `git pull && ./install.sh`.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKER=".installed-from"

scope="global"
mode="install"
declare -a targets=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)    scope="global"; shift ;;
    --project)   scope="project"; shift ;;
    --uninstall) mode="uninstall"; shift ;;
    -h|--help)
      awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"
      exit 0
      ;;
    --*) echo "unknown flag: $1" >&2; exit 2 ;;
    *)   targets+=("$1"); shift ;;
  esac
done

if [[ "$scope" == "global" ]]; then
  SKILLS_DIR="$HOME/.claude/skills"
else
  SKILLS_DIR="$PWD/.claude/skills"
fi

mkdir -p "$SKILLS_DIR"

list_repo_skills() {
  find "$REPO_ROOT" -mindepth 2 -maxdepth 2 -name SKILL.md -type f \
    | sed "s|$REPO_ROOT/||; s|/SKILL.md||" \
    | sort
}

is_owned_by_this_repo() {
  # $1 is an installed skill dir. Returns 0 if the marker file names this repo.
  local dir="$1"
  local marker_file="$dir/$MARKER"
  [[ -f "$marker_file" ]] && grep -q "^repo=$REPO_ROOT\$" "$marker_file"
}

install_one() {
  local name="$1"
  local src="$REPO_ROOT/$name"
  local dst="$SKILLS_DIR/$name"

  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "skip: $name (no SKILL.md at $src)"
    return 1
  fi

  # If dst exists, it must either be a symlink we previously created, or a
  # copy owned by this repo. Otherwise bail to avoid clobbering user work.
  if [[ -L "$dst" ]]; then
    echo "info: $name was a symlink, replacing with copy"
    rm "$dst"
  elif [[ -d "$dst" ]]; then
    if ! is_owned_by_this_repo "$dst"; then
      echo "skip: $name ($dst exists and is not owned by this repo — move/remove it first)"
      return 1
    fi
    rm -rf "$dst"
  elif [[ -e "$dst" ]]; then
    echo "skip: $name ($dst exists as a file — move/remove it first)"
    return 1
  fi

  cp -R "$src" "$dst"

  local sha="unknown"
  if sha="$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null)"; then :; fi

  {
    echo "repo=$REPO_ROOT"
    echo "sha=$sha"
    echo "installed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > "$dst/$MARKER"

  echo "copy: $name ($scope) from $src@$sha"
}

uninstall_one() {
  local name="$1"
  local dst="$SKILLS_DIR/$name"

  if [[ -L "$dst" ]]; then
    # Legacy: was a symlink from an older install.sh. Only remove if it
    # pointed at this repo.
    local target
    target="$(readlink "$dst")"
    if [[ "$target" == "$REPO_ROOT/$name" ]]; then
      rm "$dst"
      echo "rm:   $name ($scope, legacy symlink)"
    else
      echo "skip: $name (symlink points to $target, not this repo)"
    fi
    return 0
  fi

  if [[ ! -d "$dst" ]]; then
    echo "skip: $name (not installed in $scope)"
    return 0
  fi

  if ! is_owned_by_this_repo "$dst"; then
    echo "skip: $name (not owned by this repo — $MARKER missing or repo mismatch)"
    return 0
  fi

  rm -rf "$dst"
  echo "rm:   $name ($scope)"
}

if [[ ${#targets[@]} -eq 0 ]]; then
  mapfile -t targets < <(list_repo_skills)
fi

if [[ ${#targets[@]} -eq 0 ]]; then
  echo "no skills found in $REPO_ROOT"
  exit 0
fi

for name in "${targets[@]}"; do
  if [[ "$mode" == "install" ]]; then
    install_one "$name" || true
  else
    uninstall_one "$name" || true
  fi
done
