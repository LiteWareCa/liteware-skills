#!/usr/bin/env bash
# install.sh — install Liteware skills into your AI coding assistant
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL="copilot"
SKILLS=()

usage() {
  echo "Usage: $0 [--tool copilot|claude|gemini] [--skills skill1,skill2]"
  echo
  echo "  --tool     Target AI assistant (default: copilot)"
  echo "  --skills   Comma-separated list of skill dirs to install (default: all)"
  echo
  echo "Examples:"
  echo "  $0"
  echo "  $0 --tool claude"
  echo "  $0 --tool gemini --skills liteware-project,liteware-python"
  exit 1
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool) TOOL="$2"; shift 2 ;;
    --skills) IFS=',' read -ra SKILLS <<< "$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1"; usage ;;
  esac
done

# Default: all skill directories
if [[ ${#SKILLS[@]} -eq 0 ]]; then
  mapfile -t SKILLS < <(find "$REPO_DIR" -maxdepth 1 -mindepth 1 -type d -not -name '.*' | xargs -I{} basename {})
fi

install_copilot() {
  local dest="$HOME/.copilot/skills"
  mkdir -p "$dest"
  for skill in "${SKILLS[@]}"; do
    local src="$REPO_DIR/$skill"
    [[ -d "$src" ]] || { echo "Warning: skill '$skill' not found, skipping"; continue; }
    rm -rf "$dest/$skill"
    cp -r "$src" "$dest/$skill"
    echo "✓ Installed $skill → $dest/$skill"
  done
}

install_claude() {
  local dest="$HOME/.claude/CLAUDE.md"
  mkdir -p "$(dirname "$dest")"
  # Strip YAML frontmatter (--- ... ---) and append instructions
  for skill in "${SKILLS[@]}"; do
    local src="$REPO_DIR/$skill/SKILL.md"
    [[ -f "$src" ]] || { echo "Warning: skill '$skill' not found, skipping"; continue; }
    echo "" >> "$dest"
    echo "<!-- liteware-skill: $skill -->" >> "$dest"
    # Strip frontmatter block (lines between first two ---)
    awk '/^---/{found++; next} found==1{next} {print}' "$src" >> "$dest"
    echo "✓ Appended $skill → $dest"
  done
}

install_gemini() {
  local dest="$HOME/.gemini/skills"
  mkdir -p "$dest"
  for skill in "${SKILLS[@]}"; do
    local src="$REPO_DIR/$skill"
    [[ -d "$src" ]] || { echo "Warning: skill '$skill' not found, skipping"; continue; }
    rm -rf "$dest/$skill"
    cp -r "$src" "$dest/$skill"
    echo "✓ Installed $skill → $dest/$skill"
  done
}

case "$TOOL" in
  copilot) install_copilot ;;
  claude)  install_claude ;;
  gemini)  install_gemini ;;
  *) echo "Unknown tool: $TOOL"; usage ;;
esac

echo
echo "Done. ${#SKILLS[@]} skill(s) installed for $TOOL."
