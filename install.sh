#!/usr/bin/env bash
# Links this repo's global rules and skills into ~/.claude (and ~/.codex when present).
# Safe to re-run. Anything it would replace is moved to ~/.claude/backups/<timestamp>/ first.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
backups="$HOME/.claude/backups/$(date +%Y%m%d%H%M%S)"

link() {
  local source="$1" target="$2"
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    mkdir -p "$backups"
    mv "$target" "$backups/"
    echo "backed up $target -> $backups/"
  fi
  ln -s "$source" "$target"
  echo "linked $target -> $source"
}

mkdir -p "$HOME/.claude/skills"
link "$repo/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
for skill in "$repo"/skills/*/; do
  link "${skill%/}" "$HOME/.claude/skills/$(basename "$skill")"
done

if [ -d "$HOME/.codex" ]; then
  link "$repo/AGENTS.md" "$HOME/.codex/AGENTS.md"
  mkdir -p "$HOME/.codex/skills"
  for skill in "$repo"/skills/*/; do
    link "${skill%/}" "$HOME/.codex/skills/$(basename "$skill")"
  done
fi
