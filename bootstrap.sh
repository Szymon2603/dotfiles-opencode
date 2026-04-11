#!/usr/bin/env bash
# bootstrap.sh — jednorazowy setup maszyny
# Instaluje globalną konfigurację OpenCode z tego repo:
#   - własne skille i agenci z profiles/global.txt (symlinki)
#   - zewnętrzne skille z profiles/external-skills.txt (npx skills add)
#   - globalny AGENTS.md
#   - rejestruje opencode-install jako globalną komendę

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
OPENCODE_DIR="$HOME/.config/opencode"

mkdir -p "$OPENCODE_DIR/skills"
mkdir -p "$OPENCODE_DIR/agents"

# ── globalny AGENTS.md ──────────────────────────────────────────────────────────
if [[ -f "$DOTFILES/config/opencode/AGENTS.md" ]]; then
  ln -sf "$DOTFILES/config/opencode/AGENTS.md" "$OPENCODE_DIR/AGENTS.md"
  echo "→ AGENTS.md linked"
fi

# ── własne skille i agenci z profiles/global.txt ────────────────────────────────
GLOBAL_PROFILE="$DOTFILES/profiles/global.txt"
if [[ -f "$GLOBAL_PROFILE" ]]; then
  echo "→ Installing from profiles/global.txt..."
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue

    type="${line%%:*}"
    name="${line#*:}"
    name="$(echo "$name" | xargs)"

    case "$type" in
      skill)
        src="$DOTFILES/skills/$name"
        if [[ -d "$src" || -L "$src" ]]; then
          target="$OPENCODE_DIR/skills/$name"
          [[ -L "$target" ]] && rm "$target"
          ln -sf "$src" "$target"
          echo "  ✓ skill: $name"
        else
          echo "  ⚠ skill not found in skills/: $name"
        fi
        ;;
      agent)
        # szukaj pliku agenta z lub bez .md
        src=""
        [[ -f "$DOTFILES/agents/${name}.md" ]] && src="$DOTFILES/agents/${name}.md"
        [[ -f "$DOTFILES/agents/${name}"    ]] && src="$DOTFILES/agents/${name}"
        if [[ -n "$src" ]]; then
          basename_name="$(basename "$src")"
          target="$OPENCODE_DIR/agents/$basename_name"
          [[ -L "$target" ]] && rm "$target"
          ln -sf "$src" "$target"
          echo "  ✓ agent: $name"
        else
          echo "  ⚠ agent not found in agents/: $name"
        fi
        ;;
      *)
        echo "  ⚠ unknown type '$type' in profiles/global.txt"
        ;;
    esac
  done < "$GLOBAL_PROFILE"
fi

# ── zewnętrzne skille z profiles/external-skills.txt ───────────────────────────
EXT_FILE="$DOTFILES/profiles/external-skills.txt"
if [[ -f "$EXT_FILE" ]]; then
  echo "→ Installing external skills from profiles/external-skills.txt..."
  any=0
  while IFS= read -r skill || [[ -n "$skill" ]]; do
    [[ -z "$skill" || "$skill" == \#* ]] && continue
    echo "  installing: $skill"
    npx --yes skills add "$skill" --yes --global || echo "  ⚠ error installing $skill, skipping"
    any=1
  done < "$EXT_FILE"
  [[ "$any" -eq 0 ]] && echo "  (no external skills to install)"
fi

# ── rejestracja opencode-install ────────────────────────────────────────────────
echo "→ Registering opencode-install..."
bash "$DOTFILES/setup.sh"

echo ""
echo "✅ Bootstrap complete."
