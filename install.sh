#!/usr/bin/env bash
# Install (symlink) skills from this repo into ~/.claude/skills/ (global)
# or ./.claude/skills/ (project). Edits in either location stay in sync
# because they're symlinks.
#
# Usage:
#   ./install.sh                              # install all skills globally
#   ./install.sh --global                     # (same as default)
#   ./install.sh --project                    # install into $(pwd)/.claude/skills/
#   ./install.sh <name>                       # install one skill (global)
#   ./install.sh --project <name>             # install one skill into current project
#   ./install.sh --uninstall [--global|--project] [name...]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

scope="global"
mode="install"
declare -a targets=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      scope="global"
      shift
      ;;
    --project)
      scope="project"
      shift
      ;;
    --uninstall)
      mode="uninstall"
      shift
      ;;
    -h|--help)
      awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"
      exit 0
      ;;
    --*)
      echo "unknown flag: $1" >&2
      exit 2
      ;;
    *)
      targets+=("$1")
      shift
      ;;
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

install_one() {
  local name="$1"
  local src="$REPO_ROOT/$name"
  local dst="$SKILLS_DIR/$name"

  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "skip: $name (no SKILL.md at $src)"
    return 1
  fi

  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      echo "ok:   $name (already linked in $scope)"
      return 0
    fi
    echo "warn: $dst is a symlink to $current, replacing"
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    echo "skip: $name ($dst exists and is not a symlink — move/remove it first)"
    return 1
  fi

  ln -s "$src" "$dst"
  echo "link: $name ($scope) -> $src"
}

uninstall_one() {
  local name="$1"
  local dst="$SKILLS_DIR/$name"
  local expected="$REPO_ROOT/$name"

  if [[ ! -L "$dst" ]]; then
    echo "skip: $name (not a symlink in $scope)"
    return 0
  fi

  local current
  current="$(readlink "$dst")"
  if [[ "$current" != "$expected" ]]; then
    echo "skip: $name (symlink points to $current, not this repo)"
    return 0
  fi

  rm "$dst"
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
